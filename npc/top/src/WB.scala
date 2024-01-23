package WB

import chisel3._
import Memory._
import instsinfo._
import chisel3.util._
import npctools._

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

import datapath.{AxiLiteSignal, EXU2WBPath, WBCtrlPath}

class WB extends Module {
  val io = IO(new Bundle {
    val exu2wb     = Flipped(Decoupled(new EXU2WBPath))
    val wbctrlpath = Flipped(Decoupled(new WBCtrlPath))

    //csralumux
    val wbdataout = Output(UInt(32.W))

    val reg_wr = Output(Bool())
    val nextpc = Output(UInt(32.W))
  })

  val nextpc     = Module(new NextPc)
  val datamemaxi = Module(new DataMemAxi)
  val memregmux  = Module(new MemorRegMux)
  val csralumux  = Module(new CSRALUMUX)
  val csr        = Module(new CSR)

//AxiLiteSignal
  val axi2mem = Wire(new AxiLiteSignal)

//state
  val exuvalid = Wire(Bool())
  exuvalid := io.exu2wb.valid & io.wbctrlpath.valid

  val wbisready = Wire(Bool())
  wbisready := Mux(
    exuvalid,
    Mux(
      io.wbctrlpath.bits.datamem_rd,
      Mux(datamemaxi.axi.rready & datamemaxi.axi.rvalid, true.B, false.B), //在mem返回有效 才可以wb写回
      true.B
    ),
    false.B
  )
  io.exu2wb.ready     := wbisready
  io.wbctrlpath.ready := wbisready

  // //随机延迟部分
  // val delay_rready = Module(new DelayTrueRandomCycle)

  //axi状态转移
  //AR通道
  axi2mem.arvalid := Mux(
    exuvalid,
    Mux(
      io.wbctrlpath.bits.datamem_rd,
      Mux(axi2mem.arready, io.wbctrlpath.bits.datamem_rd, true.B), //在mem返回有效 才可以wb写回
      false.B
    ),
    false.B
  )
  axi2mem.araddr := io.exu2wb.bits.datamemaddr

  //R通道
  axi2mem.rready := axi2mem.arvalid //处于等待状态就可以接受数据
  // datamem.io.rvalid := Mux(exuvalid, io.wbctrlpath.bits.datamem_rd, false.B)

  //AW通道
  axi2mem.awvalid := true.B
  axi2mem.wvalid  := Mux(exuvalid, io.wbctrlpath.bits.datamem_wr, false.B)
  axi2mem.awaddr  := io.exu2wb.bits.datamemaddr

  //W通道
  axi2mem.wdata := io.exu2wb.bits.rs2
  axi2mem.wstrb := io.wbctrlpath.bits.datamem_wmask

  //B通道
  axi2mem.bready := DontCare

//总线连接
  nextpc.io.pc    := io.exu2wb.bits.pc
  nextpc.io.pclj  := io.exu2wb.bits.pclj
  nextpc.io.pcrs1 := io.exu2wb.bits.pcrs1
  nextpc.io.imm   := io.exu2wb.bits.imm
  nextpc.io.rs1   := io.exu2wb.bits.rs1
  // datamem.io.waddr     := io.exu2wb.bits.datamemaddr
  // datamem.io.raddr     := io.exu2wb.bits.datamemaddr
  // datamem.io.wdata     := io.exu2wb.bits.rs2
  csr.io.pc            := io.exu2wb.bits.pc
  csr.io.rs1data       := io.exu2wb.bits.rs1
  csr.io.idx           := io.exu2wb.bits.inst(31, 20)
  memregmux.io.aludata := io.exu2wb.bits.datamemaddr

  nextpc.io.csrjump := io.wbctrlpath.bits.csrisjump
  // datamem.io.wvalid      := Mux(wbisready, io.wbctrlpath.bits.datamem_wr, false.B)
  // datamem.io.rvalid      := Mux(exuvalid, io.wbctrlpath.bits.datamem_rd, false.B)
  // datamem.io.wstrb       := io.wbctrlpath.bits.datamem_wmask
  csr.io.wr              := io.wbctrlpath.bits.csr_wr
  csr.io.re              := io.wbctrlpath.bits.csr_rd
  csr.io.wpc             := io.wbctrlpath.bits.csr_wpc
  csr.io.ecall           := io.wbctrlpath.bits.csr_ecall
  csr.io.mret            := io.wbctrlpath.bits.csr_mret
  memregmux.io.memen     := io.wbctrlpath.bits.memorreg_memen
  csralumux.io.choosecsr := io.wbctrlpath.bits.csroralu_isscr

  //内部连线
  // memregmux.io.memdata := datamem.io.rdata
  memregmux.io.memdata := axi2mem.rdata
  io.wbdataout         := csralumux.io.out
  csralumux.io.aludata := memregmux.io.out
  csralumux.io.csrdata := csr.io.dataout
  nextpc.io.csrdata    := csr.io.pcdataout

  //外部连线
  io.nextpc := nextpc.io.nextpc
  io.reg_wr := Mux(wbisready, io.wbctrlpath.bits.reg_wr, false.B)

  //axi连线
  datamemaxi.axi.araddr  := axi2mem.araddr
  datamemaxi.axi.arvalid := axi2mem.arvalid
  axi2mem.arready        := datamemaxi.axi.arready

  axi2mem.rdata         := datamemaxi.axi.rdata
  axi2mem.rresp         := datamemaxi.axi.rresp
  axi2mem.rvalid        := datamemaxi.axi.rvalid
  datamemaxi.axi.rready := axi2mem.rready

  datamemaxi.axi.awvalid := axi2mem.awvalid
  datamemaxi.axi.awaddr  := axi2mem.awaddr
  axi2mem.awready        := datamemaxi.axi.awready

  datamemaxi.axi.wdata  := axi2mem.wdata
  datamemaxi.axi.wstrb  := axi2mem.wstrb
  datamemaxi.axi.wvalid := axi2mem.wvalid
  axi2mem.wready        := datamemaxi.axi.wready

  // axi2mem.arready := datamemaxi.axi.arready

  axi2mem.bresp         := datamemaxi.axi.bresp
  axi2mem.bvalid        := datamemaxi.axi.bvalid
  datamemaxi.axi.bready := axi2mem.bready

}
