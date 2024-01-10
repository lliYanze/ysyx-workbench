package IFU

import chisel3._
import chisel3.util.Decoupled

class PC extends Module {
  val io = IO(new Bundle {
    val csrjump = Input(Bool())
    val csrdata = Input(UInt(32.W))
    val pclj    = Input(Bool()) //true imm ,false +4
    val pcrs1   = Input(Bool()) //true rs1 ,false PC
    val imm     = Input(UInt(32.W))
    val rs1     = Input(UInt(32.W))

    val nextpc = Output(UInt(32.W))

    val pc = Output(UInt(32.W))
  })
  val pc     = RegInit("h8000_0000".U(32.W))
  val nextpc = Wire(UInt(32.W))
  when(io.csrjump) {
    nextpc := io.csrdata
  }.otherwise {
    nextpc := Mux(io.pclj, io.imm, 4.U) + Mux(io.pcrs1, io.rs1, pc)
  }
  pc        := nextpc
  io.pc     := pc
  io.nextpc := nextpc
}

import datapath.IFU2IDUPath
class IFU extends Module {
  val ifu2idu = Decoupled(new IFU2IDUPath)
  val io = IO(new Bundle {
    val instin  = Input(UInt(32.W))
    val instout = Output(UInt(32.W))

    val csrjump = Input(Bool())
    val csrdata = Input(UInt(32.W))
    val pclj    = Input(Bool()) //true imm ,false +4
    val pcrs1   = Input(Bool()) //true rs1 ,false PC
    val imm     = Input(UInt(32.W))
    val rs1     = Input(UInt(32.W))

    val nextpc = Output(UInt(32.W))

    val pc = Output(UInt(32.W))
  })
  val pc = Module(new PC)
  pc.io.csrjump := io.csrjump
  pc.io.csrdata := io.csrdata
  pc.io.pclj    := io.pclj
  pc.io.pcrs1   := io.pcrs1
  pc.io.imm     := io.imm
  pc.io.rs1     := io.rs1
  io.nextpc     := pc.io.nextpc
  io.pc         := pc.io.pc
  io.instout    := io.instin

}
