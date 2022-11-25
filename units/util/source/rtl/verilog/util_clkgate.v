
`timescale 1ns/100ps

module util_clkgate #(
    parameter DELAY = 0.1
)(
    input  wire clk_i,
    input  wire en_i,
    input  wire testmode_i,
    output wire clk_o
);

`ifdef XILINX_FPGA

    BUFGCE clkgate_bufgce (
       .I  (clk_i),
       .CE (en_i | testmode_i),
       .O  (clk_o)
    );

`else

    reg  int_clk;
    wire int_en;

    assign
        // synopsys translate_off
        #DELAY
        // synopsys translate_on
        int_en = en_i | testmode_i;

    always @(clk_i or int_en) begin
        if (clk_i == 1'b0) begin
            int_clk <= int_en;
        end
    end

    assign clk_o = int_clk & clk_i;

`endif

endmodule
