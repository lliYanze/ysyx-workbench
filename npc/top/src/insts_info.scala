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

  // val SUB  = 1.U(5.W)
  // val JRET = 2.U(5.W)
  // val JUMP = 3.U(5.W)
  //
  // val NOP = "b11110".U(5.W)
  //
  // val END = "b11111".U(5.W)
}

case object OP7 {
  val MAIN = 0.U(7.W)
}

case object OP {
  val ADD  = 0.U(5.W)
  val SUB  = 1.U(5.W)
  val JRET = 2.U(5.W)
  val JUMP = 3.U(5.W)

  val NOP = "b11110".U(5.W)

  val END = "b11111".U(5.W)

}

case object TESTINSTRUCTIONS {
  val R  = "b0110011".U(7.W)
  val IR = "b0010011".U(7.W) //addi xori...
  val IM = "b0000011".U(7.W) //lb lh lw lbu lhu
  val IE = "b1110011".U(7.W) //ebreak
  val S  = "b0100011".U(7.W)
  val B  = "b1100011".U(7.W)
  val UP = "b0010111".U(7.W) //auipc
  val UI = "b0110111".U(7.W) //lui
  val J  = "b1101111".U(7.W)

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
