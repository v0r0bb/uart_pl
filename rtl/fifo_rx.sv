import uart_apb4_intf_pkg::*;

module fifo_rx (
    input clk_i, 
    input rst_n,

    output uart_apb4_intf__in_t hwif_in,
    input uart_apb4_intf__out_t hwif_out,

    input rx_vld_i,
    input [7:0] rx_data_i,
    output rx_rdy_o
);

    logic empty, full;
    logic [4:0] cnt;

    fifo_generic #(
        .WIDTH(8), .DEPTH(16)
    ) i_fifo (
        .clk_i(clk_i), .rst(~rst_n),
        .push(rx_vld_i & ~full),
        .pop(hwif_out.UART_RX.req & ~hwif_out.UART_RX.req_is_wr & ~empty),
        .wr_data(rx_data_i),
        .rd_data(hwif_in.UART_RX.rd_data),
        .empty(empty), .full(full),
        .cnt(cnt)
    );

    assign rx_rdy_o = ~full;

    assign hwif_in.UART_SR.rd_data.RXFLEVEL = cnt;
    assign hwif_in.UART_SR.rd_data.RXFNE    = ~empty;

    assign hwif_in.UART_RX.rd_ack = hwif_out.UART_RX.req & ~hwif_out.UART_RX.req_is_wr;
    assign hwif_in.UART_SR.rd_ack = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;

endmodule