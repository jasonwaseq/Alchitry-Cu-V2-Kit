`timescale 1ns / 1ps

module qsec_clks_tb;
    localparam integer CLK_HZ = 8;
    localparam integer EXPECTED_CYCLES = CLK_HZ / 4;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    wire qsec_pulse;

    integer cycles_since_pulse = 0;
    integer pulse_count = 0;

    qsec_clks #(
        .CLK_HZ(CLK_HZ)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .qsec_pulse(qsec_pulse)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (rst_n) begin
            cycles_since_pulse <= cycles_since_pulse + 1;
        end
    end

    initial begin
        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        while (pulse_count < 4) begin
            @(posedge clk);
            #1;

            if (qsec_pulse) begin
                if (cycles_since_pulse != EXPECTED_CYCLES) begin
                    $fatal(1, "Expected pulse after %0d cycles, got %0d", EXPECTED_CYCLES, cycles_since_pulse);
                end
                cycles_since_pulse = 0;
                pulse_count = pulse_count + 1;
            end
        end

        $display("qsec_clks_tb passed");
        $finish;
    end
endmodule