package singlecpu

import Trace._
import instsinfo._

import chisel3._
import chisel3.util.DecoupledIO

import IFU.IFU
import IDU.IDU
import EXU.EXU
import WB.WB

object StageConnect {
  def apply[T <: Data](left: DecoupledIO[T], right: DecoupledIO[T]) = {
    val arch = "multi"
    if (arch == "single") {
      right.bits  := left.bits
      right.valid := left.valid
      left.ready  := right.ready
    } else {
      right <> left
    }
  }
}

class Core extends Module {
  val io = IO(new Bundle {
    val nextpc = Output(UInt(32.W))
    val pc     = Output(UInt(32.W))
  })

  val ifu = Module(new IFU)
  val idu = Module(new IDU)
  val exu = Module(new EXU)
  val wb  = Module(new WB)

  val endnpc    = Module(new EndNpc)
  val insttrace = Module(new InstTrace)
  val ftrace    = Module(new Ftrace)

  //链接外部信号
  io.nextpc := wb.io.nextpc
  io.pc     := ifu.io.pc

  StageConnect(ifu.io.ifu2idu, idu.io.ifu2idu)
  StageConnect(idu.io.idu2exu, exu.io.idu2exu)
  StageConnect(exu.io.exu2wb, wb.io.exu2wb)
  StageConnect(idu.io.ctrlpath, exu.io.ctrlpath)
  StageConnect(exu.io.wbctrlpath, wb.io.wbctrlpath)

  //写回时内部有关的信号
  idu.io.regdatain := wb.io.wbdataout
  idu.io.wr        := wb.io.reg_wr
  ifu.io.pcin      := wb.io.nextpc

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
