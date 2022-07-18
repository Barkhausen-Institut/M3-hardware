
module ddr4_domain #(
    `include "noc_parameter.vh"
    ,`include "ddr4_user_parameter.vh"
    ,parameter INST = "C1",
    parameter HOME_MODID = {NOC_MODID_SIZE{1'b0}},
    parameter SIMULATION = 0        //if enabled, DDR4 controller is removed and simple on-chip memory is connected
)
(
    input   wire                                  sys_clk_n,
    input   wire                                  sys_clk_p,
    input   wire            [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input   wire                                  sys_rst,
    input   wire                                  ddr4_clk_i,
    output  wire                                  ddr4_init_calib_complete_o,
    output  wire           [DDR4_STATUS_SIZE-1:0] ddr4_status_o,

    // NoC interface
    input	wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_in_data_i,
    output	wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_raddr_o,
    input	wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_waddr_i,
    output	wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_out_data_o,
    input	wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_raddr_i,
    output	wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_waddr_o,

    output  wire                                  ddr4_act_n,
    output  wire                           [16:0] ddr4_addr,
    output  wire                            [1:0] ddr4_ba,
    output  wire                                  ddr4_bg,
    output  wire                                  ddr4_cke,
    output  wire                                  ddr4_odt,
    output  wire                                  ddr4_cs_n,
    output  wire                                  ddr4_ck_t,
    output  wire                                  ddr4_ck_c,
    output  wire                                  ddr4_reset_n,
    inout   wire                            [9:0] ddr4_dm_dbi_n,
    inout   wire                           [79:0] ddr4_dq,
    inout   wire                            [9:0] ddr4_dqs_c,
    inout   wire                            [9:0] ddr4_dqs_t
);

    wire ddr4_rst_n_s;

    wire [NOC_CHIPID_SIZE-1:0] home_chipid_s;



ddr4_wrap #(
    .INST                        (INST),
    .HOME_MODID                  (HOME_MODID),
    .SIMULATION                  (SIMULATION)
) i_ddr4_wrap (
    .sys_clk_n                   (sys_clk_n),
    .sys_clk_p                   (sys_clk_p),
    .sys_rst                     (sys_rst),
    .home_chipid_i               (home_chipid_s),
    .ddr4_clk_i                  (ddr4_clk_i),
    .ddr4_rst_n_i                (ddr4_rst_n_s),
    .ddr4_init_calib_complete_o  (ddr4_init_calib_complete_o),
    .ddr4_status_o               (ddr4_status_o),

    .noc_fifo_in_data_i          (noc_fifo_in_data_i),
    .noc_fifo_in_raddr_o         (noc_fifo_in_raddr_o),
    .noc_fifo_in_waddr_i         (noc_fifo_in_waddr_i),
    .noc_fifo_out_data_o         (noc_fifo_out_data_o),
    .noc_fifo_out_raddr_i        (noc_fifo_out_raddr_i),
    .noc_fifo_out_waddr_o        (noc_fifo_out_waddr_o),

    .ddr4_act_n                  (ddr4_act_n),
    .ddr4_addr                   (ddr4_addr),
    .ddr4_ba                     (ddr4_ba),
    .ddr4_bg                     (ddr4_bg),
    .ddr4_cke                    (ddr4_cke),
    .ddr4_odt                    (ddr4_odt),
    .ddr4_cs_n                   (ddr4_cs_n),
    .ddr4_ck_t                   (ddr4_ck_t),
    .ddr4_ck_c                   (ddr4_ck_c),
    .ddr4_reset_n                (ddr4_reset_n),
    .ddr4_dm_dbi_n               (ddr4_dm_dbi_n),
    .ddr4_dq                     (ddr4_dq),
    .ddr4_dqs_c                  (ddr4_dqs_c),
    .ddr4_dqs_t                  (ddr4_dqs_t)
);



util_reset_sync i_util_reset_sync_ref (
    .clk_i             (ddr4_clk_i),
    .reset_q_i         (~sys_rst),
    .scan_mode_i       (1'b0),
    .sync_reset_q_o    (ddr4_rst_n_s)
);


util_sync #(
    .WIDTH     (NOC_CHIPID_SIZE)
) i_util_sync_chipid (
    .clk_i     (ddr4_clk_i),
    .reset_n_i (ddr4_rst_n_s),
    .data_i    (home_chipid_i),
    .data_o    (home_chipid_s)
);


endmodule
