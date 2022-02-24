
`timescale 1ns/100ps

module util_clkbuf #(
    parameter DELAY = 0.1
)(
    input  wire I,
    output wire Z
);

    assign
        // synopsys translate_off
        #DELAY
        // synopsys translate_on
        Z = I;

endmodule 
