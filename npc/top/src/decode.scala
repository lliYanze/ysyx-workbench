package InstDecode

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._
import instsinfo._

class InstDecode extends Module {
  val io = IO(new Bundle {
    val inst       = Input(UInt(32.W))
    val format     = Output(UInt(3.W))
    val s1type     = Output(Bool()) //true : reg, false : PC
    val s2type     = Output(UInt(2.W)) //ture : reg, false : imm
    val jumpctl    = Output(UInt(3.W))
    val op         = Output(UInt(4.W))
    val ftrace     = Output(Bool())
    val memrd      = Output(Bool())
    val memwr      = Output(Bool())
    val memctl     = Output(UInt(3.W))
    val tomemorreg = Output(Bool())
    val regwr      = Output(Bool())
  })
  val s1Reg: Bool = true.B
  val s1PC:  Bool = false.B

  val s2Reg: Bool = true.B
  val s2Imm: Bool = false.B

  val enableFtrace: Bool = true.B
  val notFtrace:    Bool = false.B

  val mwr:    Bool = true.B
  val mnotwr: Bool = false.B

  val alutoreg: Bool = false.B
  val memtoreg: Bool = true.B

  val rwr:    Bool = true.B
  val rnotwr: Bool = false.B

  val mrd:    Bool = true.B
  val mnotrd: Bool = false.B

  val csignals =
    ListLookup(
      io.inst,
      List(TYPE.E, s1Reg, s2Reg, JUMPCTL.NOTJUMP, OPCTL.ERR, notFtrace, mnotwr, alutoreg, MEMCTL.NOP, rnotwr, mnotrd),
      Array(
        ///***************R***************//
        instructions.add -> List(
          TYPE.I,
          s1Reg,
          RS2MUX.REG,
          JUMPCTL.NOTJUMP,
          OPCTL.ADD,
          notFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rwr,
          mnotrd
        ),
        instructions.sub -> List(
          TYPE.I,
          s1Reg,
          RS2MUX.REG,
          JUMPCTL.NOTJUMP,
          OPCTL.SUB,
          notFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rwr,
          mnotrd
        ),
        ///***************I***************//
        instructions.addi -> List(
          TYPE.I,
          s1Reg,
          RS2MUX.IMM,
          JUMPCTL.NOTJUMP,
          OPCTL.ADD,
          notFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rwr,
          mnotrd
        ),
        instructions.sltiu -> List(
          TYPE.I,
          s1Reg,
          RS2MUX.IMM,
          JUMPCTL.NOTJUMP,
          OPCTL.SLTU,
          notFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rwr,
          mnotrd
        ),
        instructions.jalr -> List(
          TYPE.I,
          s1Reg,
          RS2MUX.PC,
          JUMPCTL.JLRS1,
          OPCTL.ADD,
          enableFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rwr,
          mnotrd
        ),
        instructions.lw -> List(
          TYPE.I,
          s1Reg,
          RS2MUX.IMM,
          JUMPCTL.NOTJUMP,
          OPCTL.ADD,
          notFtrace,
          mnotwr,
          memtoreg,
          MEMCTL.WORD,
          rwr,
          mrd
        ),
        instructions.ebreak -> List(
          TYPE.E,
          s1Reg,
          RS2MUX.IMM,
          JUMPCTL.NOTJUMP,
          OPCTL.END,
          notFtrace,
          mnotwr,
          memtoreg,
          MEMCTL.WORD,
          rwr,
          mrd
        ),
        ///***************U***************//
        instructions.auipc -> List(
          TYPE.U,
          s1PC,
          RS2MUX.IMM,
          JUMPCTL.NOTJUMP,
          OPCTL.ADD,
          notFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rwr,
          mnotrd
        ),
        ///***************J***************//
        instructions.jal -> List(
          TYPE.J,
          s1PC,
          RS2MUX.PC,
          JUMPCTL.JLPC,
          OPCTL.ADD,
          enableFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rwr,
          mnotrd
        ),
        ///***************S***************//
        instructions.sw -> List(
          TYPE.S,
          s1Reg,
          RS2MUX.IMM,
          JUMPCTL.NOTJUMP,
          OPCTL.ADD,
          notFtrace,
          mwr,
          alutoreg,
          MEMCTL.WORD,
          rnotwr,
          mrd
        ),
        ///***************B***************//
        instructions.beq -> List(
          TYPE.B,
          s1Reg,
          RS2MUX.REG,
          JUMPCTL.JEQ,
          OPCTL.SLT,
          enableFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rnotwr,
          mnotrd
        ),
        instructions.bne -> List(
          TYPE.B,
          s1Reg,
          RS2MUX.REG,
          JUMPCTL.JNE,
          OPCTL.SLT,
          enableFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rnotwr,
          mnotrd
        ),
        instructions.bge -> List(
          TYPE.B,
          s1Reg,
          RS2MUX.REG,
          JUMPCTL.JGE,
          OPCTL.SLT,
          enableFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rnotwr,
          mnotrd
        ),
        ///***************E***************//
        instructions.begin -> List(
          TYPE.E,
          s1Reg,
          RS2MUX.IMM,
          JUMPCTL.NOTJUMP,
          OPCTL.NOP,
          notFtrace,
          mnotwr,
          alutoreg,
          MEMCTL.NOP,
          rnotwr,
          mnotrd
        )
      )
    )

  io.format     := csignals(0)
  io.s1type     := csignals(1)
  io.s2type     := csignals(2)
  io.jumpctl    := csignals(3)
  io.op         := csignals(4)
  io.ftrace     := csignals(5)
  io.memwr      := csignals(6)
  io.tomemorreg := csignals(7)
  io.memctl     := csignals(8)
  io.regwr      := csignals(9)
  io.memrd      := csignals(10)
}
