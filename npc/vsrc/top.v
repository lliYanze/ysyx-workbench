module top(
    input wire clk,
    input wire ret,
    input wire ps2_clk,
    input wire ps2_data,
    output reg[7:0] seg_led0,
    output reg[7:0] seg_led1,
    output reg[7:0] seg_led2,
    output reg[7:0] seg_led3,
    output reg[7:0] seg_led4,
    output reg[7:0] seg_led5
);

reg [7:0] buffer;

reg  key_clk;
reg [7:0] num_count;
reg [7:0] asc;

key key0(.clk(clk), .resetn(~ret), .ps2_clk(ps2_clk), .ps2_data(ps2_data), .out_buffer(buffer), .key_clk(key_clk), .num_count(num_count));

vmem vmem0(.clk(key_clk), .addr(buffer), .asc(asc));

seg seg0(.clk(key_clk), .input_num(buffer[3:0]), .output_seg(seg_led0));
seg seg1(.clk(key_clk), .input_num(buffer[7:4]), .output_seg(seg_led1));
seg seg4(.clk(key_clk), .input_num(num_count[3:0]), .output_seg(seg_led4));
seg seg5(.clk(key_clk), .input_num(num_count[7:4]), .output_seg(seg_led5));

seg seg2(.clk(key_clk), .input_num(asc[3:0]), .output_seg(seg_led2));
seg seg3(.clk(key_clk), .input_num(asc[7:4]), .output_seg(seg_led3));


endmodule



module vmem(clk, addr, asc);
input clk;
input reg[7:0] addr;
output reg[7:0] asc;

reg [7:0] mem[255:0];


initial begin
    mem[8'h1c] = 8'h41;
    mem[8'h32] = 8'h42;
    mem[8'h21] = 8'h43;
    mem[8'h23] = 8'h44;
    mem[8'h24] = 8'h45;
end

assign   asc = mem[addr];

endmodule


