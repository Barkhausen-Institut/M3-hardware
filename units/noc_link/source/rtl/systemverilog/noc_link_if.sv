
`ifndef _tNOC_LINK_INTERFACE
`define _tNOC_LINK_INTERFACE

// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

interface noc_link_if #(
    `include "noc_parameter.vh"
    );

    //parallel IF signals
    logic [NOC_ASYNC_FIFO_AWIDTH:0]        fifo_read_addr;
    logic [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] fifo_read_data;
    logic [NOC_ASYNC_FIFO_AWIDTH:0]        fifo_write_addr;

    modport tx(
        output      fifo_write_addr,
        output      fifo_read_data,
        input       fifo_read_addr
    );

    modport rx(
        input       fifo_write_addr,
        input       fifo_read_data,
        output      fifo_read_addr
    );

endinterface

`endif //  `ifndef _tNOC_LINK_INTERFACE
