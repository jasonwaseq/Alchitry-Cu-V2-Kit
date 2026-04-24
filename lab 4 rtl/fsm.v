`timescale 1ns / 1ps

module fsm(
    input clk_i,
    input stop_i,
    input four_secs_i,
    input two_secs_i,
    input match_i,
    input go_i,
    output load_target_o,
    output reset_timer_o,
    output load_numbers_o,
    output shr_o,
    output shl_o,
    output flash_both_o,
    output flash_alt_o
);
    reg idle = 1'b1;
    reg game = 1'b0;
    reg check_sum = 1'b0;
    reg flash_win = 1'b0;
    reg flash_loss = 1'b0;
    
    wire next_idle;
    wire next_game;
    wire next_check_sum;
    wire next_flash_win;
    wire next_flash_loss;
    
    always @(posedge clk_i) begin
        idle <= next_idle;
        game <= next_game;
        check_sum <= next_check_sum;
        flash_loss <= next_flash_loss;
        flash_win <= next_flash_win;
    end
    
    assign next_idle = ~go_i & idle | flash_win & four_secs_i | flash_loss & four_secs_i;
    assign next_game = go_i & idle | game & two_secs_i & ~stop_i | game & ~two_secs_i & ~stop_i;  
    assign next_check_sum = stop_i & game;
    assign next_flash_win = check_sum & match_i | flash_win & ~four_secs_i;
    assign next_flash_loss = check_sum & ~match_i | flash_loss & ~four_secs_i;
    
    assign load_target_o = idle & go_i;
    assign reset_timer_o = idle | next_check_sum | ~go_i & two_secs_i & game;
    assign load_numbers_o = game & two_secs_i;
    assign shl_o = flash_win & four_secs_i;
    assign shr_o = flash_loss & four_secs_i;
    assign flash_both_o = flash_loss;
    assign flash_alt_o = flash_win;

endmodule