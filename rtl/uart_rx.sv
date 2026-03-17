import uart_apb4_intf_pkg::*;

module uart_rx (
    input clk_i, 
    input rst_n,

    input uart_apb4_intf__out_t hwif_out,

    input uart_clk_i,

    output       rx_vld_o,
    output [7:0] rx_data_o,
    input        rx_rdy_i,

    input rx_i
);

    localparam SAMPLE_X16_1     = 7,
               SAMPLE_X16_2     = 8, 
               SAMPLE_X16_3     = 9,
               SAMPLE_X16_VOTED = 10;

    localparam SAMPLE_X8_1      = 3,
               SAMPLE_X8_2      = 4,
               SAMPLE_X8_3      = 5,
               SAMPLE_X8_VOTED  = 6;

    localparam SAMPLE_X8_LAST   = 7,
               SAMPLE_X16_LAST  = 15;

    localparam SAMPLE_X8_STOP1   = 7,
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

    logic [2:0] rx_sample;
    logic       rx_voted;

    logic is_sample;
    logic is_vote;
    logic is_last;
    logic is_stop;

    logic stop_bits;
    logic over8;

    logic [7:0] rx_shift_reg;
    logic [7:0] rx_reg;
    logic       rx_vld_reg;

    assign over8     = hwif_out.UART_CR.OVER8.value;
    assign stop_bits = hwif_out.UART_CR.SB.value;

    assign rx_voted = rx_sample[0] & rx_sample[1] |
                      rx_sample[0] & rx_sample[2] |
                      rx_sample[1] & rx_sample[2];

    assign is_sample = over8 ? 
        (sample_cnt == SAMPLE_X8_1 | sample_cnt == SAMPLE_X8_2 | sample_cnt == SAMPLE_X8_3) : 
        (sample_cnt == SAMPLE_X16_1 | sample_cnt == SAMPLE_X16_2 | sample_cnt == SAMPLE_X16_3);

    assign is_vote = over8 ? (sample_cnt ==  SAMPLE_X8_VOTED) : (sample_cnt ==  SAMPLE_X16_VOTED);

    assign is_last = over8 ? (sample_cnt == SAMPLE_X8_LAST) : (sample_cnt == SAMPLE_X16_LAST);

    assign is_stop = stop_bits ? 
        (over8 ? (sample_cnt == SAMPLE_X8_STOP2) : (sample_cnt == SAMPLE_X16_STOP2)) :
        (over8 ? (sample_cnt == SAMPLE_X8_STOP1) : (sample_cnt == SAMPLE_X16_STOP1));

    always_ff @(posedge clk_i) begin
        if (uart_clk_i & is_sample)
            rx_sample <= {rx_sample[1:0], rx_i};
    end

    always_ff @(posedge clk_i or negedge rst_n) begin 
        if (~rst_n)
            sample_cnt <= '0;
        else if ((state == IDLE & ~rx_i) | (uart_clk_i & state != STOP & is_last))
                sample_cnt <= '0;
        else if (uart_clk_i)
                sample_cnt <= sample_cnt + 1'b1;
    end

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (~rst_n) 
            state <= IDLE;
        else begin 
            case (state)
                IDLE: begin 
                    if (~rx_i) 
                       state <= START;
                end
                START: begin 
                    if (uart_clk_i) begin
                        if (is_vote & rx_voted)
                            state <= IDLE;
                        else if (is_last) begin 
                            state <= DATA;
                            bit_cnt <= '0; 
                        end
                    end
                end 
                DATA: begin 
                    if (uart_clk_i) begin
                        if (is_vote)
                            rx_shift_reg <= {rx_voted, rx_shift_reg[7:1]};
                        if (is_last) begin 
                            if (bit_cnt == DATA_BITS) 
                                state <= STOP;
                            else  
                                bit_cnt <= bit_cnt + 1'b1;
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

    always_ff @(posedge clk_i or negedge rst_n) begin 
        if (~rst_n)
            rx_vld_reg <= 1'b0;
        else if (state == STOP & is_stop & uart_clk_i) begin
            rx_vld_reg <= 1'b1;
            rx_reg <= rx_shift_reg;
        end
        else if (rx_vld_o & rx_rdy_i)
            rx_vld_reg <= 1'b0;
    end

    assign rx_vld_o  = rx_vld_reg;
    assign rx_data_o = rx_reg;

endmodule