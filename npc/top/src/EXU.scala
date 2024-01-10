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

import datapath.IDU2EXUPath

class EXU extends Module {
  val io = IO(new Bundle {
    val idu2exu = Flipped(Decoupled(new IDU2EXUPath))
    val r2type  = Input(UInt(2.W))
    val r1type  = Input(Bool())
    val end     = Output(Bool())
  })
  val r1mux = Module(new R1mux)
  val r2mux = Module(new R2mux)

  val alu = Module(new Alu)

  r1mux.io.pc     := io.idu2exu.bits.pc
  r1mux.io.rs1    := io.idu2exu.bits.rs1
  r1mux.io.r1type := io.r1type

  r2mux.io.rs2    := io.idu2exu.bits.rs2
  r2mux.io.imm    := io.idu2exu.bits.imm
  r2mux.io.r2type := io.r2type

}
