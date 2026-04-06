module qsec_clks #(
    parameter integer CLK_HZ = 100000000
) (
    input wire clk,
    input wire rst_n,
    output reg qsec_pulse
);
    localparam integer QSEC_CYCLES = CLK_HZ / 4;
    localparam integer COUNTER_WIDTH = $clog2(QSEC_CYCLES);

    reg [COUNTER_WIDTH-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= {COUNTER_WIDTH{1'b0}};
            qsec_pulse <= 1'b0;
        end else if (count == QSEC_CYCLES - 1) begin
            count <= {COUNTER_WIDTH{1'b0}};
            qsec_pulse <= 1'b1;
        end else begin
            count <= count + 1'b1;
            qsec_pulse <= 1'b0;
        end
    end
endmodule