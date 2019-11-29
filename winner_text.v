`timescale 1ns / 1ps

module win_text(
    input [9:0] scan_x,
    input [8:0] scan_y,
    input [9:0] x,
    input [8:0] y,
    output draw
    );
    wire mask;
    wire [9:0] x_shift = scan_x - x;
    wire [8:0] y_shift = scan_y - y;
    wire [17:0] x_shift_double = x_shift << 1;
    wire [16:0] x_shift_triple = x_shift_double + x_shift;
    square MASK (scan_x, scan_y, x, y, 298, 103, mask); // outline
    assign draw = mask & (
        // w 
        ((y_shift + x_shift_triple > 298) & (y_shift + x_shift_triple < 314)) |
        ((y_shift + x_shift_triple > 504) & (y_shift + x_shift_triple < 520)) |
        ((y_shift + 108 > x_shift_triple) & (y_shift + 92 < x_shift_triple)) |
        ((y_shift + 314 > x_shift_triple) & (y_shift + 298 < x_shift_triple)) |
        // i character
        ((x_shift > 200) & (x_shift < 206)) |
        // n characte
        ((x_shift > 240) & (x_shift < 246)) |
        ((x_shift > 292) & (x_shift < 298))  |
        ((y_shift + 492 > x_shift_double) & (y_shift + 480 < x_shift_double))                 
    );
endmodule