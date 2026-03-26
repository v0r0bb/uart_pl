module fifo_rx 
    import uart_pl_pkg::*;
(
    input clk_i, 
    input rst_n,

    input fifo_rx_hwif_out_t fifo_rx_hwif_out_i,
    output fifo_rx_hwif_in_t fifo_rx_hwif_in_o,

    input                   rx_vld_i,
    input [DATA_BITS - 1:0] rx_data_i,
    output                  rx_rdy_o
);

    logic empty, full;
    
    logic [FIFO_DEPTH_CNT_WIDTH - 1:0] cnt;

    fifo_generic #(
        .WIDTH(DATA_BITS), .DEPTH(FIFO_DEPTH)
    ) i_fifo (
        .clk_i(clk_i), .rst(~rst_n),
        .push(rx_vld_i & ~full),
        .pop(fifo_rx_hwif_out_i.rd_req_rx & ~empty),
        .wr_data(rx_data_i),
        .rd_data(fifo_rx_hwif_in_o.rd_data),
        .empty(empty), .full(full),
        .cnt(cnt)
    );

    assign rx_rdy_o = ~full;

    assign fifo_rx_hwif_in_o.rxflevel = cnt;
    assign fifo_rx_hwif_in_o.rxfne    = ~empty;

endmodule