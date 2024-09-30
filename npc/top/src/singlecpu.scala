package singlecpu

import Trace._
import instsinfo._

import chisel3._
import chisel3.util.DecoupledIO

import IFU.IFU
import IDU.IDU
import EXU.EXU
import WB.WB

import Memory._
import datapath._

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

object AxiConnect {
  def apply[T <: Data](left: AxiLiteSignal_M, right: AxiLiteSignal_S) = {
    right.master := left.master
    left.slaver  := right.slaver
  }
}

class Core extends Module {
  val io = IO(new Bundle {
    val nextpc = Output(UInt(32.W))
    val pc     = Output(UInt(32.W))
    val diff   = Output(Bool())
  })
  val ifu = Module(new IFU)
  val idu = Module(new IDU)
  val exu = Module(new EXU)
  val wb  = Module(new WB)

  // val instmemaxi = Module(new InstMemAxi)
  // val datamemaxi = Module(new DataMemAxi)
  val memaxi = Module(new MemAxi)

  val endnpc    = Module(new EndNpc)
  val insttrace = Module(new InstTrace)
  val ftrace    = Module(new Ftrace)

  //链接外部信号
  io.nextpc := wb.io.nextpc
  io.pc     := ifu.io.pc
  io.diff   := ifu.io.diff

  StageConnect(ifu.io.ifu2idu, idu.io.ifu2idu)
  StageConnect(idu.io.idu2exu, exu.io.idu2exu)
  StageConnect(exu.io.exu2wb, wb.io.exu2wb)
  StageConnect(idu.io.ctrlpath, exu.io.ctrlpath)
  StageConnect(exu.io.wbctrlpath, wb.io.wbctrlpath)

  // AxiConnect(ifu.axi2mem, instmemaxi.axi)
  // AxiConnect(wb.axi2mem, datamemaxi.axi)
  AxiConnect(ifu.axi2mem, memaxi.getifuaxi)
  AxiConnect(wb.axi2mem, memaxi.getwbaxi)

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
