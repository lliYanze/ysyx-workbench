import chisel3._
import chisel3.util._

import singlecpu._

class TOP extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val pc     = Output(UInt(32.W))
    val nextpc = Output(UInt(32.W))
    val diff   = Output(Bool())

  })
  val core = Module(new Core)
  io.pc     := core.io.pc
  io.nextpc := core.io.nextpc
  io.diff   := core.io.diff

}
