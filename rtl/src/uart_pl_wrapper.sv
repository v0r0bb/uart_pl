module uart_pl_wrapper #(
	parameter C_S_APB_DATA_WIDTH = 32,
    parameter C_S_APB_ADDR_WIDTH = 32,
    parameter UART_PL_APB_BASE   = 32'h43C00000
) (
    input clk_i,
    input rst_n, 

    input  [C_S_APB_ADDR_WIDTH - 1:0]   PADDR,
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

//    logic is_uart_pl;
//    assign is_uart_pl = (PADDR[C_S_APB_ADDR_WIDTH - 1:ADDR_WIDTH] == (UART_PL_APB_BASE >> ADDR_WIDTH));

    uart_pl_top i_uart_pl_top (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .paddr(PADDR),
        .psel(PSEL),
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