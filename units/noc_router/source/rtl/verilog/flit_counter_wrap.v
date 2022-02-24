`ifndef _tFLIT_COUNTER_WRAP
`define _tFLIT_COUNTER_WRAP

// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module flit_counter_wrap #(
    `include "noc_parameter.vh"
    ,parameter                      OUTPORT_QUANT       = 1
)
(
    input   wire                                    clk_i,
    input   wire                                    reset_q_i,
    input   wire    [OUTPORT_QUANT-1:0]             cnt_en_i,
    output  wire    [CNT_SIZE-1:0]                  cnt_data_o,
    input   wire    [clogb2(OUTPORT_QUANT)-1:0]     cnt_port_sel_i,
    input   wire                                    cnt_rst_i
);

    function integer clogb2 (input [31:0] value_in);
        reg [31:0] value;
        begin
            value = value_in - 1;
            for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
                value = value >> 1;
        end
    endfunction

    // signals ******************************************************************************************
    wire    [CNT_SIZE-1:0]      cnt_data [0:OUTPORT_QUANT-1];
    wire    [OUTPORT_QUANT-1:0] cnt_rst;
    reg     [OUTPORT_QUANT-1:0] tmp0_cnt_en;    // before switching of source, after switching of mode

    genvar gen_i;
    // logic ******************************************************************************************

    assign cnt_data_o   = cnt_data [cnt_port_sel_i];

    // set reset only for selected counter
    generate
        for (gen_i=0; gen_i<OUTPORT_QUANT; gen_i=gen_i+1) begin
            assign cnt_rst [gen_i] = (gen_i == cnt_port_sel_i) ? cnt_rst_i : 1'b0;
        end
    endgenerate

    // select mode (count ever flit or only the ones with matching prios)
    generate
        for (gen_i=0; gen_i<OUTPORT_QUANT; gen_i=gen_i+1) begin
            always @* begin
                tmp0_cnt_en [gen_i] = cnt_en_i [gen_i]; // count every flit
            end
        end
    endgenerate

    // instances ******************************************************************************************
    generate
        for (gen_i=0; gen_i<OUTPORT_QUANT; gen_i=gen_i+1) begin: counter_inst
            flit_counter #(
                .CNT_SIZE   (CNT_SIZE)
            )
            i_flit_counter (
                .clk_i      (clk_i),
                .reset_q_i  (reset_q_i),
                .cnt_en_i   (tmp0_cnt_en [gen_i]),
                .cnt_rst_i  (cnt_rst [gen_i]),
                .cnt_data_o (cnt_data [gen_i])
            );
        end
    endgenerate

endmodule // flit_counter_wrap

`endif //  `ifndef _tFLIT_COUNTER_WRAP
