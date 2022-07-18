
module mem_sp_wrap #(
    parameter MEM_TYPE = "auto",        //only for FPGA memory: auto, distributed, block, ultra
    parameter MEM_DATAWIDTH = 128,
    parameter MEM_ADDRWIDTH = 14
)
(
    input  wire                            clk,
    input  wire                            reset,

    input  wire                            en,
    input  wire  [(MEM_DATAWIDTH+7)/8-1:0] we,
    input  wire        [MEM_ADDRWIDTH-1:0] addr,
    input  wire        [MEM_DATAWIDTH-1:0] din,
    output wire        [MEM_DATAWIDTH-1:0] dout
);

`ifdef XILINX_FPGA

    xpm_sp_ram #(
        .MEM_TYPE(MEM_TYPE),
        .MEM_DATAWIDTH(MEM_DATAWIDTH),
        .MEM_ADDRWIDTH(MEM_ADDRWIDTH)
    ) i_xpm_sp_ram (
        .clk    (clk),
        .reset  (reset),
        .en     (en),
        .we     (we),
        .addr   (addr),
        .din    (din),
        .dout   (dout)
    );

`else

    //chip SRAM wrapper

`endif


endmodule
