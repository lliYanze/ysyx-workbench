
 import "DPI-C" function void insttrace(input int pc, input int inst);
module InstTrace(
    input wire [31:0] inst,
    input wire [31:0] pc,
    input wire clock
);
 always @(posedge clock) 
    insttrace(pc, inst);

endmodule
