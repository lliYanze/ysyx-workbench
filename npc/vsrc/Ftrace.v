
 import "DPI-C" function void ftrace(input int pc, input int inst, input int nextpc);
module Ftrace(
    input wire [31:0] inst,
    input wire [31:0] pc,
    input wire [31:0] nextpc,
    input wire  jump,
    input wire clock
);
 always @(posedge clock)
    if(jump) ftrace(pc, inst, nextpc);

endmodule
