
 import "DPI-C" function void data_write(input int addr, input int data, input bit[2:0] wmask);
 import "DPI-C" function void data_read(input int addr, output int dataout);
module DataMem(
    input wire [31:0] addr,
    input wire [31:0] data,
    input wire [2:0] wmask,
    input wire wr,
    input wire clock,
    output wire [31:0] dataout
);
 always @(posedge clock)
    if (wr) data_write(addr, data, wmask);
    else data_read(addr, dataout);

endmodule
