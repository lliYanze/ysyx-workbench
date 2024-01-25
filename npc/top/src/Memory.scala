package Memory

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._
import chisel3.experimental._
import datapath.AxiLiteSignal
import npctools._

class MemRead extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val addr       = Input(UInt(32.W))
    val data       = Input(UInt(32.W))
    val writevalid = Input(Bool())
    val readvalid  = Input(Bool())
    val wmask      = Input(UInt(3.W))
    val clock      = Input(Clock())
    val dataout    = Output(UInt(32.W))
  })

  setInline(
    "MemRead.v",
    s"""
       | import "DPI-C" function void data_write(input int addr, input int data, input bit[2:0] wmask);
       | import "DPI-C" function int data_read(input int addr, input bit[2:0] wmask, input bit valid);
       |module MemRead(
       |    input wire [31:0] addr,
       |    input wire [31:0] data,
       |    input wire [2:0] wmask,
       |    input wire writevalid,
       |    input wire readvalid,
       |    input wire clock,
       |    output wire [31:0] dataout
       |);
       | assign dataout = (readvalid & ~writevalid) ?  data_read(addr, wmask, readvalid & ~writevalid): 0;
       | always @(posedge clock) begin
       |    if (writevalid) data_write(addr, data, wmask);
       | end
       |
       |endmodule
       |""".stripMargin
  )
}

class DataMemAxi extends Module {
  val s_waitaddr :: s_wait_rvalid :: s_wait_rready :: Nil = Enum(3)

  val axi      = IO(new AxiLiteSignal)
  val datamem  = Module(new DataMem)
  val axistate = RegInit(s_waitaddr)

  val raddr = RegEnable(axi.araddr, axi.arvalid & axi.arready)
  val rdata = RegEnable(datamem.io.rdata, datamem.io.rvalid)

  //AR通道
  axi.arready := Mux(axistate === s_waitaddr, true.B, false.B) //立刻可以接受地址

  //R通道
  axi.rvalid := Mux(
    axistate === s_wait_rvalid, //保证需要先判断 arvalid和arready
    (datamem.io.rvalid),
    Mux(axistate === s_wait_rready, true.B, false.B) //保持置一直到 cpu 读取完毕
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
      s_wait_rvalid -> Mux(datamem.io.rvalid, Mux(axi.rready, s_waitaddr, s_wait_rready), s_wait_rvalid),
      s_wait_rready -> Mux(axi.rready, s_waitaddr, s_wait_rready)
    )
  )

  //与SRAM的连接
  //AR通道
  datamem.io.raddr     := Mux(axi.arvalid & axi.arready, axi.araddr, raddr)
  datamem.io.waddr     := axi.awaddr
  datamem.io.wdata     := axi.wdata
  datamem.io.wvalid    := axi.wvalid
  datamem.io.wstrb     := axi.wstrb
  datamem.io.readvalid := axi.arvalid & axi.arready
  axi.rdata            := datamem.io.rdata
  // axi.rvalid           := datamem.io.rvalid
}

class DataMem extends Module {
  val io = IO(new Bundle {
    val raddr  = Input(UInt(32.W))
    val waddr  = Input(UInt(32.W))
    val wdata  = Input(UInt(32.W))
    val wvalid = Input(Bool())
    val wstrb  = Input(UInt(3.W))
    val rdata  = Output(UInt(32.W))

    //握手信号
    val readvalid = Input(Bool()) //读请求有效
    val rvalid    = Output(Bool()) //有有效数据

  })
  val datamemread = Module(new MemRead)

//FIXME: 为了方便默认数据直接就可以读出来,等待valid有效直接读取
  val memdata = RegEnable(datamemread.io.dataout, io.readvalid)
  io.rdata := memdata

  //随机延迟
  val delayrvalid = Module(new DelayTrueRandomCycle)
  delayrvalid.io.en := io.readvalid
  io.rvalid         := delayrvalid.io.out

  val addr = Reg(io.raddr.cloneType)
  addr                      := Mux(io.readvalid, io.raddr, Mux(io.wvalid, io.waddr, addr))
  datamemread.io.addr       := Mux(io.readvalid, io.raddr, Mux(io.wvalid, io.waddr, addr))
  datamemread.io.data       := io.wdata
  datamemread.io.writevalid := io.wvalid
  datamemread.io.readvalid  := io.readvalid
  datamemread.io.wmask      := io.wstrb
  datamemread.io.clock      := clock
}

class InstMemAxi extends Module {
  val s_waitaddr :: s_wait_rvalid :: s_wait_rready :: Nil = Enum(3)

  val axi      = IO(new AxiLiteSignal)
  val instmem  = Module(new InstMem)
  val axistate = RegInit(s_waitaddr)

  val raddr = RegEnable(axi.araddr, axi.arvalid & axi.arready)
  val rdata = RegEnable(instmem.io.rdata, instmem.io.rvalid)

  instmem.io.raddr     := Mux(axi.arvalid & axi.arready, axi.araddr, raddr)
  instmem.io.readvalid := axi.arvalid & axi.arready
  axi.rdata            := instmem.io.rdata

  //AR通道
  axi.arready := Mux(axistate === s_waitaddr, true.B, false.B) //立刻可以接受地址

  //R通道
  axi.rvalid := Mux(
    axistate === s_wait_rvalid, //保证需要先判断 arvalid和arready
    instmem.io.rvalid,
    Mux(axistate === s_wait_rready, true.B, false.B) //保持置一直到 cpu 读取完毕
  )
  axi.rresp := 0.U

  //AW通道
  axi.awready := false.B
  assert(!axi.awvalid, "InstMemAxi: awvalid must be false")

  //W通道
  axi.wready := false.B
  assert(!axi.wvalid, "InstMemAxi: wvalid must be false")

  //B通道
  axi.bresp  := DontCare
  axi.bvalid := DontCare

  axistate := MuxLookup(
    axistate,
    s_waitaddr,
    List(
      s_waitaddr -> Mux(axi.arvalid & axi.arready, s_wait_rvalid, s_waitaddr),
      s_wait_rvalid -> Mux(instmem.io.rvalid, Mux(axi.rready, s_waitaddr, s_wait_rready), s_wait_rvalid),
      s_wait_rready -> Mux(axi.rready, s_waitaddr, s_wait_rready)
    )
  )

  //与SRAM的连接
  instmem.io.wvalid := axi.wvalid
  instmem.io.wstrb  := axi.wstrb
  instmem.io.waddr  := axi.awaddr
  instmem.io.wdata  := axi.wdata

}
class InstMemIO extends Bundle {
  val pc = Input(UInt(32.W))
  val en = Input(Bool())

  val inst       = Output(UInt(32.W))
  val inst_valid = Output(Bool())
}

class InstMem extends Module {
  val io = IO(new Bundle {
    val raddr  = Input(UInt(32.W))
    val waddr  = Input(UInt(32.W))
    val wdata  = Input(UInt(32.W))
    val wvalid = Input(Bool())
    val wstrb  = Input(UInt(3.W))
    val rdata  = Output(UInt(32.W))

    //握手信号
    val readvalid = Input(Bool()) //读请求有效
    val rvalid    = Output(Bool()) //有有效数据
  })
  //SRAM部分
  val instmemread = Module(new MemRead)
  val memdata     = RegEnable(instmemread.io.dataout, io.readvalid)
  io.rdata := memdata

  val delaytrue = Module(new DelayTrueRandomCycle)

  //连接部分
  delaytrue.io.en := io.readvalid
  io.rvalid       := delaytrue.io.out

  instmemread.io.addr       := io.raddr
  instmemread.io.clock      := clock
  instmemread.io.writevalid := io.wvalid
  instmemread.io.wmask      := io.wstrb
  instmemread.io.readvalid  := io.readvalid
}
