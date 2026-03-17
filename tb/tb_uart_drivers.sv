`timescale 1ns/1ps
import uart_apb4_intf_pkg::*;

module tb_uart_drivers;

    localparam real CLK_FREQ  = 10_000_000;
    localparam real BAUD_RATE = 115200;
    localparam bit  OVER8     = 0;
    localparam bit  SB        = 0;

    localparam real UART_DIV = (CLK_FREQ / (8 * (2 - OVER8) * BAUD_RATE));

    localparam int DIV_MANT = $floor(UART_DIV);

    localparam int DIV_FRAC = (OVER8) ? 
        $rtoi((UART_DIV - DIV_MANT) * 16) : 
        $rtoi((UART_DIV - DIV_MANT) * 8);

    logic clk_i, rst_n;

    logic tx_o, rx_i;

    logic       tx_vld_i;
    logic [7:0] tx_data_i;
    logic       tx_rdy_o;

    logic       rx_vld_o;
    logic [7:0] rx_data_o;
    logic       rx_rdy_i;

    uart_apb4_intf__out_t hwif_out;

    /* 10 MHz */
    initial begin 
        clk_i = 0;
        forever #50 clk_i = ~clk_i;
    end

    // initial begin 
    //     uart_clk_i = 0;
    //     forever #542 begin 
    //         @(posedge clk_i);
    //         uart_clk_i = 1;
    //         @(negedge clk_i)
    //         uart_clk_i = 0;
    //     end
    // end

    initial begin
        rst_n = 0;
        #100 rst_n = 1;
    end

    assign rx_i = tx_o;

    uart_rx DUT_uart_rx (
        .clk_i      (clk_i), 
        .rst_n      (rst_n),
        .hwif_out   (hwif_out),
        .uart_clk_i (uart_clk),
        .rx_vld_o   (rx_vld_o),
        .rx_data_o  (rx_data_o),
        .rx_rdy_i   (rx_rdy_i),
        .rx_i       (rx_i)
    );

    uart_tx DUT_uart_tx (
        .clk_i      (clk_i), 
        .rst_n      (rst_n),
        .hwif_out   (hwif_out),
        .uart_clk_i (uart_clk),
        .tx_vld_i   (tx_vld_i),
        .tx_data_i  (tx_data_i),
        .tx_rdy_o   (tx_rdy_o),
        .tx_o       (tx_o)
    );

    uart_baudgen DUT_uart_baudgen (
        .clk_i      (clk_i), 
        .rst_n      (rst_n),
        .hwif_out   (hwif_out),
        .uart_clk_o (uart_clk)
    );

    initial begin
        hwif_out.UART_CR.OVER8.value     <= OVER8; 
        hwif_out.UART_CR.SB.value        <= SB; 
        hwif_out.UART_BRR.DIV_FRAC.value <= DIV_FRAC;
        hwif_out.UART_BRR.DIV_MANT.value <= DIV_MANT;

        rx_rdy_i <= 1'b1;
        tx_vld_i <= 1'b0;

        wait(rst_n);
        repeat(10) @(posedge clk_i);

        repeat (3) transmission_byte();
        #150_000;
        $display("Simulation finished");
        $finish;
    end

    task transmission_byte();
            bit [7:0] data;
            data <= $urandom_range(1, 255);
            @(posedge clk_i);

            wait(tx_rdy_o);
            tx_data_i <= data;
            tx_vld_i <= 1;
            @(posedge clk_i);
            tx_vld_i <= 0;
            // @(posedge clk_i);

            $display("[%0t] [TX]: %h", $time(), data);
    endtask

    always @(posedge clk_i) begin
        if (rx_vld_o) 
            $display("[%0t] [RX]: %h", $time(), rx_data_o);
    end

    initial begin
        #300_000; 
        $error("Simulation timeout!");
    end

endmodule
