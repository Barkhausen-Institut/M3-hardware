
module ddr4_wrap #(
    `include "noc_parameter.vh"
    ,`include "ddr4_user_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter INST = "C1",
    parameter HOME_MODID = {NOC_MODID_SIZE{1'b0}},
    parameter SIMULATION = 0
)
(
    input  wire                                   sys_clk_n,
    input  wire                                   sys_clk_p,
    input  wire                                   sys_rst,
    input  wire             [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input  wire                                   ddr4_clk_i,
    input  wire                                   ddr4_rst_n_i,
    output wire                                   ddr4_init_calib_complete_o,
    output wire            [DDR4_STATUS_SIZE-1:0] ddr4_status_o,

    // NoC interface
    input   wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_in_data_i,
    output  wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_raddr_o,
    input   wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_waddr_i,
    output  wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_out_data_o,
    input   wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_raddr_i,
    output  wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_waddr_o,

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


// NoC signals between noc_link_phy and NoCIF
wire     [NOC_PAYLOAD_SIZE-1:0] noc_rx_payload_s;
wire                            noc_rx_rdreq_s;
wire      [NOC_HEADER_SIZE-1:0] noc_rx_header_s;
wire                            noc_rx_flit_avail_n_s;

wire     [NOC_PAYLOAD_SIZE-1:0] noc_tx_payload_s;
wire                            noc_tx_stall_s;
wire                            noc_tx_wrreq_s;
wire      [NOC_HEADER_SIZE-1:0] noc_tx_header_s;

wire    [CHIP_X_COORD_SIZE-1:0] noc_rx_src_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] noc_rx_src_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] noc_rx_src_chip_z_coord_s;
wire     [MOD_X_COORD_SIZE-1:0] noc_rx_src_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] noc_rx_src_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] noc_rx_src_mod_z_coord_s;
wire    [CHIP_X_COORD_SIZE-1:0] noc_rx_trg_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] noc_rx_trg_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] noc_rx_trg_chip_z_coord_s;
wire     [MOD_X_COORD_SIZE-1:0] noc_rx_trg_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] noc_rx_trg_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] noc_rx_trg_mod_z_coord_s;

wire    [CHIP_X_COORD_SIZE-1:0] noc_tx_src_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] noc_tx_src_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] noc_tx_src_chip_z_coord_s;
wire     [MOD_X_COORD_SIZE-1:0] noc_tx_src_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] noc_tx_src_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] noc_tx_src_mod_z_coord_s;
wire    [CHIP_X_COORD_SIZE-1:0] noc_tx_trg_chip_x_coord_s;
wire    [CHIP_Y_COORD_SIZE-1:0] noc_tx_trg_chip_y_coord_s;
wire    [CHIP_Z_COORD_SIZE-1:0] noc_tx_trg_chip_z_coord_s;
wire     [MOD_X_COORD_SIZE-1:0] noc_tx_trg_mod_x_coord_s;
wire     [MOD_Y_COORD_SIZE-1:0] noc_tx_trg_mod_y_coord_s;
wire     [MOD_Z_COORD_SIZE-1:0] noc_tx_trg_mod_z_coord_s;


//NoC interface
wire                             ddr4_noc_rx_wrreq_s;
wire                             ddr4_noc_rx_burst_s;
wire                             ddr4_noc_rx_arq_s;
wire         [NOC_BSEL_SIZE-1:0] ddr4_noc_rx_bsel_s;
wire       [NOC_CHIPID_SIZE-1:0] ddr4_noc_rx_src_chipid_s;
wire        [NOC_MODID_SIZE-1:0] ddr4_noc_rx_src_modid_s;
wire       [NOC_CHIPID_SIZE-1:0] ddr4_noc_rx_trg_chipid_s;
wire        [NOC_MODID_SIZE-1:0] ddr4_noc_rx_trg_modid_s;
wire         [NOC_MODE_SIZE-1:0] ddr4_noc_rx_mode_s;
wire         [NOC_ADDR_SIZE-1:0] ddr4_noc_rx_addr_s;
wire         [NOC_DATA_SIZE-1:0] ddr4_noc_rx_data0_s;
wire         [NOC_DATA_SIZE-1:0] ddr4_noc_rx_data1_s;
wire                             ddr4_noc_tx_stall_s;

wire                             ddr4_noc_tx_wrreq_s;
wire                             ddr4_noc_tx_burst_s;
wire                             ddr4_noc_tx_arq_s;
wire         [NOC_BSEL_SIZE-1:0] ddr4_noc_tx_bsel_s;
wire       [NOC_CHIPID_SIZE-1:0] ddr4_noc_tx_src_chipid_s;
wire        [NOC_MODID_SIZE-1:0] ddr4_noc_tx_src_modid_s;
wire       [NOC_CHIPID_SIZE-1:0] ddr4_noc_tx_trg_chipid_s;
wire        [NOC_MODID_SIZE-1:0] ddr4_noc_tx_trg_modid_s;
wire         [NOC_MODE_SIZE-1:0] ddr4_noc_tx_mode_s;
wire         [NOC_ADDR_SIZE-1:0] ddr4_noc_tx_addr_s;
wire         [NOC_DATA_SIZE-1:0] ddr4_noc_tx_data0_s;
wire         [NOC_DATA_SIZE-1:0] ddr4_noc_tx_data1_s;
wire                             ddr4_noc_rx_stall_s;

assign {noc_tx_src_mod_x_coord_s, noc_tx_src_mod_y_coord_s, noc_tx_src_mod_z_coord_s} = ddr4_noc_tx_src_modid_s;
assign {noc_tx_src_chip_x_coord_s, noc_tx_src_chip_y_coord_s, noc_tx_src_chip_z_coord_s} = ddr4_noc_tx_src_chipid_s;
assign {noc_tx_trg_mod_x_coord_s, noc_tx_trg_mod_y_coord_s, noc_tx_trg_mod_z_coord_s} = ddr4_noc_tx_trg_modid_s;
assign {noc_tx_trg_chip_x_coord_s, noc_tx_trg_chip_y_coord_s, noc_tx_trg_chip_z_coord_s} = ddr4_noc_tx_trg_chipid_s;

assign ddr4_noc_rx_src_modid_s = {noc_rx_src_mod_x_coord_s, noc_rx_src_mod_y_coord_s, noc_rx_src_mod_z_coord_s};
assign ddr4_noc_rx_src_chipid_s = {noc_rx_src_chip_x_coord_s, noc_rx_src_chip_y_coord_s, noc_rx_src_chip_z_coord_s};
assign ddr4_noc_rx_trg_modid_s = {noc_rx_trg_mod_x_coord_s, noc_rx_trg_mod_y_coord_s, noc_rx_trg_mod_z_coord_s};
assign ddr4_noc_rx_trg_chipid_s = {noc_rx_trg_chip_x_coord_s, noc_rx_trg_chip_y_coord_s, noc_rx_trg_chip_z_coord_s};

wire                          ddr4_config_en_s;
wire  [TCU_REG_BSEL_SIZE-1:0] ddr4_config_wben_s;
wire  [TCU_REG_ADDR_SIZE-1:0] ddr4_config_addr_s;
wire  [TCU_REG_DATA_SIZE-1:0] ddr4_config_wdata_s;
wire  [TCU_REG_DATA_SIZE-1:0] ddr4_config_rdata_s;

wire                          tcu_mem_en_s;
wire                          tcu_mem_req_s;
wire  [TCU_MEM_BSEL_SIZE-1:0] tcu_mem_wben_s;
wire  [TCU_MEM_ADDR_SIZE-1:0] tcu_mem_addr_s;
wire  [TCU_MEM_DATA_SIZE-1:0] tcu_mem_wdata_s;
wire  [TCU_MEM_DATA_SIZE-1:0] tcu_mem_rdata_s;
wire                          tcu_mem_rdata_avail_s;
wire                          tcu_mem_wdata_infifo_s = 1'b0;
wire                          tcu_mem_wstall_s;
wire                          tcu_mem_rstall_s;

wire    [TCU_STATUS_SIZE-1:0] tcu_status;



noc_link_par_phy #(
    .NOC_ASYNC_FIFO_AWIDTH(NOC_ASYNC_FIFO_AWIDTH),
    .NOC_ASYNC_FIFO_PACKET_SIZE(NOC_ASYNC_FIFO_PACKET_SIZE)
) i_noc_link_par_phy (
    .clk_i                  (ddr4_clk_i),
    .rst_q_i                (ddr4_rst_n_i),
    .rx_fifo_empty_o        (noc_rx_flit_avail_n_s),
    .rx_fifo_read_addr_o    (noc_fifo_in_raddr_o),
    .rx_fifo_read_data_i    (noc_fifo_in_data_i),
    .rx_fifo_write_addr_i   (noc_fifo_in_waddr_i),
    .rx_header_o            (noc_rx_header_s),
    .rx_payload_o           (noc_rx_payload_s),
    .rx_rdreq_i             (noc_rx_rdreq_s),
    .testmode_i             (1'b0),
    .tx_fifo_read_addr_i    (noc_fifo_out_raddr_i),
    .tx_fifo_read_data_o    (noc_fifo_out_data_o),
    .tx_fifo_write_addr_o   (noc_fifo_out_waddr_o),
    .tx_header_i            (noc_tx_header_s),
    .tx_payload_i           (noc_tx_payload_s),
    .tx_stall_o             (noc_tx_stall_s),
    .tx_wrreq_i             (noc_tx_wrreq_s)
);

nocif i_nocif (
    .clk_i                  (ddr4_clk_i),
    .flit_avail_q_i         (noc_rx_flit_avail_n_s),
    .header_i               (noc_rx_header_s),
    .header_o               (noc_tx_header_s),
    .mod_addr_i             (ddr4_noc_tx_addr_s),
    .mod_addr_o             (ddr4_noc_rx_addr_s),
    .mod_burst_i            (ddr4_noc_tx_burst_s),
    .mod_burst_o            (ddr4_noc_rx_burst_s),
    .mod_arq_i              (ddr4_noc_tx_arq_s),
    .mod_arq_o              (ddr4_noc_rx_arq_s),
    .mod_bsel_i             (ddr4_noc_tx_bsel_s),
    .mod_bsel_o             (ddr4_noc_rx_bsel_s),
    .mod_data0_i            (ddr4_noc_tx_data0_s),
    .mod_data0_o            (ddr4_noc_rx_data0_s),
    .mod_data1_i            (ddr4_noc_tx_data1_s),
    .mod_data1_o            (ddr4_noc_rx_data1_s),
    .mod_mode_i             (ddr4_noc_tx_mode_s),
    .mod_mode_o             (ddr4_noc_rx_mode_s),
    .mod_stall_i            (ddr4_noc_rx_stall_s),
    .mod_stall_o            (ddr4_noc_tx_stall_s),
    .mod_wrreq_i            (ddr4_noc_tx_wrreq_s),
    .mod_wrreq_o            (ddr4_noc_rx_wrreq_s),
    .payload_i              (noc_rx_payload_s),
    .payload_o              (noc_tx_payload_s),
    .rdreq_o                (noc_rx_rdreq_s),
    .reset_q_i              (ddr4_rst_n_i),
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
    .stall_i                (noc_tx_stall_s),
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
    .wrreq_o                (noc_tx_wrreq_s)
);



tcu_top #(
    .TCU_ENABLE_CMDS            (0),
    .TCU_ENABLE_DRAM            (1),
    .TCU_ENABLE_MEM_ADDR_ALIGN  (0),
    .HOME_MODID                 (HOME_MODID),
    .CLKFREQ_MHZ                (100),
    .TILE_TYPE                  ('d1),              //memory tile
    .TILE_ISA                   ('d0),
    .TILE_ATTR                  ('d16),             //IMEM
    .TILE_MEMSIZE               ('h80000000 >> 12), //mem size in 4 kB pages
    .DMEM_DATA_SIZE             (TCU_MEM_DATA_SIZE),
    .DMEM_ADDR_SIZE             (TCU_MEM_ADDR_SIZE),
    .DMEM_BSEL_SIZE             (TCU_MEM_BSEL_SIZE),
    .IMEM_DATA_SIZE             (TCU_MEM_DATA_SIZE),
    .IMEM_ADDR_SIZE             (TCU_MEM_ADDR_SIZE),
    .IMEM_BSEL_SIZE             (TCU_MEM_BSEL_SIZE),
    .DMEM_START_ADDR            (32'h0),
    .DMEM_SIZE                  ('h80000000),   //2GB DRAM
    .IMEM_START_ADDR            (32'h0),        //unused
    .IMEM_SIZE                  (0),
    .NOCMUX_TX_IF1_PRIO         (1),            //IF2 unused
    .NOCMUX_RX_IF1_PRIO         (1),
    .NOCMUX_RX_IF1_ADDR_START   (32'h0),
    .NOCMUX_RX_IF1_ADDR_END     (32'hFFFFFFFF),
    .NOCMUX_RX_IF1_ONLY_MODE_2  (0),
    .NOCMUX_RX_IF2_ADDR_START   (32'h0),
    .NOCMUX_RX_IF2_ADDR_END     (32'h0),
    .NOCMUX_RX_IF2_ONLY_MODE_2  (0)
) i_tcu_top (
    .clk_i                      (ddr4_clk_i),
    .reset_n_i                  (ddr4_rst_n_i),

    .tcu_noc_rx_wrreq_i         (ddr4_noc_rx_wrreq_s),
    .tcu_noc_rx_burst_i         (ddr4_noc_rx_burst_s),
    .tcu_noc_rx_arq_i           (ddr4_noc_rx_arq_s),
    .tcu_noc_rx_bsel_i          (ddr4_noc_rx_bsel_s),
    .tcu_noc_rx_src_chipid_i    (ddr4_noc_rx_src_chipid_s),
    .tcu_noc_rx_src_modid_i     (ddr4_noc_rx_src_modid_s),
    .tcu_noc_rx_trg_chipid_i    (ddr4_noc_rx_trg_chipid_s),
    .tcu_noc_rx_trg_modid_i     (ddr4_noc_rx_trg_modid_s),
    .tcu_noc_rx_mode_i          (ddr4_noc_rx_mode_s),
    .tcu_noc_rx_addr_i          (ddr4_noc_rx_addr_s),
    .tcu_noc_rx_data0_i         (ddr4_noc_rx_data0_s),
    .tcu_noc_rx_data1_i         (ddr4_noc_rx_data1_s),
    .tcu_noc_rx_stall_o         (ddr4_noc_rx_stall_s),

    .tcu_noc_tx_wrreq_o         (ddr4_noc_tx_wrreq_s),
    .tcu_noc_tx_burst_o         (ddr4_noc_tx_burst_s),
    .tcu_noc_tx_arq_o           (ddr4_noc_tx_arq_s),
    .tcu_noc_tx_bsel_o          (ddr4_noc_tx_bsel_s),
    .tcu_noc_tx_src_chipid_o    (ddr4_noc_tx_src_chipid_s),
    .tcu_noc_tx_src_modid_o     (ddr4_noc_tx_src_modid_s),
    .tcu_noc_tx_trg_chipid_o    (ddr4_noc_tx_trg_chipid_s),
    .tcu_noc_tx_trg_modid_o     (ddr4_noc_tx_trg_modid_s),
    .tcu_noc_tx_mode_o          (ddr4_noc_tx_mode_s),
    .tcu_noc_tx_addr_o          (ddr4_noc_tx_addr_s),
    .tcu_noc_tx_data0_o         (ddr4_noc_tx_data0_s),
    .tcu_noc_tx_data1_o         (ddr4_noc_tx_data1_s),
    .tcu_noc_tx_stall_i         (ddr4_noc_tx_stall_s),

    .tcu_byp_noc_tx_wrreq_i     (1'b0),
    .tcu_byp_noc_tx_burst_i     (1'b0),
    .tcu_byp_noc_tx_arq_i       (1'b0),
    .tcu_byp_noc_tx_bsel_i      ({NOC_BSEL_SIZE{1'b0}}),
    .tcu_byp_noc_tx_src_chipid_i({NOC_CHIPID_SIZE{1'b0}}),
    .tcu_byp_noc_tx_src_modid_i ({NOC_MODID_SIZE{1'b0}}),
    .tcu_byp_noc_tx_trg_chipid_i({NOC_CHIPID_SIZE{1'b0}}),
    .tcu_byp_noc_tx_trg_modid_i ({NOC_MODID_SIZE{1'b0}}),
    .tcu_byp_noc_tx_mode_i      ({NOC_MODE_SIZE{1'b0}}),
    .tcu_byp_noc_tx_addr_i      ({NOC_ADDR_SIZE{1'b0}}),
    .tcu_byp_noc_tx_data0_i     ({NOC_DATA_SIZE{1'b0}}),
    .tcu_byp_noc_tx_data1_i     ({NOC_DATA_SIZE{1'b0}}),
    .tcu_byp_noc_tx_stall_o     (),

    .tcu_byp_noc_rx_wrreq_o     (),
    .tcu_byp_noc_rx_burst_o     (),
    .tcu_byp_noc_rx_arq_o       (),
    .tcu_byp_noc_rx_bsel_o      (),
    .tcu_byp_noc_rx_src_chipid_o(),
    .tcu_byp_noc_rx_src_modid_o (),
    .tcu_byp_noc_rx_trg_chipid_o(),
    .tcu_byp_noc_rx_trg_modid_o (),
    .tcu_byp_noc_rx_mode_o      (),
    .tcu_byp_noc_rx_addr_o      (),
    .tcu_byp_noc_rx_data0_o     (),
    .tcu_byp_noc_rx_data1_o     (),
    .tcu_byp_noc_rx_stall_i     (1'b0),
    
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
    .core_dmem_out_rdata_i      ({TCU_MEM_DATA_SIZE{1'b0}}),
    .core_dmem_out_stall_i      (1'b0),

    .core_imem_out_en_o         (), //unused
    .core_imem_out_wben_o       (),
    .core_imem_out_addr_o       (),
    .core_imem_out_wdata_o      (),
    .core_imem_out_rdata_i      ({TCU_MEM_DATA_SIZE{1'b0}}),
    .core_imem_out_stall_i      (1'b0),

    .tcu_dmem_en_o              (tcu_mem_en_s),
    .tcu_dmem_req_o             (tcu_mem_req_s),
    .tcu_dmem_wben_o            (tcu_mem_wben_s),
    .tcu_dmem_addr_o            (tcu_mem_addr_s),
    .tcu_dmem_wdata_o           (tcu_mem_wdata_s),
    .tcu_dmem_rdata_i           (tcu_mem_rdata_s),
    .tcu_dmem_rdata_avail_i     (tcu_mem_rdata_avail_s),
    .tcu_dmem_wdata_infifo_i    (tcu_mem_wdata_infifo_s),
    .tcu_dmem_wabort_o          (),
    .tcu_dmem_wstall_i          (tcu_mem_wstall_s),
    .tcu_dmem_rstall_i          (tcu_mem_rstall_s),

    .tcu_imem_en_o              (),  //unused
    .tcu_imem_req_o             (),
    .tcu_imem_wben_o            (),
    .tcu_imem_addr_o            (),
    .tcu_imem_wdata_o           (),
    .tcu_imem_rdata_i           ({TCU_MEM_DATA_SIZE{1'b0}}),
    .tcu_imem_rdata_avail_i     (1'b0),
    .tcu_imem_wdata_infifo_i    (1'b0),
    .tcu_imem_wabort_o          (),
    .tcu_imem_wstall_i          (1'b0),
    .tcu_imem_rstall_i          (1'b0),

    .config_mem_en_o            (ddr4_config_en_s),
    .config_mem_wben_o          (ddr4_config_wben_s),
    .config_mem_addr_o          (ddr4_config_addr_s),
    .config_mem_wdata_o         (ddr4_config_wdata_s),
    .config_mem_rdata_i         (ddr4_config_rdata_s),

    .tcu_status_o               (tcu_status),

    .home_chipid_i              (home_chipid_i),

    .print_chipid_i             ({NOC_CHIPID_SIZE{1'b0}}),  //debug print is disabled
    .print_modid_i              ({NOC_MODID_SIZE{1'b0}})
);


ddr4_regfile i_ddr4_regfile (
    .clk_i                      (ddr4_clk_i),
    .reset_n_i                  (ddr4_rst_n_i),

    .config_en_i                (ddr4_config_en_s),
    .config_wben_i              (ddr4_config_wben_s),
    .config_addr_i              (ddr4_config_addr_s),
    .config_wdata_i             (ddr4_config_wdata_s),
    .config_rdata_o             (ddr4_config_rdata_s),

    .ddr4_status_i              (ddr4_status_o),
    .ddr4_init_calib_complete_i (ddr4_init_calib_complete_o)
);



genvar ram_block;
generate
if (SIMULATION) begin: NO_DDR4

    assign tcu_mem_rdata_avail_s = 1'b1;    //unused for simple memory
    assign tcu_mem_wstall_s = 1'b0;
    assign tcu_mem_rstall_s = 1'b0;

    assign ddr4_status_o = {DDR4_STATUS_SIZE{1'b0}};
    assign ddr4_init_calib_complete_o = 1'b0;

    assign ddr4_act_n    = 1'b0;
    assign ddr4_addr     = 17'h0;
    assign ddr4_ba       = 2'h0;
    assign ddr4_bg       = 1'b0;
    assign ddr4_cke      = 1'b0;
    assign ddr4_odt      = 1'b0;
    assign ddr4_cs_n     = 1'b0;
    assign ddr4_ck_t     = 1'b0;
    assign ddr4_ck_c     = 1'b1;
    assign ddr4_reset_n  = 1'b0;
    assign ddr4_dm_dbi_n = 10'hz;    //inout ports
    assign ddr4_dq       = 80'hz;
    assign ddr4_dqs_c    = 10'hz;
    assign ddr4_dqs_t    = 10'hz;


    //localparam DDR4_SIM_RAM_AWIDTH = 27;  //acutal DRAM size: 2GB = 2^27 * 16byte
    localparam DDR4_SIM_RAM_AWIDTH = 18;  //reduced: 4MB = 2^18 * 16byte
    localparam RAM_BLOCK_NUM = 32;
    localparam RAM_BLOCK_NUM_LOG = $clog2(RAM_BLOCK_NUM);

    reg [RAM_BLOCK_NUM_LOG-1:0] r_sim_ram_sel;

    wire [DDR4_SIM_RAM_AWIDTH-1:0] sim_ram_addr = tcu_mem_addr_s[DDR4_SIM_RAM_AWIDTH+4-1 : 4];

    //upper addr bits determine RAM block
    wire [RAM_BLOCK_NUM-1:0] sim_ram_en = tcu_mem_en_s << sim_ram_addr[DDR4_SIM_RAM_AWIDTH-RAM_BLOCK_NUM_LOG +: RAM_BLOCK_NUM_LOG];
    wire [RAM_BLOCK_NUM_LOG-1:0] sim_ram_sel = sim_ram_addr[DDR4_SIM_RAM_AWIDTH-RAM_BLOCK_NUM_LOG +: RAM_BLOCK_NUM_LOG];

    wire [TCU_MEM_DATA_SIZE-1:0] sim_ram_rdata [0:RAM_BLOCK_NUM-1];
    assign tcu_mem_rdata_s = sim_ram_rdata[r_sim_ram_sel];


    always @(posedge ddr4_clk_i or negedge ddr4_rst_n_i) begin
        if (ddr4_rst_n_i == 1'b0) begin
            r_sim_ram_sel <= {RAM_BLOCK_NUM_LOG{1'b0}};
        end else begin
            r_sim_ram_sel <= sim_ram_sel;
        end
    end


    //split memory into multiple RAM blocks to reduce simulation effort
    for (ram_block=0; ram_block<RAM_BLOCK_NUM; ram_block=ram_block+1) begin: SIM_RAM
        mem_sp_wrap #(
            .MEM_TYPE      ("distributed"),
            .MEM_DATAWIDTH (TCU_MEM_DATA_SIZE),
            .MEM_ADDRWIDTH (DDR4_SIM_RAM_AWIDTH-RAM_BLOCK_NUM_LOG)
        ) i_ddr4_sim_ram (
            .clk   (ddr4_clk_i),
            .reset (~ddr4_rst_n_i),
            .en    (sim_ram_en[ram_block]),
            .we    (tcu_mem_wben_s),
            .addr  (sim_ram_addr[DDR4_SIM_RAM_AWIDTH-RAM_BLOCK_NUM_LOG-1:0]),
            .din   (tcu_mem_wdata_s),
            .dout  (sim_ram_rdata[ram_block])
        );
    end

end
else begin: DDR4_IF

    //ddr4 app interface
    wire   [DDR4_APP_ADDR_WIDTH-1:0] ddr4_app_addr;
    wire    [DDR4_APP_CMD_WIDTH-1:0] ddr4_app_cmd;
    wire                             ddr4_app_en;
    wire   [DDR4_APP_DATA_WIDTH-1:0] ddr4_app_wdf_data;
    wire                             ddr4_app_wdf_end;
    wire [DDR4_APP_DATA_WIDTH/8-1:0] ddr4_app_wdf_mask;
    wire                             ddr4_app_wdf_wren;
    wire   [DDR4_APP_DATA_WIDTH-1:0] ddr4_app_rd_data;
    wire                             ddr4_app_rd_data_end;
    wire                             ddr4_app_rd_data_valid;
    wire                             ddr4_app_rdy;
    wire                             ddr4_app_wdf_rdy;

    wire   [DDR4_APP_ADDR_WIDTH-1:0] bridge_app_addr;
    wire    [DDR4_APP_CMD_WIDTH-1:0] bridge_app_cmd;
    wire                             bridge_app_en;
    wire   [DDR4_APP_DATA_WIDTH-1:0] bridge_app_wdf_data;
    wire                             bridge_app_wdf_end;
    wire [DDR4_APP_DATA_WIDTH/8-1:0] bridge_app_wdf_mask;
    wire                             bridge_app_wdf_wren;
    wire   [DDR4_APP_DATA_WIDTH-1:0] bridge_app_rd_data;
    wire                             bridge_app_rd_data_end;
    wire                             bridge_app_rd_data_valid;
    wire                             bridge_app_rdy;
    wire                             bridge_app_wdf_rdy;

    wire                             ddr4_ui_clk;
    wire                             ddr4_ui_clk_rst;


    ddr4_mem_app_bridge i_ddr4_mem_app_bridge (
        .mem_clk_i                  (ddr4_clk_i),
        .mem_reset_n_i              (ddr4_rst_n_i),
        .mem_en_i                   (tcu_mem_en_s),
        .mem_req_i                  (tcu_mem_req_s),
        .mem_wben_i                 (tcu_mem_wben_s),
        .mem_addr_i                 (tcu_mem_addr_s),
        .mem_wdata_i                (tcu_mem_wdata_s),
        .mem_rdata_o                (tcu_mem_rdata_s),
        .mem_rdata_avail_o          (tcu_mem_rdata_avail_s),
        .mem_wstall_o               (tcu_mem_wstall_s),
        .mem_rstall_o               (tcu_mem_rstall_s),
        .mem_access_i               (tcu_status[0]),
        .ddr4_app_addr_o            (bridge_app_addr),
        .ddr4_app_cmd_o             (bridge_app_cmd),
        .ddr4_app_en_o              (bridge_app_en),
        .ddr4_app_wdf_data_o        (bridge_app_wdf_data),
        .ddr4_app_wdf_end_o         (bridge_app_wdf_end),
        .ddr4_app_wdf_mask_o        (bridge_app_wdf_mask),
        .ddr4_app_wdf_wren_o        (bridge_app_wdf_wren),
        .ddr4_app_rd_data_i         (bridge_app_rd_data),
        .ddr4_app_rd_data_end_i     (bridge_app_rd_data_end),
        .ddr4_app_rd_data_valid_i   (bridge_app_rd_data_valid),
        .ddr4_app_rdy_i             (bridge_app_rdy),
        .ddr4_app_wdf_rdy_i         (bridge_app_wdf_rdy),
        .ddr4_status_o              (ddr4_status_o)
    );


    ddr4_app_sync i_ddr4_app_sync (
        .mem_clk_i                    (ddr4_clk_i),
        .mem_rst_i                    (~ddr4_rst_n_i),

        .bridge_app_addr_i            (bridge_app_addr),
        .bridge_app_cmd_i             (bridge_app_cmd),
        .bridge_app_en_i              (bridge_app_en),
        .bridge_app_wdf_data_i        (bridge_app_wdf_data),
        .bridge_app_wdf_end_i         (bridge_app_wdf_end),
        .bridge_app_wdf_mask_i        (bridge_app_wdf_mask),
        .bridge_app_wdf_wren_i        (bridge_app_wdf_wren),
        .bridge_app_rdy_o             (bridge_app_rdy),
        .bridge_app_wdf_rdy_o         (bridge_app_wdf_rdy),
        .bridge_app_rd_data_o         (bridge_app_rd_data),
        .bridge_app_rd_data_end_o     (bridge_app_rd_data_end),
        .bridge_app_rd_data_valid_o   (bridge_app_rd_data_valid),

        .ddr4_ui_clk_i                (ddr4_ui_clk),
        .ddr4_ui_rst_i                (ddr4_ui_clk_rst),

        .ddr4_app_addr_o              (ddr4_app_addr),
        .ddr4_app_cmd_o               (ddr4_app_cmd),
        .ddr4_app_en_o                (ddr4_app_en),
        .ddr4_app_wdf_data_o          (ddr4_app_wdf_data),
        .ddr4_app_wdf_end_o           (ddr4_app_wdf_end),
        .ddr4_app_wdf_mask_o          (ddr4_app_wdf_mask),
        .ddr4_app_wdf_wren_o          (ddr4_app_wdf_wren),
        .ddr4_app_rdy_i               (ddr4_app_rdy),
        .ddr4_app_wdf_rdy_i           (ddr4_app_wdf_rdy),
        .ddr4_app_rd_data_i           (ddr4_app_rd_data),
        .ddr4_app_rd_data_end_i       (ddr4_app_rd_data_end),
        .ddr4_app_rd_data_valid_i     (ddr4_app_rd_data_valid)
    );


    if (INST == "C1") begin: DDR4_C1

        ddr4_c1_xcvu9p u_ddr4_c1_xcvu9p (
            .sys_rst                       (sys_rst),

            .c0_sys_clk_p                  (sys_clk_p),
            .c0_sys_clk_n                  (sys_clk_n),
            .c0_init_calib_complete        (ddr4_init_calib_complete_o),

            .c0_ddr4_act_n                 (ddr4_act_n),
            .c0_ddr4_adr                   (ddr4_addr),
            .c0_ddr4_ba                    (ddr4_ba),
            .c0_ddr4_bg                    (ddr4_bg),
            .c0_ddr4_cke                   (ddr4_cke),
            .c0_ddr4_odt                   (ddr4_odt),
            .c0_ddr4_cs_n                  (ddr4_cs_n),
            .c0_ddr4_ck_t                  (ddr4_ck_t),
            .c0_ddr4_ck_c                  (ddr4_ck_c),
            .c0_ddr4_reset_n               (ddr4_reset_n),
            .c0_ddr4_dm_dbi_n              (ddr4_dm_dbi_n),
            .c0_ddr4_dq                    (ddr4_dq),
            .c0_ddr4_dqs_c                 (ddr4_dqs_c),
            .c0_ddr4_dqs_t                 (ddr4_dqs_t),

            .c0_ddr4_app_addr              (ddr4_app_addr),
            .c0_ddr4_app_cmd               (ddr4_app_cmd),
            .c0_ddr4_app_en                (ddr4_app_en),
            .c0_ddr4_app_hi_pri            (1'b0),
            .c0_ddr4_app_wdf_data          (ddr4_app_wdf_data),
            .c0_ddr4_app_wdf_end           (ddr4_app_wdf_end),
            .c0_ddr4_app_wdf_mask          (ddr4_app_wdf_mask),
            .c0_ddr4_app_wdf_wren          (ddr4_app_wdf_wren),
            .c0_ddr4_app_rd_data           (ddr4_app_rd_data),
            .c0_ddr4_app_rd_data_end       (ddr4_app_rd_data_end),
            .c0_ddr4_app_rd_data_valid     (ddr4_app_rd_data_valid),
            .c0_ddr4_app_rdy               (ddr4_app_rdy),
            .c0_ddr4_app_wdf_rdy           (ddr4_app_wdf_rdy),
            .c0_ddr4_ui_clk                (ddr4_ui_clk),
            .c0_ddr4_ui_clk_sync_rst       (ddr4_ui_clk_rst),

            //unused
            .dbg_bus                       (),
            .dbg_clk                       ()
        );

    end
    else if (INST == "C2") begin: DDR4_C2

        ddr4_c2_xcvu9p u_ddr4_c2_xcvu9p (
            .sys_rst                       (sys_rst),

            .c0_sys_clk_p                  (sys_clk_p),
            .c0_sys_clk_n                  (sys_clk_n),
            .c0_init_calib_complete        (ddr4_init_calib_complete_o),

            .c0_ddr4_act_n                 (ddr4_act_n),
            .c0_ddr4_adr                   (ddr4_addr),
            .c0_ddr4_ba                    (ddr4_ba),
            .c0_ddr4_bg                    (ddr4_bg),
            .c0_ddr4_cke                   (ddr4_cke),
            .c0_ddr4_odt                   (ddr4_odt),
            .c0_ddr4_cs_n                  (ddr4_cs_n),
            .c0_ddr4_ck_t                  (ddr4_ck_t),
            .c0_ddr4_ck_c                  (ddr4_ck_c),
            .c0_ddr4_reset_n               (ddr4_reset_n),
            .c0_ddr4_dm_dbi_n              (ddr4_dm_dbi_n),
            .c0_ddr4_dq                    (ddr4_dq),
            .c0_ddr4_dqs_c                 (ddr4_dqs_c),
            .c0_ddr4_dqs_t                 (ddr4_dqs_t),

            .c0_ddr4_app_addr              (ddr4_app_addr),
            .c0_ddr4_app_cmd               (ddr4_app_cmd),
            .c0_ddr4_app_en                (ddr4_app_en),
            .c0_ddr4_app_hi_pri            (1'b0),
            .c0_ddr4_app_wdf_data          (ddr4_app_wdf_data),
            .c0_ddr4_app_wdf_end           (ddr4_app_wdf_end),
            .c0_ddr4_app_wdf_mask          (ddr4_app_wdf_mask),
            .c0_ddr4_app_wdf_wren          (ddr4_app_wdf_wren),
            .c0_ddr4_app_rd_data           (ddr4_app_rd_data),
            .c0_ddr4_app_rd_data_end       (ddr4_app_rd_data_end),
            .c0_ddr4_app_rd_data_valid     (ddr4_app_rd_data_valid),
            .c0_ddr4_app_rdy               (ddr4_app_rdy),
            .c0_ddr4_app_wdf_rdy           (ddr4_app_wdf_rdy),
            .c0_ddr4_ui_clk                (ddr4_ui_clk),
            .c0_ddr4_ui_clk_sync_rst       (ddr4_ui_clk_rst),

            //unused
            .dbg_bus                       (),
            .dbg_clk                       ()
        );

    end
end
endgenerate

endmodule
