`timescale 1ns / 1ps

module ring_counter(
    input advance_i,
    input clk_i,
    input reset_i,    
    output reg [3:0] data_o = 4'b0001
);

    always @(posedge clk_i) begin
        if (reset_i) begin
            data_o <= 4'b0001;
        end else if (advance_i) begin
            data_o <= {data_o[2:0], data_o[3]};
        end
    end

endmodule
