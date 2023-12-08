module SourceDecoder(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [2:0]  io_format,
  output [4:0]  io_op
);
  wire [31:0] _T = io_inst & 32'h707f; // @[inst.scala 199:16]
  wire  _T_1 = 32'h13 == _T; // @[inst.scala 199:16]
  wire [31:0] _T_2 = io_inst & 32'hfff0707f; // @[inst.scala 206:22]
  wire  _T_3 = 32'h100073 == _T_2; // @[inst.scala 206:22]
  wire [31:0] _T_4 = io_inst & 32'h7f; // @[inst.scala 209:22]
  wire  _T_5 = 32'h6f == _T_4; // @[inst.scala 209:22]
  wire  _T_7 = 32'h67 == _T; // @[inst.scala 213:22]
  wire  _T_9 = 32'h2023 == _T; // @[inst.scala 217:22]
  wire  _T_11 = 32'h17 == _T_4; // @[inst.scala 221:22]
  wire [2:0] _GEN_0 = 32'h17 == _T_4 ? 3'h1 : 3'h6; // @[inst.scala 221:48 222:15 225:15]
  wire [4:0] _GEN_1 = 32'h17 == _T_4 ? 5'h1e : 5'h1f; // @[inst.scala 221:48 223:15 229:11]
  wire [2:0] _GEN_2 = 32'h2023 == _T ? 3'h1 : _GEN_0; // @[inst.scala 217:45 218:15]
  wire [4:0] _GEN_3 = 32'h2023 == _T ? 5'h1e : _GEN_1; // @[inst.scala 217:45 219:15]
  wire [2:0] _GEN_4 = 32'h67 == _T ? 3'h1 : _GEN_2; // @[inst.scala 213:47 214:15]
  wire [4:0] _GEN_5 = 32'h67 == _T ? 5'h1e : _GEN_3; // @[inst.scala 213:47 215:15]
  wire [2:0] _GEN_6 = 32'h6f == _T_4 ? 3'h1 : _GEN_4; // @[inst.scala 209:46 210:15]
  wire [4:0] _GEN_7 = 32'h6f == _T_4 ? 5'h1e : _GEN_5; // @[inst.scala 209:46 211:15]
  wire [2:0] _GEN_8 = 32'h100073 == _T_2 ? 3'h1 : _GEN_6; // @[inst.scala 206:49 207:15]
  wire [4:0] _GEN_9 = 32'h100073 == _T_2 ? 5'h1f : _GEN_7; // @[inst.scala 206:49 208:15]
  assign io_format = 32'h13 == _T ? 3'h1 : _GEN_8; // @[inst.scala 199:41 201:15]
  assign io_op = 32'h13 == _T ? 5'h0 : _GEN_9; // @[inst.scala 199:41 205:11]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~_T_1 & ~_T_3 & ~_T_5 & ~_T_7 & ~_T_9 & ~_T_11 & ~reset) begin
          $fwrite(32'h80000002,"Error: Unknown instruction!\n"); // @[inst.scala 230:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module ImmGen(
  input  [2:0]  io_format,
  input  [31:0] io_inst,
  output [31:0] io_out
);
  wire [31:0] _io_out_T_2 = {20'h0,io_inst[31:20]}; // @[Cat.scala 33:92]
  assign io_out = io_format == 3'h1 ? _io_out_T_2 : 32'h2; // @[inst.scala 242:30 243:12 245:12]
endmodule
module RegFile(
  input         clock,
  input         reset,
  input  [4:0]  io_rs1,
  input  [4:0]  io_rd,
  input         io_wr,
  input  [31:0] io_datain,
  output [31:0] io_rs1out
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
  reg [31:0] regfile_0; // @[inst.scala 260:24]
  reg [31:0] regfile_1; // @[inst.scala 260:24]
  reg [31:0] regfile_2; // @[inst.scala 260:24]
  reg [31:0] regfile_3; // @[inst.scala 260:24]
  reg [31:0] regfile_4; // @[inst.scala 260:24]
  reg [31:0] regfile_5; // @[inst.scala 260:24]
  reg [31:0] regfile_6; // @[inst.scala 260:24]
  reg [31:0] regfile_7; // @[inst.scala 260:24]
  reg [31:0] regfile_8; // @[inst.scala 260:24]
  reg [31:0] regfile_9; // @[inst.scala 260:24]
  reg [31:0] regfile_10; // @[inst.scala 260:24]
  reg [31:0] regfile_11; // @[inst.scala 260:24]
  reg [31:0] regfile_12; // @[inst.scala 260:24]
  reg [31:0] regfile_13; // @[inst.scala 260:24]
  reg [31:0] regfile_14; // @[inst.scala 260:24]
  reg [31:0] regfile_15; // @[inst.scala 260:24]
  reg [31:0] regfile_16; // @[inst.scala 260:24]
  reg [31:0] regfile_17; // @[inst.scala 260:24]
  reg [31:0] regfile_18; // @[inst.scala 260:24]
  reg [31:0] regfile_19; // @[inst.scala 260:24]
  reg [31:0] regfile_20; // @[inst.scala 260:24]
  reg [31:0] regfile_21; // @[inst.scala 260:24]
  reg [31:0] regfile_22; // @[inst.scala 260:24]
  reg [31:0] regfile_23; // @[inst.scala 260:24]
  reg [31:0] regfile_24; // @[inst.scala 260:24]
  reg [31:0] regfile_25; // @[inst.scala 260:24]
  reg [31:0] regfile_26; // @[inst.scala 260:24]
  reg [31:0] regfile_27; // @[inst.scala 260:24]
  reg [31:0] regfile_28; // @[inst.scala 260:24]
  reg [31:0] regfile_29; // @[inst.scala 260:24]
  reg [31:0] regfile_30; // @[inst.scala 260:24]
  reg [31:0] regfile_31; // @[inst.scala 260:24]
  wire [31:0] _GEN_65 = 5'h1 == io_rs1 ? regfile_1 : regfile_0; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_66 = 5'h2 == io_rs1 ? regfile_2 : _GEN_65; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_67 = 5'h3 == io_rs1 ? regfile_3 : _GEN_66; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_68 = 5'h4 == io_rs1 ? regfile_4 : _GEN_67; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_69 = 5'h5 == io_rs1 ? regfile_5 : _GEN_68; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_70 = 5'h6 == io_rs1 ? regfile_6 : _GEN_69; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_71 = 5'h7 == io_rs1 ? regfile_7 : _GEN_70; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_72 = 5'h8 == io_rs1 ? regfile_8 : _GEN_71; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_73 = 5'h9 == io_rs1 ? regfile_9 : _GEN_72; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_74 = 5'ha == io_rs1 ? regfile_10 : _GEN_73; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_75 = 5'hb == io_rs1 ? regfile_11 : _GEN_74; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_76 = 5'hc == io_rs1 ? regfile_12 : _GEN_75; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_77 = 5'hd == io_rs1 ? regfile_13 : _GEN_76; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_78 = 5'he == io_rs1 ? regfile_14 : _GEN_77; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_79 = 5'hf == io_rs1 ? regfile_15 : _GEN_78; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_80 = 5'h10 == io_rs1 ? regfile_16 : _GEN_79; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_81 = 5'h11 == io_rs1 ? regfile_17 : _GEN_80; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_82 = 5'h12 == io_rs1 ? regfile_18 : _GEN_81; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_83 = 5'h13 == io_rs1 ? regfile_19 : _GEN_82; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_84 = 5'h14 == io_rs1 ? regfile_20 : _GEN_83; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_85 = 5'h15 == io_rs1 ? regfile_21 : _GEN_84; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_86 = 5'h16 == io_rs1 ? regfile_22 : _GEN_85; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_87 = 5'h17 == io_rs1 ? regfile_23 : _GEN_86; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_88 = 5'h18 == io_rs1 ? regfile_24 : _GEN_87; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_89 = 5'h19 == io_rs1 ? regfile_25 : _GEN_88; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_90 = 5'h1a == io_rs1 ? regfile_26 : _GEN_89; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_91 = 5'h1b == io_rs1 ? regfile_27 : _GEN_90; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_92 = 5'h1c == io_rs1 ? regfile_28 : _GEN_91; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_93 = 5'h1d == io_rs1 ? regfile_29 : _GEN_92; // @[inst.scala 265:{13,13}]
  wire [31:0] _GEN_94 = 5'h1e == io_rs1 ? regfile_30 : _GEN_93; // @[inst.scala 265:{13,13}]
  assign io_rs1out = 5'h1f == io_rs1 ? regfile_31 : _GEN_94; // @[inst.scala 265:{13,13}]
  always @(posedge clock) begin
    if (reset) begin // @[inst.scala 260:24]
      regfile_0 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h0 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_0 <= 32'h0;
        end else begin
          regfile_0 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_1 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h1 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_1 <= 32'h0;
        end else begin
          regfile_1 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_2 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h2 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_2 <= 32'h0;
        end else begin
          regfile_2 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_3 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h3 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_3 <= 32'h0;
        end else begin
          regfile_3 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_4 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h4 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_4 <= 32'h0;
        end else begin
          regfile_4 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_5 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h5 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_5 <= 32'h0;
        end else begin
          regfile_5 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_6 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h6 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_6 <= 32'h0;
        end else begin
          regfile_6 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_7 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h7 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_7 <= 32'h0;
        end else begin
          regfile_7 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_8 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h8 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_8 <= 32'h0;
        end else begin
          regfile_8 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_9 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h9 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_9 <= 32'h0;
        end else begin
          regfile_9 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_10 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'ha == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_10 <= 32'h0;
        end else begin
          regfile_10 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_11 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'hb == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_11 <= 32'h0;
        end else begin
          regfile_11 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_12 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'hc == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_12 <= 32'h0;
        end else begin
          regfile_12 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_13 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'hd == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_13 <= 32'h0;
        end else begin
          regfile_13 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_14 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'he == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_14 <= 32'h0;
        end else begin
          regfile_14 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_15 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'hf == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_15 <= 32'h0;
        end else begin
          regfile_15 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_16 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h10 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_16 <= 32'h0;
        end else begin
          regfile_16 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_17 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h11 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_17 <= 32'h0;
        end else begin
          regfile_17 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_18 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h12 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_18 <= 32'h0;
        end else begin
          regfile_18 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_19 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h13 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_19 <= 32'h0;
        end else begin
          regfile_19 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_20 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h14 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_20 <= 32'h0;
        end else begin
          regfile_20 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_21 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h15 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_21 <= 32'h0;
        end else begin
          regfile_21 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_22 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h16 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_22 <= 32'h0;
        end else begin
          regfile_22 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_23 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h17 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_23 <= 32'h0;
        end else begin
          regfile_23 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_24 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h18 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_24 <= 32'h0;
        end else begin
          regfile_24 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_25 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h19 == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_25 <= 32'h0;
        end else begin
          regfile_25 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_26 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h1a == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_26 <= 32'h0;
        end else begin
          regfile_26 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_27 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h1b == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_27 <= 32'h0;
        end else begin
          regfile_27 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_28 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h1c == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_28 <= 32'h0;
        end else begin
          regfile_28 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_29 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h1d == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_29 <= 32'h0;
        end else begin
          regfile_29 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_30 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h1e == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
          regfile_30 <= 32'h0;
        end else begin
          regfile_30 <= io_datain;
        end
      end
    end
    if (reset) begin // @[inst.scala 260:24]
      regfile_31 <= 32'h0; // @[inst.scala 260:24]
    end else if (io_wr) begin // @[inst.scala 261:15]
      if (5'h1f == io_rd) begin // @[inst.scala 262:20]
        if (io_rd == 5'h0) begin // @[inst.scala 262:26]
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
  wire  _T = io_op == 5'h0; // @[inst.scala 168:14]
  wire [31:0] _io_out_T_1 = io_s1 + io_s2; // @[inst.scala 169:21]
  wire  _T_2 = ~reset; // @[inst.scala 171:11]
  wire  _T_3 = io_op == 5'h1f; // @[inst.scala 172:20]
  wire  _T_6 = io_op == 5'h1e; // @[inst.scala 177:20]
  wire  _GEN_6 = ~_T; // @[inst.scala 176:11]
  wire  _GEN_10 = _GEN_6 & ~_T_3; // @[inst.scala 180:11]
  assign io_out = io_op == 5'h0 ? _io_out_T_1 : 32'h0; // @[inst.scala 168:26 169:12]
  assign io_rw = io_op == 5'h0; // @[inst.scala 168:14]
  assign io_end = io_op == 5'h0 ? 1'h0 : _T_3; // @[inst.scala 166:10 168:26]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T & ~reset) begin
          $fwrite(32'h80000002,"add\n"); // @[inst.scala 171:11]
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
          $fwrite(32'h80000002,"ebreak!\n"); // @[inst.scala 176:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_6 & ~_T_3 & _T_6 & _T_2) begin
          $fwrite(32'h80000002,"instruction nop!\n"); // @[inst.scala 180:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_GEN_10 & ~_T_6 & _T_2) begin
          $fwrite(32'h80000002,"Error: Unknown instruction!\n"); // @[inst.scala 184:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module Exu(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [31:0] io_out
);
  wire  source_decoder_clock; // @[inst.scala 280:30]
  wire  source_decoder_reset; // @[inst.scala 280:30]
  wire [31:0] source_decoder_io_inst; // @[inst.scala 280:30]
  wire [2:0] source_decoder_io_format; // @[inst.scala 280:30]
  wire [4:0] source_decoder_io_op; // @[inst.scala 280:30]
  wire [2:0] immgen_io_format; // @[inst.scala 281:30]
  wire [31:0] immgen_io_inst; // @[inst.scala 281:30]
  wire [31:0] immgen_io_out; // @[inst.scala 281:30]
  wire  regfile_clock; // @[inst.scala 282:30]
  wire  regfile_reset; // @[inst.scala 282:30]
  wire [4:0] regfile_io_rs1; // @[inst.scala 282:30]
  wire [4:0] regfile_io_rd; // @[inst.scala 282:30]
  wire  regfile_io_wr; // @[inst.scala 282:30]
  wire [31:0] regfile_io_datain; // @[inst.scala 282:30]
  wire [31:0] regfile_io_rs1out; // @[inst.scala 282:30]
  wire  alu_clock; // @[inst.scala 286:19]
  wire  alu_reset; // @[inst.scala 286:19]
  wire [31:0] alu_io_s1; // @[inst.scala 286:19]
  wire [31:0] alu_io_s2; // @[inst.scala 286:19]
  wire [4:0] alu_io_op; // @[inst.scala 286:19]
  wire [31:0] alu_io_out; // @[inst.scala 286:19]
  wire  alu_io_rw; // @[inst.scala 286:19]
  wire  alu_io_end; // @[inst.scala 286:19]
  wire  endnpc_endflag; // @[inst.scala 288:22]
  SourceDecoder source_decoder ( // @[inst.scala 280:30]
    .clock(source_decoder_clock),
    .reset(source_decoder_reset),
    .io_inst(source_decoder_io_inst),
    .io_format(source_decoder_io_format),
    .io_op(source_decoder_io_op)
  );
  ImmGen immgen ( // @[inst.scala 281:30]
    .io_format(immgen_io_format),
    .io_inst(immgen_io_inst),
    .io_out(immgen_io_out)
  );
  RegFile regfile ( // @[inst.scala 282:30]
    .clock(regfile_clock),
    .reset(regfile_reset),
    .io_rs1(regfile_io_rs1),
    .io_rd(regfile_io_rd),
    .io_wr(regfile_io_wr),
    .io_datain(regfile_io_datain),
    .io_rs1out(regfile_io_rs1out)
  );
  Alu alu ( // @[inst.scala 286:19]
    .clock(alu_clock),
    .reset(alu_reset),
    .io_s1(alu_io_s1),
    .io_s2(alu_io_s2),
    .io_op(alu_io_op),
    .io_out(alu_io_out),
    .io_rw(alu_io_rw),
    .io_end(alu_io_end)
  );
  EndNpc endnpc ( // @[inst.scala 288:22]
    .endflag(endnpc_endflag)
  );
  assign io_out = alu_io_out; // @[inst.scala 324:10]
  assign source_decoder_clock = clock;
  assign source_decoder_reset = reset;
  assign source_decoder_io_inst = io_inst; // @[inst.scala 290:26]
  assign immgen_io_format = source_decoder_io_format; // @[inst.scala 299:20]
  assign immgen_io_inst = io_inst; // @[inst.scala 300:20]
  assign regfile_clock = clock;
  assign regfile_reset = reset;
  assign regfile_io_rs1 = io_inst[19:15]; // @[inst.scala 292:28]
  assign regfile_io_rd = io_inst[11:7]; // @[inst.scala 294:28]
  assign regfile_io_wr = alu_io_rw; // @[inst.scala 297:21]
  assign regfile_io_datain = alu_io_out; // @[inst.scala 296:21]
  assign alu_clock = clock;
  assign alu_reset = reset;
  assign alu_io_s1 = regfile_io_rs1out; // @[inst.scala 303:13]
  assign alu_io_s2 = immgen_io_out; // @[inst.scala 304:13]
  assign alu_io_op = source_decoder_io_op; // @[inst.scala 320:13]
  assign endnpc_endflag = alu_io_end; // @[inst.scala 306:21]
endmodule
module TOP(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [31:0] io_out,
  output [31:0] io_pc
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  wire  exu_clock; // @[TOP.scala 12:19]
  wire  exu_reset; // @[TOP.scala 12:19]
  wire [31:0] exu_io_inst; // @[TOP.scala 12:19]
  wire [31:0] exu_io_out; // @[TOP.scala 12:19]
  reg [31:0] pc; // @[TOP.scala 13:20]
  wire [31:0] _pc_T_1 = pc + 32'h4; // @[TOP.scala 14:21]
  Exu exu ( // @[TOP.scala 12:19]
    .clock(exu_clock),
    .reset(exu_reset),
    .io_inst(exu_io_inst),
    .io_out(exu_io_out)
  );
  assign io_out = exu_io_out; // @[TOP.scala 17:15]
  assign io_pc = pc; // @[TOP.scala 15:15]
  assign exu_clock = clock;
  assign exu_reset = reset;
  assign exu_io_inst = io_inst; // @[TOP.scala 16:15]
  always @(posedge clock) begin
    if (reset) begin // @[TOP.scala 13:20]
      pc <= 32'h80000000; // @[TOP.scala 13:20]
    end else begin
      pc <= _pc_T_1; // @[TOP.scala 14:15]
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
