
module tcu_top #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"

    //---------------
    //general TCU settings
    ,parameter TCU_ENABLE_CMDS            = 1,  //enable unprivileged and external commands
    parameter TCU_ENABLE_VIRT_ADDR        = 0,  //enable support for virtual addresses
    parameter TCU_ENABLE_VIRT_PES         = 0,  //enable support for VPEs
    parameter TCU_ENABLE_PMP              = 0,  //if enabled, core mem access is translated to NoC requests according to EPs
    parameter TCU_ENABLE_DRAM             = 0,  //if enabled, read latency of mem via TCU-Mem interface > 1
    parameter TCU_ENABLE_NOC_INFIFO       = 0,  //enable additional input FIFO to hold NoC burst packets, automatically enabled if TCU_ENABLE_PMP=1
    parameter TCU_ENABLE_NOC_OUTFIFO      = 0,  //enable additional output FIFO to hold NoC burst packets, automatically enabled if TCU_ENABLE_PMP=1
    parameter TCU_ENABLE_MEM_ADDR_ALIGN   = 1,  //if enabled, TCU mem-map adjusts addr alignment according to local memory
    parameter TCU_ENABLE_LOG              = 0,  //if enabled, TCU writes debug messages to log mem
    parameter TCU_ENABLE_PRINT            = 0,  //if enabled, TCU can write print messages to Ethernet interface
    parameter TCU_REGADDR_CORE_REQ_INT    = TCU_REGADDR_CORE_CFG_START + 'h8,  //reg addr of core request interrupt
    parameter TCU_REGADDR_TIMER_INT       = TCU_REGADDR_CORE_CFG_START + 'h10, //reg addr of timer interrupt
    parameter CLKFREQ_MHZ                 = 100,

    //tile description
    parameter    [TILE_TYPE_SIZE-1:0] TILE_TYPE    = 0,
    parameter     [TILE_ISA_SIZE-1:0] TILE_ISA     = 0,
    parameter    [TILE_ATTR_SIZE-1:0] TILE_ATTR    = 0,
    parameter [TILE_MEMSIZE_SIZE-1:0] TILE_MEMSIZE = 0,

    //timeout when TCU is waiting for NoC or Mem, 0 to disable
    parameter [31:0] TIMEOUT_SEND_CYCLES  = CLKFREQ_MHZ*2000000,    //for sender
    parameter [31:0] TIMEOUT_RECV_CYCLES  = CLKFREQ_MHZ*1000000,    //for receiver

    //---------------
    //Mem settings
    parameter CORE_DMEM_DATA_SIZE         = 32,
    parameter CORE_DMEM_ADDR_SIZE         = 32,
    parameter CORE_DMEM_BSEL_SIZE         = CORE_DMEM_DATA_SIZE/8,
    parameter CORE_IMEM_DATA_SIZE         = 32,
    parameter CORE_IMEM_ADDR_SIZE         = 32,
    parameter CORE_IMEM_BSEL_SIZE         = CORE_IMEM_DATA_SIZE/8,
    parameter DMEM_DATA_SIZE              = 128,
    parameter DMEM_ADDR_SIZE              = 14,
    parameter DMEM_BSEL_SIZE              = DMEM_DATA_SIZE/8,
    parameter IMEM_DATA_SIZE              = 128,
    parameter IMEM_ADDR_SIZE              = 14,
    parameter IMEM_BSEL_SIZE              = IMEM_DATA_SIZE/8,
    parameter DMEM_START_ADDR             = 32'h00040000,
    parameter DMEM_SIZE                   = 'h40000,
    parameter IMEM_START_ADDR             = 32'h00000000,
    parameter IMEM_SIZE                   = 'h40000,

    //---------------
    //settings for TCU NoC MUX, see module tcu_noc_mux
    parameter NOCMUX_TX_IF1_PRIO          = 0,
    parameter NOCMUX_RX_IF1_PRIO          = 0,
    parameter NOCMUX_RX_IF1_ADDR_START    = 32'h0,
    parameter NOCMUX_RX_IF1_ADDR_END      = 32'hFFFFFFFF,
    parameter NOCMUX_RX_IF1_ONLY_MODE_2   = 0,
    parameter NOCMUX_RX_IF1_ONLY_HOMECHIP = 0,
    parameter NOCMUX_RX_IF2_ADDR_START    = 32'h0,
    parameter NOCMUX_RX_IF2_ADDR_END      = 32'hFFFFFFFF,
    parameter NOCMUX_RX_IF2_ONLY_MODE_2   = 0,
    parameter NOCMUX_RX_IF2_ONLY_HOMECHIP = 0
)(
    input  wire                           clk_i,
    input  wire                           reset_n_i,

    //---------------
    //TCU NoC IF
    input  wire                           tcu_noc_rx_wrreq_i,
    input  wire                           tcu_noc_rx_burst_i,
    input  wire                           tcu_noc_rx_arq_i,
    input  wire       [NOC_BSEL_SIZE-1:0] tcu_noc_rx_bsel_i,
    input  wire     [NOC_CHIPID_SIZE-1:0] tcu_noc_rx_src_chipid_i,
    input  wire      [NOC_MODID_SIZE-1:0] tcu_noc_rx_src_modid_i,
    input  wire     [NOC_CHIPID_SIZE-1:0] tcu_noc_rx_trg_chipid_i,
    input  wire      [NOC_MODID_SIZE-1:0] tcu_noc_rx_trg_modid_i,
    input  wire       [NOC_MODE_SIZE-1:0] tcu_noc_rx_mode_i,
    input  wire       [NOC_ADDR_SIZE-1:0] tcu_noc_rx_addr_i,
    input  wire       [NOC_DATA_SIZE-1:0] tcu_noc_rx_data0_i,
    input  wire       [NOC_DATA_SIZE-1:0] tcu_noc_rx_data1_i,
    output wire                           tcu_noc_rx_stall_o,

    output wire                           tcu_noc_tx_wrreq_o,
    output wire                           tcu_noc_tx_burst_o,
    output wire                           tcu_noc_tx_arq_o,
    output wire       [NOC_BSEL_SIZE-1:0] tcu_noc_tx_bsel_o,
    output wire     [NOC_CHIPID_SIZE-1:0] tcu_noc_tx_src_chipid_o,
    output wire      [NOC_MODID_SIZE-1:0] tcu_noc_tx_src_modid_o,
    output wire     [NOC_CHIPID_SIZE-1:0] tcu_noc_tx_trg_chipid_o,
    output wire      [NOC_MODID_SIZE-1:0] tcu_noc_tx_trg_modid_o,
    output wire       [NOC_MODE_SIZE-1:0] tcu_noc_tx_mode_o,
    output wire       [NOC_ADDR_SIZE-1:0] tcu_noc_tx_addr_o,
    output wire       [NOC_DATA_SIZE-1:0] tcu_noc_tx_data0_o,
    output wire       [NOC_DATA_SIZE-1:0] tcu_noc_tx_data1_o,
    input  wire                           tcu_noc_tx_stall_i,

    //---------------
    //TCU Bypass NoC IF
    input  wire                           tcu_byp_noc_tx_wrreq_i,
    input  wire                           tcu_byp_noc_tx_burst_i,
    input  wire                           tcu_byp_noc_tx_arq_i,
    input  wire       [NOC_BSEL_SIZE-1:0] tcu_byp_noc_tx_bsel_i,
    input  wire     [NOC_CHIPID_SIZE-1:0] tcu_byp_noc_tx_src_chipid_i,
    input  wire      [NOC_MODID_SIZE-1:0] tcu_byp_noc_tx_src_modid_i,
    input  wire     [NOC_CHIPID_SIZE-1:0] tcu_byp_noc_tx_trg_chipid_i,
    input  wire      [NOC_MODID_SIZE-1:0] tcu_byp_noc_tx_trg_modid_i,
    input  wire       [NOC_MODE_SIZE-1:0] tcu_byp_noc_tx_mode_i,
    input  wire       [NOC_ADDR_SIZE-1:0] tcu_byp_noc_tx_addr_i,
    input  wire       [NOC_DATA_SIZE-1:0] tcu_byp_noc_tx_data0_i,
    input  wire       [NOC_DATA_SIZE-1:0] tcu_byp_noc_tx_data1_i,
    output wire                           tcu_byp_noc_tx_stall_o,

    output wire                           tcu_byp_noc_rx_wrreq_o,
    output wire                           tcu_byp_noc_rx_burst_o,
    output wire                           tcu_byp_noc_rx_arq_o,
    output wire       [NOC_BSEL_SIZE-1:0] tcu_byp_noc_rx_bsel_o,
    output wire     [NOC_CHIPID_SIZE-1:0] tcu_byp_noc_rx_src_chipid_o,
    output wire      [NOC_MODID_SIZE-1:0] tcu_byp_noc_rx_src_modid_o,
    output wire     [NOC_CHIPID_SIZE-1:0] tcu_byp_noc_rx_trg_chipid_o,
    output wire      [NOC_MODID_SIZE-1:0] tcu_byp_noc_rx_trg_modid_o,
    output wire       [NOC_MODE_SIZE-1:0] tcu_byp_noc_rx_mode_o,
    output wire       [NOC_ADDR_SIZE-1:0] tcu_byp_noc_rx_addr_o,
    output wire       [NOC_DATA_SIZE-1:0] tcu_byp_noc_rx_data0_o,
    output wire       [NOC_DATA_SIZE-1:0] tcu_byp_noc_rx_data1_o,
    input  wire                           tcu_byp_noc_rx_stall_i,
    
    //---------------
    //Core DMEM IF (DMEM + REG)
    input  wire                           core_dmem_in_en_i,
    input  wire [CORE_DMEM_BSEL_SIZE-1:0] core_dmem_in_wben_i,
    input  wire [CORE_DMEM_ADDR_SIZE-1:0] core_dmem_in_addr_i,
    input  wire [CORE_DMEM_DATA_SIZE-1:0] core_dmem_in_wdata_i,
    output wire [CORE_DMEM_DATA_SIZE-1:0] core_dmem_in_rdata_o,
    output wire                           core_dmem_in_stall_o,

    //---------------
    //Core IMEM IF
    input  wire                           core_imem_in_en_i,
    input  wire [CORE_IMEM_BSEL_SIZE-1:0] core_imem_in_wben_i,
    input  wire [CORE_IMEM_ADDR_SIZE-1:0] core_imem_in_addr_i,
    input  wire [CORE_IMEM_DATA_SIZE-1:0] core_imem_in_wdata_i,
    output wire [CORE_IMEM_DATA_SIZE-1:0] core_imem_in_rdata_o,
    output wire                           core_imem_in_stall_o,

    //---------------
    //DMEM IF from core
    output wire                           core_dmem_out_en_o,
    output wire      [DMEM_BSEL_SIZE-1:0] core_dmem_out_wben_o,
    output wire      [DMEM_ADDR_SIZE-1:0] core_dmem_out_addr_o,
    output wire      [DMEM_DATA_SIZE-1:0] core_dmem_out_wdata_o,
    input  wire      [DMEM_DATA_SIZE-1:0] core_dmem_out_rdata_i,
    input  wire                           core_dmem_out_stall_i,

    //---------------
    //IMEM IF from core
    output wire                           core_imem_out_en_o,
    output wire      [IMEM_BSEL_SIZE-1:0] core_imem_out_wben_o,
    output wire      [IMEM_ADDR_SIZE-1:0] core_imem_out_addr_o,
    output wire      [IMEM_DATA_SIZE-1:0] core_imem_out_wdata_o,
    input  wire      [IMEM_DATA_SIZE-1:0] core_imem_out_rdata_i,
    input  wire                           core_imem_out_stall_i,

    //---------------
    //DMEM IF from TCU
    output wire                           tcu_dmem_en_o,
    output wire                           tcu_dmem_req_o,
    output wire      [DMEM_BSEL_SIZE-1:0] tcu_dmem_wben_o,
    output wire      [DMEM_ADDR_SIZE-1:0] tcu_dmem_addr_o,
    output wire      [DMEM_DATA_SIZE-1:0] tcu_dmem_wdata_o,
    input  wire      [DMEM_DATA_SIZE-1:0] tcu_dmem_rdata_i,
    input  wire                           tcu_dmem_rdata_avail_i,
    input  wire                           tcu_dmem_wdata_infifo_i,
    output wire                           tcu_dmem_wabort_o,
    input  wire                           tcu_dmem_wstall_i,
    input  wire                           tcu_dmem_rstall_i,

    //---------------
    //IMEM IF from TCU
    output wire                           tcu_imem_en_o,
    output wire                           tcu_imem_req_o,
    output wire      [IMEM_BSEL_SIZE-1:0] tcu_imem_wben_o,
    output wire      [IMEM_ADDR_SIZE-1:0] tcu_imem_addr_o,
    output wire      [IMEM_DATA_SIZE-1:0] tcu_imem_wdata_o,
    input  wire      [IMEM_DATA_SIZE-1:0] tcu_imem_rdata_i,
    input  wire                           tcu_imem_rdata_avail_i,
    input  wire                           tcu_imem_wdata_infifo_i,
    output wire                           tcu_imem_wabort_o,
    input  wire                           tcu_imem_wstall_i,
    input  wire                           tcu_imem_rstall_i,

    //---------------
    //config IF for special core regs
    output wire                           config_mem_en_o,
    output wire   [TCU_REG_BSEL_SIZE-1:0] config_mem_wben_o,
    output wire   [TCU_REG_ADDR_SIZE-1:0] config_mem_addr_o,
    output wire   [TCU_REG_DATA_SIZE-1:0] config_mem_wdata_o,
    input  wire   [TCU_REG_DATA_SIZE-1:0] config_mem_rdata_i,

    //---------------
    //status flag
    output wire     [TCU_STATUS_SIZE-1:0] tcu_status_o,

    //---------------
    //Home Chip/Mod-ID
    input  wire     [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input  wire      [NOC_MODID_SIZE-1:0] home_modid_i,

    //---------------
    //Mod-ID and Chip-ID for debug print
    input  wire     [NOC_CHIPID_SIZE-1:0] print_chipid_i,
    input  wire      [NOC_MODID_SIZE-1:0] print_modid_i
);


    localparam TCU_ENABLE_PRIV_CMDS = TCU_ENABLE_VIRT_ADDR || TCU_ENABLE_VIRT_PES;
    
    wire                    [2:0] reg_en_s;
    wire  [TCU_REG_DATA_SIZE-1:0] reg_wben_s;
    wire  [TCU_REG_ADDR_SIZE-1:0] reg_addr_s;
    wire  [TCU_REG_DATA_SIZE-1:0] reg_wdata_s;
    wire  [TCU_REG_DATA_SIZE-1:0] reg_rdata_s;
    wire                          reg_stall_s;

    wire                    [1:0] ctrl_reg_en_s;
    wire  [TCU_REG_DATA_SIZE-1:0] ctrl_reg_wben_s;
    wire  [TCU_REG_ADDR_SIZE-1:0] ctrl_reg_addr_s;
    wire  [TCU_REG_DATA_SIZE-1:0] ctrl_reg_wdata_s;
    wire  [TCU_REG_DATA_SIZE-1:0] ctrl_reg_rdata_s;
    wire                          ctrl_reg_stall_s;

    wire                          core_reg_en_s;
    wire  [TCU_REG_BSEL_SIZE-1:0] core_reg_wben_s;
    wire  [TCU_REG_ADDR_SIZE-1:0] core_reg_addr_s;
    wire  [TCU_REG_DATA_SIZE-1:0] core_reg_wdata_s;
    wire  [TCU_REG_DATA_SIZE-1:0] core_reg_rdata_s;
    wire                          core_reg_stall_s;

    wire                          pmp_reg_en_s;
    wire  [TCU_REG_ADDR_SIZE-1:0] pmp_reg_addr_s;
    wire  [TCU_REG_DATA_SIZE-1:0] pmp_reg_rdata_s;
    wire                          pmp_reg_stall_s;

    wire                                 core_req_pmpfail_push_s;
    wire [TCU_CORE_REQ_PMPFAIL_SIZE-1:0] core_req_pmpfail_data_s;
    wire                                 core_req_pmpfail_stall_s;

    wire                    [2:0] tcu_fire_s;
    wire                   [63:0] tcu_fire_cmd_s;
    wire                   [63:0] tcu_fire_data_addr_s;
    wire                   [63:0] tcu_fire_data_size_s;
    wire                   [63:0] tcu_fire_arg1_s;
    wire                   [63:0] tcu_fire_cur_vpe_s;

    wire                          tcu_reset_s;
    wire                   [63:0] tcu_cur_time_s;

    wire                          tcu_features_virt_addr_s;
    wire                          tcu_features_virt_pes_s;
    wire                          tcu_priv_rpt_pmpfail_s;

    wire                          tcu_print_valid_s;

    wire                          tcu_mem_en_s;
    wire                          tcu_mem_req_s;
    wire  [TCU_MEM_BSEL_SIZE-1:0] tcu_mem_wben_s;
    wire  [TCU_MEM_ADDR_SIZE-1:0] tcu_mem_addr_s;
    wire  [TCU_MEM_DATA_SIZE-1:0] tcu_mem_wdata_s;
    wire  [TCU_MEM_DATA_SIZE-1:0] tcu_mem_rdata_s;
    wire                          tcu_mem_rdata_avail_s;
    wire                          tcu_mem_wdata_infifo_s;
    wire                          tcu_mem_wabort_s;
    wire                          tcu_mem_wstall_s;
    wire                          tcu_mem_rstall_s;

    wire                          ctrl_noc_rx_wrreq_s;
    wire                          ctrl_noc_rx_burst_s;
    wire      [NOC_BSEL_SIZE-1:0] ctrl_noc_rx_bsel_s;
    wire    [NOC_CHIPID_SIZE-1:0] ctrl_noc_rx_src_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] ctrl_noc_rx_src_modid_s;
    wire    [NOC_CHIPID_SIZE-1:0] ctrl_noc_rx_trg_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] ctrl_noc_rx_trg_modid_s;
    wire      [NOC_MODE_SIZE-1:0] ctrl_noc_rx_mode_s;
    wire      [NOC_ADDR_SIZE-1:0] ctrl_noc_rx_addr_s;
    wire      [NOC_DATA_SIZE-1:0] ctrl_noc_rx_data0_s;
    wire      [NOC_DATA_SIZE-1:0] ctrl_noc_rx_data1_s;
    wire                          ctrl_noc_rx_stall_s;

    wire                          ctrl_noc_tx_wrreq_s;
    wire                          ctrl_noc_tx_burst_s;
    wire      [NOC_BSEL_SIZE-1:0] ctrl_noc_tx_bsel_s;
    wire    [NOC_CHIPID_SIZE-1:0] ctrl_noc_tx_src_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] ctrl_noc_tx_src_modid_s;
    wire    [NOC_CHIPID_SIZE-1:0] ctrl_noc_tx_trg_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] ctrl_noc_tx_trg_modid_s;
    wire      [NOC_MODE_SIZE-1:0] ctrl_noc_tx_mode_s;
    wire      [NOC_ADDR_SIZE-1:0] ctrl_noc_tx_addr_s;
    wire      [NOC_DATA_SIZE-1:0] ctrl_noc_tx_data0_s;
    wire      [NOC_DATA_SIZE-1:0] ctrl_noc_tx_data1_s;
    wire                          ctrl_noc_tx_stall_s;

    wire                          nocmux2_rx_wrreq_s;
    wire                          nocmux2_rx_burst_s;
    wire                          nocmux2_rx_arq_s;
    wire      [NOC_BSEL_SIZE-1:0] nocmux2_rx_bsel_s;
    wire    [NOC_CHIPID_SIZE-1:0] nocmux2_rx_src_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] nocmux2_rx_src_modid_s;
    wire    [NOC_CHIPID_SIZE-1:0] nocmux2_rx_trg_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] nocmux2_rx_trg_modid_s;
    wire      [NOC_MODE_SIZE-1:0] nocmux2_rx_mode_s;
    wire      [NOC_ADDR_SIZE-1:0] nocmux2_rx_addr_s;
    wire      [NOC_DATA_SIZE-1:0] nocmux2_rx_data0_s;
    wire      [NOC_DATA_SIZE-1:0] nocmux2_rx_data1_s;
    wire                          nocmux2_rx_stall_s;

    wire                          nocmux2_tx_wrreq_s;
    wire                          nocmux2_tx_burst_s;
    wire                          nocmux2_tx_arq_s;
    wire      [NOC_BSEL_SIZE-1:0] nocmux2_tx_bsel_s;
    wire    [NOC_CHIPID_SIZE-1:0] nocmux2_tx_src_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] nocmux2_tx_src_modid_s;
    wire    [NOC_CHIPID_SIZE-1:0] nocmux2_tx_trg_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] nocmux2_tx_trg_modid_s;
    wire      [NOC_MODE_SIZE-1:0] nocmux2_tx_mode_s;
    wire      [NOC_ADDR_SIZE-1:0] nocmux2_tx_addr_s;
    wire      [NOC_DATA_SIZE-1:0] nocmux2_tx_data0_s;
    wire      [NOC_DATA_SIZE-1:0] nocmux2_tx_data1_s;
    wire                          nocmux2_tx_stall_s;

    wire                          ctrl_outfifo_tx_wrreq_s;
    wire                          ctrl_outfifo_tx_burst_s;
    wire                          ctrl_outfifo_tx_arq_s = 1'b0;     //TCU controller does not handle ARQ bit
    wire      [NOC_BSEL_SIZE-1:0] ctrl_outfifo_tx_bsel_s;
    wire    [NOC_CHIPID_SIZE-1:0] ctrl_outfifo_tx_src_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] ctrl_outfifo_tx_src_modid_s;
    wire    [NOC_CHIPID_SIZE-1:0] ctrl_outfifo_tx_trg_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] ctrl_outfifo_tx_trg_modid_s;
    wire      [NOC_MODE_SIZE-1:0] ctrl_outfifo_tx_mode_s;
    wire      [NOC_ADDR_SIZE-1:0] ctrl_outfifo_tx_addr_s;
    wire      [NOC_DATA_SIZE-1:0] ctrl_outfifo_tx_data0_s;
    wire      [NOC_DATA_SIZE-1:0] ctrl_outfifo_tx_data1_s;
    wire                          ctrl_outfifo_tx_stall_s;

    wire                          ctrl_infifo_rx_wrreq_s;
    wire                          ctrl_infifo_rx_burst_s;
    wire                          ctrl_infifo_rx_arq_s;
    wire      [NOC_BSEL_SIZE-1:0] ctrl_infifo_rx_bsel_s;
    wire    [NOC_CHIPID_SIZE-1:0] ctrl_infifo_rx_src_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] ctrl_infifo_rx_src_modid_s;
    wire    [NOC_CHIPID_SIZE-1:0] ctrl_infifo_rx_trg_chipid_s;
    wire     [NOC_MODID_SIZE-1:0] ctrl_infifo_rx_trg_modid_s;
    wire      [NOC_MODE_SIZE-1:0] ctrl_infifo_rx_mode_s;
    wire      [NOC_ADDR_SIZE-1:0] ctrl_infifo_rx_addr_s;
    wire      [NOC_DATA_SIZE-1:0] ctrl_infifo_rx_data0_s;
    wire      [NOC_DATA_SIZE-1:0] ctrl_infifo_rx_data1_s;
    wire                          ctrl_infifo_rx_stall_s;

    wire [TCU_FLITCOUNT_SIZE-1:0] noc1_rx_flit_count_s;
    wire [TCU_FLITCOUNT_SIZE-1:0] noc2_rx_flit_count_s;
    wire [TCU_FLITCOUNT_SIZE-1:0] noc1_tx_flit_count_s;
    wire [TCU_FLITCOUNT_SIZE-1:0] noc2_tx_flit_count_s;
    wire [TCU_FLITCOUNT_SIZE-1:0] noc_error_flit_count_s;
    wire [TCU_FLITCOUNT_SIZE-1:0] noc_drop_flit_count_s;

    wire                          tcu_log_en_s;
    wire  [TCU_LOG_DATA_SIZE-1:0] tcu_log_data_s;
    wire  [TCU_LOG_DATA_SIZE-1:0] tcu_log_cur_vpe_s;
    wire  [TCU_LOG_DATA_SIZE-1:0] tcu_log_pmp_s;



    tcu_regs #(
        .TCU_ENABLE_CMDS          (TCU_ENABLE_CMDS),
        .TCU_ENABLE_PRIV_CMDS     (TCU_ENABLE_PRIV_CMDS),
        .TCU_ENABLE_LOG           (TCU_ENABLE_LOG),
        .TCU_ENABLE_PRINT         (TCU_ENABLE_PRINT),
        .CLKFREQ_MHZ              (CLKFREQ_MHZ),
        .TILE_TYPE                (TILE_TYPE),
        .TILE_ISA                 (TILE_ISA),
        .TILE_ATTR                (TILE_ATTR),
        .TILE_MEMSIZE             (TILE_MEMSIZE)
    ) i_tcu_regs (
        .clk_i                    (clk_i),
        .reset_n_i                (reset_n_i),
        
        .reg_en_i                 (reg_en_s),
        .reg_wben_i               (reg_wben_s),
        .reg_addr_i               (reg_addr_s),
        .reg_wdata_i              (reg_wdata_s),
        .reg_rdata_o              (reg_rdata_s),
        .reg_stall_o              (reg_stall_s),

        .tcu_fire_o               (tcu_fire_s),
        .tcu_fire_cmd_o           (tcu_fire_cmd_s),
        .tcu_fire_data_addr_o     (tcu_fire_data_addr_s),
        .tcu_fire_data_size_o     (tcu_fire_data_size_s),
        .tcu_fire_arg1_o          (tcu_fire_arg1_s),
        .tcu_fire_cur_vpe_o       (tcu_fire_cur_vpe_s),

        .tcu_reset_o              (tcu_reset_s),
        .tcu_cur_time_o           (tcu_cur_time_s),

        .tcu_features_virt_addr_o (tcu_features_virt_addr_s),
        .tcu_features_virt_pes_o  (tcu_features_virt_pes_s),
        .tcu_priv_rpt_pmpfail_o   (tcu_priv_rpt_pmpfail_s),

        .tcu_print_valid_o        (tcu_print_valid_s),

        .config_en_o              (config_mem_en_o),
        .config_wben_o            (config_mem_wben_o),
        .config_addr_o            (config_mem_addr_o),
        .config_wdata_o           (config_mem_wdata_o),
        .config_rdata_i           (config_mem_rdata_i),

        .tcu_log_en_i             (tcu_log_en_s),
        .tcu_log_data_i           (tcu_log_data_s),
        .tcu_log_cur_vpe_o        (tcu_log_cur_vpe_s),

        .tcu_status_i             (tcu_status_o),
        .noc1_rx_flit_count_i     (noc1_rx_flit_count_s),
        .noc2_rx_flit_count_i     (noc2_rx_flit_count_s),
        .noc1_tx_flit_count_i     (noc1_tx_flit_count_s),
        .noc2_tx_flit_count_i     (noc2_tx_flit_count_s),
        .noc_error_flit_count_i   (noc_error_flit_count_s),
        .noc_drop_flit_count_i    (noc_drop_flit_count_s)
    );


    tcu_memmap #(
        .TCU_ENABLE_MEM_ADDR_ALIGN  (TCU_ENABLE_MEM_ADDR_ALIGN),
        .CORE_DMEM_DATA_SIZE        (CORE_DMEM_DATA_SIZE),
        .CORE_DMEM_ADDR_SIZE        (CORE_DMEM_ADDR_SIZE),
        .CORE_DMEM_BSEL_SIZE        (CORE_DMEM_BSEL_SIZE),
        .CORE_IMEM_DATA_SIZE        (CORE_IMEM_DATA_SIZE),
        .CORE_IMEM_ADDR_SIZE        (CORE_IMEM_ADDR_SIZE),
        .CORE_IMEM_BSEL_SIZE        (CORE_IMEM_BSEL_SIZE),
        .DMEM_DATA_SIZE             (DMEM_DATA_SIZE),
        .DMEM_ADDR_SIZE             (DMEM_ADDR_SIZE),
        .DMEM_BSEL_SIZE             (DMEM_BSEL_SIZE),
        .IMEM_DATA_SIZE             (IMEM_DATA_SIZE),
        .IMEM_ADDR_SIZE             (IMEM_ADDR_SIZE),
        .IMEM_BSEL_SIZE             (IMEM_BSEL_SIZE),
        .DMEM_START_ADDR            (DMEM_START_ADDR),
        .DMEM_SIZE                  (DMEM_SIZE),
        .IMEM_START_ADDR            (IMEM_START_ADDR),
        .IMEM_SIZE                  (IMEM_SIZE)
    ) i_tcu_memmap (
        .clk_i                      (clk_i),
        .reset_n_i                  (reset_n_i),

        //---------------
        //Core DMEM IF
        .core_dmem_in_en_i          (core_dmem_in_en_i),
        .core_dmem_in_wben_i        (core_dmem_in_wben_i),
        .core_dmem_in_addr_i        (core_dmem_in_addr_i),
        .core_dmem_in_wdata_i       (core_dmem_in_wdata_i),
        .core_dmem_in_rdata_o       (core_dmem_in_rdata_o),
        .core_dmem_in_stall_o       (core_dmem_in_stall_o),

        //---------------
        //Core IMEM IF
        .core_imem_in_en_i          (core_imem_in_en_i),
        .core_imem_in_wben_i        (core_imem_in_wben_i),
        .core_imem_in_addr_i        (core_imem_in_addr_i),
        .core_imem_in_wdata_i       (core_imem_in_wdata_i),
        .core_imem_in_rdata_o       (core_imem_in_rdata_o),
        .core_imem_in_stall_o       (core_imem_in_stall_o),

        //---------------
        //to DMEM
        .core_dmem_out_en_o         (core_dmem_out_en_o),
        .core_dmem_out_wben_o       (core_dmem_out_wben_o),
        .core_dmem_out_addr_o       (core_dmem_out_addr_o),
        .core_dmem_out_wdata_o      (core_dmem_out_wdata_o),
        .core_dmem_out_rdata_i      (core_dmem_out_rdata_i),
        .core_dmem_out_stall_i      (core_dmem_out_stall_i),

        //---------------
        //to IMEM
        .core_imem_out_en_o         (core_imem_out_en_o),
        .core_imem_out_wben_o       (core_imem_out_wben_o),
        .core_imem_out_addr_o       (core_imem_out_addr_o),
        .core_imem_out_wdata_o      (core_imem_out_wdata_o),
        .core_imem_out_rdata_i      (core_imem_out_rdata_i),
        .core_imem_out_stall_i      (core_imem_out_stall_i),

        //---------------
        //core to regs
        .core_reg_out_en_o          (core_reg_en_s),
        .core_reg_out_wben_o        (core_reg_wben_s),
        .core_reg_out_addr_o        (core_reg_addr_s),
        .core_reg_out_wdata_o       (core_reg_wdata_s),
        .core_reg_out_rdata_i       (core_reg_rdata_s),
        .core_reg_out_stall_i       (core_reg_stall_s),

        //---------------
        //TCU mem IF
        .tcu_mem_en_i               (tcu_mem_en_s),
        .tcu_mem_req_i              (tcu_mem_req_s),
        .tcu_mem_wben_i             (tcu_mem_wben_s),
        .tcu_mem_addr_i             (tcu_mem_addr_s),
        .tcu_mem_wdata_i            (tcu_mem_wdata_s),
        .tcu_mem_rdata_o            (tcu_mem_rdata_s),
        .tcu_mem_rdata_avail_o      (tcu_mem_rdata_avail_s),
        .tcu_mem_wdata_infifo_o     (tcu_mem_wdata_infifo_s),
        .tcu_mem_wabort_i           (tcu_mem_wabort_s),
        .tcu_mem_wstall_o           (tcu_mem_wstall_s),
        .tcu_mem_rstall_o           (tcu_mem_rstall_s),

        //---------------
        //TCU to DMEM
        .tcu_dmem_en_o              (tcu_dmem_en_o),
        .tcu_dmem_req_o             (tcu_dmem_req_o),
        .tcu_dmem_wben_o            (tcu_dmem_wben_o),
        .tcu_dmem_addr_o            (tcu_dmem_addr_o),
        .tcu_dmem_wdata_o           (tcu_dmem_wdata_o),
        .tcu_dmem_rdata_i           (tcu_dmem_rdata_i),
        .tcu_dmem_rdata_avail_i     (tcu_dmem_rdata_avail_i),
        .tcu_dmem_wdata_infifo_i    (tcu_dmem_wdata_infifo_i),
        .tcu_dmem_wabort_o          (tcu_dmem_wabort_o),
        .tcu_dmem_wstall_i          (tcu_dmem_wstall_i),
        .tcu_dmem_rstall_i          (tcu_dmem_rstall_i),

        //---------------
        //TCU to IMEM
        .tcu_imem_en_o              (tcu_imem_en_o),
        .tcu_imem_req_o             (tcu_imem_req_o),
        .tcu_imem_wben_o            (tcu_imem_wben_o),
        .tcu_imem_addr_o            (tcu_imem_addr_o),
        .tcu_imem_wdata_o           (tcu_imem_wdata_o),
        .tcu_imem_rdata_i           (tcu_imem_rdata_i),
        .tcu_imem_rdata_avail_i     (tcu_imem_rdata_avail_i),
        .tcu_imem_wdata_infifo_i    (tcu_imem_wdata_infifo_i),
        .tcu_imem_wabort_o          (tcu_imem_wabort_o),
        .tcu_imem_wstall_i          (tcu_imem_wstall_i),
        .tcu_imem_rstall_i          (tcu_imem_rstall_i)
    );


    tcu_reg_mux i_tcu_reg_mux (
        .clk_i                (clk_i),
        .reset_n_i            (reset_n_i),

        //---------------
        //Core reg IF
        .reg_in1_en_i         ({core_reg_en_s, 1'b0, core_reg_en_s}),   //Bit 0: standard enable, Bit 2: from core
        .reg_in1_wben_i       (core_reg_wben_s),                        //byte-wise select
        .reg_in1_addr_i       (core_reg_addr_s),
        .reg_in1_wdata_i      (core_reg_wdata_s),
        .reg_in1_rdata_o      (core_reg_rdata_s),
        .reg_in1_stall_o      (core_reg_stall_s),

        //---------------
        //Reg IF from PMP (only read)
        .reg_in2_en_i         ({pmp_reg_en_s, 1'b0, pmp_reg_en_s}),    //Bit 0: standard enable, Bit 2: from core
        .reg_in2_wben_i       ({TCU_REG_DATA_SIZE{1'b0}}),             //bit-wise select
        .reg_in2_addr_i       (pmp_reg_addr_s),
        .reg_in2_wdata_i      ({TCU_REG_DATA_SIZE{1'b0}}),
        .reg_in2_rdata_o      (pmp_reg_rdata_s),
        .reg_in2_stall_o      (pmp_reg_stall_s),

        //---------------
        //reg IF from tcu_ctrl
        .reg_in3_en_i         ({1'b0, ctrl_reg_en_s}),                 //Bit 0: standard enable, Bit 1: from extern
        .reg_in3_wben_i       (ctrl_reg_wben_s),                       //bit-wise select
        .reg_in3_addr_i       (ctrl_reg_addr_s),
        .reg_in3_wdata_i      (ctrl_reg_wdata_s),
        .reg_in3_rdata_o      (ctrl_reg_rdata_s),
        .reg_in3_stall_o      (ctrl_reg_stall_s),

        //---------------
        //reg IF to tcu_regs
        .reg_out_en_o         (reg_en_s),
        .reg_out_wben_o       (reg_wben_s),
        .reg_out_addr_o       (reg_addr_s),
        .reg_out_wdata_o      (reg_wdata_s),
        .reg_out_rdata_i      (reg_rdata_s),
        .reg_out_stall_i      (reg_stall_s)
    );


    generate
    if (TCU_ENABLE_PMP) begin: PMP

        tcu_pmp i_tcu_pmp (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_n_i),
            .tcu_reset_i             (tcu_reset_s),

            .home_chipid_i           (home_chipid_i),
            .home_modid_i            (home_modid_i),
            .pmp_drop_flit_count_o   (),

            //---------------
            //Reg IF (only read)
            .reg_en_o                (pmp_reg_en_s),
            .reg_addr_o              (pmp_reg_addr_s),
            .reg_rdata_i             (pmp_reg_rdata_s),
            .reg_stall_i             (pmp_reg_stall_s),

            //---------------
            //NoC IF to/from core
            .noc_in_tx_wrreq_i       (tcu_byp_noc_tx_wrreq_i),
            .noc_in_tx_burst_i       (tcu_byp_noc_tx_burst_i),
            .noc_in_tx_arq_i         (tcu_byp_noc_tx_arq_i),
            .noc_in_tx_bsel_i        (tcu_byp_noc_tx_bsel_i),
            .noc_in_tx_src_chipid_i  (tcu_byp_noc_tx_src_chipid_i),
            .noc_in_tx_src_modid_i   (tcu_byp_noc_tx_src_modid_i),
            .noc_in_tx_trg_chipid_i  (tcu_byp_noc_tx_trg_chipid_i),
            .noc_in_tx_trg_modid_i   (tcu_byp_noc_tx_trg_modid_i),
            .noc_in_tx_mode_i        (tcu_byp_noc_tx_mode_i),
            .noc_in_tx_addr_i        (tcu_byp_noc_tx_addr_i),
            .noc_in_tx_data0_i       (tcu_byp_noc_tx_data0_i),
            .noc_in_tx_data1_i       (tcu_byp_noc_tx_data1_i),
            .noc_in_tx_stall_o       (tcu_byp_noc_tx_stall_o),

            .noc_in_rx_wrreq_o       (tcu_byp_noc_rx_wrreq_o),
            .noc_in_rx_burst_o       (tcu_byp_noc_rx_burst_o),
            .noc_in_rx_arq_o         (tcu_byp_noc_rx_arq_o),
            .noc_in_rx_bsel_o        (tcu_byp_noc_rx_bsel_o),
            .noc_in_rx_src_chipid_o  (tcu_byp_noc_rx_src_chipid_o),
            .noc_in_rx_src_modid_o   (tcu_byp_noc_rx_src_modid_o),
            .noc_in_rx_trg_chipid_o  (tcu_byp_noc_rx_trg_chipid_o),
            .noc_in_rx_trg_modid_o   (tcu_byp_noc_rx_trg_modid_o),
            .noc_in_rx_mode_o        (tcu_byp_noc_rx_mode_o),
            .noc_in_rx_addr_o        (tcu_byp_noc_rx_addr_o),
            .noc_in_rx_data0_o       (tcu_byp_noc_rx_data0_o),
            .noc_in_rx_data1_o       (tcu_byp_noc_rx_data1_o),
            .noc_in_rx_stall_i       (tcu_byp_noc_rx_stall_i),

            //---------------
            //NoC IF to/from NoC via NoC-MUX
            .noc_out_tx_wrreq_o      (nocmux2_tx_wrreq_s),
            .noc_out_tx_burst_o      (nocmux2_tx_burst_s),
            .noc_out_tx_arq_o        (nocmux2_tx_arq_s),
            .noc_out_tx_bsel_o       (nocmux2_tx_bsel_s),
            .noc_out_tx_src_chipid_o (nocmux2_tx_src_chipid_s),
            .noc_out_tx_src_modid_o  (nocmux2_tx_src_modid_s),
            .noc_out_tx_trg_chipid_o (nocmux2_tx_trg_chipid_s),
            .noc_out_tx_trg_modid_o  (nocmux2_tx_trg_modid_s),
            .noc_out_tx_mode_o       (nocmux2_tx_mode_s),
            .noc_out_tx_addr_o       (nocmux2_tx_addr_s),
            .noc_out_tx_data0_o      (nocmux2_tx_data0_s),
            .noc_out_tx_data1_o      (nocmux2_tx_data1_s),
            .noc_out_tx_stall_i      (nocmux2_tx_stall_s),

            .noc_out_rx_wrreq_i      (nocmux2_rx_wrreq_s),
            .noc_out_rx_burst_i      (nocmux2_rx_burst_s),
            .noc_out_rx_arq_i        (nocmux2_rx_arq_s),
            .noc_out_rx_bsel_i       (nocmux2_rx_bsel_s),
            .noc_out_rx_src_chipid_i (nocmux2_rx_src_chipid_s),
            .noc_out_rx_src_modid_i  (nocmux2_rx_src_modid_s),
            .noc_out_rx_trg_chipid_i (nocmux2_rx_trg_chipid_s),
            .noc_out_rx_trg_modid_i  (nocmux2_rx_trg_modid_s),
            .noc_out_rx_mode_i       (nocmux2_rx_mode_s),
            .noc_out_rx_addr_i       (nocmux2_rx_addr_s),
            .noc_out_rx_data0_i      (nocmux2_rx_data0_s),
            .noc_out_rx_data1_i      (nocmux2_rx_data1_s),
            .noc_out_rx_stall_o      (nocmux2_rx_stall_s),

            //---------------
            //PMP failures
            .core_req_enable_i       (tcu_priv_rpt_pmpfail_s),
            .core_req_push_o         (core_req_pmpfail_push_s),
            .core_req_data_o         (core_req_pmpfail_data_s),
            .core_req_stall_i        (core_req_pmpfail_stall_s),

            //---------------
            //logging
            .tcu_log_pmp_o           (tcu_log_pmp_s)
        );

    end
    else begin: NO_PMP

        assign pmp_reg_en_s = 1'b0;
        assign pmp_reg_addr_s = {TCU_REG_ADDR_SIZE{1'b0}};

        assign nocmux2_tx_wrreq_s          = tcu_byp_noc_tx_wrreq_i;
        assign nocmux2_tx_burst_s          = tcu_byp_noc_tx_burst_i;
        assign nocmux2_tx_arq_s            = tcu_byp_noc_tx_arq_i;
        assign nocmux2_tx_bsel_s           = tcu_byp_noc_tx_bsel_i;
        assign nocmux2_tx_src_chipid_s     = tcu_byp_noc_tx_src_chipid_i;
        assign nocmux2_tx_src_modid_s      = tcu_byp_noc_tx_src_modid_i;
        assign nocmux2_tx_trg_chipid_s     = tcu_byp_noc_tx_trg_chipid_i;
        assign nocmux2_tx_trg_modid_s      = tcu_byp_noc_tx_trg_modid_i;
        assign nocmux2_tx_mode_s           = tcu_byp_noc_tx_mode_i;
        assign nocmux2_tx_addr_s           = tcu_byp_noc_tx_addr_i;
        assign nocmux2_tx_data0_s          = tcu_byp_noc_tx_data0_i;
        assign nocmux2_tx_data1_s          = tcu_byp_noc_tx_data1_i;
        assign tcu_byp_noc_tx_stall_o      = nocmux2_tx_stall_s;

        assign tcu_byp_noc_rx_wrreq_o      = nocmux2_rx_wrreq_s;
        assign tcu_byp_noc_rx_burst_o      = nocmux2_rx_burst_s;
        assign tcu_byp_noc_rx_arq_o        = nocmux2_rx_arq_s;
        assign tcu_byp_noc_rx_bsel_o       = nocmux2_rx_bsel_s;
        assign tcu_byp_noc_rx_src_chipid_o = nocmux2_rx_src_chipid_s;
        assign tcu_byp_noc_rx_src_modid_o  = nocmux2_rx_src_modid_s;
        assign tcu_byp_noc_rx_trg_chipid_o = nocmux2_rx_trg_chipid_s;
        assign tcu_byp_noc_rx_trg_modid_o  = nocmux2_rx_trg_modid_s;
        assign tcu_byp_noc_rx_mode_o       = nocmux2_rx_mode_s;
        assign tcu_byp_noc_rx_addr_o       = nocmux2_rx_addr_s;
        assign tcu_byp_noc_rx_data0_o      = nocmux2_rx_data0_s;
        assign tcu_byp_noc_rx_data1_o      = nocmux2_rx_data1_s;
        assign nocmux2_rx_stall_s          = tcu_byp_noc_rx_stall_i;

        assign core_req_pmpfail_push_s = 1'b0;
        assign core_req_pmpfail_data_s = {TCU_CORE_REQ_PMPFAIL_SIZE{1'b0}};

        assign tcu_log_pmp_s = TCU_LOG_NONE;

    end
    endgenerate


    tcu_noc_mux #(
        .TX_IF1_PRIO                (NOCMUX_TX_IF1_PRIO),
        .RX_IF1_PRIO                (NOCMUX_RX_IF1_PRIO),
        .RX_IF1_ADDR_START          (NOCMUX_RX_IF1_ADDR_START),
        .RX_IF1_ADDR_END            (NOCMUX_RX_IF1_ADDR_END),
        .RX_IF1_ONLY_MODE_2         (NOCMUX_RX_IF1_ONLY_MODE_2),
        .RX_IF1_ONLY_HOMECHIP       (NOCMUX_RX_IF1_ONLY_HOMECHIP),
        .RX_IF2_ADDR_START          (NOCMUX_RX_IF2_ADDR_START),
        .RX_IF2_ADDR_END            (NOCMUX_RX_IF2_ADDR_END),
        .RX_IF2_ONLY_MODE_2         (NOCMUX_RX_IF2_ONLY_MODE_2),
        .RX_IF2_ONLY_HOMECHIP       (NOCMUX_RX_IF2_ONLY_HOMECHIP)
    ) i_tcu_noc_mux (
        .clk_i                      (clk_i),
        .reset_n_i                  (reset_n_i),
        .tcu_reset_i                (tcu_reset_s),
        .home_chipid_i              (home_chipid_i),

        //---------------
        //NoC IF 1 (from tcu_ctrl)
        .noc1_tx_wrreq_i            (ctrl_outfifo_tx_wrreq_s),
        .noc1_tx_burst_i            (ctrl_outfifo_tx_burst_s),
        .noc1_tx_arq_i              (ctrl_outfifo_tx_arq_s),
        .noc1_tx_bsel_i             (ctrl_outfifo_tx_bsel_s),
        .noc1_tx_src_chipid_i       (ctrl_outfifo_tx_src_chipid_s),
        .noc1_tx_src_modid_i        (ctrl_outfifo_tx_src_modid_s),
        .noc1_tx_trg_chipid_i       (ctrl_outfifo_tx_trg_chipid_s),
        .noc1_tx_trg_modid_i        (ctrl_outfifo_tx_trg_modid_s),
        .noc1_tx_mode_i             (ctrl_outfifo_tx_mode_s),
        .noc1_tx_addr_i             (ctrl_outfifo_tx_addr_s),
        .noc1_tx_data0_i            (ctrl_outfifo_tx_data0_s),
        .noc1_tx_data1_i            (ctrl_outfifo_tx_data1_s),
        .noc1_tx_stall_o            (ctrl_outfifo_tx_stall_s),

        .noc1_rx_wrreq_o            (ctrl_infifo_rx_wrreq_s),
        .noc1_rx_burst_o            (ctrl_infifo_rx_burst_s),
        .noc1_rx_arq_o              (ctrl_infifo_rx_arq_s),
        .noc1_rx_bsel_o             (ctrl_infifo_rx_bsel_s),
        .noc1_rx_src_chipid_o       (ctrl_infifo_rx_src_chipid_s),
        .noc1_rx_src_modid_o        (ctrl_infifo_rx_src_modid_s),
        .noc1_rx_trg_chipid_o       (ctrl_infifo_rx_trg_chipid_s),
        .noc1_rx_trg_modid_o        (ctrl_infifo_rx_trg_modid_s),
        .noc1_rx_mode_o             (ctrl_infifo_rx_mode_s),
        .noc1_rx_addr_o             (ctrl_infifo_rx_addr_s),
        .noc1_rx_data0_o            (ctrl_infifo_rx_data0_s),
        .noc1_rx_data1_o            (ctrl_infifo_rx_data1_s),
        .noc1_rx_stall_i            (ctrl_infifo_rx_stall_s),

        //---------------
        //NoC IF 2 (from bypass or PMP)
        .noc2_tx_wrreq_i            (nocmux2_tx_wrreq_s),
        .noc2_tx_burst_i            (nocmux2_tx_burst_s),
        .noc2_tx_arq_i              (nocmux2_tx_arq_s),
        .noc2_tx_bsel_i             (nocmux2_tx_bsel_s),
        .noc2_tx_src_chipid_i       (nocmux2_tx_src_chipid_s),
        .noc2_tx_src_modid_i        (nocmux2_tx_src_modid_s),
        .noc2_tx_trg_chipid_i       (nocmux2_tx_trg_chipid_s),
        .noc2_tx_trg_modid_i        (nocmux2_tx_trg_modid_s),
        .noc2_tx_mode_i             (nocmux2_tx_mode_s),
        .noc2_tx_addr_i             (nocmux2_tx_addr_s),
        .noc2_tx_data0_i            (nocmux2_tx_data0_s),
        .noc2_tx_data1_i            (nocmux2_tx_data1_s),
        .noc2_tx_stall_o            (nocmux2_tx_stall_s),

        .noc2_rx_wrreq_o            (nocmux2_rx_wrreq_s),
        .noc2_rx_burst_o            (nocmux2_rx_burst_s),
        .noc2_rx_arq_o              (nocmux2_rx_arq_s),
        .noc2_rx_bsel_o             (nocmux2_rx_bsel_s),
        .noc2_rx_src_chipid_o       (nocmux2_rx_src_chipid_s),
        .noc2_rx_src_modid_o        (nocmux2_rx_src_modid_s),
        .noc2_rx_trg_chipid_o       (nocmux2_rx_trg_chipid_s),
        .noc2_rx_trg_modid_o        (nocmux2_rx_trg_modid_s),
        .noc2_rx_mode_o             (nocmux2_rx_mode_s),
        .noc2_rx_addr_o             (nocmux2_rx_addr_s),
        .noc2_rx_data0_o            (nocmux2_rx_data0_s),
        .noc2_rx_data1_o            (nocmux2_rx_data1_s),
        .noc2_rx_stall_i            (nocmux2_rx_stall_s),

        //---------------
        //NoC IF out (TCU output to NoC)
        .noc_out_tx_wrreq_o         (tcu_noc_tx_wrreq_o),
        .noc_out_tx_burst_o         (tcu_noc_tx_burst_o),
        .noc_out_tx_arq_o           (tcu_noc_tx_arq_o),
        .noc_out_tx_bsel_o          (tcu_noc_tx_bsel_o),
        .noc_out_tx_src_chipid_o    (tcu_noc_tx_src_chipid_o),
        .noc_out_tx_src_modid_o     (tcu_noc_tx_src_modid_o),
        .noc_out_tx_trg_chipid_o    (tcu_noc_tx_trg_chipid_o),
        .noc_out_tx_trg_modid_o     (tcu_noc_tx_trg_modid_o),
        .noc_out_tx_mode_o          (tcu_noc_tx_mode_o),
        .noc_out_tx_addr_o          (tcu_noc_tx_addr_o),
        .noc_out_tx_data0_o         (tcu_noc_tx_data0_o),
        .noc_out_tx_data1_o         (tcu_noc_tx_data1_o),
        .noc_out_tx_stall_i         (tcu_noc_tx_stall_i),

        .noc_out_rx_wrreq_i         (tcu_noc_rx_wrreq_i),
        .noc_out_rx_burst_i         (tcu_noc_rx_burst_i),
        .noc_out_rx_arq_i           (tcu_noc_rx_arq_i),
        .noc_out_rx_bsel_i          (tcu_noc_rx_bsel_i),
        .noc_out_rx_src_chipid_i    (tcu_noc_rx_src_chipid_i),
        .noc_out_rx_src_modid_i     (tcu_noc_rx_src_modid_i),
        .noc_out_rx_trg_chipid_i    (tcu_noc_rx_trg_chipid_i),
        .noc_out_rx_trg_modid_i     (tcu_noc_rx_trg_modid_i),
        .noc_out_rx_mode_i          (tcu_noc_rx_mode_i),
        .noc_out_rx_addr_i          (tcu_noc_rx_addr_i),
        .noc_out_rx_data0_i         (tcu_noc_rx_data0_i),
        .noc_out_rx_data1_i         (tcu_noc_rx_data1_i),
        .noc_out_rx_stall_o         (tcu_noc_rx_stall_o),

        .noc1_rx_flit_count_o       (noc1_rx_flit_count_s),
        .noc2_rx_flit_count_o       (noc2_rx_flit_count_s),
        .noc1_tx_flit_count_o       (noc1_tx_flit_count_s),
        .noc2_tx_flit_count_o       (noc2_tx_flit_count_s)
    );


    //NoC output FIFO is enabled when PMP is selected
    tcu_noc_fifo #(
        .TCU_ENABLE_NOC_FIFO       (TCU_ENABLE_NOC_OUTFIFO || TCU_ENABLE_PMP),
        .NOC_MASTER                (0),
        .FIFO_POP_FULL_BURST_ONLY  (1),
        .FIFO_PUSH_EMPTY_BURST_ONLY(0)
    ) i_tcu_noc_outfifo (
        .clk_i                   (clk_i),
        .reset_n_i               (reset_n_i),

        .noc_wrreq_i             (ctrl_noc_tx_wrreq_s),
        .noc_burst_i             (ctrl_noc_tx_burst_s),
        .noc_bsel_i              (ctrl_noc_tx_bsel_s),
        .noc_src_chipid_i        (ctrl_noc_tx_src_chipid_s),
        .noc_src_modid_i         (ctrl_noc_tx_src_modid_s),
        .noc_trg_chipid_i        (ctrl_noc_tx_trg_chipid_s),
        .noc_trg_modid_i         (ctrl_noc_tx_trg_modid_s),
        .noc_mode_i              (ctrl_noc_tx_mode_s),
        .noc_addr_i              (ctrl_noc_tx_addr_s),
        .noc_data0_i             (ctrl_noc_tx_data0_s),
        .noc_data1_i             (ctrl_noc_tx_data1_s),
        .noc_stall_o             (ctrl_noc_tx_stall_s),

        .noc_wrreq_o             (ctrl_outfifo_tx_wrreq_s),
        .noc_burst_o             (ctrl_outfifo_tx_burst_s),
        .noc_bsel_o              (ctrl_outfifo_tx_bsel_s),
        .noc_src_chipid_o        (ctrl_outfifo_tx_src_chipid_s),
        .noc_src_modid_o         (ctrl_outfifo_tx_src_modid_s),
        .noc_trg_chipid_o        (ctrl_outfifo_tx_trg_chipid_s),
        .noc_trg_modid_o         (ctrl_outfifo_tx_trg_modid_s),
        .noc_mode_o              (ctrl_outfifo_tx_mode_s),
        .noc_addr_o              (ctrl_outfifo_tx_addr_s),
        .noc_data0_o             (ctrl_outfifo_tx_data0_s),
        .noc_data1_o             (ctrl_outfifo_tx_data1_s),
        .noc_stall_i             (ctrl_outfifo_tx_stall_s)
    );


    //NoC input FIFO is enabled when PMP is selected
    tcu_noc_fifo #(
        .TCU_ENABLE_NOC_FIFO       (TCU_ENABLE_NOC_INFIFO || TCU_ENABLE_PMP),
        .NOC_MASTER                (1),
        .FIFO_POP_FULL_BURST_ONLY  (0),
        .FIFO_PUSH_EMPTY_BURST_ONLY(1)
    ) i_tcu_noc_infifo (
        .clk_i                   (clk_i),
        .reset_n_i               (reset_n_i),

        .noc_wrreq_i             (ctrl_infifo_rx_wrreq_s),
        .noc_burst_i             (ctrl_infifo_rx_burst_s),
        .noc_bsel_i              (ctrl_infifo_rx_bsel_s),
        .noc_src_chipid_i        (ctrl_infifo_rx_src_chipid_s),
        .noc_src_modid_i         (ctrl_infifo_rx_src_modid_s),
        .noc_trg_chipid_i        (ctrl_infifo_rx_trg_chipid_s),
        .noc_trg_modid_i         (ctrl_infifo_rx_trg_modid_s),
        .noc_mode_i              (ctrl_infifo_rx_mode_s),
        .noc_addr_i              (ctrl_infifo_rx_addr_s),
        .noc_data0_i             (ctrl_infifo_rx_data0_s),
        .noc_data1_i             (ctrl_infifo_rx_data1_s),
        .noc_stall_o             (ctrl_infifo_rx_stall_s),

        .noc_wrreq_o             (ctrl_noc_rx_wrreq_s),
        .noc_burst_o             (ctrl_noc_rx_burst_s),
        .noc_bsel_o              (ctrl_noc_rx_bsel_s),
        .noc_src_chipid_o        (ctrl_noc_rx_src_chipid_s),
        .noc_src_modid_o         (ctrl_noc_rx_src_modid_s),
        .noc_trg_chipid_o        (ctrl_noc_rx_trg_chipid_s),
        .noc_trg_modid_o         (ctrl_noc_rx_trg_modid_s),
        .noc_mode_o              (ctrl_noc_rx_mode_s),
        .noc_addr_o              (ctrl_noc_rx_addr_s),
        .noc_data0_o             (ctrl_noc_rx_data0_s),
        .noc_data1_o             (ctrl_noc_rx_data1_s),
        .noc_stall_i             (ctrl_noc_rx_stall_s)
    );


    tcu_ctrl #(
        .TCU_ENABLE_CMDS          (TCU_ENABLE_CMDS),
        .TCU_ENABLE_VIRT_ADDR     (TCU_ENABLE_VIRT_ADDR),
        .TCU_ENABLE_VIRT_PES      (TCU_ENABLE_VIRT_PES),
        .TCU_ENABLE_DRAM          (TCU_ENABLE_DRAM),
        .TCU_ENABLE_LOG           (TCU_ENABLE_LOG),
        .TCU_ENABLE_PRINT         (TCU_ENABLE_PRINT),
        .TCU_REGADDR_CORE_REQ_INT (TCU_REGADDR_CORE_REQ_INT),
        .TCU_REGADDR_TIMER_INT    (TCU_REGADDR_TIMER_INT),
        .CLKFREQ_MHZ              (CLKFREQ_MHZ),
        .TIMEOUT_SEND_CYCLES      (TIMEOUT_SEND_CYCLES),
        .TIMEOUT_RECV_CYCLES      (TIMEOUT_RECV_CYCLES)
    ) i_tcu_ctrl (
        .clk_i                    (clk_i),
        .reset_n_i                (reset_n_i),

        //---------------
        //NoC IF
        .noc_rx_wrreq_i           (ctrl_noc_rx_wrreq_s),
        .noc_rx_burst_i           (ctrl_noc_rx_burst_s),
        .noc_rx_bsel_i            (ctrl_noc_rx_bsel_s),
        .noc_rx_src_chipid_i      (ctrl_noc_rx_src_chipid_s),
        .noc_rx_src_modid_i       (ctrl_noc_rx_src_modid_s),
        .noc_rx_trg_chipid_i      (ctrl_noc_rx_trg_chipid_s),
        .noc_rx_trg_modid_i       (ctrl_noc_rx_trg_modid_s),
        .noc_rx_mode_i            (ctrl_noc_rx_mode_s),
        .noc_rx_addr_i            (ctrl_noc_rx_addr_s),
        .noc_rx_data0_i           (ctrl_noc_rx_data0_s),
        .noc_rx_data1_i           (ctrl_noc_rx_data1_s),
        .noc_rx_stall_o           (ctrl_noc_rx_stall_s),

        .noc_tx_wrreq_o           (ctrl_noc_tx_wrreq_s),
        .noc_tx_burst_o           (ctrl_noc_tx_burst_s),
        .noc_tx_bsel_o            (ctrl_noc_tx_bsel_s),
        .noc_tx_src_chipid_o      (ctrl_noc_tx_src_chipid_s),
        .noc_tx_src_modid_o       (ctrl_noc_tx_src_modid_s),
        .noc_tx_trg_chipid_o      (ctrl_noc_tx_trg_chipid_s),
        .noc_tx_trg_modid_o       (ctrl_noc_tx_trg_modid_s),
        .noc_tx_mode_o            (ctrl_noc_tx_mode_s),
        .noc_tx_addr_o            (ctrl_noc_tx_addr_s),
        .noc_tx_data0_o           (ctrl_noc_tx_data0_s),
        .noc_tx_data1_o           (ctrl_noc_tx_data1_s),
        .noc_tx_stall_i           (ctrl_noc_tx_stall_s),

        //---------------
        //reg IF
        .reg_en_o                 (ctrl_reg_en_s),
        .reg_wben_o               (ctrl_reg_wben_s),
        .reg_addr_o               (ctrl_reg_addr_s),
        .reg_wdata_o              (ctrl_reg_wdata_s),
        .reg_rdata_i              (ctrl_reg_rdata_s),
        .reg_stall_i              (ctrl_reg_stall_s),

        //---------------
        //mem IF
        .mem_en_o                 (tcu_mem_en_s),
        .mem_req_o                (tcu_mem_req_s),
        .mem_wben_o               (tcu_mem_wben_s),
        .mem_addr_o               (tcu_mem_addr_s),
        .mem_wdata_o              (tcu_mem_wdata_s),
        .mem_rdata_i              (tcu_mem_rdata_s),
        .mem_rdata_avail_i        (tcu_mem_rdata_avail_s),
        .mem_wdata_infifo_i       (tcu_mem_wdata_infifo_s),
        .mem_wabort_o             (tcu_mem_wabort_s),
        .mem_wstall_i             (tcu_mem_wstall_s),
        .mem_rstall_i             (tcu_mem_rstall_s),

        //---------------
        //tcu trigger
        .tcu_fire_i               (tcu_fire_s),
        .tcu_fire_cmd_i           (tcu_fire_cmd_s),
        .tcu_fire_data_addr_i     (tcu_fire_data_addr_s),
        .tcu_fire_data_size_i     (tcu_fire_data_size_s),
        .tcu_fire_arg1_i          (tcu_fire_arg1_s),
        .tcu_fire_cur_vpe_i       (tcu_fire_cur_vpe_s),

        //---------------
        //Log IF
        .tcu_log_en_o             (tcu_log_en_s),
        .tcu_log_data_o           (tcu_log_data_s),
        .tcu_log_cur_vpe_i        (tcu_log_cur_vpe_s),
        .tcu_log_pmp_i            (tcu_log_pmp_s),

        //---------------
        //PMP failures
        .core_req_pmpfail_push_i  (core_req_pmpfail_push_s),
        .core_req_pmpfail_data_i  (core_req_pmpfail_data_s),
        .core_req_pmpfail_stall_o (core_req_pmpfail_stall_s),

        //---------------
        //global TCU reset and time
        .tcu_reset_i              (tcu_reset_s),
        .tcu_cur_time_i           (tcu_cur_time_s),

        //---------------
        //TCU feature settings
        .tcu_features_virt_addr_i (tcu_features_virt_addr_s),
        .tcu_features_virt_pes_i  (tcu_features_virt_pes_s),

        //---------------
        //TCU print trigger
        .tcu_print_valid_i        (tcu_print_valid_s),

        //---------------
        //TCU status
        .tcu_status_o             (tcu_status_o),
        .noc_error_flit_count_o   (noc_error_flit_count_s),
        .noc_drop_flit_count_o    (noc_drop_flit_count_s),

        //---------------
        //Home Chip/Mod-ID
        .home_chipid_i            (home_chipid_i),
        .home_modid_i             (home_modid_i),

        //---------------
        //debug print IDs
        .print_chipid_i           (print_chipid_i),
        .print_modid_i            (print_modid_i)
    );


endmodule
