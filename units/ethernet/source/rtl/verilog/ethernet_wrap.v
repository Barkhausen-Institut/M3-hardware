
module ethernet_wrap #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,`include "mod_ids.vh"
    ,parameter NOC_FLIT_SIZE  = (NOC_PAYLOAD_SIZE + NOC_HEADER_SIZE),
    parameter HOST_IP         = {8'd192, 8'd168, 8'd42, 8'd25},
    parameter HOST_PORT       = 16'd1800,
    parameter FPGA_IP_BASE    = {8'd192, 8'd168, 8'd42, 8'd240},
    parameter FPGA_PORT       = 16'd1800,
    parameter GATEWAY_IP_ADDR = {8'd192, 8'd168, 8'd42, 8'd1},
    parameter SUBNET_MASK     = {8'd255, 8'd255, 8'd255, 8'd0},
    parameter HOME_MODID      = {NOC_MODID_SIZE{1'b0}}
)
(
    input  wire                                  clk_eth_i,
    input  wire                                  rst_eth_n_i,

    input  wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_in_data_i,
    output wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_raddr_o,
    input  wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_waddr_i,
    output wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_out_data_o,
    input  wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_raddr_i,
    output wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_waddr_o,

    //GMII
    input  wire                                  gmii_clk,
    input  wire                                  gmii_rst,
    input  wire                                  gmii_clk_en,
    output wire                            [7:0] gmii_txd,
    output wire                                  gmii_tx_en,
    output wire                                  gmii_tx_er,
    input  wire                            [7:0] gmii_rxd,
    input  wire                                  gmii_rx_dv,
    input  wire                                  gmii_rx_er,

    input  wire                           [15:0] eth_status_vector_i,
    output wire                           [31:0] eth_config_vector_o,
    input  wire                                  eth_an_complete_i,
    input  wire                            [1:0] eth_pll_lock_i,
    output wire                                  eth_system_reset_o,

    input  wire                           [31:0] fpga_ip_addr_i,
    input  wire                           [47:0] fpga_mac_addr_i,

    input  wire            [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    output wire            [NOC_CHIPID_SIZE-1:0] host_chipid_o
);


// NoC signals between noc_link_phy and NoCIF
wire     [NOC_PAYLOAD_SIZE-1:0] noc_rx_payload_s;
wire      [NOC_HEADER_SIZE-1:0] noc_rx_header_s;
wire     [NOC_PAYLOAD_SIZE-1:0] noc_tx_payload_s;
wire      [NOC_HEADER_SIZE-1:0] noc_tx_header_s;

wire                            noc_rx_fifo_empty;
wire                            noc_tx_fifo_full;
wire                            noc_rx_read_en;
wire                            noc_tx_data_valid;

wire        [NOC_ADDR_SIZE-1:0] noc_rx_mod_addr_s;
wire                            noc_rx_mod_burst_s;
wire                            noc_rx_mod_arq_s;
wire        [NOC_BSEL_SIZE-1:0] noc_rx_mod_bsel_s;
wire        [NOC_DATA_SIZE-1:0] noc_rx_mod_data0_s;
wire        [NOC_DATA_SIZE-1:0] noc_rx_mod_data1_s;
wire        [NOC_MODE_SIZE-1:0] noc_rx_mod_mode_s;
wire                            noc_rx_mod_stall_s;
wire                            noc_rx_mod_wrreq_s;
wire    [CHIP_X_COORD_SIZE-1:0] noc_rx_src_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] noc_rx_src_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] noc_rx_src_chip_z_coord_s;
wire      [NOC_CHIPID_SIZE-1:0] noc_rx_src_chipid_s;
wire     [MOD_X_COORD_SIZE-1:0] noc_rx_src_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] noc_rx_src_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] noc_rx_src_mod_z_coord_s;
wire       [NOC_MODID_SIZE-1:0] noc_rx_src_modid_s;
wire    [CHIP_X_COORD_SIZE-1:0] noc_rx_trg_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] noc_rx_trg_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] noc_rx_trg_chip_z_coord_s;
wire      [NOC_CHIPID_SIZE-1:0] noc_rx_trg_chipid_s;
wire     [MOD_X_COORD_SIZE-1:0] noc_rx_trg_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] noc_rx_trg_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] noc_rx_trg_mod_z_coord_s;
wire       [NOC_MODID_SIZE-1:0] noc_rx_trg_modid_s;

wire        [NOC_ADDR_SIZE-1:0] noc_tx_mod_addr_s;
wire                            noc_tx_mod_burst_s;
wire                            noc_tx_mod_arq_s;
wire        [NOC_BSEL_SIZE-1:0] noc_tx_mod_bsel_s;
wire        [NOC_DATA_SIZE-1:0] noc_tx_mod_data0_s;
wire        [NOC_DATA_SIZE-1:0] noc_tx_mod_data1_s;
wire        [NOC_MODE_SIZE-1:0] noc_tx_mod_mode_s;
wire                            noc_tx_mod_stall_s;
wire                            noc_tx_mod_wrreq_s;
wire    [CHIP_X_COORD_SIZE-1:0] noc_tx_src_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] noc_tx_src_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] noc_tx_src_chip_z_coord_s;
wire      [NOC_CHIPID_SIZE-1:0] noc_tx_src_chipid_s;
wire     [MOD_X_COORD_SIZE-1:0] noc_tx_src_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] noc_tx_src_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] noc_tx_src_mod_z_coord_s;
wire       [NOC_MODID_SIZE-1:0] noc_tx_src_modid_s;
wire    [CHIP_X_COORD_SIZE-1:0] noc_tx_trg_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] noc_tx_trg_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] noc_tx_trg_chip_z_coord_s;
wire      [NOC_CHIPID_SIZE-1:0] noc_tx_trg_chipid_s;
wire     [MOD_X_COORD_SIZE-1:0] noc_tx_trg_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] noc_tx_trg_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] noc_tx_trg_mod_z_coord_s;
wire       [NOC_MODID_SIZE-1:0] noc_tx_trg_modid_s;

//reg config signals
wire                            eth_config_en;
wire    [TCU_REG_BSEL_SIZE-1:0] eth_config_wben;
wire    [TCU_REG_ADDR_SIZE-1:0] eth_config_addr;
wire    [TCU_REG_DATA_SIZE-1:0] eth_config_wdata;
wire    [TCU_REG_DATA_SIZE-1:0] eth_config_rdata;


//status flag
wire      [TCU_STATUS_SIZE-1:0] tcu_status;

wire                     [31:0] rx_udp_error;
wire                     [31:0] udp_status;
wire                     [31:0] mac_status;

reg                             trigger_system_reset;
reg                             set_host_ip;

wire                     [31:0] host_ip_addr;
wire                     [31:0] rx_udp_source_ip;
wire                     [15:0] host_port;
wire      [NOC_CHIPID_SIZE-1:0] host_chipid;
wire                     [15:0] fpga_port;


// signals between udp_noc_bridge and async_fifos
wire     [NOC_PAYLOAD_SIZE-1:0] eth_rx_payload_s;
wire      [NOC_HEADER_SIZE-1:0] eth_rx_header_s;
wire     [NOC_PAYLOAD_SIZE-1:0] eth_tx_payload_s;
wire      [NOC_HEADER_SIZE-1:0] eth_tx_header_s;

wire        [NOC_FLIT_SIZE-1:0] eth_rx_data;
wire                            eth_rx_read_en;
wire                            eth_rx_flit_avail_q;
wire        [NOC_FLIT_SIZE-1:0] eth_tx_data;
wire                            eth_tx_stall;
wire                            eth_tx_data_valid;

wire        [NOC_ADDR_SIZE-1:0] eth_rx_mod_addr_s;
wire                            eth_rx_mod_burst_s;
wire                            eth_rx_mod_arq_s;
wire        [NOC_BSEL_SIZE-1:0] eth_rx_mod_bsel_s;
wire        [NOC_DATA_SIZE-1:0] eth_rx_mod_data0_s;
wire        [NOC_DATA_SIZE-1:0] eth_rx_mod_data1_s;
wire        [NOC_MODE_SIZE-1:0] eth_rx_mod_mode_s;
wire                            eth_rx_mod_stall_s;
wire                            eth_rx_mod_wrreq_s;
wire    [CHIP_X_COORD_SIZE-1:0] eth_rx_src_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] eth_rx_src_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] eth_rx_src_chip_z_coord_s;
wire      [NOC_CHIPID_SIZE-1:0] eth_rx_src_chipid_s;
wire     [MOD_X_COORD_SIZE-1:0] eth_rx_src_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] eth_rx_src_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] eth_rx_src_mod_z_coord_s;
wire       [NOC_MODID_SIZE-1:0] eth_rx_src_modid_s;
wire    [CHIP_X_COORD_SIZE-1:0] eth_rx_trg_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] eth_rx_trg_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] eth_rx_trg_chip_z_coord_s;
wire      [NOC_CHIPID_SIZE-1:0] eth_rx_trg_chipid_s;
wire     [MOD_X_COORD_SIZE-1:0] eth_rx_trg_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] eth_rx_trg_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] eth_rx_trg_mod_z_coord_s;
wire       [NOC_MODID_SIZE-1:0] eth_rx_trg_modid_s;

wire        [NOC_ADDR_SIZE-1:0] eth_tx_mod_addr_s;
wire                            eth_tx_mod_burst_s;
wire                            eth_tx_mod_arq_s;
wire        [NOC_BSEL_SIZE-1:0] eth_tx_mod_bsel_s;
wire        [NOC_DATA_SIZE-1:0] eth_tx_mod_data0_s;
wire        [NOC_DATA_SIZE-1:0] eth_tx_mod_data1_s;
wire        [NOC_MODE_SIZE-1:0] eth_tx_mod_mode_s;
wire                            eth_tx_mod_stall_s;
wire                            eth_tx_mod_wrreq_s;
wire    [CHIP_X_COORD_SIZE-1:0] eth_tx_src_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] eth_tx_src_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] eth_tx_src_chip_z_coord_s;
wire      [NOC_CHIPID_SIZE-1:0] eth_tx_src_chipid_s;
wire     [MOD_X_COORD_SIZE-1:0] eth_tx_src_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] eth_tx_src_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] eth_tx_src_mod_z_coord_s;
wire       [NOC_MODID_SIZE-1:0] eth_tx_src_modid_s;
wire    [CHIP_X_COORD_SIZE-1:0] eth_tx_trg_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] eth_tx_trg_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] eth_tx_trg_chip_z_coord_s;
wire      [NOC_CHIPID_SIZE-1:0] eth_tx_trg_chipid_s;
wire     [MOD_X_COORD_SIZE-1:0] eth_tx_trg_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] eth_tx_trg_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] eth_tx_trg_mod_z_coord_s;
wire       [NOC_MODID_SIZE-1:0] eth_tx_trg_modid_s;




noc_link_par_phy #(
    .NOC_ASYNC_FIFO_AWIDTH(NOC_ASYNC_FIFO_AWIDTH),
    .NOC_ASYNC_FIFO_PACKET_SIZE(NOC_ASYNC_FIFO_PACKET_SIZE)
) i_noc_link_par_phy (
    .clk_i                  (clk_eth_i),
    .rst_q_i                (rst_eth_n_i),
    .rx_fifo_empty_o        (noc_rx_fifo_empty),
    .rx_fifo_read_addr_o    (noc_fifo_in_raddr_o),
    .rx_fifo_read_data_i    (noc_fifo_in_data_i),
    .rx_fifo_write_addr_i   (noc_fifo_in_waddr_i),
    .rx_header_o            (noc_rx_header_s),
    .rx_payload_o           (noc_rx_payload_s),
    .rx_rdreq_i             (noc_rx_read_en),
    .testmode_i             (1'b0),
    .tx_fifo_read_addr_i    (noc_fifo_out_raddr_i),
    .tx_fifo_read_data_o    (noc_fifo_out_data_o),
    .tx_fifo_write_addr_o   (noc_fifo_out_waddr_o),
    .tx_header_i            (noc_tx_header_s),
    .tx_payload_i           (noc_tx_payload_s),
    .tx_stall_o             (noc_tx_fifo_full),
    .tx_wrreq_i             (noc_tx_data_valid)
);


nocif i_nocif_noc (
    .clk_i                  (clk_eth_i),
    .flit_avail_q_i         (noc_rx_fifo_empty),
    .header_i               (noc_rx_header_s),
    .header_o               (noc_tx_header_s),
    .mod_addr_i             (noc_tx_mod_addr_s),
    .mod_addr_o             (noc_rx_mod_addr_s),
    .mod_burst_i            (noc_tx_mod_burst_s),
    .mod_burst_o            (noc_rx_mod_burst_s),
    .mod_arq_i              (noc_tx_mod_arq_s),
    .mod_arq_o              (noc_rx_mod_arq_s),
    .mod_bsel_i             (noc_tx_mod_bsel_s),
    .mod_bsel_o             (noc_rx_mod_bsel_s),
    .mod_data0_i            (noc_tx_mod_data0_s),
    .mod_data0_o            (noc_rx_mod_data0_s),
    .mod_data1_i            (noc_tx_mod_data1_s),
    .mod_data1_o            (noc_rx_mod_data1_s),
    .mod_mode_i             (noc_tx_mod_mode_s),
    .mod_mode_o             (noc_rx_mod_mode_s),
    .mod_stall_i            (noc_rx_mod_stall_s),
    .mod_stall_o            (noc_tx_mod_stall_s),
    .mod_wrreq_i            (noc_tx_mod_wrreq_s),
    .mod_wrreq_o            (noc_rx_mod_wrreq_s),
    .payload_i              (noc_rx_payload_s),
    .payload_o              (noc_tx_payload_s),
    .rdreq_o                (noc_rx_read_en),
    .reset_q_i              (rst_eth_n_i),
    .src_chip_x_coord_i     (noc_tx_src_chip_x_coord_s),
    .src_chip_x_coord_o     (noc_rx_src_chip_x_coord_s),
    .src_chip_y_coord_i     (noc_tx_src_chip_y_coord_s),
    .src_chip_y_coord_o     (noc_rx_src_chip_y_coord_s),
    .src_chip_z_coord_i     (noc_tx_src_chip_z_coord_s),
    .src_chip_z_coord_o     (noc_rx_src_chip_z_coord_s),
    .src_mod_x_coord_i      (noc_tx_src_mod_x_coord_s),
    .src_mod_x_coord_o      (noc_rx_src_mod_x_coord_s),
    .src_mod_y_coord_i      (noc_tx_src_mod_y_coord_s),
    .src_mod_y_coord_o      (noc_rx_src_mod_y_coord_s),
    .src_mod_z_coord_i      (noc_tx_src_mod_z_coord_s),
    .src_mod_z_coord_o      (noc_rx_src_mod_z_coord_s),
    .stall_i                (noc_tx_fifo_full),
    .trg_chip_x_coord_i     (noc_tx_trg_chip_x_coord_s),
    .trg_chip_x_coord_o     (noc_rx_trg_chip_x_coord_s),
    .trg_chip_y_coord_i     (noc_tx_trg_chip_y_coord_s),
    .trg_chip_y_coord_o     (noc_rx_trg_chip_y_coord_s),
    .trg_chip_z_coord_i     (noc_tx_trg_chip_z_coord_s),
    .trg_chip_z_coord_o     (noc_rx_trg_chip_z_coord_s),
    .trg_mod_x_coord_i      (noc_tx_trg_mod_x_coord_s),
    .trg_mod_x_coord_o      (noc_rx_trg_mod_x_coord_s),
    .trg_mod_y_coord_i      (noc_tx_trg_mod_y_coord_s),
    .trg_mod_y_coord_o      (noc_rx_trg_mod_y_coord_s),
    .trg_mod_z_coord_i      (noc_tx_trg_mod_z_coord_s),
    .trg_mod_z_coord_o      (noc_rx_trg_mod_z_coord_s),
    .wrreq_o                (noc_tx_data_valid)
);

assign noc_rx_src_chipid_s = {noc_rx_src_chip_x_coord_s, noc_rx_src_chip_y_coord_s, noc_rx_src_chip_z_coord_s};
assign noc_rx_src_modid_s = {noc_rx_src_mod_x_coord_s, noc_rx_src_mod_y_coord_s, noc_rx_src_mod_z_coord_s};
assign noc_rx_trg_chipid_s = {noc_rx_trg_chip_x_coord_s, noc_rx_trg_chip_y_coord_s, noc_rx_trg_chip_z_coord_s};
assign noc_rx_trg_modid_s = {noc_rx_trg_mod_x_coord_s, noc_rx_trg_mod_y_coord_s, noc_rx_trg_mod_z_coord_s};

assign {noc_tx_src_chip_x_coord_s, noc_tx_src_chip_y_coord_s, noc_tx_src_chip_z_coord_s} = noc_tx_src_chipid_s;
assign {noc_tx_src_mod_x_coord_s, noc_tx_src_mod_y_coord_s, noc_tx_src_mod_z_coord_s} = noc_tx_src_modid_s;
assign {noc_tx_trg_chip_x_coord_s, noc_tx_trg_chip_y_coord_s, noc_tx_trg_chip_z_coord_s} = noc_tx_trg_chipid_s;
assign {noc_tx_trg_mod_x_coord_s, noc_tx_trg_mod_y_coord_s, noc_tx_trg_mod_z_coord_s} = noc_tx_trg_modid_s;



nocif_slave i_nocif_eth (
    .clk_i                  (clk_eth_i),
    .reset_q_i              (rst_eth_n_i),
    .flit_avail_q_o         (eth_rx_flit_avail_q),
    .rdreq_i                (eth_rx_read_en),
    .wrreq_i                (eth_tx_data_valid),
    .stall_o                (eth_tx_stall),
    .header_i               (eth_tx_header_s),
    .header_o               (eth_rx_header_s),
    .payload_i              (eth_tx_payload_s),
    .payload_o              (eth_rx_payload_s),
    .mod_addr_i             (eth_rx_mod_addr_s),
    .mod_addr_o             (eth_tx_mod_addr_s),
    .mod_burst_i            (eth_rx_mod_burst_s),
    .mod_burst_o            (eth_tx_mod_burst_s),
    .mod_arq_i              (eth_rx_mod_arq_s),
    .mod_arq_o              (eth_tx_mod_arq_s),
    .mod_bsel_i             (eth_rx_mod_bsel_s),
    .mod_bsel_o             (eth_tx_mod_bsel_s),
    .mod_data0_i            (eth_rx_mod_data0_s),
    .mod_data0_o            (eth_tx_mod_data0_s),
    .mod_data1_i            (eth_rx_mod_data1_s),
    .mod_data1_o            (eth_tx_mod_data1_s),
    .mod_mode_i             (eth_rx_mod_mode_s),
    .mod_mode_o             (eth_tx_mod_mode_s),
    .mod_stall_i            (eth_tx_mod_stall_s),
    .mod_stall_o            (eth_rx_mod_stall_s),
    .mod_wrreq_i            (eth_rx_mod_wrreq_s),
    .mod_wrreq_o            (eth_tx_mod_wrreq_s),
    .src_chip_x_coord_i     (eth_rx_src_chip_x_coord_s),
    .src_chip_x_coord_o     (eth_tx_src_chip_x_coord_s),
    .src_chip_y_coord_i     (eth_rx_src_chip_y_coord_s),
    .src_chip_y_coord_o     (eth_tx_src_chip_y_coord_s),
    .src_chip_z_coord_i     (eth_rx_src_chip_z_coord_s),
    .src_chip_z_coord_o     (eth_tx_src_chip_z_coord_s),
    .src_mod_x_coord_i      (eth_rx_src_mod_x_coord_s),
    .src_mod_x_coord_o      (eth_tx_src_mod_x_coord_s),
    .src_mod_y_coord_i      (eth_rx_src_mod_y_coord_s),
    .src_mod_y_coord_o      (eth_tx_src_mod_y_coord_s),
    .src_mod_z_coord_i      (eth_rx_src_mod_z_coord_s),
    .src_mod_z_coord_o      (eth_tx_src_mod_z_coord_s),
    .trg_chip_x_coord_i     (eth_rx_trg_chip_x_coord_s),
    .trg_chip_x_coord_o     (eth_tx_trg_chip_x_coord_s),
    .trg_chip_y_coord_i     (eth_rx_trg_chip_y_coord_s),
    .trg_chip_y_coord_o     (eth_tx_trg_chip_y_coord_s),
    .trg_chip_z_coord_i     (eth_rx_trg_chip_z_coord_s),
    .trg_chip_z_coord_o     (eth_tx_trg_chip_z_coord_s),
    .trg_mod_x_coord_i      (eth_rx_trg_mod_x_coord_s),
    .trg_mod_x_coord_o      (eth_tx_trg_mod_x_coord_s),
    .trg_mod_y_coord_i      (eth_rx_trg_mod_y_coord_s),
    .trg_mod_y_coord_o      (eth_tx_trg_mod_y_coord_s),
    .trg_mod_z_coord_i      (eth_rx_trg_mod_z_coord_s),
    .trg_mod_z_coord_o      (eth_tx_trg_mod_z_coord_s)
);


assign eth_tx_src_chipid_s = {eth_tx_src_chip_x_coord_s, eth_tx_src_chip_y_coord_s, eth_tx_src_chip_z_coord_s};
assign eth_tx_src_modid_s = {eth_tx_src_mod_x_coord_s, eth_tx_src_mod_y_coord_s, eth_tx_src_mod_z_coord_s};
assign eth_tx_trg_chipid_s = {eth_tx_trg_chip_x_coord_s, eth_tx_trg_chip_y_coord_s, eth_tx_trg_chip_z_coord_s};
assign eth_tx_trg_modid_s = {eth_tx_trg_mod_x_coord_s, eth_tx_trg_mod_y_coord_s, eth_tx_trg_mod_z_coord_s};

assign {eth_rx_src_chip_x_coord_s, eth_rx_src_chip_y_coord_s, eth_rx_src_chip_z_coord_s} = eth_rx_src_chipid_s;
assign {eth_rx_src_mod_x_coord_s, eth_rx_src_mod_y_coord_s, eth_rx_src_mod_z_coord_s} = eth_rx_src_modid_s;
assign {eth_rx_trg_chip_x_coord_s, eth_rx_trg_chip_y_coord_s, eth_rx_trg_chip_z_coord_s} = eth_rx_trg_chipid_s;
assign {eth_rx_trg_mod_x_coord_s, eth_rx_trg_mod_y_coord_s, eth_rx_trg_mod_z_coord_s} = eth_rx_trg_modid_s;

assign eth_tx_header_s = eth_tx_data[NOC_FLIT_SIZE-1:NOC_PAYLOAD_SIZE];
assign eth_tx_payload_s = eth_tx_data[NOC_PAYLOAD_SIZE-1:0];

assign eth_rx_data = {eth_rx_header_s, eth_rx_payload_s};



tcu_top #(
    .TCU_ENABLE_CMDS            (0),
    .TCU_ENABLE_DRAM            (0),
    .HOME_MODID                 (HOME_MODID),
    .CLKFREQ_MHZ                (125),
    .NOCMUX_TX_IF1_PRIO         (0),
    .NOCMUX_RX_IF1_PRIO         (1),
    .NOCMUX_RX_IF1_ADDR_START   (32'hF0000000),        //IF1 only takes packets to regs from this chip
    .NOCMUX_RX_IF1_ADDR_END     (32'hFFFFFFFF),
    .NOCMUX_RX_IF1_ONLY_MODE_2  (0),
    .NOCMUX_RX_IF1_ONLY_HOMECHIP(1),
    .NOCMUX_RX_IF2_ADDR_START   (32'h0),               //IF2 connects to Ethernet and takes all packets
    .NOCMUX_RX_IF2_ADDR_END     (32'hFFFFFFFF),
    .NOCMUX_RX_IF2_ONLY_MODE_2  (0),
    .NOCMUX_RX_IF2_ONLY_HOMECHIP(0)
) i_tcu_top (
    .clk_i                      (clk_eth_i),
    .reset_n_i                  (rst_eth_n_i),

    .tcu_noc_rx_wrreq_i         (noc_rx_mod_wrreq_s),
    .tcu_noc_rx_burst_i         (noc_rx_mod_burst_s),
    .tcu_noc_rx_arq_i           (noc_rx_mod_arq_s),
    .tcu_noc_rx_bsel_i          (noc_rx_mod_bsel_s),
    .tcu_noc_rx_src_chipid_i    (noc_rx_src_chipid_s),
    .tcu_noc_rx_src_modid_i     (noc_rx_src_modid_s),
    .tcu_noc_rx_trg_chipid_i    (noc_rx_trg_chipid_s),
    .tcu_noc_rx_trg_modid_i     (noc_rx_trg_modid_s),
    .tcu_noc_rx_mode_i          (noc_rx_mod_mode_s),
    .tcu_noc_rx_addr_i          (noc_rx_mod_addr_s),
    .tcu_noc_rx_data0_i         (noc_rx_mod_data0_s),
    .tcu_noc_rx_data1_i         (noc_rx_mod_data1_s),
    .tcu_noc_rx_stall_o         (noc_rx_mod_stall_s),

    .tcu_noc_tx_wrreq_o         (noc_tx_mod_wrreq_s),
    .tcu_noc_tx_burst_o         (noc_tx_mod_burst_s),
    .tcu_noc_tx_arq_o           (noc_tx_mod_arq_s),
    .tcu_noc_tx_bsel_o          (noc_tx_mod_bsel_s),
    .tcu_noc_tx_src_chipid_o    (noc_tx_src_chipid_s),
    .tcu_noc_tx_src_modid_o     (noc_tx_src_modid_s),
    .tcu_noc_tx_trg_chipid_o    (noc_tx_trg_chipid_s),
    .tcu_noc_tx_trg_modid_o     (noc_tx_trg_modid_s),
    .tcu_noc_tx_mode_o          (noc_tx_mod_mode_s),
    .tcu_noc_tx_addr_o          (noc_tx_mod_addr_s),
    .tcu_noc_tx_data0_o         (noc_tx_mod_data0_s),
    .tcu_noc_tx_data1_o         (noc_tx_mod_data1_s),
    .tcu_noc_tx_stall_i         (noc_tx_mod_stall_s),

    .tcu_byp_noc_tx_wrreq_i     (eth_tx_mod_wrreq_s),
    .tcu_byp_noc_tx_burst_i     (eth_tx_mod_burst_s),
    .tcu_byp_noc_tx_arq_i       (eth_tx_mod_arq_s),
    .tcu_byp_noc_tx_bsel_i      (eth_tx_mod_bsel_s),
    .tcu_byp_noc_tx_src_chipid_i(eth_tx_src_chipid_s),
    .tcu_byp_noc_tx_src_modid_i (eth_tx_src_modid_s),
    .tcu_byp_noc_tx_trg_chipid_i(eth_tx_trg_chipid_s),
    .tcu_byp_noc_tx_trg_modid_i (eth_tx_trg_modid_s),
    .tcu_byp_noc_tx_mode_i      (eth_tx_mod_mode_s),
    .tcu_byp_noc_tx_addr_i      (eth_tx_mod_addr_s),
    .tcu_byp_noc_tx_data0_i     (eth_tx_mod_data0_s),
    .tcu_byp_noc_tx_data1_i     (eth_tx_mod_data1_s),
    .tcu_byp_noc_tx_stall_o     (eth_tx_mod_stall_s),

    .tcu_byp_noc_rx_wrreq_o     (eth_rx_mod_wrreq_s),
    .tcu_byp_noc_rx_burst_o     (eth_rx_mod_burst_s),
    .tcu_byp_noc_rx_arq_o       (eth_rx_mod_arq_s),
    .tcu_byp_noc_rx_bsel_o      (eth_rx_mod_bsel_s),
    .tcu_byp_noc_rx_src_chipid_o(eth_rx_src_chipid_s),
    .tcu_byp_noc_rx_src_modid_o (eth_rx_src_modid_s),
    .tcu_byp_noc_rx_trg_chipid_o(eth_rx_trg_chipid_s),
    .tcu_byp_noc_rx_trg_modid_o (eth_rx_trg_modid_s),
    .tcu_byp_noc_rx_mode_o      (eth_rx_mod_mode_s),
    .tcu_byp_noc_rx_addr_o      (eth_rx_mod_addr_s),
    .tcu_byp_noc_rx_data0_o     (eth_rx_mod_data0_s),
    .tcu_byp_noc_rx_data1_o     (eth_rx_mod_data1_s),
    .tcu_byp_noc_rx_stall_i     (eth_rx_mod_stall_s),

    .core_dmem_in_en_i          (1'b0),    //unused
    .core_dmem_in_wben_i        (4'h0),
    .core_dmem_in_addr_i        (32'h0),
    .core_dmem_in_wdata_i       (32'h0),
    .core_dmem_in_rdata_o       (),
    .core_dmem_in_stall_o       (),

    .core_imem_in_en_i          (1'b0),    //unused
    .core_imem_in_wben_i        (4'h0),
    .core_imem_in_addr_i        (32'h0),
    .core_imem_in_wdata_i       (32'h0),
    .core_imem_in_rdata_o       (),
    .core_imem_in_stall_o       (),

    .core_dmem_out_en_o         (),  //unused
    .core_dmem_out_wben_o       (),
    .core_dmem_out_addr_o       (),
    .core_dmem_out_wdata_o      (),
    .core_dmem_out_rdata_i      (128'h0),
    .core_dmem_out_stall_i      (1'b0),

    .core_imem_out_en_o         (), //unused
    .core_imem_out_wben_o       (),
    .core_imem_out_addr_o       (),
    .core_imem_out_wdata_o      (),
    .core_imem_out_rdata_i      (128'h0),
    .core_imem_out_stall_i      (1'b0),

    .tcu_dmem_en_o              (), //unused
    .tcu_dmem_req_o             (),
    .tcu_dmem_wben_o            (),
    .tcu_dmem_addr_o            (),
    .tcu_dmem_wdata_o           (),
    .tcu_dmem_rdata_i           (128'h0),
    .tcu_dmem_rdata_avail_i     (1'b0),
    .tcu_dmem_wdata_infifo_i    (1'b0),
    .tcu_dmem_wabort_o          (),
    .tcu_dmem_wstall_i          (1'b0),
    .tcu_dmem_rstall_i          (1'b0),

    .tcu_imem_en_o              (),  //unused
    .tcu_imem_req_o             (),
    .tcu_imem_wben_o            (),
    .tcu_imem_addr_o            (),
    .tcu_imem_wdata_o           (),
    .tcu_imem_rdata_i           (128'h0),
    .tcu_imem_rdata_avail_i     (1'b0),
    .tcu_imem_wdata_infifo_i    (1'b0),
    .tcu_imem_wabort_o          (),
    .tcu_imem_wstall_i          (1'b0),
    .tcu_imem_rstall_i          (1'b0),

    .config_mem_en_o            (eth_config_en),
    .config_mem_wben_o          (eth_config_wben),
    .config_mem_addr_o          (eth_config_addr),
    .config_mem_wdata_o         (eth_config_wdata),
    .config_mem_rdata_i         (eth_config_rdata),

    .tcu_status_o               (tcu_status),

    .home_chipid_i              (home_chipid_i),

    .print_chipid_i             (host_chipid),
    .print_modid_i              (MODID_ETH)
);


ethernet_regfile #(
    .HOST_IP                    (HOST_IP),
    .HOST_PORT                  (HOST_PORT),
    .FPGA_PORT                  (FPGA_PORT)
) i_ethernet_regfile (
    .clk_i                      (clk_eth_i),
    .reset_n_i                  (rst_eth_n_i),

    .config_en_i                (eth_config_en),
    .config_wben_i              (eth_config_wben),
    .config_addr_i              (eth_config_addr),
    .config_wdata_i             (eth_config_wdata),
    .config_rdata_o             (eth_config_rdata),

    .trigger_system_reset_i     (trigger_system_reset),
    .eth_system_reset_o         (eth_system_reset_o),
    .eth_status_vector_i        (eth_status_vector_i),
    .eth_config_vector_o        (eth_config_vector_o),
    .eth_an_complete_i          (eth_an_complete_i),
    .eth_pll_lock_i             (eth_pll_lock_i),
    .udp_status_i               (udp_status),
    .rx_udp_error_i             (rx_udp_error),
    .mac_status_i               (mac_status),
    .fpga_ip_addr_i             (fpga_ip_addr_i),
    .fpga_port_o                (fpga_port),
    .fpga_mac_addr_i            (fpga_mac_addr_i),
    .set_host_ip_i              (set_host_ip),
    .host_ip_addr_i             (rx_udp_source_ip),
    .host_ip_addr_o             (host_ip_addr),
    .host_port_o                (host_port),
    .host_chipid_o              (host_chipid)
);

assign host_chipid_o = host_chipid;


ethernet_udp_wrap #(
    .FPGA_IP_BASE        (FPGA_IP_BASE)
) i_ethernet_udp_wrap (
    .clk_eth_i           (clk_eth_i),
    .rst_eth_n_i         (rst_eth_n_i),

    //NoC interface
    .noc_rx_fifo_empty_i (eth_rx_flit_avail_q),
    .noc_rx_read_en_o    (eth_rx_read_en),
    .noc_rx_data_i       (eth_rx_data),
    .noc_tx_fifo_full_i  (eth_tx_stall),
    .noc_tx_data_valid_o (eth_tx_data_valid),
    .noc_tx_data_o       (eth_tx_data),

    //GMII
    .gmii_clk            (gmii_clk),
    .gmii_rst            (gmii_rst),
    .gmii_clk_en         (gmii_clk_en),
    .gmii_txd            (gmii_txd),
    .gmii_tx_en          (gmii_tx_en),
    .gmii_tx_er          (gmii_tx_er),
    .gmii_rxd            (gmii_rxd),
    .gmii_rx_dv          (gmii_rx_dv),
    .gmii_rx_er          (gmii_rx_er),

    //Ethernet addr
    .fpga_port_i         (fpga_port),
    .fpga_ip_addr_i      (fpga_ip_addr_i),
    .fpga_mac_addr_i     (fpga_mac_addr_i),
    .host_port_i         (host_port),
    .host_ip_addr_i      (host_ip_addr),
    .host_chipid_i       (host_chipid),
    .rx_udp_source_ip_o  (rx_udp_source_ip),
    .gateway_ip_addr_i   (GATEWAY_IP_ADDR),
    .subnet_mask_i       (SUBNET_MASK),

    .udp_status_o        (udp_status),
    .rx_udp_error_o      (rx_udp_error),
    .mac_status_o        (mac_status)
);


//listen to special ethernet packets
always @* begin
    trigger_system_reset = 1'b0;
    set_host_ip = 1'b0;

    //ethernet reset
    if (eth_tx_data_valid &&
        (eth_tx_mod_burst_s == 1'b0) &&
        (eth_tx_trg_modid_s == HOME_MODID) &&
        (eth_tx_trg_chipid_s == home_chipid_i) &&
        (eth_tx_mod_mode_s == MODE_WRITE_POSTED) &&
        (eth_tx_mod_addr_s == 32'hF0003028) &&
        (eth_tx_mod_data0_s == 'h1)) begin
        trigger_system_reset = 1'b1;
    end

    //magic flit from self test automatically sets host IP
    else if (eth_tx_data_valid &&
        (eth_tx_mod_burst_s == 1'b0) &&
        (eth_tx_src_modid_s == MODID_ETH) &&
        (eth_tx_src_chipid_s == host_chipid) &&
        (eth_tx_trg_modid_s == HOME_MODID) &&
        (eth_tx_trg_chipid_s == host_chipid) &&
        (eth_tx_mod_mode_s == MODE_WRITE_POSTED) &&
        (eth_tx_mod_addr_s == 32'hDEADBEE0) &&
        (eth_tx_mod_data0_s == 'hFFDEBC9A78563412)) begin
        set_host_ip = 1'b1;
    end
end


endmodule
