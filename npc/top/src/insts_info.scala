package instsinfo

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

case object TYPE {
  val U = 0.U(3.W)
  val I = 1.U(3.W)
  val S = 2.U(3.W)
  val B = 3.U(3.W)
  val R = 4.U(3.W)
  val J = 5.U(3.W)
  val E = 6.U(3.W)
}

case object OP3 {
  val ADD               = 0.U(3.W)
  val ShiftLeft         = 1.U(3.W)
  val LessThan          = 2.U(3.W)
  val LessThanU         = 3.U(3.W)
  val XOR               = 4.U(3.W)
  val ShiftRightLogical = 5.U(3.W)
  val OR                = 6.U(3.W)
  val AND               = 7.U(3.W)
}

case object RS2MUX {
  val IMM = "b00".U(2.W)
  val REG = "b01".U(2.W)
  val PC  = "b10".U(2.W)
}

case object OPCTL {
  val ADD  = "b0000".U(4.W)
  val SUB  = "b1000".U(4.W)
  val SLL  = "b0001".U(4.W)
  val SLT  = "b0010".U(4.W)
  val SLTU = "b0011".U(4.W)
  val XOR  = "b0100".U(4.W)
  val SRL  = "b0101".U(4.W)
  val SRA  = "b1101".U(4.W)
  val OR   = "b0110".U(4.W)
  val AND  = "b0111".U(4.W)

  val NOP = "b1110".U(4.W)
  val END = "b1111".U(4.W)
}

case object JUMPCTL {
  val NOTJUMP = "b000".U(3.W)
  val JLPC    = "b001".U(3.W)
  val JLRS1   = "b010".U(3.W)
}

case object OP {
  val ADD  = 0.U(5.W)
  val SUB  = 1.U(5.W)
  val JRET = 2.U(5.W)
  val JUMP = 3.U(5.W)

  val NOP = "b11110".U(5.W)

  val END = "b11111".U(5.W)

}

case object instructions {

  /** ****************************
    */
  /** ************R***************
    */
  /** ****************************
    */

  /** ****************************
    */
  /** ************I***************
    */
  /** ****************************
    */
  val addi: BitPat = BitPat("b???????_?????_?????_000_?????_0010011")

  val ebreak: BitPat = BitPat("b0000000_00001_?????_000_?????_1110011")

  val jalr: BitPat = BitPat("b???????_?????_?????_000_?????_1100111")

  /** ****************************
    */
  /** ************S***************
    */
  /** ****************************
    */

  val sw: BitPat = BitPat("b???????_?????_?????_010_?????_0100011")

  /** ****************************
    */
  /** ************B***************
    */
  /** ****************************
    */

  /** ****************************
    */
  /** ************U***************
    */
  /** ****************************
    */

  val auipc: BitPat = BitPat("b???????_?????_?????_???_?????_0010111")

  /** ****************************
    */
  /** ************J***************
    */
  /** ****************************
    */
  val jal: BitPat = BitPat("b???????_?????_?????_???_?????_1101111")

  val begin: BitPat = BitPat("b0000000_00000_00000_000_00000_0000000")

}
