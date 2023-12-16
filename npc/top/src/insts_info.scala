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

  val RS2 = "b1001".U(4.W)

  val NOP = "b1110".U(4.W)
  val END = "b1111".U(4.W)
  val ERR = "b1100".U(4.W)
}

case object JUMPCTL {
  val NOTJUMP = "b000".U(3.W)
  val JLPC    = "b001".U(3.W)
  val JLRS1   = "b010".U(3.W)
  val JEQ     = "b011".U(3.W)
  val JNE     = "b100".U(3.W)
  val JLT     = "b101".U(3.W)
  val JGE     = "b110".U(3.W)
}

case object MEMCTL {
  val BYTE  = "b000".U(3.W)
  val HALF  = "b001".U(3.W)
  val WORD  = "b010".U(3.W)
  val UCHAR = "b100".U(3.W)
  val UHALF = "b101".U(3.W)
  val NOP   = "b111".U(3.W)
}

case object instructions {

  /** ****************************
    */
  /** ************R***************
    */
  /** ****************************
    */

  val add: BitPat = BitPat("b0000000_?????_?????_000_?????_0110011")
  val sub: BitPat = BitPat("b0100000_?????_?????_000_?????_0110011")
  val xor: BitPat = BitPat("b0000000_?????_?????_100_?????_0110011")

  /** ****************************
    */
  /** ************I***************
    */
  /** ****************************
    */
  val addi: BitPat = BitPat("b???????_?????_?????_000_?????_0010011")

  val lw: BitPat = BitPat("b???????_?????_?????_010_?????_0000011")

  val sltiu: BitPat = BitPat("b???????_?????_?????_011_?????_0010011")

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

  val beq: BitPat = BitPat("b???????_?????_?????_000_?????_1100011")
  val bne: BitPat = BitPat("b???????_?????_?????_001_?????_1100011")

  val bge: BitPat = BitPat("b???????_?????_?????_101_?????_1100011")

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
