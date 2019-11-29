`timescale 1ns / 1ps

/*
clock_divider #(<MODE>,<SIZE>,<TARGET>) (<Hz_IN>,<RST>,<Hz_OUT>)

mode:
    1'b0 = NEG_EDGE
    1'b1 = POS_EDGE
size = ceil(log_2(target))
target = Hz_IN / (Hz_OUT * 2)
*/

module clock_divider(
    input clk,
    input reset,
    output reg clkout
    );
    parameter MODE = 1'b1;
    parameter SIZE = 4;
    parameter TARGET = 2;

    reg [ SIZE - 1 : 0 ] count;    
    initial begin
        count <= 0;
        clkout <= MODE;
    end
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            clkout <= MODE;
        end
        else begin
            count <= count + 1;
            if (count == TARGET - 1) begin
                count <= 0;
                clkout <= ~clkout;
            end
        end
    end
endmodule
