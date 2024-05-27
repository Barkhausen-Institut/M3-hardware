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

module JtagStateMachine_boom(
  input        clock,
               reset,
               io_tms,
  output [3:0] io_currState
);

  reg  [3:0]       currState;	// @[JtagStateMachine.scala:78:26]
  wire [15:0][3:0] _GEN = {{io_tms ? 4'hF : 4'hC}, {io_tms ? 4'h9 : 4'hA}, {io_tms ? 4'h7 : 4'hC}, {io_tms ? 4'h7 : 4'hC}, {io_tms ? 4'h8 : 4'hB}, {io_tms ? 4'h9 : 4'hA}, {io_tms ? 4'hD : 4'hB}, {io_tms ? 4'hD : 4'hA}, {{2'h1, ~io_tms, 1'h0}}, {io_tms ? 4'h1 : 4'h2}, {io_tms ? 4'h7 : 4'hC}, {{3'h7, io_tms}}, {io_tms ? 4'h0 : 4'h3}, {io_tms ? 4'h1 : 4'h2}, {io_tms ? 4'h5 : 4'h3}, {io_tms ? 4'h5 : 4'h2}};	// @[JtagStateMachine.scala:77:27, :80:22, :82:{17,23}, :85:{17,23}, :88:{17,23}, :91:{17,23}, :94:{17,23}, :97:{17,23}, :100:{17,23}, :103:{17,23}, :106:{17,23}, :109:{17,23}, :112:{17,23}, :115:{17,23}, :118:{17,23}, :121:{17,23}, :124:{17,23}, :127:{17,23}]
  always @(posedge clock or posedge reset) begin
    if (reset)
      currState <= 4'hF;	// @[JtagStateMachine.scala:77:27, :78:26]
    else
      currState <= _GEN[currState];	// @[JtagStateMachine.scala:77:27, :78:26, :80:22, :82:17, :85:17, :88:17, :91:17, :94:17, :97:17, :100:17, :103:17, :106:17, :109:17, :112:17, :115:17, :118:17, :121:17, :124:17, :127:17]
  end // always @(posedge, posedge)
  `ifndef SYNTHESIS
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif // FIRRTL_BEFORE_INITIAL
    logic [31:0] _RANDOM_0;
    initial begin
      `ifdef INIT_RANDOM_PROLOG_
        `INIT_RANDOM_PROLOG_
      `endif // INIT_RANDOM_PROLOG_
      `ifdef RANDOMIZE_REG_INIT
        _RANDOM_0 = `RANDOM;
        currState = _RANDOM_0[3:0];	// @[JtagStateMachine.scala:78:26]
      `endif // RANDOMIZE_REG_INIT
      `ifdef RANDOMIZE
        if (reset)
          currState = 4'hF;	// @[JtagStateMachine.scala:77:27, :78:26]
      `endif // RANDOMIZE
    end // initial
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif // FIRRTL_AFTER_INITIAL
  `endif // not def SYNTHESIS
  assign io_currState = currState;	// @[JtagStateMachine.scala:78:26]
endmodule
