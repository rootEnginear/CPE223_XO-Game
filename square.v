`timescale 1ns / 1ps

module square(
    input [9:0] scan_x,
    input [8:0] scan_y,
    input [31:0] x,
    input [31:0] y,
    input [9:0] width,
    input [8:0] height,
    output draw
    );
    assign draw = (scan_x > x) & (scan_x < x + width) & (scan_y > y) & (scan_y < y + height);
endmodule
