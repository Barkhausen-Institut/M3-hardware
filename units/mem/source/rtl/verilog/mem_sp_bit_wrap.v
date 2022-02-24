
module mem_sp_bit_wrap #(
    parameter MEM_TYPE = "auto",        //only for FPGA memory: auto, distributed, block, ultra
    parameter MEM_DATAWIDTH = 128,
    parameter MEM_ADDRWIDTH = 14
)
(
    input  wire                            clk,
    input  wire                            reset,

    input  wire                            en,
    input  wire        [MEM_DATAWIDTH-1:0] we,    //bit-wise write-enable
    input  wire        [MEM_ADDRWIDTH-1:0] addr,
    input  wire        [MEM_DATAWIDTH-1:0] din,
    output wire        [MEM_DATAWIDTH-1:0] dout
);

`ifdef FPGA_COMPILE

    genvar idx_byte;

    generate
    if (MEM_TYPE == "distributed") begin: FPGA_DISTRAM
        xpm_sp_distram #(
            .MEM_DATAWIDTH(MEM_DATAWIDTH),
            .MEM_ADDRWIDTH(MEM_ADDRWIDTH)
        ) i_xpm_sp_distram (
            .clk    (clk),
            .reset  (reset),
            .en     (en),
            .we     (we),
            .addr   (addr),
            .din    (din),
            .dout   (dout)
        );
    end
    else begin: FPGA_RAM
        localparam MEM_DATAWIDTH_EXT = ((MEM_DATAWIDTH+7)/8) << 3;

        wire   [MEM_DATAWIDTH_EXT-1:0] we_ext = {{(MEM_DATAWIDTH_EXT-MEM_DATAWIDTH){1'b0}}, we};
        wire [(MEM_DATAWIDTH+7)/8-1:0] we_byte;

        for (idx_byte=0; idx_byte<(MEM_DATAWIDTH+7)/8; idx_byte=idx_byte+1) begin
            assign we_byte[idx_byte] = |we_ext[(idx_byte+1)*8-1 : idx_byte*8];
        end

        xpm_sp_ram #(
            .MEM_TYPE(MEM_TYPE),
            .MEM_DATAWIDTH(MEM_DATAWIDTH),
            .MEM_ADDRWIDTH(MEM_ADDRWIDTH)
        ) i_xpm_sp_ram (
            .clk    (clk),
            .reset  (reset),
            .en     (en),
            .we     (we_byte),
            .addr   (addr),
            .din    (din),
            .dout   (dout)
        );
    end
    endgenerate

`else

    //chip SRAM wrapper

`endif


endmodule
