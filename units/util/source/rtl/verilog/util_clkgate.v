
`timescale 1ns/100ps

module util_clkgate #(
    parameter DELAY = 0.1
)(
    input  wire CP,
    input  wire EN,
    input  wire TE,
    output wire CPEN
);



`ifdef FPGA_COMPILE

    BUFGCE clkgate_bufgce (
	   .I  (CP),
       .CE (EN | TE),
       .O  (CPEN)
	);
	
`else
   
    reg  CKL;
    wire INT_E;

    assign
        // synopsys translate_off
        #DELAY
        // synopsys translate_on
        INT_E = EN | (TE == 1'b1);

    always @(CP or INT_E) begin
        if (CP == 1'b0) begin
            CKL <= INT_E;
        end
    end

    assign CPEN = CKL & CP;

`endif
	
endmodule
