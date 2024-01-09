package Alu

import instsinfo._
import chisel3._

class Alu extends Module {
  val io = IO(new Bundle {
    val s1   = Input(UInt(32.W))
    val s2   = Input(UInt(32.W))
    val op   = Input(UInt(4.W))
    val out  = Output(UInt(32.W))
    val eq   = Output(Bool())
    val less = Output(Bool())
    val end  = Output(Bool())
  })

  io.end := false.B

  def dnotjump: Unit = {
    io.eq   := false.B
    io.less := false.B
  }

  when(io.op === OPCTL.ADD) {
    dnotjump
    io.out := io.s1 + io.s2
  }.elsewhen(io.op === OPCTL.END) {
    dnotjump
    io.out := 0.U
    io.end := true.B
  }.elsewhen(io.op === OPCTL.NOP) {
    dnotjump
    io.out := 0.U
  }.elsewhen(io.op === OPCTL.SUB) {
    io.out := io.s1 - io.s2
    dnotjump
  }.elsewhen(io.op === OPCTL.SLT) {
    io.out  := Mux(io.s1.asSInt < io.s2.asSInt, 1.U, 0.U)
    io.eq   := (io.s1 - io.s2) === 0.U
    io.less := io.s1.asSInt < io.s2.asSInt
  }.elsewhen(io.op === OPCTL.SLTU) {
    io.out  := Mux(io.s1 < io.s2, 1.U, 0.U)
    io.eq   := io.out === 0.U
    io.less := Mux(io.s1 < io.s2, 1.U, 0.U)
  }.elsewhen(io.op === OPCTL.AND) {
    dnotjump
    io.out := io.s1 & io.s2
  }.elsewhen(io.op === OPCTL.SLL) {
    dnotjump
    io.out := io.s1 << io.s2(4, 0)
  }.elsewhen(io.op === OPCTL.SRL) {
    dnotjump
    io.out := io.s1 >> io.s2(4, 0)
  }.elsewhen(io.op === OPCTL.SRA) {
    dnotjump
    io.out := (io.s1.asSInt >> io.s2(4, 0)).asUInt
  }.elsewhen(io.op === OPCTL.LUI) {
    dnotjump
    io.out := io.s2
  }.elsewhen(io.op === OPCTL.XOR) {
    dnotjump
    io.out := io.s1 ^ io.s2
  }.elsewhen(io.op === OPCTL.OR) {
    dnotjump
    io.out := io.s1 | io.s2
  }.otherwise {
    dnotjump
    io.out := 0.U
    printf("Error: Unknown instruction! \n")
    io.end := true.B
  }
}
