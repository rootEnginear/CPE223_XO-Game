`timescale 1ns / 1ps

// Ref: https://www.fpga4fun.com/Debouncer.html
module debouncer(
    input clk,
    input pb,  // "PB" is the glitchy, asynchronous to clk, active low push-button signal
    output pb_down  // 1 for one clock cycle when the push-button goes down (i.e. just pushed)
    );
    reg pb_state; // 1 as long as the push-button is active (down)
    // First use two flip-flops to synchronize the PB signal the "clk" clock domain
    reg pb_sync_0; always @(posedge clk) pb_sync_0 <= ~pb;  // invert PB to make PB_sync_0 active high
    reg pb_sync_1; always @(posedge clk) pb_sync_1 <= pb_sync_0;
    
    // Next declare a 16-bits counter
    reg [15:0] pb_cnt;
    
    // When the push-button is pushed or released, we increment the counter
    // The counter has to be maxed out before we decide that the push-button state has changed
    wire pb_idle = (pb_state==pb_sync_1);
    wire pb_cnt_max = &pb_cnt;	// true when all bits of PB_cnt are 1's
    
    always @(posedge clk) begin
        if(pb_idle) pb_cnt <= 0;  // nothing's going on
        else begin
            pb_cnt <= pb_cnt + 16'd1;  // something's going on, increment the counter
            if(pb_cnt_max) pb_state <= ~pb_state;  // if the counter is maxed out, PB changed!
        end
    end
    
    assign pb_down = ~pb_idle & pb_cnt_max & pb_state;
endmodule
