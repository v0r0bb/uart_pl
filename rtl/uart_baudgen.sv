import uart_apb4_intf_pkg::*;

module uart_baudgen (
    input clk_i,
    input rst_n,

    input uart_apb4_intf__out_t hwif_out,

    output uart_clk_o
);

    logic [3:0]  div_frac;
    logic [11:0] div_mant;
    logic        over8;

    logic [12:0] current_mant;
    logic [12:0] cnt;
    logic [3:0]  acc;       
    logic        acc_overflow;

    assign over8    = hwif_out.UART_CR.OVER8.value;
    assign div_frac = hwif_out.UART_BRR.DIV_FRAC.value;
    assign div_mant = hwif_out.UART_BRR.DIV_MANT.value;

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (~rst_n) begin 
            acc <= 4'd0;
            acc_overflow <= 1'b0;
        end
        else if (uart_clk_o) begin
            if (over8) 
                {acc_overflow, acc[2:0]} <= acc[2:0] + div_frac[2:0];
            else   
                {acc_overflow, acc} <= acc + div_frac;
        end
    end

    assign current_mant = div_mant + (acc_overflow ? 1'b1 : 1'b0);

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (~rst_n)
            cnt <= '0;
        else if (cnt >= (current_mant - 1))
            cnt <= '0;
        else 
            cnt <= cnt + 1'b1;
    end

    assign uart_clk_o = (cnt == current_mant - 1);

endmodule