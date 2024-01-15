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
