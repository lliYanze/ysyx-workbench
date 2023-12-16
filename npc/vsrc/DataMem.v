
 import "DPI-C" function void data_write(input int addr, input int data, input bit[2:0] wmask);
 import "DPI-C" function int data_read(input int addr, input bit[2:0] wmask, input bit valid);
module DataMem(
    input wire [31:0] addr,
    input wire [31:0] data,
    input wire [2:0] wmask,
    input wire wr,
    input wire valid,
    input wire clock,
    output wire [31:0] dataout
);
 assign dataout = (valid & ~wr) ?  data_read(addr, wmask, valid & ~wr): 0;
 always @(posedge clock) begin
    if (wr) data_write(addr, data, wmask);
 end

endmodule
