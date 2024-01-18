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
import Memory.InstMem

class IFU extends Module {
  val io = IO(new Bundle {
    val ifu2idu = Decoupled(new IFU2IDUPath)
    val instout = Output(UInt(32.W))

    val pcin = Input(UInt(32.W))
    val pc   = Output(UInt(32.W))

  })
  val pc      = Module(new PC)
  val instmem = Module(new InstMem)
  pc.io.pcin := io.pcin
  io.pc      := pc.io.pc

  io.instout    := instmem.io.inst
  instmem.io.pc := io.pcin

  io.ifu2idu.bits.pc   := pc.io.pc
  io.ifu2idu.bits.inst := instmem.io.inst

  io.ifu2idu.valid := true.B

}
