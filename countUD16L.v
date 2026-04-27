`timescale 1ns / 1ps

module countUD16L (
    input clk_i,
    input reset_i,
    input up_i,
    input dw_i,
    input ld_i,
    input [15:0] din_i,
    output [15:0] q_o,
    output utc_o,
    output dtc_o
);
    
    wire [3:0] q0, q1, q2, q3;
    wire utc0, utc1, utc2, utc3;
    wire dtc0, dtc1, dtc2, dtc3;
    
    countUD4L c0 (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .up_i(up_i),
        .dw_i(dw_i),
        .ld_i(ld_i),
        .din_i(din_i[3:0]),
        .q_o(q0),
        .utc_o(utc0),
        .dtc_o(dtc0)
    );
    
    countUD4L c1 (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .up_i(up_i & utc0),
    .dw_i(dw_i & dtc0),
    .ld_i(ld_i),
    .din_i(din_i[7:4]),
    .q_o(q1),
    .utc_o(utc1),
    .dtc_o(dtc1)
    );

    countUD4L c2 (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .up_i(up_i & utc0 & utc1),
        .dw_i(dw_i & dtc0 & dtc1),
        .ld_i(ld_i),
        .din_i(din_i[11:8]),
        .q_o(q2),
        .utc_o(utc2),
        .dtc_o(dtc2)
    );

    countUD4L c3 (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .up_i(up_i & utc0 & utc1 & utc2),
        .dw_i(dw_i & dtc0 & dtc1 & dtc2),
        .ld_i(ld_i),
        .din_i(din_i[15:12]),
        .q_o(q3),
        .utc_o(utc3),
        .dtc_o(dtc3)
    );
    
    assign q_o = {q3, q2, q1, q0};
    assign utc_o = utc0 & utc1 & utc2 & utc3;
    assign dtc_o = dtc0 & dtc1 & dtc2 & dtc3;
    
endmodule
