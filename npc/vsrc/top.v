module top(
    input wire[3:0] A,
    input wire[3:0] B,
    input wire[2:0] mod,
    output reg[3:0] result,
    output reg zero,
    output reg C,
    output reg overflow
);

reg [3:0] B_complement = 4'b0000;
always @(A or B or mod) begin
    B_complement = 4'b0000;
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
            //{C,result} = A + ~B + 1;  
            overflow = (A[3] == B_complement[3])&(A[3] != result[3]);
            //overflow = (A[3] == [3])&(A[3] != result[3]);
            zero = ~(|result);

        end
        //取反
        3'b010: begin
            zero = 0;
            overflow = 0;
            C = 0;
            if(A[3]) 
                result = {A[3],~A[2:0]};
            else 
                result = A;
        end
        3'b011: begin
            result = A & B;
            zero = 0;
            overflow = 0;
            C = 0;
        end
        //或
        3'b100: begin
            result = A | B;
            zero = 0;
            overflow = 0;
            C = 0;
        end

        //异或
        3'b101: begin
            result = A ^ B;
            zero = 0;
            overflow = 0;
            C = 0;
        end
        //比较大小
        3'b110 : begin 
            if(A[3] > B[3]) begin
                C = 1;
                zero = 0;
                result = 0;
                overflow = 0;
            end
            else begin
                B_complement = ~B + 1;
                {C,result} = A + B_complement;  
                zero = ~(|result[2:0]);
                overflow = (A[3] == B[3])&(A[3] != result[3]);
                if(result[3] ) 
                    C = 1;
                else 
                    C = 0;
            end
        end


        default: begin C = 1'b0; zero = 1'b0;result = 4'b0000;overflow = 1'b0;end
    endcase
end

endmodule
