
`include "tcu_defines.vh"

module tcu_ctrl #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_CMDS           = 1,
    parameter TCU_ENABLE_VIRT_ADDR       = 0,
    parameter TCU_ENABLE_VIRT_PES        = 0,
    parameter TCU_ENABLE_DRAM            = 0,
    parameter TCU_ENABLE_LOG             = 0,
    parameter TCU_ENABLE_PRINT           = 0,
    parameter TCU_REGADDR_CORE_REQ_INT   = TCU_REGADDR_CORE_CFG_START + 'h8,
    parameter TCU_REGADDR_TIMER_INT      = TCU_REGADDR_CORE_CFG_START + 'h10,
    parameter HOME_MODID                 = {NOC_MODID_SIZE{1'b0}},
    parameter CLKFREQ_MHZ                = 100,
    parameter [31:0] TIMEOUT_SEND_CYCLES = CLKFREQ_MHZ*2000000,
    parameter [31:0] TIMEOUT_RECV_CYCLES = CLKFREQ_MHZ*1000000
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //NoC IF
    input  wire                          noc_rx_wrreq_i,
    input  wire                          noc_rx_burst_i,
    input  wire      [NOC_BSEL_SIZE-1:0] noc_rx_bsel_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_rx_src_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_rx_src_modid_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_rx_trg_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_rx_trg_modid_i,
    input  wire      [NOC_MODE_SIZE-1:0] noc_rx_mode_i,
    input  wire      [NOC_ADDR_SIZE-1:0] noc_rx_addr_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_rx_data0_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_rx_data1_i,
    output reg                           noc_rx_stall_o,

    output wire                          noc_tx_wrreq_o,
    output wire                          noc_tx_burst_o,
    output wire      [NOC_BSEL_SIZE-1:0] noc_tx_bsel_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_tx_src_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_tx_src_modid_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_tx_trg_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_tx_trg_modid_o,
    output wire      [NOC_MODE_SIZE-1:0] noc_tx_mode_o,
    output wire      [NOC_ADDR_SIZE-1:0] noc_tx_addr_o,
    output wire      [NOC_DATA_SIZE-1:0] noc_tx_data0_o,
    output wire      [NOC_DATA_SIZE-1:0] noc_tx_data1_o,
    input  wire                          noc_tx_stall_i,


    //---------------
    //reg IF
    output reg                     [1:0] reg_en_o,    //Bit 0: standard enable, Bit 1: from extern
    output reg   [TCU_REG_DATA_SIZE-1:0] reg_wben_o,  //bit-wise select
    output reg   [TCU_REG_ADDR_SIZE-1:0] reg_addr_o,
    output reg   [TCU_REG_DATA_SIZE-1:0] reg_wdata_o,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_rdata_i,
    input  wire                          reg_stall_i,

    //---------------
    //Mem IF
    output wire                          mem_en_o,
    output wire                          mem_req_o,
    output wire  [TCU_MEM_BSEL_SIZE-1:0] mem_wben_o,
    output wire  [TCU_MEM_ADDR_SIZE-1:0] mem_addr_o,
    output wire  [TCU_MEM_DATA_SIZE-1:0] mem_wdata_o,
    input  wire  [TCU_MEM_DATA_SIZE-1:0] mem_rdata_i,
    input  wire                          mem_rdata_avail_i, //only used for DRAM access
    input  wire                          mem_wdata_infifo_i,//only used for DRAM access (write data still in FIFO of mem bridge)
    output wire                          mem_wabort_o,      //only used for DRAM access (abort write)
    input  wire                          mem_wstall_i,      //only used if memory has independent r/w ports
    input  wire                          mem_rstall_i,

    //---------------
    //triggers from regs
    input  wire                    [2:0] tcu_fire_i,    //Bit 0: fire TCU (unpriv cmd), Bit 1: ext cmd, Bit 3: priv cmd
    input  wire                   [63:0] tcu_fire_cmd_i,
    input  wire                   [63:0] tcu_fire_data_addr_i,
    input  wire                   [63:0] tcu_fire_data_size_i,
    input  wire                   [63:0] tcu_fire_arg1_i,
    input  wire                   [63:0] tcu_fire_cur_vpe_i,

    //---------------
    //Log IF
    output wire                          tcu_log_en_o,
    output wire  [TCU_LOG_DATA_SIZE-1:0] tcu_log_data_o,
    input  wire  [TCU_LOG_DATA_SIZE-1:0] tcu_log_cur_vpe_i,
    input  wire  [TCU_LOG_DATA_SIZE-1:0] tcu_log_pmp_i,

    //---------------
    //TCU status
    output wire    [TCU_STATUS_SIZE-1:0] tcu_status_o,
    output wire [TCU_FLITCOUNT_SIZE-1:0] noc_error_flit_count_o,
    output wire [TCU_FLITCOUNT_SIZE-1:0] noc_drop_flit_count_o,

    //---------------
    //global TCU reset
    input  wire                          tcu_reset_i,
    input  wire                   [63:0] tcu_cur_time_i,

    //---------------
    //TCU feature settings
    input  wire                          tcu_features_virt_addr_i,
    input  wire                          tcu_features_virt_pes_i,

    //---------------
    //TCU print trigger
    input  wire                          tcu_print_valid_i,

    //---------------
    //Home Chip-ID
    input  wire    [NOC_CHIPID_SIZE-1:0] home_chipid_i,

    //---------------
    //debug print IDs
    input  wire    [NOC_CHIPID_SIZE-1:0] print_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] print_modid_i
);

    `include "tcu_functions.v"

    integer i;

    localparam TCU_ENABLE_PRIV_CMDS = TCU_ENABLE_VIRT_ADDR || TCU_ENABLE_VIRT_PES;

    localparam CTRL_STATES_SIZE              = 5;
    localparam S_CTRL_IDLE                   = 5'h00;
    localparam S_CTRL_MEM_WRITE_READ_INITEP  = 5'h01;
    localparam S_CTRL_MEM_WRITE_WAIT_INITEP  = 5'h02;
    localparam S_CTRL_MEM_WRITE_CHECK_INITEP = 5'h03;
    localparam S_CTRL_MEM_WRITE_TLB_LOOKUP   = 5'h04;
    localparam S_CTRL_MEM_WRITE_TLB_WAIT     = 5'h05;
    localparam S_CTRL_MEM_WRITE_START        = 5'h06;
    localparam S_CTRL_MEM_WRITE              = 5'h07;
    localparam S_CTRL_MEM_READ_READ_INITEP   = 5'h08;
    localparam S_CTRL_MEM_READ_WAIT_INITEP   = 5'h09;
    localparam S_CTRL_MEM_READ_CHECK_INITEP  = 5'h0A;
    localparam S_CTRL_MEM_READ_TLB_LOOKUP    = 5'h0B;
    localparam S_CTRL_MEM_READ_TLB_WAIT      = 5'h0C;
    localparam S_CTRL_MEM_READ_START         = 5'h0D;
    localparam S_CTRL_MEM_READ               = 5'h0E;
    localparam S_CTRL_SEND_MSG_READ_INITEP   = 5'h0F;
    localparam S_CTRL_SEND_MSG_WAIT_INITEP   = 5'h10;
    localparam S_CTRL_SEND_MSG_START         = 5'h11;
    localparam S_CTRL_SEND_MSG               = 5'h12;
    localparam S_CTRL_FETCH_MSG_READ_INITEP  = 5'h13;
    localparam S_CTRL_FETCH_MSG_WAIT_INITEP  = 5'h14;
    localparam S_CTRL_FETCH_MSG              = 5'h15;
    localparam S_CTRL_REPLY_MSG_READ_INITEP  = 5'h16;
    localparam S_CTRL_REPLY_MSG_WAIT_INITEP  = 5'h17;
    localparam S_CTRL_REPLY_MSG_START        = 5'h18;
    localparam S_CTRL_REPLY_MSG              = 5'h19;
    localparam S_CTRL_ACK_MSG_READ_INITEP    = 5'h1A;
    localparam S_CTRL_ACK_MSG_WAIT_INITEP    = 5'h1B;
    localparam S_CTRL_ACK_MSG                = 5'h1C;
    localparam S_CTRL_FINISH                 = 5'h1F;

    localparam CTRL_EXT_STATES_SIZE          = 3;
    localparam S_CTRL_EXT_IDLE               = 3'h0;
    localparam S_CTRL_EXT_INVEP_READ_INITEP  = 3'h1;
    localparam S_CTRL_EXT_INVEP_WAIT_INITEP  = 3'h2;
    localparam S_CTRL_EXT_INVEP              = 3'h3;
    localparam S_CTRL_EXT_FINISH             = 3'h7;

    localparam NOC_STATES_SIZE               = 4;
    localparam S_NOC_IDLE                    = 4'h0;
    localparam S_NOC_TCU_REG_WRITE           = 4'h1;
    localparam S_NOC_MEM_WRITE_PAUSE         = 4'h2;
    localparam S_NOC_MEM_WRITE               = 4'h3;
    localparam S_NOC_RSP_PREPARE             = 4'h4;
    localparam S_NOC_RSP                     = 4'h5;
    localparam S_NOC_RECEIVE_MSG_WAIT        = 4'h6;
    localparam S_NOC_RECEIVE_MSG_PAUSE       = 4'h7;
    localparam S_NOC_RECEIVE_MSG             = 4'h8;
    localparam S_NOC_RECV_ACK                = 4'h9;

    reg [NOC_STATES_SIZE-1:0] noc_state, next_noc_state;

    
    //select upper or lower 128 bit
    reg r_tmp_addr_align;
    reg r_tmp_addr_align_inreg, rin_tmp_addr_align_inreg;

    reg                      r_write_ack_recv, rin_write_ack_recv;
    reg                      r_msg_ack_recv, rin_msg_ack_recv;
    reg                      r_rsp_recv, rin_rsp_recv;
    reg [TCU_ERROR_SIZE-1:0] r_rsp_error, rin_rsp_error;
    reg               [31:0] r_rsp_size, rin_rsp_size;
    reg                      r_rsp_abort, rin_rsp_abort;

    //trigger for NoC packets
    reg r_start_noc_recv;

    reg [TCU_EP_SIZE-1:0] r_tmp_recvep, rin_tmp_recvep;


    //reg stage for outgoing NoC packet
    reg                       r_noc_tx_wrreq, rin_noc_tx_wrreq;
    reg                       r_noc_tx_burst, rin_noc_tx_burst;
    reg   [NOC_BSEL_SIZE-1:0] r_noc_tx_bsel, rin_noc_tx_bsel;
    reg   [NOC_MODE_SIZE-1:0] r_noc_tx_mode, rin_noc_tx_mode;
    reg [NOC_CHIPID_SIZE-1:0] r_noc_tx_trg_chipid, rin_noc_tx_trg_chipid;
    reg  [NOC_MODID_SIZE-1:0] r_noc_tx_trg_modid, rin_noc_tx_trg_modid;
    reg   [NOC_ADDR_SIZE-1:0] r_noc_tx_addr, rin_noc_tx_addr;
    reg   [NOC_DATA_SIZE-1:0] r_noc_tx_data0, rin_noc_tx_data0;
    reg   [NOC_DATA_SIZE-1:0] r_noc_tx_data1, rin_noc_tx_data1;


    //temp. store data from TCU reg or mem if NoC is stalled from outside
    reg                       r_noc_rx_burst;//, rin_noc_rx_burst;
    reg   [NOC_BSEL_SIZE-1:0] r_noc_rx_bsel, rin_noc_rx_bsel;
    reg   [NOC_MODE_SIZE-1:0] r_noc_rx_mode, rin_noc_rx_mode;
    reg [NOC_CHIPID_SIZE-1:0] r_noc_rx_chipid, rin_noc_rx_chipid;
    reg  [NOC_MODID_SIZE-1:0] r_noc_rx_modid, rin_noc_rx_modid;
    reg   [NOC_ADDR_SIZE-1:0] r_noc_rx_addr, rin_noc_rx_addr;
    reg   [NOC_ADDR_SIZE-1:0] r_noc_rx_retaddr, rin_noc_rx_retaddr;
    reg                [31:0] r_noc_rx_read_size, rin_noc_rx_read_size;
    reg   [NOC_DATA_SIZE-1:0] r_noc_rx_data0, rin_noc_rx_data0;
    reg   [NOC_DATA_SIZE-1:0] r_noc_rx_data1, rin_noc_rx_data1;
    reg   [NOC_DATA_SIZE-1:0] r2_noc_rx_data0;
    reg   [NOC_DATA_SIZE-1:0] r2_noc_rx_data1;

    //number of error and dropped incoming NoC flits
    //dropped flits must not be an error if they are handled corretly
    reg [TCU_FLITCOUNT_SIZE-1:0] r_noc_error_flit_count, rin_noc_error_flit_count;
    reg [TCU_FLITCOUNT_SIZE-1:0] r_noc_drop_flit_count, rin_noc_drop_flit_count;


    //mem reg
    reg                    [1:0] r_mem_en, rin_mem_en;
    reg  [TCU_MEM_BSEL_SIZE-1:0] r_mem_wben, rin_mem_wben;
    reg  [TCU_MEM_ADDR_SIZE-1:0] r_mem_addr, rin_mem_addr;
    reg  [TCU_MEM_DATA_SIZE-1:0] r_mem_wdata, rin_mem_wdata;
    reg  [TCU_MEM_DATA_SIZE-1:0] r_mem_rdata, rin_mem_rdata;
    reg                          r_mem_wstall;

    reg                          r_mas_mem_rdata_inreg, rin_mas_mem_rdata_inreg;
    reg                          r_sm_mem_rdata_inreg, rin_sm_mem_rdata_inreg;
    reg                          r_rpm_mem_rdata_inreg, rin_rpm_mem_rdata_inreg;


    //---------------
    //signals of NoC request module
    reg                       r_reqfifo_push, rin_reqfifo_push;

    wire   [NOC_ADDR_SIZE-1:0] reqfifo_addr;
    wire   [NOC_ADDR_SIZE-1:0] reqfifo_retaddr;
    wire                [31:0] reqfifo_read_size;
    wire   [NOC_BSEL_SIZE-1:0] reqfifo_bsel;
    wire [NOC_CHIPID_SIZE-1:0] reqfifo_chipid;
    wire  [NOC_MODID_SIZE-1:0] reqfifo_modid;
    wire   [NOC_MODE_SIZE-1:0] reqfifo_mode;
    wire                       reqfifo_full;

    wire                         noc_req_start_noc_send;
    wire                         noc_req_reg_en;
    wire [TCU_REG_DATA_SIZE-1:0] noc_req_reg_retdata;
    wire                         noc_req_done;

    //---------------
    //sync reset
    //synopsys sync_set_reset "reset_ctrl_n"
    wire reset_ctrl_n;


    //---------------
    //identify which FSM accesses regs or mem
    wire ctrl_mem_access;
    wire ctrl_reg_access;
    wire ctrl_ext_reg_access;
    wire ctrl_priv_reg_access;
    wire receive_active;
    wire send_active;


    //---------------
    //wires to assign regs from generate
    wire     [CTRL_STATES_SIZE-1:0] ctrl_state_s;
    wire [CTRL_EXT_STATES_SIZE-1:0] ctrl_ext_state_s;
    
    wire                       tcu_fire_cmd_active;
    wire                       tcu_fire_ext_active;

    wire                       firecmd_start;
    wire                       firecmd_ext_start;
    wire [TCU_CHIPID_SIZE-1:0] firecmd_recvchip;
    wire   [TCU_PEID_SIZE-1:0] firecmd_recvpe;

    wire    [TCU_ERROR_SIZE-1:0] error_type;
    wire    [TCU_ERROR_SIZE-1:0] error_ext_type;
    wire  [TCU_EXT_ARG_SIZE-1:0] ext_arg;

    wire start_recv_msg_s;
    

    //---------------
    //interface from mem_access_send
    wire                   [1:0] mas_mem_en;
    wire [TCU_MEM_ADDR_SIZE-1:0] mas_mem_addr;
    wire                         mas_mem_rdata_valid;
    wire [TCU_MEM_DATA_SIZE-1:0] mas_mem_wdata;

    wire                         mas_noc_wrreq;
    wire                         mas_noc_burst;
    wire     [NOC_BSEL_SIZE-1:0] mas_noc_bsel;
    reg      [NOC_BSEL_SIZE-1:0] r_mas_noc_bsel, rin_mas_noc_bsel;
    wire     [NOC_DATA_SIZE-1:0] mas_noc_data0;
    wire     [NOC_ADDR_SIZE-1:0] mas_noc_addr;
    reg      [NOC_ADDR_SIZE-1:0] r_mas_noc_addr, rin_mas_noc_addr;
    wire     [NOC_MODE_SIZE-1:0] mas_noc_mode;
    wire   [NOC_CHIPID_SIZE-1:0] mas_noc_chipid;
    wire    [NOC_MODID_SIZE-1:0] mas_noc_modid;

    wire                         mas_done;
    wire                         mas_active;
    wire                         mas_noc_active;
    wire    [TCU_ERROR_SIZE-1:0] mas_error;

    wire                         mas_start;
    wire   [TCU_OPCODE_SIZE-1:0] mas_opcode;
    wire                  [31:0] mas_laddr;
    wire                  [31:0] mas_raddr;
    wire                  [31:0] mas_size;
    wire   [NOC_CHIPID_SIZE-1:0] mas_chipid;
    wire    [NOC_MODID_SIZE-1:0] mas_modid;

    //---------------
    //interface from mem_access_request
    wire                         marq_noc_wrreq;
    wire     [NOC_DATA_SIZE-1:0] marq_noc_data0;
    wire     [NOC_ADDR_SIZE-1:0] marq_noc_addr;
    wire   [NOC_CHIPID_SIZE-1:0] marq_noc_chipid;
    wire    [NOC_MODID_SIZE-1:0] marq_noc_modid;

    wire                         marq_done;
    wire                         marq_active;
    wire                         marq_noc_active;
    wire    [TCU_ERROR_SIZE-1:0] marq_error;

    wire                         marq_read_wait;
    wire                         marq_start;
    wire   [TCU_OPCODE_SIZE-1:0] marq_opcode;
    wire                  [31:0] marq_laddr;
    wire                  [31:0] marq_raddr;
    wire                  [31:0] marq_size;
    wire   [NOC_CHIPID_SIZE-1:0] marq_chipid;
    wire    [NOC_MODID_SIZE-1:0] marq_modid;
    

    //---------------
    //interface from mem_access_recv
    wire                   [2:0] mar_mem_en;
    wire [TCU_MEM_BSEL_SIZE-1:0] mar_mem_wben;
    wire [TCU_MEM_ADDR_SIZE-1:0] mar_mem_addr;
    wire [TCU_MEM_DATA_SIZE-1:0] mar_mem_wdata;
    wire                         mar_mem_wabort;

    wire                         mar_noc_fifo_pop;

    wire                         mar_noc_wrreq;
    wire   [NOC_CHIPID_SIZE-1:0] mar_noc_chipid;
    wire    [NOC_MODID_SIZE-1:0] mar_noc_modid;
    wire     [NOC_ADDR_SIZE-1:0] mar_noc_addr;
    wire                  [31:0] mar_noc_data;

    wire                         mar_done;
    wire                         mar_active;
    wire                   [3:0] mar_shift;
    wire    [TCU_ERROR_SIZE-1:0] mar_error;

    //---------------
    //interface from send_msg
    wire                   [1:0] sm_mem_en;
    wire [TCU_MEM_ADDR_SIZE-1:0] sm_mem_addr;
    wire                         sm_mem_rdata_valid;
    wire [TCU_MEM_DATA_SIZE-1:0] sm_mem_wdata;

    wire                         sm_reg_en;
    wire [TCU_REG_DATA_SIZE-1:0] sm_reg_wben;
    wire [TCU_REG_ADDR_SIZE-1:0] sm_reg_addr;
    wire [TCU_REG_DATA_SIZE-1:0] sm_reg_wdata;

    wire                         sm_tlb_read;

    wire                         sm_noc_wrreq;
    wire                         sm_noc_burst;
    wire     [NOC_BSEL_SIZE-1:0] sm_noc_bsel;
    wire     [NOC_DATA_SIZE-1:0] sm_noc_data0;
    wire     [NOC_DATA_SIZE-1:0] sm_noc_data1;
    wire     [NOC_ADDR_SIZE-1:0] sm_noc_addr;
    wire     [NOC_MODE_SIZE-1:0] sm_noc_mode;
    wire   [NOC_CHIPID_SIZE-1:0] sm_noc_chipid;
    wire    [NOC_MODID_SIZE-1:0] sm_noc_modid;
    
    wire                         sm_done;
    wire                         sm_active;
    wire                         sm_noc_active;
    wire    [TCU_ERROR_SIZE-1:0] sm_error;


    //---------------
    //interface from recv_msg
    wire                   [2:0] rm_mem_en;
    wire [TCU_MEM_BSEL_SIZE-1:0] rm_mem_wben;
    wire [TCU_MEM_ADDR_SIZE-1:0] rm_mem_addr;
    wire [TCU_MEM_DATA_SIZE-1:0] rm_mem_wdata;
    wire                         rm_mem_wabort;

    wire                         rm_reg_en;
    wire [TCU_REG_DATA_SIZE-1:0] rm_reg_wben;
    wire [TCU_REG_ADDR_SIZE-1:0] rm_reg_addr;
    wire [TCU_REG_DATA_SIZE-1:0] rm_reg_wdata;
    
    wire                         rm_noc_fifo_pop;
    wire                         rm_noc_wrreq;
    wire     [NOC_DATA_SIZE-1:0] rm_noc_data;
    wire     [NOC_ADDR_SIZE-1:0] rm_noc_addr;
    wire   [NOC_CHIPID_SIZE-1:0] rm_noc_chipid;
    wire    [NOC_MODID_SIZE-1:0] rm_noc_modid;

    wire                         rm_done;
    wire                         rm_active;
    wire                         rm_cur_vpe_active;
    wire                         rm_crd_update_active;

    wire                                rm_core_req_push;
    wire [TCU_CORE_REQ_FORMSG_SIZE-1:0] rm_core_req_data;
    wire                                rm_core_req_stall;

    wire [TCU_LOG_DATA_SIZE-1:0] tcu_log_rm;

    //---------------
    //interface from fetch_msg
    wire                         fm_reg_en;
    wire [TCU_REG_DATA_SIZE-1:0] fm_reg_wben;
    wire [TCU_REG_ADDR_SIZE-1:0] fm_reg_addr;
    wire [TCU_REG_DATA_SIZE-1:0] fm_reg_wdata;

    wire                         fm_fetch_success;
    wire                  [31:0] fm_msgoffset;
    wire                         fm_done;
    wire                         fm_active;
    wire    [TCU_ERROR_SIZE-1:0] fm_error;


    //---------------
    //interface from ext_invep
    wire                         ext_invep_reg_en;
    wire [TCU_REG_ADDR_SIZE-1:0] ext_invep_reg_addr;
    wire [TCU_REG_DATA_SIZE-1:0] ext_invep_reg_wdata;

    wire                         ext_invep_done;
    wire                         ext_invep_active;      //this stall is not evaluated
    wire    [TCU_ERROR_SIZE-1:0] ext_invep_error;
    wire  [TCU_EXT_ARG_SIZE-1:0] ext_invep_arg;


    //---------------
    //interface from priv cmds
    wire                         priv_reg_en;
    wire [TCU_REG_BSEL_SIZE-1:0] priv_reg_wben;
    wire [TCU_REG_ADDR_SIZE-1:0] priv_reg_addr;
    wire [TCU_REG_DATA_SIZE-1:0] priv_reg_wdata;


    //---------------
    //TLB read data
    wire [TCU_TLB_PHYSPAGE_SIZE-1:0] unpriv_tlb_physpage;
    wire                             unpriv_tlb_active;
    wire                             unpriv_tlb_read_done;
    wire        [TCU_ERROR_SIZE-1:0] unpriv_tlb_read_error;

    wire                             unpriv_write_abort;
    wire                             unpriv_read_abort;
    wire                             unpriv_send_abort;
    wire                             unpriv_reply_abort;
    

    //---------------
    //interface from reply_msg
    wire                   [1:0] rpm_mem_en;
    wire [TCU_MEM_ADDR_SIZE-1:0] rpm_mem_addr;
    wire                         rpm_mem_rdata_valid;
    wire [TCU_MEM_DATA_SIZE-1:0] rpm_mem_wdata;

    wire                         rpm_reg_en;
    wire [TCU_REG_DATA_SIZE-1:0] rpm_reg_wben;
    wire [TCU_REG_ADDR_SIZE-1:0] rpm_reg_addr;
    wire [TCU_REG_DATA_SIZE-1:0] rpm_reg_wdata;

    wire                         rpm_tlb_read;

    wire                         rpm_noc_wrreq;
    wire                         rpm_noc_burst;
    wire     [NOC_BSEL_SIZE-1:0] rpm_noc_bsel;
    wire     [NOC_DATA_SIZE-1:0] rpm_noc_data0;
    wire     [NOC_DATA_SIZE-1:0] rpm_noc_data1;
    wire     [NOC_ADDR_SIZE-1:0] rpm_noc_addr;
    wire     [NOC_MODE_SIZE-1:0] rpm_noc_mode;
    wire   [NOC_CHIPID_SIZE-1:0] rpm_noc_chipid;
    wire    [NOC_MODID_SIZE-1:0] rpm_noc_modid;

    wire                         rpm_log_valid;
    wire   [TCU_CHIPID_SIZE-1:0] rpm_log_rpl_chip;
    wire     [TCU_PEID_SIZE-1:0] rpm_log_rpl_pe;

    wire                         rpm_done;
    wire                         rpm_active;
    wire                         rpm_noc_active;
    wire    [TCU_ERROR_SIZE-1:0] rpm_error;


    //---------------
    //interface from ack_msg
    wire                         am_reg_en;
    wire [TCU_REG_DATA_SIZE-1:0] am_reg_wben;
    wire [TCU_REG_ADDR_SIZE-1:0] am_reg_addr;
    wire [TCU_REG_DATA_SIZE-1:0] am_reg_wdata;
    
    wire                         am_done;
    wire                         am_active;
    wire    [TCU_ERROR_SIZE-1:0] am_error;


    //---------------
    //interface for logging
    wire [TCU_LOG_DATA_SIZE-1:0] tcu_log_unpriv_data_s;
    wire [TCU_LOG_DATA_SIZE-1:0] tcu_log_ext_data_s;
    reg  [TCU_LOG_DATA_SIZE-1:0] tcu_log_noc_data;


    //---------------
    //split unpriv command reg
    wire   [TCU_OPCODE_SIZE-1:0] cmd_cmd_op   = tcu_fire_cmd_i[TCU_OPCODE_SIZE-1 : 0];
    wire       [TCU_EP_SIZE-1:0] cmd_cmd_ep   = tcu_fire_cmd_i[TCU_EP_SIZE+TCU_OPCODE_SIZE-1 : TCU_OPCODE_SIZE];
    wire    [TCU_ERROR_SIZE-1:0] cmd_cmd_err  = tcu_fire_cmd_i[TCU_ERROR_SIZE+TCU_EP_SIZE+TCU_OPCODE_SIZE-1 : TCU_EP_SIZE+TCU_OPCODE_SIZE];
    wire     [TCU_ARG0_SIZE-1:0] cmd_cmd_arg0 = tcu_fire_cmd_i[TCU_ARG0_SIZE+TCU_ERROR_SIZE+TCU_EP_SIZE+TCU_OPCODE_SIZE-1 : TCU_ERROR_SIZE+TCU_EP_SIZE+TCU_OPCODE_SIZE];

    //split external command reg
    wire   [TCU_OPCODE_SIZE-1:0] cmd_ext_op   = tcu_fire_cmd_i[TCU_OPCODE_SIZE-1 : 0];
    wire    [TCU_ERROR_SIZE-1:0] cmd_ext_err  = tcu_fire_cmd_i[TCU_ERROR_SIZE+TCU_OPCODE_SIZE-1 : TCU_OPCODE_SIZE];
    wire  [TCU_EXT_ARG_SIZE-1:0] cmd_ext_arg  = tcu_fire_cmd_i[TCU_EXT_ARG_SIZE+TCU_ERROR_SIZE+TCU_OPCODE_SIZE-1 : TCU_ERROR_SIZE+TCU_OPCODE_SIZE];

    //split priv command reg
    wire   [TCU_OPCODE_SIZE-1:0] cmd_priv_op  = tcu_fire_cmd_i[TCU_OPCODE_SIZE-1 : 0];
    wire    [TCU_ERROR_SIZE-1:0] cmd_priv_err = tcu_fire_cmd_i[TCU_ERROR_SIZE+TCU_OPCODE_SIZE-1 : TCU_OPCODE_SIZE];
    wire [TCU_PRIV_ARG_SIZE-1:0] cmd_priv_arg = tcu_fire_cmd_i[TCU_PRIV_ARG_SIZE+TCU_ERROR_SIZE+TCU_OPCODE_SIZE-1 : TCU_ERROR_SIZE+TCU_OPCODE_SIZE];


    //---------------
    //interface to state machine for reading initial ep
    wire                         read_initep_reg_en;
    wire [TCU_REG_ADDR_SIZE-1:0] read_initep_reg_addr;
    wire                         read_initep_active;
    wire                         read_initep_start_s;


    //---------------
    //interface to debug print
    wire                         print_reg_en;
    wire [TCU_REG_BSEL_SIZE-1:0] print_reg_wben;
    wire [TCU_REG_ADDR_SIZE-1:0] print_reg_addr;
    wire                         print_active;

    wire                         print_noc_wrreq;
    wire                         print_noc_burst;
    wire     [NOC_BSEL_SIZE-1:0] print_noc_bsel;
    wire   [NOC_CHIPID_SIZE-1:0] print_noc_chipid;
    wire    [NOC_MODID_SIZE-1:0] print_noc_modid;
    wire     [NOC_DATA_SIZE-1:0] print_noc_data0;
    wire     [NOC_DATA_SIZE-1:0] print_noc_data1;



    assign tcu_status_o = {{(8-CTRL_EXT_STATES_SIZE){1'b0}}, ctrl_ext_state_s,
                            {(8-CTRL_STATES_SIZE){1'b0}}, ctrl_state_s,
                            {(8-NOC_STATES_SIZE){1'b0}}, noc_state,
                            am_active, fm_active, rpm_active, rm_active, sm_active, marq_active, mar_active, mas_active};



    always @(posedge clk_i) begin
        if (reset_ctrl_n == 1'b0) begin
            noc_state <= S_NOC_IDLE;

            r_tmp_addr_align <= 1'b0;
            r_tmp_addr_align_inreg <= 1'b0;

            r_write_ack_recv <= 1'b0;
            r_msg_ack_recv <= 1'b0;
            r_rsp_recv <= 1'b0;
            r_rsp_error <= TCU_ERROR_NONE;
            r_rsp_size <= 32'h0;
            r_rsp_abort <= 1'b0;

            r_start_noc_recv <= 1'b0;

            r_noc_rx_burst <= 1'b0;

            r_tmp_recvep <= {TCU_EP_SIZE{1'b0}};

            r_mas_noc_bsel <= {NOC_BSEL_SIZE{1'b0}};
            r_mas_noc_addr <= {NOC_ADDR_SIZE{1'b0}};

            r_noc_tx_wrreq      <= 1'b0;
            r_noc_tx_burst      <= 1'b0;
            r_noc_tx_bsel       <= {NOC_BSEL_SIZE{1'b0}};
            r_noc_tx_mode       <= {NOC_MODE_SIZE{1'b0}};
            r_noc_tx_trg_chipid <= {NOC_CHIPID_SIZE{1'b0}};
            r_noc_tx_trg_modid  <= {NOC_MODID_SIZE{1'b0}};
            r_noc_tx_addr       <= {NOC_ADDR_SIZE{1'b0}};
            r_noc_tx_data0      <= {NOC_DATA_SIZE{1'b0}};
            r_noc_tx_data1      <= {NOC_DATA_SIZE{1'b0}};

            r_noc_rx_bsel      <= {NOC_BSEL_SIZE{1'b0}};
            r_noc_rx_mode      <= {NOC_MODE_SIZE{1'b0}};
            r_noc_rx_chipid    <= {NOC_CHIPID_SIZE{1'b0}};
            r_noc_rx_modid     <= {NOC_MODID_SIZE{1'b0}};
            r_noc_rx_addr      <= {NOC_ADDR_SIZE{1'b0}};
            r_noc_rx_retaddr   <= {NOC_ADDR_SIZE{1'b0}};
            r_noc_rx_read_size <= 32'h0;
            r_noc_rx_data0     <= {NOC_DATA_SIZE{1'b0}};
            r_noc_rx_data1     <= {NOC_DATA_SIZE{1'b0}};
            r2_noc_rx_data0    <= {NOC_DATA_SIZE{1'b0}};
            r2_noc_rx_data1    <= {NOC_DATA_SIZE{1'b0}};

            r_noc_error_flit_count <= {TCU_FLITCOUNT_SIZE{1'b0}};
            r_noc_drop_flit_count <= {TCU_FLITCOUNT_SIZE{1'b0}};

            r_mem_en     <= 2'b00;
            r_mem_wben   <= {TCU_MEM_BSEL_SIZE{1'b0}};
            r_mem_addr   <= {TCU_MEM_ADDR_SIZE{1'b0}};
            r_mem_wdata  <= {TCU_MEM_DATA_SIZE{1'b0}};
            r_mem_rdata  <= {TCU_MEM_DATA_SIZE{1'b0}};
            r_mem_wstall <= 1'b0;

            r_mas_mem_rdata_inreg <= 1'b0;
            r_sm_mem_rdata_inreg  <= 1'b0;
            r_rpm_mem_rdata_inreg <= 1'b0;

            r_reqfifo_push <= 1'b0;
        end
        else begin
            noc_state <= next_noc_state;

            r_tmp_addr_align <= mem_addr_o[3];
            r_tmp_addr_align_inreg <= rin_tmp_addr_align_inreg;

            r_write_ack_recv <= rin_write_ack_recv;
            r_msg_ack_recv <= rin_msg_ack_recv;
            r_rsp_recv <= rin_rsp_recv;
            r_rsp_error <= rin_rsp_error;
            r_rsp_size <= rin_rsp_size;
            r_rsp_abort <= rin_rsp_abort;

            r_start_noc_recv <= (noc_state == S_NOC_MEM_WRITE_PAUSE) && !mar_active;

            r_noc_rx_burst <= (noc_rx_wrreq_i && !noc_rx_stall_o) ? noc_rx_burst_i : r_noc_rx_burst;

            r_tmp_recvep <= rin_tmp_recvep;

            r_mas_noc_bsel <= rin_mas_noc_bsel;
            r_mas_noc_addr <= rin_mas_noc_addr;

            r_noc_tx_wrreq      <= rin_noc_tx_wrreq;
            r_noc_tx_burst      <= rin_noc_tx_burst;
            r_noc_tx_bsel       <= rin_noc_tx_bsel;
            r_noc_tx_mode       <= rin_noc_tx_mode;
            r_noc_tx_trg_chipid <= rin_noc_tx_trg_chipid;
            r_noc_tx_trg_modid  <= rin_noc_tx_trg_modid;
            r_noc_tx_addr       <= rin_noc_tx_addr;
            r_noc_tx_data0      <= rin_noc_tx_data0;
            r_noc_tx_data1      <= rin_noc_tx_data1;

            r_noc_rx_bsel      <= rin_noc_rx_bsel;
            r_noc_rx_mode      <= rin_noc_rx_mode;
            r_noc_rx_chipid    <= rin_noc_rx_chipid;
            r_noc_rx_modid     <= rin_noc_rx_modid;
            r_noc_rx_addr      <= rin_noc_rx_addr;
            r_noc_rx_retaddr   <= rin_noc_rx_retaddr;
            r_noc_rx_read_size <= rin_noc_rx_read_size;
            r_noc_rx_data0     <= rin_noc_rx_data0;
            r_noc_rx_data1     <= rin_noc_rx_data1;
            r2_noc_rx_data0    <= r_noc_rx_data0;
            r2_noc_rx_data1    <= r_noc_rx_data1;

            r_noc_error_flit_count <= rin_noc_error_flit_count;
            r_noc_drop_flit_count <= rin_noc_drop_flit_count;

            r_mem_en     <= rin_mem_en;
            r_mem_wben   <= rin_mem_wben;
            r_mem_addr   <= rin_mem_addr;
            r_mem_wdata  <= rin_mem_wdata;
            r_mem_rdata  <= rin_mem_rdata;
            r_mem_wstall <= mem_wstall_i;

            r_mas_mem_rdata_inreg <= rin_mas_mem_rdata_inreg;
            r_sm_mem_rdata_inreg  <= rin_sm_mem_rdata_inreg;
            r_rpm_mem_rdata_inreg <= rin_rpm_mem_rdata_inreg;

            r_reqfifo_push <= rin_reqfifo_push;
        end
    end




    generate
    if (TCU_ENABLE_CMDS) begin: CMD_CTRL
        reg     [CTRL_STATES_SIZE-1:0] ctrl_state, next_ctrl_state;
        reg [CTRL_EXT_STATES_SIZE-1:0] ctrl_ext_state, next_ctrl_ext_state;

        reg                            r_firecmd_start, rin_firecmd_start;           //indicate start of unpriv TCU command
        reg                            r_firecmd_ext_start, rin_firecmd_ext_start;   //indicate start of ext TCU command
        
        reg      [TCU_OPCODE_SIZE-1:0] r_firecmd_opcode, rin_firecmd_opcode;
        reg      [TCU_OPCODE_SIZE-1:0] r_firecmd_ext_opcode, rin_firecmd_ext_opcode;
        
        reg          [TCU_EP_SIZE-1:0] r_firecmd_ep, rin_firecmd_ep;                 //currently used ep for command
        reg          [TCU_EP_SIZE-1:0] r_firecmd_replyep, rin_firecmd_replyep;
        reg                     [63:0] r_firecmd_data_addr, rin_firecmd_data_addr;
        reg                     [63:0] r_firecmd_data_size, rin_firecmd_data_size;
        reg                      [1:0] r_firecmd_perm, rin_firecmd_perm;
        reg                     [31:0] r_firecmd_msgoffset, rin_firecmd_msgoffset;
        reg                     [31:0] r_firecmd_recvaddr, rin_firecmd_recvaddr;
        reg      [TCU_CHIPID_SIZE-1:0] r_firecmd_recvchip, rin_firecmd_recvchip;
        reg        [TCU_PEID_SIZE-1:0] r_firecmd_recvpe, rin_firecmd_recvpe;
        reg                     [63:0] r_firecmd_replylabel, rin_firecmd_replylabel;
        reg     [TCU_EXT_ARG_SIZE-1:0] r_firecmd_ext_arg, rin_firecmd_ext_arg;

        reg       [TCU_ERROR_SIZE-1:0] r_error_type, rin_error_type;
        reg       [TCU_ERROR_SIZE-1:0] r_error_ext_type, rin_error_ext_type;
        reg     [TCU_EXT_ARG_SIZE-1:0] r_ext_arg, rin_ext_arg;


        //reg interface to read intial ep
        reg                            read_initep_start;
        reg                            read_initep_ext_start;
        wire                           read_initep_done;


        //access from unpriv cmds to TLB
        reg                            unpriv_tlb_read;


        //trigger for receive message
        wire start_recv_msg = (noc_state == S_NOC_RECEIVE_MSG_PAUSE) && !rm_active;
        reg r_start_recv_msg;

        //logging
        reg [TCU_LOG_DATA_SIZE-1:0] tcu_log_unpriv_data;
        reg [TCU_LOG_DATA_SIZE-1:0] tcu_log_ext_data;

        wire [63:0] epdata_0;
        wire [63:0] epdata_1;
        wire [63:0] epdata_2;


        //---------------
        //ep type is at same position for all ep types
        wire [TCU_EP_TYPE_SIZE-1:0] ep_type      = epdata_0[TCU_EP_TYPE_SIZE-1:0];

        //if ep is interpreted as memory ep
        wire   [TCU_VPEID_SIZE-1:0] mep_vpe      = epdata_0[TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_TYPE_SIZE];
        wire [TCU_MEMFLAG_SIZE-1:0] mep_memflag  = epdata_0[TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
        wire    [TCU_PEID_SIZE-1:0] mep_pe       = epdata_0[TCU_PEID_SIZE+TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
        wire  [TCU_CHIPID_SIZE-1:0] mep_chip     = epdata_0[TCU_CHIPID_SIZE+TCU_PEID_SIZE+TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_PEID_SIZE+TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];   //TODO: correct?
        wire                 [63:0] mep_addr     = epdata_1;
        wire                 [63:0] mep_size     = epdata_2;


        always @(posedge clk_i) begin
            if (reset_ctrl_n == 1'b0) begin
                ctrl_state <= S_CTRL_IDLE;
                ctrl_ext_state <= S_CTRL_EXT_IDLE;

                r_firecmd_start <= 1'b0;
                r_firecmd_ext_start <= 1'b0;

                r_firecmd_opcode <= {TCU_OPCODE_SIZE{1'b0}};
                r_firecmd_ext_opcode <= {TCU_OPCODE_SIZE{1'b0}};

                r_firecmd_ep         <= {TCU_EP_SIZE{1'b0}};
                r_firecmd_replyep    <= {TCU_EP_SIZE{1'b0}};
                r_firecmd_data_addr  <= 64'h0;
                r_firecmd_data_size  <= 64'h0;
                r_firecmd_perm       <= 2'h0;
                r_firecmd_msgoffset  <= 32'h0;
                r_firecmd_recvaddr   <= 32'h0;
                r_firecmd_recvchip   <= {TCU_CHIPID_SIZE{1'b0}};
                r_firecmd_recvpe     <= {TCU_PEID_SIZE{1'b0}};
                r_firecmd_replylabel <= 64'h0;
                r_firecmd_ext_arg    <= {TCU_EXT_ARG_SIZE{1'b0}};

                r_error_type <= {TCU_ERROR_SIZE{1'b0}};
                r_error_ext_type <= {TCU_ERROR_SIZE{1'b0}};
                r_ext_arg <= {TCU_EXT_ARG_SIZE{1'b0}};

                r_start_recv_msg <= 1'b0;
            end
            else begin
                ctrl_state <= next_ctrl_state;
                ctrl_ext_state <= next_ctrl_ext_state;

                r_firecmd_start <= rin_firecmd_start;
                r_firecmd_ext_start <= rin_firecmd_ext_start;

                r_firecmd_opcode <= rin_firecmd_opcode;
                r_firecmd_ext_opcode <= rin_firecmd_ext_opcode;

                r_firecmd_ep         <= rin_firecmd_ep;
                r_firecmd_replyep    <= rin_firecmd_replyep;
                r_firecmd_data_addr  <= rin_firecmd_data_addr;
                r_firecmd_data_size  <= rin_firecmd_data_size;
                r_firecmd_perm       <= rin_firecmd_perm;
                r_firecmd_msgoffset  <= rin_firecmd_msgoffset;
                r_firecmd_recvaddr   <= rin_firecmd_recvaddr;
                r_firecmd_recvchip   <= rin_firecmd_recvchip;
                r_firecmd_recvpe     <= rin_firecmd_recvpe;
                r_firecmd_replylabel <= rin_firecmd_replylabel;
                r_firecmd_ext_arg    <= rin_firecmd_ext_arg;

                r_error_type <= rin_error_type;
                r_error_ext_type <= rin_error_ext_type;
                r_ext_arg <= rin_ext_arg;

                r_start_recv_msg <= start_recv_msg;
            end
        end
    
        assign ctrl_state_s = ctrl_state;
        assign ctrl_ext_state_s = ctrl_ext_state;

        assign mas_start  = r_firecmd_start ? 1'b1 : noc_req_start_noc_send;
        assign mas_opcode = r_firecmd_start ? r_firecmd_opcode : ((reqfifo_mode == MODE_READ_REQ_2) ? TCU_OPCODE_WRITE_RSP_2 : TCU_OPCODE_WRITE_RSP);
        assign mas_laddr  = r_firecmd_start ? r_firecmd_data_addr[31:0] : reqfifo_addr;
        assign mas_raddr  = r_firecmd_start ? r_firecmd_recvaddr : reqfifo_retaddr;
        assign mas_size   = r_firecmd_start ? r_firecmd_data_size[31:0] : reqfifo_read_size;
        assign mas_chipid = r_firecmd_start ? r_firecmd_recvchip : reqfifo_chipid;
        assign mas_modid  = r_firecmd_start ? r_firecmd_recvpe : reqfifo_modid;

        assign marq_start  = r_firecmd_start;
        assign marq_opcode = r_firecmd_opcode;
        assign marq_laddr  = r_firecmd_data_addr;
        assign marq_raddr  = r_firecmd_recvaddr;
        assign marq_size   = r_firecmd_data_size;
        assign marq_chipid = r_firecmd_recvchip;
        assign marq_modid  = r_firecmd_recvpe;

        assign tcu_fire_cmd_active = (ctrl_state != S_CTRL_IDLE);
        assign tcu_fire_ext_active = (ctrl_ext_state != S_CTRL_EXT_IDLE);

        assign error_type = r_error_type;
        assign error_ext_type = r_error_ext_type;
        assign ext_arg = r_ext_arg;

        assign firecmd_start = r_firecmd_start;
        assign firecmd_ext_start = r_firecmd_ext_start;
        assign firecmd_recvchip = r_firecmd_recvchip;
        assign firecmd_recvpe = r_firecmd_recvpe;

        assign start_recv_msg_s = r_start_recv_msg;

        assign read_initep_start_s = read_initep_start;

        assign tcu_log_unpriv_data_s = tcu_log_unpriv_data;
        assign tcu_log_ext_data_s = tcu_log_ext_data;

        //---------------
        //state machine for unprivileged commands
        always @* begin
            next_ctrl_state = ctrl_state;

            rin_firecmd_start      = 1'b0;
            rin_firecmd_opcode     = r_firecmd_opcode;
            rin_firecmd_ep         = r_firecmd_ep;
            rin_firecmd_replyep    = r_firecmd_replyep;
            rin_firecmd_data_addr  = r_firecmd_data_addr;
            rin_firecmd_data_size  = r_firecmd_data_size;
            rin_firecmd_perm       = r_firecmd_perm;
            rin_firecmd_msgoffset  = r_firecmd_msgoffset;
            rin_firecmd_recvaddr   = r_firecmd_recvaddr;
            rin_firecmd_recvchip   = r_firecmd_recvchip;
            rin_firecmd_recvpe     = r_firecmd_recvpe;
            rin_firecmd_replylabel = r_firecmd_replylabel;

            rin_error_type = r_error_type;

            read_initep_start = 1'b0;

            unpriv_tlb_read = 1'b0;

            tcu_log_unpriv_data = TCU_LOG_NONE;


            case (ctrl_state)

                //---------------
                //wait for incoming fire command
                S_CTRL_IDLE: begin
                    //unprivileged command
                    if (tcu_fire_i == 3'b001) begin

                        rin_firecmd_ep = cmd_cmd_ep;
                        rin_firecmd_data_addr = tcu_fire_data_addr_i;
                        rin_firecmd_data_size = tcu_fire_data_size_i;
                        rin_firecmd_perm = 2'h0;

                        //read opcode
                        case (cmd_cmd_op)

                            TCU_OPCODE_SEND: begin
                                rin_firecmd_opcode = TCU_OPCODE_SEND;
                                rin_firecmd_replyep = cmd_cmd_arg0[TCU_EP_SIZE-1:0];    //reply ep
                                rin_firecmd_replylabel = tcu_fire_arg1_i;
                                rin_firecmd_perm = TCU_MEMFLAG_R;
                                next_ctrl_state = S_CTRL_SEND_MSG_READ_INITEP;
                            end

                            //---------------
                            TCU_OPCODE_REPLY: begin
                                rin_firecmd_opcode = TCU_OPCODE_REPLY;
                                rin_firecmd_msgoffset = cmd_cmd_arg0;
                                rin_firecmd_perm = TCU_MEMFLAG_R;
                                next_ctrl_state = S_CTRL_REPLY_MSG_READ_INITEP;
                            end

                            //---------------
                            TCU_OPCODE_READ: begin
                                rin_firecmd_opcode = TCU_OPCODE_READ;
                                //store arg1 reg already here to preserve input data
                                //mep_addr must be added later
                                rin_firecmd_recvaddr = tcu_fire_arg1_i;
                                rin_firecmd_perm = TCU_MEMFLAG_W;
                                next_ctrl_state = S_CTRL_MEM_READ_READ_INITEP;
                            end

                            //---------------
                            TCU_OPCODE_WRITE: begin
                                rin_firecmd_opcode = TCU_OPCODE_WRITE;
                                //store arg1 reg already here to preserve input data
                                //mep_addr must be added later
                                rin_firecmd_recvaddr = tcu_fire_arg1_i;
                                rin_firecmd_perm = TCU_MEMFLAG_R;
                                next_ctrl_state = S_CTRL_MEM_WRITE_READ_INITEP;
                            end

                            //---------------
                            TCU_OPCODE_FETCH: begin
                                rin_firecmd_opcode = TCU_OPCODE_FETCH;
                                next_ctrl_state = S_CTRL_FETCH_MSG_READ_INITEP;
                            end

                            //---------------
                            TCU_OPCODE_ACK_MSG: begin
                                rin_firecmd_opcode = TCU_OPCODE_ACK_MSG;
                                rin_firecmd_msgoffset = cmd_cmd_arg0;
                                next_ctrl_state = S_CTRL_ACK_MSG_READ_INITEP;
                            end

                            //---------------
                            //everthing else leads to an unknown command
                            default: begin
                                rin_error_type = TCU_ERROR_UNKNOWN_CMD;
                                next_ctrl_state = S_CTRL_FINISH;
                            end
                        endcase //case (cmd_cmd_op)
                    end
                end


                //---------------
                //TCU cmd: read data from local mem and send it to the NoC
                S_CTRL_MEM_WRITE_READ_INITEP: begin
                    //first read initial ep
                    if (!read_initep_active) begin
                        read_initep_start = 1'b1;
                        next_ctrl_state = S_CTRL_MEM_WRITE_WAIT_INITEP;
                    end
                end

                S_CTRL_MEM_WRITE_WAIT_INITEP: begin
                    if (read_initep_done) begin
                        `TCU_DEBUG(("CMD_WRITE, trg-modid: 0x%x, ep: %0d, local addr: 0x%x, addr offset: 0x%x, size: %0d", mep_pe, r_firecmd_ep, r_firecmd_data_addr, r_firecmd_recvaddr, r_firecmd_data_size));
                        tcu_log_unpriv_data = {mep_pe, r_firecmd_data_size[19:0], r_firecmd_recvaddr[19:0], r_firecmd_data_addr[31:0], r_firecmd_ep[7:0], TCU_LOG_CMD_WRITE};

                        next_ctrl_state = S_CTRL_MEM_WRITE_CHECK_INITEP;
                    end
                end

                S_CTRL_MEM_WRITE_CHECK_INITEP: begin
                    //interpret ep content as memory endpoint
                    if (ep_type == TCU_EP_TYPE_MEMORY) begin

                        //check VPE ID
                        if (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (mep_vpe == tcu_fire_cur_vpe_i[TCU_VPEID_SIZE-1:0])) begin

                            //check rw permissions
                            if (mep_memflag & TCU_MEMFLAG_W) begin

                                //check if data fits to mem at ep
                                if ((r_firecmd_data_size + r_firecmd_recvaddr) <= mep_size) begin

                                    //check if there is a page boundary in addr range
                                    if (!(TCU_ENABLE_VIRT_ADDR && tcu_features_virt_addr_i) ||
                                        (({{TCU_TLB_PHYSPAGE_SIZE{1'b0}}, r_firecmd_data_addr[TCU_PAGEOFFSET_SIZE_4KB-1:0]} + r_firecmd_data_size) <= TCU_PAGE_SIZE_4KB)) begin
                                        if (r_firecmd_data_size != 'd0) begin
                                            rin_firecmd_recvaddr = mep_addr + r_firecmd_recvaddr;
                                            rin_firecmd_recvpe = mep_pe;
                                            rin_firecmd_recvchip = mep_chip;

                                            if (TCU_ENABLE_VIRT_ADDR && tcu_features_virt_addr_i) begin
                                                next_ctrl_state = S_CTRL_MEM_WRITE_TLB_LOOKUP;
                                            end else begin
                                                next_ctrl_state = S_CTRL_MEM_WRITE_START;
                                            end
                                        end
                                        else begin
                                            rin_error_type = TCU_ERROR_NONE;
                                            next_ctrl_state = S_CTRL_FINISH;
                                        end
                                    end
                                    else begin
                                        rin_error_type = TCU_ERROR_PAGE_BOUNDARY;
                                        next_ctrl_state = S_CTRL_FINISH;
                                    end
                                end
                                else begin
                                    rin_error_type = TCU_ERROR_OUT_OF_BOUNDS;
                                    next_ctrl_state = S_CTRL_FINISH;
                                end
                            end
                            else begin
                                rin_error_type = TCU_ERROR_NO_PERM;
                                next_ctrl_state = S_CTRL_FINISH;
                            end
                        end
                        else begin
                            rin_error_type = TCU_ERROR_FOREIGN_EP;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                    end
                    else begin
                        rin_error_type = TCU_ERROR_NO_MEP;
                        next_ctrl_state = S_CTRL_FINISH;
                    end
                end

                //translate virt to phys addr
                S_CTRL_MEM_WRITE_TLB_LOOKUP: begin
                    if (TCU_ENABLE_VIRT_ADDR) begin
                        if (!unpriv_tlb_active) begin
                            unpriv_tlb_read = 1'b1;
                            next_ctrl_state = S_CTRL_MEM_WRITE_TLB_WAIT;
                        end

                        //stop on abort
                        if (unpriv_write_abort) begin
                            rin_error_type = TCU_ERROR_ABORT;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                    end
                end

                //wait for TLB access
                S_CTRL_MEM_WRITE_TLB_WAIT: begin
                    if (TCU_ENABLE_VIRT_ADDR) begin
                        if (unpriv_tlb_read_done) begin
                            if (unpriv_tlb_read_error == TCU_ERROR_NONE) begin
                                rin_firecmd_data_addr = {unpriv_tlb_physpage, r_firecmd_data_addr[TCU_PAGEOFFSET_SIZE_4KB-1:0]}; //keep lower bits from virt addr
                                next_ctrl_state = S_CTRL_MEM_WRITE_START;
                            end
                            else begin
                                rin_error_type = unpriv_tlb_read_error;
                                next_ctrl_state = S_CTRL_FINISH;
                            end
                        end

                        //stop on abort
                        if (unpriv_write_abort) begin
                            rin_error_type = TCU_ERROR_ABORT;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                    end
                end

                S_CTRL_MEM_WRITE_START: begin
                    //check if send from NoC is still ongoing
                    if (!mas_active && !print_active) begin
                        //check abort condition again
                        if (unpriv_write_abort) begin
                            rin_error_type = TCU_ERROR_ABORT;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                        else begin
                            rin_firecmd_start = 1'b1;
                            next_ctrl_state = S_CTRL_MEM_WRITE;
                        end
                    end
                end

                S_CTRL_MEM_WRITE: begin
                    rin_error_type = mas_error;
                    if (mas_done) begin
                        next_ctrl_state = S_CTRL_FINISH;
                    end
                end


                //---------------
                //TCU cmd: read data from ep mem and write it to local mem
                S_CTRL_MEM_READ_READ_INITEP: begin
                    //first read initial ep
                    if (!read_initep_active) begin
                        read_initep_start = 1'b1;
                        next_ctrl_state = S_CTRL_MEM_READ_WAIT_INITEP;
                    end
                end

                S_CTRL_MEM_READ_WAIT_INITEP: begin
                    if (read_initep_done) begin
                        `TCU_DEBUG(("CMD_READ, trg-modid: 0x%x, ep: %0d, local addr: 0x%x, addr offset: 0x%x, size: %0d", mep_pe, r_firecmd_ep, r_firecmd_data_addr[31:0], r_firecmd_recvaddr, r_firecmd_data_size));
                        tcu_log_unpriv_data = {mep_pe, r_firecmd_data_size[19:0], r_firecmd_recvaddr[19:0], r_firecmd_data_addr[31:0], r_firecmd_ep[7:0], TCU_LOG_CMD_READ};

                        next_ctrl_state = S_CTRL_MEM_READ_CHECK_INITEP;
                    end
                end

                S_CTRL_MEM_READ_CHECK_INITEP: begin
                    //interpret ep content as memory ep
                    if (ep_type == TCU_EP_TYPE_MEMORY) begin

                        //check VPE ID
                        if (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (mep_vpe == tcu_fire_cur_vpe_i[TCU_VPEID_SIZE-1:0])) begin

                            //check rw permissions
                            if (mep_memflag & TCU_MEMFLAG_R) begin

                                //check if data fits to mem at ep
                                if ((r_firecmd_data_size + r_firecmd_recvaddr) <= mep_size) begin

                                    //check if there is a page boundary in addr range
                                    if (!(TCU_ENABLE_VIRT_ADDR && tcu_features_virt_addr_i) ||
                                        (({{TCU_TLB_PHYSPAGE_SIZE{1'b0}}, r_firecmd_data_addr[TCU_PAGEOFFSET_SIZE_4KB-1:0]} + r_firecmd_data_size) <= TCU_PAGE_SIZE_4KB)) begin
                                        if (r_firecmd_data_size != 'd0) begin
                                            rin_firecmd_recvaddr = mep_addr + r_firecmd_recvaddr;
                                            rin_firecmd_recvpe = mep_pe;
                                            rin_firecmd_recvchip = mep_chip;

                                            if (TCU_ENABLE_VIRT_ADDR && tcu_features_virt_addr_i) begin
                                                next_ctrl_state = S_CTRL_MEM_READ_TLB_LOOKUP;
                                            end else begin
                                                next_ctrl_state = S_CTRL_MEM_READ_START;
                                            end
                                        end
                                        else begin
                                            rin_error_type = TCU_ERROR_NONE;
                                            next_ctrl_state = S_CTRL_FINISH;
                                        end
                                    end
                                    else begin
                                        rin_error_type = TCU_ERROR_PAGE_BOUNDARY;
                                        next_ctrl_state = S_CTRL_FINISH;
                                    end
                                end
                                else begin
                                    rin_error_type = TCU_ERROR_OUT_OF_BOUNDS;
                                    next_ctrl_state = S_CTRL_FINISH;
                                end
                            end
                            else begin
                                rin_error_type = TCU_ERROR_NO_PERM;
                                next_ctrl_state = S_CTRL_FINISH;
                            end
                        end
                        else begin
                            rin_error_type = TCU_ERROR_FOREIGN_EP;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                    end
                    else begin
                        rin_error_type = TCU_ERROR_NO_MEP;
                        next_ctrl_state = S_CTRL_FINISH;
                    end
                end

                //translate local virt to phys addr
                S_CTRL_MEM_READ_TLB_LOOKUP: begin
                    if (TCU_ENABLE_VIRT_ADDR) begin
                        if (!unpriv_tlb_active) begin
                            unpriv_tlb_read = 1'b1;
                            next_ctrl_state = S_CTRL_MEM_READ_TLB_WAIT;
                        end

                        //stop on abort
                        if (unpriv_read_abort) begin
                            rin_error_type = TCU_ERROR_ABORT;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                    end
                end

                //wait for TLB access
                S_CTRL_MEM_READ_TLB_WAIT: begin
                    if (TCU_ENABLE_VIRT_ADDR) begin
                        if (unpriv_tlb_read_done) begin
                            if (unpriv_tlb_read_error == TCU_ERROR_NONE) begin
                                rin_firecmd_data_addr = {unpriv_tlb_physpage, r_firecmd_data_addr[TCU_PAGEOFFSET_SIZE_4KB-1:0]}; //keep lower bits from virt addr
                                next_ctrl_state = S_CTRL_MEM_READ_START;
                            end
                            else begin
                                rin_error_type = unpriv_tlb_read_error;
                                next_ctrl_state = S_CTRL_FINISH;
                            end
                        end

                        //stop on abort
                        if (unpriv_read_abort) begin
                            rin_error_type = TCU_ERROR_ABORT;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                    end
                end

                S_CTRL_MEM_READ_START: begin
                    //check if previous request was finished and nothing to send anymore
                    if (!marq_active && !mas_active && !print_active) begin
                        //check abort condition again
                        if (unpriv_read_abort) begin
                            rin_error_type = TCU_ERROR_ABORT;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                        else begin
                            rin_firecmd_start = 1'b1;
                            next_ctrl_state = S_CTRL_MEM_READ;
                        end
                    end
                end
                
                S_CTRL_MEM_READ: begin
                    rin_error_type = marq_error;
                    if (marq_done) begin
                        next_ctrl_state = S_CTRL_FINISH;
                    end
                end


                //---------------
                S_CTRL_SEND_MSG_READ_INITEP: begin
                    //first read initial ep
                    if (!read_initep_active && !start_recv_msg && !r_start_recv_msg && !rm_active) begin
                        read_initep_start = 1'b1;
                        next_ctrl_state = S_CTRL_SEND_MSG_WAIT_INITEP;
                    end
                end

                S_CTRL_SEND_MSG_WAIT_INITEP: begin
                    //start again if RECV is ongoing
                    if (start_recv_msg || r_start_recv_msg || rm_active) begin
                        next_ctrl_state = S_CTRL_SEND_MSG_READ_INITEP;
                    end
                    else if (read_initep_done) begin
                        `TCU_DEBUG(("CMD_SEND, trg-modid: 0x%x, send-ep: %0d, local addr: 0x%x, size: %0d", epdata_1[TCU_PEID_SIZE+TCU_EP_SIZE-1:TCU_EP_SIZE], r_firecmd_ep, r_firecmd_data_addr, r_firecmd_data_size));
                        tcu_log_unpriv_data = {epdata_1[TCU_PEID_SIZE+TCU_EP_SIZE-1:TCU_EP_SIZE], r_firecmd_data_size, r_firecmd_data_addr, r_firecmd_ep, TCU_LOG_CMD_SEND};

                        next_ctrl_state = S_CTRL_SEND_MSG_START;
                    end
                end

                S_CTRL_SEND_MSG_START: begin
                    //check if send from NoC is still ongoing
                    if (!mas_active && !print_active) begin
                        //check abort condition again
                        if (unpriv_send_abort) begin
                            rin_error_type = TCU_ERROR_ABORT;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                        else begin
                            rin_firecmd_start = 1'b1;
                            next_ctrl_state = S_CTRL_SEND_MSG;
                        end
                    end
                end

                S_CTRL_SEND_MSG: begin
                    rin_error_type = sm_error;
                    unpriv_tlb_read = sm_tlb_read;
                    if (sm_done) begin
                        next_ctrl_state = S_CTRL_FINISH;
                    end
                end


                //---------------
                S_CTRL_FETCH_MSG_READ_INITEP: begin
                    //first read initial ep, wait if RECV starts or is ongoing
                    if (!read_initep_active && !start_recv_msg && !r_start_recv_msg && !rm_active) begin
                        read_initep_start = 1'b1;
                        next_ctrl_state = S_CTRL_FETCH_MSG_WAIT_INITEP;
                    end
                end

                S_CTRL_FETCH_MSG_WAIT_INITEP: begin
                    //start again if RECV starts or is ongoing
                    if (r_start_recv_msg || rm_active) begin
                        next_ctrl_state = S_CTRL_FETCH_MSG_READ_INITEP;
                    end
                    else if (read_initep_done) begin
                        rin_firecmd_start = 1'b1;
                        next_ctrl_state = S_CTRL_FETCH_MSG;
                    end
                end

                S_CTRL_FETCH_MSG: begin
                    rin_error_type = fm_error;
                    if (fm_done) begin
                        `TCU_DEBUG(("CMD_FETCH, ep: %0d, msg offset: 0x%x", r_firecmd_ep, fm_msgoffset));

                        if (fm_fetch_success) begin
                            tcu_log_unpriv_data = {fm_msgoffset, r_firecmd_ep, TCU_LOG_CMD_FETCH};
                        end
                        next_ctrl_state = S_CTRL_FINISH;
                    end
                end


                //---------------
                S_CTRL_REPLY_MSG_READ_INITEP: begin
                    //first read initial ep
                    if (!read_initep_active && !start_recv_msg && !r_start_recv_msg && !rm_active) begin
                        read_initep_start = 1'b1;
                        next_ctrl_state = S_CTRL_REPLY_MSG_WAIT_INITEP;
                    end
                end

                S_CTRL_REPLY_MSG_WAIT_INITEP: begin
                    //start again if RECV is ongoing
                    if (start_recv_msg || r_start_recv_msg || rm_active) begin
                        next_ctrl_state = S_CTRL_REPLY_MSG_READ_INITEP;
                    end
                    else if (read_initep_done) begin
                        next_ctrl_state = S_CTRL_REPLY_MSG_START;
                    end
                end

                S_CTRL_REPLY_MSG_START: begin
                    //check if send from NoC is still ongoing
                    if (!mas_active && !print_active) begin
                        //check abort condition again
                        if (unpriv_reply_abort) begin
                            rin_error_type = TCU_ERROR_ABORT;
                            next_ctrl_state = S_CTRL_FINISH;
                        end
                        else begin
                            rin_firecmd_start = 1'b1;
                            next_ctrl_state = S_CTRL_REPLY_MSG;
                        end
                    end
                end

                S_CTRL_REPLY_MSG: begin
                    if (rpm_log_valid) begin
                        `TCU_DEBUG(("CMD_REPLY, trg-modid: 0x%x, send-ep: %0d, local addr: 0x%x, msg offset: 0x%x, size: %0d", rpm_log_rpl_pe, r_firecmd_ep, r_firecmd_data_addr, r_firecmd_msgoffset, r_firecmd_data_size));
                        tcu_log_unpriv_data = {rpm_log_rpl_pe, r_firecmd_data_size[19:0], r_firecmd_msgoffset[19:0], r_firecmd_data_addr, r_firecmd_ep[7:0], TCU_LOG_CMD_REPLY};
                    end

                    rin_error_type = rpm_error;
                    unpriv_tlb_read = rpm_tlb_read;
                    if (rpm_done) begin
                        next_ctrl_state = S_CTRL_FINISH;
                    end
                end


                //---------------
                S_CTRL_ACK_MSG_READ_INITEP: begin
                    //first read initial ep, wait if RECV starts or is ongoing
                    if (!read_initep_active && !start_recv_msg && !r_start_recv_msg && !rm_active) begin
                        read_initep_start = 1'b1;
                        next_ctrl_state = S_CTRL_ACK_MSG_WAIT_INITEP;
                    end
                end

                S_CTRL_ACK_MSG_WAIT_INITEP: begin
                    //start again if RECV is ongoing
                    if (r_start_recv_msg || rm_active) begin
                        next_ctrl_state = S_CTRL_ACK_MSG_READ_INITEP;
                    end
                    else if (read_initep_done) begin
                        `TCU_DEBUG(("CMD_ACK, ep: %0d, msg offset: 0x%x", r_firecmd_ep, r_firecmd_msgoffset));
                        tcu_log_unpriv_data = {r_firecmd_msgoffset, r_firecmd_ep, TCU_LOG_CMD_ACK_MSG};

                        rin_firecmd_start = 1'b1;
                        next_ctrl_state = S_CTRL_ACK_MSG;
                    end
                end

                S_CTRL_ACK_MSG: begin
                    rin_error_type = am_error;
                    if (am_done) begin
                        next_ctrl_state = S_CTRL_FINISH;
                    end
                end


                //---------------
                S_CTRL_FINISH: begin
                    if (!reg_stall_i && !print_active && !rm_reg_en && !read_initep_active) begin
                        rin_firecmd_opcode = TCU_OPCODE_IDLE;
                        next_ctrl_state = S_CTRL_IDLE;

                        `TCU_DEBUG(("CMD_FINISH, error: %0d", r_error_type));
                        if (r_error_type != TCU_ERROR_NONE) begin
                            tcu_log_unpriv_data = {r_error_type, TCU_LOG_CMD_FINISH};
                        end
                    end
                end

                default: next_ctrl_state = S_CTRL_IDLE;

            endcase //case (ctrl_state)
        end


        //---------------
        //state machine for external commands
        always @* begin
            next_ctrl_ext_state = ctrl_ext_state;

            rin_firecmd_ext_start  = 1'b0;
            rin_firecmd_ext_opcode = r_firecmd_ext_opcode;
            rin_firecmd_ext_arg    = r_firecmd_ext_arg;

            rin_error_ext_type = r_error_ext_type;
            rin_ext_arg = r_ext_arg;

            read_initep_ext_start = 1'b0;

            tcu_log_ext_data = TCU_LOG_NONE;


            case (ctrl_ext_state)

                //---------------
                //wait for incoming fire command
                S_CTRL_EXT_IDLE: begin

                    //external command
                    if (tcu_fire_i == 3'b011) begin
                        
                        //read opcode
                        case (cmd_ext_op)

                            TCU_OPCODE_EXT_INVEP: begin
                                rin_firecmd_ext_opcode = TCU_OPCODE_EXT_INVEP;
                                rin_firecmd_ext_arg = cmd_ext_arg;  //epid and force
                                next_ctrl_ext_state = S_CTRL_EXT_INVEP_READ_INITEP;
                            end

                            //---------------
                            //everthing else leads to an unknown command
                            default: begin
                                rin_error_ext_type = TCU_ERROR_UNKNOWN_CMD;
                                next_ctrl_ext_state = S_CTRL_EXT_FINISH;
                            end
                        endcase //case (cmd_ext_op)
                    end
                end


                //---------------
                S_CTRL_EXT_INVEP_READ_INITEP: begin
                    //first read initial ep
                    if (!read_initep_active) begin
                        read_initep_ext_start = 1'b1;
                        next_ctrl_ext_state = S_CTRL_EXT_INVEP_WAIT_INITEP;
                    end
                end

                S_CTRL_EXT_INVEP_WAIT_INITEP: begin
                    if (read_initep_done) begin
                        `TCU_DEBUG(("CMD_EXT_INVEP, ep: %0d, force: %d", r_firecmd_ext_arg[TCU_EP_SIZE-1:0], r_firecmd_ext_arg[16]));
                        tcu_log_ext_data = {r_firecmd_ext_arg[16], r_firecmd_ext_arg[TCU_EP_SIZE-1:0], TCU_LOG_CMD_EXT_INVEP};

                        rin_firecmd_ext_start = 1'b1;
                        next_ctrl_ext_state = S_CTRL_EXT_INVEP;
                    end
                end

                S_CTRL_EXT_INVEP: begin
                    rin_error_ext_type = ext_invep_error;
                    rin_ext_arg = ext_invep_arg;
                    if (ext_invep_done) begin
                        next_ctrl_ext_state = S_CTRL_EXT_FINISH;
                    end
                end

                //---------------
                S_CTRL_EXT_FINISH: begin
                    if (!reg_stall_i && !ctrl_reg_access) begin
                        rin_firecmd_ext_opcode = TCU_OPCODE_EXT_IDLE;
                        next_ctrl_ext_state = S_CTRL_EXT_IDLE;

                        `TCU_DEBUG(("CMD_EXT_FINISH, error: %0d", r_error_ext_type));
                        tcu_log_ext_data = {r_error_ext_type, TCU_LOG_CMD_EXT_FINISH};
                    end
                end

                default: next_ctrl_ext_state = S_CTRL_EXT_IDLE;

            endcase //case (ctrl_ext_state)
        end


        tcu_ctrl_read_initep i_tcu_ctrl_read_initep (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_ctrl_n),

            //---------------
            //reg IF
            .read_initep_reg_en_o    (read_initep_reg_en),
            .read_initep_reg_addr_o  (read_initep_reg_addr),
            .read_initep_reg_rdata_i (reg_rdata_i),
            .read_initep_reg_stall_i (reg_stall_i || print_active || rm_reg_en),

            //---------------
            //EP data
            .read_initep_epidx_i     (r_firecmd_ep),
            .read_initep_ext_epidx_i (r_firecmd_ext_arg[TCU_EP_SIZE-1:0]),
            .read_initep_data_0_o    (epdata_0),
            .read_initep_data_1_o    (epdata_1),
            .read_initep_data_2_o    (epdata_2),

            //---------------
            //trigger
            .read_initep_start_i     (read_initep_start),
            .read_initep_ext_start_i (read_initep_ext_start),
            .read_initep_active_o    (read_initep_active),
            .read_initep_done_o      (read_initep_done)
        );

    end

    else begin: NO_CMD_CTRL
        assign ctrl_state_s = S_CTRL_IDLE;
        assign ctrl_ext_state_s = S_CTRL_EXT_IDLE;

        assign mas_start  = noc_req_start_noc_send;
        assign mas_opcode = (reqfifo_mode == MODE_READ_REQ_2) ? TCU_OPCODE_WRITE_RSP_2 : TCU_OPCODE_WRITE_RSP;
        assign mas_laddr  = reqfifo_addr;
        assign mas_raddr  = reqfifo_retaddr;
        assign mas_size   = reqfifo_read_size;
        assign mas_chipid = reqfifo_chipid;
        assign mas_modid  = reqfifo_modid;

        assign marq_start  = 1'b0;
        assign marq_opcode = {TCU_OPCODE_SIZE{1'b0}};
        assign marq_laddr  = 32'h0;
        assign marq_raddr  = 32'h0;
        assign marq_size   = 32'h0;
        assign marq_chipid = {NOC_CHIPID_SIZE{1'b0}};
        assign marq_modid  = {NOC_MODID_SIZE{1'b0}};

        assign tcu_fire_cmd_active = 1'b0;
        assign tcu_fire_ext_active = 1'b0;

        assign error_type = TCU_ERROR_NONE;
        assign error_ext_type = TCU_ERROR_NONE;
        assign ext_arg = {TCU_EXT_ARG_SIZE{1'b0}};
        
        assign firecmd_start = 1'b0;
        assign firecmd_ext_start = 1'b0;
        assign firecmd_recvchip = {TCU_CHIPID_SIZE{1'b0}};
        assign firecmd_recvpe = {TCU_PEID_SIZE{1'b0}};

        assign start_recv_msg_s = 1'b0;

        assign read_initep_reg_en = 1'b0;
        assign read_initep_reg_addr = {TCU_REG_ADDR_SIZE{1'b0}};
        assign read_initep_active = 1'b0;
        assign read_initep_start_s = 1'b0;

        assign tcu_log_unpriv_data_s = TCU_LOG_NONE;
        assign tcu_log_ext_data_s = TCU_LOG_NONE;
    end
    endgenerate



    generate
    if (TCU_ENABLE_CMDS && TCU_ENABLE_PRIV_CMDS) begin: PRIV_CTRL
        reg                         r_firecmd_priv_start, rin_firecmd_priv_start;   //indicate start of priv TCU command
        reg   [TCU_OPCODE_SIZE-1:0] r_firecmd_priv_opcode, rin_firecmd_priv_opcode;
        reg [TCU_PRIV_ARG_SIZE-1:0] r_firecmd_priv_arg0, rin_firecmd_priv_arg0;
        reg                  [63:0] r_firecmd_priv_arg1, rin_firecmd_priv_arg1;

        always @(posedge clk_i) begin
            if (reset_ctrl_n == 1'b0) begin
                r_firecmd_priv_start   <= 1'b0;
                r_firecmd_priv_opcode  <= {TCU_OPCODE_SIZE{1'b0}};
                r_firecmd_priv_arg0    <= {TCU_PRIV_ARG_SIZE{1'b0}};
                r_firecmd_priv_arg1    <= 64'h0;
            end
            else begin
                r_firecmd_priv_start   <= rin_firecmd_priv_start;
                r_firecmd_priv_opcode  <= rin_firecmd_priv_opcode;
                r_firecmd_priv_arg0    <= rin_firecmd_priv_arg0;
                r_firecmd_priv_arg1    <= rin_firecmd_priv_arg1;
            end
        end


        always @* begin
            rin_firecmd_priv_start = 1'b0;
            rin_firecmd_priv_opcode = r_firecmd_priv_opcode;
            rin_firecmd_priv_arg0 = r_firecmd_priv_arg0;
            rin_firecmd_priv_arg1 = r_firecmd_priv_arg1;

            if ((tcu_features_virt_addr_i || tcu_features_virt_pes_i) && (tcu_fire_i == 3'b101)) begin
                rin_firecmd_priv_start = 1'b1;
                rin_firecmd_priv_opcode = cmd_priv_op;
                rin_firecmd_priv_arg0 = cmd_priv_arg;
                rin_firecmd_priv_arg1 = tcu_fire_arg1_i;
            end
        end
    end
    endgenerate



    //---------------
    //memory access
    always @* begin
        rin_mem_en = 2'b00;
        rin_mem_wben = r_mem_wben;
        rin_mem_addr = r_mem_addr;
        rin_mem_wdata = r_mem_wdata;
    

        //receiver has prio
        //when stalled, still write data to mem interface and hold it
        if (!r_mem_wstall) begin

            //receive message
            //data is aligned to 16 byte
            if (rm_mem_en[0]) begin
                rin_mem_en = 2'b01;
                rin_mem_wben = rm_mem_wben;
                rin_mem_addr = rm_mem_addr;
                rin_mem_wdata = {r_noc_rx_data1, r_noc_rx_data0} << {rm_mem_addr[3:0], 3'h0};
            end
            
            //data is aligned to any byte
            else if (rm_mem_en[1]) begin
                rin_mem_en = 2'b01;
                rin_mem_wben = rm_mem_wben;
                rin_mem_addr = rm_mem_addr;

                if (rm_mem_addr[3:0] > 4'd8) begin
                    rin_mem_wdata = {r_noc_rx_data0, r2_noc_rx_data1, r2_noc_rx_data0} >> {(5'd16 - rm_mem_addr[3:0]), 3'h0};
                end else begin
                    rin_mem_wdata = {r_noc_rx_data1, r_noc_rx_data0, r2_noc_rx_data1} >> {(4'd8 - rm_mem_addr[3:0]), 3'h0};
                end
            end

            //inform mem interface about expected write data size
            else if (rm_mem_en[2]) begin
                rin_mem_en = 2'b10;
                rin_mem_wben = rm_mem_wben;
                rin_mem_addr = rm_mem_addr;
                rin_mem_wdata = rm_mem_wdata;
            end


            //mem transfer: write receiving data to memory
            //data is aligned to 16 byte
            if (mar_mem_en[0]) begin
                rin_mem_en = 2'b01;
                rin_mem_wben = mar_mem_wben;
                rin_mem_addr = mar_mem_addr;
                rin_mem_wdata = ({r_noc_rx_data1, r_noc_rx_data0} >> {mar_shift, 3'h0}) << {mar_mem_addr[3:0], 3'h0};
            end
            
            //data is aligned to any byte
            else if (mar_mem_en[1]) begin
                rin_mem_en = 2'b01;
                rin_mem_wben = mar_mem_wben;
                rin_mem_addr = mar_mem_addr;

                if (mar_mem_addr[3:0] > 4'd8) begin
                    rin_mem_wdata = {r_noc_rx_data0, r2_noc_rx_data1, r2_noc_rx_data0} >> {(5'd16 - mar_mem_addr[3:0] + mar_shift), 3'h0};
                end else begin
                    rin_mem_wdata = {r_noc_rx_data1, r_noc_rx_data0, r2_noc_rx_data1} >> {(4'd8 - mar_mem_addr[3:0] + mar_shift), 3'h0};
                end
            end

            //inform mem interface about expected write data size
            else if (mar_mem_en[2]) begin
                rin_mem_en = 2'b10;
                rin_mem_wben = mar_mem_wben;
                rin_mem_addr = mar_mem_addr;
                rin_mem_wdata = mar_mem_wdata;
            end
        end
        else if (|r_mem_wben) begin
            //when stalled keep old value, so that enable is still on when stall turns off
            rin_mem_en = r_mem_en;
        end

        if (!receive_active) begin
            //receiver currently not active, provide access to sender (triggered by controller)
            if (ctrl_mem_access) begin    
                if (ctrl_state_s == S_CTRL_MEM_WRITE) begin //read triggered by TCU command
                    rin_mem_en = mas_mem_en;    //either read request or normal read
                    rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b0}};
                    rin_mem_addr = mas_mem_addr;
                    rin_mem_wdata = mas_mem_wdata;  //number of bytes for read request
                end
                else if (ctrl_state_s == S_CTRL_SEND_MSG) begin
                    rin_mem_en = sm_mem_en;
                    rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b0}};
                    rin_mem_addr = sm_mem_addr;
                    rin_mem_wdata = sm_mem_wdata;
                end
                else if (ctrl_state_s == S_CTRL_REPLY_MSG) begin
                    rin_mem_en = rpm_mem_en;
                    rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b0}};
                    rin_mem_addr = rpm_mem_addr;
                    rin_mem_wdata = rpm_mem_wdata;
                end
            end

            //only used for DRAM access when controller is disabled or response to NoC request needed
            else if (mas_mem_en) begin
                rin_mem_en = mas_mem_en;
                rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b0}};
                rin_mem_addr = mas_mem_addr;
                rin_mem_wdata = mas_mem_wdata;
            end
        end
    end

    assign mem_en_o = |rin_mem_wben ?
                        (rin_mem_en[0] & !mem_wstall_i) :
                        (rin_mem_en[0] & !mem_rstall_i);
    assign mem_req_o = |rin_mem_wben ?
                        (rin_mem_en[1] & !mem_wstall_i) :
                        (rin_mem_en[1] & !mem_rstall_i);
    assign mem_wben_o = rin_mem_wben;
    assign mem_addr_o = rin_mem_addr;
    assign mem_wdata_o = rin_mem_wdata;
    assign mem_wabort_o = mar_mem_wabort || rm_mem_wabort;




    //all receive commands have prio over send commands
    //but do not interrupt send command during burst unless memory or NoC does not stall
    assign receive_active = (noc_state == S_NOC_MEM_WRITE) ||
                            (|mar_mem_en) ||
                            (noc_state == S_NOC_RECEIVE_MSG) ||
                            (|rm_mem_en) ||
                            (noc_state == S_NOC_RECV_ACK);

    //this signal should inform the receivers that some data from mem is sent
    //debug print does not access memory and does not need to set this signal
    assign send_active = (((mas_mem_en[0] || sm_mem_en[0] || rpm_mem_en[0]) && !receive_active) || r_noc_tx_burst) &&
                            !noc_tx_stall_i && !mem_rstall_i && !print_active;

    generate
    assign ctrl_mem_access = TCU_ENABLE_CMDS ? 
                             (ctrl_state_s == S_CTRL_MEM_WRITE) ||
                             (ctrl_state_s == S_CTRL_SEND_MSG) ||
                             (ctrl_state_s == S_CTRL_REPLY_MSG) :
                             1'b0;
    endgenerate


    //---------------
    //reply to regs
    generate
    always @* begin
        reg_en_o = 2'h0;
        reg_wben_o = {TCU_REG_DATA_SIZE{1'b0}};
        reg_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
        reg_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};

        if (!reg_stall_i) begin

            if (TCU_ENABLE_CMDS && TCU_ENABLE_PRINT && print_reg_en) begin
                reg_en_o = 2'b01;
                for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                    reg_wben_o[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = {TCU_REG_BSEL_SIZE{print_reg_wben[i]}};
                end
                reg_addr_o = print_reg_addr;
                reg_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};
            end

            //receiver has prio over other commands
            else if (TCU_ENABLE_CMDS && rm_reg_en) begin
                reg_en_o = 2'b01;
                reg_wben_o = rm_reg_wben;
                reg_addr_o = rm_reg_addr;
                reg_wdata_o = rm_reg_wdata;
            end
            else if (TCU_ENABLE_CMDS && read_initep_reg_en) begin
                reg_en_o = 2'b01;
                reg_addr_o = read_initep_reg_addr;
            end
            else if (TCU_ENABLE_CMDS && sm_reg_en) begin
                reg_en_o = 2'b01;
                reg_wben_o = sm_reg_wben;
                reg_addr_o = sm_reg_addr;
                reg_wdata_o = sm_reg_wdata;
            end
            else if (TCU_ENABLE_CMDS && rpm_reg_en) begin
                reg_en_o = 2'b01;
                reg_wben_o = rpm_reg_wben;
                reg_addr_o = rpm_reg_addr;
                reg_wdata_o = rpm_reg_wdata;
            end
            else if (TCU_ENABLE_CMDS && fm_reg_en) begin
                reg_en_o = 2'b01;
                reg_wben_o = fm_reg_wben;
                reg_addr_o = fm_reg_addr;
                reg_wdata_o = fm_reg_wdata;
            end
            else if (TCU_ENABLE_CMDS && am_reg_en) begin
                reg_en_o = 2'b01;
                reg_wben_o = am_reg_wben;
                reg_addr_o = am_reg_addr;
                reg_wdata_o = am_reg_wdata;
            end
            else if (TCU_ENABLE_CMDS && (ctrl_state_s == S_CTRL_FINISH)) begin
                reg_en_o = 2'b01;
                reg_wben_o = {TCU_REG_DATA_SIZE{1'b1}};
                reg_addr_o = TCU_REGADDR_COMMAND;
                reg_wdata_o = {{TCU_ARG0_SIZE{1'b0}},
                                error_type,
                                {TCU_EP_SIZE{1'b0}},
                                TCU_OPCODE_IDLE};
            end
            else if (TCU_ENABLE_CMDS && ext_invep_reg_en) begin
                reg_en_o = 2'b01;
                reg_wben_o = {TCU_REG_DATA_SIZE{1'b1}};
                reg_addr_o = ext_invep_reg_addr;
                reg_wdata_o = ext_invep_reg_wdata;
            end
            else if (TCU_ENABLE_CMDS && (ctrl_ext_state_s == S_CTRL_EXT_FINISH)) begin
                reg_en_o = 2'b01;
                reg_wben_o = {TCU_REG_DATA_SIZE{1'b1}};
                reg_addr_o = TCU_REGADDR_EXT_CMD;
                reg_wdata_o = {ext_arg, error_ext_type, TCU_OPCODE_EXT_IDLE};
            end
            else if (TCU_ENABLE_PRIV_CMDS && priv_reg_en) begin
                reg_en_o = 2'b01;
                for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                    reg_wben_o[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = {TCU_REG_BSEL_SIZE{priv_reg_wben[i]}};
                end
                reg_addr_o = priv_reg_addr;
                reg_wdata_o = priv_reg_wdata;
            end

            //TCU controller has prio over ext access from NoC
            else if (!ctrl_reg_access && !ctrl_ext_reg_access && !ctrl_priv_reg_access) begin
                if ((noc_state == S_NOC_TCU_REG_WRITE) && !tcu_fire_i[0] && !firecmd_start && !firecmd_ext_start) begin
                    reg_en_o = 2'b11;
                    for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                        reg_wben_o[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = {TCU_REG_BSEL_SIZE{r_noc_rx_bsel[i]}};
                    end
                    reg_addr_o = r_noc_rx_addr;
                    reg_wdata_o = r_noc_rx_data0;
                end
                else if (noc_req_reg_en) begin
                    reg_en_o = 2'b11;
                    reg_addr_o = reqfifo_addr;
                end
            end
        end
    end
    endgenerate


    generate
    assign ctrl_reg_access = TCU_ENABLE_CMDS ?
                                rm_reg_en ||
                                read_initep_active ||
                                sm_reg_en ||
                                rpm_reg_en ||
                                fm_reg_en ||
                                am_reg_en ||
                                (ctrl_state_s == S_CTRL_FINISH) ||
                                (TCU_ENABLE_PRINT && print_reg_en) :
                                1'b0;

    assign ctrl_ext_reg_access = TCU_ENABLE_CMDS ?
                                    (ctrl_ext_state_s == S_CTRL_EXT_FINISH) || ext_invep_reg_en :
                                    1'b0;

    assign ctrl_priv_reg_access = (TCU_ENABLE_CMDS && TCU_ENABLE_PRIV_CMDS) ? priv_reg_en : 1'b0;
    endgenerate



    //---------------
    //prepare NoC packets
    generate
    always @* begin
        rin_noc_tx_wrreq = 1'b0;
        rin_noc_tx_burst = r_noc_tx_burst;
        rin_noc_tx_bsel = r_noc_tx_bsel;
        rin_noc_tx_mode = r_noc_tx_mode;
        rin_noc_tx_trg_chipid = r_noc_tx_trg_chipid;
        rin_noc_tx_trg_modid = r_noc_tx_trg_modid;
        rin_noc_tx_addr = r_noc_tx_addr;
        rin_noc_tx_data0 = r_noc_tx_data0;
        rin_noc_tx_data1 = r_noc_tx_data1;

        rin_tmp_addr_align_inreg = r_tmp_addr_align_inreg;

        rin_mas_mem_rdata_inreg = r_mas_mem_rdata_inreg;
        rin_mas_noc_bsel = r_mas_noc_bsel;
        rin_mas_noc_addr = r_mas_noc_addr;

        rin_sm_mem_rdata_inreg = r_sm_mem_rdata_inreg;
        rin_rpm_mem_rdata_inreg = r_rpm_mem_rdata_inreg;

        rin_mem_rdata = r_mem_rdata;


        if (!noc_tx_stall_i) begin
            rin_tmp_addr_align_inreg = mem_addr_o[3];

            //debug print (prio over recv-msg and noc-request)
            //no dependency to other send cmds because they cannot occur together
            if (TCU_ENABLE_PRINT && print_noc_wrreq) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = print_noc_burst;
                rin_noc_tx_bsel = print_noc_bsel;
                rin_noc_tx_trg_chipid = print_noc_chipid;
                rin_noc_tx_trg_modid = print_noc_modid;
                rin_noc_tx_mode = MODE_WRITE_POSTED;
                rin_noc_tx_addr = {4'h0, tcu_cur_time_i[NOC_ADDR_SIZE-4-1:0]}; //current time as random addr, keep upper 4 bits empty because of TCU reg addr
                rin_noc_tx_data0 = print_noc_data0;
                rin_noc_tx_data1 = print_noc_data1;
            end

            //send msg ack - from receiver (has highest prio)
            else if (TCU_ENABLE_CMDS && rm_noc_wrreq) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = 1'b0;
                rin_noc_tx_bsel = {NOC_BSEL_SIZE{1'b1}};
                rin_noc_tx_trg_chipid = rm_noc_chipid;
                rin_noc_tx_trg_modid = rm_noc_modid;
                rin_noc_tx_mode = MODE_TCU_ACK;
                rin_noc_tx_addr = {tcu_cur_time_i[15:0], rm_noc_addr[15:0]};    //insert kind of randomness into addr field due to ARQ protocol
                rin_noc_tx_data0 = rm_noc_data;
            end

            //send write ack
            else if (mar_noc_wrreq) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = 1'b0;
                rin_noc_tx_bsel = {NOC_BSEL_SIZE{1'b1}};
                rin_noc_tx_trg_chipid = mar_noc_chipid;
                rin_noc_tx_trg_modid = mar_noc_modid;
                rin_noc_tx_mode = MODE_TCU_ACK;
                rin_noc_tx_addr = mar_noc_addr;
                rin_noc_tx_data0 = {32'h1, mar_noc_data};   //indicate WRITE ACK
            end

            //send return reg data from NoC request
            else if (noc_req_done) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = 1'b0;
                rin_noc_tx_bsel = reqfifo_bsel;
                rin_noc_tx_trg_chipid = reqfifo_chipid;
                rin_noc_tx_trg_modid = reqfifo_modid;
                rin_noc_tx_mode = (reqfifo_mode == MODE_READ_REQ_2) ? MODE_READ_RSP_2 : MODE_READ_RSP;
                rin_noc_tx_addr = reqfifo_retaddr;
                rin_noc_tx_data0 = noc_req_reg_retdata;
            end

            //mem transfer: send header for burst write
            else if (mas_noc_wrreq) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = mas_noc_burst;
                rin_noc_tx_bsel = mas_noc_bsel;
                rin_noc_tx_trg_chipid = mas_noc_chipid;
                rin_noc_tx_trg_modid = mas_noc_modid;
                rin_noc_tx_mode = mas_noc_mode;
                rin_noc_tx_addr = mas_noc_addr;
                rin_noc_tx_data0 = mas_noc_data0;
                rin_noc_tx_data1 = {NOC_DATA_SIZE{1'b0}};
            end

            //send NoC payload packets
            else if (mas_mem_rdata_valid || r_mas_mem_rdata_inreg) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_mas_mem_rdata_inreg = 1'b0;

                //only 8-byte payload (or use this 2x for splitted non-burst packet)
                if (!r_noc_tx_burst) begin
                    rin_noc_tx_burst = 1'b0;
                    rin_noc_tx_bsel = r_mas_noc_bsel;
                    rin_noc_tx_trg_chipid = mas_noc_chipid; //should actually also use registered value, but chipid does not change within packet
                    rin_noc_tx_trg_modid = mas_noc_modid;   //should actually also use registered value, but modid does not change within packet
                    rin_noc_tx_mode = mas_noc_mode;         //should actually also use registered value, but mode does not change within packet
                    rin_noc_tx_addr = r_mas_noc_addr;
                    if (r_mas_mem_rdata_inreg) begin
                        rin_noc_tx_data0 = r_tmp_addr_align_inreg ? r_mem_rdata[127:64] : r_mem_rdata[63:0];
                    end else begin
                        rin_noc_tx_data0 = r_tmp_addr_align ? mem_rdata_i[127:64] : mem_rdata_i[63:0];
                    end
                    rin_noc_tx_data1 = {NOC_DATA_SIZE{1'b0}};
                end

                //payload has more than 8 bytes
                else begin
                    rin_noc_tx_burst = mas_noc_burst;
                    rin_noc_tx_bsel = mas_noc_bsel;
                    if (r_mas_mem_rdata_inreg) begin
                        rin_noc_tx_data0 = r_mem_rdata[63:0];
                        rin_noc_tx_data1 = r_mem_rdata[127:64];
                    end else begin
                        rin_noc_tx_data0 = mem_rdata_i[63:0];
                        rin_noc_tx_data1 = mem_rdata_i[127:64];
                    end
                end
            end
            
            //mem transfer: send read request
            else if (TCU_ENABLE_CMDS && marq_noc_wrreq) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = 1'b0;
                rin_noc_tx_bsel = {NOC_BSEL_SIZE{1'b1}};
                rin_noc_tx_trg_chipid = marq_noc_chipid;
                rin_noc_tx_trg_modid = marq_noc_modid;
                rin_noc_tx_mode = MODE_READ_REQ;
                rin_noc_tx_addr = marq_noc_addr;
                rin_noc_tx_data0 = marq_noc_data0;
                rin_noc_tx_data1 = {NOC_DATA_SIZE{1'b0}};
            end


            //send cmd: send header
            else if (TCU_ENABLE_CMDS && sm_noc_wrreq) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = sm_noc_burst;
                rin_noc_tx_bsel = sm_noc_bsel;
                rin_noc_tx_trg_chipid = sm_noc_chipid;
                rin_noc_tx_trg_modid = sm_noc_modid;
                rin_noc_tx_mode = sm_noc_mode;
                rin_noc_tx_addr = {tcu_cur_time_i[NOC_ADDR_SIZE-TCU_EP_SIZE-1:0], sm_noc_addr[TCU_EP_SIZE-1:0]};    //insert kind of randomness into addr field due to ARQ protocol
                rin_noc_tx_data0 = sm_noc_data0;
                rin_noc_tx_data1 = sm_noc_data1;
            end

            //send payload (only NoC payload packets here, NoC header before)
            else if (TCU_ENABLE_CMDS && (sm_mem_rdata_valid || r_sm_mem_rdata_inreg)) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = sm_noc_burst;
                rin_noc_tx_bsel = sm_noc_bsel;

                rin_sm_mem_rdata_inreg = 1'b0;
                if (r_sm_mem_rdata_inreg) begin
                    rin_noc_tx_data0 = r_mem_rdata[63:0];
                    rin_noc_tx_data1 = r_mem_rdata[127:64];
                end else begin
                    rin_noc_tx_data0 = mem_rdata_i[63:0];
                    rin_noc_tx_data1 = mem_rdata_i[127:64];
                end
            end

            //reply cmd: send header of reply message
            else if (TCU_ENABLE_CMDS && rpm_noc_wrreq) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = rpm_noc_burst;
                rin_noc_tx_bsel = rpm_noc_bsel;
                rin_noc_tx_trg_chipid = rpm_noc_chipid;
                rin_noc_tx_trg_modid = rpm_noc_modid;
                rin_noc_tx_mode = rpm_noc_mode;
                rin_noc_tx_addr = {tcu_cur_time_i[NOC_ADDR_SIZE-TCU_EP_SIZE-1:0], rpm_noc_addr[TCU_EP_SIZE-1:0]};   //insert kind of randomness into addr field due to ARQ protocol
                rin_noc_tx_data0 = rpm_noc_data0;
                rin_noc_tx_data1 = rpm_noc_data1;
            end

            //send payload of reply message
            else if (TCU_ENABLE_CMDS && (rpm_mem_rdata_valid || r_rpm_mem_rdata_inreg)) begin
                rin_noc_tx_wrreq = 1'b1;
                rin_noc_tx_burst = rpm_noc_burst;
                rin_noc_tx_bsel = rpm_noc_bsel;

                rin_rpm_mem_rdata_inreg = 1'b0;
                if (r_rpm_mem_rdata_inreg) begin
                    rin_noc_tx_data0 = r_mem_rdata[63:0];
                    rin_noc_tx_data1 = r_mem_rdata[127:64];
                end else begin
                    rin_noc_tx_data0 = mem_rdata_i[63:0];
                    rin_noc_tx_data1 = mem_rdata_i[127:64];
                end
            end
        end

        //when NoC stall prevents sending, keep old value so that wrreq is still on when stall turns off
        else begin
            rin_noc_tx_wrreq = r_noc_tx_wrreq;
        end

        //and hold already loaded mem data to write to NoC IF regs as soon as stall turns off
        if (noc_tx_stall_i || rm_noc_wrreq || mar_noc_wrreq || noc_req_done) begin
            if (mas_mem_rdata_valid) begin
                rin_mas_mem_rdata_inreg = 1'b1;
                rin_mem_rdata = mem_rdata_i;
            end
            else if (sm_mem_rdata_valid) begin
                rin_sm_mem_rdata_inreg = 1'b1;
                rin_mem_rdata = mem_rdata_i;
            end
            else if (rpm_mem_rdata_valid) begin
                rin_rpm_mem_rdata_inreg = 1'b1;
                rin_mem_rdata = mem_rdata_i;
            end
        end

        //NoC data is only valid during mem enable
        if (mas_mem_en[0]) begin
            rin_mas_noc_bsel = mas_noc_bsel;
            rin_mas_noc_addr = mas_noc_addr;
        end
    end
    endgenerate



    assign noc_tx_src_chipid_o = home_chipid_i;
    assign noc_tx_src_modid_o = HOME_MODID;


    assign noc_tx_wrreq_o = r_noc_tx_wrreq;
    assign noc_tx_burst_o = r_noc_tx_burst;
    assign noc_tx_bsel_o = r_noc_tx_bsel;
    assign noc_tx_trg_chipid_o = r_noc_tx_trg_chipid;
    assign noc_tx_trg_modid_o = r_noc_tx_trg_modid;
    assign noc_tx_mode_o = r_noc_tx_mode;
    assign noc_tx_addr_o = r_noc_tx_addr;
    assign noc_tx_data0_o = r_noc_tx_data0;
    assign noc_tx_data1_o = r_noc_tx_data1;


    assign noc_error_flit_count_o = r_noc_error_flit_count;
    assign noc_drop_flit_count_o = r_noc_drop_flit_count;



    generate
    //---------------
    //state machine for incoming NoC packets
    always @* begin
        noc_rx_stall_o = 1'b1;

        next_noc_state = noc_state;

        rin_noc_rx_bsel = r_noc_rx_bsel;
        rin_noc_rx_mode = r_noc_rx_mode;
        rin_noc_rx_chipid = r_noc_rx_chipid;
        rin_noc_rx_modid = r_noc_rx_modid;
        rin_noc_rx_addr = r_noc_rx_addr;
        rin_noc_rx_data0 = r_noc_rx_data0;
        rin_noc_rx_data1 = r_noc_rx_data1;
        rin_noc_rx_retaddr = r_noc_rx_retaddr;
        rin_noc_rx_read_size = r_noc_rx_read_size;

        rin_write_ack_recv = 1'b0;
        rin_msg_ack_recv = 1'b0;
        rin_rsp_recv = 1'b0;
        rin_rsp_error = TCU_ERROR_NONE;
        rin_rsp_size = r_rsp_size;
        rin_rsp_abort = r_rsp_abort;

        rin_tmp_recvep = r_tmp_recvep;

        rin_reqfifo_push = 1'b0;

        rin_noc_error_flit_count = r_noc_error_flit_count;
        rin_noc_drop_flit_count = r_noc_drop_flit_count;

        tcu_log_noc_data = TCU_LOG_NONE;


        case (noc_state)

            //---------------
            //wait for incoming NoC packet
            S_NOC_IDLE: begin

                if (noc_rx_wrreq_i) begin

                    //we should not end up here when evaluating the payload of a burst
                    //if header is correct, work on payload in corresponding state

                    //check again if this packet is for us, and last packet was not burst
                    if ((noc_rx_trg_chipid_i == home_chipid_i) && (noc_rx_trg_modid_i == HOME_MODID) && !r_noc_rx_burst) begin

                        //write or write from response
                        if ((noc_rx_mode_i == MODE_WRITE_POSTED) || (noc_rx_mode_i == MODE_READ_RSP) ||
                            (noc_rx_mode_i == MODE_WRITE_POSTED_2) || (noc_rx_mode_i == MODE_READ_RSP_2)) begin
                            rin_noc_rx_bsel = noc_rx_bsel_i;
                            rin_noc_rx_chipid = noc_rx_src_chipid_i;
                            rin_noc_rx_modid = noc_rx_src_modid_i;
                            rin_noc_rx_mode = noc_rx_mode_i;
                            rin_noc_rx_addr = noc_rx_addr_i;
                            rin_noc_rx_data0 = noc_rx_data0_i;

                            //access to TCU reg
                            if (noc_rx_addr_i[(NOC_ADDR_SIZE-4)+:4] == TCU_REGADDR_START[(NOC_ADDR_SIZE-4)+:4]) begin

                                //check that NoC packet is not burst
                                if (noc_rx_burst_i) begin
                                    //release packet and do nothing
                                    noc_rx_stall_o = 1'b0;
                                    rin_noc_error_flit_count = r_noc_error_flit_count + 1;
                                    rin_noc_drop_flit_count = r_noc_drop_flit_count + 1;

                                    `TCU_DEBUG(("NOC_REG_WRITE burst enabled. Packet dropped!"));
                                    tcu_log_noc_data = {noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_REG_WRITE_ERR};
                                end
                                else begin
                                    next_noc_state = S_NOC_TCU_REG_WRITE;

                                    `TCU_DEBUG(("NOC_REG_WRITE, mode: %d, src-(chip:mod): %d:0x%x, addr: 0x%x, data0: 0x%x",
                                        noc_rx_mode_i, noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i, noc_rx_data0_i));
                                    tcu_log_noc_data = {noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_REG_WRITE};
                                end
                            end
                            else begin
                                //check if we expect a response
                                if (TCU_ENABLE_CMDS && ((noc_rx_mode_i == MODE_READ_RSP) || (noc_rx_mode_i == MODE_READ_RSP_2))) begin
                                    if (marq_read_wait) begin
                                        //keep number of received bytes to know when request finished
                                        if (noc_rx_burst_i) begin
                                            //16*#flits - (15-bsel_first) - (15-bsel_last)
                                            rin_rsp_size = {noc_rx_data0_i[31:0], 4'h0} - (4'd15-noc_rx_bsel_i[3:0]) - (4'd15-noc_rx_bsel_i[7:4]);
                                        end else begin
                                            rin_rsp_size = count_ones8(noc_rx_bsel_i);
                                        end

                                        //if read was aborted, drop the corresponding response
                                        if (unpriv_read_abort &&
                                            (marq_noc_chipid == noc_rx_src_chipid_i) &&
                                            (marq_noc_modid == noc_rx_src_modid_i)) begin
                                            rin_rsp_abort = 1'b1;
                                        end

                                        next_noc_state = S_NOC_MEM_WRITE_PAUSE;

                                        `TCU_DEBUG(("NOC_READ_RSP, mode: %d, src-(chip:mod): %d:0x%x, addr: 0x%x",
                                            noc_rx_mode_i, noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i));
                                        tcu_log_noc_data = {noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_READ_RSP};
                                    end
                                    else begin
                                        //release packet and do nothing
                                        noc_rx_stall_o = 1'b0;
                                        rin_noc_error_flit_count = r_noc_error_flit_count + 1;
                                        rin_noc_drop_flit_count = r_noc_drop_flit_count + 1;

                                        `TCU_DEBUG(("NOC_READ_RSP, mode: %d, src-(chip:mod): %d:0x%x, addr: 0x%x, no response expected. Packet dropped!",
                                            noc_rx_mode_i, noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i));
                                        tcu_log_noc_data = {noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_READ_RSP_ERR};
                                    end
                                end

                                //normal write
                                else begin
                                    next_noc_state = S_NOC_MEM_WRITE_PAUSE;

                                    `TCU_DEBUG(("NOC_WRITE, mode: %d, src-(chip:mod): %d:0x%x, addr: 0x%x",
                                        noc_rx_mode_i, noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i));
                                    tcu_log_noc_data = {noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_WRITE};
                                end
                            end
                        end

                        //read
                        else if ((noc_rx_mode_i == MODE_READ_REQ) || (noc_rx_mode_i == MODE_READ_REQ_2)) begin
                            rin_noc_rx_bsel = noc_rx_bsel_i;
                            rin_noc_rx_chipid = noc_rx_src_chipid_i;
                            rin_noc_rx_modid = noc_rx_src_modid_i;
                            rin_noc_rx_mode = noc_rx_mode_i;
                            rin_noc_rx_addr = noc_rx_addr_i;
                            rin_noc_rx_retaddr = noc_rx_data0_i[31:0];
                            rin_noc_rx_read_size = noc_rx_data0_i[63:32];

                            //only push to FIFO if no burst, FIFO not full, and read size not 0 (or 8 for reg access)
                            //else release packet and do nothing
                            if (noc_rx_burst_i || reqfifo_full || (noc_rx_data0_i[63:32] == 32'h0) ||
                                    ((noc_rx_addr_i[(NOC_ADDR_SIZE-4)+:4] == TCU_REGADDR_START[(NOC_ADDR_SIZE-4)+:4]) &&
                                    (noc_rx_data0_i[63:32] != 32'h8))) begin
                                rin_noc_error_flit_count = r_noc_error_flit_count + 1;
                                rin_noc_drop_flit_count = r_noc_drop_flit_count + 1;

                                `TCU_DEBUG(("NOC_READ, mode: %d, src-(chip:mod): %d:0x%x, addr: 0x%x, #bytes: %0d, invalid read request. Packet dropped!",
                                    noc_rx_mode_i, noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i, noc_rx_data0_i[63:32]));
                                tcu_log_noc_data = {noc_rx_data0_i[63:32], noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_READ_ERR};
                            end
                            else begin
                                rin_reqfifo_push = 1'b1;

                                `TCU_DEBUG(("NOC_READ, mode: %d, src-(chip:mod): %d:0x%x, addr: 0x%x, #bytes: %0d",
                                    noc_rx_mode_i, noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i, noc_rx_data0_i[63:32]));

                                //do not log reads of log
                                if ((noc_rx_addr_i < TCU_REGADDR_TCU_LOG) || (noc_rx_addr_i >= (TCU_REGADDR_TCU_LOG+TCU_LOG_REG_COUNT*8))) begin
                                    tcu_log_noc_data = {noc_rx_data0_i[63:32], noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_READ};
                                end
                            end

                            noc_rx_stall_o = 1'b0;
                        end

                        //receive new message
                        else if (TCU_ENABLE_CMDS && (noc_rx_mode_i == MODE_TCU_MSG)) begin

                            //should be a burst of at least 1 flit (header + payload)
                            if (noc_rx_burst_i && (noc_rx_data0_i >= 64'h1)) begin
                                rin_tmp_recvep = noc_rx_addr_i[TCU_EP_SIZE-1:0];  //read recv ep
                                noc_rx_stall_o = 1'b0;  //already release packet, because we need the NoC payload

                                //RECEIVE must not start when FETCH or ACK is active
                                if (firecmd_start || fm_active || am_active || read_initep_start_s || read_initep_active ||
                                    (ctrl_state_s == S_CTRL_SEND_MSG_START) ||
                                    (ctrl_state_s == S_CTRL_REPLY_MSG_START)) begin
                                    next_noc_state = S_NOC_RECEIVE_MSG_WAIT;
                                end else begin
                                    //first go to pause state to keep sender active if needed
                                    next_noc_state = S_NOC_RECEIVE_MSG_PAUSE;
                                end

                                `TCU_DEBUG(("NOC_MSG, src-(chip:mod): %d:0x%x, recv-ep: %0d",
                                    noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i[TCU_EP_SIZE-1:0]));
                                tcu_log_noc_data = {noc_rx_addr_i[TCU_EP_SIZE-1:0], noc_rx_src_modid_i, TCU_LOG_NOC_MSG};
                            end
                            else begin
                                //release packet and do nothing
                                noc_rx_stall_o = 1'b0;
                                rin_noc_error_flit_count = r_noc_error_flit_count + 1;
                                rin_noc_drop_flit_count = r_noc_drop_flit_count + 1;

                                `TCU_DEBUG(("NOC_MSG, src-(chip:mod: %d:0x%x, recv-ep: %0d. Invalid header packet received. Packet dropped!",
                                    noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i[TCU_EP_SIZE-1:0]));
                                tcu_log_noc_data = {noc_rx_addr_i[TCU_EP_SIZE-1:0], noc_rx_src_modid_i, TCU_LOG_NOC_MSG_INV};
                            end
                        end

                        //receive ack (should not be a burst)
                        else if (TCU_ENABLE_CMDS && (noc_rx_mode_i == MODE_TCU_ACK)) begin
                            if (!noc_rx_burst_i) begin
                                rin_noc_rx_addr = noc_rx_addr_i;  //read label from original send ep or WRITE addr
                                rin_noc_rx_chipid = noc_rx_src_chipid_i;
                                rin_noc_rx_modid = noc_rx_src_modid_i; //read incoming modid

                                //WRITE ACK or MSG ACK
                                if (noc_rx_data0_i[32]) begin
                                    rin_write_ack_recv = 1'b1;
                                    rin_noc_rx_data0 = noc_rx_data0_i[31:0];     //read WRITE size

                                    `TCU_DEBUG(("NOC_WRITE_ACK, src-(chip:mod): %d:0x%x, addr: 0x%0x, size: %0d",
                                        noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i, noc_rx_data0_i[31:0]));
                                    tcu_log_noc_data = {noc_rx_data0_i[31:0], noc_rx_addr_i, noc_rx_src_modid_i, TCU_LOG_NOC_WRITE_ACK};
                                end
                                else begin
                                    rin_msg_ack_recv = 1'b1;
                                    rin_noc_rx_data0 = noc_rx_data0_i[TCU_ERROR_SIZE-1:0];     //read incoming error type

                                    `TCU_DEBUG(("NOC_MSG_ACK, src-(chip:mod): %d:0x%x, label: 0x%0x, error: %0d",
                                        noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i, noc_rx_data0_i[TCU_ERROR_SIZE-1:0]));
                                    tcu_log_noc_data = {noc_rx_data0_i[TCU_ERROR_SIZE-1:0], noc_rx_src_modid_i, TCU_LOG_NOC_MSG_ACK};
                                end

                                noc_rx_stall_o = 1'b0;
                                next_noc_state = S_NOC_RECV_ACK;
                            end

                            //no valid packet: release packet and do nothing
                            else begin
                                noc_rx_stall_o = 1'b0;
                                rin_noc_error_flit_count = r_noc_error_flit_count + 1;
                                rin_noc_drop_flit_count = r_noc_drop_flit_count + 1;

                                `TCU_DEBUG(("NOC_ACK burst enabled. Packet dropped!"));
                                tcu_log_noc_data = {noc_rx_data0_i[31:0], noc_rx_src_modid_i, TCU_LOG_NOC_ACK_ERR};
                            end
                        end

                        //receive error packet
                        else if (TCU_ENABLE_CMDS && (noc_rx_mode_i == MODE_ERROR)) begin
                            //check if we expect a response from this sender
                            if (marq_read_wait &&
                                (marq_noc_chipid == noc_rx_src_chipid_i) &&
                                (marq_noc_modid == noc_rx_src_modid_i)) begin
                                rin_rsp_recv = 1'b1;
                                rin_rsp_error = noc_rx_data0_i[TCU_ERROR_SIZE-1:0];     //read incoming error type
                                noc_rx_stall_o = 1'b0;

                                `TCU_DEBUG(("NOC_ERROR, src-(chip:mod): %d:0x%x, addr: 0x%0x, error: %0d",
                                    noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i, noc_rx_data0_i[TCU_ERROR_SIZE-1:0]));
                                tcu_log_noc_data = {noc_rx_data0_i[TCU_ERROR_SIZE-1:0], noc_rx_addr_i, noc_rx_src_modid_i, TCU_LOG_NOC_ERROR};
                            end
                            else begin
                                //release packet and do nothing
                                noc_rx_stall_o = 1'b0;
                                rin_noc_error_flit_count = r_noc_error_flit_count + 1;
                                rin_noc_drop_flit_count = r_noc_drop_flit_count + 1;

                                `TCU_DEBUG(("NOC_ERROR, src-(chip:mod): %d:0x%x, addr: 0x%0x, error: %0d, no response expected. Packet ignored!",
                                    noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_addr_i, noc_rx_data0_i[TCU_ERROR_SIZE-1:0]));
                                tcu_log_noc_data = {noc_rx_data0_i[TCU_ERROR_SIZE-1:0], noc_rx_addr_i, noc_rx_src_modid_i, TCU_LOG_NOC_ERROR_UNEXP};
                            end
                        end

                        //invalid mode
                        else begin
                            //release packet and do nothing
                            noc_rx_stall_o = 1'b0;
                            rin_noc_error_flit_count = r_noc_error_flit_count + 1;
                            rin_noc_drop_flit_count = r_noc_drop_flit_count + 1;

                            if (noc_rx_burst_i) begin
                                `TCU_DEBUG(("NOC packet with invalid mode received. src-(chip:mod): %d:0x%x, mode: %d, addr: 0x%x, burst flag: 1, burst length: %d. Packet dropped!",
                                    noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_mode_i, noc_rx_addr_i, noc_rx_data0_i[12:0]));
                                tcu_log_noc_data = {noc_rx_data0_i[12:0], 1'b1, noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_INVMODE};
                            end else begin
                                `TCU_DEBUG(("NOC packet with invalid mode received. src-(chip:mod): %d:0x%x, mode: %d, addr: 0x%x, burst flag: 0. Packet dropped!",
                                    noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_mode_i, noc_rx_addr_i));
                                tcu_log_noc_data = {13'h8, 1'b0, noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_INVMODE};
                            end
                        end
                    end
                    else begin
                        //release packet and do nothing
                        noc_rx_stall_o = 1'b0;
                        rin_noc_drop_flit_count = r_noc_drop_flit_count + 1;

                        //it is not an error packet when NoC header was correctly dropped and the payload is now dropped here
                        if (!r_noc_rx_burst) begin
                            rin_noc_error_flit_count = r_noc_error_flit_count + 1;

                            if (noc_rx_burst_i) begin
                                `TCU_DEBUG(("NOC invalid packet received. src-(chip:mod): %d:0x%x, mode: %d, addr: 0x%x, burst flag: 1, burst length: %d. Packet dropped!",
                                    noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_mode_i, noc_rx_addr_i, noc_rx_data0_i[12:0]));
                                tcu_log_noc_data = {noc_rx_data0_i[12:0], 1'b1, noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_INVFLIT};
                            end else begin
                                `TCU_DEBUG(("NOC invalid packet received. src-(chip:mod): %d:0x%x, mode: %d, addr: 0x%x, burst flag: 0. Packet dropped!",
                                    noc_rx_src_chipid_i, noc_rx_src_modid_i, noc_rx_mode_i, noc_rx_addr_i));
                                tcu_log_noc_data = {13'h8, 1'b0, noc_rx_addr_i, noc_rx_mode_i, noc_rx_src_modid_i, TCU_LOG_NOC_INVFLIT};
                            end
                        end
                    end
                end
            end

            //---------------
            //write NoC data reg
            S_NOC_TCU_REG_WRITE: begin
                //postpone this until no ext cmd has started right now because this reg-write could trigger an external cmd
                if (!reg_stall_i &&
                    !ctrl_reg_access &&
                    !ctrl_ext_reg_access &&
                    !ctrl_priv_reg_access &&
                    !tcu_fire_i[0] &&
                    !firecmd_start &&
                    !firecmd_ext_start) begin
                    noc_rx_stall_o = 1'b0;
                    next_noc_state = S_NOC_IDLE;
                end
            end
            
            //---------------
            //if there is no incoming packet at the moment, grant access to sender
            S_NOC_MEM_WRITE_PAUSE: begin
                //if receiver is stalled, do not pass next data to reg
                if (!send_active && mar_noc_fifo_pop) begin
                    rin_noc_rx_data0 = noc_rx_data0_i;
                    rin_noc_rx_data1 = noc_rx_data1_i;
                end

                if (mar_noc_fifo_pop) begin
                    noc_rx_stall_o = 1'b0;
                end

                if (mar_done) begin
                    //check if this was the response we were waiting for
                    if (TCU_ENABLE_CMDS && (r_noc_rx_mode == MODE_READ_RSP) &&
                        (r_noc_rx_chipid == marq_noc_chipid) &&
                        (r_noc_rx_modid == marq_noc_modid)) begin
                        rin_rsp_recv = 1'b1;
                        rin_rsp_abort = 1'b0;
                        if (mar_error != TCU_ERROR_NONE) begin
                            rin_rsp_error = mar_error;
                            tcu_log_noc_data = {mar_error, marq_noc_modid, TCU_LOG_NOC_READ_RSP_DONE};
                        end

                        `TCU_DEBUG(("NOC_MEM_WRITE response received from (chip:mod): %d:0x%x, error: %0d",
                            marq_noc_chipid, marq_noc_modid, mar_error));
                    end

                    //todo: if something went wrong during normal write
                    //else if (mar_error != TCU_ERROR_NONE) begin
                    //  //send error packet back to sender
                    //end

                    next_noc_state = S_NOC_IDLE;
                end
                else if (!noc_rx_wrreq_i || send_active) begin
                    next_noc_state = S_NOC_MEM_WRITE_PAUSE;
                end else begin
                    next_noc_state = S_NOC_MEM_WRITE;
                end
            end

            //write NoC data to local mem
            S_NOC_MEM_WRITE: begin
                //if receiver is stalled, do not pass next data to reg
                if (!send_active && mar_noc_fifo_pop) begin
                    rin_noc_rx_data0 = noc_rx_data0_i;
                    rin_noc_rx_data1 = noc_rx_data1_i;
                end

                if (mar_noc_fifo_pop) begin
                    noc_rx_stall_o = 1'b0;
                end

                if (mar_done) begin
                    //check if this was the response we were waiting for
                    if (TCU_ENABLE_CMDS && (r_noc_rx_mode == MODE_READ_RSP) &&
                        (r_noc_rx_chipid == marq_noc_chipid) &&
                        (r_noc_rx_modid == marq_noc_modid)) begin
                        rin_rsp_recv = 1'b1;
                        rin_rsp_abort = 1'b0;
                        if (mar_error != TCU_ERROR_NONE) begin
                            rin_rsp_error = mar_error;
                            tcu_log_noc_data = {mar_error, marq_noc_modid, TCU_LOG_NOC_READ_RSP_DONE};
                        end

                        `TCU_DEBUG(("NOC_MEM_WRITE response received from (chip:mod): %d:0x%x, error: %0d",
                            marq_noc_chipid, marq_noc_modid, mar_error));
                    end

                    //todo: if something went wrong during normal write
                    //else if (mar_error != TCU_ERROR_NONE) begin
                    //  //send error packet back to sender
                    //end

                    next_noc_state = S_NOC_IDLE;
                end
                else if ((!noc_rx_wrreq_i || send_active) && !mem_wstall_i) begin
                    next_noc_state = S_NOC_MEM_WRITE_PAUSE;
                end
                else begin
                    next_noc_state = S_NOC_MEM_WRITE;
                end
            end

            //---------------
            //wait until FETCH or ACK completed to prevent race condition
            S_NOC_RECEIVE_MSG_WAIT: begin
                if (!firecmd_start && !read_initep_active && !fm_active && !am_active) begin
                    next_noc_state = S_NOC_RECEIVE_MSG_PAUSE;
                end
            end

            //if there is no incoming packet at the moment, grant access to sender
            S_NOC_RECEIVE_MSG_PAUSE: begin
                //if recveiver is stalled, do not pass next data to reg
                if (!send_active && rm_noc_fifo_pop) begin
                    rin_noc_rx_data0 = noc_rx_data0_i;
                    rin_noc_rx_data1 = noc_rx_data1_i;
                end

                if (rm_noc_fifo_pop) begin
                    noc_rx_stall_o = 1'b0;
                end

                if (rm_done) begin
                    next_noc_state = S_NOC_IDLE;
                end else if (!noc_rx_wrreq_i || send_active) begin
                    next_noc_state = S_NOC_RECEIVE_MSG_PAUSE;
                end else begin
                    next_noc_state = S_NOC_RECEIVE_MSG;
                end
            end

            //stay here while tcu_ctrl_recv_msg handles receiving messages
            S_NOC_RECEIVE_MSG: begin
                //if recveiver is stalled, do not pass next data to reg
                if (!send_active && rm_noc_fifo_pop) begin
                    rin_noc_rx_data0 = noc_rx_data0_i;
                    rin_noc_rx_data1 = noc_rx_data1_i;
                end

                if (rm_noc_fifo_pop) begin
                    noc_rx_stall_o = 1'b0;
                end

                //done or current packet does not belong to this message
                if (rm_done) begin
                    next_noc_state = S_NOC_IDLE;
                end
                else if ((!noc_rx_wrreq_i || send_active) && !mem_wstall_i) begin
                    next_noc_state = S_NOC_RECEIVE_MSG_PAUSE;
                end
                else begin
                    next_noc_state = S_NOC_RECEIVE_MSG;
                end
            end

            //---------------
            //receive ack from send or reply command
            S_NOC_RECV_ACK: begin
                next_noc_state = S_NOC_IDLE;
            end

            default: next_noc_state = S_NOC_IDLE;
        endcase //case (noc_state)
    end
    endgenerate





    tcu_ctrl_noc_req #(
        .REQFIFO_DATA_SIZE  (2*NOC_ADDR_SIZE+32+NOC_MODE_SIZE+NOC_CHIPID_SIZE+NOC_MODID_SIZE+NOC_BSEL_SIZE),
        .REQFIFO_ADDR_SIZE  (3)
    ) i_tcu_ctrl_noc_req (
        .clk_i              (clk_i),
        .reset_n_i          (reset_ctrl_n),

        //---------------
        //FIFO signals
        .reqfifo_push_i	    (r_reqfifo_push),
        .reqfifo_full_o     (reqfifo_full),
        .reqfifo_wdata_i    ({r_noc_rx_addr, r_noc_rx_retaddr, r_noc_rx_read_size, r_noc_rx_mode, r_noc_rx_chipid, r_noc_rx_modid, r_noc_rx_bsel}),
        .reqfifo_rdata_o    ({reqfifo_addr, reqfifo_retaddr, reqfifo_read_size, reqfifo_mode, reqfifo_chipid, reqfifo_modid, reqfifo_bsel}),

        //---------------
        //reg IF
        .reg_en_o           (noc_req_reg_en),
        .reg_rdata_i        (reg_rdata_i),
        .reg_retdata_o      (noc_req_reg_retdata),
        .reg_stall_i        (reg_stall_i ||
                                ctrl_reg_access || ctrl_ext_reg_access || ctrl_priv_reg_access ||
                                (noc_state == S_NOC_TCU_REG_WRITE) || tcu_fire_i[0] || firecmd_start || firecmd_ext_start),

        //---------------
        //link to mem_access_send
        .start_noc_send_o   (noc_req_start_noc_send),
        .noc_stall_i        (noc_tx_stall_i || rm_noc_wrreq || mar_noc_wrreq || print_active),

        //---------------
        //stall and done
        //do not stall during noc-request because this could be our request
        //do not stall during cmds which do not send
        .noc_req_stall_i    (mas_active || sm_noc_active || rpm_noc_active || tcu_fire_i[0] ||
                                (tcu_fire_cmd_active && !marq_active && !fm_active && !am_active) ||
                                print_active),
        .noc_req_done_o     (noc_req_done)
    );


    tcu_ctrl_mem_access_send #(
        .TCU_ENABLE_DRAM      (TCU_ENABLE_DRAM),
        .TIMEOUT_SEND_CYCLES  (TIMEOUT_SEND_CYCLES)
    ) i_tcu_ctrl_mem_access_send (
        .clk_i                (clk_i),
        .reset_n_i            (reset_ctrl_n),

        //---------------
        //mem IF
        .mas_mem_en_o         (mas_mem_en),
        .mas_mem_addr_o       (mas_mem_addr),
        .mas_mem_rdata_valid_o(mas_mem_rdata_valid),
        .mas_mem_rdata_avail_i(mem_rdata_avail_i),
        .mas_mem_wdata_o      (mas_mem_wdata),
        .mas_mem_stall_i      (mem_rstall_i || receive_active),

        .noc_stall_i          (noc_tx_stall_i || print_active || rm_noc_wrreq || mar_noc_wrreq || noc_req_done),
        .noc_wrreq_o          (mas_noc_wrreq),
        .noc_burst_o          (mas_noc_burst),
        .noc_bsel_o           (mas_noc_bsel),
        .noc_data0_o          (mas_noc_data0),
        .noc_addr_o           (mas_noc_addr),
        .noc_mode_o           (mas_noc_mode),
        .noc_chipid_o         (mas_noc_chipid),
        .noc_modid_o          (mas_noc_modid),
        .noc_ack_recv_i       (r_write_ack_recv),
        .noc_ack_addr_i       (r_noc_rx_addr),
        .noc_ack_chipid_i     (r_noc_rx_chipid),
        .noc_ack_modid_i      (r_noc_rx_modid),
        .noc_ack_size_i       (r_noc_rx_data0[31:0]),

        //---------------
        //trigger
        .mas_start_i          (mas_start),
        .mas_opcode_i         (mas_opcode),
        .mas_laddr_i          (mas_laddr),
        .mas_raddr_i          (mas_raddr),
        .mas_size_i           (mas_size),
        .mas_chipid_i         (mas_chipid),
        .mas_modid_i          (mas_modid),
        .mas_abort_i          (unpriv_write_abort),
        .mas_active_o         (mas_active),
        .mas_noc_active_o     (mas_noc_active),
        .mas_done_o           (mas_done),
        .mas_error_o          (mas_error)
    );


    tcu_ctrl_mem_access_recv #(
        .TCU_ENABLE_DRAM        (TCU_ENABLE_DRAM),
        .TIMEOUT_RECV_CYCLES    (TIMEOUT_RECV_CYCLES)
    ) i_tcu_ctrl_mem_access_recv (
        .clk_i                  (clk_i),
        .reset_n_i              (reset_ctrl_n),

        //---------------
        //mem IF
        .mar_mem_en_o           (mar_mem_en),
        .mar_mem_wben_o         (mar_mem_wben),
        .mar_mem_addr_o         (mar_mem_addr),
        .mar_mem_wdata_o        (mar_mem_wdata),
        .mar_mem_wdata_infifo_i (mem_wdata_infifo_i),
        .mar_mem_wabort_o       (mar_mem_wabort),
        .mar_mem_stall_i        (mem_wstall_i || send_active),

        //---------------
        //NoC signals
        .noc_stall_i            (noc_tx_stall_i || rm_noc_wrreq || print_active ||
                                    sm_noc_active || rpm_noc_active ||
                                    r_noc_tx_burst), //should not send ACK during ongoing burst
        .noc_fifo_pop_o         (mar_noc_fifo_pop),
        .noc_wrreq_i            (noc_rx_wrreq_i),
        .noc_burst_i            (noc_rx_burst_i),
        .noc_bsel_i             (noc_rx_bsel_i),
        .noc_chipid_i           (noc_rx_src_chipid_i),
        .noc_modid_i            (noc_rx_src_modid_i),
        .noc_addr_i             (noc_rx_addr_i),
        .noc_mode_i             (noc_rx_mode_i),
        .noc_data0_i            (noc_rx_data0_i),
        .noc_wrreq_o            (mar_noc_wrreq),
        .noc_chipid_o           (mar_noc_chipid),
        .noc_modid_o            (mar_noc_modid),
        .noc_addr_o             (mar_noc_addr),
        .noc_data_o             (mar_noc_data),

        //---------------
        //trigger
        .mar_start_i            (r_start_noc_recv),
        .mar_abort_i            (r_rsp_abort),
        .mar_active_o           (mar_active),
        .mar_done_o             (mar_done),
        .mar_error_o            (mar_error),
        .mar_shift_o            (mar_shift)
    );



    generate
    if (TCU_ENABLE_CMDS) begin: MODULES_CMDS

        tcu_ctrl_mem_access_request #(
            .TIMEOUT_SEND_CYCLES  (TIMEOUT_SEND_CYCLES)
        ) i_tcu_ctrl_mem_access_request (
            .clk_i                (clk_i),
            .reset_n_i            (reset_ctrl_n),

            //---------------
            .noc_stall_i          (noc_tx_stall_i || print_active || rm_noc_wrreq || mar_noc_wrreq || noc_req_done ||
                                    mas_noc_wrreq || mas_mem_rdata_valid || r_mas_mem_rdata_inreg), //mas has prio over marq and could be executed at the same time
            .noc_wrreq_o          (marq_noc_wrreq),
            .noc_data0_o          (marq_noc_data0),
            .noc_addr_o           (marq_noc_addr),
            .noc_chipid_o         (marq_noc_chipid),
            .noc_modid_o          (marq_noc_modid),
            .noc_rsp_recv_i       (r_rsp_recv),
            .noc_rsp_error_i      (r_rsp_error),
            .noc_rsp_size_i       (r_rsp_size),

            //---------------
            //trigger
            .marq_start_i         (marq_start),
            .marq_opcode_i        (marq_opcode),
            .marq_laddr_i         (marq_laddr),
            .marq_raddr_i         (marq_raddr),
            .marq_size_i          (marq_size),
            .marq_chipid_i        (marq_chipid),
            .marq_modid_i         (marq_modid),
            .marq_abort_i         (unpriv_read_abort),
            .marq_read_wait_o     (marq_read_wait),
            .marq_active_o        (marq_active),
            .marq_noc_active_o    (marq_noc_active),
            .marq_done_o          (marq_done),
            .marq_error_o         (marq_error)
        );


        tcu_ctrl_send_msg #(
            .TCU_ENABLE_DRAM         (TCU_ENABLE_DRAM),
            .TCU_ENABLE_VIRT_ADDR    (TCU_ENABLE_VIRT_ADDR),
            .TCU_ENABLE_VIRT_PES     (TCU_ENABLE_VIRT_PES),
            .HOME_MODID              (HOME_MODID),
            .TIMEOUT_SEND_CYCLES     (TIMEOUT_SEND_CYCLES)
        ) i_tcu_ctrl_send_msg (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_ctrl_n),

            //---------------
            //reg IF
            .sm_reg_en_o             (sm_reg_en),
            .sm_reg_wben_o           (sm_reg_wben),
            .sm_reg_addr_o           (sm_reg_addr),
            .sm_reg_wdata_o          (sm_reg_wdata),
            .sm_reg_rdata_i          (reg_rdata_i),
            .sm_reg_stall_i          (reg_stall_i || print_active || rm_reg_en || read_initep_active),

            //---------------
            //mem IF
            .sm_mem_en_o             (sm_mem_en),
            .sm_mem_addr_o           (sm_mem_addr),
            .sm_mem_rdata_valid_o    (sm_mem_rdata_valid),
            .sm_mem_rdata_avail_i    (mem_rdata_avail_i),
            .sm_mem_wdata_o          (sm_mem_wdata),
            .sm_mem_stall_i          (mem_rstall_i || receive_active),

            //---------------
            //TLB IF
            .tlb_read_o              (sm_tlb_read),
            .tlb_physpage_i          (unpriv_tlb_physpage),
            .tlb_read_done_i         (unpriv_tlb_read_done),
            .tlb_read_error_i        (unpriv_tlb_read_error),
            .tlb_active_i            (unpriv_tlb_active),

            //---------------
            //NoC signals
            .noc_stall_i             (noc_tx_stall_i || print_active || rm_noc_wrreq || mar_noc_wrreq || noc_req_done),
            .noc_wrreq_o             (sm_noc_wrreq),
            .noc_burst_o             (sm_noc_burst),
            .noc_bsel_o              (sm_noc_bsel),
            .noc_data0_o             (sm_noc_data0),
            .noc_data1_o             (sm_noc_data1),
            .noc_addr_o              (sm_noc_addr),
            .noc_mode_o              (sm_noc_mode),
            .noc_chipid_o            (sm_noc_chipid),
            .noc_modid_o             (sm_noc_modid),
            .noc_ack_recv_i          (r_msg_ack_recv),
            .noc_ack_addr_i          (r_noc_rx_addr),
            .noc_ack_chipid_i        (r_noc_rx_chipid),
            .noc_ack_modid_i         (r_noc_rx_modid),
            .noc_ack_error_i         (r_noc_rx_data0[TCU_ERROR_SIZE-1:0]),

            //---------------
            //trigger
            .sm_start_i              (CMD_CTRL.r_firecmd_start),
            .sm_opcode_i             (CMD_CTRL.r_firecmd_opcode),
            .sm_laddr_i              (CMD_CTRL.r_firecmd_data_addr[31:0]),
            .sm_size_i               (CMD_CTRL.r_firecmd_data_size[31:0]),
            .sm_sendep_i             (CMD_CTRL.r_firecmd_ep),
            .sm_epdata_i             ({CMD_CTRL.epdata_2, CMD_CTRL.epdata_1, CMD_CTRL.epdata_0}),
            .sm_replyep_i            (CMD_CTRL.r_firecmd_replyep),
            .sm_replylabel_i         (CMD_CTRL.r_firecmd_replylabel),
            .sm_cur_vpeid_i          (tcu_fire_cur_vpe_i[TCU_VPEID_SIZE-1:0]),
            .sm_abort_i              (unpriv_send_abort),
            .sm_crd_update_stall_i   (rm_crd_update_active),
            .sm_active_o             (sm_active),
            .sm_noc_active_o         (sm_noc_active),
            .sm_done_o               (sm_done),
            .sm_error_o              (sm_error),

            //---------------
            //TCU feature settings
            .tcu_features_virt_addr_i(tcu_features_virt_addr_i),
            .tcu_features_virt_pes_i (tcu_features_virt_pes_i),

            .home_chipid_i           (home_chipid_i)
        );


        tcu_ctrl_recv_msg #(
            .TCU_ENABLE_VIRT_PES     (TCU_ENABLE_VIRT_PES),
            .TCU_ENABLE_DRAM         (TCU_ENABLE_DRAM),
            .TCU_ENABLE_LOG          (TCU_ENABLE_LOG),
            .TIMEOUT_RECV_CYCLES     (TIMEOUT_RECV_CYCLES)
        ) i_tcu_ctrl_recv_msg (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_ctrl_n),

            //---------------
            //reg IF
            .rm_reg_en_o             (rm_reg_en),
            .rm_reg_wben_o           (rm_reg_wben),
            .rm_reg_addr_o           (rm_reg_addr),
            .rm_reg_wdata_o          (rm_reg_wdata),
            .rm_reg_rdata_i          (reg_rdata_i),
            .rm_reg_stall_i          (reg_stall_i || print_active),

            //---------------
            //mem IF
            .rm_mem_en_o             (rm_mem_en),
            .rm_mem_wben_o           (rm_mem_wben),
            .rm_mem_addr_o           (rm_mem_addr),
            .rm_mem_wdata_o          (rm_mem_wdata),
            .rm_mem_wdata_infifo_i   (mem_wdata_infifo_i),
            .rm_mem_wabort_o         (rm_mem_wabort),
            .rm_mem_stall_i          (mem_wstall_i || send_active),

            //---------------
            //NoC signals
            .noc_fifo_pop_o          (rm_noc_fifo_pop),
            .noc_wrreq_i             (noc_rx_wrreq_i),
            .noc_burst_i             (noc_rx_burst_i),
            .noc_bsel_i              (noc_rx_bsel_i),
            .noc_stall_i             (noc_tx_stall_i || print_active ||
                                        mas_noc_active || sm_noc_active || rpm_noc_active),
            .noc_wrreq_o             (rm_noc_wrreq),
            .noc_data_o              (rm_noc_data),
            .noc_addr_o              (rm_noc_addr),
            .noc_chipid_o            (rm_noc_chipid),
            .noc_modid_o             (rm_noc_modid),

            //---------------
            //trigger
            .rm_start_i              (start_recv_msg_s),
            .rm_recvep_i             (r_tmp_recvep),
            .rm_header_i             ({noc_rx_data1_i, noc_rx_data0_i}),
            .rm_cur_vpe_i            (tcu_fire_cur_vpe_i[31:0]),
            .rm_active_o             (rm_active),
            .rm_cur_vpe_active_o     (rm_cur_vpe_active),
            .rm_crd_update_active_o  (rm_crd_update_active),
            .rm_done_o               (rm_done),

            //---------------
            //core req: foreign msg
            .rm_core_req_push_o      (rm_core_req_push),
            .rm_core_req_data_o      (rm_core_req_data),
            .rm_core_req_stall_i     (rm_core_req_stall),

            //---------------
            //TCU logging
            .tcu_log_rm_o            (tcu_log_rm),

            //---------------
            //TCU feature settings
            .tcu_features_virt_pes_i (tcu_features_virt_pes_i),

            .home_chipid_i           (home_chipid_i)
        );

        tcu_ctrl_reply_msg #(
            .TCU_ENABLE_DRAM         (TCU_ENABLE_DRAM),
            .TCU_ENABLE_VIRT_ADDR    (TCU_ENABLE_VIRT_ADDR),
            .TCU_ENABLE_VIRT_PES     (TCU_ENABLE_VIRT_PES),
            .HOME_MODID              (HOME_MODID),
            .TIMEOUT_SEND_CYCLES     (TIMEOUT_SEND_CYCLES)
        ) i_tcu_ctrl_reply_msg (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_ctrl_n),

            //---------------
            //reg IF
            .rpm_reg_en_o            (rpm_reg_en),
            .rpm_reg_wben_o          (rpm_reg_wben),
            .rpm_reg_addr_o          (rpm_reg_addr),
            .rpm_reg_wdata_o         (rpm_reg_wdata),
            .rpm_reg_rdata_i         (reg_rdata_i),
            .rpm_reg_stall_i         (reg_stall_i || print_active || rm_reg_en || read_initep_active),

            //---------------
            //mem IF
            .rpm_mem_en_o            (rpm_mem_en),
            .rpm_mem_addr_o          (rpm_mem_addr),
            .rpm_mem_rdata_valid_o   (rpm_mem_rdata_valid),
            .rpm_mem_rdata_avail_i   (mem_rdata_avail_i),
            .rpm_mem_wdata_o         (rpm_mem_wdata),
            .rpm_mem_stall_i         (mem_rstall_i || receive_active),

            //---------------
            //TLB IF
            .tlb_read_o              (rpm_tlb_read),
            .tlb_physpage_i          (unpriv_tlb_physpage),
            .tlb_read_done_i         (unpriv_tlb_read_done),
            .tlb_read_error_i        (unpriv_tlb_read_error),
            .tlb_active_i            (unpriv_tlb_active),

            //---------------
            //NoC signals
            .noc_stall_i             (noc_tx_stall_i || print_active || rm_noc_wrreq || mar_noc_wrreq || noc_req_done),
            .noc_wrreq_o             (rpm_noc_wrreq),
            .noc_burst_o             (rpm_noc_burst),
            .noc_bsel_o              (rpm_noc_bsel),
            .noc_data0_o             (rpm_noc_data0),
            .noc_data1_o             (rpm_noc_data1),
            .noc_addr_o              (rpm_noc_addr),
            .noc_mode_o              (rpm_noc_mode),
            .noc_chipid_o            (rpm_noc_chipid),
            .noc_modid_o             (rpm_noc_modid),
            .noc_ack_recv_i          (r_msg_ack_recv),
            .noc_ack_addr_i          (r_noc_rx_addr),
            .noc_ack_chipid_i        (r_noc_rx_chipid),
            .noc_ack_modid_i         (r_noc_rx_modid),
            .noc_ack_error_i         (r_noc_rx_data0[TCU_ERROR_SIZE-1:0]),

            //---------------
            //trigger
            .rpm_start_i             (CMD_CTRL.r_firecmd_start),
            .rpm_opcode_i            (CMD_CTRL.r_firecmd_opcode),
            .rpm_rmsgoffset_i        (CMD_CTRL.r_firecmd_msgoffset),
            .rpm_laddr_i             (CMD_CTRL.r_firecmd_data_addr),
            .rpm_size_i              (CMD_CTRL.r_firecmd_data_size),
            .rpm_recvep_i            (CMD_CTRL.r_firecmd_ep),
            .rpm_epdata_i            ({CMD_CTRL.epdata_2, CMD_CTRL.epdata_1, CMD_CTRL.epdata_0}),
            .rpm_cur_vpe_i           (tcu_fire_cur_vpe_i[31:0]),
            .rpm_abort_i             (unpriv_reply_abort),
            .rpm_cur_vpe_stall_i     (rm_cur_vpe_active),
            .rpm_active_o            (rpm_active),
            .rpm_noc_active_o        (rpm_noc_active),
            .rpm_done_o              (rpm_done),
            .rpm_error_o             (rpm_error),

            //---------------
            //for logging
            .rpm_log_valid_o         (rpm_log_valid),
            .rpm_log_rpl_chip_o      (rpm_log_rpl_chip),
            .rpm_log_rpl_pe_o        (rpm_log_rpl_pe),

            //---------------
            //TCU feature settings
            .tcu_features_virt_addr_i(tcu_features_virt_addr_i),
            .tcu_features_virt_pes_i (tcu_features_virt_pes_i),

            .home_chipid_i           (home_chipid_i)
        );


        tcu_ctrl_fetch_msg #(
            .TCU_ENABLE_VIRT_PES     (TCU_ENABLE_VIRT_PES)
        ) i_tcu_ctrl_fetch_msg (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_ctrl_n),

            //---------------
            //reg IF
            .fm_reg_en_o             (fm_reg_en),
            .fm_reg_wben_o           (fm_reg_wben),
            .fm_reg_addr_o           (fm_reg_addr),
            .fm_reg_wdata_o          (fm_reg_wdata),
            .fm_reg_stall_i          (reg_stall_i || print_active || rm_reg_en || read_initep_active),

            //---------------
            //trigger
            .fm_start_i              (CMD_CTRL.r_firecmd_start),
            .fm_opcode_i             (CMD_CTRL.r_firecmd_opcode),
            .fm_recvep_i             (CMD_CTRL.r_firecmd_ep),
            .fm_epdata_i             ({CMD_CTRL.epdata_2, CMD_CTRL.epdata_1, CMD_CTRL.epdata_0}),
            .fm_cur_vpe_i            (tcu_fire_cur_vpe_i[31:0]),
            .fm_active_o             (fm_active),
            .fm_msgoffset_o          (fm_msgoffset),
            .fm_fetch_success_o      (fm_fetch_success),
            .fm_done_o               (fm_done),
            .fm_error_o              (fm_error),

            //---------------
            //TCU feature settings
            .tcu_features_virt_pes_i (tcu_features_virt_pes_i)
        );


        tcu_ctrl_ack_msg #(
            .TCU_ENABLE_VIRT_PES     (TCU_ENABLE_VIRT_PES)
        ) i_tcu_ctrl_ack_msg (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_ctrl_n),

            //---------------
            //reg IF
            .am_reg_en_o             (am_reg_en),
            .am_reg_wben_o           (am_reg_wben),
            .am_reg_addr_o           (am_reg_addr),
            .am_reg_wdata_o          (am_reg_wdata),
            .am_reg_rdata_i          (reg_rdata_i),
            .am_reg_stall_i          (reg_stall_i || print_active || rm_reg_en || read_initep_active),

            //---------------
            //trigger
            .am_start_i              (CMD_CTRL.r_firecmd_start),
            .am_opcode_i             (CMD_CTRL.r_firecmd_opcode),
            .am_rmsgoffset_i         (CMD_CTRL.r_firecmd_msgoffset),
            .am_recvep_i             (CMD_CTRL.r_firecmd_ep),
            .am_epdata_i             ({CMD_CTRL.epdata_2, CMD_CTRL.epdata_1, CMD_CTRL.epdata_0}),
            .am_cur_vpe_i            (tcu_fire_cur_vpe_i[31:0]),
            .am_active_o             (am_active),
            .am_done_o               (am_done),
            .am_error_o              (am_error),

            //---------------
            //TCU feature settings
            .tcu_features_virt_pes_i (tcu_features_virt_pes_i)
        );


        tcu_ctrl_ext_invep i_tcu_ctrl_ext_invep (
            .clk_i                 (clk_i),
            .reset_n_i             (reset_ctrl_n),
            
            //---------------
            //reg IF
            .ext_invep_reg_en_o    (ext_invep_reg_en),
            .ext_invep_reg_addr_o  (ext_invep_reg_addr),
            .ext_invep_reg_wdata_o (ext_invep_reg_wdata),
            .ext_invep_reg_stall_i (reg_stall_i || ctrl_reg_access),    //unpriv cmds have prio over ext cmds

            //---------------
            //trigger
            .ext_invep_start_i     (CMD_CTRL.r_firecmd_ext_start),
            .ext_invep_opcode_i    (CMD_CTRL.r_firecmd_ext_opcode),
            .ext_invep_arg_i       (CMD_CTRL.r_firecmd_ext_arg),
            .ext_invep_epdata_i    ({CMD_CTRL.epdata_2, CMD_CTRL.epdata_1, CMD_CTRL.epdata_0}),
            .ext_invep_active_o    (ext_invep_active),
            .ext_invep_done_o      (ext_invep_done),
            .ext_invep_error_o     (ext_invep_error),
            .ext_invep_arg_o       (ext_invep_arg)
        );
    end

    else begin: MODULES_NO_CMDS

        assign sm_reg_en           = 1'b0;
        assign sm_reg_wben         = {TCU_REG_DATA_SIZE{1'b0}};
        assign sm_reg_addr         = {TCU_REG_ADDR_SIZE{1'b0}};
        assign sm_reg_wdata        = {TCU_REG_DATA_SIZE{1'b0}};
        assign rm_reg_en           = 1'b0;
        assign rm_reg_wben         = {TCU_REG_DATA_SIZE{1'b0}};
        assign rm_reg_addr         = {TCU_REG_ADDR_SIZE{1'b0}};
        assign rm_reg_wdata        = {TCU_REG_DATA_SIZE{1'b0}};
        assign rpm_reg_en          = 1'b0;
        assign rpm_reg_wben        = {TCU_REG_DATA_SIZE{1'b0}};
        assign rpm_reg_addr        = {TCU_REG_ADDR_SIZE{1'b0}};
        assign rpm_reg_wdata       = {TCU_REG_DATA_SIZE{1'b0}};
        assign fm_reg_en           = 1'b0;
        assign fm_reg_wben         = {TCU_REG_DATA_SIZE{1'b0}};
        assign fm_reg_addr         = {TCU_REG_ADDR_SIZE{1'b0}};
        assign fm_reg_wdata        = {TCU_REG_DATA_SIZE{1'b0}};
        assign am_reg_en           = 1'b0;
        assign am_reg_wben         = {TCU_REG_DATA_SIZE{1'b0}};
        assign am_reg_addr         = {TCU_REG_ADDR_SIZE{1'b0}};
        assign am_reg_wdata        = {TCU_REG_DATA_SIZE{1'b0}};
        assign ext_invep_reg_en    = 1'b0;
        assign ext_invep_reg_addr  = {TCU_REG_ADDR_SIZE{1'b0}};
        assign ext_invep_reg_wdata = {TCU_REG_DATA_SIZE{1'b0}};

        assign sm_mem_en           = 2'h0;
        assign sm_mem_addr         = {TCU_MEM_ADDR_SIZE{1'b0}};
        assign sm_mem_wdata        = {TCU_MEM_DATA_SIZE{1'b0}};
        assign sm_mem_rdata_valid  = 1'b0;
        assign rm_mem_en           = 3'b0;
        assign rm_mem_wben         = {TCU_MEM_BSEL_SIZE{1'b0}};
        assign rm_mem_addr         = {TCU_MEM_ADDR_SIZE{1'b0}};
        assign rm_mem_wdata        = {TCU_MEM_DATA_SIZE{1'b0}};
        assign rm_mem_wabort       = 1'b0;
        assign rpm_mem_en          = 2'h0;
        assign rpm_mem_addr        = {TCU_MEM_ADDR_SIZE{1'b0}};
        assign rpm_mem_wdata       = {TCU_MEM_DATA_SIZE{1'b0}};
        assign rpm_mem_rdata_valid = 1'b0;

        assign sm_tlb_read = 1'b0;
        assign rpm_tlb_read = 1'b0;

        assign marq_noc_wrreq  = 1'b0;
        assign marq_noc_data0  = {NOC_DATA_SIZE{1'b0}};
        assign marq_noc_addr   = {NOC_ADDR_SIZE{1'b0}};
        assign marq_noc_chipid = {NOC_CHIPID_SIZE{1'b0}};
        assign marq_noc_modid  = {NOC_MODID_SIZE{1'b0}};

        assign sm_noc_wrreq  = 1'b0;
        assign sm_noc_burst  = 1'b0;
        assign sm_noc_bsel   = {NOC_BSEL_SIZE{1'b0}};
        assign sm_noc_data0  = {NOC_DATA_SIZE{1'b0}};
        assign sm_noc_data1  = {NOC_DATA_SIZE{1'b0}};
        assign sm_noc_addr   = {NOC_ADDR_SIZE{1'b0}};
        assign sm_noc_mode   = {NOC_MODE_SIZE{1'b0}};
        assign sm_noc_chipid = {NOC_CHIPID_SIZE{1'b0}};
        assign sm_noc_modid  = {NOC_MODID_SIZE{1'b0}};

        assign rm_noc_fifo_pop  = 1'b0;
        assign rm_noc_wrreq     = 1'b0;
        assign rm_noc_data      = {NOC_DATA_SIZE{1'b0}};
        assign rm_noc_addr      = {NOC_ADDR_SIZE{1'b0}};
        assign rm_noc_chipid    = {NOC_CHIPID_SIZE{1'b0}};
        assign rm_noc_modid     = {NOC_MODID_SIZE{1'b0}};
        assign rm_core_req_push = 1'b0;
        assign rm_core_req_data = {TCU_CORE_REQ_FORMSG_SIZE{1'b0}};

        assign rpm_noc_wrreq  = 1'b0;
        assign rpm_noc_burst  = 1'b0;
        assign rpm_noc_bsel   = {NOC_BSEL_SIZE{1'b0}};
        assign rpm_noc_data0  = {NOC_DATA_SIZE{1'b0}};
        assign rpm_noc_data1  = {NOC_DATA_SIZE{1'b0}};
        assign rpm_noc_addr   = {NOC_ADDR_SIZE{1'b0}};
        assign rpm_noc_mode   = {NOC_MODE_SIZE{1'b0}};
        assign rpm_noc_chipid = {NOC_CHIPID_SIZE{1'b0}};
        assign rpm_noc_modid  = {NOC_MODID_SIZE{1'b0}};

        assign marq_active     = 1'b0;
        assign marq_noc_active = 1'b0;
        assign marq_done       = 1'b0;
        assign marq_error      = TCU_ERROR_NONE;
        assign marq_read_wait  = 1'b0;

        assign sm_active     = 1'b0;
        assign sm_noc_active = 1'b0;
        assign sm_done       = 1'b0;
        assign sm_error      = TCU_ERROR_NONE;

        assign rm_active            = 1'b0;
        assign rm_cur_vpe_active    = 1'b0;
        assign rm_crd_update_active = 1'b0;
        assign rm_done              = 1'b0;
        assign tcu_log_rm           = {TCU_LOG_DATA_SIZE{1'b0}};

        assign rpm_active     = 1'b0;
        assign rpm_noc_active = 1'b0;
        assign rpm_done       = 1'b0;
        assign rpm_error      = TCU_ERROR_NONE;

        assign fm_active        = 1'b0;
        assign fm_fetch_success = 1'b0;
        assign fm_msgoffset     = 32'h0;
        assign fm_done          = 1'b0;
        assign fm_error         = TCU_ERROR_NONE;

        assign am_active = 1'b0;
        assign am_done   = 1'b0;
        assign am_error  = TCU_ERROR_NONE;

        assign ext_invep_active = 1'b0;
        assign ext_invep_done   = 1'b0;
        assign ext_invep_error  = TCU_ERROR_NONE;
        assign ext_invep_arg    = {TCU_EXT_ARG_SIZE{1'b0}};

        assign rpm_log_valid    = 1'b0;
        assign rpm_log_rpl_chip = {TCU_CHIPID_SIZE{1'b0}};
        assign rpm_log_rpl_pe   = {TCU_PEID_SIZE{1'b0}};
    end
    endgenerate


    //FIFO for priv. logs is in module tcu_priv_ctrl
    wire                         log_priv_fifo_pop_s;
    wire                         log_priv_fifo_empty_s;
    wire [TCU_LOG_DATA_SIZE-1:0] log_priv_fifo_data_out_s;


    generate
    if (TCU_ENABLE_CMDS && TCU_ENABLE_PRIV_CMDS) begin: PRIV_CMDS

        tcu_priv_ctrl #(
            .TCU_ENABLE_VIRT_PES     (TCU_ENABLE_VIRT_PES),
            .TCU_REGADDR_CORE_REQ_INT(TCU_REGADDR_CORE_REQ_INT),
            .TCU_REGADDR_TIMER_INT   (TCU_REGADDR_TIMER_INT),
            .TCU_ENABLE_LOG          (TCU_ENABLE_LOG),
            .HOME_MODID              (HOME_MODID),
            .CLKFREQ_MHZ             (CLKFREQ_MHZ)
        ) i_tcu_priv_ctrl (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_ctrl_n),

            //---------------
            //reg IF
            .priv_reg_en_o           (priv_reg_en),
            .priv_reg_wben_o         (priv_reg_wben),
            .priv_reg_addr_o         (priv_reg_addr),
            .priv_reg_wdata_o        (priv_reg_wdata),
            .priv_reg_rdata_i        (reg_rdata_i),
            .priv_reg_stall_i        (reg_stall_i || ctrl_reg_access || ctrl_ext_reg_access),  //unpriv and ext cmds have prio over priv cmds

            //---------------
            //TLB IF
            .unpriv_tlb_read_i       (CMD_CTRL.unpriv_tlb_read),
            .unpriv_tlb_vpeid_i      (tcu_fire_cur_vpe_i[TCU_TLB_VPEID_SIZE-1:0]),
            .unpriv_tlb_virtpage_i   (CMD_CTRL.r_firecmd_data_addr[TCU_VIRTADDR_SIZE-1 : TCU_VIRTADDR_SIZE-TCU_TLB_VIRTPAGE_SIZE]), //only need virt page number
            .unpriv_tlb_read_perm_i  (CMD_CTRL.r_firecmd_perm),
            .unpriv_tlb_physpage_o   (unpriv_tlb_physpage),
            .unpriv_tlb_active_o     (unpriv_tlb_active),
            .unpriv_tlb_read_done_o  (unpriv_tlb_read_done),
            .unpriv_tlb_read_error_o (unpriv_tlb_read_error),

            //---------------
            //core req (from RECEIVE)
            .core_req_formsg_push_i  (rm_core_req_push),
            .core_req_formsg_data_i  (rm_core_req_data),
            .core_req_formsg_stall_o (rm_core_req_stall),

            //---------------
            //abort cmd
            .unpriv_cmd_opcode_i     (CMD_CTRL.r_firecmd_opcode),
            .unpriv_write_abort_o    (unpriv_write_abort),
            .unpriv_read_abort_o     (unpriv_read_abort),
            .unpriv_send_abort_o     (unpriv_send_abort),
            .unpriv_reply_abort_o    (unpriv_reply_abort),

            //---------------
            //trigger
            .priv_cmd_start_i        (PRIV_CTRL.r_firecmd_priv_start),
            .priv_cmd_opcode_i       (PRIV_CTRL.r_firecmd_priv_opcode),
            .priv_cmd_arg0_i         (PRIV_CTRL.r_firecmd_priv_arg0),
            .priv_cmd_arg1_i         (PRIV_CTRL.r_firecmd_priv_arg1),
            .priv_cmd_cur_vpe_i      (tcu_fire_cur_vpe_i[31:0]),
            .priv_cmd_stall_i        (start_recv_msg_s || rm_active ||
                                        firecmd_start || rpm_active || fm_active || am_active),   //stall xchg_vpe command to prevent race condition

            //---------------
            //TCU feature settings
            .tcu_features_virt_pes_i (tcu_features_virt_pes_i),

            //---------------
            //logging
            .log_priv_fifo_empty_o   (log_priv_fifo_empty_s),
            .log_priv_fifo_data_out_o(log_priv_fifo_data_out_s),
            .log_priv_fifo_pop_i     (log_priv_fifo_pop_s),

            //---------------
            //for debugging
            .home_chipid_i           (home_chipid_i)
        );

    end

    else begin: NO_PRIV_CMDS

        assign priv_reg_en    = 1'b0;
        assign priv_reg_wben  = {TCU_REG_BSEL_SIZE{1'b0}};
        assign priv_reg_addr  = {TCU_REG_ADDR_SIZE{1'b0}};
        assign priv_reg_wdata = {TCU_REG_DATA_SIZE{1'b0}};

        assign unpriv_tlb_physpage   = {TCU_TLB_PHYSPAGE_SIZE{1'b0}};
        assign unpriv_tlb_active     = 1'b0;
        assign unpriv_tlb_read_done  = 1'b0;
        assign unpriv_tlb_read_error = TCU_ERROR_NONE;

        assign rm_core_req_stall = 1'b0;

        assign unpriv_write_abort = 1'b0;
        assign unpriv_read_abort = 1'b0;
        assign unpriv_send_abort = 1'b0;
        assign unpriv_reply_abort = 1'b0;

        assign log_priv_fifo_empty_s = 1'b1;
        assign log_priv_fifo_data_out_s = TCU_LOG_NONE;

    end
    endgenerate



    tcu_ctrl_reset i_tcu_ctrl_reset (
        .clk_i           (clk_i),
        .reset_n_i       (reset_n_i),
        .reset_sync_n_o  (reset_ctrl_n),
        .tcu_reset_i     (tcu_reset_i)
    );


    generate
    if (TCU_ENABLE_LOG) begin: LOGGING
        reg                          rin_tcu_log_en;
        reg  [TCU_LOG_DATA_SIZE-1:0] rin_tcu_log_data;

        wire                         log_unpriv_fifo_push = (tcu_log_unpriv_data_s[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_unpriv_fifo_pop;
        wire                         log_unpriv_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_unpriv_fifo_data_out;

        wire                         log_ext_fifo_push = (tcu_log_ext_data_s[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_ext_fifo_pop;
        wire                         log_ext_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_ext_fifo_data_out;

        wire                         log_noc_fifo_push = (tcu_log_noc_data[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_noc_fifo_pop;
        wire                         log_noc_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_noc_fifo_data_out;

        wire                         log_cur_vpe_fifo_push = (tcu_log_cur_vpe_i[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_cur_vpe_fifo_pop;
        wire                         log_cur_vpe_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_cur_vpe_fifo_data_out;

        wire                         log_rm_fifo_push = (tcu_log_rm[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_rm_fifo_pop;
        wire                         log_rm_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_rm_fifo_data_out;

        wire                         log_pmp_fifo_push = (tcu_log_pmp_i[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_pmp_fifo_pop;
        wire                         log_pmp_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_pmp_fifo_data_out;

        //FIFO for priv. logs is in module tcu_priv_ctrl
        reg                          log_priv_fifo_pop;


        //use FIFOs because logs may occure at the same time
        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (2)
        ) log_unpriv_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_unpriv_fifo_push),
            .wdata_i	(tcu_log_unpriv_data_s),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_unpriv_fifo_pop),
            .rdata_o	(log_unpriv_fifo_data_out),
            .rempty_o	(log_unpriv_fifo_empty)
        );

        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (2)
        ) log_ext_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_ext_fifo_push),
            .wdata_i	(tcu_log_ext_data_s),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_ext_fifo_pop),
            .rdata_o	(log_ext_fifo_data_out),
            .rempty_o	(log_ext_fifo_empty)
        );

        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (2)
        ) log_noc_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_noc_fifo_push),
            .wdata_i	(tcu_log_noc_data),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_noc_fifo_pop),
            .rdata_o	(log_noc_fifo_data_out),
            .rempty_o	(log_noc_fifo_empty)
        );

        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (2)
        ) log_cur_vpe_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_cur_vpe_fifo_push),
            .wdata_i	(tcu_log_cur_vpe_i),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_cur_vpe_fifo_pop),
            .rdata_o	(log_cur_vpe_fifo_data_out),
            .rempty_o	(log_cur_vpe_fifo_empty)
        );

        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (2)
        ) log_rm_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_rm_fifo_push),
            .wdata_i	(tcu_log_rm),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_rm_fifo_pop),
            .rdata_o	(log_rm_fifo_data_out),
            .rempty_o	(log_rm_fifo_empty)
        );

        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (2)
        ) log_pmp_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_pmp_fifo_push),
            .wdata_i	(tcu_log_pmp_i),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_pmp_fifo_pop),
            .rdata_o	(log_pmp_fifo_data_out),
            .rempty_o	(log_pmp_fifo_empty)
        );

        always @* begin
            rin_tcu_log_en = 1'b0;
            rin_tcu_log_data = {TCU_LOG_DATA_SIZE{1'b0}};

            log_unpriv_fifo_pop = 1'b0;
            log_ext_fifo_pop = 1'b0;
            log_noc_fifo_pop = 1'b0;
            log_cur_vpe_fifo_pop = 1'b0;
            log_rm_fifo_pop = 1'b0;
            log_pmp_fifo_pop = 1'b0;
            log_priv_fifo_pop = 1'b0;

            if (!log_unpriv_fifo_empty) begin
                rin_tcu_log_en = 1'b1;
                rin_tcu_log_data = log_unpriv_fifo_data_out;
                log_unpriv_fifo_pop = 1'b1;
            end
            else if (!log_ext_fifo_empty) begin
                rin_tcu_log_en = 1'b1;
                rin_tcu_log_data = log_ext_fifo_data_out;
                log_ext_fifo_pop = 1'b1;
            end
            else if (!log_noc_fifo_empty) begin
                rin_tcu_log_en = 1'b1;
                rin_tcu_log_data = log_noc_fifo_data_out;
                log_noc_fifo_pop = 1'b1;
            end
            else if (!log_cur_vpe_fifo_empty) begin
                rin_tcu_log_en = 1'b1;
                rin_tcu_log_data = log_cur_vpe_fifo_data_out;
                log_cur_vpe_fifo_pop = 1'b1;
            end
            else if (!log_rm_fifo_empty) begin
                rin_tcu_log_en = 1'b1;
                rin_tcu_log_data = log_rm_fifo_data_out;
                log_rm_fifo_pop = 1'b1;
            end
            else if (!log_pmp_fifo_empty) begin
                rin_tcu_log_en = 1'b1;
                rin_tcu_log_data = log_pmp_fifo_data_out;
                log_pmp_fifo_pop = 1'b1;
            end
            else if (!log_priv_fifo_empty_s) begin
                rin_tcu_log_en = 1'b1;
                rin_tcu_log_data = log_priv_fifo_data_out_s;
                log_priv_fifo_pop = 1'b1;
            end
        end

        assign tcu_log_en_o = rin_tcu_log_en;
        assign tcu_log_data_o = rin_tcu_log_data;

        assign log_priv_fifo_pop_s = log_priv_fifo_pop;
    end
    else begin: NO_LOGGING
        assign tcu_log_en_o = 1'b0;
        assign tcu_log_data_o = {TCU_LOG_DATA_SIZE{1'b0}};

        assign log_priv_fifo_pop_s = 1'b0;
    end
    endgenerate


    generate
    if (TCU_ENABLE_PRINT) begin: PRINT

        tcu_ctrl_print i_tcu_ctrl_print (
            .clk_i             (clk_i),
            .reset_n_i         (reset_ctrl_n),

            //---------------
            //reg IF
            .print_reg_en_o    (print_reg_en),
            .print_reg_wben_o  (print_reg_wben),
            .print_reg_addr_o  (print_reg_addr),
            .print_reg_rdata_i (reg_rdata_i),
            .print_reg_stall_i (reg_stall_i), //highest prio for reg access

            //---------------
            //NoC IF
            //prio over recv-msg, write-ack, and noc-request, do not care other cmds because they do not occur together with print
            .noc_stall_i       (noc_tx_stall_i),
            .noc_wrreq_o       (print_noc_wrreq),
            .noc_burst_o       (print_noc_burst),
            .noc_bsel_o        (print_noc_bsel),
            .noc_chipid_o      (print_noc_chipid),
            .noc_modid_o       (print_noc_modid),
            .noc_data0_o       (print_noc_data0),
            .noc_data1_o       (print_noc_data1),

            .print_chipid_i    (print_chipid_i),
            .print_modid_i     (print_modid_i),

            //---------------
            //trigger
            //do not start during other send cmds
            //do not start immediately after cmd has started
            .print_start_i     (tcu_print_valid_i &&
                                !(mas_active || marq_noc_active || sm_noc_active || rpm_noc_active) &&
                                !tcu_fire_i[0] &&
                                (!tcu_fire_cmd_active || fm_active || am_active)),
            .print_active_o    (print_active)
        );

    end
    else begin: NO_PRINT
        assign print_reg_en = 1'b0;
        assign print_reg_wben = {TCU_REG_BSEL_SIZE{1'b0}};
        assign print_reg_addr = {TCU_REG_ADDR_SIZE{1'b0}};

        assign print_noc_wrreq = 1'b0;
        assign print_noc_burst = 1'b0;
        assign print_noc_bsel  = {NOC_BSEL_SIZE{1'b0}};
        assign print_noc_chipid = {NOC_CHIPID_SIZE{1'b0}};
        assign print_noc_modid = {NOC_MODID_SIZE{1'b0}};
        assign print_noc_data0 = {NOC_DATA_SIZE{1'b0}};
        assign print_noc_data1 = {NOC_DATA_SIZE{1'b0}};

        assign print_active = 1'b0;
    end
    endgenerate


endmodule
