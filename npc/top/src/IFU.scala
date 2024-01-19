package IFU

import chisel3._
import chisel3.util._

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

    val diff = Output(Bool())

  })
  val pc      = Module(new PC)
  val instmem = Module(new InstMem)

  //state
  val s_begin :: s_free :: s_working :: Nil = Enum(3)
  val state                                 = RegInit(s_begin)
  state := MuxLookup(
    state,
    s_free,
    List(
      s_begin -> Mux(io.pcin === "h0000_0004".U, s_free, s_begin),
      s_free -> Mux(instmem.io.inst_valid, s_working, s_free),
      s_working -> Mux(io.ifu2idu.ready, s_free, s_working)
    )
  )

  val ifu2iduPath = Wire(new IFU2IDUPath)
  ifu2iduPath.pc   := Mux(state === s_begin, "h8000_0000".U, pc.io.pc)
  ifu2iduPath.inst := instmem.io.inst

  val axistate = RegEnable(ifu2iduPath, state === s_free)
  io.ifu2idu.bits := axistate
//Fixme: 用来规避最开始的nextpc问题
  pc.io.pcin := Mux(state === s_begin, "h8000_0000".U, io.pcin)
  io.pc      := Mux(state === s_begin, "h8000_0000".U, io.pcin)

  io.instout    := instmem.io.inst
  instmem.io.pc := Mux(io.pcin === "h0000_0004".U, "h8000_0000".U, io.pcin)

  io.ifu2idu.valid := instmem.io.inst_valid

  instmem.io.en := Mux(state === s_free, true.B, false.B)

  // io.diff := ~instmem.io.inst_valid
  when(io.pcin === "h0000_0004".U) {
    io.diff := false.B
  }.otherwise {
    io.diff := Mux(state === s_free, true.B, false.B)
  }

}
