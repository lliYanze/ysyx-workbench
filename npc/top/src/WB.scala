package WB

import chisel3._

class NextPc extends Module {
  val io = IO(new Bundle {
    val pc      = Input(UInt(32.W))
    val csrjump = Input(Bool())
    val csrdata = Input(UInt(32.W))
    val pclj    = Input(Bool()) //true imm ,false +4
    val pcrs1   = Input(Bool()) //true rs1 ,false PC
    val imm     = Input(UInt(32.W))
    val rs1     = Input(UInt(32.W))
    val nextpc  = Output(UInt(32.W))
  })
  when(io.csrjump) {
    io.nextpc := io.csrdata
  }.otherwise {
    io.nextpc := Mux(io.pclj, io.imm, 4.U) + Mux(io.pcrs1, io.rs1, io.pc)
  }

}
