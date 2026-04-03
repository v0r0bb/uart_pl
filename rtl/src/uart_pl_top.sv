module uart_pl_top
#(
    localparam ADDR_WIDTH = 5,
    localparam DATA_WIDTH = 32
) (
    input clk_i,
    input rst_n, 

    input  [ADDR_WIDTH - 1:0]   paddr,
    input                       psel,
    input                       penable,
    input                       pwrite,
    input  [2:0]                pprot,
    input  [DATA_WIDTH - 1:0]   pwdata,
    output [DATA_WIDTH - 1:0]   prdata,
    input  [DATA_WIDTH/8 - 1:0] pstrb,
    output                      pready,
    output                      pslverr,

    input  rx_i, 
    output tx_o
);

    import uart_apb4_intf_pkg::*;
    import uart_pl_pkg::*;

    uart_apb4_intf__out_t hwif_out;
    uart_apb4_intf__in_t  hwif_in;

    apb4_intf #(
    	.DATA_WIDTH(DATA_WIDTH),
    	.ADDR_WIDTH(ADDR_WIDTH)
	) s_apb();

    assign s_apb.PADDR   = paddr;
    assign s_apb.PSEL    = psel ;
    assign s_apb.PENABLE = penable;
    assign s_apb.PWRITE  = pwrite;
    assign s_apb.PPROT   = pprot;
    assign s_apb.PWDATA  = pwdata;
    assign s_apb.PSTRB   = pstrb;

    assign prdata  = s_apb.PRDATA;
    assign pready  = s_apb.PREADY;
    assign pslverr = s_apb.PSLVERR;

    logic uart_strb;

    logic                   rx_vld;
    logic [DATA_BITS - 1:0] rx_data;
    logic                   rx_rdy;

    logic                   tx_vld;
    logic [DATA_BITS - 1:0] tx_data;
    logic                   tx_rdy;

    baudgen_cfg_t baudgen_cfg;
    driver_cfg_t  driver_cfg;

    fifo_tx_hwif_intf fifo_tx_hwif();
    fifo_rx_hwif_intf fifo_rx_hwif();
    rx_hwif_intf      rx_hwif();

    uart_apb4_intf i_uart_apb4_intf (
        .clk(clk_i), .rst(~rst_n),
        .s_apb(s_apb.slave),
        .hwif_in(hwif_in),
        .hwif_out(hwif_out)
    );

    uart_pl_decode i_uart_pl_decode (
        .hwif_in(hwif_in), .hwif_out(hwif_out),
        .baudgen_cfg_o(baudgen_cfg),
        .driver_cfg_o(driver_cfg),
        .fifo_tx(fifo_tx_hwif.master),
        .fifo_rx(fifo_rx_hwif.master),
        .rx(rx_hwif.master)
    );

    fifo_tx i_fifo_tx (
        .clk_i(clk_i), .rst_n(rst_n),
        .fifo_tx_hwif(fifo_tx_hwif.slave),
        .tx_vld_o(tx_vld),
        .tx_data_o(tx_data),
        .tx_rdy_i(tx_rdy)
    );

    fifo_rx i_fifo_rx (
        .clk_i(clk_i), .rst_n(rst_n),
        .fifo_rx_hwif(fifo_rx_hwif.slave),
        .rx_vld_i(rx_vld),
        .rx_data_i(rx_data),
        .rx_rdy_o(rx_rdy)
    );

    uart_baudgen i_uart_baudgen (
        .clk_i(clk_i), .rst_n(rst_n),
        .cfg_i(baudgen_cfg),
        .uart_strb_o(uart_strb)
    );

    uart_tx i_uart_tx (
        .clk_i(clk_i), .rst_n(rst_n),
        .cfg_i(driver_cfg),
        .uart_strb_i(uart_strb),
        .tx_vld_i(tx_vld),
        .tx_data_i(tx_data),
        .tx_rdy_o(tx_rdy),
        .tx_o(tx_o)
    );

    uart_rx i_uart_rx (
        .clk_i(clk_i), .rst_n(rst_n),
        .cfg_i(driver_cfg),
        .rx_hwif(rx_hwif.slave),
        .uart_strb_i(uart_strb),
        .rx_vld_o(rx_vld),
        .rx_data_o(rx_data),
        .rx_rdy_i(rx_rdy),
        .rx_i(rx_i)
    );

endmodule