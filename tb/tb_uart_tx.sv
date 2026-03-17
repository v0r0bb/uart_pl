 module tb_uart_tx;

    localparam real CLK_FREQ  = 10_000_000;
    localparam real BAUD_RATE = 115200;
    localparam bit  OVER8     = 0;
    localparam bit  SB        = 0;

    localparam real UART_DIV = (CLK_FREQ / (8 * (2 - OVER8) * BAUD_RATE));

    localparam int DIV_MANT = $floor(UART_DIV);

    localparam int DIV_FRAC = (OVER8) ? 
        $rtoi((UART_DIV - DIV_MANT) * 16) : 
        $rtoi((UART_DIV - DIV_MANT) * 8);


    localparam UART_SR  = 32'h0;
    localparam UART_CR  = 32'h4;
    localparam UART_RX  = 32'h8;
    localparam UART_TX  = 32'hC;
    localparam UART_BRR = 32'h10;

    logic clk_i;
    logic rst_n;

    logic [31:0] PADDR;
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;
    
    logic tx_o, rx_i;

    uart_pl DUT (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .tx_o(tx_o),

        .PPROT(0),
        .PSTRB(4'hF),
        .PSLVERR(),
        .rx_i(rx_i)  
    );
    assign rx_i = tx_o;

    initial begin 
        clk_i = 0;
        forever #50 clk_i = ~clk_i;
    end

    initial begin
        rst_n = 0;
        #100 rst_n = 1;
    end

    task apb_write(input [31:0] addr, input [31:0] data);
        @(posedge clk_i);
        PSEL    <= 1;
        PENABLE <= 0;
        PWRITE  <= 1;
        PADDR   <= addr;
        PWDATA  <= data;
        @(posedge clk_i);
        
        PENABLE <= 1;
        do begin
            @(posedge clk_i);
        end
        while (~PREADY);
        PSEL    <= 0;
        PENABLE <= 0;
    endtask

    task apb_read(input [31:0] addr, output [31:0] data);
        @(posedge clk_i);
        PSEL    <= 1;
        PENABLE <= 0;
        PWRITE  <= 0;
        PADDR   <= addr;
        PWDATA  <= data;
        @(posedge clk_i);
        
        PENABLE <= 1;
        do begin
            @(posedge clk_i);
        end
        while (~PREADY);
        data <= PRDATA;
        PSEL    <= 0;
        PENABLE <= 0;
    endtask

    int data;

    initial begin 
        PSEL    <= 0;
        PENABLE <= 0;
        PWRITE  <= 0;
        PADDR   <= '0;
        PWDATA  <= 0;

        wait(rst_n);
        apb_read(UART_SR, data);
        apb_write(UART_BRR, DIV_MANT << 4 | DIV_FRAC);
        apb_write(UART_CR, OVER8 << 1 | SB);
        // apb_write(UART_TX, 32'hAA);
        // apb_write(UART_TX, 32'h55);
        // apb_read(UART_SR, data);

        repeat (16) apb_write(UART_TX, $urandom_range(0, 255));
        apb_read(UART_SR, data);
        #200_000;
    end

    always @(posedge clk_i) begin
        if (PSEL & PENABLE) 
            $display("[%0t] APB transaction: %s addr = 0x%h, data = 0x%h", 
                $time(), PWRITE ? "WRITE" : "READ", PADDR, PWRITE ? PWDATA : PRDATA);
    end

    always @(posedge clk_i) begin
        if (DUT.i_fifo_rx.hwif_in.UART_SR.rd_data.RXFNE) begin
            $display("[%0t] RX: RXFNE=1, data = 0x%h", $time, DUT.i_fifo_rx.hwif_in.UART_RX.rd_data);
            apb_read(UART_SR, data);
            apb_read(UART_RX, data);
        end
    end


 endmodule 