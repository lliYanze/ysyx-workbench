package singlecpu

// import Memory._
import Trace._
import instsinfo._

import chisel3._

import IFU.IFU
import IDU.IDU
import EXU.EXU
import WB.WB

class Core extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val nextpc = Output(UInt(32.W))
    val pc     = Output(UInt(32.W))
  })

  val ifu = Module(new IFU)
  val idu = Module(new IDU)
  val exu = Module(new EXU)
  val wb  = Module(new WB)

  val endnpc = Module(new EndNpc)

  val insttrace = Module(new InstTrace)
  val ftrace    = Module(new Ftrace)

  //链接外部信号
  io.nextpc     := wb.io.nextpc
  io.pc         := ifu.io.pc
  ifu.io.instin := io.inst

  ifu.io.ifu2idu <> idu.io.ifu2idu
  idu.io.idu2exu <> exu.io.idu2exu
  exu.io.exu2wb <> wb.io.exu2wb

  ifu.io.pcin := wb.io.nextpc

  wb.io.csrwr     := idu.io.wreg
  wb.io.re        := idu.io.read
  wb.io.wpc       := idu.io.wpc
  wb.io.rs1data   := idu.io.rs1out
  wb.io.ecall     := idu.io.ecall
  wb.io.mret      := idu.io.mret
  wb.io.choosecsr := idu.io.choosecsr
  wb.io.memen     := idu.io.tomemorreg
  wb.io.data      := idu.io.rs2out
  wb.io.wr        := idu.io.memwr
  wb.io.wmask     := idu.io.memctl
  wb.io.valid     := idu.io.memrd
  wb.io.imm       := idu.io.immout
  wb.io.rs1       := idu.io.rs1out
  wb.io.csrjump   := idu.io.csrjump
  idu.io.wr       := idu.io.regwr
  exu.io.ctl      := idu.io.jumpctl
  exu.io.r1type   := idu.io.s1type
  exu.io.r2type   := idu.io.s2type
  exu.io.op       := idu.io.op

  idu.io.regdatain := wb.io.wbdataout
  wb.io.csrdata    := wb.io.csrpcdataout

  insttrace.io.inst  := ifu.io.instout
  insttrace.io.pc    := ifu.io.pc
  insttrace.io.clock := clock

  ftrace.io.inst   := ifu.io.instout
  ftrace.io.pc     := ifu.io.pc
  ftrace.io.nextpc := wb.io.nextpc
  ftrace.io.clock  := clock
  ftrace.io.jump   := idu.io.ftrace

  endnpc.io.endflag := exu.io.end
  endnpc.io.state   := idu.io.end_state

}
