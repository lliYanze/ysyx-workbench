package IFU

import chisel3._
import chisel3.util._
import npctools._

class PC extends Module {
  val io = IO(new Bundle {
    val pcin = Input(UInt(32.W))
    val pc   = Output(UInt(32.W))
  })
  val pc = RegInit("h8000_0000".U(32.W))
  pc    := io.pcin
  io.pc := pc
}

import datapath.{AxiLiteSignal, IFU2IDUPath}
import Memory.InstMemAxi

class IFU extends Module {
  val io = IO(new Bundle {
    val ifu2idu = Decoupled(new IFU2IDUPath)
    val instout = Output(UInt(32.W))

    val pcin = Input(UInt(32.W))
    val pc   = Output(UInt(32.W))

    val diff = Output(Bool())

  })
  val s_begin :: s_working :: s_workdown :: Nil = Enum(3)

  //module
  val pc         = Module(new PC)
  val instmemaxi = Module(new InstMemAxi)
  pc.io.pcin := io.pcin
  io.pc      := io.pcin

  //wire
  val ifu2iduPath  = Wire(new IFU2IDUPath)
  val axi2mem      = Wire(Flipped(new AxiLiteSignal))
  val instmemvalid = Wire(Bool())
  val work2down    = Wire(Bool())
  val work2ing     = Wire(Bool())

  //state
  val state     = RegInit(s_begin)
  val old_state = RegInit(s_begin)
  val ifustate  = RegEnable(ifu2iduPath, work2down)
  ifu2iduPath.pc   := pc.io.pc
  io.ifu2idu.bits  := ifustate
  io.ifu2idu.valid := (state === s_workdown)

  work2down := (state === s_working & instmemvalid)
  work2ing  := (state === s_workdown & io.ifu2idu.ready)
  //随机延迟部分
  val delay_rready  = Module(new DelayTrueRandomCycle)
  val delay_arvalid = Module(new DelayTrueRandomCycle)

  //axi状态转移
  //AR通道
  delay_arvalid.io.en := Mux(
    state === s_begin,
    true.B, //由于最开始输入的地址就是有效值所以直接为true
    Mux(state === s_workdown, work2ing, Mux(axi2mem.arready, false.B, true.B))
  )
  axi2mem.arvalid := delay_arvalid.io.out

  //R通道
  delay_rready.io.en := (state === s_working & axi2mem.rvalid)
  axi2mem.rready     := delay_rready.io.out

  //AW通道
  axi2mem.awvalid := false.B
  axi2mem.awaddr  := DontCare
  assert(axi2mem.awready === false.B, "awready must be false.B")

  //W通道
  axi2mem.wdata  := DontCare
  axi2mem.wstrb  := DontCare
  axi2mem.wvalid := false.B
  assert(axi2mem.wready === false.B, "wready must be false.B")

  //B通道
  axi2mem.bready := false.B
  assert(axi2mem.bvalid === false.B, "bvalid must be false.B")

  //axi连线
  axi2mem.araddr   := io.pcin
  instmemvalid     := axi2mem.rvalid & axi2mem.rready
  io.instout       := axi2mem.rdata
  ifu2iduPath.inst := axi2mem.rdata

  //state转移
  old_state := state
  state := MuxLookup(
    state,
    s_workdown,
    List(
      s_begin -> Mux(io.pcin === "h8000_0000".U, s_working, s_begin),
      s_workdown -> Mux(io.ifu2idu.ready, s_working, s_workdown),
      s_working -> Mux(instmemvalid, s_workdown, s_working)
    )
  )

  // FIXME: diff规避最开始0x80000000的问题
  when(ifustate.pc === 0.U) {
    io.diff := false.B
  }.otherwise {
    io.diff := Mux((old_state === s_workdown) & (state === s_working), true.B, false.B)
  }
  //axi连线
  instmemaxi.axi.araddr  := axi2mem.araddr
  instmemaxi.axi.arvalid := axi2mem.arvalid
  axi2mem.arready        := instmemaxi.axi.arready

  axi2mem.rdata         := instmemaxi.axi.rdata
  axi2mem.rresp         := instmemaxi.axi.rresp
  axi2mem.rvalid        := instmemaxi.axi.rvalid
  instmemaxi.axi.rready := axi2mem.rready

  instmemaxi.axi.awvalid := axi2mem.awvalid
  instmemaxi.axi.awaddr  := axi2mem.awaddr
  axi2mem.awready        := instmemaxi.axi.awready

  instmemaxi.axi.wdata  := axi2mem.wdata
  instmemaxi.axi.wstrb  := axi2mem.wstrb
  instmemaxi.axi.wvalid := axi2mem.wvalid
  axi2mem.wready        := instmemaxi.axi.wready

  axi2mem.arready := instmemaxi.axi.arready

  axi2mem.bresp         := instmemaxi.axi.bresp
  axi2mem.bvalid        := instmemaxi.axi.bvalid
  instmemaxi.axi.bready := axi2mem.bready

}
