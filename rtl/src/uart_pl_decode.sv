module uart_pl_decode
    import uart_apb4_intf_pkg::*;
    import uart_pl_pkg::*;
(
    output uart_apb4_intf__in_t hwif_in,
    input uart_apb4_intf__out_t hwif_out,

    output baudgen_cfg_t baudgen_cfg_o,
    output driver_cfg_t  driver_cfg_o, 

    fifo_tx_hwif_intf.master fifo_tx,
    fifo_rx_hwif_intf.master fifo_rx,
    rx_hwif_intf.master      rx
);

    uart_apb4_intf__in_t hwif_in_fifo_tx, hwif_in_fifo_rx, hwif_in_rx;

    /* config */
    always_comb begin 
        baudgen_cfg_o.over8    = hwif_out.UART_CR.OVER8.value;
        baudgen_cfg_o.div_frac = hwif_out.UART_BRR.DIV_FRAC.value;
        baudgen_cfg_o.div_mant = hwif_out.UART_BRR.DIV_MANT.value;

        driver_cfg_o.over8     = hwif_out.UART_CR.OVER8.value;
        driver_cfg_o.stop_bits = hwif_out.UART_CR.SB.value;
    end

    /* fifo_rx */
    always_comb begin 
        fifo_rx.rd_req_rx = hwif_out.UART_RX.req & ~hwif_out.UART_RX.req_is_wr;
        fifo_rx.rd_req_sr = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;

        hwif_in_fifo_rx.UART_RX.rd_data          = fifo_rx.rd_data;
        hwif_in_fifo_rx.UART_SR.rd_data.RXFNE    = fifo_rx.rxfne;
        hwif_in_fifo_rx.UART_SR.rd_data.RXFLEVEL = fifo_rx.rxflevel;

        hwif_in_fifo_rx.UART_RX.rd_ack = hwif_out.UART_RX.req & ~hwif_out.UART_RX.req_is_wr;
        hwif_in_fifo_rx.UART_SR.rd_ack = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;
    end

    /* fifo_tx */
    always_comb begin
        fifo_tx.wr_req_tx = hwif_out.UART_TX.req & hwif_out.UART_TX.req_is_wr;
        fifo_tx.rd_req_sr = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;

        fifo_tx.wr_data                         = hwif_out.UART_TX.wr_data;
        hwif_in_fifo_tx.UART_SR.rd_data.TXFNF    = fifo_tx.txfnf;
        hwif_in_fifo_tx.UART_SR.rd_data.TXFSPACE = fifo_tx.txfspace;

        hwif_in_fifo_tx.UART_TX.wr_ack = hwif_out.UART_TX.req & hwif_out.UART_TX.req_is_wr;
        hwif_in_fifo_tx.UART_SR.rd_ack = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;
    end 

    /* uart_rx driver */
    always_comb begin 
        rx.rd_req_sr = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;

        hwif_in_rx.UART_SR.rd_data.ORE = rx.ore;

        hwif_in_rx.UART_SR.rd_ack = hwif_out.UART_SR.req & ~hwif_out.UART_SR.req_is_wr;
    end

    always_comb begin 
        hwif_in = '{default:0};

        /* SR read ack */
        hwif_in.UART_SR.rd_ack = hwif_in_fifo_tx.UART_SR.rd_ack | hwif_in_fifo_rx.UART_SR.rd_ack |
            hwif_in_rx.UART_SR.rd_ack;

        /* fifo_tx */
        hwif_in.UART_TX.wr_ack = hwif_in_fifo_tx.UART_TX.wr_ack;
        hwif_in.UART_SR.rd_data.TXFSPACE = hwif_in_fifo_tx.UART_SR.rd_data.TXFSPACE;
        hwif_in.UART_SR.rd_data.TXFNF = hwif_in_fifo_tx.UART_SR.rd_data.TXFNF;

        /* fifo_rx */
        hwif_in.UART_RX.rd_ack = hwif_in_fifo_rx.UART_RX.rd_ack;
        hwif_in.UART_SR.rd_data.RXFLEVEL = hwif_in_fifo_rx.UART_SR.rd_data.RXFLEVEL;
        hwif_in.UART_SR.rd_data.RXFNE = hwif_in_fifo_rx.UART_SR.rd_data.RXFNE;
        hwif_in.UART_RX.rd_data = hwif_in_fifo_rx.UART_RX.rd_data;

        /* rx driver */
        hwif_in.UART_SR.rd_data.ORE =  hwif_in_rx.UART_SR.rd_data.ORE;
    end

endmodule