`timescale 1ns / 1ps

module nought(
    input [9:0] scan_x,
    input [8:0] scan_y,
    input [9:0] x,
    input [8:0] y,
    output draw
    );
    wire w_bound, w_h1, w_h2, w_v1, w_v2;
    wire [9:0] x_shift = scan_x - x;
    wire [8:0] y_shift = scan_y - y;
    square NOUGH_BOUND (scan_x,scan_y,x+26,y,103,103,w_bound);
    square H1 (scan_x,scan_y,x+56,y,40,10,w_h1);
    square H2 (scan_x,scan_y,x+59,y+93,36,10,w_h2);
    square V1 (scan_x,scan_y,x+26,y+30,10,40,w_v1);
    square V2 (scan_x,scan_y,x+119,y+32,10,38,w_v2);
    assign draw = w_bound & (
    w_h1 | w_h2 | w_v1 | w_v2 |
    ((y_shift > x_shift+34) & (y_shift < x_shift+48)) |
    ((y_shift+86 < x_shift) & (y_shift+100 > x_shift)) |
    ((y_shift+x_shift > 54) & (y_shift+x_shift < 68)) |
    ((y_shift+x_shift > 188) & (y_shift+x_shift < 202))
    );
endmodule
