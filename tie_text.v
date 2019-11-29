`timescale 1ns / 1ps

module tie_text(
    input [9:0] scan_x,
    input [8:0] scan_y,
    input [9:0] x,
    input [8:0] y,
    output draw
    );
    wire t1,t2,i,e1,e2,e3,e4;
    wire [9:0] x_shift = scan_x - x;
    wire [8:0] y_shift = scan_y - y;
    square T1 (scan_x, scan_y, x, y, 100, 8, t1);
    square T2 (scan_x, scan_y, x+47, y, 8, 103, t2);
    square I (scan_x, scan_y, x+120, y, 8, 103, i);
    square E1 (scan_x, scan_y, x+165, y, 8, 103, e1);
    square E2 (scan_x, scan_y, x+165, y, 69, 8, e2);
    square E3 (scan_x, scan_y, x+165, y+48, 70, 8, e3);
    square E4 (scan_x, scan_y, x+165, y+95, 70, 8, e4); 
    assign draw = t1|t2|i|e1|e2|e3|e4;           
endmodule
