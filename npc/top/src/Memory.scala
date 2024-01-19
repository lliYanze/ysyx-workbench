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

class InstMemRead extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val pc    = Input(UInt(32.W))
    val clock = Input(Clock())
    val inst  = Output(UInt(32.W))
  })
  setInline(
    "InstMemRead.v",
    s"""
       |module InstMemRead(
       |    input wire [31:0] pc,
       |    input wire clock,
       |    output wire [31:0] inst
       |);
       | assign inst = data_read(pc, 3'b010, 1'b1);
       |endmodule
       |""".stripMargin
  )
}

class InstMemIO extends Bundle {
  val pc = Input(UInt(32.W))
  val en = Input(Bool())

  val inst       = Output(UInt(32.W))
  val inst_valid = Output(Bool())
}

class InstMem extends Module {
  val io          = IO(new InstMemIO)
  val instmemread = Module(new InstMemRead)
  val instget     = RegNext(instmemread.io.inst)

  val instvalid = Reg(Bool())
  // val instvalid = RegNext(io.en)
  io.inst_valid := instvalid
  instvalid     := ~io.en

  instmemread.io.pc    := io.pc
  instmemread.io.clock := clock

  // io.inst := instmemread.io.inst
  io.inst := instget

}
