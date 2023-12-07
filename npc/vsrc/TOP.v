module FormatDecoder(
  input  [6:0] input_,
  output [2:0] output_
);
  wire [4:0] output_plaInput = input_[4:0]; // @[decoder.scala 38:16 pla.scala 77:22]
  wire [4:0] output_invInputs = ~output_plaInput; // @[pla.scala 78:21]
  wire  output_andMatrixInput_0 = output_plaInput[0]; // @[pla.scala 90:45]
  wire  output_andMatrixInput_1 = output_plaInput[1]; // @[pla.scala 90:45]
  wire  output_andMatrixInput_2 = output_invInputs[2]; // @[pla.scala 91:29]
  wire  output_andMatrixInput_3 = output_invInputs[3]; // @[pla.scala 91:29]
  wire  output_andMatrixInput_4 = output_plaInput[4]; // @[pla.scala 90:45]
  wire [4:0] _output_T = {output_andMatrixInput_0,output_andMatrixInput_1,output_andMatrixInput_2,
    output_andMatrixInput_3,output_andMatrixInput_4}; // @[Cat.scala 33:92]
  wire  _output_T_1 = &_output_T; // @[pla.scala 98:74]
  wire  _output_orMatrixOutputs_T = |_output_T_1; // @[pla.scala 114:39]
  wire [2:0] output_orMatrixOutputs = {2'h0,_output_orMatrixOutputs_T}; // @[Cat.scala 33:92]
  wire [1:0] output_invMatrixOutputs_hi = {output_orMatrixOutputs[2],output_orMatrixOutputs[1]}; // @[Cat.scala 33:92]
  assign output_ = {output_invMatrixOutputs_hi,output_orMatrixOutputs[0]}; // @[Cat.scala 33:92]
endmodule
module ImmGen(
  input  [2:0]  io_format,
  input  [31:0] io_inst,
  output [31:0] io_out
);
  wire [31:0] _io_out_T_2 = {20'h0,io_inst[31:20]}; // @[Cat.scala 33:92]
  assign io_out = io_format == 3'h1 ? _io_out_T_2 : 32'h2; // @[TOP.scala 31:32 32:12 34:12]
endmodule
module Source_Decoder(
  input  [31:0] io_inst,
  output [4:0]  io_rs1,
  output [4:0]  io_rd
);
  assign io_rs1 = io_inst[19:15]; // @[TOP.scala 48:22]
  assign io_rd = io_inst[11:7]; // @[TOP.scala 50:22]
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
  reg [31:0] regfile_0; // @[TOP.scala 70:24]
  reg [31:0] regfile_1; // @[TOP.scala 70:24]
  reg [31:0] regfile_2; // @[TOP.scala 70:24]
  reg [31:0] regfile_3; // @[TOP.scala 70:24]
  reg [31:0] regfile_4; // @[TOP.scala 70:24]
  reg [31:0] regfile_5; // @[TOP.scala 70:24]
  reg [31:0] regfile_6; // @[TOP.scala 70:24]
  reg [31:0] regfile_7; // @[TOP.scala 70:24]
  reg [31:0] regfile_8; // @[TOP.scala 70:24]
  reg [31:0] regfile_9; // @[TOP.scala 70:24]
  reg [31:0] regfile_10; // @[TOP.scala 70:24]
  reg [31:0] regfile_11; // @[TOP.scala 70:24]
  reg [31:0] regfile_12; // @[TOP.scala 70:24]
  reg [31:0] regfile_13; // @[TOP.scala 70:24]
  reg [31:0] regfile_14; // @[TOP.scala 70:24]
  reg [31:0] regfile_15; // @[TOP.scala 70:24]
  reg [31:0] regfile_16; // @[TOP.scala 70:24]
  reg [31:0] regfile_17; // @[TOP.scala 70:24]
  reg [31:0] regfile_18; // @[TOP.scala 70:24]
  reg [31:0] regfile_19; // @[TOP.scala 70:24]
  reg [31:0] regfile_20; // @[TOP.scala 70:24]
  reg [31:0] regfile_21; // @[TOP.scala 70:24]
  reg [31:0] regfile_22; // @[TOP.scala 70:24]
  reg [31:0] regfile_23; // @[TOP.scala 70:24]
  reg [31:0] regfile_24; // @[TOP.scala 70:24]
  reg [31:0] regfile_25; // @[TOP.scala 70:24]
  reg [31:0] regfile_26; // @[TOP.scala 70:24]
  reg [31:0] regfile_27; // @[TOP.scala 70:24]
  reg [31:0] regfile_28; // @[TOP.scala 70:24]
  reg [31:0] regfile_29; // @[TOP.scala 70:24]
  reg [31:0] regfile_30; // @[TOP.scala 70:24]
  reg [31:0] regfile_31; // @[TOP.scala 70:24]
  wire [31:0] _GEN_65 = 5'h1 == io_rs1 ? regfile_1 : regfile_0; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_66 = 5'h2 == io_rs1 ? regfile_2 : _GEN_65; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_67 = 5'h3 == io_rs1 ? regfile_3 : _GEN_66; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_68 = 5'h4 == io_rs1 ? regfile_4 : _GEN_67; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_69 = 5'h5 == io_rs1 ? regfile_5 : _GEN_68; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_70 = 5'h6 == io_rs1 ? regfile_6 : _GEN_69; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_71 = 5'h7 == io_rs1 ? regfile_7 : _GEN_70; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_72 = 5'h8 == io_rs1 ? regfile_8 : _GEN_71; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_73 = 5'h9 == io_rs1 ? regfile_9 : _GEN_72; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_74 = 5'ha == io_rs1 ? regfile_10 : _GEN_73; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_75 = 5'hb == io_rs1 ? regfile_11 : _GEN_74; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_76 = 5'hc == io_rs1 ? regfile_12 : _GEN_75; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_77 = 5'hd == io_rs1 ? regfile_13 : _GEN_76; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_78 = 5'he == io_rs1 ? regfile_14 : _GEN_77; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_79 = 5'hf == io_rs1 ? regfile_15 : _GEN_78; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_80 = 5'h10 == io_rs1 ? regfile_16 : _GEN_79; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_81 = 5'h11 == io_rs1 ? regfile_17 : _GEN_80; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_82 = 5'h12 == io_rs1 ? regfile_18 : _GEN_81; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_83 = 5'h13 == io_rs1 ? regfile_19 : _GEN_82; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_84 = 5'h14 == io_rs1 ? regfile_20 : _GEN_83; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_85 = 5'h15 == io_rs1 ? regfile_21 : _GEN_84; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_86 = 5'h16 == io_rs1 ? regfile_22 : _GEN_85; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_87 = 5'h17 == io_rs1 ? regfile_23 : _GEN_86; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_88 = 5'h18 == io_rs1 ? regfile_24 : _GEN_87; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_89 = 5'h19 == io_rs1 ? regfile_25 : _GEN_88; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_90 = 5'h1a == io_rs1 ? regfile_26 : _GEN_89; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_91 = 5'h1b == io_rs1 ? regfile_27 : _GEN_90; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_92 = 5'h1c == io_rs1 ? regfile_28 : _GEN_91; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_93 = 5'h1d == io_rs1 ? regfile_29 : _GEN_92; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_94 = 5'h1e == io_rs1 ? regfile_30 : _GEN_93; // @[TOP.scala 77:{15,15}]
  wire [31:0] _GEN_95 = 5'h1f == io_rs1 ? regfile_31 : _GEN_94; // @[TOP.scala 77:{15,15}]
  assign io_rs1out = io_rs1 == 5'h0 ? 32'h0 : _GEN_95; // @[TOP.scala 74:24 75:15 77:15]
  always @(posedge clock) begin
    if (reset) begin // @[TOP.scala 70:24]
      regfile_0 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h0 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_0 <= 32'h0;
        end else begin
          regfile_0 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_1 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h1 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_1 <= 32'h0;
        end else begin
          regfile_1 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_2 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h2 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_2 <= 32'h0;
        end else begin
          regfile_2 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_3 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h3 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_3 <= 32'h0;
        end else begin
          regfile_3 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_4 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h4 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_4 <= 32'h0;
        end else begin
          regfile_4 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_5 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h5 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_5 <= 32'h0;
        end else begin
          regfile_5 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_6 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h6 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_6 <= 32'h0;
        end else begin
          regfile_6 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_7 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h7 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_7 <= 32'h0;
        end else begin
          regfile_7 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_8 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h8 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_8 <= 32'h0;
        end else begin
          regfile_8 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_9 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h9 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_9 <= 32'h0;
        end else begin
          regfile_9 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_10 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'ha == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_10 <= 32'h0;
        end else begin
          regfile_10 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_11 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'hb == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_11 <= 32'h0;
        end else begin
          regfile_11 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_12 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'hc == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_12 <= 32'h0;
        end else begin
          regfile_12 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_13 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'hd == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_13 <= 32'h0;
        end else begin
          regfile_13 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_14 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'he == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_14 <= 32'h0;
        end else begin
          regfile_14 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_15 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'hf == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_15 <= 32'h0;
        end else begin
          regfile_15 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_16 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h10 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_16 <= 32'h0;
        end else begin
          regfile_16 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_17 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h11 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_17 <= 32'h0;
        end else begin
          regfile_17 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_18 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h12 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_18 <= 32'h0;
        end else begin
          regfile_18 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_19 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h13 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_19 <= 32'h0;
        end else begin
          regfile_19 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_20 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h14 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_20 <= 32'h0;
        end else begin
          regfile_20 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_21 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h15 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_21 <= 32'h0;
        end else begin
          regfile_21 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_22 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h16 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_22 <= 32'h0;
        end else begin
          regfile_22 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_23 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h17 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_23 <= 32'h0;
        end else begin
          regfile_23 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_24 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h18 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_24 <= 32'h0;
        end else begin
          regfile_24 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_25 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h19 == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_25 <= 32'h0;
        end else begin
          regfile_25 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_26 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h1a == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_26 <= 32'h0;
        end else begin
          regfile_26 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_27 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h1b == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_27 <= 32'h0;
        end else begin
          regfile_27 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_28 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h1c == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_28 <= 32'h0;
        end else begin
          regfile_28 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_29 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h1d == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_29 <= 32'h0;
        end else begin
          regfile_29 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_30 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h1e == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
          regfile_30 <= 32'h0;
        end else begin
          regfile_30 <= io_datain;
        end
      end
    end
    if (reset) begin // @[TOP.scala 70:24]
      regfile_31 <= 32'h0; // @[TOP.scala 70:24]
    end else if (io_wr) begin // @[TOP.scala 71:15]
      if (5'h1f == io_rd) begin // @[TOP.scala 72:20]
        if (io_rd == 5'h0) begin // @[TOP.scala 72:26]
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
module Exu(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output        io_regw,
  output [31:0] io_regdata
);
  wire [6:0] formatdecoder_input_; // @[TOP.scala 99:29]
  wire [2:0] formatdecoder_output_; // @[TOP.scala 99:29]
  wire [2:0] immgen_io_format; // @[TOP.scala 100:29]
  wire [31:0] immgen_io_inst; // @[TOP.scala 100:29]
  wire [31:0] immgen_io_out; // @[TOP.scala 100:29]
  wire [31:0] sourcedecoder_io_inst; // @[TOP.scala 101:29]
  wire [4:0] sourcedecoder_io_rs1; // @[TOP.scala 101:29]
  wire [4:0] sourcedecoder_io_rd; // @[TOP.scala 101:29]
  wire  regfile_clock; // @[TOP.scala 102:29]
  wire  regfile_reset; // @[TOP.scala 102:29]
  wire [4:0] regfile_io_rs1; // @[TOP.scala 102:29]
  wire [4:0] regfile_io_rd; // @[TOP.scala 102:29]
  wire  regfile_io_wr; // @[TOP.scala 102:29]
  wire [31:0] regfile_io_datain; // @[TOP.scala 102:29]
  wire [31:0] regfile_io_rs1out; // @[TOP.scala 102:29]
  wire [31:0] _T = io_inst & 32'h707f; // @[TOP.scala 114:16]
  wire [31:0] _io_regdata_T_1 = regfile_io_rs1out + immgen_io_out; // @[TOP.scala 117:37]
  FormatDecoder formatdecoder ( // @[TOP.scala 99:29]
    .input_(formatdecoder_input_),
    .output_(formatdecoder_output_)
  );
  ImmGen immgen ( // @[TOP.scala 100:29]
    .io_format(immgen_io_format),
    .io_inst(immgen_io_inst),
    .io_out(immgen_io_out)
  );
  Source_Decoder sourcedecoder ( // @[TOP.scala 101:29]
    .io_inst(sourcedecoder_io_inst),
    .io_rs1(sourcedecoder_io_rs1),
    .io_rd(sourcedecoder_io_rd)
  );
  RegFile regfile ( // @[TOP.scala 102:29]
    .clock(regfile_clock),
    .reset(regfile_reset),
    .io_rs1(regfile_io_rs1),
    .io_rd(regfile_io_rd),
    .io_wr(regfile_io_wr),
    .io_datain(regfile_io_datain),
    .io_rs1out(regfile_io_rs1out)
  );
  assign io_regw = 32'h13 == _T; // @[TOP.scala 114:16]
  assign io_regdata = 32'h13 == _T ? _io_regdata_T_1 : 32'h0; // @[TOP.scala 114:41 117:16 122:23]
  assign formatdecoder_input_ = io_inst[6:0]; // @[TOP.scala 103:37]
  assign immgen_io_format = formatdecoder_output_; // @[TOP.scala 106:27]
  assign immgen_io_inst = io_inst; // @[TOP.scala 107:27]
  assign sourcedecoder_io_inst = io_inst; // @[TOP.scala 104:27]
  assign regfile_clock = clock;
  assign regfile_reset = reset;
  assign regfile_io_rs1 = sourcedecoder_io_rs1; // @[TOP.scala 108:27]
  assign regfile_io_rd = sourcedecoder_io_rd; // @[TOP.scala 110:27]
  assign regfile_io_wr = io_regw; // @[TOP.scala 111:27]
  assign regfile_io_datain = 32'h13 == _T ? io_regdata : 32'h0; // @[TOP.scala 112:27 114:41 121:23]
endmodule
module TOP(
  input         clock,
  input         reset,
  input  [31:0] io_inst,
  output [31:0] io_out
);
  wire  exu_clock; // @[TOP.scala 133:19]
  wire  exu_reset; // @[TOP.scala 133:19]
  wire [31:0] exu_io_inst; // @[TOP.scala 133:19]
  wire  exu_io_regw; // @[TOP.scala 133:19]
  wire [31:0] exu_io_regdata; // @[TOP.scala 133:19]
  Exu exu ( // @[TOP.scala 133:19]
    .clock(exu_clock),
    .reset(exu_reset),
    .io_inst(exu_io_inst),
    .io_regw(exu_io_regw),
    .io_regdata(exu_io_regdata)
  );
  assign io_out = exu_io_regdata; // @[TOP.scala 135:15]
  assign exu_clock = clock;
  assign exu_reset = reset;
  assign exu_io_inst = io_inst; // @[TOP.scala 134:15]
endmodule
