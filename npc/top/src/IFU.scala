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

// import datapath.{AxiLiteSignal, AxiLiteSignal_D, IFU2IDUPath}
import datapath._
import Memory.InstMemAxi

class IFU extends Module {
  val io = IO(new Bundle {
    val ifu2idu = Decoupled(new IFU2IDUPath)
    val instout = Output(UInt(32.W))
    val pcin    = Input(UInt(32.W))
    val pc      = Output(UInt(32.W))
    val diff    = Output(Bool())

  })

  val s_begin :: s_working :: s_workdown :: Nil = Enum(3)

  //module
  val pc         = Module(new PC)
  val instmemaxi = Module(new InstMemAxi)
  pc.io.pcin := io.pcin
  io.pc      := io.pcin

  //wire
  val ifu2iduPath = Wire(new IFU2IDUPath)
  val axi2mem     = Wire(new AxiLiteSignal_M)

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
    Mux(state === s_workdown, work2ing, Mux(axi2mem.slaver.arready, false.B, true.B))
  )
  axi2mem.master.arvalid := delay_arvalid.io.out

  //R通道
  delay_rready.io.en    := (state === s_working & axi2mem.slaver.rvalid)
  axi2mem.master.rready := delay_rready.io.out

  //AW通道
  axi2mem.master.awvalid := false.B
  axi2mem.master.awaddr  := DontCare
  assert(axi2mem.slaver.awready === false.B, "awready must be false.B")

  //W通道
  axi2mem.master.wdata  := DontCare
  axi2mem.master.wstrb  := 0x2.U
  axi2mem.master.wvalid := false.B
  assert(axi2mem.slaver.wready === false.B, "wready must be false.B")

  //B通道
  axi2mem.master.bready := false.B
  assert(axi2mem.slaver.bvalid === false.B, "bvalid must be false.B")

  //axi连线
  axi2mem.master.araddr := io.pcin
  instmemvalid          := axi2mem.slaver.rvalid & axi2mem.master.rready
  io.instout            := axi2mem.slaver.rdata
  ifu2iduPath.inst      := axi2mem.slaver.rdata

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
  io.diff := Mux((old_state === s_workdown) & (state === s_working), true.B, false.B)

  //axi连线

  instmemaxi.axi.master := axi2mem.master
  axi2mem.slaver        := instmemaxi.axi.slaver
}
