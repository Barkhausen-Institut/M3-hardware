
module ethernet_fmc_rocket_core #(
    `include "noc_parameter.vh"
    ,parameter ROCKET_USE_LOCAL_MEM = 1,
    parameter ROCKET_ENABLE_TRACE   = 1,
    parameter ROCKET_TRACE_BASEADDR = 32'h00100000,
    parameter ROCKET_TRACE_SIZE     = 'h8000,
    parameter ROCKET_MEM_DATA_SIZE  = 128,
    parameter ROCKET_MEM_BSEL_SIZE  = ROCKET_MEM_DATA_SIZE/8,
    parameter ROCKET_MEM_ADDR_SIZE  = 32,
    parameter ROCKET_REG_DATA_SIZE  = 64,
    parameter ROCKET_REG_BSEL_SIZE  = ROCKET_REG_DATA_SIZE/8,
    parameter ROCKET_REG_ADDR_SIZE  = 32
)
(
    input  wire                               clk_i,
    input  wire                               reset_n_i,

    output wire                               mem_en_o,
    output wire    [ROCKET_MEM_BSEL_SIZE-1:0] mem_wben_o,
    output wire    [ROCKET_MEM_ADDR_SIZE-1:0] mem_addr_o,
    output wire    [ROCKET_MEM_DATA_SIZE-1:0] mem_wdata_o,
    input  wire    [ROCKET_MEM_DATA_SIZE-1:0] mem_rdata_i,
    input  wire                               mem_stall_i,

    output wire                               rocket_noc_tx_wrreq_o,
    output wire                               rocket_noc_tx_burst_o,
    output wire           [NOC_BSEL_SIZE-1:0] rocket_noc_tx_bsel_o,
    output wire         [NOC_CHIPID_SIZE-1:0] rocket_noc_tx_src_chipid_o,
    output wire          [NOC_MODID_SIZE-1:0] rocket_noc_tx_src_modid_o,
    output wire         [NOC_CHIPID_SIZE-1:0] rocket_noc_tx_trg_chipid_o,
    output wire          [NOC_MODID_SIZE-1:0] rocket_noc_tx_trg_modid_o,
    output wire           [NOC_MODE_SIZE-1:0] rocket_noc_tx_mode_o,
    output wire           [NOC_ADDR_SIZE-1:0] rocket_noc_tx_addr_o,
    output wire           [NOC_DATA_SIZE-1:0] rocket_noc_tx_data0_o,
    output wire           [NOC_DATA_SIZE-1:0] rocket_noc_tx_data1_o,
    input  wire                               rocket_noc_tx_stall_i,

    input  wire                               rocket_noc_rx_wrreq_i,
    input  wire                               rocket_noc_rx_burst_i,
    input  wire           [NOC_BSEL_SIZE-1:0] rocket_noc_rx_bsel_i,
    input  wire         [NOC_CHIPID_SIZE-1:0] rocket_noc_rx_src_chipid_i,
    input  wire          [NOC_MODID_SIZE-1:0] rocket_noc_rx_src_modid_i,
    input  wire         [NOC_CHIPID_SIZE-1:0] rocket_noc_rx_trg_chipid_i,
    input  wire          [NOC_MODID_SIZE-1:0] rocket_noc_rx_trg_modid_i,
    input  wire           [NOC_MODE_SIZE-1:0] rocket_noc_rx_mode_i,
    input  wire           [NOC_ADDR_SIZE-1:0] rocket_noc_rx_addr_i,
    input  wire           [NOC_DATA_SIZE-1:0] rocket_noc_rx_data0_i,
    input  wire           [NOC_DATA_SIZE-1:0] rocket_noc_rx_data1_i,
    output wire                               rocket_noc_rx_stall_o,

    output wire                        [31:0] rocket_mmio_axi4_ar_addr_o,
    output wire                         [1:0] rocket_mmio_axi4_ar_burst_o,
    output wire                         [3:0] rocket_mmio_axi4_ar_cache_o,
    output wire                         [7:0] rocket_mmio_axi4_ar_len_o,
    output wire                               rocket_mmio_axi4_ar_lock_o,
    output wire                         [2:0] rocket_mmio_axi4_ar_prot_o,
    output wire                         [3:0] rocket_mmio_axi4_ar_qos_o,
    input  wire                               rocket_mmio_axi4_ar_ready_i,
    output wire                         [2:0] rocket_mmio_axi4_ar_size_o,
    output wire                               rocket_mmio_axi4_ar_valid_o,
    output wire                         [3:0] rocket_mmio_axi4_ar_id_o,
    output wire                        [31:0] rocket_mmio_axi4_aw_addr_o,
    output wire                         [1:0] rocket_mmio_axi4_aw_burst_o,
    output wire                         [3:0] rocket_mmio_axi4_aw_cache_o,
    output wire                         [7:0] rocket_mmio_axi4_aw_len_o,
    output wire                               rocket_mmio_axi4_aw_lock_o,
    output wire                         [2:0] rocket_mmio_axi4_aw_prot_o,
    output wire                         [3:0] rocket_mmio_axi4_aw_qos_o,
    input  wire                               rocket_mmio_axi4_aw_ready_i,
    output wire                         [2:0] rocket_mmio_axi4_aw_size_o,
    output wire                               rocket_mmio_axi4_aw_valid_o,
    output wire                         [3:0] rocket_mmio_axi4_aw_id_o,
    output wire                               rocket_mmio_axi4_b_ready_o,
    input  wire                         [1:0] rocket_mmio_axi4_b_resp_i,
    input  wire                               rocket_mmio_axi4_b_valid_i,
    input  wire                         [3:0] rocket_mmio_axi4_b_id_i,
    input  wire                        [63:0] rocket_mmio_axi4_r_data_i,
    input  wire                               rocket_mmio_axi4_r_last_i,
    output wire                               rocket_mmio_axi4_r_ready_o,
    input  wire                         [1:0] rocket_mmio_axi4_r_resp_i,
    input  wire                               rocket_mmio_axi4_r_valid_i,
    input  wire                         [3:0] rocket_mmio_axi4_r_id_i,
    output wire                        [63:0] rocket_mmio_axi4_w_data_o,
    output wire                               rocket_mmio_axi4_w_last_o,
    input  wire                               rocket_mmio_axi4_w_ready_i,
    output wire                         [7:0] rocket_mmio_axi4_w_strb_o,
    output wire                               rocket_mmio_axi4_w_valid_o,

    input  wire                        [31:0] eth_dma_axi4_ar_addr_i,
    input  wire                         [1:0] eth_dma_axi4_ar_burst_i,
    input  wire                         [3:0] eth_dma_axi4_ar_cache_i,
    input  wire                         [7:0] eth_dma_axi4_ar_len_i,
    input  wire                               eth_dma_axi4_ar_lock_i,
    input  wire                         [2:0] eth_dma_axi4_ar_prot_i,
    input  wire                         [3:0] eth_dma_axi4_ar_qos_i,
    output wire                               eth_dma_axi4_ar_ready_o,
    input  wire                         [2:0] eth_dma_axi4_ar_size_i,
    input  wire                               eth_dma_axi4_ar_valid_i,
    input  wire                         [3:0] eth_dma_axi4_ar_id_i,
    input  wire                        [31:0] eth_dma_axi4_aw_addr_i,
    input  wire                         [1:0] eth_dma_axi4_aw_burst_i,
    input  wire                         [3:0] eth_dma_axi4_aw_cache_i,
    input  wire                         [7:0] eth_dma_axi4_aw_len_i,
    input  wire                               eth_dma_axi4_aw_lock_i,
    input  wire                         [2:0] eth_dma_axi4_aw_prot_i,
    input  wire                         [3:0] eth_dma_axi4_aw_qos_i,
    output wire                               eth_dma_axi4_aw_ready_o,
    input  wire                         [2:0] eth_dma_axi4_aw_size_i,
    input  wire                               eth_dma_axi4_aw_valid_i,
    input  wire                         [3:0] eth_dma_axi4_aw_id_i,
    input  wire                               eth_dma_axi4_b_ready_i,
    output wire                         [1:0] eth_dma_axi4_b_resp_o,
    output wire                               eth_dma_axi4_b_valid_o,
    output wire                         [3:0] eth_dma_axi4_b_id_o,
    output wire                       [127:0] eth_dma_axi4_r_data_o,
    output wire                               eth_dma_axi4_r_last_o,
    input  wire                               eth_dma_axi4_r_ready_i,
    output wire                         [1:0] eth_dma_axi4_r_resp_o,
    output wire                               eth_dma_axi4_r_valid_o,
    output wire                         [3:0] eth_dma_axi4_r_id_o,
    input  wire                       [127:0] eth_dma_axi4_w_data_i,
    input  wire                               eth_dma_axi4_w_last_i,
    output wire                               eth_dma_axi4_w_ready_o,
    input  wire                        [15:0] eth_dma_axi4_w_strb_i,
    input  wire                               eth_dma_axi4_w_valid_i,

    output wire                               reg_en_o,
    output wire    [ROCKET_REG_BSEL_SIZE-1:0] reg_wben_o,
    output wire    [ROCKET_REG_ADDR_SIZE-1:0] reg_addr_o,
    output wire    [ROCKET_REG_DATA_SIZE-1:0] reg_wdata_o,
    input  wire    [ROCKET_REG_DATA_SIZE-1:0] reg_rdata_i,
    input  wire                               reg_stall_i,

    input  wire                               tcu_mem_en_i,
    input  wire                               tcu_mem_req_i,
    input  wire    [ROCKET_MEM_BSEL_SIZE-1:0] tcu_mem_wben_i,
    input  wire    [ROCKET_MEM_ADDR_SIZE-1:0] tcu_mem_addr_i,
    input  wire    [ROCKET_MEM_DATA_SIZE-1:0] tcu_mem_wdata_i,
    output wire    [ROCKET_MEM_DATA_SIZE-1:0] tcu_mem_rdata_o,
    output wire                               tcu_mem_rdata_avail_o,
    output wire                               tcu_mem_wdata_infifo_o,
    input  wire                               tcu_mem_wabort_i,
    output wire                               tcu_mem_wstall_o,
    output wire                               tcu_mem_rstall_o,
    input  wire                               tcu_mem_access_i,

    input  wire                               ext_int1_i,
    input  wire                               ext_int2_i,
    input  wire                               ext_int3_i,
    input  wire                               ext_int4_i,
    input  wire                               ext_int5_i,
    input  wire                               ext_int6_i,

    output wire                               uart_tx,
    input  wire                               uart_rx,

    output wire                        [31:0] tcu_mem_axi4_error_o,
    output wire                        [31:0] axi4_mem_bridge_error_o,

    input  wire                               rocket_trace_enabled_i,
    output wire    [ROCKET_MEM_ADDR_SIZE-1:0] rocket_trace_ptr_o,
    output wire    [ROCKET_MEM_ADDR_SIZE-1:0] rocket_trace_count_o,

    input wire                                jtag_tck_i,
    input wire                                jtag_tms_i,
    input wire                                jtag_tdi_i,
    output wire                               jtag_tdo_o,
    output wire                               jtag_tdo_en_o
);


wire                            mem_axi4_0_aw_ready;
wire                            mem_axi4_0_aw_valid;
wire                      [3:0] mem_axi4_0_aw_bits_id;
wire [ROCKET_MEM_ADDR_SIZE-1:0] mem_axi4_0_aw_bits_addr;
wire                      [7:0] mem_axi4_0_aw_bits_len;
wire                      [2:0] mem_axi4_0_aw_bits_size;
wire                      [1:0] mem_axi4_0_aw_bits_burst;
wire                            mem_axi4_0_aw_bits_lock;
wire                      [3:0] mem_axi4_0_aw_bits_cache;
wire                      [2:0] mem_axi4_0_aw_bits_prot;
wire                      [3:0] mem_axi4_0_aw_bits_qos;
wire                            mem_axi4_0_w_ready;
wire                            mem_axi4_0_w_valid;
wire [ROCKET_MEM_DATA_SIZE-1:0] mem_axi4_0_w_bits_data;
wire [ROCKET_MEM_BSEL_SIZE-1:0] mem_axi4_0_w_bits_strb;
wire                            mem_axi4_0_w_bits_last;
wire                            mem_axi4_0_b_ready;
wire                            mem_axi4_0_b_valid;
wire                      [3:0] mem_axi4_0_b_bits_id;
wire                      [1:0] mem_axi4_0_b_bits_resp;
wire                            mem_axi4_0_ar_ready;
wire                            mem_axi4_0_ar_valid;
wire                      [3:0] mem_axi4_0_ar_bits_id;
wire [ROCKET_MEM_ADDR_SIZE-1:0] mem_axi4_0_ar_bits_addr;
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
wire [ROCKET_MEM_DATA_SIZE-1:0] mem_axi4_0_r_bits_data;
wire                      [1:0] mem_axi4_0_r_bits_resp;
wire                            mem_axi4_0_r_bits_last;


wire                            mmio_axi4_0_aw_ready;
wire                            mmio_axi4_0_aw_valid;
wire                      [3:0] mmio_axi4_0_aw_bits_id;
wire [ROCKET_REG_ADDR_SIZE-1:0] mmio_axi4_0_aw_bits_addr;
wire                      [7:0] mmio_axi4_0_aw_bits_len;
wire                      [2:0] mmio_axi4_0_aw_bits_size;
wire                      [1:0] mmio_axi4_0_aw_bits_burst;
wire                            mmio_axi4_0_aw_bits_lock;
wire                      [3:0] mmio_axi4_0_aw_bits_cache;
wire                      [2:0] mmio_axi4_0_aw_bits_prot;
wire                      [3:0] mmio_axi4_0_aw_bits_qos;
wire                            mmio_axi4_0_w_ready;
wire                            mmio_axi4_0_w_valid;
wire [ROCKET_REG_DATA_SIZE-1:0] mmio_axi4_0_w_bits_data;
wire [ROCKET_REG_BSEL_SIZE-1:0] mmio_axi4_0_w_bits_strb;
wire                            mmio_axi4_0_w_bits_last;
wire                            mmio_axi4_0_b_ready;
wire                            mmio_axi4_0_b_valid;
wire                      [3:0] mmio_axi4_0_b_bits_id;
wire                      [1:0] mmio_axi4_0_b_bits_resp;
wire                            mmio_axi4_0_ar_ready;
wire                            mmio_axi4_0_ar_valid;
wire                      [3:0] mmio_axi4_0_ar_bits_id;
wire [ROCKET_REG_ADDR_SIZE-1:0] mmio_axi4_0_ar_bits_addr;
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
wire [ROCKET_REG_DATA_SIZE-1:0] mmio_axi4_0_r_bits_data;
wire                      [1:0] mmio_axi4_0_r_bits_resp;
wire                            mmio_axi4_0_r_bits_last;

wire                            tcu_mmio_axi4_aw_ready;
wire                            tcu_mmio_axi4_aw_valid;
wire                      [3:0] tcu_mmio_axi4_aw_id = 4'h0; //id is not propagated through AXI MUX
wire [ROCKET_REG_ADDR_SIZE-1:0] tcu_mmio_axi4_aw_addr;
wire                      [7:0] tcu_mmio_axi4_aw_len;
wire                      [2:0] tcu_mmio_axi4_aw_size;
wire                      [1:0] tcu_mmio_axi4_aw_burst;
wire                            tcu_mmio_axi4_aw_lock;
wire                      [3:0] tcu_mmio_axi4_aw_cache;
wire                      [2:0] tcu_mmio_axi4_aw_prot;
wire                      [3:0] tcu_mmio_axi4_aw_qos;
wire                            tcu_mmio_axi4_w_ready;
wire                            tcu_mmio_axi4_w_valid;
wire [ROCKET_REG_DATA_SIZE-1:0] tcu_mmio_axi4_w_data;
wire [ROCKET_REG_BSEL_SIZE-1:0] tcu_mmio_axi4_w_strb;
wire                            tcu_mmio_axi4_w_last;
wire                            tcu_mmio_axi4_b_ready;
wire                            tcu_mmio_axi4_b_valid;
wire                      [3:0] tcu_mmio_axi4_b_id = 4'h0; //id is not propagated through AXI MUX
wire                      [1:0] tcu_mmio_axi4_b_resp;
wire                            tcu_mmio_axi4_ar_ready;
wire                            tcu_mmio_axi4_ar_valid;
wire                      [3:0] tcu_mmio_axi4_ar_id = 4'h0; //id is not propagated through AXI MUX
wire [ROCKET_REG_ADDR_SIZE-1:0] tcu_mmio_axi4_ar_addr;
wire                      [7:0] tcu_mmio_axi4_ar_len;
wire                      [2:0] tcu_mmio_axi4_ar_size;
wire                      [1:0] tcu_mmio_axi4_ar_burst;
wire                            tcu_mmio_axi4_ar_lock;
wire                      [3:0] tcu_mmio_axi4_ar_cache;
wire                      [2:0] tcu_mmio_axi4_ar_prot;
wire                      [3:0] tcu_mmio_axi4_ar_qos;
wire                            tcu_mmio_axi4_r_ready;
wire                            tcu_mmio_axi4_r_valid;
wire                      [3:0] tcu_mmio_axi4_r_id = 4'h0; //id is not propagated through AXI MUX
wire [ROCKET_REG_DATA_SIZE-1:0] tcu_mmio_axi4_r_data;
wire                      [1:0] tcu_mmio_axi4_r_resp;
wire                            tcu_mmio_axi4_r_last;


wire                            l2_frontend_bus_axi4_0_aw_ready;
wire                            l2_frontend_bus_axi4_0_aw_valid;
wire                      [3:0] l2_frontend_bus_axi4_0_aw_bits_id;
wire [ROCKET_MEM_ADDR_SIZE-1:0] l2_frontend_bus_axi4_0_aw_bits_addr;
wire                      [7:0] l2_frontend_bus_axi4_0_aw_bits_len;
wire                      [2:0] l2_frontend_bus_axi4_0_aw_bits_size;
wire                      [1:0] l2_frontend_bus_axi4_0_aw_bits_burst;
wire                            l2_frontend_bus_axi4_0_aw_bits_lock;
wire                      [3:0] l2_frontend_bus_axi4_0_aw_bits_cache;
wire                      [2:0] l2_frontend_bus_axi4_0_aw_bits_prot;
wire                      [3:0] l2_frontend_bus_axi4_0_aw_bits_qos;
wire                            l2_frontend_bus_axi4_0_w_ready;
wire                            l2_frontend_bus_axi4_0_w_valid;
wire [ROCKET_MEM_DATA_SIZE-1:0] l2_frontend_bus_axi4_0_w_bits_data;
wire [ROCKET_MEM_BSEL_SIZE-1:0] l2_frontend_bus_axi4_0_w_bits_strb;
wire                            l2_frontend_bus_axi4_0_w_bits_last;
wire                            l2_frontend_bus_axi4_0_b_ready;
wire                            l2_frontend_bus_axi4_0_b_valid;
wire                      [3:0] l2_frontend_bus_axi4_0_b_bits_id;
wire                      [1:0] l2_frontend_bus_axi4_0_b_bits_resp;
wire                            l2_frontend_bus_axi4_0_ar_ready;
wire                            l2_frontend_bus_axi4_0_ar_valid;
wire                      [3:0] l2_frontend_bus_axi4_0_ar_bits_id;
wire [ROCKET_MEM_ADDR_SIZE-1:0] l2_frontend_bus_axi4_0_ar_bits_addr;
wire                      [7:0] l2_frontend_bus_axi4_0_ar_bits_len;
wire                      [2:0] l2_frontend_bus_axi4_0_ar_bits_size;
wire                      [1:0] l2_frontend_bus_axi4_0_ar_bits_burst;
wire                            l2_frontend_bus_axi4_0_ar_bits_lock;
wire                      [3:0] l2_frontend_bus_axi4_0_ar_bits_cache;
wire                      [2:0] l2_frontend_bus_axi4_0_ar_bits_prot;
wire                      [3:0] l2_frontend_bus_axi4_0_ar_bits_qos;
wire                            l2_frontend_bus_axi4_0_r_ready;
wire                            l2_frontend_bus_axi4_0_r_valid;
wire                      [3:0] l2_frontend_bus_axi4_0_r_bits_id;
wire [ROCKET_MEM_DATA_SIZE-1:0] l2_frontend_bus_axi4_0_r_bits_data;
wire                      [1:0] l2_frontend_bus_axi4_0_r_bits_resp;
wire                            l2_frontend_bus_axi4_0_r_bits_last;


wire                            tcu_l2_frontend_bus_axi4_0_aw_ready;
wire                            tcu_l2_frontend_bus_axi4_0_aw_valid;
wire                      [3:0] tcu_l2_frontend_bus_axi4_0_aw_bits_id;
wire [ROCKET_MEM_ADDR_SIZE-1:0] tcu_l2_frontend_bus_axi4_0_aw_bits_addr;
wire                      [7:0] tcu_l2_frontend_bus_axi4_0_aw_bits_len;
wire                      [2:0] tcu_l2_frontend_bus_axi4_0_aw_bits_size;
wire                      [1:0] tcu_l2_frontend_bus_axi4_0_aw_bits_burst;
wire                            tcu_l2_frontend_bus_axi4_0_aw_bits_lock = 1'b0;
wire                      [3:0] tcu_l2_frontend_bus_axi4_0_aw_bits_cache = 4'h0;
wire                      [2:0] tcu_l2_frontend_bus_axi4_0_aw_bits_prot = 3'h0;
wire                      [3:0] tcu_l2_frontend_bus_axi4_0_aw_bits_qos = 4'h0;
wire                            tcu_l2_frontend_bus_axi4_0_w_ready;
wire                            tcu_l2_frontend_bus_axi4_0_w_valid;
wire [ROCKET_MEM_DATA_SIZE-1:0] tcu_l2_frontend_bus_axi4_0_w_bits_data;
wire [ROCKET_MEM_BSEL_SIZE-1:0] tcu_l2_frontend_bus_axi4_0_w_bits_strb;
wire                            tcu_l2_frontend_bus_axi4_0_w_bits_last;
wire                            tcu_l2_frontend_bus_axi4_0_b_ready;
wire                            tcu_l2_frontend_bus_axi4_0_b_valid;
wire                      [3:0] tcu_l2_frontend_bus_axi4_0_b_bits_id;
wire                      [1:0] tcu_l2_frontend_bus_axi4_0_b_bits_resp;
wire                            tcu_l2_frontend_bus_axi4_0_ar_ready;
wire                            tcu_l2_frontend_bus_axi4_0_ar_valid;
wire                      [3:0] tcu_l2_frontend_bus_axi4_0_ar_bits_id;
wire [ROCKET_MEM_ADDR_SIZE-1:0] tcu_l2_frontend_bus_axi4_0_ar_bits_addr;
wire                      [7:0] tcu_l2_frontend_bus_axi4_0_ar_bits_len;
wire                      [2:0] tcu_l2_frontend_bus_axi4_0_ar_bits_size;
wire                      [1:0] tcu_l2_frontend_bus_axi4_0_ar_bits_burst;
wire                            tcu_l2_frontend_bus_axi4_0_ar_bits_lock = 1'b0;
wire                      [3:0] tcu_l2_frontend_bus_axi4_0_ar_bits_cache = 4'h0;
wire                      [2:0] tcu_l2_frontend_bus_axi4_0_ar_bits_prot = 3'h0;
wire                      [3:0] tcu_l2_frontend_bus_axi4_0_ar_bits_qos = 4'h0;
wire                            tcu_l2_frontend_bus_axi4_0_r_ready;
wire                            tcu_l2_frontend_bus_axi4_0_r_valid;
wire                      [3:0] tcu_l2_frontend_bus_axi4_0_r_bits_id;
wire [ROCKET_MEM_DATA_SIZE-1:0] tcu_l2_frontend_bus_axi4_0_r_bits_data;
wire                      [1:0] tcu_l2_frontend_bus_axi4_0_r_bits_resp;
wire                            tcu_l2_frontend_bus_axi4_0_r_bits_last;


wire                            tcu_axi4_mem_en;
wire                            tcu_axi4_mem_req;
wire [ROCKET_MEM_DATA_SIZE-1:0] tcu_axi4_mem_rdata;
wire                            tcu_axi4_mem_rdata_avail;




generate
if (ROCKET_USE_LOCAL_MEM) begin: axi4_mem
    axi4_mem_bridge #(
        .AXI_ID_WIDTH      (4),
        .AXI_ADDR_WIDTH    (ROCKET_MEM_ADDR_SIZE),
        .AXI_DATA_WIDTH    (ROCKET_MEM_DATA_SIZE)
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

    assign rocket_noc_tx_wrreq_o      = 1'b0;
    assign rocket_noc_tx_burst_o      = 1'b0;
    assign rocket_noc_tx_bsel_o       = {NOC_BSEL_SIZE{1'b0}};
    assign rocket_noc_tx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
    assign rocket_noc_tx_src_modid_o  = {NOC_MODID_SIZE{1'b0}};
    assign rocket_noc_tx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
    assign rocket_noc_tx_trg_modid_o  = {NOC_MODID_SIZE{1'b0}};
    assign rocket_noc_tx_mode_o       = {NOC_MODE_SIZE{1'b0}};
    assign rocket_noc_tx_addr_o       = {NOC_ADDR_SIZE{1'b0}};
    assign rocket_noc_tx_data0_o      = {NOC_DATA_SIZE{1'b0}};
    assign rocket_noc_tx_data1_o      = {NOC_DATA_SIZE{1'b0}};
    assign rocket_noc_rx_stall_o      = 1'b0;
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
        .noc_rx_wrreq_i         (rocket_noc_rx_wrreq_i),
        .noc_rx_burst_i         (rocket_noc_rx_burst_i),
        .noc_rx_bsel_i          (rocket_noc_rx_bsel_i),
        .noc_rx_src_chipid_i    (rocket_noc_rx_src_chipid_i),
        .noc_rx_src_modid_i     (rocket_noc_rx_src_modid_i),
        .noc_rx_trg_chipid_i    (rocket_noc_rx_trg_chipid_i),
        .noc_rx_trg_modid_i     (rocket_noc_rx_trg_modid_i),
        .noc_rx_mode_i          (rocket_noc_rx_mode_i),
        .noc_rx_addr_i          (rocket_noc_rx_addr_i),
        .noc_rx_data0_i         (rocket_noc_rx_data0_i),
        .noc_rx_data1_i         (rocket_noc_rx_data1_i),
        .noc_rx_stall_o         (rocket_noc_rx_stall_o),
        .noc_tx_wrreq_o         (rocket_noc_tx_wrreq_o),
        .noc_tx_burst_o         (rocket_noc_tx_burst_o),
        .noc_tx_bsel_o          (rocket_noc_tx_bsel_o),
        .noc_tx_src_chipid_o    (rocket_noc_tx_src_chipid_o),
        .noc_tx_src_modid_o     (rocket_noc_tx_src_modid_o),
        .noc_tx_trg_chipid_o    (rocket_noc_tx_trg_chipid_o),
        .noc_tx_trg_modid_o     (rocket_noc_tx_trg_modid_o),
        .noc_tx_mode_o          (rocket_noc_tx_mode_o),
        .noc_tx_addr_o          (rocket_noc_tx_addr_o),
        .noc_tx_data0_o         (rocket_noc_tx_data0_o),
        .noc_tx_data1_o         (rocket_noc_tx_data1_o),
        .noc_tx_stall_i         (rocket_noc_tx_stall_i)
    );

    assign mem_en_o    = 1'b0;
    assign mem_wben_o  = {ROCKET_MEM_BSEL_SIZE{1'b0}};
    assign mem_addr_o  = {ROCKET_MEM_ADDR_SIZE{1'b0}};
    assign mem_wdata_o = {ROCKET_MEM_DATA_SIZE{1'b0}};
end
endgenerate


axi4_mem_bridge #(
    .AXI_ID_WIDTH      (4),
    .AXI_ADDR_WIDTH    (ROCKET_REG_ADDR_SIZE),
    .AXI_DATA_WIDTH    (ROCKET_REG_DATA_SIZE)
) axi4_to_reg (
    .clk_i             (clk_i),
    .reset_n_i         (reset_n_i),
    .axi4_error_o      (),
    .axi4_aw_id_i      (tcu_mmio_axi4_aw_id),
    .axi4_aw_addr_i    (tcu_mmio_axi4_aw_addr),
    .axi4_aw_len_i     (tcu_mmio_axi4_aw_len),
    .axi4_aw_size_i    (tcu_mmio_axi4_aw_size),
    .axi4_aw_burst_i   (tcu_mmio_axi4_aw_burst),
    .axi4_aw_valid_i   (tcu_mmio_axi4_aw_valid),
    .axi4_aw_ready_o   (tcu_mmio_axi4_aw_ready),
    .axi4_w_data_i     (tcu_mmio_axi4_w_data),
    .axi4_w_strb_i     (tcu_mmio_axi4_w_strb),
    .axi4_w_last_i     (tcu_mmio_axi4_w_last),
    .axi4_w_valid_i    (tcu_mmio_axi4_w_valid),
    .axi4_w_ready_o    (tcu_mmio_axi4_w_ready),
    .axi4_b_id_o       (tcu_mmio_axi4_b_id),
    .axi4_b_resp_o     (tcu_mmio_axi4_b_resp),
    .axi4_b_valid_o    (tcu_mmio_axi4_b_valid),
    .axi4_b_ready_i    (tcu_mmio_axi4_b_ready),
    .axi4_ar_id_i      (tcu_mmio_axi4_ar_id),
    .axi4_ar_addr_i    (tcu_mmio_axi4_ar_addr),
    .axi4_ar_len_i     (tcu_mmio_axi4_ar_len),
    .axi4_ar_size_i    (tcu_mmio_axi4_ar_size),
    .axi4_ar_burst_i   (tcu_mmio_axi4_ar_burst),
    .axi4_ar_valid_i   (tcu_mmio_axi4_ar_valid),
    .axi4_ar_ready_o   (tcu_mmio_axi4_ar_ready),
    .axi4_r_id_o       (tcu_mmio_axi4_r_id),
    .axi4_r_data_o     (tcu_mmio_axi4_r_data),
    .axi4_r_resp_o     (tcu_mmio_axi4_r_resp),
    .axi4_r_last_o     (tcu_mmio_axi4_r_last),
    .axi4_r_valid_o    (tcu_mmio_axi4_r_valid),
    .axi4_r_ready_i    (tcu_mmio_axi4_r_ready),
    .mem_en_o          (reg_en_o),
    .mem_wben_o        (reg_wben_o),
    .mem_addr_o        (reg_addr_o),
    .mem_wdata_o       (reg_wdata_o),
    .mem_rdata_i       (reg_rdata_i),
    .mem_stall_i       (reg_stall_i)
);



mem_axi4_bridge #(
    .AXI_ID_WIDTH      (4),
    .AXI_ADDR_WIDTH    (ROCKET_MEM_ADDR_SIZE),
    .AXI_DATA_WIDTH    (ROCKET_MEM_DATA_SIZE)
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
    .axi4_aw_id_o      (tcu_l2_frontend_bus_axi4_0_aw_bits_id),
    .axi4_aw_addr_o    (tcu_l2_frontend_bus_axi4_0_aw_bits_addr),
    .axi4_aw_len_o     (tcu_l2_frontend_bus_axi4_0_aw_bits_len),
    .axi4_aw_size_o    (tcu_l2_frontend_bus_axi4_0_aw_bits_size),
    .axi4_aw_burst_o   (tcu_l2_frontend_bus_axi4_0_aw_bits_burst),
    .axi4_aw_valid_o   (tcu_l2_frontend_bus_axi4_0_aw_valid),
    .axi4_aw_ready_i   (tcu_l2_frontend_bus_axi4_0_aw_ready),
    .axi4_w_data_o     (tcu_l2_frontend_bus_axi4_0_w_bits_data),
    .axi4_w_strb_o     (tcu_l2_frontend_bus_axi4_0_w_bits_strb),
    .axi4_w_last_o     (tcu_l2_frontend_bus_axi4_0_w_bits_last),
    .axi4_w_valid_o    (tcu_l2_frontend_bus_axi4_0_w_valid),
    .axi4_w_ready_i    (tcu_l2_frontend_bus_axi4_0_w_ready),
    .axi4_b_id_i       (tcu_l2_frontend_bus_axi4_0_b_bits_id),
    .axi4_b_resp_i     (tcu_l2_frontend_bus_axi4_0_b_bits_resp),
    .axi4_b_valid_i    (tcu_l2_frontend_bus_axi4_0_b_valid),
    .axi4_b_ready_o    (tcu_l2_frontend_bus_axi4_0_b_ready),
    .axi4_ar_id_o      (tcu_l2_frontend_bus_axi4_0_ar_bits_id),
    .axi4_ar_addr_o    (tcu_l2_frontend_bus_axi4_0_ar_bits_addr),
    .axi4_ar_len_o     (tcu_l2_frontend_bus_axi4_0_ar_bits_len),
    .axi4_ar_size_o    (tcu_l2_frontend_bus_axi4_0_ar_bits_size),
    .axi4_ar_burst_o   (tcu_l2_frontend_bus_axi4_0_ar_bits_burst),
    .axi4_ar_valid_o   (tcu_l2_frontend_bus_axi4_0_ar_valid),
    .axi4_ar_ready_i   (tcu_l2_frontend_bus_axi4_0_ar_ready),
    .axi4_r_id_i       (tcu_l2_frontend_bus_axi4_0_r_bits_id),
    .axi4_r_data_i     (tcu_l2_frontend_bus_axi4_0_r_bits_data),
    .axi4_r_resp_i     (tcu_l2_frontend_bus_axi4_0_r_bits_resp),
    .axi4_r_last_i     (tcu_l2_frontend_bus_axi4_0_r_bits_last),
    .axi4_r_valid_i    (tcu_l2_frontend_bus_axi4_0_r_valid),
    .axi4_r_ready_o    (tcu_l2_frontend_bus_axi4_0_r_ready)
);


bd_axi4_mux_1to2_wrapper i_bd_axi4_mux_1to2_wrapper (
    .axi4_clk           (clk_i),
    .axi4_reset_n       (reset_n_i),
    .AXI4_IN_araddr     (mmio_axi4_0_ar_bits_addr),
    .AXI4_IN_arburst    (mmio_axi4_0_ar_bits_burst),
    .AXI4_IN_arcache    (mmio_axi4_0_ar_bits_cache),
    .AXI4_IN_arid       (mmio_axi4_0_ar_bits_id),
    .AXI4_IN_arlen      (mmio_axi4_0_ar_bits_len),
    .AXI4_IN_arlock     (mmio_axi4_0_ar_bits_lock),
    .AXI4_IN_arprot     (mmio_axi4_0_ar_bits_prot),
    .AXI4_IN_arqos      (mmio_axi4_0_ar_bits_qos),
    .AXI4_IN_arready    (mmio_axi4_0_ar_ready),
    .AXI4_IN_arsize     (mmio_axi4_0_ar_bits_size),
    .AXI4_IN_arvalid    (mmio_axi4_0_ar_valid),
    .AXI4_IN_awaddr     (mmio_axi4_0_aw_bits_addr),
    .AXI4_IN_awburst    (mmio_axi4_0_aw_bits_burst),
    .AXI4_IN_awcache    (mmio_axi4_0_aw_bits_cache),
    .AXI4_IN_awid       (mmio_axi4_0_aw_bits_id),
    .AXI4_IN_awlen      (mmio_axi4_0_aw_bits_len),
    .AXI4_IN_awlock     (mmio_axi4_0_aw_bits_lock),
    .AXI4_IN_awprot     (mmio_axi4_0_aw_bits_prot),
    .AXI4_IN_awqos      (mmio_axi4_0_aw_bits_qos),
    .AXI4_IN_awready    (mmio_axi4_0_aw_ready),
    .AXI4_IN_awsize     (mmio_axi4_0_aw_bits_size),
    .AXI4_IN_awvalid    (mmio_axi4_0_aw_valid),
    .AXI4_IN_bid        (mmio_axi4_0_b_bits_id),
    .AXI4_IN_bready     (mmio_axi4_0_b_ready),
    .AXI4_IN_bresp      (mmio_axi4_0_b_bits_resp),
    .AXI4_IN_bvalid     (mmio_axi4_0_b_valid),
    .AXI4_IN_rdata      (mmio_axi4_0_r_bits_data),
    .AXI4_IN_rid        (mmio_axi4_0_r_bits_id),
    .AXI4_IN_rlast      (mmio_axi4_0_r_bits_last),
    .AXI4_IN_rready     (mmio_axi4_0_r_ready),
    .AXI4_IN_rresp      (mmio_axi4_0_r_bits_resp),
    .AXI4_IN_rvalid     (mmio_axi4_0_r_valid),
    .AXI4_IN_wdata      (mmio_axi4_0_w_bits_data),
    .AXI4_IN_wlast      (mmio_axi4_0_w_bits_last),
    .AXI4_IN_wready     (mmio_axi4_0_w_ready),
    .AXI4_IN_wstrb      (mmio_axi4_0_w_bits_strb),
    .AXI4_IN_wvalid     (mmio_axi4_0_w_valid),
    .AXI4_OUT0_araddr   (tcu_mmio_axi4_ar_addr),
    .AXI4_OUT0_arburst  (tcu_mmio_axi4_ar_burst),
    .AXI4_OUT0_arcache  (tcu_mmio_axi4_ar_cache),
    .AXI4_OUT0_arlen    (tcu_mmio_axi4_ar_len),
    .AXI4_OUT0_arlock   (tcu_mmio_axi4_ar_lock),
    .AXI4_OUT0_arprot   (tcu_mmio_axi4_ar_prot),
    .AXI4_OUT0_arqos    (tcu_mmio_axi4_ar_qos),
    .AXI4_OUT0_arready  (tcu_mmio_axi4_ar_ready),
    .AXI4_OUT0_arsize   (tcu_mmio_axi4_ar_size),
    .AXI4_OUT0_arvalid  (tcu_mmio_axi4_ar_valid),
    .AXI4_OUT0_awaddr   (tcu_mmio_axi4_aw_addr),
    .AXI4_OUT0_awburst  (tcu_mmio_axi4_aw_burst),
    .AXI4_OUT0_awcache  (tcu_mmio_axi4_aw_cache),
    .AXI4_OUT0_awlen    (tcu_mmio_axi4_aw_len),
    .AXI4_OUT0_awlock   (tcu_mmio_axi4_aw_lock),
    .AXI4_OUT0_awprot   (tcu_mmio_axi4_aw_prot),
    .AXI4_OUT0_awqos    (tcu_mmio_axi4_aw_qos),
    .AXI4_OUT0_awready  (tcu_mmio_axi4_aw_ready),
    .AXI4_OUT0_awsize   (tcu_mmio_axi4_aw_size),
    .AXI4_OUT0_awvalid  (tcu_mmio_axi4_aw_valid),
    .AXI4_OUT0_bready   (tcu_mmio_axi4_b_ready),
    .AXI4_OUT0_bresp    (tcu_mmio_axi4_b_resp),
    .AXI4_OUT0_bvalid   (tcu_mmio_axi4_b_valid),
    .AXI4_OUT0_rdata    (tcu_mmio_axi4_r_data),
    .AXI4_OUT0_rlast    (tcu_mmio_axi4_r_last),
    .AXI4_OUT0_rready   (tcu_mmio_axi4_r_ready),
    .AXI4_OUT0_rresp    (tcu_mmio_axi4_r_resp),
    .AXI4_OUT0_rvalid   (tcu_mmio_axi4_r_valid),
    .AXI4_OUT0_wdata    (tcu_mmio_axi4_w_data),
    .AXI4_OUT0_wlast    (tcu_mmio_axi4_w_last),
    .AXI4_OUT0_wready   (tcu_mmio_axi4_w_ready),
    .AXI4_OUT0_wstrb    (tcu_mmio_axi4_w_strb),
    .AXI4_OUT0_wvalid   (tcu_mmio_axi4_w_valid),
    .AXI4_OUT1_araddr   (rocket_mmio_axi4_ar_addr_o),
    .AXI4_OUT1_arburst  (rocket_mmio_axi4_ar_burst_o),
    .AXI4_OUT1_arcache  (rocket_mmio_axi4_ar_cache_o),
    .AXI4_OUT1_arlen    (rocket_mmio_axi4_ar_len_o),
    .AXI4_OUT1_arlock   (rocket_mmio_axi4_ar_lock_o),
    .AXI4_OUT1_arprot   (rocket_mmio_axi4_ar_prot_o),
    .AXI4_OUT1_arqos    (rocket_mmio_axi4_ar_qos_o),
    .AXI4_OUT1_arready  (rocket_mmio_axi4_ar_ready_i),
    .AXI4_OUT1_arsize   (rocket_mmio_axi4_ar_size_o),
    .AXI4_OUT1_arvalid  (rocket_mmio_axi4_ar_valid_o),
    .AXI4_OUT1_awaddr   (rocket_mmio_axi4_aw_addr_o),
    .AXI4_OUT1_awburst  (rocket_mmio_axi4_aw_burst_o),
    .AXI4_OUT1_awcache  (rocket_mmio_axi4_aw_cache_o),
    .AXI4_OUT1_awlen    (rocket_mmio_axi4_aw_len_o),
    .AXI4_OUT1_awlock   (rocket_mmio_axi4_aw_lock_o),
    .AXI4_OUT1_awprot   (rocket_mmio_axi4_aw_prot_o),
    .AXI4_OUT1_awqos    (rocket_mmio_axi4_aw_qos_o),
    .AXI4_OUT1_awready  (rocket_mmio_axi4_aw_ready_i),
    .AXI4_OUT1_awsize   (rocket_mmio_axi4_aw_size_o),
    .AXI4_OUT1_awvalid  (rocket_mmio_axi4_aw_valid_o),
    .AXI4_OUT1_bready   (rocket_mmio_axi4_b_ready_o),
    .AXI4_OUT1_bresp    (rocket_mmio_axi4_b_resp_i),
    .AXI4_OUT1_bvalid   (rocket_mmio_axi4_b_valid_i),
    .AXI4_OUT1_rdata    (rocket_mmio_axi4_r_data_i),
    .AXI4_OUT1_rlast    (rocket_mmio_axi4_r_last_i),
    .AXI4_OUT1_rready   (rocket_mmio_axi4_r_ready_o),
    .AXI4_OUT1_rresp    (rocket_mmio_axi4_r_resp_i),
    .AXI4_OUT1_rvalid   (rocket_mmio_axi4_r_valid_i),
    .AXI4_OUT1_wdata    (rocket_mmio_axi4_w_data_o),
    .AXI4_OUT1_wlast    (rocket_mmio_axi4_w_last_o),
    .AXI4_OUT1_wready   (rocket_mmio_axi4_w_ready_i),
    .AXI4_OUT1_wstrb    (rocket_mmio_axi4_w_strb_o),
    .AXI4_OUT1_wvalid   (rocket_mmio_axi4_w_valid_o)
);

//id is not propagated through AXI4 mux
assign rocket_mmio_axi4_aw_id_o = 4'h0;
assign rocket_mmio_axi4_ar_id_o = 4'h0;


bd_axi4_mux_2to1_wrapper i_bd_axi4_mux_2to1_wrapper (
    .axi4_clk           (clk_i),
    .axi4_reset_n       (reset_n_i),
    .AXI4_IN0_araddr    (tcu_l2_frontend_bus_axi4_0_ar_bits_addr),
    .AXI4_IN0_arburst   (tcu_l2_frontend_bus_axi4_0_ar_bits_burst),
    .AXI4_IN0_arcache   (tcu_l2_frontend_bus_axi4_0_ar_bits_cache),
    .AXI4_IN0_arid      (tcu_l2_frontend_bus_axi4_0_ar_bits_id),
    .AXI4_IN0_arlen     (tcu_l2_frontend_bus_axi4_0_ar_bits_len),
    .AXI4_IN0_arlock    (tcu_l2_frontend_bus_axi4_0_ar_bits_lock),
    .AXI4_IN0_arprot    (tcu_l2_frontend_bus_axi4_0_ar_bits_prot),
    .AXI4_IN0_arqos     (tcu_l2_frontend_bus_axi4_0_ar_bits_qos),
    .AXI4_IN0_arready   (tcu_l2_frontend_bus_axi4_0_ar_ready),
    .AXI4_IN0_arsize    (tcu_l2_frontend_bus_axi4_0_ar_bits_size),
    .AXI4_IN0_arvalid   (tcu_l2_frontend_bus_axi4_0_ar_valid),
    .AXI4_IN0_awaddr    (tcu_l2_frontend_bus_axi4_0_aw_bits_addr),
    .AXI4_IN0_awburst   (tcu_l2_frontend_bus_axi4_0_aw_bits_burst),
    .AXI4_IN0_awcache   (tcu_l2_frontend_bus_axi4_0_aw_bits_cache),
    .AXI4_IN0_awid      (tcu_l2_frontend_bus_axi4_0_aw_bits_id),
    .AXI4_IN0_awlen     (tcu_l2_frontend_bus_axi4_0_aw_bits_len),
    .AXI4_IN0_awlock    (tcu_l2_frontend_bus_axi4_0_aw_bits_lock),
    .AXI4_IN0_awprot    (tcu_l2_frontend_bus_axi4_0_aw_bits_prot),
    .AXI4_IN0_awqos     (tcu_l2_frontend_bus_axi4_0_aw_bits_qos),
    .AXI4_IN0_awready   (tcu_l2_frontend_bus_axi4_0_aw_ready),
    .AXI4_IN0_awsize    (tcu_l2_frontend_bus_axi4_0_aw_bits_size),
    .AXI4_IN0_awvalid   (tcu_l2_frontend_bus_axi4_0_aw_valid),
    .AXI4_IN0_bid       (tcu_l2_frontend_bus_axi4_0_b_bits_id),
    .AXI4_IN0_bready    (tcu_l2_frontend_bus_axi4_0_b_ready),
    .AXI4_IN0_bresp     (tcu_l2_frontend_bus_axi4_0_b_bits_resp),
    .AXI4_IN0_bvalid    (tcu_l2_frontend_bus_axi4_0_b_valid),
    .AXI4_IN0_rdata     (tcu_l2_frontend_bus_axi4_0_r_bits_data),
    .AXI4_IN0_rid       (tcu_l2_frontend_bus_axi4_0_r_bits_id),
    .AXI4_IN0_rlast     (tcu_l2_frontend_bus_axi4_0_r_bits_last),
    .AXI4_IN0_rready    (tcu_l2_frontend_bus_axi4_0_r_ready),
    .AXI4_IN0_rresp     (tcu_l2_frontend_bus_axi4_0_r_bits_resp),
    .AXI4_IN0_rvalid    (tcu_l2_frontend_bus_axi4_0_r_valid),
    .AXI4_IN0_wdata     (tcu_l2_frontend_bus_axi4_0_w_bits_data),
    .AXI4_IN0_wlast     (tcu_l2_frontend_bus_axi4_0_w_bits_last),
    .AXI4_IN0_wready    (tcu_l2_frontend_bus_axi4_0_w_ready),
    .AXI4_IN0_wstrb     (tcu_l2_frontend_bus_axi4_0_w_bits_strb),
    .AXI4_IN0_wvalid    (tcu_l2_frontend_bus_axi4_0_w_valid),
    .AXI4_IN1_araddr    (eth_dma_axi4_ar_addr_i),
    .AXI4_IN1_arburst   (eth_dma_axi4_ar_burst_i),
    .AXI4_IN1_arcache   (eth_dma_axi4_ar_cache_i),
    .AXI4_IN1_arid      (eth_dma_axi4_ar_id_i),
    .AXI4_IN1_arlen     (eth_dma_axi4_ar_len_i),
    .AXI4_IN1_arlock    (eth_dma_axi4_ar_lock_i),
    .AXI4_IN1_arprot    (eth_dma_axi4_ar_prot_i),
    .AXI4_IN1_arqos     (eth_dma_axi4_ar_qos_i),
    .AXI4_IN1_arready   (eth_dma_axi4_ar_ready_o),
    .AXI4_IN1_arsize    (eth_dma_axi4_ar_size_i),
    .AXI4_IN1_arvalid   (eth_dma_axi4_ar_valid_i),
    .AXI4_IN1_awaddr    (eth_dma_axi4_aw_addr_i),
    .AXI4_IN1_awburst   (eth_dma_axi4_aw_burst_i),
    .AXI4_IN1_awcache   (eth_dma_axi4_aw_cache_i),
    .AXI4_IN1_awid      (eth_dma_axi4_aw_id_i),
    .AXI4_IN1_awlen     (eth_dma_axi4_aw_len_i),
    .AXI4_IN1_awlock    (eth_dma_axi4_aw_lock_i),
    .AXI4_IN1_awprot    (eth_dma_axi4_aw_prot_i),
    .AXI4_IN1_awqos     (eth_dma_axi4_aw_qos_i),
    .AXI4_IN1_awready   (eth_dma_axi4_aw_ready_o),
    .AXI4_IN1_awsize    (eth_dma_axi4_aw_size_i),
    .AXI4_IN1_awvalid   (eth_dma_axi4_aw_valid_i),
    .AXI4_IN1_bid       (eth_dma_axi4_b_id_o),
    .AXI4_IN1_bready    (eth_dma_axi4_b_ready_i),
    .AXI4_IN1_bresp     (eth_dma_axi4_b_resp_o),
    .AXI4_IN1_bvalid    (eth_dma_axi4_b_valid_o),
    .AXI4_IN1_rdata     (eth_dma_axi4_r_data_o),
    .AXI4_IN1_rid       (eth_dma_axi4_r_id_o),
    .AXI4_IN1_rlast     (eth_dma_axi4_r_last_o),
    .AXI4_IN1_rready    (eth_dma_axi4_r_ready_i),
    .AXI4_IN1_rresp     (eth_dma_axi4_r_resp_o),
    .AXI4_IN1_rvalid    (eth_dma_axi4_r_valid_o),
    .AXI4_IN1_wdata     (eth_dma_axi4_w_data_i),
    .AXI4_IN1_wlast     (eth_dma_axi4_w_last_i),
    .AXI4_IN1_wready    (eth_dma_axi4_w_ready_o),
    .AXI4_IN1_wstrb     (eth_dma_axi4_w_strb_i),
    .AXI4_IN1_wvalid    (eth_dma_axi4_w_valid_i),
    .AXI4_OUT_araddr    (l2_frontend_bus_axi4_0_ar_bits_addr),
    .AXI4_OUT_arburst   (l2_frontend_bus_axi4_0_ar_bits_burst),
    .AXI4_OUT_arcache   (l2_frontend_bus_axi4_0_ar_bits_cache),
    .AXI4_OUT_arlen     (l2_frontend_bus_axi4_0_ar_bits_len),
    .AXI4_OUT_arlock    (l2_frontend_bus_axi4_0_ar_bits_lock),
    .AXI4_OUT_arprot    (l2_frontend_bus_axi4_0_ar_bits_prot),
    .AXI4_OUT_arqos     (l2_frontend_bus_axi4_0_ar_bits_qos),
    .AXI4_OUT_arready   (l2_frontend_bus_axi4_0_ar_ready),
    .AXI4_OUT_arsize    (l2_frontend_bus_axi4_0_ar_bits_size),
    .AXI4_OUT_arvalid   (l2_frontend_bus_axi4_0_ar_valid),
    .AXI4_OUT_awaddr    (l2_frontend_bus_axi4_0_aw_bits_addr),
    .AXI4_OUT_awburst   (l2_frontend_bus_axi4_0_aw_bits_burst),
    .AXI4_OUT_awcache   (l2_frontend_bus_axi4_0_aw_bits_cache),
    .AXI4_OUT_awlen     (l2_frontend_bus_axi4_0_aw_bits_len),
    .AXI4_OUT_awlock    (l2_frontend_bus_axi4_0_aw_bits_lock),
    .AXI4_OUT_awprot    (l2_frontend_bus_axi4_0_aw_bits_prot),
    .AXI4_OUT_awqos     (l2_frontend_bus_axi4_0_aw_bits_qos),
    .AXI4_OUT_awready   (l2_frontend_bus_axi4_0_aw_ready),
    .AXI4_OUT_awsize    (l2_frontend_bus_axi4_0_aw_bits_size),
    .AXI4_OUT_awvalid   (l2_frontend_bus_axi4_0_aw_valid),
    .AXI4_OUT_bready    (l2_frontend_bus_axi4_0_b_ready),
    .AXI4_OUT_bresp     (l2_frontend_bus_axi4_0_b_bits_resp),
    .AXI4_OUT_bvalid    (l2_frontend_bus_axi4_0_b_valid),
    .AXI4_OUT_rdata     (l2_frontend_bus_axi4_0_r_bits_data),
    .AXI4_OUT_rlast     (l2_frontend_bus_axi4_0_r_bits_last),
    .AXI4_OUT_rready    (l2_frontend_bus_axi4_0_r_ready),
    .AXI4_OUT_rresp     (l2_frontend_bus_axi4_0_r_bits_resp),
    .AXI4_OUT_rvalid    (l2_frontend_bus_axi4_0_r_valid),
    .AXI4_OUT_wdata     (l2_frontend_bus_axi4_0_w_bits_data),
    .AXI4_OUT_wlast     (l2_frontend_bus_axi4_0_w_bits_last),
    .AXI4_OUT_wready    (l2_frontend_bus_axi4_0_w_ready),
    .AXI4_OUT_wstrb     (l2_frontend_bus_axi4_0_w_bits_strb),
    .AXI4_OUT_wvalid    (l2_frontend_bus_axi4_0_w_valid)
);

//id is not propagated through AXI4 mux
assign l2_frontend_bus_axi4_0_aw_bits_id = 4'h0;
assign l2_frontend_bus_axi4_0_ar_bits_id = 4'h0;



wire         traceIO_traces_0_clock;
wire         traceIO_traces_0_reset;
wire         traceIO_traces_0_insns_0_valid;
wire [39:0]  traceIO_traces_0_insns_0_iaddr;
wire [31:0]  traceIO_traces_0_insns_0_insn;
`ifdef ETHFMC_USE_BOOM
wire [63:0]  traceIO_traces_0_insns_0_wdata;
`endif
wire [2:0]   traceIO_traces_0_insns_0_priv;
wire         traceIO_traces_0_insns_0_exception;
wire         traceIO_traces_0_insns_0_interrupt;
wire [63:0]  traceIO_traces_0_insns_0_cause;
wire [39:0]  traceIO_traces_0_insns_0_tval;

`ifdef ETHFMC_USE_BOOM
wire         traceIO_traces_0_insns_1_valid;
wire [39:0]  traceIO_traces_0_insns_1_iaddr;
wire [31:0]  traceIO_traces_0_insns_1_insn;
wire [63:0]  traceIO_traces_0_insns_1_wdata;
wire [2:0]   traceIO_traces_0_insns_1_priv;
wire         traceIO_traces_0_insns_1_exception;
wire         traceIO_traces_0_insns_1_interrupt;
wire [63:0]  traceIO_traces_0_insns_1_cause;
wire [39:0]  traceIO_traces_0_insns_1_tval;
`endif

wire debug_ndreset;
wire debug_dmactive;
wire debug_dmactive_sync;


//feed back synced active signal as ack
util_sync util_sync_dmactive (
    .clk_i     (clk_i),
    .reset_n_i (reset_n_i),
    .data_i    (debug_dmactive),
    .data_o    (debug_dmactive_sync)
);

`ifdef ETHFMC_USE_BOOM
DigitalTop_boom boom_top (
`else
DigitalTop rocket_top (
`endif
    .clock                                (clk_i),
    .reset                                (~reset_n_i),

    .auto_domain_resetCtrl_async_reset_sink_in_clock                                       (clk_i),
    .auto_domain_resetCtrl_async_reset_sink_in_reset                                       (~reset_n_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_clock  (clk_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_cbus_0_reset  (~reset_n_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_clock  (clk_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_mbus_0_reset  (~reset_n_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_clock  (clk_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_fbus_0_reset  (~reset_n_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_clock  (clk_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_pbus_0_reset  (~reset_n_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_clock  (clk_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_1_reset  (~reset_n_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_clock  (clk_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_subsystem_sbus_0_reset  (~reset_n_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_clock    (clk_i),
    .auto_domain_resetCtrl_tile_reset_provider_in_member_allClocks_implicit_clock_reset    (~reset_n_i),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_clock (),  //outputs unused
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_cbus_0_reset (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_clock (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_mbus_0_reset (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_clock (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_fbus_0_reset (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_clock (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_pbus_0_reset (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_clock (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_1_reset (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_clock (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_subsystem_sbus_0_reset (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_clock   (),
    .auto_domain_resetCtrl_tile_reset_provider_out_member_allClocks_implicit_clock_reset   (),
    .auto_subsystem_mbus_fixedClockNode_out_1_clock                                        (),
    .auto_subsystem_mbus_fixedClockNode_out_1_reset                                        (),
    .auto_subsystem_mbus_fixedClockNode_out_0_clock                                        (),
    .auto_subsystem_mbus_fixedClockNode_out_0_reset                                        (),
    .auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_clock      (clk_i),
    .auto_subsystem_mbus_subsystem_mbus_clock_groups_in_member_subsystem_mbus_0_reset      (~reset_n_i),
    .auto_subsystem_cbus_fixedClockNode_out_clock                                          (),
    .auto_subsystem_cbus_fixedClockNode_out_reset                                          (),
    .auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_clock      (clk_i),
    .auto_subsystem_cbus_subsystem_cbus_clock_groups_in_member_subsystem_cbus_0_reset      (~reset_n_i),
    .auto_subsystem_fbus_fixedClockNode_out_clock                                          (),
    .auto_subsystem_fbus_fixedClockNode_out_reset                                          (),
    .auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_clock      (clk_i),
    .auto_subsystem_fbus_subsystem_fbus_clock_groups_in_member_subsystem_fbus_0_reset      (~reset_n_i),
    .auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_clock      (clk_i),
    .auto_subsystem_pbus_subsystem_pbus_clock_groups_in_member_subsystem_pbus_0_reset      (~reset_n_i),
    .auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_clock      (clk_i),
    .auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_1_reset      (~reset_n_i),
    .auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_clock      (clk_i),
    .auto_subsystem_sbus_subsystem_sbus_clock_groups_in_member_subsystem_sbus_0_reset      (~reset_n_i),

    .resetctrl_hartIsInReset_0            (debug_ndreset),

    .debug_clock                          (clk_i),
    .debug_reset                          (~reset_n_i),
    .debug_systemjtag_jtag_TCK            (jtag_tck_i),
    .debug_systemjtag_jtag_TMS            (jtag_tms_i),
    .debug_systemjtag_jtag_TDI            (jtag_tdi_i),
    .debug_systemjtag_jtag_TDO_data       (jtag_tdo_o),
    .debug_systemjtag_jtag_TDO_driven     (jtag_tdo_en_o),
    .debug_systemjtag_reset               (~reset_n_i),
    .debug_systemjtag_mfr_id              (11'h0),
    .debug_systemjtag_part_number         (16'h0),
    .debug_systemjtag_version             (4'h0),
    .debug_ndreset                        (debug_ndreset),  //debugger can reset hart
    .debug_dmactive                       (debug_dmactive),
    .debug_dmactiveAck                    (debug_dmactive_sync),

    .interrupts                           ({2'h0, ext_int6_i, ext_int5_i, ext_int4_i, ext_int3_i, ext_int2_i, ext_int1_i}),

    .uart_0_txd                           (uart_tx),
    .uart_0_rxd                           (uart_rx),

    .traceIO_traces_0_clock               (traceIO_traces_0_clock),
    .traceIO_traces_0_reset               (traceIO_traces_0_reset),
    .traceIO_traces_0_insns_0_valid       (traceIO_traces_0_insns_0_valid),
    .traceIO_traces_0_insns_0_iaddr       (traceIO_traces_0_insns_0_iaddr),
    .traceIO_traces_0_insns_0_insn        (traceIO_traces_0_insns_0_insn),
`ifdef ETHFMC_USE_BOOM
    .traceIO_traces_0_insns_0_wdata       (traceIO_traces_0_insns_0_wdata),
`endif
    .traceIO_traces_0_insns_0_priv        (traceIO_traces_0_insns_0_priv),
    .traceIO_traces_0_insns_0_exception   (traceIO_traces_0_insns_0_exception),
    .traceIO_traces_0_insns_0_interrupt   (traceIO_traces_0_insns_0_interrupt),
    .traceIO_traces_0_insns_0_cause       (traceIO_traces_0_insns_0_cause),
    .traceIO_traces_0_insns_0_tval        (traceIO_traces_0_insns_0_tval),
`ifdef ETHFMC_USE_BOOM
    .traceIO_traces_0_insns_1_valid       (traceIO_traces_0_insns_1_valid),
    .traceIO_traces_0_insns_1_iaddr       (traceIO_traces_0_insns_1_iaddr),
    .traceIO_traces_0_insns_1_insn        (traceIO_traces_0_insns_1_insn),
    .traceIO_traces_0_insns_1_wdata       (traceIO_traces_0_insns_1_wdata),
    .traceIO_traces_0_insns_1_priv        (traceIO_traces_0_insns_1_priv),
    .traceIO_traces_0_insns_1_exception   (traceIO_traces_0_insns_1_exception),
    .traceIO_traces_0_insns_1_interrupt   (traceIO_traces_0_insns_1_interrupt),
    .traceIO_traces_0_insns_1_cause       (traceIO_traces_0_insns_1_cause),
    .traceIO_traces_0_insns_1_tval        (traceIO_traces_0_insns_1_tval),
`endif

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
    .l2_frontend_bus_axi4_0_aw_bits_lock  (l2_frontend_bus_axi4_0_aw_bits_lock), //unused
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
    .l2_frontend_bus_axi4_0_ar_bits_lock  (l2_frontend_bus_axi4_0_ar_bits_lock), //unused
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
if (ROCKET_ENABLE_TRACE) begin: trace_gen

    wire                            tcu_trace_mem_en;
    wire [ROCKET_MEM_DATA_SIZE-1:0] tcu_trace_mem_rdata;

    //MUX between trace memory and TCU-Rocket interface
    wire tcu_mem_select_trace = (tcu_mem_addr_i >= ROCKET_TRACE_BASEADDR) && (tcu_mem_addr_i < (ROCKET_TRACE_BASEADDR+ROCKET_TRACE_SIZE));

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


    ethernet_fmc_rocket_trace #(
        .ROCKET_TRACE_BASEADDR (ROCKET_TRACE_BASEADDR),
        .ROCKET_TRACE_SIZE     (ROCKET_TRACE_SIZE),
        .ROCKET_MEM_DATA_SIZE  (ROCKET_MEM_DATA_SIZE),
        .ROCKET_MEM_ADDR_SIZE  (ROCKET_MEM_ADDR_SIZE)
    ) i_ethernet_fmc_rocket_trace (
        .clk_i                 (clk_i),
        .reset_n_i             (reset_n_i),

        .trace_enabled_i       (rocket_trace_enabled_i),
        .trace_ptr_o           (rocket_trace_ptr_o),
        .trace_count_o         (rocket_trace_count_o),

        .trace_valid           (traceIO_traces_0_insns_0_valid),
        .trace_iaddr           (traceIO_traces_0_insns_0_iaddr),
        .trace_insn            (traceIO_traces_0_insns_0_insn),
        .trace_priv            (traceIO_traces_0_insns_0_priv),
        .trace_exception       (traceIO_traces_0_insns_0_exception),
        .trace_interrupt       (traceIO_traces_0_insns_0_interrupt),
        .trace_cause           (traceIO_traces_0_insns_0_cause),
        .trace_tval            (traceIO_traces_0_insns_0_tval),

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

    assign rocket_trace_ptr_o = {ROCKET_MEM_ADDR_SIZE{1'b0}};
    assign rocket_trace_count_o = {ROCKET_MEM_ADDR_SIZE{1'b0}};
end
endgenerate




endmodule
