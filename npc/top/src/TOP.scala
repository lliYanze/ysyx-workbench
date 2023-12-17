import chisel3._
import chisel3.util._

import singlecpu._

class TOP extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val pc     = Output(UInt(32.W))
    val nextpc = Output(UInt(32.W))

  })
  val exu = Module(new Exu)
  io.pc       := exu.io.pc
  exu.io.inst := io.inst
  io.nextpc   := exu.io.nextpc

}
