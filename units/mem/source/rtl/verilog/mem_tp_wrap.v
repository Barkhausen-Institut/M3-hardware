
module mem_tp_wrap #(
    parameter MEM_TYPE = "auto",        //only for FPGA memory: auto, distributed, block, ultra
    parameter MEM_DATAWIDTH = 128,
    parameter MEM_ADDRWIDTH = 14
)
(
    input  wire                            clk,
    input  wire                            reset,

    input  wire                            ena,
    input  wire  [(MEM_DATAWIDTH+7)/8-1:0] wea,
    input  wire        [MEM_ADDRWIDTH-1:0] addra,
    input  wire        [MEM_DATAWIDTH-1:0] dina,

    input  wire                            enb,
    input  wire        [MEM_ADDRWIDTH-1:0] addrb,
    output wire        [MEM_DATAWIDTH-1:0] doutb
);

`ifdef FPGA_COMPILE

    xpm_sdp_ram #(
        .MEM_TYPE(MEM_TYPE),
        .MEM_DATAWIDTH(MEM_DATAWIDTH),
        .MEM_ADDRWIDTH(MEM_ADDRWIDTH)
    ) i_xpm_sdp_ram (
        .clk    (clk),
        .reset  (reset),
        .ena    (ena),
        .wea    (wea),
        .addra  (addra),
        .dina   (dina),
        .enb    (enb),
        .addrb  (addrb),
        .doutb  (doutb)
    );

`else

    //chip SRAM wrapper

`endif


endmodule
