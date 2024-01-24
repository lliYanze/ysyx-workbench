package npctools

import chisel3._
import chisel3.util._
import chisel3.util.random.LFSR

class CustomShiftRegister(depth: Int, width: Int) extends Module {
  val io = IO(new Bundle {
    val in         = Input(UInt(width.W))
    val real_depth = Input(UInt(log2Ceil(depth).W))
    val out        = Output(UInt(width.W))
  })
  assert(
    log2Ceil(depth) >= io.real_depth.getWidth,
    "real_depth`s width must be less than or equal to depth`s width"
  )
  assert(io.real_depth >= 0.U, "depth must be not less than 0")
  assert(io.real_depth <= 15.U, "real_depth must not greater than 15")

  val regs = RegInit(VecInit(Seq.fill(16)(0.U(width.W))))

  // 输入连接到第一个寄存器
  regs(0) := io.in

  // 每个寄存器连接到下一个寄存器
  regs(1)  := Mux(1.U <= io.real_depth - 1.U, regs(0), 0.U)
  regs(2)  := Mux(2.U <= io.real_depth - 1.U, regs(1), 0.U)
  regs(3)  := Mux(3.U <= io.real_depth - 1.U, regs(2), 0.U)
  regs(4)  := Mux(4.U <= io.real_depth - 1.U, regs(3), 0.U)
  regs(5)  := Mux(5.U <= io.real_depth - 1.U, regs(4), 0.U)
  regs(6)  := Mux(6.U <= io.real_depth - 1.U, regs(5), 0.U)
  regs(7)  := Mux(7.U <= io.real_depth - 1.U, regs(6), 0.U)
  regs(8)  := Mux(8.U <= io.real_depth - 1.U, regs(7), 0.U)
  regs(9)  := Mux(9.U <= io.real_depth - 1.U, regs(8), 0.U)
  regs(10) := Mux(10.U <= io.real_depth - 1.U, regs(9), 0.U)
  regs(11) := Mux(11.U <= io.real_depth - 1.U, regs(10), 0.U)
  regs(12) := Mux(12.U <= io.real_depth - 1.U, regs(11), 0.U)
  regs(13) := Mux(13.U <= io.real_depth - 1.U, regs(12), 0.U)
  regs(14) := Mux(14.U <= io.real_depth - 1.U, regs(13), 0.U)
  regs(15) := Mux(15.U <= io.real_depth - 1.U, regs(14), 0.U)

  // 输出连接到实际寄存器
  io.out := regs(io.real_depth - 1.U)

}

class DelayTrueRandomCycle extends Module {
  val io = IO(new Bundle {
    val en  = Input(Bool())
    val out = Output(Bool())
  })

  val s_idle :: s_working :: s_delay :: Nil = Enum(3)

  val state          = RegInit(s_idle)
  val en             = RegNext(io.en)
  val delay_register = Module(new CustomShiftRegister(16, 1))
  val RANDOM: UInt = LFSR(4) % 15.U + 1.U
  val random_flush = RegEnable(RANDOM, RANDOM, state === s_idle & io.en & ~en)

  delay_register.io.real_depth := random_flush
  delay_register.io.in         := io.en
  io.out                       := delay_register.io.out
  state := MuxLookup(
    state,
    s_idle,
    List(
      s_idle -> Mux(io.en, s_working, s_idle),
      s_working -> Mux(delay_register.io.out.asBool, s_delay, s_working),
      s_delay -> Mux(~delay_register.io.out.asBool, s_idle, s_delay)
    )
  )
}
