module test (
    input wire clk,
    input wire rst_n,
    output wire [7:0] led
);
    localparam integer CLK_HZ = 100000000;
    localparam integer HALF_1S = CLK_HZ / 2;
    localparam integer HALF_2S = CLK_HZ;
    localparam integer HALF_3S = (CLK_HZ * 3) / 2;
    localparam integer HALF_4S = CLK_HZ * 2;

    reg [$clog2(HALF_1S)-1:0] cnt_led1;
    reg [$clog2(HALF_2S)-1:0] cnt_led2;
    reg [$clog2(HALF_3S)-1:0] cnt_led3;
    reg [$clog2(HALF_4S)-1:0] cnt_led4;

    reg led1_state;
    reg led2_state;
    reg led3_state;
    reg led4_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_led1 <= {($clog2(HALF_1S)){1'b0}};
            cnt_led2 <= {($clog2(HALF_2S)){1'b0}};
            cnt_led3 <= {($clog2(HALF_3S)){1'b0}};
            cnt_led4 <= {($clog2(HALF_4S)){1'b0}};
            led1_state <= 1'b0;
            led2_state <= 1'b0;
            led3_state <= 1'b0;
            led4_state <= 1'b0;
        end else begin
            if (cnt_led1 == HALF_1S - 1) begin
                cnt_led1 <= {($clog2(HALF_1S)){1'b0}};
                led1_state <= ~led1_state;
            end else begin
                cnt_led1 <= cnt_led1 + 1'b1;
            end

            if (cnt_led2 == HALF_2S - 1) begin
                cnt_led2 <= {($clog2(HALF_2S)){1'b0}};
                led2_state <= ~led2_state;
            end else begin
                cnt_led2 <= cnt_led2 + 1'b1;
            end

            if (cnt_led3 == HALF_3S - 1) begin
                cnt_led3 <= {($clog2(HALF_3S)){1'b0}};
                led3_state <= ~led3_state;
            end else begin
                cnt_led3 <= cnt_led3 + 1'b1;
            end

            if (cnt_led4 == HALF_4S - 1) begin
                cnt_led4 <= {($clog2(HALF_4S)){1'b0}};
                led4_state <= ~led4_state;
            end else begin
                cnt_led4 <= cnt_led4 + 1'b1;
            end
        end
    end

    assign led = {4'b0000, led4_state, led3_state, led2_state, led1_state};
endmodule