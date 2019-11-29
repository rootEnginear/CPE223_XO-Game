`timescale 1ns / 1ps

module cross(
    input [9:0] scan_x,
    input [8:0] scan_y,
    input [9:0] x,
    input [8:0] y,
    output draw
    );
    localparam THICKNESS = 7;
    wire w_bound;
    wire [9:0] x_shift = scan_x - x;
    wire [8:0] y_shift = scan_y - y;
    square CROSS_BOUND (scan_x,scan_y,x+26,y,103,103,w_bound); //wow this is square for crop cross
    assign draw = w_bound & (
        ((y_shift+26+THICKNESS > x_shift) & (y_shift+26-THICKNESS < x_shift)) |
        ((y_shift+x_shift > 129-THICKNESS) & (y_shift+x_shift < 129+THICKNESS))
    );
endmodule
