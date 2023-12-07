import chisel3._
import chisel3.util._

import inst._

class TOP extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))
    val out  = Output(UInt(32.W))
    val pc   = Output(UInt(32.W))
  })
  val exu = Module(new Exu)
  val pc  = RegInit("h8000_0000".U(32.W))
  pc          := pc + 4.U
  io.pc       := pc
  exu.io.inst := io.inst
  io.out      := exu.io.out
}
