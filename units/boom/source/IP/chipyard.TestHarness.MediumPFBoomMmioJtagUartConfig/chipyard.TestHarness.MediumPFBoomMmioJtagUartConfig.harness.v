module Queue_1_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [63:0] io_enq_bits_data,
  input  [7:0]  io_enq_bits_strb,
  input         io_deq_ready,
  output        io_deq_valid,
  output [63:0] io_deq_bits_data,
  output [7:0]  io_deq_bits_strb
);
`ifdef RANDOMIZE_MEM_INIT
  reg [63:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg [63:0] ram_data [0:1]; // @[Decoupled.scala 218:16]
  wire [63:0] ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [63:0] ram_data_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_en; // @[Decoupled.scala 218:16]
  reg [7:0] ram_strb [0:1]; // @[Decoupled.scala 218:16]
  wire [7:0] ram_strb_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_strb_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [7:0] ram_strb_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_en; // @[Decoupled.scala 218:16]
  reg  value; // @[Counter.scala 60:40]
  reg  value_1; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = value == value_1; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign ram_data_io_deq_bits_MPORT_addr = value_1;
  assign ram_data_io_deq_bits_MPORT_data = ram_data[ram_data_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_data_MPORT_data = io_enq_bits_data;
  assign ram_data_MPORT_addr = value;
  assign ram_data_MPORT_mask = 1'h1;
  assign ram_data_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_strb_io_deq_bits_MPORT_addr = value_1;
  assign ram_strb_io_deq_bits_MPORT_data = ram_strb[ram_strb_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_strb_MPORT_data = io_enq_bits_strb;
  assign ram_strb_MPORT_addr = value;
  assign ram_strb_MPORT_mask = 1'h1;
  assign ram_strb_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits_data = ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_strb = ram_strb_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_data_MPORT_en & ram_data_MPORT_mask) begin
      ram_data[ram_data_MPORT_addr] <= ram_data_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_strb_MPORT_en & ram_strb_MPORT_mask) begin
      ram_strb[ram_strb_MPORT_addr] <= ram_strb_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      value <= value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value_1 <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      value_1 <= value_1 + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {2{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_data[initvar] = _RAND_0[63:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_strb[initvar] = _RAND_1[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{`RANDOM}};
  value = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  value_1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  maybe_full = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_12_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [63:0] io_enq_bits_data,
  input  [7:0]  io_enq_bits_strb,
  input         io_enq_bits_last,
  input         io_deq_ready,
  output        io_deq_valid,
  output [63:0] io_deq_bits_data,
  output [7:0]  io_deq_bits_strb,
  output        io_deq_bits_last
);
`ifdef RANDOMIZE_MEM_INIT
  reg [63:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [63:0] ram_data [0:0]; // @[Decoupled.scala 218:16]
  wire [63:0] ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [63:0] ram_data_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_en; // @[Decoupled.scala 218:16]
  reg [7:0] ram_strb [0:0]; // @[Decoupled.scala 218:16]
  wire [7:0] ram_strb_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_strb_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [7:0] ram_strb_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_last [0:0]; // @[Decoupled.scala 218:16]
  wire  ram_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  empty = ~maybe_full; // @[Decoupled.scala 224:28]
  wire  _do_enq_T = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  _do_deq_T = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_9 = io_deq_ready ? 1'h0 : _do_enq_T; // @[Decoupled.scala 249:27 Decoupled.scala 249:36]
  wire  do_enq = empty ? _GEN_9 : _do_enq_T; // @[Decoupled.scala 246:18]
  wire  do_deq = empty ? 1'h0 : _do_deq_T; // @[Decoupled.scala 246:18 Decoupled.scala 248:14]
  assign ram_data_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_data_io_deq_bits_MPORT_data = ram_data[ram_data_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_data_MPORT_data = io_enq_bits_data;
  assign ram_data_MPORT_addr = 1'h0;
  assign ram_data_MPORT_mask = 1'h1;
  assign ram_data_MPORT_en = empty ? _GEN_9 : _do_enq_T;
  assign ram_strb_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_strb_io_deq_bits_MPORT_data = ram_strb[ram_strb_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_strb_MPORT_data = io_enq_bits_strb;
  assign ram_strb_MPORT_addr = 1'h0;
  assign ram_strb_MPORT_mask = 1'h1;
  assign ram_strb_MPORT_en = empty ? _GEN_9 : _do_enq_T;
  assign ram_last_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_last_io_deq_bits_MPORT_data = ram_last[ram_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_last_MPORT_data = io_enq_bits_last;
  assign ram_last_MPORT_addr = 1'h0;
  assign ram_last_MPORT_mask = 1'h1;
  assign ram_last_MPORT_en = empty ? _GEN_9 : _do_enq_T;
  assign io_enq_ready = ~maybe_full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = io_enq_valid | ~empty; // @[Decoupled.scala 245:25 Decoupled.scala 245:40 Decoupled.scala 240:16]
  assign io_deq_bits_data = empty ? io_enq_bits_data : ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_strb = empty ? io_enq_bits_strb : ram_strb_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_last = empty ? io_enq_bits_last : ram_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_data_MPORT_en & ram_data_MPORT_mask) begin
      ram_data[ram_data_MPORT_addr] <= ram_data_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_strb_MPORT_en & ram_strb_MPORT_mask) begin
      ram_strb[ram_strb_MPORT_addr] <= ram_strb_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_last_MPORT_en & ram_last_MPORT_mask) begin
      ram_last[ram_last_MPORT_addr] <= ram_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      if (empty) begin // @[Decoupled.scala 246:18]
        if (io_deq_ready) begin // @[Decoupled.scala 249:27]
          maybe_full <= 1'h0; // @[Decoupled.scala 249:36]
        end else begin
          maybe_full <= _do_enq_T;
        end
      end else begin
        maybe_full <= _do_enq_T;
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {2{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_data[initvar] = _RAND_0[63:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_strb[initvar] = _RAND_1[7:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_last[initvar] = _RAND_2[0:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_28_inTestHarness(
  input          clock,
  input          reset,
  output         io_enq_ready,
  input          io_enq_valid,
  input  [127:0] io_enq_bits_data,
  input  [15:0]  io_enq_bits_strb,
  input          io_enq_bits_last,
  input          io_deq_ready,
  output         io_deq_valid,
  output [127:0] io_deq_bits_data,
  output [15:0]  io_deq_bits_strb,
  output         io_deq_bits_last
);
`ifdef RANDOMIZE_MEM_INIT
  reg [127:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [127:0] ram_data [0:0]; // @[Decoupled.scala 218:16]
  wire [127:0] ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [127:0] ram_data_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_en; // @[Decoupled.scala 218:16]
  reg [15:0] ram_strb [0:0]; // @[Decoupled.scala 218:16]
  wire [15:0] ram_strb_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_strb_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [15:0] ram_strb_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_last [0:0]; // @[Decoupled.scala 218:16]
  wire  ram_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  empty = ~maybe_full; // @[Decoupled.scala 224:28]
  wire  _do_enq_T = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  _do_deq_T = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_9 = io_deq_ready ? 1'h0 : _do_enq_T; // @[Decoupled.scala 249:27 Decoupled.scala 249:36]
  wire  do_enq = empty ? _GEN_9 : _do_enq_T; // @[Decoupled.scala 246:18]
  wire  do_deq = empty ? 1'h0 : _do_deq_T; // @[Decoupled.scala 246:18 Decoupled.scala 248:14]
  assign ram_data_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_data_io_deq_bits_MPORT_data = ram_data[ram_data_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_data_MPORT_data = io_enq_bits_data;
  assign ram_data_MPORT_addr = 1'h0;
  assign ram_data_MPORT_mask = 1'h1;
  assign ram_data_MPORT_en = empty ? _GEN_9 : _do_enq_T;
  assign ram_strb_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_strb_io_deq_bits_MPORT_data = ram_strb[ram_strb_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_strb_MPORT_data = io_enq_bits_strb;
  assign ram_strb_MPORT_addr = 1'h0;
  assign ram_strb_MPORT_mask = 1'h1;
  assign ram_strb_MPORT_en = empty ? _GEN_9 : _do_enq_T;
  assign ram_last_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_last_io_deq_bits_MPORT_data = ram_last[ram_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_last_MPORT_data = io_enq_bits_last;
  assign ram_last_MPORT_addr = 1'h0;
  assign ram_last_MPORT_mask = 1'h1;
  assign ram_last_MPORT_en = empty ? _GEN_9 : _do_enq_T;
  assign io_enq_ready = ~maybe_full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = io_enq_valid | ~empty; // @[Decoupled.scala 245:25 Decoupled.scala 245:40 Decoupled.scala 240:16]
  assign io_deq_bits_data = empty ? io_enq_bits_data : ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_strb = empty ? io_enq_bits_strb : ram_strb_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_last = empty ? io_enq_bits_last : ram_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_data_MPORT_en & ram_data_MPORT_mask) begin
      ram_data[ram_data_MPORT_addr] <= ram_data_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_strb_MPORT_en & ram_strb_MPORT_mask) begin
      ram_strb[ram_strb_MPORT_addr] <= ram_strb_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_last_MPORT_en & ram_last_MPORT_mask) begin
      ram_last[ram_last_MPORT_addr] <= ram_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      if (empty) begin // @[Decoupled.scala 246:18]
        if (io_deq_ready) begin // @[Decoupled.scala 249:27]
          maybe_full <= 1'h0; // @[Decoupled.scala 249:36]
        end else begin
          maybe_full <= _do_enq_T;
        end
      end else begin
        maybe_full <= _do_enq_T;
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {4{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_data[initvar] = _RAND_0[127:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_strb[initvar] = _RAND_1[15:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_last[initvar] = _RAND_2[0:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AsyncResetSynchronizerPrimitiveShiftReg_d3_i0_inTestHarness(
  input   clock,
  input   reset,
  input   io_d,
  output  io_q
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg  sync_0; // @[SynchronizerReg.scala 51:87]
  reg  sync_1; // @[SynchronizerReg.scala 51:87]
  reg  sync_2; // @[SynchronizerReg.scala 51:87]
  assign io_q = sync_0; // @[SynchronizerReg.scala 59:8]
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      sync_0 <= 1'h0;
    end else begin
      sync_0 <= sync_1;
    end
  end
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      sync_1 <= 1'h0;
    end else begin
      sync_1 <= sync_2;
    end
  end
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      sync_2 <= 1'h0;
    end else begin
      sync_2 <= io_d;
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
  sync_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  sync_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  sync_2 = _RAND_2[0:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    sync_0 = 1'h0;
  end
  if (reset) begin
    sync_1 = 1'h0;
  end
  if (reset) begin
    sync_2 = 1'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AsyncResetSynchronizerShiftReg_w1_d3_i0_inTestHarness(
  input   clock,
  input   reset,
  output  io_q
);
  wire  output_chain_clock; // @[ShiftReg.scala 45:23]
  wire  output_chain_reset; // @[ShiftReg.scala 45:23]
  wire  output_chain_io_d; // @[ShiftReg.scala 45:23]
  wire  output_chain_io_q; // @[ShiftReg.scala 45:23]
  AsyncResetSynchronizerPrimitiveShiftReg_d3_i0_inTestHarness output_chain ( // @[ShiftReg.scala 45:23]
    .clock(output_chain_clock),
    .reset(output_chain_reset),
    .io_d(output_chain_io_d),
    .io_q(output_chain_io_q)
  );
  assign io_q = output_chain_io_q; // @[ShiftReg.scala 48:24 ShiftReg.scala 48:24]
  assign output_chain_clock = clock;
  assign output_chain_reset = reset; // @[SynchronizerReg.scala 86:21]
  assign output_chain_io_d = 1'h1; // @[SynchronizerReg.scala 87:41]
endmodule
module ClockGroupAggregator_6_inTestHarness(
  input   auto_in_member_allClocks_subsystem_cbus_0_clock,
  input   auto_in_member_allClocks_subsystem_cbus_0_reset,
  input   auto_in_member_allClocks_subsystem_mbus_0_clock,
  input   auto_in_member_allClocks_subsystem_mbus_0_reset,
  input   auto_in_member_allClocks_subsystem_fbus_0_clock,
  input   auto_in_member_allClocks_subsystem_fbus_0_reset,
  input   auto_in_member_allClocks_subsystem_pbus_0_clock,
  input   auto_in_member_allClocks_subsystem_pbus_0_reset,
  input   auto_in_member_allClocks_subsystem_sbus_1_clock,
  input   auto_in_member_allClocks_subsystem_sbus_1_reset,
  input   auto_in_member_allClocks_subsystem_sbus_0_clock,
  input   auto_in_member_allClocks_subsystem_sbus_0_reset,
  input   auto_in_member_allClocks_implicit_clock_clock,
  input   auto_in_member_allClocks_implicit_clock_reset,
  output  auto_out_5_member_subsystem_cbus_subsystem_cbus_0_clock,
  output  auto_out_5_member_subsystem_cbus_subsystem_cbus_0_reset,
  output  auto_out_4_member_subsystem_mbus_subsystem_mbus_0_clock,
  output  auto_out_4_member_subsystem_mbus_subsystem_mbus_0_reset,
  output  auto_out_3_member_subsystem_fbus_subsystem_fbus_0_clock,
  output  auto_out_3_member_subsystem_fbus_subsystem_fbus_0_reset,
  output  auto_out_2_member_subsystem_pbus_subsystem_pbus_0_clock,
  output  auto_out_2_member_subsystem_pbus_subsystem_pbus_0_reset,
  output  auto_out_1_member_subsystem_sbus_subsystem_sbus_1_clock,
  output  auto_out_1_member_subsystem_sbus_subsystem_sbus_1_reset,
  output  auto_out_1_member_subsystem_sbus_subsystem_sbus_0_clock,
  output  auto_out_1_member_subsystem_sbus_subsystem_sbus_0_reset,
  output  auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_clock,
  output  auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_reset
);
  assign auto_out_5_member_subsystem_cbus_subsystem_cbus_0_clock = auto_in_member_allClocks_subsystem_cbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_5_member_subsystem_cbus_subsystem_cbus_0_reset = auto_in_member_allClocks_subsystem_cbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_4_member_subsystem_mbus_subsystem_mbus_0_clock = auto_in_member_allClocks_subsystem_mbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_4_member_subsystem_mbus_subsystem_mbus_0_reset = auto_in_member_allClocks_subsystem_mbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_3_member_subsystem_fbus_subsystem_fbus_0_clock = auto_in_member_allClocks_subsystem_fbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_3_member_subsystem_fbus_subsystem_fbus_0_reset = auto_in_member_allClocks_subsystem_fbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_member_subsystem_pbus_subsystem_pbus_0_clock = auto_in_member_allClocks_subsystem_pbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_member_subsystem_pbus_subsystem_pbus_0_reset = auto_in_member_allClocks_subsystem_pbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_member_subsystem_sbus_subsystem_sbus_1_clock = auto_in_member_allClocks_subsystem_sbus_1_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_member_subsystem_sbus_subsystem_sbus_1_reset = auto_in_member_allClocks_subsystem_sbus_1_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_member_subsystem_sbus_subsystem_sbus_0_clock = auto_in_member_allClocks_subsystem_sbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_member_subsystem_sbus_subsystem_sbus_0_reset = auto_in_member_allClocks_subsystem_sbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_clock =
    auto_in_member_allClocks_implicit_clock_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_reset =
    auto_in_member_allClocks_implicit_clock_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module ClockGroup_6_inTestHarness(
  input   auto_in_member_dividerOnlyClockGenerator_implicit_clock_clock,
  input   auto_in_member_dividerOnlyClockGenerator_implicit_clock_reset,
  output  auto_out_clock,
  output  auto_out_reset
);
  assign auto_out_clock = auto_in_member_dividerOnlyClockGenerator_implicit_clock_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_reset = auto_in_member_dividerOnlyClockGenerator_implicit_clock_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module ClockGroupParameterModifier_inTestHarness(
  input   auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_clock,
  input   auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_reset,
  input   auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_clock,
  input   auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_reset,
  input   auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_clock,
  input   auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_reset,
  input   auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_clock,
  input   auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_reset,
  input   auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_clock,
  input   auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_reset,
  input   auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_clock,
  input   auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_reset,
  output  auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_clock,
  output  auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_reset,
  output  auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_clock,
  output  auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_reset,
  output  auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_clock,
  output  auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_reset,
  output  auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_clock,
  output  auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_reset,
  output  auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_clock,
  output  auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_reset,
  output  auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_clock,
  output  auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_reset
);
  assign auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_clock =
    auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_reset =
    auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_clock =
    auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_reset =
    auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_clock =
    auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_reset =
    auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_clock =
    auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_reset =
    auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_clock =
    auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_reset =
    auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_clock =
    auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_reset =
    auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module DividerOnlyClockGenerator_inTestHarness(
  input   auto_divider_only_clk_generator_in_clock,
  input   auto_divider_only_clk_generator_in_reset,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_clock,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_reset,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_clock,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_reset,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_clock,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_reset,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_clock,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_reset,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_clock,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_reset,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_clock,
  output  auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_reset,
  output  auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_clock,
  output  auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_reset
);
  wire  bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out; // @[DividerOnlyClockGenerator.scala 133:27]
  wire  bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_in; // @[DividerOnlyClockGenerator.scala 133:27]
  ClockDividerN #(.DIV(1)) bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1 ( // @[DividerOnlyClockGenerator.scala 133:27]
    .clk_out(bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out),
    .clk_in(bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_in)
  );
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_clock =
    bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out; // @[Nodes.scala 1207:84 DividerOnlyClockGenerator.scala 142:19]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_reset =
    auto_divider_only_clk_generator_in_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_clock =
    bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out; // @[Nodes.scala 1207:84 DividerOnlyClockGenerator.scala 142:19]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_reset =
    auto_divider_only_clk_generator_in_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_clock =
    bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out; // @[Nodes.scala 1207:84 DividerOnlyClockGenerator.scala 142:19]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_reset =
    auto_divider_only_clk_generator_in_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_clock =
    bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out; // @[Nodes.scala 1207:84 DividerOnlyClockGenerator.scala 142:19]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_reset =
    auto_divider_only_clk_generator_in_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_clock =
    bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out; // @[Nodes.scala 1207:84 DividerOnlyClockGenerator.scala 142:19]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_reset =
    auto_divider_only_clk_generator_in_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_clock =
    bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out; // @[Nodes.scala 1207:84 DividerOnlyClockGenerator.scala 142:19]
  assign auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_reset =
    auto_divider_only_clk_generator_in_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_clock =
    bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_out; // @[Nodes.scala 1207:84 DividerOnlyClockGenerator.scala 142:19]
  assign auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_reset =
    auto_divider_only_clk_generator_in_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_member_allClocks_implicit_clock_clock_ClockDivideBy1_clk_in =
    auto_divider_only_clk_generator_in_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module ClockGroupParameterModifier_1_inTestHarness(
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_clock,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_reset,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_clock,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_reset,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_clock,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_reset,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_clock,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_reset,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_clock,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_reset,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_clock,
  input   auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_reset,
  input   auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_clock,
  input   auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_reset,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_clock,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_reset,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_clock,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_reset,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_clock,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_reset,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_clock,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_reset,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_clock,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_reset,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_clock,
  output  auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_reset,
  output  auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_clock,
  output  auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_reset
);
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_clock =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_reset =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_clock =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_reset =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_clock =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_reset =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_clock =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_reset =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_clock =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_reset =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_clock =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_reset =
    auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_clock =
    auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_reset =
    auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module ResetCatchAndSync_d3_inTestHarness(
  input   clock,
  input   reset,
  output  io_sync_reset
);
  wire  io_sync_reset_chain_clock; // @[ShiftReg.scala 45:23]
  wire  io_sync_reset_chain_reset; // @[ShiftReg.scala 45:23]
  wire  io_sync_reset_chain_io_q; // @[ShiftReg.scala 45:23]
  wire  _io_sync_reset_WIRE = io_sync_reset_chain_io_q; // @[ShiftReg.scala 48:24 ShiftReg.scala 48:24]
  AsyncResetSynchronizerShiftReg_w1_d3_i0_inTestHarness io_sync_reset_chain ( // @[ShiftReg.scala 45:23]
    .clock(io_sync_reset_chain_clock),
    .reset(io_sync_reset_chain_reset),
    .io_q(io_sync_reset_chain_io_q)
  );
  assign io_sync_reset = ~_io_sync_reset_WIRE; // @[ResetCatchAndSync.scala 29:7]
  assign io_sync_reset_chain_clock = clock;
  assign io_sync_reset_chain_reset = reset; // @[ResetCatchAndSync.scala 26:27]
endmodule
module ClockGroupResetSynchronizer_inTestHarness(
  input   auto_in_member_allClocks_subsystem_cbus_0_clock,
  input   auto_in_member_allClocks_subsystem_cbus_0_reset,
  input   auto_in_member_allClocks_subsystem_mbus_0_clock,
  input   auto_in_member_allClocks_subsystem_mbus_0_reset,
  input   auto_in_member_allClocks_subsystem_fbus_0_clock,
  input   auto_in_member_allClocks_subsystem_fbus_0_reset,
  input   auto_in_member_allClocks_subsystem_pbus_0_clock,
  input   auto_in_member_allClocks_subsystem_pbus_0_reset,
  input   auto_in_member_allClocks_subsystem_sbus_1_clock,
  input   auto_in_member_allClocks_subsystem_sbus_1_reset,
  input   auto_in_member_allClocks_subsystem_sbus_0_clock,
  input   auto_in_member_allClocks_subsystem_sbus_0_reset,
  input   auto_in_member_allClocks_implicit_clock_clock,
  input   auto_in_member_allClocks_implicit_clock_reset,
  output  auto_out_member_allClocks_subsystem_cbus_0_clock,
  output  auto_out_member_allClocks_subsystem_cbus_0_reset,
  output  auto_out_member_allClocks_subsystem_mbus_0_clock,
  output  auto_out_member_allClocks_subsystem_mbus_0_reset,
  output  auto_out_member_allClocks_subsystem_fbus_0_clock,
  output  auto_out_member_allClocks_subsystem_fbus_0_reset,
  output  auto_out_member_allClocks_subsystem_pbus_0_clock,
  output  auto_out_member_allClocks_subsystem_pbus_0_reset,
  output  auto_out_member_allClocks_subsystem_sbus_1_clock,
  output  auto_out_member_allClocks_subsystem_sbus_1_reset,
  output  auto_out_member_allClocks_subsystem_sbus_0_clock,
  output  auto_out_member_allClocks_subsystem_sbus_0_reset,
  output  auto_out_member_allClocks_implicit_clock_clock,
  output  auto_out_member_allClocks_implicit_clock_reset
);
  wire  bundleOut_0_member_allClocks_implicit_clock_reset_catcher_clock; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_implicit_clock_reset_catcher_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_implicit_clock_reset_catcher_io_sync_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_clock; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_io_sync_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_clock; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_io_sync_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_clock; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_io_sync_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_clock; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_io_sync_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_clock; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_io_sync_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_clock; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_io_sync_reset; // @[ResetCatchAndSync.scala 39:28]
  ResetCatchAndSync_d3_inTestHarness bundleOut_0_member_allClocks_implicit_clock_reset_catcher ( // @[ResetCatchAndSync.scala 39:28]
    .clock(bundleOut_0_member_allClocks_implicit_clock_reset_catcher_clock),
    .reset(bundleOut_0_member_allClocks_implicit_clock_reset_catcher_reset),
    .io_sync_reset(bundleOut_0_member_allClocks_implicit_clock_reset_catcher_io_sync_reset)
  );
  ResetCatchAndSync_d3_inTestHarness bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher ( // @[ResetCatchAndSync.scala 39:28]
    .clock(bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_clock),
    .reset(bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_reset),
    .io_sync_reset(bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_io_sync_reset)
  );
  ResetCatchAndSync_d3_inTestHarness bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher ( // @[ResetCatchAndSync.scala 39:28]
    .clock(bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_clock),
    .reset(bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_reset),
    .io_sync_reset(bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_io_sync_reset)
  );
  ResetCatchAndSync_d3_inTestHarness bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher ( // @[ResetCatchAndSync.scala 39:28]
    .clock(bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_clock),
    .reset(bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_reset),
    .io_sync_reset(bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_io_sync_reset)
  );
  ResetCatchAndSync_d3_inTestHarness bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher ( // @[ResetCatchAndSync.scala 39:28]
    .clock(bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_clock),
    .reset(bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_reset),
    .io_sync_reset(bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_io_sync_reset)
  );
  ResetCatchAndSync_d3_inTestHarness bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher ( // @[ResetCatchAndSync.scala 39:28]
    .clock(bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_clock),
    .reset(bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_reset),
    .io_sync_reset(bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_io_sync_reset)
  );
  ResetCatchAndSync_d3_inTestHarness bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher ( // @[ResetCatchAndSync.scala 39:28]
    .clock(bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_clock),
    .reset(bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_reset),
    .io_sync_reset(bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_io_sync_reset)
  );
  assign auto_out_member_allClocks_subsystem_cbus_0_clock = auto_in_member_allClocks_subsystem_cbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_member_allClocks_subsystem_cbus_0_reset =
    bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_io_sync_reset; // @[Nodes.scala 1207:84 ResetSynchronizer.scala 35:17]
  assign auto_out_member_allClocks_subsystem_mbus_0_clock = auto_in_member_allClocks_subsystem_mbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_member_allClocks_subsystem_mbus_0_reset =
    bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_io_sync_reset; // @[Nodes.scala 1207:84 ResetSynchronizer.scala 35:17]
  assign auto_out_member_allClocks_subsystem_fbus_0_clock = auto_in_member_allClocks_subsystem_fbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_member_allClocks_subsystem_fbus_0_reset =
    bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_io_sync_reset; // @[Nodes.scala 1207:84 ResetSynchronizer.scala 35:17]
  assign auto_out_member_allClocks_subsystem_pbus_0_clock = auto_in_member_allClocks_subsystem_pbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_member_allClocks_subsystem_pbus_0_reset =
    bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_io_sync_reset; // @[Nodes.scala 1207:84 ResetSynchronizer.scala 35:17]
  assign auto_out_member_allClocks_subsystem_sbus_1_clock = auto_in_member_allClocks_subsystem_sbus_1_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_member_allClocks_subsystem_sbus_1_reset =
    bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_io_sync_reset; // @[Nodes.scala 1207:84 ResetSynchronizer.scala 35:17]
  assign auto_out_member_allClocks_subsystem_sbus_0_clock = auto_in_member_allClocks_subsystem_sbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_member_allClocks_subsystem_sbus_0_reset =
    bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_io_sync_reset; // @[Nodes.scala 1207:84 ResetSynchronizer.scala 35:17]
  assign auto_out_member_allClocks_implicit_clock_clock = auto_in_member_allClocks_implicit_clock_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_member_allClocks_implicit_clock_reset =
    bundleOut_0_member_allClocks_implicit_clock_reset_catcher_io_sync_reset; // @[Nodes.scala 1207:84 ResetSynchronizer.scala 35:17]
  assign bundleOut_0_member_allClocks_implicit_clock_reset_catcher_clock = auto_in_member_allClocks_implicit_clock_clock
    ; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_member_allClocks_implicit_clock_reset_catcher_reset = auto_in_member_allClocks_implicit_clock_reset
    ; // @[ResetSynchronizer.scala 35:55]
  assign bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_clock =
    auto_in_member_allClocks_subsystem_sbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_member_allClocks_subsystem_sbus_0_reset_catcher_reset =
    auto_in_member_allClocks_subsystem_sbus_0_reset; // @[ResetSynchronizer.scala 35:55]
  assign bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_clock =
    auto_in_member_allClocks_subsystem_sbus_1_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_member_allClocks_subsystem_sbus_1_reset_catcher_reset =
    auto_in_member_allClocks_subsystem_sbus_1_reset; // @[ResetSynchronizer.scala 35:55]
  assign bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_clock =
    auto_in_member_allClocks_subsystem_pbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_member_allClocks_subsystem_pbus_0_reset_catcher_reset =
    auto_in_member_allClocks_subsystem_pbus_0_reset; // @[ResetSynchronizer.scala 35:55]
  assign bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_clock =
    auto_in_member_allClocks_subsystem_fbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_member_allClocks_subsystem_fbus_0_reset_catcher_reset =
    auto_in_member_allClocks_subsystem_fbus_0_reset; // @[ResetSynchronizer.scala 35:55]
  assign bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_clock =
    auto_in_member_allClocks_subsystem_mbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_member_allClocks_subsystem_mbus_0_reset_catcher_reset =
    auto_in_member_allClocks_subsystem_mbus_0_reset; // @[ResetSynchronizer.scala 35:55]
  assign bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_clock =
    auto_in_member_allClocks_subsystem_cbus_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_member_allClocks_subsystem_cbus_0_reset_catcher_reset =
    auto_in_member_allClocks_subsystem_cbus_0_reset; // @[ResetSynchronizer.scala 35:55]
endmodule
module FixedClockBroadcast_7_inTestHarness(
  input   auto_in_clock,
  input   auto_in_reset,
  output  auto_out_clock,
  output  auto_out_reset
);
  assign auto_out_clock = auto_in_clock; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_reset = auto_in_reset; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module ResetSynchronizerShiftReg_w1_d3_i0_inTestHarness(
  input   clock,
  input   reset,
  input   io_d,
  output  io_q
);
  wire  output_chain_clock; // @[ShiftReg.scala 45:23]
  wire  output_chain_reset; // @[ShiftReg.scala 45:23]
  wire  output_chain_io_d; // @[ShiftReg.scala 45:23]
  wire  output_chain_io_q; // @[ShiftReg.scala 45:23]
  AsyncResetSynchronizerPrimitiveShiftReg_d3_i0_inTestHarness output_chain ( // @[ShiftReg.scala 45:23]
    .clock(output_chain_clock),
    .reset(output_chain_reset),
    .io_d(output_chain_io_d),
    .io_q(output_chain_io_q)
  );
  assign io_q = output_chain_io_q; // @[ShiftReg.scala 48:24 ShiftReg.scala 48:24]
  assign output_chain_clock = clock;
  assign output_chain_reset = reset;
  assign output_chain_io_d = io_d; // @[SynchronizerReg.scala 147:39]
endmodule
module ChipTop_inTestHarness(
  input          jtag_TCK,
  input          jtag_TMS,
  input          jtag_TDI,
  output         jtag_TDO,
  output         axi4_mmio_0_clock,
  output         axi4_mmio_0_reset,
  input          axi4_mmio_0_bits_aw_ready,
  output         axi4_mmio_0_bits_aw_valid,
  output [3:0]   axi4_mmio_0_bits_aw_bits_id,
  output [31:0]  axi4_mmio_0_bits_aw_bits_addr,
  output [7:0]   axi4_mmio_0_bits_aw_bits_len,
  output [2:0]   axi4_mmio_0_bits_aw_bits_size,
  output [1:0]   axi4_mmio_0_bits_aw_bits_burst,
  input          axi4_mmio_0_bits_w_ready,
  output         axi4_mmio_0_bits_w_valid,
  output [63:0]  axi4_mmio_0_bits_w_bits_data,
  output [7:0]   axi4_mmio_0_bits_w_bits_strb,
  output         axi4_mmio_0_bits_w_bits_last,
  output         axi4_mmio_0_bits_b_ready,
  input          axi4_mmio_0_bits_b_valid,
  input  [3:0]   axi4_mmio_0_bits_b_bits_id,
  input  [1:0]   axi4_mmio_0_bits_b_bits_resp,
  input          axi4_mmio_0_bits_ar_ready,
  output         axi4_mmio_0_bits_ar_valid,
  output [3:0]   axi4_mmio_0_bits_ar_bits_id,
  output [31:0]  axi4_mmio_0_bits_ar_bits_addr,
  output [7:0]   axi4_mmio_0_bits_ar_bits_len,
  output [2:0]   axi4_mmio_0_bits_ar_bits_size,
  output [1:0]   axi4_mmio_0_bits_ar_bits_burst,
  output         axi4_mmio_0_bits_r_ready,
  input          axi4_mmio_0_bits_r_valid,
  input  [3:0]   axi4_mmio_0_bits_r_bits_id,
  input  [63:0]  axi4_mmio_0_bits_r_bits_data,
  input  [1:0]   axi4_mmio_0_bits_r_bits_resp,
  input          axi4_mmio_0_bits_r_bits_last,
  output         axi4_mem_0_clock,
  output         axi4_mem_0_reset,
  input          axi4_mem_0_bits_aw_ready,
  output         axi4_mem_0_bits_aw_valid,
  output [3:0]   axi4_mem_0_bits_aw_bits_id,
  output [31:0]  axi4_mem_0_bits_aw_bits_addr,
  output [7:0]   axi4_mem_0_bits_aw_bits_len,
  output [2:0]   axi4_mem_0_bits_aw_bits_size,
  output [1:0]   axi4_mem_0_bits_aw_bits_burst,
  input          axi4_mem_0_bits_w_ready,
  output         axi4_mem_0_bits_w_valid,
  output [127:0] axi4_mem_0_bits_w_bits_data,
  output [15:0]  axi4_mem_0_bits_w_bits_strb,
  output         axi4_mem_0_bits_w_bits_last,
  output         axi4_mem_0_bits_b_ready,
  input          axi4_mem_0_bits_b_valid,
  input  [3:0]   axi4_mem_0_bits_b_bits_id,
  input  [1:0]   axi4_mem_0_bits_b_bits_resp,
  input          axi4_mem_0_bits_ar_ready,
  output         axi4_mem_0_bits_ar_valid,
  output [3:0]   axi4_mem_0_bits_ar_bits_id,
  output [31:0]  axi4_mem_0_bits_ar_bits_addr,
  output [7:0]   axi4_mem_0_bits_ar_bits_len,
  output [2:0]   axi4_mem_0_bits_ar_bits_size,
  output [1:0]   axi4_mem_0_bits_ar_bits_burst,
  output         axi4_mem_0_bits_r_ready,
  input          axi4_mem_0_bits_r_valid,
  input  [3:0]   axi4_mem_0_bits_r_bits_id,
  input  [127:0] axi4_mem_0_bits_r_bits_data,
  input  [1:0]   axi4_mem_0_bits_r_bits_resp,
  input          axi4_mem_0_bits_r_bits_last,
  output         uart_0_txd,
  input          uart_0_rxd,
  input          reset_wire_reset,
  input          clock
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  wire  system_clock; // @[ChipTop.scala 32:35]
  wire  system_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_async_reset_sink_in_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_async_reset_sink_in_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_mbus_fixedClockNode_out_1_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_mbus_fixedClockNode_out_1_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_mbus_fixedClockNode_out_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_mbus_fixedClockNode_out_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_cbus_fixedClockNode_out_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_cbus_fixedClockNode_out_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_fbus_fixedClockNode_out_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_fbus_fixedClockNode_out_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_reset; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_clock; // @[ChipTop.scala 32:35]
  wire  system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_reset; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_aw_ready; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_aw_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_mem_axi4_0_aw_bits_id; // @[ChipTop.scala 32:35]
  wire [31:0] system_mem_axi4_0_aw_bits_addr; // @[ChipTop.scala 32:35]
  wire [7:0] system_mem_axi4_0_aw_bits_len; // @[ChipTop.scala 32:35]
  wire [2:0] system_mem_axi4_0_aw_bits_size; // @[ChipTop.scala 32:35]
  wire [1:0] system_mem_axi4_0_aw_bits_burst; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_aw_bits_lock; // @[ChipTop.scala 32:35]
  wire [3:0] system_mem_axi4_0_aw_bits_cache; // @[ChipTop.scala 32:35]
  wire [2:0] system_mem_axi4_0_aw_bits_prot; // @[ChipTop.scala 32:35]
  wire [3:0] system_mem_axi4_0_aw_bits_qos; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_w_ready; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_w_valid; // @[ChipTop.scala 32:35]
  wire [127:0] system_mem_axi4_0_w_bits_data; // @[ChipTop.scala 32:35]
  wire [15:0] system_mem_axi4_0_w_bits_strb; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_w_bits_last; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_b_ready; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_b_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_mem_axi4_0_b_bits_id; // @[ChipTop.scala 32:35]
  wire [1:0] system_mem_axi4_0_b_bits_resp; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_ar_ready; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_ar_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_mem_axi4_0_ar_bits_id; // @[ChipTop.scala 32:35]
  wire [31:0] system_mem_axi4_0_ar_bits_addr; // @[ChipTop.scala 32:35]
  wire [7:0] system_mem_axi4_0_ar_bits_len; // @[ChipTop.scala 32:35]
  wire [2:0] system_mem_axi4_0_ar_bits_size; // @[ChipTop.scala 32:35]
  wire [1:0] system_mem_axi4_0_ar_bits_burst; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_ar_bits_lock; // @[ChipTop.scala 32:35]
  wire [3:0] system_mem_axi4_0_ar_bits_cache; // @[ChipTop.scala 32:35]
  wire [2:0] system_mem_axi4_0_ar_bits_prot; // @[ChipTop.scala 32:35]
  wire [3:0] system_mem_axi4_0_ar_bits_qos; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_r_ready; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_r_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_mem_axi4_0_r_bits_id; // @[ChipTop.scala 32:35]
  wire [127:0] system_mem_axi4_0_r_bits_data; // @[ChipTop.scala 32:35]
  wire [1:0] system_mem_axi4_0_r_bits_resp; // @[ChipTop.scala 32:35]
  wire  system_mem_axi4_0_r_bits_last; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_aw_ready; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_aw_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_mmio_axi4_0_aw_bits_id; // @[ChipTop.scala 32:35]
  wire [31:0] system_mmio_axi4_0_aw_bits_addr; // @[ChipTop.scala 32:35]
  wire [7:0] system_mmio_axi4_0_aw_bits_len; // @[ChipTop.scala 32:35]
  wire [2:0] system_mmio_axi4_0_aw_bits_size; // @[ChipTop.scala 32:35]
  wire [1:0] system_mmio_axi4_0_aw_bits_burst; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_aw_bits_lock; // @[ChipTop.scala 32:35]
  wire [3:0] system_mmio_axi4_0_aw_bits_cache; // @[ChipTop.scala 32:35]
  wire [2:0] system_mmio_axi4_0_aw_bits_prot; // @[ChipTop.scala 32:35]
  wire [3:0] system_mmio_axi4_0_aw_bits_qos; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_w_ready; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_w_valid; // @[ChipTop.scala 32:35]
  wire [63:0] system_mmio_axi4_0_w_bits_data; // @[ChipTop.scala 32:35]
  wire [7:0] system_mmio_axi4_0_w_bits_strb; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_w_bits_last; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_b_ready; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_b_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_mmio_axi4_0_b_bits_id; // @[ChipTop.scala 32:35]
  wire [1:0] system_mmio_axi4_0_b_bits_resp; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_ar_ready; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_ar_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_mmio_axi4_0_ar_bits_id; // @[ChipTop.scala 32:35]
  wire [31:0] system_mmio_axi4_0_ar_bits_addr; // @[ChipTop.scala 32:35]
  wire [7:0] system_mmio_axi4_0_ar_bits_len; // @[ChipTop.scala 32:35]
  wire [2:0] system_mmio_axi4_0_ar_bits_size; // @[ChipTop.scala 32:35]
  wire [1:0] system_mmio_axi4_0_ar_bits_burst; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_ar_bits_lock; // @[ChipTop.scala 32:35]
  wire [3:0] system_mmio_axi4_0_ar_bits_cache; // @[ChipTop.scala 32:35]
  wire [2:0] system_mmio_axi4_0_ar_bits_prot; // @[ChipTop.scala 32:35]
  wire [3:0] system_mmio_axi4_0_ar_bits_qos; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_r_ready; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_r_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_mmio_axi4_0_r_bits_id; // @[ChipTop.scala 32:35]
  wire [63:0] system_mmio_axi4_0_r_bits_data; // @[ChipTop.scala 32:35]
  wire [1:0] system_mmio_axi4_0_r_bits_resp; // @[ChipTop.scala 32:35]
  wire  system_mmio_axi4_0_r_bits_last; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_aw_ready; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_aw_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_l2_frontend_bus_axi4_0_aw_bits_id; // @[ChipTop.scala 32:35]
  wire [31:0] system_l2_frontend_bus_axi4_0_aw_bits_addr; // @[ChipTop.scala 32:35]
  wire [7:0] system_l2_frontend_bus_axi4_0_aw_bits_len; // @[ChipTop.scala 32:35]
  wire [2:0] system_l2_frontend_bus_axi4_0_aw_bits_size; // @[ChipTop.scala 32:35]
  wire [1:0] system_l2_frontend_bus_axi4_0_aw_bits_burst; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_aw_bits_lock; // @[ChipTop.scala 32:35]
  wire [3:0] system_l2_frontend_bus_axi4_0_aw_bits_cache; // @[ChipTop.scala 32:35]
  wire [2:0] system_l2_frontend_bus_axi4_0_aw_bits_prot; // @[ChipTop.scala 32:35]
  wire [3:0] system_l2_frontend_bus_axi4_0_aw_bits_qos; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_w_ready; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_w_valid; // @[ChipTop.scala 32:35]
  wire [127:0] system_l2_frontend_bus_axi4_0_w_bits_data; // @[ChipTop.scala 32:35]
  wire [15:0] system_l2_frontend_bus_axi4_0_w_bits_strb; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_w_bits_last; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_b_ready; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_b_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_l2_frontend_bus_axi4_0_b_bits_id; // @[ChipTop.scala 32:35]
  wire [1:0] system_l2_frontend_bus_axi4_0_b_bits_resp; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_ar_ready; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_ar_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_l2_frontend_bus_axi4_0_ar_bits_id; // @[ChipTop.scala 32:35]
  wire [31:0] system_l2_frontend_bus_axi4_0_ar_bits_addr; // @[ChipTop.scala 32:35]
  wire [7:0] system_l2_frontend_bus_axi4_0_ar_bits_len; // @[ChipTop.scala 32:35]
  wire [2:0] system_l2_frontend_bus_axi4_0_ar_bits_size; // @[ChipTop.scala 32:35]
  wire [1:0] system_l2_frontend_bus_axi4_0_ar_bits_burst; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_ar_bits_lock; // @[ChipTop.scala 32:35]
  wire [3:0] system_l2_frontend_bus_axi4_0_ar_bits_cache; // @[ChipTop.scala 32:35]
  wire [2:0] system_l2_frontend_bus_axi4_0_ar_bits_prot; // @[ChipTop.scala 32:35]
  wire [3:0] system_l2_frontend_bus_axi4_0_ar_bits_qos; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_r_ready; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_r_valid; // @[ChipTop.scala 32:35]
  wire [3:0] system_l2_frontend_bus_axi4_0_r_bits_id; // @[ChipTop.scala 32:35]
  wire [127:0] system_l2_frontend_bus_axi4_0_r_bits_data; // @[ChipTop.scala 32:35]
  wire [1:0] system_l2_frontend_bus_axi4_0_r_bits_resp; // @[ChipTop.scala 32:35]
  wire  system_l2_frontend_bus_axi4_0_r_bits_last; // @[ChipTop.scala 32:35]
  wire  system_resetctrl_hartIsInReset_0; // @[ChipTop.scala 32:35]
  wire  system_debug_clock; // @[ChipTop.scala 32:35]
  wire  system_debug_reset; // @[ChipTop.scala 32:35]
  wire  system_debug_systemjtag_jtag_TCK; // @[ChipTop.scala 32:35]
  wire  system_debug_systemjtag_jtag_TMS; // @[ChipTop.scala 32:35]
  wire  system_debug_systemjtag_jtag_TDI; // @[ChipTop.scala 32:35]
  wire  system_debug_systemjtag_jtag_TDO_data; // @[ChipTop.scala 32:35]
  wire  system_debug_systemjtag_jtag_TDO_driven; // @[ChipTop.scala 32:35]
  wire  system_debug_systemjtag_reset; // @[ChipTop.scala 32:35]
  wire [10:0] system_debug_systemjtag_mfr_id; // @[ChipTop.scala 32:35]
  wire [15:0] system_debug_systemjtag_part_number; // @[ChipTop.scala 32:35]
  wire [3:0] system_debug_systemjtag_version; // @[ChipTop.scala 32:35]
  wire  system_debug_ndreset; // @[ChipTop.scala 32:35]
  wire  system_debug_dmactive; // @[ChipTop.scala 32:35]
  wire  system_debug_dmactiveAck; // @[ChipTop.scala 32:35]
  wire [7:0] system_interrupts; // @[ChipTop.scala 32:35]
  wire  system_traceIO_traces_0_clock; // @[ChipTop.scala 32:35]
  wire  system_traceIO_traces_0_reset; // @[ChipTop.scala 32:35]
  wire  system_traceIO_traces_0_insns_0_valid; // @[ChipTop.scala 32:35]
  wire [39:0] system_traceIO_traces_0_insns_0_iaddr; // @[ChipTop.scala 32:35]
  wire [31:0] system_traceIO_traces_0_insns_0_insn; // @[ChipTop.scala 32:35]
  wire [63:0] system_traceIO_traces_0_insns_0_wdata; // @[ChipTop.scala 32:35]
  wire [2:0] system_traceIO_traces_0_insns_0_priv; // @[ChipTop.scala 32:35]
  wire  system_traceIO_traces_0_insns_0_exception; // @[ChipTop.scala 32:35]
  wire  system_traceIO_traces_0_insns_0_interrupt; // @[ChipTop.scala 32:35]
  wire [63:0] system_traceIO_traces_0_insns_0_cause; // @[ChipTop.scala 32:35]
  wire [39:0] system_traceIO_traces_0_insns_0_tval; // @[ChipTop.scala 32:35]
  wire  system_traceIO_traces_0_insns_1_valid; // @[ChipTop.scala 32:35]
  wire [39:0] system_traceIO_traces_0_insns_1_iaddr; // @[ChipTop.scala 32:35]
  wire [31:0] system_traceIO_traces_0_insns_1_insn; // @[ChipTop.scala 32:35]
  wire [63:0] system_traceIO_traces_0_insns_1_wdata; // @[ChipTop.scala 32:35]
  wire [2:0] system_traceIO_traces_0_insns_1_priv; // @[ChipTop.scala 32:35]
  wire  system_traceIO_traces_0_insns_1_exception; // @[ChipTop.scala 32:35]
  wire  system_traceIO_traces_0_insns_1_interrupt; // @[ChipTop.scala 32:35]
  wire [63:0] system_traceIO_traces_0_insns_1_cause; // @[ChipTop.scala 32:35]
  wire [39:0] system_traceIO_traces_0_insns_1_tval; // @[ChipTop.scala 32:35]
  wire  system_uart_0_txd; // @[ChipTop.scala 32:35]
  wire  system_uart_0_rxd; // @[ChipTop.scala 32:35]
  wire  aggregator_auto_in_member_allClocks_subsystem_cbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_cbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_mbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_mbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_fbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_fbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_pbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_pbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_sbus_1_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_sbus_1_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_sbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_subsystem_sbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_implicit_clock_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_in_member_allClocks_implicit_clock_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_5_member_subsystem_cbus_subsystem_cbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_5_member_subsystem_cbus_subsystem_cbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_4_member_subsystem_mbus_subsystem_mbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_4_member_subsystem_mbus_subsystem_mbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_3_member_subsystem_fbus_subsystem_fbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_3_member_subsystem_fbus_subsystem_fbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_2_member_subsystem_pbus_subsystem_pbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_2_member_subsystem_pbus_subsystem_pbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_1_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_1_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_0_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_0_reset; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_clock; // @[Clocks.scala 79:32]
  wire  aggregator_auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_reset; // @[Clocks.scala 79:32]
  wire  dividerOnlyClockGenerator_auto_in_member_dividerOnlyClockGenerator_implicit_clock_clock; // @[ClockGroup.scala 32:69]
  wire  dividerOnlyClockGenerator_auto_in_member_dividerOnlyClockGenerator_implicit_clock_reset; // @[ClockGroup.scala 32:69]
  wire  dividerOnlyClockGenerator_auto_out_clock; // @[ClockGroup.scala 32:69]
  wire  dividerOnlyClockGenerator_auto_out_reset; // @[ClockGroup.scala 32:69]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_clock; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_reset; // @[ClockGroupNamePrefixer.scala 32:15]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_in_clock; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_in_reset; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_clock; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_reset; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_clock; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_reset; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_clock; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_reset; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_clock; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_reset; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_clock; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_reset; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_clock; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_reset; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_clock; // @[Clocks.scala 90:45]
  wire  dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_reset; // @[Clocks.scala 90:45]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_clock; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_reset; // @[ClockGroupNamePrefixer.scala 68:15]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_cbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_cbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_mbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_mbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_fbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_fbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_pbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_pbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_1_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_1_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_implicit_clock_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_in_member_allClocks_implicit_clock_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_cbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_cbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_mbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_mbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_fbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_fbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_pbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_pbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_1_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_1_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_0_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_0_reset; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_implicit_clock_clock; // @[ResetSynchronizer.scala 42:69]
  wire  dividerOnlyClockGenerator_3_auto_out_member_allClocks_implicit_clock_reset; // @[ResetSynchronizer.scala 42:69]
  wire  asyncResetBroadcast_auto_in_clock; // @[ClockGroup.scala 106:107]
  wire  asyncResetBroadcast_auto_in_reset; // @[ClockGroup.scala 106:107]
  wire  asyncResetBroadcast_auto_out_clock; // @[ClockGroup.scala 106:107]
  wire  asyncResetBroadcast_auto_out_reset; // @[ClockGroup.scala 106:107]
  wire  system_debug_systemjtag_reset_catcher_clock; // @[ResetCatchAndSync.scala 39:28]
  wire  system_debug_systemjtag_reset_catcher_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  system_debug_systemjtag_reset_catcher_io_sync_reset; // @[ResetCatchAndSync.scala 39:28]
  wire  debug_reset_syncd_debug_reset_sync_clock; // @[ShiftReg.scala 45:23]
  wire  debug_reset_syncd_debug_reset_sync_reset; // @[ShiftReg.scala 45:23]
  wire  debug_reset_syncd_debug_reset_sync_io_q; // @[ShiftReg.scala 45:23]
  wire  dmactiveAck_dmactiveAck_clock; // @[ShiftReg.scala 45:23]
  wire  dmactiveAck_dmactiveAck_reset; // @[ShiftReg.scala 45:23]
  wire  dmactiveAck_dmactiveAck_io_d; // @[ShiftReg.scala 45:23]
  wire  dmactiveAck_dmactiveAck_io_q; // @[ShiftReg.scala 45:23]
  wire  gated_clock_debug_clock_gate_in; // @[ClockGate.scala 24:20]
  wire  gated_clock_debug_clock_gate_test_en; // @[ClockGate.scala 24:20]
  wire  gated_clock_debug_clock_gate_en; // @[ClockGate.scala 24:20]
  wire  gated_clock_debug_clock_gate_out; // @[ClockGate.scala 24:20]
  wire  iocell_jtag_TDO_pad; // @[IOCell.scala 112:24]
  wire  iocell_jtag_TDO_o; // @[IOCell.scala 112:24]
  wire  iocell_jtag_TDO_oe; // @[IOCell.scala 112:24]
  wire  iocell_jtag_TDI_pad; // @[IOCell.scala 111:23]
  wire  iocell_jtag_TDI_i; // @[IOCell.scala 111:23]
  wire  iocell_jtag_TDI_ie; // @[IOCell.scala 111:23]
  wire  iocell_jtag_TMS_pad; // @[IOCell.scala 111:23]
  wire  iocell_jtag_TMS_i; // @[IOCell.scala 111:23]
  wire  iocell_jtag_TMS_ie; // @[IOCell.scala 111:23]
  wire  iocell_jtag_TCK_pad; // @[IOCell.scala 111:23]
  wire  iocell_jtag_TCK_i; // @[IOCell.scala 111:23]
  wire  iocell_jtag_TCK_ie; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_pad; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_i; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_ie; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_1_pad; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_1_i; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_1_ie; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_2_pad; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_2_i; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_2_ie; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_3_pad; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_3_i; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_3_ie; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_4_pad; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_4_i; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_4_ie; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_5_pad; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_5_i; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_5_ie; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_6_pad; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_6_i; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_6_ie; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_7_pad; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_7_i; // @[IOCell.scala 111:23]
  wire  iocell_ext_interrupts_7_ie; // @[IOCell.scala 111:23]
  wire  iocell_uart_0_rxd_pad; // @[IOCell.scala 111:23]
  wire  iocell_uart_0_rxd_i; // @[IOCell.scala 111:23]
  wire  iocell_uart_0_rxd_ie; // @[IOCell.scala 111:23]
  wire  iocell_uart_0_txd_pad; // @[IOCell.scala 112:24]
  wire  iocell_uart_0_txd_o; // @[IOCell.scala 112:24]
  wire  iocell_uart_0_txd_oe; // @[IOCell.scala 112:24]
  wire  reset_wire_iocell_reset_pad; // @[IOCell.scala 111:23]
  wire  reset_wire_iocell_reset_i; // @[IOCell.scala 111:23]
  wire  reset_wire_iocell_reset_ie; // @[IOCell.scala 111:23]
  wire  iocell_clock_pad; // @[IOCell.scala 111:23]
  wire  iocell_clock_i; // @[IOCell.scala 111:23]
  wire  iocell_clock_ie; // @[IOCell.scala 111:23]
  wire  _debug_reset_syncd_WIRE = debug_reset_syncd_debug_reset_sync_io_q; // @[ShiftReg.scala 48:24 ShiftReg.scala 48:24]
  wire  _T = ~_debug_reset_syncd_WIRE; // @[Periphery.scala 297:38]
  wire  bundleIn_0_clock = system_auto_subsystem_cbus_fixedClockNode_out_clock; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  reg  clock_en; // @[Periphery.scala 299:29]
  wire [3:0] system_interrupts_lo = {iocell_ext_interrupts_3_i,iocell_ext_interrupts_2_i,iocell_ext_interrupts_1_i,
    iocell_ext_interrupts_i}; // @[Cat.scala 30:58]
  wire [3:0] system_interrupts_hi = {iocell_ext_interrupts_7_i,iocell_ext_interrupts_6_i,iocell_ext_interrupts_5_i,
    iocell_ext_interrupts_4_i}; // @[Cat.scala 30:58]
  DigitalTop system ( // @[ChipTop.scala 32:35]
    .clock(system_clock),
    .reset(system_reset),
    .auto_domain_resetCtrl_async_reset_sink_in_clock(system_auto_domain_resetCtrl_async_reset_sink_in_clock),
    .auto_domain_resetCtrl_async_reset_sink_in_reset(system_auto_domain_resetCtrl_async_reset_sink_in_reset),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_clock),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_reset),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_clock),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_reset),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_clock),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_reset),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_clock),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_reset),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_clock(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_clock),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_reset(
      system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_reset),
    .auto_subsystem_mbus_fixedClockNode_out_1_clock(system_auto_subsystem_mbus_fixedClockNode_out_1_clock),
    .auto_subsystem_mbus_fixedClockNode_out_1_reset(system_auto_subsystem_mbus_fixedClockNode_out_1_reset),
    .auto_subsystem_mbus_fixedClockNode_out_0_clock(system_auto_subsystem_mbus_fixedClockNode_out_0_clock),
    .auto_subsystem_mbus_fixedClockNode_out_0_reset(system_auto_subsystem_mbus_fixedClockNode_out_0_reset),
    .auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_clock(
      system_auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_clock),
    .auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_reset(
      system_auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_reset),
    .auto_subsystem_cbus_fixedClockNode_out_clock(system_auto_subsystem_cbus_fixedClockNode_out_clock),
    .auto_subsystem_cbus_fixedClockNode_out_reset(system_auto_subsystem_cbus_fixedClockNode_out_reset),
    .auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_clock(
      system_auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_clock),
    .auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_reset(
      system_auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_reset),
    .auto_subsystem_fbus_fixedClockNode_out_clock(system_auto_subsystem_fbus_fixedClockNode_out_clock),
    .auto_subsystem_fbus_fixedClockNode_out_reset(system_auto_subsystem_fbus_fixedClockNode_out_reset),
    .auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_clock(
      system_auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_clock),
    .auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_reset(
      system_auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_reset),
    .auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_clock(
      system_auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_clock),
    .auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_reset(
      system_auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_reset),
    .auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_clock(
      system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_clock),
    .auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_reset(
      system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_reset),
    .auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_clock(
      system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_clock),
    .auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_reset(
      system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_reset),
    .mem_axi4_0_aw_ready(system_mem_axi4_0_aw_ready),
    .mem_axi4_0_aw_valid(system_mem_axi4_0_aw_valid),
    .mem_axi4_0_aw_bits_id(system_mem_axi4_0_aw_bits_id),
    .mem_axi4_0_aw_bits_addr(system_mem_axi4_0_aw_bits_addr),
    .mem_axi4_0_aw_bits_len(system_mem_axi4_0_aw_bits_len),
    .mem_axi4_0_aw_bits_size(system_mem_axi4_0_aw_bits_size),
    .mem_axi4_0_aw_bits_burst(system_mem_axi4_0_aw_bits_burst),
    .mem_axi4_0_aw_bits_lock(system_mem_axi4_0_aw_bits_lock),
    .mem_axi4_0_aw_bits_cache(system_mem_axi4_0_aw_bits_cache),
    .mem_axi4_0_aw_bits_prot(system_mem_axi4_0_aw_bits_prot),
    .mem_axi4_0_aw_bits_qos(system_mem_axi4_0_aw_bits_qos),
    .mem_axi4_0_w_ready(system_mem_axi4_0_w_ready),
    .mem_axi4_0_w_valid(system_mem_axi4_0_w_valid),
    .mem_axi4_0_w_bits_data(system_mem_axi4_0_w_bits_data),
    .mem_axi4_0_w_bits_strb(system_mem_axi4_0_w_bits_strb),
    .mem_axi4_0_w_bits_last(system_mem_axi4_0_w_bits_last),
    .mem_axi4_0_b_ready(system_mem_axi4_0_b_ready),
    .mem_axi4_0_b_valid(system_mem_axi4_0_b_valid),
    .mem_axi4_0_b_bits_id(system_mem_axi4_0_b_bits_id),
    .mem_axi4_0_b_bits_resp(system_mem_axi4_0_b_bits_resp),
    .mem_axi4_0_ar_ready(system_mem_axi4_0_ar_ready),
    .mem_axi4_0_ar_valid(system_mem_axi4_0_ar_valid),
    .mem_axi4_0_ar_bits_id(system_mem_axi4_0_ar_bits_id),
    .mem_axi4_0_ar_bits_addr(system_mem_axi4_0_ar_bits_addr),
    .mem_axi4_0_ar_bits_len(system_mem_axi4_0_ar_bits_len),
    .mem_axi4_0_ar_bits_size(system_mem_axi4_0_ar_bits_size),
    .mem_axi4_0_ar_bits_burst(system_mem_axi4_0_ar_bits_burst),
    .mem_axi4_0_ar_bits_lock(system_mem_axi4_0_ar_bits_lock),
    .mem_axi4_0_ar_bits_cache(system_mem_axi4_0_ar_bits_cache),
    .mem_axi4_0_ar_bits_prot(system_mem_axi4_0_ar_bits_prot),
    .mem_axi4_0_ar_bits_qos(system_mem_axi4_0_ar_bits_qos),
    .mem_axi4_0_r_ready(system_mem_axi4_0_r_ready),
    .mem_axi4_0_r_valid(system_mem_axi4_0_r_valid),
    .mem_axi4_0_r_bits_id(system_mem_axi4_0_r_bits_id),
    .mem_axi4_0_r_bits_data(system_mem_axi4_0_r_bits_data),
    .mem_axi4_0_r_bits_resp(system_mem_axi4_0_r_bits_resp),
    .mem_axi4_0_r_bits_last(system_mem_axi4_0_r_bits_last),
    .mmio_axi4_0_aw_ready(system_mmio_axi4_0_aw_ready),
    .mmio_axi4_0_aw_valid(system_mmio_axi4_0_aw_valid),
    .mmio_axi4_0_aw_bits_id(system_mmio_axi4_0_aw_bits_id),
    .mmio_axi4_0_aw_bits_addr(system_mmio_axi4_0_aw_bits_addr),
    .mmio_axi4_0_aw_bits_len(system_mmio_axi4_0_aw_bits_len),
    .mmio_axi4_0_aw_bits_size(system_mmio_axi4_0_aw_bits_size),
    .mmio_axi4_0_aw_bits_burst(system_mmio_axi4_0_aw_bits_burst),
    .mmio_axi4_0_aw_bits_lock(system_mmio_axi4_0_aw_bits_lock),
    .mmio_axi4_0_aw_bits_cache(system_mmio_axi4_0_aw_bits_cache),
    .mmio_axi4_0_aw_bits_prot(system_mmio_axi4_0_aw_bits_prot),
    .mmio_axi4_0_aw_bits_qos(system_mmio_axi4_0_aw_bits_qos),
    .mmio_axi4_0_w_ready(system_mmio_axi4_0_w_ready),
    .mmio_axi4_0_w_valid(system_mmio_axi4_0_w_valid),
    .mmio_axi4_0_w_bits_data(system_mmio_axi4_0_w_bits_data),
    .mmio_axi4_0_w_bits_strb(system_mmio_axi4_0_w_bits_strb),
    .mmio_axi4_0_w_bits_last(system_mmio_axi4_0_w_bits_last),
    .mmio_axi4_0_b_ready(system_mmio_axi4_0_b_ready),
    .mmio_axi4_0_b_valid(system_mmio_axi4_0_b_valid),
    .mmio_axi4_0_b_bits_id(system_mmio_axi4_0_b_bits_id),
    .mmio_axi4_0_b_bits_resp(system_mmio_axi4_0_b_bits_resp),
    .mmio_axi4_0_ar_ready(system_mmio_axi4_0_ar_ready),
    .mmio_axi4_0_ar_valid(system_mmio_axi4_0_ar_valid),
    .mmio_axi4_0_ar_bits_id(system_mmio_axi4_0_ar_bits_id),
    .mmio_axi4_0_ar_bits_addr(system_mmio_axi4_0_ar_bits_addr),
    .mmio_axi4_0_ar_bits_len(system_mmio_axi4_0_ar_bits_len),
    .mmio_axi4_0_ar_bits_size(system_mmio_axi4_0_ar_bits_size),
    .mmio_axi4_0_ar_bits_burst(system_mmio_axi4_0_ar_bits_burst),
    .mmio_axi4_0_ar_bits_lock(system_mmio_axi4_0_ar_bits_lock),
    .mmio_axi4_0_ar_bits_cache(system_mmio_axi4_0_ar_bits_cache),
    .mmio_axi4_0_ar_bits_prot(system_mmio_axi4_0_ar_bits_prot),
    .mmio_axi4_0_ar_bits_qos(system_mmio_axi4_0_ar_bits_qos),
    .mmio_axi4_0_r_ready(system_mmio_axi4_0_r_ready),
    .mmio_axi4_0_r_valid(system_mmio_axi4_0_r_valid),
    .mmio_axi4_0_r_bits_id(system_mmio_axi4_0_r_bits_id),
    .mmio_axi4_0_r_bits_data(system_mmio_axi4_0_r_bits_data),
    .mmio_axi4_0_r_bits_resp(system_mmio_axi4_0_r_bits_resp),
    .mmio_axi4_0_r_bits_last(system_mmio_axi4_0_r_bits_last),
    .l2_frontend_bus_axi4_0_aw_ready(system_l2_frontend_bus_axi4_0_aw_ready),
    .l2_frontend_bus_axi4_0_aw_valid(system_l2_frontend_bus_axi4_0_aw_valid),
    .l2_frontend_bus_axi4_0_aw_bits_id(system_l2_frontend_bus_axi4_0_aw_bits_id),
    .l2_frontend_bus_axi4_0_aw_bits_addr(system_l2_frontend_bus_axi4_0_aw_bits_addr),
    .l2_frontend_bus_axi4_0_aw_bits_len(system_l2_frontend_bus_axi4_0_aw_bits_len),
    .l2_frontend_bus_axi4_0_aw_bits_size(system_l2_frontend_bus_axi4_0_aw_bits_size),
    .l2_frontend_bus_axi4_0_aw_bits_burst(system_l2_frontend_bus_axi4_0_aw_bits_burst),
    .l2_frontend_bus_axi4_0_aw_bits_lock(system_l2_frontend_bus_axi4_0_aw_bits_lock),
    .l2_frontend_bus_axi4_0_aw_bits_cache(system_l2_frontend_bus_axi4_0_aw_bits_cache),
    .l2_frontend_bus_axi4_0_aw_bits_prot(system_l2_frontend_bus_axi4_0_aw_bits_prot),
    .l2_frontend_bus_axi4_0_aw_bits_qos(system_l2_frontend_bus_axi4_0_aw_bits_qos),
    .l2_frontend_bus_axi4_0_w_ready(system_l2_frontend_bus_axi4_0_w_ready),
    .l2_frontend_bus_axi4_0_w_valid(system_l2_frontend_bus_axi4_0_w_valid),
    .l2_frontend_bus_axi4_0_w_bits_data(system_l2_frontend_bus_axi4_0_w_bits_data),
    .l2_frontend_bus_axi4_0_w_bits_strb(system_l2_frontend_bus_axi4_0_w_bits_strb),
    .l2_frontend_bus_axi4_0_w_bits_last(system_l2_frontend_bus_axi4_0_w_bits_last),
    .l2_frontend_bus_axi4_0_b_ready(system_l2_frontend_bus_axi4_0_b_ready),
    .l2_frontend_bus_axi4_0_b_valid(system_l2_frontend_bus_axi4_0_b_valid),
    .l2_frontend_bus_axi4_0_b_bits_id(system_l2_frontend_bus_axi4_0_b_bits_id),
    .l2_frontend_bus_axi4_0_b_bits_resp(system_l2_frontend_bus_axi4_0_b_bits_resp),
    .l2_frontend_bus_axi4_0_ar_ready(system_l2_frontend_bus_axi4_0_ar_ready),
    .l2_frontend_bus_axi4_0_ar_valid(system_l2_frontend_bus_axi4_0_ar_valid),
    .l2_frontend_bus_axi4_0_ar_bits_id(system_l2_frontend_bus_axi4_0_ar_bits_id),
    .l2_frontend_bus_axi4_0_ar_bits_addr(system_l2_frontend_bus_axi4_0_ar_bits_addr),
    .l2_frontend_bus_axi4_0_ar_bits_len(system_l2_frontend_bus_axi4_0_ar_bits_len),
    .l2_frontend_bus_axi4_0_ar_bits_size(system_l2_frontend_bus_axi4_0_ar_bits_size),
    .l2_frontend_bus_axi4_0_ar_bits_burst(system_l2_frontend_bus_axi4_0_ar_bits_burst),
    .l2_frontend_bus_axi4_0_ar_bits_lock(system_l2_frontend_bus_axi4_0_ar_bits_lock),
    .l2_frontend_bus_axi4_0_ar_bits_cache(system_l2_frontend_bus_axi4_0_ar_bits_cache),
    .l2_frontend_bus_axi4_0_ar_bits_prot(system_l2_frontend_bus_axi4_0_ar_bits_prot),
    .l2_frontend_bus_axi4_0_ar_bits_qos(system_l2_frontend_bus_axi4_0_ar_bits_qos),
    .l2_frontend_bus_axi4_0_r_ready(system_l2_frontend_bus_axi4_0_r_ready),
    .l2_frontend_bus_axi4_0_r_valid(system_l2_frontend_bus_axi4_0_r_valid),
    .l2_frontend_bus_axi4_0_r_bits_id(system_l2_frontend_bus_axi4_0_r_bits_id),
    .l2_frontend_bus_axi4_0_r_bits_data(system_l2_frontend_bus_axi4_0_r_bits_data),
    .l2_frontend_bus_axi4_0_r_bits_resp(system_l2_frontend_bus_axi4_0_r_bits_resp),
    .l2_frontend_bus_axi4_0_r_bits_last(system_l2_frontend_bus_axi4_0_r_bits_last),
    .resetctrl_hartIsInReset_0(system_resetctrl_hartIsInReset_0),
    .debug_clock(system_debug_clock),
    .debug_reset(system_debug_reset),
    .debug_systemjtag_jtag_TCK(system_debug_systemjtag_jtag_TCK),
    .debug_systemjtag_jtag_TMS(system_debug_systemjtag_jtag_TMS),
    .debug_systemjtag_jtag_TDI(system_debug_systemjtag_jtag_TDI),
    .debug_systemjtag_jtag_TDO_data(system_debug_systemjtag_jtag_TDO_data),
    .debug_systemjtag_jtag_TDO_driven(system_debug_systemjtag_jtag_TDO_driven),
    .debug_systemjtag_reset(system_debug_systemjtag_reset),
    .debug_systemjtag_mfr_id(system_debug_systemjtag_mfr_id),
    .debug_systemjtag_part_number(system_debug_systemjtag_part_number),
    .debug_systemjtag_version(system_debug_systemjtag_version),
    .debug_ndreset(system_debug_ndreset),
    .debug_dmactive(system_debug_dmactive),
    .debug_dmactiveAck(system_debug_dmactiveAck),
    .interrupts(system_interrupts),
    .traceIO_traces_0_clock(system_traceIO_traces_0_clock),
    .traceIO_traces_0_reset(system_traceIO_traces_0_reset),
    .traceIO_traces_0_insns_0_valid(system_traceIO_traces_0_insns_0_valid),
    .traceIO_traces_0_insns_0_iaddr(system_traceIO_traces_0_insns_0_iaddr),
    .traceIO_traces_0_insns_0_insn(system_traceIO_traces_0_insns_0_insn),
    .traceIO_traces_0_insns_0_wdata(system_traceIO_traces_0_insns_0_wdata),
    .traceIO_traces_0_insns_0_priv(system_traceIO_traces_0_insns_0_priv),
    .traceIO_traces_0_insns_0_exception(system_traceIO_traces_0_insns_0_exception),
    .traceIO_traces_0_insns_0_interrupt(system_traceIO_traces_0_insns_0_interrupt),
    .traceIO_traces_0_insns_0_cause(system_traceIO_traces_0_insns_0_cause),
    .traceIO_traces_0_insns_0_tval(system_traceIO_traces_0_insns_0_tval),
    .traceIO_traces_0_insns_1_valid(system_traceIO_traces_0_insns_1_valid),
    .traceIO_traces_0_insns_1_iaddr(system_traceIO_traces_0_insns_1_iaddr),
    .traceIO_traces_0_insns_1_insn(system_traceIO_traces_0_insns_1_insn),
    .traceIO_traces_0_insns_1_wdata(system_traceIO_traces_0_insns_1_wdata),
    .traceIO_traces_0_insns_1_priv(system_traceIO_traces_0_insns_1_priv),
    .traceIO_traces_0_insns_1_exception(system_traceIO_traces_0_insns_1_exception),
    .traceIO_traces_0_insns_1_interrupt(system_traceIO_traces_0_insns_1_interrupt),
    .traceIO_traces_0_insns_1_cause(system_traceIO_traces_0_insns_1_cause),
    .traceIO_traces_0_insns_1_tval(system_traceIO_traces_0_insns_1_tval),
    .uart_0_txd(system_uart_0_txd),
    .uart_0_rxd(system_uart_0_rxd)
  );
  ClockGroupAggregator_6_inTestHarness aggregator ( // @[Clocks.scala 79:32]
    .auto_in_member_allClocks_subsystem_cbus_0_clock(aggregator_auto_in_member_allClocks_subsystem_cbus_0_clock),
    .auto_in_member_allClocks_subsystem_cbus_0_reset(aggregator_auto_in_member_allClocks_subsystem_cbus_0_reset),
    .auto_in_member_allClocks_subsystem_mbus_0_clock(aggregator_auto_in_member_allClocks_subsystem_mbus_0_clock),
    .auto_in_member_allClocks_subsystem_mbus_0_reset(aggregator_auto_in_member_allClocks_subsystem_mbus_0_reset),
    .auto_in_member_allClocks_subsystem_fbus_0_clock(aggregator_auto_in_member_allClocks_subsystem_fbus_0_clock),
    .auto_in_member_allClocks_subsystem_fbus_0_reset(aggregator_auto_in_member_allClocks_subsystem_fbus_0_reset),
    .auto_in_member_allClocks_subsystem_pbus_0_clock(aggregator_auto_in_member_allClocks_subsystem_pbus_0_clock),
    .auto_in_member_allClocks_subsystem_pbus_0_reset(aggregator_auto_in_member_allClocks_subsystem_pbus_0_reset),
    .auto_in_member_allClocks_subsystem_sbus_1_clock(aggregator_auto_in_member_allClocks_subsystem_sbus_1_clock),
    .auto_in_member_allClocks_subsystem_sbus_1_reset(aggregator_auto_in_member_allClocks_subsystem_sbus_1_reset),
    .auto_in_member_allClocks_subsystem_sbus_0_clock(aggregator_auto_in_member_allClocks_subsystem_sbus_0_clock),
    .auto_in_member_allClocks_subsystem_sbus_0_reset(aggregator_auto_in_member_allClocks_subsystem_sbus_0_reset),
    .auto_in_member_allClocks_implicit_clock_clock(aggregator_auto_in_member_allClocks_implicit_clock_clock),
    .auto_in_member_allClocks_implicit_clock_reset(aggregator_auto_in_member_allClocks_implicit_clock_reset),
    .auto_out_5_member_subsystem_cbus_subsystem_cbus_0_clock(
      aggregator_auto_out_5_member_subsystem_cbus_subsystem_cbus_0_clock),
    .auto_out_5_member_subsystem_cbus_subsystem_cbus_0_reset(
      aggregator_auto_out_5_member_subsystem_cbus_subsystem_cbus_0_reset),
    .auto_out_4_member_subsystem_mbus_subsystem_mbus_0_clock(
      aggregator_auto_out_4_member_subsystem_mbus_subsystem_mbus_0_clock),
    .auto_out_4_member_subsystem_mbus_subsystem_mbus_0_reset(
      aggregator_auto_out_4_member_subsystem_mbus_subsystem_mbus_0_reset),
    .auto_out_3_member_subsystem_fbus_subsystem_fbus_0_clock(
      aggregator_auto_out_3_member_subsystem_fbus_subsystem_fbus_0_clock),
    .auto_out_3_member_subsystem_fbus_subsystem_fbus_0_reset(
      aggregator_auto_out_3_member_subsystem_fbus_subsystem_fbus_0_reset),
    .auto_out_2_member_subsystem_pbus_subsystem_pbus_0_clock(
      aggregator_auto_out_2_member_subsystem_pbus_subsystem_pbus_0_clock),
    .auto_out_2_member_subsystem_pbus_subsystem_pbus_0_reset(
      aggregator_auto_out_2_member_subsystem_pbus_subsystem_pbus_0_reset),
    .auto_out_1_member_subsystem_sbus_subsystem_sbus_1_clock(
      aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_1_clock),
    .auto_out_1_member_subsystem_sbus_subsystem_sbus_1_reset(
      aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_1_reset),
    .auto_out_1_member_subsystem_sbus_subsystem_sbus_0_clock(
      aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_0_clock),
    .auto_out_1_member_subsystem_sbus_subsystem_sbus_0_reset(
      aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_0_reset),
    .auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_clock(
      aggregator_auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_clock),
    .auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_reset(
      aggregator_auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_reset)
  );
  ClockGroup_6_inTestHarness dividerOnlyClockGenerator ( // @[ClockGroup.scala 32:69]
    .auto_in_member_dividerOnlyClockGenerator_implicit_clock_clock(
      dividerOnlyClockGenerator_auto_in_member_dividerOnlyClockGenerator_implicit_clock_clock),
    .auto_in_member_dividerOnlyClockGenerator_implicit_clock_reset(
      dividerOnlyClockGenerator_auto_in_member_dividerOnlyClockGenerator_implicit_clock_reset),
    .auto_out_clock(dividerOnlyClockGenerator_auto_out_clock),
    .auto_out_reset(dividerOnlyClockGenerator_auto_out_reset)
  );
  ClockGroupParameterModifier_inTestHarness dividerOnlyClockGenerator_1 ( // @[ClockGroupNamePrefixer.scala 32:15]
    .auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_clock),
    .auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_reset),
    .auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_clock),
    .auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_reset),
    .auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_clock),
    .auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_reset),
    .auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_clock),
    .auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_reset),
    .auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_clock),
    .auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_reset),
    .auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_clock),
    .auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_reset),
    .auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_clock),
    .auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_reset),
    .auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_clock),
    .auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_reset),
    .auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_clock),
    .auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_reset),
    .auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_clock),
    .auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_reset),
    .auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_clock),
    .auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_reset),
    .auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_clock(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_clock),
    .auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_reset(
      dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_reset)
  );
  DividerOnlyClockGenerator_inTestHarness dividerOnlyClkGenerator ( // @[Clocks.scala 90:45]
    .auto_divider_only_clk_generator_in_clock(dividerOnlyClkGenerator_auto_divider_only_clk_generator_in_clock),
    .auto_divider_only_clk_generator_in_reset(dividerOnlyClkGenerator_auto_divider_only_clk_generator_in_reset),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_clock(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_clock),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_reset(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_reset),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_clock(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_clock),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_reset(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_reset),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_clock(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_clock),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_reset(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_reset),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_clock(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_clock),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_reset(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_reset),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_clock(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_clock),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_reset(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_reset),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_clock(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_clock),
    .auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_reset(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_reset),
    .auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_clock(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_clock),
    .auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_reset(
      dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_reset)
  );
  ClockGroupParameterModifier_1_inTestHarness dividerOnlyClockGenerator_2 ( // @[ClockGroupNamePrefixer.scala 68:15]
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_clock),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_reset),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_clock),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_reset),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_clock),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_reset),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_clock),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_reset),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_clock),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_reset),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_clock),
    .auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_reset),
    .auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_clock),
    .auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_reset),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_clock),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_reset),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_clock),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_reset),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_clock),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_reset),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_clock),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_reset),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_clock),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_reset),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_clock),
    .auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_reset),
    .auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_clock(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_clock),
    .auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_reset(
      dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_reset)
  );
  ClockGroupResetSynchronizer_inTestHarness dividerOnlyClockGenerator_3 ( // @[ResetSynchronizer.scala 42:69]
    .auto_in_member_allClocks_subsystem_cbus_0_clock(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_cbus_0_clock),
    .auto_in_member_allClocks_subsystem_cbus_0_reset(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_cbus_0_reset),
    .auto_in_member_allClocks_subsystem_mbus_0_clock(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_mbus_0_clock),
    .auto_in_member_allClocks_subsystem_mbus_0_reset(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_mbus_0_reset),
    .auto_in_member_allClocks_subsystem_fbus_0_clock(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_fbus_0_clock),
    .auto_in_member_allClocks_subsystem_fbus_0_reset(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_fbus_0_reset),
    .auto_in_member_allClocks_subsystem_pbus_0_clock(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_pbus_0_clock),
    .auto_in_member_allClocks_subsystem_pbus_0_reset(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_pbus_0_reset),
    .auto_in_member_allClocks_subsystem_sbus_1_clock(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_1_clock),
    .auto_in_member_allClocks_subsystem_sbus_1_reset(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_1_reset),
    .auto_in_member_allClocks_subsystem_sbus_0_clock(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_0_clock),
    .auto_in_member_allClocks_subsystem_sbus_0_reset(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_0_reset),
    .auto_in_member_allClocks_implicit_clock_clock(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_implicit_clock_clock),
    .auto_in_member_allClocks_implicit_clock_reset(
      dividerOnlyClockGenerator_3_auto_in_member_allClocks_implicit_clock_reset),
    .auto_out_member_allClocks_subsystem_cbus_0_clock(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_cbus_0_clock),
    .auto_out_member_allClocks_subsystem_cbus_0_reset(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_cbus_0_reset),
    .auto_out_member_allClocks_subsystem_mbus_0_clock(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_mbus_0_clock),
    .auto_out_member_allClocks_subsystem_mbus_0_reset(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_mbus_0_reset),
    .auto_out_member_allClocks_subsystem_fbus_0_clock(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_fbus_0_clock),
    .auto_out_member_allClocks_subsystem_fbus_0_reset(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_fbus_0_reset),
    .auto_out_member_allClocks_subsystem_pbus_0_clock(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_pbus_0_clock),
    .auto_out_member_allClocks_subsystem_pbus_0_reset(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_pbus_0_reset),
    .auto_out_member_allClocks_subsystem_sbus_1_clock(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_1_clock),
    .auto_out_member_allClocks_subsystem_sbus_1_reset(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_1_reset),
    .auto_out_member_allClocks_subsystem_sbus_0_clock(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_0_clock),
    .auto_out_member_allClocks_subsystem_sbus_0_reset(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_0_reset),
    .auto_out_member_allClocks_implicit_clock_clock(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_implicit_clock_clock),
    .auto_out_member_allClocks_implicit_clock_reset(
      dividerOnlyClockGenerator_3_auto_out_member_allClocks_implicit_clock_reset)
  );
  FixedClockBroadcast_7_inTestHarness asyncResetBroadcast ( // @[ClockGroup.scala 106:107]
    .auto_in_clock(asyncResetBroadcast_auto_in_clock),
    .auto_in_reset(asyncResetBroadcast_auto_in_reset),
    .auto_out_clock(asyncResetBroadcast_auto_out_clock),
    .auto_out_reset(asyncResetBroadcast_auto_out_reset)
  );
  ResetCatchAndSync_d3_inTestHarness system_debug_systemjtag_reset_catcher ( // @[ResetCatchAndSync.scala 39:28]
    .clock(system_debug_systemjtag_reset_catcher_clock),
    .reset(system_debug_systemjtag_reset_catcher_reset),
    .io_sync_reset(system_debug_systemjtag_reset_catcher_io_sync_reset)
  );
  AsyncResetSynchronizerShiftReg_w1_d3_i0_inTestHarness debug_reset_syncd_debug_reset_sync ( // @[ShiftReg.scala 45:23]
    .clock(debug_reset_syncd_debug_reset_sync_clock),
    .reset(debug_reset_syncd_debug_reset_sync_reset),
    .io_q(debug_reset_syncd_debug_reset_sync_io_q)
  );
  ResetSynchronizerShiftReg_w1_d3_i0_inTestHarness dmactiveAck_dmactiveAck ( // @[ShiftReg.scala 45:23]
    .clock(dmactiveAck_dmactiveAck_clock),
    .reset(dmactiveAck_dmactiveAck_reset),
    .io_d(dmactiveAck_dmactiveAck_io_d),
    .io_q(dmactiveAck_dmactiveAck_io_q)
  );
  EICG_wrapper gated_clock_debug_clock_gate ( // @[ClockGate.scala 24:20]
    .in(gated_clock_debug_clock_gate_in),
    .test_en(gated_clock_debug_clock_gate_test_en),
    .en(gated_clock_debug_clock_gate_en),
    .out(gated_clock_debug_clock_gate_out)
  );
  GenericDigitalOutIOCell iocell_jtag_TDO ( // @[IOCell.scala 112:24]
    .pad(iocell_jtag_TDO_pad),
    .o(iocell_jtag_TDO_o),
    .oe(iocell_jtag_TDO_oe)
  );
  GenericDigitalInIOCell iocell_jtag_TDI ( // @[IOCell.scala 111:23]
    .pad(iocell_jtag_TDI_pad),
    .i(iocell_jtag_TDI_i),
    .ie(iocell_jtag_TDI_ie)
  );
  GenericDigitalInIOCell iocell_jtag_TMS ( // @[IOCell.scala 111:23]
    .pad(iocell_jtag_TMS_pad),
    .i(iocell_jtag_TMS_i),
    .ie(iocell_jtag_TMS_ie)
  );
  GenericDigitalInIOCell iocell_jtag_TCK ( // @[IOCell.scala 111:23]
    .pad(iocell_jtag_TCK_pad),
    .i(iocell_jtag_TCK_i),
    .ie(iocell_jtag_TCK_ie)
  );
  GenericDigitalInIOCell iocell_ext_interrupts ( // @[IOCell.scala 111:23]
    .pad(iocell_ext_interrupts_pad),
    .i(iocell_ext_interrupts_i),
    .ie(iocell_ext_interrupts_ie)
  );
  GenericDigitalInIOCell iocell_ext_interrupts_1 ( // @[IOCell.scala 111:23]
    .pad(iocell_ext_interrupts_1_pad),
    .i(iocell_ext_interrupts_1_i),
    .ie(iocell_ext_interrupts_1_ie)
  );
  GenericDigitalInIOCell iocell_ext_interrupts_2 ( // @[IOCell.scala 111:23]
    .pad(iocell_ext_interrupts_2_pad),
    .i(iocell_ext_interrupts_2_i),
    .ie(iocell_ext_interrupts_2_ie)
  );
  GenericDigitalInIOCell iocell_ext_interrupts_3 ( // @[IOCell.scala 111:23]
    .pad(iocell_ext_interrupts_3_pad),
    .i(iocell_ext_interrupts_3_i),
    .ie(iocell_ext_interrupts_3_ie)
  );
  GenericDigitalInIOCell iocell_ext_interrupts_4 ( // @[IOCell.scala 111:23]
    .pad(iocell_ext_interrupts_4_pad),
    .i(iocell_ext_interrupts_4_i),
    .ie(iocell_ext_interrupts_4_ie)
  );
  GenericDigitalInIOCell iocell_ext_interrupts_5 ( // @[IOCell.scala 111:23]
    .pad(iocell_ext_interrupts_5_pad),
    .i(iocell_ext_interrupts_5_i),
    .ie(iocell_ext_interrupts_5_ie)
  );
  GenericDigitalInIOCell iocell_ext_interrupts_6 ( // @[IOCell.scala 111:23]
    .pad(iocell_ext_interrupts_6_pad),
    .i(iocell_ext_interrupts_6_i),
    .ie(iocell_ext_interrupts_6_ie)
  );
  GenericDigitalInIOCell iocell_ext_interrupts_7 ( // @[IOCell.scala 111:23]
    .pad(iocell_ext_interrupts_7_pad),
    .i(iocell_ext_interrupts_7_i),
    .ie(iocell_ext_interrupts_7_ie)
  );
  GenericDigitalInIOCell iocell_uart_0_rxd ( // @[IOCell.scala 111:23]
    .pad(iocell_uart_0_rxd_pad),
    .i(iocell_uart_0_rxd_i),
    .ie(iocell_uart_0_rxd_ie)
  );
  GenericDigitalOutIOCell iocell_uart_0_txd ( // @[IOCell.scala 112:24]
    .pad(iocell_uart_0_txd_pad),
    .o(iocell_uart_0_txd_o),
    .oe(iocell_uart_0_txd_oe)
  );
  GenericDigitalInIOCell reset_wire_iocell_reset ( // @[IOCell.scala 111:23]
    .pad(reset_wire_iocell_reset_pad),
    .i(reset_wire_iocell_reset_i),
    .ie(reset_wire_iocell_reset_ie)
  );
  GenericDigitalInIOCell iocell_clock ( // @[IOCell.scala 111:23]
    .pad(iocell_clock_pad),
    .i(iocell_clock_i),
    .ie(iocell_clock_ie)
  );
  assign jtag_TDO = iocell_jtag_TDO_pad; // @[IOCell.scala 239:25]
  assign axi4_mmio_0_clock = system_auto_subsystem_mbus_fixedClockNode_out_0_clock; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign axi4_mmio_0_reset = system_auto_subsystem_mbus_fixedClockNode_out_0_reset; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign axi4_mmio_0_bits_aw_valid = system_mmio_axi4_0_aw_valid; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_aw_bits_id = system_mmio_axi4_0_aw_bits_id; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_aw_bits_addr = system_mmio_axi4_0_aw_bits_addr; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_aw_bits_len = system_mmio_axi4_0_aw_bits_len; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_aw_bits_size = system_mmio_axi4_0_aw_bits_size; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_aw_bits_burst = system_mmio_axi4_0_aw_bits_burst; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_w_valid = system_mmio_axi4_0_w_valid; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_w_bits_data = system_mmio_axi4_0_w_bits_data; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_w_bits_strb = system_mmio_axi4_0_w_bits_strb; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_w_bits_last = system_mmio_axi4_0_w_bits_last; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_b_ready = system_mmio_axi4_0_b_ready; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_ar_valid = system_mmio_axi4_0_ar_valid; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_ar_bits_id = system_mmio_axi4_0_ar_bits_id; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_ar_bits_addr = system_mmio_axi4_0_ar_bits_addr; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_ar_bits_len = system_mmio_axi4_0_ar_bits_len; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_ar_bits_size = system_mmio_axi4_0_ar_bits_size; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_ar_bits_burst = system_mmio_axi4_0_ar_bits_burst; // @[IOBinders.scala 305:16]
  assign axi4_mmio_0_bits_r_ready = system_mmio_axi4_0_r_ready; // @[IOBinders.scala 305:16]
  assign axi4_mem_0_clock = system_auto_subsystem_mbus_fixedClockNode_out_1_clock; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign axi4_mem_0_reset = system_auto_subsystem_mbus_fixedClockNode_out_1_reset; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign axi4_mem_0_bits_aw_valid = system_mem_axi4_0_aw_valid; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_aw_bits_id = system_mem_axi4_0_aw_bits_id; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_aw_bits_addr = system_mem_axi4_0_aw_bits_addr; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_aw_bits_len = system_mem_axi4_0_aw_bits_len; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_aw_bits_size = system_mem_axi4_0_aw_bits_size; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_aw_bits_burst = system_mem_axi4_0_aw_bits_burst; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_w_valid = system_mem_axi4_0_w_valid; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_w_bits_data = system_mem_axi4_0_w_bits_data; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_w_bits_strb = system_mem_axi4_0_w_bits_strb; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_w_bits_last = system_mem_axi4_0_w_bits_last; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_b_ready = system_mem_axi4_0_b_ready; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_ar_valid = system_mem_axi4_0_ar_valid; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_ar_bits_id = system_mem_axi4_0_ar_bits_id; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_ar_bits_addr = system_mem_axi4_0_ar_bits_addr; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_ar_bits_len = system_mem_axi4_0_ar_bits_len; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_ar_bits_size = system_mem_axi4_0_ar_bits_size; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_ar_bits_burst = system_mem_axi4_0_ar_bits_burst; // @[IOBinders.scala 285:16]
  assign axi4_mem_0_bits_r_ready = system_mem_axi4_0_r_ready; // @[IOBinders.scala 285:16]
  assign uart_0_txd = iocell_uart_0_txd_pad; // @[IOCell.scala 239:25]
  assign system_clock = dividerOnlyClockGenerator_auto_out_clock; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign system_reset = dividerOnlyClockGenerator_auto_out_reset; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_async_reset_sink_in_clock = asyncResetBroadcast_auto_out_clock; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_async_reset_sink_in_reset = asyncResetBroadcast_auto_out_reset; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_clock =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_reset =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_cbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_clock =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_reset =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_mbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_clock =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_reset =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_fbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_clock =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_reset =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_pbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_clock =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_clock; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_reset =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_1_reset; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_clock =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_reset =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_subsystem_sbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_clock =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_clock; // @[LazyModule.scala 296:16]
  assign system_auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_reset =
    dividerOnlyClkGenerator_auto_divider_only_clk_generator_out_member_allClocks_implicit_clock_reset; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_clock =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_reset =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_3_member_subsystem_mbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_clock =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_reset =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_4_member_subsystem_cbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_clock =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_reset =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_2_member_subsystem_fbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_clock =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_reset =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_1_member_subsystem_pbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_clock =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_clock; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_reset =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_1_reset; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_clock =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_clock; // @[LazyModule.scala 296:16]
  assign system_auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_reset =
    dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_out_0_member_subsystem_sbus_0_reset; // @[LazyModule.scala 296:16]
  assign system_mem_axi4_0_aw_ready = axi4_mem_0_bits_aw_ready; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_w_ready = axi4_mem_0_bits_w_ready; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_b_valid = axi4_mem_0_bits_b_valid; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_b_bits_id = axi4_mem_0_bits_b_bits_id; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_b_bits_resp = axi4_mem_0_bits_b_bits_resp; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_ar_ready = axi4_mem_0_bits_ar_ready; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_r_valid = axi4_mem_0_bits_r_valid; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_r_bits_id = axi4_mem_0_bits_r_bits_id; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_r_bits_data = axi4_mem_0_bits_r_bits_data; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_r_bits_resp = axi4_mem_0_bits_r_bits_resp; // @[IOBinders.scala 285:16]
  assign system_mem_axi4_0_r_bits_last = axi4_mem_0_bits_r_bits_last; // @[IOBinders.scala 285:16]
  assign system_mmio_axi4_0_aw_ready = axi4_mmio_0_bits_aw_ready; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_w_ready = axi4_mmio_0_bits_w_ready; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_b_valid = axi4_mmio_0_bits_b_valid; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_b_bits_id = axi4_mmio_0_bits_b_bits_id; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_b_bits_resp = axi4_mmio_0_bits_b_bits_resp; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_ar_ready = axi4_mmio_0_bits_ar_ready; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_r_valid = axi4_mmio_0_bits_r_valid; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_r_bits_id = axi4_mmio_0_bits_r_bits_id; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_r_bits_data = axi4_mmio_0_bits_r_bits_data; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_r_bits_resp = axi4_mmio_0_bits_r_bits_resp; // @[IOBinders.scala 305:16]
  assign system_mmio_axi4_0_r_bits_last = axi4_mmio_0_bits_r_bits_last; // @[IOBinders.scala 305:16]
  assign system_l2_frontend_bus_axi4_0_aw_valid = 1'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_id = 4'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_addr = 32'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_len = 8'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_size = 3'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_burst = 2'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_lock = 1'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_cache = 4'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_prot = 3'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_aw_bits_qos = 4'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_w_valid = 1'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_w_bits_data = 128'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_w_bits_strb = 16'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_w_bits_last = 1'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_b_ready = 1'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_valid = 1'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_id = 4'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_addr = 32'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_len = 8'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_size = 3'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_burst = 2'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_lock = 1'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_cache = 4'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_prot = 3'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_ar_bits_qos = 4'h0; // @[IOBinders.scala 325:11]
  assign system_l2_frontend_bus_axi4_0_r_ready = 1'h0; // @[IOBinders.scala 325:11]
  assign system_resetctrl_hartIsInReset_0 = system_auto_subsystem_cbus_fixedClockNode_out_reset; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign system_debug_clock = gated_clock_debug_clock_gate_out; // @[Periphery.scala 303:19]
  assign system_debug_reset = ~_debug_reset_syncd_WIRE; // @[Periphery.scala 291:40]
  assign system_debug_systemjtag_jtag_TCK = iocell_jtag_TCK_i; // @[IOCell.scala 179:61]
  assign system_debug_systemjtag_jtag_TMS = iocell_jtag_TMS_i; // @[IOBinders.scala 248:31 IOCell.scala 224:26]
  assign system_debug_systemjtag_jtag_TDI = iocell_jtag_TDI_i; // @[IOBinders.scala 248:31 IOCell.scala 224:26]
  assign system_debug_systemjtag_reset = system_debug_systemjtag_reset_catcher_io_sync_reset; // @[IOBinders.scala 234:21]
  assign system_debug_systemjtag_mfr_id = 11'h0; // @[IOBinders.scala 235:22]
  assign system_debug_systemjtag_part_number = 16'h0; // @[IOBinders.scala 236:27]
  assign system_debug_systemjtag_version = 4'h0; // @[IOBinders.scala 237:23]
  assign system_debug_dmactiveAck = dmactiveAck_dmactiveAck_io_q; // @[ShiftReg.scala 48:24 ShiftReg.scala 48:24]
  assign system_interrupts = {system_interrupts_hi,system_interrupts_lo}; // @[Cat.scala 30:58]
  assign system_uart_0_rxd = iocell_uart_0_rxd_i; // @[IOCell.scala 224:26]
  assign aggregator_auto_in_member_allClocks_subsystem_cbus_0_clock =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_clock; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_cbus_0_reset =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_cbus_0_reset; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_mbus_0_clock =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_clock; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_mbus_0_reset =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_mbus_0_reset; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_fbus_0_clock =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_clock; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_fbus_0_reset =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_fbus_0_reset; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_pbus_0_clock =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_clock; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_pbus_0_reset =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_pbus_0_reset; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_sbus_1_clock =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_clock; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_sbus_1_reset =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_1_reset; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_sbus_0_clock =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_clock; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_subsystem_sbus_0_reset =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_subsystem_sbus_0_reset; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_implicit_clock_clock =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_clock; // @[LazyModule.scala 296:16]
  assign aggregator_auto_in_member_allClocks_implicit_clock_reset =
    dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_out_member_allClocks_implicit_clock_reset; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_auto_in_member_dividerOnlyClockGenerator_implicit_clock_clock =
    aggregator_auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_auto_in_member_dividerOnlyClockGenerator_implicit_clock_reset =
    aggregator_auto_out_0_member_dividerOnlyClockGenerator_implicit_clock_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_clock
     = aggregator_auto_out_5_member_subsystem_cbus_subsystem_cbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_4_member_subsystem_cbus_subsystem_cbus_0_reset
     = aggregator_auto_out_5_member_subsystem_cbus_subsystem_cbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_clock
     = aggregator_auto_out_4_member_subsystem_mbus_subsystem_mbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_3_member_subsystem_mbus_subsystem_mbus_0_reset
     = aggregator_auto_out_4_member_subsystem_mbus_subsystem_mbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_clock
     = aggregator_auto_out_3_member_subsystem_fbus_subsystem_fbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_2_member_subsystem_fbus_subsystem_fbus_0_reset
     = aggregator_auto_out_3_member_subsystem_fbus_subsystem_fbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_clock
     = aggregator_auto_out_2_member_subsystem_pbus_subsystem_pbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_1_member_subsystem_pbus_subsystem_pbus_0_reset
     = aggregator_auto_out_2_member_subsystem_pbus_subsystem_pbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_clock
     = aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_1_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_1_reset
     = aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_1_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_clock
     = aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_1_auto_divider_only_clock_generator_in_0_member_subsystem_sbus_subsystem_sbus_0_reset
     = aggregator_auto_out_1_member_subsystem_sbus_subsystem_sbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClkGenerator_auto_divider_only_clk_generator_in_clock = iocell_clock_i; // @[IOCell.scala 179:61]
  assign dividerOnlyClkGenerator_auto_divider_only_clk_generator_in_reset = reset_wire_iocell_reset_i; // @[IOCell.scala 180:64]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_clock =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_cbus_0_clock; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_cbus_0_reset =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_cbus_0_reset; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_clock =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_mbus_0_clock; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_mbus_0_reset =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_mbus_0_reset; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_clock =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_fbus_0_clock; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_fbus_0_reset =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_fbus_0_reset; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_clock =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_pbus_0_clock; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_pbus_0_reset =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_pbus_0_reset; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_clock =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_1_clock; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_1_reset =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_1_reset; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_clock =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_0_clock; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_subsystem_sbus_0_reset =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_subsystem_sbus_0_reset; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_clock =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_implicit_clock_clock; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_2_auto_divider_only_clock_generator_in_member_allClocks_implicit_clock_reset =
    dividerOnlyClockGenerator_3_auto_out_member_allClocks_implicit_clock_reset; // @[LazyModule.scala 296:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_cbus_0_clock =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_cbus_0_reset =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_mbus_0_clock =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_mbus_0_reset =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_fbus_0_clock =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_fbus_0_reset =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_pbus_0_clock =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_pbus_0_reset =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_1_clock =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_1_reset =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_0_clock =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_subsystem_sbus_0_reset =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_reset; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_implicit_clock_clock =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_clock; // @[LazyModule.scala 298:16]
  assign dividerOnlyClockGenerator_3_auto_in_member_allClocks_implicit_clock_reset =
    system_auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_reset; // @[LazyModule.scala 298:16]
  assign asyncResetBroadcast_auto_in_clock = 1'h0; // @[Clocks.scala 116:28]
  assign asyncResetBroadcast_auto_in_reset = reset_wire_iocell_reset_i; // @[IOCell.scala 180:64]
  assign system_debug_systemjtag_reset_catcher_clock = system_debug_systemjtag_jtag_TCK;
  assign system_debug_systemjtag_reset_catcher_reset = system_auto_subsystem_cbus_fixedClockNode_out_reset; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign debug_reset_syncd_debug_reset_sync_clock = system_auto_subsystem_cbus_fixedClockNode_out_clock; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign debug_reset_syncd_debug_reset_sync_reset = system_debug_systemjtag_reset; // @[Periphery.scala 282:38]
  assign dmactiveAck_dmactiveAck_clock = system_auto_subsystem_cbus_fixedClockNode_out_clock; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign dmactiveAck_dmactiveAck_reset = ~_debug_reset_syncd_WIRE; // @[Periphery.scala 297:38]
  assign dmactiveAck_dmactiveAck_io_d = system_debug_dmactive; // @[ShiftReg.scala 47:16]
  assign gated_clock_debug_clock_gate_in = system_auto_subsystem_cbus_fixedClockNode_out_clock; // @[Nodes.scala 1210:84 LazyModule.scala 296:16]
  assign gated_clock_debug_clock_gate_test_en = 1'h0; // @[ClockGate.scala 27:19]
  assign gated_clock_debug_clock_gate_en = clock_en; // @[ClockGate.scala 28:14]
  assign iocell_jtag_TDO_o = system_debug_systemjtag_jtag_TDO_data; // @[IOBinders.scala 248:31 IOBinders.scala 252:25]
  assign iocell_jtag_TDO_oe = 1'h1; // @[IOCell.scala 235:30]
  assign iocell_jtag_TDI_pad = jtag_TDI; // @[IOCell.scala 213:39]
  assign iocell_jtag_TDI_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_jtag_TMS_pad = jtag_TMS; // @[IOCell.scala 213:39]
  assign iocell_jtag_TMS_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_jtag_TCK_pad = jtag_TCK; // @[IOCell.scala 179:44]
  assign iocell_jtag_TCK_ie = 1'h1; // @[IOCell.scala 164:24]
  assign iocell_ext_interrupts_pad = 1'h0; // @[IOCell.scala 213:39]
  assign iocell_ext_interrupts_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_ext_interrupts_1_pad = 1'h0; // @[IOCell.scala 213:39]
  assign iocell_ext_interrupts_1_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_ext_interrupts_2_pad = 1'h0; // @[IOCell.scala 213:39]
  assign iocell_ext_interrupts_2_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_ext_interrupts_3_pad = 1'h0; // @[IOCell.scala 213:39]
  assign iocell_ext_interrupts_3_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_ext_interrupts_4_pad = 1'h0; // @[IOCell.scala 213:39]
  assign iocell_ext_interrupts_4_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_ext_interrupts_5_pad = 1'h0; // @[IOCell.scala 213:39]
  assign iocell_ext_interrupts_5_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_ext_interrupts_6_pad = 1'h0; // @[IOCell.scala 213:39]
  assign iocell_ext_interrupts_6_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_ext_interrupts_7_pad = 1'h0; // @[IOCell.scala 213:39]
  assign iocell_ext_interrupts_7_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_uart_0_rxd_pad = uart_0_rxd; // @[IOCell.scala 213:39]
  assign iocell_uart_0_rxd_ie = 1'h1; // @[IOCell.scala 220:30]
  assign iocell_uart_0_txd_o = system_uart_0_txd; // @[IOCell.scala 228:40]
  assign iocell_uart_0_txd_oe = 1'h1; // @[IOCell.scala 235:30]
  assign reset_wire_iocell_reset_pad = reset_wire_reset; // @[IOCell.scala 180:54]
  assign reset_wire_iocell_reset_ie = 1'h1; // @[IOCell.scala 164:24]
  assign iocell_clock_pad = clock; // @[IOCell.scala 179:44]
  assign iocell_clock_ie = 1'h1; // @[IOCell.scala 164:24]
  always @(posedge bundleIn_0_clock or posedge _T) begin
    if (_T) begin
      clock_en <= 1'h1;
    end else begin
      clock_en <= dmactiveAck_dmactiveAck_io_q;
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
  clock_en = _RAND_0[0:0];
`endif // RANDOMIZE_REG_INIT
  if (_T) begin
    clock_en = 1'h1;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4RAM_inTestHarness(
  input         clock,
  input         reset,
  output        auto_in_aw_ready,
  input         auto_in_aw_valid,
  input  [3:0]  auto_in_aw_bits_id,
  input  [27:0] auto_in_aw_bits_addr,
  input         auto_in_aw_bits_echo_real_last,
  output        auto_in_w_ready,
  input         auto_in_w_valid,
  input  [63:0] auto_in_w_bits_data,
  input  [7:0]  auto_in_w_bits_strb,
  input         auto_in_b_ready,
  output        auto_in_b_valid,
  output [3:0]  auto_in_b_bits_id,
  output [1:0]  auto_in_b_bits_resp,
  output        auto_in_b_bits_echo_real_last,
  output        auto_in_ar_ready,
  input         auto_in_ar_valid,
  input  [3:0]  auto_in_ar_bits_id,
  input  [27:0] auto_in_ar_bits_addr,
  input         auto_in_ar_bits_echo_real_last,
  input         auto_in_r_ready,
  output        auto_in_r_valid,
  output [3:0]  auto_in_r_bits_id,
  output [63:0] auto_in_r_bits_data,
  output [1:0]  auto_in_r_bits_resp,
  output        auto_in_r_bits_echo_real_last
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
`endif // RANDOMIZE_REG_INIT
  wire [24:0] mem_R0_addr; // @[DescribedSRAM.scala 19:26]
  wire  mem_R0_en; // @[DescribedSRAM.scala 19:26]
  wire  mem_R0_clk; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_0; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_1; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_2; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_3; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_4; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_5; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_6; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_7; // @[DescribedSRAM.scala 19:26]
  wire [24:0] mem_W0_addr; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_en; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_clk; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_0; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_1; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_2; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_3; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_4; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_5; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_6; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_7; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_0; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_1; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_2; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_3; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_4; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_5; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_6; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_7; // @[DescribedSRAM.scala 19:26]
  wire  r_addr_lo_lo_lo_lo = auto_in_ar_bits_addr[3]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_lo_hi_lo = auto_in_ar_bits_addr[4]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_lo_hi_hi = auto_in_ar_bits_addr[5]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_lo = auto_in_ar_bits_addr[6]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_hi_lo = auto_in_ar_bits_addr[7]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_hi_hi = auto_in_ar_bits_addr[8]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_lo = auto_in_ar_bits_addr[9]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_hi_lo = auto_in_ar_bits_addr[10]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_hi_hi = auto_in_ar_bits_addr[11]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_lo = auto_in_ar_bits_addr[12]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_hi_lo = auto_in_ar_bits_addr[13]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_hi_hi = auto_in_ar_bits_addr[14]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_lo = auto_in_ar_bits_addr[15]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_hi_lo = auto_in_ar_bits_addr[16]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_hi_hi = auto_in_ar_bits_addr[17]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_lo = auto_in_ar_bits_addr[18]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_hi_lo = auto_in_ar_bits_addr[19]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_hi_hi = auto_in_ar_bits_addr[20]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_lo = auto_in_ar_bits_addr[21]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_hi_lo = auto_in_ar_bits_addr[22]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_hi_hi = auto_in_ar_bits_addr[23]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_lo_lo = auto_in_ar_bits_addr[24]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_lo_hi = auto_in_ar_bits_addr[25]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_hi_lo = auto_in_ar_bits_addr[26]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_hi_hi = auto_in_ar_bits_addr[27]; // @[SRAM.scala 65:73]
  wire [5:0] r_addr_lo_lo = {r_addr_lo_lo_hi_hi_hi,r_addr_lo_lo_hi_hi_lo,r_addr_lo_lo_hi_lo,r_addr_lo_lo_lo_hi_hi,
    r_addr_lo_lo_lo_hi_lo,r_addr_lo_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [11:0] r_addr_lo = {r_addr_lo_hi_hi_hi_hi,r_addr_lo_hi_hi_hi_lo,r_addr_lo_hi_hi_lo,r_addr_lo_hi_lo_hi_hi,
    r_addr_lo_hi_lo_hi_lo,r_addr_lo_hi_lo_lo,r_addr_lo_lo}; // @[Cat.scala 30:58]
  wire [5:0] r_addr_hi_lo = {r_addr_hi_lo_hi_hi_hi,r_addr_hi_lo_hi_hi_lo,r_addr_hi_lo_hi_lo,r_addr_hi_lo_lo_hi_hi,
    r_addr_hi_lo_lo_hi_lo,r_addr_hi_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] r_addr_hi = {r_addr_hi_hi_hi_hi_hi,r_addr_hi_hi_hi_hi_lo,r_addr_hi_hi_hi_lo_hi,r_addr_hi_hi_hi_lo_lo,
    r_addr_hi_hi_lo_hi_hi,r_addr_hi_hi_lo_hi_lo,r_addr_hi_hi_lo_lo,r_addr_hi_lo}; // @[Cat.scala 30:58]
  wire  w_addr_lo_lo_lo_lo = auto_in_aw_bits_addr[3]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_lo_hi_lo = auto_in_aw_bits_addr[4]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_lo_hi_hi = auto_in_aw_bits_addr[5]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_lo = auto_in_aw_bits_addr[6]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_hi_lo = auto_in_aw_bits_addr[7]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_hi_hi = auto_in_aw_bits_addr[8]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_lo = auto_in_aw_bits_addr[9]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_hi_lo = auto_in_aw_bits_addr[10]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_hi_hi = auto_in_aw_bits_addr[11]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_lo = auto_in_aw_bits_addr[12]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_hi_lo = auto_in_aw_bits_addr[13]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_hi_hi = auto_in_aw_bits_addr[14]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_lo = auto_in_aw_bits_addr[15]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_hi_lo = auto_in_aw_bits_addr[16]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_hi_hi = auto_in_aw_bits_addr[17]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_lo = auto_in_aw_bits_addr[18]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_hi_lo = auto_in_aw_bits_addr[19]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_hi_hi = auto_in_aw_bits_addr[20]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_lo = auto_in_aw_bits_addr[21]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_hi_lo = auto_in_aw_bits_addr[22]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_hi_hi = auto_in_aw_bits_addr[23]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_lo_lo = auto_in_aw_bits_addr[24]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_lo_hi = auto_in_aw_bits_addr[25]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_hi_lo = auto_in_aw_bits_addr[26]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_hi_hi = auto_in_aw_bits_addr[27]; // @[SRAM.scala 66:73]
  wire [5:0] w_addr_lo_lo = {w_addr_lo_lo_hi_hi_hi,w_addr_lo_lo_hi_hi_lo,w_addr_lo_lo_hi_lo,w_addr_lo_lo_lo_hi_hi,
    w_addr_lo_lo_lo_hi_lo,w_addr_lo_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [11:0] w_addr_lo = {w_addr_lo_hi_hi_hi_hi,w_addr_lo_hi_hi_hi_lo,w_addr_lo_hi_hi_lo,w_addr_lo_hi_lo_hi_hi,
    w_addr_lo_hi_lo_hi_lo,w_addr_lo_hi_lo_lo,w_addr_lo_lo}; // @[Cat.scala 30:58]
  wire [5:0] w_addr_hi_lo = {w_addr_hi_lo_hi_hi_hi,w_addr_hi_lo_hi_hi_lo,w_addr_hi_lo_hi_lo,w_addr_hi_lo_lo_hi_hi,
    w_addr_hi_lo_lo_hi_lo,w_addr_hi_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] w_addr_hi = {w_addr_hi_hi_hi_hi_hi,w_addr_hi_hi_hi_hi_lo,w_addr_hi_hi_hi_lo_hi,w_addr_hi_hi_hi_lo_lo,
    w_addr_hi_hi_lo_hi_hi,w_addr_hi_hi_lo_hi_lo,w_addr_hi_hi_lo_lo,w_addr_hi_lo}; // @[Cat.scala 30:58]
  wire [28:0] _r_sel0_T_1 = {1'b0,$signed(auto_in_ar_bits_addr)}; // @[Parameters.scala 137:49]
  wire [28:0] _r_sel0_T_3 = $signed(_r_sel0_T_1) & 29'sh10000000; // @[Parameters.scala 137:52]
  wire  r_sel0 = $signed(_r_sel0_T_3) == 29'sh0; // @[Parameters.scala 137:67]
  wire [28:0] _w_sel0_T_1 = {1'b0,$signed(auto_in_aw_bits_addr)}; // @[Parameters.scala 137:49]
  wire [28:0] _w_sel0_T_3 = $signed(_w_sel0_T_1) & 29'sh10000000; // @[Parameters.scala 137:52]
  wire  w_sel0 = $signed(_w_sel0_T_3) == 29'sh0; // @[Parameters.scala 137:67]
  reg  w_full; // @[SRAM.scala 70:25]
  reg [3:0] w_id; // @[SRAM.scala 71:21]
  reg  w_echo_real_last; // @[SRAM.scala 72:21]
  reg  r_sel1; // @[SRAM.scala 73:21]
  reg  w_sel1; // @[SRAM.scala 74:21]
  wire  _T = auto_in_b_ready & w_full; // @[Decoupled.scala 40:37]
  wire  _GEN_0 = _T ? 1'h0 : w_full; // @[SRAM.scala 76:25 SRAM.scala 76:34 SRAM.scala 70:25]
  wire  _bundleIn_0_aw_ready_T_1 = auto_in_b_ready | ~w_full; // @[SRAM.scala 92:47]
  wire  in_aw_ready = auto_in_w_valid & (auto_in_b_ready | ~w_full); // @[SRAM.scala 92:32]
  wire  _T_1 = in_aw_ready & auto_in_aw_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_1 = _T_1 | _GEN_0; // @[SRAM.scala 77:25 SRAM.scala 77:34]
  reg  r_full; // @[SRAM.scala 99:25]
  reg [3:0] r_id; // @[SRAM.scala 100:21]
  reg  r_echo_real_last; // @[SRAM.scala 101:21]
  wire  _T_13 = auto_in_r_ready & r_full; // @[Decoupled.scala 40:37]
  wire  _GEN_40 = _T_13 ? 1'h0 : r_full; // @[SRAM.scala 103:25 SRAM.scala 103:34 SRAM.scala 99:25]
  wire  in_ar_ready = auto_in_r_ready | ~r_full; // @[SRAM.scala 117:31]
  wire  _T_14 = in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_41 = _T_14 | _GEN_40; // @[SRAM.scala 104:25 SRAM.scala 104:34]
  reg  rdata_REG; // @[package.scala 91:91]
  reg [7:0] rdata_r_0; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_1; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_2; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_3; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_4; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_5; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_6; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_7; // @[Reg.scala 15:16]
  wire [7:0] _GEN_49 = rdata_REG ? mem_R0_data_0 : rdata_r_0; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_50 = rdata_REG ? mem_R0_data_1 : rdata_r_1; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_51 = rdata_REG ? mem_R0_data_2 : rdata_r_2; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_52 = rdata_REG ? mem_R0_data_3 : rdata_r_3; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_53 = rdata_REG ? mem_R0_data_4 : rdata_r_4; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_54 = rdata_REG ? mem_R0_data_5 : rdata_r_5; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_55 = rdata_REG ? mem_R0_data_6 : rdata_r_6; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_56 = rdata_REG ? mem_R0_data_7 : rdata_r_7; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [31:0] bundleIn_0_r_bits_data_lo = {_GEN_52,_GEN_51,_GEN_50,_GEN_49}; // @[Cat.scala 30:58]
  wire [31:0] bundleIn_0_r_bits_data_hi = {_GEN_56,_GEN_55,_GEN_54,_GEN_53}; // @[Cat.scala 30:58]
  mem_inTestHarness mem ( // @[DescribedSRAM.scala 19:26]
    .R0_addr(mem_R0_addr),
    .R0_en(mem_R0_en),
    .R0_clk(mem_R0_clk),
    .R0_data_0(mem_R0_data_0),
    .R0_data_1(mem_R0_data_1),
    .R0_data_2(mem_R0_data_2),
    .R0_data_3(mem_R0_data_3),
    .R0_data_4(mem_R0_data_4),
    .R0_data_5(mem_R0_data_5),
    .R0_data_6(mem_R0_data_6),
    .R0_data_7(mem_R0_data_7),
    .W0_addr(mem_W0_addr),
    .W0_en(mem_W0_en),
    .W0_clk(mem_W0_clk),
    .W0_data_0(mem_W0_data_0),
    .W0_data_1(mem_W0_data_1),
    .W0_data_2(mem_W0_data_2),
    .W0_data_3(mem_W0_data_3),
    .W0_data_4(mem_W0_data_4),
    .W0_data_5(mem_W0_data_5),
    .W0_data_6(mem_W0_data_6),
    .W0_data_7(mem_W0_data_7),
    .W0_mask_0(mem_W0_mask_0),
    .W0_mask_1(mem_W0_mask_1),
    .W0_mask_2(mem_W0_mask_2),
    .W0_mask_3(mem_W0_mask_3),
    .W0_mask_4(mem_W0_mask_4),
    .W0_mask_5(mem_W0_mask_5),
    .W0_mask_6(mem_W0_mask_6),
    .W0_mask_7(mem_W0_mask_7)
  );
  assign auto_in_aw_ready = auto_in_w_valid & (auto_in_b_ready | ~w_full); // @[SRAM.scala 92:32]
  assign auto_in_w_ready = auto_in_aw_valid & _bundleIn_0_aw_ready_T_1; // @[SRAM.scala 93:32]
  assign auto_in_b_valid = w_full; // @[Nodes.scala 1210:84 SRAM.scala 91:17]
  assign auto_in_b_bits_id = w_id; // @[Nodes.scala 1210:84 SRAM.scala 95:20]
  assign auto_in_b_bits_resp = w_sel1 ? 2'h0 : 2'h3; // @[SRAM.scala 96:26]
  assign auto_in_b_bits_echo_real_last = w_echo_real_last; // @[Nodes.scala 1210:84 BundleMap.scala 247:19]
  assign auto_in_ar_ready = auto_in_r_ready | ~r_full; // @[SRAM.scala 117:31]
  assign auto_in_r_valid = r_full; // @[Nodes.scala 1210:84 SRAM.scala 116:17]
  assign auto_in_r_bits_id = r_id; // @[Nodes.scala 1210:84 SRAM.scala 119:20]
  assign auto_in_r_bits_data = {bundleIn_0_r_bits_data_hi,bundleIn_0_r_bits_data_lo}; // @[Cat.scala 30:58]
  assign auto_in_r_bits_resp = r_sel1 ? 2'h0 : 2'h3; // @[SRAM.scala 120:26]
  assign auto_in_r_bits_echo_real_last = r_echo_real_last; // @[Nodes.scala 1210:84 BundleMap.scala 247:19]
  assign mem_R0_addr = {r_addr_hi,r_addr_lo}; // @[Cat.scala 30:58]
  assign mem_R0_en = in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  assign mem_R0_clk = clock; // @[package.scala 91:58 package.scala 91:58]
  assign mem_W0_addr = {w_addr_hi,w_addr_lo}; // @[Cat.scala 30:58]
  assign mem_W0_en = _T_1 & w_sel0; // @[SRAM.scala 86:24]
  assign mem_W0_clk = clock; // @[SRAM.scala 86:35]
  assign mem_W0_data_0 = auto_in_w_bits_data[7:0]; // @[SRAM.scala 85:62]
  assign mem_W0_data_1 = auto_in_w_bits_data[15:8]; // @[SRAM.scala 85:62]
  assign mem_W0_data_2 = auto_in_w_bits_data[23:16]; // @[SRAM.scala 85:62]
  assign mem_W0_data_3 = auto_in_w_bits_data[31:24]; // @[SRAM.scala 85:62]
  assign mem_W0_data_4 = auto_in_w_bits_data[39:32]; // @[SRAM.scala 85:62]
  assign mem_W0_data_5 = auto_in_w_bits_data[47:40]; // @[SRAM.scala 85:62]
  assign mem_W0_data_6 = auto_in_w_bits_data[55:48]; // @[SRAM.scala 85:62]
  assign mem_W0_data_7 = auto_in_w_bits_data[63:56]; // @[SRAM.scala 85:62]
  assign mem_W0_mask_0 = auto_in_w_bits_strb[0]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_1 = auto_in_w_bits_strb[1]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_2 = auto_in_w_bits_strb[2]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_3 = auto_in_w_bits_strb[3]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_4 = auto_in_w_bits_strb[4]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_5 = auto_in_w_bits_strb[5]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_6 = auto_in_w_bits_strb[6]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_7 = auto_in_w_bits_strb[7]; // @[SRAM.scala 87:47]
  always @(posedge clock) begin
    if (reset) begin // @[SRAM.scala 70:25]
      w_full <= 1'h0; // @[SRAM.scala 70:25]
    end else begin
      w_full <= _GEN_1;
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_id <= auto_in_aw_bits_id; // @[SRAM.scala 80:12]
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_echo_real_last <= auto_in_aw_bits_echo_real_last; // @[BundleMap.scala 247:19]
    end
    if (_T_14) begin // @[SRAM.scala 106:25]
      r_sel1 <= r_sel0; // @[SRAM.scala 108:14]
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_sel1 <= w_sel0; // @[SRAM.scala 81:14]
    end
    if (reset) begin // @[SRAM.scala 99:25]
      r_full <= 1'h0; // @[SRAM.scala 99:25]
    end else begin
      r_full <= _GEN_41;
    end
    if (_T_14) begin // @[SRAM.scala 106:25]
      r_id <= auto_in_ar_bits_id; // @[SRAM.scala 107:12]
    end
    if (_T_14) begin // @[SRAM.scala 106:25]
      r_echo_real_last <= auto_in_ar_bits_echo_real_last; // @[BundleMap.scala 247:19]
    end
    rdata_REG <= in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_0 <= mem_R0_data_0; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_1 <= mem_R0_data_1; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_2 <= mem_R0_data_2; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_3 <= mem_R0_data_3; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_4 <= mem_R0_data_4; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_5 <= mem_R0_data_5; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_6 <= mem_R0_data_6; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_7 <= mem_R0_data_7; // @[Reg.scala 16:23]
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
  w_full = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  w_id = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  w_echo_real_last = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  r_sel1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  w_sel1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  r_full = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  r_id = _RAND_6[3:0];
  _RAND_7 = {1{`RANDOM}};
  r_echo_real_last = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  rdata_REG = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  rdata_r_0 = _RAND_9[7:0];
  _RAND_10 = {1{`RANDOM}};
  rdata_r_1 = _RAND_10[7:0];
  _RAND_11 = {1{`RANDOM}};
  rdata_r_2 = _RAND_11[7:0];
  _RAND_12 = {1{`RANDOM}};
  rdata_r_3 = _RAND_12[7:0];
  _RAND_13 = {1{`RANDOM}};
  rdata_r_4 = _RAND_13[7:0];
  _RAND_14 = {1{`RANDOM}};
  rdata_r_5 = _RAND_14[7:0];
  _RAND_15 = {1{`RANDOM}};
  rdata_r_6 = _RAND_15[7:0];
  _RAND_16 = {1{`RANDOM}};
  rdata_r_7 = _RAND_16[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4Xbar_inTestHarness(
  input         clock,
  input         reset,
  output        auto_in_aw_ready,
  input         auto_in_aw_valid,
  input  [3:0]  auto_in_aw_bits_id,
  input  [27:0] auto_in_aw_bits_addr,
  input  [7:0]  auto_in_aw_bits_len,
  input  [2:0]  auto_in_aw_bits_size,
  input  [1:0]  auto_in_aw_bits_burst,
  output        auto_in_w_ready,
  input         auto_in_w_valid,
  input  [63:0] auto_in_w_bits_data,
  input  [7:0]  auto_in_w_bits_strb,
  input         auto_in_w_bits_last,
  input         auto_in_b_ready,
  output        auto_in_b_valid,
  output [3:0]  auto_in_b_bits_id,
  output [1:0]  auto_in_b_bits_resp,
  output        auto_in_ar_ready,
  input         auto_in_ar_valid,
  input  [3:0]  auto_in_ar_bits_id,
  input  [27:0] auto_in_ar_bits_addr,
  input  [7:0]  auto_in_ar_bits_len,
  input  [2:0]  auto_in_ar_bits_size,
  input  [1:0]  auto_in_ar_bits_burst,
  input         auto_in_r_ready,
  output        auto_in_r_valid,
  output [3:0]  auto_in_r_bits_id,
  output [63:0] auto_in_r_bits_data,
  output [1:0]  auto_in_r_bits_resp,
  output        auto_in_r_bits_last,
  input         auto_out_aw_ready,
  output        auto_out_aw_valid,
  output [3:0]  auto_out_aw_bits_id,
  output [27:0] auto_out_aw_bits_addr,
  output [7:0]  auto_out_aw_bits_len,
  output [2:0]  auto_out_aw_bits_size,
  output [1:0]  auto_out_aw_bits_burst,
  input         auto_out_w_ready,
  output        auto_out_w_valid,
  output [63:0] auto_out_w_bits_data,
  output [7:0]  auto_out_w_bits_strb,
  output        auto_out_w_bits_last,
  output        auto_out_b_ready,
  input         auto_out_b_valid,
  input  [3:0]  auto_out_b_bits_id,
  input  [1:0]  auto_out_b_bits_resp,
  input         auto_out_ar_ready,
  output        auto_out_ar_valid,
  output [3:0]  auto_out_ar_bits_id,
  output [27:0] auto_out_ar_bits_addr,
  output [7:0]  auto_out_ar_bits_len,
  output [2:0]  auto_out_ar_bits_size,
  output [1:0]  auto_out_ar_bits_burst,
  output        auto_out_r_ready,
  input         auto_out_r_valid,
  input  [3:0]  auto_out_r_bits_id,
  input  [63:0] auto_out_r_bits_data,
  input  [1:0]  auto_out_r_bits_resp,
  input         auto_out_r_bits_last
);
  wire  _awOut_0_io_enq_bits_T_1 = ~auto_in_aw_valid; // @[Xbar.scala 263:60]
  wire  _T_1 = ~auto_in_ar_valid; // @[Xbar.scala 263:60]
  wire  _T_14 = ~auto_out_r_valid; // @[Xbar.scala 263:60]
  wire  _T_26 = ~auto_out_b_valid; // @[Xbar.scala 263:60]
  assign auto_in_aw_ready = auto_out_aw_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_w_ready = auto_out_w_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_b_valid = auto_out_b_valid; // @[Xbar.scala 285:22]
  assign auto_in_b_bits_id = auto_out_b_bits_id; // @[Xbar.scala 83:69]
  assign auto_in_b_bits_resp = auto_out_b_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_ar_ready = auto_out_ar_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_valid = auto_out_r_valid; // @[Xbar.scala 285:22]
  assign auto_in_r_bits_id = auto_out_r_bits_id; // @[Xbar.scala 83:69]
  assign auto_in_r_bits_data = auto_out_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_resp = auto_out_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_last = auto_out_r_bits_last; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_out_aw_valid = auto_in_aw_valid; // @[Xbar.scala 285:22]
  assign auto_out_aw_bits_id = auto_in_aw_bits_id; // @[Xbar.scala 86:47]
  assign auto_out_aw_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_aw_bits_len = auto_in_aw_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_aw_bits_size = auto_in_aw_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_aw_bits_burst = auto_in_aw_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_w_valid = auto_in_w_valid; // @[Xbar.scala 229:40]
  assign auto_out_w_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_w_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_w_bits_last = auto_in_w_bits_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_b_ready = auto_in_b_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_ar_valid = auto_in_ar_valid; // @[Xbar.scala 285:22]
  assign auto_out_ar_bits_id = auto_in_ar_bits_id; // @[Xbar.scala 87:47]
  assign auto_out_ar_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_ar_bits_len = auto_in_ar_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_ar_bits_size = auto_in_ar_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_ar_bits_burst = auto_in_ar_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_r_ready = auto_in_r_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_awOut_0_io_enq_bits_T_1 | auto_in_aw_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_awOut_0_io_enq_bits_T_1 | auto_in_aw_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_T_1 | auto_in_ar_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_T_1 | auto_in_ar_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_T_14 | auto_out_r_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_T_14 | auto_out_r_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_T_26 | auto_out_b_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_T_26 | auto_out_b_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module Queue_61_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [3:0]  io_enq_bits_id,
  input  [27:0] io_enq_bits_addr,
  input         io_enq_bits_echo_real_last,
  input         io_deq_ready,
  output        io_deq_valid,
  output [3:0]  io_deq_bits_id,
  output [27:0] io_deq_bits_addr,
  output        io_deq_bits_echo_real_last
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:1]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [27:0] ram_addr [0:1]; // @[Decoupled.scala 218:16]
  wire [27:0] ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [27:0] ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_echo_real_last [0:1]; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  value; // @[Counter.scala 60:40]
  reg  value_1; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = value == value_1; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign ram_id_io_deq_bits_MPORT_addr = value_1;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = value;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_addr_io_deq_bits_MPORT_addr = value_1;
  assign ram_addr_io_deq_bits_MPORT_data = ram_addr[ram_addr_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_addr_MPORT_data = io_enq_bits_addr;
  assign ram_addr_MPORT_addr = value;
  assign ram_addr_MPORT_mask = 1'h1;
  assign ram_addr_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_echo_real_last_io_deq_bits_MPORT_addr = value_1;
  assign ram_echo_real_last_io_deq_bits_MPORT_data = ram_echo_real_last[ram_echo_real_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_echo_real_last_MPORT_data = io_enq_bits_echo_real_last;
  assign ram_echo_real_last_MPORT_addr = value;
  assign ram_echo_real_last_MPORT_mask = 1'h1;
  assign ram_echo_real_last_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits_id = ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_addr = ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_echo_real_last = ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_addr_MPORT_en & ram_addr_MPORT_mask) begin
      ram_addr[ram_addr_MPORT_addr] <= ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_echo_real_last_MPORT_en & ram_echo_real_last_MPORT_mask) begin
      ram_echo_real_last[ram_echo_real_last_MPORT_addr] <= ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      value <= value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value_1 <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      value_1 <= value_1 + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_addr[initvar] = _RAND_1[27:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_echo_real_last[initvar] = _RAND_2[0:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  value = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  value_1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  maybe_full = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_63_inTestHarness(
  input        clock,
  input        reset,
  output       io_enq_ready,
  input        io_enq_valid,
  input  [3:0] io_enq_bits_id,
  input  [1:0] io_enq_bits_resp,
  input        io_enq_bits_echo_real_last,
  input        io_deq_ready,
  output       io_deq_valid,
  output [3:0] io_deq_bits_id,
  output [1:0] io_deq_bits_resp,
  output       io_deq_bits_echo_real_last
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:1]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [1:0] ram_resp [0:1]; // @[Decoupled.scala 218:16]
  wire [1:0] ram_resp_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_resp_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [1:0] ram_resp_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_echo_real_last [0:1]; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  value; // @[Counter.scala 60:40]
  reg  value_1; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = value == value_1; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign ram_id_io_deq_bits_MPORT_addr = value_1;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = value;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_resp_io_deq_bits_MPORT_addr = value_1;
  assign ram_resp_io_deq_bits_MPORT_data = ram_resp[ram_resp_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_resp_MPORT_data = io_enq_bits_resp;
  assign ram_resp_MPORT_addr = value;
  assign ram_resp_MPORT_mask = 1'h1;
  assign ram_resp_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_echo_real_last_io_deq_bits_MPORT_addr = value_1;
  assign ram_echo_real_last_io_deq_bits_MPORT_data = ram_echo_real_last[ram_echo_real_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_echo_real_last_MPORT_data = io_enq_bits_echo_real_last;
  assign ram_echo_real_last_MPORT_addr = value;
  assign ram_echo_real_last_MPORT_mask = 1'h1;
  assign ram_echo_real_last_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits_id = ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_resp = ram_resp_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_echo_real_last = ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_resp_MPORT_en & ram_resp_MPORT_mask) begin
      ram_resp[ram_resp_MPORT_addr] <= ram_resp_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_echo_real_last_MPORT_en & ram_echo_real_last_MPORT_mask) begin
      ram_echo_real_last[ram_echo_real_last_MPORT_addr] <= ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      value <= value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value_1 <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      value_1 <= value_1 + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_resp[initvar] = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_echo_real_last[initvar] = _RAND_2[0:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  value = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  value_1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  maybe_full = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_65_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [3:0]  io_enq_bits_id,
  input  [63:0] io_enq_bits_data,
  input  [1:0]  io_enq_bits_resp,
  input         io_enq_bits_echo_real_last,
  input         io_deq_ready,
  output        io_deq_valid,
  output [3:0]  io_deq_bits_id,
  output [63:0] io_deq_bits_data,
  output [1:0]  io_deq_bits_resp,
  output        io_deq_bits_echo_real_last,
  output        io_deq_bits_last
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:1]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [63:0] ram_data [0:1]; // @[Decoupled.scala 218:16]
  wire [63:0] ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [63:0] ram_data_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_en; // @[Decoupled.scala 218:16]
  reg [1:0] ram_resp [0:1]; // @[Decoupled.scala 218:16]
  wire [1:0] ram_resp_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_resp_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [1:0] ram_resp_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_echo_real_last [0:1]; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_last [0:1]; // @[Decoupled.scala 218:16]
  wire  ram_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  value; // @[Counter.scala 60:40]
  reg  value_1; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = value == value_1; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign ram_id_io_deq_bits_MPORT_addr = value_1;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = value;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_data_io_deq_bits_MPORT_addr = value_1;
  assign ram_data_io_deq_bits_MPORT_data = ram_data[ram_data_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_data_MPORT_data = io_enq_bits_data;
  assign ram_data_MPORT_addr = value;
  assign ram_data_MPORT_mask = 1'h1;
  assign ram_data_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_resp_io_deq_bits_MPORT_addr = value_1;
  assign ram_resp_io_deq_bits_MPORT_data = ram_resp[ram_resp_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_resp_MPORT_data = io_enq_bits_resp;
  assign ram_resp_MPORT_addr = value;
  assign ram_resp_MPORT_mask = 1'h1;
  assign ram_resp_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_echo_real_last_io_deq_bits_MPORT_addr = value_1;
  assign ram_echo_real_last_io_deq_bits_MPORT_data = ram_echo_real_last[ram_echo_real_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_echo_real_last_MPORT_data = io_enq_bits_echo_real_last;
  assign ram_echo_real_last_MPORT_addr = value;
  assign ram_echo_real_last_MPORT_mask = 1'h1;
  assign ram_echo_real_last_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_last_io_deq_bits_MPORT_addr = value_1;
  assign ram_last_io_deq_bits_MPORT_data = ram_last[ram_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_last_MPORT_data = 1'h1;
  assign ram_last_MPORT_addr = value;
  assign ram_last_MPORT_mask = 1'h1;
  assign ram_last_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits_id = ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_data = ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_resp = ram_resp_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_echo_real_last = ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_last = ram_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_data_MPORT_en & ram_data_MPORT_mask) begin
      ram_data[ram_data_MPORT_addr] <= ram_data_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_resp_MPORT_en & ram_resp_MPORT_mask) begin
      ram_resp[ram_resp_MPORT_addr] <= ram_resp_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_echo_real_last_MPORT_en & ram_echo_real_last_MPORT_mask) begin
      ram_echo_real_last[ram_echo_real_last_MPORT_addr] <= ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_last_MPORT_en & ram_last_MPORT_mask) begin
      ram_last[ram_last_MPORT_addr] <= ram_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      value <= value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value_1 <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      value_1 <= value_1 + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {2{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_data[initvar] = _RAND_1[63:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_resp[initvar] = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_echo_real_last[initvar] = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_last[initvar] = _RAND_4[0:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_5 = {1{`RANDOM}};
  value = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  value_1 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  maybe_full = _RAND_7[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4Buffer_1_inTestHarness(
  input         clock,
  input         reset,
  output        auto_in_aw_ready,
  input         auto_in_aw_valid,
  input  [3:0]  auto_in_aw_bits_id,
  input  [27:0] auto_in_aw_bits_addr,
  input         auto_in_aw_bits_echo_real_last,
  output        auto_in_w_ready,
  input         auto_in_w_valid,
  input  [63:0] auto_in_w_bits_data,
  input  [7:0]  auto_in_w_bits_strb,
  input         auto_in_b_ready,
  output        auto_in_b_valid,
  output [3:0]  auto_in_b_bits_id,
  output [1:0]  auto_in_b_bits_resp,
  output        auto_in_b_bits_echo_real_last,
  output        auto_in_ar_ready,
  input         auto_in_ar_valid,
  input  [3:0]  auto_in_ar_bits_id,
  input  [27:0] auto_in_ar_bits_addr,
  input         auto_in_ar_bits_echo_real_last,
  input         auto_in_r_ready,
  output        auto_in_r_valid,
  output [3:0]  auto_in_r_bits_id,
  output [63:0] auto_in_r_bits_data,
  output [1:0]  auto_in_r_bits_resp,
  output        auto_in_r_bits_echo_real_last,
  output        auto_in_r_bits_last,
  input         auto_out_aw_ready,
  output        auto_out_aw_valid,
  output [3:0]  auto_out_aw_bits_id,
  output [27:0] auto_out_aw_bits_addr,
  output        auto_out_aw_bits_echo_real_last,
  input         auto_out_w_ready,
  output        auto_out_w_valid,
  output [63:0] auto_out_w_bits_data,
  output [7:0]  auto_out_w_bits_strb,
  output        auto_out_b_ready,
  input         auto_out_b_valid,
  input  [3:0]  auto_out_b_bits_id,
  input  [1:0]  auto_out_b_bits_resp,
  input         auto_out_b_bits_echo_real_last,
  input         auto_out_ar_ready,
  output        auto_out_ar_valid,
  output [3:0]  auto_out_ar_bits_id,
  output [27:0] auto_out_ar_bits_addr,
  output        auto_out_ar_bits_echo_real_last,
  output        auto_out_r_ready,
  input         auto_out_r_valid,
  input  [3:0]  auto_out_r_bits_id,
  input  [63:0] auto_out_r_bits_data,
  input  [1:0]  auto_out_r_bits_resp,
  input         auto_out_r_bits_echo_real_last
);
  wire  bundleOut_0_aw_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_aw_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [27:0] bundleOut_0_aw_deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_aw_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [27:0] bundleOut_0_aw_deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [63:0] bundleOut_0_w_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [7:0] bundleOut_0_w_deq_io_enq_bits_strb; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [63:0] bundleOut_0_w_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [7:0] bundleOut_0_w_deq_io_deq_bits_strb; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_b_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_b_deq_io_enq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_b_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_b_deq_io_deq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_ar_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [27:0] bundleOut_0_ar_deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_ar_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [27:0] bundleOut_0_ar_deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_r_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [63:0] bundleIn_0_r_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_r_deq_io_enq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_r_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [63:0] bundleIn_0_r_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_r_deq_io_deq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_bits_last; // @[Decoupled.scala 296:21]
  Queue_61_inTestHarness bundleOut_0_aw_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_aw_deq_clock),
    .reset(bundleOut_0_aw_deq_reset),
    .io_enq_ready(bundleOut_0_aw_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_aw_deq_io_enq_valid),
    .io_enq_bits_id(bundleOut_0_aw_deq_io_enq_bits_id),
    .io_enq_bits_addr(bundleOut_0_aw_deq_io_enq_bits_addr),
    .io_enq_bits_echo_real_last(bundleOut_0_aw_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleOut_0_aw_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_aw_deq_io_deq_valid),
    .io_deq_bits_id(bundleOut_0_aw_deq_io_deq_bits_id),
    .io_deq_bits_addr(bundleOut_0_aw_deq_io_deq_bits_addr),
    .io_deq_bits_echo_real_last(bundleOut_0_aw_deq_io_deq_bits_echo_real_last)
  );
  Queue_1_inTestHarness bundleOut_0_w_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_w_deq_clock),
    .reset(bundleOut_0_w_deq_reset),
    .io_enq_ready(bundleOut_0_w_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_w_deq_io_enq_valid),
    .io_enq_bits_data(bundleOut_0_w_deq_io_enq_bits_data),
    .io_enq_bits_strb(bundleOut_0_w_deq_io_enq_bits_strb),
    .io_deq_ready(bundleOut_0_w_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_w_deq_io_deq_valid),
    .io_deq_bits_data(bundleOut_0_w_deq_io_deq_bits_data),
    .io_deq_bits_strb(bundleOut_0_w_deq_io_deq_bits_strb)
  );
  Queue_63_inTestHarness bundleIn_0_b_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleIn_0_b_deq_clock),
    .reset(bundleIn_0_b_deq_reset),
    .io_enq_ready(bundleIn_0_b_deq_io_enq_ready),
    .io_enq_valid(bundleIn_0_b_deq_io_enq_valid),
    .io_enq_bits_id(bundleIn_0_b_deq_io_enq_bits_id),
    .io_enq_bits_resp(bundleIn_0_b_deq_io_enq_bits_resp),
    .io_enq_bits_echo_real_last(bundleIn_0_b_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleIn_0_b_deq_io_deq_ready),
    .io_deq_valid(bundleIn_0_b_deq_io_deq_valid),
    .io_deq_bits_id(bundleIn_0_b_deq_io_deq_bits_id),
    .io_deq_bits_resp(bundleIn_0_b_deq_io_deq_bits_resp),
    .io_deq_bits_echo_real_last(bundleIn_0_b_deq_io_deq_bits_echo_real_last)
  );
  Queue_61_inTestHarness bundleOut_0_ar_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_ar_deq_clock),
    .reset(bundleOut_0_ar_deq_reset),
    .io_enq_ready(bundleOut_0_ar_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_ar_deq_io_enq_valid),
    .io_enq_bits_id(bundleOut_0_ar_deq_io_enq_bits_id),
    .io_enq_bits_addr(bundleOut_0_ar_deq_io_enq_bits_addr),
    .io_enq_bits_echo_real_last(bundleOut_0_ar_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleOut_0_ar_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_ar_deq_io_deq_valid),
    .io_deq_bits_id(bundleOut_0_ar_deq_io_deq_bits_id),
    .io_deq_bits_addr(bundleOut_0_ar_deq_io_deq_bits_addr),
    .io_deq_bits_echo_real_last(bundleOut_0_ar_deq_io_deq_bits_echo_real_last)
  );
  Queue_65_inTestHarness bundleIn_0_r_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleIn_0_r_deq_clock),
    .reset(bundleIn_0_r_deq_reset),
    .io_enq_ready(bundleIn_0_r_deq_io_enq_ready),
    .io_enq_valid(bundleIn_0_r_deq_io_enq_valid),
    .io_enq_bits_id(bundleIn_0_r_deq_io_enq_bits_id),
    .io_enq_bits_data(bundleIn_0_r_deq_io_enq_bits_data),
    .io_enq_bits_resp(bundleIn_0_r_deq_io_enq_bits_resp),
    .io_enq_bits_echo_real_last(bundleIn_0_r_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleIn_0_r_deq_io_deq_ready),
    .io_deq_valid(bundleIn_0_r_deq_io_deq_valid),
    .io_deq_bits_id(bundleIn_0_r_deq_io_deq_bits_id),
    .io_deq_bits_data(bundleIn_0_r_deq_io_deq_bits_data),
    .io_deq_bits_resp(bundleIn_0_r_deq_io_deq_bits_resp),
    .io_deq_bits_echo_real_last(bundleIn_0_r_deq_io_deq_bits_echo_real_last),
    .io_deq_bits_last(bundleIn_0_r_deq_io_deq_bits_last)
  );
  assign auto_in_aw_ready = bundleOut_0_aw_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_w_ready = bundleOut_0_w_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_b_valid = bundleIn_0_b_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_in_b_bits_id = bundleIn_0_b_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_b_bits_resp = bundleIn_0_b_deq_io_deq_bits_resp; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_b_bits_echo_real_last = bundleIn_0_b_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_ar_ready = bundleOut_0_ar_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_r_valid = bundleIn_0_r_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_in_r_bits_id = bundleIn_0_r_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_data = bundleIn_0_r_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_resp = bundleIn_0_r_deq_io_deq_bits_resp; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_echo_real_last = bundleIn_0_r_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_last = bundleIn_0_r_deq_io_deq_bits_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_valid = bundleOut_0_aw_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_aw_bits_id = bundleOut_0_aw_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_addr = bundleOut_0_aw_deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_echo_real_last = bundleOut_0_aw_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_valid = bundleOut_0_w_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_w_bits_data = bundleOut_0_w_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_bits_strb = bundleOut_0_w_deq_io_deq_bits_strb; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_b_ready = bundleIn_0_b_deq_io_enq_ready; // @[Nodes.scala 1207:84 Decoupled.scala 299:17]
  assign auto_out_ar_valid = bundleOut_0_ar_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_ar_bits_id = bundleOut_0_ar_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_addr = bundleOut_0_ar_deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_echo_real_last = bundleOut_0_ar_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_r_ready = bundleIn_0_r_deq_io_enq_ready; // @[Nodes.scala 1207:84 Decoupled.scala 299:17]
  assign bundleOut_0_aw_deq_clock = clock;
  assign bundleOut_0_aw_deq_reset = reset;
  assign bundleOut_0_aw_deq_io_enq_valid = auto_in_aw_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_id = auto_in_aw_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_echo_real_last = auto_in_aw_bits_echo_real_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_deq_ready = auto_out_aw_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleOut_0_w_deq_clock = clock;
  assign bundleOut_0_w_deq_reset = reset;
  assign bundleOut_0_w_deq_io_enq_valid = auto_in_w_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_enq_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_enq_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_deq_ready = auto_out_w_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_clock = clock;
  assign bundleIn_0_b_deq_reset = reset;
  assign bundleIn_0_b_deq_io_enq_valid = auto_out_b_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_id = auto_out_b_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_resp = auto_out_b_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_echo_real_last = auto_out_b_bits_echo_real_last; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_deq_ready = auto_in_b_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_clock = clock;
  assign bundleOut_0_ar_deq_reset = reset;
  assign bundleOut_0_ar_deq_io_enq_valid = auto_in_ar_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_id = auto_in_ar_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_echo_real_last = auto_in_ar_bits_echo_real_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_deq_ready = auto_out_ar_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_clock = clock;
  assign bundleIn_0_r_deq_reset = reset;
  assign bundleIn_0_r_deq_io_enq_valid = auto_out_r_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_id = auto_out_r_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_data = auto_out_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_resp = auto_out_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_echo_real_last = auto_out_r_bits_echo_real_last; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_deq_ready = auto_in_r_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module Queue_66_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [3:0]  io_enq_bits_id,
  input  [27:0] io_enq_bits_addr,
  input  [7:0]  io_enq_bits_len,
  input  [2:0]  io_enq_bits_size,
  input  [1:0]  io_enq_bits_burst,
  input         io_deq_ready,
  output        io_deq_valid,
  output [3:0]  io_deq_bits_id,
  output [27:0] io_deq_bits_addr,
  output [7:0]  io_deq_bits_len,
  output [2:0]  io_deq_bits_size,
  output [1:0]  io_deq_bits_burst
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:0]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [27:0] ram_addr [0:0]; // @[Decoupled.scala 218:16]
  wire [27:0] ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [27:0] ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_en; // @[Decoupled.scala 218:16]
  reg [7:0] ram_len [0:0]; // @[Decoupled.scala 218:16]
  wire [7:0] ram_len_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_len_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [7:0] ram_len_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_en; // @[Decoupled.scala 218:16]
  reg [2:0] ram_size [0:0]; // @[Decoupled.scala 218:16]
  wire [2:0] ram_size_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_size_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [2:0] ram_size_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_en; // @[Decoupled.scala 218:16]
  reg [1:0] ram_burst [0:0]; // @[Decoupled.scala 218:16]
  wire [1:0] ram_burst_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_burst_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [1:0] ram_burst_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_en; // @[Decoupled.scala 218:16]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  empty = ~maybe_full; // @[Decoupled.scala 224:28]
  wire  _do_enq_T = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  _do_deq_T = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_15 = io_deq_ready ? 1'h0 : _do_enq_T; // @[Decoupled.scala 249:27 Decoupled.scala 249:36]
  wire  do_enq = empty ? _GEN_15 : _do_enq_T; // @[Decoupled.scala 246:18]
  wire  do_deq = empty ? 1'h0 : _do_deq_T; // @[Decoupled.scala 246:18 Decoupled.scala 248:14]
  assign ram_id_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = 1'h0;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_addr_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_addr_io_deq_bits_MPORT_data = ram_addr[ram_addr_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_addr_MPORT_data = io_enq_bits_addr;
  assign ram_addr_MPORT_addr = 1'h0;
  assign ram_addr_MPORT_mask = 1'h1;
  assign ram_addr_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_len_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_len_io_deq_bits_MPORT_data = ram_len[ram_len_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_len_MPORT_data = io_enq_bits_len;
  assign ram_len_MPORT_addr = 1'h0;
  assign ram_len_MPORT_mask = 1'h1;
  assign ram_len_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_size_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_size_io_deq_bits_MPORT_data = ram_size[ram_size_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_size_MPORT_data = io_enq_bits_size;
  assign ram_size_MPORT_addr = 1'h0;
  assign ram_size_MPORT_mask = 1'h1;
  assign ram_size_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_burst_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_burst_io_deq_bits_MPORT_data = ram_burst[ram_burst_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_burst_MPORT_data = io_enq_bits_burst;
  assign ram_burst_MPORT_addr = 1'h0;
  assign ram_burst_MPORT_mask = 1'h1;
  assign ram_burst_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign io_enq_ready = ~maybe_full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = io_enq_valid | ~empty; // @[Decoupled.scala 245:25 Decoupled.scala 245:40 Decoupled.scala 240:16]
  assign io_deq_bits_id = empty ? io_enq_bits_id : ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_addr = empty ? io_enq_bits_addr : ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_len = empty ? io_enq_bits_len : ram_len_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_size = empty ? io_enq_bits_size : ram_size_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_burst = empty ? io_enq_bits_burst : ram_burst_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_addr_MPORT_en & ram_addr_MPORT_mask) begin
      ram_addr[ram_addr_MPORT_addr] <= ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_len_MPORT_en & ram_len_MPORT_mask) begin
      ram_len[ram_len_MPORT_addr] <= ram_len_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_size_MPORT_en & ram_size_MPORT_mask) begin
      ram_size[ram_size_MPORT_addr] <= ram_size_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_burst_MPORT_en & ram_burst_MPORT_mask) begin
      ram_burst[ram_burst_MPORT_addr] <= ram_burst_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      if (empty) begin // @[Decoupled.scala 246:18]
        if (io_deq_ready) begin // @[Decoupled.scala 249:27]
          maybe_full <= 1'h0; // @[Decoupled.scala 249:36]
        end else begin
          maybe_full <= _do_enq_T;
        end
      end else begin
        maybe_full <= _do_enq_T;
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_addr[initvar] = _RAND_1[27:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_len[initvar] = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_size[initvar] = _RAND_3[2:0];
  _RAND_4 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_burst[initvar] = _RAND_4[1:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_5 = {1{`RANDOM}};
  maybe_full = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4Fragmenter_1_inTestHarness(
  input         clock,
  input         reset,
  output        auto_in_aw_ready,
  input         auto_in_aw_valid,
  input  [3:0]  auto_in_aw_bits_id,
  input  [27:0] auto_in_aw_bits_addr,
  input  [7:0]  auto_in_aw_bits_len,
  input  [2:0]  auto_in_aw_bits_size,
  input  [1:0]  auto_in_aw_bits_burst,
  output        auto_in_w_ready,
  input         auto_in_w_valid,
  input  [63:0] auto_in_w_bits_data,
  input  [7:0]  auto_in_w_bits_strb,
  input         auto_in_w_bits_last,
  input         auto_in_b_ready,
  output        auto_in_b_valid,
  output [3:0]  auto_in_b_bits_id,
  output [1:0]  auto_in_b_bits_resp,
  output        auto_in_ar_ready,
  input         auto_in_ar_valid,
  input  [3:0]  auto_in_ar_bits_id,
  input  [27:0] auto_in_ar_bits_addr,
  input  [7:0]  auto_in_ar_bits_len,
  input  [2:0]  auto_in_ar_bits_size,
  input  [1:0]  auto_in_ar_bits_burst,
  input         auto_in_r_ready,
  output        auto_in_r_valid,
  output [3:0]  auto_in_r_bits_id,
  output [63:0] auto_in_r_bits_data,
  output [1:0]  auto_in_r_bits_resp,
  output        auto_in_r_bits_last,
  input         auto_out_aw_ready,
  output        auto_out_aw_valid,
  output [3:0]  auto_out_aw_bits_id,
  output [27:0] auto_out_aw_bits_addr,
  output        auto_out_aw_bits_echo_real_last,
  input         auto_out_w_ready,
  output        auto_out_w_valid,
  output [63:0] auto_out_w_bits_data,
  output [7:0]  auto_out_w_bits_strb,
  output        auto_out_b_ready,
  input         auto_out_b_valid,
  input  [3:0]  auto_out_b_bits_id,
  input  [1:0]  auto_out_b_bits_resp,
  input         auto_out_b_bits_echo_real_last,
  input         auto_out_ar_ready,
  output        auto_out_ar_valid,
  output [3:0]  auto_out_ar_bits_id,
  output [27:0] auto_out_ar_bits_addr,
  output        auto_out_ar_bits_echo_real_last,
  output        auto_out_r_ready,
  input         auto_out_r_valid,
  input  [3:0]  auto_out_r_bits_id,
  input  [63:0] auto_out_r_bits_data,
  input  [1:0]  auto_out_r_bits_resp,
  input         auto_out_r_bits_echo_real_last,
  input         auto_out_r_bits_last
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
`endif // RANDOMIZE_REG_INIT
  wire  deq_clock; // @[Decoupled.scala 296:21]
  wire  deq_reset; // @[Decoupled.scala 296:21]
  wire  deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [27:0] deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_io_enq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_io_enq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_io_enq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [27:0] deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_io_deq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_io_deq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_io_deq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_1_clock; // @[Decoupled.scala 296:21]
  wire  deq_1_reset; // @[Decoupled.scala 296:21]
  wire  deq_1_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  deq_1_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_1_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [27:0] deq_1_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_1_io_enq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_1_io_enq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_1_io_enq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_1_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  deq_1_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_1_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [27:0] deq_1_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_1_io_deq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_1_io_deq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_1_io_deq_bits_burst; // @[Decoupled.scala 296:21]
  wire  in_w_deq_clock; // @[Decoupled.scala 296:21]
  wire  in_w_deq_reset; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [63:0] in_w_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [7:0] in_w_deq_io_enq_bits_strb; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_bits_last; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [63:0] in_w_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [7:0] in_w_deq_io_deq_bits_strb; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_bits_last; // @[Decoupled.scala 296:21]
  reg  busy; // @[Fragmenter.scala 60:29]
  reg [27:0] r_addr; // @[Fragmenter.scala 61:25]
  reg [7:0] r_len; // @[Fragmenter.scala 62:25]
  wire [7:0] irr_bits_len = deq_io_deq_bits_len; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [7:0] len = busy ? r_len : irr_bits_len; // @[Fragmenter.scala 64:23]
  wire [27:0] irr_bits_addr = deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [27:0] addr = busy ? r_addr : irr_bits_addr; // @[Fragmenter.scala 65:23]
  wire [1:0] irr_bits_burst = deq_io_deq_bits_burst; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  fixed = irr_bits_burst == 2'h0; // @[Fragmenter.scala 92:34]
  wire [2:0] irr_bits_size = deq_io_deq_bits_size; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [15:0] _inc_addr_T = 16'h1 << irr_bits_size; // @[Fragmenter.scala 100:38]
  wire [27:0] _GEN_48 = {{12'd0}, _inc_addr_T}; // @[Fragmenter.scala 100:29]
  wire [27:0] inc_addr = addr + _GEN_48; // @[Fragmenter.scala 100:29]
  wire [15:0] _wrapMask_T = {irr_bits_len,8'hff}; // @[Cat.scala 30:58]
  wire [22:0] _GEN_49 = {{7'd0}, _wrapMask_T}; // @[Bundles.scala 30:21]
  wire [22:0] _wrapMask_T_1 = _GEN_49 << irr_bits_size; // @[Bundles.scala 30:21]
  wire [14:0] wrapMask = _wrapMask_T_1[22:8]; // @[Bundles.scala 30:30]
  wire [27:0] _GEN_50 = {{13'd0}, wrapMask}; // @[Fragmenter.scala 104:33]
  wire [27:0] _mux_addr_T = inc_addr & _GEN_50; // @[Fragmenter.scala 104:33]
  wire [27:0] _mux_addr_T_1 = ~irr_bits_addr; // @[Fragmenter.scala 104:49]
  wire [27:0] _mux_addr_T_2 = _mux_addr_T_1 | _GEN_50; // @[Fragmenter.scala 104:62]
  wire [27:0] _mux_addr_T_3 = ~_mux_addr_T_2; // @[Fragmenter.scala 104:47]
  wire [27:0] _mux_addr_T_4 = _mux_addr_T | _mux_addr_T_3; // @[Fragmenter.scala 104:45]
  wire  ar_last = 8'h0 == len; // @[Fragmenter.scala 110:27]
  wire [27:0] _out_bits_addr_T = ~addr; // @[Fragmenter.scala 122:28]
  wire [9:0] _out_bits_addr_T_2 = 10'h7 << irr_bits_size; // @[package.scala 234:77]
  wire [2:0] _out_bits_addr_T_4 = ~_out_bits_addr_T_2[2:0]; // @[package.scala 234:46]
  wire [27:0] _GEN_52 = {{25'd0}, _out_bits_addr_T_4}; // @[Fragmenter.scala 122:34]
  wire [27:0] _out_bits_addr_T_5 = _out_bits_addr_T | _GEN_52; // @[Fragmenter.scala 122:34]
  wire  irr_valid = deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _T_2 = auto_out_ar_ready & irr_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_53 = {{1'd0}, len}; // @[Fragmenter.scala 127:25]
  wire [8:0] _r_len_T_1 = _GEN_53 - 9'h1; // @[Fragmenter.scala 127:25]
  wire [8:0] _GEN_4 = _T_2 ? _r_len_T_1 : {{1'd0}, r_len}; // @[Fragmenter.scala 124:27 Fragmenter.scala 127:18 Fragmenter.scala 62:25]
  reg  busy_1; // @[Fragmenter.scala 60:29]
  reg [27:0] r_addr_1; // @[Fragmenter.scala 61:25]
  reg [7:0] r_len_1; // @[Fragmenter.scala 62:25]
  wire [7:0] irr_1_bits_len = deq_1_io_deq_bits_len; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [7:0] len_1 = busy_1 ? r_len_1 : irr_1_bits_len; // @[Fragmenter.scala 64:23]
  wire [27:0] irr_1_bits_addr = deq_1_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [27:0] addr_1 = busy_1 ? r_addr_1 : irr_1_bits_addr; // @[Fragmenter.scala 65:23]
  wire [1:0] irr_1_bits_burst = deq_1_io_deq_bits_burst; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  fixed_1 = irr_1_bits_burst == 2'h0; // @[Fragmenter.scala 92:34]
  wire [2:0] irr_1_bits_size = deq_1_io_deq_bits_size; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [15:0] _inc_addr_T_2 = 16'h1 << irr_1_bits_size; // @[Fragmenter.scala 100:38]
  wire [27:0] _GEN_58 = {{12'd0}, _inc_addr_T_2}; // @[Fragmenter.scala 100:29]
  wire [27:0] inc_addr_1 = addr_1 + _GEN_58; // @[Fragmenter.scala 100:29]
  wire [15:0] _wrapMask_T_2 = {irr_1_bits_len,8'hff}; // @[Cat.scala 30:58]
  wire [22:0] _GEN_59 = {{7'd0}, _wrapMask_T_2}; // @[Bundles.scala 30:21]
  wire [22:0] _wrapMask_T_3 = _GEN_59 << irr_1_bits_size; // @[Bundles.scala 30:21]
  wire [14:0] wrapMask_1 = _wrapMask_T_3[22:8]; // @[Bundles.scala 30:30]
  wire [27:0] _GEN_60 = {{13'd0}, wrapMask_1}; // @[Fragmenter.scala 104:33]
  wire [27:0] _mux_addr_T_5 = inc_addr_1 & _GEN_60; // @[Fragmenter.scala 104:33]
  wire [27:0] _mux_addr_T_6 = ~irr_1_bits_addr; // @[Fragmenter.scala 104:49]
  wire [27:0] _mux_addr_T_7 = _mux_addr_T_6 | _GEN_60; // @[Fragmenter.scala 104:62]
  wire [27:0] _mux_addr_T_8 = ~_mux_addr_T_7; // @[Fragmenter.scala 104:47]
  wire [27:0] _mux_addr_T_9 = _mux_addr_T_5 | _mux_addr_T_8; // @[Fragmenter.scala 104:45]
  wire  aw_last = 8'h0 == len_1; // @[Fragmenter.scala 110:27]
  reg [8:0] w_counter; // @[Fragmenter.scala 164:30]
  wire  w_idle = w_counter == 9'h0; // @[Fragmenter.scala 165:30]
  reg  wbeats_latched; // @[Fragmenter.scala 150:35]
  wire  _in_aw_ready_T = w_idle | wbeats_latched; // @[Fragmenter.scala 158:52]
  wire  in_aw_ready = auto_out_aw_ready & (w_idle | wbeats_latched); // @[Fragmenter.scala 158:35]
  wire [27:0] _out_bits_addr_T_7 = ~addr_1; // @[Fragmenter.scala 122:28]
  wire [9:0] _out_bits_addr_T_9 = 10'h7 << irr_1_bits_size; // @[package.scala 234:77]
  wire [2:0] _out_bits_addr_T_11 = ~_out_bits_addr_T_9[2:0]; // @[package.scala 234:46]
  wire [27:0] _GEN_62 = {{25'd0}, _out_bits_addr_T_11}; // @[Fragmenter.scala 122:34]
  wire [27:0] _out_bits_addr_T_12 = _out_bits_addr_T_7 | _GEN_62; // @[Fragmenter.scala 122:34]
  wire  irr_1_valid = deq_1_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _T_5 = in_aw_ready & irr_1_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_63 = {{1'd0}, len_1}; // @[Fragmenter.scala 127:25]
  wire [8:0] _r_len_T_3 = _GEN_63 - 9'h1; // @[Fragmenter.scala 127:25]
  wire [8:0] _GEN_9 = _T_5 ? _r_len_T_3 : {{1'd0}, r_len_1}; // @[Fragmenter.scala 124:27 Fragmenter.scala 127:18 Fragmenter.scala 62:25]
  wire  wbeats_valid = irr_1_valid & ~wbeats_latched; // @[Fragmenter.scala 159:35]
  wire  _GEN_10 = wbeats_valid & w_idle | wbeats_latched; // @[Fragmenter.scala 153:43 Fragmenter.scala 153:60 Fragmenter.scala 150:35]
  wire  bundleOut_0_aw_valid = irr_1_valid & _in_aw_ready_T; // @[Fragmenter.scala 157:35]
  wire  _T_7 = auto_out_aw_ready & bundleOut_0_aw_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _w_todo_T = wbeats_valid ? 9'h1 : 9'h0; // @[Fragmenter.scala 166:35]
  wire [8:0] w_todo = w_idle ? _w_todo_T : w_counter; // @[Fragmenter.scala 166:23]
  wire  w_last = w_todo == 9'h1; // @[Fragmenter.scala 167:27]
  wire  in_w_valid = in_w_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _bundleOut_0_w_valid_T_1 = ~w_idle | wbeats_valid; // @[Fragmenter.scala 173:51]
  wire  bundleOut_0_w_valid = in_w_valid & (~w_idle | wbeats_valid); // @[Fragmenter.scala 173:33]
  wire  _w_counter_T = auto_out_w_ready & bundleOut_0_w_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_64 = {{8'd0}, _w_counter_T}; // @[Fragmenter.scala 168:27]
  wire [8:0] _w_counter_T_2 = w_todo - _GEN_64; // @[Fragmenter.scala 168:27]
  wire  in_w_bits_last = in_w_deq_io_deq_bits_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  bundleOut_0_b_ready = auto_in_b_ready | ~auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 189:33]
  reg [1:0] error_0; // @[Fragmenter.scala 192:26]
  reg [1:0] error_1; // @[Fragmenter.scala 192:26]
  reg [1:0] error_2; // @[Fragmenter.scala 192:26]
  reg [1:0] error_3; // @[Fragmenter.scala 192:26]
  reg [1:0] error_4; // @[Fragmenter.scala 192:26]
  reg [1:0] error_5; // @[Fragmenter.scala 192:26]
  reg [1:0] error_6; // @[Fragmenter.scala 192:26]
  reg [1:0] error_7; // @[Fragmenter.scala 192:26]
  reg [1:0] error_8; // @[Fragmenter.scala 192:26]
  reg [1:0] error_9; // @[Fragmenter.scala 192:26]
  reg [1:0] error_10; // @[Fragmenter.scala 192:26]
  reg [1:0] error_11; // @[Fragmenter.scala 192:26]
  reg [1:0] error_12; // @[Fragmenter.scala 192:26]
  reg [1:0] error_13; // @[Fragmenter.scala 192:26]
  reg [1:0] error_14; // @[Fragmenter.scala 192:26]
  reg [1:0] error_15; // @[Fragmenter.scala 192:26]
  wire [1:0] _GEN_13 = 4'h1 == auto_out_b_bits_id ? error_1 : error_0; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_14 = 4'h2 == auto_out_b_bits_id ? error_2 : _GEN_13; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_15 = 4'h3 == auto_out_b_bits_id ? error_3 : _GEN_14; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_16 = 4'h4 == auto_out_b_bits_id ? error_4 : _GEN_15; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_17 = 4'h5 == auto_out_b_bits_id ? error_5 : _GEN_16; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_18 = 4'h6 == auto_out_b_bits_id ? error_6 : _GEN_17; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_19 = 4'h7 == auto_out_b_bits_id ? error_7 : _GEN_18; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_20 = 4'h8 == auto_out_b_bits_id ? error_8 : _GEN_19; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_21 = 4'h9 == auto_out_b_bits_id ? error_9 : _GEN_20; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_22 = 4'ha == auto_out_b_bits_id ? error_10 : _GEN_21; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_23 = 4'hb == auto_out_b_bits_id ? error_11 : _GEN_22; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_24 = 4'hc == auto_out_b_bits_id ? error_12 : _GEN_23; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_25 = 4'hd == auto_out_b_bits_id ? error_13 : _GEN_24; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_26 = 4'he == auto_out_b_bits_id ? error_14 : _GEN_25; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_27 = 4'hf == auto_out_b_bits_id ? error_15 : _GEN_26; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [15:0] _T_22 = 16'h1 << auto_out_b_bits_id; // @[OneHot.scala 65:12]
  wire  _T_40 = bundleOut_0_b_ready & auto_out_b_valid; // @[Decoupled.scala 40:37]
  wire [1:0] _error_0_T = error_0 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_1_T = error_1 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_2_T = error_2 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_3_T = error_3 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_4_T = error_4 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_5_T = error_5 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_6_T = error_6 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_7_T = error_7 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_8_T = error_8 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_9_T = error_9 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_10_T = error_10 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_11_T = error_11 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_12_T = error_12 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_13_T = error_13 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_14_T = error_14 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_15_T = error_15 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  Queue_66_inTestHarness deq ( // @[Decoupled.scala 296:21]
    .clock(deq_clock),
    .reset(deq_reset),
    .io_enq_ready(deq_io_enq_ready),
    .io_enq_valid(deq_io_enq_valid),
    .io_enq_bits_id(deq_io_enq_bits_id),
    .io_enq_bits_addr(deq_io_enq_bits_addr),
    .io_enq_bits_len(deq_io_enq_bits_len),
    .io_enq_bits_size(deq_io_enq_bits_size),
    .io_enq_bits_burst(deq_io_enq_bits_burst),
    .io_deq_ready(deq_io_deq_ready),
    .io_deq_valid(deq_io_deq_valid),
    .io_deq_bits_id(deq_io_deq_bits_id),
    .io_deq_bits_addr(deq_io_deq_bits_addr),
    .io_deq_bits_len(deq_io_deq_bits_len),
    .io_deq_bits_size(deq_io_deq_bits_size),
    .io_deq_bits_burst(deq_io_deq_bits_burst)
  );
  Queue_66_inTestHarness deq_1 ( // @[Decoupled.scala 296:21]
    .clock(deq_1_clock),
    .reset(deq_1_reset),
    .io_enq_ready(deq_1_io_enq_ready),
    .io_enq_valid(deq_1_io_enq_valid),
    .io_enq_bits_id(deq_1_io_enq_bits_id),
    .io_enq_bits_addr(deq_1_io_enq_bits_addr),
    .io_enq_bits_len(deq_1_io_enq_bits_len),
    .io_enq_bits_size(deq_1_io_enq_bits_size),
    .io_enq_bits_burst(deq_1_io_enq_bits_burst),
    .io_deq_ready(deq_1_io_deq_ready),
    .io_deq_valid(deq_1_io_deq_valid),
    .io_deq_bits_id(deq_1_io_deq_bits_id),
    .io_deq_bits_addr(deq_1_io_deq_bits_addr),
    .io_deq_bits_len(deq_1_io_deq_bits_len),
    .io_deq_bits_size(deq_1_io_deq_bits_size),
    .io_deq_bits_burst(deq_1_io_deq_bits_burst)
  );
  Queue_12_inTestHarness in_w_deq ( // @[Decoupled.scala 296:21]
    .clock(in_w_deq_clock),
    .reset(in_w_deq_reset),
    .io_enq_ready(in_w_deq_io_enq_ready),
    .io_enq_valid(in_w_deq_io_enq_valid),
    .io_enq_bits_data(in_w_deq_io_enq_bits_data),
    .io_enq_bits_strb(in_w_deq_io_enq_bits_strb),
    .io_enq_bits_last(in_w_deq_io_enq_bits_last),
    .io_deq_ready(in_w_deq_io_deq_ready),
    .io_deq_valid(in_w_deq_io_deq_valid),
    .io_deq_bits_data(in_w_deq_io_deq_bits_data),
    .io_deq_bits_strb(in_w_deq_io_deq_bits_strb),
    .io_deq_bits_last(in_w_deq_io_deq_bits_last)
  );
  assign auto_in_aw_ready = deq_1_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_w_ready = in_w_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_b_valid = auto_out_b_valid & auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 188:33]
  assign auto_in_b_bits_id = auto_out_b_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_b_bits_resp = auto_out_b_bits_resp | _GEN_27; // @[Fragmenter.scala 193:41]
  assign auto_in_ar_ready = deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_r_valid = auto_out_r_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_id = auto_out_r_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_data = auto_out_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_resp = auto_out_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_last = auto_out_r_bits_last & auto_out_r_bits_echo_real_last; // @[Fragmenter.scala 183:41]
  assign auto_out_aw_valid = irr_1_valid & _in_aw_ready_T; // @[Fragmenter.scala 157:35]
  assign auto_out_aw_bits_id = deq_1_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_addr = ~_out_bits_addr_T_12; // @[Fragmenter.scala 122:26]
  assign auto_out_aw_bits_echo_real_last = 8'h0 == len_1; // @[Fragmenter.scala 110:27]
  assign auto_out_w_valid = in_w_valid & (~w_idle | wbeats_valid); // @[Fragmenter.scala 173:33]
  assign auto_out_w_bits_data = in_w_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_bits_strb = in_w_deq_io_deq_bits_strb; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_b_ready = auto_in_b_ready | ~auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 189:33]
  assign auto_out_ar_valid = deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_ar_bits_id = deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_addr = ~_out_bits_addr_T_5; // @[Fragmenter.scala 122:26]
  assign auto_out_ar_bits_echo_real_last = 8'h0 == len; // @[Fragmenter.scala 110:27]
  assign auto_out_r_ready = auto_in_r_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_clock = clock;
  assign deq_reset = reset;
  assign deq_io_enq_valid = auto_in_ar_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_id = auto_in_ar_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_len = auto_in_ar_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_size = auto_in_ar_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_burst = auto_in_ar_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_deq_ready = auto_out_ar_ready & ar_last; // @[Fragmenter.scala 111:30]
  assign deq_1_clock = clock;
  assign deq_1_reset = reset;
  assign deq_1_io_enq_valid = auto_in_aw_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_id = auto_in_aw_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_len = auto_in_aw_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_size = auto_in_aw_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_burst = auto_in_aw_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_deq_ready = in_aw_ready & aw_last; // @[Fragmenter.scala 111:30]
  assign in_w_deq_clock = clock;
  assign in_w_deq_reset = reset;
  assign in_w_deq_io_enq_valid = auto_in_w_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_last = auto_in_w_bits_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_deq_ready = auto_out_w_ready & _bundleOut_0_w_valid_T_1; // @[Fragmenter.scala 174:33]
  always @(posedge clock) begin
    if (reset) begin // @[Fragmenter.scala 60:29]
      busy <= 1'h0; // @[Fragmenter.scala 60:29]
    end else if (_T_2) begin // @[Fragmenter.scala 124:27]
      busy <= ~ar_last; // @[Fragmenter.scala 125:16]
    end
    if (_T_2) begin // @[Fragmenter.scala 124:27]
      if (fixed) begin // @[Fragmenter.scala 106:60]
        r_addr <= irr_bits_addr; // @[Fragmenter.scala 107:20]
      end else if (irr_bits_burst == 2'h2) begin // @[Fragmenter.scala 103:59]
        r_addr <= _mux_addr_T_4; // @[Fragmenter.scala 104:20]
      end else begin
        r_addr <= inc_addr;
      end
    end
    r_len <= _GEN_4[7:0];
    if (reset) begin // @[Fragmenter.scala 60:29]
      busy_1 <= 1'h0; // @[Fragmenter.scala 60:29]
    end else if (_T_5) begin // @[Fragmenter.scala 124:27]
      busy_1 <= ~aw_last; // @[Fragmenter.scala 125:16]
    end
    if (_T_5) begin // @[Fragmenter.scala 124:27]
      if (fixed_1) begin // @[Fragmenter.scala 106:60]
        r_addr_1 <= irr_1_bits_addr; // @[Fragmenter.scala 107:20]
      end else if (irr_1_bits_burst == 2'h2) begin // @[Fragmenter.scala 103:59]
        r_addr_1 <= _mux_addr_T_9; // @[Fragmenter.scala 104:20]
      end else begin
        r_addr_1 <= inc_addr_1;
      end
    end
    r_len_1 <= _GEN_9[7:0];
    if (reset) begin // @[Fragmenter.scala 164:30]
      w_counter <= 9'h0; // @[Fragmenter.scala 164:30]
    end else begin
      w_counter <= _w_counter_T_2; // @[Fragmenter.scala 168:17]
    end
    if (reset) begin // @[Fragmenter.scala 150:35]
      wbeats_latched <= 1'h0; // @[Fragmenter.scala 150:35]
    end else if (_T_7) begin // @[Fragmenter.scala 154:28]
      wbeats_latched <= 1'h0; // @[Fragmenter.scala 154:45]
    end else begin
      wbeats_latched <= _GEN_10;
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_0 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[0] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_0 <= 2'h0;
      end else begin
        error_0 <= _error_0_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_1 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[1] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_1 <= 2'h0;
      end else begin
        error_1 <= _error_1_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_2 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[2] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_2 <= 2'h0;
      end else begin
        error_2 <= _error_2_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_3 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[3] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_3 <= 2'h0;
      end else begin
        error_3 <= _error_3_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_4 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[4] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_4 <= 2'h0;
      end else begin
        error_4 <= _error_4_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_5 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[5] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_5 <= 2'h0;
      end else begin
        error_5 <= _error_5_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_6 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[6] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_6 <= 2'h0;
      end else begin
        error_6 <= _error_6_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_7 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[7] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_7 <= 2'h0;
      end else begin
        error_7 <= _error_7_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_8 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[8] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_8 <= 2'h0;
      end else begin
        error_8 <= _error_8_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_9 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[9] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_9 <= 2'h0;
      end else begin
        error_9 <= _error_9_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_10 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[10] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_10 <= 2'h0;
      end else begin
        error_10 <= _error_10_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_11 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[11] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_11 <= 2'h0;
      end else begin
        error_11 <= _error_11_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_12 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[12] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_12 <= 2'h0;
      end else begin
        error_12 <= _error_12_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_13 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[13] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_13 <= 2'h0;
      end else begin
        error_13 <= _error_13_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_14 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[14] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_14 <= 2'h0;
      end else begin
        error_14 <= _error_14_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_15 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[15] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_15 <= 2'h0;
      end else begin
        error_15 <= _error_15_T;
      end
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_w_counter_T | w_todo != 9'h0 | reset)) begin
          $fwrite(32'h80000002,
            "Assertion failed\n    at Fragmenter.scala:169 assert (!out.w.fire() || w_todo =/= UInt(0)) // underflow impossible\n"
            ); // @[Fragmenter.scala 169:14]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_w_counter_T | w_todo != 9'h0 | reset)) begin
          $fatal; // @[Fragmenter.scala 169:14]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~bundleOut_0_w_valid | ~in_w_bits_last | w_last | reset)) begin
          $fwrite(32'h80000002,
            "Assertion failed\n    at Fragmenter.scala:178 assert (!out.w.valid || !in_w.bits.last || w_last)\n"); // @[Fragmenter.scala 178:14]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~bundleOut_0_w_valid | ~in_w_bits_last | w_last | reset)) begin
          $fatal; // @[Fragmenter.scala 178:14]
        end
    `ifdef STOP_COND
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
  busy = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  r_addr = _RAND_1[27:0];
  _RAND_2 = {1{`RANDOM}};
  r_len = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  busy_1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  r_addr_1 = _RAND_4[27:0];
  _RAND_5 = {1{`RANDOM}};
  r_len_1 = _RAND_5[7:0];
  _RAND_6 = {1{`RANDOM}};
  w_counter = _RAND_6[8:0];
  _RAND_7 = {1{`RANDOM}};
  wbeats_latched = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  error_0 = _RAND_8[1:0];
  _RAND_9 = {1{`RANDOM}};
  error_1 = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  error_2 = _RAND_10[1:0];
  _RAND_11 = {1{`RANDOM}};
  error_3 = _RAND_11[1:0];
  _RAND_12 = {1{`RANDOM}};
  error_4 = _RAND_12[1:0];
  _RAND_13 = {1{`RANDOM}};
  error_5 = _RAND_13[1:0];
  _RAND_14 = {1{`RANDOM}};
  error_6 = _RAND_14[1:0];
  _RAND_15 = {1{`RANDOM}};
  error_7 = _RAND_15[1:0];
  _RAND_16 = {1{`RANDOM}};
  error_8 = _RAND_16[1:0];
  _RAND_17 = {1{`RANDOM}};
  error_9 = _RAND_17[1:0];
  _RAND_18 = {1{`RANDOM}};
  error_10 = _RAND_18[1:0];
  _RAND_19 = {1{`RANDOM}};
  error_11 = _RAND_19[1:0];
  _RAND_20 = {1{`RANDOM}};
  error_12 = _RAND_20[1:0];
  _RAND_21 = {1{`RANDOM}};
  error_13 = _RAND_21[1:0];
  _RAND_22 = {1{`RANDOM}};
  error_14 = _RAND_22[1:0];
  _RAND_23 = {1{`RANDOM}};
  error_15 = _RAND_23[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module SimAXIMem_inTestHarness(
  input         clock,
  input         reset,
  output        io_axi4_0_aw_ready,
  input         io_axi4_0_aw_valid,
  input  [3:0]  io_axi4_0_aw_bits_id,
  input  [27:0] io_axi4_0_aw_bits_addr,
  input  [7:0]  io_axi4_0_aw_bits_len,
  input  [2:0]  io_axi4_0_aw_bits_size,
  input  [1:0]  io_axi4_0_aw_bits_burst,
  output        io_axi4_0_w_ready,
  input         io_axi4_0_w_valid,
  input  [63:0] io_axi4_0_w_bits_data,
  input  [7:0]  io_axi4_0_w_bits_strb,
  input         io_axi4_0_w_bits_last,
  input         io_axi4_0_b_ready,
  output        io_axi4_0_b_valid,
  output [3:0]  io_axi4_0_b_bits_id,
  output [1:0]  io_axi4_0_b_bits_resp,
  output        io_axi4_0_ar_ready,
  input         io_axi4_0_ar_valid,
  input  [3:0]  io_axi4_0_ar_bits_id,
  input  [27:0] io_axi4_0_ar_bits_addr,
  input  [7:0]  io_axi4_0_ar_bits_len,
  input  [2:0]  io_axi4_0_ar_bits_size,
  input  [1:0]  io_axi4_0_ar_bits_burst,
  input         io_axi4_0_r_ready,
  output        io_axi4_0_r_valid,
  output [3:0]  io_axi4_0_r_bits_id,
  output [63:0] io_axi4_0_r_bits_data,
  output [1:0]  io_axi4_0_r_bits_resp,
  output        io_axi4_0_r_bits_last
);
  wire  srams_clock; // @[SimAXIMem.scala 16:15]
  wire  srams_reset; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_aw_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_aw_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_auto_in_aw_bits_id; // @[SimAXIMem.scala 16:15]
  wire [27:0] srams_auto_in_aw_bits_addr; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_aw_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_w_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_w_valid; // @[SimAXIMem.scala 16:15]
  wire [63:0] srams_auto_in_w_bits_data; // @[SimAXIMem.scala 16:15]
  wire [7:0] srams_auto_in_w_bits_strb; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_b_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_b_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_auto_in_b_bits_id; // @[SimAXIMem.scala 16:15]
  wire [1:0] srams_auto_in_b_bits_resp; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_b_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_ar_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_ar_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_auto_in_ar_bits_id; // @[SimAXIMem.scala 16:15]
  wire [27:0] srams_auto_in_ar_bits_addr; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_ar_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_r_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_r_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_auto_in_r_bits_id; // @[SimAXIMem.scala 16:15]
  wire [63:0] srams_auto_in_r_bits_data; // @[SimAXIMem.scala 16:15]
  wire [1:0] srams_auto_in_r_bits_resp; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_r_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  axi4xbar_clock; // @[Xbar.scala 218:30]
  wire  axi4xbar_reset; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_aw_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_aw_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_in_aw_bits_id; // @[Xbar.scala 218:30]
  wire [27:0] axi4xbar_auto_in_aw_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_in_aw_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_in_aw_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_in_aw_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_w_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_w_valid; // @[Xbar.scala 218:30]
  wire [63:0] axi4xbar_auto_in_w_bits_data; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_in_w_bits_strb; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_w_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_b_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_b_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_in_b_bits_id; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_in_b_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_ar_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_ar_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_in_ar_bits_id; // @[Xbar.scala 218:30]
  wire [27:0] axi4xbar_auto_in_ar_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_in_ar_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_in_ar_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_in_ar_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_r_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_r_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_in_r_bits_id; // @[Xbar.scala 218:30]
  wire [63:0] axi4xbar_auto_in_r_bits_data; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_in_r_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_r_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_aw_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_aw_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_aw_bits_id; // @[Xbar.scala 218:30]
  wire [27:0] axi4xbar_auto_out_aw_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_aw_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_out_aw_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_aw_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_w_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_w_valid; // @[Xbar.scala 218:30]
  wire [63:0] axi4xbar_auto_out_w_bits_data; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_w_bits_strb; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_w_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_b_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_b_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_b_bits_id; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_b_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_ar_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_ar_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_ar_bits_id; // @[Xbar.scala 218:30]
  wire [27:0] axi4xbar_auto_out_ar_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_ar_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_out_ar_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_ar_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_r_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_r_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_r_bits_id; // @[Xbar.scala 218:30]
  wire [63:0] axi4xbar_auto_out_r_bits_data; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_r_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_r_bits_last; // @[Xbar.scala 218:30]
  wire  axi4buf_clock; // @[Buffer.scala 58:29]
  wire  axi4buf_reset; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_aw_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_aw_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_in_aw_bits_id; // @[Buffer.scala 58:29]
  wire [27:0] axi4buf_auto_in_aw_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_aw_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_w_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_w_valid; // @[Buffer.scala 58:29]
  wire [63:0] axi4buf_auto_in_w_bits_data; // @[Buffer.scala 58:29]
  wire [7:0] axi4buf_auto_in_w_bits_strb; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_b_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_b_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_in_b_bits_id; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_auto_in_b_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_b_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_ar_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_ar_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_in_ar_bits_id; // @[Buffer.scala 58:29]
  wire [27:0] axi4buf_auto_in_ar_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_ar_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_r_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_r_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_in_r_bits_id; // @[Buffer.scala 58:29]
  wire [63:0] axi4buf_auto_in_r_bits_data; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_auto_in_r_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_r_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_r_bits_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_aw_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_aw_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_out_aw_bits_id; // @[Buffer.scala 58:29]
  wire [27:0] axi4buf_auto_out_aw_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_aw_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_w_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_w_valid; // @[Buffer.scala 58:29]
  wire [63:0] axi4buf_auto_out_w_bits_data; // @[Buffer.scala 58:29]
  wire [7:0] axi4buf_auto_out_w_bits_strb; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_b_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_b_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_out_b_bits_id; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_auto_out_b_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_b_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_ar_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_ar_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_out_ar_bits_id; // @[Buffer.scala 58:29]
  wire [27:0] axi4buf_auto_out_ar_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_ar_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_r_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_r_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_out_r_bits_id; // @[Buffer.scala 58:29]
  wire [63:0] axi4buf_auto_out_r_bits_data; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_auto_out_r_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_r_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4frag_clock; // @[Fragmenter.scala 205:30]
  wire  axi4frag_reset; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_aw_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_aw_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_in_aw_bits_id; // @[Fragmenter.scala 205:30]
  wire [27:0] axi4frag_auto_in_aw_bits_addr; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_auto_in_aw_bits_len; // @[Fragmenter.scala 205:30]
  wire [2:0] axi4frag_auto_in_aw_bits_size; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_in_aw_bits_burst; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_w_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_w_valid; // @[Fragmenter.scala 205:30]
  wire [63:0] axi4frag_auto_in_w_bits_data; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_auto_in_w_bits_strb; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_w_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_b_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_b_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_in_b_bits_id; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_in_b_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_ar_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_ar_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_in_ar_bits_id; // @[Fragmenter.scala 205:30]
  wire [27:0] axi4frag_auto_in_ar_bits_addr; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_auto_in_ar_bits_len; // @[Fragmenter.scala 205:30]
  wire [2:0] axi4frag_auto_in_ar_bits_size; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_in_ar_bits_burst; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_r_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_r_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_in_r_bits_id; // @[Fragmenter.scala 205:30]
  wire [63:0] axi4frag_auto_in_r_bits_data; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_in_r_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_r_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_aw_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_aw_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_out_aw_bits_id; // @[Fragmenter.scala 205:30]
  wire [27:0] axi4frag_auto_out_aw_bits_addr; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_aw_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_w_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_w_valid; // @[Fragmenter.scala 205:30]
  wire [63:0] axi4frag_auto_out_w_bits_data; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_auto_out_w_bits_strb; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_b_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_b_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_out_b_bits_id; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_out_b_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_ar_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_ar_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_out_ar_bits_id; // @[Fragmenter.scala 205:30]
  wire [27:0] axi4frag_auto_out_ar_bits_addr; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_ar_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_r_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_r_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_out_r_bits_id; // @[Fragmenter.scala 205:30]
  wire [63:0] axi4frag_auto_out_r_bits_data; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_out_r_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_r_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_r_bits_last; // @[Fragmenter.scala 205:30]
  AXI4RAM_inTestHarness srams ( // @[SimAXIMem.scala 16:15]
    .clock(srams_clock),
    .reset(srams_reset),
    .auto_in_aw_ready(srams_auto_in_aw_ready),
    .auto_in_aw_valid(srams_auto_in_aw_valid),
    .auto_in_aw_bits_id(srams_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(srams_auto_in_aw_bits_addr),
    .auto_in_aw_bits_echo_real_last(srams_auto_in_aw_bits_echo_real_last),
    .auto_in_w_ready(srams_auto_in_w_ready),
    .auto_in_w_valid(srams_auto_in_w_valid),
    .auto_in_w_bits_data(srams_auto_in_w_bits_data),
    .auto_in_w_bits_strb(srams_auto_in_w_bits_strb),
    .auto_in_b_ready(srams_auto_in_b_ready),
    .auto_in_b_valid(srams_auto_in_b_valid),
    .auto_in_b_bits_id(srams_auto_in_b_bits_id),
    .auto_in_b_bits_resp(srams_auto_in_b_bits_resp),
    .auto_in_b_bits_echo_real_last(srams_auto_in_b_bits_echo_real_last),
    .auto_in_ar_ready(srams_auto_in_ar_ready),
    .auto_in_ar_valid(srams_auto_in_ar_valid),
    .auto_in_ar_bits_id(srams_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(srams_auto_in_ar_bits_addr),
    .auto_in_ar_bits_echo_real_last(srams_auto_in_ar_bits_echo_real_last),
    .auto_in_r_ready(srams_auto_in_r_ready),
    .auto_in_r_valid(srams_auto_in_r_valid),
    .auto_in_r_bits_id(srams_auto_in_r_bits_id),
    .auto_in_r_bits_data(srams_auto_in_r_bits_data),
    .auto_in_r_bits_resp(srams_auto_in_r_bits_resp),
    .auto_in_r_bits_echo_real_last(srams_auto_in_r_bits_echo_real_last)
  );
  AXI4Xbar_inTestHarness axi4xbar ( // @[Xbar.scala 218:30]
    .clock(axi4xbar_clock),
    .reset(axi4xbar_reset),
    .auto_in_aw_ready(axi4xbar_auto_in_aw_ready),
    .auto_in_aw_valid(axi4xbar_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4xbar_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4xbar_auto_in_aw_bits_addr),
    .auto_in_aw_bits_len(axi4xbar_auto_in_aw_bits_len),
    .auto_in_aw_bits_size(axi4xbar_auto_in_aw_bits_size),
    .auto_in_aw_bits_burst(axi4xbar_auto_in_aw_bits_burst),
    .auto_in_w_ready(axi4xbar_auto_in_w_ready),
    .auto_in_w_valid(axi4xbar_auto_in_w_valid),
    .auto_in_w_bits_data(axi4xbar_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4xbar_auto_in_w_bits_strb),
    .auto_in_w_bits_last(axi4xbar_auto_in_w_bits_last),
    .auto_in_b_ready(axi4xbar_auto_in_b_ready),
    .auto_in_b_valid(axi4xbar_auto_in_b_valid),
    .auto_in_b_bits_id(axi4xbar_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4xbar_auto_in_b_bits_resp),
    .auto_in_ar_ready(axi4xbar_auto_in_ar_ready),
    .auto_in_ar_valid(axi4xbar_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4xbar_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4xbar_auto_in_ar_bits_addr),
    .auto_in_ar_bits_len(axi4xbar_auto_in_ar_bits_len),
    .auto_in_ar_bits_size(axi4xbar_auto_in_ar_bits_size),
    .auto_in_ar_bits_burst(axi4xbar_auto_in_ar_bits_burst),
    .auto_in_r_ready(axi4xbar_auto_in_r_ready),
    .auto_in_r_valid(axi4xbar_auto_in_r_valid),
    .auto_in_r_bits_id(axi4xbar_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4xbar_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4xbar_auto_in_r_bits_resp),
    .auto_in_r_bits_last(axi4xbar_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4xbar_auto_out_aw_ready),
    .auto_out_aw_valid(axi4xbar_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4xbar_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4xbar_auto_out_aw_bits_addr),
    .auto_out_aw_bits_len(axi4xbar_auto_out_aw_bits_len),
    .auto_out_aw_bits_size(axi4xbar_auto_out_aw_bits_size),
    .auto_out_aw_bits_burst(axi4xbar_auto_out_aw_bits_burst),
    .auto_out_w_ready(axi4xbar_auto_out_w_ready),
    .auto_out_w_valid(axi4xbar_auto_out_w_valid),
    .auto_out_w_bits_data(axi4xbar_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4xbar_auto_out_w_bits_strb),
    .auto_out_w_bits_last(axi4xbar_auto_out_w_bits_last),
    .auto_out_b_ready(axi4xbar_auto_out_b_ready),
    .auto_out_b_valid(axi4xbar_auto_out_b_valid),
    .auto_out_b_bits_id(axi4xbar_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4xbar_auto_out_b_bits_resp),
    .auto_out_ar_ready(axi4xbar_auto_out_ar_ready),
    .auto_out_ar_valid(axi4xbar_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4xbar_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4xbar_auto_out_ar_bits_addr),
    .auto_out_ar_bits_len(axi4xbar_auto_out_ar_bits_len),
    .auto_out_ar_bits_size(axi4xbar_auto_out_ar_bits_size),
    .auto_out_ar_bits_burst(axi4xbar_auto_out_ar_bits_burst),
    .auto_out_r_ready(axi4xbar_auto_out_r_ready),
    .auto_out_r_valid(axi4xbar_auto_out_r_valid),
    .auto_out_r_bits_id(axi4xbar_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4xbar_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4xbar_auto_out_r_bits_resp),
    .auto_out_r_bits_last(axi4xbar_auto_out_r_bits_last)
  );
  AXI4Buffer_1_inTestHarness axi4buf ( // @[Buffer.scala 58:29]
    .clock(axi4buf_clock),
    .reset(axi4buf_reset),
    .auto_in_aw_ready(axi4buf_auto_in_aw_ready),
    .auto_in_aw_valid(axi4buf_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4buf_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4buf_auto_in_aw_bits_addr),
    .auto_in_aw_bits_echo_real_last(axi4buf_auto_in_aw_bits_echo_real_last),
    .auto_in_w_ready(axi4buf_auto_in_w_ready),
    .auto_in_w_valid(axi4buf_auto_in_w_valid),
    .auto_in_w_bits_data(axi4buf_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4buf_auto_in_w_bits_strb),
    .auto_in_b_ready(axi4buf_auto_in_b_ready),
    .auto_in_b_valid(axi4buf_auto_in_b_valid),
    .auto_in_b_bits_id(axi4buf_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4buf_auto_in_b_bits_resp),
    .auto_in_b_bits_echo_real_last(axi4buf_auto_in_b_bits_echo_real_last),
    .auto_in_ar_ready(axi4buf_auto_in_ar_ready),
    .auto_in_ar_valid(axi4buf_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4buf_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4buf_auto_in_ar_bits_addr),
    .auto_in_ar_bits_echo_real_last(axi4buf_auto_in_ar_bits_echo_real_last),
    .auto_in_r_ready(axi4buf_auto_in_r_ready),
    .auto_in_r_valid(axi4buf_auto_in_r_valid),
    .auto_in_r_bits_id(axi4buf_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4buf_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4buf_auto_in_r_bits_resp),
    .auto_in_r_bits_echo_real_last(axi4buf_auto_in_r_bits_echo_real_last),
    .auto_in_r_bits_last(axi4buf_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4buf_auto_out_aw_ready),
    .auto_out_aw_valid(axi4buf_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4buf_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4buf_auto_out_aw_bits_addr),
    .auto_out_aw_bits_echo_real_last(axi4buf_auto_out_aw_bits_echo_real_last),
    .auto_out_w_ready(axi4buf_auto_out_w_ready),
    .auto_out_w_valid(axi4buf_auto_out_w_valid),
    .auto_out_w_bits_data(axi4buf_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4buf_auto_out_w_bits_strb),
    .auto_out_b_ready(axi4buf_auto_out_b_ready),
    .auto_out_b_valid(axi4buf_auto_out_b_valid),
    .auto_out_b_bits_id(axi4buf_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4buf_auto_out_b_bits_resp),
    .auto_out_b_bits_echo_real_last(axi4buf_auto_out_b_bits_echo_real_last),
    .auto_out_ar_ready(axi4buf_auto_out_ar_ready),
    .auto_out_ar_valid(axi4buf_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4buf_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4buf_auto_out_ar_bits_addr),
    .auto_out_ar_bits_echo_real_last(axi4buf_auto_out_ar_bits_echo_real_last),
    .auto_out_r_ready(axi4buf_auto_out_r_ready),
    .auto_out_r_valid(axi4buf_auto_out_r_valid),
    .auto_out_r_bits_id(axi4buf_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4buf_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4buf_auto_out_r_bits_resp),
    .auto_out_r_bits_echo_real_last(axi4buf_auto_out_r_bits_echo_real_last)
  );
  AXI4Fragmenter_1_inTestHarness axi4frag ( // @[Fragmenter.scala 205:30]
    .clock(axi4frag_clock),
    .reset(axi4frag_reset),
    .auto_in_aw_ready(axi4frag_auto_in_aw_ready),
    .auto_in_aw_valid(axi4frag_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4frag_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4frag_auto_in_aw_bits_addr),
    .auto_in_aw_bits_len(axi4frag_auto_in_aw_bits_len),
    .auto_in_aw_bits_size(axi4frag_auto_in_aw_bits_size),
    .auto_in_aw_bits_burst(axi4frag_auto_in_aw_bits_burst),
    .auto_in_w_ready(axi4frag_auto_in_w_ready),
    .auto_in_w_valid(axi4frag_auto_in_w_valid),
    .auto_in_w_bits_data(axi4frag_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4frag_auto_in_w_bits_strb),
    .auto_in_w_bits_last(axi4frag_auto_in_w_bits_last),
    .auto_in_b_ready(axi4frag_auto_in_b_ready),
    .auto_in_b_valid(axi4frag_auto_in_b_valid),
    .auto_in_b_bits_id(axi4frag_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4frag_auto_in_b_bits_resp),
    .auto_in_ar_ready(axi4frag_auto_in_ar_ready),
    .auto_in_ar_valid(axi4frag_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4frag_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4frag_auto_in_ar_bits_addr),
    .auto_in_ar_bits_len(axi4frag_auto_in_ar_bits_len),
    .auto_in_ar_bits_size(axi4frag_auto_in_ar_bits_size),
    .auto_in_ar_bits_burst(axi4frag_auto_in_ar_bits_burst),
    .auto_in_r_ready(axi4frag_auto_in_r_ready),
    .auto_in_r_valid(axi4frag_auto_in_r_valid),
    .auto_in_r_bits_id(axi4frag_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4frag_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4frag_auto_in_r_bits_resp),
    .auto_in_r_bits_last(axi4frag_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4frag_auto_out_aw_ready),
    .auto_out_aw_valid(axi4frag_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4frag_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4frag_auto_out_aw_bits_addr),
    .auto_out_aw_bits_echo_real_last(axi4frag_auto_out_aw_bits_echo_real_last),
    .auto_out_w_ready(axi4frag_auto_out_w_ready),
    .auto_out_w_valid(axi4frag_auto_out_w_valid),
    .auto_out_w_bits_data(axi4frag_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4frag_auto_out_w_bits_strb),
    .auto_out_b_ready(axi4frag_auto_out_b_ready),
    .auto_out_b_valid(axi4frag_auto_out_b_valid),
    .auto_out_b_bits_id(axi4frag_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4frag_auto_out_b_bits_resp),
    .auto_out_b_bits_echo_real_last(axi4frag_auto_out_b_bits_echo_real_last),
    .auto_out_ar_ready(axi4frag_auto_out_ar_ready),
    .auto_out_ar_valid(axi4frag_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4frag_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4frag_auto_out_ar_bits_addr),
    .auto_out_ar_bits_echo_real_last(axi4frag_auto_out_ar_bits_echo_real_last),
    .auto_out_r_ready(axi4frag_auto_out_r_ready),
    .auto_out_r_valid(axi4frag_auto_out_r_valid),
    .auto_out_r_bits_id(axi4frag_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4frag_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4frag_auto_out_r_bits_resp),
    .auto_out_r_bits_echo_real_last(axi4frag_auto_out_r_bits_echo_real_last),
    .auto_out_r_bits_last(axi4frag_auto_out_r_bits_last)
  );
  assign io_axi4_0_aw_ready = axi4xbar_auto_in_aw_ready; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_w_ready = axi4xbar_auto_in_w_ready; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_b_valid = axi4xbar_auto_in_b_valid; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_b_bits_id = axi4xbar_auto_in_b_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_b_bits_resp = axi4xbar_auto_in_b_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_ar_ready = axi4xbar_auto_in_ar_ready; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_valid = axi4xbar_auto_in_r_valid; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_bits_id = axi4xbar_auto_in_r_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_bits_data = axi4xbar_auto_in_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_bits_resp = axi4xbar_auto_in_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_bits_last = axi4xbar_auto_in_r_bits_last; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign srams_clock = clock;
  assign srams_reset = reset;
  assign srams_auto_in_aw_valid = axi4buf_auto_out_aw_valid; // @[LazyModule.scala 296:16]
  assign srams_auto_in_aw_bits_id = axi4buf_auto_out_aw_bits_id; // @[LazyModule.scala 296:16]
  assign srams_auto_in_aw_bits_addr = axi4buf_auto_out_aw_bits_addr; // @[LazyModule.scala 296:16]
  assign srams_auto_in_aw_bits_echo_real_last = axi4buf_auto_out_aw_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign srams_auto_in_w_valid = axi4buf_auto_out_w_valid; // @[LazyModule.scala 296:16]
  assign srams_auto_in_w_bits_data = axi4buf_auto_out_w_bits_data; // @[LazyModule.scala 296:16]
  assign srams_auto_in_w_bits_strb = axi4buf_auto_out_w_bits_strb; // @[LazyModule.scala 296:16]
  assign srams_auto_in_b_ready = axi4buf_auto_out_b_ready; // @[LazyModule.scala 296:16]
  assign srams_auto_in_ar_valid = axi4buf_auto_out_ar_valid; // @[LazyModule.scala 296:16]
  assign srams_auto_in_ar_bits_id = axi4buf_auto_out_ar_bits_id; // @[LazyModule.scala 296:16]
  assign srams_auto_in_ar_bits_addr = axi4buf_auto_out_ar_bits_addr; // @[LazyModule.scala 296:16]
  assign srams_auto_in_ar_bits_echo_real_last = axi4buf_auto_out_ar_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign srams_auto_in_r_ready = axi4buf_auto_out_r_ready; // @[LazyModule.scala 296:16]
  assign axi4xbar_clock = clock;
  assign axi4xbar_reset = reset;
  assign axi4xbar_auto_in_aw_valid = io_axi4_0_aw_valid; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_id = io_axi4_0_aw_bits_id; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_addr = io_axi4_0_aw_bits_addr; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_len = io_axi4_0_aw_bits_len; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_size = io_axi4_0_aw_bits_size; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_burst = io_axi4_0_aw_bits_burst; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_w_valid = io_axi4_0_w_valid; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_w_bits_data = io_axi4_0_w_bits_data; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_w_bits_strb = io_axi4_0_w_bits_strb; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_w_bits_last = io_axi4_0_w_bits_last; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_b_ready = io_axi4_0_b_ready; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_valid = io_axi4_0_ar_valid; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_id = io_axi4_0_ar_bits_id; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_addr = io_axi4_0_ar_bits_addr; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_len = io_axi4_0_ar_bits_len; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_size = io_axi4_0_ar_bits_size; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_burst = io_axi4_0_ar_bits_burst; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_r_ready = io_axi4_0_r_ready; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_out_aw_ready = axi4frag_auto_in_aw_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_w_ready = axi4frag_auto_in_w_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_b_valid = axi4frag_auto_in_b_valid; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_b_bits_id = axi4frag_auto_in_b_bits_id; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_b_bits_resp = axi4frag_auto_in_b_bits_resp; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_ar_ready = axi4frag_auto_in_ar_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_r_valid = axi4frag_auto_in_r_valid; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_r_bits_id = axi4frag_auto_in_r_bits_id; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_r_bits_data = axi4frag_auto_in_r_bits_data; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_r_bits_resp = axi4frag_auto_in_r_bits_resp; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_r_bits_last = axi4frag_auto_in_r_bits_last; // @[LazyModule.scala 298:16]
  assign axi4buf_clock = clock;
  assign axi4buf_reset = reset;
  assign axi4buf_auto_in_aw_valid = axi4frag_auto_out_aw_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_aw_bits_id = axi4frag_auto_out_aw_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_aw_bits_addr = axi4frag_auto_out_aw_bits_addr; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_aw_bits_echo_real_last = axi4frag_auto_out_aw_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_w_valid = axi4frag_auto_out_w_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_w_bits_data = axi4frag_auto_out_w_bits_data; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_w_bits_strb = axi4frag_auto_out_w_bits_strb; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_b_ready = axi4frag_auto_out_b_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_ar_valid = axi4frag_auto_out_ar_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_ar_bits_id = axi4frag_auto_out_ar_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_ar_bits_addr = axi4frag_auto_out_ar_bits_addr; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_ar_bits_echo_real_last = axi4frag_auto_out_ar_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_r_ready = axi4frag_auto_out_r_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_aw_ready = srams_auto_in_aw_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_w_ready = srams_auto_in_w_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_b_valid = srams_auto_in_b_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_b_bits_id = srams_auto_in_b_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_b_bits_resp = srams_auto_in_b_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_b_bits_echo_real_last = srams_auto_in_b_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_ar_ready = srams_auto_in_ar_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_valid = srams_auto_in_r_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_bits_id = srams_auto_in_r_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_bits_data = srams_auto_in_r_bits_data; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_bits_resp = srams_auto_in_r_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_bits_echo_real_last = srams_auto_in_r_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_clock = clock;
  assign axi4frag_reset = reset;
  assign axi4frag_auto_in_aw_valid = axi4xbar_auto_out_aw_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_id = axi4xbar_auto_out_aw_bits_id; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_addr = axi4xbar_auto_out_aw_bits_addr; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_len = axi4xbar_auto_out_aw_bits_len; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_size = axi4xbar_auto_out_aw_bits_size; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_burst = axi4xbar_auto_out_aw_bits_burst; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_w_valid = axi4xbar_auto_out_w_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_w_bits_data = axi4xbar_auto_out_w_bits_data; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_w_bits_strb = axi4xbar_auto_out_w_bits_strb; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_w_bits_last = axi4xbar_auto_out_w_bits_last; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_b_ready = axi4xbar_auto_out_b_ready; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_valid = axi4xbar_auto_out_ar_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_id = axi4xbar_auto_out_ar_bits_id; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_addr = axi4xbar_auto_out_ar_bits_addr; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_len = axi4xbar_auto_out_ar_bits_len; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_size = axi4xbar_auto_out_ar_bits_size; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_burst = axi4xbar_auto_out_ar_bits_burst; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_r_ready = axi4xbar_auto_out_r_ready; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_out_aw_ready = axi4buf_auto_in_aw_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_w_ready = axi4buf_auto_in_w_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_b_valid = axi4buf_auto_in_b_valid; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_b_bits_id = axi4buf_auto_in_b_bits_id; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_b_bits_resp = axi4buf_auto_in_b_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_b_bits_echo_real_last = axi4buf_auto_in_b_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_ar_ready = axi4buf_auto_in_ar_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_valid = axi4buf_auto_in_r_valid; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_id = axi4buf_auto_in_r_bits_id; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_data = axi4buf_auto_in_r_bits_data; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_resp = axi4buf_auto_in_r_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_echo_real_last = axi4buf_auto_in_r_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_last = axi4buf_auto_in_r_bits_last; // @[LazyModule.scala 296:16]
endmodule
module AXI4RAM_1_inTestHarness(
  input          clock,
  input          reset,
  output         auto_in_aw_ready,
  input          auto_in_aw_valid,
  input  [3:0]   auto_in_aw_bits_id,
  input  [30:0]  auto_in_aw_bits_addr,
  input          auto_in_aw_bits_echo_real_last,
  output         auto_in_w_ready,
  input          auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_b_ready,
  output         auto_in_b_valid,
  output [3:0]   auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output         auto_in_b_bits_echo_real_last,
  output         auto_in_ar_ready,
  input          auto_in_ar_valid,
  input  [3:0]   auto_in_ar_bits_id,
  input  [30:0]  auto_in_ar_bits_addr,
  input          auto_in_ar_bits_echo_real_last,
  input          auto_in_r_ready,
  output         auto_in_r_valid,
  output [3:0]   auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output         auto_in_r_bits_echo_real_last
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
`endif // RANDOMIZE_REG_INIT
  wire [26:0] mem_R0_addr; // @[DescribedSRAM.scala 19:26]
  wire  mem_R0_en; // @[DescribedSRAM.scala 19:26]
  wire  mem_R0_clk; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_0; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_1; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_2; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_3; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_4; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_5; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_6; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_7; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_8; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_9; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_10; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_11; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_12; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_13; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_14; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_15; // @[DescribedSRAM.scala 19:26]
  wire [26:0] mem_W0_addr; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_en; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_clk; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_0; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_1; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_2; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_3; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_4; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_5; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_6; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_7; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_8; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_9; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_10; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_11; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_12; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_13; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_14; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_15; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_0; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_1; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_2; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_3; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_4; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_5; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_6; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_7; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_8; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_9; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_10; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_11; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_12; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_13; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_14; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_15; // @[DescribedSRAM.scala 19:26]
  wire  r_addr_lo_lo_lo_lo = auto_in_ar_bits_addr[4]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_lo_hi_lo = auto_in_ar_bits_addr[5]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_lo_hi_hi = auto_in_ar_bits_addr[6]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_lo = auto_in_ar_bits_addr[7]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_hi_lo = auto_in_ar_bits_addr[8]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_hi_hi = auto_in_ar_bits_addr[9]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_lo = auto_in_ar_bits_addr[10]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_hi_lo = auto_in_ar_bits_addr[11]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_hi_hi = auto_in_ar_bits_addr[12]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_lo_lo = auto_in_ar_bits_addr[13]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_lo_hi = auto_in_ar_bits_addr[14]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_hi_lo = auto_in_ar_bits_addr[15]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_hi_hi = auto_in_ar_bits_addr[16]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_lo = auto_in_ar_bits_addr[17]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_hi_lo = auto_in_ar_bits_addr[18]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_hi_hi = auto_in_ar_bits_addr[19]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_lo_lo = auto_in_ar_bits_addr[20]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_lo_hi = auto_in_ar_bits_addr[21]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_hi_lo = auto_in_ar_bits_addr[22]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_hi_hi = auto_in_ar_bits_addr[23]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_lo = auto_in_ar_bits_addr[24]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_hi_lo = auto_in_ar_bits_addr[25]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_hi_hi = auto_in_ar_bits_addr[26]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_lo_lo = auto_in_ar_bits_addr[27]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_lo_hi = auto_in_ar_bits_addr[28]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_hi_lo = auto_in_ar_bits_addr[29]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_hi_hi = auto_in_ar_bits_addr[30]; // @[SRAM.scala 65:73]
  wire [5:0] r_addr_lo_lo = {r_addr_lo_lo_hi_hi_hi,r_addr_lo_lo_hi_hi_lo,r_addr_lo_lo_hi_lo,r_addr_lo_lo_lo_hi_hi,
    r_addr_lo_lo_lo_hi_lo,r_addr_lo_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] r_addr_lo = {r_addr_lo_hi_hi_hi_hi,r_addr_lo_hi_hi_hi_lo,r_addr_lo_hi_hi_lo_hi,r_addr_lo_hi_hi_lo_lo,
    r_addr_lo_hi_lo_hi_hi,r_addr_lo_hi_lo_hi_lo,r_addr_lo_hi_lo_lo,r_addr_lo_lo}; // @[Cat.scala 30:58]
  wire [6:0] r_addr_hi_lo = {r_addr_hi_lo_hi_hi_hi,r_addr_hi_lo_hi_hi_lo,r_addr_hi_lo_hi_lo_hi,r_addr_hi_lo_hi_lo_lo,
    r_addr_hi_lo_lo_hi_hi,r_addr_hi_lo_lo_hi_lo,r_addr_hi_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [13:0] r_addr_hi = {r_addr_hi_hi_hi_hi_hi,r_addr_hi_hi_hi_hi_lo,r_addr_hi_hi_hi_lo_hi,r_addr_hi_hi_hi_lo_lo,
    r_addr_hi_hi_lo_hi_hi,r_addr_hi_hi_lo_hi_lo,r_addr_hi_hi_lo_lo,r_addr_hi_lo}; // @[Cat.scala 30:58]
  wire  w_addr_lo_lo_lo_lo = auto_in_aw_bits_addr[4]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_lo_hi_lo = auto_in_aw_bits_addr[5]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_lo_hi_hi = auto_in_aw_bits_addr[6]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_lo = auto_in_aw_bits_addr[7]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_hi_lo = auto_in_aw_bits_addr[8]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_hi_hi = auto_in_aw_bits_addr[9]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_lo = auto_in_aw_bits_addr[10]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_hi_lo = auto_in_aw_bits_addr[11]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_hi_hi = auto_in_aw_bits_addr[12]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_lo_lo = auto_in_aw_bits_addr[13]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_lo_hi = auto_in_aw_bits_addr[14]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_hi_lo = auto_in_aw_bits_addr[15]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_hi_hi = auto_in_aw_bits_addr[16]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_lo = auto_in_aw_bits_addr[17]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_hi_lo = auto_in_aw_bits_addr[18]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_hi_hi = auto_in_aw_bits_addr[19]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_lo_lo = auto_in_aw_bits_addr[20]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_lo_hi = auto_in_aw_bits_addr[21]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_hi_lo = auto_in_aw_bits_addr[22]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_hi_hi = auto_in_aw_bits_addr[23]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_lo = auto_in_aw_bits_addr[24]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_hi_lo = auto_in_aw_bits_addr[25]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_hi_hi = auto_in_aw_bits_addr[26]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_lo_lo = auto_in_aw_bits_addr[27]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_lo_hi = auto_in_aw_bits_addr[28]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_hi_lo = auto_in_aw_bits_addr[29]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_hi_hi = auto_in_aw_bits_addr[30]; // @[SRAM.scala 66:73]
  wire [5:0] w_addr_lo_lo = {w_addr_lo_lo_hi_hi_hi,w_addr_lo_lo_hi_hi_lo,w_addr_lo_lo_hi_lo,w_addr_lo_lo_lo_hi_hi,
    w_addr_lo_lo_lo_hi_lo,w_addr_lo_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] w_addr_lo = {w_addr_lo_hi_hi_hi_hi,w_addr_lo_hi_hi_hi_lo,w_addr_lo_hi_hi_lo_hi,w_addr_lo_hi_hi_lo_lo,
    w_addr_lo_hi_lo_hi_hi,w_addr_lo_hi_lo_hi_lo,w_addr_lo_hi_lo_lo,w_addr_lo_lo}; // @[Cat.scala 30:58]
  wire [6:0] w_addr_hi_lo = {w_addr_hi_lo_hi_hi_hi,w_addr_hi_lo_hi_hi_lo,w_addr_hi_lo_hi_lo_hi,w_addr_hi_lo_hi_lo_lo,
    w_addr_hi_lo_lo_hi_hi,w_addr_hi_lo_lo_hi_lo,w_addr_hi_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [13:0] w_addr_hi = {w_addr_hi_hi_hi_hi_hi,w_addr_hi_hi_hi_hi_lo,w_addr_hi_hi_hi_lo_hi,w_addr_hi_hi_hi_lo_lo,
    w_addr_hi_hi_lo_hi_hi,w_addr_hi_hi_lo_hi_lo,w_addr_hi_hi_lo_lo,w_addr_hi_lo}; // @[Cat.scala 30:58]
  wire [31:0] _r_sel0_T_1 = {1'b0,$signed(auto_in_ar_bits_addr)}; // @[Parameters.scala 137:49]
  wire [31:0] _r_sel0_T_3 = $signed(_r_sel0_T_1) & 32'sh80000000; // @[Parameters.scala 137:52]
  wire  r_sel0 = $signed(_r_sel0_T_3) == 32'sh0; // @[Parameters.scala 137:67]
  wire [31:0] _w_sel0_T_1 = {1'b0,$signed(auto_in_aw_bits_addr)}; // @[Parameters.scala 137:49]
  wire [31:0] _w_sel0_T_3 = $signed(_w_sel0_T_1) & 32'sh80000000; // @[Parameters.scala 137:52]
  wire  w_sel0 = $signed(_w_sel0_T_3) == 32'sh0; // @[Parameters.scala 137:67]
  reg  w_full; // @[SRAM.scala 70:25]
  reg [3:0] w_id; // @[SRAM.scala 71:21]
  reg  w_echo_real_last; // @[SRAM.scala 72:21]
  reg  r_sel1; // @[SRAM.scala 73:21]
  reg  w_sel1; // @[SRAM.scala 74:21]
  wire  _T = auto_in_b_ready & w_full; // @[Decoupled.scala 40:37]
  wire  _GEN_0 = _T ? 1'h0 : w_full; // @[SRAM.scala 76:25 SRAM.scala 76:34 SRAM.scala 70:25]
  wire  _bundleIn_0_aw_ready_T_1 = auto_in_b_ready | ~w_full; // @[SRAM.scala 92:47]
  wire  in_aw_ready = auto_in_w_valid & (auto_in_b_ready | ~w_full); // @[SRAM.scala 92:32]
  wire  _T_1 = in_aw_ready & auto_in_aw_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_1 = _T_1 | _GEN_0; // @[SRAM.scala 77:25 SRAM.scala 77:34]
  reg  r_full; // @[SRAM.scala 99:25]
  reg [3:0] r_id; // @[SRAM.scala 100:21]
  reg  r_echo_real_last; // @[SRAM.scala 101:21]
  wire  _T_21 = auto_in_r_ready & r_full; // @[Decoupled.scala 40:37]
  wire  _GEN_72 = _T_21 ? 1'h0 : r_full; // @[SRAM.scala 103:25 SRAM.scala 103:34 SRAM.scala 99:25]
  wire  in_ar_ready = auto_in_r_ready | ~r_full; // @[SRAM.scala 117:31]
  wire  _T_22 = in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_73 = _T_22 | _GEN_72; // @[SRAM.scala 104:25 SRAM.scala 104:34]
  reg  rdata_REG; // @[package.scala 91:91]
  reg [7:0] rdata_r_0; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_1; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_2; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_3; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_4; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_5; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_6; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_7; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_8; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_9; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_10; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_11; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_12; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_13; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_14; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_15; // @[Reg.scala 15:16]
  wire [7:0] _GEN_81 = rdata_REG ? mem_R0_data_0 : rdata_r_0; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_82 = rdata_REG ? mem_R0_data_1 : rdata_r_1; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_83 = rdata_REG ? mem_R0_data_2 : rdata_r_2; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_84 = rdata_REG ? mem_R0_data_3 : rdata_r_3; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_85 = rdata_REG ? mem_R0_data_4 : rdata_r_4; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_86 = rdata_REG ? mem_R0_data_5 : rdata_r_5; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_87 = rdata_REG ? mem_R0_data_6 : rdata_r_6; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_88 = rdata_REG ? mem_R0_data_7 : rdata_r_7; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_89 = rdata_REG ? mem_R0_data_8 : rdata_r_8; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_90 = rdata_REG ? mem_R0_data_9 : rdata_r_9; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_91 = rdata_REG ? mem_R0_data_10 : rdata_r_10; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_92 = rdata_REG ? mem_R0_data_11 : rdata_r_11; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_93 = rdata_REG ? mem_R0_data_12 : rdata_r_12; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_94 = rdata_REG ? mem_R0_data_13 : rdata_r_13; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_95 = rdata_REG ? mem_R0_data_14 : rdata_r_14; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_96 = rdata_REG ? mem_R0_data_15 : rdata_r_15; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [63:0] bundleIn_0_r_bits_data_lo = {_GEN_88,_GEN_87,_GEN_86,_GEN_85,_GEN_84,_GEN_83,_GEN_82,_GEN_81}; // @[Cat.scala 30:58]
  wire [63:0] bundleIn_0_r_bits_data_hi = {_GEN_96,_GEN_95,_GEN_94,_GEN_93,_GEN_92,_GEN_91,_GEN_90,_GEN_89}; // @[Cat.scala 30:58]
  mem_0_inTestHarness mem ( // @[DescribedSRAM.scala 19:26]
    .R0_addr(mem_R0_addr),
    .R0_en(mem_R0_en),
    .R0_clk(mem_R0_clk),
    .R0_data_0(mem_R0_data_0),
    .R0_data_1(mem_R0_data_1),
    .R0_data_2(mem_R0_data_2),
    .R0_data_3(mem_R0_data_3),
    .R0_data_4(mem_R0_data_4),
    .R0_data_5(mem_R0_data_5),
    .R0_data_6(mem_R0_data_6),
    .R0_data_7(mem_R0_data_7),
    .R0_data_8(mem_R0_data_8),
    .R0_data_9(mem_R0_data_9),
    .R0_data_10(mem_R0_data_10),
    .R0_data_11(mem_R0_data_11),
    .R0_data_12(mem_R0_data_12),
    .R0_data_13(mem_R0_data_13),
    .R0_data_14(mem_R0_data_14),
    .R0_data_15(mem_R0_data_15),
    .W0_addr(mem_W0_addr),
    .W0_en(mem_W0_en),
    .W0_clk(mem_W0_clk),
    .W0_data_0(mem_W0_data_0),
    .W0_data_1(mem_W0_data_1),
    .W0_data_2(mem_W0_data_2),
    .W0_data_3(mem_W0_data_3),
    .W0_data_4(mem_W0_data_4),
    .W0_data_5(mem_W0_data_5),
    .W0_data_6(mem_W0_data_6),
    .W0_data_7(mem_W0_data_7),
    .W0_data_8(mem_W0_data_8),
    .W0_data_9(mem_W0_data_9),
    .W0_data_10(mem_W0_data_10),
    .W0_data_11(mem_W0_data_11),
    .W0_data_12(mem_W0_data_12),
    .W0_data_13(mem_W0_data_13),
    .W0_data_14(mem_W0_data_14),
    .W0_data_15(mem_W0_data_15),
    .W0_mask_0(mem_W0_mask_0),
    .W0_mask_1(mem_W0_mask_1),
    .W0_mask_2(mem_W0_mask_2),
    .W0_mask_3(mem_W0_mask_3),
    .W0_mask_4(mem_W0_mask_4),
    .W0_mask_5(mem_W0_mask_5),
    .W0_mask_6(mem_W0_mask_6),
    .W0_mask_7(mem_W0_mask_7),
    .W0_mask_8(mem_W0_mask_8),
    .W0_mask_9(mem_W0_mask_9),
    .W0_mask_10(mem_W0_mask_10),
    .W0_mask_11(mem_W0_mask_11),
    .W0_mask_12(mem_W0_mask_12),
    .W0_mask_13(mem_W0_mask_13),
    .W0_mask_14(mem_W0_mask_14),
    .W0_mask_15(mem_W0_mask_15)
  );
  assign auto_in_aw_ready = auto_in_w_valid & (auto_in_b_ready | ~w_full); // @[SRAM.scala 92:32]
  assign auto_in_w_ready = auto_in_aw_valid & _bundleIn_0_aw_ready_T_1; // @[SRAM.scala 93:32]
  assign auto_in_b_valid = w_full; // @[Nodes.scala 1210:84 SRAM.scala 91:17]
  assign auto_in_b_bits_id = w_id; // @[Nodes.scala 1210:84 SRAM.scala 95:20]
  assign auto_in_b_bits_resp = w_sel1 ? 2'h0 : 2'h3; // @[SRAM.scala 96:26]
  assign auto_in_b_bits_echo_real_last = w_echo_real_last; // @[Nodes.scala 1210:84 BundleMap.scala 247:19]
  assign auto_in_ar_ready = auto_in_r_ready | ~r_full; // @[SRAM.scala 117:31]
  assign auto_in_r_valid = r_full; // @[Nodes.scala 1210:84 SRAM.scala 116:17]
  assign auto_in_r_bits_id = r_id; // @[Nodes.scala 1210:84 SRAM.scala 119:20]
  assign auto_in_r_bits_data = {bundleIn_0_r_bits_data_hi,bundleIn_0_r_bits_data_lo}; // @[Cat.scala 30:58]
  assign auto_in_r_bits_resp = r_sel1 ? 2'h0 : 2'h3; // @[SRAM.scala 120:26]
  assign auto_in_r_bits_echo_real_last = r_echo_real_last; // @[Nodes.scala 1210:84 BundleMap.scala 247:19]
  assign mem_R0_addr = {r_addr_hi,r_addr_lo}; // @[Cat.scala 30:58]
  assign mem_R0_en = in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  assign mem_R0_clk = clock; // @[package.scala 91:58 package.scala 91:58]
  assign mem_W0_addr = {w_addr_hi,w_addr_lo}; // @[Cat.scala 30:58]
  assign mem_W0_en = _T_1 & w_sel0; // @[SRAM.scala 86:24]
  assign mem_W0_clk = clock; // @[SRAM.scala 86:35]
  assign mem_W0_data_0 = auto_in_w_bits_data[7:0]; // @[SRAM.scala 85:62]
  assign mem_W0_data_1 = auto_in_w_bits_data[15:8]; // @[SRAM.scala 85:62]
  assign mem_W0_data_2 = auto_in_w_bits_data[23:16]; // @[SRAM.scala 85:62]
  assign mem_W0_data_3 = auto_in_w_bits_data[31:24]; // @[SRAM.scala 85:62]
  assign mem_W0_data_4 = auto_in_w_bits_data[39:32]; // @[SRAM.scala 85:62]
  assign mem_W0_data_5 = auto_in_w_bits_data[47:40]; // @[SRAM.scala 85:62]
  assign mem_W0_data_6 = auto_in_w_bits_data[55:48]; // @[SRAM.scala 85:62]
  assign mem_W0_data_7 = auto_in_w_bits_data[63:56]; // @[SRAM.scala 85:62]
  assign mem_W0_data_8 = auto_in_w_bits_data[71:64]; // @[SRAM.scala 85:62]
  assign mem_W0_data_9 = auto_in_w_bits_data[79:72]; // @[SRAM.scala 85:62]
  assign mem_W0_data_10 = auto_in_w_bits_data[87:80]; // @[SRAM.scala 85:62]
  assign mem_W0_data_11 = auto_in_w_bits_data[95:88]; // @[SRAM.scala 85:62]
  assign mem_W0_data_12 = auto_in_w_bits_data[103:96]; // @[SRAM.scala 85:62]
  assign mem_W0_data_13 = auto_in_w_bits_data[111:104]; // @[SRAM.scala 85:62]
  assign mem_W0_data_14 = auto_in_w_bits_data[119:112]; // @[SRAM.scala 85:62]
  assign mem_W0_data_15 = auto_in_w_bits_data[127:120]; // @[SRAM.scala 85:62]
  assign mem_W0_mask_0 = auto_in_w_bits_strb[0]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_1 = auto_in_w_bits_strb[1]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_2 = auto_in_w_bits_strb[2]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_3 = auto_in_w_bits_strb[3]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_4 = auto_in_w_bits_strb[4]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_5 = auto_in_w_bits_strb[5]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_6 = auto_in_w_bits_strb[6]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_7 = auto_in_w_bits_strb[7]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_8 = auto_in_w_bits_strb[8]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_9 = auto_in_w_bits_strb[9]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_10 = auto_in_w_bits_strb[10]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_11 = auto_in_w_bits_strb[11]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_12 = auto_in_w_bits_strb[12]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_13 = auto_in_w_bits_strb[13]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_14 = auto_in_w_bits_strb[14]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_15 = auto_in_w_bits_strb[15]; // @[SRAM.scala 87:47]
  always @(posedge clock) begin
    if (reset) begin // @[SRAM.scala 70:25]
      w_full <= 1'h0; // @[SRAM.scala 70:25]
    end else begin
      w_full <= _GEN_1;
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_id <= auto_in_aw_bits_id; // @[SRAM.scala 80:12]
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_echo_real_last <= auto_in_aw_bits_echo_real_last; // @[BundleMap.scala 247:19]
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_sel1 <= r_sel0; // @[SRAM.scala 108:14]
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_sel1 <= w_sel0; // @[SRAM.scala 81:14]
    end
    if (reset) begin // @[SRAM.scala 99:25]
      r_full <= 1'h0; // @[SRAM.scala 99:25]
    end else begin
      r_full <= _GEN_73;
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_id <= auto_in_ar_bits_id; // @[SRAM.scala 107:12]
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_echo_real_last <= auto_in_ar_bits_echo_real_last; // @[BundleMap.scala 247:19]
    end
    rdata_REG <= in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_0 <= mem_R0_data_0; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_1 <= mem_R0_data_1; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_2 <= mem_R0_data_2; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_3 <= mem_R0_data_3; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_4 <= mem_R0_data_4; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_5 <= mem_R0_data_5; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_6 <= mem_R0_data_6; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_7 <= mem_R0_data_7; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_8 <= mem_R0_data_8; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_9 <= mem_R0_data_9; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_10 <= mem_R0_data_10; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_11 <= mem_R0_data_11; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_12 <= mem_R0_data_12; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_13 <= mem_R0_data_13; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_14 <= mem_R0_data_14; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_15 <= mem_R0_data_15; // @[Reg.scala 16:23]
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
  w_full = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  w_id = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  w_echo_real_last = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  r_sel1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  w_sel1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  r_full = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  r_id = _RAND_6[3:0];
  _RAND_7 = {1{`RANDOM}};
  r_echo_real_last = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  rdata_REG = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  rdata_r_0 = _RAND_9[7:0];
  _RAND_10 = {1{`RANDOM}};
  rdata_r_1 = _RAND_10[7:0];
  _RAND_11 = {1{`RANDOM}};
  rdata_r_2 = _RAND_11[7:0];
  _RAND_12 = {1{`RANDOM}};
  rdata_r_3 = _RAND_12[7:0];
  _RAND_13 = {1{`RANDOM}};
  rdata_r_4 = _RAND_13[7:0];
  _RAND_14 = {1{`RANDOM}};
  rdata_r_5 = _RAND_14[7:0];
  _RAND_15 = {1{`RANDOM}};
  rdata_r_6 = _RAND_15[7:0];
  _RAND_16 = {1{`RANDOM}};
  rdata_r_7 = _RAND_16[7:0];
  _RAND_17 = {1{`RANDOM}};
  rdata_r_8 = _RAND_17[7:0];
  _RAND_18 = {1{`RANDOM}};
  rdata_r_9 = _RAND_18[7:0];
  _RAND_19 = {1{`RANDOM}};
  rdata_r_10 = _RAND_19[7:0];
  _RAND_20 = {1{`RANDOM}};
  rdata_r_11 = _RAND_20[7:0];
  _RAND_21 = {1{`RANDOM}};
  rdata_r_12 = _RAND_21[7:0];
  _RAND_22 = {1{`RANDOM}};
  rdata_r_13 = _RAND_22[7:0];
  _RAND_23 = {1{`RANDOM}};
  rdata_r_14 = _RAND_23[7:0];
  _RAND_24 = {1{`RANDOM}};
  rdata_r_15 = _RAND_24[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4RAM_2_inTestHarness(
  input          clock,
  input          reset,
  output         auto_in_aw_ready,
  input          auto_in_aw_valid,
  input  [3:0]   auto_in_aw_bits_id,
  input  [31:0]  auto_in_aw_bits_addr,
  input          auto_in_aw_bits_echo_real_last,
  output         auto_in_w_ready,
  input          auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_b_ready,
  output         auto_in_b_valid,
  output [3:0]   auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output         auto_in_b_bits_echo_real_last,
  output         auto_in_ar_ready,
  input          auto_in_ar_valid,
  input  [3:0]   auto_in_ar_bits_id,
  input  [31:0]  auto_in_ar_bits_addr,
  input          auto_in_ar_bits_echo_real_last,
  input          auto_in_r_ready,
  output         auto_in_r_valid,
  output [3:0]   auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output         auto_in_r_bits_echo_real_last
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
`endif // RANDOMIZE_REG_INIT
  wire [25:0] mem_R0_addr; // @[DescribedSRAM.scala 19:26]
  wire  mem_R0_en; // @[DescribedSRAM.scala 19:26]
  wire  mem_R0_clk; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_0; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_1; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_2; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_3; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_4; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_5; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_6; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_7; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_8; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_9; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_10; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_11; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_12; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_13; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_14; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_15; // @[DescribedSRAM.scala 19:26]
  wire [25:0] mem_W0_addr; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_en; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_clk; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_0; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_1; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_2; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_3; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_4; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_5; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_6; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_7; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_8; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_9; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_10; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_11; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_12; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_13; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_14; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_15; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_0; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_1; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_2; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_3; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_4; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_5; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_6; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_7; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_8; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_9; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_10; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_11; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_12; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_13; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_14; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_15; // @[DescribedSRAM.scala 19:26]
  wire  r_addr_lo_lo_lo_lo = auto_in_ar_bits_addr[4]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_lo_hi_lo = auto_in_ar_bits_addr[5]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_lo_hi_hi = auto_in_ar_bits_addr[6]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_lo = auto_in_ar_bits_addr[7]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_hi_lo = auto_in_ar_bits_addr[8]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_hi_hi = auto_in_ar_bits_addr[9]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_lo = auto_in_ar_bits_addr[10]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_hi_lo = auto_in_ar_bits_addr[11]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_hi_hi = auto_in_ar_bits_addr[12]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_lo_lo = auto_in_ar_bits_addr[13]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_lo_hi = auto_in_ar_bits_addr[14]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_hi_lo = auto_in_ar_bits_addr[15]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_hi_hi = auto_in_ar_bits_addr[16]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_lo = auto_in_ar_bits_addr[17]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_hi_lo = auto_in_ar_bits_addr[18]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_hi_hi = auto_in_ar_bits_addr[19]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_lo = auto_in_ar_bits_addr[20]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_hi_lo = auto_in_ar_bits_addr[21]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_hi_hi = auto_in_ar_bits_addr[22]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_lo = auto_in_ar_bits_addr[23]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_hi_lo = auto_in_ar_bits_addr[24]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_hi_hi = auto_in_ar_bits_addr[25]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_lo_lo = auto_in_ar_bits_addr[26]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_lo_hi = auto_in_ar_bits_addr[27]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_hi_lo = auto_in_ar_bits_addr[28]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_hi_hi = auto_in_ar_bits_addr[29]; // @[SRAM.scala 65:73]
  wire [5:0] r_addr_lo_lo = {r_addr_lo_lo_hi_hi_hi,r_addr_lo_lo_hi_hi_lo,r_addr_lo_lo_hi_lo,r_addr_lo_lo_lo_hi_hi,
    r_addr_lo_lo_lo_hi_lo,r_addr_lo_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] r_addr_lo = {r_addr_lo_hi_hi_hi_hi,r_addr_lo_hi_hi_hi_lo,r_addr_lo_hi_hi_lo_hi,r_addr_lo_hi_hi_lo_lo,
    r_addr_lo_hi_lo_hi_hi,r_addr_lo_hi_lo_hi_lo,r_addr_lo_hi_lo_lo,r_addr_lo_lo}; // @[Cat.scala 30:58]
  wire [5:0] r_addr_hi_lo = {r_addr_hi_lo_hi_hi_hi,r_addr_hi_lo_hi_hi_lo,r_addr_hi_lo_hi_lo,r_addr_hi_lo_lo_hi_hi,
    r_addr_hi_lo_lo_hi_lo,r_addr_hi_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] r_addr_hi = {r_addr_hi_hi_hi_hi_hi,r_addr_hi_hi_hi_hi_lo,r_addr_hi_hi_hi_lo_hi,r_addr_hi_hi_hi_lo_lo,
    r_addr_hi_hi_lo_hi_hi,r_addr_hi_hi_lo_hi_lo,r_addr_hi_hi_lo_lo,r_addr_hi_lo}; // @[Cat.scala 30:58]
  wire  w_addr_lo_lo_lo_lo = auto_in_aw_bits_addr[4]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_lo_hi_lo = auto_in_aw_bits_addr[5]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_lo_hi_hi = auto_in_aw_bits_addr[6]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_lo = auto_in_aw_bits_addr[7]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_hi_lo = auto_in_aw_bits_addr[8]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_hi_hi = auto_in_aw_bits_addr[9]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_lo = auto_in_aw_bits_addr[10]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_hi_lo = auto_in_aw_bits_addr[11]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_hi_hi = auto_in_aw_bits_addr[12]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_lo_lo = auto_in_aw_bits_addr[13]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_lo_hi = auto_in_aw_bits_addr[14]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_hi_lo = auto_in_aw_bits_addr[15]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_hi_hi = auto_in_aw_bits_addr[16]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_lo = auto_in_aw_bits_addr[17]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_hi_lo = auto_in_aw_bits_addr[18]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_hi_hi = auto_in_aw_bits_addr[19]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_lo = auto_in_aw_bits_addr[20]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_hi_lo = auto_in_aw_bits_addr[21]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_hi_hi = auto_in_aw_bits_addr[22]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_lo = auto_in_aw_bits_addr[23]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_hi_lo = auto_in_aw_bits_addr[24]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_hi_hi = auto_in_aw_bits_addr[25]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_lo_lo = auto_in_aw_bits_addr[26]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_lo_hi = auto_in_aw_bits_addr[27]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_hi_lo = auto_in_aw_bits_addr[28]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_hi_hi = auto_in_aw_bits_addr[29]; // @[SRAM.scala 66:73]
  wire [5:0] w_addr_lo_lo = {w_addr_lo_lo_hi_hi_hi,w_addr_lo_lo_hi_hi_lo,w_addr_lo_lo_hi_lo,w_addr_lo_lo_lo_hi_hi,
    w_addr_lo_lo_lo_hi_lo,w_addr_lo_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] w_addr_lo = {w_addr_lo_hi_hi_hi_hi,w_addr_lo_hi_hi_hi_lo,w_addr_lo_hi_hi_lo_hi,w_addr_lo_hi_hi_lo_lo,
    w_addr_lo_hi_lo_hi_hi,w_addr_lo_hi_lo_hi_lo,w_addr_lo_hi_lo_lo,w_addr_lo_lo}; // @[Cat.scala 30:58]
  wire [5:0] w_addr_hi_lo = {w_addr_hi_lo_hi_hi_hi,w_addr_hi_lo_hi_hi_lo,w_addr_hi_lo_hi_lo,w_addr_hi_lo_lo_hi_hi,
    w_addr_hi_lo_lo_hi_lo,w_addr_hi_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] w_addr_hi = {w_addr_hi_hi_hi_hi_hi,w_addr_hi_hi_hi_hi_lo,w_addr_hi_hi_hi_lo_hi,w_addr_hi_hi_hi_lo_lo,
    w_addr_hi_hi_lo_hi_hi,w_addr_hi_hi_lo_hi_lo,w_addr_hi_hi_lo_lo,w_addr_hi_lo}; // @[Cat.scala 30:58]
  wire [31:0] _r_sel0_T = auto_in_ar_bits_addr ^ 32'h80000000; // @[Parameters.scala 137:31]
  wire [32:0] _r_sel0_T_1 = {1'b0,$signed(_r_sel0_T)}; // @[Parameters.scala 137:49]
  wire [32:0] _r_sel0_T_3 = $signed(_r_sel0_T_1) & -33'sh40000000; // @[Parameters.scala 137:52]
  wire  r_sel0 = $signed(_r_sel0_T_3) == 33'sh0; // @[Parameters.scala 137:67]
  wire [31:0] _w_sel0_T = auto_in_aw_bits_addr ^ 32'h80000000; // @[Parameters.scala 137:31]
  wire [32:0] _w_sel0_T_1 = {1'b0,$signed(_w_sel0_T)}; // @[Parameters.scala 137:49]
  wire [32:0] _w_sel0_T_3 = $signed(_w_sel0_T_1) & -33'sh40000000; // @[Parameters.scala 137:52]
  wire  w_sel0 = $signed(_w_sel0_T_3) == 33'sh0; // @[Parameters.scala 137:67]
  reg  w_full; // @[SRAM.scala 70:25]
  reg [3:0] w_id; // @[SRAM.scala 71:21]
  reg  w_echo_real_last; // @[SRAM.scala 72:21]
  reg  r_sel1; // @[SRAM.scala 73:21]
  reg  w_sel1; // @[SRAM.scala 74:21]
  wire  _T = auto_in_b_ready & w_full; // @[Decoupled.scala 40:37]
  wire  _GEN_0 = _T ? 1'h0 : w_full; // @[SRAM.scala 76:25 SRAM.scala 76:34 SRAM.scala 70:25]
  wire  _bundleIn_0_aw_ready_T_1 = auto_in_b_ready | ~w_full; // @[SRAM.scala 92:47]
  wire  in_aw_ready = auto_in_w_valid & (auto_in_b_ready | ~w_full); // @[SRAM.scala 92:32]
  wire  _T_1 = in_aw_ready & auto_in_aw_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_1 = _T_1 | _GEN_0; // @[SRAM.scala 77:25 SRAM.scala 77:34]
  reg  r_full; // @[SRAM.scala 99:25]
  reg [3:0] r_id; // @[SRAM.scala 100:21]
  reg  r_echo_real_last; // @[SRAM.scala 101:21]
  wire  _T_21 = auto_in_r_ready & r_full; // @[Decoupled.scala 40:37]
  wire  _GEN_72 = _T_21 ? 1'h0 : r_full; // @[SRAM.scala 103:25 SRAM.scala 103:34 SRAM.scala 99:25]
  wire  in_ar_ready = auto_in_r_ready | ~r_full; // @[SRAM.scala 117:31]
  wire  _T_22 = in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_73 = _T_22 | _GEN_72; // @[SRAM.scala 104:25 SRAM.scala 104:34]
  reg  rdata_REG; // @[package.scala 91:91]
  reg [7:0] rdata_r_0; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_1; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_2; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_3; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_4; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_5; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_6; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_7; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_8; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_9; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_10; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_11; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_12; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_13; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_14; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_15; // @[Reg.scala 15:16]
  wire [7:0] _GEN_81 = rdata_REG ? mem_R0_data_0 : rdata_r_0; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_82 = rdata_REG ? mem_R0_data_1 : rdata_r_1; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_83 = rdata_REG ? mem_R0_data_2 : rdata_r_2; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_84 = rdata_REG ? mem_R0_data_3 : rdata_r_3; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_85 = rdata_REG ? mem_R0_data_4 : rdata_r_4; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_86 = rdata_REG ? mem_R0_data_5 : rdata_r_5; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_87 = rdata_REG ? mem_R0_data_6 : rdata_r_6; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_88 = rdata_REG ? mem_R0_data_7 : rdata_r_7; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_89 = rdata_REG ? mem_R0_data_8 : rdata_r_8; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_90 = rdata_REG ? mem_R0_data_9 : rdata_r_9; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_91 = rdata_REG ? mem_R0_data_10 : rdata_r_10; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_92 = rdata_REG ? mem_R0_data_11 : rdata_r_11; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_93 = rdata_REG ? mem_R0_data_12 : rdata_r_12; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_94 = rdata_REG ? mem_R0_data_13 : rdata_r_13; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_95 = rdata_REG ? mem_R0_data_14 : rdata_r_14; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_96 = rdata_REG ? mem_R0_data_15 : rdata_r_15; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [63:0] bundleIn_0_r_bits_data_lo = {_GEN_88,_GEN_87,_GEN_86,_GEN_85,_GEN_84,_GEN_83,_GEN_82,_GEN_81}; // @[Cat.scala 30:58]
  wire [63:0] bundleIn_0_r_bits_data_hi = {_GEN_96,_GEN_95,_GEN_94,_GEN_93,_GEN_92,_GEN_91,_GEN_90,_GEN_89}; // @[Cat.scala 30:58]
  mem_1_inTestHarness mem ( // @[DescribedSRAM.scala 19:26]
    .R0_addr(mem_R0_addr),
    .R0_en(mem_R0_en),
    .R0_clk(mem_R0_clk),
    .R0_data_0(mem_R0_data_0),
    .R0_data_1(mem_R0_data_1),
    .R0_data_2(mem_R0_data_2),
    .R0_data_3(mem_R0_data_3),
    .R0_data_4(mem_R0_data_4),
    .R0_data_5(mem_R0_data_5),
    .R0_data_6(mem_R0_data_6),
    .R0_data_7(mem_R0_data_7),
    .R0_data_8(mem_R0_data_8),
    .R0_data_9(mem_R0_data_9),
    .R0_data_10(mem_R0_data_10),
    .R0_data_11(mem_R0_data_11),
    .R0_data_12(mem_R0_data_12),
    .R0_data_13(mem_R0_data_13),
    .R0_data_14(mem_R0_data_14),
    .R0_data_15(mem_R0_data_15),
    .W0_addr(mem_W0_addr),
    .W0_en(mem_W0_en),
    .W0_clk(mem_W0_clk),
    .W0_data_0(mem_W0_data_0),
    .W0_data_1(mem_W0_data_1),
    .W0_data_2(mem_W0_data_2),
    .W0_data_3(mem_W0_data_3),
    .W0_data_4(mem_W0_data_4),
    .W0_data_5(mem_W0_data_5),
    .W0_data_6(mem_W0_data_6),
    .W0_data_7(mem_W0_data_7),
    .W0_data_8(mem_W0_data_8),
    .W0_data_9(mem_W0_data_9),
    .W0_data_10(mem_W0_data_10),
    .W0_data_11(mem_W0_data_11),
    .W0_data_12(mem_W0_data_12),
    .W0_data_13(mem_W0_data_13),
    .W0_data_14(mem_W0_data_14),
    .W0_data_15(mem_W0_data_15),
    .W0_mask_0(mem_W0_mask_0),
    .W0_mask_1(mem_W0_mask_1),
    .W0_mask_2(mem_W0_mask_2),
    .W0_mask_3(mem_W0_mask_3),
    .W0_mask_4(mem_W0_mask_4),
    .W0_mask_5(mem_W0_mask_5),
    .W0_mask_6(mem_W0_mask_6),
    .W0_mask_7(mem_W0_mask_7),
    .W0_mask_8(mem_W0_mask_8),
    .W0_mask_9(mem_W0_mask_9),
    .W0_mask_10(mem_W0_mask_10),
    .W0_mask_11(mem_W0_mask_11),
    .W0_mask_12(mem_W0_mask_12),
    .W0_mask_13(mem_W0_mask_13),
    .W0_mask_14(mem_W0_mask_14),
    .W0_mask_15(mem_W0_mask_15)
  );
  assign auto_in_aw_ready = auto_in_w_valid & (auto_in_b_ready | ~w_full); // @[SRAM.scala 92:32]
  assign auto_in_w_ready = auto_in_aw_valid & _bundleIn_0_aw_ready_T_1; // @[SRAM.scala 93:32]
  assign auto_in_b_valid = w_full; // @[Nodes.scala 1210:84 SRAM.scala 91:17]
  assign auto_in_b_bits_id = w_id; // @[Nodes.scala 1210:84 SRAM.scala 95:20]
  assign auto_in_b_bits_resp = w_sel1 ? 2'h0 : 2'h3; // @[SRAM.scala 96:26]
  assign auto_in_b_bits_echo_real_last = w_echo_real_last; // @[Nodes.scala 1210:84 BundleMap.scala 247:19]
  assign auto_in_ar_ready = auto_in_r_ready | ~r_full; // @[SRAM.scala 117:31]
  assign auto_in_r_valid = r_full; // @[Nodes.scala 1210:84 SRAM.scala 116:17]
  assign auto_in_r_bits_id = r_id; // @[Nodes.scala 1210:84 SRAM.scala 119:20]
  assign auto_in_r_bits_data = {bundleIn_0_r_bits_data_hi,bundleIn_0_r_bits_data_lo}; // @[Cat.scala 30:58]
  assign auto_in_r_bits_resp = r_sel1 ? 2'h0 : 2'h3; // @[SRAM.scala 120:26]
  assign auto_in_r_bits_echo_real_last = r_echo_real_last; // @[Nodes.scala 1210:84 BundleMap.scala 247:19]
  assign mem_R0_addr = {r_addr_hi,r_addr_lo}; // @[Cat.scala 30:58]
  assign mem_R0_en = in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  assign mem_R0_clk = clock; // @[package.scala 91:58 package.scala 91:58]
  assign mem_W0_addr = {w_addr_hi,w_addr_lo}; // @[Cat.scala 30:58]
  assign mem_W0_en = _T_1 & w_sel0; // @[SRAM.scala 86:24]
  assign mem_W0_clk = clock; // @[SRAM.scala 86:35]
  assign mem_W0_data_0 = auto_in_w_bits_data[7:0]; // @[SRAM.scala 85:62]
  assign mem_W0_data_1 = auto_in_w_bits_data[15:8]; // @[SRAM.scala 85:62]
  assign mem_W0_data_2 = auto_in_w_bits_data[23:16]; // @[SRAM.scala 85:62]
  assign mem_W0_data_3 = auto_in_w_bits_data[31:24]; // @[SRAM.scala 85:62]
  assign mem_W0_data_4 = auto_in_w_bits_data[39:32]; // @[SRAM.scala 85:62]
  assign mem_W0_data_5 = auto_in_w_bits_data[47:40]; // @[SRAM.scala 85:62]
  assign mem_W0_data_6 = auto_in_w_bits_data[55:48]; // @[SRAM.scala 85:62]
  assign mem_W0_data_7 = auto_in_w_bits_data[63:56]; // @[SRAM.scala 85:62]
  assign mem_W0_data_8 = auto_in_w_bits_data[71:64]; // @[SRAM.scala 85:62]
  assign mem_W0_data_9 = auto_in_w_bits_data[79:72]; // @[SRAM.scala 85:62]
  assign mem_W0_data_10 = auto_in_w_bits_data[87:80]; // @[SRAM.scala 85:62]
  assign mem_W0_data_11 = auto_in_w_bits_data[95:88]; // @[SRAM.scala 85:62]
  assign mem_W0_data_12 = auto_in_w_bits_data[103:96]; // @[SRAM.scala 85:62]
  assign mem_W0_data_13 = auto_in_w_bits_data[111:104]; // @[SRAM.scala 85:62]
  assign mem_W0_data_14 = auto_in_w_bits_data[119:112]; // @[SRAM.scala 85:62]
  assign mem_W0_data_15 = auto_in_w_bits_data[127:120]; // @[SRAM.scala 85:62]
  assign mem_W0_mask_0 = auto_in_w_bits_strb[0]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_1 = auto_in_w_bits_strb[1]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_2 = auto_in_w_bits_strb[2]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_3 = auto_in_w_bits_strb[3]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_4 = auto_in_w_bits_strb[4]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_5 = auto_in_w_bits_strb[5]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_6 = auto_in_w_bits_strb[6]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_7 = auto_in_w_bits_strb[7]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_8 = auto_in_w_bits_strb[8]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_9 = auto_in_w_bits_strb[9]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_10 = auto_in_w_bits_strb[10]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_11 = auto_in_w_bits_strb[11]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_12 = auto_in_w_bits_strb[12]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_13 = auto_in_w_bits_strb[13]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_14 = auto_in_w_bits_strb[14]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_15 = auto_in_w_bits_strb[15]; // @[SRAM.scala 87:47]
  always @(posedge clock) begin
    if (reset) begin // @[SRAM.scala 70:25]
      w_full <= 1'h0; // @[SRAM.scala 70:25]
    end else begin
      w_full <= _GEN_1;
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_id <= auto_in_aw_bits_id; // @[SRAM.scala 80:12]
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_echo_real_last <= auto_in_aw_bits_echo_real_last; // @[BundleMap.scala 247:19]
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_sel1 <= r_sel0; // @[SRAM.scala 108:14]
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_sel1 <= w_sel0; // @[SRAM.scala 81:14]
    end
    if (reset) begin // @[SRAM.scala 99:25]
      r_full <= 1'h0; // @[SRAM.scala 99:25]
    end else begin
      r_full <= _GEN_73;
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_id <= auto_in_ar_bits_id; // @[SRAM.scala 107:12]
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_echo_real_last <= auto_in_ar_bits_echo_real_last; // @[BundleMap.scala 247:19]
    end
    rdata_REG <= in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_0 <= mem_R0_data_0; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_1 <= mem_R0_data_1; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_2 <= mem_R0_data_2; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_3 <= mem_R0_data_3; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_4 <= mem_R0_data_4; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_5 <= mem_R0_data_5; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_6 <= mem_R0_data_6; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_7 <= mem_R0_data_7; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_8 <= mem_R0_data_8; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_9 <= mem_R0_data_9; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_10 <= mem_R0_data_10; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_11 <= mem_R0_data_11; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_12 <= mem_R0_data_12; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_13 <= mem_R0_data_13; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_14 <= mem_R0_data_14; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_15 <= mem_R0_data_15; // @[Reg.scala 16:23]
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
  w_full = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  w_id = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  w_echo_real_last = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  r_sel1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  w_sel1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  r_full = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  r_id = _RAND_6[3:0];
  _RAND_7 = {1{`RANDOM}};
  r_echo_real_last = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  rdata_REG = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  rdata_r_0 = _RAND_9[7:0];
  _RAND_10 = {1{`RANDOM}};
  rdata_r_1 = _RAND_10[7:0];
  _RAND_11 = {1{`RANDOM}};
  rdata_r_2 = _RAND_11[7:0];
  _RAND_12 = {1{`RANDOM}};
  rdata_r_3 = _RAND_12[7:0];
  _RAND_13 = {1{`RANDOM}};
  rdata_r_4 = _RAND_13[7:0];
  _RAND_14 = {1{`RANDOM}};
  rdata_r_5 = _RAND_14[7:0];
  _RAND_15 = {1{`RANDOM}};
  rdata_r_6 = _RAND_15[7:0];
  _RAND_16 = {1{`RANDOM}};
  rdata_r_7 = _RAND_16[7:0];
  _RAND_17 = {1{`RANDOM}};
  rdata_r_8 = _RAND_17[7:0];
  _RAND_18 = {1{`RANDOM}};
  rdata_r_9 = _RAND_18[7:0];
  _RAND_19 = {1{`RANDOM}};
  rdata_r_10 = _RAND_19[7:0];
  _RAND_20 = {1{`RANDOM}};
  rdata_r_11 = _RAND_20[7:0];
  _RAND_21 = {1{`RANDOM}};
  rdata_r_12 = _RAND_21[7:0];
  _RAND_22 = {1{`RANDOM}};
  rdata_r_13 = _RAND_22[7:0];
  _RAND_23 = {1{`RANDOM}};
  rdata_r_14 = _RAND_23[7:0];
  _RAND_24 = {1{`RANDOM}};
  rdata_r_15 = _RAND_24[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4RAM_3_inTestHarness(
  input          clock,
  input          reset,
  output         auto_in_aw_ready,
  input          auto_in_aw_valid,
  input  [3:0]   auto_in_aw_bits_id,
  input  [31:0]  auto_in_aw_bits_addr,
  input          auto_in_aw_bits_echo_real_last,
  output         auto_in_w_ready,
  input          auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_b_ready,
  output         auto_in_b_valid,
  output [3:0]   auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output         auto_in_b_bits_echo_real_last,
  output         auto_in_ar_ready,
  input          auto_in_ar_valid,
  input  [3:0]   auto_in_ar_bits_id,
  input  [31:0]  auto_in_ar_bits_addr,
  input          auto_in_ar_bits_echo_real_last,
  input          auto_in_r_ready,
  output         auto_in_r_valid,
  output [3:0]   auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output         auto_in_r_bits_echo_real_last
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
`endif // RANDOMIZE_REG_INIT
  wire [24:0] mem_R0_addr; // @[DescribedSRAM.scala 19:26]
  wire  mem_R0_en; // @[DescribedSRAM.scala 19:26]
  wire  mem_R0_clk; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_0; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_1; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_2; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_3; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_4; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_5; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_6; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_7; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_8; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_9; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_10; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_11; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_12; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_13; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_14; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_R0_data_15; // @[DescribedSRAM.scala 19:26]
  wire [24:0] mem_W0_addr; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_en; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_clk; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_0; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_1; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_2; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_3; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_4; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_5; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_6; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_7; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_8; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_9; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_10; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_11; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_12; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_13; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_14; // @[DescribedSRAM.scala 19:26]
  wire [7:0] mem_W0_data_15; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_0; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_1; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_2; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_3; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_4; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_5; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_6; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_7; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_8; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_9; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_10; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_11; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_12; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_13; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_14; // @[DescribedSRAM.scala 19:26]
  wire  mem_W0_mask_15; // @[DescribedSRAM.scala 19:26]
  wire  r_addr_lo_lo_lo_lo = auto_in_ar_bits_addr[4]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_lo_hi_lo = auto_in_ar_bits_addr[5]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_lo_hi_hi = auto_in_ar_bits_addr[6]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_lo = auto_in_ar_bits_addr[7]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_hi_lo = auto_in_ar_bits_addr[8]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_lo_hi_hi_hi = auto_in_ar_bits_addr[9]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_lo = auto_in_ar_bits_addr[10]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_hi_lo = auto_in_ar_bits_addr[11]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_lo_hi_hi = auto_in_ar_bits_addr[12]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_lo = auto_in_ar_bits_addr[13]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_hi_lo = auto_in_ar_bits_addr[14]; // @[SRAM.scala 65:73]
  wire  r_addr_lo_hi_hi_hi_hi = auto_in_ar_bits_addr[15]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_lo = auto_in_ar_bits_addr[16]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_hi_lo = auto_in_ar_bits_addr[17]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_lo_hi_hi = auto_in_ar_bits_addr[18]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_lo = auto_in_ar_bits_addr[19]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_hi_lo = auto_in_ar_bits_addr[20]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_lo_hi_hi_hi = auto_in_ar_bits_addr[21]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_lo = auto_in_ar_bits_addr[22]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_hi_lo = auto_in_ar_bits_addr[23]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_lo_hi_hi = auto_in_ar_bits_addr[24]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_lo_lo = auto_in_ar_bits_addr[25]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_lo_hi = auto_in_ar_bits_addr[26]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_hi_lo = auto_in_ar_bits_addr[27]; // @[SRAM.scala 65:73]
  wire  r_addr_hi_hi_hi_hi_hi = auto_in_ar_bits_addr[28]; // @[SRAM.scala 65:73]
  wire [5:0] r_addr_lo_lo = {r_addr_lo_lo_hi_hi_hi,r_addr_lo_lo_hi_hi_lo,r_addr_lo_lo_hi_lo,r_addr_lo_lo_lo_hi_hi,
    r_addr_lo_lo_lo_hi_lo,r_addr_lo_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [11:0] r_addr_lo = {r_addr_lo_hi_hi_hi_hi,r_addr_lo_hi_hi_hi_lo,r_addr_lo_hi_hi_lo,r_addr_lo_hi_lo_hi_hi,
    r_addr_lo_hi_lo_hi_lo,r_addr_lo_hi_lo_lo,r_addr_lo_lo}; // @[Cat.scala 30:58]
  wire [5:0] r_addr_hi_lo = {r_addr_hi_lo_hi_hi_hi,r_addr_hi_lo_hi_hi_lo,r_addr_hi_lo_hi_lo,r_addr_hi_lo_lo_hi_hi,
    r_addr_hi_lo_lo_hi_lo,r_addr_hi_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] r_addr_hi = {r_addr_hi_hi_hi_hi_hi,r_addr_hi_hi_hi_hi_lo,r_addr_hi_hi_hi_lo_hi,r_addr_hi_hi_hi_lo_lo,
    r_addr_hi_hi_lo_hi_hi,r_addr_hi_hi_lo_hi_lo,r_addr_hi_hi_lo_lo,r_addr_hi_lo}; // @[Cat.scala 30:58]
  wire  w_addr_lo_lo_lo_lo = auto_in_aw_bits_addr[4]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_lo_hi_lo = auto_in_aw_bits_addr[5]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_lo_hi_hi = auto_in_aw_bits_addr[6]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_lo = auto_in_aw_bits_addr[7]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_hi_lo = auto_in_aw_bits_addr[8]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_lo_hi_hi_hi = auto_in_aw_bits_addr[9]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_lo = auto_in_aw_bits_addr[10]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_hi_lo = auto_in_aw_bits_addr[11]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_lo_hi_hi = auto_in_aw_bits_addr[12]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_lo = auto_in_aw_bits_addr[13]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_hi_lo = auto_in_aw_bits_addr[14]; // @[SRAM.scala 66:73]
  wire  w_addr_lo_hi_hi_hi_hi = auto_in_aw_bits_addr[15]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_lo = auto_in_aw_bits_addr[16]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_hi_lo = auto_in_aw_bits_addr[17]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_lo_hi_hi = auto_in_aw_bits_addr[18]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_lo = auto_in_aw_bits_addr[19]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_hi_lo = auto_in_aw_bits_addr[20]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_lo_hi_hi_hi = auto_in_aw_bits_addr[21]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_lo = auto_in_aw_bits_addr[22]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_hi_lo = auto_in_aw_bits_addr[23]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_lo_hi_hi = auto_in_aw_bits_addr[24]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_lo_lo = auto_in_aw_bits_addr[25]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_lo_hi = auto_in_aw_bits_addr[26]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_hi_lo = auto_in_aw_bits_addr[27]; // @[SRAM.scala 66:73]
  wire  w_addr_hi_hi_hi_hi_hi = auto_in_aw_bits_addr[28]; // @[SRAM.scala 66:73]
  wire [5:0] w_addr_lo_lo = {w_addr_lo_lo_hi_hi_hi,w_addr_lo_lo_hi_hi_lo,w_addr_lo_lo_hi_lo,w_addr_lo_lo_lo_hi_hi,
    w_addr_lo_lo_lo_hi_lo,w_addr_lo_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [11:0] w_addr_lo = {w_addr_lo_hi_hi_hi_hi,w_addr_lo_hi_hi_hi_lo,w_addr_lo_hi_hi_lo,w_addr_lo_hi_lo_hi_hi,
    w_addr_lo_hi_lo_hi_lo,w_addr_lo_hi_lo_lo,w_addr_lo_lo}; // @[Cat.scala 30:58]
  wire [5:0] w_addr_hi_lo = {w_addr_hi_lo_hi_hi_hi,w_addr_hi_lo_hi_hi_lo,w_addr_hi_lo_hi_lo,w_addr_hi_lo_lo_hi_hi,
    w_addr_hi_lo_lo_hi_lo,w_addr_hi_lo_lo_lo}; // @[Cat.scala 30:58]
  wire [12:0] w_addr_hi = {w_addr_hi_hi_hi_hi_hi,w_addr_hi_hi_hi_hi_lo,w_addr_hi_hi_hi_lo_hi,w_addr_hi_hi_hi_lo_lo,
    w_addr_hi_hi_lo_hi_hi,w_addr_hi_hi_lo_hi_lo,w_addr_hi_hi_lo_lo,w_addr_hi_lo}; // @[Cat.scala 30:58]
  wire [31:0] _r_sel0_T = auto_in_ar_bits_addr ^ 32'hc0000000; // @[Parameters.scala 137:31]
  wire [32:0] _r_sel0_T_1 = {1'b0,$signed(_r_sel0_T)}; // @[Parameters.scala 137:49]
  wire [32:0] _r_sel0_T_3 = $signed(_r_sel0_T_1) & -33'sh20000000; // @[Parameters.scala 137:52]
  wire  r_sel0 = $signed(_r_sel0_T_3) == 33'sh0; // @[Parameters.scala 137:67]
  wire [31:0] _w_sel0_T = auto_in_aw_bits_addr ^ 32'hc0000000; // @[Parameters.scala 137:31]
  wire [32:0] _w_sel0_T_1 = {1'b0,$signed(_w_sel0_T)}; // @[Parameters.scala 137:49]
  wire [32:0] _w_sel0_T_3 = $signed(_w_sel0_T_1) & -33'sh20000000; // @[Parameters.scala 137:52]
  wire  w_sel0 = $signed(_w_sel0_T_3) == 33'sh0; // @[Parameters.scala 137:67]
  reg  w_full; // @[SRAM.scala 70:25]
  reg [3:0] w_id; // @[SRAM.scala 71:21]
  reg  w_echo_real_last; // @[SRAM.scala 72:21]
  reg  r_sel1; // @[SRAM.scala 73:21]
  reg  w_sel1; // @[SRAM.scala 74:21]
  wire  _T = auto_in_b_ready & w_full; // @[Decoupled.scala 40:37]
  wire  _GEN_0 = _T ? 1'h0 : w_full; // @[SRAM.scala 76:25 SRAM.scala 76:34 SRAM.scala 70:25]
  wire  _bundleIn_0_aw_ready_T_1 = auto_in_b_ready | ~w_full; // @[SRAM.scala 92:47]
  wire  in_aw_ready = auto_in_w_valid & (auto_in_b_ready | ~w_full); // @[SRAM.scala 92:32]
  wire  _T_1 = in_aw_ready & auto_in_aw_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_1 = _T_1 | _GEN_0; // @[SRAM.scala 77:25 SRAM.scala 77:34]
  reg  r_full; // @[SRAM.scala 99:25]
  reg [3:0] r_id; // @[SRAM.scala 100:21]
  reg  r_echo_real_last; // @[SRAM.scala 101:21]
  wire  _T_21 = auto_in_r_ready & r_full; // @[Decoupled.scala 40:37]
  wire  _GEN_72 = _T_21 ? 1'h0 : r_full; // @[SRAM.scala 103:25 SRAM.scala 103:34 SRAM.scala 99:25]
  wire  in_ar_ready = auto_in_r_ready | ~r_full; // @[SRAM.scala 117:31]
  wire  _T_22 = in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_73 = _T_22 | _GEN_72; // @[SRAM.scala 104:25 SRAM.scala 104:34]
  reg  rdata_REG; // @[package.scala 91:91]
  reg [7:0] rdata_r_0; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_1; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_2; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_3; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_4; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_5; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_6; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_7; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_8; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_9; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_10; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_11; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_12; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_13; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_14; // @[Reg.scala 15:16]
  reg [7:0] rdata_r_15; // @[Reg.scala 15:16]
  wire [7:0] _GEN_81 = rdata_REG ? mem_R0_data_0 : rdata_r_0; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_82 = rdata_REG ? mem_R0_data_1 : rdata_r_1; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_83 = rdata_REG ? mem_R0_data_2 : rdata_r_2; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_84 = rdata_REG ? mem_R0_data_3 : rdata_r_3; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_85 = rdata_REG ? mem_R0_data_4 : rdata_r_4; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_86 = rdata_REG ? mem_R0_data_5 : rdata_r_5; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_87 = rdata_REG ? mem_R0_data_6 : rdata_r_6; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_88 = rdata_REG ? mem_R0_data_7 : rdata_r_7; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_89 = rdata_REG ? mem_R0_data_8 : rdata_r_8; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_90 = rdata_REG ? mem_R0_data_9 : rdata_r_9; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_91 = rdata_REG ? mem_R0_data_10 : rdata_r_10; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_92 = rdata_REG ? mem_R0_data_11 : rdata_r_11; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_93 = rdata_REG ? mem_R0_data_12 : rdata_r_12; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_94 = rdata_REG ? mem_R0_data_13 : rdata_r_13; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_95 = rdata_REG ? mem_R0_data_14 : rdata_r_14; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [7:0] _GEN_96 = rdata_REG ? mem_R0_data_15 : rdata_r_15; // @[Reg.scala 16:19 Reg.scala 16:23 Reg.scala 15:16]
  wire [63:0] bundleIn_0_r_bits_data_lo = {_GEN_88,_GEN_87,_GEN_86,_GEN_85,_GEN_84,_GEN_83,_GEN_82,_GEN_81}; // @[Cat.scala 30:58]
  wire [63:0] bundleIn_0_r_bits_data_hi = {_GEN_96,_GEN_95,_GEN_94,_GEN_93,_GEN_92,_GEN_91,_GEN_90,_GEN_89}; // @[Cat.scala 30:58]
  mem_2_inTestHarness mem ( // @[DescribedSRAM.scala 19:26]
    .R0_addr(mem_R0_addr),
    .R0_en(mem_R0_en),
    .R0_clk(mem_R0_clk),
    .R0_data_0(mem_R0_data_0),
    .R0_data_1(mem_R0_data_1),
    .R0_data_2(mem_R0_data_2),
    .R0_data_3(mem_R0_data_3),
    .R0_data_4(mem_R0_data_4),
    .R0_data_5(mem_R0_data_5),
    .R0_data_6(mem_R0_data_6),
    .R0_data_7(mem_R0_data_7),
    .R0_data_8(mem_R0_data_8),
    .R0_data_9(mem_R0_data_9),
    .R0_data_10(mem_R0_data_10),
    .R0_data_11(mem_R0_data_11),
    .R0_data_12(mem_R0_data_12),
    .R0_data_13(mem_R0_data_13),
    .R0_data_14(mem_R0_data_14),
    .R0_data_15(mem_R0_data_15),
    .W0_addr(mem_W0_addr),
    .W0_en(mem_W0_en),
    .W0_clk(mem_W0_clk),
    .W0_data_0(mem_W0_data_0),
    .W0_data_1(mem_W0_data_1),
    .W0_data_2(mem_W0_data_2),
    .W0_data_3(mem_W0_data_3),
    .W0_data_4(mem_W0_data_4),
    .W0_data_5(mem_W0_data_5),
    .W0_data_6(mem_W0_data_6),
    .W0_data_7(mem_W0_data_7),
    .W0_data_8(mem_W0_data_8),
    .W0_data_9(mem_W0_data_9),
    .W0_data_10(mem_W0_data_10),
    .W0_data_11(mem_W0_data_11),
    .W0_data_12(mem_W0_data_12),
    .W0_data_13(mem_W0_data_13),
    .W0_data_14(mem_W0_data_14),
    .W0_data_15(mem_W0_data_15),
    .W0_mask_0(mem_W0_mask_0),
    .W0_mask_1(mem_W0_mask_1),
    .W0_mask_2(mem_W0_mask_2),
    .W0_mask_3(mem_W0_mask_3),
    .W0_mask_4(mem_W0_mask_4),
    .W0_mask_5(mem_W0_mask_5),
    .W0_mask_6(mem_W0_mask_6),
    .W0_mask_7(mem_W0_mask_7),
    .W0_mask_8(mem_W0_mask_8),
    .W0_mask_9(mem_W0_mask_9),
    .W0_mask_10(mem_W0_mask_10),
    .W0_mask_11(mem_W0_mask_11),
    .W0_mask_12(mem_W0_mask_12),
    .W0_mask_13(mem_W0_mask_13),
    .W0_mask_14(mem_W0_mask_14),
    .W0_mask_15(mem_W0_mask_15)
  );
  assign auto_in_aw_ready = auto_in_w_valid & (auto_in_b_ready | ~w_full); // @[SRAM.scala 92:32]
  assign auto_in_w_ready = auto_in_aw_valid & _bundleIn_0_aw_ready_T_1; // @[SRAM.scala 93:32]
  assign auto_in_b_valid = w_full; // @[Nodes.scala 1210:84 SRAM.scala 91:17]
  assign auto_in_b_bits_id = w_id; // @[Nodes.scala 1210:84 SRAM.scala 95:20]
  assign auto_in_b_bits_resp = w_sel1 ? 2'h0 : 2'h3; // @[SRAM.scala 96:26]
  assign auto_in_b_bits_echo_real_last = w_echo_real_last; // @[Nodes.scala 1210:84 BundleMap.scala 247:19]
  assign auto_in_ar_ready = auto_in_r_ready | ~r_full; // @[SRAM.scala 117:31]
  assign auto_in_r_valid = r_full; // @[Nodes.scala 1210:84 SRAM.scala 116:17]
  assign auto_in_r_bits_id = r_id; // @[Nodes.scala 1210:84 SRAM.scala 119:20]
  assign auto_in_r_bits_data = {bundleIn_0_r_bits_data_hi,bundleIn_0_r_bits_data_lo}; // @[Cat.scala 30:58]
  assign auto_in_r_bits_resp = r_sel1 ? 2'h0 : 2'h3; // @[SRAM.scala 120:26]
  assign auto_in_r_bits_echo_real_last = r_echo_real_last; // @[Nodes.scala 1210:84 BundleMap.scala 247:19]
  assign mem_R0_addr = {r_addr_hi,r_addr_lo}; // @[Cat.scala 30:58]
  assign mem_R0_en = in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  assign mem_R0_clk = clock; // @[package.scala 91:58 package.scala 91:58]
  assign mem_W0_addr = {w_addr_hi,w_addr_lo}; // @[Cat.scala 30:58]
  assign mem_W0_en = _T_1 & w_sel0; // @[SRAM.scala 86:24]
  assign mem_W0_clk = clock; // @[SRAM.scala 86:35]
  assign mem_W0_data_0 = auto_in_w_bits_data[7:0]; // @[SRAM.scala 85:62]
  assign mem_W0_data_1 = auto_in_w_bits_data[15:8]; // @[SRAM.scala 85:62]
  assign mem_W0_data_2 = auto_in_w_bits_data[23:16]; // @[SRAM.scala 85:62]
  assign mem_W0_data_3 = auto_in_w_bits_data[31:24]; // @[SRAM.scala 85:62]
  assign mem_W0_data_4 = auto_in_w_bits_data[39:32]; // @[SRAM.scala 85:62]
  assign mem_W0_data_5 = auto_in_w_bits_data[47:40]; // @[SRAM.scala 85:62]
  assign mem_W0_data_6 = auto_in_w_bits_data[55:48]; // @[SRAM.scala 85:62]
  assign mem_W0_data_7 = auto_in_w_bits_data[63:56]; // @[SRAM.scala 85:62]
  assign mem_W0_data_8 = auto_in_w_bits_data[71:64]; // @[SRAM.scala 85:62]
  assign mem_W0_data_9 = auto_in_w_bits_data[79:72]; // @[SRAM.scala 85:62]
  assign mem_W0_data_10 = auto_in_w_bits_data[87:80]; // @[SRAM.scala 85:62]
  assign mem_W0_data_11 = auto_in_w_bits_data[95:88]; // @[SRAM.scala 85:62]
  assign mem_W0_data_12 = auto_in_w_bits_data[103:96]; // @[SRAM.scala 85:62]
  assign mem_W0_data_13 = auto_in_w_bits_data[111:104]; // @[SRAM.scala 85:62]
  assign mem_W0_data_14 = auto_in_w_bits_data[119:112]; // @[SRAM.scala 85:62]
  assign mem_W0_data_15 = auto_in_w_bits_data[127:120]; // @[SRAM.scala 85:62]
  assign mem_W0_mask_0 = auto_in_w_bits_strb[0]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_1 = auto_in_w_bits_strb[1]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_2 = auto_in_w_bits_strb[2]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_3 = auto_in_w_bits_strb[3]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_4 = auto_in_w_bits_strb[4]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_5 = auto_in_w_bits_strb[5]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_6 = auto_in_w_bits_strb[6]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_7 = auto_in_w_bits_strb[7]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_8 = auto_in_w_bits_strb[8]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_9 = auto_in_w_bits_strb[9]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_10 = auto_in_w_bits_strb[10]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_11 = auto_in_w_bits_strb[11]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_12 = auto_in_w_bits_strb[12]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_13 = auto_in_w_bits_strb[13]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_14 = auto_in_w_bits_strb[14]; // @[SRAM.scala 87:47]
  assign mem_W0_mask_15 = auto_in_w_bits_strb[15]; // @[SRAM.scala 87:47]
  always @(posedge clock) begin
    if (reset) begin // @[SRAM.scala 70:25]
      w_full <= 1'h0; // @[SRAM.scala 70:25]
    end else begin
      w_full <= _GEN_1;
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_id <= auto_in_aw_bits_id; // @[SRAM.scala 80:12]
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_echo_real_last <= auto_in_aw_bits_echo_real_last; // @[BundleMap.scala 247:19]
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_sel1 <= r_sel0; // @[SRAM.scala 108:14]
    end
    if (_T_1) begin // @[SRAM.scala 79:25]
      w_sel1 <= w_sel0; // @[SRAM.scala 81:14]
    end
    if (reset) begin // @[SRAM.scala 99:25]
      r_full <= 1'h0; // @[SRAM.scala 99:25]
    end else begin
      r_full <= _GEN_73;
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_id <= auto_in_ar_bits_id; // @[SRAM.scala 107:12]
    end
    if (_T_22) begin // @[SRAM.scala 106:25]
      r_echo_real_last <= auto_in_ar_bits_echo_real_last; // @[BundleMap.scala 247:19]
    end
    rdata_REG <= in_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_0 <= mem_R0_data_0; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_1 <= mem_R0_data_1; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_2 <= mem_R0_data_2; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_3 <= mem_R0_data_3; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_4 <= mem_R0_data_4; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_5 <= mem_R0_data_5; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_6 <= mem_R0_data_6; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_7 <= mem_R0_data_7; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_8 <= mem_R0_data_8; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_9 <= mem_R0_data_9; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_10 <= mem_R0_data_10; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_11 <= mem_R0_data_11; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_12 <= mem_R0_data_12; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_13 <= mem_R0_data_13; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_14 <= mem_R0_data_14; // @[Reg.scala 16:23]
    end
    if (rdata_REG) begin // @[Reg.scala 16:19]
      rdata_r_15 <= mem_R0_data_15; // @[Reg.scala 16:23]
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
  w_full = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  w_id = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  w_echo_real_last = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  r_sel1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  w_sel1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  r_full = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  r_id = _RAND_6[3:0];
  _RAND_7 = {1{`RANDOM}};
  r_echo_real_last = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  rdata_REG = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  rdata_r_0 = _RAND_9[7:0];
  _RAND_10 = {1{`RANDOM}};
  rdata_r_1 = _RAND_10[7:0];
  _RAND_11 = {1{`RANDOM}};
  rdata_r_2 = _RAND_11[7:0];
  _RAND_12 = {1{`RANDOM}};
  rdata_r_3 = _RAND_12[7:0];
  _RAND_13 = {1{`RANDOM}};
  rdata_r_4 = _RAND_13[7:0];
  _RAND_14 = {1{`RANDOM}};
  rdata_r_5 = _RAND_14[7:0];
  _RAND_15 = {1{`RANDOM}};
  rdata_r_6 = _RAND_15[7:0];
  _RAND_16 = {1{`RANDOM}};
  rdata_r_7 = _RAND_16[7:0];
  _RAND_17 = {1{`RANDOM}};
  rdata_r_8 = _RAND_17[7:0];
  _RAND_18 = {1{`RANDOM}};
  rdata_r_9 = _RAND_18[7:0];
  _RAND_19 = {1{`RANDOM}};
  rdata_r_10 = _RAND_19[7:0];
  _RAND_20 = {1{`RANDOM}};
  rdata_r_11 = _RAND_20[7:0];
  _RAND_21 = {1{`RANDOM}};
  rdata_r_12 = _RAND_21[7:0];
  _RAND_22 = {1{`RANDOM}};
  rdata_r_13 = _RAND_22[7:0];
  _RAND_23 = {1{`RANDOM}};
  rdata_r_14 = _RAND_23[7:0];
  _RAND_24 = {1{`RANDOM}};
  rdata_r_15 = _RAND_24[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module QueueCompatibility_44_inTestHarness(
  input        clock,
  input        reset,
  output       io_enq_ready,
  input        io_enq_valid,
  input  [2:0] io_enq_bits,
  input        io_deq_ready,
  output       io_deq_valid,
  output [2:0] io_deq_bits
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [2:0] ram [0:1]; // @[Decoupled.scala 218:16]
  wire [2:0] ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [2:0] ram_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_MPORT_en; // @[Decoupled.scala 218:16]
  reg  enq_ptr_value; // @[Counter.scala 60:40]
  reg  deq_ptr_value; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = enq_ptr_value == deq_ptr_value; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  _do_enq_T = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  _do_deq_T = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_9 = io_deq_ready ? 1'h0 : _do_enq_T; // @[Decoupled.scala 249:27 Decoupled.scala 249:36]
  wire  do_enq = empty ? _GEN_9 : _do_enq_T; // @[Decoupled.scala 246:18]
  wire  do_deq = empty ? 1'h0 : _do_deq_T; // @[Decoupled.scala 246:18 Decoupled.scala 248:14]
  assign ram_io_deq_bits_MPORT_addr = deq_ptr_value;
  assign ram_io_deq_bits_MPORT_data = ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_MPORT_data = io_enq_bits;
  assign ram_MPORT_addr = enq_ptr_value;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = empty ? _GEN_9 : _do_enq_T;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = io_enq_valid | ~empty; // @[Decoupled.scala 245:25 Decoupled.scala 245:40 Decoupled.scala 240:16]
  assign io_deq_bits = empty ? io_enq_bits : ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      enq_ptr_value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      enq_ptr_value <= enq_ptr_value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      deq_ptr_value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      deq_ptr_value <= deq_ptr_value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      if (empty) begin // @[Decoupled.scala 246:18]
        if (io_deq_ready) begin // @[Decoupled.scala 249:27]
          maybe_full <= 1'h0; // @[Decoupled.scala 249:36]
        end else begin
          maybe_full <= _do_enq_T;
        end
      end else begin
        maybe_full <= _do_enq_T;
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram[initvar] = _RAND_0[2:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  enq_ptr_value = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  deq_ptr_value = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4Xbar_1_inTestHarness(
  input          clock,
  input          reset,
  output         auto_in_aw_ready,
  input          auto_in_aw_valid,
  input  [3:0]   auto_in_aw_bits_id,
  input  [31:0]  auto_in_aw_bits_addr,
  input  [7:0]   auto_in_aw_bits_len,
  input  [2:0]   auto_in_aw_bits_size,
  input  [1:0]   auto_in_aw_bits_burst,
  output         auto_in_w_ready,
  input          auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_w_bits_last,
  input          auto_in_b_ready,
  output         auto_in_b_valid,
  output [3:0]   auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output         auto_in_ar_ready,
  input          auto_in_ar_valid,
  input  [3:0]   auto_in_ar_bits_id,
  input  [31:0]  auto_in_ar_bits_addr,
  input  [7:0]   auto_in_ar_bits_len,
  input  [2:0]   auto_in_ar_bits_size,
  input  [1:0]   auto_in_ar_bits_burst,
  input          auto_in_r_ready,
  output         auto_in_r_valid,
  output [3:0]   auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output         auto_in_r_bits_last,
  input          auto_out_2_aw_ready,
  output         auto_out_2_aw_valid,
  output [3:0]   auto_out_2_aw_bits_id,
  output [31:0]  auto_out_2_aw_bits_addr,
  output [7:0]   auto_out_2_aw_bits_len,
  output [2:0]   auto_out_2_aw_bits_size,
  output [1:0]   auto_out_2_aw_bits_burst,
  input          auto_out_2_w_ready,
  output         auto_out_2_w_valid,
  output [127:0] auto_out_2_w_bits_data,
  output [15:0]  auto_out_2_w_bits_strb,
  output         auto_out_2_w_bits_last,
  output         auto_out_2_b_ready,
  input          auto_out_2_b_valid,
  input  [3:0]   auto_out_2_b_bits_id,
  input  [1:0]   auto_out_2_b_bits_resp,
  input          auto_out_2_ar_ready,
  output         auto_out_2_ar_valid,
  output [3:0]   auto_out_2_ar_bits_id,
  output [31:0]  auto_out_2_ar_bits_addr,
  output [7:0]   auto_out_2_ar_bits_len,
  output [2:0]   auto_out_2_ar_bits_size,
  output [1:0]   auto_out_2_ar_bits_burst,
  output         auto_out_2_r_ready,
  input          auto_out_2_r_valid,
  input  [3:0]   auto_out_2_r_bits_id,
  input  [127:0] auto_out_2_r_bits_data,
  input  [1:0]   auto_out_2_r_bits_resp,
  input          auto_out_2_r_bits_last,
  input          auto_out_1_aw_ready,
  output         auto_out_1_aw_valid,
  output [3:0]   auto_out_1_aw_bits_id,
  output [31:0]  auto_out_1_aw_bits_addr,
  output [7:0]   auto_out_1_aw_bits_len,
  output [2:0]   auto_out_1_aw_bits_size,
  output [1:0]   auto_out_1_aw_bits_burst,
  input          auto_out_1_w_ready,
  output         auto_out_1_w_valid,
  output [127:0] auto_out_1_w_bits_data,
  output [15:0]  auto_out_1_w_bits_strb,
  output         auto_out_1_w_bits_last,
  output         auto_out_1_b_ready,
  input          auto_out_1_b_valid,
  input  [3:0]   auto_out_1_b_bits_id,
  input  [1:0]   auto_out_1_b_bits_resp,
  input          auto_out_1_ar_ready,
  output         auto_out_1_ar_valid,
  output [3:0]   auto_out_1_ar_bits_id,
  output [31:0]  auto_out_1_ar_bits_addr,
  output [7:0]   auto_out_1_ar_bits_len,
  output [2:0]   auto_out_1_ar_bits_size,
  output [1:0]   auto_out_1_ar_bits_burst,
  output         auto_out_1_r_ready,
  input          auto_out_1_r_valid,
  input  [3:0]   auto_out_1_r_bits_id,
  input  [127:0] auto_out_1_r_bits_data,
  input  [1:0]   auto_out_1_r_bits_resp,
  input          auto_out_1_r_bits_last,
  input          auto_out_0_aw_ready,
  output         auto_out_0_aw_valid,
  output [3:0]   auto_out_0_aw_bits_id,
  output [30:0]  auto_out_0_aw_bits_addr,
  output [7:0]   auto_out_0_aw_bits_len,
  output [2:0]   auto_out_0_aw_bits_size,
  output [1:0]   auto_out_0_aw_bits_burst,
  input          auto_out_0_w_ready,
  output         auto_out_0_w_valid,
  output [127:0] auto_out_0_w_bits_data,
  output [15:0]  auto_out_0_w_bits_strb,
  output         auto_out_0_w_bits_last,
  output         auto_out_0_b_ready,
  input          auto_out_0_b_valid,
  input  [3:0]   auto_out_0_b_bits_id,
  input  [1:0]   auto_out_0_b_bits_resp,
  input          auto_out_0_ar_ready,
  output         auto_out_0_ar_valid,
  output [3:0]   auto_out_0_ar_bits_id,
  output [30:0]  auto_out_0_ar_bits_addr,
  output [7:0]   auto_out_0_ar_bits_len,
  output [2:0]   auto_out_0_ar_bits_size,
  output [1:0]   auto_out_0_ar_bits_burst,
  output         auto_out_0_r_ready,
  input          auto_out_0_r_valid,
  input  [3:0]   auto_out_0_r_bits_id,
  input  [127:0] auto_out_0_r_bits_data,
  input  [1:0]   auto_out_0_r_bits_resp,
  input          auto_out_0_r_bits_last
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
`endif // RANDOMIZE_REG_INIT
  wire  awIn_0_clock; // @[Xbar.scala 62:47]
  wire  awIn_0_reset; // @[Xbar.scala 62:47]
  wire  awIn_0_io_enq_ready; // @[Xbar.scala 62:47]
  wire  awIn_0_io_enq_valid; // @[Xbar.scala 62:47]
  wire [2:0] awIn_0_io_enq_bits; // @[Xbar.scala 62:47]
  wire  awIn_0_io_deq_ready; // @[Xbar.scala 62:47]
  wire  awIn_0_io_deq_valid; // @[Xbar.scala 62:47]
  wire [2:0] awIn_0_io_deq_bits; // @[Xbar.scala 62:47]
  wire [32:0] _requestARIO_T_1 = {1'b0,$signed(auto_in_ar_bits_addr)}; // @[Parameters.scala 137:49]
  wire [32:0] _requestARIO_T_3 = $signed(_requestARIO_T_1) & 33'sh80000000; // @[Parameters.scala 137:52]
  wire  requestARIO_0_0 = $signed(_requestARIO_T_3) == 33'sh0; // @[Parameters.scala 137:67]
  wire [31:0] _requestARIO_T_5 = auto_in_ar_bits_addr ^ 32'h80000000; // @[Parameters.scala 137:31]
  wire [32:0] _requestARIO_T_6 = {1'b0,$signed(_requestARIO_T_5)}; // @[Parameters.scala 137:49]
  wire [32:0] _requestARIO_T_8 = $signed(_requestARIO_T_6) & 33'shc0000000; // @[Parameters.scala 137:52]
  wire  requestARIO_0_1 = $signed(_requestARIO_T_8) == 33'sh0; // @[Parameters.scala 137:67]
  wire [31:0] _requestARIO_T_10 = auto_in_ar_bits_addr ^ 32'hc0000000; // @[Parameters.scala 137:31]
  wire [32:0] _requestARIO_T_11 = {1'b0,$signed(_requestARIO_T_10)}; // @[Parameters.scala 137:49]
  wire [32:0] _requestARIO_T_13 = $signed(_requestARIO_T_11) & 33'shc0000000; // @[Parameters.scala 137:52]
  wire  requestARIO_0_2 = $signed(_requestARIO_T_13) == 33'sh0; // @[Parameters.scala 137:67]
  wire [32:0] _requestAWIO_T_1 = {1'b0,$signed(auto_in_aw_bits_addr)}; // @[Parameters.scala 137:49]
  wire [32:0] _requestAWIO_T_3 = $signed(_requestAWIO_T_1) & 33'sh80000000; // @[Parameters.scala 137:52]
  wire  requestAWIO_0_0 = $signed(_requestAWIO_T_3) == 33'sh0; // @[Parameters.scala 137:67]
  wire [31:0] _requestAWIO_T_5 = auto_in_aw_bits_addr ^ 32'h80000000; // @[Parameters.scala 137:31]
  wire [32:0] _requestAWIO_T_6 = {1'b0,$signed(_requestAWIO_T_5)}; // @[Parameters.scala 137:49]
  wire [32:0] _requestAWIO_T_8 = $signed(_requestAWIO_T_6) & 33'shc0000000; // @[Parameters.scala 137:52]
  wire  requestAWIO_0_1 = $signed(_requestAWIO_T_8) == 33'sh0; // @[Parameters.scala 137:67]
  wire [31:0] _requestAWIO_T_10 = auto_in_aw_bits_addr ^ 32'hc0000000; // @[Parameters.scala 137:31]
  wire [32:0] _requestAWIO_T_11 = {1'b0,$signed(_requestAWIO_T_10)}; // @[Parameters.scala 137:49]
  wire [32:0] _requestAWIO_T_13 = $signed(_requestAWIO_T_11) & 33'shc0000000; // @[Parameters.scala 137:52]
  wire  requestAWIO_0_2 = $signed(_requestAWIO_T_13) == 33'sh0; // @[Parameters.scala 137:67]
  wire [1:0] awIn_0_io_enq_bits_hi = {requestAWIO_0_2,requestAWIO_0_1}; // @[Xbar.scala 71:75]
  wire  requestWIO_0_0 = awIn_0_io_deq_bits[0]; // @[Xbar.scala 72:73]
  wire  requestWIO_0_1 = awIn_0_io_deq_bits[1]; // @[Xbar.scala 72:73]
  wire  requestWIO_0_2 = awIn_0_io_deq_bits[2]; // @[Xbar.scala 72:73]
  reg  idle_3; // @[Xbar.scala 249:23]
  wire [2:0] readys_filter_lo = {auto_out_2_r_valid,auto_out_1_r_valid,auto_out_0_r_valid}; // @[Cat.scala 30:58]
  reg [2:0] readys_mask; // @[Arbiter.scala 23:23]
  wire [2:0] _readys_filter_T = ~readys_mask; // @[Arbiter.scala 24:30]
  wire [2:0] readys_filter_hi = readys_filter_lo & _readys_filter_T; // @[Arbiter.scala 24:28]
  wire [5:0] readys_filter = {readys_filter_hi,auto_out_2_r_valid,auto_out_1_r_valid,auto_out_0_r_valid}; // @[Cat.scala 30:58]
  wire [5:0] _GEN_72 = {{1'd0}, readys_filter[5:1]}; // @[package.scala 253:43]
  wire [5:0] _readys_unready_T_1 = readys_filter | _GEN_72; // @[package.scala 253:43]
  wire [5:0] _GEN_73 = {{2'd0}, _readys_unready_T_1[5:2]}; // @[package.scala 253:43]
  wire [5:0] _readys_unready_T_3 = _readys_unready_T_1 | _GEN_73; // @[package.scala 253:43]
  wire [5:0] _readys_unready_T_6 = {readys_mask, 3'h0}; // @[Arbiter.scala 25:66]
  wire [5:0] _GEN_74 = {{1'd0}, _readys_unready_T_3[5:1]}; // @[Arbiter.scala 25:58]
  wire [5:0] readys_unready = _GEN_74 | _readys_unready_T_6; // @[Arbiter.scala 25:58]
  wire [2:0] _readys_readys_T_2 = readys_unready[5:3] & readys_unready[2:0]; // @[Arbiter.scala 26:39]
  wire [2:0] readys_readys = ~_readys_readys_T_2; // @[Arbiter.scala 26:18]
  wire  readys_3_0 = readys_readys[0]; // @[Xbar.scala 255:69]
  wire  winner_3_0 = readys_3_0 & auto_out_0_r_valid; // @[Xbar.scala 257:63]
  reg  state_3_0; // @[Xbar.scala 268:24]
  wire  muxState_3_0 = idle_3 ? winner_3_0 : state_3_0; // @[Xbar.scala 269:23]
  wire [3:0] _T_78 = muxState_3_0 ? auto_out_0_r_bits_id : 4'h0; // @[Mux.scala 27:72]
  wire  readys_3_1 = readys_readys[1]; // @[Xbar.scala 255:69]
  wire  winner_3_1 = readys_3_1 & auto_out_1_r_valid; // @[Xbar.scala 257:63]
  reg  state_3_1; // @[Xbar.scala 268:24]
  wire  muxState_3_1 = idle_3 ? winner_3_1 : state_3_1; // @[Xbar.scala 269:23]
  wire [3:0] _T_79 = muxState_3_1 ? auto_out_1_r_bits_id : 4'h0; // @[Mux.scala 27:72]
  wire [3:0] _T_81 = _T_78 | _T_79; // @[Mux.scala 27:72]
  wire  readys_3_2 = readys_readys[2]; // @[Xbar.scala 255:69]
  wire  winner_3_2 = readys_3_2 & auto_out_2_r_valid; // @[Xbar.scala 257:63]
  reg  state_3_2; // @[Xbar.scala 268:24]
  wire  muxState_3_2 = idle_3 ? winner_3_2 : state_3_2; // @[Xbar.scala 269:23]
  wire [3:0] _T_80 = muxState_3_2 ? auto_out_2_r_bits_id : 4'h0; // @[Mux.scala 27:72]
  wire [3:0] in_0_r_bits_id = _T_81 | _T_80; // @[Mux.scala 27:72]
  reg  idle_4; // @[Xbar.scala 249:23]
  wire [2:0] readys_filter_lo_1 = {auto_out_2_b_valid,auto_out_1_b_valid,auto_out_0_b_valid}; // @[Cat.scala 30:58]
  reg [2:0] readys_mask_1; // @[Arbiter.scala 23:23]
  wire [2:0] _readys_filter_T_1 = ~readys_mask_1; // @[Arbiter.scala 24:30]
  wire [2:0] readys_filter_hi_1 = readys_filter_lo_1 & _readys_filter_T_1; // @[Arbiter.scala 24:28]
  wire [5:0] readys_filter_1 = {readys_filter_hi_1,auto_out_2_b_valid,auto_out_1_b_valid,auto_out_0_b_valid}; // @[Cat.scala 30:58]
  wire [5:0] _GEN_75 = {{1'd0}, readys_filter_1[5:1]}; // @[package.scala 253:43]
  wire [5:0] _readys_unready_T_8 = readys_filter_1 | _GEN_75; // @[package.scala 253:43]
  wire [5:0] _GEN_76 = {{2'd0}, _readys_unready_T_8[5:2]}; // @[package.scala 253:43]
  wire [5:0] _readys_unready_T_10 = _readys_unready_T_8 | _GEN_76; // @[package.scala 253:43]
  wire [5:0] _readys_unready_T_13 = {readys_mask_1, 3'h0}; // @[Arbiter.scala 25:66]
  wire [5:0] _GEN_77 = {{1'd0}, _readys_unready_T_10[5:1]}; // @[Arbiter.scala 25:58]
  wire [5:0] readys_unready_1 = _GEN_77 | _readys_unready_T_13; // @[Arbiter.scala 25:58]
  wire [2:0] _readys_readys_T_5 = readys_unready_1[5:3] & readys_unready_1[2:0]; // @[Arbiter.scala 26:39]
  wire [2:0] readys_readys_1 = ~_readys_readys_T_5; // @[Arbiter.scala 26:18]
  wire  readys_4_0 = readys_readys_1[0]; // @[Xbar.scala 255:69]
  wire  winner_4_0 = readys_4_0 & auto_out_0_b_valid; // @[Xbar.scala 257:63]
  reg  state_4_0; // @[Xbar.scala 268:24]
  wire  muxState_4_0 = idle_4 ? winner_4_0 : state_4_0; // @[Xbar.scala 269:23]
  wire [3:0] _T_110 = muxState_4_0 ? auto_out_0_b_bits_id : 4'h0; // @[Mux.scala 27:72]
  wire  readys_4_1 = readys_readys_1[1]; // @[Xbar.scala 255:69]
  wire  winner_4_1 = readys_4_1 & auto_out_1_b_valid; // @[Xbar.scala 257:63]
  reg  state_4_1; // @[Xbar.scala 268:24]
  wire  muxState_4_1 = idle_4 ? winner_4_1 : state_4_1; // @[Xbar.scala 269:23]
  wire [3:0] _T_111 = muxState_4_1 ? auto_out_1_b_bits_id : 4'h0; // @[Mux.scala 27:72]
  wire [3:0] _T_113 = _T_110 | _T_111; // @[Mux.scala 27:72]
  wire  readys_4_2 = readys_readys_1[2]; // @[Xbar.scala 255:69]
  wire  winner_4_2 = readys_4_2 & auto_out_2_b_valid; // @[Xbar.scala 257:63]
  reg  state_4_2; // @[Xbar.scala 268:24]
  wire  muxState_4_2 = idle_4 ? winner_4_2 : state_4_2; // @[Xbar.scala 269:23]
  wire [3:0] _T_112 = muxState_4_2 ? auto_out_2_b_bits_id : 4'h0; // @[Mux.scala 27:72]
  wire [3:0] in_0_b_bits_id = _T_113 | _T_112; // @[Mux.scala 27:72]
  wire [15:0] arSel = 16'h1 << auto_in_ar_bits_id; // @[OneHot.scala 65:12]
  wire [15:0] awSel = 16'h1 << auto_in_aw_bits_id; // @[OneHot.scala 65:12]
  wire [15:0] rSel = 16'h1 << in_0_r_bits_id; // @[OneHot.scala 65:12]
  wire [15:0] bSel = 16'h1 << in_0_b_bits_id; // @[OneHot.scala 65:12]
  wire  in_0_ar_ready = requestARIO_0_0 & auto_out_0_ar_ready | requestARIO_0_1 & auto_out_1_ar_ready | requestARIO_0_2
     & auto_out_2_ar_ready; // @[Mux.scala 27:72]
  reg  arFIFOMap_9_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_9_T_19 = ~arFIFOMap_9_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_8_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_8_T_19 = ~arFIFOMap_8_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_7_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_7_T_19 = ~arFIFOMap_7_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_6_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_6_T_19 = ~arFIFOMap_6_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_5_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_5_T_19 = ~arFIFOMap_5_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_4_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_4_T_19 = ~arFIFOMap_4_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_3_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_3_T_19 = ~arFIFOMap_3_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_2_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_2_T_19 = ~arFIFOMap_2_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_1_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_1_T_19 = ~arFIFOMap_1_count; // @[Xbar.scala 119:22]
  reg  arFIFOMap_0_count; // @[Xbar.scala 111:34]
  wire  _arFIFOMap_0_T_19 = ~arFIFOMap_0_count; // @[Xbar.scala 119:22]
  wire  _arFIFOMap_0_T_1 = in_0_ar_ready & auto_in_ar_valid; // @[Decoupled.scala 40:37]
  wire  _arFIFOMap_0_T_2 = arSel[0] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  anyValid = auto_out_0_r_valid | auto_out_1_r_valid | auto_out_2_r_valid; // @[Xbar.scala 253:36]
  wire  _in_0_r_valid_T_4 = state_3_0 & auto_out_0_r_valid | state_3_1 & auto_out_1_r_valid | state_3_2 &
    auto_out_2_r_valid; // @[Mux.scala 27:72]
  wire  in_0_r_valid = idle_3 ? anyValid : _in_0_r_valid_T_4; // @[Xbar.scala 285:22]
  wire  _arFIFOMap_0_T_4 = auto_in_r_ready & in_0_r_valid; // @[Decoupled.scala 40:37]
  wire  in_0_r_bits_last = muxState_3_0 & auto_out_0_r_bits_last | muxState_3_1 & auto_out_1_r_bits_last | muxState_3_2
     & auto_out_2_r_bits_last; // @[Mux.scala 27:72]
  wire  _arFIFOMap_0_T_6 = rSel[0] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_0_count_T_1 = arFIFOMap_0_count + _arFIFOMap_0_T_2; // @[Xbar.scala 113:30]
  wire  in_0_aw_ready = requestAWIO_0_0 & auto_out_0_aw_ready | requestAWIO_0_1 & auto_out_1_aw_ready | requestAWIO_0_2
     & auto_out_2_aw_ready; // @[Mux.scala 27:72]
  reg  latched; // @[Xbar.scala 144:30]
  wire  _bundleIn_0_aw_ready_T = latched | awIn_0_io_enq_ready; // @[Xbar.scala 146:57]
  wire  io_in_0_aw_ready = in_0_aw_ready & (latched | awIn_0_io_enq_ready); // @[Xbar.scala 146:45]
  reg  awFIFOMap_9_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_9_T_18 = ~awFIFOMap_9_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_8_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_8_T_18 = ~awFIFOMap_8_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_7_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_7_T_18 = ~awFIFOMap_7_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_6_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_6_T_18 = ~awFIFOMap_6_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_5_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_5_T_18 = ~awFIFOMap_5_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_4_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_4_T_18 = ~awFIFOMap_4_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_3_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_3_T_18 = ~awFIFOMap_3_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_2_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_2_T_18 = ~awFIFOMap_2_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_1_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_1_T_18 = ~awFIFOMap_1_count; // @[Xbar.scala 119:22]
  reg  awFIFOMap_0_count; // @[Xbar.scala 111:34]
  wire  _awFIFOMap_0_T_18 = ~awFIFOMap_0_count; // @[Xbar.scala 119:22]
  wire  _awFIFOMap_0_T_1 = io_in_0_aw_ready & auto_in_aw_valid; // @[Decoupled.scala 40:37]
  wire  _awFIFOMap_0_T_2 = awSel[0] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  anyValid_1 = auto_out_0_b_valid | auto_out_1_b_valid | auto_out_2_b_valid; // @[Xbar.scala 253:36]
  wire  _in_0_b_valid_T_4 = state_4_0 & auto_out_0_b_valid | state_4_1 & auto_out_1_b_valid | state_4_2 &
    auto_out_2_b_valid; // @[Mux.scala 27:72]
  wire  in_0_b_valid = idle_4 ? anyValid_1 : _in_0_b_valid_T_4; // @[Xbar.scala 285:22]
  wire  _awFIFOMap_0_T_4 = auto_in_b_ready & in_0_b_valid; // @[Decoupled.scala 40:37]
  wire  _awFIFOMap_0_T_5 = bSel[0] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_0_count_T_1 = awFIFOMap_0_count + _awFIFOMap_0_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_1_T_2 = arSel[1] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_1_T_6 = rSel[1] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_1_count_T_1 = arFIFOMap_1_count + _arFIFOMap_1_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_1_T_2 = awSel[1] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_1_T_5 = bSel[1] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_1_count_T_1 = awFIFOMap_1_count + _awFIFOMap_1_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_2_T_2 = arSel[2] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_2_T_6 = rSel[2] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_2_count_T_1 = arFIFOMap_2_count + _arFIFOMap_2_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_2_T_2 = awSel[2] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_2_T_5 = bSel[2] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_2_count_T_1 = awFIFOMap_2_count + _awFIFOMap_2_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_3_T_2 = arSel[3] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_3_T_6 = rSel[3] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_3_count_T_1 = arFIFOMap_3_count + _arFIFOMap_3_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_3_T_2 = awSel[3] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_3_T_5 = bSel[3] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_3_count_T_1 = awFIFOMap_3_count + _awFIFOMap_3_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_4_T_2 = arSel[4] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_4_T_6 = rSel[4] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_4_count_T_1 = arFIFOMap_4_count + _arFIFOMap_4_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_4_T_2 = awSel[4] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_4_T_5 = bSel[4] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_4_count_T_1 = awFIFOMap_4_count + _awFIFOMap_4_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_5_T_2 = arSel[5] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_5_T_6 = rSel[5] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_5_count_T_1 = arFIFOMap_5_count + _arFIFOMap_5_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_5_T_2 = awSel[5] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_5_T_5 = bSel[5] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_5_count_T_1 = awFIFOMap_5_count + _awFIFOMap_5_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_6_T_2 = arSel[6] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_6_T_6 = rSel[6] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_6_count_T_1 = arFIFOMap_6_count + _arFIFOMap_6_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_6_T_2 = awSel[6] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_6_T_5 = bSel[6] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_6_count_T_1 = awFIFOMap_6_count + _awFIFOMap_6_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_7_T_2 = arSel[7] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_7_T_6 = rSel[7] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_7_count_T_1 = arFIFOMap_7_count + _arFIFOMap_7_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_7_T_2 = awSel[7] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_7_T_5 = bSel[7] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_7_count_T_1 = awFIFOMap_7_count + _awFIFOMap_7_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_8_T_2 = arSel[8] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_8_T_6 = rSel[8] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_8_count_T_1 = arFIFOMap_8_count + _arFIFOMap_8_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_8_T_2 = awSel[8] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_8_T_5 = bSel[8] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_8_count_T_1 = awFIFOMap_8_count + _awFIFOMap_8_T_2; // @[Xbar.scala 113:30]
  wire  _arFIFOMap_9_T_2 = arSel[9] & _arFIFOMap_0_T_1; // @[Xbar.scala 126:25]
  wire  _arFIFOMap_9_T_6 = rSel[9] & _arFIFOMap_0_T_4 & in_0_r_bits_last; // @[Xbar.scala 127:45]
  wire  _arFIFOMap_9_count_T_1 = arFIFOMap_9_count + _arFIFOMap_9_T_2; // @[Xbar.scala 113:30]
  wire  _awFIFOMap_9_T_2 = awSel[9] & _awFIFOMap_0_T_1; // @[Xbar.scala 130:25]
  wire  _awFIFOMap_9_T_5 = bSel[9] & _awFIFOMap_0_T_4; // @[Xbar.scala 131:24]
  wire  _awFIFOMap_9_count_T_1 = awFIFOMap_9_count + _awFIFOMap_9_T_2; // @[Xbar.scala 113:30]
  wire  in_0_aw_valid = auto_in_aw_valid & _bundleIn_0_aw_ready_T; // @[Xbar.scala 145:45]
  wire  _T = awIn_0_io_enq_ready & awIn_0_io_enq_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_52 = _T | latched; // @[Xbar.scala 148:38 Xbar.scala 148:48 Xbar.scala 144:30]
  wire  _T_1 = in_0_aw_ready & in_0_aw_valid; // @[Decoupled.scala 40:37]
  wire  in_0_w_valid = auto_in_w_valid & awIn_0_io_deq_valid; // @[Xbar.scala 152:43]
  wire  in_0_w_ready = requestWIO_0_0 & auto_out_0_w_ready | requestWIO_0_1 & auto_out_1_w_ready | requestWIO_0_2 &
    auto_out_2_w_ready; // @[Mux.scala 27:72]
  wire  portsAROI_filtered_0_valid = auto_in_ar_valid & requestARIO_0_0; // @[Xbar.scala 229:40]
  wire  portsAROI_filtered_1_valid = auto_in_ar_valid & requestARIO_0_1; // @[Xbar.scala 229:40]
  wire  portsAROI_filtered_2_valid = auto_in_ar_valid & requestARIO_0_2; // @[Xbar.scala 229:40]
  wire  portsAWOI_filtered_0_valid = in_0_aw_valid & requestAWIO_0_0; // @[Xbar.scala 229:40]
  wire  portsAWOI_filtered_1_valid = in_0_aw_valid & requestAWIO_0_1; // @[Xbar.scala 229:40]
  wire  portsAWOI_filtered_2_valid = in_0_aw_valid & requestAWIO_0_2; // @[Xbar.scala 229:40]
  wire  _awOut_0_io_enq_bits_T_1 = ~portsAWOI_filtered_0_valid; // @[Xbar.scala 263:60]
  wire  _T_3 = ~portsAROI_filtered_0_valid; // @[Xbar.scala 263:60]
  wire  _awOut_1_io_enq_bits_T_1 = ~portsAWOI_filtered_1_valid; // @[Xbar.scala 263:60]
  wire  _T_16 = ~portsAROI_filtered_1_valid; // @[Xbar.scala 263:60]
  wire  _awOut_2_io_enq_bits_T_1 = ~portsAWOI_filtered_2_valid; // @[Xbar.scala 263:60]
  wire  _T_29 = ~portsAROI_filtered_2_valid; // @[Xbar.scala 263:60]
  wire [2:0] _readys_mask_T = readys_readys & readys_filter_lo; // @[Arbiter.scala 28:29]
  wire [3:0] _readys_mask_T_1 = {_readys_mask_T, 1'h0}; // @[package.scala 244:48]
  wire [2:0] _readys_mask_T_3 = _readys_mask_T | _readys_mask_T_1[2:0]; // @[package.scala 244:43]
  wire [4:0] _readys_mask_T_4 = {_readys_mask_T_3, 2'h0}; // @[package.scala 244:48]
  wire [2:0] _readys_mask_T_6 = _readys_mask_T_3 | _readys_mask_T_4[2:0]; // @[package.scala 244:43]
  wire  prefixOR_2 = winner_3_0 | winner_3_1; // @[Xbar.scala 262:50]
  wire  _prefixOR_T_3 = prefixOR_2 | winner_3_2; // @[Xbar.scala 262:50]
  wire  _GEN_67 = anyValid ? 1'h0 : idle_3; // @[Xbar.scala 273:21 Xbar.scala 273:28 Xbar.scala 249:23]
  wire  _GEN_68 = _arFIFOMap_0_T_4 | _GEN_67; // @[Xbar.scala 274:24 Xbar.scala 274:31]
  wire  allowed__0 = idle_3 ? readys_3_0 : state_3_0; // @[Xbar.scala 277:24]
  wire  allowed__1 = idle_3 ? readys_3_1 : state_3_1; // @[Xbar.scala 277:24]
  wire  allowed__2 = idle_3 ? readys_3_2 : state_3_2; // @[Xbar.scala 277:24]
  wire [1:0] _T_68 = muxState_3_0 ? auto_out_0_r_bits_resp : 2'h0; // @[Mux.scala 27:72]
  wire [1:0] _T_69 = muxState_3_1 ? auto_out_1_r_bits_resp : 2'h0; // @[Mux.scala 27:72]
  wire [1:0] _T_70 = muxState_3_2 ? auto_out_2_r_bits_resp : 2'h0; // @[Mux.scala 27:72]
  wire [1:0] _T_71 = _T_68 | _T_69; // @[Mux.scala 27:72]
  wire [127:0] _T_73 = muxState_3_0 ? auto_out_0_r_bits_data : 128'h0; // @[Mux.scala 27:72]
  wire [127:0] _T_74 = muxState_3_1 ? auto_out_1_r_bits_data : 128'h0; // @[Mux.scala 27:72]
  wire [127:0] _T_75 = muxState_3_2 ? auto_out_2_r_bits_data : 128'h0; // @[Mux.scala 27:72]
  wire [127:0] _T_76 = _T_73 | _T_74; // @[Mux.scala 27:72]
  wire [2:0] _readys_mask_T_8 = readys_readys_1 & readys_filter_lo_1; // @[Arbiter.scala 28:29]
  wire [3:0] _readys_mask_T_9 = {_readys_mask_T_8, 1'h0}; // @[package.scala 244:48]
  wire [2:0] _readys_mask_T_11 = _readys_mask_T_8 | _readys_mask_T_9[2:0]; // @[package.scala 244:43]
  wire [4:0] _readys_mask_T_12 = {_readys_mask_T_11, 2'h0}; // @[package.scala 244:48]
  wire [2:0] _readys_mask_T_14 = _readys_mask_T_11 | _readys_mask_T_12[2:0]; // @[package.scala 244:43]
  wire  prefixOR_2_1 = winner_4_0 | winner_4_1; // @[Xbar.scala 262:50]
  wire  _prefixOR_T_4 = prefixOR_2_1 | winner_4_2; // @[Xbar.scala 262:50]
  wire  _GEN_70 = anyValid_1 ? 1'h0 : idle_4; // @[Xbar.scala 273:21 Xbar.scala 273:28 Xbar.scala 249:23]
  wire  _GEN_71 = _awFIFOMap_0_T_4 | _GEN_70; // @[Xbar.scala 274:24 Xbar.scala 274:31]
  wire  allowed_1_0 = idle_4 ? readys_4_0 : state_4_0; // @[Xbar.scala 277:24]
  wire  allowed_1_1 = idle_4 ? readys_4_1 : state_4_1; // @[Xbar.scala 277:24]
  wire  allowed_1_2 = idle_4 ? readys_4_2 : state_4_2; // @[Xbar.scala 277:24]
  wire [1:0] _T_105 = muxState_4_0 ? auto_out_0_b_bits_resp : 2'h0; // @[Mux.scala 27:72]
  wire [1:0] _T_106 = muxState_4_1 ? auto_out_1_b_bits_resp : 2'h0; // @[Mux.scala 27:72]
  wire [1:0] _T_107 = muxState_4_2 ? auto_out_2_b_bits_resp : 2'h0; // @[Mux.scala 27:72]
  wire [1:0] _T_108 = _T_105 | _T_106; // @[Mux.scala 27:72]
  QueueCompatibility_44_inTestHarness awIn_0 ( // @[Xbar.scala 62:47]
    .clock(awIn_0_clock),
    .reset(awIn_0_reset),
    .io_enq_ready(awIn_0_io_enq_ready),
    .io_enq_valid(awIn_0_io_enq_valid),
    .io_enq_bits(awIn_0_io_enq_bits),
    .io_deq_ready(awIn_0_io_deq_ready),
    .io_deq_valid(awIn_0_io_deq_valid),
    .io_deq_bits(awIn_0_io_deq_bits)
  );
  assign auto_in_aw_ready = in_0_aw_ready & (latched | awIn_0_io_enq_ready); // @[Xbar.scala 146:45]
  assign auto_in_w_ready = in_0_w_ready & awIn_0_io_deq_valid; // @[Xbar.scala 153:43]
  assign auto_in_b_valid = idle_4 ? anyValid_1 : _in_0_b_valid_T_4; // @[Xbar.scala 285:22]
  assign auto_in_b_bits_id = _T_113 | _T_112; // @[Mux.scala 27:72]
  assign auto_in_b_bits_resp = _T_108 | _T_107; // @[Mux.scala 27:72]
  assign auto_in_ar_ready = requestARIO_0_0 & auto_out_0_ar_ready | requestARIO_0_1 & auto_out_1_ar_ready |
    requestARIO_0_2 & auto_out_2_ar_ready; // @[Mux.scala 27:72]
  assign auto_in_r_valid = idle_3 ? anyValid : _in_0_r_valid_T_4; // @[Xbar.scala 285:22]
  assign auto_in_r_bits_id = _T_81 | _T_80; // @[Mux.scala 27:72]
  assign auto_in_r_bits_data = _T_76 | _T_75; // @[Mux.scala 27:72]
  assign auto_in_r_bits_resp = _T_71 | _T_70; // @[Mux.scala 27:72]
  assign auto_in_r_bits_last = muxState_3_0 & auto_out_0_r_bits_last | muxState_3_1 & auto_out_1_r_bits_last |
    muxState_3_2 & auto_out_2_r_bits_last; // @[Mux.scala 27:72]
  assign auto_out_2_aw_valid = in_0_aw_valid & requestAWIO_0_2; // @[Xbar.scala 229:40]
  assign auto_out_2_aw_bits_id = auto_in_aw_bits_id; // @[Xbar.scala 86:47]
  assign auto_out_2_aw_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_aw_bits_len = auto_in_aw_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_aw_bits_size = auto_in_aw_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_aw_bits_burst = auto_in_aw_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_w_valid = in_0_w_valid & requestWIO_0_2; // @[Xbar.scala 229:40]
  assign auto_out_2_w_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_w_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_w_bits_last = auto_in_w_bits_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_b_ready = auto_in_b_ready & allowed_1_2; // @[Xbar.scala 279:31]
  assign auto_out_2_ar_valid = auto_in_ar_valid & requestARIO_0_2; // @[Xbar.scala 229:40]
  assign auto_out_2_ar_bits_id = auto_in_ar_bits_id; // @[Xbar.scala 87:47]
  assign auto_out_2_ar_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_ar_bits_len = auto_in_ar_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_ar_bits_size = auto_in_ar_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_ar_bits_burst = auto_in_ar_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_2_r_ready = auto_in_r_ready & allowed__2; // @[Xbar.scala 279:31]
  assign auto_out_1_aw_valid = in_0_aw_valid & requestAWIO_0_1; // @[Xbar.scala 229:40]
  assign auto_out_1_aw_bits_id = auto_in_aw_bits_id; // @[Xbar.scala 86:47]
  assign auto_out_1_aw_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_aw_bits_len = auto_in_aw_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_aw_bits_size = auto_in_aw_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_aw_bits_burst = auto_in_aw_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_w_valid = in_0_w_valid & requestWIO_0_1; // @[Xbar.scala 229:40]
  assign auto_out_1_w_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_w_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_w_bits_last = auto_in_w_bits_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_b_ready = auto_in_b_ready & allowed_1_1; // @[Xbar.scala 279:31]
  assign auto_out_1_ar_valid = auto_in_ar_valid & requestARIO_0_1; // @[Xbar.scala 229:40]
  assign auto_out_1_ar_bits_id = auto_in_ar_bits_id; // @[Xbar.scala 87:47]
  assign auto_out_1_ar_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_ar_bits_len = auto_in_ar_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_ar_bits_size = auto_in_ar_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_ar_bits_burst = auto_in_ar_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_1_r_ready = auto_in_r_ready & allowed__1; // @[Xbar.scala 279:31]
  assign auto_out_0_aw_valid = in_0_aw_valid & requestAWIO_0_0; // @[Xbar.scala 229:40]
  assign auto_out_0_aw_bits_id = auto_in_aw_bits_id; // @[Xbar.scala 86:47]
  assign auto_out_0_aw_bits_addr = auto_in_aw_bits_addr[30:0]; // @[Nodes.scala 1207:84 BundleMap.scala 247:19]
  assign auto_out_0_aw_bits_len = auto_in_aw_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_aw_bits_size = auto_in_aw_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_aw_bits_burst = auto_in_aw_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_w_valid = in_0_w_valid & requestWIO_0_0; // @[Xbar.scala 229:40]
  assign auto_out_0_w_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_w_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_w_bits_last = auto_in_w_bits_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_b_ready = auto_in_b_ready & allowed_1_0; // @[Xbar.scala 279:31]
  assign auto_out_0_ar_valid = auto_in_ar_valid & requestARIO_0_0; // @[Xbar.scala 229:40]
  assign auto_out_0_ar_bits_id = auto_in_ar_bits_id; // @[Xbar.scala 87:47]
  assign auto_out_0_ar_bits_addr = auto_in_ar_bits_addr[30:0]; // @[Nodes.scala 1207:84 BundleMap.scala 247:19]
  assign auto_out_0_ar_bits_len = auto_in_ar_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_ar_bits_size = auto_in_ar_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_ar_bits_burst = auto_in_ar_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign auto_out_0_r_ready = auto_in_r_ready & allowed__0; // @[Xbar.scala 279:31]
  assign awIn_0_clock = clock;
  assign awIn_0_reset = reset;
  assign awIn_0_io_enq_valid = auto_in_aw_valid & ~latched; // @[Xbar.scala 147:51]
  assign awIn_0_io_enq_bits = {awIn_0_io_enq_bits_hi,requestAWIO_0_0}; // @[Xbar.scala 71:75]
  assign awIn_0_io_deq_ready = auto_in_w_valid & auto_in_w_bits_last & in_0_w_ready; // @[Xbar.scala 154:74]
  always @(posedge clock) begin
    idle_3 <= reset | _GEN_68; // @[Xbar.scala 249:23 Xbar.scala 249:23]
    if (reset) begin // @[Arbiter.scala 23:23]
      readys_mask <= 3'h7; // @[Arbiter.scala 23:23]
    end else if (idle_3 & |readys_filter_lo) begin // @[Arbiter.scala 27:32]
      readys_mask <= _readys_mask_T_6; // @[Arbiter.scala 28:12]
    end
    if (reset) begin // @[Xbar.scala 268:24]
      state_3_0 <= 1'h0; // @[Xbar.scala 268:24]
    end else if (idle_3) begin // @[Xbar.scala 269:23]
      state_3_0 <= winner_3_0;
    end
    if (reset) begin // @[Xbar.scala 268:24]
      state_3_1 <= 1'h0; // @[Xbar.scala 268:24]
    end else if (idle_3) begin // @[Xbar.scala 269:23]
      state_3_1 <= winner_3_1;
    end
    if (reset) begin // @[Xbar.scala 268:24]
      state_3_2 <= 1'h0; // @[Xbar.scala 268:24]
    end else if (idle_3) begin // @[Xbar.scala 269:23]
      state_3_2 <= winner_3_2;
    end
    idle_4 <= reset | _GEN_71; // @[Xbar.scala 249:23 Xbar.scala 249:23]
    if (reset) begin // @[Arbiter.scala 23:23]
      readys_mask_1 <= 3'h7; // @[Arbiter.scala 23:23]
    end else if (idle_4 & |readys_filter_lo_1) begin // @[Arbiter.scala 27:32]
      readys_mask_1 <= _readys_mask_T_14; // @[Arbiter.scala 28:12]
    end
    if (reset) begin // @[Xbar.scala 268:24]
      state_4_0 <= 1'h0; // @[Xbar.scala 268:24]
    end else if (idle_4) begin // @[Xbar.scala 269:23]
      state_4_0 <= winner_4_0;
    end
    if (reset) begin // @[Xbar.scala 268:24]
      state_4_1 <= 1'h0; // @[Xbar.scala 268:24]
    end else if (idle_4) begin // @[Xbar.scala 269:23]
      state_4_1 <= winner_4_1;
    end
    if (reset) begin // @[Xbar.scala 268:24]
      state_4_2 <= 1'h0; // @[Xbar.scala 268:24]
    end else if (idle_4) begin // @[Xbar.scala 269:23]
      state_4_2 <= winner_4_2;
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_9_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_9_count <= _arFIFOMap_9_count_T_1 - _arFIFOMap_9_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_8_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_8_count <= _arFIFOMap_8_count_T_1 - _arFIFOMap_8_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_7_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_7_count <= _arFIFOMap_7_count_T_1 - _arFIFOMap_7_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_6_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_6_count <= _arFIFOMap_6_count_T_1 - _arFIFOMap_6_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_5_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_5_count <= _arFIFOMap_5_count_T_1 - _arFIFOMap_5_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_4_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_4_count <= _arFIFOMap_4_count_T_1 - _arFIFOMap_4_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_3_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_3_count <= _arFIFOMap_3_count_T_1 - _arFIFOMap_3_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_2_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_2_count <= _arFIFOMap_2_count_T_1 - _arFIFOMap_2_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_1_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_1_count <= _arFIFOMap_1_count_T_1 - _arFIFOMap_1_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      arFIFOMap_0_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      arFIFOMap_0_count <= _arFIFOMap_0_count_T_1 - _arFIFOMap_0_T_6; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 144:30]
      latched <= 1'h0; // @[Xbar.scala 144:30]
    end else if (_T_1) begin // @[Xbar.scala 149:32]
      latched <= 1'h0; // @[Xbar.scala 149:42]
    end else begin
      latched <= _GEN_52;
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_9_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_9_count <= _awFIFOMap_9_count_T_1 - _awFIFOMap_9_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_8_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_8_count <= _awFIFOMap_8_count_T_1 - _awFIFOMap_8_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_7_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_7_count <= _awFIFOMap_7_count_T_1 - _awFIFOMap_7_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_6_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_6_count <= _awFIFOMap_6_count_T_1 - _awFIFOMap_6_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_5_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_5_count <= _awFIFOMap_5_count_T_1 - _awFIFOMap_5_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_4_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_4_count <= _awFIFOMap_4_count_T_1 - _awFIFOMap_4_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_3_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_3_count <= _awFIFOMap_3_count_T_1 - _awFIFOMap_3_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_2_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_2_count <= _awFIFOMap_2_count_T_1 - _awFIFOMap_2_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_1_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_1_count <= _awFIFOMap_1_count_T_1 - _awFIFOMap_1_T_5; // @[Xbar.scala 113:21]
    end
    if (reset) begin // @[Xbar.scala 111:34]
      awFIFOMap_0_count <= 1'h0; // @[Xbar.scala 111:34]
    end else begin
      awFIFOMap_0_count <= _awFIFOMap_0_count_T_1 - _awFIFOMap_0_T_5; // @[Xbar.scala 113:21]
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_0_T_6 | arFIFOMap_0_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_0_T_6 | arFIFOMap_0_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_0_T_2 | _arFIFOMap_0_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_0_T_2 | _arFIFOMap_0_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_0_T_5 | awFIFOMap_0_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_0_T_5 | awFIFOMap_0_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_0_T_2 | _awFIFOMap_0_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_0_T_2 | _awFIFOMap_0_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_1_T_6 | arFIFOMap_1_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_1_T_6 | arFIFOMap_1_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_1_T_2 | _arFIFOMap_1_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_1_T_2 | _arFIFOMap_1_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_1_T_5 | awFIFOMap_1_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_1_T_5 | awFIFOMap_1_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_1_T_2 | _awFIFOMap_1_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_1_T_2 | _awFIFOMap_1_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_2_T_6 | arFIFOMap_2_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_2_T_6 | arFIFOMap_2_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_2_T_2 | _arFIFOMap_2_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_2_T_2 | _arFIFOMap_2_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_2_T_5 | awFIFOMap_2_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_2_T_5 | awFIFOMap_2_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_2_T_2 | _awFIFOMap_2_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_2_T_2 | _awFIFOMap_2_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_3_T_6 | arFIFOMap_3_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_3_T_6 | arFIFOMap_3_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_3_T_2 | _arFIFOMap_3_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_3_T_2 | _arFIFOMap_3_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_3_T_5 | awFIFOMap_3_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_3_T_5 | awFIFOMap_3_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_3_T_2 | _awFIFOMap_3_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_3_T_2 | _awFIFOMap_3_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_4_T_6 | arFIFOMap_4_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_4_T_6 | arFIFOMap_4_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_4_T_2 | _arFIFOMap_4_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_4_T_2 | _arFIFOMap_4_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_4_T_5 | awFIFOMap_4_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_4_T_5 | awFIFOMap_4_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_4_T_2 | _awFIFOMap_4_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_4_T_2 | _awFIFOMap_4_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_5_T_6 | arFIFOMap_5_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_5_T_6 | arFIFOMap_5_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_5_T_2 | _arFIFOMap_5_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_5_T_2 | _arFIFOMap_5_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_5_T_5 | awFIFOMap_5_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_5_T_5 | awFIFOMap_5_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_5_T_2 | _awFIFOMap_5_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_5_T_2 | _awFIFOMap_5_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_6_T_6 | arFIFOMap_6_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_6_T_6 | arFIFOMap_6_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_6_T_2 | _arFIFOMap_6_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_6_T_2 | _arFIFOMap_6_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_6_T_5 | awFIFOMap_6_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_6_T_5 | awFIFOMap_6_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_6_T_2 | _awFIFOMap_6_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_6_T_2 | _awFIFOMap_6_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_7_T_6 | arFIFOMap_7_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_7_T_6 | arFIFOMap_7_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_7_T_2 | _arFIFOMap_7_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_7_T_2 | _arFIFOMap_7_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_7_T_5 | awFIFOMap_7_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_7_T_5 | awFIFOMap_7_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_7_T_2 | _awFIFOMap_7_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_7_T_2 | _awFIFOMap_7_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_8_T_6 | arFIFOMap_8_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_8_T_6 | arFIFOMap_8_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_8_T_2 | _arFIFOMap_8_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_8_T_2 | _arFIFOMap_8_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_8_T_5 | awFIFOMap_8_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_8_T_5 | awFIFOMap_8_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_8_T_2 | _awFIFOMap_8_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_8_T_2 | _awFIFOMap_8_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_9_T_6 | arFIFOMap_9_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_9_T_6 | arFIFOMap_9_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_arFIFOMap_9_T_2 | _arFIFOMap_9_T_19 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_arFIFOMap_9_T_2 | _arFIFOMap_9_T_19 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_9_T_5 | awFIFOMap_9_count | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:114 assert (!resp_fire || count =/= UInt(0))\n"); // @[Xbar.scala 114:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_9_T_5 | awFIFOMap_9_count | reset)) begin
          $fatal; // @[Xbar.scala 114:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_awFIFOMap_9_T_2 | _awFIFOMap_9_T_18 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:115 assert (!req_fire  || count =/= UInt(flight))\n"
            ); // @[Xbar.scala 115:22]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_awFIFOMap_9_T_2 | _awFIFOMap_9_T_18 | reset)) begin
          $fatal; // @[Xbar.scala 115:22]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_awOut_0_io_enq_bits_T_1 | portsAWOI_filtered_0_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_awOut_0_io_enq_bits_T_1 | portsAWOI_filtered_0_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_T_3 | portsAROI_filtered_0_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_T_3 | portsAROI_filtered_0_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_awOut_1_io_enq_bits_T_1 | portsAWOI_filtered_1_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_awOut_1_io_enq_bits_T_1 | portsAWOI_filtered_1_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_T_16 | portsAROI_filtered_1_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_T_16 | portsAROI_filtered_1_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_awOut_2_io_enq_bits_T_1 | portsAWOI_filtered_2_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_awOut_2_io_enq_bits_T_1 | portsAWOI_filtered_2_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(_T_29 | portsAROI_filtered_2_valid | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(_T_29 | portsAROI_filtered_2_valid | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~((~winner_3_0 | ~winner_3_1) & (~prefixOR_2 | ~winner_3_2) | reset)) begin
          $fwrite(32'h80000002,
            "Assertion failed\n    at Xbar.scala:263 assert((prefixOR zip winner) map { case (p,w) => !p || !w } reduce {_ && _})\n"
            ); // @[Xbar.scala 263:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~((~winner_3_0 | ~winner_3_1) & (~prefixOR_2 | ~winner_3_2) | reset)) begin
          $fatal; // @[Xbar.scala 263:11]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~anyValid | _prefixOR_T_3 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~anyValid | _prefixOR_T_3 | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~((~winner_4_0 | ~winner_4_1) & (~prefixOR_2_1 | ~winner_4_2) | reset)) begin
          $fwrite(32'h80000002,
            "Assertion failed\n    at Xbar.scala:263 assert((prefixOR zip winner) map { case (p,w) => !p || !w } reduce {_ && _})\n"
            ); // @[Xbar.scala 263:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~((~winner_4_0 | ~winner_4_1) & (~prefixOR_2_1 | ~winner_4_2) | reset)) begin
          $fatal; // @[Xbar.scala 263:11]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~anyValid_1 | _prefixOR_T_4 | reset)) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Xbar.scala:265 assert (!anyValid || winner.reduce(_||_))\n"); // @[Xbar.scala 265:12]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~anyValid_1 | _prefixOR_T_4 | reset)) begin
          $fatal; // @[Xbar.scala 265:12]
        end
    `ifdef STOP_COND
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
  idle_3 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  readys_mask = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  state_3_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  state_3_1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  state_3_2 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  idle_4 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  readys_mask_1 = _RAND_6[2:0];
  _RAND_7 = {1{`RANDOM}};
  state_4_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  state_4_1 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  state_4_2 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  arFIFOMap_9_count = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  arFIFOMap_8_count = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  arFIFOMap_7_count = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  arFIFOMap_6_count = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  arFIFOMap_5_count = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  arFIFOMap_4_count = _RAND_15[0:0];
  _RAND_16 = {1{`RANDOM}};
  arFIFOMap_3_count = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  arFIFOMap_2_count = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  arFIFOMap_1_count = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  arFIFOMap_0_count = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  latched = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  awFIFOMap_9_count = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  awFIFOMap_8_count = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  awFIFOMap_7_count = _RAND_23[0:0];
  _RAND_24 = {1{`RANDOM}};
  awFIFOMap_6_count = _RAND_24[0:0];
  _RAND_25 = {1{`RANDOM}};
  awFIFOMap_5_count = _RAND_25[0:0];
  _RAND_26 = {1{`RANDOM}};
  awFIFOMap_4_count = _RAND_26[0:0];
  _RAND_27 = {1{`RANDOM}};
  awFIFOMap_3_count = _RAND_27[0:0];
  _RAND_28 = {1{`RANDOM}};
  awFIFOMap_2_count = _RAND_28[0:0];
  _RAND_29 = {1{`RANDOM}};
  awFIFOMap_1_count = _RAND_29[0:0];
  _RAND_30 = {1{`RANDOM}};
  awFIFOMap_0_count = _RAND_30[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_69_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [3:0]  io_enq_bits_id,
  input  [30:0] io_enq_bits_addr,
  input         io_enq_bits_echo_real_last,
  input         io_deq_ready,
  output        io_deq_valid,
  output [3:0]  io_deq_bits_id,
  output [30:0] io_deq_bits_addr,
  output        io_deq_bits_echo_real_last
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:1]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [30:0] ram_addr [0:1]; // @[Decoupled.scala 218:16]
  wire [30:0] ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [30:0] ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_echo_real_last [0:1]; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  value; // @[Counter.scala 60:40]
  reg  value_1; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = value == value_1; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign ram_id_io_deq_bits_MPORT_addr = value_1;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = value;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_addr_io_deq_bits_MPORT_addr = value_1;
  assign ram_addr_io_deq_bits_MPORT_data = ram_addr[ram_addr_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_addr_MPORT_data = io_enq_bits_addr;
  assign ram_addr_MPORT_addr = value;
  assign ram_addr_MPORT_mask = 1'h1;
  assign ram_addr_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_echo_real_last_io_deq_bits_MPORT_addr = value_1;
  assign ram_echo_real_last_io_deq_bits_MPORT_data = ram_echo_real_last[ram_echo_real_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_echo_real_last_MPORT_data = io_enq_bits_echo_real_last;
  assign ram_echo_real_last_MPORT_addr = value;
  assign ram_echo_real_last_MPORT_mask = 1'h1;
  assign ram_echo_real_last_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits_id = ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_addr = ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_echo_real_last = ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_addr_MPORT_en & ram_addr_MPORT_mask) begin
      ram_addr[ram_addr_MPORT_addr] <= ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_echo_real_last_MPORT_en & ram_echo_real_last_MPORT_mask) begin
      ram_echo_real_last[ram_echo_real_last_MPORT_addr] <= ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      value <= value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value_1 <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      value_1 <= value_1 + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_addr[initvar] = _RAND_1[30:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_echo_real_last[initvar] = _RAND_2[0:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  value = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  value_1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  maybe_full = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_70_inTestHarness(
  input          clock,
  input          reset,
  output         io_enq_ready,
  input          io_enq_valid,
  input  [127:0] io_enq_bits_data,
  input  [15:0]  io_enq_bits_strb,
  input          io_deq_ready,
  output         io_deq_valid,
  output [127:0] io_deq_bits_data,
  output [15:0]  io_deq_bits_strb
);
`ifdef RANDOMIZE_MEM_INIT
  reg [127:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg [127:0] ram_data [0:1]; // @[Decoupled.scala 218:16]
  wire [127:0] ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [127:0] ram_data_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_en; // @[Decoupled.scala 218:16]
  reg [15:0] ram_strb [0:1]; // @[Decoupled.scala 218:16]
  wire [15:0] ram_strb_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_strb_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [15:0] ram_strb_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_strb_MPORT_en; // @[Decoupled.scala 218:16]
  reg  value; // @[Counter.scala 60:40]
  reg  value_1; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = value == value_1; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign ram_data_io_deq_bits_MPORT_addr = value_1;
  assign ram_data_io_deq_bits_MPORT_data = ram_data[ram_data_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_data_MPORT_data = io_enq_bits_data;
  assign ram_data_MPORT_addr = value;
  assign ram_data_MPORT_mask = 1'h1;
  assign ram_data_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_strb_io_deq_bits_MPORT_addr = value_1;
  assign ram_strb_io_deq_bits_MPORT_data = ram_strb[ram_strb_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_strb_MPORT_data = io_enq_bits_strb;
  assign ram_strb_MPORT_addr = value;
  assign ram_strb_MPORT_mask = 1'h1;
  assign ram_strb_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits_data = ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_strb = ram_strb_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_data_MPORT_en & ram_data_MPORT_mask) begin
      ram_data[ram_data_MPORT_addr] <= ram_data_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_strb_MPORT_en & ram_strb_MPORT_mask) begin
      ram_strb[ram_strb_MPORT_addr] <= ram_strb_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      value <= value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value_1 <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      value_1 <= value_1 + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {4{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_data[initvar] = _RAND_0[127:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_strb[initvar] = _RAND_1[15:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{`RANDOM}};
  value = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  value_1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  maybe_full = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_73_inTestHarness(
  input          clock,
  input          reset,
  output         io_enq_ready,
  input          io_enq_valid,
  input  [3:0]   io_enq_bits_id,
  input  [127:0] io_enq_bits_data,
  input  [1:0]   io_enq_bits_resp,
  input          io_enq_bits_echo_real_last,
  input          io_deq_ready,
  output         io_deq_valid,
  output [3:0]   io_deq_bits_id,
  output [127:0] io_deq_bits_data,
  output [1:0]   io_deq_bits_resp,
  output         io_deq_bits_echo_real_last,
  output         io_deq_bits_last
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [127:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:1]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [127:0] ram_data [0:1]; // @[Decoupled.scala 218:16]
  wire [127:0] ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [127:0] ram_data_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_data_MPORT_en; // @[Decoupled.scala 218:16]
  reg [1:0] ram_resp [0:1]; // @[Decoupled.scala 218:16]
  wire [1:0] ram_resp_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_resp_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [1:0] ram_resp_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_resp_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_echo_real_last [0:1]; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_last [0:1]; // @[Decoupled.scala 218:16]
  wire  ram_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  value; // @[Counter.scala 60:40]
  reg  value_1; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = value == value_1; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign ram_id_io_deq_bits_MPORT_addr = value_1;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = value;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_data_io_deq_bits_MPORT_addr = value_1;
  assign ram_data_io_deq_bits_MPORT_data = ram_data[ram_data_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_data_MPORT_data = io_enq_bits_data;
  assign ram_data_MPORT_addr = value;
  assign ram_data_MPORT_mask = 1'h1;
  assign ram_data_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_resp_io_deq_bits_MPORT_addr = value_1;
  assign ram_resp_io_deq_bits_MPORT_data = ram_resp[ram_resp_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_resp_MPORT_data = io_enq_bits_resp;
  assign ram_resp_MPORT_addr = value;
  assign ram_resp_MPORT_mask = 1'h1;
  assign ram_resp_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_echo_real_last_io_deq_bits_MPORT_addr = value_1;
  assign ram_echo_real_last_io_deq_bits_MPORT_data = ram_echo_real_last[ram_echo_real_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_echo_real_last_MPORT_data = io_enq_bits_echo_real_last;
  assign ram_echo_real_last_MPORT_addr = value;
  assign ram_echo_real_last_MPORT_mask = 1'h1;
  assign ram_echo_real_last_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_last_io_deq_bits_MPORT_addr = value_1;
  assign ram_last_io_deq_bits_MPORT_data = ram_last[ram_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_last_MPORT_data = 1'h1;
  assign ram_last_MPORT_addr = value;
  assign ram_last_MPORT_mask = 1'h1;
  assign ram_last_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits_id = ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_data = ram_data_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_resp = ram_resp_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_echo_real_last = ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_last = ram_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_data_MPORT_en & ram_data_MPORT_mask) begin
      ram_data[ram_data_MPORT_addr] <= ram_data_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_resp_MPORT_en & ram_resp_MPORT_mask) begin
      ram_resp[ram_resp_MPORT_addr] <= ram_resp_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_echo_real_last_MPORT_en & ram_echo_real_last_MPORT_mask) begin
      ram_echo_real_last[ram_echo_real_last_MPORT_addr] <= ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_last_MPORT_en & ram_last_MPORT_mask) begin
      ram_last[ram_last_MPORT_addr] <= ram_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      value <= value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value_1 <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      value_1 <= value_1 + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {4{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_data[initvar] = _RAND_1[127:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_resp[initvar] = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_echo_real_last[initvar] = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_last[initvar] = _RAND_4[0:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_5 = {1{`RANDOM}};
  value = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  value_1 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  maybe_full = _RAND_7[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4Buffer_2_inTestHarness(
  input          clock,
  input          reset,
  output         auto_in_aw_ready,
  input          auto_in_aw_valid,
  input  [3:0]   auto_in_aw_bits_id,
  input  [30:0]  auto_in_aw_bits_addr,
  input          auto_in_aw_bits_echo_real_last,
  output         auto_in_w_ready,
  input          auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_b_ready,
  output         auto_in_b_valid,
  output [3:0]   auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output         auto_in_b_bits_echo_real_last,
  output         auto_in_ar_ready,
  input          auto_in_ar_valid,
  input  [3:0]   auto_in_ar_bits_id,
  input  [30:0]  auto_in_ar_bits_addr,
  input          auto_in_ar_bits_echo_real_last,
  input          auto_in_r_ready,
  output         auto_in_r_valid,
  output [3:0]   auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output         auto_in_r_bits_echo_real_last,
  output         auto_in_r_bits_last,
  input          auto_out_aw_ready,
  output         auto_out_aw_valid,
  output [3:0]   auto_out_aw_bits_id,
  output [30:0]  auto_out_aw_bits_addr,
  output         auto_out_aw_bits_echo_real_last,
  input          auto_out_w_ready,
  output         auto_out_w_valid,
  output [127:0] auto_out_w_bits_data,
  output [15:0]  auto_out_w_bits_strb,
  output         auto_out_b_ready,
  input          auto_out_b_valid,
  input  [3:0]   auto_out_b_bits_id,
  input  [1:0]   auto_out_b_bits_resp,
  input          auto_out_b_bits_echo_real_last,
  input          auto_out_ar_ready,
  output         auto_out_ar_valid,
  output [3:0]   auto_out_ar_bits_id,
  output [30:0]  auto_out_ar_bits_addr,
  output         auto_out_ar_bits_echo_real_last,
  output         auto_out_r_ready,
  input          auto_out_r_valid,
  input  [3:0]   auto_out_r_bits_id,
  input  [127:0] auto_out_r_bits_data,
  input  [1:0]   auto_out_r_bits_resp,
  input          auto_out_r_bits_echo_real_last
);
  wire  bundleOut_0_aw_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_aw_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [30:0] bundleOut_0_aw_deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_aw_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [30:0] bundleOut_0_aw_deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [127:0] bundleOut_0_w_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [15:0] bundleOut_0_w_deq_io_enq_bits_strb; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [127:0] bundleOut_0_w_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [15:0] bundleOut_0_w_deq_io_deq_bits_strb; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_b_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_b_deq_io_enq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_b_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_b_deq_io_deq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_ar_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [30:0] bundleOut_0_ar_deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_ar_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [30:0] bundleOut_0_ar_deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_r_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [127:0] bundleIn_0_r_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_r_deq_io_enq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_r_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [127:0] bundleIn_0_r_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_r_deq_io_deq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_bits_last; // @[Decoupled.scala 296:21]
  Queue_69_inTestHarness bundleOut_0_aw_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_aw_deq_clock),
    .reset(bundleOut_0_aw_deq_reset),
    .io_enq_ready(bundleOut_0_aw_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_aw_deq_io_enq_valid),
    .io_enq_bits_id(bundleOut_0_aw_deq_io_enq_bits_id),
    .io_enq_bits_addr(bundleOut_0_aw_deq_io_enq_bits_addr),
    .io_enq_bits_echo_real_last(bundleOut_0_aw_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleOut_0_aw_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_aw_deq_io_deq_valid),
    .io_deq_bits_id(bundleOut_0_aw_deq_io_deq_bits_id),
    .io_deq_bits_addr(bundleOut_0_aw_deq_io_deq_bits_addr),
    .io_deq_bits_echo_real_last(bundleOut_0_aw_deq_io_deq_bits_echo_real_last)
  );
  Queue_70_inTestHarness bundleOut_0_w_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_w_deq_clock),
    .reset(bundleOut_0_w_deq_reset),
    .io_enq_ready(bundleOut_0_w_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_w_deq_io_enq_valid),
    .io_enq_bits_data(bundleOut_0_w_deq_io_enq_bits_data),
    .io_enq_bits_strb(bundleOut_0_w_deq_io_enq_bits_strb),
    .io_deq_ready(bundleOut_0_w_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_w_deq_io_deq_valid),
    .io_deq_bits_data(bundleOut_0_w_deq_io_deq_bits_data),
    .io_deq_bits_strb(bundleOut_0_w_deq_io_deq_bits_strb)
  );
  Queue_63_inTestHarness bundleIn_0_b_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleIn_0_b_deq_clock),
    .reset(bundleIn_0_b_deq_reset),
    .io_enq_ready(bundleIn_0_b_deq_io_enq_ready),
    .io_enq_valid(bundleIn_0_b_deq_io_enq_valid),
    .io_enq_bits_id(bundleIn_0_b_deq_io_enq_bits_id),
    .io_enq_bits_resp(bundleIn_0_b_deq_io_enq_bits_resp),
    .io_enq_bits_echo_real_last(bundleIn_0_b_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleIn_0_b_deq_io_deq_ready),
    .io_deq_valid(bundleIn_0_b_deq_io_deq_valid),
    .io_deq_bits_id(bundleIn_0_b_deq_io_deq_bits_id),
    .io_deq_bits_resp(bundleIn_0_b_deq_io_deq_bits_resp),
    .io_deq_bits_echo_real_last(bundleIn_0_b_deq_io_deq_bits_echo_real_last)
  );
  Queue_69_inTestHarness bundleOut_0_ar_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_ar_deq_clock),
    .reset(bundleOut_0_ar_deq_reset),
    .io_enq_ready(bundleOut_0_ar_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_ar_deq_io_enq_valid),
    .io_enq_bits_id(bundleOut_0_ar_deq_io_enq_bits_id),
    .io_enq_bits_addr(bundleOut_0_ar_deq_io_enq_bits_addr),
    .io_enq_bits_echo_real_last(bundleOut_0_ar_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleOut_0_ar_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_ar_deq_io_deq_valid),
    .io_deq_bits_id(bundleOut_0_ar_deq_io_deq_bits_id),
    .io_deq_bits_addr(bundleOut_0_ar_deq_io_deq_bits_addr),
    .io_deq_bits_echo_real_last(bundleOut_0_ar_deq_io_deq_bits_echo_real_last)
  );
  Queue_73_inTestHarness bundleIn_0_r_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleIn_0_r_deq_clock),
    .reset(bundleIn_0_r_deq_reset),
    .io_enq_ready(bundleIn_0_r_deq_io_enq_ready),
    .io_enq_valid(bundleIn_0_r_deq_io_enq_valid),
    .io_enq_bits_id(bundleIn_0_r_deq_io_enq_bits_id),
    .io_enq_bits_data(bundleIn_0_r_deq_io_enq_bits_data),
    .io_enq_bits_resp(bundleIn_0_r_deq_io_enq_bits_resp),
    .io_enq_bits_echo_real_last(bundleIn_0_r_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleIn_0_r_deq_io_deq_ready),
    .io_deq_valid(bundleIn_0_r_deq_io_deq_valid),
    .io_deq_bits_id(bundleIn_0_r_deq_io_deq_bits_id),
    .io_deq_bits_data(bundleIn_0_r_deq_io_deq_bits_data),
    .io_deq_bits_resp(bundleIn_0_r_deq_io_deq_bits_resp),
    .io_deq_bits_echo_real_last(bundleIn_0_r_deq_io_deq_bits_echo_real_last),
    .io_deq_bits_last(bundleIn_0_r_deq_io_deq_bits_last)
  );
  assign auto_in_aw_ready = bundleOut_0_aw_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_w_ready = bundleOut_0_w_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_b_valid = bundleIn_0_b_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_in_b_bits_id = bundleIn_0_b_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_b_bits_resp = bundleIn_0_b_deq_io_deq_bits_resp; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_b_bits_echo_real_last = bundleIn_0_b_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_ar_ready = bundleOut_0_ar_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_r_valid = bundleIn_0_r_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_in_r_bits_id = bundleIn_0_r_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_data = bundleIn_0_r_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_resp = bundleIn_0_r_deq_io_deq_bits_resp; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_echo_real_last = bundleIn_0_r_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_last = bundleIn_0_r_deq_io_deq_bits_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_valid = bundleOut_0_aw_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_aw_bits_id = bundleOut_0_aw_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_addr = bundleOut_0_aw_deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_echo_real_last = bundleOut_0_aw_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_valid = bundleOut_0_w_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_w_bits_data = bundleOut_0_w_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_bits_strb = bundleOut_0_w_deq_io_deq_bits_strb; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_b_ready = bundleIn_0_b_deq_io_enq_ready; // @[Nodes.scala 1207:84 Decoupled.scala 299:17]
  assign auto_out_ar_valid = bundleOut_0_ar_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_ar_bits_id = bundleOut_0_ar_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_addr = bundleOut_0_ar_deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_echo_real_last = bundleOut_0_ar_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_r_ready = bundleIn_0_r_deq_io_enq_ready; // @[Nodes.scala 1207:84 Decoupled.scala 299:17]
  assign bundleOut_0_aw_deq_clock = clock;
  assign bundleOut_0_aw_deq_reset = reset;
  assign bundleOut_0_aw_deq_io_enq_valid = auto_in_aw_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_id = auto_in_aw_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_echo_real_last = auto_in_aw_bits_echo_real_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_deq_ready = auto_out_aw_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleOut_0_w_deq_clock = clock;
  assign bundleOut_0_w_deq_reset = reset;
  assign bundleOut_0_w_deq_io_enq_valid = auto_in_w_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_enq_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_enq_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_deq_ready = auto_out_w_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_clock = clock;
  assign bundleIn_0_b_deq_reset = reset;
  assign bundleIn_0_b_deq_io_enq_valid = auto_out_b_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_id = auto_out_b_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_resp = auto_out_b_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_echo_real_last = auto_out_b_bits_echo_real_last; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_deq_ready = auto_in_b_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_clock = clock;
  assign bundleOut_0_ar_deq_reset = reset;
  assign bundleOut_0_ar_deq_io_enq_valid = auto_in_ar_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_id = auto_in_ar_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_echo_real_last = auto_in_ar_bits_echo_real_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_deq_ready = auto_out_ar_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_clock = clock;
  assign bundleIn_0_r_deq_reset = reset;
  assign bundleIn_0_r_deq_io_enq_valid = auto_out_r_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_id = auto_out_r_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_data = auto_out_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_resp = auto_out_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_echo_real_last = auto_out_r_bits_echo_real_last; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_deq_ready = auto_in_r_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module Queue_74_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [3:0]  io_enq_bits_id,
  input  [30:0] io_enq_bits_addr,
  input  [7:0]  io_enq_bits_len,
  input  [2:0]  io_enq_bits_size,
  input  [1:0]  io_enq_bits_burst,
  input         io_deq_ready,
  output        io_deq_valid,
  output [3:0]  io_deq_bits_id,
  output [30:0] io_deq_bits_addr,
  output [7:0]  io_deq_bits_len,
  output [2:0]  io_deq_bits_size,
  output [1:0]  io_deq_bits_burst
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:0]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [30:0] ram_addr [0:0]; // @[Decoupled.scala 218:16]
  wire [30:0] ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [30:0] ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_en; // @[Decoupled.scala 218:16]
  reg [7:0] ram_len [0:0]; // @[Decoupled.scala 218:16]
  wire [7:0] ram_len_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_len_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [7:0] ram_len_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_en; // @[Decoupled.scala 218:16]
  reg [2:0] ram_size [0:0]; // @[Decoupled.scala 218:16]
  wire [2:0] ram_size_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_size_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [2:0] ram_size_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_en; // @[Decoupled.scala 218:16]
  reg [1:0] ram_burst [0:0]; // @[Decoupled.scala 218:16]
  wire [1:0] ram_burst_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_burst_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [1:0] ram_burst_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_en; // @[Decoupled.scala 218:16]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  empty = ~maybe_full; // @[Decoupled.scala 224:28]
  wire  _do_enq_T = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  _do_deq_T = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_15 = io_deq_ready ? 1'h0 : _do_enq_T; // @[Decoupled.scala 249:27 Decoupled.scala 249:36]
  wire  do_enq = empty ? _GEN_15 : _do_enq_T; // @[Decoupled.scala 246:18]
  wire  do_deq = empty ? 1'h0 : _do_deq_T; // @[Decoupled.scala 246:18 Decoupled.scala 248:14]
  assign ram_id_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = 1'h0;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_addr_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_addr_io_deq_bits_MPORT_data = ram_addr[ram_addr_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_addr_MPORT_data = io_enq_bits_addr;
  assign ram_addr_MPORT_addr = 1'h0;
  assign ram_addr_MPORT_mask = 1'h1;
  assign ram_addr_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_len_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_len_io_deq_bits_MPORT_data = ram_len[ram_len_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_len_MPORT_data = io_enq_bits_len;
  assign ram_len_MPORT_addr = 1'h0;
  assign ram_len_MPORT_mask = 1'h1;
  assign ram_len_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_size_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_size_io_deq_bits_MPORT_data = ram_size[ram_size_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_size_MPORT_data = io_enq_bits_size;
  assign ram_size_MPORT_addr = 1'h0;
  assign ram_size_MPORT_mask = 1'h1;
  assign ram_size_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_burst_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_burst_io_deq_bits_MPORT_data = ram_burst[ram_burst_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_burst_MPORT_data = io_enq_bits_burst;
  assign ram_burst_MPORT_addr = 1'h0;
  assign ram_burst_MPORT_mask = 1'h1;
  assign ram_burst_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign io_enq_ready = ~maybe_full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = io_enq_valid | ~empty; // @[Decoupled.scala 245:25 Decoupled.scala 245:40 Decoupled.scala 240:16]
  assign io_deq_bits_id = empty ? io_enq_bits_id : ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_addr = empty ? io_enq_bits_addr : ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_len = empty ? io_enq_bits_len : ram_len_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_size = empty ? io_enq_bits_size : ram_size_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_burst = empty ? io_enq_bits_burst : ram_burst_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_addr_MPORT_en & ram_addr_MPORT_mask) begin
      ram_addr[ram_addr_MPORT_addr] <= ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_len_MPORT_en & ram_len_MPORT_mask) begin
      ram_len[ram_len_MPORT_addr] <= ram_len_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_size_MPORT_en & ram_size_MPORT_mask) begin
      ram_size[ram_size_MPORT_addr] <= ram_size_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_burst_MPORT_en & ram_burst_MPORT_mask) begin
      ram_burst[ram_burst_MPORT_addr] <= ram_burst_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      if (empty) begin // @[Decoupled.scala 246:18]
        if (io_deq_ready) begin // @[Decoupled.scala 249:27]
          maybe_full <= 1'h0; // @[Decoupled.scala 249:36]
        end else begin
          maybe_full <= _do_enq_T;
        end
      end else begin
        maybe_full <= _do_enq_T;
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_addr[initvar] = _RAND_1[30:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_len[initvar] = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_size[initvar] = _RAND_3[2:0];
  _RAND_4 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_burst[initvar] = _RAND_4[1:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_5 = {1{`RANDOM}};
  maybe_full = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4Fragmenter_2_inTestHarness(
  input          clock,
  input          reset,
  output         auto_in_aw_ready,
  input          auto_in_aw_valid,
  input  [3:0]   auto_in_aw_bits_id,
  input  [30:0]  auto_in_aw_bits_addr,
  input  [7:0]   auto_in_aw_bits_len,
  input  [2:0]   auto_in_aw_bits_size,
  input  [1:0]   auto_in_aw_bits_burst,
  output         auto_in_w_ready,
  input          auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_w_bits_last,
  input          auto_in_b_ready,
  output         auto_in_b_valid,
  output [3:0]   auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output         auto_in_ar_ready,
  input          auto_in_ar_valid,
  input  [3:0]   auto_in_ar_bits_id,
  input  [30:0]  auto_in_ar_bits_addr,
  input  [7:0]   auto_in_ar_bits_len,
  input  [2:0]   auto_in_ar_bits_size,
  input  [1:0]   auto_in_ar_bits_burst,
  input          auto_in_r_ready,
  output         auto_in_r_valid,
  output [3:0]   auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output         auto_in_r_bits_last,
  input          auto_out_aw_ready,
  output         auto_out_aw_valid,
  output [3:0]   auto_out_aw_bits_id,
  output [30:0]  auto_out_aw_bits_addr,
  output         auto_out_aw_bits_echo_real_last,
  input          auto_out_w_ready,
  output         auto_out_w_valid,
  output [127:0] auto_out_w_bits_data,
  output [15:0]  auto_out_w_bits_strb,
  output         auto_out_b_ready,
  input          auto_out_b_valid,
  input  [3:0]   auto_out_b_bits_id,
  input  [1:0]   auto_out_b_bits_resp,
  input          auto_out_b_bits_echo_real_last,
  input          auto_out_ar_ready,
  output         auto_out_ar_valid,
  output [3:0]   auto_out_ar_bits_id,
  output [30:0]  auto_out_ar_bits_addr,
  output         auto_out_ar_bits_echo_real_last,
  output         auto_out_r_ready,
  input          auto_out_r_valid,
  input  [3:0]   auto_out_r_bits_id,
  input  [127:0] auto_out_r_bits_data,
  input  [1:0]   auto_out_r_bits_resp,
  input          auto_out_r_bits_echo_real_last,
  input          auto_out_r_bits_last
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
`endif // RANDOMIZE_REG_INIT
  wire  deq_clock; // @[Decoupled.scala 296:21]
  wire  deq_reset; // @[Decoupled.scala 296:21]
  wire  deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [30:0] deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_io_enq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_io_enq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_io_enq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [30:0] deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_io_deq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_io_deq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_io_deq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_1_clock; // @[Decoupled.scala 296:21]
  wire  deq_1_reset; // @[Decoupled.scala 296:21]
  wire  deq_1_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  deq_1_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_1_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [30:0] deq_1_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_1_io_enq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_1_io_enq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_1_io_enq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_1_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  deq_1_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_1_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [30:0] deq_1_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_1_io_deq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_1_io_deq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_1_io_deq_bits_burst; // @[Decoupled.scala 296:21]
  wire  in_w_deq_clock; // @[Decoupled.scala 296:21]
  wire  in_w_deq_reset; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [127:0] in_w_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [15:0] in_w_deq_io_enq_bits_strb; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_bits_last; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [127:0] in_w_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [15:0] in_w_deq_io_deq_bits_strb; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_bits_last; // @[Decoupled.scala 296:21]
  reg  busy; // @[Fragmenter.scala 60:29]
  reg [30:0] r_addr; // @[Fragmenter.scala 61:25]
  reg [7:0] r_len; // @[Fragmenter.scala 62:25]
  wire [7:0] irr_bits_len = deq_io_deq_bits_len; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [7:0] len = busy ? r_len : irr_bits_len; // @[Fragmenter.scala 64:23]
  wire [30:0] irr_bits_addr = deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [30:0] addr = busy ? r_addr : irr_bits_addr; // @[Fragmenter.scala 65:23]
  wire [1:0] irr_bits_burst = deq_io_deq_bits_burst; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  fixed = irr_bits_burst == 2'h0; // @[Fragmenter.scala 92:34]
  wire [2:0] irr_bits_size = deq_io_deq_bits_size; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [15:0] _inc_addr_T = 16'h1 << irr_bits_size; // @[Fragmenter.scala 100:38]
  wire [30:0] _GEN_48 = {{15'd0}, _inc_addr_T}; // @[Fragmenter.scala 100:29]
  wire [30:0] inc_addr = addr + _GEN_48; // @[Fragmenter.scala 100:29]
  wire [15:0] _wrapMask_T = {irr_bits_len,8'hff}; // @[Cat.scala 30:58]
  wire [22:0] _GEN_49 = {{7'd0}, _wrapMask_T}; // @[Bundles.scala 30:21]
  wire [22:0] _wrapMask_T_1 = _GEN_49 << irr_bits_size; // @[Bundles.scala 30:21]
  wire [14:0] wrapMask = _wrapMask_T_1[22:8]; // @[Bundles.scala 30:30]
  wire [30:0] _GEN_50 = {{16'd0}, wrapMask}; // @[Fragmenter.scala 104:33]
  wire [30:0] _mux_addr_T = inc_addr & _GEN_50; // @[Fragmenter.scala 104:33]
  wire [30:0] _mux_addr_T_1 = ~irr_bits_addr; // @[Fragmenter.scala 104:49]
  wire [30:0] _mux_addr_T_2 = _mux_addr_T_1 | _GEN_50; // @[Fragmenter.scala 104:62]
  wire [30:0] _mux_addr_T_3 = ~_mux_addr_T_2; // @[Fragmenter.scala 104:47]
  wire [30:0] _mux_addr_T_4 = _mux_addr_T | _mux_addr_T_3; // @[Fragmenter.scala 104:45]
  wire  ar_last = 8'h0 == len; // @[Fragmenter.scala 110:27]
  wire [30:0] _out_bits_addr_T = ~addr; // @[Fragmenter.scala 122:28]
  wire [10:0] _out_bits_addr_T_2 = 11'hf << irr_bits_size; // @[package.scala 234:77]
  wire [3:0] _out_bits_addr_T_4 = ~_out_bits_addr_T_2[3:0]; // @[package.scala 234:46]
  wire [30:0] _GEN_52 = {{27'd0}, _out_bits_addr_T_4}; // @[Fragmenter.scala 122:34]
  wire [30:0] _out_bits_addr_T_5 = _out_bits_addr_T | _GEN_52; // @[Fragmenter.scala 122:34]
  wire  irr_valid = deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _T_2 = auto_out_ar_ready & irr_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_53 = {{1'd0}, len}; // @[Fragmenter.scala 127:25]
  wire [8:0] _r_len_T_1 = _GEN_53 - 9'h1; // @[Fragmenter.scala 127:25]
  wire [8:0] _GEN_4 = _T_2 ? _r_len_T_1 : {{1'd0}, r_len}; // @[Fragmenter.scala 124:27 Fragmenter.scala 127:18 Fragmenter.scala 62:25]
  reg  busy_1; // @[Fragmenter.scala 60:29]
  reg [30:0] r_addr_1; // @[Fragmenter.scala 61:25]
  reg [7:0] r_len_1; // @[Fragmenter.scala 62:25]
  wire [7:0] irr_1_bits_len = deq_1_io_deq_bits_len; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [7:0] len_1 = busy_1 ? r_len_1 : irr_1_bits_len; // @[Fragmenter.scala 64:23]
  wire [30:0] irr_1_bits_addr = deq_1_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [30:0] addr_1 = busy_1 ? r_addr_1 : irr_1_bits_addr; // @[Fragmenter.scala 65:23]
  wire [1:0] irr_1_bits_burst = deq_1_io_deq_bits_burst; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  fixed_1 = irr_1_bits_burst == 2'h0; // @[Fragmenter.scala 92:34]
  wire [2:0] irr_1_bits_size = deq_1_io_deq_bits_size; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [15:0] _inc_addr_T_2 = 16'h1 << irr_1_bits_size; // @[Fragmenter.scala 100:38]
  wire [30:0] _GEN_58 = {{15'd0}, _inc_addr_T_2}; // @[Fragmenter.scala 100:29]
  wire [30:0] inc_addr_1 = addr_1 + _GEN_58; // @[Fragmenter.scala 100:29]
  wire [15:0] _wrapMask_T_2 = {irr_1_bits_len,8'hff}; // @[Cat.scala 30:58]
  wire [22:0] _GEN_59 = {{7'd0}, _wrapMask_T_2}; // @[Bundles.scala 30:21]
  wire [22:0] _wrapMask_T_3 = _GEN_59 << irr_1_bits_size; // @[Bundles.scala 30:21]
  wire [14:0] wrapMask_1 = _wrapMask_T_3[22:8]; // @[Bundles.scala 30:30]
  wire [30:0] _GEN_60 = {{16'd0}, wrapMask_1}; // @[Fragmenter.scala 104:33]
  wire [30:0] _mux_addr_T_5 = inc_addr_1 & _GEN_60; // @[Fragmenter.scala 104:33]
  wire [30:0] _mux_addr_T_6 = ~irr_1_bits_addr; // @[Fragmenter.scala 104:49]
  wire [30:0] _mux_addr_T_7 = _mux_addr_T_6 | _GEN_60; // @[Fragmenter.scala 104:62]
  wire [30:0] _mux_addr_T_8 = ~_mux_addr_T_7; // @[Fragmenter.scala 104:47]
  wire [30:0] _mux_addr_T_9 = _mux_addr_T_5 | _mux_addr_T_8; // @[Fragmenter.scala 104:45]
  wire  aw_last = 8'h0 == len_1; // @[Fragmenter.scala 110:27]
  reg [8:0] w_counter; // @[Fragmenter.scala 164:30]
  wire  w_idle = w_counter == 9'h0; // @[Fragmenter.scala 165:30]
  reg  wbeats_latched; // @[Fragmenter.scala 150:35]
  wire  _in_aw_ready_T = w_idle | wbeats_latched; // @[Fragmenter.scala 158:52]
  wire  in_aw_ready = auto_out_aw_ready & (w_idle | wbeats_latched); // @[Fragmenter.scala 158:35]
  wire [30:0] _out_bits_addr_T_7 = ~addr_1; // @[Fragmenter.scala 122:28]
  wire [10:0] _out_bits_addr_T_9 = 11'hf << irr_1_bits_size; // @[package.scala 234:77]
  wire [3:0] _out_bits_addr_T_11 = ~_out_bits_addr_T_9[3:0]; // @[package.scala 234:46]
  wire [30:0] _GEN_62 = {{27'd0}, _out_bits_addr_T_11}; // @[Fragmenter.scala 122:34]
  wire [30:0] _out_bits_addr_T_12 = _out_bits_addr_T_7 | _GEN_62; // @[Fragmenter.scala 122:34]
  wire  irr_1_valid = deq_1_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _T_5 = in_aw_ready & irr_1_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_63 = {{1'd0}, len_1}; // @[Fragmenter.scala 127:25]
  wire [8:0] _r_len_T_3 = _GEN_63 - 9'h1; // @[Fragmenter.scala 127:25]
  wire [8:0] _GEN_9 = _T_5 ? _r_len_T_3 : {{1'd0}, r_len_1}; // @[Fragmenter.scala 124:27 Fragmenter.scala 127:18 Fragmenter.scala 62:25]
  wire  wbeats_valid = irr_1_valid & ~wbeats_latched; // @[Fragmenter.scala 159:35]
  wire  _GEN_10 = wbeats_valid & w_idle | wbeats_latched; // @[Fragmenter.scala 153:43 Fragmenter.scala 153:60 Fragmenter.scala 150:35]
  wire  bundleOut_0_aw_valid = irr_1_valid & _in_aw_ready_T; // @[Fragmenter.scala 157:35]
  wire  _T_7 = auto_out_aw_ready & bundleOut_0_aw_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _w_todo_T = wbeats_valid ? 9'h1 : 9'h0; // @[Fragmenter.scala 166:35]
  wire [8:0] w_todo = w_idle ? _w_todo_T : w_counter; // @[Fragmenter.scala 166:23]
  wire  w_last = w_todo == 9'h1; // @[Fragmenter.scala 167:27]
  wire  in_w_valid = in_w_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _bundleOut_0_w_valid_T_1 = ~w_idle | wbeats_valid; // @[Fragmenter.scala 173:51]
  wire  bundleOut_0_w_valid = in_w_valid & (~w_idle | wbeats_valid); // @[Fragmenter.scala 173:33]
  wire  _w_counter_T = auto_out_w_ready & bundleOut_0_w_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_64 = {{8'd0}, _w_counter_T}; // @[Fragmenter.scala 168:27]
  wire [8:0] _w_counter_T_2 = w_todo - _GEN_64; // @[Fragmenter.scala 168:27]
  wire  in_w_bits_last = in_w_deq_io_deq_bits_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  bundleOut_0_b_ready = auto_in_b_ready | ~auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 189:33]
  reg [1:0] error_0; // @[Fragmenter.scala 192:26]
  reg [1:0] error_1; // @[Fragmenter.scala 192:26]
  reg [1:0] error_2; // @[Fragmenter.scala 192:26]
  reg [1:0] error_3; // @[Fragmenter.scala 192:26]
  reg [1:0] error_4; // @[Fragmenter.scala 192:26]
  reg [1:0] error_5; // @[Fragmenter.scala 192:26]
  reg [1:0] error_6; // @[Fragmenter.scala 192:26]
  reg [1:0] error_7; // @[Fragmenter.scala 192:26]
  reg [1:0] error_8; // @[Fragmenter.scala 192:26]
  reg [1:0] error_9; // @[Fragmenter.scala 192:26]
  reg [1:0] error_10; // @[Fragmenter.scala 192:26]
  reg [1:0] error_11; // @[Fragmenter.scala 192:26]
  reg [1:0] error_12; // @[Fragmenter.scala 192:26]
  reg [1:0] error_13; // @[Fragmenter.scala 192:26]
  reg [1:0] error_14; // @[Fragmenter.scala 192:26]
  reg [1:0] error_15; // @[Fragmenter.scala 192:26]
  wire [1:0] _GEN_13 = 4'h1 == auto_out_b_bits_id ? error_1 : error_0; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_14 = 4'h2 == auto_out_b_bits_id ? error_2 : _GEN_13; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_15 = 4'h3 == auto_out_b_bits_id ? error_3 : _GEN_14; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_16 = 4'h4 == auto_out_b_bits_id ? error_4 : _GEN_15; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_17 = 4'h5 == auto_out_b_bits_id ? error_5 : _GEN_16; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_18 = 4'h6 == auto_out_b_bits_id ? error_6 : _GEN_17; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_19 = 4'h7 == auto_out_b_bits_id ? error_7 : _GEN_18; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_20 = 4'h8 == auto_out_b_bits_id ? error_8 : _GEN_19; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_21 = 4'h9 == auto_out_b_bits_id ? error_9 : _GEN_20; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_22 = 4'ha == auto_out_b_bits_id ? error_10 : _GEN_21; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_23 = 4'hb == auto_out_b_bits_id ? error_11 : _GEN_22; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_24 = 4'hc == auto_out_b_bits_id ? error_12 : _GEN_23; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_25 = 4'hd == auto_out_b_bits_id ? error_13 : _GEN_24; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_26 = 4'he == auto_out_b_bits_id ? error_14 : _GEN_25; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_27 = 4'hf == auto_out_b_bits_id ? error_15 : _GEN_26; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [15:0] _T_22 = 16'h1 << auto_out_b_bits_id; // @[OneHot.scala 65:12]
  wire  _T_40 = bundleOut_0_b_ready & auto_out_b_valid; // @[Decoupled.scala 40:37]
  wire [1:0] _error_0_T = error_0 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_1_T = error_1 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_2_T = error_2 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_3_T = error_3 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_4_T = error_4 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_5_T = error_5 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_6_T = error_6 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_7_T = error_7 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_8_T = error_8 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_9_T = error_9 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_10_T = error_10 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_11_T = error_11 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_12_T = error_12 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_13_T = error_13 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_14_T = error_14 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_15_T = error_15 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  Queue_74_inTestHarness deq ( // @[Decoupled.scala 296:21]
    .clock(deq_clock),
    .reset(deq_reset),
    .io_enq_ready(deq_io_enq_ready),
    .io_enq_valid(deq_io_enq_valid),
    .io_enq_bits_id(deq_io_enq_bits_id),
    .io_enq_bits_addr(deq_io_enq_bits_addr),
    .io_enq_bits_len(deq_io_enq_bits_len),
    .io_enq_bits_size(deq_io_enq_bits_size),
    .io_enq_bits_burst(deq_io_enq_bits_burst),
    .io_deq_ready(deq_io_deq_ready),
    .io_deq_valid(deq_io_deq_valid),
    .io_deq_bits_id(deq_io_deq_bits_id),
    .io_deq_bits_addr(deq_io_deq_bits_addr),
    .io_deq_bits_len(deq_io_deq_bits_len),
    .io_deq_bits_size(deq_io_deq_bits_size),
    .io_deq_bits_burst(deq_io_deq_bits_burst)
  );
  Queue_74_inTestHarness deq_1 ( // @[Decoupled.scala 296:21]
    .clock(deq_1_clock),
    .reset(deq_1_reset),
    .io_enq_ready(deq_1_io_enq_ready),
    .io_enq_valid(deq_1_io_enq_valid),
    .io_enq_bits_id(deq_1_io_enq_bits_id),
    .io_enq_bits_addr(deq_1_io_enq_bits_addr),
    .io_enq_bits_len(deq_1_io_enq_bits_len),
    .io_enq_bits_size(deq_1_io_enq_bits_size),
    .io_enq_bits_burst(deq_1_io_enq_bits_burst),
    .io_deq_ready(deq_1_io_deq_ready),
    .io_deq_valid(deq_1_io_deq_valid),
    .io_deq_bits_id(deq_1_io_deq_bits_id),
    .io_deq_bits_addr(deq_1_io_deq_bits_addr),
    .io_deq_bits_len(deq_1_io_deq_bits_len),
    .io_deq_bits_size(deq_1_io_deq_bits_size),
    .io_deq_bits_burst(deq_1_io_deq_bits_burst)
  );
  Queue_28_inTestHarness in_w_deq ( // @[Decoupled.scala 296:21]
    .clock(in_w_deq_clock),
    .reset(in_w_deq_reset),
    .io_enq_ready(in_w_deq_io_enq_ready),
    .io_enq_valid(in_w_deq_io_enq_valid),
    .io_enq_bits_data(in_w_deq_io_enq_bits_data),
    .io_enq_bits_strb(in_w_deq_io_enq_bits_strb),
    .io_enq_bits_last(in_w_deq_io_enq_bits_last),
    .io_deq_ready(in_w_deq_io_deq_ready),
    .io_deq_valid(in_w_deq_io_deq_valid),
    .io_deq_bits_data(in_w_deq_io_deq_bits_data),
    .io_deq_bits_strb(in_w_deq_io_deq_bits_strb),
    .io_deq_bits_last(in_w_deq_io_deq_bits_last)
  );
  assign auto_in_aw_ready = deq_1_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_w_ready = in_w_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_b_valid = auto_out_b_valid & auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 188:33]
  assign auto_in_b_bits_id = auto_out_b_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_b_bits_resp = auto_out_b_bits_resp | _GEN_27; // @[Fragmenter.scala 193:41]
  assign auto_in_ar_ready = deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_r_valid = auto_out_r_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_id = auto_out_r_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_data = auto_out_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_resp = auto_out_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_last = auto_out_r_bits_last & auto_out_r_bits_echo_real_last; // @[Fragmenter.scala 183:41]
  assign auto_out_aw_valid = irr_1_valid & _in_aw_ready_T; // @[Fragmenter.scala 157:35]
  assign auto_out_aw_bits_id = deq_1_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_addr = ~_out_bits_addr_T_12; // @[Fragmenter.scala 122:26]
  assign auto_out_aw_bits_echo_real_last = 8'h0 == len_1; // @[Fragmenter.scala 110:27]
  assign auto_out_w_valid = in_w_valid & (~w_idle | wbeats_valid); // @[Fragmenter.scala 173:33]
  assign auto_out_w_bits_data = in_w_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_bits_strb = in_w_deq_io_deq_bits_strb; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_b_ready = auto_in_b_ready | ~auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 189:33]
  assign auto_out_ar_valid = deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_ar_bits_id = deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_addr = ~_out_bits_addr_T_5; // @[Fragmenter.scala 122:26]
  assign auto_out_ar_bits_echo_real_last = 8'h0 == len; // @[Fragmenter.scala 110:27]
  assign auto_out_r_ready = auto_in_r_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_clock = clock;
  assign deq_reset = reset;
  assign deq_io_enq_valid = auto_in_ar_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_id = auto_in_ar_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_len = auto_in_ar_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_size = auto_in_ar_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_burst = auto_in_ar_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_deq_ready = auto_out_ar_ready & ar_last; // @[Fragmenter.scala 111:30]
  assign deq_1_clock = clock;
  assign deq_1_reset = reset;
  assign deq_1_io_enq_valid = auto_in_aw_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_id = auto_in_aw_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_len = auto_in_aw_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_size = auto_in_aw_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_burst = auto_in_aw_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_deq_ready = in_aw_ready & aw_last; // @[Fragmenter.scala 111:30]
  assign in_w_deq_clock = clock;
  assign in_w_deq_reset = reset;
  assign in_w_deq_io_enq_valid = auto_in_w_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_last = auto_in_w_bits_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_deq_ready = auto_out_w_ready & _bundleOut_0_w_valid_T_1; // @[Fragmenter.scala 174:33]
  always @(posedge clock) begin
    if (reset) begin // @[Fragmenter.scala 60:29]
      busy <= 1'h0; // @[Fragmenter.scala 60:29]
    end else if (_T_2) begin // @[Fragmenter.scala 124:27]
      busy <= ~ar_last; // @[Fragmenter.scala 125:16]
    end
    if (_T_2) begin // @[Fragmenter.scala 124:27]
      if (fixed) begin // @[Fragmenter.scala 106:60]
        r_addr <= irr_bits_addr; // @[Fragmenter.scala 107:20]
      end else if (irr_bits_burst == 2'h2) begin // @[Fragmenter.scala 103:59]
        r_addr <= _mux_addr_T_4; // @[Fragmenter.scala 104:20]
      end else begin
        r_addr <= inc_addr;
      end
    end
    r_len <= _GEN_4[7:0];
    if (reset) begin // @[Fragmenter.scala 60:29]
      busy_1 <= 1'h0; // @[Fragmenter.scala 60:29]
    end else if (_T_5) begin // @[Fragmenter.scala 124:27]
      busy_1 <= ~aw_last; // @[Fragmenter.scala 125:16]
    end
    if (_T_5) begin // @[Fragmenter.scala 124:27]
      if (fixed_1) begin // @[Fragmenter.scala 106:60]
        r_addr_1 <= irr_1_bits_addr; // @[Fragmenter.scala 107:20]
      end else if (irr_1_bits_burst == 2'h2) begin // @[Fragmenter.scala 103:59]
        r_addr_1 <= _mux_addr_T_9; // @[Fragmenter.scala 104:20]
      end else begin
        r_addr_1 <= inc_addr_1;
      end
    end
    r_len_1 <= _GEN_9[7:0];
    if (reset) begin // @[Fragmenter.scala 164:30]
      w_counter <= 9'h0; // @[Fragmenter.scala 164:30]
    end else begin
      w_counter <= _w_counter_T_2; // @[Fragmenter.scala 168:17]
    end
    if (reset) begin // @[Fragmenter.scala 150:35]
      wbeats_latched <= 1'h0; // @[Fragmenter.scala 150:35]
    end else if (_T_7) begin // @[Fragmenter.scala 154:28]
      wbeats_latched <= 1'h0; // @[Fragmenter.scala 154:45]
    end else begin
      wbeats_latched <= _GEN_10;
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_0 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[0] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_0 <= 2'h0;
      end else begin
        error_0 <= _error_0_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_1 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[1] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_1 <= 2'h0;
      end else begin
        error_1 <= _error_1_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_2 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[2] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_2 <= 2'h0;
      end else begin
        error_2 <= _error_2_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_3 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[3] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_3 <= 2'h0;
      end else begin
        error_3 <= _error_3_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_4 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[4] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_4 <= 2'h0;
      end else begin
        error_4 <= _error_4_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_5 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[5] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_5 <= 2'h0;
      end else begin
        error_5 <= _error_5_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_6 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[6] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_6 <= 2'h0;
      end else begin
        error_6 <= _error_6_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_7 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[7] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_7 <= 2'h0;
      end else begin
        error_7 <= _error_7_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_8 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[8] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_8 <= 2'h0;
      end else begin
        error_8 <= _error_8_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_9 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[9] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_9 <= 2'h0;
      end else begin
        error_9 <= _error_9_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_10 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[10] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_10 <= 2'h0;
      end else begin
        error_10 <= _error_10_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_11 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[11] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_11 <= 2'h0;
      end else begin
        error_11 <= _error_11_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_12 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[12] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_12 <= 2'h0;
      end else begin
        error_12 <= _error_12_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_13 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[13] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_13 <= 2'h0;
      end else begin
        error_13 <= _error_13_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_14 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[14] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_14 <= 2'h0;
      end else begin
        error_14 <= _error_14_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_15 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[15] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_15 <= 2'h0;
      end else begin
        error_15 <= _error_15_T;
      end
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_w_counter_T | w_todo != 9'h0 | reset)) begin
          $fwrite(32'h80000002,
            "Assertion failed\n    at Fragmenter.scala:169 assert (!out.w.fire() || w_todo =/= UInt(0)) // underflow impossible\n"
            ); // @[Fragmenter.scala 169:14]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_w_counter_T | w_todo != 9'h0 | reset)) begin
          $fatal; // @[Fragmenter.scala 169:14]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~bundleOut_0_w_valid | ~in_w_bits_last | w_last | reset)) begin
          $fwrite(32'h80000002,
            "Assertion failed\n    at Fragmenter.scala:178 assert (!out.w.valid || !in_w.bits.last || w_last)\n"); // @[Fragmenter.scala 178:14]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~bundleOut_0_w_valid | ~in_w_bits_last | w_last | reset)) begin
          $fatal; // @[Fragmenter.scala 178:14]
        end
    `ifdef STOP_COND
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
  busy = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  r_addr = _RAND_1[30:0];
  _RAND_2 = {1{`RANDOM}};
  r_len = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  busy_1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  r_addr_1 = _RAND_4[30:0];
  _RAND_5 = {1{`RANDOM}};
  r_len_1 = _RAND_5[7:0];
  _RAND_6 = {1{`RANDOM}};
  w_counter = _RAND_6[8:0];
  _RAND_7 = {1{`RANDOM}};
  wbeats_latched = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  error_0 = _RAND_8[1:0];
  _RAND_9 = {1{`RANDOM}};
  error_1 = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  error_2 = _RAND_10[1:0];
  _RAND_11 = {1{`RANDOM}};
  error_3 = _RAND_11[1:0];
  _RAND_12 = {1{`RANDOM}};
  error_4 = _RAND_12[1:0];
  _RAND_13 = {1{`RANDOM}};
  error_5 = _RAND_13[1:0];
  _RAND_14 = {1{`RANDOM}};
  error_6 = _RAND_14[1:0];
  _RAND_15 = {1{`RANDOM}};
  error_7 = _RAND_15[1:0];
  _RAND_16 = {1{`RANDOM}};
  error_8 = _RAND_16[1:0];
  _RAND_17 = {1{`RANDOM}};
  error_9 = _RAND_17[1:0];
  _RAND_18 = {1{`RANDOM}};
  error_10 = _RAND_18[1:0];
  _RAND_19 = {1{`RANDOM}};
  error_11 = _RAND_19[1:0];
  _RAND_20 = {1{`RANDOM}};
  error_12 = _RAND_20[1:0];
  _RAND_21 = {1{`RANDOM}};
  error_13 = _RAND_21[1:0];
  _RAND_22 = {1{`RANDOM}};
  error_14 = _RAND_22[1:0];
  _RAND_23 = {1{`RANDOM}};
  error_15 = _RAND_23[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_77_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [3:0]  io_enq_bits_id,
  input  [31:0] io_enq_bits_addr,
  input         io_enq_bits_echo_real_last,
  input         io_deq_ready,
  output        io_deq_valid,
  output [3:0]  io_deq_bits_id,
  output [31:0] io_deq_bits_addr,
  output        io_deq_bits_echo_real_last
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:1]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [31:0] ram_addr [0:1]; // @[Decoupled.scala 218:16]
  wire [31:0] ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [31:0] ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_en; // @[Decoupled.scala 218:16]
  reg  ram_echo_real_last [0:1]; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_echo_real_last_MPORT_en; // @[Decoupled.scala 218:16]
  reg  value; // @[Counter.scala 60:40]
  reg  value_1; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = value == value_1; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign ram_id_io_deq_bits_MPORT_addr = value_1;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = value;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_addr_io_deq_bits_MPORT_addr = value_1;
  assign ram_addr_io_deq_bits_MPORT_data = ram_addr[ram_addr_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_addr_MPORT_data = io_enq_bits_addr;
  assign ram_addr_MPORT_addr = value;
  assign ram_addr_MPORT_mask = 1'h1;
  assign ram_addr_MPORT_en = io_enq_ready & io_enq_valid;
  assign ram_echo_real_last_io_deq_bits_MPORT_addr = value_1;
  assign ram_echo_real_last_io_deq_bits_MPORT_data = ram_echo_real_last[ram_echo_real_last_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_echo_real_last_MPORT_data = io_enq_bits_echo_real_last;
  assign ram_echo_real_last_MPORT_addr = value;
  assign ram_echo_real_last_MPORT_mask = 1'h1;
  assign ram_echo_real_last_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits_id = ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_addr = ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  assign io_deq_bits_echo_real_last = ram_echo_real_last_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_addr_MPORT_en & ram_addr_MPORT_mask) begin
      ram_addr[ram_addr_MPORT_addr] <= ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_echo_real_last_MPORT_en & ram_echo_real_last_MPORT_mask) begin
      ram_echo_real_last[ram_echo_real_last_MPORT_addr] <= ram_echo_real_last_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      value <= value + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      value_1 <= 1'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      value_1 <= value_1 + 1'h1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_addr[initvar] = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 2; initvar = initvar+1)
    ram_echo_real_last[initvar] = _RAND_2[0:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  value = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  value_1 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  maybe_full = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4Buffer_3_inTestHarness(
  input          clock,
  input          reset,
  output         auto_in_aw_ready,
  input          auto_in_aw_valid,
  input  [3:0]   auto_in_aw_bits_id,
  input  [31:0]  auto_in_aw_bits_addr,
  input          auto_in_aw_bits_echo_real_last,
  output         auto_in_w_ready,
  input          auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_b_ready,
  output         auto_in_b_valid,
  output [3:0]   auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output         auto_in_b_bits_echo_real_last,
  output         auto_in_ar_ready,
  input          auto_in_ar_valid,
  input  [3:0]   auto_in_ar_bits_id,
  input  [31:0]  auto_in_ar_bits_addr,
  input          auto_in_ar_bits_echo_real_last,
  input          auto_in_r_ready,
  output         auto_in_r_valid,
  output [3:0]   auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output         auto_in_r_bits_echo_real_last,
  output         auto_in_r_bits_last,
  input          auto_out_aw_ready,
  output         auto_out_aw_valid,
  output [3:0]   auto_out_aw_bits_id,
  output [31:0]  auto_out_aw_bits_addr,
  output         auto_out_aw_bits_echo_real_last,
  input          auto_out_w_ready,
  output         auto_out_w_valid,
  output [127:0] auto_out_w_bits_data,
  output [15:0]  auto_out_w_bits_strb,
  output         auto_out_b_ready,
  input          auto_out_b_valid,
  input  [3:0]   auto_out_b_bits_id,
  input  [1:0]   auto_out_b_bits_resp,
  input          auto_out_b_bits_echo_real_last,
  input          auto_out_ar_ready,
  output         auto_out_ar_valid,
  output [3:0]   auto_out_ar_bits_id,
  output [31:0]  auto_out_ar_bits_addr,
  output         auto_out_ar_bits_echo_real_last,
  output         auto_out_r_ready,
  input          auto_out_r_valid,
  input  [3:0]   auto_out_r_bits_id,
  input  [127:0] auto_out_r_bits_data,
  input  [1:0]   auto_out_r_bits_resp,
  input          auto_out_r_bits_echo_real_last
);
  wire  bundleOut_0_aw_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_aw_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [31:0] bundleOut_0_aw_deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_aw_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [31:0] bundleOut_0_aw_deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_aw_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [127:0] bundleOut_0_w_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [15:0] bundleOut_0_w_deq_io_enq_bits_strb; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_w_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [127:0] bundleOut_0_w_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [15:0] bundleOut_0_w_deq_io_deq_bits_strb; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_b_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_b_deq_io_enq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_b_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_b_deq_io_deq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_b_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_ar_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [31:0] bundleOut_0_ar_deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleOut_0_ar_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [31:0] bundleOut_0_ar_deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire  bundleOut_0_ar_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_clock; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_reset; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_r_deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [127:0] bundleIn_0_r_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_r_deq_io_enq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_enq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] bundleIn_0_r_deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [127:0] bundleIn_0_r_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [1:0] bundleIn_0_r_deq_io_deq_bits_resp; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 296:21]
  wire  bundleIn_0_r_deq_io_deq_bits_last; // @[Decoupled.scala 296:21]
  Queue_77_inTestHarness bundleOut_0_aw_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_aw_deq_clock),
    .reset(bundleOut_0_aw_deq_reset),
    .io_enq_ready(bundleOut_0_aw_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_aw_deq_io_enq_valid),
    .io_enq_bits_id(bundleOut_0_aw_deq_io_enq_bits_id),
    .io_enq_bits_addr(bundleOut_0_aw_deq_io_enq_bits_addr),
    .io_enq_bits_echo_real_last(bundleOut_0_aw_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleOut_0_aw_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_aw_deq_io_deq_valid),
    .io_deq_bits_id(bundleOut_0_aw_deq_io_deq_bits_id),
    .io_deq_bits_addr(bundleOut_0_aw_deq_io_deq_bits_addr),
    .io_deq_bits_echo_real_last(bundleOut_0_aw_deq_io_deq_bits_echo_real_last)
  );
  Queue_70_inTestHarness bundleOut_0_w_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_w_deq_clock),
    .reset(bundleOut_0_w_deq_reset),
    .io_enq_ready(bundleOut_0_w_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_w_deq_io_enq_valid),
    .io_enq_bits_data(bundleOut_0_w_deq_io_enq_bits_data),
    .io_enq_bits_strb(bundleOut_0_w_deq_io_enq_bits_strb),
    .io_deq_ready(bundleOut_0_w_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_w_deq_io_deq_valid),
    .io_deq_bits_data(bundleOut_0_w_deq_io_deq_bits_data),
    .io_deq_bits_strb(bundleOut_0_w_deq_io_deq_bits_strb)
  );
  Queue_63_inTestHarness bundleIn_0_b_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleIn_0_b_deq_clock),
    .reset(bundleIn_0_b_deq_reset),
    .io_enq_ready(bundleIn_0_b_deq_io_enq_ready),
    .io_enq_valid(bundleIn_0_b_deq_io_enq_valid),
    .io_enq_bits_id(bundleIn_0_b_deq_io_enq_bits_id),
    .io_enq_bits_resp(bundleIn_0_b_deq_io_enq_bits_resp),
    .io_enq_bits_echo_real_last(bundleIn_0_b_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleIn_0_b_deq_io_deq_ready),
    .io_deq_valid(bundleIn_0_b_deq_io_deq_valid),
    .io_deq_bits_id(bundleIn_0_b_deq_io_deq_bits_id),
    .io_deq_bits_resp(bundleIn_0_b_deq_io_deq_bits_resp),
    .io_deq_bits_echo_real_last(bundleIn_0_b_deq_io_deq_bits_echo_real_last)
  );
  Queue_77_inTestHarness bundleOut_0_ar_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleOut_0_ar_deq_clock),
    .reset(bundleOut_0_ar_deq_reset),
    .io_enq_ready(bundleOut_0_ar_deq_io_enq_ready),
    .io_enq_valid(bundleOut_0_ar_deq_io_enq_valid),
    .io_enq_bits_id(bundleOut_0_ar_deq_io_enq_bits_id),
    .io_enq_bits_addr(bundleOut_0_ar_deq_io_enq_bits_addr),
    .io_enq_bits_echo_real_last(bundleOut_0_ar_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleOut_0_ar_deq_io_deq_ready),
    .io_deq_valid(bundleOut_0_ar_deq_io_deq_valid),
    .io_deq_bits_id(bundleOut_0_ar_deq_io_deq_bits_id),
    .io_deq_bits_addr(bundleOut_0_ar_deq_io_deq_bits_addr),
    .io_deq_bits_echo_real_last(bundleOut_0_ar_deq_io_deq_bits_echo_real_last)
  );
  Queue_73_inTestHarness bundleIn_0_r_deq ( // @[Decoupled.scala 296:21]
    .clock(bundleIn_0_r_deq_clock),
    .reset(bundleIn_0_r_deq_reset),
    .io_enq_ready(bundleIn_0_r_deq_io_enq_ready),
    .io_enq_valid(bundleIn_0_r_deq_io_enq_valid),
    .io_enq_bits_id(bundleIn_0_r_deq_io_enq_bits_id),
    .io_enq_bits_data(bundleIn_0_r_deq_io_enq_bits_data),
    .io_enq_bits_resp(bundleIn_0_r_deq_io_enq_bits_resp),
    .io_enq_bits_echo_real_last(bundleIn_0_r_deq_io_enq_bits_echo_real_last),
    .io_deq_ready(bundleIn_0_r_deq_io_deq_ready),
    .io_deq_valid(bundleIn_0_r_deq_io_deq_valid),
    .io_deq_bits_id(bundleIn_0_r_deq_io_deq_bits_id),
    .io_deq_bits_data(bundleIn_0_r_deq_io_deq_bits_data),
    .io_deq_bits_resp(bundleIn_0_r_deq_io_deq_bits_resp),
    .io_deq_bits_echo_real_last(bundleIn_0_r_deq_io_deq_bits_echo_real_last),
    .io_deq_bits_last(bundleIn_0_r_deq_io_deq_bits_last)
  );
  assign auto_in_aw_ready = bundleOut_0_aw_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_w_ready = bundleOut_0_w_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_b_valid = bundleIn_0_b_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_in_b_bits_id = bundleIn_0_b_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_b_bits_resp = bundleIn_0_b_deq_io_deq_bits_resp; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_b_bits_echo_real_last = bundleIn_0_b_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_ar_ready = bundleOut_0_ar_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_r_valid = bundleIn_0_r_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_in_r_bits_id = bundleIn_0_r_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_data = bundleIn_0_r_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_resp = bundleIn_0_r_deq_io_deq_bits_resp; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_echo_real_last = bundleIn_0_r_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_in_r_bits_last = bundleIn_0_r_deq_io_deq_bits_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_valid = bundleOut_0_aw_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_aw_bits_id = bundleOut_0_aw_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_addr = bundleOut_0_aw_deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_echo_real_last = bundleOut_0_aw_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_valid = bundleOut_0_w_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_w_bits_data = bundleOut_0_w_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_bits_strb = bundleOut_0_w_deq_io_deq_bits_strb; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_b_ready = bundleIn_0_b_deq_io_enq_ready; // @[Nodes.scala 1207:84 Decoupled.scala 299:17]
  assign auto_out_ar_valid = bundleOut_0_ar_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_ar_bits_id = bundleOut_0_ar_deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_addr = bundleOut_0_ar_deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_echo_real_last = bundleOut_0_ar_deq_io_deq_bits_echo_real_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_r_ready = bundleIn_0_r_deq_io_enq_ready; // @[Nodes.scala 1207:84 Decoupled.scala 299:17]
  assign bundleOut_0_aw_deq_clock = clock;
  assign bundleOut_0_aw_deq_reset = reset;
  assign bundleOut_0_aw_deq_io_enq_valid = auto_in_aw_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_id = auto_in_aw_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_enq_bits_echo_real_last = auto_in_aw_bits_echo_real_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_aw_deq_io_deq_ready = auto_out_aw_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleOut_0_w_deq_clock = clock;
  assign bundleOut_0_w_deq_reset = reset;
  assign bundleOut_0_w_deq_io_enq_valid = auto_in_w_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_enq_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_enq_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_w_deq_io_deq_ready = auto_out_w_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_clock = clock;
  assign bundleIn_0_b_deq_reset = reset;
  assign bundleIn_0_b_deq_io_enq_valid = auto_out_b_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_id = auto_out_b_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_resp = auto_out_b_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_enq_bits_echo_real_last = auto_out_b_bits_echo_real_last; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_b_deq_io_deq_ready = auto_in_b_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_clock = clock;
  assign bundleOut_0_ar_deq_reset = reset;
  assign bundleOut_0_ar_deq_io_enq_valid = auto_in_ar_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_id = auto_in_ar_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_enq_bits_echo_real_last = auto_in_ar_bits_echo_real_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign bundleOut_0_ar_deq_io_deq_ready = auto_out_ar_ready; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_clock = clock;
  assign bundleIn_0_r_deq_reset = reset;
  assign bundleIn_0_r_deq_io_enq_valid = auto_out_r_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_id = auto_out_r_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_data = auto_out_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_resp = auto_out_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_enq_bits_echo_real_last = auto_out_r_bits_echo_real_last; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign bundleIn_0_r_deq_io_deq_ready = auto_in_r_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
endmodule
module Queue_82_inTestHarness(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [3:0]  io_enq_bits_id,
  input  [31:0] io_enq_bits_addr,
  input  [7:0]  io_enq_bits_len,
  input  [2:0]  io_enq_bits_size,
  input  [1:0]  io_enq_bits_burst,
  input         io_deq_ready,
  output        io_deq_valid,
  output [3:0]  io_deq_bits_id,
  output [31:0] io_deq_bits_addr,
  output [7:0]  io_deq_bits_len,
  output [2:0]  io_deq_bits_size,
  output [1:0]  io_deq_bits_burst
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] ram_id [0:0]; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [3:0] ram_id_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_id_MPORT_en; // @[Decoupled.scala 218:16]
  reg [31:0] ram_addr [0:0]; // @[Decoupled.scala 218:16]
  wire [31:0] ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [31:0] ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_addr_MPORT_en; // @[Decoupled.scala 218:16]
  reg [7:0] ram_len [0:0]; // @[Decoupled.scala 218:16]
  wire [7:0] ram_len_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_len_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [7:0] ram_len_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_len_MPORT_en; // @[Decoupled.scala 218:16]
  reg [2:0] ram_size [0:0]; // @[Decoupled.scala 218:16]
  wire [2:0] ram_size_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_size_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [2:0] ram_size_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_size_MPORT_en; // @[Decoupled.scala 218:16]
  reg [1:0] ram_burst [0:0]; // @[Decoupled.scala 218:16]
  wire [1:0] ram_burst_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_burst_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [1:0] ram_burst_MPORT_data; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_burst_MPORT_en; // @[Decoupled.scala 218:16]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  empty = ~maybe_full; // @[Decoupled.scala 224:28]
  wire  _do_enq_T = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  _do_deq_T = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  wire  _GEN_15 = io_deq_ready ? 1'h0 : _do_enq_T; // @[Decoupled.scala 249:27 Decoupled.scala 249:36]
  wire  do_enq = empty ? _GEN_15 : _do_enq_T; // @[Decoupled.scala 246:18]
  wire  do_deq = empty ? 1'h0 : _do_deq_T; // @[Decoupled.scala 246:18 Decoupled.scala 248:14]
  assign ram_id_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_id_io_deq_bits_MPORT_data = ram_id[ram_id_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_id_MPORT_data = io_enq_bits_id;
  assign ram_id_MPORT_addr = 1'h0;
  assign ram_id_MPORT_mask = 1'h1;
  assign ram_id_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_addr_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_addr_io_deq_bits_MPORT_data = ram_addr[ram_addr_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_addr_MPORT_data = io_enq_bits_addr;
  assign ram_addr_MPORT_addr = 1'h0;
  assign ram_addr_MPORT_mask = 1'h1;
  assign ram_addr_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_len_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_len_io_deq_bits_MPORT_data = ram_len[ram_len_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_len_MPORT_data = io_enq_bits_len;
  assign ram_len_MPORT_addr = 1'h0;
  assign ram_len_MPORT_mask = 1'h1;
  assign ram_len_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_size_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_size_io_deq_bits_MPORT_data = ram_size[ram_size_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_size_MPORT_data = io_enq_bits_size;
  assign ram_size_MPORT_addr = 1'h0;
  assign ram_size_MPORT_mask = 1'h1;
  assign ram_size_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign ram_burst_io_deq_bits_MPORT_addr = 1'h0;
  assign ram_burst_io_deq_bits_MPORT_data = ram_burst[ram_burst_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_burst_MPORT_data = io_enq_bits_burst;
  assign ram_burst_MPORT_addr = 1'h0;
  assign ram_burst_MPORT_mask = 1'h1;
  assign ram_burst_MPORT_en = empty ? _GEN_15 : _do_enq_T;
  assign io_enq_ready = ~maybe_full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = io_enq_valid | ~empty; // @[Decoupled.scala 245:25 Decoupled.scala 245:40 Decoupled.scala 240:16]
  assign io_deq_bits_id = empty ? io_enq_bits_id : ram_id_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_addr = empty ? io_enq_bits_addr : ram_addr_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_len = empty ? io_enq_bits_len : ram_len_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_size = empty ? io_enq_bits_size : ram_size_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  assign io_deq_bits_burst = empty ? io_enq_bits_burst : ram_burst_io_deq_bits_MPORT_data; // @[Decoupled.scala 246:18 Decoupled.scala 247:19 Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_id_MPORT_en & ram_id_MPORT_mask) begin
      ram_id[ram_id_MPORT_addr] <= ram_id_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_addr_MPORT_en & ram_addr_MPORT_mask) begin
      ram_addr[ram_addr_MPORT_addr] <= ram_addr_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_len_MPORT_en & ram_len_MPORT_mask) begin
      ram_len[ram_len_MPORT_addr] <= ram_len_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_size_MPORT_en & ram_size_MPORT_mask) begin
      ram_size[ram_size_MPORT_addr] <= ram_size_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if(ram_burst_MPORT_en & ram_burst_MPORT_mask) begin
      ram_burst[ram_burst_MPORT_addr] <= ram_burst_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      if (empty) begin // @[Decoupled.scala 246:18]
        if (io_deq_ready) begin // @[Decoupled.scala 249:27]
          maybe_full <= 1'h0; // @[Decoupled.scala 249:36]
        end else begin
          maybe_full <= _do_enq_T;
        end
      end else begin
        maybe_full <= _do_enq_T;
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_id[initvar] = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_addr[initvar] = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_len[initvar] = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_size[initvar] = _RAND_3[2:0];
  _RAND_4 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1; initvar = initvar+1)
    ram_burst[initvar] = _RAND_4[1:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_5 = {1{`RANDOM}};
  maybe_full = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXI4Fragmenter_3_inTestHarness(
  input          clock,
  input          reset,
  output         auto_in_aw_ready,
  input          auto_in_aw_valid,
  input  [3:0]   auto_in_aw_bits_id,
  input  [31:0]  auto_in_aw_bits_addr,
  input  [7:0]   auto_in_aw_bits_len,
  input  [2:0]   auto_in_aw_bits_size,
  input  [1:0]   auto_in_aw_bits_burst,
  output         auto_in_w_ready,
  input          auto_in_w_valid,
  input  [127:0] auto_in_w_bits_data,
  input  [15:0]  auto_in_w_bits_strb,
  input          auto_in_w_bits_last,
  input          auto_in_b_ready,
  output         auto_in_b_valid,
  output [3:0]   auto_in_b_bits_id,
  output [1:0]   auto_in_b_bits_resp,
  output         auto_in_ar_ready,
  input          auto_in_ar_valid,
  input  [3:0]   auto_in_ar_bits_id,
  input  [31:0]  auto_in_ar_bits_addr,
  input  [7:0]   auto_in_ar_bits_len,
  input  [2:0]   auto_in_ar_bits_size,
  input  [1:0]   auto_in_ar_bits_burst,
  input          auto_in_r_ready,
  output         auto_in_r_valid,
  output [3:0]   auto_in_r_bits_id,
  output [127:0] auto_in_r_bits_data,
  output [1:0]   auto_in_r_bits_resp,
  output         auto_in_r_bits_last,
  input          auto_out_aw_ready,
  output         auto_out_aw_valid,
  output [3:0]   auto_out_aw_bits_id,
  output [31:0]  auto_out_aw_bits_addr,
  output         auto_out_aw_bits_echo_real_last,
  input          auto_out_w_ready,
  output         auto_out_w_valid,
  output [127:0] auto_out_w_bits_data,
  output [15:0]  auto_out_w_bits_strb,
  output         auto_out_b_ready,
  input          auto_out_b_valid,
  input  [3:0]   auto_out_b_bits_id,
  input  [1:0]   auto_out_b_bits_resp,
  input          auto_out_b_bits_echo_real_last,
  input          auto_out_ar_ready,
  output         auto_out_ar_valid,
  output [3:0]   auto_out_ar_bits_id,
  output [31:0]  auto_out_ar_bits_addr,
  output         auto_out_ar_bits_echo_real_last,
  output         auto_out_r_ready,
  input          auto_out_r_valid,
  input  [3:0]   auto_out_r_bits_id,
  input  [127:0] auto_out_r_bits_data,
  input  [1:0]   auto_out_r_bits_resp,
  input          auto_out_r_bits_echo_real_last,
  input          auto_out_r_bits_last
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
`endif // RANDOMIZE_REG_INIT
  wire  deq_clock; // @[Decoupled.scala 296:21]
  wire  deq_reset; // @[Decoupled.scala 296:21]
  wire  deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [31:0] deq_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_io_enq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_io_enq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_io_enq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [31:0] deq_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_io_deq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_io_deq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_io_deq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_1_clock; // @[Decoupled.scala 296:21]
  wire  deq_1_reset; // @[Decoupled.scala 296:21]
  wire  deq_1_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  deq_1_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_1_io_enq_bits_id; // @[Decoupled.scala 296:21]
  wire [31:0] deq_1_io_enq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_1_io_enq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_1_io_enq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_1_io_enq_bits_burst; // @[Decoupled.scala 296:21]
  wire  deq_1_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  deq_1_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [3:0] deq_1_io_deq_bits_id; // @[Decoupled.scala 296:21]
  wire [31:0] deq_1_io_deq_bits_addr; // @[Decoupled.scala 296:21]
  wire [7:0] deq_1_io_deq_bits_len; // @[Decoupled.scala 296:21]
  wire [2:0] deq_1_io_deq_bits_size; // @[Decoupled.scala 296:21]
  wire [1:0] deq_1_io_deq_bits_burst; // @[Decoupled.scala 296:21]
  wire  in_w_deq_clock; // @[Decoupled.scala 296:21]
  wire  in_w_deq_reset; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_ready; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_valid; // @[Decoupled.scala 296:21]
  wire [127:0] in_w_deq_io_enq_bits_data; // @[Decoupled.scala 296:21]
  wire [15:0] in_w_deq_io_enq_bits_strb; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_enq_bits_last; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_ready; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_valid; // @[Decoupled.scala 296:21]
  wire [127:0] in_w_deq_io_deq_bits_data; // @[Decoupled.scala 296:21]
  wire [15:0] in_w_deq_io_deq_bits_strb; // @[Decoupled.scala 296:21]
  wire  in_w_deq_io_deq_bits_last; // @[Decoupled.scala 296:21]
  reg  busy; // @[Fragmenter.scala 60:29]
  reg [31:0] r_addr; // @[Fragmenter.scala 61:25]
  reg [7:0] r_len; // @[Fragmenter.scala 62:25]
  wire [7:0] irr_bits_len = deq_io_deq_bits_len; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [7:0] len = busy ? r_len : irr_bits_len; // @[Fragmenter.scala 64:23]
  wire [31:0] irr_bits_addr = deq_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [31:0] addr = busy ? r_addr : irr_bits_addr; // @[Fragmenter.scala 65:23]
  wire [1:0] irr_bits_burst = deq_io_deq_bits_burst; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  fixed = irr_bits_burst == 2'h0; // @[Fragmenter.scala 92:34]
  wire [2:0] irr_bits_size = deq_io_deq_bits_size; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [15:0] _inc_addr_T = 16'h1 << irr_bits_size; // @[Fragmenter.scala 100:38]
  wire [31:0] _GEN_48 = {{16'd0}, _inc_addr_T}; // @[Fragmenter.scala 100:29]
  wire [31:0] inc_addr = addr + _GEN_48; // @[Fragmenter.scala 100:29]
  wire [15:0] _wrapMask_T = {irr_bits_len,8'hff}; // @[Cat.scala 30:58]
  wire [22:0] _GEN_49 = {{7'd0}, _wrapMask_T}; // @[Bundles.scala 30:21]
  wire [22:0] _wrapMask_T_1 = _GEN_49 << irr_bits_size; // @[Bundles.scala 30:21]
  wire [14:0] wrapMask = _wrapMask_T_1[22:8]; // @[Bundles.scala 30:30]
  wire [31:0] _GEN_50 = {{17'd0}, wrapMask}; // @[Fragmenter.scala 104:33]
  wire [31:0] _mux_addr_T = inc_addr & _GEN_50; // @[Fragmenter.scala 104:33]
  wire [31:0] _mux_addr_T_1 = ~irr_bits_addr; // @[Fragmenter.scala 104:49]
  wire [31:0] _mux_addr_T_2 = _mux_addr_T_1 | _GEN_50; // @[Fragmenter.scala 104:62]
  wire [31:0] _mux_addr_T_3 = ~_mux_addr_T_2; // @[Fragmenter.scala 104:47]
  wire [31:0] _mux_addr_T_4 = _mux_addr_T | _mux_addr_T_3; // @[Fragmenter.scala 104:45]
  wire  ar_last = 8'h0 == len; // @[Fragmenter.scala 110:27]
  wire [31:0] _out_bits_addr_T = ~addr; // @[Fragmenter.scala 122:28]
  wire [10:0] _out_bits_addr_T_2 = 11'hf << irr_bits_size; // @[package.scala 234:77]
  wire [3:0] _out_bits_addr_T_4 = ~_out_bits_addr_T_2[3:0]; // @[package.scala 234:46]
  wire [31:0] _GEN_52 = {{28'd0}, _out_bits_addr_T_4}; // @[Fragmenter.scala 122:34]
  wire [31:0] _out_bits_addr_T_5 = _out_bits_addr_T | _GEN_52; // @[Fragmenter.scala 122:34]
  wire  irr_valid = deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _T_2 = auto_out_ar_ready & irr_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_53 = {{1'd0}, len}; // @[Fragmenter.scala 127:25]
  wire [8:0] _r_len_T_1 = _GEN_53 - 9'h1; // @[Fragmenter.scala 127:25]
  wire [8:0] _GEN_4 = _T_2 ? _r_len_T_1 : {{1'd0}, r_len}; // @[Fragmenter.scala 124:27 Fragmenter.scala 127:18 Fragmenter.scala 62:25]
  reg  busy_1; // @[Fragmenter.scala 60:29]
  reg [31:0] r_addr_1; // @[Fragmenter.scala 61:25]
  reg [7:0] r_len_1; // @[Fragmenter.scala 62:25]
  wire [7:0] irr_1_bits_len = deq_1_io_deq_bits_len; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [7:0] len_1 = busy_1 ? r_len_1 : irr_1_bits_len; // @[Fragmenter.scala 64:23]
  wire [31:0] irr_1_bits_addr = deq_1_io_deq_bits_addr; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [31:0] addr_1 = busy_1 ? r_addr_1 : irr_1_bits_addr; // @[Fragmenter.scala 65:23]
  wire [1:0] irr_1_bits_burst = deq_1_io_deq_bits_burst; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  fixed_1 = irr_1_bits_burst == 2'h0; // @[Fragmenter.scala 92:34]
  wire [2:0] irr_1_bits_size = deq_1_io_deq_bits_size; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire [15:0] _inc_addr_T_2 = 16'h1 << irr_1_bits_size; // @[Fragmenter.scala 100:38]
  wire [31:0] _GEN_58 = {{16'd0}, _inc_addr_T_2}; // @[Fragmenter.scala 100:29]
  wire [31:0] inc_addr_1 = addr_1 + _GEN_58; // @[Fragmenter.scala 100:29]
  wire [15:0] _wrapMask_T_2 = {irr_1_bits_len,8'hff}; // @[Cat.scala 30:58]
  wire [22:0] _GEN_59 = {{7'd0}, _wrapMask_T_2}; // @[Bundles.scala 30:21]
  wire [22:0] _wrapMask_T_3 = _GEN_59 << irr_1_bits_size; // @[Bundles.scala 30:21]
  wire [14:0] wrapMask_1 = _wrapMask_T_3[22:8]; // @[Bundles.scala 30:30]
  wire [31:0] _GEN_60 = {{17'd0}, wrapMask_1}; // @[Fragmenter.scala 104:33]
  wire [31:0] _mux_addr_T_5 = inc_addr_1 & _GEN_60; // @[Fragmenter.scala 104:33]
  wire [31:0] _mux_addr_T_6 = ~irr_1_bits_addr; // @[Fragmenter.scala 104:49]
  wire [31:0] _mux_addr_T_7 = _mux_addr_T_6 | _GEN_60; // @[Fragmenter.scala 104:62]
  wire [31:0] _mux_addr_T_8 = ~_mux_addr_T_7; // @[Fragmenter.scala 104:47]
  wire [31:0] _mux_addr_T_9 = _mux_addr_T_5 | _mux_addr_T_8; // @[Fragmenter.scala 104:45]
  wire  aw_last = 8'h0 == len_1; // @[Fragmenter.scala 110:27]
  reg [8:0] w_counter; // @[Fragmenter.scala 164:30]
  wire  w_idle = w_counter == 9'h0; // @[Fragmenter.scala 165:30]
  reg  wbeats_latched; // @[Fragmenter.scala 150:35]
  wire  _in_aw_ready_T = w_idle | wbeats_latched; // @[Fragmenter.scala 158:52]
  wire  in_aw_ready = auto_out_aw_ready & (w_idle | wbeats_latched); // @[Fragmenter.scala 158:35]
  wire [31:0] _out_bits_addr_T_7 = ~addr_1; // @[Fragmenter.scala 122:28]
  wire [10:0] _out_bits_addr_T_9 = 11'hf << irr_1_bits_size; // @[package.scala 234:77]
  wire [3:0] _out_bits_addr_T_11 = ~_out_bits_addr_T_9[3:0]; // @[package.scala 234:46]
  wire [31:0] _GEN_62 = {{28'd0}, _out_bits_addr_T_11}; // @[Fragmenter.scala 122:34]
  wire [31:0] _out_bits_addr_T_12 = _out_bits_addr_T_7 | _GEN_62; // @[Fragmenter.scala 122:34]
  wire  irr_1_valid = deq_1_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _T_5 = in_aw_ready & irr_1_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_63 = {{1'd0}, len_1}; // @[Fragmenter.scala 127:25]
  wire [8:0] _r_len_T_3 = _GEN_63 - 9'h1; // @[Fragmenter.scala 127:25]
  wire [8:0] _GEN_9 = _T_5 ? _r_len_T_3 : {{1'd0}, r_len_1}; // @[Fragmenter.scala 124:27 Fragmenter.scala 127:18 Fragmenter.scala 62:25]
  wire  wbeats_valid = irr_1_valid & ~wbeats_latched; // @[Fragmenter.scala 159:35]
  wire  _GEN_10 = wbeats_valid & w_idle | wbeats_latched; // @[Fragmenter.scala 153:43 Fragmenter.scala 153:60 Fragmenter.scala 150:35]
  wire  bundleOut_0_aw_valid = irr_1_valid & _in_aw_ready_T; // @[Fragmenter.scala 157:35]
  wire  _T_7 = auto_out_aw_ready & bundleOut_0_aw_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _w_todo_T = wbeats_valid ? 9'h1 : 9'h0; // @[Fragmenter.scala 166:35]
  wire [8:0] w_todo = w_idle ? _w_todo_T : w_counter; // @[Fragmenter.scala 166:23]
  wire  w_last = w_todo == 9'h1; // @[Fragmenter.scala 167:27]
  wire  in_w_valid = in_w_deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  wire  _bundleOut_0_w_valid_T_1 = ~w_idle | wbeats_valid; // @[Fragmenter.scala 173:51]
  wire  bundleOut_0_w_valid = in_w_valid & (~w_idle | wbeats_valid); // @[Fragmenter.scala 173:33]
  wire  _w_counter_T = auto_out_w_ready & bundleOut_0_w_valid; // @[Decoupled.scala 40:37]
  wire [8:0] _GEN_64 = {{8'd0}, _w_counter_T}; // @[Fragmenter.scala 168:27]
  wire [8:0] _w_counter_T_2 = w_todo - _GEN_64; // @[Fragmenter.scala 168:27]
  wire  in_w_bits_last = in_w_deq_io_deq_bits_last; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  wire  bundleOut_0_b_ready = auto_in_b_ready | ~auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 189:33]
  reg [1:0] error_0; // @[Fragmenter.scala 192:26]
  reg [1:0] error_1; // @[Fragmenter.scala 192:26]
  reg [1:0] error_2; // @[Fragmenter.scala 192:26]
  reg [1:0] error_3; // @[Fragmenter.scala 192:26]
  reg [1:0] error_4; // @[Fragmenter.scala 192:26]
  reg [1:0] error_5; // @[Fragmenter.scala 192:26]
  reg [1:0] error_6; // @[Fragmenter.scala 192:26]
  reg [1:0] error_7; // @[Fragmenter.scala 192:26]
  reg [1:0] error_8; // @[Fragmenter.scala 192:26]
  reg [1:0] error_9; // @[Fragmenter.scala 192:26]
  reg [1:0] error_10; // @[Fragmenter.scala 192:26]
  reg [1:0] error_11; // @[Fragmenter.scala 192:26]
  reg [1:0] error_12; // @[Fragmenter.scala 192:26]
  reg [1:0] error_13; // @[Fragmenter.scala 192:26]
  reg [1:0] error_14; // @[Fragmenter.scala 192:26]
  reg [1:0] error_15; // @[Fragmenter.scala 192:26]
  wire [1:0] _GEN_13 = 4'h1 == auto_out_b_bits_id ? error_1 : error_0; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_14 = 4'h2 == auto_out_b_bits_id ? error_2 : _GEN_13; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_15 = 4'h3 == auto_out_b_bits_id ? error_3 : _GEN_14; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_16 = 4'h4 == auto_out_b_bits_id ? error_4 : _GEN_15; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_17 = 4'h5 == auto_out_b_bits_id ? error_5 : _GEN_16; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_18 = 4'h6 == auto_out_b_bits_id ? error_6 : _GEN_17; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_19 = 4'h7 == auto_out_b_bits_id ? error_7 : _GEN_18; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_20 = 4'h8 == auto_out_b_bits_id ? error_8 : _GEN_19; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_21 = 4'h9 == auto_out_b_bits_id ? error_9 : _GEN_20; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_22 = 4'ha == auto_out_b_bits_id ? error_10 : _GEN_21; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_23 = 4'hb == auto_out_b_bits_id ? error_11 : _GEN_22; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_24 = 4'hc == auto_out_b_bits_id ? error_12 : _GEN_23; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_25 = 4'hd == auto_out_b_bits_id ? error_13 : _GEN_24; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_26 = 4'he == auto_out_b_bits_id ? error_14 : _GEN_25; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [1:0] _GEN_27 = 4'hf == auto_out_b_bits_id ? error_15 : _GEN_26; // @[Fragmenter.scala 193:41 Fragmenter.scala 193:41]
  wire [15:0] _T_22 = 16'h1 << auto_out_b_bits_id; // @[OneHot.scala 65:12]
  wire  _T_40 = bundleOut_0_b_ready & auto_out_b_valid; // @[Decoupled.scala 40:37]
  wire [1:0] _error_0_T = error_0 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_1_T = error_1 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_2_T = error_2 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_3_T = error_3 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_4_T = error_4 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_5_T = error_5 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_6_T = error_6 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_7_T = error_7 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_8_T = error_8 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_9_T = error_9 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_10_T = error_10 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_11_T = error_11 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_12_T = error_12 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_13_T = error_13 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_14_T = error_14 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  wire [1:0] _error_15_T = error_15 | auto_out_b_bits_resp; // @[Fragmenter.scala 195:70]
  Queue_82_inTestHarness deq ( // @[Decoupled.scala 296:21]
    .clock(deq_clock),
    .reset(deq_reset),
    .io_enq_ready(deq_io_enq_ready),
    .io_enq_valid(deq_io_enq_valid),
    .io_enq_bits_id(deq_io_enq_bits_id),
    .io_enq_bits_addr(deq_io_enq_bits_addr),
    .io_enq_bits_len(deq_io_enq_bits_len),
    .io_enq_bits_size(deq_io_enq_bits_size),
    .io_enq_bits_burst(deq_io_enq_bits_burst),
    .io_deq_ready(deq_io_deq_ready),
    .io_deq_valid(deq_io_deq_valid),
    .io_deq_bits_id(deq_io_deq_bits_id),
    .io_deq_bits_addr(deq_io_deq_bits_addr),
    .io_deq_bits_len(deq_io_deq_bits_len),
    .io_deq_bits_size(deq_io_deq_bits_size),
    .io_deq_bits_burst(deq_io_deq_bits_burst)
  );
  Queue_82_inTestHarness deq_1 ( // @[Decoupled.scala 296:21]
    .clock(deq_1_clock),
    .reset(deq_1_reset),
    .io_enq_ready(deq_1_io_enq_ready),
    .io_enq_valid(deq_1_io_enq_valid),
    .io_enq_bits_id(deq_1_io_enq_bits_id),
    .io_enq_bits_addr(deq_1_io_enq_bits_addr),
    .io_enq_bits_len(deq_1_io_enq_bits_len),
    .io_enq_bits_size(deq_1_io_enq_bits_size),
    .io_enq_bits_burst(deq_1_io_enq_bits_burst),
    .io_deq_ready(deq_1_io_deq_ready),
    .io_deq_valid(deq_1_io_deq_valid),
    .io_deq_bits_id(deq_1_io_deq_bits_id),
    .io_deq_bits_addr(deq_1_io_deq_bits_addr),
    .io_deq_bits_len(deq_1_io_deq_bits_len),
    .io_deq_bits_size(deq_1_io_deq_bits_size),
    .io_deq_bits_burst(deq_1_io_deq_bits_burst)
  );
  Queue_28_inTestHarness in_w_deq ( // @[Decoupled.scala 296:21]
    .clock(in_w_deq_clock),
    .reset(in_w_deq_reset),
    .io_enq_ready(in_w_deq_io_enq_ready),
    .io_enq_valid(in_w_deq_io_enq_valid),
    .io_enq_bits_data(in_w_deq_io_enq_bits_data),
    .io_enq_bits_strb(in_w_deq_io_enq_bits_strb),
    .io_enq_bits_last(in_w_deq_io_enq_bits_last),
    .io_deq_ready(in_w_deq_io_deq_ready),
    .io_deq_valid(in_w_deq_io_deq_valid),
    .io_deq_bits_data(in_w_deq_io_deq_bits_data),
    .io_deq_bits_strb(in_w_deq_io_deq_bits_strb),
    .io_deq_bits_last(in_w_deq_io_deq_bits_last)
  );
  assign auto_in_aw_ready = deq_1_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_w_ready = in_w_deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_b_valid = auto_out_b_valid & auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 188:33]
  assign auto_in_b_bits_id = auto_out_b_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_b_bits_resp = auto_out_b_bits_resp | _GEN_27; // @[Fragmenter.scala 193:41]
  assign auto_in_ar_ready = deq_io_enq_ready; // @[Nodes.scala 1210:84 Decoupled.scala 299:17]
  assign auto_in_r_valid = auto_out_r_valid; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_id = auto_out_r_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_data = auto_out_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_resp = auto_out_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 311:12]
  assign auto_in_r_bits_last = auto_out_r_bits_last & auto_out_r_bits_echo_real_last; // @[Fragmenter.scala 183:41]
  assign auto_out_aw_valid = irr_1_valid & _in_aw_ready_T; // @[Fragmenter.scala 157:35]
  assign auto_out_aw_bits_id = deq_1_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_aw_bits_addr = ~_out_bits_addr_T_12; // @[Fragmenter.scala 122:26]
  assign auto_out_aw_bits_echo_real_last = 8'h0 == len_1; // @[Fragmenter.scala 110:27]
  assign auto_out_w_valid = in_w_valid & (~w_idle | wbeats_valid); // @[Fragmenter.scala 173:33]
  assign auto_out_w_bits_data = in_w_deq_io_deq_bits_data; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_w_bits_strb = in_w_deq_io_deq_bits_strb; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_b_ready = auto_in_b_ready | ~auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 189:33]
  assign auto_out_ar_valid = deq_io_deq_valid; // @[Decoupled.scala 317:19 Decoupled.scala 319:15]
  assign auto_out_ar_bits_id = deq_io_deq_bits_id; // @[Decoupled.scala 317:19 Decoupled.scala 318:14]
  assign auto_out_ar_bits_addr = ~_out_bits_addr_T_5; // @[Fragmenter.scala 122:26]
  assign auto_out_ar_bits_echo_real_last = 8'h0 == len; // @[Fragmenter.scala 110:27]
  assign auto_out_r_ready = auto_in_r_ready; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_clock = clock;
  assign deq_reset = reset;
  assign deq_io_enq_valid = auto_in_ar_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_id = auto_in_ar_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_addr = auto_in_ar_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_len = auto_in_ar_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_size = auto_in_ar_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_enq_bits_burst = auto_in_ar_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_io_deq_ready = auto_out_ar_ready & ar_last; // @[Fragmenter.scala 111:30]
  assign deq_1_clock = clock;
  assign deq_1_reset = reset;
  assign deq_1_io_enq_valid = auto_in_aw_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_id = auto_in_aw_bits_id; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_addr = auto_in_aw_bits_addr; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_len = auto_in_aw_bits_len; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_size = auto_in_aw_bits_size; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_enq_bits_burst = auto_in_aw_bits_burst; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign deq_1_io_deq_ready = in_aw_ready & aw_last; // @[Fragmenter.scala 111:30]
  assign in_w_deq_clock = clock;
  assign in_w_deq_reset = reset;
  assign in_w_deq_io_enq_valid = auto_in_w_valid; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_data = auto_in_w_bits_data; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_strb = auto_in_w_bits_strb; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_enq_bits_last = auto_in_w_bits_last; // @[Nodes.scala 1210:84 LazyModule.scala 309:16]
  assign in_w_deq_io_deq_ready = auto_out_w_ready & _bundleOut_0_w_valid_T_1; // @[Fragmenter.scala 174:33]
  always @(posedge clock) begin
    if (reset) begin // @[Fragmenter.scala 60:29]
      busy <= 1'h0; // @[Fragmenter.scala 60:29]
    end else if (_T_2) begin // @[Fragmenter.scala 124:27]
      busy <= ~ar_last; // @[Fragmenter.scala 125:16]
    end
    if (_T_2) begin // @[Fragmenter.scala 124:27]
      if (fixed) begin // @[Fragmenter.scala 106:60]
        r_addr <= irr_bits_addr; // @[Fragmenter.scala 107:20]
      end else if (irr_bits_burst == 2'h2) begin // @[Fragmenter.scala 103:59]
        r_addr <= _mux_addr_T_4; // @[Fragmenter.scala 104:20]
      end else begin
        r_addr <= inc_addr;
      end
    end
    r_len <= _GEN_4[7:0];
    if (reset) begin // @[Fragmenter.scala 60:29]
      busy_1 <= 1'h0; // @[Fragmenter.scala 60:29]
    end else if (_T_5) begin // @[Fragmenter.scala 124:27]
      busy_1 <= ~aw_last; // @[Fragmenter.scala 125:16]
    end
    if (_T_5) begin // @[Fragmenter.scala 124:27]
      if (fixed_1) begin // @[Fragmenter.scala 106:60]
        r_addr_1 <= irr_1_bits_addr; // @[Fragmenter.scala 107:20]
      end else if (irr_1_bits_burst == 2'h2) begin // @[Fragmenter.scala 103:59]
        r_addr_1 <= _mux_addr_T_9; // @[Fragmenter.scala 104:20]
      end else begin
        r_addr_1 <= inc_addr_1;
      end
    end
    r_len_1 <= _GEN_9[7:0];
    if (reset) begin // @[Fragmenter.scala 164:30]
      w_counter <= 9'h0; // @[Fragmenter.scala 164:30]
    end else begin
      w_counter <= _w_counter_T_2; // @[Fragmenter.scala 168:17]
    end
    if (reset) begin // @[Fragmenter.scala 150:35]
      wbeats_latched <= 1'h0; // @[Fragmenter.scala 150:35]
    end else if (_T_7) begin // @[Fragmenter.scala 154:28]
      wbeats_latched <= 1'h0; // @[Fragmenter.scala 154:45]
    end else begin
      wbeats_latched <= _GEN_10;
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_0 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[0] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_0 <= 2'h0;
      end else begin
        error_0 <= _error_0_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_1 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[1] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_1 <= 2'h0;
      end else begin
        error_1 <= _error_1_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_2 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[2] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_2 <= 2'h0;
      end else begin
        error_2 <= _error_2_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_3 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[3] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_3 <= 2'h0;
      end else begin
        error_3 <= _error_3_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_4 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[4] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_4 <= 2'h0;
      end else begin
        error_4 <= _error_4_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_5 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[5] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_5 <= 2'h0;
      end else begin
        error_5 <= _error_5_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_6 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[6] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_6 <= 2'h0;
      end else begin
        error_6 <= _error_6_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_7 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[7] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_7 <= 2'h0;
      end else begin
        error_7 <= _error_7_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_8 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[8] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_8 <= 2'h0;
      end else begin
        error_8 <= _error_8_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_9 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[9] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_9 <= 2'h0;
      end else begin
        error_9 <= _error_9_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_10 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[10] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_10 <= 2'h0;
      end else begin
        error_10 <= _error_10_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_11 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[11] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_11 <= 2'h0;
      end else begin
        error_11 <= _error_11_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_12 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[12] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_12 <= 2'h0;
      end else begin
        error_12 <= _error_12_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_13 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[13] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_13 <= 2'h0;
      end else begin
        error_13 <= _error_13_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_14 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[14] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_14 <= 2'h0;
      end else begin
        error_14 <= _error_14_T;
      end
    end
    if (reset) begin // @[Fragmenter.scala 192:26]
      error_15 <= 2'h0; // @[Fragmenter.scala 192:26]
    end else if (_T_22[15] & _T_40) begin // @[Fragmenter.scala 195:36]
      if (auto_out_b_bits_echo_real_last) begin // @[Fragmenter.scala 195:48]
        error_15 <= 2'h0;
      end else begin
        error_15 <= _error_15_T;
      end
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~_w_counter_T | w_todo != 9'h0 | reset)) begin
          $fwrite(32'h80000002,
            "Assertion failed\n    at Fragmenter.scala:169 assert (!out.w.fire() || w_todo =/= UInt(0)) // underflow impossible\n"
            ); // @[Fragmenter.scala 169:14]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~_w_counter_T | w_todo != 9'h0 | reset)) begin
          $fatal; // @[Fragmenter.scala 169:14]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~(~bundleOut_0_w_valid | ~in_w_bits_last | w_last | reset)) begin
          $fwrite(32'h80000002,
            "Assertion failed\n    at Fragmenter.scala:178 assert (!out.w.valid || !in_w.bits.last || w_last)\n"); // @[Fragmenter.scala 178:14]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~bundleOut_0_w_valid | ~in_w_bits_last | w_last | reset)) begin
          $fatal; // @[Fragmenter.scala 178:14]
        end
    `ifdef STOP_COND
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
  busy = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  r_addr = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  r_len = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  busy_1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  r_addr_1 = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  r_len_1 = _RAND_5[7:0];
  _RAND_6 = {1{`RANDOM}};
  w_counter = _RAND_6[8:0];
  _RAND_7 = {1{`RANDOM}};
  wbeats_latched = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  error_0 = _RAND_8[1:0];
  _RAND_9 = {1{`RANDOM}};
  error_1 = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  error_2 = _RAND_10[1:0];
  _RAND_11 = {1{`RANDOM}};
  error_3 = _RAND_11[1:0];
  _RAND_12 = {1{`RANDOM}};
  error_4 = _RAND_12[1:0];
  _RAND_13 = {1{`RANDOM}};
  error_5 = _RAND_13[1:0];
  _RAND_14 = {1{`RANDOM}};
  error_6 = _RAND_14[1:0];
  _RAND_15 = {1{`RANDOM}};
  error_7 = _RAND_15[1:0];
  _RAND_16 = {1{`RANDOM}};
  error_8 = _RAND_16[1:0];
  _RAND_17 = {1{`RANDOM}};
  error_9 = _RAND_17[1:0];
  _RAND_18 = {1{`RANDOM}};
  error_10 = _RAND_18[1:0];
  _RAND_19 = {1{`RANDOM}};
  error_11 = _RAND_19[1:0];
  _RAND_20 = {1{`RANDOM}};
  error_12 = _RAND_20[1:0];
  _RAND_21 = {1{`RANDOM}};
  error_13 = _RAND_21[1:0];
  _RAND_22 = {1{`RANDOM}};
  error_14 = _RAND_22[1:0];
  _RAND_23 = {1{`RANDOM}};
  error_15 = _RAND_23[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module SimAXIMem_1_inTestHarness(
  input          clock,
  input          reset,
  output         io_axi4_0_aw_ready,
  input          io_axi4_0_aw_valid,
  input  [3:0]   io_axi4_0_aw_bits_id,
  input  [31:0]  io_axi4_0_aw_bits_addr,
  input  [7:0]   io_axi4_0_aw_bits_len,
  input  [2:0]   io_axi4_0_aw_bits_size,
  input  [1:0]   io_axi4_0_aw_bits_burst,
  output         io_axi4_0_w_ready,
  input          io_axi4_0_w_valid,
  input  [127:0] io_axi4_0_w_bits_data,
  input  [15:0]  io_axi4_0_w_bits_strb,
  input          io_axi4_0_w_bits_last,
  input          io_axi4_0_b_ready,
  output         io_axi4_0_b_valid,
  output [3:0]   io_axi4_0_b_bits_id,
  output [1:0]   io_axi4_0_b_bits_resp,
  output         io_axi4_0_ar_ready,
  input          io_axi4_0_ar_valid,
  input  [3:0]   io_axi4_0_ar_bits_id,
  input  [31:0]  io_axi4_0_ar_bits_addr,
  input  [7:0]   io_axi4_0_ar_bits_len,
  input  [2:0]   io_axi4_0_ar_bits_size,
  input  [1:0]   io_axi4_0_ar_bits_burst,
  input          io_axi4_0_r_ready,
  output         io_axi4_0_r_valid,
  output [3:0]   io_axi4_0_r_bits_id,
  output [127:0] io_axi4_0_r_bits_data,
  output [1:0]   io_axi4_0_r_bits_resp,
  output         io_axi4_0_r_bits_last
);
  wire  srams_clock; // @[SimAXIMem.scala 16:15]
  wire  srams_reset; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_aw_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_aw_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_auto_in_aw_bits_id; // @[SimAXIMem.scala 16:15]
  wire [30:0] srams_auto_in_aw_bits_addr; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_aw_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_w_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_w_valid; // @[SimAXIMem.scala 16:15]
  wire [127:0] srams_auto_in_w_bits_data; // @[SimAXIMem.scala 16:15]
  wire [15:0] srams_auto_in_w_bits_strb; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_b_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_b_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_auto_in_b_bits_id; // @[SimAXIMem.scala 16:15]
  wire [1:0] srams_auto_in_b_bits_resp; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_b_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_ar_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_ar_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_auto_in_ar_bits_id; // @[SimAXIMem.scala 16:15]
  wire [30:0] srams_auto_in_ar_bits_addr; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_ar_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_r_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_r_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_auto_in_r_bits_id; // @[SimAXIMem.scala 16:15]
  wire [127:0] srams_auto_in_r_bits_data; // @[SimAXIMem.scala 16:15]
  wire [1:0] srams_auto_in_r_bits_resp; // @[SimAXIMem.scala 16:15]
  wire  srams_auto_in_r_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_1_clock; // @[SimAXIMem.scala 16:15]
  wire  srams_1_reset; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_aw_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_aw_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_1_auto_in_aw_bits_id; // @[SimAXIMem.scala 16:15]
  wire [31:0] srams_1_auto_in_aw_bits_addr; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_aw_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_w_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_w_valid; // @[SimAXIMem.scala 16:15]
  wire [127:0] srams_1_auto_in_w_bits_data; // @[SimAXIMem.scala 16:15]
  wire [15:0] srams_1_auto_in_w_bits_strb; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_b_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_b_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_1_auto_in_b_bits_id; // @[SimAXIMem.scala 16:15]
  wire [1:0] srams_1_auto_in_b_bits_resp; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_b_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_ar_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_ar_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_1_auto_in_ar_bits_id; // @[SimAXIMem.scala 16:15]
  wire [31:0] srams_1_auto_in_ar_bits_addr; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_ar_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_r_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_r_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_1_auto_in_r_bits_id; // @[SimAXIMem.scala 16:15]
  wire [127:0] srams_1_auto_in_r_bits_data; // @[SimAXIMem.scala 16:15]
  wire [1:0] srams_1_auto_in_r_bits_resp; // @[SimAXIMem.scala 16:15]
  wire  srams_1_auto_in_r_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_2_clock; // @[SimAXIMem.scala 16:15]
  wire  srams_2_reset; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_aw_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_aw_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_2_auto_in_aw_bits_id; // @[SimAXIMem.scala 16:15]
  wire [31:0] srams_2_auto_in_aw_bits_addr; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_aw_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_w_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_w_valid; // @[SimAXIMem.scala 16:15]
  wire [127:0] srams_2_auto_in_w_bits_data; // @[SimAXIMem.scala 16:15]
  wire [15:0] srams_2_auto_in_w_bits_strb; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_b_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_b_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_2_auto_in_b_bits_id; // @[SimAXIMem.scala 16:15]
  wire [1:0] srams_2_auto_in_b_bits_resp; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_b_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_ar_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_ar_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_2_auto_in_ar_bits_id; // @[SimAXIMem.scala 16:15]
  wire [31:0] srams_2_auto_in_ar_bits_addr; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_ar_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_r_ready; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_r_valid; // @[SimAXIMem.scala 16:15]
  wire [3:0] srams_2_auto_in_r_bits_id; // @[SimAXIMem.scala 16:15]
  wire [127:0] srams_2_auto_in_r_bits_data; // @[SimAXIMem.scala 16:15]
  wire [1:0] srams_2_auto_in_r_bits_resp; // @[SimAXIMem.scala 16:15]
  wire  srams_2_auto_in_r_bits_echo_real_last; // @[SimAXIMem.scala 16:15]
  wire  axi4xbar_clock; // @[Xbar.scala 218:30]
  wire  axi4xbar_reset; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_aw_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_aw_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_in_aw_bits_id; // @[Xbar.scala 218:30]
  wire [31:0] axi4xbar_auto_in_aw_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_in_aw_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_in_aw_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_in_aw_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_w_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_w_valid; // @[Xbar.scala 218:30]
  wire [127:0] axi4xbar_auto_in_w_bits_data; // @[Xbar.scala 218:30]
  wire [15:0] axi4xbar_auto_in_w_bits_strb; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_w_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_b_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_b_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_in_b_bits_id; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_in_b_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_ar_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_ar_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_in_ar_bits_id; // @[Xbar.scala 218:30]
  wire [31:0] axi4xbar_auto_in_ar_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_in_ar_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_in_ar_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_in_ar_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_r_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_r_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_in_r_bits_id; // @[Xbar.scala 218:30]
  wire [127:0] axi4xbar_auto_in_r_bits_data; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_in_r_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_in_r_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_aw_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_aw_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_2_aw_bits_id; // @[Xbar.scala 218:30]
  wire [31:0] axi4xbar_auto_out_2_aw_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_2_aw_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_out_2_aw_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_2_aw_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_w_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_w_valid; // @[Xbar.scala 218:30]
  wire [127:0] axi4xbar_auto_out_2_w_bits_data; // @[Xbar.scala 218:30]
  wire [15:0] axi4xbar_auto_out_2_w_bits_strb; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_w_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_b_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_b_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_2_b_bits_id; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_2_b_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_ar_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_ar_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_2_ar_bits_id; // @[Xbar.scala 218:30]
  wire [31:0] axi4xbar_auto_out_2_ar_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_2_ar_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_out_2_ar_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_2_ar_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_r_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_r_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_2_r_bits_id; // @[Xbar.scala 218:30]
  wire [127:0] axi4xbar_auto_out_2_r_bits_data; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_2_r_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_2_r_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_aw_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_aw_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_1_aw_bits_id; // @[Xbar.scala 218:30]
  wire [31:0] axi4xbar_auto_out_1_aw_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_1_aw_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_out_1_aw_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_1_aw_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_w_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_w_valid; // @[Xbar.scala 218:30]
  wire [127:0] axi4xbar_auto_out_1_w_bits_data; // @[Xbar.scala 218:30]
  wire [15:0] axi4xbar_auto_out_1_w_bits_strb; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_w_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_b_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_b_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_1_b_bits_id; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_1_b_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_ar_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_ar_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_1_ar_bits_id; // @[Xbar.scala 218:30]
  wire [31:0] axi4xbar_auto_out_1_ar_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_1_ar_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_out_1_ar_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_1_ar_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_r_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_r_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_1_r_bits_id; // @[Xbar.scala 218:30]
  wire [127:0] axi4xbar_auto_out_1_r_bits_data; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_1_r_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_1_r_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_aw_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_aw_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_0_aw_bits_id; // @[Xbar.scala 218:30]
  wire [30:0] axi4xbar_auto_out_0_aw_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_0_aw_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_out_0_aw_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_0_aw_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_w_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_w_valid; // @[Xbar.scala 218:30]
  wire [127:0] axi4xbar_auto_out_0_w_bits_data; // @[Xbar.scala 218:30]
  wire [15:0] axi4xbar_auto_out_0_w_bits_strb; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_w_bits_last; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_b_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_b_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_0_b_bits_id; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_0_b_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_ar_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_ar_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_0_ar_bits_id; // @[Xbar.scala 218:30]
  wire [30:0] axi4xbar_auto_out_0_ar_bits_addr; // @[Xbar.scala 218:30]
  wire [7:0] axi4xbar_auto_out_0_ar_bits_len; // @[Xbar.scala 218:30]
  wire [2:0] axi4xbar_auto_out_0_ar_bits_size; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_0_ar_bits_burst; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_r_ready; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_r_valid; // @[Xbar.scala 218:30]
  wire [3:0] axi4xbar_auto_out_0_r_bits_id; // @[Xbar.scala 218:30]
  wire [127:0] axi4xbar_auto_out_0_r_bits_data; // @[Xbar.scala 218:30]
  wire [1:0] axi4xbar_auto_out_0_r_bits_resp; // @[Xbar.scala 218:30]
  wire  axi4xbar_auto_out_0_r_bits_last; // @[Xbar.scala 218:30]
  wire  axi4buf_clock; // @[Buffer.scala 58:29]
  wire  axi4buf_reset; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_aw_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_aw_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_in_aw_bits_id; // @[Buffer.scala 58:29]
  wire [30:0] axi4buf_auto_in_aw_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_aw_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_w_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_w_valid; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_auto_in_w_bits_data; // @[Buffer.scala 58:29]
  wire [15:0] axi4buf_auto_in_w_bits_strb; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_b_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_b_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_in_b_bits_id; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_auto_in_b_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_b_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_ar_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_ar_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_in_ar_bits_id; // @[Buffer.scala 58:29]
  wire [30:0] axi4buf_auto_in_ar_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_ar_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_r_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_r_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_in_r_bits_id; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_auto_in_r_bits_data; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_auto_in_r_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_r_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_in_r_bits_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_aw_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_aw_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_out_aw_bits_id; // @[Buffer.scala 58:29]
  wire [30:0] axi4buf_auto_out_aw_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_aw_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_w_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_w_valid; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_auto_out_w_bits_data; // @[Buffer.scala 58:29]
  wire [15:0] axi4buf_auto_out_w_bits_strb; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_b_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_b_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_out_b_bits_id; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_auto_out_b_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_b_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_ar_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_ar_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_out_ar_bits_id; // @[Buffer.scala 58:29]
  wire [30:0] axi4buf_auto_out_ar_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_ar_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_r_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_r_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_auto_out_r_bits_id; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_auto_out_r_bits_data; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_auto_out_r_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_auto_out_r_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4frag_clock; // @[Fragmenter.scala 205:30]
  wire  axi4frag_reset; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_aw_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_aw_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_in_aw_bits_id; // @[Fragmenter.scala 205:30]
  wire [30:0] axi4frag_auto_in_aw_bits_addr; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_auto_in_aw_bits_len; // @[Fragmenter.scala 205:30]
  wire [2:0] axi4frag_auto_in_aw_bits_size; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_in_aw_bits_burst; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_w_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_w_valid; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_auto_in_w_bits_data; // @[Fragmenter.scala 205:30]
  wire [15:0] axi4frag_auto_in_w_bits_strb; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_w_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_b_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_b_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_in_b_bits_id; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_in_b_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_ar_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_ar_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_in_ar_bits_id; // @[Fragmenter.scala 205:30]
  wire [30:0] axi4frag_auto_in_ar_bits_addr; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_auto_in_ar_bits_len; // @[Fragmenter.scala 205:30]
  wire [2:0] axi4frag_auto_in_ar_bits_size; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_in_ar_bits_burst; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_r_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_r_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_in_r_bits_id; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_auto_in_r_bits_data; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_in_r_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_in_r_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_aw_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_aw_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_out_aw_bits_id; // @[Fragmenter.scala 205:30]
  wire [30:0] axi4frag_auto_out_aw_bits_addr; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_aw_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_w_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_w_valid; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_auto_out_w_bits_data; // @[Fragmenter.scala 205:30]
  wire [15:0] axi4frag_auto_out_w_bits_strb; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_b_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_b_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_out_b_bits_id; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_out_b_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_ar_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_ar_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_out_ar_bits_id; // @[Fragmenter.scala 205:30]
  wire [30:0] axi4frag_auto_out_ar_bits_addr; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_ar_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_r_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_r_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_auto_out_r_bits_id; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_auto_out_r_bits_data; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_auto_out_r_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_r_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_auto_out_r_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4buf_1_clock; // @[Buffer.scala 58:29]
  wire  axi4buf_1_reset; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_aw_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_aw_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_1_auto_in_aw_bits_id; // @[Buffer.scala 58:29]
  wire [31:0] axi4buf_1_auto_in_aw_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_aw_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_w_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_w_valid; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_1_auto_in_w_bits_data; // @[Buffer.scala 58:29]
  wire [15:0] axi4buf_1_auto_in_w_bits_strb; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_b_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_b_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_1_auto_in_b_bits_id; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_1_auto_in_b_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_b_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_ar_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_ar_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_1_auto_in_ar_bits_id; // @[Buffer.scala 58:29]
  wire [31:0] axi4buf_1_auto_in_ar_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_ar_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_r_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_r_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_1_auto_in_r_bits_id; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_1_auto_in_r_bits_data; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_1_auto_in_r_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_r_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_in_r_bits_last; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_aw_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_aw_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_1_auto_out_aw_bits_id; // @[Buffer.scala 58:29]
  wire [31:0] axi4buf_1_auto_out_aw_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_aw_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_w_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_w_valid; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_1_auto_out_w_bits_data; // @[Buffer.scala 58:29]
  wire [15:0] axi4buf_1_auto_out_w_bits_strb; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_b_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_b_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_1_auto_out_b_bits_id; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_1_auto_out_b_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_b_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_ar_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_ar_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_1_auto_out_ar_bits_id; // @[Buffer.scala 58:29]
  wire [31:0] axi4buf_1_auto_out_ar_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_ar_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_r_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_r_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_1_auto_out_r_bits_id; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_1_auto_out_r_bits_data; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_1_auto_out_r_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_1_auto_out_r_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4frag_1_clock; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_reset; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_aw_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_aw_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_1_auto_in_aw_bits_id; // @[Fragmenter.scala 205:30]
  wire [31:0] axi4frag_1_auto_in_aw_bits_addr; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_1_auto_in_aw_bits_len; // @[Fragmenter.scala 205:30]
  wire [2:0] axi4frag_1_auto_in_aw_bits_size; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_1_auto_in_aw_bits_burst; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_w_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_w_valid; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_1_auto_in_w_bits_data; // @[Fragmenter.scala 205:30]
  wire [15:0] axi4frag_1_auto_in_w_bits_strb; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_w_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_b_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_b_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_1_auto_in_b_bits_id; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_1_auto_in_b_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_ar_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_ar_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_1_auto_in_ar_bits_id; // @[Fragmenter.scala 205:30]
  wire [31:0] axi4frag_1_auto_in_ar_bits_addr; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_1_auto_in_ar_bits_len; // @[Fragmenter.scala 205:30]
  wire [2:0] axi4frag_1_auto_in_ar_bits_size; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_1_auto_in_ar_bits_burst; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_r_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_r_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_1_auto_in_r_bits_id; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_1_auto_in_r_bits_data; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_1_auto_in_r_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_in_r_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_aw_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_aw_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_1_auto_out_aw_bits_id; // @[Fragmenter.scala 205:30]
  wire [31:0] axi4frag_1_auto_out_aw_bits_addr; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_aw_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_w_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_w_valid; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_1_auto_out_w_bits_data; // @[Fragmenter.scala 205:30]
  wire [15:0] axi4frag_1_auto_out_w_bits_strb; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_b_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_b_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_1_auto_out_b_bits_id; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_1_auto_out_b_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_ar_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_ar_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_1_auto_out_ar_bits_id; // @[Fragmenter.scala 205:30]
  wire [31:0] axi4frag_1_auto_out_ar_bits_addr; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_ar_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_r_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_r_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_1_auto_out_r_bits_id; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_1_auto_out_r_bits_data; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_1_auto_out_r_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_r_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_1_auto_out_r_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4buf_2_clock; // @[Buffer.scala 58:29]
  wire  axi4buf_2_reset; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_aw_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_aw_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_2_auto_in_aw_bits_id; // @[Buffer.scala 58:29]
  wire [31:0] axi4buf_2_auto_in_aw_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_aw_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_w_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_w_valid; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_2_auto_in_w_bits_data; // @[Buffer.scala 58:29]
  wire [15:0] axi4buf_2_auto_in_w_bits_strb; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_b_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_b_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_2_auto_in_b_bits_id; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_2_auto_in_b_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_b_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_ar_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_ar_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_2_auto_in_ar_bits_id; // @[Buffer.scala 58:29]
  wire [31:0] axi4buf_2_auto_in_ar_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_ar_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_r_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_r_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_2_auto_in_r_bits_id; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_2_auto_in_r_bits_data; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_2_auto_in_r_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_r_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_in_r_bits_last; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_aw_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_aw_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_2_auto_out_aw_bits_id; // @[Buffer.scala 58:29]
  wire [31:0] axi4buf_2_auto_out_aw_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_aw_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_w_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_w_valid; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_2_auto_out_w_bits_data; // @[Buffer.scala 58:29]
  wire [15:0] axi4buf_2_auto_out_w_bits_strb; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_b_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_b_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_2_auto_out_b_bits_id; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_2_auto_out_b_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_b_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_ar_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_ar_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_2_auto_out_ar_bits_id; // @[Buffer.scala 58:29]
  wire [31:0] axi4buf_2_auto_out_ar_bits_addr; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_ar_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_r_ready; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_r_valid; // @[Buffer.scala 58:29]
  wire [3:0] axi4buf_2_auto_out_r_bits_id; // @[Buffer.scala 58:29]
  wire [127:0] axi4buf_2_auto_out_r_bits_data; // @[Buffer.scala 58:29]
  wire [1:0] axi4buf_2_auto_out_r_bits_resp; // @[Buffer.scala 58:29]
  wire  axi4buf_2_auto_out_r_bits_echo_real_last; // @[Buffer.scala 58:29]
  wire  axi4frag_2_clock; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_reset; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_aw_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_aw_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_2_auto_in_aw_bits_id; // @[Fragmenter.scala 205:30]
  wire [31:0] axi4frag_2_auto_in_aw_bits_addr; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_2_auto_in_aw_bits_len; // @[Fragmenter.scala 205:30]
  wire [2:0] axi4frag_2_auto_in_aw_bits_size; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_2_auto_in_aw_bits_burst; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_w_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_w_valid; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_2_auto_in_w_bits_data; // @[Fragmenter.scala 205:30]
  wire [15:0] axi4frag_2_auto_in_w_bits_strb; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_w_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_b_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_b_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_2_auto_in_b_bits_id; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_2_auto_in_b_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_ar_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_ar_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_2_auto_in_ar_bits_id; // @[Fragmenter.scala 205:30]
  wire [31:0] axi4frag_2_auto_in_ar_bits_addr; // @[Fragmenter.scala 205:30]
  wire [7:0] axi4frag_2_auto_in_ar_bits_len; // @[Fragmenter.scala 205:30]
  wire [2:0] axi4frag_2_auto_in_ar_bits_size; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_2_auto_in_ar_bits_burst; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_r_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_r_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_2_auto_in_r_bits_id; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_2_auto_in_r_bits_data; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_2_auto_in_r_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_in_r_bits_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_aw_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_aw_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_2_auto_out_aw_bits_id; // @[Fragmenter.scala 205:30]
  wire [31:0] axi4frag_2_auto_out_aw_bits_addr; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_aw_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_w_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_w_valid; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_2_auto_out_w_bits_data; // @[Fragmenter.scala 205:30]
  wire [15:0] axi4frag_2_auto_out_w_bits_strb; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_b_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_b_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_2_auto_out_b_bits_id; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_2_auto_out_b_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_b_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_ar_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_ar_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_2_auto_out_ar_bits_id; // @[Fragmenter.scala 205:30]
  wire [31:0] axi4frag_2_auto_out_ar_bits_addr; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_ar_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_r_ready; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_r_valid; // @[Fragmenter.scala 205:30]
  wire [3:0] axi4frag_2_auto_out_r_bits_id; // @[Fragmenter.scala 205:30]
  wire [127:0] axi4frag_2_auto_out_r_bits_data; // @[Fragmenter.scala 205:30]
  wire [1:0] axi4frag_2_auto_out_r_bits_resp; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_r_bits_echo_real_last; // @[Fragmenter.scala 205:30]
  wire  axi4frag_2_auto_out_r_bits_last; // @[Fragmenter.scala 205:30]
  AXI4RAM_1_inTestHarness srams ( // @[SimAXIMem.scala 16:15]
    .clock(srams_clock),
    .reset(srams_reset),
    .auto_in_aw_ready(srams_auto_in_aw_ready),
    .auto_in_aw_valid(srams_auto_in_aw_valid),
    .auto_in_aw_bits_id(srams_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(srams_auto_in_aw_bits_addr),
    .auto_in_aw_bits_echo_real_last(srams_auto_in_aw_bits_echo_real_last),
    .auto_in_w_ready(srams_auto_in_w_ready),
    .auto_in_w_valid(srams_auto_in_w_valid),
    .auto_in_w_bits_data(srams_auto_in_w_bits_data),
    .auto_in_w_bits_strb(srams_auto_in_w_bits_strb),
    .auto_in_b_ready(srams_auto_in_b_ready),
    .auto_in_b_valid(srams_auto_in_b_valid),
    .auto_in_b_bits_id(srams_auto_in_b_bits_id),
    .auto_in_b_bits_resp(srams_auto_in_b_bits_resp),
    .auto_in_b_bits_echo_real_last(srams_auto_in_b_bits_echo_real_last),
    .auto_in_ar_ready(srams_auto_in_ar_ready),
    .auto_in_ar_valid(srams_auto_in_ar_valid),
    .auto_in_ar_bits_id(srams_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(srams_auto_in_ar_bits_addr),
    .auto_in_ar_bits_echo_real_last(srams_auto_in_ar_bits_echo_real_last),
    .auto_in_r_ready(srams_auto_in_r_ready),
    .auto_in_r_valid(srams_auto_in_r_valid),
    .auto_in_r_bits_id(srams_auto_in_r_bits_id),
    .auto_in_r_bits_data(srams_auto_in_r_bits_data),
    .auto_in_r_bits_resp(srams_auto_in_r_bits_resp),
    .auto_in_r_bits_echo_real_last(srams_auto_in_r_bits_echo_real_last)
  );
  AXI4RAM_2_inTestHarness srams_1 ( // @[SimAXIMem.scala 16:15]
    .clock(srams_1_clock),
    .reset(srams_1_reset),
    .auto_in_aw_ready(srams_1_auto_in_aw_ready),
    .auto_in_aw_valid(srams_1_auto_in_aw_valid),
    .auto_in_aw_bits_id(srams_1_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(srams_1_auto_in_aw_bits_addr),
    .auto_in_aw_bits_echo_real_last(srams_1_auto_in_aw_bits_echo_real_last),
    .auto_in_w_ready(srams_1_auto_in_w_ready),
    .auto_in_w_valid(srams_1_auto_in_w_valid),
    .auto_in_w_bits_data(srams_1_auto_in_w_bits_data),
    .auto_in_w_bits_strb(srams_1_auto_in_w_bits_strb),
    .auto_in_b_ready(srams_1_auto_in_b_ready),
    .auto_in_b_valid(srams_1_auto_in_b_valid),
    .auto_in_b_bits_id(srams_1_auto_in_b_bits_id),
    .auto_in_b_bits_resp(srams_1_auto_in_b_bits_resp),
    .auto_in_b_bits_echo_real_last(srams_1_auto_in_b_bits_echo_real_last),
    .auto_in_ar_ready(srams_1_auto_in_ar_ready),
    .auto_in_ar_valid(srams_1_auto_in_ar_valid),
    .auto_in_ar_bits_id(srams_1_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(srams_1_auto_in_ar_bits_addr),
    .auto_in_ar_bits_echo_real_last(srams_1_auto_in_ar_bits_echo_real_last),
    .auto_in_r_ready(srams_1_auto_in_r_ready),
    .auto_in_r_valid(srams_1_auto_in_r_valid),
    .auto_in_r_bits_id(srams_1_auto_in_r_bits_id),
    .auto_in_r_bits_data(srams_1_auto_in_r_bits_data),
    .auto_in_r_bits_resp(srams_1_auto_in_r_bits_resp),
    .auto_in_r_bits_echo_real_last(srams_1_auto_in_r_bits_echo_real_last)
  );
  AXI4RAM_3_inTestHarness srams_2 ( // @[SimAXIMem.scala 16:15]
    .clock(srams_2_clock),
    .reset(srams_2_reset),
    .auto_in_aw_ready(srams_2_auto_in_aw_ready),
    .auto_in_aw_valid(srams_2_auto_in_aw_valid),
    .auto_in_aw_bits_id(srams_2_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(srams_2_auto_in_aw_bits_addr),
    .auto_in_aw_bits_echo_real_last(srams_2_auto_in_aw_bits_echo_real_last),
    .auto_in_w_ready(srams_2_auto_in_w_ready),
    .auto_in_w_valid(srams_2_auto_in_w_valid),
    .auto_in_w_bits_data(srams_2_auto_in_w_bits_data),
    .auto_in_w_bits_strb(srams_2_auto_in_w_bits_strb),
    .auto_in_b_ready(srams_2_auto_in_b_ready),
    .auto_in_b_valid(srams_2_auto_in_b_valid),
    .auto_in_b_bits_id(srams_2_auto_in_b_bits_id),
    .auto_in_b_bits_resp(srams_2_auto_in_b_bits_resp),
    .auto_in_b_bits_echo_real_last(srams_2_auto_in_b_bits_echo_real_last),
    .auto_in_ar_ready(srams_2_auto_in_ar_ready),
    .auto_in_ar_valid(srams_2_auto_in_ar_valid),
    .auto_in_ar_bits_id(srams_2_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(srams_2_auto_in_ar_bits_addr),
    .auto_in_ar_bits_echo_real_last(srams_2_auto_in_ar_bits_echo_real_last),
    .auto_in_r_ready(srams_2_auto_in_r_ready),
    .auto_in_r_valid(srams_2_auto_in_r_valid),
    .auto_in_r_bits_id(srams_2_auto_in_r_bits_id),
    .auto_in_r_bits_data(srams_2_auto_in_r_bits_data),
    .auto_in_r_bits_resp(srams_2_auto_in_r_bits_resp),
    .auto_in_r_bits_echo_real_last(srams_2_auto_in_r_bits_echo_real_last)
  );
  AXI4Xbar_1_inTestHarness axi4xbar ( // @[Xbar.scala 218:30]
    .clock(axi4xbar_clock),
    .reset(axi4xbar_reset),
    .auto_in_aw_ready(axi4xbar_auto_in_aw_ready),
    .auto_in_aw_valid(axi4xbar_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4xbar_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4xbar_auto_in_aw_bits_addr),
    .auto_in_aw_bits_len(axi4xbar_auto_in_aw_bits_len),
    .auto_in_aw_bits_size(axi4xbar_auto_in_aw_bits_size),
    .auto_in_aw_bits_burst(axi4xbar_auto_in_aw_bits_burst),
    .auto_in_w_ready(axi4xbar_auto_in_w_ready),
    .auto_in_w_valid(axi4xbar_auto_in_w_valid),
    .auto_in_w_bits_data(axi4xbar_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4xbar_auto_in_w_bits_strb),
    .auto_in_w_bits_last(axi4xbar_auto_in_w_bits_last),
    .auto_in_b_ready(axi4xbar_auto_in_b_ready),
    .auto_in_b_valid(axi4xbar_auto_in_b_valid),
    .auto_in_b_bits_id(axi4xbar_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4xbar_auto_in_b_bits_resp),
    .auto_in_ar_ready(axi4xbar_auto_in_ar_ready),
    .auto_in_ar_valid(axi4xbar_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4xbar_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4xbar_auto_in_ar_bits_addr),
    .auto_in_ar_bits_len(axi4xbar_auto_in_ar_bits_len),
    .auto_in_ar_bits_size(axi4xbar_auto_in_ar_bits_size),
    .auto_in_ar_bits_burst(axi4xbar_auto_in_ar_bits_burst),
    .auto_in_r_ready(axi4xbar_auto_in_r_ready),
    .auto_in_r_valid(axi4xbar_auto_in_r_valid),
    .auto_in_r_bits_id(axi4xbar_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4xbar_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4xbar_auto_in_r_bits_resp),
    .auto_in_r_bits_last(axi4xbar_auto_in_r_bits_last),
    .auto_out_2_aw_ready(axi4xbar_auto_out_2_aw_ready),
    .auto_out_2_aw_valid(axi4xbar_auto_out_2_aw_valid),
    .auto_out_2_aw_bits_id(axi4xbar_auto_out_2_aw_bits_id),
    .auto_out_2_aw_bits_addr(axi4xbar_auto_out_2_aw_bits_addr),
    .auto_out_2_aw_bits_len(axi4xbar_auto_out_2_aw_bits_len),
    .auto_out_2_aw_bits_size(axi4xbar_auto_out_2_aw_bits_size),
    .auto_out_2_aw_bits_burst(axi4xbar_auto_out_2_aw_bits_burst),
    .auto_out_2_w_ready(axi4xbar_auto_out_2_w_ready),
    .auto_out_2_w_valid(axi4xbar_auto_out_2_w_valid),
    .auto_out_2_w_bits_data(axi4xbar_auto_out_2_w_bits_data),
    .auto_out_2_w_bits_strb(axi4xbar_auto_out_2_w_bits_strb),
    .auto_out_2_w_bits_last(axi4xbar_auto_out_2_w_bits_last),
    .auto_out_2_b_ready(axi4xbar_auto_out_2_b_ready),
    .auto_out_2_b_valid(axi4xbar_auto_out_2_b_valid),
    .auto_out_2_b_bits_id(axi4xbar_auto_out_2_b_bits_id),
    .auto_out_2_b_bits_resp(axi4xbar_auto_out_2_b_bits_resp),
    .auto_out_2_ar_ready(axi4xbar_auto_out_2_ar_ready),
    .auto_out_2_ar_valid(axi4xbar_auto_out_2_ar_valid),
    .auto_out_2_ar_bits_id(axi4xbar_auto_out_2_ar_bits_id),
    .auto_out_2_ar_bits_addr(axi4xbar_auto_out_2_ar_bits_addr),
    .auto_out_2_ar_bits_len(axi4xbar_auto_out_2_ar_bits_len),
    .auto_out_2_ar_bits_size(axi4xbar_auto_out_2_ar_bits_size),
    .auto_out_2_ar_bits_burst(axi4xbar_auto_out_2_ar_bits_burst),
    .auto_out_2_r_ready(axi4xbar_auto_out_2_r_ready),
    .auto_out_2_r_valid(axi4xbar_auto_out_2_r_valid),
    .auto_out_2_r_bits_id(axi4xbar_auto_out_2_r_bits_id),
    .auto_out_2_r_bits_data(axi4xbar_auto_out_2_r_bits_data),
    .auto_out_2_r_bits_resp(axi4xbar_auto_out_2_r_bits_resp),
    .auto_out_2_r_bits_last(axi4xbar_auto_out_2_r_bits_last),
    .auto_out_1_aw_ready(axi4xbar_auto_out_1_aw_ready),
    .auto_out_1_aw_valid(axi4xbar_auto_out_1_aw_valid),
    .auto_out_1_aw_bits_id(axi4xbar_auto_out_1_aw_bits_id),
    .auto_out_1_aw_bits_addr(axi4xbar_auto_out_1_aw_bits_addr),
    .auto_out_1_aw_bits_len(axi4xbar_auto_out_1_aw_bits_len),
    .auto_out_1_aw_bits_size(axi4xbar_auto_out_1_aw_bits_size),
    .auto_out_1_aw_bits_burst(axi4xbar_auto_out_1_aw_bits_burst),
    .auto_out_1_w_ready(axi4xbar_auto_out_1_w_ready),
    .auto_out_1_w_valid(axi4xbar_auto_out_1_w_valid),
    .auto_out_1_w_bits_data(axi4xbar_auto_out_1_w_bits_data),
    .auto_out_1_w_bits_strb(axi4xbar_auto_out_1_w_bits_strb),
    .auto_out_1_w_bits_last(axi4xbar_auto_out_1_w_bits_last),
    .auto_out_1_b_ready(axi4xbar_auto_out_1_b_ready),
    .auto_out_1_b_valid(axi4xbar_auto_out_1_b_valid),
    .auto_out_1_b_bits_id(axi4xbar_auto_out_1_b_bits_id),
    .auto_out_1_b_bits_resp(axi4xbar_auto_out_1_b_bits_resp),
    .auto_out_1_ar_ready(axi4xbar_auto_out_1_ar_ready),
    .auto_out_1_ar_valid(axi4xbar_auto_out_1_ar_valid),
    .auto_out_1_ar_bits_id(axi4xbar_auto_out_1_ar_bits_id),
    .auto_out_1_ar_bits_addr(axi4xbar_auto_out_1_ar_bits_addr),
    .auto_out_1_ar_bits_len(axi4xbar_auto_out_1_ar_bits_len),
    .auto_out_1_ar_bits_size(axi4xbar_auto_out_1_ar_bits_size),
    .auto_out_1_ar_bits_burst(axi4xbar_auto_out_1_ar_bits_burst),
    .auto_out_1_r_ready(axi4xbar_auto_out_1_r_ready),
    .auto_out_1_r_valid(axi4xbar_auto_out_1_r_valid),
    .auto_out_1_r_bits_id(axi4xbar_auto_out_1_r_bits_id),
    .auto_out_1_r_bits_data(axi4xbar_auto_out_1_r_bits_data),
    .auto_out_1_r_bits_resp(axi4xbar_auto_out_1_r_bits_resp),
    .auto_out_1_r_bits_last(axi4xbar_auto_out_1_r_bits_last),
    .auto_out_0_aw_ready(axi4xbar_auto_out_0_aw_ready),
    .auto_out_0_aw_valid(axi4xbar_auto_out_0_aw_valid),
    .auto_out_0_aw_bits_id(axi4xbar_auto_out_0_aw_bits_id),
    .auto_out_0_aw_bits_addr(axi4xbar_auto_out_0_aw_bits_addr),
    .auto_out_0_aw_bits_len(axi4xbar_auto_out_0_aw_bits_len),
    .auto_out_0_aw_bits_size(axi4xbar_auto_out_0_aw_bits_size),
    .auto_out_0_aw_bits_burst(axi4xbar_auto_out_0_aw_bits_burst),
    .auto_out_0_w_ready(axi4xbar_auto_out_0_w_ready),
    .auto_out_0_w_valid(axi4xbar_auto_out_0_w_valid),
    .auto_out_0_w_bits_data(axi4xbar_auto_out_0_w_bits_data),
    .auto_out_0_w_bits_strb(axi4xbar_auto_out_0_w_bits_strb),
    .auto_out_0_w_bits_last(axi4xbar_auto_out_0_w_bits_last),
    .auto_out_0_b_ready(axi4xbar_auto_out_0_b_ready),
    .auto_out_0_b_valid(axi4xbar_auto_out_0_b_valid),
    .auto_out_0_b_bits_id(axi4xbar_auto_out_0_b_bits_id),
    .auto_out_0_b_bits_resp(axi4xbar_auto_out_0_b_bits_resp),
    .auto_out_0_ar_ready(axi4xbar_auto_out_0_ar_ready),
    .auto_out_0_ar_valid(axi4xbar_auto_out_0_ar_valid),
    .auto_out_0_ar_bits_id(axi4xbar_auto_out_0_ar_bits_id),
    .auto_out_0_ar_bits_addr(axi4xbar_auto_out_0_ar_bits_addr),
    .auto_out_0_ar_bits_len(axi4xbar_auto_out_0_ar_bits_len),
    .auto_out_0_ar_bits_size(axi4xbar_auto_out_0_ar_bits_size),
    .auto_out_0_ar_bits_burst(axi4xbar_auto_out_0_ar_bits_burst),
    .auto_out_0_r_ready(axi4xbar_auto_out_0_r_ready),
    .auto_out_0_r_valid(axi4xbar_auto_out_0_r_valid),
    .auto_out_0_r_bits_id(axi4xbar_auto_out_0_r_bits_id),
    .auto_out_0_r_bits_data(axi4xbar_auto_out_0_r_bits_data),
    .auto_out_0_r_bits_resp(axi4xbar_auto_out_0_r_bits_resp),
    .auto_out_0_r_bits_last(axi4xbar_auto_out_0_r_bits_last)
  );
  AXI4Buffer_2_inTestHarness axi4buf ( // @[Buffer.scala 58:29]
    .clock(axi4buf_clock),
    .reset(axi4buf_reset),
    .auto_in_aw_ready(axi4buf_auto_in_aw_ready),
    .auto_in_aw_valid(axi4buf_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4buf_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4buf_auto_in_aw_bits_addr),
    .auto_in_aw_bits_echo_real_last(axi4buf_auto_in_aw_bits_echo_real_last),
    .auto_in_w_ready(axi4buf_auto_in_w_ready),
    .auto_in_w_valid(axi4buf_auto_in_w_valid),
    .auto_in_w_bits_data(axi4buf_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4buf_auto_in_w_bits_strb),
    .auto_in_b_ready(axi4buf_auto_in_b_ready),
    .auto_in_b_valid(axi4buf_auto_in_b_valid),
    .auto_in_b_bits_id(axi4buf_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4buf_auto_in_b_bits_resp),
    .auto_in_b_bits_echo_real_last(axi4buf_auto_in_b_bits_echo_real_last),
    .auto_in_ar_ready(axi4buf_auto_in_ar_ready),
    .auto_in_ar_valid(axi4buf_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4buf_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4buf_auto_in_ar_bits_addr),
    .auto_in_ar_bits_echo_real_last(axi4buf_auto_in_ar_bits_echo_real_last),
    .auto_in_r_ready(axi4buf_auto_in_r_ready),
    .auto_in_r_valid(axi4buf_auto_in_r_valid),
    .auto_in_r_bits_id(axi4buf_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4buf_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4buf_auto_in_r_bits_resp),
    .auto_in_r_bits_echo_real_last(axi4buf_auto_in_r_bits_echo_real_last),
    .auto_in_r_bits_last(axi4buf_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4buf_auto_out_aw_ready),
    .auto_out_aw_valid(axi4buf_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4buf_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4buf_auto_out_aw_bits_addr),
    .auto_out_aw_bits_echo_real_last(axi4buf_auto_out_aw_bits_echo_real_last),
    .auto_out_w_ready(axi4buf_auto_out_w_ready),
    .auto_out_w_valid(axi4buf_auto_out_w_valid),
    .auto_out_w_bits_data(axi4buf_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4buf_auto_out_w_bits_strb),
    .auto_out_b_ready(axi4buf_auto_out_b_ready),
    .auto_out_b_valid(axi4buf_auto_out_b_valid),
    .auto_out_b_bits_id(axi4buf_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4buf_auto_out_b_bits_resp),
    .auto_out_b_bits_echo_real_last(axi4buf_auto_out_b_bits_echo_real_last),
    .auto_out_ar_ready(axi4buf_auto_out_ar_ready),
    .auto_out_ar_valid(axi4buf_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4buf_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4buf_auto_out_ar_bits_addr),
    .auto_out_ar_bits_echo_real_last(axi4buf_auto_out_ar_bits_echo_real_last),
    .auto_out_r_ready(axi4buf_auto_out_r_ready),
    .auto_out_r_valid(axi4buf_auto_out_r_valid),
    .auto_out_r_bits_id(axi4buf_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4buf_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4buf_auto_out_r_bits_resp),
    .auto_out_r_bits_echo_real_last(axi4buf_auto_out_r_bits_echo_real_last)
  );
  AXI4Fragmenter_2_inTestHarness axi4frag ( // @[Fragmenter.scala 205:30]
    .clock(axi4frag_clock),
    .reset(axi4frag_reset),
    .auto_in_aw_ready(axi4frag_auto_in_aw_ready),
    .auto_in_aw_valid(axi4frag_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4frag_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4frag_auto_in_aw_bits_addr),
    .auto_in_aw_bits_len(axi4frag_auto_in_aw_bits_len),
    .auto_in_aw_bits_size(axi4frag_auto_in_aw_bits_size),
    .auto_in_aw_bits_burst(axi4frag_auto_in_aw_bits_burst),
    .auto_in_w_ready(axi4frag_auto_in_w_ready),
    .auto_in_w_valid(axi4frag_auto_in_w_valid),
    .auto_in_w_bits_data(axi4frag_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4frag_auto_in_w_bits_strb),
    .auto_in_w_bits_last(axi4frag_auto_in_w_bits_last),
    .auto_in_b_ready(axi4frag_auto_in_b_ready),
    .auto_in_b_valid(axi4frag_auto_in_b_valid),
    .auto_in_b_bits_id(axi4frag_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4frag_auto_in_b_bits_resp),
    .auto_in_ar_ready(axi4frag_auto_in_ar_ready),
    .auto_in_ar_valid(axi4frag_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4frag_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4frag_auto_in_ar_bits_addr),
    .auto_in_ar_bits_len(axi4frag_auto_in_ar_bits_len),
    .auto_in_ar_bits_size(axi4frag_auto_in_ar_bits_size),
    .auto_in_ar_bits_burst(axi4frag_auto_in_ar_bits_burst),
    .auto_in_r_ready(axi4frag_auto_in_r_ready),
    .auto_in_r_valid(axi4frag_auto_in_r_valid),
    .auto_in_r_bits_id(axi4frag_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4frag_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4frag_auto_in_r_bits_resp),
    .auto_in_r_bits_last(axi4frag_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4frag_auto_out_aw_ready),
    .auto_out_aw_valid(axi4frag_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4frag_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4frag_auto_out_aw_bits_addr),
    .auto_out_aw_bits_echo_real_last(axi4frag_auto_out_aw_bits_echo_real_last),
    .auto_out_w_ready(axi4frag_auto_out_w_ready),
    .auto_out_w_valid(axi4frag_auto_out_w_valid),
    .auto_out_w_bits_data(axi4frag_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4frag_auto_out_w_bits_strb),
    .auto_out_b_ready(axi4frag_auto_out_b_ready),
    .auto_out_b_valid(axi4frag_auto_out_b_valid),
    .auto_out_b_bits_id(axi4frag_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4frag_auto_out_b_bits_resp),
    .auto_out_b_bits_echo_real_last(axi4frag_auto_out_b_bits_echo_real_last),
    .auto_out_ar_ready(axi4frag_auto_out_ar_ready),
    .auto_out_ar_valid(axi4frag_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4frag_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4frag_auto_out_ar_bits_addr),
    .auto_out_ar_bits_echo_real_last(axi4frag_auto_out_ar_bits_echo_real_last),
    .auto_out_r_ready(axi4frag_auto_out_r_ready),
    .auto_out_r_valid(axi4frag_auto_out_r_valid),
    .auto_out_r_bits_id(axi4frag_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4frag_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4frag_auto_out_r_bits_resp),
    .auto_out_r_bits_echo_real_last(axi4frag_auto_out_r_bits_echo_real_last),
    .auto_out_r_bits_last(axi4frag_auto_out_r_bits_last)
  );
  AXI4Buffer_3_inTestHarness axi4buf_1 ( // @[Buffer.scala 58:29]
    .clock(axi4buf_1_clock),
    .reset(axi4buf_1_reset),
    .auto_in_aw_ready(axi4buf_1_auto_in_aw_ready),
    .auto_in_aw_valid(axi4buf_1_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4buf_1_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4buf_1_auto_in_aw_bits_addr),
    .auto_in_aw_bits_echo_real_last(axi4buf_1_auto_in_aw_bits_echo_real_last),
    .auto_in_w_ready(axi4buf_1_auto_in_w_ready),
    .auto_in_w_valid(axi4buf_1_auto_in_w_valid),
    .auto_in_w_bits_data(axi4buf_1_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4buf_1_auto_in_w_bits_strb),
    .auto_in_b_ready(axi4buf_1_auto_in_b_ready),
    .auto_in_b_valid(axi4buf_1_auto_in_b_valid),
    .auto_in_b_bits_id(axi4buf_1_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4buf_1_auto_in_b_bits_resp),
    .auto_in_b_bits_echo_real_last(axi4buf_1_auto_in_b_bits_echo_real_last),
    .auto_in_ar_ready(axi4buf_1_auto_in_ar_ready),
    .auto_in_ar_valid(axi4buf_1_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4buf_1_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4buf_1_auto_in_ar_bits_addr),
    .auto_in_ar_bits_echo_real_last(axi4buf_1_auto_in_ar_bits_echo_real_last),
    .auto_in_r_ready(axi4buf_1_auto_in_r_ready),
    .auto_in_r_valid(axi4buf_1_auto_in_r_valid),
    .auto_in_r_bits_id(axi4buf_1_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4buf_1_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4buf_1_auto_in_r_bits_resp),
    .auto_in_r_bits_echo_real_last(axi4buf_1_auto_in_r_bits_echo_real_last),
    .auto_in_r_bits_last(axi4buf_1_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4buf_1_auto_out_aw_ready),
    .auto_out_aw_valid(axi4buf_1_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4buf_1_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4buf_1_auto_out_aw_bits_addr),
    .auto_out_aw_bits_echo_real_last(axi4buf_1_auto_out_aw_bits_echo_real_last),
    .auto_out_w_ready(axi4buf_1_auto_out_w_ready),
    .auto_out_w_valid(axi4buf_1_auto_out_w_valid),
    .auto_out_w_bits_data(axi4buf_1_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4buf_1_auto_out_w_bits_strb),
    .auto_out_b_ready(axi4buf_1_auto_out_b_ready),
    .auto_out_b_valid(axi4buf_1_auto_out_b_valid),
    .auto_out_b_bits_id(axi4buf_1_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4buf_1_auto_out_b_bits_resp),
    .auto_out_b_bits_echo_real_last(axi4buf_1_auto_out_b_bits_echo_real_last),
    .auto_out_ar_ready(axi4buf_1_auto_out_ar_ready),
    .auto_out_ar_valid(axi4buf_1_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4buf_1_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4buf_1_auto_out_ar_bits_addr),
    .auto_out_ar_bits_echo_real_last(axi4buf_1_auto_out_ar_bits_echo_real_last),
    .auto_out_r_ready(axi4buf_1_auto_out_r_ready),
    .auto_out_r_valid(axi4buf_1_auto_out_r_valid),
    .auto_out_r_bits_id(axi4buf_1_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4buf_1_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4buf_1_auto_out_r_bits_resp),
    .auto_out_r_bits_echo_real_last(axi4buf_1_auto_out_r_bits_echo_real_last)
  );
  AXI4Fragmenter_3_inTestHarness axi4frag_1 ( // @[Fragmenter.scala 205:30]
    .clock(axi4frag_1_clock),
    .reset(axi4frag_1_reset),
    .auto_in_aw_ready(axi4frag_1_auto_in_aw_ready),
    .auto_in_aw_valid(axi4frag_1_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4frag_1_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4frag_1_auto_in_aw_bits_addr),
    .auto_in_aw_bits_len(axi4frag_1_auto_in_aw_bits_len),
    .auto_in_aw_bits_size(axi4frag_1_auto_in_aw_bits_size),
    .auto_in_aw_bits_burst(axi4frag_1_auto_in_aw_bits_burst),
    .auto_in_w_ready(axi4frag_1_auto_in_w_ready),
    .auto_in_w_valid(axi4frag_1_auto_in_w_valid),
    .auto_in_w_bits_data(axi4frag_1_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4frag_1_auto_in_w_bits_strb),
    .auto_in_w_bits_last(axi4frag_1_auto_in_w_bits_last),
    .auto_in_b_ready(axi4frag_1_auto_in_b_ready),
    .auto_in_b_valid(axi4frag_1_auto_in_b_valid),
    .auto_in_b_bits_id(axi4frag_1_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4frag_1_auto_in_b_bits_resp),
    .auto_in_ar_ready(axi4frag_1_auto_in_ar_ready),
    .auto_in_ar_valid(axi4frag_1_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4frag_1_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4frag_1_auto_in_ar_bits_addr),
    .auto_in_ar_bits_len(axi4frag_1_auto_in_ar_bits_len),
    .auto_in_ar_bits_size(axi4frag_1_auto_in_ar_bits_size),
    .auto_in_ar_bits_burst(axi4frag_1_auto_in_ar_bits_burst),
    .auto_in_r_ready(axi4frag_1_auto_in_r_ready),
    .auto_in_r_valid(axi4frag_1_auto_in_r_valid),
    .auto_in_r_bits_id(axi4frag_1_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4frag_1_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4frag_1_auto_in_r_bits_resp),
    .auto_in_r_bits_last(axi4frag_1_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4frag_1_auto_out_aw_ready),
    .auto_out_aw_valid(axi4frag_1_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4frag_1_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4frag_1_auto_out_aw_bits_addr),
    .auto_out_aw_bits_echo_real_last(axi4frag_1_auto_out_aw_bits_echo_real_last),
    .auto_out_w_ready(axi4frag_1_auto_out_w_ready),
    .auto_out_w_valid(axi4frag_1_auto_out_w_valid),
    .auto_out_w_bits_data(axi4frag_1_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4frag_1_auto_out_w_bits_strb),
    .auto_out_b_ready(axi4frag_1_auto_out_b_ready),
    .auto_out_b_valid(axi4frag_1_auto_out_b_valid),
    .auto_out_b_bits_id(axi4frag_1_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4frag_1_auto_out_b_bits_resp),
    .auto_out_b_bits_echo_real_last(axi4frag_1_auto_out_b_bits_echo_real_last),
    .auto_out_ar_ready(axi4frag_1_auto_out_ar_ready),
    .auto_out_ar_valid(axi4frag_1_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4frag_1_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4frag_1_auto_out_ar_bits_addr),
    .auto_out_ar_bits_echo_real_last(axi4frag_1_auto_out_ar_bits_echo_real_last),
    .auto_out_r_ready(axi4frag_1_auto_out_r_ready),
    .auto_out_r_valid(axi4frag_1_auto_out_r_valid),
    .auto_out_r_bits_id(axi4frag_1_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4frag_1_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4frag_1_auto_out_r_bits_resp),
    .auto_out_r_bits_echo_real_last(axi4frag_1_auto_out_r_bits_echo_real_last),
    .auto_out_r_bits_last(axi4frag_1_auto_out_r_bits_last)
  );
  AXI4Buffer_3_inTestHarness axi4buf_2 ( // @[Buffer.scala 58:29]
    .clock(axi4buf_2_clock),
    .reset(axi4buf_2_reset),
    .auto_in_aw_ready(axi4buf_2_auto_in_aw_ready),
    .auto_in_aw_valid(axi4buf_2_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4buf_2_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4buf_2_auto_in_aw_bits_addr),
    .auto_in_aw_bits_echo_real_last(axi4buf_2_auto_in_aw_bits_echo_real_last),
    .auto_in_w_ready(axi4buf_2_auto_in_w_ready),
    .auto_in_w_valid(axi4buf_2_auto_in_w_valid),
    .auto_in_w_bits_data(axi4buf_2_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4buf_2_auto_in_w_bits_strb),
    .auto_in_b_ready(axi4buf_2_auto_in_b_ready),
    .auto_in_b_valid(axi4buf_2_auto_in_b_valid),
    .auto_in_b_bits_id(axi4buf_2_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4buf_2_auto_in_b_bits_resp),
    .auto_in_b_bits_echo_real_last(axi4buf_2_auto_in_b_bits_echo_real_last),
    .auto_in_ar_ready(axi4buf_2_auto_in_ar_ready),
    .auto_in_ar_valid(axi4buf_2_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4buf_2_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4buf_2_auto_in_ar_bits_addr),
    .auto_in_ar_bits_echo_real_last(axi4buf_2_auto_in_ar_bits_echo_real_last),
    .auto_in_r_ready(axi4buf_2_auto_in_r_ready),
    .auto_in_r_valid(axi4buf_2_auto_in_r_valid),
    .auto_in_r_bits_id(axi4buf_2_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4buf_2_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4buf_2_auto_in_r_bits_resp),
    .auto_in_r_bits_echo_real_last(axi4buf_2_auto_in_r_bits_echo_real_last),
    .auto_in_r_bits_last(axi4buf_2_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4buf_2_auto_out_aw_ready),
    .auto_out_aw_valid(axi4buf_2_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4buf_2_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4buf_2_auto_out_aw_bits_addr),
    .auto_out_aw_bits_echo_real_last(axi4buf_2_auto_out_aw_bits_echo_real_last),
    .auto_out_w_ready(axi4buf_2_auto_out_w_ready),
    .auto_out_w_valid(axi4buf_2_auto_out_w_valid),
    .auto_out_w_bits_data(axi4buf_2_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4buf_2_auto_out_w_bits_strb),
    .auto_out_b_ready(axi4buf_2_auto_out_b_ready),
    .auto_out_b_valid(axi4buf_2_auto_out_b_valid),
    .auto_out_b_bits_id(axi4buf_2_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4buf_2_auto_out_b_bits_resp),
    .auto_out_b_bits_echo_real_last(axi4buf_2_auto_out_b_bits_echo_real_last),
    .auto_out_ar_ready(axi4buf_2_auto_out_ar_ready),
    .auto_out_ar_valid(axi4buf_2_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4buf_2_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4buf_2_auto_out_ar_bits_addr),
    .auto_out_ar_bits_echo_real_last(axi4buf_2_auto_out_ar_bits_echo_real_last),
    .auto_out_r_ready(axi4buf_2_auto_out_r_ready),
    .auto_out_r_valid(axi4buf_2_auto_out_r_valid),
    .auto_out_r_bits_id(axi4buf_2_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4buf_2_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4buf_2_auto_out_r_bits_resp),
    .auto_out_r_bits_echo_real_last(axi4buf_2_auto_out_r_bits_echo_real_last)
  );
  AXI4Fragmenter_3_inTestHarness axi4frag_2 ( // @[Fragmenter.scala 205:30]
    .clock(axi4frag_2_clock),
    .reset(axi4frag_2_reset),
    .auto_in_aw_ready(axi4frag_2_auto_in_aw_ready),
    .auto_in_aw_valid(axi4frag_2_auto_in_aw_valid),
    .auto_in_aw_bits_id(axi4frag_2_auto_in_aw_bits_id),
    .auto_in_aw_bits_addr(axi4frag_2_auto_in_aw_bits_addr),
    .auto_in_aw_bits_len(axi4frag_2_auto_in_aw_bits_len),
    .auto_in_aw_bits_size(axi4frag_2_auto_in_aw_bits_size),
    .auto_in_aw_bits_burst(axi4frag_2_auto_in_aw_bits_burst),
    .auto_in_w_ready(axi4frag_2_auto_in_w_ready),
    .auto_in_w_valid(axi4frag_2_auto_in_w_valid),
    .auto_in_w_bits_data(axi4frag_2_auto_in_w_bits_data),
    .auto_in_w_bits_strb(axi4frag_2_auto_in_w_bits_strb),
    .auto_in_w_bits_last(axi4frag_2_auto_in_w_bits_last),
    .auto_in_b_ready(axi4frag_2_auto_in_b_ready),
    .auto_in_b_valid(axi4frag_2_auto_in_b_valid),
    .auto_in_b_bits_id(axi4frag_2_auto_in_b_bits_id),
    .auto_in_b_bits_resp(axi4frag_2_auto_in_b_bits_resp),
    .auto_in_ar_ready(axi4frag_2_auto_in_ar_ready),
    .auto_in_ar_valid(axi4frag_2_auto_in_ar_valid),
    .auto_in_ar_bits_id(axi4frag_2_auto_in_ar_bits_id),
    .auto_in_ar_bits_addr(axi4frag_2_auto_in_ar_bits_addr),
    .auto_in_ar_bits_len(axi4frag_2_auto_in_ar_bits_len),
    .auto_in_ar_bits_size(axi4frag_2_auto_in_ar_bits_size),
    .auto_in_ar_bits_burst(axi4frag_2_auto_in_ar_bits_burst),
    .auto_in_r_ready(axi4frag_2_auto_in_r_ready),
    .auto_in_r_valid(axi4frag_2_auto_in_r_valid),
    .auto_in_r_bits_id(axi4frag_2_auto_in_r_bits_id),
    .auto_in_r_bits_data(axi4frag_2_auto_in_r_bits_data),
    .auto_in_r_bits_resp(axi4frag_2_auto_in_r_bits_resp),
    .auto_in_r_bits_last(axi4frag_2_auto_in_r_bits_last),
    .auto_out_aw_ready(axi4frag_2_auto_out_aw_ready),
    .auto_out_aw_valid(axi4frag_2_auto_out_aw_valid),
    .auto_out_aw_bits_id(axi4frag_2_auto_out_aw_bits_id),
    .auto_out_aw_bits_addr(axi4frag_2_auto_out_aw_bits_addr),
    .auto_out_aw_bits_echo_real_last(axi4frag_2_auto_out_aw_bits_echo_real_last),
    .auto_out_w_ready(axi4frag_2_auto_out_w_ready),
    .auto_out_w_valid(axi4frag_2_auto_out_w_valid),
    .auto_out_w_bits_data(axi4frag_2_auto_out_w_bits_data),
    .auto_out_w_bits_strb(axi4frag_2_auto_out_w_bits_strb),
    .auto_out_b_ready(axi4frag_2_auto_out_b_ready),
    .auto_out_b_valid(axi4frag_2_auto_out_b_valid),
    .auto_out_b_bits_id(axi4frag_2_auto_out_b_bits_id),
    .auto_out_b_bits_resp(axi4frag_2_auto_out_b_bits_resp),
    .auto_out_b_bits_echo_real_last(axi4frag_2_auto_out_b_bits_echo_real_last),
    .auto_out_ar_ready(axi4frag_2_auto_out_ar_ready),
    .auto_out_ar_valid(axi4frag_2_auto_out_ar_valid),
    .auto_out_ar_bits_id(axi4frag_2_auto_out_ar_bits_id),
    .auto_out_ar_bits_addr(axi4frag_2_auto_out_ar_bits_addr),
    .auto_out_ar_bits_echo_real_last(axi4frag_2_auto_out_ar_bits_echo_real_last),
    .auto_out_r_ready(axi4frag_2_auto_out_r_ready),
    .auto_out_r_valid(axi4frag_2_auto_out_r_valid),
    .auto_out_r_bits_id(axi4frag_2_auto_out_r_bits_id),
    .auto_out_r_bits_data(axi4frag_2_auto_out_r_bits_data),
    .auto_out_r_bits_resp(axi4frag_2_auto_out_r_bits_resp),
    .auto_out_r_bits_echo_real_last(axi4frag_2_auto_out_r_bits_echo_real_last),
    .auto_out_r_bits_last(axi4frag_2_auto_out_r_bits_last)
  );
  assign io_axi4_0_aw_ready = axi4xbar_auto_in_aw_ready; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_w_ready = axi4xbar_auto_in_w_ready; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_b_valid = axi4xbar_auto_in_b_valid; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_b_bits_id = axi4xbar_auto_in_b_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_b_bits_resp = axi4xbar_auto_in_b_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_ar_ready = axi4xbar_auto_in_ar_ready; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_valid = axi4xbar_auto_in_r_valid; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_bits_id = axi4xbar_auto_in_r_bits_id; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_bits_data = axi4xbar_auto_in_r_bits_data; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_bits_resp = axi4xbar_auto_in_r_bits_resp; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign io_axi4_0_r_bits_last = axi4xbar_auto_in_r_bits_last; // @[Nodes.scala 1207:84 LazyModule.scala 298:16]
  assign srams_clock = clock;
  assign srams_reset = reset;
  assign srams_auto_in_aw_valid = axi4buf_auto_out_aw_valid; // @[LazyModule.scala 296:16]
  assign srams_auto_in_aw_bits_id = axi4buf_auto_out_aw_bits_id; // @[LazyModule.scala 296:16]
  assign srams_auto_in_aw_bits_addr = axi4buf_auto_out_aw_bits_addr; // @[LazyModule.scala 296:16]
  assign srams_auto_in_aw_bits_echo_real_last = axi4buf_auto_out_aw_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign srams_auto_in_w_valid = axi4buf_auto_out_w_valid; // @[LazyModule.scala 296:16]
  assign srams_auto_in_w_bits_data = axi4buf_auto_out_w_bits_data; // @[LazyModule.scala 296:16]
  assign srams_auto_in_w_bits_strb = axi4buf_auto_out_w_bits_strb; // @[LazyModule.scala 296:16]
  assign srams_auto_in_b_ready = axi4buf_auto_out_b_ready; // @[LazyModule.scala 296:16]
  assign srams_auto_in_ar_valid = axi4buf_auto_out_ar_valid; // @[LazyModule.scala 296:16]
  assign srams_auto_in_ar_bits_id = axi4buf_auto_out_ar_bits_id; // @[LazyModule.scala 296:16]
  assign srams_auto_in_ar_bits_addr = axi4buf_auto_out_ar_bits_addr; // @[LazyModule.scala 296:16]
  assign srams_auto_in_ar_bits_echo_real_last = axi4buf_auto_out_ar_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign srams_auto_in_r_ready = axi4buf_auto_out_r_ready; // @[LazyModule.scala 296:16]
  assign srams_1_clock = clock;
  assign srams_1_reset = reset;
  assign srams_1_auto_in_aw_valid = axi4buf_1_auto_out_aw_valid; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_aw_bits_id = axi4buf_1_auto_out_aw_bits_id; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_aw_bits_addr = axi4buf_1_auto_out_aw_bits_addr; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_aw_bits_echo_real_last = axi4buf_1_auto_out_aw_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_w_valid = axi4buf_1_auto_out_w_valid; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_w_bits_data = axi4buf_1_auto_out_w_bits_data; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_w_bits_strb = axi4buf_1_auto_out_w_bits_strb; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_b_ready = axi4buf_1_auto_out_b_ready; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_ar_valid = axi4buf_1_auto_out_ar_valid; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_ar_bits_id = axi4buf_1_auto_out_ar_bits_id; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_ar_bits_addr = axi4buf_1_auto_out_ar_bits_addr; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_ar_bits_echo_real_last = axi4buf_1_auto_out_ar_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign srams_1_auto_in_r_ready = axi4buf_1_auto_out_r_ready; // @[LazyModule.scala 296:16]
  assign srams_2_clock = clock;
  assign srams_2_reset = reset;
  assign srams_2_auto_in_aw_valid = axi4buf_2_auto_out_aw_valid; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_aw_bits_id = axi4buf_2_auto_out_aw_bits_id; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_aw_bits_addr = axi4buf_2_auto_out_aw_bits_addr; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_aw_bits_echo_real_last = axi4buf_2_auto_out_aw_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_w_valid = axi4buf_2_auto_out_w_valid; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_w_bits_data = axi4buf_2_auto_out_w_bits_data; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_w_bits_strb = axi4buf_2_auto_out_w_bits_strb; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_b_ready = axi4buf_2_auto_out_b_ready; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_ar_valid = axi4buf_2_auto_out_ar_valid; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_ar_bits_id = axi4buf_2_auto_out_ar_bits_id; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_ar_bits_addr = axi4buf_2_auto_out_ar_bits_addr; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_ar_bits_echo_real_last = axi4buf_2_auto_out_ar_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign srams_2_auto_in_r_ready = axi4buf_2_auto_out_r_ready; // @[LazyModule.scala 296:16]
  assign axi4xbar_clock = clock;
  assign axi4xbar_reset = reset;
  assign axi4xbar_auto_in_aw_valid = io_axi4_0_aw_valid; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_id = io_axi4_0_aw_bits_id; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_addr = io_axi4_0_aw_bits_addr; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_len = io_axi4_0_aw_bits_len; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_size = io_axi4_0_aw_bits_size; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_aw_bits_burst = io_axi4_0_aw_bits_burst; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_w_valid = io_axi4_0_w_valid; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_w_bits_data = io_axi4_0_w_bits_data; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_w_bits_strb = io_axi4_0_w_bits_strb; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_w_bits_last = io_axi4_0_w_bits_last; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_b_ready = io_axi4_0_b_ready; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_valid = io_axi4_0_ar_valid; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_id = io_axi4_0_ar_bits_id; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_addr = io_axi4_0_ar_bits_addr; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_len = io_axi4_0_ar_bits_len; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_size = io_axi4_0_ar_bits_size; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_ar_bits_burst = io_axi4_0_ar_bits_burst; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_in_r_ready = io_axi4_0_r_ready; // @[Nodes.scala 1207:84 Nodes.scala 1630:60]
  assign axi4xbar_auto_out_2_aw_ready = axi4frag_2_auto_in_aw_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_w_ready = axi4frag_2_auto_in_w_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_b_valid = axi4frag_2_auto_in_b_valid; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_b_bits_id = axi4frag_2_auto_in_b_bits_id; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_b_bits_resp = axi4frag_2_auto_in_b_bits_resp; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_ar_ready = axi4frag_2_auto_in_ar_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_r_valid = axi4frag_2_auto_in_r_valid; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_r_bits_id = axi4frag_2_auto_in_r_bits_id; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_r_bits_data = axi4frag_2_auto_in_r_bits_data; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_r_bits_resp = axi4frag_2_auto_in_r_bits_resp; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_2_r_bits_last = axi4frag_2_auto_in_r_bits_last; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_aw_ready = axi4frag_1_auto_in_aw_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_w_ready = axi4frag_1_auto_in_w_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_b_valid = axi4frag_1_auto_in_b_valid; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_b_bits_id = axi4frag_1_auto_in_b_bits_id; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_b_bits_resp = axi4frag_1_auto_in_b_bits_resp; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_ar_ready = axi4frag_1_auto_in_ar_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_r_valid = axi4frag_1_auto_in_r_valid; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_r_bits_id = axi4frag_1_auto_in_r_bits_id; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_r_bits_data = axi4frag_1_auto_in_r_bits_data; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_r_bits_resp = axi4frag_1_auto_in_r_bits_resp; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_1_r_bits_last = axi4frag_1_auto_in_r_bits_last; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_aw_ready = axi4frag_auto_in_aw_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_w_ready = axi4frag_auto_in_w_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_b_valid = axi4frag_auto_in_b_valid; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_b_bits_id = axi4frag_auto_in_b_bits_id; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_b_bits_resp = axi4frag_auto_in_b_bits_resp; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_ar_ready = axi4frag_auto_in_ar_ready; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_r_valid = axi4frag_auto_in_r_valid; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_r_bits_id = axi4frag_auto_in_r_bits_id; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_r_bits_data = axi4frag_auto_in_r_bits_data; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_r_bits_resp = axi4frag_auto_in_r_bits_resp; // @[LazyModule.scala 298:16]
  assign axi4xbar_auto_out_0_r_bits_last = axi4frag_auto_in_r_bits_last; // @[LazyModule.scala 298:16]
  assign axi4buf_clock = clock;
  assign axi4buf_reset = reset;
  assign axi4buf_auto_in_aw_valid = axi4frag_auto_out_aw_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_aw_bits_id = axi4frag_auto_out_aw_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_aw_bits_addr = axi4frag_auto_out_aw_bits_addr; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_aw_bits_echo_real_last = axi4frag_auto_out_aw_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_w_valid = axi4frag_auto_out_w_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_w_bits_data = axi4frag_auto_out_w_bits_data; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_w_bits_strb = axi4frag_auto_out_w_bits_strb; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_b_ready = axi4frag_auto_out_b_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_ar_valid = axi4frag_auto_out_ar_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_ar_bits_id = axi4frag_auto_out_ar_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_ar_bits_addr = axi4frag_auto_out_ar_bits_addr; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_ar_bits_echo_real_last = axi4frag_auto_out_ar_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_in_r_ready = axi4frag_auto_out_r_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_aw_ready = srams_auto_in_aw_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_w_ready = srams_auto_in_w_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_b_valid = srams_auto_in_b_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_b_bits_id = srams_auto_in_b_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_b_bits_resp = srams_auto_in_b_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_b_bits_echo_real_last = srams_auto_in_b_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_ar_ready = srams_auto_in_ar_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_valid = srams_auto_in_r_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_bits_id = srams_auto_in_r_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_bits_data = srams_auto_in_r_bits_data; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_bits_resp = srams_auto_in_r_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4buf_auto_out_r_bits_echo_real_last = srams_auto_in_r_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_clock = clock;
  assign axi4frag_reset = reset;
  assign axi4frag_auto_in_aw_valid = axi4xbar_auto_out_0_aw_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_id = axi4xbar_auto_out_0_aw_bits_id; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_addr = axi4xbar_auto_out_0_aw_bits_addr; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_len = axi4xbar_auto_out_0_aw_bits_len; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_size = axi4xbar_auto_out_0_aw_bits_size; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_aw_bits_burst = axi4xbar_auto_out_0_aw_bits_burst; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_w_valid = axi4xbar_auto_out_0_w_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_w_bits_data = axi4xbar_auto_out_0_w_bits_data; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_w_bits_strb = axi4xbar_auto_out_0_w_bits_strb; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_w_bits_last = axi4xbar_auto_out_0_w_bits_last; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_b_ready = axi4xbar_auto_out_0_b_ready; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_valid = axi4xbar_auto_out_0_ar_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_id = axi4xbar_auto_out_0_ar_bits_id; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_addr = axi4xbar_auto_out_0_ar_bits_addr; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_len = axi4xbar_auto_out_0_ar_bits_len; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_size = axi4xbar_auto_out_0_ar_bits_size; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_ar_bits_burst = axi4xbar_auto_out_0_ar_bits_burst; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_in_r_ready = axi4xbar_auto_out_0_r_ready; // @[LazyModule.scala 298:16]
  assign axi4frag_auto_out_aw_ready = axi4buf_auto_in_aw_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_w_ready = axi4buf_auto_in_w_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_b_valid = axi4buf_auto_in_b_valid; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_b_bits_id = axi4buf_auto_in_b_bits_id; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_b_bits_resp = axi4buf_auto_in_b_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_b_bits_echo_real_last = axi4buf_auto_in_b_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_ar_ready = axi4buf_auto_in_ar_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_valid = axi4buf_auto_in_r_valid; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_id = axi4buf_auto_in_r_bits_id; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_data = axi4buf_auto_in_r_bits_data; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_resp = axi4buf_auto_in_r_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_echo_real_last = axi4buf_auto_in_r_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_auto_out_r_bits_last = axi4buf_auto_in_r_bits_last; // @[LazyModule.scala 296:16]
  assign axi4buf_1_clock = clock;
  assign axi4buf_1_reset = reset;
  assign axi4buf_1_auto_in_aw_valid = axi4frag_1_auto_out_aw_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_aw_bits_id = axi4frag_1_auto_out_aw_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_aw_bits_addr = axi4frag_1_auto_out_aw_bits_addr; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_aw_bits_echo_real_last = axi4frag_1_auto_out_aw_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_w_valid = axi4frag_1_auto_out_w_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_w_bits_data = axi4frag_1_auto_out_w_bits_data; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_w_bits_strb = axi4frag_1_auto_out_w_bits_strb; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_b_ready = axi4frag_1_auto_out_b_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_ar_valid = axi4frag_1_auto_out_ar_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_ar_bits_id = axi4frag_1_auto_out_ar_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_ar_bits_addr = axi4frag_1_auto_out_ar_bits_addr; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_ar_bits_echo_real_last = axi4frag_1_auto_out_ar_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_in_r_ready = axi4frag_1_auto_out_r_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_aw_ready = srams_1_auto_in_aw_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_w_ready = srams_1_auto_in_w_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_b_valid = srams_1_auto_in_b_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_b_bits_id = srams_1_auto_in_b_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_b_bits_resp = srams_1_auto_in_b_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_b_bits_echo_real_last = srams_1_auto_in_b_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_ar_ready = srams_1_auto_in_ar_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_r_valid = srams_1_auto_in_r_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_r_bits_id = srams_1_auto_in_r_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_r_bits_data = srams_1_auto_in_r_bits_data; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_r_bits_resp = srams_1_auto_in_r_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4buf_1_auto_out_r_bits_echo_real_last = srams_1_auto_in_r_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_1_clock = clock;
  assign axi4frag_1_reset = reset;
  assign axi4frag_1_auto_in_aw_valid = axi4xbar_auto_out_1_aw_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_aw_bits_id = axi4xbar_auto_out_1_aw_bits_id; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_aw_bits_addr = axi4xbar_auto_out_1_aw_bits_addr; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_aw_bits_len = axi4xbar_auto_out_1_aw_bits_len; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_aw_bits_size = axi4xbar_auto_out_1_aw_bits_size; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_aw_bits_burst = axi4xbar_auto_out_1_aw_bits_burst; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_w_valid = axi4xbar_auto_out_1_w_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_w_bits_data = axi4xbar_auto_out_1_w_bits_data; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_w_bits_strb = axi4xbar_auto_out_1_w_bits_strb; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_w_bits_last = axi4xbar_auto_out_1_w_bits_last; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_b_ready = axi4xbar_auto_out_1_b_ready; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_ar_valid = axi4xbar_auto_out_1_ar_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_ar_bits_id = axi4xbar_auto_out_1_ar_bits_id; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_ar_bits_addr = axi4xbar_auto_out_1_ar_bits_addr; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_ar_bits_len = axi4xbar_auto_out_1_ar_bits_len; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_ar_bits_size = axi4xbar_auto_out_1_ar_bits_size; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_ar_bits_burst = axi4xbar_auto_out_1_ar_bits_burst; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_in_r_ready = axi4xbar_auto_out_1_r_ready; // @[LazyModule.scala 298:16]
  assign axi4frag_1_auto_out_aw_ready = axi4buf_1_auto_in_aw_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_w_ready = axi4buf_1_auto_in_w_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_b_valid = axi4buf_1_auto_in_b_valid; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_b_bits_id = axi4buf_1_auto_in_b_bits_id; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_b_bits_resp = axi4buf_1_auto_in_b_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_b_bits_echo_real_last = axi4buf_1_auto_in_b_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_ar_ready = axi4buf_1_auto_in_ar_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_r_valid = axi4buf_1_auto_in_r_valid; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_r_bits_id = axi4buf_1_auto_in_r_bits_id; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_r_bits_data = axi4buf_1_auto_in_r_bits_data; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_r_bits_resp = axi4buf_1_auto_in_r_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_r_bits_echo_real_last = axi4buf_1_auto_in_r_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_1_auto_out_r_bits_last = axi4buf_1_auto_in_r_bits_last; // @[LazyModule.scala 296:16]
  assign axi4buf_2_clock = clock;
  assign axi4buf_2_reset = reset;
  assign axi4buf_2_auto_in_aw_valid = axi4frag_2_auto_out_aw_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_aw_bits_id = axi4frag_2_auto_out_aw_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_aw_bits_addr = axi4frag_2_auto_out_aw_bits_addr; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_aw_bits_echo_real_last = axi4frag_2_auto_out_aw_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_w_valid = axi4frag_2_auto_out_w_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_w_bits_data = axi4frag_2_auto_out_w_bits_data; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_w_bits_strb = axi4frag_2_auto_out_w_bits_strb; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_b_ready = axi4frag_2_auto_out_b_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_ar_valid = axi4frag_2_auto_out_ar_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_ar_bits_id = axi4frag_2_auto_out_ar_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_ar_bits_addr = axi4frag_2_auto_out_ar_bits_addr; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_ar_bits_echo_real_last = axi4frag_2_auto_out_ar_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_in_r_ready = axi4frag_2_auto_out_r_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_aw_ready = srams_2_auto_in_aw_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_w_ready = srams_2_auto_in_w_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_b_valid = srams_2_auto_in_b_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_b_bits_id = srams_2_auto_in_b_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_b_bits_resp = srams_2_auto_in_b_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_b_bits_echo_real_last = srams_2_auto_in_b_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_ar_ready = srams_2_auto_in_ar_ready; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_r_valid = srams_2_auto_in_r_valid; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_r_bits_id = srams_2_auto_in_r_bits_id; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_r_bits_data = srams_2_auto_in_r_bits_data; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_r_bits_resp = srams_2_auto_in_r_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4buf_2_auto_out_r_bits_echo_real_last = srams_2_auto_in_r_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_2_clock = clock;
  assign axi4frag_2_reset = reset;
  assign axi4frag_2_auto_in_aw_valid = axi4xbar_auto_out_2_aw_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_aw_bits_id = axi4xbar_auto_out_2_aw_bits_id; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_aw_bits_addr = axi4xbar_auto_out_2_aw_bits_addr; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_aw_bits_len = axi4xbar_auto_out_2_aw_bits_len; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_aw_bits_size = axi4xbar_auto_out_2_aw_bits_size; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_aw_bits_burst = axi4xbar_auto_out_2_aw_bits_burst; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_w_valid = axi4xbar_auto_out_2_w_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_w_bits_data = axi4xbar_auto_out_2_w_bits_data; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_w_bits_strb = axi4xbar_auto_out_2_w_bits_strb; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_w_bits_last = axi4xbar_auto_out_2_w_bits_last; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_b_ready = axi4xbar_auto_out_2_b_ready; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_ar_valid = axi4xbar_auto_out_2_ar_valid; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_ar_bits_id = axi4xbar_auto_out_2_ar_bits_id; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_ar_bits_addr = axi4xbar_auto_out_2_ar_bits_addr; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_ar_bits_len = axi4xbar_auto_out_2_ar_bits_len; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_ar_bits_size = axi4xbar_auto_out_2_ar_bits_size; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_ar_bits_burst = axi4xbar_auto_out_2_ar_bits_burst; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_in_r_ready = axi4xbar_auto_out_2_r_ready; // @[LazyModule.scala 298:16]
  assign axi4frag_2_auto_out_aw_ready = axi4buf_2_auto_in_aw_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_w_ready = axi4buf_2_auto_in_w_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_b_valid = axi4buf_2_auto_in_b_valid; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_b_bits_id = axi4buf_2_auto_in_b_bits_id; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_b_bits_resp = axi4buf_2_auto_in_b_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_b_bits_echo_real_last = axi4buf_2_auto_in_b_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_ar_ready = axi4buf_2_auto_in_ar_ready; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_r_valid = axi4buf_2_auto_in_r_valid; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_r_bits_id = axi4buf_2_auto_in_r_bits_id; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_r_bits_data = axi4buf_2_auto_in_r_bits_data; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_r_bits_resp = axi4buf_2_auto_in_r_bits_resp; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_r_bits_echo_real_last = axi4buf_2_auto_in_r_bits_echo_real_last; // @[LazyModule.scala 296:16]
  assign axi4frag_2_auto_out_r_bits_last = axi4buf_2_auto_in_r_bits_last; // @[LazyModule.scala 296:16]
endmodule
module Queue_93_inTestHarness(
  input        clock,
  input        reset,
  output       io_enq_ready,
  input        io_enq_valid,
  input  [7:0] io_enq_bits,
  input        io_deq_ready,
  output       io_deq_valid,
  output [7:0] io_deq_bits
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] ram [0:127]; // @[Decoupled.scala 218:16]
  wire [7:0] ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 218:16]
  wire [6:0] ram_io_deq_bits_MPORT_addr; // @[Decoupled.scala 218:16]
  wire [7:0] ram_MPORT_data; // @[Decoupled.scala 218:16]
  wire [6:0] ram_MPORT_addr; // @[Decoupled.scala 218:16]
  wire  ram_MPORT_mask; // @[Decoupled.scala 218:16]
  wire  ram_MPORT_en; // @[Decoupled.scala 218:16]
  reg [6:0] enq_ptr_value; // @[Counter.scala 60:40]
  reg [6:0] deq_ptr_value; // @[Counter.scala 60:40]
  reg  maybe_full; // @[Decoupled.scala 221:27]
  wire  ptr_match = enq_ptr_value == deq_ptr_value; // @[Decoupled.scala 223:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 224:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 225:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  wire [6:0] _value_T_1 = enq_ptr_value + 7'h1; // @[Counter.scala 76:24]
  wire [6:0] _value_T_3 = deq_ptr_value + 7'h1; // @[Counter.scala 76:24]
  assign ram_io_deq_bits_MPORT_addr = deq_ptr_value;
  assign ram_io_deq_bits_MPORT_data = ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 218:16]
  assign ram_MPORT_data = io_enq_bits;
  assign ram_MPORT_addr = enq_ptr_value;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 241:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 240:19]
  assign io_deq_bits = ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 242:15]
  always @(posedge clock) begin
    if(ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[Decoupled.scala 218:16]
    end
    if (reset) begin // @[Counter.scala 60:40]
      enq_ptr_value <= 7'h0; // @[Counter.scala 60:40]
    end else if (do_enq) begin // @[Decoupled.scala 229:17]
      enq_ptr_value <= _value_T_1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      deq_ptr_value <= 7'h0; // @[Counter.scala 60:40]
    end else if (do_deq) begin // @[Decoupled.scala 233:17]
      deq_ptr_value <= _value_T_3; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Decoupled.scala 221:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 221:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 236:28]
      maybe_full <= do_enq; // @[Decoupled.scala 237:16]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 128; initvar = initvar+1)
    ram[initvar] = _RAND_0[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  enq_ptr_value = _RAND_1[6:0];
  _RAND_2 = {1{`RANDOM}};
  deq_ptr_value = _RAND_2[6:0];
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module UARTAdapter_inTestHarness(
  input   clock,
  input   reset,
  input   io_uart_txd,
  output  io_uart_rxd
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
`endif // RANDOMIZE_REG_INIT
  wire  txfifo_clock; // @[UARTAdapter.scala 32:22]
  wire  txfifo_reset; // @[UARTAdapter.scala 32:22]
  wire  txfifo_io_enq_ready; // @[UARTAdapter.scala 32:22]
  wire  txfifo_io_enq_valid; // @[UARTAdapter.scala 32:22]
  wire [7:0] txfifo_io_enq_bits; // @[UARTAdapter.scala 32:22]
  wire  txfifo_io_deq_ready; // @[UARTAdapter.scala 32:22]
  wire  txfifo_io_deq_valid; // @[UARTAdapter.scala 32:22]
  wire [7:0] txfifo_io_deq_bits; // @[UARTAdapter.scala 32:22]
  wire  rxfifo_clock; // @[UARTAdapter.scala 33:22]
  wire  rxfifo_reset; // @[UARTAdapter.scala 33:22]
  wire  rxfifo_io_enq_ready; // @[UARTAdapter.scala 33:22]
  wire  rxfifo_io_enq_valid; // @[UARTAdapter.scala 33:22]
  wire [7:0] rxfifo_io_enq_bits; // @[UARTAdapter.scala 33:22]
  wire  rxfifo_io_deq_ready; // @[UARTAdapter.scala 33:22]
  wire  rxfifo_io_deq_valid; // @[UARTAdapter.scala 33:22]
  wire [7:0] rxfifo_io_deq_bits; // @[UARTAdapter.scala 33:22]
  wire  sim_clock; // @[UARTAdapter.scala 108:19]
  wire  sim_reset; // @[UARTAdapter.scala 108:19]
  wire  sim_serial_in_ready; // @[UARTAdapter.scala 108:19]
  wire  sim_serial_in_valid; // @[UARTAdapter.scala 108:19]
  wire [7:0] sim_serial_in_bits; // @[UARTAdapter.scala 108:19]
  wire  sim_serial_out_ready; // @[UARTAdapter.scala 108:19]
  wire  sim_serial_out_valid; // @[UARTAdapter.scala 108:19]
  wire [7:0] sim_serial_out_bits; // @[UARTAdapter.scala 108:19]
  reg [1:0] txState; // @[UARTAdapter.scala 38:24]
  reg [7:0] txData; // @[UARTAdapter.scala 39:19]
  wire  _T_1 = txState == 2'h2 & txfifo_io_enq_ready; // @[UARTAdapter.scala 41:61]
  reg [2:0] txDataIdx; // @[Counter.scala 60:40]
  wire  wrap_wrap = txDataIdx == 3'h7; // @[Counter.scala 72:24]
  wire [2:0] _wrap_value_T_1 = txDataIdx + 3'h1; // @[Counter.scala 76:24]
  wire  txDataWrap = _T_1 & wrap_wrap; // @[Counter.scala 118:17 Counter.scala 118:24]
  wire  _T_3 = txState == 2'h1 & txfifo_io_enq_ready; // @[UARTAdapter.scala 43:63]
  reg [9:0] txBaudCount; // @[Counter.scala 60:40]
  wire  wrap_wrap_1 = txBaudCount == 10'h363; // @[Counter.scala 72:24]
  wire [9:0] _wrap_value_T_3 = txBaudCount + 10'h1; // @[Counter.scala 76:24]
  wire  txBaudWrap = _T_3 & wrap_wrap_1; // @[Counter.scala 118:17 Counter.scala 118:24]
  wire  _T_7 = txState == 2'h0 & ~io_uart_txd & txfifo_io_enq_ready; // @[UARTAdapter.scala 44:88]
  reg [1:0] txSlackCount; // @[Counter.scala 60:40]
  wire  wrap_wrap_2 = txSlackCount == 2'h3; // @[Counter.scala 72:24]
  wire [1:0] _wrap_value_T_5 = txSlackCount + 2'h1; // @[Counter.scala 76:24]
  wire  txSlackWrap = _T_7 & wrap_wrap_2; // @[Counter.scala 118:17 Counter.scala 118:24]
  wire  _T_8 = 2'h0 == txState; // @[Conditional.scala 37:30]
  wire  _T_9 = 2'h1 == txState; // @[Conditional.scala 37:30]
  wire  _T_10 = 2'h2 == txState; // @[Conditional.scala 37:30]
  wire [7:0] _GEN_35 = {{7'd0}, io_uart_txd}; // @[UARTAdapter.scala 60:41]
  wire [7:0] _txData_T = _GEN_35 << txDataIdx; // @[UARTAdapter.scala 60:41]
  wire [7:0] _txData_T_1 = txData | _txData_T; // @[UARTAdapter.scala 60:26]
  wire [1:0] _txState_T_1 = io_uart_txd ? 2'h0 : 2'h3; // @[UARTAdapter.scala 63:23]
  wire [1:0] _GEN_11 = txfifo_io_enq_ready ? 2'h1 : txState; // @[UARTAdapter.scala 64:39 UARTAdapter.scala 65:17 UARTAdapter.scala 38:24]
  wire [1:0] _GEN_12 = txDataWrap ? _txState_T_1 : _GEN_11; // @[UARTAdapter.scala 62:24 UARTAdapter.scala 63:17]
  wire  _T_11 = 2'h3 == txState; // @[Conditional.scala 37:30]
  wire [1:0] _GEN_13 = io_uart_txd & txfifo_io_enq_ready ? 2'h0 : txState; // @[UARTAdapter.scala 69:56 UARTAdapter.scala 70:17 UARTAdapter.scala 38:24]
  wire [1:0] _GEN_14 = _T_11 ? _GEN_13 : txState; // @[Conditional.scala 39:67 UARTAdapter.scala 38:24]
  reg [1:0] rxState; // @[UARTAdapter.scala 79:24]
  reg [9:0] rxBaudCount; // @[Counter.scala 60:40]
  wire  wrap_wrap_3 = rxBaudCount == 10'h363; // @[Counter.scala 72:24]
  wire [9:0] _wrap_value_T_7 = rxBaudCount + 10'h1; // @[Counter.scala 76:24]
  wire  rxBaudWrap = txfifo_io_enq_ready & wrap_wrap_3; // @[Counter.scala 118:17 Counter.scala 118:24]
  wire  _T_14 = rxState == 2'h2; // @[UARTAdapter.scala 83:49]
  wire  _T_16 = rxState == 2'h2 & txfifo_io_enq_ready & rxBaudWrap; // @[UARTAdapter.scala 83:84]
  reg [2:0] rxDataIdx; // @[Counter.scala 60:40]
  wire  wrap_wrap_4 = rxDataIdx == 3'h7; // @[Counter.scala 72:24]
  wire [2:0] _wrap_value_T_9 = rxDataIdx + 3'h1; // @[Counter.scala 76:24]
  wire  rxDataWrap = _T_16 & wrap_wrap_4; // @[Counter.scala 118:17 Counter.scala 118:24]
  wire  _T_17 = 2'h0 == rxState; // @[Conditional.scala 37:30]
  wire  _T_19 = 2'h1 == rxState; // @[Conditional.scala 37:30]
  wire  _T_20 = 2'h2 == rxState; // @[Conditional.scala 37:30]
  wire [7:0] _io_uart_rxd_T = rxfifo_io_deq_bits >> rxDataIdx; // @[UARTAdapter.scala 100:42]
  wire [1:0] _GEN_28 = rxDataWrap & rxBaudWrap ? 2'h0 : rxState; // @[UARTAdapter.scala 101:38 UARTAdapter.scala 102:17 UARTAdapter.scala 79:24]
  wire  _GEN_29 = _T_20 ? _io_uart_rxd_T[0] : 1'h1; // @[Conditional.scala 39:67 UARTAdapter.scala 100:19 UARTAdapter.scala 85:15]
  wire  _GEN_31 = _T_19 ? 1'h0 : _GEN_29; // @[Conditional.scala 39:67 UARTAdapter.scala 94:19]
  Queue_93_inTestHarness txfifo ( // @[UARTAdapter.scala 32:22]
    .clock(txfifo_clock),
    .reset(txfifo_reset),
    .io_enq_ready(txfifo_io_enq_ready),
    .io_enq_valid(txfifo_io_enq_valid),
    .io_enq_bits(txfifo_io_enq_bits),
    .io_deq_ready(txfifo_io_deq_ready),
    .io_deq_valid(txfifo_io_deq_valid),
    .io_deq_bits(txfifo_io_deq_bits)
  );
  Queue_93_inTestHarness rxfifo ( // @[UARTAdapter.scala 33:22]
    .clock(rxfifo_clock),
    .reset(rxfifo_reset),
    .io_enq_ready(rxfifo_io_enq_ready),
    .io_enq_valid(rxfifo_io_enq_valid),
    .io_enq_bits(rxfifo_io_enq_bits),
    .io_deq_ready(rxfifo_io_deq_ready),
    .io_deq_valid(rxfifo_io_deq_valid),
    .io_deq_bits(rxfifo_io_deq_bits)
  );
  SimUART #(.UARTNO(0)) sim ( // @[UARTAdapter.scala 108:19]
    .clock(sim_clock),
    .reset(sim_reset),
    .serial_in_ready(sim_serial_in_ready),
    .serial_in_valid(sim_serial_in_valid),
    .serial_in_bits(sim_serial_in_bits),
    .serial_out_ready(sim_serial_out_ready),
    .serial_out_valid(sim_serial_out_valid),
    .serial_out_bits(sim_serial_out_bits)
  );
  assign io_uart_rxd = _T_17 | _GEN_31; // @[Conditional.scala 40:58 UARTAdapter.scala 88:19]
  assign txfifo_clock = clock;
  assign txfifo_reset = reset;
  assign txfifo_io_enq_valid = _T_1 & wrap_wrap; // @[Counter.scala 118:17 Counter.scala 118:24]
  assign txfifo_io_enq_bits = txData; // @[UARTAdapter.scala 75:23]
  assign txfifo_io_deq_ready = sim_serial_out_ready; // @[UARTAdapter.scala 115:23]
  assign rxfifo_clock = clock;
  assign rxfifo_reset = reset;
  assign rxfifo_io_enq_valid = sim_serial_in_valid; // @[UARTAdapter.scala 118:23]
  assign rxfifo_io_enq_bits = sim_serial_in_bits; // @[UARTAdapter.scala 117:22]
  assign rxfifo_io_deq_ready = _T_14 & rxDataWrap & rxBaudWrap & txfifo_io_enq_ready; // @[UARTAdapter.scala 106:76]
  assign sim_clock = clock; // @[UARTAdapter.scala 110:16]
  assign sim_reset = reset; // @[UARTAdapter.scala 111:25]
  assign sim_serial_in_ready = rxfifo_io_enq_ready; // @[UARTAdapter.scala 119:26]
  assign sim_serial_out_valid = txfifo_io_deq_valid; // @[UARTAdapter.scala 114:27]
  assign sim_serial_out_bits = txfifo_io_deq_bits; // @[UARTAdapter.scala 113:26]
  always @(posedge clock) begin
    if (reset) begin // @[UARTAdapter.scala 38:24]
      txState <= 2'h0; // @[UARTAdapter.scala 38:24]
    end else if (_T_8) begin // @[Conditional.scala 40:58]
      if (txSlackWrap) begin // @[UARTAdapter.scala 48:25]
        txState <= 2'h1; // @[UARTAdapter.scala 50:17]
      end
    end else if (_T_9) begin // @[Conditional.scala 39:67]
      if (txBaudWrap) begin // @[UARTAdapter.scala 54:24]
        txState <= 2'h2; // @[UARTAdapter.scala 55:17]
      end
    end else if (_T_10) begin // @[Conditional.scala 39:67]
      txState <= _GEN_12;
    end else begin
      txState <= _GEN_14;
    end
    if (_T_8) begin // @[Conditional.scala 40:58]
      if (txSlackWrap) begin // @[UARTAdapter.scala 48:25]
        txData <= 8'h0; // @[UARTAdapter.scala 49:17]
      end
    end else if (!(_T_9)) begin // @[Conditional.scala 39:67]
      if (_T_10) begin // @[Conditional.scala 39:67]
        if (txfifo_io_enq_ready) begin // @[UARTAdapter.scala 59:34]
          txData <= _txData_T_1; // @[UARTAdapter.scala 60:16]
        end
      end
    end
    if (reset) begin // @[Counter.scala 60:40]
      txDataIdx <= 3'h0; // @[Counter.scala 60:40]
    end else if (_T_1) begin // @[Counter.scala 118:17]
      txDataIdx <= _wrap_value_T_1; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[Counter.scala 60:40]
      txBaudCount <= 10'h0; // @[Counter.scala 60:40]
    end else if (_T_3) begin // @[Counter.scala 118:17]
      if (wrap_wrap_1) begin // @[Counter.scala 86:20]
        txBaudCount <= 10'h0; // @[Counter.scala 86:28]
      end else begin
        txBaudCount <= _wrap_value_T_3; // @[Counter.scala 76:15]
      end
    end
    if (reset) begin // @[Counter.scala 60:40]
      txSlackCount <= 2'h0; // @[Counter.scala 60:40]
    end else if (_T_7) begin // @[Counter.scala 118:17]
      txSlackCount <= _wrap_value_T_5; // @[Counter.scala 76:15]
    end
    if (reset) begin // @[UARTAdapter.scala 79:24]
      rxState <= 2'h0; // @[UARTAdapter.scala 79:24]
    end else if (_T_17) begin // @[Conditional.scala 40:58]
      if (rxBaudWrap & rxfifo_io_deq_valid) begin // @[UARTAdapter.scala 89:48]
        rxState <= 2'h1; // @[UARTAdapter.scala 90:17]
      end
    end else if (_T_19) begin // @[Conditional.scala 39:67]
      if (rxBaudWrap) begin // @[UARTAdapter.scala 95:24]
        rxState <= 2'h2; // @[UARTAdapter.scala 96:17]
      end
    end else if (_T_20) begin // @[Conditional.scala 39:67]
      rxState <= _GEN_28;
    end
    if (reset) begin // @[Counter.scala 60:40]
      rxBaudCount <= 10'h0; // @[Counter.scala 60:40]
    end else if (txfifo_io_enq_ready) begin // @[Counter.scala 118:17]
      if (wrap_wrap_3) begin // @[Counter.scala 86:20]
        rxBaudCount <= 10'h0; // @[Counter.scala 86:28]
      end else begin
        rxBaudCount <= _wrap_value_T_7; // @[Counter.scala 76:15]
      end
    end
    if (reset) begin // @[Counter.scala 60:40]
      rxDataIdx <= 3'h0; // @[Counter.scala 60:40]
    end else if (_T_16) begin // @[Counter.scala 118:17]
      rxDataIdx <= _wrap_value_T_9; // @[Counter.scala 76:15]
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
  txState = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  txData = _RAND_1[7:0];
  _RAND_2 = {1{`RANDOM}};
  txDataIdx = _RAND_2[2:0];
  _RAND_3 = {1{`RANDOM}};
  txBaudCount = _RAND_3[9:0];
  _RAND_4 = {1{`RANDOM}};
  txSlackCount = _RAND_4[1:0];
  _RAND_5 = {1{`RANDOM}};
  rxState = _RAND_5[1:0];
  _RAND_6 = {1{`RANDOM}};
  rxBaudCount = _RAND_6[9:0];
  _RAND_7 = {1{`RANDOM}};
  rxDataIdx = _RAND_7[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TestHarness(
  input   clock,
  input   reset,
  output  io_success
);
  wire  chiptop_jtag_TCK; // @[TestHarness.scala 89:19]
  wire  chiptop_jtag_TMS; // @[TestHarness.scala 89:19]
  wire  chiptop_jtag_TDI; // @[TestHarness.scala 89:19]
  wire  chiptop_jtag_TDO; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_clock; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_reset; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_aw_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_aw_valid; // @[TestHarness.scala 89:19]
  wire [3:0] chiptop_axi4_mmio_0_bits_aw_bits_id; // @[TestHarness.scala 89:19]
  wire [31:0] chiptop_axi4_mmio_0_bits_aw_bits_addr; // @[TestHarness.scala 89:19]
  wire [7:0] chiptop_axi4_mmio_0_bits_aw_bits_len; // @[TestHarness.scala 89:19]
  wire [2:0] chiptop_axi4_mmio_0_bits_aw_bits_size; // @[TestHarness.scala 89:19]
  wire [1:0] chiptop_axi4_mmio_0_bits_aw_bits_burst; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_w_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_w_valid; // @[TestHarness.scala 89:19]
  wire [63:0] chiptop_axi4_mmio_0_bits_w_bits_data; // @[TestHarness.scala 89:19]
  wire [7:0] chiptop_axi4_mmio_0_bits_w_bits_strb; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_w_bits_last; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_b_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_b_valid; // @[TestHarness.scala 89:19]
  wire [3:0] chiptop_axi4_mmio_0_bits_b_bits_id; // @[TestHarness.scala 89:19]
  wire [1:0] chiptop_axi4_mmio_0_bits_b_bits_resp; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_ar_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_ar_valid; // @[TestHarness.scala 89:19]
  wire [3:0] chiptop_axi4_mmio_0_bits_ar_bits_id; // @[TestHarness.scala 89:19]
  wire [31:0] chiptop_axi4_mmio_0_bits_ar_bits_addr; // @[TestHarness.scala 89:19]
  wire [7:0] chiptop_axi4_mmio_0_bits_ar_bits_len; // @[TestHarness.scala 89:19]
  wire [2:0] chiptop_axi4_mmio_0_bits_ar_bits_size; // @[TestHarness.scala 89:19]
  wire [1:0] chiptop_axi4_mmio_0_bits_ar_bits_burst; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_r_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_r_valid; // @[TestHarness.scala 89:19]
  wire [3:0] chiptop_axi4_mmio_0_bits_r_bits_id; // @[TestHarness.scala 89:19]
  wire [63:0] chiptop_axi4_mmio_0_bits_r_bits_data; // @[TestHarness.scala 89:19]
  wire [1:0] chiptop_axi4_mmio_0_bits_r_bits_resp; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mmio_0_bits_r_bits_last; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_clock; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_reset; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_aw_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_aw_valid; // @[TestHarness.scala 89:19]
  wire [3:0] chiptop_axi4_mem_0_bits_aw_bits_id; // @[TestHarness.scala 89:19]
  wire [31:0] chiptop_axi4_mem_0_bits_aw_bits_addr; // @[TestHarness.scala 89:19]
  wire [7:0] chiptop_axi4_mem_0_bits_aw_bits_len; // @[TestHarness.scala 89:19]
  wire [2:0] chiptop_axi4_mem_0_bits_aw_bits_size; // @[TestHarness.scala 89:19]
  wire [1:0] chiptop_axi4_mem_0_bits_aw_bits_burst; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_w_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_w_valid; // @[TestHarness.scala 89:19]
  wire [127:0] chiptop_axi4_mem_0_bits_w_bits_data; // @[TestHarness.scala 89:19]
  wire [15:0] chiptop_axi4_mem_0_bits_w_bits_strb; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_w_bits_last; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_b_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_b_valid; // @[TestHarness.scala 89:19]
  wire [3:0] chiptop_axi4_mem_0_bits_b_bits_id; // @[TestHarness.scala 89:19]
  wire [1:0] chiptop_axi4_mem_0_bits_b_bits_resp; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_ar_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_ar_valid; // @[TestHarness.scala 89:19]
  wire [3:0] chiptop_axi4_mem_0_bits_ar_bits_id; // @[TestHarness.scala 89:19]
  wire [31:0] chiptop_axi4_mem_0_bits_ar_bits_addr; // @[TestHarness.scala 89:19]
  wire [7:0] chiptop_axi4_mem_0_bits_ar_bits_len; // @[TestHarness.scala 89:19]
  wire [2:0] chiptop_axi4_mem_0_bits_ar_bits_size; // @[TestHarness.scala 89:19]
  wire [1:0] chiptop_axi4_mem_0_bits_ar_bits_burst; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_r_ready; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_r_valid; // @[TestHarness.scala 89:19]
  wire [3:0] chiptop_axi4_mem_0_bits_r_bits_id; // @[TestHarness.scala 89:19]
  wire [127:0] chiptop_axi4_mem_0_bits_r_bits_data; // @[TestHarness.scala 89:19]
  wire [1:0] chiptop_axi4_mem_0_bits_r_bits_resp; // @[TestHarness.scala 89:19]
  wire  chiptop_axi4_mem_0_bits_r_bits_last; // @[TestHarness.scala 89:19]
  wire  chiptop_uart_0_txd; // @[TestHarness.scala 89:19]
  wire  chiptop_uart_0_rxd; // @[TestHarness.scala 89:19]
  wire  chiptop_reset_wire_reset; // @[TestHarness.scala 89:19]
  wire  chiptop_clock; // @[TestHarness.scala 89:19]
  wire  SimJTAG_clock; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_reset; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_jtag_TRSTn; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_jtag_TCK; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_jtag_TMS; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_jtag_TDI; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_jtag_TDO_data; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_jtag_TDO_driven; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_enable; // @[HarnessBinders.scala 257:26]
  wire  SimJTAG_init_done; // @[HarnessBinders.scala 257:26]
  wire [31:0] SimJTAG_exit; // @[HarnessBinders.scala 257:26]
  wire [31:0] plusarg_reader_out; // @[PlusArg.scala 80:11]
  wire  mmio_mem_clock; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_reset; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_aw_ready; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_aw_valid; // @[HarnessBinders.scala 221:15]
  wire [3:0] mmio_mem_io_axi4_0_aw_bits_id; // @[HarnessBinders.scala 221:15]
  wire [27:0] mmio_mem_io_axi4_0_aw_bits_addr; // @[HarnessBinders.scala 221:15]
  wire [7:0] mmio_mem_io_axi4_0_aw_bits_len; // @[HarnessBinders.scala 221:15]
  wire [2:0] mmio_mem_io_axi4_0_aw_bits_size; // @[HarnessBinders.scala 221:15]
  wire [1:0] mmio_mem_io_axi4_0_aw_bits_burst; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_w_ready; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_w_valid; // @[HarnessBinders.scala 221:15]
  wire [63:0] mmio_mem_io_axi4_0_w_bits_data; // @[HarnessBinders.scala 221:15]
  wire [7:0] mmio_mem_io_axi4_0_w_bits_strb; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_w_bits_last; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_b_ready; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_b_valid; // @[HarnessBinders.scala 221:15]
  wire [3:0] mmio_mem_io_axi4_0_b_bits_id; // @[HarnessBinders.scala 221:15]
  wire [1:0] mmio_mem_io_axi4_0_b_bits_resp; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_ar_ready; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_ar_valid; // @[HarnessBinders.scala 221:15]
  wire [3:0] mmio_mem_io_axi4_0_ar_bits_id; // @[HarnessBinders.scala 221:15]
  wire [27:0] mmio_mem_io_axi4_0_ar_bits_addr; // @[HarnessBinders.scala 221:15]
  wire [7:0] mmio_mem_io_axi4_0_ar_bits_len; // @[HarnessBinders.scala 221:15]
  wire [2:0] mmio_mem_io_axi4_0_ar_bits_size; // @[HarnessBinders.scala 221:15]
  wire [1:0] mmio_mem_io_axi4_0_ar_bits_burst; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_r_ready; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_r_valid; // @[HarnessBinders.scala 221:15]
  wire [3:0] mmio_mem_io_axi4_0_r_bits_id; // @[HarnessBinders.scala 221:15]
  wire [63:0] mmio_mem_io_axi4_0_r_bits_data; // @[HarnessBinders.scala 221:15]
  wire [1:0] mmio_mem_io_axi4_0_r_bits_resp; // @[HarnessBinders.scala 221:15]
  wire  mmio_mem_io_axi4_0_r_bits_last; // @[HarnessBinders.scala 221:15]
  wire  mem_clock; // @[HarnessBinders.scala 135:15]
  wire  mem_reset; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_aw_ready; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_aw_valid; // @[HarnessBinders.scala 135:15]
  wire [3:0] mem_io_axi4_0_aw_bits_id; // @[HarnessBinders.scala 135:15]
  wire [31:0] mem_io_axi4_0_aw_bits_addr; // @[HarnessBinders.scala 135:15]
  wire [7:0] mem_io_axi4_0_aw_bits_len; // @[HarnessBinders.scala 135:15]
  wire [2:0] mem_io_axi4_0_aw_bits_size; // @[HarnessBinders.scala 135:15]
  wire [1:0] mem_io_axi4_0_aw_bits_burst; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_w_ready; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_w_valid; // @[HarnessBinders.scala 135:15]
  wire [127:0] mem_io_axi4_0_w_bits_data; // @[HarnessBinders.scala 135:15]
  wire [15:0] mem_io_axi4_0_w_bits_strb; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_w_bits_last; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_b_ready; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_b_valid; // @[HarnessBinders.scala 135:15]
  wire [3:0] mem_io_axi4_0_b_bits_id; // @[HarnessBinders.scala 135:15]
  wire [1:0] mem_io_axi4_0_b_bits_resp; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_ar_ready; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_ar_valid; // @[HarnessBinders.scala 135:15]
  wire [3:0] mem_io_axi4_0_ar_bits_id; // @[HarnessBinders.scala 135:15]
  wire [31:0] mem_io_axi4_0_ar_bits_addr; // @[HarnessBinders.scala 135:15]
  wire [7:0] mem_io_axi4_0_ar_bits_len; // @[HarnessBinders.scala 135:15]
  wire [2:0] mem_io_axi4_0_ar_bits_size; // @[HarnessBinders.scala 135:15]
  wire [1:0] mem_io_axi4_0_ar_bits_burst; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_r_ready; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_r_valid; // @[HarnessBinders.scala 135:15]
  wire [3:0] mem_io_axi4_0_r_bits_id; // @[HarnessBinders.scala 135:15]
  wire [127:0] mem_io_axi4_0_r_bits_data; // @[HarnessBinders.scala 135:15]
  wire [1:0] mem_io_axi4_0_r_bits_resp; // @[HarnessBinders.scala 135:15]
  wire  mem_io_axi4_0_r_bits_last; // @[HarnessBinders.scala 135:15]
  wire  uart_sim_0_clock; // @[UARTAdapter.scala 132:28]
  wire  uart_sim_0_reset; // @[UARTAdapter.scala 132:28]
  wire  uart_sim_0_io_uart_txd; // @[UARTAdapter.scala 132:28]
  wire  uart_sim_0_io_uart_rxd; // @[UARTAdapter.scala 132:28]
  wire  _T_2 = ~reset; // @[HarnessBinders.scala 257:115]
  wire  _T_3 = SimJTAG_exit >= 32'h2; // @[Periphery.scala 234:19]
  ChipTop_inTestHarness chiptop ( // @[TestHarness.scala 89:19]
    .jtag_TCK(chiptop_jtag_TCK),
    .jtag_TMS(chiptop_jtag_TMS),
    .jtag_TDI(chiptop_jtag_TDI),
    .jtag_TDO(chiptop_jtag_TDO),
    .axi4_mmio_0_clock(chiptop_axi4_mmio_0_clock),
    .axi4_mmio_0_reset(chiptop_axi4_mmio_0_reset),
    .axi4_mmio_0_bits_aw_ready(chiptop_axi4_mmio_0_bits_aw_ready),
    .axi4_mmio_0_bits_aw_valid(chiptop_axi4_mmio_0_bits_aw_valid),
    .axi4_mmio_0_bits_aw_bits_id(chiptop_axi4_mmio_0_bits_aw_bits_id),
    .axi4_mmio_0_bits_aw_bits_addr(chiptop_axi4_mmio_0_bits_aw_bits_addr),
    .axi4_mmio_0_bits_aw_bits_len(chiptop_axi4_mmio_0_bits_aw_bits_len),
    .axi4_mmio_0_bits_aw_bits_size(chiptop_axi4_mmio_0_bits_aw_bits_size),
    .axi4_mmio_0_bits_aw_bits_burst(chiptop_axi4_mmio_0_bits_aw_bits_burst),
    .axi4_mmio_0_bits_w_ready(chiptop_axi4_mmio_0_bits_w_ready),
    .axi4_mmio_0_bits_w_valid(chiptop_axi4_mmio_0_bits_w_valid),
    .axi4_mmio_0_bits_w_bits_data(chiptop_axi4_mmio_0_bits_w_bits_data),
    .axi4_mmio_0_bits_w_bits_strb(chiptop_axi4_mmio_0_bits_w_bits_strb),
    .axi4_mmio_0_bits_w_bits_last(chiptop_axi4_mmio_0_bits_w_bits_last),
    .axi4_mmio_0_bits_b_ready(chiptop_axi4_mmio_0_bits_b_ready),
    .axi4_mmio_0_bits_b_valid(chiptop_axi4_mmio_0_bits_b_valid),
    .axi4_mmio_0_bits_b_bits_id(chiptop_axi4_mmio_0_bits_b_bits_id),
    .axi4_mmio_0_bits_b_bits_resp(chiptop_axi4_mmio_0_bits_b_bits_resp),
    .axi4_mmio_0_bits_ar_ready(chiptop_axi4_mmio_0_bits_ar_ready),
    .axi4_mmio_0_bits_ar_valid(chiptop_axi4_mmio_0_bits_ar_valid),
    .axi4_mmio_0_bits_ar_bits_id(chiptop_axi4_mmio_0_bits_ar_bits_id),
    .axi4_mmio_0_bits_ar_bits_addr(chiptop_axi4_mmio_0_bits_ar_bits_addr),
    .axi4_mmio_0_bits_ar_bits_len(chiptop_axi4_mmio_0_bits_ar_bits_len),
    .axi4_mmio_0_bits_ar_bits_size(chiptop_axi4_mmio_0_bits_ar_bits_size),
    .axi4_mmio_0_bits_ar_bits_burst(chiptop_axi4_mmio_0_bits_ar_bits_burst),
    .axi4_mmio_0_bits_r_ready(chiptop_axi4_mmio_0_bits_r_ready),
    .axi4_mmio_0_bits_r_valid(chiptop_axi4_mmio_0_bits_r_valid),
    .axi4_mmio_0_bits_r_bits_id(chiptop_axi4_mmio_0_bits_r_bits_id),
    .axi4_mmio_0_bits_r_bits_data(chiptop_axi4_mmio_0_bits_r_bits_data),
    .axi4_mmio_0_bits_r_bits_resp(chiptop_axi4_mmio_0_bits_r_bits_resp),
    .axi4_mmio_0_bits_r_bits_last(chiptop_axi4_mmio_0_bits_r_bits_last),
    .axi4_mem_0_clock(chiptop_axi4_mem_0_clock),
    .axi4_mem_0_reset(chiptop_axi4_mem_0_reset),
    .axi4_mem_0_bits_aw_ready(chiptop_axi4_mem_0_bits_aw_ready),
    .axi4_mem_0_bits_aw_valid(chiptop_axi4_mem_0_bits_aw_valid),
    .axi4_mem_0_bits_aw_bits_id(chiptop_axi4_mem_0_bits_aw_bits_id),
    .axi4_mem_0_bits_aw_bits_addr(chiptop_axi4_mem_0_bits_aw_bits_addr),
    .axi4_mem_0_bits_aw_bits_len(chiptop_axi4_mem_0_bits_aw_bits_len),
    .axi4_mem_0_bits_aw_bits_size(chiptop_axi4_mem_0_bits_aw_bits_size),
    .axi4_mem_0_bits_aw_bits_burst(chiptop_axi4_mem_0_bits_aw_bits_burst),
    .axi4_mem_0_bits_w_ready(chiptop_axi4_mem_0_bits_w_ready),
    .axi4_mem_0_bits_w_valid(chiptop_axi4_mem_0_bits_w_valid),
    .axi4_mem_0_bits_w_bits_data(chiptop_axi4_mem_0_bits_w_bits_data),
    .axi4_mem_0_bits_w_bits_strb(chiptop_axi4_mem_0_bits_w_bits_strb),
    .axi4_mem_0_bits_w_bits_last(chiptop_axi4_mem_0_bits_w_bits_last),
    .axi4_mem_0_bits_b_ready(chiptop_axi4_mem_0_bits_b_ready),
    .axi4_mem_0_bits_b_valid(chiptop_axi4_mem_0_bits_b_valid),
    .axi4_mem_0_bits_b_bits_id(chiptop_axi4_mem_0_bits_b_bits_id),
    .axi4_mem_0_bits_b_bits_resp(chiptop_axi4_mem_0_bits_b_bits_resp),
    .axi4_mem_0_bits_ar_ready(chiptop_axi4_mem_0_bits_ar_ready),
    .axi4_mem_0_bits_ar_valid(chiptop_axi4_mem_0_bits_ar_valid),
    .axi4_mem_0_bits_ar_bits_id(chiptop_axi4_mem_0_bits_ar_bits_id),
    .axi4_mem_0_bits_ar_bits_addr(chiptop_axi4_mem_0_bits_ar_bits_addr),
    .axi4_mem_0_bits_ar_bits_len(chiptop_axi4_mem_0_bits_ar_bits_len),
    .axi4_mem_0_bits_ar_bits_size(chiptop_axi4_mem_0_bits_ar_bits_size),
    .axi4_mem_0_bits_ar_bits_burst(chiptop_axi4_mem_0_bits_ar_bits_burst),
    .axi4_mem_0_bits_r_ready(chiptop_axi4_mem_0_bits_r_ready),
    .axi4_mem_0_bits_r_valid(chiptop_axi4_mem_0_bits_r_valid),
    .axi4_mem_0_bits_r_bits_id(chiptop_axi4_mem_0_bits_r_bits_id),
    .axi4_mem_0_bits_r_bits_data(chiptop_axi4_mem_0_bits_r_bits_data),
    .axi4_mem_0_bits_r_bits_resp(chiptop_axi4_mem_0_bits_r_bits_resp),
    .axi4_mem_0_bits_r_bits_last(chiptop_axi4_mem_0_bits_r_bits_last),
    .uart_0_txd(chiptop_uart_0_txd),
    .uart_0_rxd(chiptop_uart_0_rxd),
    .reset_wire_reset(chiptop_reset_wire_reset),
    .clock(chiptop_clock)
  );
  SimJTAG #(.TICK_DELAY(3)) SimJTAG ( // @[HarnessBinders.scala 257:26]
    .clock(SimJTAG_clock),
    .reset(SimJTAG_reset),
    .jtag_TRSTn(SimJTAG_jtag_TRSTn),
    .jtag_TCK(SimJTAG_jtag_TCK),
    .jtag_TMS(SimJTAG_jtag_TMS),
    .jtag_TDI(SimJTAG_jtag_TDI),
    .jtag_TDO_data(SimJTAG_jtag_TDO_data),
    .jtag_TDO_driven(SimJTAG_jtag_TDO_driven),
    .enable(SimJTAG_enable),
    .init_done(SimJTAG_init_done),
    .exit(SimJTAG_exit)
  );
  plusarg_reader #(.FORMAT("jtag_rbb_enable=%d"), .DEFAULT(0), .WIDTH(32)) plusarg_reader ( // @[PlusArg.scala 80:11]
    .out(plusarg_reader_out)
  );
  SimAXIMem_inTestHarness mmio_mem ( // @[HarnessBinders.scala 221:15]
    .clock(mmio_mem_clock),
    .reset(mmio_mem_reset),
    .io_axi4_0_aw_ready(mmio_mem_io_axi4_0_aw_ready),
    .io_axi4_0_aw_valid(mmio_mem_io_axi4_0_aw_valid),
    .io_axi4_0_aw_bits_id(mmio_mem_io_axi4_0_aw_bits_id),
    .io_axi4_0_aw_bits_addr(mmio_mem_io_axi4_0_aw_bits_addr),
    .io_axi4_0_aw_bits_len(mmio_mem_io_axi4_0_aw_bits_len),
    .io_axi4_0_aw_bits_size(mmio_mem_io_axi4_0_aw_bits_size),
    .io_axi4_0_aw_bits_burst(mmio_mem_io_axi4_0_aw_bits_burst),
    .io_axi4_0_w_ready(mmio_mem_io_axi4_0_w_ready),
    .io_axi4_0_w_valid(mmio_mem_io_axi4_0_w_valid),
    .io_axi4_0_w_bits_data(mmio_mem_io_axi4_0_w_bits_data),
    .io_axi4_0_w_bits_strb(mmio_mem_io_axi4_0_w_bits_strb),
    .io_axi4_0_w_bits_last(mmio_mem_io_axi4_0_w_bits_last),
    .io_axi4_0_b_ready(mmio_mem_io_axi4_0_b_ready),
    .io_axi4_0_b_valid(mmio_mem_io_axi4_0_b_valid),
    .io_axi4_0_b_bits_id(mmio_mem_io_axi4_0_b_bits_id),
    .io_axi4_0_b_bits_resp(mmio_mem_io_axi4_0_b_bits_resp),
    .io_axi4_0_ar_ready(mmio_mem_io_axi4_0_ar_ready),
    .io_axi4_0_ar_valid(mmio_mem_io_axi4_0_ar_valid),
    .io_axi4_0_ar_bits_id(mmio_mem_io_axi4_0_ar_bits_id),
    .io_axi4_0_ar_bits_addr(mmio_mem_io_axi4_0_ar_bits_addr),
    .io_axi4_0_ar_bits_len(mmio_mem_io_axi4_0_ar_bits_len),
    .io_axi4_0_ar_bits_size(mmio_mem_io_axi4_0_ar_bits_size),
    .io_axi4_0_ar_bits_burst(mmio_mem_io_axi4_0_ar_bits_burst),
    .io_axi4_0_r_ready(mmio_mem_io_axi4_0_r_ready),
    .io_axi4_0_r_valid(mmio_mem_io_axi4_0_r_valid),
    .io_axi4_0_r_bits_id(mmio_mem_io_axi4_0_r_bits_id),
    .io_axi4_0_r_bits_data(mmio_mem_io_axi4_0_r_bits_data),
    .io_axi4_0_r_bits_resp(mmio_mem_io_axi4_0_r_bits_resp),
    .io_axi4_0_r_bits_last(mmio_mem_io_axi4_0_r_bits_last)
  );
  SimAXIMem_1_inTestHarness mem ( // @[HarnessBinders.scala 135:15]
    .clock(mem_clock),
    .reset(mem_reset),
    .io_axi4_0_aw_ready(mem_io_axi4_0_aw_ready),
    .io_axi4_0_aw_valid(mem_io_axi4_0_aw_valid),
    .io_axi4_0_aw_bits_id(mem_io_axi4_0_aw_bits_id),
    .io_axi4_0_aw_bits_addr(mem_io_axi4_0_aw_bits_addr),
    .io_axi4_0_aw_bits_len(mem_io_axi4_0_aw_bits_len),
    .io_axi4_0_aw_bits_size(mem_io_axi4_0_aw_bits_size),
    .io_axi4_0_aw_bits_burst(mem_io_axi4_0_aw_bits_burst),
    .io_axi4_0_w_ready(mem_io_axi4_0_w_ready),
    .io_axi4_0_w_valid(mem_io_axi4_0_w_valid),
    .io_axi4_0_w_bits_data(mem_io_axi4_0_w_bits_data),
    .io_axi4_0_w_bits_strb(mem_io_axi4_0_w_bits_strb),
    .io_axi4_0_w_bits_last(mem_io_axi4_0_w_bits_last),
    .io_axi4_0_b_ready(mem_io_axi4_0_b_ready),
    .io_axi4_0_b_valid(mem_io_axi4_0_b_valid),
    .io_axi4_0_b_bits_id(mem_io_axi4_0_b_bits_id),
    .io_axi4_0_b_bits_resp(mem_io_axi4_0_b_bits_resp),
    .io_axi4_0_ar_ready(mem_io_axi4_0_ar_ready),
    .io_axi4_0_ar_valid(mem_io_axi4_0_ar_valid),
    .io_axi4_0_ar_bits_id(mem_io_axi4_0_ar_bits_id),
    .io_axi4_0_ar_bits_addr(mem_io_axi4_0_ar_bits_addr),
    .io_axi4_0_ar_bits_len(mem_io_axi4_0_ar_bits_len),
    .io_axi4_0_ar_bits_size(mem_io_axi4_0_ar_bits_size),
    .io_axi4_0_ar_bits_burst(mem_io_axi4_0_ar_bits_burst),
    .io_axi4_0_r_ready(mem_io_axi4_0_r_ready),
    .io_axi4_0_r_valid(mem_io_axi4_0_r_valid),
    .io_axi4_0_r_bits_id(mem_io_axi4_0_r_bits_id),
    .io_axi4_0_r_bits_data(mem_io_axi4_0_r_bits_data),
    .io_axi4_0_r_bits_resp(mem_io_axi4_0_r_bits_resp),
    .io_axi4_0_r_bits_last(mem_io_axi4_0_r_bits_last)
  );
  UARTAdapter_inTestHarness uart_sim_0 ( // @[UARTAdapter.scala 132:28]
    .clock(uart_sim_0_clock),
    .reset(uart_sim_0_reset),
    .io_uart_txd(uart_sim_0_io_uart_txd),
    .io_uart_rxd(uart_sim_0_io_uart_rxd)
  );
  assign io_success = SimJTAG_exit == 32'h1; // @[Periphery.scala 233:26]
  assign chiptop_jtag_TCK = SimJTAG_jtag_TCK; // @[HarnessBinders.scala 251:29 Periphery.scala 220:15]
  assign chiptop_jtag_TMS = SimJTAG_jtag_TMS; // @[HarnessBinders.scala 251:29 Periphery.scala 221:15]
  assign chiptop_jtag_TDI = SimJTAG_jtag_TDI; // @[HarnessBinders.scala 251:29 Periphery.scala 222:15]
  assign chiptop_axi4_mmio_0_bits_aw_ready = mmio_mem_io_axi4_0_aw_ready; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_w_ready = mmio_mem_io_axi4_0_w_ready; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_b_valid = mmio_mem_io_axi4_0_b_valid; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_b_bits_id = mmio_mem_io_axi4_0_b_bits_id; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_b_bits_resp = mmio_mem_io_axi4_0_b_bits_resp; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_ar_ready = mmio_mem_io_axi4_0_ar_ready; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_r_valid = mmio_mem_io_axi4_0_r_valid; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_r_bits_id = mmio_mem_io_axi4_0_r_bits_id; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_r_bits_data = mmio_mem_io_axi4_0_r_bits_data; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_r_bits_resp = mmio_mem_io_axi4_0_r_bits_resp; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mmio_0_bits_r_bits_last = mmio_mem_io_axi4_0_r_bits_last; // @[HarnessBinders.scala 223:29]
  assign chiptop_axi4_mem_0_bits_aw_ready = mem_io_axi4_0_aw_ready; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_w_ready = mem_io_axi4_0_w_ready; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_b_valid = mem_io_axi4_0_b_valid; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_b_bits_id = mem_io_axi4_0_b_bits_id; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_b_bits_resp = mem_io_axi4_0_b_bits_resp; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_ar_ready = mem_io_axi4_0_ar_ready; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_r_valid = mem_io_axi4_0_r_valid; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_r_bits_id = mem_io_axi4_0_r_bits_id; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_r_bits_data = mem_io_axi4_0_r_bits_data; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_r_bits_resp = mem_io_axi4_0_r_bits_resp; // @[HarnessBinders.scala 137:24]
  assign chiptop_axi4_mem_0_bits_r_bits_last = mem_io_axi4_0_r_bits_last; // @[HarnessBinders.scala 137:24]
  assign chiptop_uart_0_rxd = uart_sim_0_io_uart_rxd; // @[UARTAdapter.scala 135:18]
  assign chiptop_reset_wire_reset = reset; // @[TestHarness.scala 101:37]
  assign chiptop_clock = clock; // @[TestHarness.scala 112:40 TestHarness.scala 113:36]
  assign SimJTAG_clock = clock; // @[TestHarness.scala 112:40 TestHarness.scala 113:36]
  assign SimJTAG_reset = reset; // @[HarnessBinders.scala 257:107]
  assign SimJTAG_jtag_TDO_data = chiptop_jtag_TDO; // @[HarnessBinders.scala 251:29 HarnessBinders.scala 252:28]
  assign SimJTAG_jtag_TDO_driven = 1'h1; // @[HarnessBinders.scala 251:29 HarnessBinders.scala 253:30]
  assign SimJTAG_enable = plusarg_reader_out[0]; // @[Periphery.scala 228:18]
  assign SimJTAG_init_done = ~reset; // @[HarnessBinders.scala 257:115]
  assign mmio_mem_clock = chiptop_axi4_mmio_0_clock;
  assign mmio_mem_reset = chiptop_axi4_mmio_0_reset;
  assign mmio_mem_io_axi4_0_aw_valid = chiptop_axi4_mmio_0_bits_aw_valid; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_aw_bits_id = chiptop_axi4_mmio_0_bits_aw_bits_id; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_aw_bits_addr = chiptop_axi4_mmio_0_bits_aw_bits_addr[27:0]; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_aw_bits_len = chiptop_axi4_mmio_0_bits_aw_bits_len; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_aw_bits_size = chiptop_axi4_mmio_0_bits_aw_bits_size; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_aw_bits_burst = chiptop_axi4_mmio_0_bits_aw_bits_burst; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_w_valid = chiptop_axi4_mmio_0_bits_w_valid; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_w_bits_data = chiptop_axi4_mmio_0_bits_w_bits_data; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_w_bits_strb = chiptop_axi4_mmio_0_bits_w_bits_strb; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_w_bits_last = chiptop_axi4_mmio_0_bits_w_bits_last; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_b_ready = chiptop_axi4_mmio_0_bits_b_ready; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_ar_valid = chiptop_axi4_mmio_0_bits_ar_valid; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_ar_bits_id = chiptop_axi4_mmio_0_bits_ar_bits_id; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_ar_bits_addr = chiptop_axi4_mmio_0_bits_ar_bits_addr[27:0]; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_ar_bits_len = chiptop_axi4_mmio_0_bits_ar_bits_len; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_ar_bits_size = chiptop_axi4_mmio_0_bits_ar_bits_size; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_ar_bits_burst = chiptop_axi4_mmio_0_bits_ar_bits_burst; // @[HarnessBinders.scala 223:29]
  assign mmio_mem_io_axi4_0_r_ready = chiptop_axi4_mmio_0_bits_r_ready; // @[HarnessBinders.scala 223:29]
  assign mem_clock = chiptop_axi4_mem_0_clock;
  assign mem_reset = chiptop_axi4_mem_0_reset;
  assign mem_io_axi4_0_aw_valid = chiptop_axi4_mem_0_bits_aw_valid; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_aw_bits_id = chiptop_axi4_mem_0_bits_aw_bits_id; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_aw_bits_addr = chiptop_axi4_mem_0_bits_aw_bits_addr; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_aw_bits_len = chiptop_axi4_mem_0_bits_aw_bits_len; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_aw_bits_size = chiptop_axi4_mem_0_bits_aw_bits_size; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_aw_bits_burst = chiptop_axi4_mem_0_bits_aw_bits_burst; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_w_valid = chiptop_axi4_mem_0_bits_w_valid; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_w_bits_data = chiptop_axi4_mem_0_bits_w_bits_data; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_w_bits_strb = chiptop_axi4_mem_0_bits_w_bits_strb; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_w_bits_last = chiptop_axi4_mem_0_bits_w_bits_last; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_b_ready = chiptop_axi4_mem_0_bits_b_ready; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_ar_valid = chiptop_axi4_mem_0_bits_ar_valid; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_ar_bits_id = chiptop_axi4_mem_0_bits_ar_bits_id; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_ar_bits_addr = chiptop_axi4_mem_0_bits_ar_bits_addr; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_ar_bits_len = chiptop_axi4_mem_0_bits_ar_bits_len; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_ar_bits_size = chiptop_axi4_mem_0_bits_ar_bits_size; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_ar_bits_burst = chiptop_axi4_mem_0_bits_ar_bits_burst; // @[HarnessBinders.scala 137:24]
  assign mem_io_axi4_0_r_ready = chiptop_axi4_mem_0_bits_r_ready; // @[HarnessBinders.scala 137:24]
  assign uart_sim_0_clock = clock;
  assign uart_sim_0_reset = reset;
  assign uart_sim_0_io_uart_txd = chiptop_uart_0_txd; // @[UARTAdapter.scala 134:28]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_3 & _T_2) begin
          $fwrite(32'h80000002,"*** FAILED *** (exit code = %d)\n",{{1'd0}, SimJTAG_exit[31:1]}); // @[Periphery.scala 235:13]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (_T_3 & _T_2) begin
          $fatal; // @[Periphery.scala 236:11]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
module mem_inTestHarness(
  input  [24:0] R0_addr,
  input         R0_en,
  input         R0_clk,
  output [7:0]  R0_data_0,
  output [7:0]  R0_data_1,
  output [7:0]  R0_data_2,
  output [7:0]  R0_data_3,
  output [7:0]  R0_data_4,
  output [7:0]  R0_data_5,
  output [7:0]  R0_data_6,
  output [7:0]  R0_data_7,
  input  [24:0] W0_addr,
  input         W0_en,
  input         W0_clk,
  input  [7:0]  W0_data_0,
  input  [7:0]  W0_data_1,
  input  [7:0]  W0_data_2,
  input  [7:0]  W0_data_3,
  input  [7:0]  W0_data_4,
  input  [7:0]  W0_data_5,
  input  [7:0]  W0_data_6,
  input  [7:0]  W0_data_7,
  input         W0_mask_0,
  input         W0_mask_1,
  input         W0_mask_2,
  input         W0_mask_3,
  input         W0_mask_4,
  input         W0_mask_5,
  input         W0_mask_6,
  input         W0_mask_7
);
  wire [24:0] mem_ext_boom_R0_addr;
  wire  mem_ext_boom_R0_en;
  wire  mem_ext_boom_R0_clk;
  wire [63:0] mem_ext_boom_R0_data;
  wire [24:0] mem_ext_boom_W0_addr;
  wire  mem_ext_boom_W0_en;
  wire  mem_ext_boom_W0_clk;
  wire [63:0] mem_ext_boom_W0_data;
  wire [7:0] mem_ext_boom_W0_mask;
  wire [31:0] _GEN_4 = {W0_data_7,W0_data_6,W0_data_5,W0_data_4};
  wire [31:0] _GEN_5 = {W0_data_3,W0_data_2,W0_data_1,W0_data_0};
  wire [3:0] _GEN_10 = {W0_mask_7,W0_mask_6,W0_mask_5,W0_mask_4};
  wire [3:0] _GEN_11 = {W0_mask_3,W0_mask_2,W0_mask_1,W0_mask_0};
  mem_ext_boom mem_ext_boom (
    .R0_addr(mem_ext_boom_R0_addr),
    .R0_en(mem_ext_boom_R0_en),
    .R0_clk(mem_ext_boom_R0_clk),
    .R0_data(mem_ext_boom_R0_data),
    .W0_addr(mem_ext_boom_W0_addr),
    .W0_en(mem_ext_boom_W0_en),
    .W0_clk(mem_ext_boom_W0_clk),
    .W0_data(mem_ext_boom_W0_data),
    .W0_mask(mem_ext_boom_W0_mask)
  );
  assign mem_ext_boom_R0_clk = R0_clk;
  assign mem_ext_boom_R0_en = R0_en;
  assign mem_ext_boom_R0_addr = R0_addr;
  assign R0_data_0 = mem_ext_boom_R0_data[7:0];
  assign R0_data_1 = mem_ext_boom_R0_data[15:8];
  assign R0_data_2 = mem_ext_boom_R0_data[23:16];
  assign R0_data_3 = mem_ext_boom_R0_data[31:24];
  assign R0_data_4 = mem_ext_boom_R0_data[39:32];
  assign R0_data_5 = mem_ext_boom_R0_data[47:40];
  assign R0_data_6 = mem_ext_boom_R0_data[55:48];
  assign R0_data_7 = mem_ext_boom_R0_data[63:56];
  assign mem_ext_boom_W0_clk = W0_clk;
  assign mem_ext_boom_W0_en = W0_en;
  assign mem_ext_boom_W0_addr = W0_addr;
  assign mem_ext_boom_W0_data = {_GEN_4,_GEN_5};
  assign mem_ext_boom_W0_mask = {_GEN_10,_GEN_11};
endmodule
module mem_0_inTestHarness(
  input  [26:0] R0_addr,
  input         R0_en,
  input         R0_clk,
  output [7:0]  R0_data_0,
  output [7:0]  R0_data_1,
  output [7:0]  R0_data_2,
  output [7:0]  R0_data_3,
  output [7:0]  R0_data_4,
  output [7:0]  R0_data_5,
  output [7:0]  R0_data_6,
  output [7:0]  R0_data_7,
  output [7:0]  R0_data_8,
  output [7:0]  R0_data_9,
  output [7:0]  R0_data_10,
  output [7:0]  R0_data_11,
  output [7:0]  R0_data_12,
  output [7:0]  R0_data_13,
  output [7:0]  R0_data_14,
  output [7:0]  R0_data_15,
  input  [26:0] W0_addr,
  input         W0_en,
  input         W0_clk,
  input  [7:0]  W0_data_0,
  input  [7:0]  W0_data_1,
  input  [7:0]  W0_data_2,
  input  [7:0]  W0_data_3,
  input  [7:0]  W0_data_4,
  input  [7:0]  W0_data_5,
  input  [7:0]  W0_data_6,
  input  [7:0]  W0_data_7,
  input  [7:0]  W0_data_8,
  input  [7:0]  W0_data_9,
  input  [7:0]  W0_data_10,
  input  [7:0]  W0_data_11,
  input  [7:0]  W0_data_12,
  input  [7:0]  W0_data_13,
  input  [7:0]  W0_data_14,
  input  [7:0]  W0_data_15,
  input         W0_mask_0,
  input         W0_mask_1,
  input         W0_mask_2,
  input         W0_mask_3,
  input         W0_mask_4,
  input         W0_mask_5,
  input         W0_mask_6,
  input         W0_mask_7,
  input         W0_mask_8,
  input         W0_mask_9,
  input         W0_mask_10,
  input         W0_mask_11,
  input         W0_mask_12,
  input         W0_mask_13,
  input         W0_mask_14,
  input         W0_mask_15
);
  wire [26:0] mem_0_ext_boom_R0_addr;
  wire  mem_0_ext_boom_R0_en;
  wire  mem_0_ext_boom_R0_clk;
  wire [127:0] mem_0_ext_boom_R0_data;
  wire [26:0] mem_0_ext_boom_W0_addr;
  wire  mem_0_ext_boom_W0_en;
  wire  mem_0_ext_boom_W0_clk;
  wire [127:0] mem_0_ext_boom_W0_data;
  wire [15:0] mem_0_ext_boom_W0_mask;
  wire [63:0] _GEN_12 = {W0_data_15,W0_data_14,W0_data_13,W0_data_12,W0_data_11,W0_data_10,W0_data_9,W0_data_8};
  wire [63:0] _GEN_13 = {W0_data_7,W0_data_6,W0_data_5,W0_data_4,W0_data_3,W0_data_2,W0_data_1,W0_data_0};
  wire [7:0] _GEN_26 = {W0_mask_15,W0_mask_14,W0_mask_13,W0_mask_12,W0_mask_11,W0_mask_10,W0_mask_9,W0_mask_8};
  wire [7:0] _GEN_27 = {W0_mask_7,W0_mask_6,W0_mask_5,W0_mask_4,W0_mask_3,W0_mask_2,W0_mask_1,W0_mask_0};
  mem_0_ext_boom mem_0_ext_boom (
    .R0_addr(mem_0_ext_boom_R0_addr),
    .R0_en(mem_0_ext_boom_R0_en),
    .R0_clk(mem_0_ext_boom_R0_clk),
    .R0_data(mem_0_ext_boom_R0_data),
    .W0_addr(mem_0_ext_boom_W0_addr),
    .W0_en(mem_0_ext_boom_W0_en),
    .W0_clk(mem_0_ext_boom_W0_clk),
    .W0_data(mem_0_ext_boom_W0_data),
    .W0_mask(mem_0_ext_boom_W0_mask)
  );
  assign mem_0_ext_boom_R0_clk = R0_clk;
  assign mem_0_ext_boom_R0_en = R0_en;
  assign mem_0_ext_boom_R0_addr = R0_addr;
  assign R0_data_0 = mem_0_ext_boom_R0_data[7:0];
  assign R0_data_1 = mem_0_ext_boom_R0_data[15:8];
  assign R0_data_2 = mem_0_ext_boom_R0_data[23:16];
  assign R0_data_3 = mem_0_ext_boom_R0_data[31:24];
  assign R0_data_4 = mem_0_ext_boom_R0_data[39:32];
  assign R0_data_5 = mem_0_ext_boom_R0_data[47:40];
  assign R0_data_6 = mem_0_ext_boom_R0_data[55:48];
  assign R0_data_7 = mem_0_ext_boom_R0_data[63:56];
  assign R0_data_8 = mem_0_ext_boom_R0_data[71:64];
  assign R0_data_9 = mem_0_ext_boom_R0_data[79:72];
  assign R0_data_10 = mem_0_ext_boom_R0_data[87:80];
  assign R0_data_11 = mem_0_ext_boom_R0_data[95:88];
  assign R0_data_12 = mem_0_ext_boom_R0_data[103:96];
  assign R0_data_13 = mem_0_ext_boom_R0_data[111:104];
  assign R0_data_14 = mem_0_ext_boom_R0_data[119:112];
  assign R0_data_15 = mem_0_ext_boom_R0_data[127:120];
  assign mem_0_ext_boom_W0_clk = W0_clk;
  assign mem_0_ext_boom_W0_en = W0_en;
  assign mem_0_ext_boom_W0_addr = W0_addr;
  assign mem_0_ext_boom_W0_data = {_GEN_12,_GEN_13};
  assign mem_0_ext_boom_W0_mask = {_GEN_26,_GEN_27};
endmodule
module mem_1_inTestHarness(
  input  [25:0] R0_addr,
  input         R0_en,
  input         R0_clk,
  output [7:0]  R0_data_0,
  output [7:0]  R0_data_1,
  output [7:0]  R0_data_2,
  output [7:0]  R0_data_3,
  output [7:0]  R0_data_4,
  output [7:0]  R0_data_5,
  output [7:0]  R0_data_6,
  output [7:0]  R0_data_7,
  output [7:0]  R0_data_8,
  output [7:0]  R0_data_9,
  output [7:0]  R0_data_10,
  output [7:0]  R0_data_11,
  output [7:0]  R0_data_12,
  output [7:0]  R0_data_13,
  output [7:0]  R0_data_14,
  output [7:0]  R0_data_15,
  input  [25:0] W0_addr,
  input         W0_en,
  input         W0_clk,
  input  [7:0]  W0_data_0,
  input  [7:0]  W0_data_1,
  input  [7:0]  W0_data_2,
  input  [7:0]  W0_data_3,
  input  [7:0]  W0_data_4,
  input  [7:0]  W0_data_5,
  input  [7:0]  W0_data_6,
  input  [7:0]  W0_data_7,
  input  [7:0]  W0_data_8,
  input  [7:0]  W0_data_9,
  input  [7:0]  W0_data_10,
  input  [7:0]  W0_data_11,
  input  [7:0]  W0_data_12,
  input  [7:0]  W0_data_13,
  input  [7:0]  W0_data_14,
  input  [7:0]  W0_data_15,
  input         W0_mask_0,
  input         W0_mask_1,
  input         W0_mask_2,
  input         W0_mask_3,
  input         W0_mask_4,
  input         W0_mask_5,
  input         W0_mask_6,
  input         W0_mask_7,
  input         W0_mask_8,
  input         W0_mask_9,
  input         W0_mask_10,
  input         W0_mask_11,
  input         W0_mask_12,
  input         W0_mask_13,
  input         W0_mask_14,
  input         W0_mask_15
);
  wire [25:0] mem_1_ext_boom_R0_addr;
  wire  mem_1_ext_boom_R0_en;
  wire  mem_1_ext_boom_R0_clk;
  wire [127:0] mem_1_ext_boom_R0_data;
  wire [25:0] mem_1_ext_boom_W0_addr;
  wire  mem_1_ext_boom_W0_en;
  wire  mem_1_ext_boom_W0_clk;
  wire [127:0] mem_1_ext_boom_W0_data;
  wire [15:0] mem_1_ext_boom_W0_mask;
  wire [63:0] _GEN_12 = {W0_data_15,W0_data_14,W0_data_13,W0_data_12,W0_data_11,W0_data_10,W0_data_9,W0_data_8};
  wire [63:0] _GEN_13 = {W0_data_7,W0_data_6,W0_data_5,W0_data_4,W0_data_3,W0_data_2,W0_data_1,W0_data_0};
  wire [7:0] _GEN_26 = {W0_mask_15,W0_mask_14,W0_mask_13,W0_mask_12,W0_mask_11,W0_mask_10,W0_mask_9,W0_mask_8};
  wire [7:0] _GEN_27 = {W0_mask_7,W0_mask_6,W0_mask_5,W0_mask_4,W0_mask_3,W0_mask_2,W0_mask_1,W0_mask_0};
  mem_1_ext_boom mem_1_ext_boom (
    .R0_addr(mem_1_ext_boom_R0_addr),
    .R0_en(mem_1_ext_boom_R0_en),
    .R0_clk(mem_1_ext_boom_R0_clk),
    .R0_data(mem_1_ext_boom_R0_data),
    .W0_addr(mem_1_ext_boom_W0_addr),
    .W0_en(mem_1_ext_boom_W0_en),
    .W0_clk(mem_1_ext_boom_W0_clk),
    .W0_data(mem_1_ext_boom_W0_data),
    .W0_mask(mem_1_ext_boom_W0_mask)
  );
  assign mem_1_ext_boom_R0_clk = R0_clk;
  assign mem_1_ext_boom_R0_en = R0_en;
  assign mem_1_ext_boom_R0_addr = R0_addr;
  assign R0_data_0 = mem_1_ext_boom_R0_data[7:0];
  assign R0_data_1 = mem_1_ext_boom_R0_data[15:8];
  assign R0_data_2 = mem_1_ext_boom_R0_data[23:16];
  assign R0_data_3 = mem_1_ext_boom_R0_data[31:24];
  assign R0_data_4 = mem_1_ext_boom_R0_data[39:32];
  assign R0_data_5 = mem_1_ext_boom_R0_data[47:40];
  assign R0_data_6 = mem_1_ext_boom_R0_data[55:48];
  assign R0_data_7 = mem_1_ext_boom_R0_data[63:56];
  assign R0_data_8 = mem_1_ext_boom_R0_data[71:64];
  assign R0_data_9 = mem_1_ext_boom_R0_data[79:72];
  assign R0_data_10 = mem_1_ext_boom_R0_data[87:80];
  assign R0_data_11 = mem_1_ext_boom_R0_data[95:88];
  assign R0_data_12 = mem_1_ext_boom_R0_data[103:96];
  assign R0_data_13 = mem_1_ext_boom_R0_data[111:104];
  assign R0_data_14 = mem_1_ext_boom_R0_data[119:112];
  assign R0_data_15 = mem_1_ext_boom_R0_data[127:120];
  assign mem_1_ext_boom_W0_clk = W0_clk;
  assign mem_1_ext_boom_W0_en = W0_en;
  assign mem_1_ext_boom_W0_addr = W0_addr;
  assign mem_1_ext_boom_W0_data = {_GEN_12,_GEN_13};
  assign mem_1_ext_boom_W0_mask = {_GEN_26,_GEN_27};
endmodule
module mem_2_inTestHarness(
  input  [24:0] R0_addr,
  input         R0_en,
  input         R0_clk,
  output [7:0]  R0_data_0,
  output [7:0]  R0_data_1,
  output [7:0]  R0_data_2,
  output [7:0]  R0_data_3,
  output [7:0]  R0_data_4,
  output [7:0]  R0_data_5,
  output [7:0]  R0_data_6,
  output [7:0]  R0_data_7,
  output [7:0]  R0_data_8,
  output [7:0]  R0_data_9,
  output [7:0]  R0_data_10,
  output [7:0]  R0_data_11,
  output [7:0]  R0_data_12,
  output [7:0]  R0_data_13,
  output [7:0]  R0_data_14,
  output [7:0]  R0_data_15,
  input  [24:0] W0_addr,
  input         W0_en,
  input         W0_clk,
  input  [7:0]  W0_data_0,
  input  [7:0]  W0_data_1,
  input  [7:0]  W0_data_2,
  input  [7:0]  W0_data_3,
  input  [7:0]  W0_data_4,
  input  [7:0]  W0_data_5,
  input  [7:0]  W0_data_6,
  input  [7:0]  W0_data_7,
  input  [7:0]  W0_data_8,
  input  [7:0]  W0_data_9,
  input  [7:0]  W0_data_10,
  input  [7:0]  W0_data_11,
  input  [7:0]  W0_data_12,
  input  [7:0]  W0_data_13,
  input  [7:0]  W0_data_14,
  input  [7:0]  W0_data_15,
  input         W0_mask_0,
  input         W0_mask_1,
  input         W0_mask_2,
  input         W0_mask_3,
  input         W0_mask_4,
  input         W0_mask_5,
  input         W0_mask_6,
  input         W0_mask_7,
  input         W0_mask_8,
  input         W0_mask_9,
  input         W0_mask_10,
  input         W0_mask_11,
  input         W0_mask_12,
  input         W0_mask_13,
  input         W0_mask_14,
  input         W0_mask_15
);
  wire [24:0] mem_2_ext_boom_R0_addr;
  wire  mem_2_ext_boom_R0_en;
  wire  mem_2_ext_boom_R0_clk;
  wire [127:0] mem_2_ext_boom_R0_data;
  wire [24:0] mem_2_ext_boom_W0_addr;
  wire  mem_2_ext_boom_W0_en;
  wire  mem_2_ext_boom_W0_clk;
  wire [127:0] mem_2_ext_boom_W0_data;
  wire [15:0] mem_2_ext_boom_W0_mask;
  wire [63:0] _GEN_12 = {W0_data_15,W0_data_14,W0_data_13,W0_data_12,W0_data_11,W0_data_10,W0_data_9,W0_data_8};
  wire [63:0] _GEN_13 = {W0_data_7,W0_data_6,W0_data_5,W0_data_4,W0_data_3,W0_data_2,W0_data_1,W0_data_0};
  wire [7:0] _GEN_26 = {W0_mask_15,W0_mask_14,W0_mask_13,W0_mask_12,W0_mask_11,W0_mask_10,W0_mask_9,W0_mask_8};
  wire [7:0] _GEN_27 = {W0_mask_7,W0_mask_6,W0_mask_5,W0_mask_4,W0_mask_3,W0_mask_2,W0_mask_1,W0_mask_0};
  mem_2_ext_boom mem_2_ext_boom (
    .R0_addr(mem_2_ext_boom_R0_addr),
    .R0_en(mem_2_ext_boom_R0_en),
    .R0_clk(mem_2_ext_boom_R0_clk),
    .R0_data(mem_2_ext_boom_R0_data),
    .W0_addr(mem_2_ext_boom_W0_addr),
    .W0_en(mem_2_ext_boom_W0_en),
    .W0_clk(mem_2_ext_boom_W0_clk),
    .W0_data(mem_2_ext_boom_W0_data),
    .W0_mask(mem_2_ext_boom_W0_mask)
  );
  assign mem_2_ext_boom_R0_clk = R0_clk;
  assign mem_2_ext_boom_R0_en = R0_en;
  assign mem_2_ext_boom_R0_addr = R0_addr;
  assign R0_data_0 = mem_2_ext_boom_R0_data[7:0];
  assign R0_data_1 = mem_2_ext_boom_R0_data[15:8];
  assign R0_data_2 = mem_2_ext_boom_R0_data[23:16];
  assign R0_data_3 = mem_2_ext_boom_R0_data[31:24];
  assign R0_data_4 = mem_2_ext_boom_R0_data[39:32];
  assign R0_data_5 = mem_2_ext_boom_R0_data[47:40];
  assign R0_data_6 = mem_2_ext_boom_R0_data[55:48];
  assign R0_data_7 = mem_2_ext_boom_R0_data[63:56];
  assign R0_data_8 = mem_2_ext_boom_R0_data[71:64];
  assign R0_data_9 = mem_2_ext_boom_R0_data[79:72];
  assign R0_data_10 = mem_2_ext_boom_R0_data[87:80];
  assign R0_data_11 = mem_2_ext_boom_R0_data[95:88];
  assign R0_data_12 = mem_2_ext_boom_R0_data[103:96];
  assign R0_data_13 = mem_2_ext_boom_R0_data[111:104];
  assign R0_data_14 = mem_2_ext_boom_R0_data[119:112];
  assign R0_data_15 = mem_2_ext_boom_R0_data[127:120];
  assign mem_2_ext_boom_W0_clk = W0_clk;
  assign mem_2_ext_boom_W0_en = W0_en;
  assign mem_2_ext_boom_W0_addr = W0_addr;
  assign mem_2_ext_boom_W0_data = {_GEN_12,_GEN_13};
  assign mem_2_ext_boom_W0_mask = {_GEN_26,_GEN_27};
endmodule
