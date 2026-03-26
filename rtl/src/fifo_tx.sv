module fifo_tx 
    import uart_pl_pkg::*;
(
    input clk_i, 
    input rst_n,

    input fifo_tx_hwif_out_t fifo_tx_hwif_out_i,
    output fifo_tx_hwif_in_t fifo_tx_hwif_in_o,

    output                   tx_vld_o,
    output [DATA_BITS - 1:0] tx_data_o,
    input                    tx_rdy_i
);

    logic empty, full;

    logic [FIFO_DEPTH_CNT_WIDTH - 1:0] cnt;

    fifo_generic #(
        .WIDTH(DATA_BITS), .DEPTH(FIFO_DEPTH)
    ) i_fifo (
        .clk_i(clk_i), .rst(~rst_n),
        .push(fifo_tx_hwif_out_i.wr_req_tx & ~full),
        .pop(tx_rdy_i & ~empty),
        .wr_data(fifo_tx_hwif_out_i.wr_data),
        .rd_data(tx_data_o),
        .empty(empty), .full(full),
        .cnt(cnt)
    );

    assign tx_vld_o = ~empty;

    assign fifo_tx_hwif_in_o.txfspace = FIFO_DEPTH_CNT_WIDTH'(FIFO_DEPTH) - cnt;
    assign fifo_tx_hwif_in_o.txfnf    = ~full;

endmodule