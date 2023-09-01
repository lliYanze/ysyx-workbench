module top(
    input wire[1:0] Y,
    input wire[1:0] X0,
    input wire[1:0] X1,
    input wire[1:0] X2,
    input wire[1:0] X3,
    output reg[1:0] F
    
);


always @(Y or X0 or X1 or X2 or X3) begin
    case(Y) 
        2'b00: F = X0;
        2'b01: F = X1;
        2'b10: F = X2;
        2'b11: F = X3;
        default: F = 2'b0;
    endcase
    end
endmodule
