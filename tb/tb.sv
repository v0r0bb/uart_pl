`timescale 1ns/1ps

module tb;
    import test_pkg::*;
    import uart_pl_pkg::*;

    logic clk_i, rst_n;
    logic tx_o, rx_i;

    apb4_intf#(.ADDR_WIDTH(ADDR_WIDTH)) apb4_if();
    sync_intf sync_if(.clk_i(clk_i), .rst_n(rst_n));
    uart_intf uart_if();

    assign uart_if.data     = DUT.i_uart_rx.rx_data_o;
    assign uart_if.vld      = DUT.i_uart_rx.rx_vld_o;
    assign uart_if.rdy      = DUT.i_uart_rx.rx_rdy_i;
    assign uart_if.rxfne    = ~DUT.i_fifo_rx.empty;
    assign uart_if.txfnf    = ~DUT.i_fifo_tx.full;
    assign uart_if.rxflevel = DUT.i_fifo_rx.cnt;
    assign uart_if.txfspace = FIFO_DEPTH_CNT_WIDTH'(FIFO_DEPTH) - DUT.i_fifo_tx.cnt;

    uart_pl_top DUT (
        .clk_i(clk_i),
        .rst_n(rst_n),

        .paddr(apb4_if.PADDR),
        .psel(apb4_if.PSEL),
        .penable(apb4_if.PENABLE),
        .pwrite(apb4_if.PWRITE),
        .pwdata(apb4_if.PWDATA),
        .prdata(apb4_if.PRDATA),
        .pready(apb4_if.PREADY),
        .pprot(apb4_if.PPROT),
        .pstrb(apb4_if.PSTRB),
        .pslverr(apb4_if.PSLVERR),

        .tx_o(tx_o),
        .rx_i(rx_i)  
    );

    assign rx_i = tx_o;

    initial begin 
        clk_i = 0;
        forever #50 clk_i = ~clk_i;
    end

    task reset;
        rst_n = 0;
        repeat (5) @(posedge clk_i);
        rst_n = 1;
    endtask

    initial begin 
        test_base test;
        test_fifo test_f;

        $display("BASE TEST");
        reset();
        test = new(apb4_if, sync_if, uart_if);
        test.run();
        $display("Base test was finished");

        $display("FIFO TEST");
        reset();
        test_f = new(apb4_if, sync_if, uart_if);
        test_f.run();
        $display("Fifo test was finished");

        $finish();
    end
endmodule 