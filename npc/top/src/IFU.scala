package IFU

import chisel3._
import chisel3.util.Decoupled

class PC extends Module {
  val io = IO(new Bundle {
    val pcin = Input(UInt(32.W))
    val pc   = Output(UInt(32.W))
  })
  val pc = RegInit("h8000_0000".U(32.W))
  pc    := io.pcin
  io.pc := pc
}

import datapath.IFU2IDUPath
class IFU extends Module {
  val io = IO(new Bundle {
    val ifu2idu = Decoupled(new IFU2IDUPath)
    val instin  = Input(UInt(32.W))
    val instout = Output(UInt(32.W))

    val pcin = Input(UInt(32.W))
    val pc   = Output(UInt(32.W))
  })
  val pc = Module(new PC)
  pc.io.pcin := io.pcin
  io.pc      := pc.io.pc
  io.instout := io.instin

  io.ifu2idu.bits.pc   := pc.io.pc
  io.ifu2idu.bits.inst := io.instin
  io.ifu2idu.valid     := true.B
}
