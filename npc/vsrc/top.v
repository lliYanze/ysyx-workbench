module top(
    input wire[3:0] A,
    input wire[3:0] B,
    input wire[2:0] mod,
    output reg[3:0] result,
    output reg zero,
    output reg C,
    output reg overflow
);

reg [3:0] B_complement;
always @(A or B or mod) begin
    case(mod)
        //add
        3'b000: begin 
            {C,result} = A + B;  
            overflow = (A[3] == B[3])&(A[3] != result[3]);
            zero = ~(|result);
        end 
        //sub
        3'b001: begin
            B_complement = ~B + 1;
            {C,result} = A + B_complement;  
            overflow = (A[3] == B_complement[3])&(A[3] != result[3]);
            zero = ~(|result);

        end
        //取反
        3'b010: begin
            if(A[3]) begin
                result = {A[3],~A[2:0]};
            end 
            else begin
                result = A;
            end
        end
        default: begin C = 1'b0; zero = 1'b0;result = 4'b0000;overflow = 1'b0;end
    endcase
end

endmodule
