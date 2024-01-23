package Memory

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._
import chisel3.experimental._
import chisel3.util.random.LFSR

class DataMemRead extends BlackBox with HasBlackBoxInline {
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
    "DataMemRead.v",
    s"""
       | import "DPI-C" function void data_write(input int addr, input int data, input bit[2:0] wmask);
       | import "DPI-C" function int data_read(input int addr, input bit[2:0] wmask, input bit valid);
       |module DataMemRead(
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
import datapath.AxiLiteSignal

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
    false.B,
    Mux(axistate === s_wait_rready, datamem.io.rvalid, true.B) //保持置一直到 cpu 读取完毕
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
  axi.rvalid           := datamem.io.rvalid
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
  val datamemread = Module(new DataMemRead)

  //随机延迟
  val RANDOM: UInt = LFSR(4, io.readvalid) % 8.U + 1.U
  val delay    = RegInit(0.U(4.W))
  val olddelay = RegInit(0.U(4.W))
  val memdata  = RegEnable(datamemread.io.dataout, io.readvalid)
  olddelay  := delay
  delay     := Mux(delay === 0.U, Mux(io.readvalid, RANDOM, 0.U), delay - 1.U)
  io.rvalid := Mux(olddelay === 1.U & delay === 0.U, true.B, false.B)
  io.rdata  := memdata

  // val rvalid = ShiftRegister(io.readvalid, 5)
  // val memdata = ShiftRegister(datamemread.io.dataout, 5)
  val addr = Reg(io.raddr.cloneType)
  addr                      := Mux(io.readvalid, io.raddr, Mux(io.wvalid, io.waddr, addr))
  datamemread.io.addr       := Mux(io.readvalid, io.raddr, Mux(io.wvalid, io.waddr, addr))
  datamemread.io.data       := io.wdata
  datamemread.io.writevalid := io.wvalid
  datamemread.io.readvalid  := io.readvalid
  datamemread.io.wmask      := io.wstrb
  datamemread.io.clock      := clock
  // memdata                   := datamemread.io.dataout
  // rvalid                    := io.readvalid
  // io.rdata := memdata
  // io.rvalid := rvalid
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
      s_wait_rvalid -> Mux(instmem.io.inst_valid, Mux(axi.rready, s_waitaddr, s_wait_rready), s_wait_rvalid),
      s_wait_rready -> Mux(axi.rready, s_waitaddr, s_wait_rready)
    )
  )

}
class InstMemIO extends Bundle {
  val pc = Input(UInt(32.W))
  val en = Input(Bool())

  val inst       = Output(UInt(32.W))
  val inst_valid = Output(Bool())
}

class InstMem extends Module {
  val io          = IO(new InstMemIO)
  val instmemread = Module(new InstMemRead)
  val delay       = RegInit(0.U(4.W))
  val olddelay    = RegInit(0.U(4.W))

  val RANDOM: UInt = LFSR(4, delay === 0.U) % 8.U + 1.U
  // printf(p"RANDOM: $RANDOM\n")
  olddelay := delay
  delay    := Mux(delay === 0.U, Mux(io.en, RANDOM, 0.U), delay - 1.U)

  io.inst_valid := Mux(olddelay === 1.U & delay === 0.U, true.B, false.B)
  val instget = RegNext(instmemread.io.inst)

  // val instget     = ShiftRegister(instmemread.io.inst, 1)
  // val instget = ShiftRegister(instmemread.io.inst, 1)
  // val instget = ShiftRegister(instmemread.io.inst, RANDOM)

  // val instvalid = RegInit(true.B)
  // val instvalid = ShiftRegister(io.en, 1)
  // io.inst_valid := instvalid
  // instvalid     := io.en

  instmemread.io.pc    := io.pc
  instmemread.io.clock := clock

  io.inst := instget

}
