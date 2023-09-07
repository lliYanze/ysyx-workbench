module top(
    input wire clk,
    output reg[7:0] seg_led0,
    output reg[7:0] seg_led1,
    output reg[7:0] ledr
);

reg [7:0] random_num;

seg seg0(.input_num(random_num[3:0]), .output_seg(seg_led0));
seg seg1(.input_num(random_num[7:4]), .output_seg(seg_led1));

assign random_num = 8'b00010111;


always @(random_num) begin
    ledr = random_num;
end


endmodule
