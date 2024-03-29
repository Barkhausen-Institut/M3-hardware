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

module RenameFreeList_boom(
  input        clock,
               reset,
               io_reqs_0,
               io_reqs_1,
               io_dealloc_pregs_0_valid,
  input  [6:0] io_dealloc_pregs_0_bits,
  input        io_dealloc_pregs_1_valid,
  input  [6:0] io_dealloc_pregs_1_bits,
  input        io_ren_br_tags_0_valid,
  input  [3:0] io_ren_br_tags_0_bits,
  input        io_ren_br_tags_1_valid,
  input  [3:0] io_ren_br_tags_1_bits,
               io_brupdate_b2_uop_br_tag,
  input        io_brupdate_b2_mispredict,
               io_debug_pipeline_empty,
  output       io_alloc_pregs_0_valid,
  output [6:0] io_alloc_pregs_0_bits,
  output       io_alloc_pregs_1_valid,
  output [6:0] io_alloc_pregs_1_bits
);

  reg  [6:0]        r_sel_1;	// @[Reg.scala:19:16]
  reg  [6:0]        r_sel;	// @[Reg.scala:19:16]
  reg  [79:0]       free_list;	// @[rename-freelist.scala:50:26]
  reg  [79:0]       br_alloc_lists_0;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_1;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_2;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_3;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_4;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_5;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_6;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_7;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_8;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_9;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_10;	// @[rename-freelist.scala:51:27]
  reg  [79:0]       br_alloc_lists_11;	// @[rename-freelist.scala:51:27]
  wire [79:0]       sels_0 =
    free_list[0]
      ? 80'h1
      : free_list[1]
          ? 80'h2
          : free_list[2]
              ? 80'h4
              : free_list[3]
                  ? 80'h8
                  : free_list[4]
                      ? 80'h10
                      : free_list[5]
                          ? 80'h20
                          : free_list[6]
                              ? 80'h40
                              : free_list[7]
                                  ? 80'h80
                                  : free_list[8]
                                      ? 80'h100
                                      : free_list[9]
                                          ? 80'h200
                                          : free_list[10]
                                              ? 80'h400
                                              : free_list[11]
                                                  ? 80'h800
                                                  : free_list[12]
                                                      ? 80'h1000
                                                      : free_list[13]
                                                          ? 80'h2000
                                                          : free_list[14]
                                                              ? 80'h4000
                                                              : free_list[15]
                                                                  ? 80'h8000
                                                                  : free_list[16]
                                                                      ? 80'h10000
                                                                      : free_list[17]
                                                                          ? 80'h20000
                                                                          : free_list[18]
                                                                              ? 80'h40000
                                                                              : free_list[19]
                                                                                  ? 80'h80000
                                                                                  : free_list[20]
                                                                                      ? 80'h100000
                                                                                      : free_list[21]
                                                                                          ? 80'h200000
                                                                                          : free_list[22]
                                                                                              ? 80'h400000
                                                                                              : free_list[23]
                                                                                                  ? 80'h800000
                                                                                                  : free_list[24]
                                                                                                      ? 80'h1000000
                                                                                                      : free_list[25]
                                                                                                          ? 80'h2000000
                                                                                                          : free_list[26]
                                                                                                              ? 80'h4000000
                                                                                                              : free_list[27] ? 80'h8000000 : free_list[28] ? 80'h10000000 : free_list[29] ? 80'h20000000 : free_list[30] ? 80'h40000000 : free_list[31] ? 80'h80000000 : free_list[32] ? 80'h100000000 : free_list[33] ? 80'h200000000 : free_list[34] ? 80'h400000000 : free_list[35] ? 80'h800000000 : free_list[36] ? 80'h1000000000 : free_list[37] ? 80'h2000000000 : free_list[38] ? 80'h4000000000 : free_list[39] ? 80'h8000000000 : free_list[40] ? 80'h10000000000 : free_list[41] ? 80'h20000000000 : free_list[42] ? 80'h40000000000 : free_list[43] ? 80'h80000000000 : free_list[44] ? 80'h100000000000 : free_list[45] ? 80'h200000000000 : free_list[46] ? 80'h400000000000 : free_list[47] ? 80'h800000000000 : free_list[48] ? 80'h1000000000000 : free_list[49] ? 80'h2000000000000 : free_list[50] ? 80'h4000000000000 : free_list[51] ? 80'h8000000000000 : free_list[52] ? 80'h10000000000000 : free_list[53] ? 80'h20000000000000 : free_list[54] ? 80'h40000000000000 : free_list[55] ? 80'h80000000000000 : free_list[56] ? 80'h100000000000000 : free_list[57] ? 80'h200000000000000 : free_list[58] ? 80'h400000000000000 : free_list[59] ? 80'h800000000000000 : free_list[60] ? 80'h1000000000000000 : free_list[61] ? 80'h2000000000000000 : free_list[62] ? 80'h4000000000000000 : free_list[63] ? 80'h8000000000000000 : free_list[64] ? 80'h10000000000000000 : free_list[65] ? 80'h20000000000000000 : free_list[66] ? 80'h40000000000000000 : free_list[67] ? 80'h80000000000000000 : free_list[68] ? 80'h100000000000000000 : free_list[69] ? 80'h200000000000000000 : free_list[70] ? 80'h400000000000000000 : free_list[71] ? 80'h800000000000000000 : free_list[72] ? 80'h1000000000000000000 : free_list[73] ? 80'h2000000000000000000 : free_list[74] ? 80'h4000000000000000000 : free_list[75] ? 80'h8000000000000000000 : free_list[76] ? 80'h10000000000000000000 : free_list[77] ? 80'h20000000000000000000 : free_list[78] ? 80'h40000000000000000000 : {free_list[79], 79'h0};	// @[Mux.scala:47:70, OneHot.scala:84:71, rename-freelist.scala:50:{26,45}]
  wire [79:0]       _sels_T_1 = free_list & ~sels_0;	// @[Mux.scala:47:70, rename-freelist.scala:50:26, util.scala:410:{19,21}]
  wire [79:0]       sels_1 =
    _sels_T_1[0]
      ? 80'h1
      : _sels_T_1[1]
          ? 80'h2
          : _sels_T_1[2]
              ? 80'h4
              : _sels_T_1[3]
                  ? 80'h8
                  : _sels_T_1[4]
                      ? 80'h10
                      : _sels_T_1[5]
                          ? 80'h20
                          : _sels_T_1[6]
                              ? 80'h40
                              : _sels_T_1[7]
                                  ? 80'h80
                                  : _sels_T_1[8]
                                      ? 80'h100
                                      : _sels_T_1[9]
                                          ? 80'h200
                                          : _sels_T_1[10]
                                              ? 80'h400
                                              : _sels_T_1[11]
                                                  ? 80'h800
                                                  : _sels_T_1[12]
                                                      ? 80'h1000
                                                      : _sels_T_1[13]
                                                          ? 80'h2000
                                                          : _sels_T_1[14]
                                                              ? 80'h4000
                                                              : _sels_T_1[15]
                                                                  ? 80'h8000
                                                                  : _sels_T_1[16]
                                                                      ? 80'h10000
                                                                      : _sels_T_1[17]
                                                                          ? 80'h20000
                                                                          : _sels_T_1[18]
                                                                              ? 80'h40000
                                                                              : _sels_T_1[19]
                                                                                  ? 80'h80000
                                                                                  : _sels_T_1[20]
                                                                                      ? 80'h100000
                                                                                      : _sels_T_1[21]
                                                                                          ? 80'h200000
                                                                                          : _sels_T_1[22]
                                                                                              ? 80'h400000
                                                                                              : _sels_T_1[23]
                                                                                                  ? 80'h800000
                                                                                                  : _sels_T_1[24]
                                                                                                      ? 80'h1000000
                                                                                                      : _sels_T_1[25]
                                                                                                          ? 80'h2000000
                                                                                                          : _sels_T_1[26]
                                                                                                              ? 80'h4000000
                                                                                                              : _sels_T_1[27] ? 80'h8000000 : _sels_T_1[28] ? 80'h10000000 : _sels_T_1[29] ? 80'h20000000 : _sels_T_1[30] ? 80'h40000000 : _sels_T_1[31] ? 80'h80000000 : _sels_T_1[32] ? 80'h100000000 : _sels_T_1[33] ? 80'h200000000 : _sels_T_1[34] ? 80'h400000000 : _sels_T_1[35] ? 80'h800000000 : _sels_T_1[36] ? 80'h1000000000 : _sels_T_1[37] ? 80'h2000000000 : _sels_T_1[38] ? 80'h4000000000 : _sels_T_1[39] ? 80'h8000000000 : _sels_T_1[40] ? 80'h10000000000 : _sels_T_1[41] ? 80'h20000000000 : _sels_T_1[42] ? 80'h40000000000 : _sels_T_1[43] ? 80'h80000000000 : _sels_T_1[44] ? 80'h100000000000 : _sels_T_1[45] ? 80'h200000000000 : _sels_T_1[46] ? 80'h400000000000 : _sels_T_1[47] ? 80'h800000000000 : _sels_T_1[48] ? 80'h1000000000000 : _sels_T_1[49] ? 80'h2000000000000 : _sels_T_1[50] ? 80'h4000000000000 : _sels_T_1[51] ? 80'h8000000000000 : _sels_T_1[52] ? 80'h10000000000000 : _sels_T_1[53] ? 80'h20000000000000 : _sels_T_1[54] ? 80'h40000000000000 : _sels_T_1[55] ? 80'h80000000000000 : _sels_T_1[56] ? 80'h100000000000000 : _sels_T_1[57] ? 80'h200000000000000 : _sels_T_1[58] ? 80'h400000000000000 : _sels_T_1[59] ? 80'h800000000000000 : _sels_T_1[60] ? 80'h1000000000000000 : _sels_T_1[61] ? 80'h2000000000000000 : _sels_T_1[62] ? 80'h4000000000000000 : _sels_T_1[63] ? 80'h8000000000000000 : _sels_T_1[64] ? 80'h10000000000000000 : _sels_T_1[65] ? 80'h20000000000000000 : _sels_T_1[66] ? 80'h40000000000000000 : _sels_T_1[67] ? 80'h80000000000000000 : _sels_T_1[68] ? 80'h100000000000000000 : _sels_T_1[69] ? 80'h200000000000000000 : _sels_T_1[70] ? 80'h400000000000000000 : _sels_T_1[71] ? 80'h800000000000000000 : _sels_T_1[72] ? 80'h1000000000000000000 : _sels_T_1[73] ? 80'h2000000000000000000 : _sels_T_1[74] ? 80'h4000000000000000000 : _sels_T_1[75] ? 80'h8000000000000000000 : _sels_T_1[76] ? 80'h10000000000000000000 : _sels_T_1[77] ? 80'h20000000000000000000 : _sels_T_1[78] ? 80'h40000000000000000000 : {_sels_T_1[79], 79'h0};	// @[Mux.scala:47:70, OneHot.scala:84:71, rename-freelist.scala:50:45, util.scala:410:19]
  wire [127:0]      allocs_0 = 128'h1 << r_sel;	// @[OneHot.scala:57:35, Reg.scala:19:16]
  wire [127:0]      allocs_1 = 128'h1 << r_sel_1;	// @[OneHot.scala:57:35, Reg.scala:19:16]
  wire [15:0][79:0] _GEN = {{br_alloc_lists_0}, {br_alloc_lists_0}, {br_alloc_lists_0}, {br_alloc_lists_0}, {br_alloc_lists_11}, {br_alloc_lists_10}, {br_alloc_lists_9}, {br_alloc_lists_8}, {br_alloc_lists_7}, {br_alloc_lists_6}, {br_alloc_lists_5}, {br_alloc_lists_4}, {br_alloc_lists_3}, {br_alloc_lists_2}, {br_alloc_lists_1}, {br_alloc_lists_0}};	// @[rename-freelist.scala:51:27, :63:63]
  wire [79:0]       br_deallocs = _GEN[io_brupdate_b2_uop_br_tag] & {80{io_brupdate_b2_mispredict}};	// @[Bitwise.scala:77:12, rename-freelist.scala:63:63]
  wire [127:0]      _dealloc_mask_T = 128'h1 << io_dealloc_pregs_0_bits;	// @[OneHot.scala:57:35]
  wire [127:0]      _dealloc_mask_T_5 = 128'h1 << io_dealloc_pregs_1_bits;	// @[OneHot.scala:57:35]
  wire [79:0]       dealloc_mask = _dealloc_mask_T[79:0] & {80{io_dealloc_pregs_0_valid}} | _dealloc_mask_T_5[79:0] & {80{io_dealloc_pregs_1_valid}} | br_deallocs;	// @[Bitwise.scala:77:12, OneHot.scala:57:35, rename-freelist.scala:63:63, :64:{64,79,110}]
  reg               r_valid;	// @[rename-freelist.scala:81:26]
  wire              sel_fire_0 = (~r_valid | io_reqs_0) & (|sels_0);	// @[Mux.scala:47:70, rename-freelist.scala:80:27, :81:26, :85:{21,30,45}]
  reg               r_valid_1;	// @[rename-freelist.scala:81:26]
  wire              sel_fire_1 = (~r_valid_1 | io_reqs_1) & (|sels_1);	// @[Mux.scala:47:70, rename-freelist.scala:80:27, :81:26, :85:{21,30,45}]
  wire [62:0]       _GEN_0 = {48'h0, sels_0[79:65]} | sels_0[63:1];	// @[Mux.scala:47:70, OneHot.scala:31:18, :32:28, rename-freelist.scala:59:88]
  wire [30:0]       _GEN_1 = _GEN_0[62:32] | _GEN_0[30:0];	// @[OneHot.scala:30:18, :31:18, :32:28]
  wire [14:0]       _GEN_2 = _GEN_1[30:16] | _GEN_1[14:0];	// @[OneHot.scala:30:18, :31:18, :32:28]
  wire [6:0]        _GEN_3 = _GEN_2[14:8] | _GEN_2[6:0];	// @[OneHot.scala:30:18, :31:18, :32:28]
  wire [2:0]        _GEN_4 = _GEN_3[6:4] | _GEN_3[2:0];	// @[OneHot.scala:30:18, :31:18, :32:28]
  wire [62:0]       _GEN_5 = {48'h0, sels_1[79:65]} | sels_1[63:1];	// @[Mux.scala:47:70, OneHot.scala:31:18, :32:28, rename-freelist.scala:59:88]
  wire [30:0]       _GEN_6 = _GEN_5[62:32] | _GEN_5[30:0];	// @[OneHot.scala:30:18, :31:18, :32:28]
  wire [14:0]       _GEN_7 = _GEN_6[30:16] | _GEN_6[14:0];	// @[OneHot.scala:30:18, :31:18, :32:28]
  wire [6:0]        _GEN_8 = _GEN_7[14:8] | _GEN_7[6:0];	// @[OneHot.scala:30:18, :31:18, :32:28]
  wire [2:0]        _GEN_9 = _GEN_8[6:4] | _GEN_8[2:0];	// @[OneHot.scala:30:18, :31:18, :32:28]
  wire [79:0]       _GEN_10 = allocs_1[79:0] & {80{io_reqs_1}};	// @[Bitwise.scala:77:12, OneHot.scala:57:35, rename-freelist.scala:59:88]
  wire [79:0]       _GEN_11 = _GEN_10 | allocs_0[79:0] & {80{io_reqs_0}};	// @[Bitwise.scala:77:12, OneHot.scala:57:35, rename-freelist.scala:59:{84,88}]
  wire [1:0]        br_slots = {io_ren_br_tags_1_valid, io_ren_br_tags_0_valid};	// @[rename-freelist.scala:66:64]
  wire [1:0]        list_req = {io_ren_br_tags_1_bits == 4'h0, io_ren_br_tags_0_bits == 4'h0} & br_slots;	// @[rename-freelist.scala:63:63, :66:64, :69:{72,78,85}]
  wire [1:0]        list_req_1 = {io_ren_br_tags_1_bits == 4'h1, io_ren_br_tags_0_bits == 4'h1} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_2 = {io_ren_br_tags_1_bits == 4'h2, io_ren_br_tags_0_bits == 4'h2} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_3 = {io_ren_br_tags_1_bits == 4'h3, io_ren_br_tags_0_bits == 4'h3} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_4 = {io_ren_br_tags_1_bits == 4'h4, io_ren_br_tags_0_bits == 4'h4} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_5 = {io_ren_br_tags_1_bits == 4'h5, io_ren_br_tags_0_bits == 4'h5} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_6 = {io_ren_br_tags_1_bits == 4'h6, io_ren_br_tags_0_bits == 4'h6} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_7 = {io_ren_br_tags_1_bits == 4'h7, io_ren_br_tags_0_bits == 4'h7} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_8 = {io_ren_br_tags_1_bits == 4'h8, io_ren_br_tags_0_bits == 4'h8} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_9 = {io_ren_br_tags_1_bits == 4'h9, io_ren_br_tags_0_bits == 4'h9} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_10 = {io_ren_br_tags_1_bits == 4'hA, io_ren_br_tags_0_bits == 4'hA} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  wire [1:0]        list_req_11 = {io_ren_br_tags_1_bits == 4'hB, io_ren_br_tags_0_bits == 4'hB} & br_slots;	// @[OneHot.scala:57:35, rename-freelist.scala:66:64, :69:{72,78,85}]
  always @(posedge clock) begin
    if (reset) begin
      free_list <= 80'hFFFFFFFFFFFFFFFFFFFE;	// @[rename-freelist.scala:50:{26,45}]
      r_valid <= 1'h0;	// @[rename-freelist.scala:51:27, :81:26]
      r_valid_1 <= 1'h0;	// @[rename-freelist.scala:51:27, :81:26]
    end
    else begin
      free_list <= (free_list & ~(sels_0 & {80{sel_fire_0}} | sels_1 & {80{sel_fire_1}}) | dealloc_mask) & 80'hFFFFFFFFFFFFFFFFFFFE;	// @[Bitwise.scala:77:12, Mux.scala:47:70, rename-freelist.scala:50:{26,45}, :62:{60,82}, :64:110, :76:{27,29,39,55}, :85:45]
      r_valid <= r_valid & ~io_reqs_0 | (|sels_0);	// @[Mux.scala:47:70, rename-freelist.scala:80:27, :81:26, :84:{24,27,39}]
      r_valid_1 <= r_valid_1 & ~io_reqs_1 | (|sels_1);	// @[Mux.scala:47:70, rename-freelist.scala:80:27, :81:26, :84:{24,27,39}]
    end
    br_alloc_lists_0 <= (|list_req) ? (list_req[0] ? _GEN_10 : 80'h0) : br_alloc_lists_0 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_1 <= (|list_req_1) ? (list_req_1[0] ? _GEN_10 : 80'h0) : br_alloc_lists_1 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_2 <= (|list_req_2) ? (list_req_2[0] ? _GEN_10 : 80'h0) : br_alloc_lists_2 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_3 <= (|list_req_3) ? (list_req_3[0] ? _GEN_10 : 80'h0) : br_alloc_lists_3 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_4 <= (|list_req_4) ? (list_req_4[0] ? _GEN_10 : 80'h0) : br_alloc_lists_4 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_5 <= (|list_req_5) ? (list_req_5[0] ? _GEN_10 : 80'h0) : br_alloc_lists_5 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_6 <= (|list_req_6) ? (list_req_6[0] ? _GEN_10 : 80'h0) : br_alloc_lists_6 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_7 <= (|list_req_7) ? (list_req_7[0] ? _GEN_10 : 80'h0) : br_alloc_lists_7 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_8 <= (|list_req_8) ? (list_req_8[0] ? _GEN_10 : 80'h0) : br_alloc_lists_8 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_9 <= (|list_req_9) ? (list_req_9[0] ? _GEN_10 : 80'h0) : br_alloc_lists_9 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_10 <= (|list_req_10) ? (list_req_10[0] ? _GEN_10 : 80'h0) : br_alloc_lists_10 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    br_alloc_lists_11 <= (|list_req_11) ? (list_req_11[0] ? _GEN_10 : 80'h0) : br_alloc_lists_11 & ~br_deallocs | _GEN_11;	// @[Mux.scala:27:73, :29:36, :47:70, rename-freelist.scala:51:27, :59:{84,88}, :63:63, :69:85, :70:29, :71:29, :72:{58,60,73}]
    if (sel_fire_0)	// @[rename-freelist.scala:85:45]
      r_sel <= {|(sels_0[79:64]), |(_GEN_0[62:31]), |(_GEN_1[30:15]), |(_GEN_2[14:7]), |(_GEN_3[6:3]), |(_GEN_4[2:1]), _GEN_4[2] | _GEN_4[0]};	// @[Cat.scala:33:92, Mux.scala:47:70, OneHot.scala:30:18, :31:18, :32:{14,28}, Reg.scala:19:16]
    if (sel_fire_1)	// @[rename-freelist.scala:85:45]
      r_sel_1 <= {|(sels_1[79:64]), |(_GEN_5[62:31]), |(_GEN_6[30:15]), |(_GEN_7[14:7]), |(_GEN_8[6:3]), |(_GEN_9[2:1]), _GEN_9[2] | _GEN_9[0]};	// @[Cat.scala:33:92, Mux.scala:47:70, OneHot.scala:30:18, :31:18, :32:{14,28}, Reg.scala:19:16]
  end // always @(posedge)
  `ifndef SYNTHESIS
    wire  [79:0] _GEN_12 = free_list | allocs_0[79:0] & {80{r_valid}} | allocs_1[79:0] & {80{r_valid_1}};	// @[Bitwise.scala:77:12, OneHot.scala:57:35, rename-freelist.scala:50:26, :81:26, :91:{34,77}]
    always @(posedge clock) begin	// @[rename-freelist.scala:94:10]
      if (~reset & (|(_GEN_12 & dealloc_mask))) begin	// @[rename-freelist.scala:64:110, :91:34, :94:{10,31,47}]
        if (`ASSERT_VERBOSE_COND_)	// @[rename-freelist.scala:94:10]
          $error("Assertion failed: [freelist] Returning a free physical register.\n    at rename-freelist.scala:94 assert (!(io.debug.freelist & dealloc_mask).orR, \"[freelist] Returning a free physical register.\")\n");	// @[rename-freelist.scala:94:10]
        if (`STOP_COND_)	// @[rename-freelist.scala:94:10]
          $fatal;	// @[rename-freelist.scala:94:10]
      end
      if (~reset
          & ~(~io_debug_pipeline_empty | {1'h0, {1'h0, {1'h0, {1'h0, {1'h0, {1'h0, _GEN_12[0]} + {1'h0, _GEN_12[1]}} + {1'h0, {1'h0, _GEN_12[2]} + {1'h0, _GEN_12[3]} + {1'h0, _GEN_12[4]}}} + {1'h0, {1'h0, {1'h0, _GEN_12[5]} + {1'h0, _GEN_12[6]}} + {1'h0, {1'h0, _GEN_12[7]} + {1'h0, _GEN_12[8]} + {1'h0, _GEN_12[9]}}}} + {1'h0, {1'h0, {1'h0, {1'h0, _GEN_12[10]} + {1'h0, _GEN_12[11]}} + {1'h0, {1'h0, _GEN_12[12]} + {1'h0, _GEN_12[13]} + {1'h0, _GEN_12[14]}}} + {1'h0, {1'h0, {1'h0, _GEN_12[15]} + {1'h0, _GEN_12[16]}} + {1'h0, {1'h0, _GEN_12[17]} + {1'h0, _GEN_12[18]} + {1'h0, _GEN_12[19]}}}}} + {1'h0, {1'h0, {1'h0, {1'h0, {1'h0, _GEN_12[20]} + {1'h0, _GEN_12[21]}} + {1'h0, {1'h0, _GEN_12[22]} + {1'h0, _GEN_12[23]} + {1'h0, _GEN_12[24]}}} + {1'h0, {1'h0, {1'h0, _GEN_12[25]} + {1'h0, _GEN_12[26]}} + {1'h0, {1'h0, _GEN_12[27]} + {1'h0, _GEN_12[28]} + {1'h0, _GEN_12[29]}}}} + {1'h0, {1'h0, {1'h0, {1'h0, _GEN_12[30]} + {1'h0, _GEN_12[31]}} + {1'h0, {1'h0, _GEN_12[32]} + {1'h0, _GEN_12[33]} + {1'h0, _GEN_12[34]}}} + {1'h0, {1'h0, {1'h0, _GEN_12[35]} + {1'h0, _GEN_12[36]}} + {1'h0, {1'h0, _GEN_12[37]} + {1'h0, _GEN_12[38]} + {1'h0, _GEN_12[39]}}}}}}
              + {1'h0, {1'h0, {1'h0, {1'h0, {1'h0, {1'h0, _GEN_12[40]} + {1'h0, _GEN_12[41]}} + {1'h0, {1'h0, _GEN_12[42]} + {1'h0, _GEN_12[43]} + {1'h0, _GEN_12[44]}}} + {1'h0, {1'h0, {1'h0, _GEN_12[45]} + {1'h0, _GEN_12[46]}} + {1'h0, {1'h0, _GEN_12[47]} + {1'h0, _GEN_12[48]} + {1'h0, _GEN_12[49]}}}} + {1'h0, {1'h0, {1'h0, {1'h0, _GEN_12[50]} + {1'h0, _GEN_12[51]}} + {1'h0, {1'h0, _GEN_12[52]} + {1'h0, _GEN_12[53]} + {1'h0, _GEN_12[54]}}} + {1'h0, {1'h0, {1'h0, _GEN_12[55]} + {1'h0, _GEN_12[56]}} + {1'h0, {1'h0, _GEN_12[57]} + {1'h0, _GEN_12[58]} + {1'h0, _GEN_12[59]}}}}} + {1'h0, {1'h0, {1'h0, {1'h0, {1'h0, _GEN_12[60]} + {1'h0, _GEN_12[61]}} + {1'h0, {1'h0, _GEN_12[62]} + {1'h0, _GEN_12[63]} + {1'h0, _GEN_12[64]}}} + {1'h0, {1'h0, {1'h0, _GEN_12[65]} + {1'h0, _GEN_12[66]}} + {1'h0, {1'h0, _GEN_12[67]} + {1'h0, _GEN_12[68]} + {1'h0, _GEN_12[69]}}}} + {1'h0, {1'h0, {1'h0, {1'h0, _GEN_12[70]} + {1'h0, _GEN_12[71]}} + {1'h0, {1'h0, _GEN_12[72]} + {1'h0, _GEN_12[73]} + {1'h0, _GEN_12[74]}}} + {1'h0, {1'h0, {1'h0, _GEN_12[75]} + {1'h0, _GEN_12[76]}} + {1'h0, {1'h0, _GEN_12[77]} + {1'h0, _GEN_12[78]} + {1'h0, _GEN_12[79]}}}}}} > 7'h2F)) begin	// @[Bitwise.scala:51:90, :53:100, rename-freelist.scala:51:27, :91:34, :95:{10,11,36,67}]
        if (`ASSERT_VERBOSE_COND_)	// @[rename-freelist.scala:95:10]
          $error("Assertion failed: [freelist] Leaking physical registers.\n    at rename-freelist.scala:95 assert (!io.debug.pipeline_empty || PopCount(io.debug.freelist) >= (numPregs - numLregs - 1).U,\n");	// @[rename-freelist.scala:95:10]
        if (`STOP_COND_)	// @[rename-freelist.scala:95:10]
          $fatal;	// @[rename-freelist.scala:95:10]
      end
    end // always @(posedge)
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif // FIRRTL_BEFORE_INITIAL
    logic [31:0] _RANDOM_0;
    logic [31:0] _RANDOM_1;
    logic [31:0] _RANDOM_2;
    logic [31:0] _RANDOM_3;
    logic [31:0] _RANDOM_4;
    logic [31:0] _RANDOM_5;
    logic [31:0] _RANDOM_6;
    logic [31:0] _RANDOM_7;
    logic [31:0] _RANDOM_8;
    logic [31:0] _RANDOM_9;
    logic [31:0] _RANDOM_10;
    logic [31:0] _RANDOM_11;
    logic [31:0] _RANDOM_12;
    logic [31:0] _RANDOM_13;
    logic [31:0] _RANDOM_14;
    logic [31:0] _RANDOM_15;
    logic [31:0] _RANDOM_16;
    logic [31:0] _RANDOM_17;
    logic [31:0] _RANDOM_18;
    logic [31:0] _RANDOM_19;
    logic [31:0] _RANDOM_20;
    logic [31:0] _RANDOM_21;
    logic [31:0] _RANDOM_22;
    logic [31:0] _RANDOM_23;
    logic [31:0] _RANDOM_24;
    logic [31:0] _RANDOM_25;
    logic [31:0] _RANDOM_26;
    logic [31:0] _RANDOM_27;
    logic [31:0] _RANDOM_28;
    logic [31:0] _RANDOM_29;
    logic [31:0] _RANDOM_30;
    logic [31:0] _RANDOM_31;
    logic [31:0] _RANDOM_32;
    initial begin
      `ifdef INIT_RANDOM_PROLOG_
        `INIT_RANDOM_PROLOG_
      `endif // INIT_RANDOM_PROLOG_
      `ifdef RANDOMIZE_REG_INIT
        _RANDOM_0 = `RANDOM;
        _RANDOM_1 = `RANDOM;
        _RANDOM_2 = `RANDOM;
        _RANDOM_3 = `RANDOM;
        _RANDOM_4 = `RANDOM;
        _RANDOM_5 = `RANDOM;
        _RANDOM_6 = `RANDOM;
        _RANDOM_7 = `RANDOM;
        _RANDOM_8 = `RANDOM;
        _RANDOM_9 = `RANDOM;
        _RANDOM_10 = `RANDOM;
        _RANDOM_11 = `RANDOM;
        _RANDOM_12 = `RANDOM;
        _RANDOM_13 = `RANDOM;
        _RANDOM_14 = `RANDOM;
        _RANDOM_15 = `RANDOM;
        _RANDOM_16 = `RANDOM;
        _RANDOM_17 = `RANDOM;
        _RANDOM_18 = `RANDOM;
        _RANDOM_19 = `RANDOM;
        _RANDOM_20 = `RANDOM;
        _RANDOM_21 = `RANDOM;
        _RANDOM_22 = `RANDOM;
        _RANDOM_23 = `RANDOM;
        _RANDOM_24 = `RANDOM;
        _RANDOM_25 = `RANDOM;
        _RANDOM_26 = `RANDOM;
        _RANDOM_27 = `RANDOM;
        _RANDOM_28 = `RANDOM;
        _RANDOM_29 = `RANDOM;
        _RANDOM_30 = `RANDOM;
        _RANDOM_31 = `RANDOM;
        _RANDOM_32 = `RANDOM;
        free_list = {_RANDOM_0, _RANDOM_1, _RANDOM_2[15:0]};	// @[rename-freelist.scala:50:26]
        br_alloc_lists_0 = {_RANDOM_2[31:16], _RANDOM_3, _RANDOM_4};	// @[rename-freelist.scala:50:26, :51:27]
        br_alloc_lists_1 = {_RANDOM_5, _RANDOM_6, _RANDOM_7[15:0]};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_2 = {_RANDOM_7[31:16], _RANDOM_8, _RANDOM_9};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_3 = {_RANDOM_10, _RANDOM_11, _RANDOM_12[15:0]};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_4 = {_RANDOM_12[31:16], _RANDOM_13, _RANDOM_14};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_5 = {_RANDOM_15, _RANDOM_16, _RANDOM_17[15:0]};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_6 = {_RANDOM_17[31:16], _RANDOM_18, _RANDOM_19};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_7 = {_RANDOM_20, _RANDOM_21, _RANDOM_22[15:0]};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_8 = {_RANDOM_22[31:16], _RANDOM_23, _RANDOM_24};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_9 = {_RANDOM_25, _RANDOM_26, _RANDOM_27[15:0]};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_10 = {_RANDOM_27[31:16], _RANDOM_28, _RANDOM_29};	// @[rename-freelist.scala:51:27]
        br_alloc_lists_11 = {_RANDOM_30, _RANDOM_31, _RANDOM_32[15:0]};	// @[rename-freelist.scala:51:27]
        r_valid = _RANDOM_32[16];	// @[rename-freelist.scala:51:27, :81:26]
        r_sel = _RANDOM_32[23:17];	// @[Reg.scala:19:16, rename-freelist.scala:51:27]
        r_valid_1 = _RANDOM_32[24];	// @[rename-freelist.scala:51:27, :81:26]
        r_sel_1 = _RANDOM_32[31:25];	// @[Reg.scala:19:16, rename-freelist.scala:51:27]
      `endif // RANDOMIZE_REG_INIT
    end // initial
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif // FIRRTL_AFTER_INITIAL
  `endif // not def SYNTHESIS
  assign io_alloc_pregs_0_valid = r_valid;	// @[rename-freelist.scala:81:26]
  assign io_alloc_pregs_0_bits = r_sel;	// @[Reg.scala:19:16]
  assign io_alloc_pregs_1_valid = r_valid_1;	// @[rename-freelist.scala:81:26]
  assign io_alloc_pregs_1_bits = r_sel_1;	// @[Reg.scala:19:16]
endmodule

