// Generated by CIRCT unknown git version
// Standard header to adapt well known macros to our needs.
`ifndef RANDOMIZE
  `ifdef RANDOMIZE_REG_INIT
    `define RANDOMIZE
  `endif // RANDOMIZE_REG_INIT
`endif // not def RANDOMIZE
`ifndef RANDOMIZE
  `ifdef RANDOMIZE_MEM_INIT
    `define RANDOMIZE
  `endif // RANDOMIZE_MEM_INIT
`endif // not def RANDOMIZE

// RANDOM may be set to an expression that produces a 32-bit random unsigned value.
`ifndef RANDOM
  `define RANDOM $random
`endif // not def RANDOM

// Users can define 'PRINTF_COND' to add an extra gate to prints.
`ifndef PRINTF_COND_
  `ifdef PRINTF_COND
    `define PRINTF_COND_ (`PRINTF_COND)
  `else  // PRINTF_COND
    `define PRINTF_COND_ 1
  `endif // PRINTF_COND
`endif // not def PRINTF_COND_

// Users can define 'ASSERT_VERBOSE_COND' to add an extra gate to assert error printing.
`ifndef ASSERT_VERBOSE_COND_
  `ifdef ASSERT_VERBOSE_COND
    `define ASSERT_VERBOSE_COND_ (`ASSERT_VERBOSE_COND)
  `else  // ASSERT_VERBOSE_COND
    `define ASSERT_VERBOSE_COND_ 1
  `endif // ASSERT_VERBOSE_COND
`endif // not def ASSERT_VERBOSE_COND_

// Users can define 'STOP_COND' to add an extra gate to stop conditions.
`ifndef STOP_COND_
  `ifdef STOP_COND
    `define STOP_COND_ (`STOP_COND)
  `else  // STOP_COND
    `define STOP_COND_ 1
  `endif // STOP_COND
`endif // not def STOP_COND_

// Users can define INIT_RANDOM as general code that gets injected into the
// initializer block for modules with registers.
`ifndef INIT_RANDOM
  `define INIT_RANDOM
`endif // not def INIT_RANDOM

// If using random initialization, you can also define RANDOMIZE_DELAY to
// customize the delay used, otherwise 0.002 is used.
`ifndef RANDOMIZE_DELAY
  `define RANDOMIZE_DELAY 0.002
`endif // not def RANDOMIZE_DELAY

// Define INIT_RANDOM_PROLOG_ for use in our modules below.
`ifndef INIT_RANDOM_PROLOG_
  `ifdef RANDOMIZE
    `ifdef VERILATOR
      `define INIT_RANDOM_PROLOG_ `INIT_RANDOM
    `else  // VERILATOR
      `define INIT_RANDOM_PROLOG_ `INIT_RANDOM #`RANDOMIZE_DELAY begin end
    `endif // VERILATOR
  `else  // RANDOMIZE
    `define INIT_RANDOM_PROLOG_
  `endif // RANDOMIZE
`endif // not def INIT_RANDOM_PROLOG_

module TLFIFOFixer_1_boom(
  input         clock,
                reset,
                auto_in_a_valid,
  input  [2:0]  auto_in_a_bits_opcode,
                auto_in_a_bits_size,
  input  [6:0]  auto_in_a_bits_source,
  input  [26:0] auto_in_a_bits_address,
  input  [7:0]  auto_in_a_bits_mask,
  input  [63:0] auto_in_a_bits_data,
  input         auto_in_d_ready,
                auto_out_a_ready,
                auto_out_d_valid,
  input  [2:0]  auto_out_d_bits_opcode,
  input  [1:0]  auto_out_d_bits_param,
  input  [2:0]  auto_out_d_bits_size,
  input  [6:0]  auto_out_d_bits_source,
  input         auto_out_d_bits_sink,
                auto_out_d_bits_denied,
  input  [63:0] auto_out_d_bits_data,
  input         auto_out_d_bits_corrupt,
  output        auto_in_a_ready,
                auto_in_d_valid,
  output [2:0]  auto_in_d_bits_opcode,
  output [1:0]  auto_in_d_bits_param,
  output [2:0]  auto_in_d_bits_size,
  output [6:0]  auto_in_d_bits_source,
  output        auto_in_d_bits_sink,
                auto_in_d_bits_denied,
  output [63:0] auto_in_d_bits_data,
  output        auto_in_d_bits_corrupt,
                auto_out_a_valid,
  output [2:0]  auto_out_a_bits_opcode,
                auto_out_a_bits_size,
  output [6:0]  auto_out_a_bits_source,
  output [26:0] auto_out_a_bits_address,
  output [7:0]  auto_out_a_bits_mask,
  output [63:0] auto_out_a_bits_data,
  output        auto_out_d_ready
);

  wire [1:0]  a_id = {auto_in_a_bits_address[26], ~(auto_in_a_bits_address[26])};	// @[Mux.scala:27:73, Parameters.scala:137:{45,65}]
  wire        a_noDomain = a_id == 2'h0;	// @[Bundles.scala:259:74, FIFOFixer.scala:57:29, Mux.scala:27:73]
  reg  [2:0]  a_first_counter;	// @[Edges.scala:229:27]
  wire        a_first = a_first_counter == 3'h0;	// @[Edges.scala:229:27, :231:25]
  reg  [2:0]  d_first_counter;	// @[Edges.scala:229:27]
  reg         flight_16;	// @[FIFOFixer.scala:73:27]
  reg         flight_17;	// @[FIFOFixer.scala:73:27]
  reg         flight_18;	// @[FIFOFixer.scala:73:27]
  reg         flight_19;	// @[FIFOFixer.scala:73:27]
  reg         flight_20;	// @[FIFOFixer.scala:73:27]
  reg         flight_21;	// @[FIFOFixer.scala:73:27]
  reg         flight_22;	// @[FIFOFixer.scala:73:27]
  reg         flight_23;	// @[FIFOFixer.scala:73:27]
  reg         flight_24;	// @[FIFOFixer.scala:73:27]
  reg         flight_25;	// @[FIFOFixer.scala:73:27]
  reg         flight_26;	// @[FIFOFixer.scala:73:27]
  reg         flight_27;	// @[FIFOFixer.scala:73:27]
  reg         flight_28;	// @[FIFOFixer.scala:73:27]
  reg         flight_29;	// @[FIFOFixer.scala:73:27]
  reg         flight_30;	// @[FIFOFixer.scala:73:27]
  reg         flight_31;	// @[FIFOFixer.scala:73:27]
  wire        stalls_a_sel = auto_in_a_bits_source[6:3] == 4'h2;	// @[Parameters.scala:54:{10,32}]
  reg  [1:0]  stalls_id;	// @[Reg.scala:19:16]
  wire        stalls_a_sel_1 = auto_in_a_bits_source[6:3] == 4'h3;	// @[Parameters.scala:54:{10,32}]
  reg  [1:0]  stalls_id_1;	// @[Reg.scala:19:16]
  wire        stall = stalls_a_sel & a_first & (flight_16 | flight_17 | flight_18 | flight_19 | flight_20 | flight_21 | flight_22 | flight_23) & (a_noDomain | stalls_id != a_id) | stalls_a_sel_1 & a_first & (flight_24 | flight_25 | flight_26 | flight_27 | flight_28 | flight_29 | flight_30 | flight_31) & (a_noDomain | stalls_id_1 != a_id);	// @[Edges.scala:231:25, FIFOFixer.scala:57:29, :73:27, :82:{44,50,65,71}, :85:45, Mux.scala:27:73, Parameters.scala:54:32, Reg.scala:19:16]
  wire        bundleIn_0_a_ready = auto_out_a_ready & ~stall;	// @[FIFOFixer.scala:85:45, :89:50, :90:33]
  wire [12:0] _a_first_beats1_decode_T_1 = 13'h3F << auto_in_a_bits_size;	// @[package.scala:235:71]
  wire [12:0] _d_first_beats1_decode_T_1 = 13'h3F << auto_out_d_bits_size;	// @[package.scala:235:71]
  wire        d_first_first = d_first_counter == 3'h0;	// @[Edges.scala:229:27, :231:25]
  wire        _T_3 = d_first_first & auto_out_d_bits_opcode != 3'h6 & auto_in_d_ready & auto_out_d_valid;	// @[Edges.scala:231:25, FIFOFixer.scala:69:63, :75:21]
  wire        _T_5 = bundleIn_0_a_ready & auto_in_a_valid;	// @[Decoupled.scala:51:35, FIFOFixer.scala:90:33]
  wire        _T_1 = a_first & _T_5;	// @[Decoupled.scala:51:35, Edges.scala:231:25, FIFOFixer.scala:74:21]
  always @(posedge clock) begin
    if (reset) begin
      a_first_counter <= 3'h0;	// @[Edges.scala:229:27]
      d_first_counter <= 3'h0;	// @[Edges.scala:229:27]
      flight_16 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_17 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_18 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_19 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_20 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_21 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_22 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_23 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_24 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_25 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_26 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_27 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_28 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_29 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_30 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
      flight_31 <= 1'h0;	// @[FIFOFixer.scala:73:27, Parameters.scala:137:31]
    end
    else begin
      if (_T_5) begin	// @[Decoupled.scala:51:35]
        if (a_first) begin	// @[Edges.scala:231:25]
          if (auto_in_a_bits_opcode[2])	// @[Edges.scala:92:37]
            a_first_counter <= 3'h0;	// @[Edges.scala:229:27]
          else	// @[Edges.scala:92:37]
            a_first_counter <= ~(_a_first_beats1_decode_T_1[5:3]);	// @[Edges.scala:229:27, package.scala:235:{46,71,76}]
        end
        else	// @[Edges.scala:231:25]
          a_first_counter <= a_first_counter - 3'h1;	// @[Edges.scala:229:27, :230:28]
      end
      if (auto_in_d_ready & auto_out_d_valid) begin	// @[Decoupled.scala:51:35]
        if (d_first_first) begin	// @[Edges.scala:231:25]
          if (auto_out_d_bits_opcode[0])	// @[Edges.scala:106:36]
            d_first_counter <= ~(_d_first_beats1_decode_T_1[5:3]);	// @[Edges.scala:229:27, package.scala:235:{46,71,76}]
          else	// @[Edges.scala:106:36]
            d_first_counter <= 3'h0;	// @[Edges.scala:229:27]
        end
        else	// @[Edges.scala:231:25]
          d_first_counter <= d_first_counter - 3'h1;	// @[Edges.scala:229:27, :230:28]
      end
      flight_16 <= ~(_T_3 & auto_out_d_bits_source == 7'h10) & (_T_1 & auto_in_a_bits_source == 7'h10 | flight_16);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_17 <= ~(_T_3 & auto_out_d_bits_source == 7'h11) & (_T_1 & auto_in_a_bits_source == 7'h11 | flight_17);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_18 <= ~(_T_3 & auto_out_d_bits_source == 7'h12) & (_T_1 & auto_in_a_bits_source == 7'h12 | flight_18);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_19 <= ~(_T_3 & auto_out_d_bits_source == 7'h13) & (_T_1 & auto_in_a_bits_source == 7'h13 | flight_19);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_20 <= ~(_T_3 & auto_out_d_bits_source == 7'h14) & (_T_1 & auto_in_a_bits_source == 7'h14 | flight_20);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_21 <= ~(_T_3 & auto_out_d_bits_source == 7'h15) & (_T_1 & auto_in_a_bits_source == 7'h15 | flight_21);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_22 <= ~(_T_3 & auto_out_d_bits_source == 7'h16) & (_T_1 & auto_in_a_bits_source == 7'h16 | flight_22);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_23 <= ~(_T_3 & auto_out_d_bits_source == 7'h17) & (_T_1 & auto_in_a_bits_source == 7'h17 | flight_23);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_24 <= ~(_T_3 & auto_out_d_bits_source == 7'h18) & (_T_1 & auto_in_a_bits_source == 7'h18 | flight_24);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_25 <= ~(_T_3 & auto_out_d_bits_source == 7'h19) & (_T_1 & auto_in_a_bits_source == 7'h19 | flight_25);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_26 <= ~(_T_3 & auto_out_d_bits_source == 7'h1A) & (_T_1 & auto_in_a_bits_source == 7'h1A | flight_26);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_27 <= ~(_T_3 & auto_out_d_bits_source == 7'h1B) & (_T_1 & auto_in_a_bits_source == 7'h1B | flight_27);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_28 <= ~(_T_3 & auto_out_d_bits_source == 7'h1C) & (_T_1 & auto_in_a_bits_source == 7'h1C | flight_28);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_29 <= ~(_T_3 & auto_out_d_bits_source == 7'h1D) & (_T_1 & auto_in_a_bits_source == 7'h1D | flight_29);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_30 <= ~(_T_3 & auto_out_d_bits_source == 7'h1E) & (_T_1 & auto_in_a_bits_source == 7'h1E | flight_30);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
      flight_31 <= ~(_T_3 & auto_out_d_bits_source == 7'h1F) & (_T_1 & auto_in_a_bits_source == 7'h1F | flight_31);	// @[FIFOFixer.scala:73:27, :74:{21,35,62}, :75:{21,35,62}]
    end
    if (_T_5 & stalls_a_sel)	// @[Decoupled.scala:51:35, FIFOFixer.scala:79:47, Parameters.scala:54:32]
      stalls_id <= a_id;	// @[Mux.scala:27:73, Reg.scala:19:16]
    if (_T_5 & stalls_a_sel_1)	// @[Decoupled.scala:51:35, FIFOFixer.scala:79:47, Parameters.scala:54:32]
      stalls_id_1 <= a_id;	// @[Mux.scala:27:73, Reg.scala:19:16]
  end // always @(posedge)
  `ifndef SYNTHESIS
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif // FIRRTL_BEFORE_INITIAL
    logic [31:0] _RANDOM_0;
    logic [31:0] _RANDOM_1;
    logic [31:0] _RANDOM_2;
    initial begin
      `ifdef INIT_RANDOM_PROLOG_
        `INIT_RANDOM_PROLOG_
      `endif // INIT_RANDOM_PROLOG_
      `ifdef RANDOMIZE_REG_INIT
        _RANDOM_0 = `RANDOM;
        _RANDOM_1 = `RANDOM;
        _RANDOM_2 = `RANDOM;
        a_first_counter = _RANDOM_0[2:0];	// @[Edges.scala:229:27]
        d_first_counter = _RANDOM_0[5:3];	// @[Edges.scala:229:27]
        flight_16 = _RANDOM_0[22];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_17 = _RANDOM_0[23];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_18 = _RANDOM_0[24];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_19 = _RANDOM_0[25];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_20 = _RANDOM_0[26];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_21 = _RANDOM_0[27];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_22 = _RANDOM_0[28];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_23 = _RANDOM_0[29];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_24 = _RANDOM_0[30];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_25 = _RANDOM_0[31];	// @[Edges.scala:229:27, FIFOFixer.scala:73:27]
        flight_26 = _RANDOM_1[0];	// @[FIFOFixer.scala:73:27]
        flight_27 = _RANDOM_1[1];	// @[FIFOFixer.scala:73:27]
        flight_28 = _RANDOM_1[2];	// @[FIFOFixer.scala:73:27]
        flight_29 = _RANDOM_1[3];	// @[FIFOFixer.scala:73:27]
        flight_30 = _RANDOM_1[4];	// @[FIFOFixer.scala:73:27]
        flight_31 = _RANDOM_1[5];	// @[FIFOFixer.scala:73:27]
        stalls_id = _RANDOM_2[8:7];	// @[Reg.scala:19:16]
        stalls_id_1 = _RANDOM_2[10:9];	// @[Reg.scala:19:16]
      `endif // RANDOMIZE_REG_INIT
    end // initial
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif // FIRRTL_AFTER_INITIAL
  `endif // not def SYNTHESIS
  assign auto_in_a_ready = bundleIn_0_a_ready;	// @[FIFOFixer.scala:90:33]
  assign auto_in_d_valid = auto_out_d_valid;
  assign auto_in_d_bits_opcode = auto_out_d_bits_opcode;
  assign auto_in_d_bits_param = auto_out_d_bits_param;
  assign auto_in_d_bits_size = auto_out_d_bits_size;
  assign auto_in_d_bits_source = auto_out_d_bits_source;
  assign auto_in_d_bits_sink = auto_out_d_bits_sink;
  assign auto_in_d_bits_denied = auto_out_d_bits_denied;
  assign auto_in_d_bits_data = auto_out_d_bits_data;
  assign auto_in_d_bits_corrupt = auto_out_d_bits_corrupt;
  assign auto_out_a_valid = auto_in_a_valid & ~stall;	// @[FIFOFixer.scala:85:45, :89:{33,50}]
  assign auto_out_a_bits_opcode = auto_in_a_bits_opcode;
  assign auto_out_a_bits_size = auto_in_a_bits_size;
  assign auto_out_a_bits_source = auto_in_a_bits_source;
  assign auto_out_a_bits_address = auto_in_a_bits_address;
  assign auto_out_a_bits_mask = auto_in_a_bits_mask;
  assign auto_out_a_bits_data = auto_in_a_bits_data;
  assign auto_out_d_ready = auto_in_d_ready;
endmodule
