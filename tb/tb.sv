`timescale 1ns/1ps

module tb;
    import test_pkg::*;
    import uart_pl_pkg::*;

    logic clk_i, rst_n;
    logic tx_o, rx_i;

    apb4_intf#(.ADDR_WIDTH(ADDR_WIDTH)) apb4_if();
    sync_intf sync_if(.clk_i(clk_i), .rst_n(rst_n));
    uart_intf uart_if();

    assign uart_if.data     = DUT.i_uart_pl_top.i_uart_rx.rx_data_o;
    assign uart_if.vld      = DUT.i_uart_pl_top.i_uart_rx.rx_vld_o;
    assign uart_if.rdy      = DUT.i_uart_pl_top.i_uart_rx.rx_rdy_i;
    assign uart_if.rxfne    = ~DUT.i_uart_pl_top.i_fifo_rx.empty;
    assign uart_if.txfnf    = ~DUT.i_uart_pl_top.i_fifo_tx.full;
    assign uart_if.rxflevel = DUT.i_uart_pl_top.i_fifo_rx.cnt;
    assign uart_if.txfspace = FIFO_CNT_WIDTH'(FIFO_DEPTH) - DUT.i_uart_pl_top.i_fifo_tx.cnt;

    uart_pl_wrapper DUT (
        .clk_i(clk_i),
        .rst_n(rst_n),

        .PADDR(apb4_if.PADDR),
        .PSEL(apb4_if.PSEL),
        .PENABLE(apb4_if.PENABLE),
        .PWRITE(apb4_if.PWRITE),
        .PWDATA(apb4_if.PWDATA),
        .PRDATA(apb4_if.PRDATA),
        .PREADY(apb4_if.PREADY),
        .PPROT(apb4_if.PPROT),
        .PSTRB(apb4_if.PSTRB),
        .PSLVERR(apb4_if.PSLVERR),

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