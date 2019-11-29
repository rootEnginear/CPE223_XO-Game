`timescale 1ns / 1ps

// all variable must be prefixed, 
// `r_` for reg and `w_` for wire

module top(
    input clock,
    input [4:0] btn,
    input sw,
    output VGA_HS_O,       // horizontal sync output
    output VGA_VS_O,       // vertical sync output
    output [3:0] VGA_R,    // 4-bit VGA red output
    output [3:0] VGA_G,    // 4-bit VGA green output
    output [3:0] VGA_B,     // 4-bit VGA blue output
    output [6:0] seg,
    output [3:0] an
    );
//    # REGs #
    reg [3:0] r_cursor_index;
    reg r_cursor_blink_state;
    reg [3:0] r_xo_count;
    reg [17:0] r_memory;
    reg [15:0] r_vga_cnt;
    reg r_vga_pix_stb; // generate a 25 MHz pixel strobe
    reg [3:0] r_x_win;
    reg [3:0] r_o_win;
    reg r_is_splash_shown;
    reg [1:0] r_splash_time_count;
    reg [1:0] r_7seg_selector;
    
//    # Wires #
    wire w_button_w, w_button_a, w_button_s, w_button_d, w_button_c, w_reset_switch;
    wire w_has_winner;
    wire [8:0] w_is_checked = r_memory[17:9];
    wire [8:0] w_sign = r_memory[8:0];
    wire [7:0] w_result;
    wire w_is_win, w_is_win_posedge, w_is_end;
    wire w_4hc, w_240hc;
    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511
    wire [1:0] x_offset = r_cursor_index % 3;
    wire [1:0] y_offset = r_cursor_index / 3;
    wire [3:0] w_render_r, w_render_g, w_render_b;
    wire w_cursor_square, w_rendered_cursor;
    wire [3:0] w_score_digits [3:0];
    wire w_splash_r, w_splash_g, w_splash_b, w_1hc, w_cross_splash, w_nought_splash, splash_r, splash_g, splash_b;
    wire w_win_back, w_win_text, w_cross_win, w_nought_win, w_tie_text;
    wire w_win_rendered_r, w_win_rendered_g, w_win_rendered_b;
    
    initial begin
        r_cursor_index <= 4; // default square: must be 0 - 8 (4 bits)
        r_cursor_blink_state <= 1; // selected square blink value
        r_xo_count <= 0;
        r_memory <= 18'b0;
        r_x_win <= 0;
        r_o_win <= 0;
        r_is_splash_shown <= 1;
        r_splash_time_count <= 0;
    end
    
//    Debounce Buttons and Switches
    debouncer BTN_W (clock,btn[0],w_button_w);
    debouncer BTN_A (clock,btn[1],w_button_a);
    debouncer BTN_S (clock,btn[2],w_button_s);
    debouncer BTN_D (clock,btn[3],w_button_d);
    debouncer BTN_C (clock,btn[4],w_button_c);
    debouncer SW (clock,sw,w_reset_switch);
    debouncer IS_WIN_POSEDGE (clock,w_is_win,w_is_win_posedge);

//    Button controls
    always @(posedge clock) begin
        if (w_button_w & r_cursor_index > 2) r_cursor_index <= r_cursor_index - 3;
        else if (w_button_a & r_cursor_index > 0) r_cursor_index <= r_cursor_index - 1;
        else if (w_button_s & r_cursor_index < 8) r_cursor_index <= r_cursor_index + 1;
        else if (w_button_d & r_cursor_index < 6) r_cursor_index <= r_cursor_index + 3;
        else if (w_button_c & ~((r_memory[17:9] >> r_cursor_index) & 1'b1) & ~w_is_win) begin
            r_xo_count <= r_xo_count + 1;
            r_memory[17:9] <= r_memory[17:9] | (1 << r_cursor_index);
            r_memory[8:0] <= r_memory[8:0] | (r_xo_count[0] << r_cursor_index);
        end
        else if (w_button_c & w_is_end) begin
            r_cursor_index <= 4;
            r_xo_count <= 0;
            r_memory <= 18'b0;
        end
        else if (w_reset_switch) begin
            r_cursor_index <= 4;
            r_xo_count <= 0;
            r_memory <= 18'b0;
            r_x_win <= 0;
            r_o_win <= 0;
        end
        else if (w_is_win_posedge) begin
            if (~w_has_winner & w_is_win) r_x_win <= r_x_win+1;
            else r_o_win <= r_o_win+1;
        end
    end
    
//    Result checking
    assign w_result[0] = (w_is_checked[0] & w_is_checked[1] & w_is_checked[2] & w_sign[0] == w_sign[1] & w_sign[1] == w_sign[2]);
    assign w_result[1] = (w_is_checked[3] & w_is_checked[4] & w_is_checked[5] & w_sign[3] == w_sign[4] & w_sign[4] == w_sign[5]);
    assign w_result[2] = (w_is_checked[6] & w_is_checked[7] & w_is_checked[8] & w_sign[6] == w_sign[7] & w_sign[7] == w_sign[8]);
    assign w_result[3] = (w_is_checked[0] & w_is_checked[3] & w_is_checked[6] & w_sign[0] == w_sign[3] & w_sign[3] == w_sign[6]);
    assign w_result[4] = (w_is_checked[1] & w_is_checked[4] & w_is_checked[7] & w_sign[1] == w_sign[4] & w_sign[4] == w_sign[7]);
    assign w_result[5] = (w_is_checked[2] & w_is_checked[5] & w_is_checked[8] & w_sign[2] == w_sign[5] & w_sign[5] == w_sign[8]);
    assign w_result[6] = (w_is_checked[0] & w_is_checked[4] & w_is_checked[8] & w_sign[0] == w_sign[4] & w_sign[4] == w_sign[8]);
    assign w_result[7] = (w_is_checked[2] & w_is_checked[4] & w_is_checked[6] & w_sign[2] == w_sign[4] & w_sign[4] == w_sign[6]);
    assign w_has_winner = w_result[0] ? w_sign[0] : 'bz;
    assign w_has_winner = w_result[1] ? w_sign[3] : 'bz;
    assign w_has_winner = w_result[2] ? w_sign[6] : 'bz;
    assign w_has_winner = w_result[3] ? w_sign[0] : 'bz;
    assign w_has_winner = w_result[4] ? w_sign[1] : 'bz;
    assign w_has_winner = w_result[5] ? w_sign[2] : 'bz;
    assign w_has_winner = w_result[6] ? w_sign[0] : 'bz;
    assign w_has_winner = w_result[7] ? w_sign[2] : 'bz;
    assign w_is_win = |w_result;
    assign w_is_end = r_xo_count > 8 | w_is_win;
    
//    Scoring
    clock_divider #(1'b1,18,208334) CLOCK_240HZ (clock,0,w_240hc);
    assign w_score_digits[0] = r_o_win % 10;
    assign w_score_digits[1] = r_o_win / 10;
    assign w_score_digits[2] = r_x_win % 10;
    assign w_score_digits[3] = r_x_win / 10;
    
    always @(posedge w_240hc) r_7seg_selector <= r_7seg_selector+1;
    assign an = ~(1 << r_7seg_selector);
    _7seg _7SEG (w_score_digits[r_7seg_selector],seg);
    
//    Blinking Cursor
    clock_divider #(1'b1,24,12500000) CLOCK_4HZ (clock,0,w_4hc);
    always @(posedge w_4hc) r_cursor_blink_state <= ~r_cursor_blink_state;
    square SELECTED_SQ (x,y,50 + x_offset * 192,50 + y_offset * 137,156,103,w_cursor_square);
    assign w_rendered_cursor = w_cursor_square & (r_cursor_blink_state | |btn) & ~w_is_end;
    
//    Splash
    cross CROSS_splash (x, y, 211, 100, w_cross_splash);
    nought NOUGHT_splash (x, y, 280, 100, w_nought_splash);
    splash SPLASH (x,y,190,260,w_splash_r, w_splash_g, w_splash_b);
    assign splash_r = r_is_splash_shown & (w_splash_r | w_cross_splash);
    assign splash_g = r_is_splash_shown & (w_splash_g);
    assign splash_b = r_is_splash_shown & (w_splash_b | w_nought_splash);
    clock_divider #(1'b1,26,50000000) CLOCK_1HZ (clock,0,w_1hc);
    always @(posedge w_1hc) begin
        if (r_is_splash_shown & (r_splash_time_count < 3)) r_splash_time_count <= r_splash_time_count + 1;
        else r_is_splash_shown <= 0;
    end
    
//    Board
    board_renderer BOARD_RENDERER (x,y,r_memory,w_is_end,w_render_r,w_render_g,w_render_b);
    
//    Winning Display
    square WIN_BACK (x, y, 40, 170, 560, 135, w_win_back);
    win_text WIN_TEXT (x, y, 223, 187, w_win_text); // 120,187
    cross CROSS_WIN (x, y, 93, 187, w_cross_win);
    nought NOUGHT_WIN (x, y, 93, 187, w_nought_win);
    tie_text TIE_TEXT (x, y, 200, 187, w_tie_text);
    assign w_win_rendered_r = w_win_back ^ ((w_win_text & w_is_win) | (w_nought_win & (w_has_winner & w_is_win)));
    assign w_win_rendered_g = w_win_back ^ ((w_nought_win & (w_has_winner & w_is_win)) | ((w_cross_win & (~w_has_winner & w_is_win)) | (w_tie_text & (r_xo_count > 8 & ~w_is_win))));
    assign w_win_rendered_b = w_win_back ^ ((w_win_text & w_is_win) | ((w_cross_win & (~w_has_winner & w_is_win)) | (w_tie_text & (r_xo_count > 8 & ~w_is_win))));
    
//    Display
    always @(posedge clock) {r_vga_pix_stb, r_vga_cnt} <= r_vga_cnt + 16'h4000;  // divide by 4: (2^16) / 4 = 0x4000
    vga640x480 DISPLAY (
        .i_clk(clock),
        .i_pix_stb(r_vga_pix_stb),
        .i_rst(0),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y)
    );
    assign VGA_R = {4{splash_r}} | ({4{~r_is_splash_shown}} & (w_render_r | {3{w_rendered_cursor}} | {4{w_win_rendered_r & w_is_end}}));
    assign VGA_G = {4{splash_g}} | ({4{~r_is_splash_shown}} & (w_render_g | {3{w_rendered_cursor}} | {4{w_win_rendered_g & w_is_end}}));
    assign VGA_B = {4{splash_b}} | ({4{~r_is_splash_shown}} & (w_render_b | {4{w_win_rendered_b & w_is_end}}));
endmodule
