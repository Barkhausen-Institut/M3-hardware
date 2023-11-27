
module picorv32_core #(
    parameter PICO_MEM_DATA_SIZE = 32,
    parameter PICO_MEM_ADDR_SIZE = 32
)
(
    input  wire                            clk_i,
    input  wire                            resetn_i,

    output wire                            mem_en_o,
	output wire [PICO_MEM_DATA_SIZE/8-1:0] mem_we_o,
    output wire   [PICO_MEM_ADDR_SIZE-1:0] mem_addr_o,
	output wire   [PICO_MEM_DATA_SIZE-1:0] mem_wdata_o,
	input  wire   [PICO_MEM_DATA_SIZE-1:0] mem_rdata_i,
    input  wire                            mem_stall_i,

    output wire                            trap_o,
    input  wire                     [31:0] irq_i,
    output wire                     [31:0] eoi_o,

    input  wire   [PICO_MEM_ADDR_SIZE-1:0] stackaddr_i
);


wire mem_instr;
reg r_mem_en;

//assuming if not stalled read data is available in next cycle
always @(posedge clk_i or negedge resetn_i) begin
    if (!resetn_i) begin
        r_mem_en <= 1'b0;
    end else begin
        r_mem_en <= mem_stall_i ? r_mem_en : mem_en_o;
    end
end



picorv32 #(
    .ENABLE_COUNTERS        (1),
    .ENABLE_COUNTERS64      (1),
    .ENABLE_REGS_16_31      (1),
    .ENABLE_REGS_DUALPORT   (1),
    .LATCHED_MEM_RDATA      (0),
    .TWO_STAGE_SHIFT        (1),
    .BARREL_SHIFTER         (0),
    .TWO_CYCLE_COMPARE      (0),
    .TWO_CYCLE_ALU          (0),
    .COMPRESSED_ISA         (0),
    .CATCH_MISALIGN         (1),
    .CATCH_ILLINSN          (1),
    .ENABLE_PCPI            (0),
    .ENABLE_MUL             (0),
    .ENABLE_FAST_MUL        (0),
    .ENABLE_DIV             (0),
    .ENABLE_IRQ             (1),
    .ENABLE_IRQ_QREGS       (1),
    .ENABLE_IRQ_TIMER       (1),
    .ENABLE_TRACE           (0),
    .REGS_INIT_ZERO         (0),
    .MASKED_IRQ             (32'h0000_0000),
    .LATCHED_IRQ            (32'hffff_ffff),
    .PROGADDR_RESET         (32'h0000_0000),
    .PROGADDR_IRQ           (32'h0000_0010)
    //.STACKADDR              (STACKADDR)
) i_picorv32 (
	.clk             (clk_i),
    .resetn          (resetn_i),
	.trap            (trap_o),

	.mem_valid       (mem_en_o),
	.mem_instr       (mem_instr),
    .mem_ready       (r_mem_en),
	.mem_addr        (mem_addr_o),
	.mem_wdata       (mem_wdata_o),
	.mem_wstrb       (mem_we_o),
	.mem_rdata       (mem_rdata_i),

	// Look-Ahead Interface
	.mem_la_read     (),
	.mem_la_write    (),
	.mem_la_addr     (),
	.mem_la_wdata    (),
	.mem_la_wstrb    (),

	// Pico Co-Processor Interface (PCPI)
	.pcpi_valid      (),
	.pcpi_insn       (),
	.pcpi_rs1        (),
	.pcpi_rs2        (),
	.pcpi_wr         (1'b0),
	.pcpi_rd         (32'h0),
	.pcpi_wait       (1'b0),
	.pcpi_ready      (1'b0),

	// IRQ Interface
	.irq             (irq_i),
	.eoi             (eoi_o),

    .stackaddr_i     (stackaddr_i),

	// Trace Interface
	.trace_valid     (),
	.trace_data      ()
);


endmodule
