
module boom_core #(
    `include "noc_parameter.vh"
    ,parameter BOOM_USE_LOCAL_MEM = 1,
    parameter BOOM_ENABLE_TRACE   = 1,
    parameter BOOM_TRACE_BASEADDR = 32'h00100000,
    parameter BOOM_TRACE_SIZE     = 'h8000,
    parameter BOOM_MEM_DATA_SIZE  = 128,
    parameter BOOM_MEM_BSEL_SIZE  = BOOM_MEM_DATA_SIZE/8,
    parameter BOOM_MEM_ADDR_SIZE  = 32,
    parameter BOOM_REG_DATA_SIZE  = 64,
    parameter BOOM_REG_BSEL_SIZE  = BOOM_REG_DATA_SIZE/8,
    parameter BOOM_REG_ADDR_SIZE  = 32
)
(
    input  wire                               clk_i,
    input  wire                               reset_n_i,

    output wire                               mem_en_o,
    output wire      [BOOM_MEM_BSEL_SIZE-1:0] mem_wben_o,
    output wire      [BOOM_MEM_ADDR_SIZE-1:0] mem_addr_o,
    output wire      [BOOM_MEM_DATA_SIZE-1:0] mem_wdata_o,
    input  wire      [BOOM_MEM_DATA_SIZE-1:0] mem_rdata_i,
    input  wire                               mem_stall_i,

    output wire                               boom_noc_tx_wrreq_o,
    output wire                               boom_noc_tx_burst_o,
    output wire           [NOC_BSEL_SIZE-1:0] boom_noc_tx_bsel_o,
    output wire         [NOC_CHIPID_SIZE-1:0] boom_noc_tx_src_chipid_o,
    output wire          [NOC_MODID_SIZE-1:0] boom_noc_tx_src_modid_o,
    output wire         [NOC_CHIPID_SIZE-1:0] boom_noc_tx_trg_chipid_o,
    output wire          [NOC_MODID_SIZE-1:0] boom_noc_tx_trg_modid_o,
    output wire           [NOC_MODE_SIZE-1:0] boom_noc_tx_mode_o,
    output wire           [NOC_ADDR_SIZE-1:0] boom_noc_tx_addr_o,
    output wire           [NOC_DATA_SIZE-1:0] boom_noc_tx_data0_o,
    output wire           [NOC_DATA_SIZE-1:0] boom_noc_tx_data1_o,
    input  wire                               boom_noc_tx_stall_i,

    input  wire                               boom_noc_rx_wrreq_i,
    input  wire                               boom_noc_rx_burst_i,
    input  wire           [NOC_BSEL_SIZE-1:0] boom_noc_rx_bsel_i,
    input  wire         [NOC_CHIPID_SIZE-1:0] boom_noc_rx_src_chipid_i,
    input  wire          [NOC_MODID_SIZE-1:0] boom_noc_rx_src_modid_i,
    input  wire         [NOC_CHIPID_SIZE-1:0] boom_noc_rx_trg_chipid_i,
    input  wire          [NOC_MODID_SIZE-1:0] boom_noc_rx_trg_modid_i,
    input  wire           [NOC_MODE_SIZE-1:0] boom_noc_rx_mode_i,
    input  wire           [NOC_ADDR_SIZE-1:0] boom_noc_rx_addr_i,
    input  wire           [NOC_DATA_SIZE-1:0] boom_noc_rx_data0_i,
    input  wire           [NOC_DATA_SIZE-1:0] boom_noc_rx_data1_i,
    output wire                               boom_noc_rx_stall_o,

    output wire                               reg_en_o,
    output wire      [BOOM_REG_BSEL_SIZE-1:0] reg_wben_o,
    output wire      [BOOM_REG_ADDR_SIZE-1:0] reg_addr_o,
    output wire      [BOOM_REG_DATA_SIZE-1:0] reg_wdata_o,
    input  wire      [BOOM_REG_DATA_SIZE-1:0] reg_rdata_i,
    input  wire                               reg_stall_i,

    input  wire                               tcu_mem_en_i,
    input  wire                               tcu_mem_req_i,
    input  wire      [BOOM_MEM_BSEL_SIZE-1:0] tcu_mem_wben_i,
    input  wire      [BOOM_MEM_ADDR_SIZE-1:0] tcu_mem_addr_i,
    input  wire      [BOOM_MEM_DATA_SIZE-1:0] tcu_mem_wdata_i,
    output wire      [BOOM_MEM_DATA_SIZE-1:0] tcu_mem_rdata_o,
    output wire                               tcu_mem_rdata_avail_o,
    output wire                               tcu_mem_wdata_infifo_o,
    input  wire                               tcu_mem_wabort_i,
    output wire                               tcu_mem_wstall_o,
    output wire                               tcu_mem_rstall_o,
    input  wire                               tcu_mem_access_i,

    input  wire                               ext_int1_i,
    input  wire                               ext_int2_i,

    output wire                               uart_tx,
    input  wire                               uart_rx,

    output wire                        [31:0] tcu_mem_axi4_error_o,
    output wire                        [31:0] axi4_mem_bridge_error_o,

    input  wire                               boom_trace_enabled_i,
    output wire      [BOOM_MEM_ADDR_SIZE-1:0] boom_trace_ptr_o,
    output wire      [BOOM_MEM_ADDR_SIZE-1:0] boom_trace_count_o,

    input wire                                jtag_tck_i,
    input wire                                jtag_tms_i,
    input wire                                jtag_tdi_i,
    output wire                               jtag_tdo_o,
    output wire                               jtag_tdo_en_o
);


wire                            mem_axi4_0_aw_ready;
wire                            mem_axi4_0_aw_valid;
wire                      [3:0] mem_axi4_0_aw_bits_id;
wire   [BOOM_MEM_ADDR_SIZE-1:0] mem_axi4_0_aw_bits_addr;
wire                      [7:0] mem_axi4_0_aw_bits_len;
wire                      [2:0] mem_axi4_0_aw_bits_size;
wire                      [1:0] mem_axi4_0_aw_bits_burst;
wire                            mem_axi4_0_aw_bits_lock;
wire                      [3:0] mem_axi4_0_aw_bits_cache;
wire                      [2:0] mem_axi4_0_aw_bits_prot;
wire                      [3:0] mem_axi4_0_aw_bits_qos;
wire                            mem_axi4_0_w_ready;
wire                            mem_axi4_0_w_valid;
wire   [BOOM_MEM_DATA_SIZE-1:0] mem_axi4_0_w_bits_data;
wire   [BOOM_MEM_BSEL_SIZE-1:0] mem_axi4_0_w_bits_strb;
wire                            mem_axi4_0_w_bits_last;
wire                            mem_axi4_0_b_ready;
wire                            mem_axi4_0_b_valid;
wire                      [3:0] mem_axi4_0_b_bits_id;
wire                      [1:0] mem_axi4_0_b_bits_resp;
wire                            mem_axi4_0_ar_ready;
wire                            mem_axi4_0_ar_valid;
wire                      [3:0] mem_axi4_0_ar_bits_id;
wire   [BOOM_MEM_ADDR_SIZE-1:0] mem_axi4_0_ar_bits_addr;
wire                      [7:0] mem_axi4_0_ar_bits_len;
wire                      [2:0] mem_axi4_0_ar_bits_size;
wire                      [1:0] mem_axi4_0_ar_bits_burst;
wire                            mem_axi4_0_ar_bits_lock;
wire                      [3:0] mem_axi4_0_ar_bits_cache;
wire                      [2:0] mem_axi4_0_ar_bits_prot;
wire                      [3:0] mem_axi4_0_ar_bits_qos;
wire                            mem_axi4_0_r_ready;
wire                            mem_axi4_0_r_valid;
wire                      [3:0] mem_axi4_0_r_bits_id;
wire   [BOOM_MEM_DATA_SIZE-1:0] mem_axi4_0_r_bits_data;
wire                      [1:0] mem_axi4_0_r_bits_resp;
wire                            mem_axi4_0_r_bits_last;


wire                            mmio_axi4_0_aw_ready;
wire                            mmio_axi4_0_aw_valid;
wire                      [3:0] mmio_axi4_0_aw_bits_id;
wire   [BOOM_REG_ADDR_SIZE-1:0] mmio_axi4_0_aw_bits_addr;
wire                      [7:0] mmio_axi4_0_aw_bits_len;
wire                      [2:0] mmio_axi4_0_aw_bits_size;
wire                      [1:0] mmio_axi4_0_aw_bits_burst;
wire                            mmio_axi4_0_aw_bits_lock;
wire                      [3:0] mmio_axi4_0_aw_bits_cache;
wire                      [2:0] mmio_axi4_0_aw_bits_prot;
wire                      [3:0] mmio_axi4_0_aw_bits_qos;
wire                            mmio_axi4_0_w_ready;
wire                            mmio_axi4_0_w_valid;
wire   [BOOM_REG_DATA_SIZE-1:0] mmio_axi4_0_w_bits_data;
wire   [BOOM_REG_BSEL_SIZE-1:0] mmio_axi4_0_w_bits_strb;
wire                            mmio_axi4_0_w_bits_last;
wire                            mmio_axi4_0_b_ready;
wire                            mmio_axi4_0_b_valid;
wire                      [3:0] mmio_axi4_0_b_bits_id;
wire                      [1:0] mmio_axi4_0_b_bits_resp;
wire                            mmio_axi4_0_ar_ready;
wire                            mmio_axi4_0_ar_valid;
wire                      [3:0] mmio_axi4_0_ar_bits_id;
wire   [BOOM_REG_ADDR_SIZE-1:0] mmio_axi4_0_ar_bits_addr;
wire                      [7:0] mmio_axi4_0_ar_bits_len;
wire                      [2:0] mmio_axi4_0_ar_bits_size;
wire                      [1:0] mmio_axi4_0_ar_bits_burst;
wire                            mmio_axi4_0_ar_bits_lock;
wire                      [3:0] mmio_axi4_0_ar_bits_cache;
wire                      [2:0] mmio_axi4_0_ar_bits_prot;
wire                      [3:0] mmio_axi4_0_ar_bits_qos;
wire                            mmio_axi4_0_r_ready;
wire                            mmio_axi4_0_r_valid;
wire                      [3:0] mmio_axi4_0_r_bits_id;
wire   [BOOM_REG_DATA_SIZE-1:0] mmio_axi4_0_r_bits_data;
wire                      [1:0] mmio_axi4_0_r_bits_resp;
wire                            mmio_axi4_0_r_bits_last;


wire                            l2_frontend_bus_axi4_0_aw_ready;
wire                            l2_frontend_bus_axi4_0_aw_valid;
wire                      [3:0] l2_frontend_bus_axi4_0_aw_bits_id;
wire   [BOOM_MEM_ADDR_SIZE-1:0] l2_frontend_bus_axi4_0_aw_bits_addr;
wire                      [7:0] l2_frontend_bus_axi4_0_aw_bits_len;
wire                      [2:0] l2_frontend_bus_axi4_0_aw_bits_size;
wire                      [1:0] l2_frontend_bus_axi4_0_aw_bits_burst;
wire                            l2_frontend_bus_axi4_0_aw_bits_lock = 1'b0;
wire                      [3:0] l2_frontend_bus_axi4_0_aw_bits_cache = 4'h0;
wire                      [2:0] l2_frontend_bus_axi4_0_aw_bits_prot = 3'h0;
wire                      [3:0] l2_frontend_bus_axi4_0_aw_bits_qos = 4'h0;
wire                            l2_frontend_bus_axi4_0_w_ready;
wire                            l2_frontend_bus_axi4_0_w_valid;
wire   [BOOM_MEM_DATA_SIZE-1:0] l2_frontend_bus_axi4_0_w_bits_data;
wire   [BOOM_MEM_BSEL_SIZE-1:0] l2_frontend_bus_axi4_0_w_bits_strb;
wire                            l2_frontend_bus_axi4_0_w_bits_last;
wire                            l2_frontend_bus_axi4_0_b_ready;
wire                            l2_frontend_bus_axi4_0_b_valid;
wire                      [3:0] l2_frontend_bus_axi4_0_b_bits_id;
wire                      [1:0] l2_frontend_bus_axi4_0_b_bits_resp;
wire                            l2_frontend_bus_axi4_0_ar_ready;
wire                            l2_frontend_bus_axi4_0_ar_valid;
wire                      [3:0] l2_frontend_bus_axi4_0_ar_bits_id;
wire   [BOOM_MEM_ADDR_SIZE-1:0] l2_frontend_bus_axi4_0_ar_bits_addr;
wire                      [7:0] l2_frontend_bus_axi4_0_ar_bits_len;
wire                      [2:0] l2_frontend_bus_axi4_0_ar_bits_size;
wire                      [1:0] l2_frontend_bus_axi4_0_ar_bits_burst;
wire                            l2_frontend_bus_axi4_0_ar_bits_lock = 1'b0;
wire                      [3:0] l2_frontend_bus_axi4_0_ar_bits_cache = 4'h0;
wire                      [2:0] l2_frontend_bus_axi4_0_ar_bits_prot = 3'h0;
wire                      [3:0] l2_frontend_bus_axi4_0_ar_bits_qos = 4'h0;
wire                            l2_frontend_bus_axi4_0_r_ready;
wire                            l2_frontend_bus_axi4_0_r_valid;
wire                      [3:0] l2_frontend_bus_axi4_0_r_bits_id;
wire   [BOOM_MEM_DATA_SIZE-1:0] l2_frontend_bus_axi4_0_r_bits_data;
wire                      [1:0] l2_frontend_bus_axi4_0_r_bits_resp;
wire                            l2_frontend_bus_axi4_0_r_bits_last;


wire                            tcu_axi4_mem_en;
wire                            tcu_axi4_mem_req;
wire   [BOOM_MEM_DATA_SIZE-1:0] tcu_axi4_mem_rdata;
wire                            tcu_axi4_mem_rdata_avail;




generate
if (BOOM_USE_LOCAL_MEM) begin: axi4_mem
    axi4_mem_bridge #(
        .AXI_ID_WIDTH      (4),
        .AXI_ADDR_WIDTH    (BOOM_MEM_ADDR_SIZE),
        .AXI_DATA_WIDTH    (BOOM_MEM_DATA_SIZE)
    ) axi4_to_mem (
        .clk_i             (clk_i),
        .reset_n_i         (reset_n_i),
        .axi4_error_o      (axi4_mem_bridge_error_o),
        .axi4_aw_id_i      (mem_axi4_0_aw_bits_id),
        .axi4_aw_addr_i    (mem_axi4_0_aw_bits_addr),
        .axi4_aw_len_i     (mem_axi4_0_aw_bits_len),
        .axi4_aw_size_i    (mem_axi4_0_aw_bits_size),
        .axi4_aw_burst_i   (mem_axi4_0_aw_bits_burst),
        .axi4_aw_valid_i   (mem_axi4_0_aw_valid),
        .axi4_aw_ready_o   (mem_axi4_0_aw_ready),
        .axi4_w_data_i     (mem_axi4_0_w_bits_data),
        .axi4_w_strb_i     (mem_axi4_0_w_bits_strb),
        .axi4_w_last_i     (mem_axi4_0_w_bits_last),
        .axi4_w_valid_i    (mem_axi4_0_w_valid),
        .axi4_w_ready_o    (mem_axi4_0_w_ready),
        .axi4_b_id_o       (mem_axi4_0_b_bits_id),
        .axi4_b_resp_o     (mem_axi4_0_b_bits_resp),
        .axi4_b_valid_o    (mem_axi4_0_b_valid),
        .axi4_b_ready_i    (mem_axi4_0_b_ready),
        .axi4_ar_id_i      (mem_axi4_0_ar_bits_id),
        .axi4_ar_addr_i    (mem_axi4_0_ar_bits_addr),
        .axi4_ar_len_i     (mem_axi4_0_ar_bits_len),
        .axi4_ar_size_i    (mem_axi4_0_ar_bits_size),
        .axi4_ar_burst_i   (mem_axi4_0_ar_bits_burst),
        .axi4_ar_valid_i   (mem_axi4_0_ar_valid),
        .axi4_ar_ready_o   (mem_axi4_0_ar_ready),
        .axi4_r_id_o       (mem_axi4_0_r_bits_id),
        .axi4_r_data_o     (mem_axi4_0_r_bits_data),
        .axi4_r_resp_o     (mem_axi4_0_r_bits_resp),
        .axi4_r_last_o     (mem_axi4_0_r_bits_last),
        .axi4_r_valid_o    (mem_axi4_0_r_valid),
        .axi4_r_ready_i    (mem_axi4_0_r_ready),
        .mem_en_o          (mem_en_o),
        .mem_wben_o        (mem_wben_o),
        .mem_addr_o        (mem_addr_o),
        .mem_wdata_o       (mem_wdata_o),
        .mem_rdata_i       (mem_rdata_i),
        .mem_stall_i       (mem_stall_i)
    );

    assign boom_noc_tx_wrreq_o      = 1'b0;
    assign boom_noc_tx_burst_o      = 1'b0;
    assign boom_noc_tx_bsel_o       = {NOC_BSEL_SIZE{1'b0}};
    assign boom_noc_tx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
    assign boom_noc_tx_src_modid_o  = {NOC_MODID_SIZE{1'b0}};
    assign boom_noc_tx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
    assign boom_noc_tx_trg_modid_o  = {NOC_MODID_SIZE{1'b0}};
    assign boom_noc_tx_mode_o       = {NOC_MODE_SIZE{1'b0}};
    assign boom_noc_tx_addr_o       = {NOC_ADDR_SIZE{1'b0}};
    assign boom_noc_tx_data0_o      = {NOC_DATA_SIZE{1'b0}};
    assign boom_noc_tx_data1_o      = {NOC_DATA_SIZE{1'b0}};
    assign boom_noc_rx_stall_o      = 1'b0;
end

else begin: axi4_noc
    axi4_noc_bridge #(
        .AXI_ID_WIDTH           (4),
        .AXI_ADDR_WIDTH         (NOC_ADDR_SIZE),
        .AXI_DATA_WIDTH         (2*NOC_DATA_SIZE)
    ) axi4_to_noc (
        .clk_i                  (clk_i),
        .reset_n_i              (reset_n_i),
        .noc_error_o            (axi4_mem_bridge_error_o),
        .axi4_aw_id_i           (mem_axi4_0_aw_bits_id),
        .axi4_aw_addr_i         (mem_axi4_0_aw_bits_addr),
        .axi4_aw_len_i          (mem_axi4_0_aw_bits_len),
        .axi4_aw_size_i         (mem_axi4_0_aw_bits_size),
        .axi4_aw_burst_i        (mem_axi4_0_aw_bits_burst),
        .axi4_aw_valid_i        (mem_axi4_0_aw_valid),
        .axi4_aw_ready_o        (mem_axi4_0_aw_ready),
        .axi4_w_data_i          (mem_axi4_0_w_bits_data),
        .axi4_w_strb_i          (mem_axi4_0_w_bits_strb),
        .axi4_w_last_i          (mem_axi4_0_w_bits_last),
        .axi4_w_valid_i         (mem_axi4_0_w_valid),
        .axi4_w_ready_o         (mem_axi4_0_w_ready),
        .axi4_b_id_o            (mem_axi4_0_b_bits_id),
        .axi4_b_resp_o          (mem_axi4_0_b_bits_resp),
        .axi4_b_valid_o         (mem_axi4_0_b_valid),
        .axi4_b_ready_i         (mem_axi4_0_b_ready),
        .axi4_ar_id_i           (mem_axi4_0_ar_bits_id),
        .axi4_ar_addr_i         (mem_axi4_0_ar_bits_addr),
        .axi4_ar_len_i          (mem_axi4_0_ar_bits_len),
        .axi4_ar_size_i         (mem_axi4_0_ar_bits_size),
        .axi4_ar_burst_i        (mem_axi4_0_ar_bits_burst),
        .axi4_ar_valid_i        (mem_axi4_0_ar_valid),
        .axi4_ar_ready_o        (mem_axi4_0_ar_ready),
        .axi4_r_id_o            (mem_axi4_0_r_bits_id),
        .axi4_r_data_o          (mem_axi4_0_r_bits_data),
        .axi4_r_resp_o          (mem_axi4_0_r_bits_resp),
        .axi4_r_last_o          (mem_axi4_0_r_bits_last),
        .axi4_r_valid_o         (mem_axi4_0_r_valid),
        .axi4_r_ready_i         (mem_axi4_0_r_ready),
        .noc_rx_wrreq_i         (boom_noc_rx_wrreq_i),
        .noc_rx_burst_i         (boom_noc_rx_burst_i),
        .noc_rx_bsel_i          (boom_noc_rx_bsel_i),
        .noc_rx_src_chipid_i    (boom_noc_rx_src_chipid_i),
        .noc_rx_src_modid_i     (boom_noc_rx_src_modid_i),
        .noc_rx_trg_chipid_i    (boom_noc_rx_trg_chipid_i),
        .noc_rx_trg_modid_i     (boom_noc_rx_trg_modid_i),
        .noc_rx_mode_i          (boom_noc_rx_mode_i),
        .noc_rx_addr_i          (boom_noc_rx_addr_i),
        .noc_rx_data0_i         (boom_noc_rx_data0_i),
        .noc_rx_data1_i         (boom_noc_rx_data1_i),
        .noc_rx_stall_o         (boom_noc_rx_stall_o),
        .noc_tx_wrreq_o         (boom_noc_tx_wrreq_o),
        .noc_tx_burst_o         (boom_noc_tx_burst_o),
        .noc_tx_bsel_o          (boom_noc_tx_bsel_o),
        .noc_tx_src_chipid_o    (boom_noc_tx_src_chipid_o),
        .noc_tx_src_modid_o     (boom_noc_tx_src_modid_o),
        .noc_tx_trg_chipid_o    (boom_noc_tx_trg_chipid_o),
        .noc_tx_trg_modid_o     (boom_noc_tx_trg_modid_o),
        .noc_tx_mode_o          (boom_noc_tx_mode_o),
        .noc_tx_addr_o          (boom_noc_tx_addr_o),
        .noc_tx_data0_o         (boom_noc_tx_data0_o),
        .noc_tx_data1_o         (boom_noc_tx_data1_o),
        .noc_tx_stall_i         (boom_noc_tx_stall_i)
    );

    assign mem_en_o    = 1'b0;
    assign mem_wben_o  = {BOOM_MEM_BSEL_SIZE{1'b0}};
    assign mem_addr_o  = {BOOM_MEM_ADDR_SIZE{1'b0}};
    assign mem_wdata_o = {BOOM_MEM_DATA_SIZE{1'b0}};
end
endgenerate


axi4_mem_bridge #(
    .AXI_ID_WIDTH      (4),
    .AXI_ADDR_WIDTH    (BOOM_REG_ADDR_SIZE),
    .AXI_DATA_WIDTH    (BOOM_REG_DATA_SIZE)
) axi4_to_reg (
    .clk_i             (clk_i),
    .reset_n_i         (reset_n_i),
    .axi4_error_o      (),
    .axi4_aw_id_i      (mmio_axi4_0_aw_bits_id),
    .axi4_aw_addr_i    (mmio_axi4_0_aw_bits_addr),
    .axi4_aw_len_i     (mmio_axi4_0_aw_bits_len),
    .axi4_aw_size_i    (mmio_axi4_0_aw_bits_size),
    .axi4_aw_burst_i   (mmio_axi4_0_aw_bits_burst),
    .axi4_aw_valid_i   (mmio_axi4_0_aw_valid),
    .axi4_aw_ready_o   (mmio_axi4_0_aw_ready),
    .axi4_w_data_i     (mmio_axi4_0_w_bits_data),
    .axi4_w_strb_i     (mmio_axi4_0_w_bits_strb),
    .axi4_w_last_i     (mmio_axi4_0_w_bits_last),
    .axi4_w_valid_i    (mmio_axi4_0_w_valid),
    .axi4_w_ready_o    (mmio_axi4_0_w_ready),
    .axi4_b_id_o       (mmio_axi4_0_b_bits_id),
    .axi4_b_resp_o     (mmio_axi4_0_b_bits_resp),
    .axi4_b_valid_o    (mmio_axi4_0_b_valid),
    .axi4_b_ready_i    (mmio_axi4_0_b_ready),
    .axi4_ar_id_i      (mmio_axi4_0_ar_bits_id),
    .axi4_ar_addr_i    (mmio_axi4_0_ar_bits_addr),
    .axi4_ar_len_i     (mmio_axi4_0_ar_bits_len),
    .axi4_ar_size_i    (mmio_axi4_0_ar_bits_size),
    .axi4_ar_burst_i   (mmio_axi4_0_ar_bits_burst),
    .axi4_ar_valid_i   (mmio_axi4_0_ar_valid),
    .axi4_ar_ready_o   (mmio_axi4_0_ar_ready),
    .axi4_r_id_o       (mmio_axi4_0_r_bits_id),
    .axi4_r_data_o     (mmio_axi4_0_r_bits_data),
    .axi4_r_resp_o     (mmio_axi4_0_r_bits_resp),
    .axi4_r_last_o     (mmio_axi4_0_r_bits_last),
    .axi4_r_valid_o    (mmio_axi4_0_r_valid),
    .axi4_r_ready_i    (mmio_axi4_0_r_ready),
    .mem_en_o          (reg_en_o),
    .mem_wben_o        (reg_wben_o),
    .mem_addr_o        (reg_addr_o),
    .mem_wdata_o       (reg_wdata_o),
    .mem_rdata_i       (reg_rdata_i),
    .mem_stall_i       (reg_stall_i)
);



mem_axi4_bridge #(
    .AXI_ID_WIDTH      (4),
    .AXI_ADDR_WIDTH    (BOOM_MEM_ADDR_SIZE),
    .AXI_DATA_WIDTH    (BOOM_MEM_DATA_SIZE)
) tcu_to_axi4 (
    .clk_i             (clk_i),
    .reset_n_i         (reset_n_i),
    .mem_axi4_error_o  (tcu_mem_axi4_error_o),
    .mem_en_i          (tcu_axi4_mem_en),
    .mem_req_i         (tcu_axi4_mem_req),
    .mem_wben_i        (tcu_mem_wben_i),
    .mem_addr_i        (tcu_mem_addr_i),
    .mem_wdata_i       (tcu_mem_wdata_i),
    .mem_rdata_o       (tcu_axi4_mem_rdata),
    .mem_rdata_avail_o (tcu_axi4_mem_rdata_avail),
    .mem_wdata_infifo_o(tcu_mem_wdata_infifo_o),
    .mem_wabort_i      (tcu_mem_wabort_i),
    .mem_wstall_o      (tcu_mem_wstall_o),
    .mem_rstall_o      (tcu_mem_rstall_o),
    .mem_access_i      (tcu_mem_access_i),
    .axi4_aw_id_o      (l2_frontend_bus_axi4_0_aw_bits_id),
    .axi4_aw_addr_o    (l2_frontend_bus_axi4_0_aw_bits_addr),
    .axi4_aw_len_o     (l2_frontend_bus_axi4_0_aw_bits_len),
    .axi4_aw_size_o    (l2_frontend_bus_axi4_0_aw_bits_size),
    .axi4_aw_burst_o   (l2_frontend_bus_axi4_0_aw_bits_burst),
    .axi4_aw_valid_o   (l2_frontend_bus_axi4_0_aw_valid),
    .axi4_aw_ready_i   (l2_frontend_bus_axi4_0_aw_ready),
    .axi4_w_data_o     (l2_frontend_bus_axi4_0_w_bits_data),
    .axi4_w_strb_o     (l2_frontend_bus_axi4_0_w_bits_strb),
    .axi4_w_last_o     (l2_frontend_bus_axi4_0_w_bits_last),
    .axi4_w_valid_o    (l2_frontend_bus_axi4_0_w_valid),
    .axi4_w_ready_i    (l2_frontend_bus_axi4_0_w_ready),
    .axi4_b_id_i       (l2_frontend_bus_axi4_0_b_bits_id),
    .axi4_b_resp_i     (l2_frontend_bus_axi4_0_b_bits_resp),
    .axi4_b_valid_i    (l2_frontend_bus_axi4_0_b_valid),
    .axi4_b_ready_o    (l2_frontend_bus_axi4_0_b_ready),
    .axi4_ar_id_o      (l2_frontend_bus_axi4_0_ar_bits_id),
    .axi4_ar_addr_o    (l2_frontend_bus_axi4_0_ar_bits_addr),
    .axi4_ar_len_o     (l2_frontend_bus_axi4_0_ar_bits_len),
    .axi4_ar_size_o    (l2_frontend_bus_axi4_0_ar_bits_size),
    .axi4_ar_burst_o   (l2_frontend_bus_axi4_0_ar_bits_burst),
    .axi4_ar_valid_o   (l2_frontend_bus_axi4_0_ar_valid),
    .axi4_ar_ready_i   (l2_frontend_bus_axi4_0_ar_ready),
    .axi4_r_id_i       (l2_frontend_bus_axi4_0_r_bits_id),
    .axi4_r_data_i     (l2_frontend_bus_axi4_0_r_bits_data),
    .axi4_r_resp_i     (l2_frontend_bus_axi4_0_r_bits_resp),
    .axi4_r_last_i     (l2_frontend_bus_axi4_0_r_bits_last),
    .axi4_r_valid_i    (l2_frontend_bus_axi4_0_r_valid),
    .axi4_r_ready_o    (l2_frontend_bus_axi4_0_r_ready)
);



wire         traceIO_traces_0_clock;
wire         traceIO_traces_0_reset;
wire         traceIO_traces_0_trace_insns_0_valid;
wire [39:0]  traceIO_traces_0_trace_insns_0_iaddr;
wire [31:0]  traceIO_traces_0_trace_insns_0_insn;
wire [63:0]  traceIO_traces_0_trace_insns_0_wdata;
wire [2:0]   traceIO_traces_0_trace_insns_0_priv;
wire         traceIO_traces_0_trace_insns_0_exception;
wire         traceIO_traces_0_trace_insns_0_interrupt;
wire [63:0]  traceIO_traces_0_trace_insns_0_cause;
wire [39:0]  traceIO_traces_0_trace_insns_0_tval;
wire [63:0]  traceIO_traces_0_trace_time;
wire         traceIO_traces_0_trace_custom_rob_empty;
wire         traceIO_traces_0_trace_insns_1_valid;
wire [39:0]  traceIO_traces_0_trace_insns_1_iaddr;
wire [31:0]  traceIO_traces_0_trace_insns_1_insn;
wire [63:0]  traceIO_traces_0_trace_insns_1_wdata;
wire [2:0]   traceIO_traces_0_trace_insns_1_priv;
wire         traceIO_traces_0_trace_insns_1_exception;
wire         traceIO_traces_0_trace_insns_1_interrupt;
wire [63:0]  traceIO_traces_0_trace_insns_1_cause;
wire [39:0]  traceIO_traces_0_trace_insns_1_tval;

wire debug_dmactive;
wire debug_dmactive_sync;


//feed back synced active signal as ack
util_sync util_sync_dmactive (
    .clk_i     (clk_i),
    .reset_n_i (reset_n_i),
    .data_i    (debug_dmactive),
    .data_o    (debug_dmactive_sync)
);


//enabled by default
assign jtag_tdo_en_o = 1'b1;

DigitalTop_boom boom_top (
    .clock                                (clk_i),
    .reset                                (~reset_n_i),

    .auto_prci_ctrl_domain_reset_setter_clock_in_member_allClocks_uncore_clock (clk_i),
    .auto_prci_ctrl_domain_reset_setter_clock_in_member_allClocks_uncore_reset (~reset_n_i),
    .auto_implicitClockGrouper_out_clock                                       (),
    .auto_implicitClockGrouper_out_reset                                       (),
    .auto_subsystem_mbus_fixedClockNode_out_clock                              (),  //outputs unused
    .auto_subsystem_mbus_fixedClockNode_out_reset                              (),
    .auto_subsystem_cbus_fixedClockNode_out_clock                              (),
    .auto_subsystem_cbus_fixedClockNode_out_reset                              (),
    .auto_subsystem_fbus_fixedClockNode_out_clock                              (),
    .auto_subsystem_sbus_fixedClockNode_out_clock                              (),
    .auto_subsystem_sbus_fixedClockNode_out_reset                              (),

    .resetctrl_hartIsInReset_0            (~reset_n_i),

    .custom_boot                          (1'b0),

    .debug_clock                          (clk_i),
    .debug_reset                          (~reset_n_i),
    .debug_systemjtag_jtag_TCK            (jtag_tck_i),
    .debug_systemjtag_jtag_TMS            (jtag_tms_i),
    .debug_systemjtag_jtag_TDI            (jtag_tdi_i),
    .debug_systemjtag_jtag_TDO_data       (jtag_tdo_o),
    .debug_systemjtag_reset               (~reset_n_i),
    .debug_dmactive                       (debug_dmactive),
    .debug_dmactiveAck                    (debug_dmactive_sync),

    .interrupts                           ({6'h0, ext_int2_i, ext_int1_i}),

    .uart_0_txd                           (uart_tx),
    .uart_0_rxd                           (uart_rx),

    .traceIO_traces_0_clock                     (traceIO_traces_0_clock),
    .traceIO_traces_0_reset                     (traceIO_traces_0_reset),
    .traceIO_traces_0_trace_insns_0_valid       (traceIO_traces_0_trace_insns_0_valid),
    .traceIO_traces_0_trace_insns_0_iaddr       (traceIO_traces_0_trace_insns_0_iaddr),
    .traceIO_traces_0_trace_insns_0_insn        (traceIO_traces_0_trace_insns_0_insn),
    .traceIO_traces_0_trace_insns_0_wdata       (traceIO_traces_0_trace_insns_0_wdata),
    .traceIO_traces_0_trace_insns_0_priv        (traceIO_traces_0_trace_insns_0_priv),
    .traceIO_traces_0_trace_insns_0_exception   (traceIO_traces_0_trace_insns_0_exception),
    .traceIO_traces_0_trace_insns_0_interrupt   (traceIO_traces_0_trace_insns_0_interrupt),
    .traceIO_traces_0_trace_insns_0_cause       (traceIO_traces_0_trace_insns_0_cause),
    .traceIO_traces_0_trace_insns_0_tval        (traceIO_traces_0_trace_insns_0_tval),
    .traceIO_traces_0_trace_time                (traceIO_traces_0_trace_time),
    .traceIO_traces_0_trace_custom_rob_empty    (traceIO_traces_0_trace_custom_rob_empty),
    .traceIO_traces_0_trace_insns_1_valid       (traceIO_traces_0_trace_insns_1_valid),
    .traceIO_traces_0_trace_insns_1_iaddr       (traceIO_traces_0_trace_insns_1_iaddr),
    .traceIO_traces_0_trace_insns_1_insn        (traceIO_traces_0_trace_insns_1_insn),
    .traceIO_traces_0_trace_insns_1_wdata       (traceIO_traces_0_trace_insns_1_wdata),
    .traceIO_traces_0_trace_insns_1_priv        (traceIO_traces_0_trace_insns_1_priv),
    .traceIO_traces_0_trace_insns_1_exception   (traceIO_traces_0_trace_insns_1_exception),
    .traceIO_traces_0_trace_insns_1_interrupt   (traceIO_traces_0_trace_insns_1_interrupt),
    .traceIO_traces_0_trace_insns_1_cause       (traceIO_traces_0_trace_insns_1_cause),
    .traceIO_traces_0_trace_insns_1_tval        (traceIO_traces_0_trace_insns_1_tval),

    .mem_axi4_0_aw_ready                  (mem_axi4_0_aw_ready),
    .mem_axi4_0_aw_valid                  (mem_axi4_0_aw_valid),
    .mem_axi4_0_aw_bits_id                (mem_axi4_0_aw_bits_id),
    .mem_axi4_0_aw_bits_addr              (mem_axi4_0_aw_bits_addr),
    .mem_axi4_0_aw_bits_len               (mem_axi4_0_aw_bits_len),
    .mem_axi4_0_aw_bits_size              (mem_axi4_0_aw_bits_size),
    .mem_axi4_0_aw_bits_burst             (mem_axi4_0_aw_bits_burst),
    .mem_axi4_0_aw_bits_lock              (mem_axi4_0_aw_bits_lock), //unused
    .mem_axi4_0_aw_bits_cache             (mem_axi4_0_aw_bits_cache), //unused
    .mem_axi4_0_aw_bits_prot              (mem_axi4_0_aw_bits_prot), //unused
    .mem_axi4_0_aw_bits_qos               (mem_axi4_0_aw_bits_qos), //unused
    .mem_axi4_0_w_ready                   (mem_axi4_0_w_ready),
    .mem_axi4_0_w_valid                   (mem_axi4_0_w_valid),
    .mem_axi4_0_w_bits_data               (mem_axi4_0_w_bits_data),
    .mem_axi4_0_w_bits_strb               (mem_axi4_0_w_bits_strb),
    .mem_axi4_0_w_bits_last               (mem_axi4_0_w_bits_last),
    .mem_axi4_0_b_ready                   (mem_axi4_0_b_ready),
    .mem_axi4_0_b_valid                   (mem_axi4_0_b_valid),
    .mem_axi4_0_b_bits_id                 (mem_axi4_0_b_bits_id),
    .mem_axi4_0_b_bits_resp               (mem_axi4_0_b_bits_resp),
    .mem_axi4_0_ar_ready                  (mem_axi4_0_ar_ready),
    .mem_axi4_0_ar_valid                  (mem_axi4_0_ar_valid),
    .mem_axi4_0_ar_bits_id                (mem_axi4_0_ar_bits_id),
    .mem_axi4_0_ar_bits_addr              (mem_axi4_0_ar_bits_addr),
    .mem_axi4_0_ar_bits_len               (mem_axi4_0_ar_bits_len),
    .mem_axi4_0_ar_bits_size              (mem_axi4_0_ar_bits_size),
    .mem_axi4_0_ar_bits_burst             (mem_axi4_0_ar_bits_burst),
    .mem_axi4_0_ar_bits_lock              (mem_axi4_0_ar_bits_lock), //unused
    .mem_axi4_0_ar_bits_cache             (mem_axi4_0_ar_bits_cache), //unused
    .mem_axi4_0_ar_bits_prot              (mem_axi4_0_ar_bits_prot), //unused
    .mem_axi4_0_ar_bits_qos               (mem_axi4_0_ar_bits_qos), //unused
    .mem_axi4_0_r_ready                   (mem_axi4_0_r_ready),
    .mem_axi4_0_r_valid                   (mem_axi4_0_r_valid),
    .mem_axi4_0_r_bits_id                 (mem_axi4_0_r_bits_id),
    .mem_axi4_0_r_bits_data               (mem_axi4_0_r_bits_data),
    .mem_axi4_0_r_bits_resp               (mem_axi4_0_r_bits_resp),
    .mem_axi4_0_r_bits_last               (mem_axi4_0_r_bits_last),

    .mmio_axi4_0_aw_ready                 (mmio_axi4_0_aw_ready),
    .mmio_axi4_0_aw_valid                 (mmio_axi4_0_aw_valid),
    .mmio_axi4_0_aw_bits_id               (mmio_axi4_0_aw_bits_id),
    .mmio_axi4_0_aw_bits_addr             (mmio_axi4_0_aw_bits_addr),
    .mmio_axi4_0_aw_bits_len              (mmio_axi4_0_aw_bits_len),
    .mmio_axi4_0_aw_bits_size             (mmio_axi4_0_aw_bits_size),
    .mmio_axi4_0_aw_bits_burst            (mmio_axi4_0_aw_bits_burst),
    .mmio_axi4_0_aw_bits_lock             (mmio_axi4_0_aw_bits_lock), //unused
    .mmio_axi4_0_aw_bits_cache            (mmio_axi4_0_aw_bits_cache), //unused
    .mmio_axi4_0_aw_bits_prot             (mmio_axi4_0_aw_bits_prot), //unused
    .mmio_axi4_0_aw_bits_qos              (mmio_axi4_0_aw_bits_qos), //unused
    .mmio_axi4_0_w_ready                  (mmio_axi4_0_w_ready),
    .mmio_axi4_0_w_valid                  (mmio_axi4_0_w_valid),
    .mmio_axi4_0_w_bits_data              (mmio_axi4_0_w_bits_data),
    .mmio_axi4_0_w_bits_strb              (mmio_axi4_0_w_bits_strb),
    .mmio_axi4_0_w_bits_last              (mmio_axi4_0_w_bits_last),
    .mmio_axi4_0_b_ready                  (mmio_axi4_0_b_ready),
    .mmio_axi4_0_b_valid                  (mmio_axi4_0_b_valid),
    .mmio_axi4_0_b_bits_id                (mmio_axi4_0_b_bits_id),
    .mmio_axi4_0_b_bits_resp              (mmio_axi4_0_b_bits_resp),
    .mmio_axi4_0_ar_ready                 (mmio_axi4_0_ar_ready),
    .mmio_axi4_0_ar_valid                 (mmio_axi4_0_ar_valid),
    .mmio_axi4_0_ar_bits_id               (mmio_axi4_0_ar_bits_id),
    .mmio_axi4_0_ar_bits_addr             (mmio_axi4_0_ar_bits_addr),
    .mmio_axi4_0_ar_bits_len              (mmio_axi4_0_ar_bits_len),
    .mmio_axi4_0_ar_bits_size             (mmio_axi4_0_ar_bits_size),
    .mmio_axi4_0_ar_bits_burst            (mmio_axi4_0_ar_bits_burst),
    .mmio_axi4_0_ar_bits_lock             (mmio_axi4_0_ar_bits_lock), //unused
    .mmio_axi4_0_ar_bits_cache            (mmio_axi4_0_ar_bits_cache), //unused
    .mmio_axi4_0_ar_bits_prot             (mmio_axi4_0_ar_bits_prot), //unused
    .mmio_axi4_0_ar_bits_qos              (mmio_axi4_0_ar_bits_qos), //unused
    .mmio_axi4_0_r_ready                  (mmio_axi4_0_r_ready),
    .mmio_axi4_0_r_valid                  (mmio_axi4_0_r_valid),
    .mmio_axi4_0_r_bits_id                (mmio_axi4_0_r_bits_id),
    .mmio_axi4_0_r_bits_data              (mmio_axi4_0_r_bits_data),
    .mmio_axi4_0_r_bits_resp              (mmio_axi4_0_r_bits_resp),
    .mmio_axi4_0_r_bits_last              (mmio_axi4_0_r_bits_last),

    .l2_frontend_bus_axi4_0_aw_ready      (l2_frontend_bus_axi4_0_aw_ready),
    .l2_frontend_bus_axi4_0_aw_valid      (l2_frontend_bus_axi4_0_aw_valid),
    .l2_frontend_bus_axi4_0_aw_bits_id    (l2_frontend_bus_axi4_0_aw_bits_id),
    .l2_frontend_bus_axi4_0_aw_bits_addr  (l2_frontend_bus_axi4_0_aw_bits_addr),
    .l2_frontend_bus_axi4_0_aw_bits_len   (l2_frontend_bus_axi4_0_aw_bits_len),
    .l2_frontend_bus_axi4_0_aw_bits_size  (l2_frontend_bus_axi4_0_aw_bits_size),
    .l2_frontend_bus_axi4_0_aw_bits_burst (l2_frontend_bus_axi4_0_aw_bits_burst),
    .l2_frontend_bus_axi4_0_aw_bits_lock  (l2_frontend_bus_axi4_0_aw_bits_lock),  //unused
    .l2_frontend_bus_axi4_0_aw_bits_cache (l2_frontend_bus_axi4_0_aw_bits_cache), //unused
    .l2_frontend_bus_axi4_0_aw_bits_prot  (l2_frontend_bus_axi4_0_aw_bits_prot), //unused
    .l2_frontend_bus_axi4_0_aw_bits_qos   (l2_frontend_bus_axi4_0_aw_bits_qos), //unused
    .l2_frontend_bus_axi4_0_w_ready       (l2_frontend_bus_axi4_0_w_ready),
    .l2_frontend_bus_axi4_0_w_valid       (l2_frontend_bus_axi4_0_w_valid),
    .l2_frontend_bus_axi4_0_w_bits_data   (l2_frontend_bus_axi4_0_w_bits_data),
    .l2_frontend_bus_axi4_0_w_bits_strb   (l2_frontend_bus_axi4_0_w_bits_strb),
    .l2_frontend_bus_axi4_0_w_bits_last   (l2_frontend_bus_axi4_0_w_bits_last),
    .l2_frontend_bus_axi4_0_b_ready       (l2_frontend_bus_axi4_0_b_ready),
    .l2_frontend_bus_axi4_0_b_valid       (l2_frontend_bus_axi4_0_b_valid),
    .l2_frontend_bus_axi4_0_b_bits_id     (l2_frontend_bus_axi4_0_b_bits_id),
    .l2_frontend_bus_axi4_0_b_bits_resp   (l2_frontend_bus_axi4_0_b_bits_resp),
    .l2_frontend_bus_axi4_0_ar_ready      (l2_frontend_bus_axi4_0_ar_ready),
    .l2_frontend_bus_axi4_0_ar_valid      (l2_frontend_bus_axi4_0_ar_valid),
    .l2_frontend_bus_axi4_0_ar_bits_id    (l2_frontend_bus_axi4_0_ar_bits_id),
    .l2_frontend_bus_axi4_0_ar_bits_addr  (l2_frontend_bus_axi4_0_ar_bits_addr),
    .l2_frontend_bus_axi4_0_ar_bits_len   (l2_frontend_bus_axi4_0_ar_bits_len),
    .l2_frontend_bus_axi4_0_ar_bits_size  (l2_frontend_bus_axi4_0_ar_bits_size),
    .l2_frontend_bus_axi4_0_ar_bits_burst (l2_frontend_bus_axi4_0_ar_bits_burst),
    .l2_frontend_bus_axi4_0_ar_bits_lock  (l2_frontend_bus_axi4_0_ar_bits_lock),  //unused
    .l2_frontend_bus_axi4_0_ar_bits_cache (l2_frontend_bus_axi4_0_ar_bits_cache), //unused
    .l2_frontend_bus_axi4_0_ar_bits_prot  (l2_frontend_bus_axi4_0_ar_bits_prot), //unused
    .l2_frontend_bus_axi4_0_ar_bits_qos   (l2_frontend_bus_axi4_0_ar_bits_qos), //unused
    .l2_frontend_bus_axi4_0_r_ready       (l2_frontend_bus_axi4_0_r_ready),
    .l2_frontend_bus_axi4_0_r_valid       (l2_frontend_bus_axi4_0_r_valid),
    .l2_frontend_bus_axi4_0_r_bits_id     (l2_frontend_bus_axi4_0_r_bits_id),
    .l2_frontend_bus_axi4_0_r_bits_data   (l2_frontend_bus_axi4_0_r_bits_data),
    .l2_frontend_bus_axi4_0_r_bits_resp   (l2_frontend_bus_axi4_0_r_bits_resp),
    .l2_frontend_bus_axi4_0_r_bits_last   (l2_frontend_bus_axi4_0_r_bits_last)
);


generate
if (BOOM_ENABLE_TRACE) begin: trace_gen

    wire                          tcu_trace_mem_en;
    wire [BOOM_MEM_DATA_SIZE-1:0] tcu_trace_mem_rdata;

    //MUX between trace memory and TCU-Boom interface
    wire tcu_mem_select_trace = (tcu_mem_addr_i >= BOOM_TRACE_BASEADDR) && (tcu_mem_addr_i < (BOOM_TRACE_BASEADDR+BOOM_TRACE_SIZE));

    reg r_tcu_trace_mem_en;
    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            r_tcu_trace_mem_en <= 1'b0;
        end else begin
            r_tcu_trace_mem_en <= tcu_trace_mem_en;
        end
    end

    assign tcu_axi4_mem_en = tcu_mem_select_trace ? 1'b0 : tcu_mem_en_i;
    assign tcu_axi4_mem_req = tcu_mem_select_trace ? 1'b0 : tcu_mem_req_i;
    assign tcu_trace_mem_en = tcu_mem_select_trace ? tcu_mem_en_i : 1'b0;

    assign tcu_mem_rdata_o = r_tcu_trace_mem_en ? tcu_trace_mem_rdata : tcu_axi4_mem_rdata;

    //read data is always available when trace mem is selected
    assign tcu_mem_rdata_avail_o = tcu_mem_select_trace ? 1'b1 : tcu_axi4_mem_rdata_avail;


    boom_trace #(
        .BOOM_TRACE_BASEADDR   (BOOM_TRACE_BASEADDR),
        .BOOM_TRACE_SIZE       (BOOM_TRACE_SIZE),
        .BOOM_MEM_DATA_SIZE    (BOOM_MEM_DATA_SIZE),
        .BOOM_MEM_ADDR_SIZE    (BOOM_MEM_ADDR_SIZE)
    ) i_boom_trace (
        .clk_i                 (clk_i),
        .reset_n_i             (reset_n_i),

        .trace_enabled_i       (boom_trace_enabled_i),
        .trace_ptr_o           (boom_trace_ptr_o),
        .trace_count_o         (boom_trace_count_o),

        .trace_valid           (traceIO_traces_0_trace_insns_0_valid),
        .trace_iaddr           (traceIO_traces_0_trace_insns_0_iaddr),
        .trace_insn            (traceIO_traces_0_trace_insns_0_insn),
        .trace_priv            (traceIO_traces_0_trace_insns_0_priv),
        .trace_exception       (traceIO_traces_0_trace_insns_0_exception),
        .trace_interrupt       (traceIO_traces_0_trace_insns_0_interrupt),
        .trace_cause           (traceIO_traces_0_trace_insns_0_cause),
        .trace_tval            (traceIO_traces_0_trace_insns_0_tval),

        .trace_mem_en_i        (tcu_trace_mem_en),
        .trace_mem_addr_i      (tcu_mem_addr_i),
        .trace_mem_rdata_o     (tcu_trace_mem_rdata)
    );
end

else begin: no_trace_gen
    assign tcu_axi4_mem_en = tcu_mem_en_i;
    assign tcu_axi4_mem_req = tcu_mem_req_i;

    assign tcu_mem_rdata_o = tcu_axi4_mem_rdata;
    assign tcu_mem_rdata_avail_o = tcu_axi4_mem_rdata_avail;

    assign boom_trace_ptr_o = {BOOM_MEM_ADDR_SIZE{1'b0}};
    assign boom_trace_count_o = {BOOM_MEM_ADDR_SIZE{1'b0}};
end
endgenerate




endmodule
