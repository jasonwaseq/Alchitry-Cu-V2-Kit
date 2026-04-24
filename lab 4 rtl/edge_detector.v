`timescale 1ns / 1ps

module edge_detector(
    input clk_i,
    input sig_i,
    output edge_o
    );
    
    reg previous = 1'b0;

    always @(posedge clk_i) begin
        previous <= sig_i;
    end
    
    assign edge_o = ~previous & sig_i;
    
endmodule
