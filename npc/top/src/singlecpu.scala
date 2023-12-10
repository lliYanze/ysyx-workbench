package singlecpu

import instsinfo._

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

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

class R1mux extends Module {
  val io = IO(new Bundle {
    val r1type = Input(Bool())
    val rs1    = Input(UInt(32.W))
    val pc     = Input(UInt(32.W))
    val r1out  = Output(UInt(32.W))
  })

  io.r1out := Mux(io.r1type, io.rs1, io.pc)
  // printf("r1out: 0x%x\n", io.r1out)
  // printf("R1pc: 0x%x\n", io.pc)
}

class R2mux extends Module {
  val io = IO(new Bundle {
    val r2type = Input(Bool())
    val rs2    = Input(UInt(32.W))
    val imm    = Input(UInt(32.W))
    val r2out  = Output(UInt(32.W))
  })

  io.r2out := Mux(io.r2type, io.rs2, io.imm)
}

class Alu extends Module {
  val io = IO(new Bundle {
    val s1  = Input(UInt(32.W))
    val s2  = Input(UInt(32.W))
    val op  = Input(UInt(5.W))
    val out = Output(UInt(32.W))

    val rw  = Output(Bool()) //临时使用
    val end = Output(Bool())
  })

  io.end := false.B

  when(io.op === OP.ADD) {
    io.out := io.s1 + io.s2
    io.rw  := true.B
    printf("add\n")
  }.elsewhen(io.op === OP.END) {
    io.out := 0.U
    io.rw  := false.B
    io.end := true.B
    printf("ebreak!\n")
  }.elsewhen(io.op === OP.NOP) {
    io.out := 0.U
    io.rw  := false.B
    printf("instruction nop!\n")
  }.elsewhen(io.op === OP.JRET) {
    io.out := io.s1 + 4.U
    io.rw  := true.B
    printf("jump ret \n");

  }.otherwise {
    io.out := 0.U
    io.rw  := false.B
    io.end := true.B
    printf("Error: Unknown instruction!\n")
  }

  // printf("s1: 0x%x\t, s2: 0x%x \t, out:0x%x\n", io.s1, io.s2, io.out)
}

class SourceDecoder extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))

    val format = Output(UInt(3.W))
    val s1type = Output(Bool()) //true : reg, false : PC
    val s2type = Output(Bool()) //ture : reg, false : imm
    val pclj   = Output(Bool()) //ture : imm, false : +4
    val pcrs1  = Output(Bool()) //ture : rs1, false : PC
    val op     = Output(UInt(5.W))
  })

  val start = RegInit(0.U) //INFO:为了排除最开始时指令为0的情况

  when(io.inst === instructions().addi) {
    io.format := TYPE.I
    io.op     := OP.ADD
    io.s1type := true.B
    io.s2type := false.B
    io.pclj   := false.B
    io.pcrs1  := false.B

  }.elsewhen(io.inst === instructions().ebreak) {
    io.format := TYPE.U
    io.op     := OP.END
    io.s1type := false.B
    io.s2type := false.B
    io.pclj   := false.B
    io.pcrs1  := false.B
  }.elsewhen(io.inst === instructions().jal) {
    io.format := TYPE.J
    io.op     := OP.JRET
    io.s1type := false.B
    io.s2type := false.B
    io.pclj   := true.B
    io.pcrs1  := false.B

  }.elsewhen(io.inst === instructions().jalr) {
    io.format := TYPE.I
    io.op     := OP.JRET
    io.s1type := false.B
    io.s2type := false.B
    io.pclj   := true.B
    io.pcrs1  := true.B

  }.elsewhen(io.inst === instructions().sw) {
    io.format := TYPE.I
    io.op     := OP.NOP
    io.s1type := false.B
    io.s2type := false.B
    io.pclj   := false.B
    io.pcrs1  := false.B

  }.elsewhen(io.inst === instructions().auipc) {
    io.format := TYPE.U
    io.op     := OP.ADD
    io.s1type := false.B
    io.s2type := false.B
    io.pclj   := false.B
    io.pcrs1  := false.B
  }.otherwise {
    io.format := TYPE.E
    io.op     := Mux(start === 1.U, OP.END, OP.NOP)
    printf("start: %d\n", start)
    start     := start + 1.U
    io.s1type := false.B
    io.s2type := false.B
    io.pclj   := false.B
    io.pcrs1  := false.B
    printf("Error: Unknown instruction!\n")
  }
  // printf("inst: 0x%x\n", io.inst)

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

  val nextpc         = Module(new NextPc)
  val pc             = Module(new PC)
  val source_decoder = Module(new SourceDecoder)
  val immgen         = Module(new ImmGen)
  val regfile        = Module(new RegFile)
  val r1mux          = Module(new R1mux)
  val r2mux          = Module(new R2mux)
  val alu            = Module(new Alu)

  val endnpc = Module(new EndNpc)
  val rdaddr = Reg(UInt(32.W))

  rdaddr := nextpc.io.nextpc

  nextpc.io.imm   := immgen.io.out
  nextpc.io.nowpc := pc.io.pc
  nextpc.io.rs1   := regfile.io.rs1out
  nextpc.io.pclj  := source_decoder.io.pclj
  nextpc.io.pcrs1 := source_decoder.io.pcrs1

  io.pc      := pc.io.pc
  pc.io.pcin := nextpc.io.nextpc

  source_decoder.io.inst := io.inst

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

  io.out := alu.io.out

}
