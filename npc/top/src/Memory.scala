package Memory

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

class DataMemRead extends BlackBox with HasBlackBoxInline {
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
    "DataMemRead.v",
    s"""
       | import "DPI-C" function void data_write(input int addr, input int data, input bit[2:0] wmask);
       | import "DPI-C" function int data_read(input int addr, input bit[2:0] wmask, input bit valid);
       |module DataMemRead(
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
}
import datapath.AxiLiteSignal

// class DataMemAxi extends Module {
//   val axi = IO(new AxiLiteSignal)
//
//   val rdata = Reg(axi.rdata.cloneType)
//   rdata := datamemread.io.dataout
//   val datamemread = Module(new DataMemRead)
//   datamemread.io.addr  := axi.araddr
//   datamemread.io.data  := axi.wdata
//   datamemread.io.wr    := axi.wvalid
//   datamemread.io.valid := axi.rvalid
//   datamemread.io.wmask := axi.wstrb
//   datamemread.io.clock := clock
//   axi.rdata            := rdata
//
//
//
//
// }

class DataMem extends Module {
  val io = IO(new Bundle {
    val addr   = Input(UInt(32.W))
    val wdata  = Input(UInt(32.W))
    val wvalid = Input(Bool())
    // val wready = Output(Bool())
    val wstrb = Input(UInt(3.W))
    val rdata = Output(UInt(32.W))

    //握手信号
    val rvalid = Input(Bool()) //读请求有效
    // val rready = Output(Bool()) //存储器可以接受读请求

    // val arvalid = Input(Bool()) //CPU已经读出有效suju
    val arready = Output(Bool()) //通知CPU可以读取数据

    // val bresp  = Output(UInt(2.W)) //异常信号
    // val bready = Input(Bool())
    // val bvalid = Output(Bool())
    //
  })
  val datamemread = Module(new DataMemRead)
  val ready       = Reg(io.rvalid.cloneType)
  val memdata     = Reg(datamemread.io.dataout.cloneType)
  datamemread.io.addr  := io.addr
  datamemread.io.data  := io.wdata
  datamemread.io.wr    := io.wvalid
  datamemread.io.valid := io.rvalid
  datamemread.io.wmask := io.wstrb
  datamemread.io.clock := clock
  memdata              := datamemread.io.dataout
  ready                := io.rvalid
  io.rdata             := memdata
  io.arready           := ready
}

class InstMemRead extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val pc    = Input(UInt(32.W))
    val clock = Input(Clock())
    val inst  = Output(UInt(32.W))
  })
  setInline(
    "InstMemRead.v",
    s"""
       |module InstMemRead(
       |    input wire [31:0] pc,
       |    input wire clock,
       |    output wire [31:0] inst
       |);
       | assign inst = data_read(pc, 3'b010, 1'b1);
       |endmodule
       |""".stripMargin
  )
}

class InstMemIO extends Bundle {
  val pc = Input(UInt(32.W))
  val en = Input(Bool())

  val inst       = Output(UInt(32.W))
  val inst_valid = Output(Bool())
}

class InstMemAxi extends Module {
  val s_waitaddr :: s_wait_rvalid :: s_wait_rready :: Nil = Enum(3)

  val axi      = IO(new AxiLiteSignal)
  val instmem  = Module(new InstMem)
  val axistate = RegInit(s_waitaddr)

  val raddr = RegEnable(axi.araddr, axi.arvalid & axi.arready)
  val rdata = RegEnable(instmem.io.inst, instmem.io.inst_valid)

  instmem.io.pc := Mux(axi.arvalid & axi.arready, axi.araddr, raddr)
  instmem.io.en := axi.arvalid & axi.arready
  axi.rdata     := instmem.io.inst

  //AR通道
  axi.arready := Mux(axistate === s_waitaddr, true.B, false.B) //立刻可以接受地址

  //R通道
  axi.rvalid := Mux(
    axistate === s_wait_rvalid, //保证需要先判断 arvalid和arready
    false.B,
    Mux(axistate === s_wait_rready, instmem.io.inst_valid, true.B) //保持置一直到 cpu 读取完毕
  )
  axi.rresp := 0.U

  //AW通道
  axi.awready := false.B

  //W通道
  axi.wready := false.B

  //B通道
  axi.bresp  := DontCare
  axi.bvalid := DontCare

  axistate := MuxLookup(
    axistate,
    s_waitaddr,
    List(
      s_waitaddr -> Mux(axi.arvalid & axi.arready, s_wait_rvalid, s_waitaddr),
      s_wait_rvalid -> Mux(instmem.io.inst_valid, Mux(axi.rready, s_waitaddr, s_wait_rready), s_wait_rvalid),
      s_wait_rready -> Mux(axi.rready, s_waitaddr, s_wait_rready)
    )
  )

}

class InstMem extends Module {
  val io          = IO(new InstMemIO)
  val instmemread = Module(new InstMemRead)
  val instget     = RegNext(instmemread.io.inst)

  val instvalid = RegInit(true.B)
  io.inst_valid := instvalid
  instvalid     := io.en

  instmemread.io.pc    := io.pc
  instmemread.io.clock := clock

  io.inst := instget

}
