
module acc_core #(
    parameter MEM_DATA_SIZE = 32,
    parameter MEM_ADDR_SIZE = 32
)
(
    input  wire                       clk_i,
    input  wire                       resetn_i,

    output wire                       mem_en_o,
	output wire [MEM_DATA_SIZE/8-1:0] mem_we_o,
    output wire   [MEM_ADDR_SIZE-1:0] mem_addr_o,
	output wire   [MEM_DATA_SIZE-1:0] mem_wdata_o,
	input  wire   [MEM_DATA_SIZE-1:0] mem_rdata_i,
    input  wire                       mem_stall_i
);

//nothing in here yet
assign mem_en_o = 1'b0;
assign mem_we_o = {(MEM_DATA_SIZE/8){1'b0}};
assign mem_addr_o = {MEM_ADDR_SIZE{1'b0}};
assign mem_wdata_o = {MEM_DATA_SIZE{1'b0}};



endmodule
