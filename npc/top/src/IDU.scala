package IDU

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

import instsinfo._

class ImmGen extends Module {
  val io = IO(new Bundle {
    val format = Input(UInt(3.W))
    val inst   = Input(UInt(32.W))
    val out    = Output(UInt(32.W))
  })

  when(io.format === TYPE.I) {
    io.out := Cat(Fill(20, io.inst(31)), io.inst(31, 20))
  }.elsewhen(io.format === TYPE.U) { //U型指令是imm为高20位
    io.out := Cat(io.inst(31, 12), Fill(12, 0.U(1.W)))
  }.elsewhen(io.format === TYPE.J) {
    io.out := Cat(Fill(12, io.inst(31)), io.inst(31), io.inst(19, 12), io.inst(20), io.inst(30, 21), 0.U(1.W))
  }.elsewhen(io.format === TYPE.S) {
    io.out := Cat(Fill(20, io.inst(31)), io.inst(31, 25), io.inst(11, 7))
  }.elsewhen(io.format === TYPE.B) {
    //imm = {inst[31], inst[7], inst[30:25], inst[11:8], 0'b0}
    //          12     11            10-5          4-1     0
    io.out := Cat(Fill(19, io.inst(31)), io.inst(31), io.inst(7), io.inst(30, 25), io.inst(11, 8), 0.U)
  }.otherwise {
    io.out := 0.U
  }
}

class RegFile extends Module {
  val io = IO(new Bundle {
    val rs1    = Input(UInt(5.W))
    val rs2    = Input(UInt(5.W))
    val rd     = Input(UInt(5.W))
    val wr     = Input(Bool())
    val datain = Input(UInt(32.W))

    val rs1out    = Output(UInt(32.W))
    val rs2out    = Output(UInt(32.W))
    val end_state = Output(UInt(32.W))

  })

  val regfile = RegInit(VecInit(Seq.fill(32)(0.U(32.W))))
  io.end_state := regfile(10.U)
  val datain = Wire(UInt(32.W))
  datain := io.datain
  when(io.wr) {
    regfile(io.rd) := Mux(io.rd === 0.U, 0.U, datain)
  }

  io.rs1out := regfile(io.rs1)
  io.rs2out := regfile(io.rs2)

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

import datapath.{IDU2EXUPath, IFU2IDUPath}
import InstDecode._

class IDU extends Module {
  val io = IO(new Bundle {
    val ifu2idu = Flipped(Decoupled(new IFU2IDUPath))
    val idu2exu = Decoupled(new IDU2EXUPath)

    val s1type     = Output(Bool()) //true : reg, false : PC
    val s2type     = Output(UInt(2.W)) //ture : reg, false : imm
    val jumpctl    = Output(UInt(3.W))
    val op         = Output(UInt(4.W))
    val ftrace     = Output(Bool())
    val memrd      = Output(Bool())
    val memwr      = Output(Bool())
    val memctl     = Output(UInt(3.W))
    val tomemorreg = Output(Bool())
    val regwr      = Output(Bool())
    val csrctl     = Output(UInt(3.W))

    val immout = Output(UInt(32.W))

    val rs1out    = Output(UInt(32.W))
    val rs2out    = Output(UInt(32.W))
    val wr        = Input(Bool())
    val regdatain = Input(UInt(32.W))

    val end_state = Output(UInt(32.W))

    //csrctl未实现总线
    val wreg      = Output(Bool())
    val wpc       = Output(Bool())
    val read      = Output(Bool())
    val choosecsr = Output(Bool())
    val jump      = Output(Bool())
    val ecall     = Output(Bool())
    val mret      = Output(Bool())

  })

  val immgen  = Module(new ImmGen)
  val decode  = Module(new InstDecode)
  val regfile = Module(new RegFile)
  val csrctl  = Module(new CSRCTL)

  csrctl.io.ctl := decode.io.csrctl
  csrctl.io.rd  := io.ifu2idu.bits.inst(11, 7)
  csrctl.io.rs1 := io.ifu2idu.bits.inst(19, 15)

  decode.io.inst := io.ifu2idu.bits.inst

  io.idu2exu.bits.pc   := io.ifu2idu.bits.pc
  io.idu2exu.bits.inst := io.ifu2idu.bits.inst
  io.idu2exu.bits.imm  := immgen.io.out
  io.idu2exu.bits.rs1  := regfile.io.rs1out
  io.idu2exu.bits.rs2  := regfile.io.rs2out

  io.ifu2idu.ready := true.B
  io.idu2exu.valid := true.B

  immgen.io.format := decode.io.format
  immgen.io.inst   := io.ifu2idu.bits.inst

  regfile.io.rs1 := io.ifu2idu.bits.inst(19, 15)
  regfile.io.rs2 := io.ifu2idu.bits.inst(24, 20)
  regfile.io.rd  := io.ifu2idu.bits.inst(11, 7)

  regfile.io.wr     := io.wr
  regfile.io.datain := io.regdatain

  io.s1type     := decode.io.s1type
  io.s2type     := decode.io.s2type
  io.jumpctl    := decode.io.jumpctl
  io.op         := decode.io.op
  io.ftrace     := decode.io.ftrace
  io.memrd      := decode.io.memrd
  io.memwr      := decode.io.memwr
  io.memctl     := decode.io.memctl
  io.tomemorreg := decode.io.tomemorreg
  io.regwr      := decode.io.regwr
  io.csrctl     := decode.io.csrctl

  io.immout := immgen.io.out

  io.rs1out := regfile.io.rs1out
  io.rs2out := regfile.io.rs2out

  io.end_state := regfile.io.end_state

  io.wreg      := csrctl.io.wreg
  io.wpc       := csrctl.io.wpc
  io.read      := csrctl.io.read
  io.choosecsr := csrctl.io.choosecsr
  io.jump      := csrctl.io.jump
  io.ecall     := csrctl.io.ecall
  io.mret      := csrctl.io.mret

}
