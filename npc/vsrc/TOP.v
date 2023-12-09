module PC(
  input         clock,
  input         reset,
  input  [31:0] io_pcin,
  output [31:0] io_pc
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] pc; // @[inst.scala 270:19]
  assign io_pc = pc; // @[inst.scala 272:9]
  always @(posedge clock) begin
    if (reset) begin // @[inst.scala 270:19]
      pc <= 32'h80000000; // @[inst.scala 270:19]
    end else begin
      pc <= io_pcin; // @[inst.scala 271:9]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  pc = _RAND_0[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module SourceDecoder(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [2:0]  io_format,
  output        io_s1type,
  output        io_pclj,
  output        io_pcrs1,
  output [4:0]  io_op
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg  start; // @[inst.scala 184:22]
  wire [31:0] _T = io_inst & 32'h707f; // @[inst.scala 186:16]
  wire  _T_1 = 32'h13 == _T; // @[inst.scala 186:16]
  wire [31:0] _T_2 = io_inst & 32'hfff0707f; // @[inst.scala 194:22]
  wire  _T_3 = 32'h100073 == _T_2; // @[inst.scala 194:22]
  wire [31:0] _T_4 = io_inst & 32'h7f; // @[inst.scala 201:22]
  wire  _T_5 = 32'h6f == _T_4; // @[inst.scala 201:22]
  wire  _T_7 = 32'h67 == _T; // @[inst.scala 209:22]
  wire  _T_9 = 32'h2023 == _T; // @[inst.scala 217:22]
  wire  _T_11 = 32'h17 == _T_4; // @[inst.scala 225:22]
  wire [4:0] _io_op_T_1 = start ? 5'h1f : 5'h1e; // @[inst.scala 234:21]
  wire  _T_13 = ~reset; // @[inst.scala 235:11]
  wire [2:0] _GEN_0 = 32'h17 == _T_4 ? 3'h0 : 3'h6; // @[inst.scala 225:48 226:15 233:15]
  wire [4:0] _GEN_1 = 32'h17 == _T_4 ? 5'h0 : _io_op_T_1; // @[inst.scala 225:48 227:15 234:15]
  wire  _GEN_3 = 32'h17 == _T_4 ? start : start + 1'h1; // @[inst.scala 184:22 225:48 236:15]
  wire [2:0] _GEN_4 = 32'h2023 == _T ? 3'h1 : _GEN_0; // @[inst.scala 217:45 218:15]
  wire [4:0] _GEN_5 = 32'h2023 == _T ? 5'h1e : _GEN_1; // @[inst.scala 217:45 219:15]
  wire  _GEN_7 = 32'h2023 == _T ? start : _GEN_3; // @[inst.scala 184:22 217:45]
  wire [2:0] _GEN_8 = 32'h67 == _T ? 3'h1 : _GEN_4; // @[inst.scala 209:47 210:15]
  wire [4:0] _GEN_9 = 32'h67 == _T ? 5'h2 : _GEN_5; // @[inst.scala 209:47 211:15]
  wire  _GEN_12 = 32'h67 == _T ? start : _GEN_7; // @[inst.scala 184:22 209:47]
  wire [2:0] _GEN_13 = 32'h6f == _T_4 ? 3'h5 : _GEN_8; // @[inst.scala 201:46 202:15]
  wire [4:0] _GEN_14 = 32'h6f == _T_4 ? 5'h2 : _GEN_9; // @[inst.scala 201:46 203:15]
  wire  _GEN_16 = 32'h6f == _T_4 | _T_7; // @[inst.scala 201:46 206:15]
  wire  _GEN_17 = 32'h6f == _T_4 ? 1'h0 : _T_7; // @[inst.scala 201:46 207:15]
  wire [2:0] _GEN_19 = 32'h100073 == _T_2 ? 3'h0 : _GEN_13; // @[inst.scala 194:49 195:15]
  wire [4:0] _GEN_20 = 32'h100073 == _T_2 ? 5'h1f : _GEN_14; // @[inst.scala 194:49 196:15]
  wire  _GEN_22 = 32'h100073 == _T_2 ? 1'h0 : _GEN_16; // @[inst.scala 194:49 199:15]
  wire  _GEN_23 = 32'h100073 == _T_2 ? 1'h0 : _GEN_17; // @[inst.scala 194:49 200:15]
  wire  _GEN_42 = ~_T_1 & ~_T_3 & ~_T_5 & ~_T_7 & ~_T_9 & ~_T_11; // @[inst.scala 235:11]
  assign io_format = 32'h13 == _T ? 3'h1 : _GEN_19; // @[inst.scala 186:41 187:15]
  assign io_s1type = 32'h13 == _T; // @[inst.scala 186:16]
  assign io_pclj = 32'h13 == _T ? 1'h0 : _GEN_22; // @[inst.scala 186:41 191:15]
  assign io_pcrs1 = 32'h13 == _T ? 1'h0 : _GEN_23; // @[inst.scala 186:41 192:15]
  assign io_op = 32'h13 == _T ? 5'h0 : _GEN_20; // @[inst.scala 186:41 188:15]
  always @(posedge clock) begin
    if (reset) begin // @[inst.scala 184:22]
      start <= 1'h0; // @[inst.scala 184:22]
    end else if (!(32'h13 == _T)) begin // @[inst.scala 186:41]
      if (!(32'h100073 == _T_2)) begin // @[inst.scala 194:49]
        if (!(32'h6f == _T_4)) begin // @[inst.scala 201:46]
          start <= _GEN_12;
        end
      end
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~_T_1 & ~_T_3 & ~_T_5 & ~_T_7 & ~_T_9 & ~_T_11 & ~reset) begin
          $fwrite(32'h80000002,"start: %d\n",start); // @[inst.scala 235:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_42 & _T_13) begin
          $fwrite(32'h80000002,"Error: Unknown instruction!\n"); // @[inst.scala 241:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  start = _RAND_0[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ImmGen(
  input  [2:0]  io_format,
  input  [19:0] io_inst,
  output [31:0] io_out
);
  wire [19:0] _io_out_T_2 = io_inst[19] ? 20'hfffff : 20'h0; // @[Bitwise.scala 77:12]
  wire [31:0] _io_out_T_4 = {_io_out_T_2,io_inst[19:8]}; // @[Cat.scala 33:92]
  wire [31:0] _io_out_T_7 = {io_inst,12'h0}; // @[Cat.scala 33:92]
  wire [11:0] _io_out_T_10 = io_inst[19] ? 12'hfff : 12'h0; // @[Bitwise.scala 77:12]
  wire [32:0] _io_out_T_15 = {_io_out_T_10,io_inst[19],io_inst[7:0],io_inst[8],io_inst[18:9],1'h0}; // @[Cat.scala 33:92]
  wire [32:0] _GEN_0 = io_format == 3'h5 ? _io_out_T_15 : 33'h0; // @[inst.scala 288:36 291:12 293:12]
  wire [32:0] _GEN_1 = io_format == 3'h0 ? {{1'd0}, _io_out_T_7} : _GEN_0; // @[inst.scala 286:36 287:12]
  wire [32:0] _GEN_2 = io_format == 3'h1 ? {{1'd0}, _io_out_T_4} : _GEN_1; // @[inst.scala 284:30 285:12]
  assign io_out = _GEN_2[31:0];
endmodule
module RegFile(
  input         clock,
  input         reset,
  input  [4:0]  io_rs1,
  input  [4:0]  io_rs2,
  input  [4:0]  io_rd,
  input         io_wr,
  input  [31:0] io_datain,
  output [31:0] io_rs1out,
  output [31:0] io_rs2out,
  output [31:0] io_end_state
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] regfile_0; // @[inst.scala 311:24]
  reg [31:0] regfile_1; // @[inst.scala 311:24]
  reg [31:0] regfile_2; // @[inst.scala 311:24]
  reg [31:0] regfile_3; // @[inst.scala 311:24]
  reg [31:0] regfile_4; // @[inst.scala 311:24]
  reg [31:0] regfile_5; // @[inst.scala 311:24]
  reg [31:0] regfile_6; // @[inst.scala 311:24]
  reg [31:0] regfile_7; // @[inst.scala 311:24]
  reg [31:0] regfile_8; // @[inst.scala 311:24]
  reg [31:0] regfile_9; // @[inst.scala 311:24]
  reg [31:0] regfile_10; // @[inst.scala 311:24]
  reg [31:0] regfile_11; // @[inst.scala 311:24]
  reg [31:0] regfile_12; // @[inst.scala 311:24]
  reg [31:0] regfile_13; // @[inst.scala 311:24]
  reg [31:0] regfile_14; // @[inst.scala 311:24]
  reg [31:0] regfile_15; // @[inst.scala 311:24]
  reg [31:0] regfile_16; // @[inst.scala 311:24]
  reg [31:0] regfile_17; // @[inst.scala 311:24]
  reg [31:0] regfile_18; // @[inst.scala 311:24]
  reg [31:0] regfile_19; // @[inst.scala 311:24]
  reg [31:0] regfile_20; // @[inst.scala 311:24]
  reg [31:0] regfile_21; // @[inst.scala 311:24]
  reg [31:0] regfile_22; // @[inst.scala 311:24]
  reg [31:0] regfile_23; // @[inst.scala 311:24]
  reg [31:0] regfile_24; // @[inst.scala 311:24]
  reg [31:0] regfile_25; // @[inst.scala 311:24]
  reg [31:0] regfile_26; // @[inst.scala 311:24]
  reg [31:0] regfile_27; // @[inst.scala 311:24]
  reg [31:0] regfile_28; // @[inst.scala 311:24]
  reg [31:0] regfile_29; // @[inst.scala 311:24]
  reg [31:0] regfile_30; // @[inst.scala 311:24]
  reg [31:0] regfile_31; // @[inst.scala 311:24]
  wire [31:0] _GEN_65 = 5'h1 == io_rs1 ? regfile_1 : regfile_0; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_66 = 5'h2 == io_rs1 ? regfile_2 : _GEN_65; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_67 = 5'h3 == io_rs1 ? regfile_3 : _GEN_66; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_68 = 5'h4 == io_rs1 ? regfile_4 : _GEN_67; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_69 = 5'h5 == io_rs1 ? regfile_5 : _GEN_68; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_70 = 5'h6 == io_rs1 ? regfile_6 : _GEN_69; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_71 = 5'h7 == io_rs1 ? regfile_7 : _GEN_70; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_72 = 5'h8 == io_rs1 ? regfile_8 : _GEN_71; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_73 = 5'h9 == io_rs1 ? regfile_9 : _GEN_72; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_74 = 5'ha == io_rs1 ? regfile_10 : _GEN_73; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_75 = 5'hb == io_rs1 ? regfile_11 : _GEN_74; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_76 = 5'hc == io_rs1 ? regfile_12 : _GEN_75; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_77 = 5'hd == io_rs1 ? regfile_13 : _GEN_76; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_78 = 5'he == io_rs1 ? regfile_14 : _GEN_77; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_79 = 5'hf == io_rs1 ? regfile_15 : _GEN_78; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_80 = 5'h10 == io_rs1 ? regfile_16 : _GEN_79; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_81 = 5'h11 == io_rs1 ? regfile_17 : _GEN_80; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_82 = 5'h12 == io_rs1 ? regfile_18 : _GEN_81; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_83 = 5'h13 == io_rs1 ? regfile_19 : _GEN_82; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_84 = 5'h14 == io_rs1 ? regfile_20 : _GEN_83; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_85 = 5'h15 == io_rs1 ? regfile_21 : _GEN_84; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_86 = 5'h16 == io_rs1 ? regfile_22 : _GEN_85; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_87 = 5'h17 == io_rs1 ? regfile_23 : _GEN_86; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_88 = 5'h18 == io_rs1 ? regfile_24 : _GEN_87; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_89 = 5'h19 == io_rs1 ? regfile_25 : _GEN_88; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_90 = 5'h1a == io_rs1 ? regfile_26 : _GEN_89; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_91 = 5'h1b == io_rs1 ? regfile_27 : _GEN_90; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_92 = 5'h1c == io_rs1 ? regfile_28 : _GEN_91; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_93 = 5'h1d == io_rs1 ? regfile_29 : _GEN_92; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_94 = 5'h1e == io_rs1 ? regfile_30 : _GEN_93; // @[inst.scala 322:{13,13}]
  wire [31:0] _GEN_97 = 5'h1 == io_rs2 ? regfile_1 : regfile_0; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_98 = 5'h2 == io_rs2 ? regfile_2 : _GEN_97; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_99 = 5'h3 == io_rs2 ? regfile_3 : _GEN_98; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_100 = 5'h4 == io_rs2 ? regfile_4 : _GEN_99; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_101 = 5'h5 == io_rs2 ? regfile_5 : _GEN_100; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_102 = 5'h6 == io_rs2 ? regfile_6 : _GEN_101; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_103 = 5'h7 == io_rs2 ? regfile_7 : _GEN_102; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_104 = 5'h8 == io_rs2 ? regfile_8 : _GEN_103; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_105 = 5'h9 == io_rs2 ? regfile_9 : _GEN_104; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_106 = 5'ha == io_rs2 ? regfile_10 : _GEN_105; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_107 = 5'hb == io_rs2 ? regfile_11 : _GEN_106; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_108 = 5'hc == io_rs2 ? regfile_12 : _GEN_107; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_109 = 5'hd == io_rs2 ? regfile_13 : _GEN_108; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_110 = 5'he == io_rs2 ? regfile_14 : _GEN_109; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_111 = 5'hf == io_rs2 ? regfile_15 : _GEN_110; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_112 = 5'h10 == io_rs2 ? regfile_16 : _GEN_111; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_113 = 5'h11 == io_rs2 ? regfile_17 : _GEN_112; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_114 = 5'h12 == io_rs2 ? regfile_18 : _GEN_113; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_115 = 5'h13 == io_rs2 ? regfile_19 : _GEN_114; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_116 = 5'h14 == io_rs2 ? regfile_20 : _GEN_115; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_117 = 5'h15 == io_rs2 ? regfile_21 : _GEN_116; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_118 = 5'h16 == io_rs2 ? regfile_22 : _GEN_117; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_119 = 5'h17 == io_rs2 ? regfile_23 : _GEN_118; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_120 = 5'h18 == io_rs2 ? regfile_24 : _GEN_119; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_121 = 5'h19 == io_rs2 ? regfile_25 : _GEN_120; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_122 = 5'h1a == io_rs2 ? regfile_26 : _GEN_121; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_123 = 5'h1b == io_rs2 ? regfile_27 : _GEN_122; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_124 = 5'h1c == io_rs2 ? regfile_28 : _GEN_123; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_125 = 5'h1d == io_rs2 ? regfile_29 : _GEN_124; // @[inst.scala 323:{13,13}]
  wire [31:0] _GEN_126 = 5'h1e == io_rs2 ? regfile_30 : _GEN_125; // @[inst.scala 323:{13,13}]
  assign io_rs1out = 5'h1f == io_rs1 ? regfile_31 : _GEN_94; // @[inst.scala 322:{13,13}]
  assign io_rs2out = 5'h1f == io_rs2 ? regfile_31 : _GEN_126; // @[inst.scala 323:{13,13}]
  assign io_end_state = regfile_10; // @[inst.scala 312:16]
  always @(posedge clock) begin
    if (reset) begin // @[inst.scala 311:24]
      regfile_0 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h0 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_0 <= 32'h0;
        end else begin
          regfile_0 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_1 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h1 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_1 <= 32'h0;
        end else begin
          regfile_1 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_2 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h2 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_2 <= 32'h0;
        end else begin
          regfile_2 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_3 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h3 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_3 <= 32'h0;
        end else begin
          regfile_3 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_4 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h4 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_4 <= 32'h0;
        end else begin
          regfile_4 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_5 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h5 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_5 <= 32'h0;
        end else begin
          regfile_5 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_6 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h6 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_6 <= 32'h0;
        end else begin
          regfile_6 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_7 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h7 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_7 <= 32'h0;
        end else begin
          regfile_7 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_8 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h8 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_8 <= 32'h0;
        end else begin
          regfile_8 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_9 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h9 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_9 <= 32'h0;
        end else begin
          regfile_9 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_10 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'ha == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_10 <= 32'h0;
        end else begin
          regfile_10 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_11 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'hb == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_11 <= 32'h0;
        end else begin
          regfile_11 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_12 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'hc == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_12 <= 32'h0;
        end else begin
          regfile_12 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_13 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'hd == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_13 <= 32'h0;
        end else begin
          regfile_13 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_14 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'he == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_14 <= 32'h0;
        end else begin
          regfile_14 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_15 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'hf == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_15 <= 32'h0;
        end else begin
          regfile_15 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_16 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h10 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_16 <= 32'h0;
        end else begin
          regfile_16 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_17 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h11 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_17 <= 32'h0;
        end else begin
          regfile_17 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_18 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h12 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_18 <= 32'h0;
        end else begin
          regfile_18 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_19 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h13 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_19 <= 32'h0;
        end else begin
          regfile_19 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_20 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h14 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_20 <= 32'h0;
        end else begin
          regfile_20 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_21 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h15 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_21 <= 32'h0;
        end else begin
          regfile_21 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_22 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h16 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_22 <= 32'h0;
        end else begin
          regfile_22 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_23 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h17 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_23 <= 32'h0;
        end else begin
          regfile_23 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_24 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h18 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_24 <= 32'h0;
        end else begin
          regfile_24 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_25 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h19 == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_25 <= 32'h0;
        end else begin
          regfile_25 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_26 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h1a == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_26 <= 32'h0;
        end else begin
          regfile_26 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_27 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h1b == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_27 <= 32'h0;
        end else begin
          regfile_27 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_28 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h1c == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_28 <= 32'h0;
        end else begin
          regfile_28 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_29 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h1d == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_29 <= 32'h0;
        end else begin
          regfile_29 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_30 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h1e == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_30 <= 32'h0;
        end else begin
          regfile_30 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 311:24]
      regfile_31 <= 32'h0; // @[inst.scala 311:24]
    end else if (io_wr) begin // @[inst.scala 317:15]
      if (5'h1f == io_rd) begin // @[inst.scala 318:20]
        if (io_rd == 5'h0) begin // @[inst.scala 318:26]
          regfile_31 <= 32'h0;
        end else begin
          regfile_31 <= io_datain;
        end
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regfile_0 = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  regfile_1 = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  regfile_2 = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  regfile_3 = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  regfile_4 = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  regfile_5 = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  regfile_6 = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  regfile_7 = _RAND_7[31:0];
  _RAND_8 = {1{`RANDOM}};
  regfile_8 = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  regfile_9 = _RAND_9[31:0];
  _RAND_10 = {1{`RANDOM}};
  regfile_10 = _RAND_10[31:0];
  _RAND_11 = {1{`RANDOM}};
  regfile_11 = _RAND_11[31:0];
  _RAND_12 = {1{`RANDOM}};
  regfile_12 = _RAND_12[31:0];
  _RAND_13 = {1{`RANDOM}};
  regfile_13 = _RAND_13[31:0];
  _RAND_14 = {1{`RANDOM}};
  regfile_14 = _RAND_14[31:0];
  _RAND_15 = {1{`RANDOM}};
  regfile_15 = _RAND_15[31:0];
  _RAND_16 = {1{`RANDOM}};
  regfile_16 = _RAND_16[31:0];
  _RAND_17 = {1{`RANDOM}};
  regfile_17 = _RAND_17[31:0];
  _RAND_18 = {1{`RANDOM}};
  regfile_18 = _RAND_18[31:0];
  _RAND_19 = {1{`RANDOM}};
  regfile_19 = _RAND_19[31:0];
  _RAND_20 = {1{`RANDOM}};
  regfile_20 = _RAND_20[31:0];
  _RAND_21 = {1{`RANDOM}};
  regfile_21 = _RAND_21[31:0];
  _RAND_22 = {1{`RANDOM}};
  regfile_22 = _RAND_22[31:0];
  _RAND_23 = {1{`RANDOM}};
  regfile_23 = _RAND_23[31:0];
  _RAND_24 = {1{`RANDOM}};
  regfile_24 = _RAND_24[31:0];
  _RAND_25 = {1{`RANDOM}};
  regfile_25 = _RAND_25[31:0];
  _RAND_26 = {1{`RANDOM}};
  regfile_26 = _RAND_26[31:0];
  _RAND_27 = {1{`RANDOM}};
  regfile_27 = _RAND_27[31:0];
  _RAND_28 = {1{`RANDOM}};
  regfile_28 = _RAND_28[31:0];
  _RAND_29 = {1{`RANDOM}};
  regfile_29 = _RAND_29[31:0];
  _RAND_30 = {1{`RANDOM}};
  regfile_30 = _RAND_30[31:0];
  _RAND_31 = {1{`RANDOM}};
  regfile_31 = _RAND_31[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module R1mux(
  input         io_r1type,
  input  [31:0] io_rs1,
  input  [31:0] io_pc,
  output [31:0] io_r1out
);
  assign io_r1out = io_r1type ? io_rs1 : io_pc; // @[inst.scala 115:18]
endmodule
module Alu(
  input         clock,
  input         reset,
  input  [31:0] io_s1,
  input  [31:0] io_s2,
  input  [4:0]  io_op,
  output [31:0] io_out,
  output        io_rw,
  output        io_end
);
  wire  _T = io_op == 5'h0; // @[inst.scala 144:14]
  wire [31:0] _io_out_T_1 = io_s1 + io_s2; // @[inst.scala 145:21]
  wire  _T_2 = ~reset; // @[inst.scala 147:11]
  wire  _T_3 = io_op == 5'h1f; // @[inst.scala 148:20]
  wire  _T_6 = io_op == 5'h1e; // @[inst.scala 153:20]
  wire  _T_9 = io_op == 5'h2; // @[inst.scala 157:20]
  wire [31:0] _io_out_T_3 = io_s1 + 32'h4; // @[inst.scala 158:21]
  wire [31:0] _GEN_0 = io_op == 5'h2 ? _io_out_T_3 : 32'h0; // @[inst.scala 157:33 158:12 163:12]
  wire  _GEN_2 = io_op == 5'h2 ? 1'h0 : 1'h1; // @[inst.scala 142:10 157:33 165:12]
  wire [31:0] _GEN_3 = io_op == 5'h1e ? 32'h0 : _GEN_0; // @[inst.scala 153:32 154:12]
  wire  _GEN_4 = io_op == 5'h1e ? 1'h0 : _T_9; // @[inst.scala 153:32 155:12]
  wire  _GEN_5 = io_op == 5'h1e ? 1'h0 : _GEN_2; // @[inst.scala 142:10 153:32]
  wire [31:0] _GEN_6 = io_op == 5'h1f ? 32'h0 : _GEN_3; // @[inst.scala 148:32 149:12]
  wire  _GEN_7 = io_op == 5'h1f ? 1'h0 : _GEN_4; // @[inst.scala 148:32 150:12]
  wire  _GEN_8 = io_op == 5'h1f | _GEN_5; // @[inst.scala 148:32 151:12]
  wire  _GEN_12 = ~_T; // @[inst.scala 152:11]
  wire  _GEN_16 = _GEN_12 & ~_T_3; // @[inst.scala 156:11]
  wire  _GEN_22 = _GEN_16 & ~_T_6; // @[inst.scala 160:11]
  assign io_out = io_op == 5'h0 ? _io_out_T_1 : _GEN_6; // @[inst.scala 144:26 145:12]
  assign io_rw = io_op == 5'h0 | _GEN_7; // @[inst.scala 144:26 146:12]
  assign io_end = io_op == 5'h0 ? 1'h0 : _GEN_8; // @[inst.scala 142:10 144:26]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T & ~reset) begin
          $fwrite(32'h80000002,"add\n"); // @[inst.scala 147:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~_T & _T_3 & _T_2) begin
          $fwrite(32'h80000002,"ebreak!\n"); // @[inst.scala 152:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_12 & ~_T_3 & _T_6 & _T_2) begin
          $fwrite(32'h80000002,"instruction nop!\n"); // @[inst.scala 156:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_16 & ~_T_6 & _T_9 & _T_2) begin
          $fwrite(32'h80000002,"jump ret \n"); // @[inst.scala 160:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_22 & ~_T_9 & _T_2) begin
          $fwrite(32'h80000002,"Error: Unknown instruction!\n"); // @[inst.scala 166:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module NextPc(
  input         io_pclj,
  input         io_pcrs1,
  input  [31:0] io_nowpc,
  input  [31:0] io_imm,
  input  [31:0] io_rs1,
  output [31:0] io_nextpc
);
  wire [31:0] immor4 = io_pclj ? io_imm : 32'h4; // @[inst.scala 257:16]
  wire [31:0] rs1orpc = io_pcrs1 ? io_rs1 : io_nowpc; // @[inst.scala 259:19]
  assign io_nextpc = rs1orpc + immor4; // @[inst.scala 260:24]
endmodule
module Exu(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [31:0] io_out,
  output [31:0] io_pc
);
  wire  pc_clock; // @[inst.scala 334:30]
  wire  pc_reset; // @[inst.scala 334:30]
  wire [31:0] pc_io_pcin; // @[inst.scala 334:30]
  wire [31:0] pc_io_pc; // @[inst.scala 334:30]
  wire  source_decoder_clock; // @[inst.scala 335:30]
  wire  source_decoder_reset; // @[inst.scala 335:30]
  wire [31:0] source_decoder_io_inst; // @[inst.scala 335:30]
  wire [2:0] source_decoder_io_format; // @[inst.scala 335:30]
  wire  source_decoder_io_s1type; // @[inst.scala 335:30]
  wire  source_decoder_io_pclj; // @[inst.scala 335:30]
  wire  source_decoder_io_pcrs1; // @[inst.scala 335:30]
  wire [4:0] source_decoder_io_op; // @[inst.scala 335:30]
  wire [2:0] immgen_io_format; // @[inst.scala 336:30]
  wire [19:0] immgen_io_inst; // @[inst.scala 336:30]
  wire [31:0] immgen_io_out; // @[inst.scala 336:30]
  wire  regfile_clock; // @[inst.scala 337:30]
  wire  regfile_reset; // @[inst.scala 337:30]
  wire [4:0] regfile_io_rs1; // @[inst.scala 337:30]
  wire [4:0] regfile_io_rs2; // @[inst.scala 337:30]
  wire [4:0] regfile_io_rd; // @[inst.scala 337:30]
  wire  regfile_io_wr; // @[inst.scala 337:30]
  wire [31:0] regfile_io_datain; // @[inst.scala 337:30]
  wire [31:0] regfile_io_rs1out; // @[inst.scala 337:30]
  wire [31:0] regfile_io_rs2out; // @[inst.scala 337:30]
  wire [31:0] regfile_io_end_state; // @[inst.scala 337:30]
  wire  r1mux_io_r1type; // @[inst.scala 338:30]
  wire [31:0] r1mux_io_rs1; // @[inst.scala 338:30]
  wire [31:0] r1mux_io_pc; // @[inst.scala 338:30]
  wire [31:0] r1mux_io_r1out; // @[inst.scala 338:30]
  wire  r2mux_io_r1type; // @[inst.scala 339:30]
  wire [31:0] r2mux_io_rs1; // @[inst.scala 339:30]
  wire [31:0] r2mux_io_pc; // @[inst.scala 339:30]
  wire [31:0] r2mux_io_r1out; // @[inst.scala 339:30]
  wire  alu_clock; // @[inst.scala 341:19]
  wire  alu_reset; // @[inst.scala 341:19]
  wire [31:0] alu_io_s1; // @[inst.scala 341:19]
  wire [31:0] alu_io_s2; // @[inst.scala 341:19]
  wire [4:0] alu_io_op; // @[inst.scala 341:19]
  wire [31:0] alu_io_out; // @[inst.scala 341:19]
  wire  alu_io_rw; // @[inst.scala 341:19]
  wire  alu_io_end; // @[inst.scala 341:19]
  wire  nextpc_io_pclj; // @[inst.scala 343:22]
  wire  nextpc_io_pcrs1; // @[inst.scala 343:22]
  wire [31:0] nextpc_io_nowpc; // @[inst.scala 343:22]
  wire [31:0] nextpc_io_imm; // @[inst.scala 343:22]
  wire [31:0] nextpc_io_rs1; // @[inst.scala 343:22]
  wire [31:0] nextpc_io_nextpc; // @[inst.scala 343:22]
  wire  endnpc_endflag; // @[inst.scala 345:22]
  wire [31:0] endnpc_state; // @[inst.scala 345:22]
  PC pc ( // @[inst.scala 334:30]
    .clock(pc_clock),
    .reset(pc_reset),
    .io_pcin(pc_io_pcin),
    .io_pc(pc_io_pc)
  );
  SourceDecoder source_decoder ( // @[inst.scala 335:30]
    .clock(source_decoder_clock),
    .reset(source_decoder_reset),
    .io_inst(source_decoder_io_inst),
    .io_format(source_decoder_io_format),
    .io_s1type(source_decoder_io_s1type),
    .io_pclj(source_decoder_io_pclj),
    .io_pcrs1(source_decoder_io_pcrs1),
    .io_op(source_decoder_io_op)
  );
  ImmGen immgen ( // @[inst.scala 336:30]
    .io_format(immgen_io_format),
    .io_inst(immgen_io_inst),
    .io_out(immgen_io_out)
  );
  RegFile regfile ( // @[inst.scala 337:30]
    .clock(regfile_clock),
    .reset(regfile_reset),
    .io_rs1(regfile_io_rs1),
    .io_rs2(regfile_io_rs2),
    .io_rd(regfile_io_rd),
    .io_wr(regfile_io_wr),
    .io_datain(regfile_io_datain),
    .io_rs1out(regfile_io_rs1out),
    .io_rs2out(regfile_io_rs2out),
    .io_end_state(regfile_io_end_state)
  );
  R1mux r1mux ( // @[inst.scala 338:30]
    .io_r1type(r1mux_io_r1type),
    .io_rs1(r1mux_io_rs1),
    .io_pc(r1mux_io_pc),
    .io_r1out(r1mux_io_r1out)
  );
  R1mux r2mux ( // @[inst.scala 339:30]
    .io_r1type(r2mux_io_r1type),
    .io_rs1(r2mux_io_rs1),
    .io_pc(r2mux_io_pc),
    .io_r1out(r2mux_io_r1out)
  );
  Alu alu ( // @[inst.scala 341:19]
    .clock(alu_clock),
    .reset(alu_reset),
    .io_s1(alu_io_s1),
    .io_s2(alu_io_s2),
    .io_op(alu_io_op),
    .io_out(alu_io_out),
    .io_rw(alu_io_rw),
    .io_end(alu_io_end)
  );
  NextPc nextpc ( // @[inst.scala 343:22]
    .io_pclj(nextpc_io_pclj),
    .io_pcrs1(nextpc_io_pcrs1),
    .io_nowpc(nextpc_io_nowpc),
    .io_imm(nextpc_io_imm),
    .io_rs1(nextpc_io_rs1),
    .io_nextpc(nextpc_io_nextpc)
  );
  EndNpc endnpc ( // @[inst.scala 345:22]
    .endflag(endnpc_endflag),
    .state(endnpc_state)
  );
  assign io_out = alu_io_out; // @[inst.scala 390:10]
  assign io_pc = pc_io_pc; // @[inst.scala 356:14]
  assign pc_clock = clock;
  assign pc_reset = reset;
  assign pc_io_pcin = nextpc_io_nextpc; // @[inst.scala 357:14]
  assign source_decoder_clock = clock;
  assign source_decoder_reset = reset;
  assign source_decoder_io_inst = io_inst; // @[inst.scala 359:26]
  assign immgen_io_format = source_decoder_io_format; // @[inst.scala 368:20]
  assign immgen_io_inst = io_inst[31:12]; // @[inst.scala 369:30]
  assign regfile_clock = clock;
  assign regfile_reset = reset;
  assign regfile_io_rs1 = io_inst[19:15]; // @[inst.scala 361:28]
  assign regfile_io_rs2 = io_inst[24:20]; // @[inst.scala 362:28]
  assign regfile_io_rd = io_inst[11:7]; // @[inst.scala 363:28]
  assign regfile_io_wr = alu_io_rw; // @[inst.scala 366:21]
  assign regfile_io_datain = alu_io_out; // @[inst.scala 365:21]
  assign r1mux_io_r1type = source_decoder_io_s1type; // @[inst.scala 374:19]
  assign r1mux_io_rs1 = regfile_io_rs1out; // @[inst.scala 376:19]
  assign r1mux_io_pc = pc_io_pc; // @[inst.scala 375:19]
  assign r2mux_io_r1type = 1'h0; // @[inst.scala 378:19]
  assign r2mux_io_rs1 = regfile_io_rs2out; // @[inst.scala 380:19]
  assign r2mux_io_pc = immgen_io_out; // @[inst.scala 379:19]
  assign alu_clock = clock;
  assign alu_reset = reset;
  assign alu_io_s1 = r1mux_io_r1out; // @[inst.scala 387:13]
  assign alu_io_s2 = r2mux_io_r1out; // @[inst.scala 388:13]
  assign alu_io_op = source_decoder_io_op; // @[inst.scala 386:13]
  assign nextpc_io_pclj = source_decoder_io_pclj; // @[inst.scala 353:19]
  assign nextpc_io_pcrs1 = source_decoder_io_pcrs1; // @[inst.scala 354:19]
  assign nextpc_io_nowpc = pc_io_pc; // @[inst.scala 351:19]
  assign nextpc_io_imm = immgen_io_out; // @[inst.scala 350:19]
  assign nextpc_io_rs1 = regfile_io_rs1out; // @[inst.scala 352:19]
  assign endnpc_endflag = alu_io_end; // @[inst.scala 371:21]
  assign endnpc_state = regfile_io_end_state; // @[inst.scala 372:21]
endmodule
module TOP(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [31:0] io_pc,
  output [31:0] io_out
);
  wire  exu_clock; // @[TOP.scala 13:19]
  wire  exu_reset; // @[TOP.scala 13:19]
  wire [31:0] exu_io_inst; // @[TOP.scala 13:19]
  wire [31:0] exu_io_out; // @[TOP.scala 13:19]
  wire [31:0] exu_io_pc; // @[TOP.scala 13:19]
  Exu exu ( // @[TOP.scala 13:19]
    .clock(exu_clock),
    .reset(exu_reset),
    .io_inst(exu_io_inst),
    .io_out(exu_io_out),
    .io_pc(exu_io_pc)
  );
  assign io_pc = exu_io_pc; // @[TOP.scala 14:15]
  assign io_out = exu_io_out; // @[TOP.scala 16:15]
  assign exu_clock = clock;
  assign exu_reset = reset;
  assign exu_io_inst = io_inst; // @[TOP.scala 15:15]
endmodule
