package npctools

import chisel3._
import chisel3.util._
import chisel3.util.random.LFSR

class DelayTrueRandomCycle extends Module {
  val io = IO(new Bundle {
    val en  = Input(Bool())
    val out = Output(Bool())
  })

  //随机延迟部分
  val delaying = RegInit(false.B)
  val delay    = RegInit(0.U(4.W))
  val olddelay = RegInit(0.U(4.W))
  val RANDOM: UInt = LFSR(4, delay === 0.U) % 8.U + 1.U
  olddelay := delay
  delaying := io.en
  delay := Mux(
    delay === 0.U & olddelay === 0.U,
    Mux(io.en & ~delaying, RANDOM, 0.U),
    Mux(delay === 0.U, 0.U, delay - 1.U)
  )

  io.out :=
    Mux(olddelay === 1.U & delay === 0.U, true.B, Mux(delaying & io.en, true.B, false.B))
}
