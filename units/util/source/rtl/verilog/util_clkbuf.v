
`timescale 1ns/100ps

module util_clkbuf #(
    parameter DELAY = 0.1
)(
    input  wire clk_i,
    output wire clk_o
);

    assign
        // synopsys translate_off
        #DELAY
        // synopsys translate_on
        clk_o = clk_i;


endmodule 
