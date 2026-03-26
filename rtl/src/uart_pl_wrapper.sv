module uart_pl_wrapper #(
	parameter C_S_APB_DATA_WIDTH = 32,
    parameter C_S_APB_ADDR_WIDTH = 32
) (
    input clk_i,
    input rst_n, 

    input  [C_S_APB_ADDR_WIDTH-1:0]     PADDR,
    input                               PSEL,
    input                               PENABLE,
    input                               PWRITE,
    input  [2:0]                        PPROT,
    input  [C_S_APB_DATA_WIDTH - 1:0]   PWDATA,
    output [C_S_APB_DATA_WIDTH - 1:0]   PRDATA,
    input  [C_S_APB_DATA_WIDTH/8 - 1:0] PSTRB,
    output                              PREADY,
    output                              PSLVERR,

    input  rx_i, 
    output tx_o
);

    localparam ADDR_WIDTH = 5;
    logic is_uart_pl;

    assign is_uart_pl = (PADDR[C_S_APB_ADDR_WIDTH - 1:ADDR_WIDTH] == '0);

    uart_pl_top #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (C_S_APB_DATA_WIDTH)
    ) i_uart_pl_top (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .paddr(PADDR[ADDR_WIDTH - 1:0]),
        .psel(PSEL & is_uart_pl),
        .penable(PENABLE),
        .pwrite(PWRITE),
        .pprot(PPROT),
        .pwdata(PWDATA),
        .prdata(PRDATA),
        .pstrb(PSTRB),
        .pready(PREADY),
        .pslverr(PSLVERR),
        .rx_i(rx_i),
        .tx_o(tx_o)
    );

endmodule