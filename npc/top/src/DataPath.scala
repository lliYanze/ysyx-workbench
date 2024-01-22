package datapath
import chisel3._

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
  val arvalid = Input(Bool()) //CPU已经读出有效suju
  val araddr  = Input(UInt(32.W))
  val arready = Output(Bool()) //通知CPU可以读取数据

  //mem用地址返回数据
  val rvalid = Output(Bool()) //读请求有效
  val rresp  = Output(UInt(2.W)) //异常信号
  val rdata  = Output(UInt(32.W)) //读出的数据
  val rready = Input(Bool()) //存储器可以接受读请求

  //mem读到写入地址
  // val awaddr  = Input(UInt(32.W)) //目前awaddr和araddr一样 没有让读写同时进行
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
