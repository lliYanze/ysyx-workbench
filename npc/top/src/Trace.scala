package Trace

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.util.experimental.decode._

class EndNpc extends BlackBox with HasBlackBoxInline {
  val io = IO(new Bundle {
    val endflag = Input(Bool())
    val state   = Input(UInt(32.W))
  })

  // setInline(
  //   "EndNpc.v",
  //   s"""
  //      | import "DPI-C" function void stopnpc(input int state);
  //      |module EndNpc(
  //      |    input endflag,
  //      |  input wire [31:0] state
  //      |);
  //      | always @(*)
  //      |    if (endflag) stopnpc(state);
  //      |
  //      |endmodule
  //      |""".stripMargin
  // )
}

// class InstTrace extends BlackBox with HasBlackBoxInline {
//   val io = IO(new Bundle {
//     val inst  = Input(UInt(32.W))
//     val pc    = Input(UInt(32.W))
//     val clock = Input(Clock())
//   })
//
//   setInline(
//     "InstTrace.v",
//     s"""
//        | import "DPI-C" function void insttrace(input int pc, input int inst);
//        |module InstTrace(
//        |    input wire [31:0] inst,
//        |    input wire [31:0] pc,
//        |    input wire clock
//        |);
//        | always @(posedge clock)
//        |    insttrace(pc, inst);
//        |
//        |endmodule
//        |""".stripMargin
//   )
// }
//
// class Ftrace extends BlackBox with HasBlackBoxInline {
//   val io = IO(new Bundle {
//     val inst   = Input(UInt(32.W))
//     val pc     = Input(UInt(32.W))
//     val nextpc = Input(UInt(32.W))
//     val jump   = Input(Bool())
//     val clock  = Input(Clock())
//   })
//
//   setInline(
//     "Ftrace.v",
//     s"""
//        | import "DPI-C" function void ftrace(input int pc, input int inst, input int nextpc);
//        |module Ftrace(
//        |    input wire [31:0] inst,
//        |    input wire [31:0] pc,
//        |    input wire [31:0] nextpc,
//        |    input wire  jump,
//        |    input wire clock
//        |);
//        | always @(posedge clock)
//        |    if(jump) ftrace(pc, inst, nextpc);
//        |
//        |endmodule
//        |""".stripMargin
//   )
// }
