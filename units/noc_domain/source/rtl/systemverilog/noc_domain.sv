
module noc_domain #(
    `include "noc_parameter.vh"
)
(
    input  wire                                   clk_noc_i,
    input  wire                                   reset_n_i,
    input  wire             [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile0_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile0_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile1_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile1_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile2_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile2_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile3_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile3_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile4_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile4_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile5_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile5_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile6_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile6_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile7_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile7_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile8_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile8_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile9_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile9_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile10_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile10_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile11_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile11_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_out_waddr_i
);


    wire reset_sync_n_s;

    wire [NOC_CHIPID_SIZE-1:0] home_chipid_s;


    // Tx NoC links: NoC -> Module
    noc_link_if noc_link_if_r0_tile0();
    noc_link_if noc_link_if_r0_tile1();
    noc_link_if noc_link_if_r0_tile2();
    noc_link_if noc_link_if_r1_tile3();
    noc_link_if noc_link_if_r1_tile4();
    noc_link_if noc_link_if_r1_tile5();
    noc_link_if noc_link_if_r2_tile6();
    noc_link_if noc_link_if_r2_tile7();
    noc_link_if noc_link_if_r2_tile8();
    noc_link_if noc_link_if_r3_tile9();
    noc_link_if noc_link_if_r3_tile10();
    noc_link_if noc_link_if_r3_tile11();

    // Rx NoC links: Module -> NoC
    noc_link_if noc_link_if_tile0_r0();
    noc_link_if noc_link_if_tile1_r0();
    noc_link_if noc_link_if_tile2_r0();
    noc_link_if noc_link_if_tile3_r1();
    noc_link_if noc_link_if_tile4_r1();
    noc_link_if noc_link_if_tile5_r1();
    noc_link_if noc_link_if_tile6_r2();
    noc_link_if noc_link_if_tile7_r2();
    noc_link_if noc_link_if_tile8_r2();
    noc_link_if noc_link_if_tile9_r3();
    noc_link_if noc_link_if_tile10_r3();
    noc_link_if noc_link_if_tile11_r3();



util_reset_sync i_util_reset_sync_ref (
    .clk_i              (clk_noc_i),
    .reset_q_i          (reset_n_i),
    .scan_mode_i        (1'b0),
    .sync_reset_q_o     (reset_sync_n_s)
);


util_sync #(
    .WIDTH     (NOC_CHIPID_SIZE)
) i_util_sync_chipid (
    .clk_i     (clk_noc_i),
    .reset_n_i (reset_sync_n_s),
    .data_i    (home_chipid_i),
    .data_o    (home_chipid_s)
);



onchip_network i_onchip_network (
    .clk_i                          (clk_noc_i),
    .reset_q_i                      (reset_sync_n_s),
    .home_chipid_i                  (home_chipid_s),
    .tile0_noc_fifo_in_data_o       (tile0_noc_fifo_in_data_o),
    .tile0_noc_fifo_in_raddr_i      (tile0_noc_fifo_in_raddr_i),
    .tile0_noc_fifo_in_waddr_o      (tile0_noc_fifo_in_waddr_o),
    .tile0_noc_fifo_out_data_i      (tile0_noc_fifo_out_data_i),
    .tile0_noc_fifo_out_raddr_o     (tile0_noc_fifo_out_raddr_o),
    .tile0_noc_fifo_out_waddr_i     (tile0_noc_fifo_out_waddr_i),
    .tile1_noc_fifo_in_data_o       (tile1_noc_fifo_in_data_o),
    .tile1_noc_fifo_in_raddr_i      (tile1_noc_fifo_in_raddr_i),
    .tile1_noc_fifo_in_waddr_o      (tile1_noc_fifo_in_waddr_o),
    .tile1_noc_fifo_out_data_i      (tile1_noc_fifo_out_data_i),
    .tile1_noc_fifo_out_raddr_o     (tile1_noc_fifo_out_raddr_o),
    .tile1_noc_fifo_out_waddr_i     (tile1_noc_fifo_out_waddr_i),
    .tile2_noc_fifo_in_data_o       (tile2_noc_fifo_in_data_o),
    .tile2_noc_fifo_in_raddr_i      (tile2_noc_fifo_in_raddr_i),
    .tile2_noc_fifo_in_waddr_o      (tile2_noc_fifo_in_waddr_o),
    .tile2_noc_fifo_out_data_i      (tile2_noc_fifo_out_data_i),
    .tile2_noc_fifo_out_raddr_o     (tile2_noc_fifo_out_raddr_o),
    .tile2_noc_fifo_out_waddr_i     (tile2_noc_fifo_out_waddr_i),
    .tile3_noc_fifo_in_data_o       (tile3_noc_fifo_in_data_o),
    .tile3_noc_fifo_in_raddr_i      (tile3_noc_fifo_in_raddr_i),
    .tile3_noc_fifo_in_waddr_o      (tile3_noc_fifo_in_waddr_o),
    .tile3_noc_fifo_out_data_i      (tile3_noc_fifo_out_data_i),
    .tile3_noc_fifo_out_raddr_o     (tile3_noc_fifo_out_raddr_o),
    .tile3_noc_fifo_out_waddr_i     (tile3_noc_fifo_out_waddr_i),
    .tile4_noc_fifo_in_data_o       (tile4_noc_fifo_in_data_o),
    .tile4_noc_fifo_in_raddr_i      (tile4_noc_fifo_in_raddr_i),
    .tile4_noc_fifo_in_waddr_o      (tile4_noc_fifo_in_waddr_o),
    .tile4_noc_fifo_out_data_i      (tile4_noc_fifo_out_data_i),
    .tile4_noc_fifo_out_raddr_o     (tile4_noc_fifo_out_raddr_o),
    .tile4_noc_fifo_out_waddr_i     (tile4_noc_fifo_out_waddr_i),
    .tile5_noc_fifo_in_data_o       (tile5_noc_fifo_in_data_o),
    .tile5_noc_fifo_in_raddr_i      (tile5_noc_fifo_in_raddr_i),
    .tile5_noc_fifo_in_waddr_o      (tile5_noc_fifo_in_waddr_o),
    .tile5_noc_fifo_out_data_i      (tile5_noc_fifo_out_data_i),
    .tile5_noc_fifo_out_raddr_o     (tile5_noc_fifo_out_raddr_o),
    .tile5_noc_fifo_out_waddr_i     (tile5_noc_fifo_out_waddr_i),
    .tile6_noc_fifo_in_data_o       (tile6_noc_fifo_in_data_o),
    .tile6_noc_fifo_in_raddr_i      (tile6_noc_fifo_in_raddr_i),
    .tile6_noc_fifo_in_waddr_o      (tile6_noc_fifo_in_waddr_o),
    .tile6_noc_fifo_out_data_i      (tile6_noc_fifo_out_data_i),
    .tile6_noc_fifo_out_raddr_o     (tile6_noc_fifo_out_raddr_o),
    .tile6_noc_fifo_out_waddr_i     (tile6_noc_fifo_out_waddr_i),
    .tile7_noc_fifo_in_data_o       (tile7_noc_fifo_in_data_o),
    .tile7_noc_fifo_in_raddr_i      (tile7_noc_fifo_in_raddr_i),
    .tile7_noc_fifo_in_waddr_o      (tile7_noc_fifo_in_waddr_o),
    .tile7_noc_fifo_out_data_i      (tile7_noc_fifo_out_data_i),
    .tile7_noc_fifo_out_raddr_o     (tile7_noc_fifo_out_raddr_o),
    .tile7_noc_fifo_out_waddr_i     (tile7_noc_fifo_out_waddr_i),
    .tile8_noc_fifo_in_data_o       (tile8_noc_fifo_in_data_o),
    .tile8_noc_fifo_in_raddr_i      (tile8_noc_fifo_in_raddr_i),
    .tile8_noc_fifo_in_waddr_o      (tile8_noc_fifo_in_waddr_o),
    .tile8_noc_fifo_out_data_i      (tile8_noc_fifo_out_data_i),
    .tile8_noc_fifo_out_raddr_o     (tile8_noc_fifo_out_raddr_o),
    .tile8_noc_fifo_out_waddr_i     (tile8_noc_fifo_out_waddr_i),
    .tile9_noc_fifo_in_data_o       (tile9_noc_fifo_in_data_o),
    .tile9_noc_fifo_in_raddr_i      (tile9_noc_fifo_in_raddr_i),
    .tile9_noc_fifo_in_waddr_o      (tile9_noc_fifo_in_waddr_o),
    .tile9_noc_fifo_out_data_i      (tile9_noc_fifo_out_data_i),
    .tile9_noc_fifo_out_raddr_o     (tile9_noc_fifo_out_raddr_o),
    .tile9_noc_fifo_out_waddr_i     (tile9_noc_fifo_out_waddr_i),
    .tile10_noc_fifo_in_data_o      (tile10_noc_fifo_in_data_o),
    .tile10_noc_fifo_in_raddr_i     (tile10_noc_fifo_in_raddr_i),
    .tile10_noc_fifo_in_waddr_o     (tile10_noc_fifo_in_waddr_o),
    .tile10_noc_fifo_out_data_i     (tile10_noc_fifo_out_data_i),
    .tile10_noc_fifo_out_raddr_o    (tile10_noc_fifo_out_raddr_o),
    .tile10_noc_fifo_out_waddr_i    (tile10_noc_fifo_out_waddr_i),
    .tile11_noc_fifo_in_data_o      (tile11_noc_fifo_in_data_o),
    .tile11_noc_fifo_in_raddr_i     (tile11_noc_fifo_in_raddr_i),
    .tile11_noc_fifo_in_waddr_o     (tile11_noc_fifo_in_waddr_o),
    .tile11_noc_fifo_out_data_i     (tile11_noc_fifo_out_data_i),
    .tile11_noc_fifo_out_raddr_o    (tile11_noc_fifo_out_raddr_o),
    .tile11_noc_fifo_out_waddr_i    (tile11_noc_fifo_out_waddr_i)
);


endmodule
