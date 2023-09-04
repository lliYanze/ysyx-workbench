module tran_8to3(
    input [7:0] tran_input_wire,
    input tran_enable,
    output reg tran_all_down,
    output reg [2:0] tran_output_wire
);

always @(tran_input_wire) begin
    if(tran_enable) begin
        case(tran_input_wire)
            8'b00000001 : begin tran_output_wire = 3'b000;tran_all_down = 1'b0;end
            8'b00000010 : begin tran_output_wire = 3'b001;tran_all_down = 1'b0;end
            8'b00000100 : begin tran_output_wire = 3'b010;tran_all_down = 1'b0;end
            8'b00001000 : begin tran_output_wire = 3'b011;tran_all_down = 1'b0;end
            8'b00010000 : begin tran_output_wire = 3'b100;tran_all_down = 1'b0;end
            8'b00100000 : begin tran_output_wire = 3'b101;tran_all_down = 1'b0;end
            8'b01000000 : begin tran_output_wire = 3'b110;tran_all_down = 1'b0;end
            8'b10000000 : begin tran_output_wire = 3'b111;tran_all_down = 1'b0;end
            default: begin tran_output_wire = 3'b000;tran_all_down = 1'b1;end
        endcase
    end
    else begin
        tran_output_wire = 3'b000;
    end
end
endmodule
