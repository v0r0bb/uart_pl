module fifo_tx 
    import uart_pl_pkg::*;
(
    input clk_i, 
    input rst_n,

    fifo_tx_hwif_intf.slave fifo_tx_hwif,

    output                   tx_vld_o,
    output [DATA_BITS - 1:0] tx_data_o,
    input                    tx_rdy_i
);

    logic empty, full;

    logic [FIFO_CNT_WIDTH - 1:0] cnt;

    fifo_generic #(
        .WIDTH(DATA_BITS), .DEPTH(FIFO_DEPTH)
    ) i_fifo (
        .clk_i(clk_i), .rst_n(rst_n),
        .push(fifo_tx_hwif.wr_req_tx & ~full),
        .pop(tx_rdy_i & ~empty),
        .wr_data(fifo_tx_hwif.wr_data),
        .rd_data(tx_data_o),
        .empty(empty), .full(full),
        .cnt(cnt)
    );

    assign tx_vld_o = ~empty;

    assign fifo_tx_hwif.txfspace = FIFO_CNT_WIDTH'(FIFO_DEPTH) - cnt;
    assign fifo_tx_hwif.txfnf    = ~full;

endmodule