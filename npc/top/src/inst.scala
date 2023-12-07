package inst

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

class EndNpc extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val endflag = Input(Bool())
  })

  setInline(
    "EndNpc.v",
    s"""
       | import "DPI-C" function void stopnpc();
       |module EndNpc(
       |    input endflag
       |);
       | always @(*) 
       |    if (endflag) stopnpc();
       |
       |endmodule
       |""".stripMargin
  )

}

case class instructions() {
  val addi:   BitPat = BitPat("b???????_?????_?????_000_?????_0010011")
  val ebreak: BitPat = BitPat("b0000000_00001_?????_000_?????_1110011")
}
/*
class TypeDecoder extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val format = Output(UInt(3.W))
  })
  val format_table = TruthTable(
    Map(
      BitPat("b0010011".U) -> BitPat("b1".U(3.W)),
      BitPat("b1110011".U) -> BitPat("b1".U(3.W))
    ),
    BitPat("b0".U(3.W))
  )
  io.format := decoder(io.inst(6, 0), format_table)
}
 */

/*
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
    val r2type = Input(Bool())
    val rs2    = Input(UInt(32.W))
    val imm    = Input(UInt(32.W))
    val r2out  = Output(UInt(32.W))
  })

  io.r2out := Mux(io.r2type, io.rs2, io.imm)
}

class Dmux extends Module {
  val io = IO(new Bundle {
    val dtype    = Input(Bool())
    val regwrite = Output(Bool())
    val memwrite = Output(Bool())
  })

  io.memwrite := Mux(io.dtype, false.B, true.B)
  io.regwrite := Mux(io.dtype, true.B, false.B)
}
 */

class Alu extends Module {
  val io = IO(new Bundle {
    val s1  = Input(UInt(32.W))
    val s2  = Input(UInt(32.W))
    val op  = Input(UInt(5.W))
    val out = Output(UInt(32.W))

    val rw = Output(Bool()) //临时使用

    val end = Output(Bool())
  })

  io.end := false.B

  when(io.op === "b00000".U) {
    io.out := io.s1 + io.s2
    io.rw  := true.B
  }.elsewhen(io.op === "b00001".U) {
    io.out := 0.U
    io.rw  := false.B
    io.end := true.B
    printf("ebreak!\n")
  }.otherwise {
    io.out := 0.U
    io.rw  := false.B
    printf("Error: Unknown instruction!\n")
  }
}

class SourceDecoder extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))

    val format = Output(UInt(3.W))
    // val s1type = Output(Bool()) //true : reg, false : PC
    // val s2type = Output(Bool()) //ture : reg, false : imm
    // val dtype  = Output(Bool()) //ture : reg, false : PC
    val op = Output(UInt(5.W))
  })

  when(io.inst === instructions().addi) {
    io.format := "b001".U
    // io.s1type := true.B
    // io.s2type := true.B
    // io.dtype  := true.B
    io.op := "b00000".U
  }.elsewhen(io.inst === instructions().ebreak) {
    io.format := "b001".U
    io.op     := "b00001".U
  }.otherwise {
    io.format := "b000".U
    // io.s1type := DontCare
    // io.s2type := DontCare
    // io.dtype  := DontCare
    io.op := "b11111".U
    printf("Error: Unknown instruction!\n")
  }

}

class ImmGen extends Module {
  val io = IO(new Bundle {
    val format = Input(UInt(3.W))
    val inst   = Input(UInt(32.W))
    val out    = Output(UInt(32.W))
  })

  when(io.format === "b001".U) {
    io.out := Cat(Fill(20, 0.U(1.W)), io.inst(31, 20))
  }.otherwise {
    io.out := 2.U
  }
}

class RegFile extends Module {
  val io = IO(new Bundle {
    val rs1    = Input(UInt(5.W))
    val rs2    = Input(UInt(5.W))
    val rd     = Input(UInt(5.W))
    val wr     = Input(Bool())
    val datain = Input(UInt(32.W))

    val rs1out = Output(UInt(32.W))
    val rs2out = Output(UInt(32.W))
  })
  val regfile = RegInit(VecInit(Seq.fill(32)(0.U(32.W))))
  when(io.wr) {
    regfile(io.rd) := Mux(io.rd === 0.U, 0.U, io.datain)
  }

  io.rs1out := regfile(io.rs1)
  io.rs2out := regfile(io.rs2)
}

class Exu extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))
    val out  = Output(UInt(32.W))
    val pc   = Output(UInt(32.W))

  })

  val pc = RegInit(0.U(32.W))
  pc := pc + 4.U

  val source_decoder = Module(new SourceDecoder)
  val immgen         = Module(new ImmGen)
  val regfile        = Module(new RegFile)
  // val r1mux          = Module(new R1mux)
  // val r2mux          = Module(new R2mux)
  // val dmux           = Module(new Dmux)
  val alu = Module(new Alu)

  val endnpc = Module(new EndNpc)

  source_decoder.io.inst := io.inst

  regfile.io.rs1 := io.inst(19, 15)
  regfile.io.rs2 := io.inst(24, 20)
  regfile.io.rd  := io.inst(11, 7)
  // regfile.io.wr     := dmux.io.regwrite
  regfile.io.datain := alu.io.out
  regfile.io.wr     := alu.io.rw

  immgen.io.format := source_decoder.io.format
  immgen.io.inst   := io.inst

  //addi测试
  alu.io.s1 := regfile.io.rs1out
  alu.io.s2 := immgen.io.out

  endnpc.io.endflag := alu.io.end

  /*
  r1mux.io.r1type := source_decoder.io.s1type
  r1mux.io.pc     := pc
  r1mux.io.rs1    := regfile.io.rs1out

  r2mux.io.r2type := source_decoder.io.s2type
  r2mux.io.imm    := immgen.io.out
  r2mux.io.rs2    := regfile.io.rs2out

  dmux.io.dtype := source_decoder.io.dtype
   */

  alu.io.op := source_decoder.io.op
  // alu.io.s1 := r1mux.io.r1out
  // alu.io.s2 := r2mux.io.r2out

  io.out := alu.io.out
  io.pc  := pc

}
