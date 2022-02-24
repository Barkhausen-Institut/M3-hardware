`ifndef tPORT_OUT
`define tPORT_OUT

// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module tPortOut #(
    `include "noc_parameter.vh"
)
(
    // Header: burst(1)+bsel+srcModId+srcChipId+trgX+trgY+trgZ+trgModId+trgChipId
    // Payload: mode+address+data

    //Interface to the remote router
    output  wire    [NOC_HEADER_SIZE-1:0]   header_o,
    output  wire    [NOC_PAYLOAD_SIZE-1:0]  payload_o,
    output  wire                            wrreq_o,
    input   wire                            BEstall_i,

    //Interface to the own router (to Transmitter)
    input   wire    [NOC_HEADER_SIZE-1:0]   flitHeader_i,
    input   wire    [NOC_PAYLOAD_SIZE-1:0]  flitPayload_i,
    input   wire                            flitWrreq_i,
    output  wire                            flitStall_o
);


    assign header_o     = flitHeader_i;
    assign payload_o    = flitPayload_i;
    assign wrreq_o      = flitWrreq_i;
    assign flitStall_o  = BEstall_i;

endmodule // tPortOut

`endif //  `ifndef tPORT_OUT
