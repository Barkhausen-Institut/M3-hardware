
module tcu_ctrl_reply_msg #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_DRAM           = 0,
    parameter TCU_ENABLE_VIRT_ADDR       = 0,
    parameter TCU_ENABLE_VIRT_PES        = 0,
    parameter HOME_MODID                 = {NOC_MODID_SIZE{1'b0}},
    parameter [31:0] TIMEOUT_SEND_CYCLES = 0
)(
    input  wire                             clk_i,
    input  wire                             reset_n_i,

    //---------------
    //reg IF
    output reg                              rpm_reg_en_o,
    output reg      [TCU_REG_DATA_SIZE-1:0] rpm_reg_wben_o,
    output reg      [TCU_REG_ADDR_SIZE-1:0] rpm_reg_addr_o,
    output reg      [TCU_REG_DATA_SIZE-1:0] rpm_reg_wdata_o,
    input  wire     [TCU_REG_DATA_SIZE-1:0] rpm_reg_rdata_i,
    input  wire                             rpm_reg_stall_i,

    //---------------
    //Mem IF (only read)
    output reg                        [1:0] rpm_mem_en_o,
    output wire     [TCU_MEM_ADDR_SIZE-1:0] rpm_mem_addr_o,
    output wire                             rpm_mem_rdata_valid_o,
    input  wire                             rpm_mem_rdata_avail_i,
    output wire     [TCU_MEM_DATA_SIZE-1:0] rpm_mem_wdata_o,
    input  wire                             rpm_mem_stall_i,

    //---------------
    //TLB IF
    output reg                              tlb_read_o,
    input  wire [TCU_TLB_PHYSPAGE_SIZE-1:0] tlb_physpage_i,
    input  wire                             tlb_read_done_i,
    input  wire        [TCU_ERROR_SIZE-1:0] tlb_read_error_i,
    input  wire                             tlb_active_i,

    //---------------
    //signals to activate NoC
    input  wire                             noc_stall_i,
    output reg                              noc_wrreq_o,
    output reg                              noc_burst_o,
    output reg          [NOC_BSEL_SIZE-1:0] noc_bsel_o,
    output reg          [NOC_DATA_SIZE-1:0] noc_data0_o,
    output reg          [NOC_DATA_SIZE-1:0] noc_data1_o,
    output wire         [NOC_ADDR_SIZE-1:0] noc_addr_o,
    output wire         [NOC_MODE_SIZE-1:0] noc_mode_o,
    output wire       [NOC_CHIPID_SIZE-1:0] noc_chipid_o,
    output wire        [NOC_MODID_SIZE-1:0] noc_modid_o,

    //---------------
    //incoming acknowledgment
    input  wire                             noc_ack_recv_i,
    input  wire         [NOC_ADDR_SIZE-1:0] noc_ack_addr_i,
    input  wire       [NOC_CHIPID_SIZE-1:0] noc_ack_chipid_i,
    input  wire        [NOC_MODID_SIZE-1:0] noc_ack_modid_i,
    input  wire        [TCU_ERROR_SIZE-1:0] noc_ack_error_i,

    //---------------
    //triggers from tcu_ctrl
    input  wire                             rpm_start_i,
    input  wire       [TCU_OPCODE_SIZE-1:0] rpm_opcode_i,
    input  wire                      [31:0] rpm_rmsgoffset_i,  //offset of previously received msg, from cmd_arg0
    input  wire                      [31:0] rpm_laddr_i,       //local addr of reply data, from data_addr
    input  wire                      [31:0] rpm_size_i,        //size of reply data, from data_size
    input  wire           [TCU_EP_SIZE-1:0] rpm_recvep_i,      //recv ep from cmd_ep
    input  wire                  [3*64-1:0] rpm_epdata_i,
    input  wire                      [31:0] rpm_cur_vpe_i,
    input  wire                             rpm_abort_i,
    input  wire                             rpm_cur_vpe_stall_i,
    output wire                             rpm_active_o,
    output wire                             rpm_noc_active_o,
    output wire                             rpm_done_o,
    output wire        [TCU_ERROR_SIZE-1:0] rpm_error_o,

    //---------------
    //log
    output reg                              rpm_log_valid_o,
    output wire       [TCU_CHIPID_SIZE-1:0] rpm_log_rpl_chip_o,
    output wire         [TCU_PEID_SIZE-1:0] rpm_log_rpl_pe_o,

    //---------------
    //TCU feature settings
    input  wire                             tcu_features_virt_addr_i,
    input  wire                             tcu_features_virt_pes_i,

    //---------------
    //Home Chip-ID
    input  wire       [NOC_CHIPID_SIZE-1:0] home_chipid_i
);

    `include "tcu_functions.v"

    localparam CTRL_RPM_STATES_SIZE    = 5;
    localparam S_CTRL_RPM_IDLE         = 5'h00;
    localparam S_CTRL_RPM_TLB_LOOKUP   = 5'h01;
    localparam S_CTRL_RPM_TLB_WAIT     = 5'h02;
    localparam S_CTRL_RPM_READ_SEP1    = 5'h03;
    localparam S_CTRL_RPM_READ_SEP2    = 5'h04;
    localparam S_CTRL_RPM_READ_SEP3    = 5'h05;
    localparam S_CTRL_RPM_CHECK_SEP    = 5'h06;
    localparam S_CTRL_RPM_PREPARE_MEM1 = 5'h07;
    localparam S_CTRL_RPM_PREPARE_MEM2 = 5'h08;
    localparam S_CTRL_RPM_SEND_HD1     = 5'h09;
    localparam S_CTRL_RPM_SEND_HD2     = 5'h0A;
    localparam S_CTRL_RPM_SEND_HD3     = 5'h0B;
    localparam S_CTRL_RPM_SEND_PL      = 5'h0C;
    localparam S_CTRL_RPM_ABORT        = 5'h0D;
    localparam S_CTRL_RPM_WAIT_ACK     = 5'h0E;
    localparam S_CTRL_RPM_UPDATE_SEP   = 5'h0F;
    localparam S_CTRL_RPM_UPDATE_VPE1  = 5'h10;
    localparam S_CTRL_RPM_UPDATE_VPE2  = 5'h11;
    localparam S_CTRL_RPM_UPDATE_REP   = 5'h12;
    localparam S_CTRL_RPM_FINISH       = 5'h1F;

    reg [CTRL_RPM_STATES_SIZE-1:0] ctrl_rpm_state, next_ctrl_rpm_state;



    reg                [31:0] r_laddr, rin_laddr;
    reg                [15:0] r_size, rin_size;            //total size
    reg                [31:0] r_rplepaddr, rin_rplepaddr;
    reg     [TCU_EP_SIZE-1:0] r_recvep, rin_recvep;
    reg                [31:0] r_unread, rin_unread;

    reg r_stall;


    //temp sep reg
    reg [63:0] r_sep_0, rin_sep_0;
    reg [63:0] r_sep_1, rin_sep_1;
    reg [63:0] r_sep_2, rin_sep_2;

    reg r_rpm_mem_en;

    //mark read data from reg available
    reg r_rpm_reg_rdata_valid, rin_rpm_reg_rdata_valid;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_rpm_error, rin_rpm_error;

    //current write index
    reg [TCU_SLOT_SIZE-1:0] r_tmp_wpos, rin_tmp_wpos;

    //info from ack
    reg                      r_ack_recv, rin_ack_recv;
    reg [TCU_ERROR_SIZE-1:0] r_ack_error, rin_ack_error;

    //timeout
    reg [31:0] r_rpm_timeout, rin_rpm_timeout;


    //rep info
    wire [TCU_EP_TYPE_SIZE-1:0] rep_type     = rpm_epdata_i[TCU_EP_TYPE_SIZE-1 : 0];
    wire   [TCU_VPEID_SIZE-1:0] rep_vpeid    = rpm_epdata_i[TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] rep_rpleps   = rpm_epdata_i[TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slots    = rpm_epdata_i[TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slotsize = rpm_epdata_i[2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_wpos     = rpm_epdata_i[3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_rpos     = rpm_epdata_i[4*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire                 [63:0] rep_buffer   = rpm_epdata_i[2*64-1 : 64];
    wire                 [31:0] rep_occupied = rpm_epdata_i[2*64+32-1 : 2*64];
    wire                 [31:0] rep_unread   = rpm_epdata_i[3*64-1 : 2*64+32];

    //sep info
    wire [TCU_EP_TYPE_SIZE-1:0] sep_type   = r_sep_0[TCU_EP_TYPE_SIZE-1 : 0];
    wire   [TCU_VPEID_SIZE-1:0] sep_vpeid  = r_sep_0[TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_TYPE_SIZE];
    wire     [TCU_CRD_SIZE-1:0] sep_curcrd = r_sep_0[TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire     [TCU_CRD_SIZE-1:0] sep_maxcrd = r_sep_0[2*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire     [TCU_CRD_SIZE-1:0] sep_msgsz  = r_sep_0[3*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 2*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] sep_crdep  = r_sep_0[TCU_EP_SIZE+3*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 3*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire                        sep_reply  = r_sep_0[TCU_EP_SIZE+3*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] sep_ep     = r_sep_1[TCU_EP_SIZE-1 : 0];
    wire    [TCU_PEID_SIZE-1:0] sep_pe     = r_sep_1[TCU_PEID_SIZE+TCU_EP_SIZE-1 : TCU_EP_SIZE];
    wire  [TCU_CHIPID_SIZE-1:0] sep_chip   = r_sep_1[TCU_CHIPID_SIZE+TCU_PEID_SIZE+TCU_EP_SIZE-1 : TCU_PEID_SIZE+TCU_EP_SIZE];
    wire                 [63:0] sep_label  = r_sep_2;


    //index to get reply ep (offset/slot_size)
    wire [TCU_SLOT_SIZE-1:0] tmp_wpos = rpm_rmsgoffset_i >> rep_slotsize;

    //position in unread and occupied bitmask
    wire [TCU_REG_DATA_SIZE-1:0] set_bit_wpos = 32'h1 << r_tmp_wpos;

    //updated msgs count
    wire [TCU_REG_DATA_SIZE-1:0] cur_vpe_msgs_decr = rpm_cur_vpe_i[TCU_VPE_MSGS_SIZE+TCU_VPEID_SIZE-1:TCU_VPEID_SIZE] - 'd1;


    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_rpm_state <= S_CTRL_RPM_IDLE;

            r_laddr     <= 32'h0;
            r_size      <= 16'h0;
            r_rplepaddr <= 32'h0;
            r_recvep    <= {TCU_EP_SIZE{1'b0}};
            r_unread    <= 32'h0;

            r_stall <= 1'b0;

            r_sep_0 <= 64'h0;
            r_sep_1 <= 64'h0;
            r_sep_2 <= 64'h0;

            r_rpm_mem_en <= 1'b0;

            r_rpm_reg_rdata_valid <= 1'b0;
            r_rpm_error <= TCU_ERROR_NONE;

            r_tmp_wpos <= {TCU_SLOT_SIZE{1'b0}};

            r_ack_recv <= 1'b0;
            r_ack_error <= TCU_ERROR_NONE;

            r_rpm_timeout <= 32'h0;
        end
        else begin
            ctrl_rpm_state <= next_ctrl_rpm_state;
            
            r_laddr     <= rin_laddr;
            r_size      <= rin_size;
            r_rplepaddr <= rin_rplepaddr;
            r_recvep    <= rin_recvep;
            r_unread    <= rin_unread;

            r_stall <= noc_stall_i || rpm_mem_stall_i;

            r_sep_0 <= rin_sep_0;
            r_sep_1 <= rin_sep_1;
            r_sep_2 <= rin_sep_2;

            r_rpm_mem_en <= rpm_mem_en_o[0];

            r_rpm_reg_rdata_valid <= rin_rpm_reg_rdata_valid;
            r_rpm_error <= rin_rpm_error;

            r_tmp_wpos <= rin_tmp_wpos;

            r_ack_recv <= rin_ack_recv;
            r_ack_error <= rin_ack_error;

            r_rpm_timeout <= rin_rpm_timeout;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_rpm_state = ctrl_rpm_state;

        noc_wrreq_o = 1'b0;
        noc_burst_o = 1'b0;
        noc_bsel_o  = {NOC_BSEL_SIZE{1'b0}};
        noc_data0_o = {NOC_DATA_SIZE{1'b0}};
        noc_data1_o = {NOC_DATA_SIZE{1'b0}};

        rin_laddr     = r_laddr;
        rin_size      = r_size;
        rin_rplepaddr = r_rplepaddr;
        rin_recvep    = r_recvep;
        rin_unread    = r_unread;

        rin_sep_0 = r_sep_0;
        rin_sep_1 = r_sep_1;
        rin_sep_2 = r_sep_2;

        rin_rpm_reg_rdata_valid = 1'b0;
        rin_rpm_error = r_rpm_error;

        rin_tmp_wpos = r_tmp_wpos;

        rin_rpm_timeout = 32'h0;

        rpm_log_valid_o = 1'b0;

        tlb_read_o = 1'b0;


        case (ctrl_rpm_state)

            //---------------
            //wait for incoming command
            S_CTRL_RPM_IDLE: begin
                if (rpm_start_i && (rpm_opcode_i == TCU_OPCODE_REPLY)) begin

                    //interpret ep content as recv ep
                    if (rep_type == TCU_EP_TYPE_RECEIVE) begin

                        //reply must be enabled
                        if (rep_rpleps != {TCU_EP_SIZE{1'b1}}) begin

                            //check EP number
                            if ((rep_rpleps + (32'h1 << rep_slots)) <= TCU_EP_REG_COUNT) begin

                                //check VPE
                                if (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (rpm_cur_vpe_i[TCU_VPEID_SIZE-1:0] == rep_vpeid)) begin

                                    //check if offset < number of slots
                                    if (tmp_wpos < ({{(TCU_SLOT_SIZE-1){1'b0}}, 1'b1} << rep_slots)) begin
                                        rin_tmp_wpos = tmp_wpos;
                                        rin_size = rpm_size_i;
                                        rin_laddr = rpm_laddr_i;
                                        rin_rplepaddr = TCU_REGADDR_EP_START + (rep_rpleps+tmp_wpos)*TCU_EP_REG_SIZE;   //ep which is used to reply (this has a format of a send ep)
                                        rin_recvep = rpm_recvep_i;

                                        rin_unread = rep_unread;

                                        rin_rpm_error = TCU_ERROR_NONE;
                                        next_ctrl_rpm_state = S_CTRL_RPM_READ_SEP1;
                                    end
                                    else begin
                                        rin_rpm_error = TCU_ERROR_INV_MSG_OFF;
                                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                                    end
                                end
                                else begin
                                    rin_rpm_error = TCU_ERROR_FOREIGN_EP;
                                    next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                                end
                            end
                            else begin
                                rin_rpm_error = TCU_ERROR_RECV_INV_RPL_EPS;
                                next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                            end
                        end
                        else begin
                            rin_rpm_error = TCU_ERROR_REPLIES_DISABLED;
                            next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                        end
                    end
                    else begin
                        rin_rpm_error = TCU_ERROR_NO_REP;
                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                    end
                end
            end

            //---------------
            //read first part of reply ep
            S_CTRL_RPM_READ_SEP1: begin
                if (!rpm_reg_stall_i) begin
                    rin_rpm_reg_rdata_valid = 1'b1;
                    next_ctrl_rpm_state = S_CTRL_RPM_READ_SEP2;
                end
            end
            
            //read second part of reply ep
            S_CTRL_RPM_READ_SEP2: begin
                //reg read data should be there now
                if (r_rpm_reg_rdata_valid) begin
                    rin_sep_0 = rpm_reg_rdata_i;
                end

                if (!rpm_reg_stall_i) begin
                    rin_rpm_reg_rdata_valid = 1'b1;
                    next_ctrl_rpm_state = S_CTRL_RPM_READ_SEP3;
                end
            end

            //read third part of reply ep
            S_CTRL_RPM_READ_SEP3: begin
                //reg read data should be there now
                if (r_rpm_reg_rdata_valid) begin
                    rin_sep_1 = rpm_reg_rdata_i;
                end

                if (!rpm_reg_stall_i) begin
                    rin_rpm_reg_rdata_valid = 1'b1;
                    next_ctrl_rpm_state = S_CTRL_RPM_CHECK_SEP;
                end
            end

            //---------------
            //check ep for type, reply flag, credits
            S_CTRL_RPM_CHECK_SEP: begin
                //reg read data should be there now
                if (r_rpm_reg_rdata_valid) begin
                    rin_sep_2 = rpm_reg_rdata_i;
                    rpm_log_valid_o = 1'b1; //sep_pe is ready, too
                end

                //endpoint must be a send ep and reply enabled
                if (sep_type == TCU_EP_TYPE_SEND) begin
                    if (sep_reply == 1'b1) begin

                        //check Crd EP number
                        if ((sep_crdep == {TCU_EP_SIZE{1'b1}}) || (sep_crdep < TCU_EP_REG_COUNT)) begin

                            //msg_sz in reply-ep is limited to one burst
                            if ((32'h1 << sep_msgsz) <= (MAX_BURST_LENGTH_MSG<<4)) begin

                                //reply size must be less equal than slot_size
                                if ((r_size + TCU_HD_REG_SIZE) <= (32'h1 << sep_msgsz)) begin

                                    //check msg alignment
                                    if (r_laddr[3:0] == 4'h0) begin

                                        //check if there is a page boundary in addr range
                                        if (!(TCU_ENABLE_VIRT_ADDR && tcu_features_virt_addr_i) ||
                                            ((({{TCU_TLB_PHYSPAGE_SIZE{1'b0}}, r_laddr[TCU_PAGEOFFSET_SIZE_4KB-1:0]} + r_size) <= TCU_PAGE_SIZE_4KB))) begin

                                            //if VM is activated, access TLB first
                                            if (TCU_ENABLE_VIRT_ADDR && tcu_features_virt_addr_i) begin
                                                next_ctrl_rpm_state = S_CTRL_RPM_TLB_LOOKUP;
                                            end

                                            //for DRAM-like access first request data
                                            else begin
                                                if (TCU_ENABLE_DRAM && (r_size != 'd0)) begin
                                                    next_ctrl_rpm_state = S_CTRL_RPM_PREPARE_MEM1;
                                                end else begin
                                                    next_ctrl_rpm_state = S_CTRL_RPM_SEND_HD1;
                                                end
                                            end
                                        end
                                        else begin
                                            rin_rpm_error = TCU_ERROR_PAGE_BOUNDARY;
                                            next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                                        end
                                    end
                                    else begin
                                        rin_rpm_error = TCU_ERROR_MSG_UNALIGNED;
                                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                                    end
                                end
                                else begin
                                    rin_rpm_error = TCU_ERROR_OUT_OF_BOUNDS;
                                    next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                                end
                            end
                            else begin
                                rin_rpm_error = TCU_ERROR_SEND_INV_MSG_SZ;
                                next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                            end
                        end
                        else begin
                            rin_rpm_error = TCU_ERROR_SEND_INV_CRD_EP;
                            next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                        end
                    end
                    else begin
                        rin_rpm_error = TCU_ERROR_SEND_REPLY_EP;
                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                    end
                end
                else begin
                    rin_rpm_error = TCU_ERROR_NO_SEP;
                    next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                end
            end

            //---------------
            //TLB lookup
            S_CTRL_RPM_TLB_LOOKUP: begin
                if (TCU_ENABLE_VIRT_ADDR) begin
                    if (!tlb_active_i) begin
                        tlb_read_o = 1'b1;  //virt page number and vpe id is set in tcu_ctrl
                        next_ctrl_rpm_state = S_CTRL_RPM_TLB_WAIT;
                    end

                    //stop on abort
                    if (rpm_abort_i) begin
                        rin_rpm_error = TCU_ERROR_ABORT;
                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                    end
                end
            end

            //wait for TLB access
            S_CTRL_RPM_TLB_WAIT: begin
                if (TCU_ENABLE_VIRT_ADDR) begin
                    if (tlb_read_done_i) begin
                        if (tlb_read_error_i == TCU_ERROR_NONE) begin
                            rin_laddr = {tlb_physpage_i, r_laddr[TCU_PHYSADDR_SIZE-TCU_TLB_PHYSPAGE_SIZE-1 : 0]}; //keep lower bits from virt addr

                            //for DRAM-like access first request data
                            if (TCU_ENABLE_DRAM && (r_size != 'd0)) begin
                                next_ctrl_rpm_state = S_CTRL_RPM_PREPARE_MEM1;
                            end else begin
                                next_ctrl_rpm_state = S_CTRL_RPM_SEND_HD1;
                            end
                        end
                        else begin
                            rin_rpm_error = tlb_read_error_i;
                            next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                        end
                    end

                    //stop on abort
                    if (rpm_abort_i) begin
                        rin_rpm_error = TCU_ERROR_ABORT;
                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                    end
                end
            end


            //---------------
            //send information about total size to preload it from memory
            S_CTRL_RPM_PREPARE_MEM1: begin
                if (!rpm_mem_stall_i) begin
                    next_ctrl_rpm_state = S_CTRL_RPM_PREPARE_MEM2;
                end
            end

            //check when prepared data becomes available
            S_CTRL_RPM_PREPARE_MEM2: begin
                if (rpm_mem_rdata_avail_i) begin
                    next_ctrl_rpm_state = S_CTRL_RPM_SEND_HD1;
                end

                //timeout
                else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                    rin_rpm_timeout = r_rpm_timeout + 32'd1;
                    if (r_rpm_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_rpm_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                    end
                end
            end


            //---------------
            //write msg header to NoC packet and send it to recv ep
            S_CTRL_RPM_SEND_HD1: begin
                //first check abort condition
                if (rpm_abort_i) begin
                    rin_rpm_error = TCU_ERROR_ABORT;
                    next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                end
                else if (!noc_stall_i) begin
                    //prepare NoC header packet
                    noc_wrreq_o = 1'b1;
                    noc_burst_o = 1'b1;
                    noc_bsel_o = {(r_size[3:0] - 1), {(NOC_BSEL_SIZE/2){1'b1}}};   //aligned msg header (laddr[3:0]==0), last valid byte: size[3:0] - 1
                    noc_data0_o = r_size[15:4] + |r_size[3:0] + 2;  //burst length: palyoad + header

                    next_ctrl_rpm_state = S_CTRL_RPM_SEND_HD2;
                end
            end

            S_CTRL_RPM_SEND_HD2: begin
                if (!noc_stall_i) begin
                    //send first flit with msg header
                    //rlabel = 0
                    noc_wrreq_o = 1'b1;
                    noc_burst_o = 1'b1;
                    noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};
                    noc_data0_o = {sep_crdep,
                                    r_recvep,
                                    r_size[TCU_MSGLEN_SIZE-1:0],
                                    home_chipid_i,
                                    HOME_MODID,
                                    {TCU_RSIZE_SIZE{1'b0}},
                                    TCU_HD_FLAG_REPLY};

                    next_ctrl_rpm_state = S_CTRL_RPM_SEND_HD3;
                end
            end

            S_CTRL_RPM_SEND_HD3: begin
                if (!noc_stall_i) begin
                    //send second flit with msg header
                    noc_wrreq_o = 1'b1;
                    noc_burst_o = 1'b1;
                    noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};
                    noc_data0_o = sep_label;

                    //skip payload for empty msg
                    if (r_size == 'd0) begin
                        noc_burst_o = 1'b0; //burst ends
                        next_ctrl_rpm_state = S_CTRL_RPM_WAIT_ACK;
                    end
                    else begin
                        next_ctrl_rpm_state = S_CTRL_RPM_SEND_PL;
                    end
                end
            end

            //write msg payload to NoC packet
            S_CTRL_RPM_SEND_PL: begin
                if (!noc_stall_i) begin
                    if (rpm_mem_stall_i && (r_size > 'd0)) begin
                        noc_burst_o = 1'b1;
                        noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};
                        next_ctrl_rpm_state = S_CTRL_RPM_SEND_PL;

                        //check abort condition
                        if (rpm_abort_i) begin
                            noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                            rin_rpm_error = TCU_ERROR_ABORT;
                            next_ctrl_rpm_state = S_CTRL_RPM_ABORT;
                        end

                        //timeout
                        else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                            rin_rpm_timeout = r_rpm_timeout + 32'd1;
                            if (r_rpm_timeout > TIMEOUT_SEND_CYCLES) begin
                                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                                rin_rpm_error = TCU_ERROR_TIMEOUT_MEM;
                                next_ctrl_rpm_state = S_CTRL_RPM_ABORT;
                            end
                        end
                    end
                    else begin
                        noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};

                        //continue burst
                        if (r_size > 'd0) begin
                            rin_laddr = r_laddr + 'd16;
                            rin_size  = (r_size > 'd16) ? (r_size - 'd16) : 'd0;

                            noc_burst_o = 1'b1;

                            //check abort condition
                            if (rpm_abort_i) begin
                                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                                rin_rpm_error = TCU_ERROR_ABORT;
                                next_ctrl_rpm_state = S_CTRL_RPM_ABORT;
                            end
                            else begin
                                next_ctrl_rpm_state = S_CTRL_RPM_SEND_PL;
                            end
                        end

                        //stop burst
                        else begin
                            noc_burst_o = 1'b0;
                            next_ctrl_rpm_state = S_CTRL_RPM_WAIT_ACK;
                        end
                    end
                end
            end


            //---------------
            //abort reply cmd, still send flits of remaining burst but deassert bsel
            S_CTRL_RPM_ABORT: begin
                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}};
                
                if (!noc_stall_i) begin
                    noc_wrreq_o = 1'b1;

                    if (r_size > 'd0) begin
                        rin_size  = (r_size > 'd16) ? (r_size - 'd16) : 'd0;    
                        noc_burst_o = 1'b1;
                    end

                    //stop burst
                    else begin
                        noc_burst_o = 1'b0;
                        next_ctrl_rpm_state = S_CTRL_RPM_WAIT_ACK;
                    end
                end
            end


            //---------------
            S_CTRL_RPM_WAIT_ACK: begin
                //check if ack was received
                //only proceed when last packet was properly send
                if (r_ack_recv && !noc_stall_i) begin
                    rin_rpm_error = r_ack_error;

                    //stop here when there was an error in ack
                    if (r_ack_error != {TCU_ERROR_SIZE{1'b0}}) begin
                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                    end else begin
                        next_ctrl_rpm_state = S_CTRL_RPM_UPDATE_SEP;
                    end
                end

                //timeout
                else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                    rin_rpm_timeout = r_rpm_timeout + 32'd1;
                    if (r_rpm_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_rpm_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                    end
                end
            end

            //---------------
            //invalidate type of send ep
            S_CTRL_RPM_UPDATE_SEP: begin
                if (!rpm_reg_stall_i) begin
                    if (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) begin
                        next_ctrl_rpm_state = S_CTRL_RPM_UPDATE_VPE1;
                    end else begin
                        next_ctrl_rpm_state = S_CTRL_RPM_UPDATE_REP;
                    end
                end
            end

            //---------------
            //decr msgs in VPE reg if bit in unread bitmask is set
            S_CTRL_RPM_UPDATE_VPE1: begin
                if (TCU_ENABLE_VIRT_PES) begin
                    if (r_unread[r_tmp_wpos]) begin
                        next_ctrl_rpm_state = S_CTRL_RPM_UPDATE_VPE2;
                    end else begin
                        next_ctrl_rpm_state = S_CTRL_RPM_UPDATE_REP;
                    end
                end
            end

            S_CTRL_RPM_UPDATE_VPE2: begin
                if (TCU_ENABLE_VIRT_PES) begin
                    if (!rpm_reg_stall_i && !rpm_cur_vpe_stall_i) begin
                        next_ctrl_rpm_state = S_CTRL_RPM_UPDATE_REP;
                    end
                end
            end

            //write ep with updated bitmasks
            S_CTRL_RPM_UPDATE_REP: begin
                if (!rpm_reg_stall_i) begin
                    next_ctrl_rpm_state = S_CTRL_RPM_FINISH;
                end
            end


            //---------------
            S_CTRL_RPM_FINISH: begin
                next_ctrl_rpm_state = S_CTRL_RPM_IDLE;
            end

            default: next_ctrl_rpm_state = S_CTRL_RPM_IDLE;

        endcase //case (ctrl_rpm_state)
    end


    //---------------
    //hold ack info
    always @* begin
        rin_ack_recv = r_ack_recv;
        rin_ack_error = r_ack_error;

        //if reply is ongoing
        if (rpm_active_o) begin
            if (noc_ack_recv_i) begin
                //check if this ack is for us (label is only in lower 15 bits of addr)
                if ((noc_ack_addr_i[15:0] == sep_label[15:0]) &&
                    (noc_ack_chipid_i == sep_chip) &&
                    (noc_ack_modid_i == sep_pe)) begin
                    rin_ack_recv = 1'b1;
                    rin_ack_error = noc_ack_error_i;
                end
            end
        end
        else begin
            rin_ack_recv = 1'b0;
            rin_ack_error = TCU_ERROR_NONE;
        end
    end



    //---------------
    //reg interface
    always @* begin
        rpm_reg_en_o = 1'b0;
        rpm_reg_wben_o = {TCU_REG_DATA_SIZE{1'b0}};
        rpm_reg_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
        rpm_reg_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};

        if (ctrl_rpm_state == S_CTRL_RPM_READ_SEP1) begin
            rpm_reg_en_o = 1'b1;
            rpm_reg_addr_o = r_rplepaddr;
        end
        else if (ctrl_rpm_state == S_CTRL_RPM_READ_SEP2) begin
            rpm_reg_en_o = 1'b1;
            rpm_reg_addr_o = r_rplepaddr + 'd8;
        end
        else if (ctrl_rpm_state == S_CTRL_RPM_READ_SEP3) begin
            rpm_reg_en_o = 1'b1;
            rpm_reg_addr_o = r_rplepaddr + 'd16;
        end
        else if (ctrl_rpm_state == S_CTRL_RPM_UPDATE_SEP) begin
            rpm_reg_en_o = 1'b1;
            rpm_reg_wben_o = {TCU_EP_TYPE_SIZE{1'b1}};
            rpm_reg_addr_o = r_rplepaddr;
            rpm_reg_wdata_o = TCU_EP_TYPE_INVALID;
        end
        else if (TCU_ENABLE_VIRT_PES && (ctrl_rpm_state == S_CTRL_RPM_UPDATE_VPE2)) begin
            rpm_reg_en_o = 1'b1;
            rpm_reg_wben_o = {{(TCU_REG_DATA_SIZE-TCU_VPE_MSGS_SIZE){1'b0}}, {TCU_VPE_MSGS_SIZE{1'b1}}} << TCU_VPEID_SIZE; //only write to msgs field
            rpm_reg_addr_o = TCU_REGADDR_CUR_VPE;
            rpm_reg_wdata_o = cur_vpe_msgs_decr << TCU_VPEID_SIZE;
        end
        else if (ctrl_rpm_state == S_CTRL_RPM_UPDATE_REP) begin
            rpm_reg_en_o = 1'b1;
            rpm_reg_wben_o = (set_bit_wpos<<32) | set_bit_wpos;
            rpm_reg_addr_o = TCU_REGADDR_EP_START + r_recvep*TCU_EP_REG_SIZE + 'd16;
            rpm_reg_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};
        end
    end



    //---------------
    //memory interface
    always @* begin
        rpm_mem_en_o = 2'b00;    //bit 0: memory access, bit 1: memory request for DRAM-like mems

        if (ctrl_rpm_state == S_CTRL_RPM_PREPARE_MEM1) begin
            rpm_mem_en_o = 2'b10;
        end
        else if ((ctrl_rpm_state == S_CTRL_RPM_SEND_PL) && (r_size > 'h0)) begin   //enable mem during burst only when not last packet of burst
            rpm_mem_en_o = 2'b01;
        end
    end

    assign rpm_mem_addr_o = r_laddr;
    assign rpm_mem_rdata_valid_o = r_rpm_mem_en && !r_stall;
    assign rpm_mem_wdata_o = r_size;

    assign rpm_error_o = r_rpm_error;
    assign rpm_active_o = (ctrl_rpm_state != S_CTRL_RPM_IDLE);
    assign rpm_noc_active_o = rpm_active_o && (ctrl_rpm_state < S_CTRL_RPM_WAIT_ACK);
    assign rpm_done_o = (ctrl_rpm_state == S_CTRL_RPM_FINISH);

    assign rpm_log_rpl_chip_o = sep_chip;
    assign rpm_log_rpl_pe_o = sep_pe;

    //always send to original send pe and its send ep
    assign noc_chipid_o = sep_chip;
    assign noc_modid_o = sep_pe;
    assign noc_addr_o = sep_ep;
    assign noc_mode_o = MODE_TCU_MSG;


endmodule
