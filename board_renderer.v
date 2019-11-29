`timescale 1ns / 1ps

module board_renderer(
    input [9:0] x,
    input [8:0] y,
    input [17:0] data,
    input is_ended,
    output [3:0] r,
    output [3:0] g,
    output [3:0] b
    );
    wire h1, h2, v1, v2, v1_mask, v2_mask, game_table;
    wire [8:0] w_is_checked = data[17:9];
    wire [8:0] w_sign = data[8:0];        
    wire w_cross, w_nought;
    wire w_cross_0, w_nought_0, w_cross_1, w_nought_1, w_cross_2, w_nought_2, w_cross_3, w_nought_3, w_cross_4, w_nought_4, w_cross_5, w_nought_5, w_cross_6, w_nought_6, w_cross_7, w_nought_7, w_cross_8, w_nought_8;
     
    square HORZ_LINE_1 (x,y,40,162,560,10,h1);
    square HORZ_LINE_2 (x,y,40,303,560,10,h2);
    square VERT_LINE_1 (x,y,216,40,10,400,v1);
    square VERT_LINE_2 (x,y,414,40,10,400,v2);
    square VERT_LINE_1_MASK (x,y,216,170,10,135,v1_mask);
    square VERT_LINE_2_MASK (x,y,414,170,10,135,v2_mask);
    assign game_table = h1 | h2 | (v1^(v1_mask&is_ended)) | (v2^(v2_mask&is_ended));
    
    cross  CROSS_0  (x,y,50,50,w_cross_0);
    nought NOUGHT_0 (x,y,50,50,w_nought_0);
    cross  CROSS_1  (x,y,242,50,w_cross_1);
    nought NOUGHT_1 (x,y,242,50,w_nought_1);
    cross  CROSS_2  (x,y,434,50,w_cross_2);
    nought NOUGHT_2 (x,y,434,50,w_nought_2);
    cross  CROSS_3  (x,y,50,187,w_cross_3);
    nought NOUGHT_3 (x,y,50,187,w_nought_3);
    cross  CROSS_4  (x,y,242,187,w_cross_4);
    nought NOUGHT_4 (x,y,242,187,w_nought_4);
    cross  CROSS_5  (x,y,434,187,w_cross_5);
    nought NOUGHT_5 (x,y,434,187,w_nought_5);
    cross  CROSS_6  (x,y,50,324,w_cross_6);
    nought NOUGHT_6 (x,y,50,324,w_nought_6);
    cross  CROSS_7  (x,y,242,324,w_cross_7);
    nought NOUGHT_7 (x,y,242,324,w_nought_7);
    cross  CROSS_8  (x,y,434,324,w_cross_8);
    nought NOUGHT_8 (x,y,434,324,w_nought_8);
    assign w_cross =
        (w_cross_0 & w_is_checked[0] & ~w_sign[0]) |
        (w_cross_1 & w_is_checked[1] & ~w_sign[1]) |
        (w_cross_2 & w_is_checked[2] & ~w_sign[2]) |
        (w_cross_3 & w_is_checked[3] & ~w_sign[3]) |
        (w_cross_4 & w_is_checked[4] & ~w_sign[4]) |
        (w_cross_5 & w_is_checked[5] & ~w_sign[5]) |
        (w_cross_6 & w_is_checked[6] & ~w_sign[6]) |
        (w_cross_7 & w_is_checked[7] & ~w_sign[7]) |
        (w_cross_8 & w_is_checked[8] & ~w_sign[8]);
    assign w_nought =
        (w_nought_0 & w_is_checked[0] & w_sign[0]) |
        (w_nought_1 & w_is_checked[1] & w_sign[1]) |
        (w_nought_2 & w_is_checked[2] & w_sign[2]) |
        (w_nought_3 & w_is_checked[3] & w_sign[3]) |
        (w_nought_4 & w_is_checked[4] & w_sign[4]) |
        (w_nought_5 & w_is_checked[5] & w_sign[5]) |
        (w_nought_6 & w_is_checked[6] & w_sign[6]) |
        (w_nought_7 & w_is_checked[7] & w_sign[7]) |
        (w_nought_8 & w_is_checked[8] & w_sign[8]);
    
    assign r = {4{game_table}} | {4{w_cross}};
    assign g = {4{game_table}};
    assign b = {4{game_table}} | {4{w_nought}};
endmodule
