package singlecpu

import InstDecode._

import instsinfo._

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

// class DataMem extends BlackBox with HasBlackBoxInline {
//   val io = IO(new Bundle {
//     val addr  = Input(UInt(32.W))
//     val data  = Input(UInt(32.W))
//     val wr    = Input(Bool())
//     val wmask = Input(UInt(4.W))
//     // val dataout = Output(UInt(32.W))
//     val clock = Input(Clock())
//   })
//
//   setInline(
//     "DataMem.v",
//     s"""
//        | import "DPI-C" function void writedata(input int addr, input int data, input char wmask);
//        | import "DPI-C" function int readdata(input int addr, output int dataout);
//        |module DataMem(
//        |    input wire [31:0] addr,
//        |    input wire [31:0] data,
//        |    input wire wr,
//        |    input wire clock,
//        |);
//        | always @(posedge clock)
//        |    if (wr) writedata(addr, data, wmask);
//        |    else readdata(addr, dataout);
//        |
//        |endmodule
//        |""".stripMargin
//   )
//
// }

// class MemorRegMux extends Module {
//   val io = IO(new Bundle {
//     val memdata = Input(UInt(32.W))
//     val regdata = Input(UInt(32.W))
//     val memen   = Input(Bool())
//     val out     = Output(UInt(32.W))
//   })
//   io.out := Mux(io.memen, io.memdata, io.regdata)
// }

class EndNpc extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val endflag = Input(Bool())
    val state   = Input(UInt(32.W))
  })

  setInline(
    "EndNpc.v",
    s"""
       | import "DPI-C" function void stopnpc(input int state);
       |module EndNpc(
       |    input endflag,
       |  input wire [31:0] state
       |);
       | always @(*) 
       |    if (endflag) stopnpc(state);
       |
       |endmodule
       |""".stripMargin
  )
}

class InstTrace extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val inst  = Input(UInt(32.W))
    val pc    = Input(UInt(32.W))
    val clock = Input(Clock())
  })

  setInline(
    "InstTrace.v",
    s"""
       | import "DPI-C" function void insttrace(input int pc, input int inst);
       |module InstTrace(
       |    input wire [31:0] inst,
       |    input wire [31:0] pc,
       |    input wire clock
       |);
       | always @(posedge clock)
       |    insttrace(pc, inst);
       |
       |endmodule
       |""".stripMargin
  )
}

class Ftrace extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val pc     = Input(UInt(32.W))
    val nextpc = Input(UInt(32.W))
    val jump   = Input(Bool())
    val clock  = Input(Clock())
  })

  setInline(
    "Ftrace.v",
    s"""
       | import "DPI-C" function void ftrace(input int pc, input int inst, input int nextpc);
       |module Ftrace(
       |    input wire [31:0] inst,
       |    input wire [31:0] pc,
       |    input wire [31:0] nextpc,
       |    input wire  jump,
       |    input wire clock
       |);
       | always @(posedge clock)
       |    if(jump) ftrace(pc, inst, nextpc);
       |
       |endmodule
       |""".stripMargin
  )
}

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

class Alu extends Module {
  val io = IO(new Bundle {
    val s1  = Input(UInt(32.W))
    val s2  = Input(UInt(32.W))
    val op  = Input(UInt(4.W))
    val out = Output(UInt(32.W))

    val rw  = Output(Bool()) //临时使用
    val end = Output(Bool())
  })

  io.end := false.B

  when(io.op === OPCTL.ADD) {
    io.out := io.s1 + io.s2
    io.rw  := true.B
  }.elsewhen(io.op === OPCTL.END) {
    io.out := 0.U
    io.rw  := false.B
    io.end := true.B
  }.elsewhen(io.op === OPCTL.NOP) {
    io.out := 0.U
    io.rw  := false.B
    printf("instruction nop!\n")
  }.otherwise {
    io.out := 0.U
    io.rw  := false.B
    io.end := true.B
    printf("Error: Unknown instruction!\n")
  }
}

class JumpCtl extends Module {
  val io = IO(new Bundle {
    val ctl   = Input(UInt(3.W))
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
  }.otherwise {
    io.pclj  := pcA4
    io.pcrs1 := pcPC
  }
}

class NextPc extends Module {
  val io = IO(new Bundle {
    val pclj   = Input(Bool()) //true imm ,false +4
    val pcrs1  = Input(Bool()) //true rs1 ,false PC
    val nowpc  = Input(UInt(32.W))
    val imm    = Input(UInt(32.W))
    val rs1    = Input(UInt(32.W))
    val nextpc = Output(UInt(32.W))
  })
  val immor4 = Wire(UInt(32.W))
  immor4 := Mux(io.pclj, io.imm, 4.U)
  val rs1orpc = Wire(UInt(32.W))
  rs1orpc   := Mux(io.pcrs1, io.rs1, io.nowpc)
  io.nextpc := rs1orpc + immor4

}

class PC extends Module {
  val io = IO(new Bundle {
    val pcin = Input(UInt(32.W))
    val pc   = Output(UInt(32.W))
  })

  val pc = RegInit("h8000_0000".U(32.W))
  pc    := io.pcin
  io.pc := pc
  // printf("PC pc: 0x%x\n", pc)

}

class ImmGen extends Module {
  val io = IO(new Bundle {
    val format = Input(UInt(3.W))
    val inst   = Input(UInt(20.W))
    val out    = Output(UInt(32.W))
  })

  when(io.format === TYPE.I) {
    io.out := Cat(Fill(20, io.inst(19)), io.inst(19, 8))
  }.elsewhen(io.format === TYPE.U) { //U型指令是imm为高20位
    io.out := Cat(io.inst(19, 0), Fill(12, 0.U(1.W)))
  }.elsewhen(io.format === TYPE.J) {
    // imm 20|19:12|11|10:1
    // inst 19|7:0 |8 |18:9
    io.out := Cat(Fill(12, io.inst(19)), io.inst(19), io.inst(7, 0), io.inst(8), io.inst(18, 9), 0.U(1.W))
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
  // val regin   = RegNext(io.datain)
  // val regfile = RegNext(VecInit(Seq.fill(32)(0.U(32.W))))
  when(io.wr) {
    regfile(io.rd) := Mux(io.rd === 0.U, 0.U, datain)
  }
  // printf("datain: 0x%x\n", datain)

  io.rs1out := regfile(io.rs1)
  io.rs2out := regfile(io.rs2)
}

class Exu extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))
    val out  = Output(UInt(32.W))
    val pc   = Output(UInt(32.W))

  })

  val nextpc = Module(new NextPc)
  val pc     = Module(new PC)
  // val source_decoder = Module(new SourceDecoder)
  val source_decoder = Module(new InstDecode)
  val immgen         = Module(new ImmGen)
  val regfile        = Module(new RegFile)
  val r1mux          = Module(new R1mux)
  val r2mux          = Module(new R2mux)
  val alu            = Module(new Alu)

  val endnpc = Module(new EndNpc)
  val rdaddr = Reg(UInt(32.W))

  val insttrace = Module(new InstTrace)
  val ftrace    = Module(new Ftrace)
  val jumpctl   = Module(new JumpCtl)

  // val datamem = Module(new DataMem)

  rdaddr := nextpc.io.nextpc

  nextpc.io.imm   := immgen.io.out
  nextpc.io.nowpc := pc.io.pc
  nextpc.io.rs1   := regfile.io.rs1out
  nextpc.io.pclj  := jumpctl.io.pclj
  nextpc.io.pcrs1 := jumpctl.io.pcrs1

  io.pc      := pc.io.pc
  pc.io.pcin := nextpc.io.nextpc

  source_decoder.io.inst := io.inst

  jumpctl.io.ctl := source_decoder.io.jumpctl

  regfile.io.rs1 := io.inst(19, 15)
  regfile.io.rs2 := io.inst(24, 20)
  regfile.io.rd  := io.inst(11, 7)

  regfile.io.datain := alu.io.out
  regfile.io.wr     := alu.io.rw

  immgen.io.format := source_decoder.io.format
  immgen.io.inst   := io.inst(31, 12)

  endnpc.io.endflag := alu.io.end
  endnpc.io.state   := regfile.io.end_state

  r1mux.io.r1type := source_decoder.io.s1type
  r1mux.io.pc     := pc.io.pc
  r1mux.io.rs1    := regfile.io.rs1out

  r2mux.io.r2type := source_decoder.io.s2type
  r2mux.io.imm    := immgen.io.out
  r2mux.io.rs2    := regfile.io.rs2out

  alu.io.op := source_decoder.io.op
  alu.io.s1 := r1mux.io.r1out
  alu.io.s2 := r2mux.io.r2out

  insttrace.io.inst  := source_decoder.io.inst
  insttrace.io.pc    := pc.io.pc
  insttrace.io.clock := clock

  ftrace.io.inst   := source_decoder.io.inst
  ftrace.io.pc     := pc.io.pc
  ftrace.io.nextpc := alu.io.out
  ftrace.io.clock  := clock
  ftrace.io.jump   := source_decoder.io.ftrace

  io.out := alu.io.out

}
