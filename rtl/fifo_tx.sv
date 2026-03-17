import uart_apb4_intf_pkg::*;

module fifo_tx (
    input clk_i, 
    input rst_n,

    output uart_apb4_intf__in_t hwif_in,
    input uart_apb4_intf__out_t hwif_out,

    output tx_vld_o,
    output [7:0] tx_data_o,
    input tx_rdy_i
);

    logic empty, full;
    logic [4:0] cnt;

    fifo_generic #(
        .WIDTH(8), .DEPTH(16)
    ) i_fifo (
        .clk_i(clk_i), .rst(~rst_n),
        .push(hwif_out.UART_TX.req & hwif_out.UART_TX.req_is_wr & ~full),
        .pop(tx_rdy_i & ~empty),
        .wr_data(hwif_out.UART_TX.wr_data),
        .rd_data(tx_data_o),
        .empty(empty), .full(full),
        .cnt(cnt)
    );

    assign tx_vld_o = ~empty;

    assign hwif_in.UART_SR.rd_data.TXFSPACE = 5'd16 - cnt;
    assign hwif_in.UART_SR.rd_data.TXFNF    = ~full;

    assign hwif_in.UART_TX.wr_ack = hwif_out.UART_TX.req & hwif_out.UART_TX.req_is_wr;
    assign hwif_in.UART_SR.rd_ack = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;

endmodule