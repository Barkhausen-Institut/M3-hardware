`ifndef _tFLIT_COUNTER
`define _tFLIT_COUNTER

// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module flit_counter #(
    parameter   CNT_SIZE    = 48
)
(
    input   wire                    clk_i,
    input   wire                    reset_q_i,

    input   wire                    cnt_en_i,
    input   wire                    cnt_rst_i,
    output  wire    [CNT_SIZE-1:0]  cnt_data_o
);


    // counter
    reg     [CNT_SIZE-1:0]  r_cnt;
    reg     [CNT_SIZE-1:0]  rin_cnt;


    // logic ******************************************************************************************

    // lower counter register
    always @(posedge clk_i, negedge reset_q_i) begin: cnt_low_reg
        if (reset_q_i == 1'b0) begin
            r_cnt   <= {CNT_SIZE{1'b0}};
        end else begin
            r_cnt   <= rin_cnt;
        end
    end
    always @* begin: cnt_low_logic
        if (cnt_rst_i == 1'b1) begin
            rin_cnt = {CNT_SIZE{1'b0}};
        end else if (cnt_en_i == 1'b1) begin
            rin_cnt = r_cnt + 1;
        end else begin
            rin_cnt = r_cnt;
        end
    end

    // output ******************************************************************************************
    assign cnt_data_o       = r_cnt;


endmodule // flit_counter

`endif //  `ifndef _tFLIT_COUNTER
