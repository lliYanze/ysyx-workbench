package singlecpu

import InstDecode._
import Memory._
import Trace._
import Alu._

import instsinfo._

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

class MemorRegMux extends Module {
  val io = IO(new Bundle {
    val memdata = Input(UInt(32.W))
    val regdata = Input(UInt(32.W))
    val memen   = Input(Bool())

    val out = Output(UInt(32.W))
  })
  io.out := Mux(io.memen, io.memdata, io.regdata)
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

// class PC extends Module {
//   val io = IO(new Bundle {
//     val csrjump = Input(Bool())
//     val csrdata = Input(UInt(32.W))
//     val pclj    = Input(Bool()) //true imm ,false +4
//     val pcrs1   = Input(Bool()) //true rs1 ,false PC
//     val imm     = Input(UInt(32.W))
//     val rs1     = Input(UInt(32.W))
//
//     val nextpc = Output(UInt(32.W))
//
//     val pc = Output(UInt(32.W))
//   })
//   val pc     = RegInit("h8000_0000".U(32.W))
//   val nextpc = Wire(UInt(32.W))
//   when(io.csrjump) {
//     nextpc := io.csrdata
//   }.otherwise {
//     nextpc := Mux(io.pclj, io.imm, 4.U) + Mux(io.pcrs1, io.rs1, pc)
//   }
//   pc        := nextpc
//   io.pc     := pc
//   io.nextpc := nextpc
// }

// class ImmGen extends Module {
//   val io = IO(new Bundle {
//     val format = Input(UInt(3.W))
//     val inst   = Input(UInt(32.W))
//     val out    = Output(UInt(32.W))
//   })
//
//   when(io.format === TYPE.I) {
//     io.out := Cat(Fill(20, io.inst(31)), io.inst(31, 20))
//   }.elsewhen(io.format === TYPE.U) { //U型指令是imm为高20位
//     io.out := Cat(io.inst(31, 12), Fill(12, 0.U(1.W)))
//   }.elsewhen(io.format === TYPE.J) {
//     io.out := Cat(Fill(12, io.inst(31)), io.inst(31), io.inst(19, 12), io.inst(20), io.inst(30, 21), 0.U(1.W))
//   }.elsewhen(io.format === TYPE.S) {
//     io.out := Cat(Fill(20, io.inst(31)), io.inst(31, 25), io.inst(11, 7))
//   }.elsewhen(io.format === TYPE.B) {
//     //imm = {inst[31], inst[7], inst[30:25], inst[11:8], 0'b0}
//     //          12     11            10-5          4-1     0
//     io.out := Cat(Fill(19, io.inst(31)), io.inst(31), io.inst(7), io.inst(30, 25), io.inst(11, 8), 0.U)
//   }.otherwise {
//     io.out := 0.U
//   }
// }

// class RegFile extends Module {
//   val io = IO(new Bundle {
//     val rs1    = Input(UInt(5.W))
//     val rs2    = Input(UInt(5.W))
//     val rd     = Input(UInt(5.W))
//     val wr     = Input(Bool())
//     val datain = Input(UInt(32.W))
//
//     val rs1out    = Output(UInt(32.W))
//     val rs2out    = Output(UInt(32.W))
//     val end_state = Output(UInt(32.W))
//
//   })
//
//   val regfile = RegInit(VecInit(Seq.fill(32)(0.U(32.W))))
//   io.end_state := regfile(10.U)
//   val datain = Wire(UInt(32.W))
//   datain := io.datain
//   when(io.wr) {
//     regfile(io.rd) := Mux(io.rd === 0.U, 0.U, datain)
//   }
//
//   io.rs1out := regfile(io.rs1)
//   io.rs2out := regfile(io.rs2)
//
// }

class CSRALUMUX extends Module {
  val io = IO(new Bundle {
    val aludata   = Input(UInt(32.W))
    val csrdata   = Input(UInt(32.W))
    val choosecsr = Input(Bool())
    val out       = Output(UInt(32.W))
  })
  io.out := Mux(io.choosecsr, io.csrdata, io.aludata)
}

class CSR extends Module {
  val io = IO(new Bundle {
    val idx       = Input(UInt(12.W))
    val wr        = Input(Bool())
    val wpc       = Input(Bool())
    val re        = Input(Bool())
    val pc        = Input(UInt(32.W))
    val rs1data   = Input(UInt(32.W))
    val ecall     = Input(Bool())
    val mret      = Input(Bool())
    val dataout   = Output(UInt(32.W))
    val pcdataout = Output(UInt(32.W))

  })
  val csrfile = RegInit(VecInit(Seq.fill(4)(0.U(32.W))))
  when(io.wr || io.wpc) {
    when(io.idx === 0x300.U) {
      csrfile(0) := io.rs1data
    }.elsewhen(io.idx === 0x341.U) {
      csrfile(1) := Mux(io.wpc, io.pc, io.rs1data)
    }.elsewhen(io.idx === 0x342.U) {
      csrfile(2) := io.rs1data
    }.elsewhen(io.idx === 0x305.U) {
      csrfile(3) := io.rs1data
    }.elsewhen(io.ecall) {
      csrfile(1) := io.pc
      csrfile(2) := "hb".U
    }
  }
  when(io.re) {
    when(io.idx === 0x300.U) {
      io.dataout := csrfile(0)

    }.elsewhen(io.idx === 0x341.U) {
      io.dataout := csrfile(1)
    }.elsewhen(io.idx === 0x342.U) {
      io.dataout := csrfile(2) //由于ecall无法读a5，所以用hb代替

    }.elsewhen(io.idx === 0x305.U) {
      io.dataout := csrfile(3)
    }.otherwise {
      io.dataout := 0.U
    }
  }.otherwise {
    io.dataout := 0.U
  }
  io.pcdataout := Mux(io.ecall, csrfile(3), csrfile(1))

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

import IFU.IFU
import IDU.IDU
import WB.NextPc

class Core extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val nextpc = Output(UInt(32.W))
    val pc     = Output(UInt(32.W))
  })

  val ifu            = Module(new IFU)
  val idu            = Module(new IDU)
  val nextpc         = Module(new NextPc)
  val source_decoder = Module(new InstDecode)
  // val immgen         = Module(new ImmGen)
  // val regfile        = Module(new RegFile)
  val r1mux = Module(new R1mux)
  val r2mux = Module(new R2mux)
  val alu   = Module(new Alu)

  val endnpc = Module(new EndNpc)

  val insttrace = Module(new InstTrace)
  val ftrace    = Module(new Ftrace)
  val jumpctl   = Module(new JumpCtl)

  val memorregmux = Module(new MemorRegMux)
  val datamem     = Module(new DataMem)

  val csrctl    = Module(new CSRCTL)
  val csr       = Module(new CSR)
  val csralumux = Module(new CSRALUMUX)

  ifu.io.ifu2idu <> idu.io.ifu2idu

  csr.io.idx     := ifu.io.instout(31, 20)
  csr.io.wr      := csrctl.io.wreg
  csr.io.re      := csrctl.io.read
  csr.io.wpc     := csrctl.io.wpc
  csr.io.pc      := ifu.io.pc
  csr.io.rs1data := idu.io.rs1out
  csr.io.ecall   := csrctl.io.ecall
  csr.io.mret    := csrctl.io.mret

  csrctl.io.ctl := source_decoder.io.csrctl
  csrctl.io.rd  := ifu.io.instout(11, 7)
  csrctl.io.rs1 := ifu.io.instout(19, 15)

  csralumux.io.aludata   := memorregmux.io.out
  csralumux.io.csrdata   := csr.io.dataout
  csralumux.io.choosecsr := csrctl.io.choosecsr

  memorregmux.io.memdata := datamem.io.dataout
  memorregmux.io.regdata := alu.io.out
  memorregmux.io.memen   := source_decoder.io.tomemorreg

  datamem.io.addr  := alu.io.out
  datamem.io.data  := idu.io.rs2out
  datamem.io.wr    := source_decoder.io.memwr
  datamem.io.wmask := source_decoder.io.memctl
  datamem.io.clock := clock
  datamem.io.valid := source_decoder.io.memrd

  nextpc.io.imm     := idu.io.immout
  nextpc.io.rs1     := idu.io.rs1out
  nextpc.io.pclj    := jumpctl.io.pclj
  nextpc.io.pcrs1   := jumpctl.io.pcrs1
  nextpc.io.csrjump := csrctl.io.jump
  nextpc.io.csrdata := csr.io.pcdataout
  nextpc.io.pc      := ifu.io.pc
  ifu.io.instin     := io.inst
  ifu.io.pcin       := nextpc.io.nextpc
  io.pc             := ifu.io.pc

  source_decoder.io.inst := ifu.io.instout

  jumpctl.io.ctl  := source_decoder.io.jumpctl
  jumpctl.io.eq   := alu.io.eq
  jumpctl.io.less := alu.io.less

  // regfile.io.rs1 := ifu.io.instout(19, 15)
  // regfile.io.rs2 := ifu.io.instout(24, 20)
  // regfile.io.rd  := ifu.io.instout(11, 7)

  // regfile.io.datain := csralumux.io.out
  // regfile.io.wr     := source_decoder.io.regwr

  idu.io.regdatain := csralumux.io.out
  idu.io.wr        := source_decoder.io.regwr

  // immgen.io.format := source_decoder.io.format
  // immgen.io.inst   := ifu.io.instout

  endnpc.io.endflag := alu.io.end
  // endnpc.io.state   := regfile.io.end_state
  endnpc.io.state := idu.io.end_state

  r1mux.io.r1type := source_decoder.io.s1type
  r1mux.io.pc     := ifu.io.pc
  // r1mux.io.rs1    := regfile.io.rs1out
  r1mux.io.rs1 := idu.io.rs1out

  r2mux.io.r2type := source_decoder.io.s2type
  // r2mux.io.imm    := immgen.io.out
  // r2mux.io.rs2    := regfile.io.rs2out
  r2mux.io.imm := idu.io.immout
  r2mux.io.rs2 := idu.io.rs2out

  alu.io.op := source_decoder.io.op
  alu.io.s1 := r1mux.io.r1out
  alu.io.s2 := r2mux.io.r2out

  insttrace.io.inst  := source_decoder.io.inst
  insttrace.io.pc    := ifu.io.pc
  insttrace.io.clock := clock

  ftrace.io.inst   := source_decoder.io.inst
  ftrace.io.pc     := ifu.io.pc
  ftrace.io.nextpc := nextpc.io.nextpc
  ftrace.io.clock  := clock
  ftrace.io.jump   := source_decoder.io.ftrace

  io.nextpc := nextpc.io.nextpc
}
