module top(
    input wire[3:0] A,
    input wire[3:0] B,
    input wire[2:0] mod,
    output reg[3:0] result,
    output reg zero,
    output reg C,
    output reg overflow
);

always @(A or B or mod) begin
    case(mod)
        3'b000: begin {C,result} = A + B;  end //add
        default: begin C = 1'b0; zero = 1'b0;result = 4'b0000;overflow = 1'b0;end
    endcase
end

endmodule
