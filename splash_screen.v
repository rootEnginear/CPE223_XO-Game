`timescale 1ns / 1ps

module splash(
    input [9:0] scan_x,
    input [8:0] scan_y,
    input [9:0] x,
    input [8:0] y,
    output r,
    output g,
    output b
    );
    wire shift_x = scan_x - x;
    wire shift_y = scan_y - y;
    wire g1,g2,g3,g4,g5;  //red
    wire m1,m2,m3,m4,m5;  //green
    wire a1,a2,a3,a4;  //yellow
    wire e1,e2,e3,e4;  //light blue
    square(scan_x,scan_y,x,y,14,65,g1);
    square(scan_x,scan_y,x,y,56,14,g2);
    square(scan_x,scan_y,x,y+51,56,14,g3); 
    square(scan_x,scan_y,x+42,y+28,14,37,g4); // line "|"
    square(scan_x,scan_y,x+30,y+28,26,14,g5); // lin middle "-"
    square(scan_x,scan_y,x+76,y,55,14,a1); // top "-"
    square(scan_x,scan_y,x+76,y,14,65,a2); // left "|"
    square(scan_x,scan_y,x+117,y,14,65,a3); // right "|"
    square(scan_x,scan_y,x+76,y+28,55,14,a4); // -
    square(scan_x,scan_y,x+151,y,14,65,m1); // left line
    square(scan_x,scan_y,x+164,y,14,14,m2); // left block
    square(scan_x,scan_y,x+178,y+14,14,14,m3); // middle block
    square(scan_x,scan_y,x+190,y,14,14,m4); // right block
    square(scan_x,scan_y,x+203,y,14,65,m5); // right line
    square(scan_x,scan_y,x+241,y,14,65,e1);
    square(scan_x,scan_y,x+254,y,42,14,e2);
    square(scan_x,scan_y,x+254,y+25,42,14,e3);
    square(scan_x,scan_y,x+254,y+51,42,14,e4);
    assign r = g1|g2|g3|g4|g5|a1|a2|a3|a4;
    assign g = m1|m2|m3|m4|m5|a1|a2|a3|a4|e1|e2|e3|e4;
    assign b = e1|e2|e3|e4;
endmodule
