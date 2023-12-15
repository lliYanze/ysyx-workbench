package InstDecode

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._
import instsinfo._

class InstDecode extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))

    val format = Output(UInt(3.W))
    val s1type = Output(Bool()) //true : reg, false : PC
    val s2type = Output(Bool()) //ture : reg, false : imm
    val pcrs1  = Output(Bool()) //ture : rs1, false : PC
    val pclj   = Output(Bool()) //ture : imm, false : +4
    val op     = Output(UInt(5.W))
    val ftrace = Output(Bool())
  })
  val s1Reg: Bool = true.B
  val s1PC:  Bool = false.B

  val s2Reg: Bool = true.B
  val s2Imm: Bool = false.B

  val pcLJ: Bool = true.B
  val pcA4: Bool = false.B

  val pcR:  Bool = true.B
  val pcPC: Bool = false.B

  val enableFtrace: Bool = true.B
  val notFtrace:    Bool = false.B

  val csignals =
    ListLookup(
      io.inst,
      List(TYPE.E, s1Reg, s2Reg, pcPC, pcA4, OP.END, notFtrace),
      Array(
        ///***************R***************//

        ///***************I***************//
        instructions.addi -> List(TYPE.I, s1Reg, s2Imm, pcPC, pcA4, OP.ADD, notFtrace),
        instructions.jalr -> List(TYPE.I, s1Reg, s2Imm, pcR, pcLJ, OP.JRET, enableFtrace),
        ///***************U***************//
        instructions.auipc -> List(TYPE.U, s1PC, s2Imm, pcPC, pcA4, OP.ADD, notFtrace),
        ///***************J***************//
        instructions.jal -> List(TYPE.J, s1PC, s2Imm, pcPC, pcLJ, OP.JRET, enableFtrace),
        ///***************S***************//
        instructions.sw -> List(TYPE.E, s1Reg, s2Imm, pcPC, pcA4, OP.NOP, notFtrace),
        ///***************E***************//
        instructions.begin -> List(TYPE.E, s1Reg, s2Imm, pcPC, pcA4, OP.NOP, notFtrace)
      )
    )

  io.format := csignals(0)
  io.s1type := csignals(1)
  io.s2type := csignals(2)
  io.pcrs1  := csignals(3)
  io.pclj   := csignals(4)
  io.op     := csignals(5)
  io.ftrace := csignals(6)

}
