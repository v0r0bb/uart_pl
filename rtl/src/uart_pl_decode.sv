module uart_pl_decode
    import uart_apb4_intf_pkg::*,
           uart_pl_pkg::*;
(
    output uart_apb4_intf__in_t hwif_in,
    input uart_apb4_intf__out_t hwif_out,

    output baudgen_cfg_t baudgen_cfg_o,

    output fifo_rx_hwif_out_t fifo_rx_hwif_out_o,
    input fifo_rx_hwif_in_t   fifo_rx_hwif_in_i,

    output fifo_tx_hwif_out_t fifo_tx_hwif_out_o,
    input fifo_tx_hwif_in_t   fifo_tx_hwif_in_i,

    output rx_hwif_out_t rx_hwif_out_o,
    input rx_hwif_in_t   rx_hwif_in_i,

    output driver_cfg_t driver_cfg_o
);

    uart_apb4_intf__in_t hwif_in_fifo_tx, hwif_in_fifo_rx, hwif_in_rx;

    always_comb begin 
        baudgen_cfg_o.over8    = hwif_out.UART_CR.OVER8.value;
        baudgen_cfg_o.div_frac = hwif_out.UART_BRR.DIV_FRAC.value;
        baudgen_cfg_o.div_mant = hwif_out.UART_BRR.DIV_MANT.value;
    end

    always_comb begin 
        driver_cfg_o.over8     = hwif_out.UART_CR.OVER8.value;
        driver_cfg_o.stop_bits = hwif_out.UART_CR.SB.value;
    end

    always_comb begin 
        fifo_rx_hwif_out_o.rd_req_rx = hwif_out.UART_RX.req & ~hwif_out.UART_RX.req_is_wr;
        fifo_rx_hwif_out_o.rd_req_sr = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;

        hwif_in_fifo_rx.UART_RX.rd_data          = fifo_rx_hwif_in_i.rd_data;
        hwif_in_fifo_rx.UART_SR.rd_data.RXFNE    = fifo_rx_hwif_in_i.rxfne;
        hwif_in_fifo_rx.UART_SR.rd_data.RXFLEVEL = fifo_rx_hwif_in_i.rxflevel;

        hwif_in_fifo_rx.UART_RX.rd_ack = hwif_out.UART_RX.req & ~hwif_out.UART_RX.req_is_wr;
        hwif_in_fifo_rx.UART_SR.rd_ack = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;
    end

    always_comb begin
        fifo_tx_hwif_out_o.wr_req_tx = hwif_out.UART_TX.req & hwif_out.UART_TX.req_is_wr;
        fifo_tx_hwif_out_o.rd_req_sr = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;

        fifo_tx_hwif_out_o.wr_data               = hwif_out.UART_TX.wr_data;
        hwif_in_fifo_tx.UART_SR.rd_data.TXFNF    = fifo_tx_hwif_in_i.txfnf;
        hwif_in_fifo_tx.UART_SR.rd_data.TXFSPACE = fifo_tx_hwif_in_i.txfspace;

        hwif_in_fifo_tx.UART_TX.wr_ack = hwif_out.UART_TX.req & hwif_out.UART_TX.req_is_wr;
        hwif_in_fifo_tx.UART_SR.rd_ack = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;
    end 

    always_comb begin 
        rx_hwif_out_o.rd_req_sr = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;

        hwif_in_rx.UART_SR.rd_data.ORE = rx_hwif_in_i.ore;

        hwif_in_rx.UART_SR.rd_ack = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;
    end

    always_comb begin 
        hwif_in = '{default:0};

        /* SR read ack */
        hwif_in.UART_SR.rd_ack = hwif_in_fifo_tx.UART_SR.rd_ack | hwif_in_fifo_rx.UART_SR.rd_ack |
            hwif_in_rx.UART_SR.rd_ack;

        /* tx_fifo */
        hwif_in.UART_TX.wr_ack = hwif_in_fifo_tx.UART_TX.wr_ack;
        hwif_in.UART_SR.rd_data.TXFSPACE = hwif_in_fifo_tx.UART_SR.rd_data.TXFSPACE;
        hwif_in.UART_SR.rd_data.TXFNF = hwif_in_fifo_tx.UART_SR.rd_data.TXFNF;

        /* rx_fifo */
        hwif_in.UART_RX.rd_ack = hwif_in_fifo_rx.UART_RX.rd_ack;
        hwif_in.UART_SR.rd_data.RXFLEVEL = hwif_in_fifo_rx.UART_SR.rd_data.RXFLEVEL;
        hwif_in.UART_SR.rd_data.RXFNE = hwif_in_fifo_rx.UART_SR.rd_data.RXFNE;
        hwif_in.UART_RX.rd_data = hwif_in_fifo_rx.UART_RX.rd_data;

        /* rx driver */
        hwif_in.UART_SR.rd_data.ORE =  hwif_in_rx.UART_SR.rd_data.ORE;
    end

endmodule