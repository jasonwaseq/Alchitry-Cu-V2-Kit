`timescale 1ns / 1ps

module countUD4L (
    input clk_i,
    input reset_i, 
    input up_i,
    input dw_i,
    input ld_i,
    input [3:0] din_i,
    output [3:0] q_o,
    output utc_o,
    output dtc_o
);

    reg [3:0] q = 4'b0000;

    always @(posedge clk_i) begin
        if (reset_i) begin
            q <= 4'b0000;
        end else if (ld_i) begin
            q <= din_i;
        end else if (up_i & ~dw_i) begin
            q <= q + 4'b0001;
        end else if (~up_i & dw_i) begin
            q <= q - 4'b0001;
        end
    end

    assign q_o = q;
    assign utc_o = &q;
    assign dtc_o = ~|q;

endmodule
