`ifndef INPORT_SELECT_BE
`define INPORT_SELECT_BE

// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module inPortSelectBE #(
    parameter INPORT_QUANT				= 1
)
(
    input	wire	[INPORT_QUANT-1:0]	candidateList_i,
    output	wire	[INPORT_QUANT-1:0]	inPortSel_o,
    input	wire	[INPORT_QUANT-1:0]	roundRobinSrcPort_i,
    input	wire						burstActive_i
);

    wire	[INPORT_QUANT-1:0]	  inPortSel             [0:INPORT_QUANT-1];
    reg		[INPORT_QUANT-1:0]	  inPortSelBurst;
    wire	[INPORT_QUANT-1:0]	  candidateList_shifted [0:INPORT_QUANT-1];

    assign inPortSel_o	= (burstActive_i) ? inPortSelBurst : inPortSel [roundRobinSrcPort_i];

    always@* begin
        inPortSelBurst							= {INPORT_QUANT{1'b0}};
        inPortSelBurst [roundRobinSrcPort_i]	= 1'b1;
    end

    genvar gen_i, gen_j;
    generate
        for (gen_i=0; gen_i<INPORT_QUANT; gen_i=gen_i+1) begin: candListShift_set
            if (gen_i == INPORT_QUANT-1) begin: candListShift_specialCase
                assign candidateList_shifted [gen_i] = {candidateList_i};
            end
            else begin: candListShift_general
                assign candidateList_shifted [gen_i] = {candidateList_i [gen_i:0], candidateList_i [INPORT_QUANT-1 : gen_i+1]};
            end
        end

        for (gen_i=0; gen_i<INPORT_QUANT; gen_i=gen_i+1) begin: inPortSel_set1//the roundRobinPort
            for (gen_j=0; gen_j<INPORT_QUANT; gen_j=gen_j+1) begin: inPortSel_set2 //the inPortSel
                if (gen_j == gen_i) begin : gen_i_eq_j
                    assign inPortSel [gen_i][gen_j]	= candidateList_shifted [gen_j][INPORT_QUANT-1];
                end
                else begin: gen_i_ne_j
                    assign inPortSel [gen_i][gen_j]	= candidateList_shifted [gen_j][INPORT_QUANT-1] && !(|candidateList_shifted [gen_j][INPORT_QUANT-2 : (gen_i-gen_j-1+INPORT_QUANT)%INPORT_QUANT]);
                end
            end
        end // for (gen_i=0; gen_i<INPORT_QUANT; gen_i=gen_i+1)
    endgenerate

endmodule // inPortSelectBE

`endif
