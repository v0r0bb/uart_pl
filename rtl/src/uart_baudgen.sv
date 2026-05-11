module uart_baudgen
    import uart_pl_pkg::*;
(
    input clk_i,
    input rst_n,

    input baudgen_cfg_t cfg_i,

    output uart_strb_o
);

    logic [12:0] current_mant;
    logic [12:0] cnt;
    logic [3:0]  acc;       
    logic        acc_overflow;

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (~rst_n) begin 
            acc <= 4'd0;
            acc_overflow <= 1'b0;
        end
        else if (uart_strb_o) begin
            if (cfg_i.over8) 
                {acc_overflow, acc[2:0]} <= acc[2:0] + cfg_i.div_frac[2:0];
            else   
                {acc_overflow, acc} <= acc + cfg_i.div_frac;
        end
    end

    assign current_mant = cfg_i.div_mant + (acc_overflow ? 1'b1 : 1'b0);

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (~rst_n)
            cnt <= '0;
        else if (cnt >= (current_mant - 1))
            cnt <= '0;
        else 
            cnt <= cnt + 1'b1;
    end

    assign uart_strb_o = (cnt == current_mant - 1);

endmodule