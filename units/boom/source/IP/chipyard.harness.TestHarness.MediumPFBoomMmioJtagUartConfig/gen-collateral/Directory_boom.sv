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

module Directory_boom(
  input         clock,
                reset,
                io_write_valid,
  input  [9:0]  io_write_bits_set,
  input  [2:0]  io_write_bits_way,
  input         io_write_bits_data_dirty,
  input  [1:0]  io_write_bits_data_state,
  input         io_write_bits_data_clients,
  input  [15:0] io_write_bits_data_tag,
  input         io_read_valid,
  input  [9:0]  io_read_bits_set,
  input  [15:0] io_read_bits_tag,
  output        io_write_ready,
                io_result_bits_dirty,
  output [1:0]  io_result_bits_state,
  output        io_result_bits_clients,
  output [15:0] io_result_bits_tag,
  output        io_result_bits_hit,
  output [2:0]  io_result_bits_way,
  output        io_ready
);

  wire         cc_dir_MPORT_mask_7;	// @[Directory.scala:100:65]
  wire         cc_dir_MPORT_mask_6;	// @[Directory.scala:100:65]
  wire         cc_dir_MPORT_mask_5;	// @[Directory.scala:100:65]
  wire         cc_dir_MPORT_mask_4;	// @[Directory.scala:100:65]
  wire         cc_dir_MPORT_mask_3;	// @[Directory.scala:100:65]
  wire         cc_dir_MPORT_mask_2;	// @[Directory.scala:100:65]
  wire         cc_dir_MPORT_mask_1;	// @[Directory.scala:100:65]
  wire         cc_dir_MPORT_mask_0;	// @[Directory.scala:100:65]
  wire [19:0]  _WIRE_7;	// @[Directory.scala:99:44]
  wire [19:0]  _WIRE_6;	// @[Directory.scala:99:44]
  wire [19:0]  _WIRE_5;	// @[Directory.scala:99:44]
  wire [19:0]  _WIRE_4;	// @[Directory.scala:99:44]
  wire [19:0]  _WIRE_3;	// @[Directory.scala:99:44]
  wire [19:0]  _WIRE_2;	// @[Directory.scala:99:44]
  wire [19:0]  _WIRE_1;	// @[Directory.scala:99:44]
  wire [19:0]  _WIRE_0;	// @[Directory.scala:99:44]
  wire [9:0]   cc_dir_MPORT_addr;	// @[Directory.scala:98:10]
  wire         cc_dir_MPORT_en;	// @[Directory.scala:96:14]
  wire         _victimLFSR_prng_io_out_0;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_1;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_2;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_3;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_4;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_5;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_6;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_7;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_8;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_9;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_10;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_11;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_12;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_13;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_14;	// @[PRNG.scala:91:22]
  wire         _victimLFSR_prng_io_out_15;	// @[PRNG.scala:91:22]
  wire         _write_io_deq_valid;	// @[Decoupled.scala:375:21]
  wire [9:0]   _write_io_deq_bits_set;	// @[Decoupled.scala:375:21]
  wire [2:0]   _write_io_deq_bits_way;	// @[Decoupled.scala:375:21]
  wire         _write_io_deq_bits_data_dirty;	// @[Decoupled.scala:375:21]
  wire [1:0]   _write_io_deq_bits_data_state;	// @[Decoupled.scala:375:21]
  wire         _write_io_deq_bits_data_clients;	// @[Decoupled.scala:375:21]
  wire [15:0]  _write_io_deq_bits_data_tag;	// @[Decoupled.scala:375:21]
  wire [159:0] _cc_dir_RW0_rdata;	// @[DescribedSRAM.scala:17:26]
  reg  [10:0]  wipeCount;	// @[Directory.scala:79:26]
  reg          wipeOff;	// @[Directory.scala:80:24]
  assign cc_dir_MPORT_en = ~io_read_valid & (~(wipeCount[10]) & ~wipeOff | _write_io_deq_valid);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :80:24, :81:27, :85:{9,22}, :86:23, :90:{24,37}, :96:14]
  assign cc_dir_MPORT_addr = wipeCount[10] ? _write_io_deq_bits_set : wipeCount[9:0];	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :82:26, :98:10]
  assign _WIRE_0 = wipeCount[10] ? {_write_io_deq_bits_data_dirty, _write_io_deq_bits_data_state, _write_io_deq_bits_data_clients, _write_io_deq_bits_data_tag} : 20'h0;	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :99:{44,71}]
  assign _WIRE_1 = wipeCount[10] ? {_write_io_deq_bits_data_dirty, _write_io_deq_bits_data_state, _write_io_deq_bits_data_clients, _write_io_deq_bits_data_tag} : 20'h0;	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :99:{44,71}]
  assign _WIRE_2 = wipeCount[10] ? {_write_io_deq_bits_data_dirty, _write_io_deq_bits_data_state, _write_io_deq_bits_data_clients, _write_io_deq_bits_data_tag} : 20'h0;	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :99:{44,71}]
  assign _WIRE_3 = wipeCount[10] ? {_write_io_deq_bits_data_dirty, _write_io_deq_bits_data_state, _write_io_deq_bits_data_clients, _write_io_deq_bits_data_tag} : 20'h0;	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :99:{44,71}]
  assign _WIRE_4 = wipeCount[10] ? {_write_io_deq_bits_data_dirty, _write_io_deq_bits_data_state, _write_io_deq_bits_data_clients, _write_io_deq_bits_data_tag} : 20'h0;	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :99:{44,71}]
  assign _WIRE_5 = wipeCount[10] ? {_write_io_deq_bits_data_dirty, _write_io_deq_bits_data_state, _write_io_deq_bits_data_clients, _write_io_deq_bits_data_tag} : 20'h0;	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :99:{44,71}]
  assign _WIRE_6 = wipeCount[10] ? {_write_io_deq_bits_data_dirty, _write_io_deq_bits_data_state, _write_io_deq_bits_data_clients, _write_io_deq_bits_data_tag} : 20'h0;	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :99:{44,71}]
  assign _WIRE_7 = wipeCount[10] ? {_write_io_deq_bits_data_dirty, _write_io_deq_bits_data_state, _write_io_deq_bits_data_clients, _write_io_deq_bits_data_tag} : 20'h0;	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :99:{44,71}]
  assign cc_dir_MPORT_mask_0 = _write_io_deq_bits_way == 3'h0 | ~(wipeCount[10]);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :85:9, :100:{51,65}, :123:42]
  assign cc_dir_MPORT_mask_1 = _write_io_deq_bits_way == 3'h1 | ~(wipeCount[10]);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :85:9, :100:{51,65}, :131:63]
  assign cc_dir_MPORT_mask_2 = _write_io_deq_bits_way == 3'h2 | ~(wipeCount[10]);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :85:9, :100:{51,65}, :131:63]
  assign cc_dir_MPORT_mask_3 = _write_io_deq_bits_way == 3'h3 | ~(wipeCount[10]);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :85:9, :100:{51,65}, :131:63]
  assign cc_dir_MPORT_mask_4 = _write_io_deq_bits_way == 3'h4 | ~(wipeCount[10]);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :85:9, :100:{51,65}, :131:63]
  assign cc_dir_MPORT_mask_5 = _write_io_deq_bits_way == 3'h5 | ~(wipeCount[10]);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :85:9, :100:{51,65}, :131:63]
  assign cc_dir_MPORT_mask_6 = _write_io_deq_bits_way == 3'h6 | ~(wipeCount[10]);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :85:9, :100:{51,65}, :131:63]
  assign cc_dir_MPORT_mask_7 = (&_write_io_deq_bits_way) | ~(wipeCount[10]);	// @[Decoupled.scala:375:21, Directory.scala:79:26, :81:27, :85:9, :100:{51,65}]
  reg          ren1;	// @[Directory.scala:103:21]
  reg  [15:0]  tag;	// @[Reg.scala:19:16]
  reg  [9:0]   set;	// @[Reg.scala:19:16]
  wire [9:0]   victimLFSR = {_victimLFSR_prng_io_out_9, _victimLFSR_prng_io_out_8, _victimLFSR_prng_io_out_7, _victimLFSR_prng_io_out_6, _victimLFSR_prng_io_out_5, _victimLFSR_prng_io_out_4, _victimLFSR_prng_io_out_3, _victimLFSR_prng_io_out_2, _victimLFSR_prng_io_out_1, _victimLFSR_prng_io_out_0};	// @[Directory.scala:115:63, PRNG.scala:91:22]
  wire [2:0]   _GEN = {_victimLFSR_prng_io_out_9, _victimLFSR_prng_io_out_8, _victimLFSR_prng_io_out_7};	// @[Directory.scala:117:43, PRNG.scala:91:22]
  wire [1:0]   _GEN_0 = {_victimLFSR_prng_io_out_9, _victimLFSR_prng_io_out_8};	// @[Directory.scala:117:43, PRNG.scala:91:22]
  wire         _victimLTE_T_3 = victimLFSR > 10'h17F;	// @[Directory.scala:115:63, :117:43]
  wire         _victimLTE_T_5 = victimLFSR > 10'h27F;	// @[Directory.scala:115:63, :117:43]
  wire         _victimLTE_T_6 = victimLFSR > 10'h2FF;	// @[Directory.scala:115:63, :117:43]
  wire         _victimLTE_T_7 = victimLFSR > 10'h37F;	// @[Directory.scala:115:63, :117:43]
  wire [7:0]   victimWayOH = {_victimLTE_T_7, _victimLTE_T_6, _victimLTE_T_5, _victimLFSR_prng_io_out_9, _victimLTE_T_3, |_GEN_0, |_GEN, 1'h1} & {1'h1, ~_victimLTE_T_7, ~_victimLTE_T_6, ~_victimLTE_T_5, ~_victimLFSR_prng_io_out_9, ~_victimLTE_T_3, ~(|_GEN_0), ~(|_GEN)};	// @[Directory.scala:117:43, :119:{31,55,57,70}, PRNG.scala:91:22]
  wire [2:0]   _GEN_1 = victimWayOH[7:5] | victimWayOH[3:1];	// @[Directory.scala:119:55, OneHot.scala:30:18, :31:18, :32:28]
  wire [2:0]   victimWay = {|(victimWayOH[7:4]), |(_GEN_1[2:1]), _GEN_1[2] | _GEN_1[0]};	// @[Cat.scala:33:92, Directory.scala:119:55, OneHot.scala:30:18, :31:18, :32:{14,28}]
  wire         setQuash = _write_io_deq_valid & _write_io_deq_bits_set == set;	// @[Decoupled.scala:375:21, Directory.scala:125:{31,45}, Reg.scala:19:16]
  wire         tagMatch = _write_io_deq_bits_data_tag == tag;	// @[Decoupled.scala:375:21, Directory.scala:126:34, Reg.scala:19:16]
  wire         _hits_T_6 = _cc_dir_RW0_rdata[15:0] == tag & (|(_cc_dir_RW0_rdata[18:17])) & (~setQuash | (|_write_io_deq_bits_way));	// @[Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:125:31, :129:40, :131:{11,30,42,46,56,63}, Reg.scala:19:16]
  wire         _hits_T_13 = _cc_dir_RW0_rdata[35:20] == tag & (|(_cc_dir_RW0_rdata[38:37])) & (~setQuash | _write_io_deq_bits_way != 3'h1);	// @[Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:125:31, :129:40, :131:{11,30,42,46,56,63}, Reg.scala:19:16]
  wire         _hits_T_20 = _cc_dir_RW0_rdata[55:40] == tag & (|(_cc_dir_RW0_rdata[58:57])) & (~setQuash | _write_io_deq_bits_way != 3'h2);	// @[Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:125:31, :129:40, :131:{11,30,42,46,56,63}, Reg.scala:19:16]
  wire         _hits_T_27 = _cc_dir_RW0_rdata[75:60] == tag & (|(_cc_dir_RW0_rdata[78:77])) & (~setQuash | _write_io_deq_bits_way != 3'h3);	// @[Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:125:31, :129:40, :131:{11,30,42,46,56,63}, Reg.scala:19:16]
  wire         _hits_T_34 = _cc_dir_RW0_rdata[95:80] == tag & (|(_cc_dir_RW0_rdata[98:97])) & (~setQuash | _write_io_deq_bits_way != 3'h4);	// @[Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:125:31, :129:40, :131:{11,30,42,46,56,63}, Reg.scala:19:16]
  wire         _hits_T_41 = _cc_dir_RW0_rdata[115:100] == tag & (|(_cc_dir_RW0_rdata[118:117])) & (~setQuash | _write_io_deq_bits_way != 3'h5);	// @[Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:125:31, :129:40, :131:{11,30,42,46,56,63}, Reg.scala:19:16]
  wire         _hits_T_48 = _cc_dir_RW0_rdata[135:120] == tag & (|(_cc_dir_RW0_rdata[138:137])) & (~setQuash | _write_io_deq_bits_way != 3'h6);	// @[Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:125:31, :129:40, :131:{11,30,42,46,56,63}, Reg.scala:19:16]
  wire         _hits_T_55 = _cc_dir_RW0_rdata[155:140] == tag & (|(_cc_dir_RW0_rdata[158:157])) & (~setQuash | _write_io_deq_bits_way != 3'h7);	// @[Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:125:31, :129:40, :131:{11,30,42,46,56,63}, Reg.scala:19:16]
  wire [7:0]   hits = {_hits_T_55, _hits_T_48, _hits_T_41, _hits_T_34, _hits_T_27, _hits_T_20, _hits_T_13, _hits_T_6};	// @[Cat.scala:33:92, Directory.scala:131:42]
  wire         _view__T_69 = setQuash & (tagMatch | _write_io_deq_bits_way == victimWay);	// @[Cat.scala:33:92, Decoupled.scala:375:21, Directory.scala:125:31, :126:34, :127:29, :136:{105,118}]
  wire         _io_result_bits_way_T_7 = setQuash & tagMatch;	// @[Directory.scala:125:31, :126:34, :137:42]
  wire [2:0]   _GEN_2 = {_hits_T_55, _hits_T_48, _hits_T_41} | {_hits_T_27, _hits_T_20, _hits_T_13};	// @[Directory.scala:131:42, OneHot.scala:30:18, :31:18, :32:28]
  always @(posedge clock) begin
    if (reset) begin
      wipeCount <= 11'h0;	// @[Directory.scala:79:26]
      wipeOff <= 1'h1;	// @[Directory.scala:80:24]
      ren1 <= 1'h0;	// @[Directory.scala:103:21]
    end
    else begin
      if (wipeCount[10] | wipeOff) begin	// @[Directory.scala:79:26, :80:24, :81:27, :85:{32,44}]
      end
      else	// @[Directory.scala:79:26, :85:{32,44}]
        wipeCount <= wipeCount + 11'h1;	// @[Directory.scala:79:26, :85:57]
      wipeOff <= 1'h0;	// @[Directory.scala:80:24]
      ren1 <= io_read_valid;	// @[Directory.scala:103:21]
    end
    if (io_read_valid) begin
      tag <= io_read_bits_tag;	// @[Reg.scala:19:16]
      set <= io_read_bits_set;	// @[Reg.scala:19:16]
    end
  end // always @(posedge)
  `ifndef SYNTHESIS
    always @(posedge clock) begin	// @[Directory.scala:86:10]
      if (~reset & ~(wipeCount[10] | ~io_read_valid)) begin	// @[Directory.scala:79:26, :81:27, :86:{10,20,23}]
        if (`ASSERT_VERBOSE_COND_)	// @[Directory.scala:86:10]
          $error("Assertion failed\n    at Directory.scala:86 assert (wipeDone || !io.read.valid)\n");	// @[Directory.scala:86:10]
        if (`STOP_COND_)	// @[Directory.scala:86:10]
          $fatal;	// @[Directory.scala:86:10]
      end
      if (~reset & ~(~io_read_valid | wipeCount[10])) begin	// @[Directory.scala:79:26, :81:27, :86:23, :91:{10,26}]
        if (`ASSERT_VERBOSE_COND_)	// @[Directory.scala:91:10]
          $error("Assertion failed\n    at Directory.scala:91 assert (!io.read.valid || wipeDone)\n");	// @[Directory.scala:91:10]
        if (`STOP_COND_)	// @[Directory.scala:91:10]
          $fatal;	// @[Directory.scala:91:10]
      end
      if (~reset & ~(~ren1 | ({_victimLTE_T_7, _victimLTE_T_6, _victimLTE_T_5, _victimLFSR_prng_io_out_9, _victimLTE_T_3, |_GEN_0} & {~_victimLTE_T_6, ~_victimLTE_T_5, ~_victimLFSR_prng_io_out_9, ~_victimLTE_T_3, ~(|_GEN_0), ~(|_GEN)}) == 6'h0)) begin	// @[Cat.scala:33:92, Directory.scala:103:21, :117:43, :119:57, :121:11, :122:{10,17,39,54}, PRNG.scala:91:22]
        if (`ASSERT_VERBOSE_COND_)	// @[Directory.scala:122:10]
          $error("Assertion failed\n    at Directory.scala:122 assert (!ren2 || ((victimSimp >> 1) & ~victimSimp) === 0.U) // monotone\n");	// @[Directory.scala:122:10]
        if (`STOP_COND_)	// @[Directory.scala:122:10]
          $fatal;	// @[Directory.scala:122:10]
      end
      if (~reset & ~(~ren1 | {1'h0, {1'h0, {1'h0, victimWayOH[0]} + {1'h0, victimWayOH[1]}} + {1'h0, {1'h0, victimWayOH[2]} + {1'h0, victimWayOH[3]}}} + {1'h0, {1'h0, {1'h0, victimWayOH[4]} + {1'h0, victimWayOH[5]}} + {1'h0, {1'h0, victimWayOH[6]} + {1'h0, victimWayOH[7]}}} == 4'h1)) begin	// @[Bitwise.scala:51:90, :53:100, Directory.scala:103:21, :119:55, :121:11, :123:{10,17,42}]
        if (`ASSERT_VERBOSE_COND_)	// @[Directory.scala:123:10]
          $error("Assertion failed\n    at Directory.scala:123 assert (!ren2 || PopCount(victimWayOH) === 1.U)\n");	// @[Directory.scala:123:10]
        if (`STOP_COND_)	// @[Directory.scala:123:10]
          $fatal;	// @[Directory.scala:123:10]
      end
    end // always @(posedge)
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif // FIRRTL_BEFORE_INITIAL
    logic [31:0] _RANDOM_0;
    logic [31:0] _RANDOM_1;
    initial begin
      `ifdef INIT_RANDOM_PROLOG_
        `INIT_RANDOM_PROLOG_
      `endif // INIT_RANDOM_PROLOG_
      `ifdef RANDOMIZE_REG_INIT
        _RANDOM_0 = `RANDOM;
        _RANDOM_1 = `RANDOM;
        wipeCount = _RANDOM_0[10:0];	// @[Directory.scala:79:26]
        wipeOff = _RANDOM_0[11];	// @[Directory.scala:79:26, :80:24]
        ren1 = _RANDOM_0[12];	// @[Directory.scala:79:26, :103:21]
        tag = _RANDOM_0[28:13];	// @[Directory.scala:79:26, Reg.scala:19:16]
        set = {_RANDOM_0[31:29], _RANDOM_1[6:0]};	// @[Directory.scala:79:26, Reg.scala:19:16]
      `endif // RANDOMIZE_REG_INIT
    end // initial
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif // FIRRTL_AFTER_INITIAL
  `endif // not def SYNTHESIS
  cc_dir_boom cc_dir (	// @[DescribedSRAM.scala:17:26]
    .RW0_addr  (cc_dir_MPORT_en ? cc_dir_MPORT_addr : io_read_bits_set),	// @[DescribedSRAM.scala:17:26, Directory.scala:96:14, :98:10]
    .RW0_en    (io_read_valid | cc_dir_MPORT_en),	// @[DescribedSRAM.scala:17:26, Directory.scala:96:14]
    .RW0_clk   (clock),
    .RW0_wmode (~io_read_valid),	// @[Directory.scala:86:23]
    .RW0_wdata ({_WIRE_7, _WIRE_6, _WIRE_5, _WIRE_4, _WIRE_3, _WIRE_2, _WIRE_1, _WIRE_0}),	// @[DescribedSRAM.scala:17:26, Directory.scala:99:44]
    .RW0_wmask ({cc_dir_MPORT_mask_7, cc_dir_MPORT_mask_6, cc_dir_MPORT_mask_5, cc_dir_MPORT_mask_4, cc_dir_MPORT_mask_3, cc_dir_MPORT_mask_2, cc_dir_MPORT_mask_1, cc_dir_MPORT_mask_0}),	// @[DescribedSRAM.scala:17:26, Directory.scala:100:65]
    .RW0_rdata (_cc_dir_RW0_rdata)
  );
  Queue_115_boom write (	// @[Decoupled.scala:375:21]
    .clock                    (clock),
    .reset                    (reset),
    .io_enq_valid             (io_write_valid),
    .io_enq_bits_set          (io_write_bits_set),
    .io_enq_bits_way          (io_write_bits_way),
    .io_enq_bits_data_dirty   (io_write_bits_data_dirty),
    .io_enq_bits_data_state   (io_write_bits_data_state),
    .io_enq_bits_data_clients (io_write_bits_data_clients),
    .io_enq_bits_data_tag     (io_write_bits_data_tag),
    .io_deq_ready             (~io_read_valid),	// @[Directory.scala:86:23]
    .io_enq_ready             (io_write_ready),
    .io_deq_valid             (_write_io_deq_valid),
    .io_deq_bits_set          (_write_io_deq_bits_set),
    .io_deq_bits_way          (_write_io_deq_bits_way),
    .io_deq_bits_data_dirty   (_write_io_deq_bits_data_dirty),
    .io_deq_bits_data_state   (_write_io_deq_bits_data_state),
    .io_deq_bits_data_clients (_write_io_deq_bits_data_clients),
    .io_deq_bits_data_tag     (_write_io_deq_bits_data_tag)
  );
  MaxPeriodFibonacciLFSR_boom victimLFSR_prng (	// @[PRNG.scala:91:22]
    .clock        (clock),
    .reset        (reset),
    .io_increment (io_read_valid),
    .io_out_0     (_victimLFSR_prng_io_out_0),
    .io_out_1     (_victimLFSR_prng_io_out_1),
    .io_out_2     (_victimLFSR_prng_io_out_2),
    .io_out_3     (_victimLFSR_prng_io_out_3),
    .io_out_4     (_victimLFSR_prng_io_out_4),
    .io_out_5     (_victimLFSR_prng_io_out_5),
    .io_out_6     (_victimLFSR_prng_io_out_6),
    .io_out_7     (_victimLFSR_prng_io_out_7),
    .io_out_8     (_victimLFSR_prng_io_out_8),
    .io_out_9     (_victimLFSR_prng_io_out_9),
    .io_out_10    (_victimLFSR_prng_io_out_10),
    .io_out_11    (_victimLFSR_prng_io_out_11),
    .io_out_12    (_victimLFSR_prng_io_out_12),
    .io_out_13    (_victimLFSR_prng_io_out_13),
    .io_out_14    (_victimLFSR_prng_io_out_14),
    .io_out_15    (_victimLFSR_prng_io_out_15)
  );
  assign io_result_bits_dirty = (|hits) ? _hits_T_6 & _cc_dir_RW0_rdata[19] | _hits_T_13 & _cc_dir_RW0_rdata[39] | _hits_T_20 & _cc_dir_RW0_rdata[59] | _hits_T_27 & _cc_dir_RW0_rdata[79] | _hits_T_34 & _cc_dir_RW0_rdata[99] | _hits_T_41 & _cc_dir_RW0_rdata[119] | _hits_T_48 & _cc_dir_RW0_rdata[139] | _hits_T_55 & _cc_dir_RW0_rdata[159] : _view__T_69 ? _write_io_deq_bits_data_dirty : victimWayOH[0] & _cc_dir_RW0_rdata[19] | victimWayOH[1] & _cc_dir_RW0_rdata[39] | victimWayOH[2] & _cc_dir_RW0_rdata[59] | victimWayOH[3] & _cc_dir_RW0_rdata[79] | victimWayOH[4] & _cc_dir_RW0_rdata[99] | victimWayOH[5] & _cc_dir_RW0_rdata[119] | victimWayOH[6] & _cc_dir_RW0_rdata[139] | victimWayOH[7] & _cc_dir_RW0_rdata[159];	// @[Bitwise.scala:53:100, Cat.scala:33:92, Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:119:55, :129:40, :131:42, :133:18, :136:{67,95,105}, Mux.scala:27:73]
  assign io_result_bits_state = (|hits) ? (_hits_T_6 ? _cc_dir_RW0_rdata[18:17] : 2'h0) | (_hits_T_13 ? _cc_dir_RW0_rdata[38:37] : 2'h0) | (_hits_T_20 ? _cc_dir_RW0_rdata[58:57] : 2'h0) | (_hits_T_27 ? _cc_dir_RW0_rdata[78:77] : 2'h0) | (_hits_T_34 ? _cc_dir_RW0_rdata[98:97] : 2'h0) | (_hits_T_41 ? _cc_dir_RW0_rdata[118:117] : 2'h0) | (_hits_T_48 ? _cc_dir_RW0_rdata[138:137] : 2'h0) | (_hits_T_55 ? _cc_dir_RW0_rdata[158:157] : 2'h0) : _view__T_69 ? _write_io_deq_bits_data_state : (victimWayOH[0] ? _cc_dir_RW0_rdata[18:17] : 2'h0) | (victimWayOH[1] ? _cc_dir_RW0_rdata[38:37] : 2'h0) | (victimWayOH[2] ? _cc_dir_RW0_rdata[58:57] : 2'h0) | (victimWayOH[3] ? _cc_dir_RW0_rdata[78:77] : 2'h0) | (victimWayOH[4] ? _cc_dir_RW0_rdata[98:97] : 2'h0) | (victimWayOH[5] ? _cc_dir_RW0_rdata[118:117] : 2'h0) | (victimWayOH[6] ? _cc_dir_RW0_rdata[138:137] : 2'h0) | (victimWayOH[7] ? _cc_dir_RW0_rdata[158:157] : 2'h0);	// @[Bitwise.scala:53:100, Cat.scala:33:92, Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:119:55, :129:40, :131:{30,42}, :133:18, :136:{67,95,105}, Mux.scala:27:73]
  assign io_result_bits_clients = (|hits) ? _hits_T_6 & _cc_dir_RW0_rdata[16] | _hits_T_13 & _cc_dir_RW0_rdata[36] | _hits_T_20 & _cc_dir_RW0_rdata[56] | _hits_T_27 & _cc_dir_RW0_rdata[76] | _hits_T_34 & _cc_dir_RW0_rdata[96] | _hits_T_41 & _cc_dir_RW0_rdata[116] | _hits_T_48 & _cc_dir_RW0_rdata[136] | _hits_T_55 & _cc_dir_RW0_rdata[156] : _view__T_69 ? _write_io_deq_bits_data_clients : victimWayOH[0] & _cc_dir_RW0_rdata[16] | victimWayOH[1] & _cc_dir_RW0_rdata[36] | victimWayOH[2] & _cc_dir_RW0_rdata[56] | victimWayOH[3] & _cc_dir_RW0_rdata[76] | victimWayOH[4] & _cc_dir_RW0_rdata[96] | victimWayOH[5] & _cc_dir_RW0_rdata[116] | victimWayOH[6] & _cc_dir_RW0_rdata[136] | victimWayOH[7] & _cc_dir_RW0_rdata[156];	// @[Bitwise.scala:53:100, Cat.scala:33:92, Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:119:55, :129:40, :131:42, :133:18, :136:{67,95,105}, Mux.scala:27:73]
  assign io_result_bits_tag = (|hits) ? (_hits_T_6 ? _cc_dir_RW0_rdata[15:0] : 16'h0) | (_hits_T_13 ? _cc_dir_RW0_rdata[35:20] : 16'h0) | (_hits_T_20 ? _cc_dir_RW0_rdata[55:40] : 16'h0) | (_hits_T_27 ? _cc_dir_RW0_rdata[75:60] : 16'h0) | (_hits_T_34 ? _cc_dir_RW0_rdata[95:80] : 16'h0) | (_hits_T_41 ? _cc_dir_RW0_rdata[115:100] : 16'h0) | (_hits_T_48 ? _cc_dir_RW0_rdata[135:120] : 16'h0) | (_hits_T_55 ? _cc_dir_RW0_rdata[155:140] : 16'h0) : _view__T_69 ? _write_io_deq_bits_data_tag : (victimWayOH[0] ? _cc_dir_RW0_rdata[15:0] : 16'h0) | (victimWayOH[1] ? _cc_dir_RW0_rdata[35:20] : 16'h0) | (victimWayOH[2] ? _cc_dir_RW0_rdata[55:40] : 16'h0) | (victimWayOH[3] ? _cc_dir_RW0_rdata[75:60] : 16'h0) | (victimWayOH[4] ? _cc_dir_RW0_rdata[95:80] : 16'h0) | (victimWayOH[5] ? _cc_dir_RW0_rdata[115:100] : 16'h0) | (victimWayOH[6] ? _cc_dir_RW0_rdata[135:120] : 16'h0) | (victimWayOH[7] ? _cc_dir_RW0_rdata[155:140] : 16'h0);	// @[Bitwise.scala:53:100, Cat.scala:33:92, Decoupled.scala:375:21, DescribedSRAM.scala:17:26, Directory.scala:119:55, :129:40, :131:42, :133:18, :136:{67,95,105}, Mux.scala:27:73]
  assign io_result_bits_hit = (|hits) | _io_result_bits_way_T_7 & (|_write_io_deq_bits_data_state);	// @[Cat.scala:33:92, Decoupled.scala:375:21, Directory.scala:133:18, :137:{29,42,54,75}]
  assign io_result_bits_way = (|hits) ? {|{_hits_T_55, _hits_T_48, _hits_T_41, _hits_T_34}, |(_GEN_2[2:1]), _GEN_2[2] | _GEN_2[0]} : _io_result_bits_way_T_7 ? _write_io_deq_bits_way : victimWay;	// @[Cat.scala:33:92, Decoupled.scala:375:21, Directory.scala:131:42, :133:18, :137:42, :138:{28,53}, OneHot.scala:30:18, :31:18, :32:{14,28}]
  assign io_ready = wipeCount[10];	// @[Directory.scala:79:26, :81:27]
endmodule
