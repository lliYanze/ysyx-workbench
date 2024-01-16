package Memory

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

class DataMem extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val addr    = Input(UInt(32.W))
    val data    = Input(UInt(32.W))
    val wr      = Input(Bool())
    val valid   = Input(Bool())
    val wmask   = Input(UInt(3.W))
    val clock   = Input(Clock())
    val dataout = Output(UInt(32.W))
  })

  setInline(
    "DataMem.v",
    s"""
       | import "DPI-C" function void data_write(input int addr, input int data, input bit[2:0] wmask);
       | import "DPI-C" function int data_read(input int addr, input bit[2:0] wmask, input bit valid);
       |module DataMem(
       |    input wire [31:0] addr,
       |    input wire [31:0] data,
       |    input wire [2:0] wmask,
       |    input wire wr,
       |    input wire valid,
       |    input wire clock,
       |    output wire [31:0] dataout
       |);
       | assign dataout = (valid & ~wr) ?  data_read(addr, wmask, valid & ~wr): 0;
       | always @(posedge clock) begin
       |    if (wr) data_write(addr, data, wmask);
       | end
       |
       |endmodule
       |""".stripMargin
  )

}
