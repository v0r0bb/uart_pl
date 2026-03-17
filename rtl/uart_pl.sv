module uart_pl #(
	parameter C_S_APB_DATA_WIDTH = 32,
    parameter C_S_APB_ADDR_WIDTH = 32
) (
    input clk_i,
    input rst_n, 

    input  [C_S_APB_ADDR_WIDTH-1:0]   PADDR,
    input                             PSEL,
    input                             PENABLE,
    input                             PWRITE,
    input  [2:0]                      PPROT,
    input  [C_S_APB_DATA_WIDTH-1:0]   PWDATA,
    output [C_S_APB_DATA_WIDTH-1:0]   PRDATA,
    input  [C_S_APB_DATA_WIDTH/8-1:0] PSTRB,
    output                            PREADY,
    output                            PSLVERR,

    input  rx_i, 
    output tx_o
);

    import uart_apb4_intf_pkg::*;

    uart_apb4_intf__out_t hwif_out;
    uart_apb4_intf__in_t hwif_in;
    uart_apb4_intf__in_t hwif_in_tx, hwif_in_rx;

    apb4_intf #(
    	.DATA_WIDTH(C_S_APB_DATA_WIDTH),
    	.ADDR_WIDTH(C_S_APB_ADDR_WIDTH)
	) s_apb();

    assign s_apb.PADDR   = PADDR;
    assign s_apb.PSEL    = PSEL ;
    assign s_apb.PENABLE = PENABLE;
    assign s_apb.PWRITE  = PWRITE;
    assign s_apb.PPROT   = PPROT;
    assign s_apb.PWDATA  = PWDATA;
    assign s_apb.PSTRB   = PSTRB;

    assign PRDATA  = s_apb.PRDATA;
    assign PREADY  = s_apb.PREADY;
    assign PSLVERR = s_apb.PSLVERR;

    logic uart_clk;

    logic       rx_vld;
    logic [7:0] rx_data;
    logic       rx_rdy;

    logic       tx_vld;
    logic [7:0] tx_data;
    logic       tx_rdy;

    always_comb begin 
        hwif_in = '{default:0};

        /* SR read ack */
        hwif_in.UART_SR.rd_ack = hwif_in_tx.UART_SR.rd_ack | hwif_in_rx.UART_SR.rd_ack;

        /* tx_fifo */
        hwif_in.UART_TX.wr_ack = hwif_in_tx.UART_TX.wr_ack;
        hwif_in.UART_SR.rd_data.TXFSPACE = hwif_in_tx.UART_SR.rd_data.TXFSPACE;
        hwif_in.UART_SR.rd_data.TXFNF = hwif_in_tx.UART_SR.rd_data.TXFNF;

        /* rx_fifo */
        hwif_in.UART_RX.rd_ack = hwif_in_rx.UART_RX.rd_ack;
        hwif_in.UART_SR.rd_data.RXFLEVEL = hwif_in_rx.UART_SR.rd_data.RXFLEVEL;
        hwif_in.UART_SR.rd_data.RXFNE = hwif_in_rx.UART_SR.rd_data.RXFNE;
        hwif_in.UART_RX.rd_data = hwif_in_rx.UART_RX.rd_data;
    end

    uart_apb4_intf i_uart_apb4_intf (
        .clk(clk_i), .rst(~rst_n),
        .s_apb(s_apb.slave),
        .hwif_in(hwif_in),
        .hwif_out(hwif_out)
    );

    fifo_tx i_fifo_tx (
        .clk_i(clk_i), .rst_n(rst_n),
        .hwif_in(hwif_in_tx),
        .hwif_out(hwif_out),
        .tx_vld_o(tx_vld),
        .tx_data_o(tx_data),
        .tx_rdy_i(tx_rdy)
    );

    fifo_rx i_fifo_rx (
        .clk_i(clk_i), .rst_n(rst_n),
        .hwif_in(hwif_in_rx),
        .hwif_out(hwif_out),
        .rx_vld_i(rx_vld),
        .rx_data_i(rx_data),
        .rx_rdy_o(rx_rdy)
    );

    uart_baudgen i_uart_baudgen (
        .clk_i(clk_i), .rst_n(rst_n),
        .hwif_out(hwif_out),
        .uart_clk_o(uart_clk)
    );

    uart_tx i_uart_tx (
        .clk_i(clk_i), .rst_n(rst_n),
        .hwif_out(hwif_out),
        .uart_clk_i(uart_clk),
        .tx_vld_i(tx_vld),
        .tx_data_i(tx_data),
        .tx_rdy_o(tx_rdy),
        .tx_o(tx_o)
    );

    uart_rx i_uart_rx (
        .clk_i(clk_i), .rst_n(rst_n),
        .hwif_out(hwif_out),
        .uart_clk_i(uart_clk),
        .rx_vld_o(rx_vld),
        .rx_data_o(rx_data),
        .rx_rdy_i(rx_rdy),
        .rx_i(rx_i)
    );

endmodule