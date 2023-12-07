import chisel3._
import chisel3.util._

import chisel3.util.BitPat
import chisel3.util.experimental.decode._

case class instructions() {
  val addi: BitPat = BitPat("b???????_?????_?????_000_?????_0010011")
}

class FormatDecoder extends Module {
  val format_table = TruthTable(
    Map(
      BitPat("b0010011".U) -> BitPat("b1".U(3.W))
    ),
    BitPat("b0".U(3.W))
  )
  val input  = IO(Input(UInt(7.W)))
  val output = IO(Output(UInt(3.W)))

  output := decoder(input, format_table)
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

class Source_Decoder extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val format = Input(UInt(3.W))
    val rs1    = Output(UInt(5.W))
    val rs2    = Output(UInt(5.W))
    val rd     = Output(UInt(5.W))
  })

  when(io.format === "b001".U) {
    io.rs1 := io.inst(19, 15)
    io.rs2 := DontCare
    io.rd  := io.inst(11, 7)
  }.otherwise {
    io.rs1 := DontCare
    io.rs2 := DontCare
    io.rd  := DontCare
  }
}

//TODO:完成regfile模块
class RegFile extends Module {
  val io = IO(new Bundle {
    val rs1    = Input(UInt(5.W))
    val rs2    = Input(UInt(5.W))
    val rd     = Input(UInt(5.W))
    val wr     = Input(Bool())
    val datain = Input(UInt(32.W))
    val rs1out = Output(UInt(32.W))
    val rs2out = Output(UInt(32.W))
    val rdout  = Output(UInt(32.W))
  })
  val regfile = RegInit(VecInit(Seq.fill(32)(0.U(32.W))))
  when(io.wr) {
    regfile(io.rd) := Mux(io.rd === 0.U, 0.U, io.datain)
  }
  when(io.rs1 === 0.U) {
    io.rs1out := 0.U
  }.otherwise {
    io.rs1out := regfile(io.rs1)
  }
  when(io.rs2 === 0.U) {
    io.rs2out := 0.U
  }.otherwise {
    io.rs2out := regfile(io.rs2)
  }
  when(io.rd === 0.U) {
    io.rdout := 0.U
  }.otherwise {
    io.rdout := regfile(io.rd)
  }
}

//TODO:  完成Exu模块
class Exu extends Module {
  val io = IO(new Bundle {
    val inst    = Input(UInt(32.W))
    val regw    = Output(Bool())
    val regdata = Output(UInt(32.W))

  })
  val formatdecoder = Module(new FormatDecoder)
  val immgen        = Module(new ImmGen)
  val sourcedecoder = Module(new Source_Decoder)
  val regfile       = Module(new RegFile)
  formatdecoder.input     := io.inst(6, 0)
  sourcedecoder.io.inst   := io.inst
  sourcedecoder.io.format := formatdecoder.output
  immgen.io.format        := formatdecoder.output
  immgen.io.inst          := io.inst
  regfile.io.rs1          := sourcedecoder.io.rs1
  regfile.io.rs2          := sourcedecoder.io.rs2
  regfile.io.rd           := sourcedecoder.io.rd
  regfile.io.wr           := io.regw
  regfile.io.datain       := io.regdata

  when(io.inst === instructions().addi) {
    io.regw    := true.B
    io.regdata := regfile.io.rs1out + immgen.io.out

  }.otherwise {
    io.regw           := false.B
    regfile.io.datain := 0.U
    io.regdata        := 0.U

  }
}

class TOP extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))
    val out  = Output(UInt(32.W))

  })
  val exu = Module(new Exu)
  exu.io.inst := io.inst
  io.out      := exu.io.regdata
}
