`timescale 1ns / 1ps

module led_shifter(
    input clk_i,
    input reset_i,
    input shl_i,
    input shr_i,
    output reg [15:0] q_o = 16'b0
);

    always @(posedge clk_i) begin
        if (reset_i) begin
            q_o <= 16'b0;
        end else if (shl_i) begin
            q_o <= {q_o[14:0], 1'b1};
        end else if (shr_i) begin
            q_o <= {1'b0, q_o[15:1]};
        end
    end
    
endmodule
