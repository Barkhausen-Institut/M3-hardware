
module mem_tp_bit_wrap #(
    parameter MEM_TYPE = "auto",        //only for FPGA memory: auto, distributed, block, ultra
    parameter MEM_DATAWIDTH = 128,
    parameter MEM_ADDRWIDTH = 14
)
(
    input  wire                            clk,
    input  wire                            reset,

    input  wire                            ena,
    input  wire        [MEM_DATAWIDTH-1:0] wea,   //bit-wise write-enable
    input  wire        [MEM_ADDRWIDTH-1:0] addra,
    input  wire        [MEM_DATAWIDTH-1:0] dina,

    input  wire                            enb,
    input  wire        [MEM_ADDRWIDTH-1:0] addrb,
    output wire        [MEM_DATAWIDTH-1:0] doutb
);

`ifdef FPGA_COMPILE

    genvar idx_byte;

    generate
    if (MEM_TYPE == "distributed") begin: FPGA_DISTRAM
        xpm_sdp_distram #(
            .MEM_DATAWIDTH(MEM_DATAWIDTH),
            .MEM_ADDRWIDTH(MEM_ADDRWIDTH)
        ) i_xpm_sdp_distram (
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
    end
    else begin: FPGA_RAM
        localparam MEM_DATAWIDTH_EXT = ((MEM_DATAWIDTH+7)/8) << 3;

        wire   [MEM_DATAWIDTH_EXT-1:0] wea_ext = {{(MEM_DATAWIDTH_EXT-MEM_DATAWIDTH){1'b0}}, wea};
        wire [(MEM_DATAWIDTH+7)/8-1:0] wea_byte;

        for (idx_byte=0; idx_byte<(MEM_DATAWIDTH+7)/8; idx_byte=idx_byte+1) begin
            assign wea_byte[idx_byte] = |wea_ext[(idx_byte+1)*8-1 : idx_byte*8];
        end

        xpm_sdp_ram #(
            .MEM_TYPE(MEM_TYPE),
            .MEM_DATAWIDTH(MEM_DATAWIDTH),
            .MEM_ADDRWIDTH(MEM_ADDRWIDTH)
        ) i_xpm_sdp_ram (
            .clk    (clk),
            .reset  (reset),
            .ena    (ena),
            .wea    (wea_byte),
            .addra  (addra),
            .dina   (dina),
            .enb    (enb),
            .addrb  (addrb),
            .doutb  (doutb)
        );
    end
    endgenerate

`else

    //chip SRAM wrapper

`endif


endmodule
