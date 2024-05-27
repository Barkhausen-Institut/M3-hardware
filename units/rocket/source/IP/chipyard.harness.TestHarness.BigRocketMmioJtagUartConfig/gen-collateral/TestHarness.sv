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

module TestHarness(
  input  clock,
         reset,
  output io_success
);

  wire         _source_1_clk;	// @[HarnessClocks.scala:71:26]
  wire         _source_clk;	// @[HarnessClocks.scala:71:26]
  wire         _harnessBinderReset_catcher_io_sync_reset;	// @[ResetCatchAndSync.scala:39:28]
  wire         _uart_sim_0_uartno0_io_uart_rxd;	// @[UARTAdapter.scala:76:28]
  wire         _mem_io_axi4_0_aw_ready;	// @[HarnessBinders.scala:131:13]
  wire         _mem_io_axi4_0_w_ready;	// @[HarnessBinders.scala:131:13]
  wire         _mem_io_axi4_0_b_valid;	// @[HarnessBinders.scala:131:13]
  wire [3:0]   _mem_io_axi4_0_b_bits_id;	// @[HarnessBinders.scala:131:13]
  wire [1:0]   _mem_io_axi4_0_b_bits_resp;	// @[HarnessBinders.scala:131:13]
  wire         _mem_io_axi4_0_ar_ready;	// @[HarnessBinders.scala:131:13]
  wire         _mem_io_axi4_0_r_valid;	// @[HarnessBinders.scala:131:13]
  wire [3:0]   _mem_io_axi4_0_r_bits_id;	// @[HarnessBinders.scala:131:13]
  wire [127:0] _mem_io_axi4_0_r_bits_data;	// @[HarnessBinders.scala:131:13]
  wire [1:0]   _mem_io_axi4_0_r_bits_resp;	// @[HarnessBinders.scala:131:13]
  wire         _mem_io_axi4_0_r_bits_last;	// @[HarnessBinders.scala:131:13]
  wire         _plusarg_reader_1_out;	// @[PlusArg.scala:80:11]
  wire         _mmio_mem_io_axi4_0_aw_ready;	// @[HarnessBinders.scala:218:15]
  wire         _mmio_mem_io_axi4_0_w_ready;	// @[HarnessBinders.scala:218:15]
  wire         _mmio_mem_io_axi4_0_b_valid;	// @[HarnessBinders.scala:218:15]
  wire [3:0]   _mmio_mem_io_axi4_0_b_bits_id;	// @[HarnessBinders.scala:218:15]
  wire [1:0]   _mmio_mem_io_axi4_0_b_bits_resp;	// @[HarnessBinders.scala:218:15]
  wire         _mmio_mem_io_axi4_0_ar_ready;	// @[HarnessBinders.scala:218:15]
  wire         _mmio_mem_io_axi4_0_r_valid;	// @[HarnessBinders.scala:218:15]
  wire [3:0]   _mmio_mem_io_axi4_0_r_bits_id;	// @[HarnessBinders.scala:218:15]
  wire [63:0]  _mmio_mem_io_axi4_0_r_bits_data;	// @[HarnessBinders.scala:218:15]
  wire [1:0]   _mmio_mem_io_axi4_0_r_bits_resp;	// @[HarnessBinders.scala:218:15]
  wire         _mmio_mem_io_axi4_0_r_bits_last;	// @[HarnessBinders.scala:218:15]
  wire [31:0]  _plusarg_reader_out;	// @[PlusArg.scala:80:11]
  wire         _jtag_jtag_TRSTn;	// @[HarnessBinders.scala:261:26]
  wire         _jtag_jtag_TCK;	// @[HarnessBinders.scala:261:26]
  wire         _jtag_jtag_TMS;	// @[HarnessBinders.scala:261:26]
  wire         _jtag_jtag_TDI;	// @[HarnessBinders.scala:261:26]
  wire [31:0]  _jtag_exit;	// @[HarnessBinders.scala:261:26]
  wire         _chiptop0_axi4_mmio_0_clock;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_reset;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_bits_aw_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mmio_0_bits_aw_bits_id;	// @[HasHarnessInstantiators.scala:82:40]
  wire [31:0]  _chiptop0_axi4_mmio_0_bits_aw_bits_addr;	// @[HasHarnessInstantiators.scala:82:40]
  wire [7:0]   _chiptop0_axi4_mmio_0_bits_aw_bits_len;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_axi4_mmio_0_bits_aw_bits_size;	// @[HasHarnessInstantiators.scala:82:40]
  wire [1:0]   _chiptop0_axi4_mmio_0_bits_aw_bits_burst;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_bits_aw_bits_lock;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mmio_0_bits_aw_bits_cache;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_axi4_mmio_0_bits_aw_bits_prot;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mmio_0_bits_aw_bits_qos;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_bits_w_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [63:0]  _chiptop0_axi4_mmio_0_bits_w_bits_data;	// @[HasHarnessInstantiators.scala:82:40]
  wire [7:0]   _chiptop0_axi4_mmio_0_bits_w_bits_strb;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_bits_w_bits_last;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_bits_b_ready;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_bits_ar_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mmio_0_bits_ar_bits_id;	// @[HasHarnessInstantiators.scala:82:40]
  wire [31:0]  _chiptop0_axi4_mmio_0_bits_ar_bits_addr;	// @[HasHarnessInstantiators.scala:82:40]
  wire [7:0]   _chiptop0_axi4_mmio_0_bits_ar_bits_len;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_axi4_mmio_0_bits_ar_bits_size;	// @[HasHarnessInstantiators.scala:82:40]
  wire [1:0]   _chiptop0_axi4_mmio_0_bits_ar_bits_burst;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_bits_ar_bits_lock;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mmio_0_bits_ar_bits_cache;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_axi4_mmio_0_bits_ar_bits_prot;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mmio_0_bits_ar_bits_qos;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mmio_0_bits_r_ready;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_fbus_0_clock;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_fbus_0_bits_aw_ready;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_fbus_0_bits_w_ready;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_fbus_0_bits_b_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_fbus_0_bits_b_bits_id;	// @[HasHarnessInstantiators.scala:82:40]
  wire [1:0]   _chiptop0_axi4_fbus_0_bits_b_bits_resp;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_fbus_0_bits_ar_ready;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_fbus_0_bits_r_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_fbus_0_bits_r_bits_id;	// @[HasHarnessInstantiators.scala:82:40]
  wire [127:0] _chiptop0_axi4_fbus_0_bits_r_bits_data;	// @[HasHarnessInstantiators.scala:82:40]
  wire [1:0]   _chiptop0_axi4_fbus_0_bits_r_bits_resp;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_fbus_0_bits_r_bits_last;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_clock;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_reset;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_bits_aw_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mem_0_bits_aw_bits_id;	// @[HasHarnessInstantiators.scala:82:40]
  wire [31:0]  _chiptop0_axi4_mem_0_bits_aw_bits_addr;	// @[HasHarnessInstantiators.scala:82:40]
  wire [7:0]   _chiptop0_axi4_mem_0_bits_aw_bits_len;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_axi4_mem_0_bits_aw_bits_size;	// @[HasHarnessInstantiators.scala:82:40]
  wire [1:0]   _chiptop0_axi4_mem_0_bits_aw_bits_burst;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_bits_aw_bits_lock;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mem_0_bits_aw_bits_cache;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_axi4_mem_0_bits_aw_bits_prot;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mem_0_bits_aw_bits_qos;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_bits_w_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [127:0] _chiptop0_axi4_mem_0_bits_w_bits_data;	// @[HasHarnessInstantiators.scala:82:40]
  wire [15:0]  _chiptop0_axi4_mem_0_bits_w_bits_strb;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_bits_w_bits_last;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_bits_b_ready;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_bits_ar_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mem_0_bits_ar_bits_id;	// @[HasHarnessInstantiators.scala:82:40]
  wire [31:0]  _chiptop0_axi4_mem_0_bits_ar_bits_addr;	// @[HasHarnessInstantiators.scala:82:40]
  wire [7:0]   _chiptop0_axi4_mem_0_bits_ar_bits_len;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_axi4_mem_0_bits_ar_bits_size;	// @[HasHarnessInstantiators.scala:82:40]
  wire [1:0]   _chiptop0_axi4_mem_0_bits_ar_bits_burst;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_bits_ar_bits_lock;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mem_0_bits_ar_bits_cache;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_axi4_mem_0_bits_ar_bits_prot;	// @[HasHarnessInstantiators.scala:82:40]
  wire [3:0]   _chiptop0_axi4_mem_0_bits_ar_bits_qos;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_axi4_mem_0_bits_r_ready;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_jtag_TDO;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_uart_0_txd;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_trace_traces_0_clock;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_trace_traces_0_reset;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_trace_traces_0_trace_insns_0_valid;	// @[HasHarnessInstantiators.scala:82:40]
  wire [39:0]  _chiptop0_trace_traces_0_trace_insns_0_iaddr;	// @[HasHarnessInstantiators.scala:82:40]
  wire [31:0]  _chiptop0_trace_traces_0_trace_insns_0_insn;	// @[HasHarnessInstantiators.scala:82:40]
  wire [2:0]   _chiptop0_trace_traces_0_trace_insns_0_priv;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_trace_traces_0_trace_insns_0_exception;	// @[HasHarnessInstantiators.scala:82:40]
  wire         _chiptop0_trace_traces_0_trace_insns_0_interrupt;	// @[HasHarnessInstantiators.scala:82:40]
  wire [63:0]  _chiptop0_trace_traces_0_trace_insns_0_cause;	// @[HasHarnessInstantiators.scala:82:40]
  wire [39:0]  _chiptop0_trace_traces_0_trace_insns_0_tval;	// @[HasHarnessInstantiators.scala:82:40]
  wire [63:0]  _chiptop0_trace_traces_0_trace_time;	// @[HasHarnessInstantiators.scala:82:40]
  `ifndef SYNTHESIS	// @[Periphery.scala:233:11]
    always @(posedge _source_1_clk) begin	// @[HarnessClocks.scala:71:26, Periphery.scala:233:11]
      if (~_harnessBinderReset_catcher_io_sync_reset & (|(_jtag_exit[31:1]))) begin	// @[HarnessBinders.scala:254:41, :261:26, Periphery.scala:233:{11,20,72}, ResetCatchAndSync.scala:39:28]
        if (`ASSERT_VERBOSE_COND_)	// @[Periphery.scala:233:11]
          $error("Assertion failed: *** FAILED *** (exit code = %d)\n\n    at Periphery.scala:233 assert(io.exit < 2.U, \"*** FAILED *** (exit code = %%%%d)\\n\", io.exit >> 1.U)\n", {1'h0, _jtag_exit[31:1]});	// @[HarnessBinders.scala:254:41, :261:26, Periphery.scala:233:{11,72}, TestHarness.scala:24:25]
        if (`STOP_COND_)	// @[Periphery.scala:233:11]
          $fatal;	// @[Periphery.scala:233:11]
      end
    end // always @(posedge)
  `endif // not def SYNTHESIS
  ChipTop chiptop0 (	// @[HasHarnessInstantiators.scala:82:40]
    .axi4_mmio_0_bits_aw_ready              (_mmio_mem_io_axi4_0_aw_ready),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_w_ready               (_mmio_mem_io_axi4_0_w_ready),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_b_valid               (_mmio_mem_io_axi4_0_b_valid),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_b_bits_id             (_mmio_mem_io_axi4_0_b_bits_id),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_b_bits_resp           (_mmio_mem_io_axi4_0_b_bits_resp),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_ar_ready              (_mmio_mem_io_axi4_0_ar_ready),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_r_valid               (_mmio_mem_io_axi4_0_r_valid),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_r_bits_id             (_mmio_mem_io_axi4_0_r_bits_id),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_r_bits_data           (_mmio_mem_io_axi4_0_r_bits_data),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_r_bits_resp           (_mmio_mem_io_axi4_0_r_bits_resp),	// @[HarnessBinders.scala:218:15]
    .axi4_mmio_0_bits_r_bits_last           (_mmio_mem_io_axi4_0_r_bits_last),	// @[HarnessBinders.scala:218:15]
    .axi4_fbus_0_bits_aw_valid              (1'h0),	// @[TestHarness.scala:24:25]
    .axi4_fbus_0_bits_aw_bits_id            (4'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_aw_bits_addr          (32'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_aw_bits_len           (8'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_aw_bits_size          (3'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_aw_bits_burst         (2'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_aw_bits_lock          (1'h0),	// @[TestHarness.scala:24:25]
    .axi4_fbus_0_bits_aw_bits_cache         (4'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_aw_bits_prot          (3'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_aw_bits_qos           (4'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_w_valid               (1'h0),	// @[TestHarness.scala:24:25]
    .axi4_fbus_0_bits_w_bits_data           (128'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_w_bits_strb           (16'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_w_bits_last           (1'h0),	// @[TestHarness.scala:24:25]
    .axi4_fbus_0_bits_b_ready               (1'h0),	// @[TestHarness.scala:24:25]
    .axi4_fbus_0_bits_ar_valid              (1'h0),	// @[TestHarness.scala:24:25]
    .axi4_fbus_0_bits_ar_bits_id            (4'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_ar_bits_addr          (32'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_ar_bits_len           (8'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_ar_bits_size          (3'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_ar_bits_burst         (2'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_ar_bits_lock          (1'h0),	// @[TestHarness.scala:24:25]
    .axi4_fbus_0_bits_ar_bits_cache         (4'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_ar_bits_prot          (3'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_ar_bits_qos           (4'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_fbus_0_bits_r_ready               (1'h0),	// @[TestHarness.scala:24:25]
    .custom_boot                            (_plusarg_reader_1_out),	// @[PlusArg.scala:80:11]
    .reset_io                               (_harnessBinderReset_catcher_io_sync_reset),	// @[ResetCatchAndSync.scala:39:28]
    .clock_uncore_clock                     (_source_clk),	// @[HarnessClocks.scala:71:26]
    .axi4_mem_0_bits_aw_ready               (_mem_io_axi4_0_aw_ready),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_w_ready                (_mem_io_axi4_0_w_ready),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_b_valid                (_mem_io_axi4_0_b_valid),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_b_bits_id              (_mem_io_axi4_0_b_bits_id),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_b_bits_resp            (_mem_io_axi4_0_b_bits_resp),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_ar_ready               (_mem_io_axi4_0_ar_ready),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_r_valid                (_mem_io_axi4_0_r_valid),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_r_bits_id              (_mem_io_axi4_0_r_bits_id),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_r_bits_data            (_mem_io_axi4_0_r_bits_data),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_r_bits_resp            (_mem_io_axi4_0_r_bits_resp),	// @[HarnessBinders.scala:131:13]
    .axi4_mem_0_bits_r_bits_last            (_mem_io_axi4_0_r_bits_last),	// @[HarnessBinders.scala:131:13]
    .jtag_TCK                               (_jtag_jtag_TCK),	// @[HarnessBinders.scala:261:26]
    .jtag_TMS                               (_jtag_jtag_TMS),	// @[HarnessBinders.scala:261:26]
    .jtag_TDI                               (_jtag_jtag_TDI),	// @[HarnessBinders.scala:261:26]
    .uart_0_rxd                             (_uart_sim_0_uartno0_io_uart_rxd),	// @[UARTAdapter.scala:76:28]
    .ext_interrupts                         (8'h0),	// @[HarnessBinders.scala:234:14]
    .axi4_mmio_0_clock                      (_chiptop0_axi4_mmio_0_clock),
    .axi4_mmio_0_reset                      (_chiptop0_axi4_mmio_0_reset),
    .axi4_mmio_0_bits_aw_valid              (_chiptop0_axi4_mmio_0_bits_aw_valid),
    .axi4_mmio_0_bits_aw_bits_id            (_chiptop0_axi4_mmio_0_bits_aw_bits_id),
    .axi4_mmio_0_bits_aw_bits_addr          (_chiptop0_axi4_mmio_0_bits_aw_bits_addr),
    .axi4_mmio_0_bits_aw_bits_len           (_chiptop0_axi4_mmio_0_bits_aw_bits_len),
    .axi4_mmio_0_bits_aw_bits_size          (_chiptop0_axi4_mmio_0_bits_aw_bits_size),
    .axi4_mmio_0_bits_aw_bits_burst         (_chiptop0_axi4_mmio_0_bits_aw_bits_burst),
    .axi4_mmio_0_bits_aw_bits_lock          (_chiptop0_axi4_mmio_0_bits_aw_bits_lock),
    .axi4_mmio_0_bits_aw_bits_cache         (_chiptop0_axi4_mmio_0_bits_aw_bits_cache),
    .axi4_mmio_0_bits_aw_bits_prot          (_chiptop0_axi4_mmio_0_bits_aw_bits_prot),
    .axi4_mmio_0_bits_aw_bits_qos           (_chiptop0_axi4_mmio_0_bits_aw_bits_qos),
    .axi4_mmio_0_bits_w_valid               (_chiptop0_axi4_mmio_0_bits_w_valid),
    .axi4_mmio_0_bits_w_bits_data           (_chiptop0_axi4_mmio_0_bits_w_bits_data),
    .axi4_mmio_0_bits_w_bits_strb           (_chiptop0_axi4_mmio_0_bits_w_bits_strb),
    .axi4_mmio_0_bits_w_bits_last           (_chiptop0_axi4_mmio_0_bits_w_bits_last),
    .axi4_mmio_0_bits_b_ready               (_chiptop0_axi4_mmio_0_bits_b_ready),
    .axi4_mmio_0_bits_ar_valid              (_chiptop0_axi4_mmio_0_bits_ar_valid),
    .axi4_mmio_0_bits_ar_bits_id            (_chiptop0_axi4_mmio_0_bits_ar_bits_id),
    .axi4_mmio_0_bits_ar_bits_addr          (_chiptop0_axi4_mmio_0_bits_ar_bits_addr),
    .axi4_mmio_0_bits_ar_bits_len           (_chiptop0_axi4_mmio_0_bits_ar_bits_len),
    .axi4_mmio_0_bits_ar_bits_size          (_chiptop0_axi4_mmio_0_bits_ar_bits_size),
    .axi4_mmio_0_bits_ar_bits_burst         (_chiptop0_axi4_mmio_0_bits_ar_bits_burst),
    .axi4_mmio_0_bits_ar_bits_lock          (_chiptop0_axi4_mmio_0_bits_ar_bits_lock),
    .axi4_mmio_0_bits_ar_bits_cache         (_chiptop0_axi4_mmio_0_bits_ar_bits_cache),
    .axi4_mmio_0_bits_ar_bits_prot          (_chiptop0_axi4_mmio_0_bits_ar_bits_prot),
    .axi4_mmio_0_bits_ar_bits_qos           (_chiptop0_axi4_mmio_0_bits_ar_bits_qos),
    .axi4_mmio_0_bits_r_ready               (_chiptop0_axi4_mmio_0_bits_r_ready),
    .axi4_fbus_0_clock                      (_chiptop0_axi4_fbus_0_clock),
    .axi4_fbus_0_bits_aw_ready              (_chiptop0_axi4_fbus_0_bits_aw_ready),
    .axi4_fbus_0_bits_w_ready               (_chiptop0_axi4_fbus_0_bits_w_ready),
    .axi4_fbus_0_bits_b_valid               (_chiptop0_axi4_fbus_0_bits_b_valid),
    .axi4_fbus_0_bits_b_bits_id             (_chiptop0_axi4_fbus_0_bits_b_bits_id),
    .axi4_fbus_0_bits_b_bits_resp           (_chiptop0_axi4_fbus_0_bits_b_bits_resp),
    .axi4_fbus_0_bits_ar_ready              (_chiptop0_axi4_fbus_0_bits_ar_ready),
    .axi4_fbus_0_bits_r_valid               (_chiptop0_axi4_fbus_0_bits_r_valid),
    .axi4_fbus_0_bits_r_bits_id             (_chiptop0_axi4_fbus_0_bits_r_bits_id),
    .axi4_fbus_0_bits_r_bits_data           (_chiptop0_axi4_fbus_0_bits_r_bits_data),
    .axi4_fbus_0_bits_r_bits_resp           (_chiptop0_axi4_fbus_0_bits_r_bits_resp),
    .axi4_fbus_0_bits_r_bits_last           (_chiptop0_axi4_fbus_0_bits_r_bits_last),
    .axi4_mem_0_clock                       (_chiptop0_axi4_mem_0_clock),
    .axi4_mem_0_reset                       (_chiptop0_axi4_mem_0_reset),
    .axi4_mem_0_bits_aw_valid               (_chiptop0_axi4_mem_0_bits_aw_valid),
    .axi4_mem_0_bits_aw_bits_id             (_chiptop0_axi4_mem_0_bits_aw_bits_id),
    .axi4_mem_0_bits_aw_bits_addr           (_chiptop0_axi4_mem_0_bits_aw_bits_addr),
    .axi4_mem_0_bits_aw_bits_len            (_chiptop0_axi4_mem_0_bits_aw_bits_len),
    .axi4_mem_0_bits_aw_bits_size           (_chiptop0_axi4_mem_0_bits_aw_bits_size),
    .axi4_mem_0_bits_aw_bits_burst          (_chiptop0_axi4_mem_0_bits_aw_bits_burst),
    .axi4_mem_0_bits_aw_bits_lock           (_chiptop0_axi4_mem_0_bits_aw_bits_lock),
    .axi4_mem_0_bits_aw_bits_cache          (_chiptop0_axi4_mem_0_bits_aw_bits_cache),
    .axi4_mem_0_bits_aw_bits_prot           (_chiptop0_axi4_mem_0_bits_aw_bits_prot),
    .axi4_mem_0_bits_aw_bits_qos            (_chiptop0_axi4_mem_0_bits_aw_bits_qos),
    .axi4_mem_0_bits_w_valid                (_chiptop0_axi4_mem_0_bits_w_valid),
    .axi4_mem_0_bits_w_bits_data            (_chiptop0_axi4_mem_0_bits_w_bits_data),
    .axi4_mem_0_bits_w_bits_strb            (_chiptop0_axi4_mem_0_bits_w_bits_strb),
    .axi4_mem_0_bits_w_bits_last            (_chiptop0_axi4_mem_0_bits_w_bits_last),
    .axi4_mem_0_bits_b_ready                (_chiptop0_axi4_mem_0_bits_b_ready),
    .axi4_mem_0_bits_ar_valid               (_chiptop0_axi4_mem_0_bits_ar_valid),
    .axi4_mem_0_bits_ar_bits_id             (_chiptop0_axi4_mem_0_bits_ar_bits_id),
    .axi4_mem_0_bits_ar_bits_addr           (_chiptop0_axi4_mem_0_bits_ar_bits_addr),
    .axi4_mem_0_bits_ar_bits_len            (_chiptop0_axi4_mem_0_bits_ar_bits_len),
    .axi4_mem_0_bits_ar_bits_size           (_chiptop0_axi4_mem_0_bits_ar_bits_size),
    .axi4_mem_0_bits_ar_bits_burst          (_chiptop0_axi4_mem_0_bits_ar_bits_burst),
    .axi4_mem_0_bits_ar_bits_lock           (_chiptop0_axi4_mem_0_bits_ar_bits_lock),
    .axi4_mem_0_bits_ar_bits_cache          (_chiptop0_axi4_mem_0_bits_ar_bits_cache),
    .axi4_mem_0_bits_ar_bits_prot           (_chiptop0_axi4_mem_0_bits_ar_bits_prot),
    .axi4_mem_0_bits_ar_bits_qos            (_chiptop0_axi4_mem_0_bits_ar_bits_qos),
    .axi4_mem_0_bits_r_ready                (_chiptop0_axi4_mem_0_bits_r_ready),
    .jtag_TDO                               (_chiptop0_jtag_TDO),
    .uart_0_txd                             (_chiptop0_uart_0_txd),
    .trace_traces_0_clock                   (_chiptop0_trace_traces_0_clock),
    .trace_traces_0_reset                   (_chiptop0_trace_traces_0_reset),
    .trace_traces_0_trace_insns_0_valid     (_chiptop0_trace_traces_0_trace_insns_0_valid),
    .trace_traces_0_trace_insns_0_iaddr     (_chiptop0_trace_traces_0_trace_insns_0_iaddr),
    .trace_traces_0_trace_insns_0_insn      (_chiptop0_trace_traces_0_trace_insns_0_insn),
    .trace_traces_0_trace_insns_0_priv      (_chiptop0_trace_traces_0_trace_insns_0_priv),
    .trace_traces_0_trace_insns_0_exception (_chiptop0_trace_traces_0_trace_insns_0_exception),
    .trace_traces_0_trace_insns_0_interrupt (_chiptop0_trace_traces_0_trace_insns_0_interrupt),
    .trace_traces_0_trace_insns_0_cause     (_chiptop0_trace_traces_0_trace_insns_0_cause),
    .trace_traces_0_trace_insns_0_tval      (_chiptop0_trace_traces_0_trace_insns_0_tval),
    .trace_traces_0_trace_time              (_chiptop0_trace_traces_0_trace_time)
  );
  SimJTAG #(
    .TICK_DELAY(3)
  ) jtag (	// @[HarnessBinders.scala:261:26]
    .clock           (_source_1_clk),	// @[HarnessClocks.scala:71:26]
    .reset           (_harnessBinderReset_catcher_io_sync_reset),	// @[ResetCatchAndSync.scala:39:28]
    .jtag_TDO_data   (_chiptop0_jtag_TDO),	// @[HasHarnessInstantiators.scala:82:40]
    .jtag_TDO_driven (1'h1),	// @[HarnessBinders.scala:254:41]
    .enable          (_plusarg_reader_out[0]),	// @[Periphery.scala:227:18, PlusArg.scala:80:11]
    .init_done       (~_harnessBinderReset_catcher_io_sync_reset),	// @[HarnessBinders.scala:262:86, ResetCatchAndSync.scala:39:28]
    .jtag_TRSTn      (_jtag_jtag_TRSTn),
    .jtag_TCK        (_jtag_jtag_TCK),
    .jtag_TMS        (_jtag_jtag_TMS),
    .jtag_TDI        (_jtag_jtag_TDI),
    .exit            (_jtag_exit)
  );
  plusarg_reader_TestHarness_UNIQUIFIED #(
    .FORMAT("jtag_rbb_enable=%d"),
    .DEFAULT(0),
    .WIDTH(32)
  ) plusarg_reader_TestHarness_UNIQUIFIED (	// @[PlusArg.scala:80:11]
    .out (_plusarg_reader_out)
  );
  SimAXIMem mmio_mem (	// @[HarnessBinders.scala:218:15]
    .clock                   (_chiptop0_axi4_mmio_0_clock),	// @[HasHarnessInstantiators.scala:82:40]
    .reset                   (_chiptop0_axi4_mmio_0_reset),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_valid      (_chiptop0_axi4_mmio_0_bits_aw_valid),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_id    (_chiptop0_axi4_mmio_0_bits_aw_bits_id),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_addr  (_chiptop0_axi4_mmio_0_bits_aw_bits_addr[27:0]),	// @[HarnessBinders.scala:220:29, HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_len   (_chiptop0_axi4_mmio_0_bits_aw_bits_len),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_size  (_chiptop0_axi4_mmio_0_bits_aw_bits_size),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_burst (_chiptop0_axi4_mmio_0_bits_aw_bits_burst),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_lock  (_chiptop0_axi4_mmio_0_bits_aw_bits_lock),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_cache (_chiptop0_axi4_mmio_0_bits_aw_bits_cache),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_prot  (_chiptop0_axi4_mmio_0_bits_aw_bits_prot),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_qos   (_chiptop0_axi4_mmio_0_bits_aw_bits_qos),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_w_valid       (_chiptop0_axi4_mmio_0_bits_w_valid),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_w_bits_data   (_chiptop0_axi4_mmio_0_bits_w_bits_data),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_w_bits_strb   (_chiptop0_axi4_mmio_0_bits_w_bits_strb),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_w_bits_last   (_chiptop0_axi4_mmio_0_bits_w_bits_last),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_b_ready       (_chiptop0_axi4_mmio_0_bits_b_ready),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_valid      (_chiptop0_axi4_mmio_0_bits_ar_valid),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_id    (_chiptop0_axi4_mmio_0_bits_ar_bits_id),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_addr  (_chiptop0_axi4_mmio_0_bits_ar_bits_addr[27:0]),	// @[HarnessBinders.scala:220:29, HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_len   (_chiptop0_axi4_mmio_0_bits_ar_bits_len),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_size  (_chiptop0_axi4_mmio_0_bits_ar_bits_size),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_burst (_chiptop0_axi4_mmio_0_bits_ar_bits_burst),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_lock  (_chiptop0_axi4_mmio_0_bits_ar_bits_lock),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_cache (_chiptop0_axi4_mmio_0_bits_ar_bits_cache),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_prot  (_chiptop0_axi4_mmio_0_bits_ar_bits_prot),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_qos   (_chiptop0_axi4_mmio_0_bits_ar_bits_qos),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_r_ready       (_chiptop0_axi4_mmio_0_bits_r_ready),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_ready      (_mmio_mem_io_axi4_0_aw_ready),
    .io_axi4_0_w_ready       (_mmio_mem_io_axi4_0_w_ready),
    .io_axi4_0_b_valid       (_mmio_mem_io_axi4_0_b_valid),
    .io_axi4_0_b_bits_id     (_mmio_mem_io_axi4_0_b_bits_id),
    .io_axi4_0_b_bits_resp   (_mmio_mem_io_axi4_0_b_bits_resp),
    .io_axi4_0_ar_ready      (_mmio_mem_io_axi4_0_ar_ready),
    .io_axi4_0_r_valid       (_mmio_mem_io_axi4_0_r_valid),
    .io_axi4_0_r_bits_id     (_mmio_mem_io_axi4_0_r_bits_id),
    .io_axi4_0_r_bits_data   (_mmio_mem_io_axi4_0_r_bits_data),
    .io_axi4_0_r_bits_resp   (_mmio_mem_io_axi4_0_r_bits_resp),
    .io_axi4_0_r_bits_last   (_mmio_mem_io_axi4_0_r_bits_last)
  );
  plusarg_reader_TestHarness_UNIQUIFIED #(
    .FORMAT("custom_boot_pin=%d"),
    .DEFAULT(0),
    .WIDTH(1)
  ) plusarg_reader_1 (	// @[PlusArg.scala:80:11]
    .out (_plusarg_reader_1_out)
  );
  SimAXIMem_1 mem (	// @[HarnessBinders.scala:131:13]
    .clock                   (_source_1_clk),	// @[HarnessClocks.scala:71:26]
    .reset                   (_harnessBinderReset_catcher_io_sync_reset),	// @[ResetCatchAndSync.scala:39:28]
    .io_axi4_0_aw_valid      (_chiptop0_axi4_mem_0_bits_aw_valid),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_id    (_chiptop0_axi4_mem_0_bits_aw_bits_id),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_addr  (_chiptop0_axi4_mem_0_bits_aw_bits_addr),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_len   (_chiptop0_axi4_mem_0_bits_aw_bits_len),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_size  (_chiptop0_axi4_mem_0_bits_aw_bits_size),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_burst (_chiptop0_axi4_mem_0_bits_aw_bits_burst),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_lock  (_chiptop0_axi4_mem_0_bits_aw_bits_lock),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_cache (_chiptop0_axi4_mem_0_bits_aw_bits_cache),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_prot  (_chiptop0_axi4_mem_0_bits_aw_bits_prot),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_bits_qos   (_chiptop0_axi4_mem_0_bits_aw_bits_qos),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_w_valid       (_chiptop0_axi4_mem_0_bits_w_valid),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_w_bits_data   (_chiptop0_axi4_mem_0_bits_w_bits_data),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_w_bits_strb   (_chiptop0_axi4_mem_0_bits_w_bits_strb),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_w_bits_last   (_chiptop0_axi4_mem_0_bits_w_bits_last),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_b_ready       (_chiptop0_axi4_mem_0_bits_b_ready),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_valid      (_chiptop0_axi4_mem_0_bits_ar_valid),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_id    (_chiptop0_axi4_mem_0_bits_ar_bits_id),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_addr  (_chiptop0_axi4_mem_0_bits_ar_bits_addr),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_len   (_chiptop0_axi4_mem_0_bits_ar_bits_len),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_size  (_chiptop0_axi4_mem_0_bits_ar_bits_size),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_burst (_chiptop0_axi4_mem_0_bits_ar_bits_burst),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_lock  (_chiptop0_axi4_mem_0_bits_ar_bits_lock),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_cache (_chiptop0_axi4_mem_0_bits_ar_bits_cache),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_prot  (_chiptop0_axi4_mem_0_bits_ar_bits_prot),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_ar_bits_qos   (_chiptop0_axi4_mem_0_bits_ar_bits_qos),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_r_ready       (_chiptop0_axi4_mem_0_bits_r_ready),	// @[HasHarnessInstantiators.scala:82:40]
    .io_axi4_0_aw_ready      (_mem_io_axi4_0_aw_ready),
    .io_axi4_0_w_ready       (_mem_io_axi4_0_w_ready),
    .io_axi4_0_b_valid       (_mem_io_axi4_0_b_valid),
    .io_axi4_0_b_bits_id     (_mem_io_axi4_0_b_bits_id),
    .io_axi4_0_b_bits_resp   (_mem_io_axi4_0_b_bits_resp),
    .io_axi4_0_ar_ready      (_mem_io_axi4_0_ar_ready),
    .io_axi4_0_r_valid       (_mem_io_axi4_0_r_valid),
    .io_axi4_0_r_bits_id     (_mem_io_axi4_0_r_bits_id),
    .io_axi4_0_r_bits_data   (_mem_io_axi4_0_r_bits_data),
    .io_axi4_0_r_bits_resp   (_mem_io_axi4_0_r_bits_resp),
    .io_axi4_0_r_bits_last   (_mem_io_axi4_0_r_bits_last)
  );
  UARTAdapter uart_sim_0_uartno0 (	// @[UARTAdapter.scala:76:28]
    .clock       (_source_1_clk),	// @[HarnessClocks.scala:71:26]
    .reset       (_harnessBinderReset_catcher_io_sync_reset),	// @[ResetCatchAndSync.scala:39:28]
    .io_uart_txd (_chiptop0_uart_0_txd),	// @[HasHarnessInstantiators.scala:82:40]
    .io_uart_rxd (_uart_sim_0_uartno0_io_uart_rxd)
  );
  ResetCatchAndSync_d3_TestHarness_UNIQUIFIED harnessBinderReset_catcher (	// @[ResetCatchAndSync.scala:39:28]
    .clock         (_source_1_clk),	// @[HarnessClocks.scala:71:26]
    .reset         (reset),
    .io_sync_reset (_harnessBinderReset_catcher_io_sync_reset)
  );
  ClockSourceAtFreqMHz #(
    .PERIOD(2.000000e+00)
  ) source (	// @[HarnessClocks.scala:71:26]
    .power (1'h1),	// @[HarnessBinders.scala:254:41]
    .gate  (1'h0),	// @[TestHarness.scala:24:25]
    .clk   (_source_clk)
  );
  ClockSourceAtFreqMHz #(
    .PERIOD(1.000000e+01)
  ) source_1 (	// @[HarnessClocks.scala:71:26]
    .power (1'h1),	// @[HarnessBinders.scala:254:41]
    .gate  (1'h0),	// @[TestHarness.scala:24:25]
    .clk   (_source_1_clk)
  );
  assign io_success = _jtag_exit == 32'h1;	// @[HarnessBinders.scala:261:26, Periphery.scala:232:26]
endmodule
