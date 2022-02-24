`ifndef tPORT_IN
`define tPORT_IN

// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module tPortIn #(
    `include "noc_parameter.vh"
)
(
    // Header: burst(1)+bsel+srcModId+srcChipId+trgX+trgY+trgZ+trgModId+trgChipId
    // Payload: mode+address+data

    //Interface to the remote router
    input   wire    [NOC_HEADER_SIZE-1:0]   header_i,
    input   wire    [NOC_PAYLOAD_SIZE-1:0]  payload_i,
    output  wire                            rdreq_o,
    input   wire                            flit_avail_q_i,

    //Interface to the own router
    output  wire    [NOC_HEADER_SIZE-1:0]   BEheader_o,
    output  wire    [NOC_PAYLOAD_SIZE-1:0]  BEpayload_o,
    output  wire                            BEflitAvail_o,
    input   wire                            BEflitReq_i
);


    assign rdreq_o          = BEflitReq_i;
    assign BEflitAvail_o    = !flit_avail_q_i;
    assign BEheader_o       = header_i;
    assign BEpayload_o      = payload_i;

endmodule // tPortIn

`endif
