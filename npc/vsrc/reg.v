module digital_led(
    input [2:0] input_num,
    output reg [7:0] output_seg
);

always @(input_num) begin

    case(input_num)
        3'b000: output_seg = 8'b00000011;
        3'b001: output_seg = 8'b11110011;
        3'b010: output_seg = 8'b00100101;
        3'b011: output_seg = 8'b00001101;
        3'b100: output_seg = 8'b10011001;
        3'b101: output_seg = 8'b01001001;
        3'b110: output_seg = 8'b01000001;
        3'b111: output_seg = 8'b00011111;
        default: output_seg= 8'b00000000;
    endcase

end
endmodule
