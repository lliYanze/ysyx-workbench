package datapath
import chisel3._
import chisel3.util._

class IFU2IDUPath extends Bundle {
  val inst = UInt(32.W)
  val pc   = UInt(32.W)
}

class IDU2EXUPath extends Bundle {
  val pc   = UInt(32.W)
  val inst = UInt(32.W)
  val imm  = UInt(32.W)
  val rs1  = UInt(32.W)
  val rs2  = UInt(32.W)
}

class EXU2WBPath extends Bundle {
  val pc   = UInt(32.W)
  val inst = UInt(32.W)
  val imm  = UInt(32.W)
  val rs1  = UInt(32.W)
  val rs2  = UInt(32.W)

  //控制下一条指令的地址
  val pclj        = Input(Bool()) //true imm ,false +4
  val pcrs1       = Input(Bool()) //true rs1 ,false PC
  val datamemaddr = UInt(32.W)
}

class EXUCtrlPath extends Bundle {
  val rs1type  = UInt(2.W)
  val rs2type  = UInt(2.W)
  val alu_op   = UInt(4.W)
  val jump_ctl = UInt(3.W)
}

class WBCtrlPath extends Bundle {
  val csrisjump      = Bool()
  val datamem_wr     = Bool()
  val datamem_rd     = Bool()
  val datamem_wmask  = UInt(3.W)
  val csr_wr         = Bool()
  val csr_rd         = Bool()
  val csr_wpc        = Bool()
  val csr_ecall      = Bool()
  val csr_mret       = Bool()
  val memorreg_memen = Bool()
  val csroralu_isscr = Bool()
  val reg_wr         = Bool()
}

class CtrlPath extends Bundle {
  val exuctrlpath = new EXUCtrlPath
  val wbctrlpath  = new WBCtrlPath
}

class AxiLiteSignal extends Bundle { //mem端

  //握手信号
  //
  //mem读到地址
  val arvalid = Input(Bool()) //CPU已经读出有效数据
  val araddr  = Input(UInt(32.W))
  val arready = Output(Bool()) //通知CPU可以读取数据

  //mem用地址返回数据
  val rvalid = Output(Bool()) //读请求有效
  val rresp  = Output(UInt(2.W)) //异常信号
  val rdata  = Output(UInt(32.W)) //读出的数据
  val rready = Input(Bool()) //存储器可以接受读请求

  //mem读到写入地址
  val awaddr  = Input(UInt(32.W)) //目前awaddr和araddr一样 没有让读写同时进行
  val awvalid = Input(Bool())
  val awready = Output(Bool())

  //mem写入数据
  val wstrb  = Input(UInt(3.W))
  val wdata  = Input(UInt(32.W))
  val wvalid = Input(Bool())
  val wready = Output(Bool())

  //异常处理
  val bresp  = Output(UInt(2.W)) //异常信号
  val bvalid = Output(Bool())
  val bready = Input(Bool())
}
class master_source extends Bundle {
  val arvalid = Input(Bool())
  val araddr  = Input(UInt(32.W))
  val rready  = Input(Bool())
  val awaddr  = Input(UInt(32.W))
  val awvalid = Input(Bool())
  val wstrb   = Input(UInt(3.W))
  val wdata   = Input(UInt(32.W))
  val wvalid  = Input(Bool())
  val bready  = Input(Bool())
}

class slave_source extends Bundle {
  val arready = Output(Bool())
  val rvalid  = Output(Bool())
  val rresp   = Output(UInt(2.W))
  val rdata   = Output(UInt(32.W))
  val awready = Output(Bool())
  val wready  = Output(Bool())
  val bresp   = Output(UInt(2.W))
  val bvalid  = Output(Bool())
}

class AxiLiteSignal_M extends Bundle {
  val master = Flipped(new master_source)
  val slaver = Flipped(new slave_source)
}
class AxiLiteSignal_S extends Bundle {
  val master = new master_source
  val slaver = new slave_source
}

// class AxiLiteSignal_D_F extends Bundle {
//   val m2s = Flipped(new master_source)
//   val s2m = (new slave_source)
// }

// class master_source extends Bundle {
//   val arvalid = (Bool()) //CPU已经读出有效数据
//   val araddr  = (UInt(32.W))
//   val rready  = (Bool()) //存储器可以接受读请求
//   val awaddr  = (UInt(32.W)) //目前awaddr和araddr一样 没有让读写同时进行
//   val awvalid = (Bool())
//   val wstrb   = (UInt(3.W))
//   val wdata   = (UInt(32.W))
//   val wvalid  = (Bool())
//   val bready  = (Bool())
// }
// class slave_source extends Bundle {
//
//   val arready = (Bool()) //通知CPU可以读取数据
//   val rvalid  = (Bool()) //读请求有效
//   val rresp   = (UInt(2.W)) //异常信号
//   val rdata   = (UInt(32.W)) //读出的数据
//   val awready = (Bool())
//   val bresp   = (UInt(2.W)) //异常信号
//   val bvalid  = (Bool())
// }
//
// class AxiLiteSignal_D extends Bundle { //m -> c
//   val m2s = new master_source
//   val s2m = Flipped(new slave_source)
// }
