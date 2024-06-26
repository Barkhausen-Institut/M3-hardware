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

module AXI4UserYanker_1_boom(
  input          clock,
                 reset,
                 auto_in_aw_valid,
                 auto_in_aw_bits_id,
  input  [31:0]  auto_in_aw_bits_addr,
  input  [7:0]   auto_in_aw_bits_len,
  input  [2:0]   auto_in_aw_bits_size,
  input  [3:0]   auto_in_aw_bits_cache,
  input  [2:0]   auto_in_aw_bits_prot,
                 auto_in_aw_bits_echo_extra_id,
  input          auto_in_aw_bits_echo_real_last,
                 auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_w_bits_last,
                 auto_in_b_ready,
                 auto_in_ar_valid,
                 auto_in_ar_bits_id,
  input  [31:0]  auto_in_ar_bits_addr,
  input  [7:0]   auto_in_ar_bits_len,
  input  [2:0]   auto_in_ar_bits_size,
  input  [3:0]   auto_in_ar_bits_cache,
  input  [2:0]   auto_in_ar_bits_prot,
                 auto_in_ar_bits_echo_extra_id,
  input          auto_in_ar_bits_echo_real_last,
                 auto_in_r_ready,
                 auto_out_aw_ready,
                 auto_out_w_ready,
                 auto_out_b_valid,
                 auto_out_b_bits_id,
  input  [1:0]   auto_out_b_bits_resp,
  input          auto_out_ar_ready,
                 auto_out_r_valid,
                 auto_out_r_bits_id,
  input  [127:0] auto_out_r_bits_data,
  input  [1:0]   auto_out_r_bits_resp,
  input          auto_out_r_bits_last,
  output         auto_in_aw_ready,
                 auto_in_w_ready,
                 auto_in_b_valid,
                 auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output [2:0]   auto_in_b_bits_echo_extra_id,
  output         auto_in_b_bits_echo_real_last,
                 auto_in_ar_ready,
                 auto_in_r_valid,
                 auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output [2:0]   auto_in_r_bits_echo_extra_id,
  output         auto_in_r_bits_echo_real_last,
                 auto_in_r_bits_last,
                 auto_out_aw_valid,
                 auto_out_aw_bits_id,
  output [31:0]  auto_out_aw_bits_addr,
  output [7:0]   auto_out_aw_bits_len,
  output [2:0]   auto_out_aw_bits_size,
  output [3:0]   auto_out_aw_bits_cache,
  output [2:0]   auto_out_aw_bits_prot,
  output         auto_out_w_valid,
  output [127:0] auto_out_w_bits_data,
  output [15:0]  auto_out_w_bits_strb,
  output         auto_out_w_bits_last,
                 auto_out_b_ready,
                 auto_out_ar_valid,
                 auto_out_ar_bits_id,
  output [31:0]  auto_out_ar_bits_addr,
  output [7:0]   auto_out_ar_bits_len,
  output [2:0]   auto_out_ar_bits_size,
  output [3:0]   auto_out_ar_bits_cache,
  output [2:0]   auto_out_ar_bits_prot,
  output         auto_out_r_ready
);

  wire       _Queue_3_io_enq_ready;	// @[UserYanker.scala:50:17]
  wire       _Queue_3_io_deq_valid;	// @[UserYanker.scala:50:17]
  wire [2:0] _Queue_3_io_deq_bits_extra_id;	// @[UserYanker.scala:50:17]
  wire       _Queue_3_io_deq_bits_real_last;	// @[UserYanker.scala:50:17]
  wire       _Queue_2_io_enq_ready;	// @[UserYanker.scala:50:17]
  wire       _Queue_2_io_deq_valid;	// @[UserYanker.scala:50:17]
  wire [2:0] _Queue_2_io_deq_bits_extra_id;	// @[UserYanker.scala:50:17]
  wire       _Queue_2_io_deq_bits_real_last;	// @[UserYanker.scala:50:17]
  wire       _Queue_1_io_enq_ready;	// @[UserYanker.scala:50:17]
  wire       _Queue_1_io_deq_valid;	// @[UserYanker.scala:50:17]
  wire [2:0] _Queue_1_io_deq_bits_extra_id;	// @[UserYanker.scala:50:17]
  wire       _Queue_1_io_deq_bits_real_last;	// @[UserYanker.scala:50:17]
  wire       _Queue_io_enq_ready;	// @[UserYanker.scala:50:17]
  wire       _Queue_io_deq_valid;	// @[UserYanker.scala:50:17]
  wire [2:0] _Queue_io_deq_bits_extra_id;	// @[UserYanker.scala:50:17]
  wire       _Queue_io_deq_bits_real_last;	// @[UserYanker.scala:50:17]
  wire       _GEN = auto_in_ar_bits_id ? _Queue_1_io_enq_ready : _Queue_io_enq_ready;	// @[UserYanker.scala:50:17, :59:36]
  wire       _T_10 = auto_out_r_valid & auto_in_r_ready;	// @[UserYanker.scala:73:37]
  wire       _T_13 = auto_in_ar_valid & auto_out_ar_ready;	// @[UserYanker.scala:74:37]
  wire       _GEN_0 = auto_in_aw_bits_id ? _Queue_3_io_enq_ready : _Queue_2_io_enq_ready;	// @[UserYanker.scala:50:17, :80:36]
  `ifndef SYNTHESIS	// @[UserYanker.scala:66:14]
    always @(posedge clock) begin	// @[UserYanker.scala:66:14]
      if (~reset & ~(~auto_out_r_valid | (auto_out_r_bits_id ? _Queue_1_io_deq_valid : _Queue_io_deq_valid))) begin	// @[UserYanker.scala:50:17, :66:{14,15,28}]
        if (`ASSERT_VERBOSE_COND_)	// @[UserYanker.scala:66:14]
          $error("Assertion failed\n    at UserYanker.scala:66 assert (!out.r.valid || r_valid) // Q must be ready faster than the response\n");	// @[UserYanker.scala:66:14]
        if (`STOP_COND_)	// @[UserYanker.scala:66:14]
          $fatal;	// @[UserYanker.scala:66:14]
      end
      if (~reset & ~(~auto_out_b_valid | (auto_out_b_bits_id ? _Queue_3_io_deq_valid : _Queue_2_io_deq_valid))) begin	// @[UserYanker.scala:50:17, :87:{14,15,28}]
        if (`ASSERT_VERBOSE_COND_)	// @[UserYanker.scala:87:14]
          $error("Assertion failed\n    at UserYanker.scala:87 assert (!out.b.valid || b_valid) // Q must be ready faster than the response\n");	// @[UserYanker.scala:87:14]
        if (`STOP_COND_)	// @[UserYanker.scala:87:14]
          $fatal;	// @[UserYanker.scala:87:14]
      end
    end // always @(posedge)
  `endif // not def SYNTHESIS
  wire       _T_24 = auto_out_b_valid & auto_in_b_ready;	// @[UserYanker.scala:94:37]
  wire       _T_26 = auto_in_aw_valid & auto_out_aw_ready;	// @[UserYanker.scala:95:37]
  Queue_65_boom Queue (	// @[UserYanker.scala:50:17]
    .clock                 (clock),
    .reset                 (reset),
    .io_enq_valid          (_T_13 & ~auto_in_ar_bits_id),	// @[UserYanker.scala:70:55, :74:{37,53}]
    .io_enq_bits_extra_id  (auto_in_ar_bits_echo_extra_id),
    .io_enq_bits_real_last (auto_in_ar_bits_echo_real_last),
    .io_deq_ready          (_T_10 & ~auto_out_r_bits_id & auto_out_r_bits_last),	// @[UserYanker.scala:71:55, :73:{37,58}]
    .io_enq_ready          (_Queue_io_enq_ready),
    .io_deq_valid          (_Queue_io_deq_valid),
    .io_deq_bits_extra_id  (_Queue_io_deq_bits_extra_id),
    .io_deq_bits_real_last (_Queue_io_deq_bits_real_last)
  );
  Queue_65_boom Queue_1 (	// @[UserYanker.scala:50:17]
    .clock                 (clock),
    .reset                 (reset),
    .io_enq_valid          (_T_13 & auto_in_ar_bits_id),	// @[UserYanker.scala:74:{37,53}]
    .io_enq_bits_extra_id  (auto_in_ar_bits_echo_extra_id),
    .io_enq_bits_real_last (auto_in_ar_bits_echo_real_last),
    .io_deq_ready          (_T_10 & auto_out_r_bits_id & auto_out_r_bits_last),	// @[UserYanker.scala:73:{37,58}]
    .io_enq_ready          (_Queue_1_io_enq_ready),
    .io_deq_valid          (_Queue_1_io_deq_valid),
    .io_deq_bits_extra_id  (_Queue_1_io_deq_bits_extra_id),
    .io_deq_bits_real_last (_Queue_1_io_deq_bits_real_last)
  );
  Queue_65_boom Queue_2 (	// @[UserYanker.scala:50:17]
    .clock                 (clock),
    .reset                 (reset),
    .io_enq_valid          (_T_26 & ~auto_in_aw_bits_id),	// @[UserYanker.scala:91:55, :95:{37,53}]
    .io_enq_bits_extra_id  (auto_in_aw_bits_echo_extra_id),
    .io_enq_bits_real_last (auto_in_aw_bits_echo_real_last),
    .io_deq_ready          (_T_24 & ~auto_out_b_bits_id),	// @[UserYanker.scala:92:55, :94:{37,53}]
    .io_enq_ready          (_Queue_2_io_enq_ready),
    .io_deq_valid          (_Queue_2_io_deq_valid),
    .io_deq_bits_extra_id  (_Queue_2_io_deq_bits_extra_id),
    .io_deq_bits_real_last (_Queue_2_io_deq_bits_real_last)
  );
  Queue_65_boom Queue_3 (	// @[UserYanker.scala:50:17]
    .clock                 (clock),
    .reset                 (reset),
    .io_enq_valid          (_T_26 & auto_in_aw_bits_id),	// @[UserYanker.scala:95:{37,53}]
    .io_enq_bits_extra_id  (auto_in_aw_bits_echo_extra_id),
    .io_enq_bits_real_last (auto_in_aw_bits_echo_real_last),
    .io_deq_ready          (_T_24 & auto_out_b_bits_id),	// @[UserYanker.scala:94:{37,53}]
    .io_enq_ready          (_Queue_3_io_enq_ready),
    .io_deq_valid          (_Queue_3_io_deq_valid),
    .io_deq_bits_extra_id  (_Queue_3_io_deq_bits_extra_id),
    .io_deq_bits_real_last (_Queue_3_io_deq_bits_real_last)
  );
  assign auto_in_aw_ready = auto_out_aw_ready & _GEN_0;	// @[UserYanker.scala:80:36]
  assign auto_in_w_ready = auto_out_w_ready;
  assign auto_in_b_valid = auto_out_b_valid;
  assign auto_in_b_bits_id = auto_out_b_bits_id;
  assign auto_in_b_bits_resp = auto_out_b_bits_resp;
  assign auto_in_b_bits_echo_extra_id = auto_out_b_bits_id ? _Queue_3_io_deq_bits_extra_id : _Queue_2_io_deq_bits_extra_id;	// @[BundleMap.scala:247:19, UserYanker.scala:50:17]
  assign auto_in_b_bits_echo_real_last = auto_out_b_bits_id ? _Queue_3_io_deq_bits_real_last : _Queue_2_io_deq_bits_real_last;	// @[BundleMap.scala:247:19, UserYanker.scala:50:17]
  assign auto_in_ar_ready = auto_out_ar_ready & _GEN;	// @[UserYanker.scala:59:36]
  assign auto_in_r_valid = auto_out_r_valid;
  assign auto_in_r_bits_id = auto_out_r_bits_id;
  assign auto_in_r_bits_data = auto_out_r_bits_data;
  assign auto_in_r_bits_resp = auto_out_r_bits_resp;
  assign auto_in_r_bits_echo_extra_id = auto_out_r_bits_id ? _Queue_1_io_deq_bits_extra_id : _Queue_io_deq_bits_extra_id;	// @[BundleMap.scala:247:19, UserYanker.scala:50:17]
  assign auto_in_r_bits_echo_real_last = auto_out_r_bits_id ? _Queue_1_io_deq_bits_real_last : _Queue_io_deq_bits_real_last;	// @[BundleMap.scala:247:19, UserYanker.scala:50:17]
  assign auto_in_r_bits_last = auto_out_r_bits_last;
  assign auto_out_aw_valid = auto_in_aw_valid & _GEN_0;	// @[UserYanker.scala:80:36, :81:36]
  assign auto_out_aw_bits_id = auto_in_aw_bits_id;
  assign auto_out_aw_bits_addr = auto_in_aw_bits_addr;
  assign auto_out_aw_bits_len = auto_in_aw_bits_len;
  assign auto_out_aw_bits_size = auto_in_aw_bits_size;
  assign auto_out_aw_bits_cache = auto_in_aw_bits_cache;
  assign auto_out_aw_bits_prot = auto_in_aw_bits_prot;
  assign auto_out_w_valid = auto_in_w_valid;
  assign auto_out_w_bits_data = auto_in_w_bits_data;
  assign auto_out_w_bits_strb = auto_in_w_bits_strb;
  assign auto_out_w_bits_last = auto_in_w_bits_last;
  assign auto_out_b_ready = auto_in_b_ready;
  assign auto_out_ar_valid = auto_in_ar_valid & _GEN;	// @[UserYanker.scala:59:36, :60:36]
  assign auto_out_ar_bits_id = auto_in_ar_bits_id;
  assign auto_out_ar_bits_addr = auto_in_ar_bits_addr;
  assign auto_out_ar_bits_len = auto_in_ar_bits_len;
  assign auto_out_ar_bits_size = auto_in_ar_bits_size;
  assign auto_out_ar_bits_cache = auto_in_ar_bits_cache;
  assign auto_out_ar_bits_prot = auto_in_ar_bits_prot;
  assign auto_out_r_ready = auto_in_r_ready;
endmodule

