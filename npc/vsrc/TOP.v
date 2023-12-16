module NextPc(
  input         io_pclj,
  input         io_pcrs1,
  input  [31:0] io_nowpc,
  input  [31:0] io_imm,
  input  [31:0] io_rs1,
  output [31:0] io_nextpc
);
  wire [31:0] immor4 = io_pclj ? io_imm : 32'h4; // @[singlecpu.scala 223:16]
  wire [31:0] rs1orpc = io_pcrs1 ? io_rs1 : io_nowpc; // @[singlecpu.scala 225:19]
  assign io_nextpc = rs1orpc + immor4; // @[singlecpu.scala 226:24]
endmodule
module PC(
  input         clock,
  input         reset,
  input  [31:0] io_pcin,
  output [31:0] io_pc
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] pc; // @[singlecpu.scala 236:19]
  assign io_pc = pc; // @[singlecpu.scala 238:9]
  always @(posedge clock) begin
    if (reset) begin // @[singlecpu.scala 236:19]
      pc <= 32'h80000000; // @[singlecpu.scala 236:19]
    end else begin
      pc <= io_pcin; // @[singlecpu.scala 237:9]
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
module InstDecode(
  input  [31:0] io_inst,
  output [2:0]  io_format,
  output        io_s1type,
  output [1:0]  io_s2type,
  output [2:0]  io_jumpctl,
  output [3:0]  io_op,
  output        io_ftrace,
  output        io_memrd,
  output        io_memwr,
  output [2:0]  io_memctl,
  output        io_tomemorreg,
  output        io_regwr
);
  wire [31:0] _csignals_T = io_inst & 32'h707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_1 = 32'h13 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_3 = 32'h67 == _csignals_T; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_4 = io_inst & 32'h7f; // @[Lookup.scala 31:38]
  wire  _csignals_T_5 = 32'h17 == _csignals_T_4; // @[Lookup.scala 31:38]
  wire  _csignals_T_7 = 32'h6f == _csignals_T_4; // @[Lookup.scala 31:38]
  wire  _csignals_T_9 = 32'h2023 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_11 = 32'h2003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_13 = 32'h5063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_15 = 32'h0 == io_inst; // @[Lookup.scala 31:38]
  wire [2:0] _csignals_T_17 = _csignals_T_13 ? 3'h3 : 3'h6; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_18 = _csignals_T_11 ? 3'h1 : _csignals_T_17; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_19 = _csignals_T_9 ? 3'h2 : _csignals_T_18; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_20 = _csignals_T_7 ? 3'h5 : _csignals_T_19; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_21 = _csignals_T_5 ? 3'h0 : _csignals_T_20; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_22 = _csignals_T_3 ? 3'h1 : _csignals_T_21; // @[Lookup.scala 34:39]
  wire  _csignals_T_27 = _csignals_T_7 ? 1'h0 : 1'h1; // @[Lookup.scala 34:39]
  wire  _csignals_T_28 = _csignals_T_5 ? 1'h0 : _csignals_T_27; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_30 = _csignals_T_15 ? 2'h0 : 2'h1; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_31 = _csignals_T_13 ? 2'h1 : _csignals_T_30; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_32 = _csignals_T_11 ? 2'h0 : _csignals_T_31; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_33 = _csignals_T_9 ? 2'h0 : _csignals_T_32; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_34 = _csignals_T_7 ? 2'h2 : _csignals_T_33; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_35 = _csignals_T_5 ? 2'h0 : _csignals_T_34; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_36 = _csignals_T_3 ? 2'h2 : _csignals_T_35; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_38 = _csignals_T_13 ? 3'h2 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_39 = _csignals_T_11 ? 3'h0 : _csignals_T_38; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_40 = _csignals_T_9 ? 3'h0 : _csignals_T_39; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_41 = _csignals_T_7 ? 3'h1 : _csignals_T_40; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_42 = _csignals_T_5 ? 3'h0 : _csignals_T_41; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_43 = _csignals_T_3 ? 3'h2 : _csignals_T_42; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_44 = _csignals_T_15 ? 4'he : 4'hf; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_45 = _csignals_T_13 ? 4'h8 : _csignals_T_44; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_46 = _csignals_T_11 ? 4'h0 : _csignals_T_45; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_47 = _csignals_T_9 ? 4'h0 : _csignals_T_46; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_48 = _csignals_T_7 ? 4'h0 : _csignals_T_47; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_49 = _csignals_T_5 ? 4'h0 : _csignals_T_48; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_50 = _csignals_T_3 ? 4'h0 : _csignals_T_49; // @[Lookup.scala 34:39]
  wire  _csignals_T_53 = _csignals_T_11 ? 1'h0 : _csignals_T_13; // @[Lookup.scala 34:39]
  wire  _csignals_T_54 = _csignals_T_9 ? 1'h0 : _csignals_T_53; // @[Lookup.scala 34:39]
  wire  _csignals_T_56 = _csignals_T_5 ? 1'h0 : _csignals_T_7 | _csignals_T_54; // @[Lookup.scala 34:39]
  wire  _csignals_T_62 = _csignals_T_7 ? 1'h0 : _csignals_T_9; // @[Lookup.scala 34:39]
  wire  _csignals_T_63 = _csignals_T_5 ? 1'h0 : _csignals_T_62; // @[Lookup.scala 34:39]
  wire  _csignals_T_64 = _csignals_T_3 ? 1'h0 : _csignals_T_63; // @[Lookup.scala 34:39]
  wire  _csignals_T_68 = _csignals_T_9 ? 1'h0 : _csignals_T_11; // @[Lookup.scala 34:39]
  wire  _csignals_T_69 = _csignals_T_7 ? 1'h0 : _csignals_T_68; // @[Lookup.scala 34:39]
  wire  _csignals_T_70 = _csignals_T_5 ? 1'h0 : _csignals_T_69; // @[Lookup.scala 34:39]
  wire  _csignals_T_71 = _csignals_T_3 ? 1'h0 : _csignals_T_70; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_74 = _csignals_T_11 ? 3'h2 : 3'h7; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_75 = _csignals_T_9 ? 3'h2 : _csignals_T_74; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_76 = _csignals_T_7 ? 3'h7 : _csignals_T_75; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_77 = _csignals_T_5 ? 3'h7 : _csignals_T_76; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_78 = _csignals_T_3 ? 3'h7 : _csignals_T_77; // @[Lookup.scala 34:39]
  wire  _csignals_T_90 = _csignals_T_7 ? 1'h0 : _csignals_T_9 | _csignals_T_11; // @[Lookup.scala 34:39]
  wire  _csignals_T_91 = _csignals_T_5 ? 1'h0 : _csignals_T_90; // @[Lookup.scala 34:39]
  wire  _csignals_T_92 = _csignals_T_3 ? 1'h0 : _csignals_T_91; // @[Lookup.scala 34:39]
  assign io_format = _csignals_T_1 ? 3'h1 : _csignals_T_22; // @[Lookup.scala 34:39]
  assign io_s1type = _csignals_T_1 | (_csignals_T_3 | _csignals_T_28); // @[Lookup.scala 34:39]
  assign io_s2type = _csignals_T_1 ? 2'h0 : _csignals_T_36; // @[Lookup.scala 34:39]
  assign io_jumpctl = _csignals_T_1 ? 3'h0 : _csignals_T_43; // @[Lookup.scala 34:39]
  assign io_op = _csignals_T_1 ? 4'h0 : _csignals_T_50; // @[Lookup.scala 34:39]
  assign io_ftrace = _csignals_T_1 ? 1'h0 : _csignals_T_3 | _csignals_T_56; // @[Lookup.scala 34:39]
  assign io_memrd = _csignals_T_1 ? 1'h0 : _csignals_T_92; // @[Lookup.scala 34:39]
  assign io_memwr = _csignals_T_1 ? 1'h0 : _csignals_T_64; // @[Lookup.scala 34:39]
  assign io_memctl = _csignals_T_1 ? 3'h7 : _csignals_T_78; // @[Lookup.scala 34:39]
  assign io_tomemorreg = _csignals_T_1 ? 1'h0 : _csignals_T_71; // @[Lookup.scala 34:39]
  assign io_regwr = _csignals_T_1 | (_csignals_T_3 | (_csignals_T_5 | (_csignals_T_7 | _csignals_T_68))); // @[Lookup.scala 34:39]
endmodule
module ImmGen(
  input  [2:0]  io_format,
  input  [31:0] io_inst,
  output [31:0] io_out
);
  wire [19:0] _io_out_T_2 = io_inst[31] ? 20'hfffff : 20'h0; // @[Bitwise.scala 77:12]
  wire [31:0] _io_out_T_4 = {_io_out_T_2,io_inst[31:20]}; // @[Cat.scala 33:92]
  wire [31:0] _io_out_T_7 = {io_inst[31:12],12'h0}; // @[Cat.scala 33:92]
  wire [11:0] _io_out_T_10 = io_inst[31] ? 12'hfff : 12'h0; // @[Bitwise.scala 77:12]
  wire [32:0] _io_out_T_15 = {_io_out_T_10,io_inst[31],io_inst[19:12],io_inst[20],io_inst[30:21],1'h0}; // @[Cat.scala 33:92]
  wire [31:0] _io_out_T_21 = {_io_out_T_2,io_inst[31:25],io_inst[11:7]}; // @[Cat.scala 33:92]
  wire [31:0] _GEN_0 = io_format == 3'h2 ? _io_out_T_21 : 32'h0; // @[singlecpu.scala 255:36 256:12 258:12]
  wire [32:0] _GEN_1 = io_format == 3'h5 ? _io_out_T_15 : {{1'd0}, _GEN_0}; // @[singlecpu.scala 253:36 254:12]
  wire [32:0] _GEN_2 = io_format == 3'h0 ? {{1'd0}, _io_out_T_7} : _GEN_1; // @[singlecpu.scala 251:36 252:12]
  wire [32:0] _GEN_3 = io_format == 3'h1 ? {{1'd0}, _io_out_T_4} : _GEN_2; // @[singlecpu.scala 249:30 250:12]
  assign io_out = _GEN_3[31:0];
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
  reg [31:0] regfile_0; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_1; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_2; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_3; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_4; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_5; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_6; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_7; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_8; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_9; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_10; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_11; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_12; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_13; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_14; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_15; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_16; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_17; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_18; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_19; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_20; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_21; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_22; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_23; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_24; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_25; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_26; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_27; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_28; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_29; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_30; // @[singlecpu.scala 276:24]
  reg [31:0] regfile_31; // @[singlecpu.scala 276:24]
  wire [31:0] _GEN_65 = 5'h1 == io_rs1 ? regfile_1 : regfile_0; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_66 = 5'h2 == io_rs1 ? regfile_2 : _GEN_65; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_67 = 5'h3 == io_rs1 ? regfile_3 : _GEN_66; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_68 = 5'h4 == io_rs1 ? regfile_4 : _GEN_67; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_69 = 5'h5 == io_rs1 ? regfile_5 : _GEN_68; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_70 = 5'h6 == io_rs1 ? regfile_6 : _GEN_69; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_71 = 5'h7 == io_rs1 ? regfile_7 : _GEN_70; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_72 = 5'h8 == io_rs1 ? regfile_8 : _GEN_71; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_73 = 5'h9 == io_rs1 ? regfile_9 : _GEN_72; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_74 = 5'ha == io_rs1 ? regfile_10 : _GEN_73; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_75 = 5'hb == io_rs1 ? regfile_11 : _GEN_74; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_76 = 5'hc == io_rs1 ? regfile_12 : _GEN_75; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_77 = 5'hd == io_rs1 ? regfile_13 : _GEN_76; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_78 = 5'he == io_rs1 ? regfile_14 : _GEN_77; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_79 = 5'hf == io_rs1 ? regfile_15 : _GEN_78; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_80 = 5'h10 == io_rs1 ? regfile_16 : _GEN_79; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_81 = 5'h11 == io_rs1 ? regfile_17 : _GEN_80; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_82 = 5'h12 == io_rs1 ? regfile_18 : _GEN_81; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_83 = 5'h13 == io_rs1 ? regfile_19 : _GEN_82; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_84 = 5'h14 == io_rs1 ? regfile_20 : _GEN_83; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_85 = 5'h15 == io_rs1 ? regfile_21 : _GEN_84; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_86 = 5'h16 == io_rs1 ? regfile_22 : _GEN_85; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_87 = 5'h17 == io_rs1 ? regfile_23 : _GEN_86; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_88 = 5'h18 == io_rs1 ? regfile_24 : _GEN_87; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_89 = 5'h19 == io_rs1 ? regfile_25 : _GEN_88; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_90 = 5'h1a == io_rs1 ? regfile_26 : _GEN_89; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_91 = 5'h1b == io_rs1 ? regfile_27 : _GEN_90; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_92 = 5'h1c == io_rs1 ? regfile_28 : _GEN_91; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_93 = 5'h1d == io_rs1 ? regfile_29 : _GEN_92; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_94 = 5'h1e == io_rs1 ? regfile_30 : _GEN_93; // @[singlecpu.scala 284:{13,13}]
  wire [31:0] _GEN_97 = 5'h1 == io_rs2 ? regfile_1 : regfile_0; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_98 = 5'h2 == io_rs2 ? regfile_2 : _GEN_97; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_99 = 5'h3 == io_rs2 ? regfile_3 : _GEN_98; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_100 = 5'h4 == io_rs2 ? regfile_4 : _GEN_99; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_101 = 5'h5 == io_rs2 ? regfile_5 : _GEN_100; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_102 = 5'h6 == io_rs2 ? regfile_6 : _GEN_101; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_103 = 5'h7 == io_rs2 ? regfile_7 : _GEN_102; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_104 = 5'h8 == io_rs2 ? regfile_8 : _GEN_103; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_105 = 5'h9 == io_rs2 ? regfile_9 : _GEN_104; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_106 = 5'ha == io_rs2 ? regfile_10 : _GEN_105; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_107 = 5'hb == io_rs2 ? regfile_11 : _GEN_106; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_108 = 5'hc == io_rs2 ? regfile_12 : _GEN_107; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_109 = 5'hd == io_rs2 ? regfile_13 : _GEN_108; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_110 = 5'he == io_rs2 ? regfile_14 : _GEN_109; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_111 = 5'hf == io_rs2 ? regfile_15 : _GEN_110; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_112 = 5'h10 == io_rs2 ? regfile_16 : _GEN_111; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_113 = 5'h11 == io_rs2 ? regfile_17 : _GEN_112; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_114 = 5'h12 == io_rs2 ? regfile_18 : _GEN_113; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_115 = 5'h13 == io_rs2 ? regfile_19 : _GEN_114; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_116 = 5'h14 == io_rs2 ? regfile_20 : _GEN_115; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_117 = 5'h15 == io_rs2 ? regfile_21 : _GEN_116; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_118 = 5'h16 == io_rs2 ? regfile_22 : _GEN_117; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_119 = 5'h17 == io_rs2 ? regfile_23 : _GEN_118; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_120 = 5'h18 == io_rs2 ? regfile_24 : _GEN_119; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_121 = 5'h19 == io_rs2 ? regfile_25 : _GEN_120; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_122 = 5'h1a == io_rs2 ? regfile_26 : _GEN_121; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_123 = 5'h1b == io_rs2 ? regfile_27 : _GEN_122; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_124 = 5'h1c == io_rs2 ? regfile_28 : _GEN_123; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_125 = 5'h1d == io_rs2 ? regfile_29 : _GEN_124; // @[singlecpu.scala 285:{13,13}]
  wire [31:0] _GEN_126 = 5'h1e == io_rs2 ? regfile_30 : _GEN_125; // @[singlecpu.scala 285:{13,13}]
  assign io_rs1out = 5'h1f == io_rs1 ? regfile_31 : _GEN_94; // @[singlecpu.scala 284:{13,13}]
  assign io_rs2out = 5'h1f == io_rs2 ? regfile_31 : _GEN_126; // @[singlecpu.scala 285:{13,13}]
  assign io_end_state = regfile_10; // @[singlecpu.scala 277:16]
  always @(posedge clock) begin
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_0 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h0 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_0 <= 32'h0;
        end else begin
          regfile_0 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_1 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h1 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_1 <= 32'h0;
        end else begin
          regfile_1 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_2 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h2 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_2 <= 32'h0;
        end else begin
          regfile_2 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_3 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h3 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_3 <= 32'h0;
        end else begin
          regfile_3 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_4 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h4 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_4 <= 32'h0;
        end else begin
          regfile_4 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_5 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h5 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_5 <= 32'h0;
        end else begin
          regfile_5 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_6 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h6 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_6 <= 32'h0;
        end else begin
          regfile_6 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_7 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h7 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_7 <= 32'h0;
        end else begin
          regfile_7 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_8 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h8 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_8 <= 32'h0;
        end else begin
          regfile_8 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_9 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h9 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_9 <= 32'h0;
        end else begin
          regfile_9 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_10 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'ha == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_10 <= 32'h0;
        end else begin
          regfile_10 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_11 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'hb == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_11 <= 32'h0;
        end else begin
          regfile_11 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_12 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'hc == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_12 <= 32'h0;
        end else begin
          regfile_12 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_13 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'hd == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_13 <= 32'h0;
        end else begin
          regfile_13 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_14 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'he == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_14 <= 32'h0;
        end else begin
          regfile_14 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_15 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'hf == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_15 <= 32'h0;
        end else begin
          regfile_15 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_16 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h10 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_16 <= 32'h0;
        end else begin
          regfile_16 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_17 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h11 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_17 <= 32'h0;
        end else begin
          regfile_17 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_18 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h12 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_18 <= 32'h0;
        end else begin
          regfile_18 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_19 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h13 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_19 <= 32'h0;
        end else begin
          regfile_19 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_20 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h14 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_20 <= 32'h0;
        end else begin
          regfile_20 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_21 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h15 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_21 <= 32'h0;
        end else begin
          regfile_21 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_22 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h16 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_22 <= 32'h0;
        end else begin
          regfile_22 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_23 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h17 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_23 <= 32'h0;
        end else begin
          regfile_23 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_24 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h18 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_24 <= 32'h0;
        end else begin
          regfile_24 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_25 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h19 == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_25 <= 32'h0;
        end else begin
          regfile_25 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_26 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h1a == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_26 <= 32'h0;
        end else begin
          regfile_26 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_27 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h1b == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_27 <= 32'h0;
        end else begin
          regfile_27 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_28 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h1c == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_28 <= 32'h0;
        end else begin
          regfile_28 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_29 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h1d == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_29 <= 32'h0;
        end else begin
          regfile_29 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_30 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h1e == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_30 <= 32'h0;
        end else begin
          regfile_30 <= io_datain;
        end
      end
    end
    if (reset) begin // @[singlecpu.scala 276:24]
      regfile_31 <= 32'h0; // @[singlecpu.scala 276:24]
    end else if (io_wr) begin // @[singlecpu.scala 280:15]
      if (5'h1f == io_rd) begin // @[singlecpu.scala 281:20]
        if (io_rd == 5'h0) begin // @[singlecpu.scala 281:26]
          regfile_31 <= 32'h0;
        end else begin
          regfile_31 <= io_datain;
        end
      end
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset) begin
          $fwrite(32'h80000002,"rd is %x  datain: %x\n",io_rd,io_datain); // @[singlecpu.scala 286:9]
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
  assign io_r1out = io_r1type ? io_rs1 : io_pc; // @[singlecpu.scala 145:18]
endmodule
module R2mux(
  input  [1:0]  io_r2type,
  input  [31:0] io_rs2,
  input  [31:0] io_imm,
  output [31:0] io_r2out
);
  wire [31:0] _io_r2out_T_2 = io_r2type[0] ? io_rs2 : io_imm; // @[singlecpu.scala 156:47]
  assign io_r2out = io_r2type[1] ? 32'h4 : _io_r2out_T_2; // @[singlecpu.scala 156:18]
endmodule
module Alu(
  input         clock,
  input         reset,
  input  [31:0] io_s1,
  input  [31:0] io_s2,
  input  [3:0]  io_op,
  output [31:0] io_out,
  output        io_end
);
  wire  _T = io_op == 4'h0; // @[singlecpu.scala 170:14]
  wire [31:0] _io_out_T_1 = io_s1 + io_s2; // @[singlecpu.scala 171:21]
  wire  _T_1 = io_op == 4'hf; // @[singlecpu.scala 172:20]
  wire  _T_2 = io_op == 4'he; // @[singlecpu.scala 175:20]
  wire  _T_4 = ~reset; // @[singlecpu.scala 177:11]
  wire  _GEN_1 = io_op == 4'he ? 1'h0 : 1'h1; // @[singlecpu.scala 168:10 175:35 180:12]
  wire  _GEN_3 = io_op == 4'hf | _GEN_1; // @[singlecpu.scala 172:35 174:12]
  wire  _GEN_8 = ~_T & ~_T_1; // @[singlecpu.scala 177:11]
  assign io_out = io_op == 4'h0 ? _io_out_T_1 : 32'h0; // @[singlecpu.scala 170:29 171:12]
  assign io_end = io_op == 4'h0 ? 1'h0 : _GEN_3; // @[singlecpu.scala 168:10 170:29]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~_T & ~_T_1 & _T_2 & ~reset) begin
          $fwrite(32'h80000002,"instruction nop!\n"); // @[singlecpu.scala 177:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_8 & ~_T_2 & _T_4) begin
          $fwrite(32'h80000002,"Error: Unknown instruction!\n"); // @[singlecpu.scala 181:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module JumpCtl(
  input  [2:0] io_ctl,
  output       io_pclj,
  output       io_pcrs1
);
  wire  _T_1 = io_ctl == 3'h2; // @[singlecpu.scala 201:21]
  assign io_pclj = io_ctl == 3'h1 | _T_1; // @[singlecpu.scala 198:33 199:14]
  assign io_pcrs1 = io_ctl == 3'h1 ? 1'h0 : _T_1; // @[singlecpu.scala 198:33 200:14]
endmodule
module MemorRegMux(
  input  [31:0] io_memdata,
  input  [31:0] io_regdata,
  input         io_memen,
  output [31:0] io_out
);
  assign io_out = io_memen ? io_memdata : io_regdata; // @[singlecpu.scala 57:16]
endmodule
module Exu(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [31:0] io_out,
  output [31:0] io_pc
);
  wire  nextpc_io_pclj; // @[singlecpu.scala 298:30]
  wire  nextpc_io_pcrs1; // @[singlecpu.scala 298:30]
  wire [31:0] nextpc_io_nowpc; // @[singlecpu.scala 298:30]
  wire [31:0] nextpc_io_imm; // @[singlecpu.scala 298:30]
  wire [31:0] nextpc_io_rs1; // @[singlecpu.scala 298:30]
  wire [31:0] nextpc_io_nextpc; // @[singlecpu.scala 298:30]
  wire  pc_clock; // @[singlecpu.scala 299:30]
  wire  pc_reset; // @[singlecpu.scala 299:30]
  wire [31:0] pc_io_pcin; // @[singlecpu.scala 299:30]
  wire [31:0] pc_io_pc; // @[singlecpu.scala 299:30]
  wire [31:0] source_decoder_io_inst; // @[singlecpu.scala 300:30]
  wire [2:0] source_decoder_io_format; // @[singlecpu.scala 300:30]
  wire  source_decoder_io_s1type; // @[singlecpu.scala 300:30]
  wire [1:0] source_decoder_io_s2type; // @[singlecpu.scala 300:30]
  wire [2:0] source_decoder_io_jumpctl; // @[singlecpu.scala 300:30]
  wire [3:0] source_decoder_io_op; // @[singlecpu.scala 300:30]
  wire  source_decoder_io_ftrace; // @[singlecpu.scala 300:30]
  wire  source_decoder_io_memrd; // @[singlecpu.scala 300:30]
  wire  source_decoder_io_memwr; // @[singlecpu.scala 300:30]
  wire [2:0] source_decoder_io_memctl; // @[singlecpu.scala 300:30]
  wire  source_decoder_io_tomemorreg; // @[singlecpu.scala 300:30]
  wire  source_decoder_io_regwr; // @[singlecpu.scala 300:30]
  wire [2:0] immgen_io_format; // @[singlecpu.scala 301:30]
  wire [31:0] immgen_io_inst; // @[singlecpu.scala 301:30]
  wire [31:0] immgen_io_out; // @[singlecpu.scala 301:30]
  wire  regfile_clock; // @[singlecpu.scala 302:30]
  wire  regfile_reset; // @[singlecpu.scala 302:30]
  wire [4:0] regfile_io_rs1; // @[singlecpu.scala 302:30]
  wire [4:0] regfile_io_rs2; // @[singlecpu.scala 302:30]
  wire [4:0] regfile_io_rd; // @[singlecpu.scala 302:30]
  wire  regfile_io_wr; // @[singlecpu.scala 302:30]
  wire [31:0] regfile_io_datain; // @[singlecpu.scala 302:30]
  wire [31:0] regfile_io_rs1out; // @[singlecpu.scala 302:30]
  wire [31:0] regfile_io_rs2out; // @[singlecpu.scala 302:30]
  wire [31:0] regfile_io_end_state; // @[singlecpu.scala 302:30]
  wire  r1mux_io_r1type; // @[singlecpu.scala 303:30]
  wire [31:0] r1mux_io_rs1; // @[singlecpu.scala 303:30]
  wire [31:0] r1mux_io_pc; // @[singlecpu.scala 303:30]
  wire [31:0] r1mux_io_r1out; // @[singlecpu.scala 303:30]
  wire [1:0] r2mux_io_r2type; // @[singlecpu.scala 304:30]
  wire [31:0] r2mux_io_rs2; // @[singlecpu.scala 304:30]
  wire [31:0] r2mux_io_imm; // @[singlecpu.scala 304:30]
  wire [31:0] r2mux_io_r2out; // @[singlecpu.scala 304:30]
  wire  alu_clock; // @[singlecpu.scala 305:30]
  wire  alu_reset; // @[singlecpu.scala 305:30]
  wire [31:0] alu_io_s1; // @[singlecpu.scala 305:30]
  wire [31:0] alu_io_s2; // @[singlecpu.scala 305:30]
  wire [3:0] alu_io_op; // @[singlecpu.scala 305:30]
  wire [31:0] alu_io_out; // @[singlecpu.scala 305:30]
  wire  alu_io_end; // @[singlecpu.scala 305:30]
  wire  endnpc_endflag; // @[singlecpu.scala 307:22]
  wire [31:0] endnpc_state; // @[singlecpu.scala 307:22]
  wire [31:0] insttrace_inst; // @[singlecpu.scala 310:25]
  wire [31:0] insttrace_pc; // @[singlecpu.scala 310:25]
  wire  insttrace_clock; // @[singlecpu.scala 310:25]
  wire [31:0] ftrace_inst; // @[singlecpu.scala 311:25]
  wire [31:0] ftrace_pc; // @[singlecpu.scala 311:25]
  wire [31:0] ftrace_nextpc; // @[singlecpu.scala 311:25]
  wire  ftrace_jump; // @[singlecpu.scala 311:25]
  wire  ftrace_clock; // @[singlecpu.scala 311:25]
  wire [2:0] jumpctl_io_ctl; // @[singlecpu.scala 312:25]
  wire  jumpctl_io_pclj; // @[singlecpu.scala 312:25]
  wire  jumpctl_io_pcrs1; // @[singlecpu.scala 312:25]
  wire [31:0] memorregmux_io_memdata; // @[singlecpu.scala 314:27]
  wire [31:0] memorregmux_io_regdata; // @[singlecpu.scala 314:27]
  wire  memorregmux_io_memen; // @[singlecpu.scala 314:27]
  wire [31:0] memorregmux_io_out; // @[singlecpu.scala 314:27]
  wire [31:0] datamem_addr; // @[singlecpu.scala 315:27]
  wire [31:0] datamem_data; // @[singlecpu.scala 315:27]
  wire  datamem_wr; // @[singlecpu.scala 315:27]
  wire  datamem_valid; // @[singlecpu.scala 315:27]
  wire [2:0] datamem_wmask; // @[singlecpu.scala 315:27]
  wire  datamem_clock; // @[singlecpu.scala 315:27]
  wire [31:0] datamem_dataout; // @[singlecpu.scala 315:27]
  NextPc nextpc ( // @[singlecpu.scala 298:30]
    .io_pclj(nextpc_io_pclj),
    .io_pcrs1(nextpc_io_pcrs1),
    .io_nowpc(nextpc_io_nowpc),
    .io_imm(nextpc_io_imm),
    .io_rs1(nextpc_io_rs1),
    .io_nextpc(nextpc_io_nextpc)
  );
  PC pc ( // @[singlecpu.scala 299:30]
    .clock(pc_clock),
    .reset(pc_reset),
    .io_pcin(pc_io_pcin),
    .io_pc(pc_io_pc)
  );
  InstDecode source_decoder ( // @[singlecpu.scala 300:30]
    .io_inst(source_decoder_io_inst),
    .io_format(source_decoder_io_format),
    .io_s1type(source_decoder_io_s1type),
    .io_s2type(source_decoder_io_s2type),
    .io_jumpctl(source_decoder_io_jumpctl),
    .io_op(source_decoder_io_op),
    .io_ftrace(source_decoder_io_ftrace),
    .io_memrd(source_decoder_io_memrd),
    .io_memwr(source_decoder_io_memwr),
    .io_memctl(source_decoder_io_memctl),
    .io_tomemorreg(source_decoder_io_tomemorreg),
    .io_regwr(source_decoder_io_regwr)
  );
  ImmGen immgen ( // @[singlecpu.scala 301:30]
    .io_format(immgen_io_format),
    .io_inst(immgen_io_inst),
    .io_out(immgen_io_out)
  );
  RegFile regfile ( // @[singlecpu.scala 302:30]
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
  R1mux r1mux ( // @[singlecpu.scala 303:30]
    .io_r1type(r1mux_io_r1type),
    .io_rs1(r1mux_io_rs1),
    .io_pc(r1mux_io_pc),
    .io_r1out(r1mux_io_r1out)
  );
  R2mux r2mux ( // @[singlecpu.scala 304:30]
    .io_r2type(r2mux_io_r2type),
    .io_rs2(r2mux_io_rs2),
    .io_imm(r2mux_io_imm),
    .io_r2out(r2mux_io_r2out)
  );
  Alu alu ( // @[singlecpu.scala 305:30]
    .clock(alu_clock),
    .reset(alu_reset),
    .io_s1(alu_io_s1),
    .io_s2(alu_io_s2),
    .io_op(alu_io_op),
    .io_out(alu_io_out),
    .io_end(alu_io_end)
  );
  EndNpc endnpc ( // @[singlecpu.scala 307:22]
    .endflag(endnpc_endflag),
    .state(endnpc_state)
  );
  InstTrace insttrace ( // @[singlecpu.scala 310:25]
    .inst(insttrace_inst),
    .pc(insttrace_pc),
    .clock(insttrace_clock)
  );
  Ftrace ftrace ( // @[singlecpu.scala 311:25]
    .inst(ftrace_inst),
    .pc(ftrace_pc),
    .nextpc(ftrace_nextpc),
    .jump(ftrace_jump),
    .clock(ftrace_clock)
  );
  JumpCtl jumpctl ( // @[singlecpu.scala 312:25]
    .io_ctl(jumpctl_io_ctl),
    .io_pclj(jumpctl_io_pclj),
    .io_pcrs1(jumpctl_io_pcrs1)
  );
  MemorRegMux memorregmux ( // @[singlecpu.scala 314:27]
    .io_memdata(memorregmux_io_memdata),
    .io_regdata(memorregmux_io_regdata),
    .io_memen(memorregmux_io_memen),
    .io_out(memorregmux_io_out)
  );
  DataMem datamem ( // @[singlecpu.scala 315:27]
    .addr(datamem_addr),
    .data(datamem_data),
    .wr(datamem_wr),
    .valid(datamem_valid),
    .wmask(datamem_wmask),
    .clock(datamem_clock),
    .dataout(datamem_dataout)
  );
  assign io_out = alu_io_out; // @[singlecpu.scala 378:10]
  assign io_pc = pc_io_pc; // @[singlecpu.scala 336:14]
  assign nextpc_io_pclj = jumpctl_io_pclj; // @[singlecpu.scala 333:19]
  assign nextpc_io_pcrs1 = jumpctl_io_pcrs1; // @[singlecpu.scala 334:19]
  assign nextpc_io_nowpc = pc_io_pc; // @[singlecpu.scala 331:19]
  assign nextpc_io_imm = immgen_io_out; // @[singlecpu.scala 330:19]
  assign nextpc_io_rs1 = regfile_io_rs1out; // @[singlecpu.scala 332:19]
  assign pc_clock = clock;
  assign pc_reset = reset;
  assign pc_io_pcin = nextpc_io_nextpc; // @[singlecpu.scala 337:14]
  assign source_decoder_io_inst = io_inst; // @[singlecpu.scala 339:26]
  assign immgen_io_format = source_decoder_io_format; // @[singlecpu.scala 350:20]
  assign immgen_io_inst = io_inst; // @[singlecpu.scala 351:20]
  assign regfile_clock = clock;
  assign regfile_reset = reset;
  assign regfile_io_rs1 = io_inst[19:15]; // @[singlecpu.scala 343:28]
  assign regfile_io_rs2 = io_inst[24:20]; // @[singlecpu.scala 344:28]
  assign regfile_io_rd = io_inst[11:7]; // @[singlecpu.scala 345:28]
  assign regfile_io_wr = source_decoder_io_regwr; // @[singlecpu.scala 348:21]
  assign regfile_io_datain = memorregmux_io_out; // @[singlecpu.scala 347:21]
  assign r1mux_io_r1type = source_decoder_io_s1type; // @[singlecpu.scala 356:19]
  assign r1mux_io_rs1 = regfile_io_rs1out; // @[singlecpu.scala 358:19]
  assign r1mux_io_pc = pc_io_pc; // @[singlecpu.scala 357:19]
  assign r2mux_io_r2type = source_decoder_io_s2type; // @[singlecpu.scala 360:19]
  assign r2mux_io_rs2 = regfile_io_rs2out; // @[singlecpu.scala 362:19]
  assign r2mux_io_imm = immgen_io_out; // @[singlecpu.scala 361:19]
  assign alu_clock = clock;
  assign alu_reset = reset;
  assign alu_io_s1 = r1mux_io_r1out; // @[singlecpu.scala 365:13]
  assign alu_io_s2 = r2mux_io_r2out; // @[singlecpu.scala 366:13]
  assign alu_io_op = source_decoder_io_op; // @[singlecpu.scala 364:13]
  assign endnpc_endflag = alu_io_end; // @[singlecpu.scala 353:21]
  assign endnpc_state = regfile_io_end_state; // @[singlecpu.scala 354:21]
  assign insttrace_inst = source_decoder_io_inst; // @[singlecpu.scala 368:22]
  assign insttrace_pc = pc_io_pc; // @[singlecpu.scala 369:22]
  assign insttrace_clock = clock; // @[singlecpu.scala 370:22]
  assign ftrace_inst = source_decoder_io_inst; // @[singlecpu.scala 372:20]
  assign ftrace_pc = pc_io_pc; // @[singlecpu.scala 373:20]
  assign ftrace_nextpc = nextpc_io_nextpc; // @[singlecpu.scala 374:20]
  assign ftrace_jump = source_decoder_io_ftrace; // @[singlecpu.scala 376:20]
  assign ftrace_clock = clock; // @[singlecpu.scala 375:20]
  assign jumpctl_io_ctl = source_decoder_io_jumpctl; // @[singlecpu.scala 341:18]
  assign memorregmux_io_memdata = datamem_dataout; // @[singlecpu.scala 317:26]
  assign memorregmux_io_regdata = alu_io_out; // @[singlecpu.scala 318:26]
  assign memorregmux_io_memen = source_decoder_io_tomemorreg; // @[singlecpu.scala 319:26]
  assign datamem_addr = alu_io_out; // @[singlecpu.scala 321:20]
  assign datamem_data = regfile_io_rs2out; // @[singlecpu.scala 322:20]
  assign datamem_wr = source_decoder_io_memwr; // @[singlecpu.scala 323:20]
  assign datamem_valid = source_decoder_io_memrd; // @[singlecpu.scala 326:20]
  assign datamem_wmask = source_decoder_io_memctl; // @[singlecpu.scala 324:20]
  assign datamem_clock = clock; // @[singlecpu.scala 325:20]
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
