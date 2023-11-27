
module asm_mem_mux #(
    parameter MEM_DATAWIDTH = 128,
    parameter MEM_ADDRWIDTH = 14,
    parameter MEM_BSELWIDTH = MEM_DATAWIDTH/8
)(
    //in1 has prio
    input  wire                     mem_in1_en_i,
    input  wire [MEM_BSELWIDTH-1:0] mem_in1_wben_i,
    input  wire [MEM_ADDRWIDTH-1:0] mem_in1_addr_i,
    input  wire [MEM_DATAWIDTH-1:0] mem_in1_wdata_i,
    output wire [MEM_DATAWIDTH-1:0] mem_in1_rdata_o,
    output wire                     mem_in1_stall_o,

    input  wire                     mem_in2_en_i,
    input  wire [MEM_BSELWIDTH-1:0] mem_in2_wben_i,
    input  wire [MEM_ADDRWIDTH-1:0] mem_in2_addr_i,
    input  wire [MEM_DATAWIDTH-1:0] mem_in2_wdata_i,
    output wire [MEM_DATAWIDTH-1:0] mem_in2_rdata_o,
    output wire                     mem_in2_stall_o,

    output reg                      mem_out_en_o,
    output reg  [MEM_BSELWIDTH-1:0] mem_out_wben_o,
    output reg  [MEM_ADDRWIDTH-1:0] mem_out_addr_o,
    output reg  [MEM_DATAWIDTH-1:0] mem_out_wdata_o,
    input  wire [MEM_DATAWIDTH-1:0] mem_out_rdata_i,
    input  wire                     mem_out_stall_i
);


//in1 has prio
always @* begin
    if (mem_in1_en_i) begin
        mem_out_en_o = mem_in1_en_i;
        mem_out_wben_o = mem_in1_wben_i;
        mem_out_addr_o = mem_in1_addr_i;
        mem_out_wdata_o = mem_in1_wdata_i;
    end
    else begin
        mem_out_en_o = mem_in2_en_i;
        mem_out_wben_o = mem_in2_wben_i;
        mem_out_addr_o = mem_in2_addr_i;
        mem_out_wdata_o = mem_in2_wdata_i;
    end
end


assign mem_in1_rdata_o = mem_out_rdata_i;
assign mem_in2_rdata_o = mem_out_rdata_i;

assign mem_in1_stall_o = mem_out_stall_i;
assign mem_in2_stall_o = mem_out_stall_i | mem_in1_en_i;


endmodule
