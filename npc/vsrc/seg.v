module seg(
    input clk,
    input [3:0] input_num,
    output reg [7:0] output_seg
);
always @(clk) begin
    case(input_num)
        4'b0000: output_seg = 8'b11111111;
        4'b0001: output_seg = 8'b11110011;
        4'b0010: output_seg = 8'b00100101;
        4'b0011: output_seg = 8'b00001101;
        4'b0100: output_seg = 8'b10011001;
        4'b0101: output_seg = 8'b01001001;
        4'b0110: output_seg = 8'b01000001;
        4'b0111: output_seg = 8'b00011111;
        4'b1000: output_seg = 8'b00000001;
        4'b1001: output_seg = 8'b00011001;
        4'b1010: output_seg = 8'b00010001;
        4'b1011: output_seg = 8'b11000001;
        4'b1100: output_seg = 8'b01100011;
        4'b1101: output_seg = 8'b10000101;
        4'b1110: output_seg = 8'b01100001;
        4'b1111: output_seg = 8'b01110001;
        default: output_seg = 8'b11111111;
    endcase
end
endmodule
