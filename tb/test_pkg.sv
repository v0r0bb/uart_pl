package test_pkg;
    `include "apb4_trans.sv"
    `include "test_cfg.sv"
    `include "apb4_agent.sv"
    `include "uart_agent.sv"
    `include "environment.sv"
    `include "scoreboard.sv"
    `include "test.sv"

    localparam ADDR_WIDTH = 5;
    localparam DATA_WIDTH = 32;
    typedef enum bit [ADDR_WIDTH - 1:0] {
        UART_SR_ADDR  = 'h0,
        UART_CR_ADDR  = 'h4,
        UART_RX_ADDR  = 'h8,
        UART_TX_ADDR  = 'hC,
        UART_BRR_ADDR = 'h10
    } uart_reg_t;
endpackage