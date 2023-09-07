module top(
    input wire sw_clk,
    output reg[7:0] seg_led0,
    output reg[7:0] seg_led1,
    output reg[7:0] ledr
);

reg [7:0] random_num;

seg seg0(.input_num(random_num[3:0]), .output_seg(seg_led0));
seg seg1(.input_num(random_num[7:4]), .output_seg(seg_led1));
reg C;


always @(posedge sw_clk) begin
    if(random_num == 8'b00000000) 
        random_num <= 8'b00100000;
    else begin
        C <= ^random_num[4:1]^random_num[0];
        random_num <= {C, random_num[7:1]};
    end
end

always @(random_num) begin
    ledr = random_num;
end


endmodule
