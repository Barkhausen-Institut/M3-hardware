
module boom_wrap #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,`include "mod_ids.vh"
    ,parameter HOME_MODID         = {NOC_MODID_SIZE{1'b0}},
    parameter PM_UART_ATTACHED    = 0,
    parameter CLKFREQ_MHZ         = 100,
    parameter BOOM_USE_LOCAL_MEM  = 0,
    parameter CORE_DMEM_DATA_SIZE = 64,    //reg interface
    parameter CORE_DMEM_ADDR_SIZE = 32,
    parameter CORE_DMEM_BSEL_SIZE = CORE_DMEM_DATA_SIZE/8,
    parameter CORE_IMEM_DATA_SIZE = 128,   //connects to Boom mem interface
    parameter CORE_IMEM_ADDR_SIZE = 32,
    parameter CORE_IMEM_BSEL_SIZE = CORE_IMEM_DATA_SIZE/8,
    parameter BOOM_MEM_DATA_SIZE  = 128,   //Boom mem interface
    parameter BOOM_MEM_ADDR_SIZE  = 32,
    parameter BOOM_MEM_BSEL_SIZE  = BOOM_MEM_DATA_SIZE/8,
    parameter DMEM_DATA_SIZE      = 128,   //connects to reg interface
    parameter DMEM_ADDR_SIZE      = 17,
    parameter DMEM_BSEL_SIZE      = DMEM_DATA_SIZE/8,
    parameter IMEM_DATA_SIZE      = 128,   //SPM interface
    parameter IMEM_ADDR_SIZE      = 17,
    parameter IMEM_BSEL_SIZE      = IMEM_DATA_SIZE/8,

    //TCU memory map according to Boom config
    //for TCU everything in imem
    parameter DMEM_START_ADDR     = 32'h00000000,
    parameter DMEM_SIZE           = 'h0,
    parameter IMEM_START_ADDR     = 32'h00000000,
    parameter IMEM_SIZE           = BOOM_USE_LOCAL_MEM ? 'h10200000 : 'hE0000000
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
    output wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_out_waddr_o,

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
    wire                             boom_tcu_reg_en;
    wire   [CORE_DMEM_BSEL_SIZE-1:0] boom_tcu_reg_wben;
    wire   [CORE_DMEM_ADDR_SIZE-1:0] boom_tcu_reg_addr;
    wire   [CORE_DMEM_DATA_SIZE-1:0] boom_tcu_reg_wdata;
    wire   [CORE_DMEM_DATA_SIZE-1:0] boom_tcu_reg_rdata;
    wire                             boom_tcu_reg_stall;

    wire                             boom_mem_en;
    wire    [BOOM_MEM_BSEL_SIZE-1:0] boom_mem_wben;
    wire    [BOOM_MEM_ADDR_SIZE-1:0] boom_mem_addr;
    wire    [BOOM_MEM_DATA_SIZE-1:0] boom_mem_wdata;
    wire    [BOOM_MEM_DATA_SIZE-1:0] boom_mem_rdata;

    wire                             boom_tcu_mem_en;
    wire    [BOOM_MEM_BSEL_SIZE-1:0] boom_tcu_mem_wben;
    wire    [BOOM_MEM_ADDR_SIZE-1:0] boom_tcu_mem_addr;
    wire    [BOOM_MEM_DATA_SIZE-1:0] boom_tcu_mem_wdata;
    wire    [BOOM_MEM_DATA_SIZE-1:0] boom_tcu_mem_rdata;

    //RISC-V to NoC signals
    wire                             boom_noc_rx_wrreq_s;
    wire                             boom_noc_rx_burst_s;
    wire         [NOC_BSEL_SIZE-1:0] boom_noc_rx_bsel_s;
    wire       [NOC_CHIPID_SIZE-1:0] boom_noc_rx_src_chipid_s;
    wire        [NOC_MODID_SIZE-1:0] boom_noc_rx_src_modid_s;
    wire       [NOC_CHIPID_SIZE-1:0] boom_noc_rx_trg_chipid_s;
    wire        [NOC_MODID_SIZE-1:0] boom_noc_rx_trg_modid_s;
    wire         [NOC_MODE_SIZE-1:0] boom_noc_rx_mode_s;
    wire         [NOC_ADDR_SIZE-1:0] boom_noc_rx_addr_s;
    wire         [NOC_DATA_SIZE-1:0] boom_noc_rx_data0_s;
    wire         [NOC_DATA_SIZE-1:0] boom_noc_rx_data1_s;
    wire                             boom_noc_rx_stall_s;

    wire                             boom_noc_tx_wrreq_s;
    wire                             boom_noc_tx_burst_s;
    wire         [NOC_BSEL_SIZE-1:0] boom_noc_tx_bsel_s;
    wire       [NOC_CHIPID_SIZE-1:0] boom_noc_tx_src_chipid_s;
    wire        [NOC_MODID_SIZE-1:0] boom_noc_tx_src_modid_s;
    wire       [NOC_CHIPID_SIZE-1:0] boom_noc_tx_trg_chipid_s;
    wire        [NOC_MODID_SIZE-1:0] boom_noc_tx_trg_modid_s;
    wire         [NOC_MODE_SIZE-1:0] boom_noc_tx_mode_s;
    wire         [NOC_ADDR_SIZE-1:0] boom_noc_tx_addr_s;
    wire         [NOC_DATA_SIZE-1:0] boom_noc_tx_data0_s;
    wire         [NOC_DATA_SIZE-1:0] boom_noc_tx_data1_s;
    wire                             boom_noc_tx_stall_s;

    //TCU memory signals
    wire                             tcu_mem_en;
    wire                             tcu_mem_req;
    wire    [BOOM_MEM_BSEL_SIZE-1:0] tcu_mem_wben;
    wire    [BOOM_MEM_ADDR_SIZE-1:0] tcu_mem_addr;
    wire    [BOOM_MEM_DATA_SIZE-1:0] tcu_mem_wdata;
    wire    [BOOM_MEM_DATA_SIZE-1:0] tcu_mem_rdata;
    wire                             tcu_mem_rdata_avail;
    wire                             tcu_mem_wdata_infifo;
    wire                             tcu_mem_wabort;
    wire                             tcu_mem_wstall;
    wire                             tcu_mem_rstall;


    //core config signals
    wire                             boom_config_en;
    wire     [TCU_REG_BSEL_SIZE-1:0] boom_config_wben;
    wire     [TCU_REG_ADDR_SIZE-1:0] boom_config_addr;
    wire     [TCU_REG_DATA_SIZE-1:0] boom_config_wdata;
    wire     [TCU_REG_DATA_SIZE-1:0] boom_config_rdata;

    wire                             boom_en;
    wire                             boom_ext_int1;
    wire                             boom_ext_int2;

    //number of errors from AXI4 bridges
    wire                      [31:0] tcu_mem_axi4_error;
    wire                      [31:0] axi4_mem_bridge_error;

    //info for traces
    wire                             boom_trace_enabled;
    wire    [BOOM_MEM_ADDR_SIZE-1:0] boom_trace_ptr;
    wire    [BOOM_MEM_ADDR_SIZE-1:0] boom_trace_count;

    //status flag
    wire       [TCU_STATUS_SIZE-1:0] tcu_status;



noc_link_par_phy #(
    .NOC_ASYNC_FIFO_AWIDTH(NOC_ASYNC_FIFO_AWIDTH),
    .NOC_ASYNC_FIFO_PACKET_SIZE(NOC_ASYNC_FIFO_PACKET_SIZE)
) i_noc_link_par_phy_pm (
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



boom_core #(
    .BOOM_USE_LOCAL_MEM         (BOOM_USE_LOCAL_MEM),
    .BOOM_MEM_DATA_SIZE         (BOOM_MEM_DATA_SIZE),
    .BOOM_MEM_ADDR_SIZE         (BOOM_MEM_ADDR_SIZE),
    .BOOM_REG_DATA_SIZE         (CORE_DMEM_DATA_SIZE),
    .BOOM_REG_ADDR_SIZE         (CORE_DMEM_ADDR_SIZE)
) i_boom_core (
    .clk_i                      (clk_core_s),
    .reset_n_i                  (reset_core_n_s),
    
    .mem_en_o                   (boom_mem_en),
    .mem_wben_o                 (boom_mem_wben),
    .mem_addr_o                 (boom_mem_addr),
    .mem_wdata_o                (boom_mem_wdata),
    .mem_rdata_i                (boom_mem_rdata),
    .mem_stall_i                (1'b0),
    
    .boom_noc_tx_wrreq_o        (boom_noc_tx_wrreq_s),
    .boom_noc_tx_burst_o        (boom_noc_tx_burst_s),
    .boom_noc_tx_bsel_o         (boom_noc_tx_bsel_s),
    .boom_noc_tx_src_chipid_o   (boom_noc_tx_src_chipid_s),
    .boom_noc_tx_src_modid_o    (boom_noc_tx_src_modid_s),
    .boom_noc_tx_trg_chipid_o   (boom_noc_tx_trg_chipid_s),
    .boom_noc_tx_trg_modid_o    (boom_noc_tx_trg_modid_s),
    .boom_noc_tx_mode_o         (boom_noc_tx_mode_s),
    .boom_noc_tx_addr_o         (boom_noc_tx_addr_s),
    .boom_noc_tx_data0_o        (boom_noc_tx_data0_s),
    .boom_noc_tx_data1_o        (boom_noc_tx_data1_s),
    .boom_noc_tx_stall_i        (boom_noc_tx_stall_s),

    .boom_noc_rx_wrreq_i        (boom_noc_rx_wrreq_s),
    .boom_noc_rx_burst_i        (boom_noc_rx_burst_s),
    .boom_noc_rx_bsel_i         (boom_noc_rx_bsel_s),
    .boom_noc_rx_src_chipid_i   (boom_noc_rx_src_chipid_s),
    .boom_noc_rx_src_modid_i    (boom_noc_rx_src_modid_s),
    .boom_noc_rx_trg_chipid_i   (boom_noc_rx_trg_chipid_s),
    .boom_noc_rx_trg_modid_i    (boom_noc_rx_trg_modid_s),
    .boom_noc_rx_mode_i         (boom_noc_rx_mode_s),
    .boom_noc_rx_addr_i         (boom_noc_rx_addr_s),
    .boom_noc_rx_data0_i        (boom_noc_rx_data0_s),
    .boom_noc_rx_data1_i        (boom_noc_rx_data1_s),
    .boom_noc_rx_stall_o        (boom_noc_rx_stall_s),

    .reg_en_o                   (boom_tcu_reg_en),
    .reg_wben_o                 (boom_tcu_reg_wben),
    .reg_addr_o                 (boom_tcu_reg_addr),
    .reg_wdata_o                (boom_tcu_reg_wdata),
    .reg_rdata_i                (boom_tcu_reg_rdata),
    .reg_stall_i                (boom_tcu_reg_stall),
    
    .tcu_mem_en_i               (tcu_mem_en),
    .tcu_mem_req_i              (tcu_mem_req),
    .tcu_mem_wben_i             (tcu_mem_wben),
    .tcu_mem_addr_i             (tcu_mem_addr),
    .tcu_mem_wdata_i            (tcu_mem_wdata),
    .tcu_mem_rdata_o            (tcu_mem_rdata),
    .tcu_mem_rdata_avail_o      (tcu_mem_rdata_avail),
    .tcu_mem_wdata_infifo_o     (tcu_mem_wdata_infifo),
    .tcu_mem_wabort_i           (tcu_mem_wabort),
    .tcu_mem_wstall_o           (tcu_mem_wstall),
    .tcu_mem_rstall_o           (tcu_mem_rstall),
    .tcu_mem_access_i           (tcu_status[5] | tcu_status[3] | tcu_status[0]),    //any read access to memory

    .ext_int1_i                 (boom_ext_int1),
    .ext_int2_i                 (boom_ext_int2),

    .uart_tx                    (uart_tx_o),
    .uart_rx                    (uart_rx_i),

    .tcu_mem_axi4_error_o       (tcu_mem_axi4_error),
    .axi4_mem_bridge_error_o    (axi4_mem_bridge_error),

    .boom_trace_enabled_i       (boom_trace_enabled),
    .boom_trace_ptr_o           (boom_trace_ptr),
    .boom_trace_count_o         (boom_trace_count),

    .jtag_tck_i                 (jtag_tck_i),
    .jtag_tms_i                 (jtag_tms_i),
    .jtag_tdi_i                 (jtag_tdi_i),
    .jtag_tdo_o                 (jtag_tdo_o),
    .jtag_tdo_en_o              (jtag_tdo_en_o)
);


generate
if (BOOM_USE_LOCAL_MEM) begin: SPM
    mem_sp_wrap #(
        .MEM_TYPE     ("ultra"),
        .MEM_DATAWIDTH(IMEM_DATA_SIZE),
        .MEM_ADDRWIDTH(IMEM_ADDR_SIZE)
    ) mem (
        .clk        (clk_pm_i),
        .reset      (~reset_pm_n_i),

        //Core port
        .en         (boom_tcu_mem_en),
        .we         (boom_tcu_mem_wben),
        .addr       (boom_tcu_mem_addr[IMEM_ADDR_SIZE+LOG_IMEM_DATA_BYTES-1:LOG_IMEM_DATA_BYTES]),
        .din        (boom_tcu_mem_wdata),
        .dout       (boom_tcu_mem_rdata)
    );
end
else begin: NO_SPM
    assign boom_tcu_mem_rdata = {IMEM_DATA_SIZE{1'b0}};
end
endgenerate



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
    .TCU_ENABLE_VIRT_ADDR       (1),
    .TCU_ENABLE_VIRT_PES        (1),
    .TCU_ENABLE_PMP             (!BOOM_USE_LOCAL_MEM),
    .TCU_ENABLE_DRAM            (1),
    .TCU_ENABLE_MEM_ADDR_ALIGN  (0),
    .TCU_ENABLE_LOG             (1),
    .TCU_ENABLE_PRINT           (1),
    .TCU_REGADDR_CORE_REQ_INT   (TCU_REGADDR_CORE_CFG_START + 'h8),  //first ext. interrupt of Boom core
    .TCU_REGADDR_TIMER_INT      (TCU_REGADDR_CORE_CFG_START + 'h10), //second ext. interrupt
    .HOME_MODID                 (HOME_MODID),
    .CLKFREQ_MHZ                (CLKFREQ_MHZ),
    .TILE_TYPE                  ('d0),              //processing tile with Boom core
    .TILE_ISA                   ('d1),
    .TILE_ATTR                  ('d1 | (PM_UART_ATTACHED ? 'd8 : 'd0)),
    .TILE_MEMSIZE               ('d0),
    .CORE_DMEM_DATA_SIZE        (CORE_DMEM_DATA_SIZE),
    .CORE_DMEM_ADDR_SIZE        (CORE_DMEM_ADDR_SIZE),
    .CORE_DMEM_BSEL_SIZE        (CORE_DMEM_BSEL_SIZE),
    .CORE_IMEM_DATA_SIZE        (CORE_IMEM_DATA_SIZE),
    .CORE_IMEM_ADDR_SIZE        (CORE_IMEM_ADDR_SIZE),
    .CORE_IMEM_BSEL_SIZE        (CORE_IMEM_BSEL_SIZE),
    .DMEM_DATA_SIZE             (DMEM_DATA_SIZE),
    .DMEM_ADDR_SIZE             (DMEM_ADDR_SIZE),
    .DMEM_BSEL_SIZE             (DMEM_BSEL_SIZE),
    .IMEM_DATA_SIZE             (BOOM_MEM_DATA_SIZE),
    .IMEM_ADDR_SIZE             (BOOM_MEM_ADDR_SIZE),
    .IMEM_BSEL_SIZE             (BOOM_MEM_BSEL_SIZE),
    .DMEM_START_ADDR            (DMEM_START_ADDR),
    .DMEM_SIZE                  (DMEM_SIZE),
    .IMEM_START_ADDR            (IMEM_START_ADDR),
    .IMEM_SIZE                  (IMEM_SIZE),
    .NOCMUX_TX_IF1_PRIO         (0),
    .NOCMUX_RX_IF1_PRIO         (0),
    .NOCMUX_RX_IF1_ADDR_START   (32'h0),        //tcu_ctrl has full access
    .NOCMUX_RX_IF1_ADDR_END     (32'hFFFFFFFF),
    .NOCMUX_RX_IF1_ONLY_MODE_2  (0),            //and takes all packets
    .NOCMUX_RX_IF2_ADDR_START   (32'h0),        //Boom could be mapped to full address range
    .NOCMUX_RX_IF2_ADDR_END     (32'hFFFFFFFF),
    .NOCMUX_RX_IF2_ONLY_MODE_2  (1)             //Boom mem interface only takes packets with mode _2
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

    .tcu_byp_noc_tx_wrreq_i     (boom_noc_tx_wrreq_s),
    .tcu_byp_noc_tx_burst_i     (boom_noc_tx_burst_s),
    .tcu_byp_noc_tx_arq_i       (1'b0),     //will be set in nocif
    .tcu_byp_noc_tx_bsel_i      (boom_noc_tx_bsel_s),
    .tcu_byp_noc_tx_src_chipid_i(boom_noc_tx_src_chipid_s),
    .tcu_byp_noc_tx_src_modid_i (boom_noc_tx_src_modid_s),
    .tcu_byp_noc_tx_trg_chipid_i(boom_noc_tx_trg_chipid_s),
    .tcu_byp_noc_tx_trg_modid_i (boom_noc_tx_trg_modid_s),
    .tcu_byp_noc_tx_mode_i      (boom_noc_tx_mode_s),
    .tcu_byp_noc_tx_addr_i      (boom_noc_tx_addr_s),
    .tcu_byp_noc_tx_data0_i     (boom_noc_tx_data0_s),
    .tcu_byp_noc_tx_data1_i     (boom_noc_tx_data1_s),
    .tcu_byp_noc_tx_stall_o     (boom_noc_tx_stall_s),

    .tcu_byp_noc_rx_wrreq_o     (boom_noc_rx_wrreq_s),
    .tcu_byp_noc_rx_burst_o     (boom_noc_rx_burst_s),
    .tcu_byp_noc_rx_arq_o       (),
    .tcu_byp_noc_rx_bsel_o      (boom_noc_rx_bsel_s),
    .tcu_byp_noc_rx_src_chipid_o(boom_noc_rx_src_chipid_s),
    .tcu_byp_noc_rx_src_modid_o (boom_noc_rx_src_modid_s),
    .tcu_byp_noc_rx_trg_chipid_o(boom_noc_rx_trg_chipid_s),
    .tcu_byp_noc_rx_trg_modid_o (boom_noc_rx_trg_modid_s),
    .tcu_byp_noc_rx_mode_o      (boom_noc_rx_mode_s),
    .tcu_byp_noc_rx_addr_o      (boom_noc_rx_addr_s),
    .tcu_byp_noc_rx_data0_o     (boom_noc_rx_data0_s),
    .tcu_byp_noc_rx_data1_o     (boom_noc_rx_data1_s),
    .tcu_byp_noc_rx_stall_i     (boom_noc_rx_stall_s),
    
    .core_dmem_in_en_i          (boom_tcu_reg_en),
    .core_dmem_in_wben_i        (boom_tcu_reg_wben),
    .core_dmem_in_addr_i        (boom_tcu_reg_addr),
    .core_dmem_in_wdata_i       (boom_tcu_reg_wdata),
    .core_dmem_in_rdata_o       (boom_tcu_reg_rdata),
    .core_dmem_in_stall_o       (boom_tcu_reg_stall),

    .core_imem_in_en_i          (boom_mem_en),
    .core_imem_in_wben_i        (boom_mem_wben),
    .core_imem_in_addr_i        (boom_mem_addr),
    .core_imem_in_wdata_i       (boom_mem_wdata),
    .core_imem_in_rdata_o       (boom_mem_rdata),
    .core_imem_in_stall_o       (),

    .core_dmem_out_en_o         (),  //unused
    .core_dmem_out_wben_o       (),
    .core_dmem_out_addr_o       (),
    .core_dmem_out_wdata_o      (),
    .core_dmem_out_rdata_i      ({DMEM_DATA_SIZE{1'b0}}),
    .core_dmem_out_stall_i      (1'b0),

    .core_imem_out_en_o         (boom_tcu_mem_en),
    .core_imem_out_wben_o       (boom_tcu_mem_wben),
    .core_imem_out_addr_o       (boom_tcu_mem_addr),
    .core_imem_out_wdata_o      (boom_tcu_mem_wdata),
    .core_imem_out_rdata_i      (boom_tcu_mem_rdata),
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

    .config_mem_en_o            (boom_config_en),
    .config_mem_wben_o          (boom_config_wben),
    .config_mem_addr_o          (boom_config_addr),
    .config_mem_wdata_o         (boom_config_wdata),
    .config_mem_rdata_i         (boom_config_rdata),

    .tcu_status_o               (tcu_status),

    .home_chipid_i              (home_chipid_i),

    .print_chipid_i             (host_chipid_i),
    .print_modid_i              (MODID_ETH)
);




boom_regfile #(
    .BOOM_MEM_ADDR_SIZE         (BOOM_MEM_ADDR_SIZE)
) i_boom_regfile (
    .clk_i                      (clk_pm_i),
    .reset_n_i                  (reset_pm_n_i),

    .config_en_i                (boom_config_en),
    .config_wben_i              (boom_config_wben),
    .config_addr_i              (boom_config_addr),
    .config_wdata_i             (boom_config_wdata),
    .config_rdata_o             (boom_config_rdata),

    .boom_en_o                  (boom_en),
    .boom_ext_int1_o            (boom_ext_int1),
    .boom_ext_int2_o            (boom_ext_int2),
    .tcu_mem_axi4_error_i       (tcu_mem_axi4_error),
    .axi4_mem_bridge_error_i    (axi4_mem_bridge_error),
    .boom_trace_enabled_o       (boom_trace_enabled),
    .boom_trace_ptr_i           (boom_trace_ptr),
    .boom_trace_count_i         (boom_trace_count)
);



boom_ctrl i_boom_ctrl (
    .clk_i           (clk_pm_i),
    .clk_core_o      (clk_core_s),
    .core_en_i       (boom_en),
    .reset_core_n_o  (reset_core_n_s),
    .reset_n_i       (reset_pm_n_i)
);


endmodule
