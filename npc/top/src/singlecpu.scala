package singlecpu

import Memory._
import Trace._
import instsinfo._

import chisel3._

class MemorRegMux extends Module {
  val io = IO(new Bundle {
    val memdata = Input(UInt(32.W))
    val regdata = Input(UInt(32.W))
    val memen   = Input(Bool())

    val out = Output(UInt(32.W))
  })
  io.out := Mux(io.memen, io.memdata, io.regdata)
}

class CSRALUMUX extends Module {
  val io = IO(new Bundle {
    val aludata   = Input(UInt(32.W))
    val csrdata   = Input(UInt(32.W))
    val choosecsr = Input(Bool())
    val out       = Output(UInt(32.W))
  })
  io.out := Mux(io.choosecsr, io.csrdata, io.aludata)
}

class CSR extends Module {
  val io = IO(new Bundle {
    val idx       = Input(UInt(12.W))
    val wr        = Input(Bool())
    val wpc       = Input(Bool())
    val re        = Input(Bool())
    val pc        = Input(UInt(32.W))
    val rs1data   = Input(UInt(32.W))
    val ecall     = Input(Bool())
    val mret      = Input(Bool())
    val dataout   = Output(UInt(32.W))
    val pcdataout = Output(UInt(32.W))

  })
  val csrfile = RegInit(VecInit(Seq.fill(4)(0.U(32.W))))
  when(io.wr || io.wpc) {
    when(io.idx === 0x300.U) {
      csrfile(0) := io.rs1data
    }.elsewhen(io.idx === 0x341.U) {
      csrfile(1) := Mux(io.wpc, io.pc, io.rs1data)
    }.elsewhen(io.idx === 0x342.U) {
      csrfile(2) := io.rs1data
    }.elsewhen(io.idx === 0x305.U) {
      csrfile(3) := io.rs1data
    }.elsewhen(io.ecall) {
      csrfile(1) := io.pc
      csrfile(2) := "hb".U
    }
  }
  when(io.re) {
    when(io.idx === 0x300.U) {
      io.dataout := csrfile(0)

    }.elsewhen(io.idx === 0x341.U) {
      io.dataout := csrfile(1)
    }.elsewhen(io.idx === 0x342.U) {
      io.dataout := csrfile(2) //由于ecall无法读a5，所以用hb代替

    }.elsewhen(io.idx === 0x305.U) {
      io.dataout := csrfile(3)
    }.otherwise {
      io.dataout := 0.U
    }
  }.otherwise {
    io.dataout := 0.U
  }
  io.pcdataout := Mux(io.ecall, csrfile(3), csrfile(1))

}

class CSRCTL extends Module {
  val io = IO(new Bundle {
    val ctl       = Input(UInt(3.W))
    val rd        = Input(UInt(5.W))
    val rs1       = Input(UInt(5.W))
    val wreg      = Output(Bool())
    val wpc       = Output(Bool())
    val read      = Output(Bool())
    val choosecsr = Output(Bool())
    val jump      = Output(Bool())
    val ecall     = Output(Bool())
    val mret      = Output(Bool())
  })
  when(io.ctl === CSRCTL.NOP) {
    io.wreg      := false.B
    io.wpc       := false.B
    io.read      := false.B
    io.choosecsr := false.B
    io.jump      := false.B
    io.ecall     := false.B
    io.mret      := false.B
  }.elsewhen(io.ctl === CSRCTL.WR) {
    io.wreg      := true.B
    io.wpc       := false.B
    io.read      := Mux(io.rd === 0.U, false.B, true.B)
    io.jump      := false.B
    io.choosecsr := true.B
    io.ecall     := false.B
    io.mret      := false.B
  }.elsewhen(io.ctl === CSRCTL.RD) {
    io.wreg      := Mux(io.rs1 === 0.U, false.B, true.B)
    io.wpc       := false.B
    io.read      := true.B
    io.choosecsr := true.B
    io.jump      := false.B
    io.ecall     := false.B
    io.mret      := false.B
  }.elsewhen(io.ctl === CSRCTL.ECALL) {
    io.wreg      := false.B
    io.wpc       := true.B
    io.read      := false.B
    io.choosecsr := false.B
    io.jump      := true.B
    io.ecall     := true.B
    io.mret      := false.B
  }.elsewhen(io.ctl === CSRCTL.MRET) {
    io.wreg      := false.B
    io.wpc       := false.B
    io.read      := false.B
    io.choosecsr := false.B
    io.jump      := true.B
    io.ecall     := false.B
    io.mret      := true.B
  }.otherwise {
    io.wreg      := false.B
    io.wpc       := false.B
    io.read      := false.B
    io.choosecsr := false.B
    io.jump      := false.B
    io.ecall     := false.B
    io.mret      := false.B
  }
}

import IFU.IFU
import IDU.IDU
import EXU.EXU
import WB.NextPc

class Core extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val nextpc = Output(UInt(32.W))
    val pc     = Output(UInt(32.W))
  })

  val ifu    = Module(new IFU)
  val idu    = Module(new IDU)
  val exu    = Module(new EXU)
  val nextpc = Module(new NextPc)

  val endnpc = Module(new EndNpc)

  val insttrace = Module(new InstTrace)
  val ftrace    = Module(new Ftrace)

  val memorregmux = Module(new MemorRegMux)
  val datamem     = Module(new DataMem)

  val csrctl    = Module(new CSRCTL)
  val csr       = Module(new CSR)
  val csralumux = Module(new CSRALUMUX)

  ifu.io.ifu2idu <> idu.io.ifu2idu
  idu.io.idu2exu <> exu.io.idu2exu

  csr.io.idx     := ifu.io.instout(31, 20)
  csr.io.wr      := csrctl.io.wreg
  csr.io.re      := csrctl.io.read
  csr.io.wpc     := csrctl.io.wpc
  csr.io.pc      := ifu.io.pc
  csr.io.rs1data := idu.io.rs1out
  csr.io.ecall   := csrctl.io.ecall
  csr.io.mret    := csrctl.io.mret

  csrctl.io.ctl := idu.io.csrctl
  csrctl.io.rd  := ifu.io.instout(11, 7)
  csrctl.io.rs1 := ifu.io.instout(19, 15)

  csralumux.io.aludata   := memorregmux.io.out
  csralumux.io.csrdata   := csr.io.dataout
  csralumux.io.choosecsr := csrctl.io.choosecsr

  memorregmux.io.memdata := datamem.io.dataout
  memorregmux.io.regdata := exu.io.out
  memorregmux.io.memen   := idu.io.tomemorreg

  datamem.io.addr  := exu.io.out
  datamem.io.data  := idu.io.rs2out
  datamem.io.wr    := idu.io.memwr
  datamem.io.wmask := idu.io.memctl
  datamem.io.clock := clock
  datamem.io.valid := idu.io.memrd

  nextpc.io.imm   := idu.io.immout
  nextpc.io.rs1   := idu.io.rs1out
  nextpc.io.pclj  := exu.io.pclj
  nextpc.io.pcrs1 := exu.io.pcrs1

  nextpc.io.csrjump := csrctl.io.jump
  nextpc.io.csrdata := csr.io.pcdataout
  nextpc.io.pc      := ifu.io.pc
  ifu.io.instin     := io.inst
  ifu.io.pcin       := nextpc.io.nextpc
  io.pc             := ifu.io.pc

  exu.io.ctl := idu.io.jumpctl

  idu.io.regdatain := csralumux.io.out
  idu.io.wr        := idu.io.regwr

  endnpc.io.endflag := exu.io.end
  endnpc.io.state   := idu.io.end_state

  exu.io.r1type := idu.io.s1type
  exu.io.r2type := idu.io.s2type

  exu.io.op := idu.io.op

  insttrace.io.inst  := ifu.io.instout
  insttrace.io.pc    := ifu.io.pc
  insttrace.io.clock := clock

  ftrace.io.inst   := ifu.io.instout
  ftrace.io.pc     := ifu.io.pc
  ftrace.io.nextpc := nextpc.io.nextpc
  ftrace.io.clock  := clock
  ftrace.io.jump   := idu.io.ftrace

  io.nextpc := nextpc.io.nextpc
}
