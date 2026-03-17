import uart_apb4_intf_pkg::*;

module uart_tx (
    input clk_i, 
    input rst_n,

    input uart_apb4_intf__out_t hwif_out,

    input uart_clk_i,

    input       tx_vld_i,
    input [7:0] tx_data_i,
    output      tx_rdy_o,

    output tx_o
);

    localparam SAMPLE_X8_LAST   = 7,
               SAMPLE_X16_LAST  = 15;

    localparam SAMPLE_X8_STOP1  = 7,
               SAMPLE_X8_STOP2  = 15,
               SAMPLE_X16_STOP1 = 15,
               SAMPLE_X16_STOP2 = 31;

    localparam DATA_BITS = 7;

    typedef enum bit [1:0] {
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3
    } state_t;
    state_t state;

    logic [4:0] sample_cnt;  // 2^5 = 32
    logic [2:0] bit_cnt;

    logic is_last;
    logic is_stop;

    logic stop_bits;
    logic over8;

    logic [7:0] tx_shift_reg;
    logic       tx_reg;

    assign over8     = hwif_out.UART_CR.OVER8.value;
    assign stop_bits = hwif_out.UART_CR.SB.value;

    assign is_last = over8 ? (sample_cnt == SAMPLE_X8_LAST) : (sample_cnt == SAMPLE_X16_LAST);

    assign is_stop = stop_bits ? 
        (over8 ? (sample_cnt == SAMPLE_X8_STOP2) : (sample_cnt == SAMPLE_X16_STOP2)) :
        (over8 ? (sample_cnt == SAMPLE_X8_STOP1) : (sample_cnt == SAMPLE_X16_STOP1));

    always_ff @(posedge clk_i or negedge rst_n) begin 
        if (~rst_n)
            sample_cnt <= '0;
        else begin 
            if (uart_clk_i) begin 
                if ((state == START & tx_o) | (is_last & state != STOP))
                    sample_cnt <= '0;
                else 
                    sample_cnt <= sample_cnt + 1'b1;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (~rst_n) begin
            state <= IDLE;
            tx_reg <= 1'b1;
        end
        else begin 
            case (state)
                IDLE: begin 
                    tx_reg <= 1'b1;
                    if (tx_vld_i) begin
                       state <= START;
                       tx_shift_reg <= tx_data_i;
                    end
                end
                START: begin 
                    if (uart_clk_i) begin
                        tx_reg <= 1'b0;
                        if (is_last) begin 
                            state <= DATA;
                            bit_cnt <= '0; 
                            tx_reg <= tx_shift_reg[0];
                        end
                    end
                end 
                DATA: begin 
                    if (uart_clk_i) begin
                        if (is_last) begin 
                            if (bit_cnt == DATA_BITS) begin
                                state <= STOP;
                                tx_reg <= 1'b1;
                            end
                            else begin
                                bit_cnt <= bit_cnt + 1'b1;
                                tx_reg <= tx_shift_reg[bit_cnt + 1];
                            end
                        end
                    end
                end
                STOP: begin 
                    if (uart_clk_i) begin
                        if (is_stop)
                            state <= IDLE;
                    end
                end
            endcase
        end 
    end

    assign tx_rdy_o = (state == IDLE);
    assign tx_o = tx_reg;

endmodule