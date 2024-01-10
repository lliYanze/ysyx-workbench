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
