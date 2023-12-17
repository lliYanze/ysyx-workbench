package singlecpu

import InstDecode._

import instsinfo._

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

class DataMem extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val addr    = Input(UInt(32.W))
    val data    = Input(UInt(32.W))
    val wr      = Input(Bool())
    val valid   = Input(Bool())
    val wmask   = Input(UInt(3.W))
    val clock   = Input(Clock())
    val dataout = Output(UInt(32.W))
  })

  setInline(
    "DataMem.v",
    s"""
       | import "DPI-C" function void data_write(input int addr, input int data, input bit[2:0] wmask);
       | import "DPI-C" function int data_read(input int addr, input bit[2:0] wmask, input bit valid);
       |module DataMem(
       |    input wire [31:0] addr,
       |    input wire [31:0] data,
       |    input wire [2:0] wmask,
       |    input wire wr,
       |    input wire valid,
       |    input wire clock,
       |    output wire [31:0] dataout
       |);
       | assign dataout = (valid & ~wr) ?  data_read(addr, wmask, valid & ~wr): 0;
       | always @(posedge clock) begin
       |    if (wr) data_write(addr, data, wmask);
       | end
       |
       |endmodule
       |""".stripMargin
  )
  // printf("datemem  dataout is %x\n", io.dataout)

}

class MemorRegMux extends Module {
  val io = IO(new Bundle {
    val memdata = Input(UInt(32.W))
    val regdata = Input(UInt(32.W))
    val memen   = Input(Bool())

    val out = Output(UInt(32.W))
  })
  io.out := Mux(io.memen, io.memdata, io.regdata)
}

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

class JumpCtl extends Module {
  val io = IO(new Bundle {
    val ctl   = Input(UInt(3.W))
    val eq    = Input(Bool())
    val less  = Input(Bool())
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
  }.elsewhen(io.ctl === JUMPCTL.JEQ) {
    io.pclj  := Mux(io.eq, pcLJ, pcA4)
    io.pcrs1 := pcPC
  }.elsewhen(io.ctl === JUMPCTL.JNE) {
    io.pclj  := Mux(io.eq, pcA4, pcLJ)
    io.pcrs1 := pcPC
  }.elsewhen(io.ctl === JUMPCTL.JLT) {
    io.pclj  := Mux(io.less, pcLJ, pcA4)
    io.pcrs1 := pcPC
  }.elsewhen(io.ctl === JUMPCTL.JGE) {
    io.pclj  := Mux(io.less, pcA4, pcLJ)
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
  val nextpc = Wire(UInt(32.W))
  val immor4 = Wire(UInt(32.W))
  immor4 := Mux(io.pclj, io.imm, 4.U)
  val rs1orpc = Wire(UInt(32.W))
  rs1orpc   := Mux(io.pcrs1, io.rs1, io.nowpc)
  nextpc    := rs1orpc + immor4
  io.nextpc := rs1orpc + immor4

}

class PC extends Module {
  val io = IO(new Bundle {
    val pcin = Input(UInt(32.W))
    val pc   = Output(UInt(32.W))
  })

  val pc = RegNext(io.pcin, "h8000_0000".U(32.W))
  pc    := io.pcin
  io.pc := pc

}

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
  // printf("rd is %x  datain: %x\n", io.rd, io.datain)

}

class Exu extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val nextpc = Output(UInt(32.W))
    val pc     = Output(UInt(32.W))

  })

  val nextpc         = Module(new NextPc)
  val pc             = Module(new PC)
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

  val memorregmux = Module(new MemorRegMux)
  val datamem     = Module(new DataMem)

  memorregmux.io.memdata := datamem.io.dataout
  memorregmux.io.regdata := alu.io.out
  memorregmux.io.memen   := source_decoder.io.tomemorreg

  datamem.io.addr  := alu.io.out
  datamem.io.data  := regfile.io.rs2out
  datamem.io.wr    := source_decoder.io.memwr
  datamem.io.wmask := source_decoder.io.memctl
  datamem.io.clock := clock
  datamem.io.valid := source_decoder.io.memrd

  rdaddr := nextpc.io.nextpc

  nextpc.io.imm   := immgen.io.out
  nextpc.io.nowpc := pc.io.pc
  nextpc.io.rs1   := regfile.io.rs1out
  nextpc.io.pclj  := jumpctl.io.pclj
  nextpc.io.pcrs1 := jumpctl.io.pcrs1

  io.pc      := pc.io.pc
  pc.io.pcin := nextpc.io.nextpc

  source_decoder.io.inst := io.inst

  jumpctl.io.ctl  := source_decoder.io.jumpctl
  jumpctl.io.eq   := alu.io.eq
  jumpctl.io.less := alu.io.less

  regfile.io.rs1 := io.inst(19, 15)
  regfile.io.rs2 := io.inst(24, 20)
  regfile.io.rd  := io.inst(11, 7)

  regfile.io.datain := memorregmux.io.out
  regfile.io.wr     := source_decoder.io.regwr

  immgen.io.format := source_decoder.io.format
  immgen.io.inst   := io.inst

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
  ftrace.io.nextpc := nextpc.io.nextpc
  ftrace.io.clock  := clock
  ftrace.io.jump   := source_decoder.io.ftrace

  io.nextpc := nextpc.io.nextpc

}
