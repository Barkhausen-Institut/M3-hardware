
module util_reset_sync (
    input  wire clk_i,
    input  wire reset_q_i,
    input  wire scan_mode_i,
    output wire sync_reset_q_o
);

    wire reset_release_sync;

    util_sync i_util_sync (
        .clk_i     (clk_i),
        .reset_n_i (reset_q_i),
        .data_i    (1'b1),
        .data_o    (reset_release_sync)
    );

    assign sync_reset_q_o = (scan_mode_i) ? reset_q_i : reset_release_sync;


endmodule
