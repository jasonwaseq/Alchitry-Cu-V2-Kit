`timescale 1ns / 1ps

module time_counter(
    input clk_i,
    input inc_i,
    input reset_i,
    output [5:0] q_o
);

    wire [15:0] full_q;
    wire utc_unused;
    wire dtc_unused;
    
    countUD16L counter (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .up_i(inc_i),
        .dw_i(1'b0),
        .ld_i(reset_i),
        .din_i(16'b0000000000000000),
        .q_o(full_q),
        .utc_o(utc_unused),
        .dtc_o(dtc_unused)
    );

    assign q_o = full_q[5:0];
    
endmodule
