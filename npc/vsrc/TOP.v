module PC(
  input         clock,
  input         reset,
  input  [31:0] io_pcin,
  output [31:0] io_pc
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] pc; // @[IFU.scala 11:19]
  assign io_pc = pc; // @[IFU.scala 13:9]
  always @(posedge clock) begin
    if (reset) begin // @[IFU.scala 11:19]
      pc <= 32'h80000000; // @[IFU.scala 11:19]
    end else begin
      pc <= io_pcin; // @[IFU.scala 12:9]
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
module IFU(
  input         clock,
  input         reset,
  output [31:0] io_ifu2idu_bits_inst,
  output [31:0] io_ifu2idu_bits_pc,
  input  [31:0] io_instin,
  output [31:0] io_instout,
  input  [31:0] io_pcin,
  output [31:0] io_pc
);
  wire  pc_clock; // @[IFU.scala 26:18]
  wire  pc_reset; // @[IFU.scala 26:18]
  wire [31:0] pc_io_pcin; // @[IFU.scala 26:18]
  wire [31:0] pc_io_pc; // @[IFU.scala 26:18]
  PC pc ( // @[IFU.scala 26:18]
    .clock(pc_clock),
    .reset(pc_reset),
    .io_pcin(pc_io_pcin),
    .io_pc(pc_io_pc)
  );
  assign io_ifu2idu_bits_inst = io_instin; // @[IFU.scala 32:24]
  assign io_ifu2idu_bits_pc = pc_io_pc; // @[IFU.scala 31:24]
  assign io_instout = io_instin; // @[IFU.scala 29:14]
  assign io_pc = pc_io_pc; // @[IFU.scala 28:14]
  assign pc_clock = clock;
  assign pc_reset = reset;
  assign pc_io_pcin = io_pcin; // @[IFU.scala 27:14]
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
  wire [18:0] _io_out_T_24 = io_inst[31] ? 19'h7ffff : 19'h0; // @[Bitwise.scala 77:12]
  wire [31:0] _io_out_T_29 = {_io_out_T_24,io_inst[31],io_inst[7],io_inst[30:25],io_inst[11:8],1'h0}; // @[Cat.scala 33:92]
  wire [31:0] _GEN_0 = io_format == 3'h3 ? _io_out_T_29 : 32'h0; // @[IDU.scala 25:36 28:12 30:12]
  wire [31:0] _GEN_1 = io_format == 3'h2 ? _io_out_T_21 : _GEN_0; // @[IDU.scala 23:36 24:12]
  wire [32:0] _GEN_2 = io_format == 3'h5 ? _io_out_T_15 : {{1'd0}, _GEN_1}; // @[IDU.scala 21:36 22:12]
  wire [32:0] _GEN_3 = io_format == 3'h0 ? {{1'd0}, _io_out_T_7} : _GEN_2; // @[IDU.scala 19:36 20:12]
  wire [32:0] _GEN_4 = io_format == 3'h1 ? {{1'd0}, _io_out_T_4} : _GEN_3; // @[IDU.scala 17:30 18:12]
  assign io_out = _GEN_4[31:0];
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
  output        io_regwr,
  output [2:0]  io_csrctl
);
  wire [31:0] _csignals_T = io_inst & 32'hfe00707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_1 = 32'h33 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_3 = 32'h40000033 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_5 = 32'h4033 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_7 = 32'h6033 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_9 = 32'h7033 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_11 = 32'h1033 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_13 = 32'h5033 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_15 = 32'h40005033 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_17 = 32'h2033 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_19 = 32'h3033 == _csignals_T; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_20 = io_inst & 32'h707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_21 = 32'h13 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_23 = 32'h4013 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_25 = 32'h6013 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_27 = 32'h7013 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_29 = 32'h1013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_31 = 32'h5013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_33 = 32'h40005013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_35 = 32'h2013 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_37 = 32'h3013 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_39 = 32'h67 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_41 = 32'h3 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_43 = 32'h1003 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_45 = 32'h2003 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_47 = 32'h4003 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_49 = 32'h5003 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_50 = io_inst & 32'hfff0707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_51 = 32'h100073 == _csignals_T_50; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_52 = io_inst & 32'h7f; // @[Lookup.scala 31:38]
  wire  _csignals_T_53 = 32'h37 == _csignals_T_52; // @[Lookup.scala 31:38]
  wire  _csignals_T_55 = 32'h17 == _csignals_T_52; // @[Lookup.scala 31:38]
  wire  _csignals_T_57 = 32'h6f == _csignals_T_52; // @[Lookup.scala 31:38]
  wire  _csignals_T_59 = 32'h23 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_61 = 32'h1023 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_63 = 32'h2023 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_65 = 32'h63 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_67 = 32'h1063 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_69 = 32'h4063 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_71 = 32'h5063 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_73 = 32'h6063 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_75 = 32'h7063 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_77 = 32'h0 == io_inst; // @[Lookup.scala 31:38]
  wire  _csignals_T_79 = 32'h1073 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_81 = 32'h73 == io_inst; // @[Lookup.scala 31:38]
  wire  _csignals_T_83 = 32'h2073 == _csignals_T_20; // @[Lookup.scala 31:38]
  wire  _csignals_T_85 = 32'h30200073 == io_inst; // @[Lookup.scala 31:38]
  wire [2:0] _csignals_T_86 = _csignals_T_85 ? 3'h1 : 3'h6; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_87 = _csignals_T_83 ? 3'h1 : _csignals_T_86; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_88 = _csignals_T_81 ? 3'h1 : _csignals_T_87; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_89 = _csignals_T_79 ? 3'h1 : _csignals_T_88; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_90 = _csignals_T_77 ? 3'h6 : _csignals_T_89; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_91 = _csignals_T_75 ? 3'h3 : _csignals_T_90; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_92 = _csignals_T_73 ? 3'h3 : _csignals_T_91; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_93 = _csignals_T_71 ? 3'h3 : _csignals_T_92; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_94 = _csignals_T_69 ? 3'h3 : _csignals_T_93; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_95 = _csignals_T_67 ? 3'h3 : _csignals_T_94; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_96 = _csignals_T_65 ? 3'h3 : _csignals_T_95; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_97 = _csignals_T_63 ? 3'h2 : _csignals_T_96; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_98 = _csignals_T_61 ? 3'h2 : _csignals_T_97; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_99 = _csignals_T_59 ? 3'h2 : _csignals_T_98; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_100 = _csignals_T_57 ? 3'h5 : _csignals_T_99; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_101 = _csignals_T_55 ? 3'h0 : _csignals_T_100; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_102 = _csignals_T_53 ? 3'h0 : _csignals_T_101; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_103 = _csignals_T_51 ? 3'h6 : _csignals_T_102; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_104 = _csignals_T_49 ? 3'h1 : _csignals_T_103; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_105 = _csignals_T_47 ? 3'h1 : _csignals_T_104; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_106 = _csignals_T_45 ? 3'h1 : _csignals_T_105; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_107 = _csignals_T_43 ? 3'h1 : _csignals_T_106; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_108 = _csignals_T_41 ? 3'h1 : _csignals_T_107; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_109 = _csignals_T_39 ? 3'h1 : _csignals_T_108; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_110 = _csignals_T_37 ? 3'h1 : _csignals_T_109; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_111 = _csignals_T_35 ? 3'h1 : _csignals_T_110; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_112 = _csignals_T_33 ? 3'h1 : _csignals_T_111; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_113 = _csignals_T_31 ? 3'h1 : _csignals_T_112; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_114 = _csignals_T_29 ? 3'h1 : _csignals_T_113; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_115 = _csignals_T_27 ? 3'h1 : _csignals_T_114; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_116 = _csignals_T_25 ? 3'h1 : _csignals_T_115; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_117 = _csignals_T_23 ? 3'h1 : _csignals_T_116; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_118 = _csignals_T_21 ? 3'h1 : _csignals_T_117; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_119 = _csignals_T_19 ? 3'h1 : _csignals_T_118; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_120 = _csignals_T_17 ? 3'h1 : _csignals_T_119; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_121 = _csignals_T_15 ? 3'h1 : _csignals_T_120; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_122 = _csignals_T_13 ? 3'h1 : _csignals_T_121; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_123 = _csignals_T_11 ? 3'h1 : _csignals_T_122; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_124 = _csignals_T_9 ? 3'h1 : _csignals_T_123; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_125 = _csignals_T_7 ? 3'h1 : _csignals_T_124; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_126 = _csignals_T_5 ? 3'h1 : _csignals_T_125; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_127 = _csignals_T_3 ? 3'h1 : _csignals_T_126; // @[Lookup.scala 34:39]
  wire  _csignals_T_142 = _csignals_T_57 ? 1'h0 : 1'h1; // @[Lookup.scala 34:39]
  wire  _csignals_T_143 = _csignals_T_55 ? 1'h0 : _csignals_T_142; // @[Lookup.scala 34:39]
  wire  _csignals_T_144 = _csignals_T_53 ? 1'h0 : _csignals_T_143; // @[Lookup.scala 34:39]
  wire  _csignals_T_151 = _csignals_T_39 ? 1'h0 : _csignals_T_41 | (_csignals_T_43 | (_csignals_T_45 | (_csignals_T_47
     | (_csignals_T_49 | (_csignals_T_51 | _csignals_T_144))))); // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_170 = _csignals_T_85 ? 2'h0 : 2'h1; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_171 = _csignals_T_83 ? 2'h0 : _csignals_T_170; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_172 = _csignals_T_81 ? 2'h0 : _csignals_T_171; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_173 = _csignals_T_79 ? 2'h0 : _csignals_T_172; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_174 = _csignals_T_77 ? 2'h0 : _csignals_T_173; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_175 = _csignals_T_75 ? 2'h1 : _csignals_T_174; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_176 = _csignals_T_73 ? 2'h1 : _csignals_T_175; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_177 = _csignals_T_71 ? 2'h1 : _csignals_T_176; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_178 = _csignals_T_69 ? 2'h1 : _csignals_T_177; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_179 = _csignals_T_67 ? 2'h1 : _csignals_T_178; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_180 = _csignals_T_65 ? 2'h1 : _csignals_T_179; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_181 = _csignals_T_63 ? 2'h0 : _csignals_T_180; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_182 = _csignals_T_61 ? 2'h0 : _csignals_T_181; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_183 = _csignals_T_59 ? 2'h0 : _csignals_T_182; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_184 = _csignals_T_57 ? 2'h2 : _csignals_T_183; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_185 = _csignals_T_55 ? 2'h0 : _csignals_T_184; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_186 = _csignals_T_53 ? 2'h0 : _csignals_T_185; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_187 = _csignals_T_51 ? 2'h0 : _csignals_T_186; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_188 = _csignals_T_49 ? 2'h0 : _csignals_T_187; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_189 = _csignals_T_47 ? 2'h0 : _csignals_T_188; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_190 = _csignals_T_45 ? 2'h0 : _csignals_T_189; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_191 = _csignals_T_43 ? 2'h0 : _csignals_T_190; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_192 = _csignals_T_41 ? 2'h0 : _csignals_T_191; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_193 = _csignals_T_39 ? 2'h2 : _csignals_T_192; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_194 = _csignals_T_37 ? 2'h0 : _csignals_T_193; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_195 = _csignals_T_35 ? 2'h0 : _csignals_T_194; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_196 = _csignals_T_33 ? 2'h0 : _csignals_T_195; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_197 = _csignals_T_31 ? 2'h0 : _csignals_T_196; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_198 = _csignals_T_29 ? 2'h0 : _csignals_T_197; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_199 = _csignals_T_27 ? 2'h0 : _csignals_T_198; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_200 = _csignals_T_25 ? 2'h0 : _csignals_T_199; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_201 = _csignals_T_23 ? 2'h0 : _csignals_T_200; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_202 = _csignals_T_21 ? 2'h0 : _csignals_T_201; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_203 = _csignals_T_19 ? 2'h1 : _csignals_T_202; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_204 = _csignals_T_17 ? 2'h1 : _csignals_T_203; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_205 = _csignals_T_15 ? 2'h1 : _csignals_T_204; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_206 = _csignals_T_13 ? 2'h1 : _csignals_T_205; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_207 = _csignals_T_11 ? 2'h1 : _csignals_T_206; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_208 = _csignals_T_9 ? 2'h1 : _csignals_T_207; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_209 = _csignals_T_7 ? 2'h1 : _csignals_T_208; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_210 = _csignals_T_5 ? 2'h1 : _csignals_T_209; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_211 = _csignals_T_3 ? 2'h1 : _csignals_T_210; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_217 = _csignals_T_75 ? 3'h6 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_218 = _csignals_T_73 ? 3'h5 : _csignals_T_217; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_219 = _csignals_T_71 ? 3'h6 : _csignals_T_218; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_220 = _csignals_T_69 ? 3'h5 : _csignals_T_219; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_221 = _csignals_T_67 ? 3'h4 : _csignals_T_220; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_222 = _csignals_T_65 ? 3'h3 : _csignals_T_221; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_223 = _csignals_T_63 ? 3'h0 : _csignals_T_222; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_224 = _csignals_T_61 ? 3'h0 : _csignals_T_223; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_225 = _csignals_T_59 ? 3'h0 : _csignals_T_224; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_226 = _csignals_T_57 ? 3'h1 : _csignals_T_225; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_227 = _csignals_T_55 ? 3'h0 : _csignals_T_226; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_228 = _csignals_T_53 ? 3'h0 : _csignals_T_227; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_229 = _csignals_T_51 ? 3'h0 : _csignals_T_228; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_230 = _csignals_T_49 ? 3'h0 : _csignals_T_229; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_231 = _csignals_T_47 ? 3'h0 : _csignals_T_230; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_232 = _csignals_T_45 ? 3'h0 : _csignals_T_231; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_233 = _csignals_T_43 ? 3'h0 : _csignals_T_232; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_234 = _csignals_T_41 ? 3'h0 : _csignals_T_233; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_235 = _csignals_T_39 ? 3'h2 : _csignals_T_234; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_236 = _csignals_T_37 ? 3'h0 : _csignals_T_235; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_237 = _csignals_T_35 ? 3'h0 : _csignals_T_236; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_238 = _csignals_T_33 ? 3'h0 : _csignals_T_237; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_239 = _csignals_T_31 ? 3'h0 : _csignals_T_238; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_240 = _csignals_T_29 ? 3'h0 : _csignals_T_239; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_241 = _csignals_T_27 ? 3'h0 : _csignals_T_240; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_242 = _csignals_T_25 ? 3'h0 : _csignals_T_241; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_243 = _csignals_T_23 ? 3'h0 : _csignals_T_242; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_244 = _csignals_T_21 ? 3'h0 : _csignals_T_243; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_245 = _csignals_T_19 ? 3'h0 : _csignals_T_244; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_246 = _csignals_T_17 ? 3'h0 : _csignals_T_245; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_247 = _csignals_T_15 ? 3'h0 : _csignals_T_246; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_248 = _csignals_T_13 ? 3'h0 : _csignals_T_247; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_249 = _csignals_T_11 ? 3'h0 : _csignals_T_248; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_250 = _csignals_T_9 ? 3'h0 : _csignals_T_249; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_251 = _csignals_T_7 ? 3'h0 : _csignals_T_250; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_252 = _csignals_T_5 ? 3'h0 : _csignals_T_251; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_253 = _csignals_T_3 ? 3'h0 : _csignals_T_252; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_254 = _csignals_T_85 ? 4'he : 4'hc; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_255 = _csignals_T_83 ? 4'he : _csignals_T_254; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_256 = _csignals_T_81 ? 4'he : _csignals_T_255; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_257 = _csignals_T_79 ? 4'he : _csignals_T_256; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_258 = _csignals_T_77 ? 4'he : _csignals_T_257; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_259 = _csignals_T_75 ? 4'h3 : _csignals_T_258; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_260 = _csignals_T_73 ? 4'h3 : _csignals_T_259; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_261 = _csignals_T_71 ? 4'h2 : _csignals_T_260; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_262 = _csignals_T_69 ? 4'h2 : _csignals_T_261; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_263 = _csignals_T_67 ? 4'h2 : _csignals_T_262; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_264 = _csignals_T_65 ? 4'h2 : _csignals_T_263; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_265 = _csignals_T_63 ? 4'h0 : _csignals_T_264; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_266 = _csignals_T_61 ? 4'h0 : _csignals_T_265; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_267 = _csignals_T_59 ? 4'h0 : _csignals_T_266; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_268 = _csignals_T_57 ? 4'h0 : _csignals_T_267; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_269 = _csignals_T_55 ? 4'h0 : _csignals_T_268; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_270 = _csignals_T_53 ? 4'h9 : _csignals_T_269; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_271 = _csignals_T_51 ? 4'hf : _csignals_T_270; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_272 = _csignals_T_49 ? 4'h0 : _csignals_T_271; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_273 = _csignals_T_47 ? 4'h0 : _csignals_T_272; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_274 = _csignals_T_45 ? 4'h0 : _csignals_T_273; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_275 = _csignals_T_43 ? 4'h0 : _csignals_T_274; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_276 = _csignals_T_41 ? 4'h0 : _csignals_T_275; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_277 = _csignals_T_39 ? 4'h0 : _csignals_T_276; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_278 = _csignals_T_37 ? 4'h3 : _csignals_T_277; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_279 = _csignals_T_35 ? 4'h2 : _csignals_T_278; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_280 = _csignals_T_33 ? 4'hd : _csignals_T_279; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_281 = _csignals_T_31 ? 4'h5 : _csignals_T_280; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_282 = _csignals_T_29 ? 4'h1 : _csignals_T_281; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_283 = _csignals_T_27 ? 4'h7 : _csignals_T_282; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_284 = _csignals_T_25 ? 4'h6 : _csignals_T_283; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_285 = _csignals_T_23 ? 4'h4 : _csignals_T_284; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_286 = _csignals_T_21 ? 4'h0 : _csignals_T_285; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_287 = _csignals_T_19 ? 4'h3 : _csignals_T_286; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_288 = _csignals_T_17 ? 4'h2 : _csignals_T_287; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_289 = _csignals_T_15 ? 4'hd : _csignals_T_288; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_290 = _csignals_T_13 ? 4'h5 : _csignals_T_289; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_291 = _csignals_T_11 ? 4'h1 : _csignals_T_290; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_292 = _csignals_T_9 ? 4'h7 : _csignals_T_291; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_293 = _csignals_T_7 ? 4'h6 : _csignals_T_292; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_294 = _csignals_T_5 ? 4'h4 : _csignals_T_293; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_295 = _csignals_T_3 ? 4'h8 : _csignals_T_294; // @[Lookup.scala 34:39]
  wire  _csignals_T_307 = _csignals_T_63 ? 1'h0 : _csignals_T_65 | (_csignals_T_67 | (_csignals_T_69 | (_csignals_T_71
     | (_csignals_T_73 | _csignals_T_75)))); // @[Lookup.scala 34:39]
  wire  _csignals_T_308 = _csignals_T_61 ? 1'h0 : _csignals_T_307; // @[Lookup.scala 34:39]
  wire  _csignals_T_309 = _csignals_T_59 ? 1'h0 : _csignals_T_308; // @[Lookup.scala 34:39]
  wire  _csignals_T_311 = _csignals_T_55 ? 1'h0 : _csignals_T_57 | _csignals_T_309; // @[Lookup.scala 34:39]
  wire  _csignals_T_312 = _csignals_T_53 ? 1'h0 : _csignals_T_311; // @[Lookup.scala 34:39]
  wire  _csignals_T_313 = _csignals_T_51 ? 1'h0 : _csignals_T_312; // @[Lookup.scala 34:39]
  wire  _csignals_T_314 = _csignals_T_49 ? 1'h0 : _csignals_T_313; // @[Lookup.scala 34:39]
  wire  _csignals_T_315 = _csignals_T_47 ? 1'h0 : _csignals_T_314; // @[Lookup.scala 34:39]
  wire  _csignals_T_316 = _csignals_T_45 ? 1'h0 : _csignals_T_315; // @[Lookup.scala 34:39]
  wire  _csignals_T_317 = _csignals_T_43 ? 1'h0 : _csignals_T_316; // @[Lookup.scala 34:39]
  wire  _csignals_T_318 = _csignals_T_41 ? 1'h0 : _csignals_T_317; // @[Lookup.scala 34:39]
  wire  _csignals_T_320 = _csignals_T_37 ? 1'h0 : _csignals_T_39 | _csignals_T_318; // @[Lookup.scala 34:39]
  wire  _csignals_T_321 = _csignals_T_35 ? 1'h0 : _csignals_T_320; // @[Lookup.scala 34:39]
  wire  _csignals_T_322 = _csignals_T_33 ? 1'h0 : _csignals_T_321; // @[Lookup.scala 34:39]
  wire  _csignals_T_323 = _csignals_T_31 ? 1'h0 : _csignals_T_322; // @[Lookup.scala 34:39]
  wire  _csignals_T_324 = _csignals_T_29 ? 1'h0 : _csignals_T_323; // @[Lookup.scala 34:39]
  wire  _csignals_T_325 = _csignals_T_27 ? 1'h0 : _csignals_T_324; // @[Lookup.scala 34:39]
  wire  _csignals_T_326 = _csignals_T_25 ? 1'h0 : _csignals_T_325; // @[Lookup.scala 34:39]
  wire  _csignals_T_327 = _csignals_T_23 ? 1'h0 : _csignals_T_326; // @[Lookup.scala 34:39]
  wire  _csignals_T_328 = _csignals_T_21 ? 1'h0 : _csignals_T_327; // @[Lookup.scala 34:39]
  wire  _csignals_T_329 = _csignals_T_19 ? 1'h0 : _csignals_T_328; // @[Lookup.scala 34:39]
  wire  _csignals_T_330 = _csignals_T_17 ? 1'h0 : _csignals_T_329; // @[Lookup.scala 34:39]
  wire  _csignals_T_331 = _csignals_T_15 ? 1'h0 : _csignals_T_330; // @[Lookup.scala 34:39]
  wire  _csignals_T_332 = _csignals_T_13 ? 1'h0 : _csignals_T_331; // @[Lookup.scala 34:39]
  wire  _csignals_T_333 = _csignals_T_11 ? 1'h0 : _csignals_T_332; // @[Lookup.scala 34:39]
  wire  _csignals_T_334 = _csignals_T_9 ? 1'h0 : _csignals_T_333; // @[Lookup.scala 34:39]
  wire  _csignals_T_335 = _csignals_T_7 ? 1'h0 : _csignals_T_334; // @[Lookup.scala 34:39]
  wire  _csignals_T_336 = _csignals_T_5 ? 1'h0 : _csignals_T_335; // @[Lookup.scala 34:39]
  wire  _csignals_T_337 = _csignals_T_3 ? 1'h0 : _csignals_T_336; // @[Lookup.scala 34:39]
  wire  _csignals_T_352 = _csignals_T_57 ? 1'h0 : _csignals_T_59 | (_csignals_T_61 | _csignals_T_63); // @[Lookup.scala 34:39]
  wire  _csignals_T_353 = _csignals_T_55 ? 1'h0 : _csignals_T_352; // @[Lookup.scala 34:39]
  wire  _csignals_T_354 = _csignals_T_53 ? 1'h0 : _csignals_T_353; // @[Lookup.scala 34:39]
  wire  _csignals_T_355 = _csignals_T_51 ? 1'h0 : _csignals_T_354; // @[Lookup.scala 34:39]
  wire  _csignals_T_356 = _csignals_T_49 ? 1'h0 : _csignals_T_355; // @[Lookup.scala 34:39]
  wire  _csignals_T_357 = _csignals_T_47 ? 1'h0 : _csignals_T_356; // @[Lookup.scala 34:39]
  wire  _csignals_T_358 = _csignals_T_45 ? 1'h0 : _csignals_T_357; // @[Lookup.scala 34:39]
  wire  _csignals_T_359 = _csignals_T_43 ? 1'h0 : _csignals_T_358; // @[Lookup.scala 34:39]
  wire  _csignals_T_360 = _csignals_T_41 ? 1'h0 : _csignals_T_359; // @[Lookup.scala 34:39]
  wire  _csignals_T_361 = _csignals_T_39 ? 1'h0 : _csignals_T_360; // @[Lookup.scala 34:39]
  wire  _csignals_T_362 = _csignals_T_37 ? 1'h0 : _csignals_T_361; // @[Lookup.scala 34:39]
  wire  _csignals_T_363 = _csignals_T_35 ? 1'h0 : _csignals_T_362; // @[Lookup.scala 34:39]
  wire  _csignals_T_364 = _csignals_T_33 ? 1'h0 : _csignals_T_363; // @[Lookup.scala 34:39]
  wire  _csignals_T_365 = _csignals_T_31 ? 1'h0 : _csignals_T_364; // @[Lookup.scala 34:39]
  wire  _csignals_T_366 = _csignals_T_29 ? 1'h0 : _csignals_T_365; // @[Lookup.scala 34:39]
  wire  _csignals_T_367 = _csignals_T_27 ? 1'h0 : _csignals_T_366; // @[Lookup.scala 34:39]
  wire  _csignals_T_368 = _csignals_T_25 ? 1'h0 : _csignals_T_367; // @[Lookup.scala 34:39]
  wire  _csignals_T_369 = _csignals_T_23 ? 1'h0 : _csignals_T_368; // @[Lookup.scala 34:39]
  wire  _csignals_T_370 = _csignals_T_21 ? 1'h0 : _csignals_T_369; // @[Lookup.scala 34:39]
  wire  _csignals_T_371 = _csignals_T_19 ? 1'h0 : _csignals_T_370; // @[Lookup.scala 34:39]
  wire  _csignals_T_372 = _csignals_T_17 ? 1'h0 : _csignals_T_371; // @[Lookup.scala 34:39]
  wire  _csignals_T_373 = _csignals_T_15 ? 1'h0 : _csignals_T_372; // @[Lookup.scala 34:39]
  wire  _csignals_T_374 = _csignals_T_13 ? 1'h0 : _csignals_T_373; // @[Lookup.scala 34:39]
  wire  _csignals_T_375 = _csignals_T_11 ? 1'h0 : _csignals_T_374; // @[Lookup.scala 34:39]
  wire  _csignals_T_376 = _csignals_T_9 ? 1'h0 : _csignals_T_375; // @[Lookup.scala 34:39]
  wire  _csignals_T_377 = _csignals_T_7 ? 1'h0 : _csignals_T_376; // @[Lookup.scala 34:39]
  wire  _csignals_T_378 = _csignals_T_5 ? 1'h0 : _csignals_T_377; // @[Lookup.scala 34:39]
  wire  _csignals_T_379 = _csignals_T_3 ? 1'h0 : _csignals_T_378; // @[Lookup.scala 34:39]
  wire  _csignals_T_403 = _csignals_T_39 ? 1'h0 : _csignals_T_41 | (_csignals_T_43 | (_csignals_T_45 | (_csignals_T_47
     | (_csignals_T_49 | _csignals_T_51)))); // @[Lookup.scala 34:39]
  wire  _csignals_T_404 = _csignals_T_37 ? 1'h0 : _csignals_T_403; // @[Lookup.scala 34:39]
  wire  _csignals_T_405 = _csignals_T_35 ? 1'h0 : _csignals_T_404; // @[Lookup.scala 34:39]
  wire  _csignals_T_406 = _csignals_T_33 ? 1'h0 : _csignals_T_405; // @[Lookup.scala 34:39]
  wire  _csignals_T_407 = _csignals_T_31 ? 1'h0 : _csignals_T_406; // @[Lookup.scala 34:39]
  wire  _csignals_T_408 = _csignals_T_29 ? 1'h0 : _csignals_T_407; // @[Lookup.scala 34:39]
  wire  _csignals_T_409 = _csignals_T_27 ? 1'h0 : _csignals_T_408; // @[Lookup.scala 34:39]
  wire  _csignals_T_410 = _csignals_T_25 ? 1'h0 : _csignals_T_409; // @[Lookup.scala 34:39]
  wire  _csignals_T_411 = _csignals_T_23 ? 1'h0 : _csignals_T_410; // @[Lookup.scala 34:39]
  wire  _csignals_T_412 = _csignals_T_21 ? 1'h0 : _csignals_T_411; // @[Lookup.scala 34:39]
  wire  _csignals_T_413 = _csignals_T_19 ? 1'h0 : _csignals_T_412; // @[Lookup.scala 34:39]
  wire  _csignals_T_414 = _csignals_T_17 ? 1'h0 : _csignals_T_413; // @[Lookup.scala 34:39]
  wire  _csignals_T_415 = _csignals_T_15 ? 1'h0 : _csignals_T_414; // @[Lookup.scala 34:39]
  wire  _csignals_T_416 = _csignals_T_13 ? 1'h0 : _csignals_T_415; // @[Lookup.scala 34:39]
  wire  _csignals_T_417 = _csignals_T_11 ? 1'h0 : _csignals_T_416; // @[Lookup.scala 34:39]
  wire  _csignals_T_418 = _csignals_T_9 ? 1'h0 : _csignals_T_417; // @[Lookup.scala 34:39]
  wire  _csignals_T_419 = _csignals_T_7 ? 1'h0 : _csignals_T_418; // @[Lookup.scala 34:39]
  wire  _csignals_T_420 = _csignals_T_5 ? 1'h0 : _csignals_T_419; // @[Lookup.scala 34:39]
  wire  _csignals_T_421 = _csignals_T_3 ? 1'h0 : _csignals_T_420; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_433 = _csignals_T_63 ? 3'h2 : 3'h7; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_434 = _csignals_T_61 ? 3'h1 : _csignals_T_433; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_435 = _csignals_T_59 ? 3'h0 : _csignals_T_434; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_436 = _csignals_T_57 ? 3'h7 : _csignals_T_435; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_437 = _csignals_T_55 ? 3'h7 : _csignals_T_436; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_438 = _csignals_T_53 ? 3'h7 : _csignals_T_437; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_439 = _csignals_T_51 ? 3'h2 : _csignals_T_438; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_440 = _csignals_T_49 ? 3'h5 : _csignals_T_439; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_441 = _csignals_T_47 ? 3'h4 : _csignals_T_440; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_442 = _csignals_T_45 ? 3'h2 : _csignals_T_441; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_443 = _csignals_T_43 ? 3'h1 : _csignals_T_442; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_444 = _csignals_T_41 ? 3'h0 : _csignals_T_443; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_445 = _csignals_T_39 ? 3'h7 : _csignals_T_444; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_446 = _csignals_T_37 ? 3'h7 : _csignals_T_445; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_447 = _csignals_T_35 ? 3'h7 : _csignals_T_446; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_448 = _csignals_T_33 ? 3'h7 : _csignals_T_447; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_449 = _csignals_T_31 ? 3'h7 : _csignals_T_448; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_450 = _csignals_T_29 ? 3'h7 : _csignals_T_449; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_451 = _csignals_T_27 ? 3'h7 : _csignals_T_450; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_452 = _csignals_T_25 ? 3'h7 : _csignals_T_451; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_453 = _csignals_T_23 ? 3'h7 : _csignals_T_452; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_454 = _csignals_T_21 ? 3'h7 : _csignals_T_453; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_455 = _csignals_T_19 ? 3'h7 : _csignals_T_454; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_456 = _csignals_T_17 ? 3'h7 : _csignals_T_455; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_457 = _csignals_T_15 ? 3'h7 : _csignals_T_456; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_458 = _csignals_T_13 ? 3'h7 : _csignals_T_457; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_459 = _csignals_T_11 ? 3'h7 : _csignals_T_458; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_460 = _csignals_T_9 ? 3'h7 : _csignals_T_459; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_461 = _csignals_T_7 ? 3'h7 : _csignals_T_460; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_462 = _csignals_T_5 ? 3'h7 : _csignals_T_461; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_463 = _csignals_T_3 ? 3'h7 : _csignals_T_462; // @[Lookup.scala 34:39]
  wire  _csignals_T_466 = _csignals_T_81 ? 1'h0 : _csignals_T_83; // @[Lookup.scala 34:39]
  wire  _csignals_T_468 = _csignals_T_77 ? 1'h0 : _csignals_T_79 | _csignals_T_466; // @[Lookup.scala 34:39]
  wire  _csignals_T_469 = _csignals_T_75 ? 1'h0 : _csignals_T_468; // @[Lookup.scala 34:39]
  wire  _csignals_T_470 = _csignals_T_73 ? 1'h0 : _csignals_T_469; // @[Lookup.scala 34:39]
  wire  _csignals_T_471 = _csignals_T_71 ? 1'h0 : _csignals_T_470; // @[Lookup.scala 34:39]
  wire  _csignals_T_472 = _csignals_T_69 ? 1'h0 : _csignals_T_471; // @[Lookup.scala 34:39]
  wire  _csignals_T_473 = _csignals_T_67 ? 1'h0 : _csignals_T_472; // @[Lookup.scala 34:39]
  wire  _csignals_T_474 = _csignals_T_65 ? 1'h0 : _csignals_T_473; // @[Lookup.scala 34:39]
  wire  _csignals_T_475 = _csignals_T_63 ? 1'h0 : _csignals_T_474; // @[Lookup.scala 34:39]
  wire  _csignals_T_476 = _csignals_T_61 ? 1'h0 : _csignals_T_475; // @[Lookup.scala 34:39]
  wire  _csignals_T_477 = _csignals_T_59 ? 1'h0 : _csignals_T_476; // @[Lookup.scala 34:39]
  wire  _csignals_T_529 = _csignals_T_39 ? 1'h0 : _csignals_T_41 | (_csignals_T_43 | (_csignals_T_45 | (_csignals_T_47
     | (_csignals_T_49 | (_csignals_T_51 | _csignals_T_354))))); // @[Lookup.scala 34:39]
  wire  _csignals_T_530 = _csignals_T_37 ? 1'h0 : _csignals_T_529; // @[Lookup.scala 34:39]
  wire  _csignals_T_531 = _csignals_T_35 ? 1'h0 : _csignals_T_530; // @[Lookup.scala 34:39]
  wire  _csignals_T_532 = _csignals_T_33 ? 1'h0 : _csignals_T_531; // @[Lookup.scala 34:39]
  wire  _csignals_T_533 = _csignals_T_31 ? 1'h0 : _csignals_T_532; // @[Lookup.scala 34:39]
  wire  _csignals_T_534 = _csignals_T_29 ? 1'h0 : _csignals_T_533; // @[Lookup.scala 34:39]
  wire  _csignals_T_535 = _csignals_T_27 ? 1'h0 : _csignals_T_534; // @[Lookup.scala 34:39]
  wire  _csignals_T_536 = _csignals_T_25 ? 1'h0 : _csignals_T_535; // @[Lookup.scala 34:39]
  wire  _csignals_T_537 = _csignals_T_23 ? 1'h0 : _csignals_T_536; // @[Lookup.scala 34:39]
  wire  _csignals_T_538 = _csignals_T_21 ? 1'h0 : _csignals_T_537; // @[Lookup.scala 34:39]
  wire  _csignals_T_539 = _csignals_T_19 ? 1'h0 : _csignals_T_538; // @[Lookup.scala 34:39]
  wire  _csignals_T_540 = _csignals_T_17 ? 1'h0 : _csignals_T_539; // @[Lookup.scala 34:39]
  wire  _csignals_T_541 = _csignals_T_15 ? 1'h0 : _csignals_T_540; // @[Lookup.scala 34:39]
  wire  _csignals_T_542 = _csignals_T_13 ? 1'h0 : _csignals_T_541; // @[Lookup.scala 34:39]
  wire  _csignals_T_543 = _csignals_T_11 ? 1'h0 : _csignals_T_542; // @[Lookup.scala 34:39]
  wire  _csignals_T_544 = _csignals_T_9 ? 1'h0 : _csignals_T_543; // @[Lookup.scala 34:39]
  wire  _csignals_T_545 = _csignals_T_7 ? 1'h0 : _csignals_T_544; // @[Lookup.scala 34:39]
  wire  _csignals_T_546 = _csignals_T_5 ? 1'h0 : _csignals_T_545; // @[Lookup.scala 34:39]
  wire  _csignals_T_547 = _csignals_T_3 ? 1'h0 : _csignals_T_546; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_548 = _csignals_T_85 ? 3'h5 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_549 = _csignals_T_83 ? 3'h2 : _csignals_T_548; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_550 = _csignals_T_81 ? 3'h4 : _csignals_T_549; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_551 = _csignals_T_79 ? 3'h1 : _csignals_T_550; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_552 = _csignals_T_77 ? 3'h0 : _csignals_T_551; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_553 = _csignals_T_75 ? 3'h0 : _csignals_T_552; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_554 = _csignals_T_73 ? 3'h0 : _csignals_T_553; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_555 = _csignals_T_71 ? 3'h0 : _csignals_T_554; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_556 = _csignals_T_69 ? 3'h0 : _csignals_T_555; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_557 = _csignals_T_67 ? 3'h0 : _csignals_T_556; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_558 = _csignals_T_65 ? 3'h0 : _csignals_T_557; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_559 = _csignals_T_63 ? 3'h0 : _csignals_T_558; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_560 = _csignals_T_61 ? 3'h0 : _csignals_T_559; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_561 = _csignals_T_59 ? 3'h0 : _csignals_T_560; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_562 = _csignals_T_57 ? 3'h0 : _csignals_T_561; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_563 = _csignals_T_55 ? 3'h0 : _csignals_T_562; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_564 = _csignals_T_53 ? 3'h0 : _csignals_T_563; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_565 = _csignals_T_51 ? 3'h0 : _csignals_T_564; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_566 = _csignals_T_49 ? 3'h0 : _csignals_T_565; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_567 = _csignals_T_47 ? 3'h0 : _csignals_T_566; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_568 = _csignals_T_45 ? 3'h0 : _csignals_T_567; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_569 = _csignals_T_43 ? 3'h0 : _csignals_T_568; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_570 = _csignals_T_41 ? 3'h0 : _csignals_T_569; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_571 = _csignals_T_39 ? 3'h0 : _csignals_T_570; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_572 = _csignals_T_37 ? 3'h0 : _csignals_T_571; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_573 = _csignals_T_35 ? 3'h0 : _csignals_T_572; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_574 = _csignals_T_33 ? 3'h0 : _csignals_T_573; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_575 = _csignals_T_31 ? 3'h0 : _csignals_T_574; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_576 = _csignals_T_29 ? 3'h0 : _csignals_T_575; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_577 = _csignals_T_27 ? 3'h0 : _csignals_T_576; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_578 = _csignals_T_25 ? 3'h0 : _csignals_T_577; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_579 = _csignals_T_23 ? 3'h0 : _csignals_T_578; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_580 = _csignals_T_21 ? 3'h0 : _csignals_T_579; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_581 = _csignals_T_19 ? 3'h0 : _csignals_T_580; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_582 = _csignals_T_17 ? 3'h0 : _csignals_T_581; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_583 = _csignals_T_15 ? 3'h0 : _csignals_T_582; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_584 = _csignals_T_13 ? 3'h0 : _csignals_T_583; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_585 = _csignals_T_11 ? 3'h0 : _csignals_T_584; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_586 = _csignals_T_9 ? 3'h0 : _csignals_T_585; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_587 = _csignals_T_7 ? 3'h0 : _csignals_T_586; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_588 = _csignals_T_5 ? 3'h0 : _csignals_T_587; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_589 = _csignals_T_3 ? 3'h0 : _csignals_T_588; // @[Lookup.scala 34:39]
  assign io_format = _csignals_T_1 ? 3'h1 : _csignals_T_127; // @[Lookup.scala 34:39]
  assign io_s1type = _csignals_T_1 | (_csignals_T_3 | (_csignals_T_5 | (_csignals_T_7 | (_csignals_T_9 | (_csignals_T_11
     | (_csignals_T_13 | (_csignals_T_15 | (_csignals_T_17 | (_csignals_T_19 | (_csignals_T_21 | (_csignals_T_23 | (
    _csignals_T_25 | (_csignals_T_27 | (_csignals_T_29 | (_csignals_T_31 | (_csignals_T_33 | (_csignals_T_35 | (
    _csignals_T_37 | _csignals_T_151)))))))))))))))))); // @[Lookup.scala 34:39]
  assign io_s2type = _csignals_T_1 ? 2'h1 : _csignals_T_211; // @[Lookup.scala 34:39]
  assign io_jumpctl = _csignals_T_1 ? 3'h0 : _csignals_T_253; // @[Lookup.scala 34:39]
  assign io_op = _csignals_T_1 ? 4'h0 : _csignals_T_295; // @[Lookup.scala 34:39]
  assign io_ftrace = _csignals_T_1 ? 1'h0 : _csignals_T_337; // @[Lookup.scala 34:39]
  assign io_memrd = _csignals_T_1 ? 1'h0 : _csignals_T_547; // @[Lookup.scala 34:39]
  assign io_memwr = _csignals_T_1 ? 1'h0 : _csignals_T_379; // @[Lookup.scala 34:39]
  assign io_memctl = _csignals_T_1 ? 3'h7 : _csignals_T_463; // @[Lookup.scala 34:39]
  assign io_tomemorreg = _csignals_T_1 ? 1'h0 : _csignals_T_421; // @[Lookup.scala 34:39]
  assign io_regwr = _csignals_T_1 | (_csignals_T_3 | (_csignals_T_5 | (_csignals_T_7 | (_csignals_T_9 | (_csignals_T_11
     | (_csignals_T_13 | (_csignals_T_15 | (_csignals_T_17 | (_csignals_T_19 | (_csignals_T_21 | (_csignals_T_23 | (
    _csignals_T_25 | (_csignals_T_27 | (_csignals_T_29 | (_csignals_T_31 | (_csignals_T_33 | (_csignals_T_35 | (
    _csignals_T_37 | (_csignals_T_39 | (_csignals_T_41 | (_csignals_T_43 | (_csignals_T_45 | (_csignals_T_47 | (
    _csignals_T_49 | (_csignals_T_51 | (_csignals_T_53 | (_csignals_T_55 | (_csignals_T_57 | _csignals_T_477))))))))))))
    )))))))))))))))); // @[Lookup.scala 34:39]
  assign io_csrctl = _csignals_T_1 ? 3'h0 : _csignals_T_589; // @[Lookup.scala 34:39]
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
  reg [31:0] regfile_0; // @[IDU.scala 48:24]
  reg [31:0] regfile_1; // @[IDU.scala 48:24]
  reg [31:0] regfile_2; // @[IDU.scala 48:24]
  reg [31:0] regfile_3; // @[IDU.scala 48:24]
  reg [31:0] regfile_4; // @[IDU.scala 48:24]
  reg [31:0] regfile_5; // @[IDU.scala 48:24]
  reg [31:0] regfile_6; // @[IDU.scala 48:24]
  reg [31:0] regfile_7; // @[IDU.scala 48:24]
  reg [31:0] regfile_8; // @[IDU.scala 48:24]
  reg [31:0] regfile_9; // @[IDU.scala 48:24]
  reg [31:0] regfile_10; // @[IDU.scala 48:24]
  reg [31:0] regfile_11; // @[IDU.scala 48:24]
  reg [31:0] regfile_12; // @[IDU.scala 48:24]
  reg [31:0] regfile_13; // @[IDU.scala 48:24]
  reg [31:0] regfile_14; // @[IDU.scala 48:24]
  reg [31:0] regfile_15; // @[IDU.scala 48:24]
  reg [31:0] regfile_16; // @[IDU.scala 48:24]
  reg [31:0] regfile_17; // @[IDU.scala 48:24]
  reg [31:0] regfile_18; // @[IDU.scala 48:24]
  reg [31:0] regfile_19; // @[IDU.scala 48:24]
  reg [31:0] regfile_20; // @[IDU.scala 48:24]
  reg [31:0] regfile_21; // @[IDU.scala 48:24]
  reg [31:0] regfile_22; // @[IDU.scala 48:24]
  reg [31:0] regfile_23; // @[IDU.scala 48:24]
  reg [31:0] regfile_24; // @[IDU.scala 48:24]
  reg [31:0] regfile_25; // @[IDU.scala 48:24]
  reg [31:0] regfile_26; // @[IDU.scala 48:24]
  reg [31:0] regfile_27; // @[IDU.scala 48:24]
  reg [31:0] regfile_28; // @[IDU.scala 48:24]
  reg [31:0] regfile_29; // @[IDU.scala 48:24]
  reg [31:0] regfile_30; // @[IDU.scala 48:24]
  reg [31:0] regfile_31; // @[IDU.scala 48:24]
  wire [31:0] _GEN_65 = 5'h1 == io_rs1 ? regfile_1 : regfile_0; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_66 = 5'h2 == io_rs1 ? regfile_2 : _GEN_65; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_67 = 5'h3 == io_rs1 ? regfile_3 : _GEN_66; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_68 = 5'h4 == io_rs1 ? regfile_4 : _GEN_67; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_69 = 5'h5 == io_rs1 ? regfile_5 : _GEN_68; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_70 = 5'h6 == io_rs1 ? regfile_6 : _GEN_69; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_71 = 5'h7 == io_rs1 ? regfile_7 : _GEN_70; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_72 = 5'h8 == io_rs1 ? regfile_8 : _GEN_71; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_73 = 5'h9 == io_rs1 ? regfile_9 : _GEN_72; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_74 = 5'ha == io_rs1 ? regfile_10 : _GEN_73; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_75 = 5'hb == io_rs1 ? regfile_11 : _GEN_74; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_76 = 5'hc == io_rs1 ? regfile_12 : _GEN_75; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_77 = 5'hd == io_rs1 ? regfile_13 : _GEN_76; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_78 = 5'he == io_rs1 ? regfile_14 : _GEN_77; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_79 = 5'hf == io_rs1 ? regfile_15 : _GEN_78; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_80 = 5'h10 == io_rs1 ? regfile_16 : _GEN_79; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_81 = 5'h11 == io_rs1 ? regfile_17 : _GEN_80; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_82 = 5'h12 == io_rs1 ? regfile_18 : _GEN_81; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_83 = 5'h13 == io_rs1 ? regfile_19 : _GEN_82; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_84 = 5'h14 == io_rs1 ? regfile_20 : _GEN_83; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_85 = 5'h15 == io_rs1 ? regfile_21 : _GEN_84; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_86 = 5'h16 == io_rs1 ? regfile_22 : _GEN_85; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_87 = 5'h17 == io_rs1 ? regfile_23 : _GEN_86; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_88 = 5'h18 == io_rs1 ? regfile_24 : _GEN_87; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_89 = 5'h19 == io_rs1 ? regfile_25 : _GEN_88; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_90 = 5'h1a == io_rs1 ? regfile_26 : _GEN_89; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_91 = 5'h1b == io_rs1 ? regfile_27 : _GEN_90; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_92 = 5'h1c == io_rs1 ? regfile_28 : _GEN_91; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_93 = 5'h1d == io_rs1 ? regfile_29 : _GEN_92; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_94 = 5'h1e == io_rs1 ? regfile_30 : _GEN_93; // @[IDU.scala 56:{13,13}]
  wire [31:0] _GEN_97 = 5'h1 == io_rs2 ? regfile_1 : regfile_0; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_98 = 5'h2 == io_rs2 ? regfile_2 : _GEN_97; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_99 = 5'h3 == io_rs2 ? regfile_3 : _GEN_98; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_100 = 5'h4 == io_rs2 ? regfile_4 : _GEN_99; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_101 = 5'h5 == io_rs2 ? regfile_5 : _GEN_100; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_102 = 5'h6 == io_rs2 ? regfile_6 : _GEN_101; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_103 = 5'h7 == io_rs2 ? regfile_7 : _GEN_102; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_104 = 5'h8 == io_rs2 ? regfile_8 : _GEN_103; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_105 = 5'h9 == io_rs2 ? regfile_9 : _GEN_104; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_106 = 5'ha == io_rs2 ? regfile_10 : _GEN_105; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_107 = 5'hb == io_rs2 ? regfile_11 : _GEN_106; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_108 = 5'hc == io_rs2 ? regfile_12 : _GEN_107; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_109 = 5'hd == io_rs2 ? regfile_13 : _GEN_108; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_110 = 5'he == io_rs2 ? regfile_14 : _GEN_109; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_111 = 5'hf == io_rs2 ? regfile_15 : _GEN_110; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_112 = 5'h10 == io_rs2 ? regfile_16 : _GEN_111; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_113 = 5'h11 == io_rs2 ? regfile_17 : _GEN_112; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_114 = 5'h12 == io_rs2 ? regfile_18 : _GEN_113; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_115 = 5'h13 == io_rs2 ? regfile_19 : _GEN_114; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_116 = 5'h14 == io_rs2 ? regfile_20 : _GEN_115; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_117 = 5'h15 == io_rs2 ? regfile_21 : _GEN_116; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_118 = 5'h16 == io_rs2 ? regfile_22 : _GEN_117; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_119 = 5'h17 == io_rs2 ? regfile_23 : _GEN_118; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_120 = 5'h18 == io_rs2 ? regfile_24 : _GEN_119; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_121 = 5'h19 == io_rs2 ? regfile_25 : _GEN_120; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_122 = 5'h1a == io_rs2 ? regfile_26 : _GEN_121; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_123 = 5'h1b == io_rs2 ? regfile_27 : _GEN_122; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_124 = 5'h1c == io_rs2 ? regfile_28 : _GEN_123; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_125 = 5'h1d == io_rs2 ? regfile_29 : _GEN_124; // @[IDU.scala 57:{13,13}]
  wire [31:0] _GEN_126 = 5'h1e == io_rs2 ? regfile_30 : _GEN_125; // @[IDU.scala 57:{13,13}]
  assign io_rs1out = 5'h1f == io_rs1 ? regfile_31 : _GEN_94; // @[IDU.scala 56:{13,13}]
  assign io_rs2out = 5'h1f == io_rs2 ? regfile_31 : _GEN_126; // @[IDU.scala 57:{13,13}]
  assign io_end_state = regfile_10; // @[IDU.scala 49:16]
  always @(posedge clock) begin
    if (reset) begin // @[IDU.scala 48:24]
      regfile_0 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h0 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_0 <= 32'h0;
        end else begin
          regfile_0 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_1 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h1 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_1 <= 32'h0;
        end else begin
          regfile_1 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_2 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h2 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_2 <= 32'h0;
        end else begin
          regfile_2 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_3 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h3 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_3 <= 32'h0;
        end else begin
          regfile_3 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_4 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h4 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_4 <= 32'h0;
        end else begin
          regfile_4 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_5 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h5 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_5 <= 32'h0;
        end else begin
          regfile_5 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_6 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h6 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_6 <= 32'h0;
        end else begin
          regfile_6 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_7 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h7 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_7 <= 32'h0;
        end else begin
          regfile_7 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_8 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h8 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_8 <= 32'h0;
        end else begin
          regfile_8 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_9 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h9 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_9 <= 32'h0;
        end else begin
          regfile_9 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_10 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'ha == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_10 <= 32'h0;
        end else begin
          regfile_10 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_11 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'hb == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_11 <= 32'h0;
        end else begin
          regfile_11 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_12 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'hc == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_12 <= 32'h0;
        end else begin
          regfile_12 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_13 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'hd == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_13 <= 32'h0;
        end else begin
          regfile_13 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_14 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'he == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_14 <= 32'h0;
        end else begin
          regfile_14 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_15 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'hf == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_15 <= 32'h0;
        end else begin
          regfile_15 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_16 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h10 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_16 <= 32'h0;
        end else begin
          regfile_16 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_17 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h11 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_17 <= 32'h0;
        end else begin
          regfile_17 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_18 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h12 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_18 <= 32'h0;
        end else begin
          regfile_18 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_19 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h13 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_19 <= 32'h0;
        end else begin
          regfile_19 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_20 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h14 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_20 <= 32'h0;
        end else begin
          regfile_20 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_21 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h15 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_21 <= 32'h0;
        end else begin
          regfile_21 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_22 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h16 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_22 <= 32'h0;
        end else begin
          regfile_22 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_23 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h17 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_23 <= 32'h0;
        end else begin
          regfile_23 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_24 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h18 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_24 <= 32'h0;
        end else begin
          regfile_24 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_25 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h19 == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_25 <= 32'h0;
        end else begin
          regfile_25 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_26 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h1a == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_26 <= 32'h0;
        end else begin
          regfile_26 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_27 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h1b == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_27 <= 32'h0;
        end else begin
          regfile_27 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_28 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h1c == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_28 <= 32'h0;
        end else begin
          regfile_28 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_29 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h1d == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_29 <= 32'h0;
        end else begin
          regfile_29 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_30 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h1e == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
          regfile_30 <= 32'h0;
        end else begin
          regfile_30 <= io_datain;
        end
      end
    end
    if (reset) begin // @[IDU.scala 48:24]
      regfile_31 <= 32'h0; // @[IDU.scala 48:24]
    end else if (io_wr) begin // @[IDU.scala 52:15]
      if (5'h1f == io_rd) begin // @[IDU.scala 53:20]
        if (io_rd == 5'h0) begin // @[IDU.scala 53:26]
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
module CSRCTL(
  input  [2:0] io_ctl,
  input  [4:0] io_rd,
  input  [4:0] io_rs1,
  output       io_wreg,
  output       io_wpc,
  output       io_read,
  output       io_choosecsr,
  output       io_jump,
  output       io_ecall
);
  wire  _io_read_T_1 = io_rd == 5'h0 ? 1'h0 : 1'h1; // @[IDU.scala 85:24]
  wire  _T_2 = io_ctl == 3'h2; // @[IDU.scala 90:21]
  wire  _io_wreg_T_1 = io_rs1 == 5'h0 ? 1'h0 : 1'h1; // @[IDU.scala 91:24]
  wire  _T_3 = io_ctl == 3'h4; // @[IDU.scala 98:21]
  wire  _T_4 = io_ctl == 3'h5; // @[IDU.scala 106:21]
  wire  _GEN_4 = io_ctl == 3'h4 | _T_4; // @[IDU.scala 103:18 98:39]
  wire  _GEN_6 = io_ctl == 3'h2 & _io_wreg_T_1; // @[IDU.scala 90:36 91:18]
  wire  _GEN_7 = io_ctl == 3'h2 ? 1'h0 : _T_3; // @[IDU.scala 90:36 92:18]
  wire  _GEN_9 = io_ctl == 3'h2 ? 1'h0 : _GEN_4; // @[IDU.scala 90:36 95:18]
  wire  _GEN_11 = io_ctl == 3'h1 | _GEN_6; // @[IDU.scala 82:36 83:18]
  wire  _GEN_12 = io_ctl == 3'h1 ? 1'h0 : _GEN_7; // @[IDU.scala 82:36 84:18]
  wire  _GEN_13 = io_ctl == 3'h1 ? _io_read_T_1 : _T_2; // @[IDU.scala 82:36 85:18]
  wire  _GEN_14 = io_ctl == 3'h1 ? 1'h0 : _GEN_9; // @[IDU.scala 82:36 86:18]
  wire  _GEN_15 = io_ctl == 3'h1 | _T_2; // @[IDU.scala 82:36 87:18]
  assign io_wreg = io_ctl == 3'h0 ? 1'h0 : _GEN_11; // @[IDU.scala 74:31 75:18]
  assign io_wpc = io_ctl == 3'h0 ? 1'h0 : _GEN_12; // @[IDU.scala 74:31 76:18]
  assign io_read = io_ctl == 3'h0 ? 1'h0 : _GEN_13; // @[IDU.scala 74:31 77:18]
  assign io_choosecsr = io_ctl == 3'h0 ? 1'h0 : _GEN_15; // @[IDU.scala 74:31 78:18]
  assign io_jump = io_ctl == 3'h0 ? 1'h0 : _GEN_14; // @[IDU.scala 74:31 79:18]
  assign io_ecall = io_ctl == 3'h0 ? 1'h0 : _GEN_12; // @[IDU.scala 74:31 76:18]
endmodule
module IDU(
  input         clock,
  input         reset,
  input  [31:0] io_ifu2idu_bits_inst,
  input  [31:0] io_ifu2idu_bits_pc,
  output [31:0] io_idu2exu_bits_pc,
  output [31:0] io_idu2exu_bits_inst,
  output [31:0] io_idu2exu_bits_imm,
  output [31:0] io_idu2exu_bits_rs1,
  output [31:0] io_idu2exu_bits_rs2,
  output        io_s1type,
  output [1:0]  io_s2type,
  output [2:0]  io_jumpctl,
  output [3:0]  io_op,
  output        io_ftrace,
  output        io_memrd,
  output        io_memwr,
  output [2:0]  io_memctl,
  output        io_tomemorreg,
  output        io_regwr,
  output [31:0] io_immout,
  output [31:0] io_rs1out,
  output [31:0] io_rs2out,
  input         io_wr,
  input  [31:0] io_regdatain,
  output [31:0] io_end_state,
  output        io_wreg,
  output        io_wpc,
  output        io_read,
  output        io_choosecsr,
  output        io_csrjump,
  output        io_ecall
);
  wire [2:0] immgen_io_format; // @[IDU.scala 165:23]
  wire [31:0] immgen_io_inst; // @[IDU.scala 165:23]
  wire [31:0] immgen_io_out; // @[IDU.scala 165:23]
  wire [31:0] decode_io_inst; // @[IDU.scala 166:23]
  wire [2:0] decode_io_format; // @[IDU.scala 166:23]
  wire  decode_io_s1type; // @[IDU.scala 166:23]
  wire [1:0] decode_io_s2type; // @[IDU.scala 166:23]
  wire [2:0] decode_io_jumpctl; // @[IDU.scala 166:23]
  wire [3:0] decode_io_op; // @[IDU.scala 166:23]
  wire  decode_io_ftrace; // @[IDU.scala 166:23]
  wire  decode_io_memrd; // @[IDU.scala 166:23]
  wire  decode_io_memwr; // @[IDU.scala 166:23]
  wire [2:0] decode_io_memctl; // @[IDU.scala 166:23]
  wire  decode_io_tomemorreg; // @[IDU.scala 166:23]
  wire  decode_io_regwr; // @[IDU.scala 166:23]
  wire [2:0] decode_io_csrctl; // @[IDU.scala 166:23]
  wire  regfile_clock; // @[IDU.scala 167:23]
  wire  regfile_reset; // @[IDU.scala 167:23]
  wire [4:0] regfile_io_rs1; // @[IDU.scala 167:23]
  wire [4:0] regfile_io_rs2; // @[IDU.scala 167:23]
  wire [4:0] regfile_io_rd; // @[IDU.scala 167:23]
  wire  regfile_io_wr; // @[IDU.scala 167:23]
  wire [31:0] regfile_io_datain; // @[IDU.scala 167:23]
  wire [31:0] regfile_io_rs1out; // @[IDU.scala 167:23]
  wire [31:0] regfile_io_rs2out; // @[IDU.scala 167:23]
  wire [31:0] regfile_io_end_state; // @[IDU.scala 167:23]
  wire [2:0] csrctl_io_ctl; // @[IDU.scala 168:23]
  wire [4:0] csrctl_io_rd; // @[IDU.scala 168:23]
  wire [4:0] csrctl_io_rs1; // @[IDU.scala 168:23]
  wire  csrctl_io_wreg; // @[IDU.scala 168:23]
  wire  csrctl_io_wpc; // @[IDU.scala 168:23]
  wire  csrctl_io_read; // @[IDU.scala 168:23]
  wire  csrctl_io_choosecsr; // @[IDU.scala 168:23]
  wire  csrctl_io_jump; // @[IDU.scala 168:23]
  wire  csrctl_io_ecall; // @[IDU.scala 168:23]
  ImmGen immgen ( // @[IDU.scala 165:23]
    .io_format(immgen_io_format),
    .io_inst(immgen_io_inst),
    .io_out(immgen_io_out)
  );
  InstDecode decode ( // @[IDU.scala 166:23]
    .io_inst(decode_io_inst),
    .io_format(decode_io_format),
    .io_s1type(decode_io_s1type),
    .io_s2type(decode_io_s2type),
    .io_jumpctl(decode_io_jumpctl),
    .io_op(decode_io_op),
    .io_ftrace(decode_io_ftrace),
    .io_memrd(decode_io_memrd),
    .io_memwr(decode_io_memwr),
    .io_memctl(decode_io_memctl),
    .io_tomemorreg(decode_io_tomemorreg),
    .io_regwr(decode_io_regwr),
    .io_csrctl(decode_io_csrctl)
  );
  RegFile regfile ( // @[IDU.scala 167:23]
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
  CSRCTL csrctl ( // @[IDU.scala 168:23]
    .io_ctl(csrctl_io_ctl),
    .io_rd(csrctl_io_rd),
    .io_rs1(csrctl_io_rs1),
    .io_wreg(csrctl_io_wreg),
    .io_wpc(csrctl_io_wpc),
    .io_read(csrctl_io_read),
    .io_choosecsr(csrctl_io_choosecsr),
    .io_jump(csrctl_io_jump),
    .io_ecall(csrctl_io_ecall)
  );
  assign io_idu2exu_bits_pc = io_ifu2idu_bits_pc; // @[IDU.scala 176:24]
  assign io_idu2exu_bits_inst = io_ifu2idu_bits_inst; // @[IDU.scala 177:24]
  assign io_idu2exu_bits_imm = immgen_io_out; // @[IDU.scala 178:24]
  assign io_idu2exu_bits_rs1 = regfile_io_rs1out; // @[IDU.scala 179:24]
  assign io_idu2exu_bits_rs2 = regfile_io_rs2out; // @[IDU.scala 180:24]
  assign io_s1type = decode_io_s1type; // @[IDU.scala 195:17]
  assign io_s2type = decode_io_s2type; // @[IDU.scala 196:17]
  assign io_jumpctl = decode_io_jumpctl; // @[IDU.scala 197:17]
  assign io_op = decode_io_op; // @[IDU.scala 198:17]
  assign io_ftrace = decode_io_ftrace; // @[IDU.scala 199:17]
  assign io_memrd = decode_io_memrd; // @[IDU.scala 200:17]
  assign io_memwr = decode_io_memwr; // @[IDU.scala 201:17]
  assign io_memctl = decode_io_memctl; // @[IDU.scala 202:17]
  assign io_tomemorreg = decode_io_tomemorreg; // @[IDU.scala 203:17]
  assign io_regwr = decode_io_regwr; // @[IDU.scala 204:17]
  assign io_immout = immgen_io_out; // @[IDU.scala 207:13]
  assign io_rs1out = regfile_io_rs1out; // @[IDU.scala 209:13]
  assign io_rs2out = regfile_io_rs2out; // @[IDU.scala 210:13]
  assign io_end_state = regfile_io_end_state; // @[IDU.scala 212:16]
  assign io_wreg = csrctl_io_wreg; // @[IDU.scala 214:16]
  assign io_wpc = csrctl_io_wpc; // @[IDU.scala 215:16]
  assign io_read = csrctl_io_read; // @[IDU.scala 216:16]
  assign io_choosecsr = csrctl_io_choosecsr; // @[IDU.scala 217:16]
  assign io_csrjump = csrctl_io_jump; // @[IDU.scala 218:16]
  assign io_ecall = csrctl_io_ecall; // @[IDU.scala 219:16]
  assign immgen_io_format = decode_io_format; // @[IDU.scala 185:20]
  assign immgen_io_inst = io_ifu2idu_bits_inst; // @[IDU.scala 186:20]
  assign decode_io_inst = io_ifu2idu_bits_inst; // @[IDU.scala 174:18]
  assign regfile_clock = clock;
  assign regfile_reset = reset;
  assign regfile_io_rs1 = io_ifu2idu_bits_inst[19:15]; // @[IDU.scala 188:41]
  assign regfile_io_rs2 = io_ifu2idu_bits_inst[24:20]; // @[IDU.scala 189:41]
  assign regfile_io_rd = io_ifu2idu_bits_inst[11:7]; // @[IDU.scala 190:41]
  assign regfile_io_wr = io_wr; // @[IDU.scala 192:21]
  assign regfile_io_datain = io_regdatain; // @[IDU.scala 193:21]
  assign csrctl_io_ctl = decode_io_csrctl; // @[IDU.scala 170:17]
  assign csrctl_io_rd = io_ifu2idu_bits_inst[11:7]; // @[IDU.scala 171:40]
  assign csrctl_io_rs1 = io_ifu2idu_bits_inst[19:15]; // @[IDU.scala 172:40]
endmodule
module R1mux(
  input         io_r1type,
  input  [31:0] io_rs1,
  input  [31:0] io_pc,
  output [31:0] io_r1out
);
  assign io_r1out = io_r1type ? io_rs1 : io_pc; // @[EXU.scala 17:18]
endmodule
module R2mux(
  input  [1:0]  io_r2type,
  input  [31:0] io_rs2,
  input  [31:0] io_imm,
  output [31:0] io_r2out
);
  wire [31:0] _io_r2out_T_2 = io_r2type[0] ? io_rs2 : io_imm; // @[EXU.scala 28:47]
  assign io_r2out = io_r2type[1] ? 32'h4 : _io_r2out_T_2; // @[EXU.scala 28:18]
endmodule
module JumpCtl(
  input  [2:0] io_ctl,
  input        io_eq,
  input        io_less,
  output       io_pclj,
  output       io_pcrs1
);
  wire  _T_1 = io_ctl == 3'h2; // @[EXU.scala 49:21]
  wire  _io_pclj_T_1 = io_eq ? 1'h0 : 1'h1; // @[EXU.scala 59:20]
  wire  _io_pclj_T_3 = io_less ? 1'h0 : 1'h1; // @[EXU.scala 65:20]
  wire  _GEN_0 = io_ctl == 3'h6 & _io_pclj_T_3; // @[EXU.scala 64:38 65:14 68:14]
  wire  _GEN_2 = io_ctl == 3'h5 ? io_less : _GEN_0; // @[EXU.scala 61:38 62:14]
  wire  _GEN_4 = io_ctl == 3'h4 ? _io_pclj_T_1 : _GEN_2; // @[EXU.scala 58:38 59:14]
  wire  _GEN_6 = io_ctl == 3'h3 ? io_eq : _GEN_4; // @[EXU.scala 55:38 56:14]
  wire  _GEN_8 = io_ctl == 3'h0 ? 1'h0 : _GEN_6; // @[EXU.scala 52:42 53:14]
  wire  _GEN_10 = io_ctl == 3'h2 | _GEN_8; // @[EXU.scala 49:40 50:14]
  assign io_pclj = io_ctl == 3'h1 | _GEN_10; // @[EXU.scala 46:33 47:14]
  assign io_pcrs1 = io_ctl == 3'h1 ? 1'h0 : _T_1; // @[EXU.scala 46:33 48:14]
endmodule
module Alu(
  input         clock,
  input         reset,
  input  [31:0] io_s1,
  input  [31:0] io_s2,
  input  [3:0]  io_op,
  output [31:0] io_out,
  output        io_eq,
  output        io_less,
  output        io_end
);
  wire  _T = io_op == 4'h0; // @[Alu.scala 24:14]
  wire [31:0] _io_out_T_1 = io_s1 + io_s2; // @[Alu.scala 26:21]
  wire  _T_1 = io_op == 4'hf; // @[Alu.scala 27:20]
  wire  _T_2 = io_op == 4'he; // @[Alu.scala 31:20]
  wire  _T_3 = io_op == 4'h8; // @[Alu.scala 34:20]
  wire [31:0] _io_out_T_3 = io_s1 - io_s2; // @[Alu.scala 35:21]
  wire  _T_4 = io_op == 4'h2; // @[Alu.scala 37:20]
  wire [31:0] _io_out_T_4 = io_s1; // @[Alu.scala 38:26]
  wire [31:0] _io_out_T_5 = io_s2; // @[Alu.scala 38:41]
  wire  _io_out_T_6 = $signed(io_s1) < $signed(io_s2); // @[Alu.scala 38:33]
  wire  _T_5 = io_op == 4'h3; // @[Alu.scala 41:20]
  wire  _io_out_T_8 = io_s1 < io_s2; // @[Alu.scala 42:26]
  wire  _T_6 = io_op == 4'h7; // @[Alu.scala 45:20]
  wire [31:0] _io_out_T_10 = io_s1 & io_s2; // @[Alu.scala 47:21]
  wire  _T_7 = io_op == 4'h1; // @[Alu.scala 48:20]
  wire [62:0] _GEN_0 = {{31'd0}, io_s1}; // @[Alu.scala 50:21]
  wire [62:0] _io_out_T_12 = _GEN_0 << io_s2[4:0]; // @[Alu.scala 50:21]
  wire  _T_8 = io_op == 4'h5; // @[Alu.scala 51:20]
  wire [31:0] _io_out_T_14 = io_s1 >> io_s2[4:0]; // @[Alu.scala 53:21]
  wire  _T_9 = io_op == 4'hd; // @[Alu.scala 54:20]
  wire [31:0] _io_out_T_18 = $signed(io_s1) >>> io_s2[4:0]; // @[Alu.scala 56:45]
  wire  _T_10 = io_op == 4'h9; // @[Alu.scala 57:20]
  wire  _T_11 = io_op == 4'h4; // @[Alu.scala 60:20]
  wire [31:0] _io_out_T_19 = io_s1 ^ io_s2; // @[Alu.scala 62:21]
  wire  _T_12 = io_op == 4'h6; // @[Alu.scala 63:20]
  wire [31:0] _io_out_T_20 = io_s1 | io_s2; // @[Alu.scala 65:21]
  wire [31:0] _GEN_1 = io_op == 4'h6 ? _io_out_T_20 : 32'h0; // @[Alu.scala 63:34 65:12 68:12]
  wire  _GEN_2 = io_op == 4'h6 ? 1'h0 : 1'h1; // @[Alu.scala 17:10 63:34 70:12]
  wire [31:0] _GEN_4 = io_op == 4'h4 ? _io_out_T_19 : _GEN_1; // @[Alu.scala 60:35 62:12]
  wire  _GEN_5 = io_op == 4'h4 ? 1'h0 : _GEN_2; // @[Alu.scala 17:10 60:35]
  wire [31:0] _GEN_7 = io_op == 4'h9 ? io_s2 : _GEN_4; // @[Alu.scala 57:35 59:12]
  wire  _GEN_8 = io_op == 4'h9 ? 1'h0 : _GEN_5; // @[Alu.scala 17:10 57:35]
  wire [31:0] _GEN_10 = io_op == 4'hd ? _io_out_T_18 : _GEN_7; // @[Alu.scala 54:35 56:12]
  wire  _GEN_11 = io_op == 4'hd ? 1'h0 : _GEN_8; // @[Alu.scala 17:10 54:35]
  wire [31:0] _GEN_13 = io_op == 4'h5 ? _io_out_T_14 : _GEN_10; // @[Alu.scala 51:35 53:12]
  wire  _GEN_14 = io_op == 4'h5 ? 1'h0 : _GEN_11; // @[Alu.scala 17:10 51:35]
  wire [62:0] _GEN_16 = io_op == 4'h1 ? _io_out_T_12 : {{31'd0}, _GEN_13}; // @[Alu.scala 48:35 50:12]
  wire  _GEN_17 = io_op == 4'h1 ? 1'h0 : _GEN_14; // @[Alu.scala 17:10 48:35]
  wire [62:0] _GEN_19 = io_op == 4'h7 ? {{31'd0}, _io_out_T_10} : _GEN_16; // @[Alu.scala 45:35 47:12]
  wire  _GEN_20 = io_op == 4'h7 ? 1'h0 : _GEN_17; // @[Alu.scala 17:10 45:35]
  wire [62:0] _GEN_21 = io_op == 4'h3 ? {{62'd0}, io_s1 < io_s2} : _GEN_19; // @[Alu.scala 41:36 42:13]
  wire  _GEN_22 = io_op == 4'h3 & io_out == 32'h0; // @[Alu.scala 41:36 43:13]
  wire  _GEN_23 = io_op == 4'h3 & _io_out_T_8; // @[Alu.scala 41:36 44:13]
  wire  _GEN_24 = io_op == 4'h3 ? 1'h0 : _GEN_20; // @[Alu.scala 17:10 41:36]
  wire [62:0] _GEN_25 = io_op == 4'h2 ? {{62'd0}, $signed(_io_out_T_4) < $signed(_io_out_T_5)} : _GEN_21; // @[Alu.scala 37:35 38:13]
  wire  _GEN_26 = io_op == 4'h2 ? _io_out_T_3 == 32'h0 : _GEN_22; // @[Alu.scala 37:35 39:13]
  wire  _GEN_27 = io_op == 4'h2 ? _io_out_T_6 : _GEN_23; // @[Alu.scala 37:35 40:13]
  wire  _GEN_28 = io_op == 4'h2 ? 1'h0 : _GEN_24; // @[Alu.scala 17:10 37:35]
  wire [62:0] _GEN_29 = io_op == 4'h8 ? {{31'd0}, _io_out_T_3} : _GEN_25; // @[Alu.scala 34:35 35:12]
  wire  _GEN_30 = io_op == 4'h8 ? 1'h0 : _GEN_26; // @[Alu.scala 20:13 34:35]
  wire  _GEN_31 = io_op == 4'h8 ? 1'h0 : _GEN_27; // @[Alu.scala 21:13 34:35]
  wire  _GEN_32 = io_op == 4'h8 ? 1'h0 : _GEN_28; // @[Alu.scala 17:10 34:35]
  wire  _GEN_33 = io_op == 4'he ? 1'h0 : _GEN_30; // @[Alu.scala 20:13 31:35]
  wire  _GEN_34 = io_op == 4'he ? 1'h0 : _GEN_31; // @[Alu.scala 21:13 31:35]
  wire [62:0] _GEN_35 = io_op == 4'he ? 63'h0 : _GEN_29; // @[Alu.scala 31:35 33:12]
  wire  _GEN_36 = io_op == 4'he ? 1'h0 : _GEN_32; // @[Alu.scala 17:10 31:35]
  wire  _GEN_37 = io_op == 4'hf ? 1'h0 : _GEN_33; // @[Alu.scala 20:13 27:35]
  wire  _GEN_38 = io_op == 4'hf ? 1'h0 : _GEN_34; // @[Alu.scala 21:13 27:35]
  wire [62:0] _GEN_39 = io_op == 4'hf ? 63'h0 : _GEN_35; // @[Alu.scala 27:35 29:12]
  wire  _GEN_40 = io_op == 4'hf | _GEN_36; // @[Alu.scala 27:35 30:12]
  wire [62:0] _GEN_43 = io_op == 4'h0 ? {{31'd0}, _io_out_T_1} : _GEN_39; // @[Alu.scala 24:29 26:12]
  assign io_out = _GEN_43[31:0];
  assign io_eq = io_op == 4'h0 ? 1'h0 : _GEN_37; // @[Alu.scala 20:13 24:29]
  assign io_less = io_op == 4'h0 ? 1'h0 : _GEN_38; // @[Alu.scala 21:13 24:29]
  assign io_end = io_op == 4'h0 ? 1'h0 : _GEN_40; // @[Alu.scala 17:10 24:29]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~_T & ~_T_1 & ~_T_2 & ~_T_3 & ~_T_4 & ~_T_5 & ~_T_6 & ~_T_7 & ~_T_8 & ~_T_9 & ~_T_10 & ~_T_11 & ~_T_12 & ~
          reset) begin
          $fwrite(32'h80000002,"Error: Unknown instruction! \n"); // @[Alu.scala 69:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module EXU(
  input         clock,
  input         reset,
  output [31:0] io_exu2wb_bits_pc,
  output [31:0] io_exu2wb_bits_inst,
  output        io_exu2wb_bits_pclj,
  output        io_exu2wb_bits_pcrs1,
  output [31:0] io_exu2wb_bits_datamemaddr,
  input  [31:0] io_idu2exu_bits_pc,
  input  [31:0] io_idu2exu_bits_inst,
  input  [31:0] io_idu2exu_bits_imm,
  input  [31:0] io_idu2exu_bits_rs1,
  input  [31:0] io_idu2exu_bits_rs2,
  input  [1:0]  io_r2type,
  input         io_r1type,
  input  [2:0]  io_ctl,
  input  [3:0]  io_op,
  output        io_end
);
  wire  r1mux_io_r1type; // @[EXU.scala 90:21]
  wire [31:0] r1mux_io_rs1; // @[EXU.scala 90:21]
  wire [31:0] r1mux_io_pc; // @[EXU.scala 90:21]
  wire [31:0] r1mux_io_r1out; // @[EXU.scala 90:21]
  wire [1:0] r2mux_io_r2type; // @[EXU.scala 91:21]
  wire [31:0] r2mux_io_rs2; // @[EXU.scala 91:21]
  wire [31:0] r2mux_io_imm; // @[EXU.scala 91:21]
  wire [31:0] r2mux_io_r2out; // @[EXU.scala 91:21]
  wire [2:0] jumpctl_io_ctl; // @[EXU.scala 93:23]
  wire  jumpctl_io_eq; // @[EXU.scala 93:23]
  wire  jumpctl_io_less; // @[EXU.scala 93:23]
  wire  jumpctl_io_pclj; // @[EXU.scala 93:23]
  wire  jumpctl_io_pcrs1; // @[EXU.scala 93:23]
  wire  alu_clock; // @[EXU.scala 95:19]
  wire  alu_reset; // @[EXU.scala 95:19]
  wire [31:0] alu_io_s1; // @[EXU.scala 95:19]
  wire [31:0] alu_io_s2; // @[EXU.scala 95:19]
  wire [3:0] alu_io_op; // @[EXU.scala 95:19]
  wire [31:0] alu_io_out; // @[EXU.scala 95:19]
  wire  alu_io_eq; // @[EXU.scala 95:19]
  wire  alu_io_less; // @[EXU.scala 95:19]
  wire  alu_io_end; // @[EXU.scala 95:19]
  R1mux r1mux ( // @[EXU.scala 90:21]
    .io_r1type(r1mux_io_r1type),
    .io_rs1(r1mux_io_rs1),
    .io_pc(r1mux_io_pc),
    .io_r1out(r1mux_io_r1out)
  );
  R2mux r2mux ( // @[EXU.scala 91:21]
    .io_r2type(r2mux_io_r2type),
    .io_rs2(r2mux_io_rs2),
    .io_imm(r2mux_io_imm),
    .io_r2out(r2mux_io_r2out)
  );
  JumpCtl jumpctl ( // @[EXU.scala 93:23]
    .io_ctl(jumpctl_io_ctl),
    .io_eq(jumpctl_io_eq),
    .io_less(jumpctl_io_less),
    .io_pclj(jumpctl_io_pclj),
    .io_pcrs1(jumpctl_io_pcrs1)
  );
  Alu alu ( // @[EXU.scala 95:19]
    .clock(alu_clock),
    .reset(alu_reset),
    .io_s1(alu_io_s1),
    .io_s2(alu_io_s2),
    .io_op(alu_io_op),
    .io_out(alu_io_out),
    .io_eq(alu_io_eq),
    .io_less(alu_io_less),
    .io_end(alu_io_end)
  );
  assign io_exu2wb_bits_pc = io_idu2exu_bits_pc; // @[EXU.scala 99:23]
  assign io_exu2wb_bits_inst = io_idu2exu_bits_inst; // @[EXU.scala 100:23]
  assign io_exu2wb_bits_pclj = jumpctl_io_pclj; // @[EXU.scala 103:30]
  assign io_exu2wb_bits_pcrs1 = jumpctl_io_pcrs1; // @[EXU.scala 104:30]
  assign io_exu2wb_bits_datamemaddr = alu_io_out; // @[EXU.scala 105:30]
  assign io_end = alu_io_end; // @[EXU.scala 129:13]
  assign r1mux_io_r1type = io_r1type; // @[EXU.scala 109:19]
  assign r1mux_io_rs1 = io_idu2exu_bits_rs1; // @[EXU.scala 108:19]
  assign r1mux_io_pc = io_idu2exu_bits_pc; // @[EXU.scala 107:19]
  assign r2mux_io_r2type = io_r2type; // @[EXU.scala 113:19]
  assign r2mux_io_rs2 = io_idu2exu_bits_rs2; // @[EXU.scala 111:19]
  assign r2mux_io_imm = io_idu2exu_bits_imm; // @[EXU.scala 112:19]
  assign jumpctl_io_ctl = io_ctl; // @[EXU.scala 126:18]
  assign jumpctl_io_eq = alu_io_eq; // @[EXU.scala 118:19]
  assign jumpctl_io_less = alu_io_less; // @[EXU.scala 119:19]
  assign alu_clock = clock;
  assign alu_reset = reset;
  assign alu_io_s1 = r1mux_io_r1out; // @[EXU.scala 115:13]
  assign alu_io_s2 = r2mux_io_r2out; // @[EXU.scala 116:13]
  assign alu_io_op = io_op; // @[EXU.scala 128:13]
endmodule
module NextPc(
  input  [31:0] io_pc,
  input         io_csrjump,
  input  [31:0] io_csrdata,
  input         io_pclj,
  input         io_pcrs1,
  input  [31:0] io_imm,
  input  [31:0] io_rs1,
  output [31:0] io_nextpc
);
  wire [31:0] _io_nextpc_T = io_pclj ? io_imm : 32'h4; // @[WB.scala 22:21]
  wire [31:0] _io_nextpc_T_1 = io_pcrs1 ? io_rs1 : io_pc; // @[WB.scala 22:49]
  wire [31:0] _io_nextpc_T_3 = _io_nextpc_T + _io_nextpc_T_1; // @[WB.scala 22:44]
  assign io_nextpc = io_csrjump ? io_csrdata : _io_nextpc_T_3; // @[WB.scala 19:20 20:15 22:15]
endmodule
module MemorRegMux(
  input  [31:0] io_memdata,
  input  [31:0] io_aludata,
  input         io_memen,
  output [31:0] io_out
);
  assign io_out = io_memen ? io_memdata : io_aludata; // @[WB.scala 34:16]
endmodule
module CSRALUMUX(
  input  [31:0] io_aludata,
  input  [31:0] io_csrdata,
  input         io_choosecsr,
  output [31:0] io_out
);
  assign io_out = io_choosecsr ? io_csrdata : io_aludata; // @[WB.scala 44:16]
endmodule
module CSR(
  input         clock,
  input         reset,
  input  [11:0] io_idx,
  input         io_wr,
  input         io_wpc,
  input         io_re,
  input  [31:0] io_pc,
  input  [31:0] io_rs1data,
  input         io_ecall,
  output [31:0] io_dataout,
  output [31:0] io_pcdataout
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] csrfile_0; // @[WB.scala 61:24]
  reg [31:0] csrfile_1; // @[WB.scala 61:24]
  reg [31:0] csrfile_2; // @[WB.scala 61:24]
  reg [31:0] csrfile_3; // @[WB.scala 61:24]
  wire  _T_1 = io_idx == 12'h300; // @[WB.scala 63:17]
  wire  _T_2 = io_idx == 12'h341; // @[WB.scala 65:23]
  wire [31:0] _csrfile_1_T = io_wpc ? io_pc : io_rs1data; // @[WB.scala 66:24]
  wire  _T_3 = io_idx == 12'h342; // @[WB.scala 67:23]
  wire  _T_4 = io_idx == 12'h305; // @[WB.scala 69:23]
  wire [31:0] _GEN_0 = io_ecall ? io_pc : csrfile_1; // @[WB.scala 71:26 72:18 61:24]
  wire [31:0] _GEN_1 = io_ecall ? 32'hb : csrfile_2; // @[WB.scala 71:26 73:18 61:24]
  wire [31:0] _GEN_2 = io_idx == 12'h305 ? io_rs1data : csrfile_3; // @[WB.scala 69:36 70:18 61:24]
  wire [31:0] _GEN_3 = io_idx == 12'h305 ? csrfile_1 : _GEN_0; // @[WB.scala 61:24 69:36]
  wire [31:0] _GEN_4 = io_idx == 12'h305 ? csrfile_2 : _GEN_1; // @[WB.scala 61:24 69:36]
  wire [31:0] _GEN_5 = io_idx == 12'h342 ? io_rs1data : _GEN_4; // @[WB.scala 67:36 68:18]
  wire [31:0] _GEN_6 = io_idx == 12'h342 ? csrfile_3 : _GEN_2; // @[WB.scala 61:24 67:36]
  wire [31:0] _GEN_7 = io_idx == 12'h342 ? csrfile_1 : _GEN_3; // @[WB.scala 61:24 67:36]
  wire [31:0] _GEN_19 = _T_4 ? csrfile_3 : 32'h0; // @[WB.scala 85:36 86:18 88:18]
  wire [31:0] _GEN_20 = _T_3 ? csrfile_2 : _GEN_19; // @[WB.scala 82:36 83:18]
  wire [31:0] _GEN_21 = _T_2 ? csrfile_1 : _GEN_20; // @[WB.scala 80:36 81:18]
  wire [31:0] _GEN_22 = _T_1 ? csrfile_0 : _GEN_21; // @[WB.scala 77:30 78:18]
  assign io_dataout = io_re ? _GEN_22 : 32'h0; // @[WB.scala 76:15 91:16]
  assign io_pcdataout = io_ecall ? csrfile_3 : csrfile_1; // @[WB.scala 93:22]
  always @(posedge clock) begin
    if (reset) begin // @[WB.scala 61:24]
      csrfile_0 <= 32'h0; // @[WB.scala 61:24]
    end else if (io_wr | io_wpc) begin // @[WB.scala 62:25]
      if (io_idx == 12'h300) begin // @[WB.scala 63:30]
        csrfile_0 <= io_rs1data; // @[WB.scala 64:18]
      end
    end
    if (reset) begin // @[WB.scala 61:24]
      csrfile_1 <= 32'h0; // @[WB.scala 61:24]
    end else if (io_wr | io_wpc) begin // @[WB.scala 62:25]
      if (!(io_idx == 12'h300)) begin // @[WB.scala 63:30]
        if (io_idx == 12'h341) begin // @[WB.scala 65:36]
          csrfile_1 <= _csrfile_1_T; // @[WB.scala 66:18]
        end else begin
          csrfile_1 <= _GEN_7;
        end
      end
    end
    if (reset) begin // @[WB.scala 61:24]
      csrfile_2 <= 32'h0; // @[WB.scala 61:24]
    end else if (io_wr | io_wpc) begin // @[WB.scala 62:25]
      if (!(io_idx == 12'h300)) begin // @[WB.scala 63:30]
        if (!(io_idx == 12'h341)) begin // @[WB.scala 65:36]
          csrfile_2 <= _GEN_5;
        end
      end
    end
    if (reset) begin // @[WB.scala 61:24]
      csrfile_3 <= 32'h0; // @[WB.scala 61:24]
    end else if (io_wr | io_wpc) begin // @[WB.scala 62:25]
      if (!(io_idx == 12'h300)) begin // @[WB.scala 63:30]
        if (!(io_idx == 12'h341)) begin // @[WB.scala 65:36]
          csrfile_3 <= _GEN_6;
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
  csrfile_0 = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  csrfile_1 = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  csrfile_2 = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  csrfile_3 = _RAND_3[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module WB(
  input         clock,
  input         reset,
  input  [31:0] io_exu2wb_bits_pc,
  input  [31:0] io_exu2wb_bits_inst,
  input         io_exu2wb_bits_pclj,
  input         io_exu2wb_bits_pcrs1,
  input  [31:0] io_exu2wb_bits_datamemaddr,
  input         io_csrjump,
  input  [31:0] io_imm,
  input  [31:0] io_rs1,
  output [31:0] io_nextpc,
  input  [31:0] io_data,
  input         io_wr,
  input         io_valid,
  input  [2:0]  io_wmask,
  input         io_csrwr,
  input         io_wpc,
  input         io_re,
  input  [31:0] io_rs1data,
  input         io_ecall,
  input         io_memen,
  input         io_choosecsr,
  output [31:0] io_wbdataout
);
  wire [31:0] nextpc_io_pc; // @[WB.scala 132:25]
  wire  nextpc_io_csrjump; // @[WB.scala 132:25]
  wire [31:0] nextpc_io_csrdata; // @[WB.scala 132:25]
  wire  nextpc_io_pclj; // @[WB.scala 132:25]
  wire  nextpc_io_pcrs1; // @[WB.scala 132:25]
  wire [31:0] nextpc_io_imm; // @[WB.scala 132:25]
  wire [31:0] nextpc_io_rs1; // @[WB.scala 132:25]
  wire [31:0] nextpc_io_nextpc; // @[WB.scala 132:25]
  wire [31:0] datamem_addr; // @[WB.scala 133:25]
  wire [31:0] datamem_data; // @[WB.scala 133:25]
  wire  datamem_wr; // @[WB.scala 133:25]
  wire  datamem_valid; // @[WB.scala 133:25]
  wire [2:0] datamem_wmask; // @[WB.scala 133:25]
  wire  datamem_clock; // @[WB.scala 133:25]
  wire [31:0] datamem_dataout; // @[WB.scala 133:25]
  wire [31:0] memregmux_io_memdata; // @[WB.scala 134:25]
  wire [31:0] memregmux_io_aludata; // @[WB.scala 134:25]
  wire  memregmux_io_memen; // @[WB.scala 134:25]
  wire [31:0] memregmux_io_out; // @[WB.scala 134:25]
  wire [31:0] csralumux_io_aludata; // @[WB.scala 135:25]
  wire [31:0] csralumux_io_csrdata; // @[WB.scala 135:25]
  wire  csralumux_io_choosecsr; // @[WB.scala 135:25]
  wire [31:0] csralumux_io_out; // @[WB.scala 135:25]
  wire  csr_clock; // @[WB.scala 136:25]
  wire  csr_reset; // @[WB.scala 136:25]
  wire [11:0] csr_io_idx; // @[WB.scala 136:25]
  wire  csr_io_wr; // @[WB.scala 136:25]
  wire  csr_io_wpc; // @[WB.scala 136:25]
  wire  csr_io_re; // @[WB.scala 136:25]
  wire [31:0] csr_io_pc; // @[WB.scala 136:25]
  wire [31:0] csr_io_rs1data; // @[WB.scala 136:25]
  wire  csr_io_ecall; // @[WB.scala 136:25]
  wire [31:0] csr_io_dataout; // @[WB.scala 136:25]
  wire [31:0] csr_io_pcdataout; // @[WB.scala 136:25]
  NextPc nextpc ( // @[WB.scala 132:25]
    .io_pc(nextpc_io_pc),
    .io_csrjump(nextpc_io_csrjump),
    .io_csrdata(nextpc_io_csrdata),
    .io_pclj(nextpc_io_pclj),
    .io_pcrs1(nextpc_io_pcrs1),
    .io_imm(nextpc_io_imm),
    .io_rs1(nextpc_io_rs1),
    .io_nextpc(nextpc_io_nextpc)
  );
  DataMem datamem ( // @[WB.scala 133:25]
    .addr(datamem_addr),
    .data(datamem_data),
    .wr(datamem_wr),
    .valid(datamem_valid),
    .wmask(datamem_wmask),
    .clock(datamem_clock),
    .dataout(datamem_dataout)
  );
  MemorRegMux memregmux ( // @[WB.scala 134:25]
    .io_memdata(memregmux_io_memdata),
    .io_aludata(memregmux_io_aludata),
    .io_memen(memregmux_io_memen),
    .io_out(memregmux_io_out)
  );
  CSRALUMUX csralumux ( // @[WB.scala 135:25]
    .io_aludata(csralumux_io_aludata),
    .io_csrdata(csralumux_io_csrdata),
    .io_choosecsr(csralumux_io_choosecsr),
    .io_out(csralumux_io_out)
  );
  CSR csr ( // @[WB.scala 136:25]
    .clock(csr_clock),
    .reset(csr_reset),
    .io_idx(csr_io_idx),
    .io_wr(csr_io_wr),
    .io_wpc(csr_io_wpc),
    .io_re(csr_io_re),
    .io_pc(csr_io_pc),
    .io_rs1data(csr_io_rs1data),
    .io_ecall(csr_io_ecall),
    .io_dataout(csr_io_dataout),
    .io_pcdataout(csr_io_pcdataout)
  );
  assign io_nextpc = nextpc_io_nextpc; // @[WB.scala 177:21]
  assign io_wbdataout = csralumux_io_out; // @[WB.scala 150:24]
  assign nextpc_io_pc = io_exu2wb_bits_pc; // @[WB.scala 140:24]
  assign nextpc_io_csrjump = io_csrjump; // @[WB.scala 156:21]
  assign nextpc_io_csrdata = csr_io_pcdataout; // @[WB.scala 153:24]
  assign nextpc_io_pclj = io_exu2wb_bits_pclj; // @[WB.scala 141:24]
  assign nextpc_io_pcrs1 = io_exu2wb_bits_pcrs1; // @[WB.scala 142:24]
  assign nextpc_io_imm = io_imm; // @[WB.scala 157:21]
  assign nextpc_io_rs1 = io_rs1; // @[WB.scala 158:21]
  assign datamem_addr = io_exu2wb_bits_datamemaddr; // @[WB.scala 143:24]
  assign datamem_data = io_data; // @[WB.scala 160:20]
  assign datamem_wr = io_wr; // @[WB.scala 161:20]
  assign datamem_valid = io_valid; // @[WB.scala 162:20]
  assign datamem_wmask = io_wmask; // @[WB.scala 163:20]
  assign datamem_clock = clock; // @[WB.scala 164:20]
  assign memregmux_io_memdata = datamem_dataout; // @[WB.scala 149:24]
  assign memregmux_io_aludata = io_exu2wb_bits_datamemaddr; // @[WB.scala 146:24]
  assign memregmux_io_memen = io_memen; // @[WB.scala 173:22]
  assign csralumux_io_aludata = memregmux_io_out; // @[WB.scala 151:24]
  assign csralumux_io_csrdata = csr_io_dataout; // @[WB.scala 152:24]
  assign csralumux_io_choosecsr = io_choosecsr; // @[WB.scala 175:26]
  assign csr_clock = clock;
  assign csr_reset = reset;
  assign csr_io_idx = io_exu2wb_bits_inst[31:20]; // @[WB.scala 145:46]
  assign csr_io_wr = io_csrwr; // @[WB.scala 166:18]
  assign csr_io_wpc = io_wpc; // @[WB.scala 168:18]
  assign csr_io_re = io_re; // @[WB.scala 167:18]
  assign csr_io_pc = io_exu2wb_bits_pc; // @[WB.scala 144:24]
  assign csr_io_rs1data = io_rs1data; // @[WB.scala 169:18]
  assign csr_io_ecall = io_ecall; // @[WB.scala 170:18]
endmodule
module Core(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [31:0] io_nextpc,
  output [31:0] io_pc
);
  wire  ifu_clock; // @[singlecpu.scala 20:19]
  wire  ifu_reset; // @[singlecpu.scala 20:19]
  wire [31:0] ifu_io_ifu2idu_bits_inst; // @[singlecpu.scala 20:19]
  wire [31:0] ifu_io_ifu2idu_bits_pc; // @[singlecpu.scala 20:19]
  wire [31:0] ifu_io_instin; // @[singlecpu.scala 20:19]
  wire [31:0] ifu_io_instout; // @[singlecpu.scala 20:19]
  wire [31:0] ifu_io_pcin; // @[singlecpu.scala 20:19]
  wire [31:0] ifu_io_pc; // @[singlecpu.scala 20:19]
  wire  idu_clock; // @[singlecpu.scala 21:19]
  wire  idu_reset; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_ifu2idu_bits_inst; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_ifu2idu_bits_pc; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_idu2exu_bits_pc; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_idu2exu_bits_inst; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_idu2exu_bits_imm; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_idu2exu_bits_rs1; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_idu2exu_bits_rs2; // @[singlecpu.scala 21:19]
  wire  idu_io_s1type; // @[singlecpu.scala 21:19]
  wire [1:0] idu_io_s2type; // @[singlecpu.scala 21:19]
  wire [2:0] idu_io_jumpctl; // @[singlecpu.scala 21:19]
  wire [3:0] idu_io_op; // @[singlecpu.scala 21:19]
  wire  idu_io_ftrace; // @[singlecpu.scala 21:19]
  wire  idu_io_memrd; // @[singlecpu.scala 21:19]
  wire  idu_io_memwr; // @[singlecpu.scala 21:19]
  wire [2:0] idu_io_memctl; // @[singlecpu.scala 21:19]
  wire  idu_io_tomemorreg; // @[singlecpu.scala 21:19]
  wire  idu_io_regwr; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_immout; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_rs1out; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_rs2out; // @[singlecpu.scala 21:19]
  wire  idu_io_wr; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_regdatain; // @[singlecpu.scala 21:19]
  wire [31:0] idu_io_end_state; // @[singlecpu.scala 21:19]
  wire  idu_io_wreg; // @[singlecpu.scala 21:19]
  wire  idu_io_wpc; // @[singlecpu.scala 21:19]
  wire  idu_io_read; // @[singlecpu.scala 21:19]
  wire  idu_io_choosecsr; // @[singlecpu.scala 21:19]
  wire  idu_io_csrjump; // @[singlecpu.scala 21:19]
  wire  idu_io_ecall; // @[singlecpu.scala 21:19]
  wire  exu_clock; // @[singlecpu.scala 22:19]
  wire  exu_reset; // @[singlecpu.scala 22:19]
  wire [31:0] exu_io_exu2wb_bits_pc; // @[singlecpu.scala 22:19]
  wire [31:0] exu_io_exu2wb_bits_inst; // @[singlecpu.scala 22:19]
  wire  exu_io_exu2wb_bits_pclj; // @[singlecpu.scala 22:19]
  wire  exu_io_exu2wb_bits_pcrs1; // @[singlecpu.scala 22:19]
  wire [31:0] exu_io_exu2wb_bits_datamemaddr; // @[singlecpu.scala 22:19]
  wire [31:0] exu_io_idu2exu_bits_pc; // @[singlecpu.scala 22:19]
  wire [31:0] exu_io_idu2exu_bits_inst; // @[singlecpu.scala 22:19]
  wire [31:0] exu_io_idu2exu_bits_imm; // @[singlecpu.scala 22:19]
  wire [31:0] exu_io_idu2exu_bits_rs1; // @[singlecpu.scala 22:19]
  wire [31:0] exu_io_idu2exu_bits_rs2; // @[singlecpu.scala 22:19]
  wire [1:0] exu_io_r2type; // @[singlecpu.scala 22:19]
  wire  exu_io_r1type; // @[singlecpu.scala 22:19]
  wire [2:0] exu_io_ctl; // @[singlecpu.scala 22:19]
  wire [3:0] exu_io_op; // @[singlecpu.scala 22:19]
  wire  exu_io_end; // @[singlecpu.scala 22:19]
  wire  wb_clock; // @[singlecpu.scala 23:19]
  wire  wb_reset; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_exu2wb_bits_pc; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_exu2wb_bits_inst; // @[singlecpu.scala 23:19]
  wire  wb_io_exu2wb_bits_pclj; // @[singlecpu.scala 23:19]
  wire  wb_io_exu2wb_bits_pcrs1; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_exu2wb_bits_datamemaddr; // @[singlecpu.scala 23:19]
  wire  wb_io_csrjump; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_imm; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_rs1; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_nextpc; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_data; // @[singlecpu.scala 23:19]
  wire  wb_io_wr; // @[singlecpu.scala 23:19]
  wire  wb_io_valid; // @[singlecpu.scala 23:19]
  wire [2:0] wb_io_wmask; // @[singlecpu.scala 23:19]
  wire  wb_io_csrwr; // @[singlecpu.scala 23:19]
  wire  wb_io_wpc; // @[singlecpu.scala 23:19]
  wire  wb_io_re; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_rs1data; // @[singlecpu.scala 23:19]
  wire  wb_io_ecall; // @[singlecpu.scala 23:19]
  wire  wb_io_memen; // @[singlecpu.scala 23:19]
  wire  wb_io_choosecsr; // @[singlecpu.scala 23:19]
  wire [31:0] wb_io_wbdataout; // @[singlecpu.scala 23:19]
  wire  endnpc_endflag; // @[singlecpu.scala 25:22]
  wire [31:0] endnpc_state; // @[singlecpu.scala 25:22]
  wire [31:0] insttrace_inst; // @[singlecpu.scala 27:25]
  wire [31:0] insttrace_pc; // @[singlecpu.scala 27:25]
  wire  insttrace_clock; // @[singlecpu.scala 27:25]
  wire [31:0] ftrace_inst; // @[singlecpu.scala 28:25]
  wire [31:0] ftrace_pc; // @[singlecpu.scala 28:25]
  wire [31:0] ftrace_nextpc; // @[singlecpu.scala 28:25]
  wire  ftrace_jump; // @[singlecpu.scala 28:25]
  wire  ftrace_clock; // @[singlecpu.scala 28:25]
  IFU ifu ( // @[singlecpu.scala 20:19]
    .clock(ifu_clock),
    .reset(ifu_reset),
    .io_ifu2idu_bits_inst(ifu_io_ifu2idu_bits_inst),
    .io_ifu2idu_bits_pc(ifu_io_ifu2idu_bits_pc),
    .io_instin(ifu_io_instin),
    .io_instout(ifu_io_instout),
    .io_pcin(ifu_io_pcin),
    .io_pc(ifu_io_pc)
  );
  IDU idu ( // @[singlecpu.scala 21:19]
    .clock(idu_clock),
    .reset(idu_reset),
    .io_ifu2idu_bits_inst(idu_io_ifu2idu_bits_inst),
    .io_ifu2idu_bits_pc(idu_io_ifu2idu_bits_pc),
    .io_idu2exu_bits_pc(idu_io_idu2exu_bits_pc),
    .io_idu2exu_bits_inst(idu_io_idu2exu_bits_inst),
    .io_idu2exu_bits_imm(idu_io_idu2exu_bits_imm),
    .io_idu2exu_bits_rs1(idu_io_idu2exu_bits_rs1),
    .io_idu2exu_bits_rs2(idu_io_idu2exu_bits_rs2),
    .io_s1type(idu_io_s1type),
    .io_s2type(idu_io_s2type),
    .io_jumpctl(idu_io_jumpctl),
    .io_op(idu_io_op),
    .io_ftrace(idu_io_ftrace),
    .io_memrd(idu_io_memrd),
    .io_memwr(idu_io_memwr),
    .io_memctl(idu_io_memctl),
    .io_tomemorreg(idu_io_tomemorreg),
    .io_regwr(idu_io_regwr),
    .io_immout(idu_io_immout),
    .io_rs1out(idu_io_rs1out),
    .io_rs2out(idu_io_rs2out),
    .io_wr(idu_io_wr),
    .io_regdatain(idu_io_regdatain),
    .io_end_state(idu_io_end_state),
    .io_wreg(idu_io_wreg),
    .io_wpc(idu_io_wpc),
    .io_read(idu_io_read),
    .io_choosecsr(idu_io_choosecsr),
    .io_csrjump(idu_io_csrjump),
    .io_ecall(idu_io_ecall)
  );
  EXU exu ( // @[singlecpu.scala 22:19]
    .clock(exu_clock),
    .reset(exu_reset),
    .io_exu2wb_bits_pc(exu_io_exu2wb_bits_pc),
    .io_exu2wb_bits_inst(exu_io_exu2wb_bits_inst),
    .io_exu2wb_bits_pclj(exu_io_exu2wb_bits_pclj),
    .io_exu2wb_bits_pcrs1(exu_io_exu2wb_bits_pcrs1),
    .io_exu2wb_bits_datamemaddr(exu_io_exu2wb_bits_datamemaddr),
    .io_idu2exu_bits_pc(exu_io_idu2exu_bits_pc),
    .io_idu2exu_bits_inst(exu_io_idu2exu_bits_inst),
    .io_idu2exu_bits_imm(exu_io_idu2exu_bits_imm),
    .io_idu2exu_bits_rs1(exu_io_idu2exu_bits_rs1),
    .io_idu2exu_bits_rs2(exu_io_idu2exu_bits_rs2),
    .io_r2type(exu_io_r2type),
    .io_r1type(exu_io_r1type),
    .io_ctl(exu_io_ctl),
    .io_op(exu_io_op),
    .io_end(exu_io_end)
  );
  WB wb ( // @[singlecpu.scala 23:19]
    .clock(wb_clock),
    .reset(wb_reset),
    .io_exu2wb_bits_pc(wb_io_exu2wb_bits_pc),
    .io_exu2wb_bits_inst(wb_io_exu2wb_bits_inst),
    .io_exu2wb_bits_pclj(wb_io_exu2wb_bits_pclj),
    .io_exu2wb_bits_pcrs1(wb_io_exu2wb_bits_pcrs1),
    .io_exu2wb_bits_datamemaddr(wb_io_exu2wb_bits_datamemaddr),
    .io_csrjump(wb_io_csrjump),
    .io_imm(wb_io_imm),
    .io_rs1(wb_io_rs1),
    .io_nextpc(wb_io_nextpc),
    .io_data(wb_io_data),
    .io_wr(wb_io_wr),
    .io_valid(wb_io_valid),
    .io_wmask(wb_io_wmask),
    .io_csrwr(wb_io_csrwr),
    .io_wpc(wb_io_wpc),
    .io_re(wb_io_re),
    .io_rs1data(wb_io_rs1data),
    .io_ecall(wb_io_ecall),
    .io_memen(wb_io_memen),
    .io_choosecsr(wb_io_choosecsr),
    .io_wbdataout(wb_io_wbdataout)
  );
  EndNpc endnpc ( // @[singlecpu.scala 25:22]
    .endflag(endnpc_endflag),
    .state(endnpc_state)
  );
  InstTrace insttrace ( // @[singlecpu.scala 27:25]
    .inst(insttrace_inst),
    .pc(insttrace_pc),
    .clock(insttrace_clock)
  );
  Ftrace ftrace ( // @[singlecpu.scala 28:25]
    .inst(ftrace_inst),
    .pc(ftrace_pc),
    .nextpc(ftrace_nextpc),
    .jump(ftrace_jump),
    .clock(ftrace_clock)
  );
  assign io_nextpc = wb_io_nextpc; // @[singlecpu.scala 31:17]
  assign io_pc = ifu_io_pc; // @[singlecpu.scala 32:17]
  assign ifu_clock = clock;
  assign ifu_reset = reset;
  assign ifu_io_instin = io_inst; // @[singlecpu.scala 33:17]
  assign ifu_io_pcin = wb_io_nextpc; // @[singlecpu.scala 39:15]
  assign idu_clock = clock;
  assign idu_reset = reset;
  assign idu_io_ifu2idu_bits_inst = ifu_io_ifu2idu_bits_inst; // @[singlecpu.scala 35:18]
  assign idu_io_ifu2idu_bits_pc = ifu_io_ifu2idu_bits_pc; // @[singlecpu.scala 35:18]
  assign idu_io_wr = idu_io_regwr; // @[singlecpu.scala 63:20]
  assign idu_io_regdatain = wb_io_wbdataout; // @[singlecpu.scala 62:20]
  assign exu_clock = clock;
  assign exu_reset = reset;
  assign exu_io_idu2exu_bits_pc = idu_io_idu2exu_bits_pc; // @[singlecpu.scala 36:18]
  assign exu_io_idu2exu_bits_inst = idu_io_idu2exu_bits_inst; // @[singlecpu.scala 36:18]
  assign exu_io_idu2exu_bits_imm = idu_io_idu2exu_bits_imm; // @[singlecpu.scala 36:18]
  assign exu_io_idu2exu_bits_rs1 = idu_io_idu2exu_bits_rs1; // @[singlecpu.scala 36:18]
  assign exu_io_idu2exu_bits_rs2 = idu_io_idu2exu_bits_rs2; // @[singlecpu.scala 36:18]
  assign exu_io_r2type = idu_io_s2type; // @[singlecpu.scala 58:19]
  assign exu_io_r1type = idu_io_s1type; // @[singlecpu.scala 57:19]
  assign exu_io_ctl = idu_io_jumpctl; // @[singlecpu.scala 56:19]
  assign exu_io_op = idu_io_op; // @[singlecpu.scala 59:19]
  assign wb_clock = clock;
  assign wb_reset = reset;
  assign wb_io_exu2wb_bits_pc = exu_io_exu2wb_bits_pc; // @[singlecpu.scala 37:17]
  assign wb_io_exu2wb_bits_inst = exu_io_exu2wb_bits_inst; // @[singlecpu.scala 37:17]
  assign wb_io_exu2wb_bits_pclj = exu_io_exu2wb_bits_pclj; // @[singlecpu.scala 37:17]
  assign wb_io_exu2wb_bits_pcrs1 = exu_io_exu2wb_bits_pcrs1; // @[singlecpu.scala 37:17]
  assign wb_io_exu2wb_bits_datamemaddr = exu_io_exu2wb_bits_datamemaddr; // @[singlecpu.scala 37:17]
  assign wb_io_csrjump = idu_io_csrjump; // @[singlecpu.scala 55:19]
  assign wb_io_imm = idu_io_immout; // @[singlecpu.scala 53:19]
  assign wb_io_rs1 = idu_io_rs1out; // @[singlecpu.scala 54:19]
  assign wb_io_data = idu_io_rs2out; // @[singlecpu.scala 49:19]
  assign wb_io_wr = idu_io_memwr; // @[singlecpu.scala 50:19]
  assign wb_io_valid = idu_io_memrd; // @[singlecpu.scala 52:19]
  assign wb_io_wmask = idu_io_memctl; // @[singlecpu.scala 51:19]
  assign wb_io_csrwr = idu_io_wreg; // @[singlecpu.scala 41:19]
  assign wb_io_wpc = idu_io_wpc; // @[singlecpu.scala 43:19]
  assign wb_io_re = idu_io_read; // @[singlecpu.scala 42:19]
  assign wb_io_rs1data = idu_io_rs1out; // @[singlecpu.scala 44:19]
  assign wb_io_ecall = idu_io_ecall; // @[singlecpu.scala 45:19]
  assign wb_io_memen = idu_io_tomemorreg; // @[singlecpu.scala 48:19]
  assign wb_io_choosecsr = idu_io_choosecsr; // @[singlecpu.scala 47:19]
  assign endnpc_endflag = exu_io_end; // @[singlecpu.scala 75:21]
  assign endnpc_state = idu_io_end_state; // @[singlecpu.scala 76:21]
  assign insttrace_inst = ifu_io_instout; // @[singlecpu.scala 65:22]
  assign insttrace_pc = ifu_io_pc; // @[singlecpu.scala 66:22]
  assign insttrace_clock = clock; // @[singlecpu.scala 67:22]
  assign ftrace_inst = ifu_io_instout; // @[singlecpu.scala 69:20]
  assign ftrace_pc = ifu_io_pc; // @[singlecpu.scala 70:20]
  assign ftrace_nextpc = wb_io_nextpc; // @[singlecpu.scala 71:20]
  assign ftrace_jump = idu_io_ftrace; // @[singlecpu.scala 73:20]
  assign ftrace_clock = clock; // @[singlecpu.scala 72:20]
endmodule
module TOP(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [31:0] io_pc,
  output [31:0] io_nextpc
);
  wire  core_clock; // @[TOP.scala 13:20]
  wire  core_reset; // @[TOP.scala 13:20]
  wire [31:0] core_io_inst; // @[TOP.scala 13:20]
  wire [31:0] core_io_nextpc; // @[TOP.scala 13:20]
  wire [31:0] core_io_pc; // @[TOP.scala 13:20]
  Core core ( // @[TOP.scala 13:20]
    .clock(core_clock),
    .reset(core_reset),
    .io_inst(core_io_inst),
    .io_nextpc(core_io_nextpc),
    .io_pc(core_io_pc)
  );
  assign io_pc = core_io_pc; // @[TOP.scala 14:16]
  assign io_nextpc = core_io_nextpc; // @[TOP.scala 16:16]
  assign core_clock = clock;
  assign core_reset = reset;
  assign core_io_inst = io_inst; // @[TOP.scala 15:16]
endmodule
