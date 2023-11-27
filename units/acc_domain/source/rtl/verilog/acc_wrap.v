
module acc_wrap #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,`include "mod_ids.vh"
    ,parameter ACC_TYPE           = "none",
    parameter HOME_MODID          = {NOC_MODID_SIZE{1'b0}},
    parameter CLKFREQ_MHZ         = 100,

    //ASM: addresses to be aligned with PicoRV32 linker script
    parameter ASM_IMEM_START_ADDR = 32'h00000000,
    parameter ASM_IMEM_SIZE       = 'h10000,
    parameter ASM_DMEM_START_ADDR = ASM_IMEM_START_ADDR + ASM_IMEM_SIZE,
    parameter ASM_DMEM_SIZE       = 'h4000,
    parameter ASM_CORE_DATA_SIZE  = 32,
    parameter ASM_CORE_ADDR_SIZE  = 32,
    parameter ASM_CORE_BSEL_SIZE  = ASM_CORE_DATA_SIZE/8,
    parameter ASM_MEM_DATA_SIZE   = 128,
    parameter ASM_MEM_ADDR_SIZE   = 13,
    parameter ASM_MEM_BSEL_SIZE   = ASM_MEM_DATA_SIZE/8,

    //accelerator
    parameter ACC_MEM_START_ADDR = ASM_DMEM_START_ADDR + ASM_DMEM_SIZE, //0x14000
    parameter ACC_MEM_SIZE       = 'h1000,  //4kB
    parameter ACC_CORE_DATA_SIZE = 128,
    parameter ACC_CORE_ADDR_SIZE = 32,
    parameter ACC_CORE_BSEL_SIZE = ACC_CORE_DATA_SIZE/8,
    parameter ACC_MEM_DATA_SIZE  = ASM_MEM_DATA_SIZE,
    parameter ACC_MEM_ADDR_SIZE  = 8,
    parameter ACC_MEM_BSEL_SIZE  = ACC_MEM_DATA_SIZE/8
)
(
    input  wire                                     clk_pm_i,
    input  wire                                     reset_pm_n_i,
    input  wire               [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input  wire               [NOC_CHIPID_SIZE-1:0] host_chipid_i,
    input  wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_pm_in_data_i,
    output wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_in_raddr_o,
    input  wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_in_waddr_i,
    output wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_pm_out_data_o,
    input  wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_out_raddr_i,
    output wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_out_waddr_o
);


    wire                             clk_asm_s;
    wire                             reset_asm_n_s;
    wire                             clk_acc_s;
    wire                             reset_acc_n_s;

    wire                             noclnk_pm_rx_flit_avail_n_s;
    wire       [NOC_HEADER_SIZE-1:0] noclnk_pm_rx_header_s;
    wire      [NOC_PAYLOAD_SIZE-1:0] noclnk_pm_rx_payload_s;
    wire                             noclnk_pm_rx_rdreq_s;
    wire       [NOC_HEADER_SIZE-1:0] noclnk_pm_tx_header_s;
    wire      [NOC_PAYLOAD_SIZE-1:0] noclnk_pm_tx_payload_s;
    wire                             noclnk_pm_tx_stall_s;
    wire                             noclnk_pm_tx_wrreq_s;

    wire         [NOC_ADDR_SIZE-1:0] pm_rx_mod_addr_s;
    wire                             pm_rx_mod_burst_s;
    wire                             pm_rx_mod_arq_s;
    wire         [NOC_BSEL_SIZE-1:0] pm_rx_mod_bsel_s;
    wire         [NOC_DATA_SIZE-1:0] pm_rx_mod_data0_s;
    wire         [NOC_DATA_SIZE-1:0] pm_rx_mod_data1_s;
    wire         [NOC_MODE_SIZE-1:0] pm_rx_mod_mode_s;
    wire                             pm_rx_mod_stall_s;
    wire                             pm_rx_mod_wrreq_s;
    wire     [CHIP_X_COORD_SIZE-1:0] pm_rx_src_chip_x_coord_s;
    wire     [CHIP_Y_COORD_SIZE-1:0] pm_rx_src_chip_y_coord_s;
    wire     [CHIP_Z_COORD_SIZE-1:0] pm_rx_src_chip_z_coord_s;
    wire       [NOC_CHIPID_SIZE-1:0] pm_rx_src_chipid_s;
    wire      [MOD_X_COORD_SIZE-1:0] pm_rx_src_mod_x_coord_s;
    wire      [MOD_Y_COORD_SIZE-1:0] pm_rx_src_mod_y_coord_s;
    wire      [MOD_Z_COORD_SIZE-1:0] pm_rx_src_mod_z_coord_s;
    wire        [NOC_MODID_SIZE-1:0] pm_rx_src_modid_s;
    wire     [CHIP_X_COORD_SIZE-1:0] pm_rx_trg_chip_x_coord_s;
    wire     [CHIP_Y_COORD_SIZE-1:0] pm_rx_trg_chip_y_coord_s;
    wire     [CHIP_Z_COORD_SIZE-1:0] pm_rx_trg_chip_z_coord_s;
    wire       [NOC_CHIPID_SIZE-1:0] pm_rx_trg_chipid_s;
    wire      [MOD_X_COORD_SIZE-1:0] pm_rx_trg_mod_x_coord_s;
    wire      [MOD_Y_COORD_SIZE-1:0] pm_rx_trg_mod_y_coord_s;
    wire      [MOD_Z_COORD_SIZE-1:0] pm_rx_trg_mod_z_coord_s;
    wire        [NOC_MODID_SIZE-1:0] pm_rx_trg_modid_s;

    wire         [NOC_ADDR_SIZE-1:0] pm_tx_mod_addr_s;
    wire                             pm_tx_mod_burst_s;
    wire                             pm_tx_mod_arq_s;
    wire         [NOC_BSEL_SIZE-1:0] pm_tx_mod_bsel_s;
    wire         [NOC_DATA_SIZE-1:0] pm_tx_mod_data0_s;
    wire         [NOC_DATA_SIZE-1:0] pm_tx_mod_data1_s;
    wire         [NOC_MODE_SIZE-1:0] pm_tx_mod_mode_s;
    wire                             pm_tx_mod_stall_s;
    wire                             pm_tx_mod_wrreq_s;
    wire     [CHIP_X_COORD_SIZE-1:0] pm_tx_src_chip_x_coord_s;
    wire     [CHIP_Y_COORD_SIZE-1:0] pm_tx_src_chip_y_coord_s;
    wire     [CHIP_Z_COORD_SIZE-1:0] pm_tx_src_chip_z_coord_s;
    wire       [NOC_CHIPID_SIZE-1:0] pm_tx_src_chipid_s;
    wire      [MOD_X_COORD_SIZE-1:0] pm_tx_src_mod_x_coord_s;
    wire      [MOD_Y_COORD_SIZE-1:0] pm_tx_src_mod_y_coord_s;
    wire      [MOD_Z_COORD_SIZE-1:0] pm_tx_src_mod_z_coord_s;
    wire        [NOC_MODID_SIZE-1:0] pm_tx_src_modid_s;
    wire     [CHIP_X_COORD_SIZE-1:0] pm_tx_trg_chip_x_coord_s;
    wire     [CHIP_Y_COORD_SIZE-1:0] pm_tx_trg_chip_y_coord_s;
    wire     [CHIP_Z_COORD_SIZE-1:0] pm_tx_trg_chip_z_coord_s;
    wire       [NOC_CHIPID_SIZE-1:0] pm_tx_trg_chipid_s;
    wire      [MOD_X_COORD_SIZE-1:0] pm_tx_trg_mod_x_coord_s;
    wire      [MOD_Y_COORD_SIZE-1:0] pm_tx_trg_mod_y_coord_s;
    wire      [MOD_Z_COORD_SIZE-1:0] pm_tx_trg_mod_z_coord_s;
    wire        [NOC_MODID_SIZE-1:0] pm_tx_trg_modid_s;


    //RISC-V to memory signals
    wire                            asm2tcu_mem_en;
    wire   [ASM_CORE_BSEL_SIZE-1:0] asm2tcu_mem_we;
    wire   [ASM_CORE_ADDR_SIZE-1:0] asm2tcu_mem_addr;
    wire   [ASM_CORE_DATA_SIZE-1:0] asm2tcu_mem_wdata;
    wire   [ASM_CORE_DATA_SIZE-1:0] asm2tcu_mem_rdata;
    wire                            asm2tcu_mem_stall;

    //Accelerator memory signals
    wire                            acc2tcu_mem_en;
    wire   [ACC_CORE_BSEL_SIZE-1:0] acc2tcu_mem_wben;
    wire   [ACC_CORE_ADDR_SIZE-1:0] acc2tcu_mem_addr;
    wire   [ACC_CORE_DATA_SIZE-1:0] acc2tcu_mem_wdata;
    wire   [ACC_CORE_DATA_SIZE-1:0] acc2tcu_mem_rdata;
    wire                            acc2tcu_mem_stall;

    wire                            tcu2asm_mem_en;
    wire    [ASM_MEM_BSEL_SIZE-1:0] tcu2asm_mem_wben;
    wire    [ASM_MEM_ADDR_SIZE-1:0] tcu2asm_mem_addr;
    wire    [ASM_MEM_DATA_SIZE-1:0] tcu2asm_mem_wdata;
    wire    [ASM_MEM_DATA_SIZE-1:0] tcu2asm_mem_rdata;
    wire                            tcu2asm_mem_stall;

    wire                            tcu2acc_mem_en;
    wire    [ACC_MEM_BSEL_SIZE-1:0] tcu2acc_mem_wben;
    wire    [ACC_MEM_ADDR_SIZE-1:0] tcu2acc_mem_addr;
    wire    [ACC_MEM_DATA_SIZE-1:0] tcu2acc_mem_wdata;
    wire    [ACC_MEM_DATA_SIZE-1:0] tcu2acc_mem_rdata;
    wire                            tcu2acc_mem_stall;

    wire                         mux_asm_mem_en;
    wire [ASM_MEM_BSEL_SIZE-1:0] mux_asm_mem_wben;
    wire [ASM_MEM_ADDR_SIZE-1:0] mux_asm_mem_addr;
    wire [ASM_MEM_DATA_SIZE-1:0] mux_asm_mem_wdata;
    wire [ASM_MEM_DATA_SIZE-1:0] mux_asm_mem_rdata;

    wire                         mux_acc_mem_en;
    wire [ACC_MEM_BSEL_SIZE-1:0] mux_acc_mem_wben;
    wire [ACC_MEM_ADDR_SIZE-1:0] mux_acc_mem_addr;
    wire [ACC_MEM_DATA_SIZE-1:0] mux_acc_mem_wdata;
    wire [ACC_MEM_DATA_SIZE-1:0] mux_acc_mem_rdata;

    //TCU memory signals
    wire                            tcu_asm_mem_en;
    wire    [ASM_MEM_BSEL_SIZE-1:0] tcu_asm_mem_wben;
    wire    [ASM_MEM_ADDR_SIZE-1:0] tcu_asm_mem_addr;
    wire    [ASM_MEM_DATA_SIZE-1:0] tcu_asm_mem_wdata;
    wire    [ASM_MEM_DATA_SIZE-1:0] tcu_asm_mem_rdata;
    wire                            tcu_asm_mem_stall;

    wire                            tcu_acc_mem_en;
    wire    [ACC_MEM_BSEL_SIZE-1:0] tcu_acc_mem_wben;
    wire    [ACC_MEM_ADDR_SIZE-1:0] tcu_acc_mem_addr;
    wire    [ACC_MEM_DATA_SIZE-1:0] tcu_acc_mem_wdata;
    wire    [ACC_MEM_DATA_SIZE-1:0] tcu_acc_mem_rdata;
    wire                            tcu_acc_mem_stall;


    //core config signals
    wire                             asm_config_en;
    wire     [TCU_REG_BSEL_SIZE-1:0] asm_config_wben;
    wire     [TCU_REG_ADDR_SIZE-1:0] asm_config_addr;
    wire     [TCU_REG_DATA_SIZE-1:0] asm_config_wdata;
    wire     [TCU_REG_DATA_SIZE-1:0] asm_config_rdata;

    wire                             asm_en;
    wire                             pico_trap;
    wire                      [31:0] pico_irq;
    wire                      [31:0] pico_eoi;
    wire    [ASM_CORE_ADDR_SIZE-1:0] pico_stackaddr;

    wire                             acc_en;

    //status flag
    wire       [TCU_STATUS_SIZE-1:0] tcu_status;



noc_link_par_phy i_noc_link_par_phy_pm (
    .clk_i                (clk_pm_i),
    .rst_q_i              (reset_pm_n_i),
    .rx_fifo_empty_o      (noclnk_pm_rx_flit_avail_n_s),
    .rx_fifo_read_addr_o  (noc_fifo_pm_in_raddr_o),
    .rx_fifo_read_data_i  (noc_fifo_pm_in_data_i),
    .rx_fifo_write_addr_i (noc_fifo_pm_in_waddr_i),
    .rx_header_o          (noclnk_pm_rx_header_s),
    .rx_payload_o         (noclnk_pm_rx_payload_s),
    .rx_rdreq_i           (noclnk_pm_rx_rdreq_s),
    .testmode_i           (1'b0),
    .tx_fifo_read_addr_i  (noc_fifo_pm_out_raddr_i),
    .tx_fifo_read_data_o  (noc_fifo_pm_out_data_o),
    .tx_fifo_write_addr_o (noc_fifo_pm_out_waddr_o),
    .tx_header_i          (noclnk_pm_tx_header_s),
    .tx_payload_i         (noclnk_pm_tx_payload_s),
    .tx_stall_o           (noclnk_pm_tx_stall_s),
    .tx_wrreq_i           (noclnk_pm_tx_wrreq_s)
);

nocif i_nocif_pm (
    .clk_i                (clk_pm_i),
    .flit_avail_q_i       (noclnk_pm_rx_flit_avail_n_s),
    .header_i             (noclnk_pm_rx_header_s),
    .header_o             (noclnk_pm_tx_header_s),
    .mod_addr_i           (pm_tx_mod_addr_s),
    .mod_addr_o           (pm_rx_mod_addr_s),
    .mod_burst_i          (pm_tx_mod_burst_s),
    .mod_burst_o          (pm_rx_mod_burst_s),
    .mod_arq_i            (pm_tx_mod_arq_s),
    .mod_arq_o            (pm_rx_mod_arq_s),
    .mod_bsel_i           (pm_tx_mod_bsel_s),
    .mod_bsel_o           (pm_rx_mod_bsel_s),
    .mod_data0_i          (pm_tx_mod_data0_s),
    .mod_data0_o          (pm_rx_mod_data0_s),
    .mod_data1_i          (pm_tx_mod_data1_s),
    .mod_data1_o          (pm_rx_mod_data1_s),
    .mod_mode_i           (pm_tx_mod_mode_s),
    .mod_mode_o           (pm_rx_mod_mode_s),
    .mod_stall_i          (pm_rx_mod_stall_s),
    .mod_stall_o          (pm_tx_mod_stall_s),
    .mod_wrreq_i          (pm_tx_mod_wrreq_s),
    .mod_wrreq_o          (pm_rx_mod_wrreq_s),
    .payload_i            (noclnk_pm_rx_payload_s),
    .payload_o            (noclnk_pm_tx_payload_s),
    .rdreq_o              (noclnk_pm_rx_rdreq_s),
    .reset_q_i            (reset_pm_n_i),
    .src_chip_x_coord_i   (pm_tx_src_chip_x_coord_s),
    .src_chip_x_coord_o   (pm_rx_src_chip_x_coord_s),
    .src_chip_y_coord_i   (pm_tx_src_chip_y_coord_s),
    .src_chip_y_coord_o   (pm_rx_src_chip_y_coord_s),
    .src_chip_z_coord_i   (pm_tx_src_chip_z_coord_s),
    .src_chip_z_coord_o   (pm_rx_src_chip_z_coord_s),
    .src_mod_x_coord_i    (pm_tx_src_mod_x_coord_s),
    .src_mod_x_coord_o    (pm_rx_src_mod_x_coord_s),
    .src_mod_y_coord_i    (pm_tx_src_mod_y_coord_s),
    .src_mod_y_coord_o    (pm_rx_src_mod_y_coord_s),
    .src_mod_z_coord_i    (pm_tx_src_mod_z_coord_s),
    .src_mod_z_coord_o    (pm_rx_src_mod_z_coord_s),
    .stall_i              (noclnk_pm_tx_stall_s),
    .trg_chip_x_coord_i   (pm_tx_trg_chip_x_coord_s),
    .trg_chip_x_coord_o   (pm_rx_trg_chip_x_coord_s),
    .trg_chip_y_coord_i   (pm_tx_trg_chip_y_coord_s),
    .trg_chip_y_coord_o   (pm_rx_trg_chip_y_coord_s),
    .trg_chip_z_coord_i   (pm_tx_trg_chip_z_coord_s),
    .trg_chip_z_coord_o   (pm_rx_trg_chip_z_coord_s),
    .trg_mod_x_coord_i    (pm_tx_trg_mod_x_coord_s),
    .trg_mod_x_coord_o    (pm_rx_trg_mod_x_coord_s),
    .trg_mod_y_coord_i    (pm_tx_trg_mod_y_coord_s),
    .trg_mod_y_coord_o    (pm_rx_trg_mod_y_coord_s),
    .trg_mod_z_coord_i    (pm_tx_trg_mod_z_coord_s),
    .trg_mod_z_coord_o    (pm_rx_trg_mod_z_coord_s),
    .wrreq_o              (noclnk_pm_tx_wrreq_s)
);



picorv32_core #(
    .PICO_MEM_DATA_SIZE (ASM_CORE_DATA_SIZE),
    .PICO_MEM_ADDR_SIZE (ASM_CORE_ADDR_SIZE)
) i_picorv32_core (
    .clk_i              (clk_asm_s),
    .resetn_i           (reset_asm_n_s),

    .mem_en_o           (asm2tcu_mem_en),
    .mem_we_o           (asm2tcu_mem_we),
    .mem_addr_o         (asm2tcu_mem_addr),
    .mem_wdata_o        (asm2tcu_mem_wdata),
    .mem_rdata_i        (asm2tcu_mem_rdata),
    .mem_stall_i        (asm2tcu_mem_stall),

    .trap_o             (pico_trap),
    .irq_i              (pico_irq),
    .eoi_o              (pico_eoi),

    .stackaddr_i        (pico_stackaddr)
);


acc_core #(
    .MEM_DATA_SIZE      (ACC_CORE_DATA_SIZE),
    .MEM_ADDR_SIZE      (ACC_CORE_ADDR_SIZE)
) i_acc_core (
    .clk_i              (clk_acc_s),
    .resetn_i           (reset_acc_n_s),

    .mem_en_o           (acc2tcu_mem_en),
    .mem_we_o           (acc2tcu_mem_wben),
    .mem_addr_o         (acc2tcu_mem_addr),
    .mem_wdata_o        (acc2tcu_mem_wdata),
    .mem_rdata_i        (acc2tcu_mem_rdata),
    .mem_stall_i        (acc2tcu_mem_stall)
);


asm_regfile #(
    .PICO_STACKADDR     (ACC_MEM_START_ADDR)   //stack should start at end of DMEM
) i_asm_regfile (
    .clk_i              (clk_pm_i),
    .reset_n_i          (reset_pm_n_i),

    .config_en_i        (asm_config_en),
    .config_wben_i      (asm_config_wben),
    .config_addr_i      (asm_config_addr),
    .config_wdata_i     (asm_config_wdata),
    .config_rdata_o     (asm_config_rdata),

    .acc_en_o           (acc_en),
    .asm_en_o           (asm_en),
    .pico_trap_i        (pico_trap),
    .pico_irq_o         (pico_irq),
    .pico_eoi_i         (pico_eoi),
    .pico_stackaddr_o   (pico_stackaddr)
);


asm_mem_mux #(
    .MEM_DATAWIDTH      (ASM_MEM_DATA_SIZE),
    .MEM_ADDRWIDTH      (ASM_MEM_ADDR_SIZE)
) asm_mux_asmtcu (
    .mem_in1_en_i       (tcu2asm_mem_en),
    .mem_in1_wben_i     (tcu2asm_mem_wben),
    .mem_in1_addr_i     (tcu2asm_mem_addr),
    .mem_in1_wdata_i    (tcu2asm_mem_wdata),
    .mem_in1_rdata_o    (tcu2asm_mem_rdata),
    .mem_in1_stall_o    (tcu2asm_mem_stall),

    .mem_in2_en_i       (tcu_asm_mem_en),
    .mem_in2_wben_i     (tcu_asm_mem_wben),
    .mem_in2_addr_i     (tcu_asm_mem_addr),
    .mem_in2_wdata_i    (tcu_asm_mem_wdata),
    .mem_in2_rdata_o    (tcu_asm_mem_rdata),
    .mem_in2_stall_o    (tcu_asm_mem_stall),

    .mem_out_en_o       (mux_asm_mem_en),
    .mem_out_wben_o     (mux_asm_mem_wben),
    .mem_out_addr_o     (mux_asm_mem_addr),
    .mem_out_wdata_o    (mux_asm_mem_wdata),
    .mem_out_rdata_i    (mux_asm_mem_rdata),
    .mem_out_stall_i    (1'b0)
);


mem_sp_wrap #(
    .MEM_TYPE     ("ultra"),
    .MEM_DATAWIDTH(ASM_MEM_DATA_SIZE),
    .MEM_ADDRWIDTH(ASM_MEM_ADDR_SIZE)
) asm_mem (
    .clk        (clk_pm_i),
    .reset      (~reset_pm_n_i),
    .en         (mux_asm_mem_en),
    .we         (mux_asm_mem_wben),
    .addr       (mux_asm_mem_addr),
    .din        (mux_asm_mem_wdata),
    .dout       (mux_asm_mem_rdata)
);


asm_mem_mux #(
    .MEM_DATAWIDTH      (ACC_MEM_DATA_SIZE),
    .MEM_ADDRWIDTH      (ACC_MEM_ADDR_SIZE)
) asm_mux_acctcu (
    .mem_in1_en_i       (tcu2acc_mem_en),
    .mem_in1_wben_i     (tcu2acc_mem_wben),
    .mem_in1_addr_i     (tcu2acc_mem_addr),
    .mem_in1_wdata_i    (tcu2acc_mem_wdata),
    .mem_in1_rdata_o    (tcu2acc_mem_rdata),
    .mem_in1_stall_o    (tcu2acc_mem_stall),

    .mem_in2_en_i       (tcu_acc_mem_en),
    .mem_in2_wben_i     (tcu_acc_mem_wben),
    .mem_in2_addr_i     (tcu_acc_mem_addr),
    .mem_in2_wdata_i    (tcu_acc_mem_wdata),
    .mem_in2_rdata_o    (tcu_acc_mem_rdata),
    .mem_in2_stall_o    (tcu_acc_mem_stall),

    .mem_out_en_o       (mux_acc_mem_en),
    .mem_out_wben_o     (mux_acc_mem_wben),
    .mem_out_addr_o     (mux_acc_mem_addr),
    .mem_out_wdata_o    (mux_acc_mem_wdata),
    .mem_out_rdata_i    (mux_acc_mem_rdata),
    .mem_out_stall_i    (1'b0)
);


mem_sp_wrap #(
    .MEM_TYPE     ("ultra"),
    .MEM_DATAWIDTH(ACC_MEM_DATA_SIZE),
    .MEM_ADDRWIDTH(ACC_MEM_ADDR_SIZE)
) acc_mem (
    .clk        (clk_pm_i),
    .reset      (~reset_pm_n_i),
    .en         (mux_acc_mem_en),
    .we         (mux_acc_mem_wben),
    .addr       (mux_acc_mem_addr),
    .din        (mux_acc_mem_wdata),
    .dout       (mux_acc_mem_rdata)
);


assign pm_rx_src_chipid_s = {pm_rx_src_chip_x_coord_s, pm_rx_src_chip_y_coord_s, pm_rx_src_chip_z_coord_s};
assign pm_rx_src_modid_s = {pm_rx_src_mod_x_coord_s, pm_rx_src_mod_y_coord_s, pm_rx_src_mod_z_coord_s};
assign pm_rx_trg_chipid_s = {pm_rx_trg_chip_x_coord_s, pm_rx_trg_chip_y_coord_s, pm_rx_trg_chip_z_coord_s};
assign pm_rx_trg_modid_s = {pm_rx_trg_mod_x_coord_s, pm_rx_trg_mod_y_coord_s, pm_rx_trg_mod_z_coord_s};

assign {pm_tx_src_chip_x_coord_s, pm_tx_src_chip_y_coord_s, pm_tx_src_chip_z_coord_s} = pm_tx_src_chipid_s;
assign {pm_tx_src_mod_x_coord_s, pm_tx_src_mod_y_coord_s, pm_tx_src_mod_z_coord_s} = pm_tx_src_modid_s;
assign {pm_tx_trg_chip_x_coord_s, pm_tx_trg_chip_y_coord_s, pm_tx_trg_chip_z_coord_s} = pm_tx_trg_chipid_s;
assign {pm_tx_trg_mod_x_coord_s, pm_tx_trg_mod_y_coord_s, pm_tx_trg_mod_z_coord_s} = pm_tx_trg_modid_s;



tcu_top #(
    .TCU_ENABLE_CMDS            (1),
    .TCU_ENABLE_DRAM            (0),
    .TCU_ENABLE_LOG             (0),
    .TCU_ENABLE_PRINT           (1),
    .CLKFREQ_MHZ                (CLKFREQ_MHZ),
    .TILE_TYPE                  ('d0),      //processing tile
    .TILE_ISA                   ('d1),
    .TILE_ATTR                  ('d16),     //attribute for PicoRV32 core not defined yet, only internal SPM
    .TILE_MEMSIZE               ((ASM_IMEM_SIZE+ASM_DMEM_SIZE+ACC_MEM_SIZE) >> 12),    //80kB + 4kB
    .CORE_DMEM_DATA_SIZE        (ASM_CORE_DATA_SIZE),   //ASM is connected to TCU's DMEM interface
    .CORE_DMEM_ADDR_SIZE        (ASM_CORE_ADDR_SIZE),
    .CORE_DMEM_BSEL_SIZE        (ASM_CORE_BSEL_SIZE),
    .CORE_IMEM_DATA_SIZE        (ACC_CORE_DATA_SIZE),   //accelerator is connected to TCU's IMEM interface
    .CORE_IMEM_ADDR_SIZE        (ACC_CORE_ADDR_SIZE),
    .CORE_IMEM_BSEL_SIZE        (ACC_CORE_BSEL_SIZE),
    .DMEM_DATA_SIZE             (ASM_MEM_DATA_SIZE),
    .DMEM_ADDR_SIZE             (ASM_MEM_ADDR_SIZE),
    .DMEM_BSEL_SIZE             (ASM_MEM_BSEL_SIZE),
    .IMEM_DATA_SIZE             (ACC_MEM_DATA_SIZE),
    .IMEM_ADDR_SIZE             (ACC_MEM_ADDR_SIZE),
    .IMEM_BSEL_SIZE             (ACC_MEM_BSEL_SIZE),
    .DMEM_START_ADDR            (ASM_IMEM_START_ADDR),
    .DMEM_SIZE                  (ASM_DMEM_SIZE+ASM_IMEM_SIZE),
    .IMEM_START_ADDR            (ACC_MEM_START_ADDR),
    .IMEM_SIZE                  (ACC_MEM_SIZE),
    .NOCMUX_TX_IF1_PRIO         (1),         //there is only IF1
    .NOCMUX_RX_IF1_PRIO         (1),
    .NOCMUX_RX_IF1_ADDR_START   (32'h0),
    .NOCMUX_RX_IF1_ADDR_END     (32'hFFFFFFFF),
    .NOCMUX_RX_IF1_ONLY_MODE_2  (0),
    .NOCMUX_RX_IF2_ADDR_START   (32'h0),
    .NOCMUX_RX_IF2_ADDR_END     (32'h0),
    .NOCMUX_RX_IF2_ONLY_MODE_2  (0)
) i_tcu_top (
    .clk_i                      (clk_pm_i),
    .reset_n_i                  (reset_pm_n_i),

    .tcu_noc_rx_wrreq_i         (pm_rx_mod_wrreq_s),
    .tcu_noc_rx_burst_i         (pm_rx_mod_burst_s),
    .tcu_noc_rx_arq_i           (pm_rx_mod_arq_s),
    .tcu_noc_rx_bsel_i          (pm_rx_mod_bsel_s),
    .tcu_noc_rx_src_chipid_i    (pm_rx_src_chipid_s),
    .tcu_noc_rx_src_modid_i     (pm_rx_src_modid_s),
    .tcu_noc_rx_trg_chipid_i    (pm_rx_trg_chipid_s),
    .tcu_noc_rx_trg_modid_i     (pm_rx_trg_modid_s),
    .tcu_noc_rx_mode_i          (pm_rx_mod_mode_s),
    .tcu_noc_rx_addr_i          (pm_rx_mod_addr_s),
    .tcu_noc_rx_data0_i         (pm_rx_mod_data0_s),
    .tcu_noc_rx_data1_i         (pm_rx_mod_data1_s),
    .tcu_noc_rx_stall_o         (pm_rx_mod_stall_s),

    .tcu_noc_tx_wrreq_o         (pm_tx_mod_wrreq_s),
    .tcu_noc_tx_burst_o         (pm_tx_mod_burst_s),
    .tcu_noc_tx_arq_o           (pm_tx_mod_arq_s),
    .tcu_noc_tx_bsel_o          (pm_tx_mod_bsel_s),
    .tcu_noc_tx_src_chipid_o    (pm_tx_src_chipid_s),
    .tcu_noc_tx_src_modid_o     (pm_tx_src_modid_s),
    .tcu_noc_tx_trg_chipid_o    (pm_tx_trg_chipid_s),
    .tcu_noc_tx_trg_modid_o     (pm_tx_trg_modid_s),
    .tcu_noc_tx_mode_o          (pm_tx_mod_mode_s),
    .tcu_noc_tx_addr_o          (pm_tx_mod_addr_s),
    .tcu_noc_tx_data0_o         (pm_tx_mod_data0_s),
    .tcu_noc_tx_data1_o         (pm_tx_mod_data1_s),
    .tcu_noc_tx_stall_i         (pm_tx_mod_stall_s),

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

    .core_dmem_in_en_i          (asm2tcu_mem_en),
    .core_dmem_in_wben_i        (asm2tcu_mem_we),
    .core_dmem_in_addr_i        (asm2tcu_mem_addr),
    .core_dmem_in_wdata_i       (asm2tcu_mem_wdata),
    .core_dmem_in_rdata_o       (asm2tcu_mem_rdata),
    .core_dmem_in_stall_o       (asm2tcu_mem_stall),

    .core_imem_in_en_i          (acc2tcu_mem_en),
    .core_imem_in_wben_i        (acc2tcu_mem_wben),
    .core_imem_in_addr_i        (acc2tcu_mem_addr),
    .core_imem_in_wdata_i       (acc2tcu_mem_wdata),
    .core_imem_in_rdata_o       (acc2tcu_mem_rdata),
    .core_imem_in_stall_o       (acc2tcu_mem_stall),

    .core_dmem_out_en_o         (tcu2asm_mem_en),
    .core_dmem_out_wben_o       (tcu2asm_mem_wben),
    .core_dmem_out_addr_o       (tcu2asm_mem_addr),
    .core_dmem_out_wdata_o      (tcu2asm_mem_wdata),
    .core_dmem_out_rdata_i      (tcu2asm_mem_rdata),
    .core_dmem_out_stall_i      (tcu2asm_mem_stall),

    .core_imem_out_en_o         (tcu2acc_mem_en),
    .core_imem_out_wben_o       (tcu2acc_mem_wben),
    .core_imem_out_addr_o       (tcu2acc_mem_addr),
    .core_imem_out_wdata_o      (tcu2acc_mem_wdata),
    .core_imem_out_rdata_i      (tcu2acc_mem_rdata),
    .core_imem_out_stall_i      (tcu2acc_mem_stall),

    .tcu_dmem_en_o              (tcu_asm_mem_en),
    .tcu_dmem_req_o             (),
    .tcu_dmem_wben_o            (tcu_asm_mem_wben),
    .tcu_dmem_addr_o            (tcu_asm_mem_addr),
    .tcu_dmem_wdata_o           (tcu_asm_mem_wdata),
    .tcu_dmem_rdata_i           (tcu_asm_mem_rdata),
    .tcu_dmem_rdata_avail_i     (1'b0),
    .tcu_dmem_wdata_infifo_i    (1'b0),
    .tcu_dmem_wabort_o          (),
    .tcu_dmem_wstall_i          (tcu_asm_mem_stall),
    .tcu_dmem_rstall_i          (tcu_asm_mem_stall),

    .tcu_imem_en_o              (tcu_acc_mem_en),
    .tcu_imem_req_o             (),
    .tcu_imem_wben_o            (tcu_acc_mem_wben),
    .tcu_imem_addr_o            (tcu_acc_mem_addr),
    .tcu_imem_wdata_o           (tcu_acc_mem_wdata),
    .tcu_imem_rdata_i           (tcu_acc_mem_rdata),
    .tcu_imem_rdata_avail_i     (1'b0),
    .tcu_imem_wdata_infifo_i    (1'b0),
    .tcu_imem_wabort_o          (),
    .tcu_imem_wstall_i          (tcu_acc_mem_stall),
    .tcu_imem_rstall_i          (tcu_acc_mem_stall),

    .config_mem_en_o            (asm_config_en),
    .config_mem_wben_o          (asm_config_wben),
    .config_mem_addr_o          (asm_config_addr),
    .config_mem_wdata_o         (asm_config_wdata),
    .config_mem_rdata_i         (asm_config_rdata),

    .tcu_status_o               (tcu_status),

    .home_chipid_i              (home_chipid_i),
    .home_modid_i               (HOME_MODID),

    .print_chipid_i             (host_chipid_i),
    .print_modid_i              (MODID_ETH)
);


acc_ctrl i_asm_ctrl (
    .clk_i(clk_pm_i),
    .clk_core_o(clk_asm_s),
    .core_en_i(asm_en),
    .reset_core_n_o(reset_asm_n_s),
    .reset_n_i(reset_pm_n_i)
);

acc_ctrl i_acc_ctrl (
    .clk_i(clk_pm_i),
    .clk_core_o(clk_acc_s),
    .core_en_i(acc_en),
    .reset_core_n_o(reset_acc_n_s),
    .reset_n_i(reset_pm_n_i)
);


endmodule
