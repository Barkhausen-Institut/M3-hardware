module rld3_wrap #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter HOME_MODID = {NOC_MODID_SIZE{1'b0}}
    ,parameter SIMULATION = 0

    // RLD3 Parameters matching the Bridge/Sync configuration
    ,parameter RLD3_APP_ADDR_WIDTH = 20
    ,parameter RLD3_APP_BANK_WIDTH = 4
    ,parameter RLD3_APP_DATA_WIDTH = 288
    ,parameter RLD3_APP_CMD_WIDTH  = 2
)
(
    input  wire                     sys_rst,
    output wire                     c0_init_calib_complete,
    output wire                     c0_calib_error,

    // System Clock (Differential input to IP)
    input  wire                     c0_sys_clk_p,
    input  wire                     c0_sys_clk_n,

    // RLDRAM 3 Physical Interface
    input  wire [7:0]               c0_rld3_qk_p,
    input  wire [7:0]               c0_rld3_qk_n,
    input  wire [3:0]               c0_rld3_qvld,
    inout  wire [71:0]              c0_rld3_dq,
    output wire                     c0_rld3_ck_p,
    output wire                     c0_rld3_ck_n,
    output wire [3:0]               c0_rld3_dk_p,
    output wire [3:0]               c0_rld3_dk_n,
    output wire                     c0_rld3_cs_n,
    output wire                     c0_rld3_we_n,
    output wire                     c0_rld3_ref_n,
    output wire                     c0_rld3_reset_n,
    output wire [3:0]               c0_rld3_dm,
    output wire [19:0]              c0_rld3_a,
    output wire [3:0]               c0_rld3_ba,

    input  wire [NOC_CHIPID_SIZE-1:0] home_chipid_i,

    // NoC interface
    input  wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_in_data_i,
    output wire [NOC_ASYNC_FIFO_AWIDTH:0]         noc_fifo_in_raddr_o,
    input  wire [NOC_ASYNC_FIFO_AWIDTH:0]         noc_fifo_in_waddr_i,
    output wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_out_data_o,
    input  wire [NOC_ASYNC_FIFO_AWIDTH:0]         noc_fifo_out_raddr_i,
    output wire [NOC_ASYNC_FIFO_AWIDTH:0]         noc_fifo_out_waddr_o
);

    // =========================================================================
    // Internal Wires & Clocks
    // =========================================================================

    // Clocking
    wire rld3_ui_clk;
    wire rld3_ui_rst; // Active High from IP sync_rst output
    wire mem_clk_i   = rld3_ui_clk;
    wire mem_rst_n_i = ~rld3_ui_rst;

    // RLD3 IP User Interface Signals (Aggregated 2x Slot Widths)
    wire          c0_rld3_user_cmd_en;
    wire [3:0]    c0_rld3_user_cmd;
    wire [39:0]   c0_rld3_user_addr;
    wire [7:0]    c0_rld3_user_ba;
    wire          c0_rld3_user_wr_en;
    wire [575:0]  c0_rld3_user_wr_data;
    wire [31:0]   c0_rld3_user_wr_dm;
    wire          c0_rld3_user_afifo_empty;
    wire          c0_rld3_user_afifo_full;
    wire          c0_rld3_user_afifo_aempty;
    wire          c0_rld3_user_afifo_afull;
    wire          c0_rld3_user_wdfifo_empty;
    wire          c0_rld3_user_wdfifo_full;
    wire          c0_rld3_user_wdfifo_aempty;
    wire          c0_rld3_user_wdfifo_afull;
    wire [1:0]    c0_rld3_user_rd_valid;
    wire [575:0]  c0_rld3_user_rd_data;

    // Bridge <-> Sync Interface Signals (Single Slot Widths)
    wire [RLD3_APP_ADDR_WIDTH-1:0]   bridge_app_addr;
    wire [RLD3_APP_BANK_WIDTH-1:0]   bridge_app_ba;
    wire [RLD3_APP_CMD_WIDTH-1:0]    bridge_app_cmd;
    wire                             bridge_app_en;
    wire                             bridge_app_wr_en;
    wire [RLD3_APP_DATA_WIDTH-1:0]   bridge_app_wdf_data;
    wire [RLD3_APP_DATA_WIDTH/8-1:0] bridge_app_wdf_mask;
    wire [RLD3_APP_DATA_WIDTH-1:0]   bridge_app_rd_data;
    wire                             bridge_app_rd_data_valid;
    wire                             bridge_app_rdy;
    wire                             bridge_app_wdf_rdy;

    wire [2:0]                       rld3_bridge_status;


    // NoC signals
    wire [NOC_PAYLOAD_SIZE-1:0] noc_rx_payload_s;
    wire                        noc_rx_rdreq_s;
    wire [NOC_HEADER_SIZE-1:0]  noc_rx_header_s;
    wire                        noc_rx_flit_avail_n_s;

    wire [NOC_PAYLOAD_SIZE-1:0] noc_tx_payload_s;
    wire                        noc_tx_stall_s;
    wire                        noc_tx_wrreq_s;
    wire [NOC_HEADER_SIZE-1:0]  noc_tx_header_s;

    wire [CHIP_X_COORD_SIZE-1:0] noc_rx_src_chip_x_coord_s;
    wire [CHIP_Y_COORD_SIZE-1:0] noc_rx_src_chip_y_coord_s;
    wire [CHIP_Z_COORD_SIZE-1:0] noc_rx_src_chip_z_coord_s;
    wire [MOD_X_COORD_SIZE-1:0]  noc_rx_src_mod_x_coord_s;
    wire [MOD_Y_COORD_SIZE-1:0]  noc_rx_src_mod_y_coord_s;
    wire [MOD_Z_COORD_SIZE-1:0]  noc_rx_src_mod_z_coord_s;
    wire [CHIP_X_COORD_SIZE-1:0] noc_rx_trg_chip_x_coord_s;
    wire [CHIP_Y_COORD_SIZE-1:0] noc_rx_trg_chip_y_coord_s;
    wire [CHIP_Z_COORD_SIZE-1:0] noc_rx_trg_chip_z_coord_s;
    wire [MOD_X_COORD_SIZE-1:0]  noc_rx_trg_mod_x_coord_s;
    wire [MOD_Y_COORD_SIZE-1:0]  noc_rx_trg_mod_y_coord_s;
    wire [MOD_Z_COORD_SIZE-1:0]  noc_rx_trg_mod_z_coord_s;

    wire [CHIP_X_COORD_SIZE-1:0] noc_tx_src_chip_x_coord_s;
    wire [CHIP_Y_COORD_SIZE-1:0] noc_tx_src_chip_y_coord_s;
    wire [CHIP_Z_COORD_SIZE-1:0] noc_tx_src_chip_z_coord_s;
    wire [MOD_X_COORD_SIZE-1:0]  noc_tx_src_mod_x_coord_s;
    wire [MOD_Y_COORD_SIZE-1:0]  noc_tx_src_mod_y_coord_s;
    wire [MOD_Z_COORD_SIZE-1:0]  noc_tx_src_mod_z_coord_s;
    wire [CHIP_X_COORD_SIZE-1:0] noc_tx_trg_chip_x_coord_s;
    wire [CHIP_Y_COORD_SIZE-1:0] noc_tx_trg_chip_y_coord_s;
    wire [CHIP_Z_COORD_SIZE-1:0] noc_tx_trg_chip_z_coord_s;
    wire [MOD_X_COORD_SIZE-1:0]  noc_tx_trg_mod_x_coord_s;
    wire [MOD_Y_COORD_SIZE-1:0]  noc_tx_trg_mod_y_coord_s;
    wire [MOD_Z_COORD_SIZE-1:0]  noc_tx_trg_mod_z_coord_s;

    wire                        rld3_noc_rx_wrreq_s;
    wire                        rld3_noc_rx_burst_s;
    wire                        rld3_noc_rx_arq_s;
    wire [NOC_BSEL_SIZE-1:0]    rld3_noc_rx_bsel_s;
    wire [NOC_CHIPID_SIZE-1:0]  rld3_noc_rx_src_chipid_s;
    wire [NOC_MODID_SIZE-1:0]   rld3_noc_rx_src_modid_s;
    wire [NOC_CHIPID_SIZE-1:0]  rld3_noc_rx_trg_chipid_s;
    wire [NOC_MODID_SIZE-1:0]   rld3_noc_rx_trg_modid_s;
    wire [NOC_MODE_SIZE-1:0]    rld3_noc_rx_mode_s;
    wire [NOC_ADDR_SIZE-1:0]    rld3_noc_rx_addr_s;
    wire [NOC_DATA_SIZE-1:0]    rld3_noc_rx_data0_s;
    wire [NOC_DATA_SIZE-1:0]    rld3_noc_rx_data1_s;
    wire                        rld3_noc_tx_stall_s;

    wire                        rld3_noc_tx_wrreq_s;
    wire                        rld3_noc_tx_burst_s;
    wire                        rld3_noc_tx_arq_s;
    wire [NOC_BSEL_SIZE-1:0]    rld3_noc_tx_bsel_s;
    wire [NOC_CHIPID_SIZE-1:0]  rld3_noc_tx_src_chipid_s;
    wire [NOC_MODID_SIZE-1:0]   rld3_noc_tx_src_modid_s;
    wire [NOC_CHIPID_SIZE-1:0]  rld3_noc_tx_trg_chipid_s;
    wire [NOC_MODID_SIZE-1:0]   rld3_noc_tx_trg_modid_s;
    wire [NOC_MODE_SIZE-1:0]    rld3_noc_tx_mode_s;
    wire [NOC_ADDR_SIZE-1:0]    rld3_noc_tx_addr_s;
    wire [NOC_DATA_SIZE-1:0]    rld3_noc_tx_data0_s;
    wire [NOC_DATA_SIZE-1:0]    rld3_noc_tx_data1_s;
    wire                        rld3_noc_rx_stall_s;

    wire                        rld3_config_en_s;
    wire [TCU_REG_BSEL_SIZE-1:0] rld3_config_wben_s;
    wire [TCU_REG_ADDR_SIZE-1:0] rld3_config_addr_s;
    wire [TCU_REG_DATA_SIZE-1:0] rld3_config_wdata_s;
    wire [TCU_REG_DATA_SIZE-1:0] rld3_config_rdata_s;

    wire                        tcu_mem_en_s;
    wire                        tcu_mem_req_s;
    wire [TCU_MEM_BSEL_SIZE-1:0] tcu_mem_wben_s;
    wire [TCU_MEM_ADDR_SIZE-1:0] tcu_mem_addr_s;
    wire [TCU_MEM_DATA_SIZE-1:0] tcu_mem_wdata_s;
    wire [TCU_MEM_DATA_SIZE-1:0] tcu_mem_rdata_s;
    wire                        tcu_mem_rdata_avail_s;
    wire                        tcu_mem_wdata_infifo_s = 1'b0;
    wire                        tcu_mem_wstall_s;
    wire                        tcu_mem_rstall_s;
    wire [TCU_STATUS_SIZE-1:0]  tcu_status;

    // Coordinate Assignments
    assign {noc_tx_src_mod_x_coord_s, noc_tx_src_mod_y_coord_s, noc_tx_src_mod_z_coord_s} = rld3_noc_tx_src_modid_s;
    assign {noc_tx_src_chip_x_coord_s, noc_tx_src_chip_y_coord_s, noc_tx_src_chip_z_coord_s} = rld3_noc_tx_src_chipid_s;
    assign {noc_tx_trg_mod_x_coord_s, noc_tx_trg_mod_y_coord_s, noc_tx_trg_mod_z_coord_s} = rld3_noc_tx_trg_modid_s;
    assign {noc_tx_trg_chip_x_coord_s, noc_tx_trg_chip_y_coord_s, noc_tx_trg_chip_z_coord_s} = rld3_noc_tx_trg_chipid_s;

    assign rld3_noc_rx_src_modid_s = {noc_rx_src_mod_x_coord_s, noc_rx_src_mod_y_coord_s, noc_rx_src_mod_z_coord_s};
    assign rld3_noc_rx_src_chipid_s = {noc_rx_src_chip_x_coord_s, noc_rx_src_chip_y_coord_s, noc_rx_src_chip_z_coord_s};
    assign rld3_noc_rx_trg_modid_s = {noc_rx_trg_mod_x_coord_s, noc_rx_trg_mod_y_coord_s, noc_rx_trg_mod_z_coord_s};
    assign rld3_noc_rx_trg_chipid_s = {noc_rx_trg_chip_x_coord_s, noc_rx_trg_chip_y_coord_s, noc_rx_trg_chip_z_coord_s};

    // =========================================================================
    // NoC Modules
    // =========================================================================
    noc_link_par_phy #(
        .NOC_ASYNC_FIFO_AWIDTH(NOC_ASYNC_FIFO_AWIDTH),
        .NOC_ASYNC_FIFO_PACKET_SIZE(NOC_ASYNC_FIFO_PACKET_SIZE)
    ) i_noc_link_par_phy (
        .clk_i              (mem_clk_i),
        .rst_q_i            (mem_rst_n_i),
        .rx_fifo_empty_o    (noc_rx_flit_avail_n_s),
        .rx_fifo_read_addr_o(noc_fifo_in_raddr_o),
        .rx_fifo_read_data_i(noc_fifo_in_data_i),
        .rx_fifo_write_addr_i(noc_fifo_in_waddr_i),
        .rx_header_o        (noc_rx_header_s),
        .rx_payload_o       (noc_rx_payload_s),
        .rx_rdreq_i         (noc_rx_rdreq_s),
        .testmode_i         (1'b0),
        .tx_fifo_read_addr_i(noc_fifo_out_raddr_i),
        .tx_fifo_read_data_o(noc_fifo_out_data_o),
        .tx_fifo_write_addr_o(noc_fifo_out_waddr_o),
        .tx_header_i        (noc_tx_header_s),
        .tx_payload_i       (noc_tx_payload_s),
        .tx_stall_o         (noc_tx_stall_s),
        .tx_wrreq_i         (noc_tx_wrreq_s)
    );

    nocif i_nocif (
        .clk_i              (mem_clk_i),
        .flit_avail_q_i     (noc_rx_flit_avail_n_s),
        .header_i           (noc_rx_header_s),
        .header_o           (noc_tx_header_s),
        .mod_addr_i         (rld3_noc_tx_addr_s),
        .mod_addr_o         (rld3_noc_rx_addr_s),
        .mod_burst_i        (rld3_noc_tx_burst_s),
        .mod_burst_o        (rld3_noc_rx_burst_s),
        .mod_arq_i          (rld3_noc_tx_arq_s),
        .mod_arq_o          (rld3_noc_rx_arq_s),
        .mod_bsel_i         (rld3_noc_tx_bsel_s),
        .mod_bsel_o         (rld3_noc_rx_bsel_s),
        .mod_data0_i        (rld3_noc_tx_data0_s),
        .mod_data0_o        (rld3_noc_rx_data0_s),
        .mod_data1_i        (rld3_noc_tx_data1_s),
        .mod_data1_o        (rld3_noc_rx_data1_s),
        .mod_mode_i         (rld3_noc_tx_mode_s),
        .mod_mode_o         (rld3_noc_rx_mode_s),
        .mod_stall_i        (rld3_noc_rx_stall_s),
        .mod_stall_o        (rld3_noc_tx_stall_s),
        .mod_wrreq_i        (rld3_noc_tx_wrreq_s),
        .mod_wrreq_o        (rld3_noc_rx_wrreq_s),
        .payload_i          (noc_rx_payload_s),
        .payload_o          (noc_tx_payload_s),
        .rdreq_o            (noc_rx_rdreq_s),
        .reset_q_i          (mem_rst_n_i),
        .src_chip_x_coord_i (noc_tx_src_chip_x_coord_s),
        .src_chip_x_coord_o (noc_rx_src_chip_x_coord_s),
        .src_chip_y_coord_i (noc_tx_src_chip_y_coord_s),
        .src_chip_y_coord_o (noc_rx_src_chip_y_coord_s),
        .src_chip_z_coord_i (noc_tx_src_chip_z_coord_s),
        .src_chip_z_coord_o (noc_rx_src_chip_z_coord_s),
        .src_mod_x_coord_i  (noc_tx_src_mod_x_coord_s),
        .src_mod_x_coord_o  (noc_rx_src_mod_x_coord_s),
        .src_mod_y_coord_i  (noc_tx_src_mod_y_coord_s),
        .src_mod_y_coord_o  (noc_rx_src_mod_y_coord_s),
        .src_mod_z_coord_i  (noc_tx_src_mod_z_coord_s),
        .src_mod_z_coord_o  (noc_rx_src_mod_z_coord_s),
        .stall_i            (noc_tx_stall_s),
        .trg_chip_x_coord_i (noc_tx_trg_chip_x_coord_s),
        .trg_chip_x_coord_o (noc_rx_trg_chip_x_coord_s),
        .trg_chip_y_coord_i (noc_tx_trg_chip_y_coord_s),
        .trg_chip_y_coord_o (noc_rx_trg_chip_y_coord_s),
        .trg_chip_z_coord_i (noc_tx_trg_chip_z_coord_s),
        .trg_chip_z_coord_o (noc_rx_trg_chip_z_coord_s),
        .trg_mod_x_coord_i  (noc_tx_trg_mod_x_coord_s),
        .trg_mod_x_coord_o  (noc_rx_trg_mod_x_coord_s),
        .trg_mod_y_coord_i  (noc_tx_trg_mod_y_coord_s),
        .trg_mod_y_coord_o  (noc_rx_trg_mod_y_coord_s),
        .trg_mod_z_coord_i  (noc_tx_trg_mod_z_coord_s),
        .trg_mod_z_coord_o  (noc_rx_trg_mod_z_coord_s),
        .wrreq_o            (noc_tx_wrreq_s)
    );

    // =========================================================================
    // TCU Top
    // =========================================================================
    tcu_top #(
        .TCU_ENABLE_CMDS            (0),
        .TCU_ENABLE_DRAM            (1),
        .TCU_ENABLE_MEM_ADDR_ALIGN  (0),
        .CLKFREQ_MHZ                (100),
        .TILE_TYPE                  ('d1), // memory tile
        .TILE_ISA                   ('d0),
        .TILE_ATTR                  ('d16), // IMEM
        .TILE_MEMSIZE               ('h80000000 >> 12), // mem size in 4 kB pages
        .DMEM_DATA_SIZE             (TCU_MEM_DATA_SIZE),
        .DMEM_ADDR_SIZE             (TCU_MEM_ADDR_SIZE),
        .DMEM_BSEL_SIZE             (TCU_MEM_BSEL_SIZE),
        .IMEM_DATA_SIZE             (TCU_MEM_DATA_SIZE),
        .IMEM_ADDR_SIZE             (TCU_MEM_ADDR_SIZE),
        .IMEM_BSEL_SIZE             (TCU_MEM_BSEL_SIZE),
        .DMEM_START_ADDR            (32'h0),
        .DMEM_SIZE                  ('h80000000),
        .IMEM_START_ADDR            (32'h0),
        .IMEM_SIZE                  (0),
        .NOCMUX_TX_IF1_PRIO         (1),
        .NOCMUX_RX_IF1_PRIO         (1),
        .NOCMUX_RX_IF1_ADDR_START   (32'h0),
        .NOCMUX_RX_IF1_ADDR_END     (32'hFFFFFFFF),
        .NOCMUX_RX_IF1_ONLY_MODE_2  (0),
        .NOCMUX_RX_IF2_ADDR_START   (32'h0),
        .NOCMUX_RX_IF2_ADDR_END     (32'h0),
        .NOCMUX_RX_IF2_ONLY_MODE_2  (0)
    ) i_tcu_top (
        .clk_i                  (mem_clk_i),
        .reset_n_i              (mem_rst_n_i),
        .tcu_noc_rx_wrreq_i     (rld3_noc_rx_wrreq_s),
        .tcu_noc_rx_burst_i     (rld3_noc_rx_burst_s),
        .tcu_noc_rx_arq_i       (rld3_noc_rx_arq_s),
        .tcu_noc_rx_bsel_i      (rld3_noc_rx_bsel_s),
        .tcu_noc_rx_src_chipid_i(rld3_noc_rx_src_chipid_s),
        .tcu_noc_rx_src_modid_i (rld3_noc_rx_src_modid_s),
        .tcu_noc_rx_trg_chipid_i(rld3_noc_rx_trg_chipid_s),
        .tcu_noc_rx_trg_modid_i (rld3_noc_rx_trg_modid_s),
        .tcu_noc_rx_mode_i      (rld3_noc_rx_mode_s),
        .tcu_noc_rx_addr_i      (rld3_noc_rx_addr_s),
        .tcu_noc_rx_data0_i     (rld3_noc_rx_data0_s),
        .tcu_noc_rx_data1_i     (rld3_noc_rx_data1_s),
        .tcu_noc_rx_stall_o     (rld3_noc_rx_stall_s),
        .tcu_noc_tx_wrreq_o     (rld3_noc_tx_wrreq_s),
        .tcu_noc_tx_burst_o     (rld3_noc_tx_burst_s),
        .tcu_noc_tx_arq_o       (rld3_noc_tx_arq_s),
        .tcu_noc_tx_bsel_o      (rld3_noc_tx_bsel_s),
        .tcu_noc_tx_src_chipid_o(rld3_noc_tx_src_chipid_s),
        .tcu_noc_tx_src_modid_o (rld3_noc_tx_src_modid_s),
        .tcu_noc_tx_trg_chipid_o(rld3_noc_tx_trg_chipid_s),
        .tcu_noc_tx_trg_modid_o (rld3_noc_tx_trg_modid_s),
        .tcu_noc_tx_mode_o      (rld3_noc_tx_mode_s),
        .tcu_noc_tx_addr_o      (rld3_noc_tx_addr_s),
        .tcu_noc_tx_data0_o     (rld3_noc_tx_data0_s),
        .tcu_noc_tx_data1_o     (rld3_noc_tx_data1_s),
        .tcu_noc_tx_stall_i     (rld3_noc_tx_stall_s),
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
        .core_dmem_in_en_i      (1'b0),
        .core_dmem_in_wben_i    (4'h0),
        .core_dmem_in_addr_i    (32'h0),
        .core_dmem_in_wdata_i   (32'h0),
        .core_dmem_in_rdata_o   (),
        .core_dmem_in_stall_o   (),
        .core_imem_in_en_i      (1'b0),
        .core_imem_in_wben_i    (4'h0),
        .core_imem_in_addr_i    (32'h0),
        .core_imem_in_wdata_i   (32'h0),
        .core_imem_in_rdata_o   (),
        .core_imem_in_stall_o   (),
        .core_dmem_out_en_o     (),
        .core_dmem_out_wben_o   (),
        .core_dmem_out_addr_o   (),
        .core_dmem_out_wdata_o  (),
        .core_dmem_out_rdata_i  ({TCU_MEM_DATA_SIZE{1'b0}}),
        .core_dmem_out_stall_i  (1'b0),
        .core_imem_out_en_o     (),
        .core_imem_out_wben_o   (),
        .core_imem_out_addr_o   (),
        .core_imem_out_wdata_o  (),
        .core_imem_out_rdata_i  ({TCU_MEM_DATA_SIZE{1'b0}}),
        .core_imem_out_stall_i  (1'b0),
        .tcu_dmem_en_o          (tcu_mem_en_s),
        .tcu_dmem_req_o         (tcu_mem_req_s),
        .tcu_dmem_wben_o        (tcu_mem_wben_s),
        .tcu_dmem_addr_o        (tcu_mem_addr_s),
        .tcu_dmem_wdata_o       (tcu_mem_wdata_s),
        .tcu_dmem_rdata_i       (tcu_mem_rdata_s),
        .tcu_dmem_rdata_avail_i (tcu_mem_rdata_avail_s),
        .tcu_dmem_wdata_infifo_i(tcu_mem_wdata_infifo_s),
        .tcu_dmem_wabort_o      (),
        .tcu_dmem_wstall_i      (tcu_mem_wstall_s),
        .tcu_dmem_rstall_i      (tcu_mem_rstall_s),
        .tcu_imem_en_o          (),
        .tcu_imem_req_o         (),
        .tcu_imem_wben_o        (),
        .tcu_imem_addr_o        (),
        .tcu_imem_wdata_o       (),
        .tcu_imem_rdata_i       ({TCU_MEM_DATA_SIZE{1'b0}}),
        .tcu_imem_rdata_avail_i (1'b0),
        .tcu_imem_wdata_infifo_i(1'b0),
        .tcu_imem_wabort_o      (),
        .tcu_imem_wstall_i      (1'b0),
        .tcu_imem_rstall_i      (1'b0),
        .config_mem_en_o        (rld3_config_en_s),
        .config_mem_wben_o      (rld3_config_wben_s),
        .config_mem_addr_o      (rld3_config_addr_s),
        .config_mem_wdata_o     (rld3_config_wdata_s),
        .config_mem_rdata_i     (rld3_config_rdata_s),
        .tcu_status_o           (tcu_status),
        .home_chipid_i          (home_chipid_i),
        .home_modid_i           (HOME_MODID),
        .print_chipid_i         ({NOC_CHIPID_SIZE{1'b0}}),
        .print_modid_i          ({NOC_MODID_SIZE{1'b0}})
    );

    // =========================================================================
    // RLDRAM 3 Protocol Stack
    // =========================================================================
    genvar ram_block;
    generate
    if (SIMULATION) begin: NO_RLD3

        assign tcu_mem_rdata_avail_s = 1'b1;
        assign tcu_mem_wstall_s = 1'b0;
        assign tcu_mem_rstall_s = 1'b0;

        assign c0_init_calib_complete = 1'b0;
        assign c0_calib_error = 1'b0;

        // High-Z assignments for simulation
        assign c0_rld3_a    = 20'h0;
        assign c0_rld3_ba   = 4'h0;
        assign c0_rld3_cs_n = 1'b1; // Inactive
        assign c0_rld3_we_n = 1'b1;
        assign c0_rld3_ref_n= 1'b1;
        assign c0_rld3_dq   = 72'hz;
        assign c0_rld3_dm   = 4'hz;

        // Clock driving (Simulation Mock)
        assign rld3_ui_clk = c0_sys_clk_p;
        assign rld3_ui_rst = ~sys_rst;

        localparam SIM_RAM_AWIDTH = 18;
        localparam RAM_BLOCK_NUM = 32;
        localparam RAM_BLOCK_NUM_LOG = $clog2(RAM_BLOCK_NUM);

        reg [RAM_BLOCK_NUM_LOG-1:0] r_sim_ram_sel;
        wire [SIM_RAM_AWIDTH-1:0] sim_ram_addr = tcu_mem_addr_s[SIM_RAM_AWIDTH+4-1 : 4];

        // upper addr bits determine RAM block
        wire [RAM_BLOCK_NUM-1:0] sim_ram_en = tcu_mem_en_s << sim_ram_addr[SIM_RAM_AWIDTH-RAM_BLOCK_NUM_LOG +: RAM_BLOCK_NUM_LOG];
        wire [RAM_BLOCK_NUM_LOG-1:0] sim_ram_sel = sim_ram_addr[SIM_RAM_AWIDTH-RAM_BLOCK_NUM_LOG +: RAM_BLOCK_NUM_LOG];

        wire [TCU_MEM_DATA_SIZE-1:0] sim_ram_rdata [0:RAM_BLOCK_NUM-1];
        assign tcu_mem_rdata_s = sim_ram_rdata[r_sim_ram_sel];

        always @(posedge rld3_ui_clk or posedge rld3_ui_rst) begin
            if (rld3_ui_rst) begin
                r_sim_ram_sel <= {RAM_BLOCK_NUM_LOG{1'b0}};
            end else begin
                r_sim_ram_sel <= sim_ram_sel;
            end
        end

        for (ram_block=0; ram_block<RAM_BLOCK_NUM; ram_block=ram_block+1) begin: SIM_RAM
            mem_sp_wrap #(
                .MEM_TYPE      ("distributed"),
                .MEM_DATAWIDTH (TCU_MEM_DATA_SIZE),
                .MEM_ADDRWIDTH (SIM_RAM_AWIDTH-RAM_BLOCK_NUM_LOG)
            ) i_rld3_sim_ram (
                .clk   (rld3_ui_clk),
                .reset (rld3_ui_rst),
                .en    (sim_ram_en[ram_block]),
                .we    (tcu_mem_wben_s),
                .addr  (sim_ram_addr[SIM_RAM_AWIDTH-RAM_BLOCK_NUM_LOG-1:0]),
                .din   (tcu_mem_wdata_s),
                .dout  (sim_ram_rdata[ram_block])
            );
        end

    end
    else begin: RLD3_IF

        // 1. Bridge: TCU -> RLD3 Protocol (Address Split, Alignment)
        rld3_mem_app_bridge #(
            .RLD3_APP_ADDR_WIDTH(RLD3_APP_ADDR_WIDTH),
            .RLD3_APP_BANK_WIDTH(RLD3_APP_BANK_WIDTH),
            .RLD3_APP_DATA_WIDTH(RLD3_APP_DATA_WIDTH),
            .RLD3_APP_CMD_WIDTH(RLD3_APP_CMD_WIDTH)
        ) i_rld3_mem_app_bridge (
            .mem_clk_i              (mem_clk_i),
            .mem_reset_n_i          (mem_rst_n_i),
            .mem_en_i               (tcu_mem_en_s),
            .mem_req_i              (tcu_mem_req_s),
            .mem_wben_i             (tcu_mem_wben_s),
            .mem_addr_i             (tcu_mem_addr_s),
            .mem_wdata_i            (tcu_mem_wdata_s),
            .mem_rdata_o            (tcu_mem_rdata_s),
            .mem_rdata_avail_o      (tcu_mem_rdata_avail_s),
            .mem_wstall_o           (tcu_mem_wstall_s),
            .mem_rstall_o           (tcu_mem_rstall_s),
            .mem_access_i           (tcu_status[0]),

            .rld3_app_addr_o        (bridge_app_addr),
            .rld3_app_ba_o          (bridge_app_ba),
            .rld3_app_cmd_o         (bridge_app_cmd),
            .rld3_app_en_o          (bridge_app_en),
            .rld3_app_wr_en_o       (bridge_app_wr_en),
            .rld3_app_wdf_data_o    (bridge_app_wdf_data),
            .rld3_app_wdf_mask_o    (bridge_app_wdf_mask),
            .rld3_app_rd_data_i     (bridge_app_rd_data),
            .rld3_app_rd_data_valid_i(bridge_app_rd_data_valid),
            .rld3_app_rdy_i         (bridge_app_rdy),
            .rld3_app_wdf_rdy_i     (bridge_app_wdf_rdy),
            .rld3_status_o          (rld3_bridge_status)
        );

        // 2. Sync: CDC & Width Expansion (1-Slot -> 2-Slots)
        rld3_app_sync #(
            .BRIDGE_ADDR_WIDTH(RLD3_APP_ADDR_WIDTH),
            .BRIDGE_BANK_WIDTH(RLD3_APP_BANK_WIDTH),
            .BRIDGE_CMD_WIDTH(RLD3_APP_CMD_WIDTH),
            .BRIDGE_DATA_WIDTH(RLD3_APP_DATA_WIDTH)
        ) i_rld3_app_sync (
            .mem_clk_i              (mem_clk_i),
            .mem_rst_i              (~mem_rst_n_i), // Active High

            .bridge_app_addr_i      (bridge_app_addr),
            .bridge_app_ba_i        (bridge_app_ba),
            .bridge_app_cmd_i       (bridge_app_cmd),
            .bridge_app_en_i        (bridge_app_en),
            .bridge_app_wr_en_i     (bridge_app_wr_en),
            .bridge_app_wdf_data_i  (bridge_app_wdf_data),
            .bridge_app_wdf_mask_i  (bridge_app_wdf_mask),
            .bridge_app_rdy_o       (bridge_app_rdy),
            .bridge_app_wdf_rdy_o   (bridge_app_wdf_rdy),
            .bridge_app_rd_data_o   (bridge_app_rd_data),
            .bridge_app_rd_data_valid_o(bridge_app_rd_data_valid),

            .rld3_ui_clk_i          (rld3_ui_clk),
            .rld3_ui_rst_i          (rld3_ui_rst),
            .rld3_user_addr_o       (c0_rld3_user_addr),
            .rld3_user_ba_o         (c0_rld3_user_ba),
            .rld3_user_cmd_o        (c0_rld3_user_cmd),
            .rld3_user_cmd_en_o     (c0_rld3_user_cmd_en),
            .rld3_user_wr_en_o      (c0_rld3_user_wr_en),
            .rld3_user_wr_data_o    (c0_rld3_user_wr_data),
            .rld3_user_wr_dm_o      (c0_rld3_user_wr_dm),
            .rld3_user_afifo_full_i (c0_rld3_user_afifo_full),
            .rld3_user_wdfifo_full_i(c0_rld3_user_wdfifo_full),
            .rld3_user_rd_data_i    (c0_rld3_user_rd_data),
            .rld3_user_rd_valid_i   (c0_rld3_user_rd_valid)
        );

        // 3. IP Instance
        rld3_xcvu37p u_rld3_xcvu37p (
            .sys_rst                (sys_rst),
            .c0_sys_clk_p           (c0_sys_clk_p),
            .c0_sys_clk_n           (c0_sys_clk_n),
            .c0_init_calib_complete (c0_init_calib_complete),
            .c0_calib_error         (c0_calib_error),

            // User Interface
            .c0_rld3_ui_clk         (rld3_ui_clk),
            .c0_rld3_ui_clk_sync_rst(rld3_ui_rst),

            .c0_rld3_user_cmd_en    (c0_rld3_user_cmd_en),
            .c0_rld3_user_cmd       (c0_rld3_user_cmd),
            .c0_rld3_user_addr      (c0_rld3_user_addr),
            .c0_rld3_user_ba        (c0_rld3_user_ba),
            .c0_rld3_user_wr_en     (c0_rld3_user_wr_en),
            .c0_rld3_user_wr_data   (c0_rld3_user_wr_data),
            .c0_rld3_user_wr_dm     (c0_rld3_user_wr_dm),
            .c0_rld3_user_rd_valid  (c0_rld3_user_rd_valid),
            .c0_rld3_user_rd_data   (c0_rld3_user_rd_data),

            // Status
            .c0_rld3_user_afifo_empty   (c0_rld3_user_afifo_empty),
            .c0_rld3_user_afifo_full    (c0_rld3_user_afifo_full),
            .c0_rld3_user_afifo_aempty  (c0_rld3_user_afifo_aempty),
            .c0_rld3_user_afifo_afull   (c0_rld3_user_afifo_afull),
            .c0_rld3_user_wdfifo_empty  (c0_rld3_user_wdfifo_empty),
            .c0_rld3_user_wdfifo_full   (c0_rld3_user_wdfifo_full),
            .c0_rld3_user_wdfifo_aempty (c0_rld3_user_wdfifo_aempty),
            .c0_rld3_user_wdfifo_afull  (c0_rld3_user_wdfifo_afull),

            // Physical Interface
            .c0_rld3_a              (c0_rld3_a),
            .c0_rld3_ba             (c0_rld3_ba),
            .c0_rld3_cs_n           (c0_rld3_cs_n),
            .c0_rld3_ck_p           (c0_rld3_ck_p),
            .c0_rld3_ck_n           (c0_rld3_ck_n),
            .c0_rld3_dk_p           (c0_rld3_dk_p),
            .c0_rld3_dk_n           (c0_rld3_dk_n),
            .c0_rld3_ref_n          (c0_rld3_ref_n),
            .c0_rld3_we_n           (c0_rld3_we_n),
            .c0_rld3_dq             (c0_rld3_dq),
            .c0_rld3_dm             (c0_rld3_dm),
            .c0_rld3_qk_p           (c0_rld3_qk_p),
            .c0_rld3_qk_n           (c0_rld3_qk_n),
            .c0_rld3_qvld           (c0_rld3_qvld),
            .c0_rld3_reset_n        (c0_rld3_reset_n),
            .dbg_bus                (),
            .dbg_clk                ()
        );

    end
    endgenerate

endmodule
