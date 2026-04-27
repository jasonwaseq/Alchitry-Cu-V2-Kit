`timescale 1ns / 1ps

module lfsr(
    input clk_i,
    input ce_i,
    output reg [7:0] q_o = 8'b10000000
    );
    
    wire feedback;
    
    assign feedback = q_o[0] ^ q_o[5] ^ q_o[6] ^ q_o[7];

    always @(posedge clk_i) begin
        if (ce_i) begin
            q_o <= {feedback, q_o[7:1]};
        end
    end
    
endmodule
