package EXU

import chisel3._
import chisel3.util._
import instsinfo._

import Alu._

class R1mux extends Module {
  val io = IO(new Bundle {
    val r1type = Input(Bool())
    val rs1    = Input(UInt(32.W))
    val pc     = Input(UInt(32.W))
    val r1out  = Output(UInt(32.W))
  })

  io.r1out := Mux(io.r1type, io.rs1, io.pc)
}

class R2mux extends Module {
  val io = IO(new Bundle {
    val r2type = Input(UInt(2.W))
    val rs2    = Input(UInt(32.W))
    val imm    = Input(UInt(32.W))
    val r2out  = Output(UInt(32.W))
  })

  io.r2out := Mux(io.r2type(1), 4.U(32.W), Mux(io.r2type(0), io.rs2, io.imm))
}

class JumpCtl extends Module {
  val io = IO(new Bundle {
    val ctl   = Input(UInt(3.W))
    val eq    = Input(Bool())
    val less  = Input(Bool())
    val pclj  = Output(Bool()) //ture : imm, false : +4
    val pcrs1 = Output(Bool()) //ture : rs1, false : PC
  })

  val pcLJ: Bool = true.B
  val pcA4: Bool = false.B

  val pcR:  Bool = true.B
  val pcPC: Bool = false.B

  when(io.ctl === JUMPCTL.JLPC) {
    io.pclj  := pcLJ
    io.pcrs1 := pcPC
  }.elsewhen(io.ctl === JUMPCTL.JLRS1) {
    io.pclj  := pcLJ
    io.pcrs1 := pcR
  }.elsewhen(io.ctl === JUMPCTL.NOTJUMP) {
    io.pclj  := pcA4
    io.pcrs1 := pcPC
  }.elsewhen(io.ctl === JUMPCTL.JEQ) {
    io.pclj  := Mux(io.eq, pcLJ, pcA4)
    io.pcrs1 := pcPC
  }.elsewhen(io.ctl === JUMPCTL.JNE) {
    io.pclj  := Mux(io.eq, pcA4, pcLJ)
    io.pcrs1 := pcPC
  }.elsewhen(io.ctl === JUMPCTL.JLT) {
    io.pclj  := Mux(io.less, pcLJ, pcA4)
    io.pcrs1 := pcPC
  }.elsewhen(io.ctl === JUMPCTL.JGE) {
    io.pclj  := Mux(io.less, pcA4, pcLJ)
    io.pcrs1 := pcPC
  }.otherwise {
    io.pclj  := pcA4
    io.pcrs1 := pcPC
  }
}

import datapath.IDU2EXUPath
import datapath.EXU2WBPath
import datapath.CtrlPath
import datapath.WBCtrlPath

class EXU extends Module {
  val io = IO(new Bundle {
    val exu2wb     = Decoupled(new EXU2WBPath)
    val idu2exu    = Flipped(Decoupled(new IDU2EXUPath))
    val ctrlpath   = Flipped(Decoupled(new CtrlPath))
    val wbctrlpath = Decoupled(new WBCtrlPath)
    val end        = Output(Bool())
  })
  val r1mux   = Module(new R1mux)
  val r2mux   = Module(new R2mux)
  val jumpctl = Module(new JumpCtl)
  val alu     = Module(new Alu)

//两总线之间的连接
  io.wbctrlpath.bits := io.ctrlpath.bits.wbctrlpath
  //idu2exu
  io.exu2wb.bits.pc   := io.idu2exu.bits.pc
  io.exu2wb.bits.inst := io.idu2exu.bits.inst

  //exu2wb
  io.exu2wb.bits.pclj        := jumpctl.io.pclj
  io.exu2wb.bits.pcrs1       := jumpctl.io.pcrs1
  io.exu2wb.bits.datamemaddr := alu.io.out

  r1mux.io.pc     := io.idu2exu.bits.pc
  r1mux.io.rs1    := io.idu2exu.bits.rs1
  r1mux.io.r1type := io.ctrlpath.bits.exuctrlpath.rs1type

  r2mux.io.rs2    := io.idu2exu.bits.rs2
  r2mux.io.imm    := io.idu2exu.bits.imm
  r2mux.io.r2type := io.ctrlpath.bits.exuctrlpath.rs2type

  alu.io.s1 := r1mux.io.r1out
  alu.io.s2 := r2mux.io.r2out
  alu.io.op := io.ctrlpath.bits.exuctrlpath.alu_op

  jumpctl.io.eq   := alu.io.eq
  jumpctl.io.less := alu.io.less
  jumpctl.io.ctl  := io.ctrlpath.bits.exuctrlpath.jump_ctl

  //未实现总线临时使用部分

  io.idu2exu.ready    := true.B
  io.exu2wb.valid     := true.B
  io.ctrlpath.ready   := true.B
  io.wbctrlpath.valid := true.B

  io.end := alu.io.end
}
