
module rld3_domain #(
    `include "noc_parameter.vh"
    ,parameter HOME_MODID = {NOC_MODID_SIZE{1'b0}},
    parameter SIMULATION = 0        //if enabled, DDR4 controller is removed and simple on-chip memory is connected
)
(
    input  wire                                  c0_sys_clk_n,
    input  wire                                  c0_sys_clk_p,
    input  wire            [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input  wire                                  sys_rst,
    output wire                                  c0_init_calib_complete,
    input  wire      [7:0]       c0_rld3_qk_p,
    input  wire      [7:0]       c0_rld3_qk_n,
    input  wire      [3:0]       c0_rld3_qvld,
    // Inouts
    inout wire       [71:0]      c0_rld3_dq,

    // Outputs
    output wire                 c0_rld3_ck_p,
    output wire                 c0_rld3_ck_n,
    output wire [3:0]           c0_rld3_dk_p,
    output wire [3:0]           c0_rld3_dk_n,
    output wire                 c0_rld3_cs_n,
    output wire                 c0_rld3_we_n,
    output wire                 c0_rld3_ref_n,
    output wire                 c0_rld3_reset_n,
    output wire [3:0]           c0_rld3_dm,
    output wire [19:0]          c0_rld3_a,
    output wire [3:0]           c0_rld3_ba,



    // NoC interface
    input	wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_in_data_i,
    output	wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_raddr_o,
    input	wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_waddr_i,
    output	wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_out_data_o,
    input	wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_raddr_i,
    output	wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_waddr_o


);

    // wire ddr4_rst_n_s;
    //
    // wire [NOC_CHIPID_SIZE-1:0] home_chipid_s;


    rld3_wrap #(
        .HOME_MODID                  (HOME_MODID),
        .SIMULATION                  (SIMULATION)
    ) i_rld3_wrap (

        .sys_rst                     (sys_rst),
        .c0_sys_clk_p                (c0_sys_clk_p),
        .c0_sys_clk_n                (c0_sys_clk_n),
        .c0_init_calib_complete      (c0_init_calib_complete),

        .home_chipid_i               (home_chipid_i),

        .noc_fifo_in_data_i          (noc_fifo_in_data_i),
        .noc_fifo_in_raddr_o         (noc_fifo_in_raddr_o),
        .noc_fifo_in_waddr_i         (noc_fifo_in_waddr_i),
        .noc_fifo_out_data_o         (noc_fifo_out_data_o),
        .noc_fifo_out_raddr_i        (noc_fifo_out_raddr_i),
        .noc_fifo_out_waddr_o        (noc_fifo_out_waddr_o),

        .c0_rld3_a                   (c0_rld3_a),
        .c0_rld3_ba                  (c0_rld3_ba),
        .c0_rld3_cs_n                (c0_rld3_cs_n),
        .c0_rld3_ck_p                (c0_rld3_ck_p),
        .c0_rld3_ck_n                (c0_rld3_ck_n),
        .c0_rld3_dk_p                (c0_rld3_dk_p),
        .c0_rld3_dk_n                (c0_rld3_dk_n),
        .c0_rld3_ref_n               (c0_rld3_ref_n),
        .c0_rld3_we_n                (c0_rld3_we_n),
        .c0_rld3_dq                  (c0_rld3_dq),
        .c0_rld3_dm                  (c0_rld3_dm),
        .c0_rld3_qk_p                (c0_rld3_qk_p),
        .c0_rld3_qk_n                (c0_rld3_qk_n),
        .c0_rld3_qvld                (c0_rld3_qvld),
        .c0_rld3_reset_n             (c0_rld3_reset_n)

    );


// util_reset_sync i_util_reset_sync_ref (
//     .clk_i             (ddr4_clk_i),
//     .reset_q_i         (~sys_rst),
//     .scan_mode_i       (1'b0),
//     .sync_reset_q_o    (ddr4_rst_n_s)
// );
//
//
// util_sync #(
//     .WIDTH     (NOC_CHIPID_SIZE)
// ) i_util_sync_chipid (
//     .clk_i     (ddr4_clk_i),
//     .reset_n_i (ddr4_rst_n_s),
//     .data_i    (home_chipid_i),
//     .data_o    (home_chipid_s)
// );


endmodule
