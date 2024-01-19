package Alu

import instsinfo._
import chisel3._
import chisel3.util.MuxLookup

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

  io.out := MuxLookup(
    io.op,
    0.U,
    (
      Seq(
        OPCTL.ADD -> (io.s1 + io.s2),
        OPCTL.END -> 0.U,
        OPCTL.SUB -> (io.s1 - io.s2),
        OPCTL.SLT -> Mux(io.s1.asSInt < io.s2.asSInt, 1.U, 0.U),
        OPCTL.SLTU -> Mux(io.s1 < io.s2, 1.U, 0.U),
        OPCTL.AND -> (io.s1 & io.s2),
        OPCTL.SLL -> (io.s1 << io.s2(4, 0)),
        OPCTL.SRL -> (io.s1 >> io.s2(4, 0)),
        OPCTL.SRA -> (io.s1.asSInt >> io.s2(4, 0)).asUInt,
        OPCTL.LUI -> io.s2,
        OPCTL.XOR -> (io.s1 ^ io.s2),
        OPCTL.OR -> (io.s1 | io.s2)
      )
    )
  )

  io.eq := MuxLookup(
    io.op,
    false.B,
    (
      Seq(
        OPCTL.SLT -> ((io.s1 - io.s2) === 0.U),
        OPCTL.SLTU -> (io.out === 0.U)
      )
    )
  )

  io.less := MuxLookup(
    io.op,
    false.B,
    (
      Seq(
        OPCTL.SLT -> (io.s1.asSInt < io.s2.asSInt),
        OPCTL.SLTU -> (io.s1 < io.s2)
      )
    )
  )

  io.end := MuxLookup(
    io.op,
    false.B,
    (
      Seq(
        OPCTL.END -> true.B
      )
    )
  )

}
