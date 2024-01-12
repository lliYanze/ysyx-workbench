package WB

import chisel3._
import Memory._
import instsinfo._
import chisel3.util.Decoupled

class NextPc extends Module {
  val io = IO(new Bundle {
    val pc      = Input(UInt(32.W))
    val csrjump = Input(Bool())
    val csrdata = Input(UInt(32.W))
    val pclj    = Input(Bool()) //true imm ,false +4
    val pcrs1   = Input(Bool()) //true rs1 ,false PC
    val imm     = Input(UInt(32.W))
    val rs1     = Input(UInt(32.W))
    val nextpc  = Output(UInt(32.W))
  })
  when(io.csrjump) {
    io.nextpc := io.csrdata
  }.otherwise {
    io.nextpc := Mux(io.pclj, io.imm, 4.U) + Mux(io.pcrs1, io.rs1, io.pc)
  }

}
class MemorRegMux extends Module {
  val io = IO(new Bundle {
    val memdata = Input(UInt(32.W))
    val aludata = Input(UInt(32.W))
    val memen   = Input(Bool())

    val out = Output(UInt(32.W))
  })
  io.out := Mux(io.memen, io.memdata, io.aludata)
}

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

import datapath.EXU2WBPath

class WB extends Module {
  val io = IO(new Bundle {
    val exu2wb = Flipped(Decoupled(new EXU2WBPath))

    val csrjump = Input(Bool())
    val imm     = Input(UInt(32.W))
    val rs1     = Input(UInt(32.W))
    val nextpc  = Output(UInt(32.W))

    val data    = Input(UInt(32.W))
    val wr      = Input(Bool())
    val valid   = Input(Bool())
    val wmask   = Input(UInt(3.W))
    val dataout = Output(UInt(32.W))

    //CSR
    val csrwr   = Input(Bool())
    val wpc     = Input(Bool())
    val re      = Input(Bool())
    val rs1data = Input(UInt(32.W))
    val ecall   = Input(Bool())
    val mret    = Input(Bool())

    //MemorRegMux
    val memen          = Input(Bool())
    val memorregmuxout = Output(UInt(32.W))

    //csralumux
    val choosecsr = Input(Bool())

    val wbdataout = Output(UInt(32.W))
  })

  val nextpc    = Module(new NextPc)
  val datamem   = Module(new DataMem)
  val memregmux = Module(new MemorRegMux)
  val csralumux = Module(new CSRALUMUX)
  val csr       = Module(new CSR)

//总线连接

  nextpc.io.pc         := io.exu2wb.bits.pc
  nextpc.io.pclj       := io.exu2wb.bits.pclj
  nextpc.io.pcrs1      := io.exu2wb.bits.pcrs1
  datamem.io.addr      := io.exu2wb.bits.datamemaddr
  csr.io.pc            := io.exu2wb.bits.pc
  csr.io.idx           := io.exu2wb.bits.inst(31, 20)
  memregmux.io.aludata := io.exu2wb.bits.datamemaddr

  //内部连线
  memregmux.io.memdata := datamem.io.dataout
  io.wbdataout         := csralumux.io.out
  csralumux.io.aludata := memregmux.io.out
  csralumux.io.csrdata := csr.io.dataout
  nextpc.io.csrdata    := csr.io.pcdataout

  //外部连线
  nextpc.io.csrjump := io.csrjump
  nextpc.io.imm     := io.imm
  nextpc.io.rs1     := io.rs1

  datamem.io.data  := io.data
  datamem.io.wr    := io.wr
  datamem.io.valid := io.valid
  datamem.io.wmask := io.wmask
  datamem.io.clock := clock

  csr.io.wr      := io.csrwr
  csr.io.re      := io.re
  csr.io.wpc     := io.wpc
  csr.io.rs1data := io.rs1data
  csr.io.ecall   := io.ecall
  csr.io.mret    := io.mret

  memregmux.io.memen := io.memen

  csralumux.io.choosecsr := io.choosecsr

  io.nextpc         := nextpc.io.nextpc
  io.dataout        := datamem.io.dataout
  io.memorregmuxout := memregmux.io.out

  //临时使用
  io.exu2wb.ready := true.B
}
