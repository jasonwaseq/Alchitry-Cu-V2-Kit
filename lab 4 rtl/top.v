`timescale 1ns / 1ps

module top(
    input  wire clkin,    
    input  wire [15:0] sw,       
    input  wire btnU,     
    input  wire btnC,     
    input  wire btnR,     
    output wire [3:0] an,       
    output wire [6:0] seg,      
    output wire [15:0] led,      
    output wire dp        
);

    wire clk = clkin;
    // Cu reset is active-low on the board button; convert it once and use an active-high
    // internal reset everywhere else in this design.
    // For Alchitry Io Board, emulate pull-downs on buttons
  reg [4:0] btn_r;
  always @(posedge clk) btn_r <= {btnD, btnL, btnR, btnU, btnC};

  wire rst = ~sw[0];
  wire stop = ~btn_r[4];  // Center button
  wire up = ~btn_r[3];    // Top button
  wire right = ~btn_r[2]; // Right button
  wire left = ~btn_r[1];  // Left button
  wire down = ~btn_r[0];  // Down button
    wire qsec;
    qsec_clks slowit(
        .clk(clk),
        .rst_n(btnR),
        .qsec_pulse(qsec)
    );

    reg [15:0] digsel_div = 16'd0;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            digsel_div <= 16'd0;
        end else begin
            digsel_div <= digsel_div + 16'd1;
        end
    end
    wire digsel = digsel_div[15];
    wire digsel_tick;
    edge_detector edge_digsel(.clk_i(clk), .sig_i(digsel), .edge_o(digsel_tick));

    wire go_pulse, stop_pulse;
    edge_detector edge_go  (.clk_i(clk), .sig_i(btnC), .edge_o(go_pulse));
    edge_detector edge_stop(.clk_i(clk), .sig_i(btnU), .edge_o(stop_pulse));

    wire [7:0] rand_q;
    lfsr random_num(
        .clk_i(clk),
        .ce_i (qsec),
        .q_o(rand_q)
    );

    wire [5:0] sec_q;
    wire reset_timer;
    
    time_counter timer(
        .clk_i(clk),
        .inc_i(qsec),
        .reset_i(reset_timer),
        .q_o(sec_q)
    );

    wire any_sec   = sec_q[5] | sec_q[4] | sec_q[3] | sec_q[2] | sec_q[1] | sec_q[0];
    wire two_secs  = ~sec_q[2] & ~sec_q[1] & ~sec_q[0] & any_sec;        
    wire four_secs =  sec_q[4] & ~sec_q[3] & ~sec_q[2] & ~sec_q[1] & ~sec_q[0]; 

    wire load_target;
    wire load_numbers;
    wire shr;
    wire shl;
    wire flash_both;
    wire flash_alt;
    wire match;
    
    fsm quick_add(
        .clk_i(clk),
        .go_i(go_pulse),
        .stop_i(stop_pulse),
        .two_secs_i(two_secs),
        .four_secs_i(four_secs),
        .match_i(match),
        .load_target_o(load_target),
        .reset_timer_o(reset_timer),
        .load_numbers_o(load_numbers),
        .shr_o(shr),
        .shl_o(shl),
        .flash_both_o(flash_both),
        .flash_alt_o(flash_alt)
    );

    led_shifter led_shift(
        .clk_i(clk),
        .in_i(shl),
        .shl_i(shl),
        .shr_i(shr),
        .q_o(led)
    );
    
    wire two_tick;
    edge_detector ed_t2(.clk_i(clk), .sig_i(two_secs), .edge_o(two_tick));
    wire load_numbers_tick = two_tick & load_numbers;

    reg [2:0] Aval = 3'b000;
    reg [2:0] Bval = 3'b000;
    reg [3:0] Sval = 4'b0000;

    always @(posedge clk) begin
        if (load_numbers_tick) begin
            Aval <= rand_q[2:0];
            Bval <= rand_q[5:3];
        end

        if (load_target) begin
            Sval <= rand_q[7:4];
        end
    end

    wire [7:0] sum8;
    wire       ovfl, carry_out;
    adder8 u_adder (
        .A    ({5'b0, Aval}),   
        .B    ({5'b0, Bval}),   
        .Cin  (1'b0),
        .S    (sum8),
        .ovfl (ovfl),
        .Cout (carry_out)
    );

    wire [3:0] sum_number = sum8[3:0];
    assign match = &(~(sum_number ^ Sval))|sw[14];


    wire [15:0] disp_nibs;
    assign disp_nibs = { Sval, sum_number, {1'b0,Bval}, {1'b0,Aval} };

    wire [3:0] active_digit;
    ring_counter ringcounter(
        .clk_i(clk),
        .advance_i(digsel_tick),
        .reset_i(rst),
        .data_o(active_digit)
    );

    wire [3:0] number;
    selector pick(.sel(active_digit), .N(disp_nibs), .H(number));
    wire [6:0] raw_seg;
    hex7seg h7s(.n(number), .seg(raw_seg));

    wire cheat_on = sw[15];
    wire hide_sum_digit = active_digit[2] & ~cheat_on;
    assign seg = ~raw_seg & {7{~hide_sum_digit}};
    assign dp = 1'b0;

    wire [3:0] base_an;
    assign base_an = {
        ~active_digit[3],
        ~active_digit[2],
        ~active_digit[1],
        ~active_digit[0]
    };

    wire phase = sec_q[0];

    wire lose = flash_both;
    wire win  = flash_alt;
    wire display3 = (lose & phase) | (win  &  phase);
    wire display2 = 1'b0;
    wire display1 = (lose & phase) | (win  & ~phase);
    wire display0 = display1;
    wire [3:0] flash_display = {display3, display2, display1, display0};

    assign an = base_an | flash_display;

endmodule
