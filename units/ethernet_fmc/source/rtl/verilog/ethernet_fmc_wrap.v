
module ethernet_fmc_wrap #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,`include "mod_ids.vh"
    ,parameter ETH_INCLUDE_SHARED_LOGIC = 1,
    parameter HOME_MODID                = {NOC_MODID_SIZE{1'b0}},
    parameter CLKFREQ_MHZ               = 100,
    parameter ROCKET_USE_LOCAL_MEM      = 0,
    parameter CORE_DMEM_DATA_SIZE       = 64,    //reg interface
    parameter CORE_DMEM_ADDR_SIZE       = 32,
    parameter CORE_DMEM_BSEL_SIZE       = CORE_DMEM_DATA_SIZE/8,
    parameter CORE_IMEM_DATA_SIZE       = 128,   //connects to Rocket mem interface
    parameter CORE_IMEM_ADDR_SIZE       = 32,
    parameter CORE_IMEM_BSEL_SIZE       = CORE_IMEM_DATA_SIZE/8,
    parameter ROCKET_MEM_DATA_SIZE      = 128,   //Rocket mem interface
    parameter ROCKET_MEM_ADDR_SIZE      = 32,
    parameter ROCKET_MEM_BSEL_SIZE      = ROCKET_MEM_DATA_SIZE/8,
    parameter DMEM_DATA_SIZE            = 128,   //connects to reg interface
    parameter DMEM_ADDR_SIZE            = 17,
    parameter DMEM_BSEL_SIZE            = DMEM_DATA_SIZE/8,
    parameter IMEM_DATA_SIZE            = 128,   //SPM interface
    parameter IMEM_ADDR_SIZE            = 17,
    parameter IMEM_BSEL_SIZE            = IMEM_DATA_SIZE/8,

    //TCU memory map according to Rocket config
    //for TCU everything in imem
    parameter DMEM_START_ADDR           = 32'h00000000,
    parameter DMEM_SIZE                 = 'h0,
    parameter IMEM_START_ADDR           = 32'h00000000,
    parameter IMEM_SIZE                 = ROCKET_USE_LOCAL_MEM ? 'h10200000 : 'hE0000000
)
(
    input  wire                                     clk_axi_i,
    input  wire                                     reset_n_i,
    input  wire               [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input  wire               [NOC_CHIPID_SIZE-1:0] host_chipid_i,
    input  wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_eth_in_data_i,
    output wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_eth_in_raddr_o,
    input  wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_eth_in_waddr_i,
    output wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_eth_out_data_o,
    input  wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_eth_out_raddr_i,
    output wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_eth_out_waddr_o,

    // physical interface
    input  wire                               [3:0] rgmii_rxd,
    input  wire                                     rgmii_rx_ctl,
    input  wire                                     rgmii_rxc,
    output wire                               [3:0] rgmii_txd,
    output wire                                     rgmii_tx_ctl,
    output wire                                     rgmii_txc,

    input  wire                                     gtx_clk_i,
    input  wire                                     ref_clk_i,

    //MDIO
    output wire                                     mdio_mdc_o,
    inout  wire                                     mdio_io,

    output wire                                     phy_reset_n,

    input  wire                                     jtag_tck_i,
    input  wire                                     jtag_tms_i,
    input  wire                                     jtag_tdi_i,
    output wire                                     jtag_tdo_o,
    output wire                                     jtag_tdo_en_o,

    output wire                                     uart_tx_o,
    input  wire                                     uart_rx_i
);
    
    localparam LOG_IMEM_DATA_BYTES = $clog2(IMEM_BSEL_SIZE);

    wire                             clk_core_s;
    wire                             reset_core_n_s;

    wire                             noclnk_eth_rx_flit_avail_n_s;
    wire       [NOC_HEADER_SIZE-1:0] noclnk_eth_rx_header_s;
    wire      [NOC_PAYLOAD_SIZE-1:0] noclnk_eth_rx_payload_s;
    wire                             noclnk_eth_rx_rdreq_s;
    wire       [NOC_HEADER_SIZE-1:0] noclnk_eth_tx_header_s;
    wire      [NOC_PAYLOAD_SIZE-1:0] noclnk_eth_tx_payload_s;
    wire                             noclnk_eth_tx_stall_s;
    wire                             noclnk_eth_tx_wrreq_s;

    wire         [NOC_ADDR_SIZE-1:0] eth_rx_mod_addr_s;
    wire                             eth_rx_mod_burst_s;
    wire                             eth_rx_mod_arq_s;
    wire         [NOC_BSEL_SIZE-1:0] eth_rx_mod_bsel_s;
    wire         [NOC_DATA_SIZE-1:0] eth_rx_mod_data0_s;
    wire         [NOC_DATA_SIZE-1:0] eth_rx_mod_data1_s;
    wire         [NOC_MODE_SIZE-1:0] eth_rx_mod_mode_s;
    wire                             eth_rx_mod_stall_s;
    wire                             eth_rx_mod_wrreq_s;
    wire     [CHIP_X_COORD_SIZE-1:0] eth_rx_src_chip_x_coord_s;
    wire     [CHIP_Y_COORD_SIZE-1:0] eth_rx_src_chip_y_coord_s;
    wire     [CHIP_Z_COORD_SIZE-1:0] eth_rx_src_chip_z_coord_s;
    wire       [NOC_CHIPID_SIZE-1:0] eth_rx_src_chipid_s;
    wire      [MOD_X_COORD_SIZE-1:0] eth_rx_src_mod_x_coord_s;
    wire      [MOD_Y_COORD_SIZE-1:0] eth_rx_src_mod_y_coord_s;
    wire      [MOD_Z_COORD_SIZE-1:0] eth_rx_src_mod_z_coord_s;
    wire        [NOC_MODID_SIZE-1:0] eth_rx_src_modid_s;
    wire     [CHIP_X_COORD_SIZE-1:0] eth_rx_trg_chip_x_coord_s;
    wire     [CHIP_Y_COORD_SIZE-1:0] eth_rx_trg_chip_y_coord_s;
    wire     [CHIP_Z_COORD_SIZE-1:0] eth_rx_trg_chip_z_coord_s;
    wire       [NOC_CHIPID_SIZE-1:0] eth_rx_trg_chipid_s;
    wire      [MOD_X_COORD_SIZE-1:0] eth_rx_trg_mod_x_coord_s;
    wire      [MOD_Y_COORD_SIZE-1:0] eth_rx_trg_mod_y_coord_s;
    wire      [MOD_Z_COORD_SIZE-1:0] eth_rx_trg_mod_z_coord_s;
    wire        [NOC_MODID_SIZE-1:0] eth_rx_trg_modid_s;

    wire         [NOC_ADDR_SIZE-1:0] eth_tx_mod_addr_s;
    wire                             eth_tx_mod_burst_s;
    wire                             eth_tx_mod_arq_s;
    wire         [NOC_BSEL_SIZE-1:0] eth_tx_mod_bsel_s;
    wire         [NOC_DATA_SIZE-1:0] eth_tx_mod_data0_s;
    wire         [NOC_DATA_SIZE-1:0] eth_tx_mod_data1_s;
    wire         [NOC_MODE_SIZE-1:0] eth_tx_mod_mode_s;
    wire                             eth_tx_mod_stall_s;
    wire                             eth_tx_mod_wrreq_s;
    wire     [CHIP_X_COORD_SIZE-1:0] eth_tx_src_chip_x_coord_s;
    wire     [CHIP_Y_COORD_SIZE-1:0] eth_tx_src_chip_y_coord_s;
    wire     [CHIP_Z_COORD_SIZE-1:0] eth_tx_src_chip_z_coord_s;
    wire       [NOC_CHIPID_SIZE-1:0] eth_tx_src_chipid_s;
    wire      [MOD_X_COORD_SIZE-1:0] eth_tx_src_mod_x_coord_s;
    wire      [MOD_Y_COORD_SIZE-1:0] eth_tx_src_mod_y_coord_s;
    wire      [MOD_Z_COORD_SIZE-1:0] eth_tx_src_mod_z_coord_s;
    wire        [NOC_MODID_SIZE-1:0] eth_tx_src_modid_s;
    wire     [CHIP_X_COORD_SIZE-1:0] eth_tx_trg_chip_x_coord_s;
    wire     [CHIP_Y_COORD_SIZE-1:0] eth_tx_trg_chip_y_coord_s;
    wire     [CHIP_Z_COORD_SIZE-1:0] eth_tx_trg_chip_z_coord_s;
    wire       [NOC_CHIPID_SIZE-1:0] eth_tx_trg_chipid_s;
    wire      [MOD_X_COORD_SIZE-1:0] eth_tx_trg_mod_x_coord_s;
    wire      [MOD_Y_COORD_SIZE-1:0] eth_tx_trg_mod_y_coord_s;
    wire      [MOD_Z_COORD_SIZE-1:0] eth_tx_trg_mod_z_coord_s;
    wire        [NOC_MODID_SIZE-1:0] eth_tx_trg_modid_s;


    //RISC-V to memory signals
    wire                             rocket_tcu_reg_en;
    wire   [CORE_DMEM_BSEL_SIZE-1:0] rocket_tcu_reg_wben;
    wire   [CORE_DMEM_ADDR_SIZE-1:0] rocket_tcu_reg_addr;
    wire   [CORE_DMEM_DATA_SIZE-1:0] rocket_tcu_reg_wdata;
    wire   [CORE_DMEM_DATA_SIZE-1:0] rocket_tcu_reg_rdata;
    wire                             rocket_tcu_reg_stall;

    wire                             rocket_mem_en;
    wire  [ROCKET_MEM_BSEL_SIZE-1:0] rocket_mem_wben;
    wire  [ROCKET_MEM_ADDR_SIZE-1:0] rocket_mem_addr;
    wire  [ROCKET_MEM_DATA_SIZE-1:0] rocket_mem_wdata;
    wire  [ROCKET_MEM_DATA_SIZE-1:0] rocket_mem_rdata;

    wire                             rocket_tcu_mem_en;
    wire  [ROCKET_MEM_BSEL_SIZE-1:0] rocket_tcu_mem_wben;
    wire  [ROCKET_MEM_ADDR_SIZE-1:0] rocket_tcu_mem_addr;
    wire  [ROCKET_MEM_DATA_SIZE-1:0] rocket_tcu_mem_wdata;
    wire  [ROCKET_MEM_DATA_SIZE-1:0] rocket_tcu_mem_rdata;

    //RISC-V to NoC signals
    wire                             rocket_noc_rx_wrreq_s;
    wire                             rocket_noc_rx_burst_s;
    wire         [NOC_BSEL_SIZE-1:0] rocket_noc_rx_bsel_s;
    wire       [NOC_CHIPID_SIZE-1:0] rocket_noc_rx_src_chipid_s;
    wire        [NOC_MODID_SIZE-1:0] rocket_noc_rx_src_modid_s;
    wire       [NOC_CHIPID_SIZE-1:0] rocket_noc_rx_trg_chipid_s;
    wire        [NOC_MODID_SIZE-1:0] rocket_noc_rx_trg_modid_s;
    wire         [NOC_MODE_SIZE-1:0] rocket_noc_rx_mode_s;
    wire         [NOC_ADDR_SIZE-1:0] rocket_noc_rx_addr_s;
    wire         [NOC_DATA_SIZE-1:0] rocket_noc_rx_data0_s;
    wire         [NOC_DATA_SIZE-1:0] rocket_noc_rx_data1_s;
    wire                             rocket_noc_rx_stall_s;

    wire                             rocket_noc_tx_wrreq_s;
    wire                             rocket_noc_tx_burst_s;
    wire         [NOC_BSEL_SIZE-1:0] rocket_noc_tx_bsel_s;
    wire       [NOC_CHIPID_SIZE-1:0] rocket_noc_tx_src_chipid_s;
    wire        [NOC_MODID_SIZE-1:0] rocket_noc_tx_src_modid_s;
    wire       [NOC_CHIPID_SIZE-1:0] rocket_noc_tx_trg_chipid_s;
    wire        [NOC_MODID_SIZE-1:0] rocket_noc_tx_trg_modid_s;
    wire         [NOC_MODE_SIZE-1:0] rocket_noc_tx_mode_s;
    wire         [NOC_ADDR_SIZE-1:0] rocket_noc_tx_addr_s;
    wire         [NOC_DATA_SIZE-1:0] rocket_noc_tx_data0_s;
    wire         [NOC_DATA_SIZE-1:0] rocket_noc_tx_data1_s;
    wire                             rocket_noc_tx_stall_s;

    //TCU memory signals
    wire                             tcu_mem_en;
    wire                             tcu_mem_req;
    wire  [ROCKET_MEM_BSEL_SIZE-1:0] tcu_mem_wben;
    wire  [ROCKET_MEM_ADDR_SIZE-1:0] tcu_mem_addr;
    wire  [ROCKET_MEM_DATA_SIZE-1:0] tcu_mem_wdata;
    wire  [ROCKET_MEM_DATA_SIZE-1:0] tcu_mem_rdata;
    wire                             tcu_mem_rdata_avail;
    wire                             tcu_mem_wdata_infifo;
    wire                             tcu_mem_wabort;
    wire                             tcu_mem_wstall;
    wire                             tcu_mem_rstall;


    //core config signals
    wire                             rocket_config_en;
    wire     [TCU_REG_BSEL_SIZE-1:0] rocket_config_wben;
    wire     [TCU_REG_ADDR_SIZE-1:0] rocket_config_addr;
    wire     [TCU_REG_DATA_SIZE-1:0] rocket_config_wdata;
    wire     [TCU_REG_DATA_SIZE-1:0] rocket_config_rdata;

    wire                             rocket_en;
    wire                             rocket_ext_int1;
    wire                             rocket_ext_int2;

    //number of errors from AXI4 bridges
    wire                      [31:0] tcu_mem_axi4_error;
    wire                      [31:0] axi4_mem_bridge_error;

    //info for traces
    wire                             rocket_trace_enabled;
    wire  [ROCKET_MEM_ADDR_SIZE-1:0] rocket_trace_ptr;
    wire  [ROCKET_MEM_ADDR_SIZE-1:0] rocket_trace_count;

    //status flag
    wire       [TCU_STATUS_SIZE-1:0] tcu_status;


    //AXI4 from Rocket to Ethernet BD
    wire                             eth_mmio_axi4_aw_ready;
    wire                             eth_mmio_axi4_aw_valid;
    wire                       [3:0] eth_mmio_axi4_aw_id;
    wire                      [31:0] eth_mmio_axi4_aw_addr;
    wire                       [7:0] eth_mmio_axi4_aw_len;
    wire                       [2:0] eth_mmio_axi4_aw_size;
    wire                       [1:0] eth_mmio_axi4_aw_burst;
    wire                             eth_mmio_axi4_aw_lock;
    wire                       [3:0] eth_mmio_axi4_aw_cache;
    wire                       [2:0] eth_mmio_axi4_aw_prot;
    wire                       [3:0] eth_mmio_axi4_aw_qos;
    wire                             eth_mmio_axi4_w_ready;
    wire                             eth_mmio_axi4_w_valid;
    wire                      [63:0] eth_mmio_axi4_w_data;
    wire                       [7:0] eth_mmio_axi4_w_strb;
    wire                             eth_mmio_axi4_w_last;
    wire                             eth_mmio_axi4_b_ready;
    wire                             eth_mmio_axi4_b_valid;
    wire                       [3:0] eth_mmio_axi4_b_id;
    wire                       [1:0] eth_mmio_axi4_b_resp;
    wire                             eth_mmio_axi4_ar_ready;
    wire                             eth_mmio_axi4_ar_valid;
    wire                       [3:0] eth_mmio_axi4_ar_id;
    wire                      [31:0] eth_mmio_axi4_ar_addr;
    wire                       [7:0] eth_mmio_axi4_ar_len;
    wire                       [2:0] eth_mmio_axi4_ar_size;
    wire                       [1:0] eth_mmio_axi4_ar_burst;
    wire                             eth_mmio_axi4_ar_lock;
    wire                       [3:0] eth_mmio_axi4_ar_cache;
    wire                       [2:0] eth_mmio_axi4_ar_prot;
    wire                       [3:0] eth_mmio_axi4_ar_qos;
    wire                             eth_mmio_axi4_r_ready;
    wire                             eth_mmio_axi4_r_valid;
    wire                       [3:0] eth_mmio_axi4_r_id;
    wire                      [63:0] eth_mmio_axi4_r_data;
    wire                       [1:0] eth_mmio_axi4_r_resp;
    wire                             eth_mmio_axi4_r_last;

    //AXI4 from Ethernet BD to Rocket L3 FrontBus
    wire                             eth_dma_axi4_aw_ready;
    wire                             eth_dma_axi4_aw_valid;
    wire                       [3:0] eth_dma_axi4_aw_id = 4'h0; //no id output from BD
    wire                      [31:0] eth_dma_axi4_aw_addr;
    wire                       [7:0] eth_dma_axi4_aw_len;
    wire                       [2:0] eth_dma_axi4_aw_size;
    wire                       [1:0] eth_dma_axi4_aw_burst;
    wire                             eth_dma_axi4_aw_lock;
    wire                       [3:0] eth_dma_axi4_aw_cache;
    wire                       [2:0] eth_dma_axi4_aw_prot;
    wire                       [3:0] eth_dma_axi4_aw_qos;
    wire                             eth_dma_axi4_w_ready;
    wire                             eth_dma_axi4_w_valid;
    wire                     [127:0] eth_dma_axi4_w_data;
    wire                      [15:0] eth_dma_axi4_w_strb;
    wire                             eth_dma_axi4_w_last;
    wire                             eth_dma_axi4_b_ready;
    wire                             eth_dma_axi4_b_valid;
    wire                       [3:0] eth_dma_axi4_b_id;
    wire                       [1:0] eth_dma_axi4_b_resp;
    wire                             eth_dma_axi4_ar_ready;
    wire                             eth_dma_axi4_ar_valid;
    wire                       [3:0] eth_dma_axi4_ar_id = 4'h0; //no id output from BD;
    wire                      [31:0] eth_dma_axi4_ar_addr;
    wire                       [7:0] eth_dma_axi4_ar_len;
    wire                       [2:0] eth_dma_axi4_ar_size;
    wire                       [1:0] eth_dma_axi4_ar_burst;
    wire                             eth_dma_axi4_ar_lock;
    wire                       [3:0] eth_dma_axi4_ar_cache;
    wire                       [2:0] eth_dma_axi4_ar_prot;
    wire                       [3:0] eth_dma_axi4_ar_qos;
    wire                             eth_dma_axi4_r_ready;
    wire                             eth_dma_axi4_r_valid;
    wire                       [3:0] eth_dma_axi4_r_id;
    wire                     [127:0] eth_dma_axi4_r_data;
    wire                       [1:0] eth_dma_axi4_r_resp;
    wire                             eth_dma_axi4_r_last;

    //interrupts
    wire irq_axi_ethernet;
    wire irq_axi_dma_mm2s;
    wire irq_axi_dma_s2mm;
    wire irq_mac;



noc_link_par_phy #(
    .NOC_ASYNC_FIFO_AWIDTH(NOC_ASYNC_FIFO_AWIDTH),
    .NOC_ASYNC_FIFO_PACKET_SIZE(NOC_ASYNC_FIFO_PACKET_SIZE)
) i_noc_link_par_phy_eth (
    .clk_i                (clk_axi_i),
    .rst_q_i              (reset_n_i),
    .rx_fifo_empty_o      (noclnk_eth_rx_flit_avail_n_s),
    .rx_fifo_read_addr_o  (noc_fifo_eth_in_raddr_o),
    .rx_fifo_read_data_i  (noc_fifo_eth_in_data_i),
    .rx_fifo_write_addr_i (noc_fifo_eth_in_waddr_i),
    .rx_header_o          (noclnk_eth_rx_header_s),
    .rx_payload_o         (noclnk_eth_rx_payload_s),
    .rx_rdreq_i           (noclnk_eth_rx_rdreq_s),
    .testmode_i           (1'b0),
    .tx_fifo_read_addr_i  (noc_fifo_eth_out_raddr_i),
    .tx_fifo_read_data_o  (noc_fifo_eth_out_data_o),
    .tx_fifo_write_addr_o (noc_fifo_eth_out_waddr_o),
    .tx_header_i          (noclnk_eth_tx_header_s),
    .tx_payload_i         (noclnk_eth_tx_payload_s),
    .tx_stall_o           (noclnk_eth_tx_stall_s),
    .tx_wrreq_i           (noclnk_eth_tx_wrreq_s)
);

nocif i_nocif_eth (
    .clk_i                (clk_axi_i),
    .flit_avail_q_i       (noclnk_eth_rx_flit_avail_n_s),
    .header_i             (noclnk_eth_rx_header_s),
    .header_o             (noclnk_eth_tx_header_s),
    .mod_addr_i           (eth_tx_mod_addr_s),
    .mod_addr_o           (eth_rx_mod_addr_s),
    .mod_burst_i          (eth_tx_mod_burst_s),
    .mod_burst_o          (eth_rx_mod_burst_s),
    .mod_arq_i            (eth_tx_mod_arq_s),
    .mod_arq_o            (eth_rx_mod_arq_s),
    .mod_bsel_i           (eth_tx_mod_bsel_s),
    .mod_bsel_o           (eth_rx_mod_bsel_s),
    .mod_data0_i          (eth_tx_mod_data0_s),
    .mod_data0_o          (eth_rx_mod_data0_s),
    .mod_data1_i          (eth_tx_mod_data1_s),
    .mod_data1_o          (eth_rx_mod_data1_s),
    .mod_mode_i           (eth_tx_mod_mode_s),
    .mod_mode_o           (eth_rx_mod_mode_s),
    .mod_stall_i          (eth_rx_mod_stall_s),
    .mod_stall_o          (eth_tx_mod_stall_s),
    .mod_wrreq_i          (eth_tx_mod_wrreq_s),
    .mod_wrreq_o          (eth_rx_mod_wrreq_s),
    .payload_i            (noclnk_eth_rx_payload_s),
    .payload_o            (noclnk_eth_tx_payload_s),
    .rdreq_o              (noclnk_eth_rx_rdreq_s),
    .reset_q_i            (reset_n_i),
    .src_chip_x_coord_i   (eth_tx_src_chip_x_coord_s),
    .src_chip_x_coord_o   (eth_rx_src_chip_x_coord_s),
    .src_chip_y_coord_i   (eth_tx_src_chip_y_coord_s),
    .src_chip_y_coord_o   (eth_rx_src_chip_y_coord_s),
    .src_chip_z_coord_i   (eth_tx_src_chip_z_coord_s),
    .src_chip_z_coord_o   (eth_rx_src_chip_z_coord_s),
    .src_mod_x_coord_i    (eth_tx_src_mod_x_coord_s),
    .src_mod_x_coord_o    (eth_rx_src_mod_x_coord_s),
    .src_mod_y_coord_i    (eth_tx_src_mod_y_coord_s),
    .src_mod_y_coord_o    (eth_rx_src_mod_y_coord_s),
    .src_mod_z_coord_i    (eth_tx_src_mod_z_coord_s),
    .src_mod_z_coord_o    (eth_rx_src_mod_z_coord_s),
    .stall_i              (noclnk_eth_tx_stall_s),
    .trg_chip_x_coord_i   (eth_tx_trg_chip_x_coord_s),
    .trg_chip_x_coord_o   (eth_rx_trg_chip_x_coord_s),
    .trg_chip_y_coord_i   (eth_tx_trg_chip_y_coord_s),
    .trg_chip_y_coord_o   (eth_rx_trg_chip_y_coord_s),
    .trg_chip_z_coord_i   (eth_tx_trg_chip_z_coord_s),
    .trg_chip_z_coord_o   (eth_rx_trg_chip_z_coord_s),
    .trg_mod_x_coord_i    (eth_tx_trg_mod_x_coord_s),
    .trg_mod_x_coord_o    (eth_rx_trg_mod_x_coord_s),
    .trg_mod_y_coord_i    (eth_tx_trg_mod_y_coord_s),
    .trg_mod_y_coord_o    (eth_rx_trg_mod_y_coord_s),
    .trg_mod_z_coord_i    (eth_tx_trg_mod_z_coord_s),
    .trg_mod_z_coord_o    (eth_rx_trg_mod_z_coord_s),
    .wrreq_o              (noclnk_eth_tx_wrreq_s)
);



ethernet_fmc_rocket_core #(
    .ROCKET_USE_LOCAL_MEM         (ROCKET_USE_LOCAL_MEM),
    .ROCKET_MEM_DATA_SIZE         (ROCKET_MEM_DATA_SIZE),
    .ROCKET_MEM_ADDR_SIZE         (ROCKET_MEM_ADDR_SIZE),
    .ROCKET_REG_DATA_SIZE         (CORE_DMEM_DATA_SIZE),
    .ROCKET_REG_ADDR_SIZE         (CORE_DMEM_ADDR_SIZE)
) i_ethernet_fmc_rocket_core (
    .clk_i                        (clk_core_s),
    .reset_n_i                    (reset_core_n_s),
    
    .mem_en_o                     (rocket_mem_en),
    .mem_wben_o                   (rocket_mem_wben),
    .mem_addr_o                   (rocket_mem_addr),
    .mem_wdata_o                  (rocket_mem_wdata),
    .mem_rdata_i                  (rocket_mem_rdata),
    .mem_stall_i                  (1'b0),
    
    .rocket_noc_tx_wrreq_o        (rocket_noc_tx_wrreq_s),
    .rocket_noc_tx_burst_o        (rocket_noc_tx_burst_s),
    .rocket_noc_tx_bsel_o         (rocket_noc_tx_bsel_s),
    .rocket_noc_tx_src_chipid_o   (rocket_noc_tx_src_chipid_s),
    .rocket_noc_tx_src_modid_o    (rocket_noc_tx_src_modid_s),
    .rocket_noc_tx_trg_chipid_o   (rocket_noc_tx_trg_chipid_s),
    .rocket_noc_tx_trg_modid_o    (rocket_noc_tx_trg_modid_s),
    .rocket_noc_tx_mode_o         (rocket_noc_tx_mode_s),
    .rocket_noc_tx_addr_o         (rocket_noc_tx_addr_s),
    .rocket_noc_tx_data0_o        (rocket_noc_tx_data0_s),
    .rocket_noc_tx_data1_o        (rocket_noc_tx_data1_s),
    .rocket_noc_tx_stall_i        (rocket_noc_tx_stall_s),

    .rocket_noc_rx_wrreq_i        (rocket_noc_rx_wrreq_s),
    .rocket_noc_rx_burst_i        (rocket_noc_rx_burst_s),
    .rocket_noc_rx_bsel_i         (rocket_noc_rx_bsel_s),
    .rocket_noc_rx_src_chipid_i   (rocket_noc_rx_src_chipid_s),
    .rocket_noc_rx_src_modid_i    (rocket_noc_rx_src_modid_s),
    .rocket_noc_rx_trg_chipid_i   (rocket_noc_rx_trg_chipid_s),
    .rocket_noc_rx_trg_modid_i    (rocket_noc_rx_trg_modid_s),
    .rocket_noc_rx_mode_i         (rocket_noc_rx_mode_s),
    .rocket_noc_rx_addr_i         (rocket_noc_rx_addr_s),
    .rocket_noc_rx_data0_i        (rocket_noc_rx_data0_s),
    .rocket_noc_rx_data1_i        (rocket_noc_rx_data1_s),
    .rocket_noc_rx_stall_o        (rocket_noc_rx_stall_s),

    .rocket_mmio_axi4_ar_addr_o   (eth_mmio_axi4_ar_addr),
    .rocket_mmio_axi4_ar_burst_o  (eth_mmio_axi4_ar_burst),
    .rocket_mmio_axi4_ar_cache_o  (eth_mmio_axi4_ar_cache),
    .rocket_mmio_axi4_ar_id_o     (eth_mmio_axi4_ar_id),
    .rocket_mmio_axi4_ar_len_o    (eth_mmio_axi4_ar_len),
    .rocket_mmio_axi4_ar_lock_o   (eth_mmio_axi4_ar_lock),
    .rocket_mmio_axi4_ar_prot_o   (eth_mmio_axi4_ar_prot),
    .rocket_mmio_axi4_ar_qos_o    (eth_mmio_axi4_ar_qos),
    .rocket_mmio_axi4_ar_ready_i  (eth_mmio_axi4_ar_ready),
    .rocket_mmio_axi4_ar_size_o   (eth_mmio_axi4_ar_size),
    .rocket_mmio_axi4_ar_valid_o  (eth_mmio_axi4_ar_valid),
    .rocket_mmio_axi4_aw_addr_o   (eth_mmio_axi4_aw_addr),
    .rocket_mmio_axi4_aw_burst_o  (eth_mmio_axi4_aw_burst),
    .rocket_mmio_axi4_aw_cache_o  (eth_mmio_axi4_aw_cache),
    .rocket_mmio_axi4_aw_id_o     (eth_mmio_axi4_aw_id),
    .rocket_mmio_axi4_aw_len_o    (eth_mmio_axi4_aw_len),
    .rocket_mmio_axi4_aw_lock_o   (eth_mmio_axi4_aw_lock),
    .rocket_mmio_axi4_aw_prot_o   (eth_mmio_axi4_aw_prot),
    .rocket_mmio_axi4_aw_qos_o    (eth_mmio_axi4_aw_qos),
    .rocket_mmio_axi4_aw_ready_i  (eth_mmio_axi4_aw_ready),
    .rocket_mmio_axi4_aw_size_o   (eth_mmio_axi4_aw_size),
    .rocket_mmio_axi4_aw_valid_o  (eth_mmio_axi4_aw_valid),
    .rocket_mmio_axi4_b_ready_o   (eth_mmio_axi4_b_ready),
    .rocket_mmio_axi4_b_resp_i    (eth_mmio_axi4_b_resp),
    .rocket_mmio_axi4_b_valid_i   (eth_mmio_axi4_b_valid),
    .rocket_mmio_axi4_b_id_i      (eth_mmio_axi4_b_id),
    .rocket_mmio_axi4_r_data_i    (eth_mmio_axi4_r_data),
    .rocket_mmio_axi4_r_last_i    (eth_mmio_axi4_r_last),
    .rocket_mmio_axi4_r_ready_o   (eth_mmio_axi4_r_ready),
    .rocket_mmio_axi4_r_resp_i    (eth_mmio_axi4_r_resp),
    .rocket_mmio_axi4_r_valid_i   (eth_mmio_axi4_r_valid),
    .rocket_mmio_axi4_r_id_i      (eth_mmio_axi4_r_id),
    .rocket_mmio_axi4_w_data_o    (eth_mmio_axi4_w_data),
    .rocket_mmio_axi4_w_last_o    (eth_mmio_axi4_w_last),
    .rocket_mmio_axi4_w_ready_i   (eth_mmio_axi4_w_ready),
    .rocket_mmio_axi4_w_strb_o    (eth_mmio_axi4_w_strb),
    .rocket_mmio_axi4_w_valid_o   (eth_mmio_axi4_w_valid),

    .eth_dma_axi4_ar_addr_i       (eth_dma_axi4_ar_addr),
    .eth_dma_axi4_ar_burst_i      (eth_dma_axi4_ar_burst),
    .eth_dma_axi4_ar_cache_i      (eth_dma_axi4_ar_cache),
    .eth_dma_axi4_ar_len_i        (eth_dma_axi4_ar_len),
    .eth_dma_axi4_ar_lock_i       (eth_dma_axi4_ar_lock),
    .eth_dma_axi4_ar_prot_i       (eth_dma_axi4_ar_prot),
    .eth_dma_axi4_ar_qos_i        (eth_dma_axi4_ar_qos),
    .eth_dma_axi4_ar_ready_o      (eth_dma_axi4_ar_ready),
    .eth_dma_axi4_ar_size_i       (eth_dma_axi4_ar_size),
    .eth_dma_axi4_ar_valid_i      (eth_dma_axi4_ar_valid),
    .eth_dma_axi4_ar_id_i         (eth_dma_axi4_ar_id),
    .eth_dma_axi4_aw_addr_i       (eth_dma_axi4_aw_addr),
    .eth_dma_axi4_aw_burst_i      (eth_dma_axi4_aw_burst),
    .eth_dma_axi4_aw_cache_i      (eth_dma_axi4_aw_cache),
    .eth_dma_axi4_aw_len_i        (eth_dma_axi4_aw_len),
    .eth_dma_axi4_aw_lock_i       (eth_dma_axi4_aw_lock),
    .eth_dma_axi4_aw_prot_i       (eth_dma_axi4_aw_prot),
    .eth_dma_axi4_aw_qos_i        (eth_dma_axi4_aw_qos),
    .eth_dma_axi4_aw_ready_o      (eth_dma_axi4_aw_ready),
    .eth_dma_axi4_aw_size_i       (eth_dma_axi4_aw_size),
    .eth_dma_axi4_aw_valid_i      (eth_dma_axi4_aw_valid),
    .eth_dma_axi4_aw_id_i         (eth_dma_axi4_aw_id),
    .eth_dma_axi4_b_ready_i       (eth_dma_axi4_b_ready),
    .eth_dma_axi4_b_resp_o        (eth_dma_axi4_b_resp),
    .eth_dma_axi4_b_valid_o       (eth_dma_axi4_b_valid),
    .eth_dma_axi4_b_id_o          (eth_dma_axi4_b_id),
    .eth_dma_axi4_r_data_o        (eth_dma_axi4_r_data),
    .eth_dma_axi4_r_last_o        (eth_dma_axi4_r_last),
    .eth_dma_axi4_r_ready_i       (eth_dma_axi4_r_ready),
    .eth_dma_axi4_r_resp_o        (eth_dma_axi4_r_resp),
    .eth_dma_axi4_r_valid_o       (eth_dma_axi4_r_valid),
    .eth_dma_axi4_r_id_o          (eth_dma_axi4_r_id),
    .eth_dma_axi4_w_data_i        (eth_dma_axi4_w_data),
    .eth_dma_axi4_w_last_i        (eth_dma_axi4_w_last),
    .eth_dma_axi4_w_ready_o       (eth_dma_axi4_w_ready),
    .eth_dma_axi4_w_strb_i        (eth_dma_axi4_w_strb),
    .eth_dma_axi4_w_valid_i       (eth_dma_axi4_w_valid),

    .reg_en_o                     (rocket_tcu_reg_en),
    .reg_wben_o                   (rocket_tcu_reg_wben),
    .reg_addr_o                   (rocket_tcu_reg_addr),
    .reg_wdata_o                  (rocket_tcu_reg_wdata),
    .reg_rdata_i                  (rocket_tcu_reg_rdata),
    .reg_stall_i                  (rocket_tcu_reg_stall),
    
    .tcu_mem_en_i                 (tcu_mem_en),
    .tcu_mem_req_i                (tcu_mem_req),
    .tcu_mem_wben_i               (tcu_mem_wben),
    .tcu_mem_addr_i               (tcu_mem_addr),
    .tcu_mem_wdata_i              (tcu_mem_wdata),
    .tcu_mem_rdata_o              (tcu_mem_rdata),
    .tcu_mem_rdata_avail_o        (tcu_mem_rdata_avail),
    .tcu_mem_wdata_infifo_o       (tcu_mem_wdata_infifo),
    .tcu_mem_wabort_i             (tcu_mem_wabort),
    .tcu_mem_wstall_o             (tcu_mem_wstall),
    .tcu_mem_rstall_o             (tcu_mem_rstall),
    .tcu_mem_access_i             (tcu_status[5] | tcu_status[3] | tcu_status[0]),    //any read access to memory

    .ext_int1_i                   (rocket_ext_int1),
    .ext_int2_i                   (rocket_ext_int2),
    .ext_int3_i                   (irq_axi_ethernet),
    .ext_int4_i                   (irq_axi_dma_mm2s),
    .ext_int5_i                   (irq_axi_dma_s2mm),
    .ext_int6_i                   (irq_mac),

    .uart_tx                      (uart_tx_o),
    .uart_rx                      (uart_rx_i),

    .tcu_mem_axi4_error_o         (tcu_mem_axi4_error),
    .axi4_mem_bridge_error_o      (axi4_mem_bridge_error),

    .rocket_trace_enabled_i       (rocket_trace_enabled),
    .rocket_trace_ptr_o           (rocket_trace_ptr),
    .rocket_trace_count_o         (rocket_trace_count),

    .jtag_tck_i                   (jtag_tck_i),
    .jtag_tms_i                   (jtag_tms_i),
    .jtag_tdi_i                   (jtag_tdi_i),
    .jtag_tdo_o                   (jtag_tdo_o),
    .jtag_tdo_en_o                (jtag_tdo_en_o)
);


generate
if (ROCKET_USE_LOCAL_MEM) begin: SPM
    mem_sp_wrap #(
        .MEM_TYPE     ("ultra"),
        .MEM_DATAWIDTH(IMEM_DATA_SIZE),
        .MEM_ADDRWIDTH(IMEM_ADDR_SIZE)
    ) mem (
        .clk        (clk_axi_i),
        .reset      (~reset_n_i),

        //Core port
        .en         (rocket_tcu_mem_en),
        .we         (rocket_tcu_mem_wben),
        .addr       (rocket_tcu_mem_addr[IMEM_ADDR_SIZE+LOG_IMEM_DATA_BYTES-1:LOG_IMEM_DATA_BYTES]),
        .din        (rocket_tcu_mem_wdata),
        .dout       (rocket_tcu_mem_rdata)
    );
end
else begin: NO_SPM
    assign rocket_tcu_mem_rdata = {IMEM_DATA_SIZE{1'b0}};
end
endgenerate



assign eth_rx_src_chipid_s = {eth_rx_src_chip_x_coord_s, eth_rx_src_chip_y_coord_s, eth_rx_src_chip_z_coord_s};
assign eth_rx_src_modid_s = {eth_rx_src_mod_x_coord_s, eth_rx_src_mod_y_coord_s, eth_rx_src_mod_z_coord_s};
assign eth_rx_trg_chipid_s = {eth_rx_trg_chip_x_coord_s, eth_rx_trg_chip_y_coord_s, eth_rx_trg_chip_z_coord_s};
assign eth_rx_trg_modid_s = {eth_rx_trg_mod_x_coord_s, eth_rx_trg_mod_y_coord_s, eth_rx_trg_mod_z_coord_s};

assign {eth_tx_src_chip_x_coord_s, eth_tx_src_chip_y_coord_s, eth_tx_src_chip_z_coord_s} = eth_tx_src_chipid_s;
assign {eth_tx_src_mod_x_coord_s, eth_tx_src_mod_y_coord_s, eth_tx_src_mod_z_coord_s} = eth_tx_src_modid_s;
assign {eth_tx_trg_chip_x_coord_s, eth_tx_trg_chip_y_coord_s, eth_tx_trg_chip_z_coord_s} = eth_tx_trg_chipid_s;
assign {eth_tx_trg_mod_x_coord_s, eth_tx_trg_mod_y_coord_s, eth_tx_trg_mod_z_coord_s} = eth_tx_trg_modid_s;



tcu_top #(
    .TCU_ENABLE_CMDS            (1),
    .TCU_ENABLE_VIRT_ADDR       (1),
    .TCU_ENABLE_VIRT_PES        (1),
    .TCU_ENABLE_PMP             (!ROCKET_USE_LOCAL_MEM),
    .TCU_ENABLE_DRAM            (1),
    .TCU_ENABLE_MEM_ADDR_ALIGN  (0),
    .TCU_ENABLE_LOG             (1),
    .TCU_ENABLE_PRINT           (1),
    .TCU_REGADDR_CORE_REQ_INT   (TCU_REGADDR_CORE_CFG_START + 'h8),  //first ext. interrupt of Rocket core
    .TCU_REGADDR_TIMER_INT      (TCU_REGADDR_CORE_CFG_START + 'h10), //second ext. interrupt
    .HOME_MODID                 (HOME_MODID),
    .CLKFREQ_MHZ                (CLKFREQ_MHZ),
    .CORE_DMEM_DATA_SIZE        (CORE_DMEM_DATA_SIZE),
    .CORE_DMEM_ADDR_SIZE        (CORE_DMEM_ADDR_SIZE),
    .CORE_DMEM_BSEL_SIZE        (CORE_DMEM_BSEL_SIZE),
    .CORE_IMEM_DATA_SIZE        (CORE_IMEM_DATA_SIZE),
    .CORE_IMEM_ADDR_SIZE        (CORE_IMEM_ADDR_SIZE),
    .CORE_IMEM_BSEL_SIZE        (CORE_IMEM_BSEL_SIZE),
    .DMEM_DATA_SIZE             (DMEM_DATA_SIZE),
    .DMEM_ADDR_SIZE             (DMEM_ADDR_SIZE),
    .DMEM_BSEL_SIZE             (DMEM_BSEL_SIZE),
    .IMEM_DATA_SIZE             (ROCKET_MEM_DATA_SIZE),
    .IMEM_ADDR_SIZE             (ROCKET_MEM_ADDR_SIZE),
    .IMEM_BSEL_SIZE             (ROCKET_MEM_BSEL_SIZE),
    .DMEM_START_ADDR            (DMEM_START_ADDR),
    .DMEM_SIZE                  (DMEM_SIZE),
    .IMEM_START_ADDR            (IMEM_START_ADDR),
    .IMEM_SIZE                  (IMEM_SIZE),
    .NOCMUX_TX_IF1_PRIO         (0),
    .NOCMUX_RX_IF1_PRIO         (0),
    .NOCMUX_RX_IF1_ADDR_START   (32'h0),        //tcu_ctrl has full access
    .NOCMUX_RX_IF1_ADDR_END     (32'hFFFFFFFF),
    .NOCMUX_RX_IF1_ONLY_MODE_2  (0),            //and takes all packets
    .NOCMUX_RX_IF2_ADDR_START   (32'h0),        //Rocket could be mapped to full address range
    .NOCMUX_RX_IF2_ADDR_END     (32'hFFFFFFFF),
    .NOCMUX_RX_IF2_ONLY_MODE_2  (1)             //Rocket mem interface only takes packets with mode _2
) i_tcu_top (
    .clk_i                      (clk_axi_i),
    .reset_n_i                  (reset_n_i),

    .tcu_noc_rx_wrreq_i         (eth_rx_mod_wrreq_s),
    .tcu_noc_rx_burst_i         (eth_rx_mod_burst_s),
    .tcu_noc_rx_arq_i           (eth_rx_mod_arq_s),
    .tcu_noc_rx_bsel_i          (eth_rx_mod_bsel_s),
    .tcu_noc_rx_src_chipid_i    (eth_rx_src_chipid_s),
    .tcu_noc_rx_src_modid_i     (eth_rx_src_modid_s),
    .tcu_noc_rx_trg_chipid_i    (eth_rx_trg_chipid_s),
    .tcu_noc_rx_trg_modid_i     (eth_rx_trg_modid_s),
    .tcu_noc_rx_mode_i          (eth_rx_mod_mode_s),
    .tcu_noc_rx_addr_i          (eth_rx_mod_addr_s),
    .tcu_noc_rx_data0_i         (eth_rx_mod_data0_s),
    .tcu_noc_rx_data1_i         (eth_rx_mod_data1_s),
    .tcu_noc_rx_stall_o         (eth_rx_mod_stall_s),

    .tcu_noc_tx_wrreq_o         (eth_tx_mod_wrreq_s),
    .tcu_noc_tx_burst_o         (eth_tx_mod_burst_s),
    .tcu_noc_tx_arq_o           (eth_tx_mod_arq_s),
    .tcu_noc_tx_bsel_o          (eth_tx_mod_bsel_s),
    .tcu_noc_tx_src_chipid_o    (eth_tx_src_chipid_s),
    .tcu_noc_tx_src_modid_o     (eth_tx_src_modid_s),
    .tcu_noc_tx_trg_chipid_o    (eth_tx_trg_chipid_s),
    .tcu_noc_tx_trg_modid_o     (eth_tx_trg_modid_s),
    .tcu_noc_tx_mode_o          (eth_tx_mod_mode_s),
    .tcu_noc_tx_addr_o          (eth_tx_mod_addr_s),
    .tcu_noc_tx_data0_o         (eth_tx_mod_data0_s),
    .tcu_noc_tx_data1_o         (eth_tx_mod_data1_s),
    .tcu_noc_tx_stall_i         (eth_tx_mod_stall_s),

    .tcu_byp_noc_tx_wrreq_i     (rocket_noc_tx_wrreq_s),
    .tcu_byp_noc_tx_burst_i     (rocket_noc_tx_burst_s),
    .tcu_byp_noc_tx_arq_i       (1'b0), //will be set in nocif
    .tcu_byp_noc_tx_bsel_i      (rocket_noc_tx_bsel_s),
    .tcu_byp_noc_tx_src_chipid_i(rocket_noc_tx_src_chipid_s),
    .tcu_byp_noc_tx_src_modid_i (rocket_noc_tx_src_modid_s),
    .tcu_byp_noc_tx_trg_chipid_i(rocket_noc_tx_trg_chipid_s),
    .tcu_byp_noc_tx_trg_modid_i (rocket_noc_tx_trg_modid_s),
    .tcu_byp_noc_tx_mode_i      (rocket_noc_tx_mode_s),
    .tcu_byp_noc_tx_addr_i      (rocket_noc_tx_addr_s),
    .tcu_byp_noc_tx_data0_i     (rocket_noc_tx_data0_s),
    .tcu_byp_noc_tx_data1_i     (rocket_noc_tx_data1_s),
    .tcu_byp_noc_tx_stall_o     (rocket_noc_tx_stall_s),

    .tcu_byp_noc_rx_wrreq_o     (rocket_noc_rx_wrreq_s),
    .tcu_byp_noc_rx_burst_o     (rocket_noc_rx_burst_s),
    .tcu_byp_noc_rx_arq_o       (),
    .tcu_byp_noc_rx_bsel_o      (rocket_noc_rx_bsel_s),
    .tcu_byp_noc_rx_src_chipid_o(rocket_noc_rx_src_chipid_s),
    .tcu_byp_noc_rx_src_modid_o (rocket_noc_rx_src_modid_s),
    .tcu_byp_noc_rx_trg_chipid_o(rocket_noc_rx_trg_chipid_s),
    .tcu_byp_noc_rx_trg_modid_o (rocket_noc_rx_trg_modid_s),
    .tcu_byp_noc_rx_mode_o      (rocket_noc_rx_mode_s),
    .tcu_byp_noc_rx_addr_o      (rocket_noc_rx_addr_s),
    .tcu_byp_noc_rx_data0_o     (rocket_noc_rx_data0_s),
    .tcu_byp_noc_rx_data1_o     (rocket_noc_rx_data1_s),
    .tcu_byp_noc_rx_stall_i     (rocket_noc_rx_stall_s),
    
    .core_dmem_in_en_i          (rocket_tcu_reg_en),
    .core_dmem_in_wben_i        (rocket_tcu_reg_wben),
    .core_dmem_in_addr_i        (rocket_tcu_reg_addr),
    .core_dmem_in_wdata_i       (rocket_tcu_reg_wdata),
    .core_dmem_in_rdata_o       (rocket_tcu_reg_rdata),
    .core_dmem_in_stall_o       (rocket_tcu_reg_stall),

    .core_imem_in_en_i          (rocket_mem_en),
    .core_imem_in_wben_i        (rocket_mem_wben),
    .core_imem_in_addr_i        (rocket_mem_addr),
    .core_imem_in_wdata_i       (rocket_mem_wdata),
    .core_imem_in_rdata_o       (rocket_mem_rdata),
    .core_imem_in_stall_o       (),

    .core_dmem_out_en_o         (),  //unused
    .core_dmem_out_wben_o       (),
    .core_dmem_out_addr_o       (),
    .core_dmem_out_wdata_o      (),
    .core_dmem_out_rdata_i      ({DMEM_DATA_SIZE{1'b0}}),
    .core_dmem_out_stall_i      (1'b0),

    .core_imem_out_en_o         (rocket_tcu_mem_en),
    .core_imem_out_wben_o       (rocket_tcu_mem_wben),
    .core_imem_out_addr_o       (rocket_tcu_mem_addr),
    .core_imem_out_wdata_o      (rocket_tcu_mem_wdata),
    .core_imem_out_rdata_i      (rocket_tcu_mem_rdata),
    .core_imem_out_stall_i      (1'b0),

    .tcu_dmem_en_o              (),  //unused
    .tcu_dmem_req_o             (),
    .tcu_dmem_wben_o            (),
    .tcu_dmem_addr_o            (),
    .tcu_dmem_wdata_o           (),
    .tcu_dmem_rdata_i           ({DMEM_DATA_SIZE{1'b0}}),
    .tcu_dmem_rdata_avail_i     (1'b0),
    .tcu_dmem_wdata_infifo_i    (1'b0),
    .tcu_dmem_wabort_o          (),
    .tcu_dmem_wstall_i          (1'b0),
    .tcu_dmem_rstall_i          (1'b0),

    .tcu_imem_en_o              (tcu_mem_en),
    .tcu_imem_req_o             (tcu_mem_req),
    .tcu_imem_wben_o            (tcu_mem_wben),
    .tcu_imem_addr_o            (tcu_mem_addr),
    .tcu_imem_wdata_o           (tcu_mem_wdata),
    .tcu_imem_rdata_i           (tcu_mem_rdata),
    .tcu_imem_rdata_avail_i     (tcu_mem_rdata_avail),
    .tcu_imem_wdata_infifo_i    (tcu_mem_wdata_infifo),
    .tcu_imem_wabort_o          (tcu_mem_wabort),
    .tcu_imem_wstall_i          (tcu_mem_wstall),
    .tcu_imem_rstall_i          (tcu_mem_rstall),

    .config_mem_en_o            (rocket_config_en),
    .config_mem_wben_o          (rocket_config_wben),
    .config_mem_addr_o          (rocket_config_addr),
    .config_mem_wdata_o         (rocket_config_wdata),
    .config_mem_rdata_i         (rocket_config_rdata),

    .tcu_status_o               (tcu_status),

    .home_chipid_i              (home_chipid_i),

    .print_chipid_i             (host_chipid_i),
    .print_modid_i              (MODID_ETH)
);



generate
if (ETH_INCLUDE_SHARED_LOGIC) begin: AXI_ETH
    bd_axi_dma_eth_fmc_wrapper i_bd_axi_dma_eth_fmc_wrapper (
        //AXI clock
        .aclk_0                 (clk_axi_i),
        .aresetn_0              (reset_n_i),

        //AXI Ethernet IP clocks
        .gtx_clk_0              (gtx_clk_i),
        .ref_clk_0              (ref_clk_i),

        //interrupts to Rocket core
        .interrupt_axi_ethernet (irq_axi_ethernet),
        .mm2s_dma_introut       (irq_axi_dma_mm2s),
        .s2mm_dma_introut       (irq_axi_dma_s2mm),
        .mac_irq_0              (irq_mac),

        //AXI4 to L2 FB of Rocket core
        .M00_AXI_0_araddr       (eth_dma_axi4_ar_addr),
        .M00_AXI_0_arburst      (eth_dma_axi4_ar_burst),
        .M00_AXI_0_arcache      (eth_dma_axi4_ar_cache),
        .M00_AXI_0_arlen        (eth_dma_axi4_ar_len),
        .M00_AXI_0_arlock       (eth_dma_axi4_ar_lock),
        .M00_AXI_0_arprot       (eth_dma_axi4_ar_prot),
        .M00_AXI_0_arqos        (eth_dma_axi4_ar_qos),
        .M00_AXI_0_arready      (eth_dma_axi4_ar_ready),
        .M00_AXI_0_arsize       (eth_dma_axi4_ar_size),
        .M00_AXI_0_arvalid      (eth_dma_axi4_ar_valid),
        .M00_AXI_0_awaddr       (eth_dma_axi4_aw_addr),
        .M00_AXI_0_awburst      (eth_dma_axi4_aw_burst),
        .M00_AXI_0_awcache      (eth_dma_axi4_aw_cache),
        .M00_AXI_0_awlen        (eth_dma_axi4_aw_len),
        .M00_AXI_0_awlock       (eth_dma_axi4_aw_lock),
        .M00_AXI_0_awprot       (eth_dma_axi4_aw_prot),
        .M00_AXI_0_awqos        (eth_dma_axi4_aw_qos),
        .M00_AXI_0_awready      (eth_dma_axi4_aw_ready),
        .M00_AXI_0_awsize       (eth_dma_axi4_aw_size),
        .M00_AXI_0_awvalid      (eth_dma_axi4_aw_valid),
        .M00_AXI_0_bready       (eth_dma_axi4_b_ready),
        .M00_AXI_0_bresp        (eth_dma_axi4_b_resp),
        .M00_AXI_0_bvalid       (eth_dma_axi4_b_valid),
        .M00_AXI_0_rdata        (eth_dma_axi4_r_data),
        .M00_AXI_0_rlast        (eth_dma_axi4_r_last),
        .M00_AXI_0_rready       (eth_dma_axi4_r_ready),
        .M00_AXI_0_rresp        (eth_dma_axi4_r_resp),
        .M00_AXI_0_rvalid       (eth_dma_axi4_r_valid),
        .M00_AXI_0_wdata        (eth_dma_axi4_w_data),
        .M00_AXI_0_wlast        (eth_dma_axi4_w_last),
        .M00_AXI_0_wready       (eth_dma_axi4_w_ready),
        .M00_AXI_0_wstrb        (eth_dma_axi4_w_strb),
        .M00_AXI_0_wvalid       (eth_dma_axi4_w_valid),

        //AXI4 from Rocket core
        .S00_AXI_0_araddr       ({8'h0, eth_mmio_axi4_ar_addr[23:0]}),  //upper addr bits are only for Rocket MMIO
        .S00_AXI_0_arburst      (eth_mmio_axi4_ar_burst),
        .S00_AXI_0_arcache      (eth_mmio_axi4_ar_cache),
        .S00_AXI_0_arid         (eth_mmio_axi4_ar_id),
        .S00_AXI_0_arlen        (eth_mmio_axi4_ar_len),
        .S00_AXI_0_arlock       (eth_mmio_axi4_ar_lock),
        .S00_AXI_0_arprot       (eth_mmio_axi4_ar_prot),
        .S00_AXI_0_arqos        (eth_mmio_axi4_ar_qos),
        .S00_AXI_0_arready      (eth_mmio_axi4_ar_ready),
        .S00_AXI_0_arsize       (eth_mmio_axi4_ar_size),
        .S00_AXI_0_arvalid      (eth_mmio_axi4_ar_valid),
        .S00_AXI_0_awaddr       ({8'h0, eth_mmio_axi4_aw_addr[23:0]}),  //upper addr bits are only for Rocket MMIO
        .S00_AXI_0_awburst      (eth_mmio_axi4_aw_burst),
        .S00_AXI_0_awcache      (eth_mmio_axi4_aw_cache),
        .S00_AXI_0_awid         (eth_mmio_axi4_aw_id),
        .S00_AXI_0_awlen        (eth_mmio_axi4_aw_len),
        .S00_AXI_0_awlock       (eth_mmio_axi4_aw_lock),
        .S00_AXI_0_awprot       (eth_mmio_axi4_aw_prot),
        .S00_AXI_0_awqos        (eth_mmio_axi4_aw_qos),
        .S00_AXI_0_awready      (eth_mmio_axi4_aw_ready),
        .S00_AXI_0_awsize       (eth_mmio_axi4_aw_size),
        .S00_AXI_0_awvalid      (eth_mmio_axi4_aw_valid),
        .S00_AXI_0_bid          (eth_mmio_axi4_b_id),
        .S00_AXI_0_bready       (eth_mmio_axi4_b_ready),
        .S00_AXI_0_bresp        (eth_mmio_axi4_b_resp),
        .S00_AXI_0_bvalid       (eth_mmio_axi4_b_valid),
        .S00_AXI_0_rdata        (eth_mmio_axi4_r_data),
        .S00_AXI_0_rid          (eth_mmio_axi4_r_id),
        .S00_AXI_0_rlast        (eth_mmio_axi4_r_last),
        .S00_AXI_0_rready       (eth_mmio_axi4_r_ready),
        .S00_AXI_0_rresp        (eth_mmio_axi4_r_resp),
        .S00_AXI_0_rvalid       (eth_mmio_axi4_r_valid),
        .S00_AXI_0_wdata        (eth_mmio_axi4_w_data),
        .S00_AXI_0_wlast        (eth_mmio_axi4_w_last),
        .S00_AXI_0_wready       (eth_mmio_axi4_w_ready),
        .S00_AXI_0_wstrb        (eth_mmio_axi4_w_strb),
        .S00_AXI_0_wvalid       (eth_mmio_axi4_w_valid),

        //MDIO
        .mdio_0_mdc             (mdio_mdc_o),
        .mdio_0_mdio_io         (mdio_io),

        //PHY reset
        .phy_rst_n_0            (phy_reset_n),

        //RGMII
        .rgmii_0_rd             (rgmii_rxd),
        .rgmii_0_rx_ctl         (rgmii_rx_ctl),
        .rgmii_0_rxc            (rgmii_rxc),
        .rgmii_0_td             (rgmii_txd),
        .rgmii_0_tx_ctl         (rgmii_tx_ctl),
        .rgmii_0_txc            (rgmii_txc)
    );
end
else begin: AXI_ETH_NSL
    bd_axi_dma_eth_fmc_nsl_wrapper i_bd_axi_dma_eth_fmc_nsl_wrapper (
        //AXI clock
        .aclk_0                 (clk_axi_i),
        .aresetn_0              (reset_n_i),

        //AXI Ethernet IP clocks
        .gtx_clk_0              (gtx_clk_i),

        //interrupts to Rocket core
        .interrupt_axi_ethernet (irq_axi_ethernet),
        .mm2s_dma_introut       (irq_axi_dma_mm2s),
        .s2mm_dma_introut       (irq_axi_dma_s2mm),
        .mac_irq_0              (irq_mac),

        //AXI4 to L2 FB of Rocket core
        .M00_AXI_0_araddr       (eth_dma_axi4_ar_addr),
        .M00_AXI_0_arburst      (eth_dma_axi4_ar_burst),
        .M00_AXI_0_arcache      (eth_dma_axi4_ar_cache),
        .M00_AXI_0_arlen        (eth_dma_axi4_ar_len),
        .M00_AXI_0_arlock       (eth_dma_axi4_ar_lock),
        .M00_AXI_0_arprot       (eth_dma_axi4_ar_prot),
        .M00_AXI_0_arqos        (eth_dma_axi4_ar_qos),
        .M00_AXI_0_arready      (eth_dma_axi4_ar_ready),
        .M00_AXI_0_arsize       (eth_dma_axi4_ar_size),
        .M00_AXI_0_arvalid      (eth_dma_axi4_ar_valid),
        .M00_AXI_0_awaddr       (eth_dma_axi4_aw_addr),
        .M00_AXI_0_awburst      (eth_dma_axi4_aw_burst),
        .M00_AXI_0_awcache      (eth_dma_axi4_aw_cache),
        .M00_AXI_0_awlen        (eth_dma_axi4_aw_len),
        .M00_AXI_0_awlock       (eth_dma_axi4_aw_lock),
        .M00_AXI_0_awprot       (eth_dma_axi4_aw_prot),
        .M00_AXI_0_awqos        (eth_dma_axi4_aw_qos),
        .M00_AXI_0_awready      (eth_dma_axi4_aw_ready),
        .M00_AXI_0_awsize       (eth_dma_axi4_aw_size),
        .M00_AXI_0_awvalid      (eth_dma_axi4_aw_valid),
        .M00_AXI_0_bready       (eth_dma_axi4_b_ready),
        .M00_AXI_0_bresp        (eth_dma_axi4_b_resp),
        .M00_AXI_0_bvalid       (eth_dma_axi4_b_valid),
        .M00_AXI_0_rdata        (eth_dma_axi4_r_data),
        .M00_AXI_0_rlast        (eth_dma_axi4_r_last),
        .M00_AXI_0_rready       (eth_dma_axi4_r_ready),
        .M00_AXI_0_rresp        (eth_dma_axi4_r_resp),
        .M00_AXI_0_rvalid       (eth_dma_axi4_r_valid),
        .M00_AXI_0_wdata        (eth_dma_axi4_w_data),
        .M00_AXI_0_wlast        (eth_dma_axi4_w_last),
        .M00_AXI_0_wready       (eth_dma_axi4_w_ready),
        .M00_AXI_0_wstrb        (eth_dma_axi4_w_strb),
        .M00_AXI_0_wvalid       (eth_dma_axi4_w_valid),

        //AXI4 from Rocket core
        .S00_AXI_0_araddr       ({8'h0, eth_mmio_axi4_ar_addr[23:0]}),  //upper addr bits are only for Rocket MMIO
        .S00_AXI_0_arburst      (eth_mmio_axi4_ar_burst),
        .S00_AXI_0_arcache      (eth_mmio_axi4_ar_cache),
        .S00_AXI_0_arid         (eth_mmio_axi4_ar_id),
        .S00_AXI_0_arlen        (eth_mmio_axi4_ar_len),
        .S00_AXI_0_arlock       (eth_mmio_axi4_ar_lock),
        .S00_AXI_0_arprot       (eth_mmio_axi4_ar_prot),
        .S00_AXI_0_arqos        (eth_mmio_axi4_ar_qos),
        .S00_AXI_0_arready      (eth_mmio_axi4_ar_ready),
        .S00_AXI_0_arsize       (eth_mmio_axi4_ar_size),
        .S00_AXI_0_arvalid      (eth_mmio_axi4_ar_valid),
        .S00_AXI_0_awaddr       ({8'h0, eth_mmio_axi4_aw_addr[23:0]}),  //upper addr bits are only for Rocket MMIO
        .S00_AXI_0_awburst      (eth_mmio_axi4_aw_burst),
        .S00_AXI_0_awcache      (eth_mmio_axi4_aw_cache),
        .S00_AXI_0_awid         (eth_mmio_axi4_aw_id),
        .S00_AXI_0_awlen        (eth_mmio_axi4_aw_len),
        .S00_AXI_0_awlock       (eth_mmio_axi4_aw_lock),
        .S00_AXI_0_awprot       (eth_mmio_axi4_aw_prot),
        .S00_AXI_0_awqos        (eth_mmio_axi4_aw_qos),
        .S00_AXI_0_awready      (eth_mmio_axi4_aw_ready),
        .S00_AXI_0_awsize       (eth_mmio_axi4_aw_size),
        .S00_AXI_0_awvalid      (eth_mmio_axi4_aw_valid),
        .S00_AXI_0_bid          (eth_mmio_axi4_b_id),
        .S00_AXI_0_bready       (eth_mmio_axi4_b_ready),
        .S00_AXI_0_bresp        (eth_mmio_axi4_b_resp),
        .S00_AXI_0_bvalid       (eth_mmio_axi4_b_valid),
        .S00_AXI_0_rdata        (eth_mmio_axi4_r_data),
        .S00_AXI_0_rid          (eth_mmio_axi4_r_id),
        .S00_AXI_0_rlast        (eth_mmio_axi4_r_last),
        .S00_AXI_0_rready       (eth_mmio_axi4_r_ready),
        .S00_AXI_0_rresp        (eth_mmio_axi4_r_resp),
        .S00_AXI_0_rvalid       (eth_mmio_axi4_r_valid),
        .S00_AXI_0_wdata        (eth_mmio_axi4_w_data),
        .S00_AXI_0_wlast        (eth_mmio_axi4_w_last),
        .S00_AXI_0_wready       (eth_mmio_axi4_w_ready),
        .S00_AXI_0_wstrb        (eth_mmio_axi4_w_strb),
        .S00_AXI_0_wvalid       (eth_mmio_axi4_w_valid),

        //MDIO
        .mdio_0_mdc             (mdio_mdc_o),
        .mdio_0_mdio_io         (mdio_io),

        //PHY reset
        .phy_rst_n_0            (phy_reset_n),

        //RGMII
        .rgmii_0_rd             (rgmii_rxd),
        .rgmii_0_rx_ctl         (rgmii_rx_ctl),
        .rgmii_0_rxc            (rgmii_rxc),
        .rgmii_0_td             (rgmii_txd),
        .rgmii_0_tx_ctl         (rgmii_tx_ctl),
        .rgmii_0_txc            (rgmii_txc)
    );
end
endgenerate





ethernet_fmc_regfile #(
    .ROCKET_MEM_ADDR_SIZE       (ROCKET_MEM_ADDR_SIZE)
) i_ethernet_fmc_regfile (
    .clk_i                      (clk_axi_i),
    .reset_n_i                  (reset_n_i),

    .config_en_i                (rocket_config_en),
    .config_wben_i              (rocket_config_wben),
    .config_addr_i              (rocket_config_addr),
    .config_wdata_i             (rocket_config_wdata),
    .config_rdata_o             (rocket_config_rdata),

    .rocket_en_o                (rocket_en),
    .rocket_ext_int1_o          (rocket_ext_int1),
    .rocket_ext_int2_o          (rocket_ext_int2),
    .tcu_mem_axi4_error_i       (tcu_mem_axi4_error),
    .axi4_mem_bridge_error_i    (axi4_mem_bridge_error),
    .rocket_trace_enabled_o     (rocket_trace_enabled),
    .rocket_trace_ptr_i         (rocket_trace_ptr),
    .rocket_trace_count_i       (rocket_trace_count)
);



ethernet_fmc_rocket_ctrl i_ethernet_fmc_rocket_ctrl (
    .clk_i           (clk_axi_i),
    .clk_core_o      (clk_core_s),
    .core_en_i       (rocket_en),
    .reset_core_n_o  (reset_core_n_s),
    .reset_n_i       (reset_n_i)
);


endmodule
