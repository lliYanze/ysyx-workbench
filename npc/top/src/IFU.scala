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
  val s_begin :: s_workdown :: s_working :: Nil = Enum(3)

  val state     = RegInit(s_begin)
  val old_state = RegInit(s_begin)
  old_state := state

  state := MuxLookup(
    state,
    s_workdown,
    List(
      s_begin -> Mux(io.pcin === "h8000_0000".U, s_working, s_begin),
      s_workdown -> Mux(io.ifu2idu.ready, s_working, s_workdown),
      s_working -> Mux(instmem.io.inst_valid, s_workdown, s_working)
    )
  )

  val ifu2iduPath = Wire(new IFU2IDUPath)
  ifu2iduPath.pc   := pc.io.pc
  ifu2iduPath.inst := instmem.io.inst

  val axistate = RegEnable(ifu2iduPath, state === s_working & instmem.io.inst_valid)
  io.ifu2idu.bits := axistate
  pc.io.pcin      := io.pcin
  io.pc           := io.pcin

  io.instout    := instmem.io.inst
  instmem.io.pc := io.pcin

  io.ifu2idu.valid := (state === s_workdown)

  //Fixme: diff规避最开始0x80000000的问题
  when(axistate.pc === 0.U) {
    io.diff       := false.B
    instmem.io.en := true.B
  }.otherwise {
    io.diff       := Mux((old_state === s_workdown) & (state === s_working), true.B, false.B)
    instmem.io.en := Mux(state === s_workdown & io.ifu2idu.ready, true.B, false.B)
  }

}
