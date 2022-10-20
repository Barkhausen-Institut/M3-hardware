
module tcu_ctrl_send_msg #(
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
    output reg                              sm_reg_en_o,
    output reg      [TCU_REG_DATA_SIZE-1:0] sm_reg_wben_o,
    output reg      [TCU_REG_ADDR_SIZE-1:0] sm_reg_addr_o,
    output reg      [TCU_REG_DATA_SIZE-1:0] sm_reg_wdata_o,
    input  wire     [TCU_REG_DATA_SIZE-1:0] sm_reg_rdata_i,
    input  wire                             sm_reg_stall_i,

    //---------------
    //Mem IF (only read)
    output reg                        [1:0] sm_mem_en_o,
    output wire     [TCU_MEM_ADDR_SIZE-1:0] sm_mem_addr_o,
    output wire                             sm_mem_rdata_valid_o,
    input  wire                             sm_mem_rdata_avail_i,
    output wire     [TCU_MEM_DATA_SIZE-1:0] sm_mem_wdata_o,
    input  wire                             sm_mem_stall_i,

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
    input  wire                             sm_start_i,
    input  wire       [TCU_OPCODE_SIZE-1:0] sm_opcode_i,
    input  wire                      [31:0] sm_laddr_i,    //local addr of send msg, from data_addr
    input  wire                      [31:0] sm_size_i,     //size of send msg, from data_size
    input  wire           [TCU_EP_SIZE-1:0] sm_sendep_i,   //send ep which is used to send now, from cmd_ep
    input  wire                  [3*64-1:0] sm_epdata_i,
    input  wire           [TCU_EP_SIZE-1:0] sm_replyep_i,  //from cmd_arg0
    input  wire                      [31:0] sm_replylabel_i,   //from arg1 reg
    input  wire        [TCU_VPEID_SIZE-1:0] sm_cur_vpeid_i,
    input  wire                             sm_abort_i,
    input  wire                             sm_crd_update_stall_i,
    output wire                             sm_active_o,
    output wire                             sm_noc_active_o,
    output wire                             sm_done_o,
    output wire        [TCU_ERROR_SIZE-1:0] sm_error_o,

    //---------------
    //TCU feature settings
    input  wire                             tcu_features_virt_pes_i,
    input  wire                             tcu_features_virt_addr_i,

    //---------------
    //Home Chip-ID
    input  wire       [NOC_CHIPID_SIZE-1:0] home_chipid_i
);

    `include "tcu_functions.v"


    localparam CTRL_SM_STATES_SIZE     = 5;
    localparam S_CTRL_SM_IDLE          = 5'h00;
    localparam S_CTRL_SM_TLB_LOOKUP    = 5'h01;
    localparam S_CTRL_SM_TLB_WAIT      = 5'h02;
    localparam S_CTRL_SM_READ_REPLYEP1 = 5'h03;
    localparam S_CTRL_SM_READ_REPLYEP2 = 5'h04;
    localparam S_CTRL_SM_CHECK_CREDITS = 5'h05;
    localparam S_CTRL_SM_PREPARE_MEM1  = 5'h06;
    localparam S_CTRL_SM_PREPARE_MEM2  = 5'h07;
    localparam S_CTRL_SM_SEND_HD1      = 5'h08;
    localparam S_CTRL_SM_SEND_HD2      = 5'h09;
    localparam S_CTRL_SM_SEND_PL       = 5'h0A;
    localparam S_CTRL_SM_ABORT         = 5'h0B;
    localparam S_CTRL_SM_WAIT_ACK      = 5'h0C;
    localparam S_CTRL_SM_UPDATE_EP1    = 5'h0D;
    localparam S_CTRL_SM_UPDATE_EP2    = 5'h0E;
    localparam S_CTRL_SM_UPDATE_EP3    = 5'h0F;
    localparam S_CTRL_SM_FINISH        = 5'h1F;

    reg [CTRL_SM_STATES_SIZE-1:0] ctrl_sm_state, next_ctrl_sm_state;


    reg [63:0] r_sep_1, rin_sep_1;
    reg [63:0] r_sep_2, rin_sep_2;


    reg                [31:0] r_laddr, rin_laddr;
    reg                [15:0] r_size, rin_size;            //total size
    reg     [TCU_EP_SIZE-1:0] r_sendep, rin_sendep;
    reg     [TCU_EP_SIZE-1:0] r_crdep, rin_crdep;
    reg    [TCU_CRD_SIZE-1:0] r_curcrd, rin_curcrd;
    reg     [TCU_EP_SIZE-1:0] r_replyep, rin_replyep;
    reg  [TCU_RSIZE_SIZE-1:0] r_replysize, rin_replysize;
    reg                [31:0] r_replylabel, rin_replylabel;

    reg r_stall;

    reg r_sm_mem_en;

    //info from ack
    reg                      r_ack_recv, rin_ack_recv;
    reg [TCU_ERROR_SIZE-1:0] r_ack_error, rin_ack_error;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_sm_error, rin_sm_error;

    //timeout
    reg [31:0] r_sm_timeout, rin_sm_timeout;


    //ep info
    wire [TCU_EP_TYPE_SIZE-1:0] sep_type_s   = sm_epdata_i[TCU_EP_TYPE_SIZE-1 : 0];
    wire   [TCU_VPEID_SIZE-1:0] sep_vpeid_s  = sm_epdata_i[TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_TYPE_SIZE];
    wire     [TCU_CRD_SIZE-1:0] sep_curcrd_s = sm_epdata_i[TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire     [TCU_CRD_SIZE-1:0] sep_maxcrd_s = sm_epdata_i[2*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire     [TCU_CRD_SIZE-1:0] sep_msgsz_s  = sm_epdata_i[3*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 2*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] sep_crdep_s  = sm_epdata_i[TCU_EP_SIZE+3*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 3*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire                        sep_reply_s  = sm_epdata_i[TCU_EP_SIZE+3*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] sep_ep_s     = sm_epdata_i[TCU_EP_SIZE+64-1 : 64];
    wire    [TCU_PEID_SIZE-1:0] sep_pe_s     = sm_epdata_i[TCU_PEID_SIZE+TCU_EP_SIZE+64-1 : TCU_EP_SIZE+64];
    wire                 [63:0] sep_label_s  = sm_epdata_i[3*64-1 : 2*64];

    //ep info (from reg)
    wire     [TCU_CRD_SIZE-1:0] sep_curcrd = r_curcrd;
    wire      [TCU_EP_SIZE-1:0] sep_ep     = r_sep_1[TCU_EP_SIZE-1 : 0];
    wire    [TCU_PEID_SIZE-1:0] sep_pe     = r_sep_1[TCU_PEID_SIZE+TCU_EP_SIZE-1 : TCU_EP_SIZE];
    wire  [TCU_CHIPID_SIZE-1:0] sep_chip   = r_sep_1[TCU_CHIPID_SIZE+TCU_PEID_SIZE+TCU_EP_SIZE-1 : TCU_PEID_SIZE+TCU_EP_SIZE];
    wire                 [63:0] sep_label  = r_sep_2;


    //updated credits
    wire [TCU_REG_DATA_SIZE-1:0] sep_curcrd_decr = sep_curcrd - {{(TCU_CRD_SIZE-1){1'b0}}, 1'b1};



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_sm_state <= S_CTRL_SM_IDLE;

            r_sep_1 <= 64'h0;
            r_sep_2 <= 64'h0;

            r_laddr      <= 32'h0;
            r_size       <= 16'h0;
            r_sendep     <= {TCU_EP_SIZE{1'b0}};
            r_crdep      <= {TCU_EP_SIZE{1'b0}};
            r_curcrd     <= {TCU_CRD_SIZE{1'b0}};
            r_replyep    <= {TCU_EP_SIZE{1'b0}};
            r_replysize  <= {TCU_RSIZE_SIZE{1'b0}};
            r_replylabel <= 32'h0;

            r_stall <= 1'b0;
            r_sm_mem_en <= 1'b0;

            r_ack_recv <= 1'b0;
            r_ack_error <= TCU_ERROR_NONE;

            r_sm_error <= TCU_ERROR_NONE;
            r_sm_timeout <= 32'h0;
        end
        else begin
            ctrl_sm_state <= next_ctrl_sm_state;

            r_sep_1 <= rin_sep_1;
            r_sep_2 <= rin_sep_2;

            r_laddr      <= rin_laddr;
            r_size       <= rin_size;
            r_sendep     <= rin_sendep;
            r_crdep      <= rin_crdep;
            r_curcrd     <= rin_curcrd;
            r_replyep    <= rin_replyep;
            r_replysize  <= rin_replysize;
            r_replylabel <= rin_replylabel;

            r_stall <= noc_stall_i || sm_mem_stall_i;
            r_sm_mem_en <= sm_mem_en_o[0];

            r_ack_recv <= rin_ack_recv;
            r_ack_error <= rin_ack_error;

            r_sm_error <= rin_sm_error;
            r_sm_timeout <= rin_sm_timeout;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_sm_state = ctrl_sm_state;

        rin_sep_1 = r_sep_1;
        rin_sep_2 = r_sep_2;

        noc_wrreq_o = 1'b0;
        noc_burst_o = 1'b0;
        noc_bsel_o = {NOC_BSEL_SIZE{1'b0}};
        noc_data0_o = {NOC_DATA_SIZE{1'b0}};
        noc_data1_o = {NOC_DATA_SIZE{1'b0}};

        rin_laddr      = r_laddr;
        rin_size       = r_size;
        rin_sendep     = r_sendep;
        rin_crdep      = r_crdep;
        rin_curcrd     = r_curcrd;
        rin_replyep    = r_replyep;
        rin_replysize  = r_replysize;
        rin_replylabel = r_replylabel;

        rin_sm_error = r_sm_error;
        rin_sm_timeout = 32'h0;

        tlb_read_o = 1'b0;


        case (ctrl_sm_state)

            //---------------
            //wait for incoming command
            S_CTRL_SM_IDLE: begin
                if (sm_start_i && (sm_opcode_i == TCU_OPCODE_SEND)) begin

                    //read access type
                    if (sep_type_s == TCU_EP_TYPE_SEND) begin

                        //check reply flag
                        if (sep_reply_s == 1'b0) begin

                            //check VPE
                            if (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (sm_cur_vpeid_i == sep_vpeid_s)) begin

                                //check msg_sz field in send-ep (multiple bursts are not allowed!)
                                if ((32'h1 << sep_msgsz_s) <= (MAX_BURST_LENGTH_MSG<<4)) begin

                                    //check msg size
                                    if ((sm_size_i + TCU_HD_REG_SIZE) <= (32'h1 << sep_msgsz_s)) begin

                                        //check msg alignment
                                        if (sm_laddr_i[3:0] == 4'h0) begin

                                            //check if there is a page boundary in addr range
                                            if (!(TCU_ENABLE_VIRT_ADDR && tcu_features_virt_addr_i) ||
                                                ((({{TCU_TLB_PHYSPAGE_SIZE{1'b0}}, sm_laddr_i[TCU_PAGEOFFSET_SIZE_4KB-1:0]} + sm_size_i) <= TCU_PAGE_SIZE_4KB))) begin
                                                rin_curcrd = sep_curcrd_s;
                                                rin_sep_1 = sm_epdata_i[2*64-1:64];
                                                rin_sep_2 = sm_epdata_i[3*64-1:2*64];

                                                rin_laddr = sm_laddr_i;
                                                rin_size = sm_size_i[15:0];

                                                rin_replylabel = sm_replylabel_i;
                                                rin_sendep = sm_sendep_i;

                                                rin_replyep = sm_replyep_i;

                                                //if VM is activated, access TLB first
                                                if (TCU_ENABLE_VIRT_ADDR && tcu_features_virt_addr_i) begin
                                                    next_ctrl_sm_state = S_CTRL_SM_TLB_LOOKUP;
                                                end

                                                //check if reply ep is configured
                                                else begin
                                                    if (sm_replyep_i != {TCU_EP_SIZE{1'b1}}) begin
                                                        next_ctrl_sm_state = S_CTRL_SM_READ_REPLYEP1;
                                                    end else begin
                                                        rin_replysize = $clog2(TCU_HD_REG_SIZE);    //send empty reply
                                                        next_ctrl_sm_state = S_CTRL_SM_CHECK_CREDITS;
                                                    end
                                                end

                                                rin_sm_error = TCU_ERROR_NONE;
                                            end
                                            else begin
                                                rin_sm_error = TCU_ERROR_PAGE_BOUNDARY;
                                                next_ctrl_sm_state = S_CTRL_SM_FINISH;
                                            end
                                        end
                                        else begin
                                            rin_sm_error = TCU_ERROR_MSG_UNALIGNED;
                                            next_ctrl_sm_state = S_CTRL_SM_FINISH;
                                        end
                                    end
                                    else begin
                                        rin_sm_error = TCU_ERROR_OUT_OF_BOUNDS;
                                        next_ctrl_sm_state = S_CTRL_SM_FINISH;
                                    end
                                end
                                else begin
                                    rin_sm_error = TCU_ERROR_SEND_INV_MSG_SZ;
                                    next_ctrl_sm_state = S_CTRL_SM_FINISH;
                                end
                            end
                            else begin
                                rin_sm_error = TCU_ERROR_FOREIGN_EP;
                                next_ctrl_sm_state = S_CTRL_SM_FINISH;
                            end
                        end
                        else begin
                            rin_sm_error = TCU_ERROR_SEND_REPLY_EP;
                            next_ctrl_sm_state = S_CTRL_SM_FINISH;
                        end
                    end
                    else begin
                        rin_sm_error = TCU_ERROR_NO_SEP;
                        next_ctrl_sm_state = S_CTRL_SM_FINISH;
                    end
                end
            end


            //---------------
            //TLB lookup
            S_CTRL_SM_TLB_LOOKUP: begin
                if (TCU_ENABLE_VIRT_ADDR) begin
                    if (!tlb_active_i) begin
                        tlb_read_o = 1'b1;  //virt page number and vpe id is set in tcu_ctrl
                        next_ctrl_sm_state = S_CTRL_SM_TLB_WAIT;
                    end

                    //stop on abort
                    if (sm_abort_i) begin
                        rin_sm_error = TCU_ERROR_ABORT;
                        next_ctrl_sm_state = S_CTRL_SM_FINISH;
                    end
                end
            end

            //wait for TLB access
            S_CTRL_SM_TLB_WAIT: begin
                if (TCU_ENABLE_VIRT_ADDR) begin
                    if (tlb_read_done_i) begin
                        if (tlb_read_error_i == TCU_ERROR_NONE) begin
                            rin_laddr = {tlb_physpage_i, r_laddr[TCU_PHYSADDR_SIZE-TCU_TLB_PHYSPAGE_SIZE-1 : 0]}; //keep lower bits from virt addr

                            if (r_replyep != {TCU_EP_SIZE{1'b1}}) begin
                                next_ctrl_sm_state = S_CTRL_SM_READ_REPLYEP1;
                            end else begin
                                rin_replysize = $clog2(TCU_HD_REG_SIZE);    //send empty reply
                                next_ctrl_sm_state = S_CTRL_SM_CHECK_CREDITS;
                            end
                        end
                        else begin
                            rin_sm_error = tlb_read_error_i;
                            next_ctrl_sm_state = S_CTRL_SM_FINISH;
                        end
                    end

                    //stop on abort
                    if (sm_abort_i) begin
                        rin_sm_error = TCU_ERROR_ABORT;
                        next_ctrl_sm_state = S_CTRL_SM_FINISH;
                    end
                end
            end


            //---------------
            //fetch data from reply ep, if available
            S_CTRL_SM_READ_REPLYEP1: begin
                if (!sm_reg_stall_i) begin
                    next_ctrl_sm_state = S_CTRL_SM_READ_REPLYEP2;
                end
            end

            S_CTRL_SM_READ_REPLYEP2: begin
                //reg read data should be there now
                if (sm_reg_rdata_i[TCU_EP_TYPE_SIZE-1:0] == TCU_EP_TYPE_RECEIVE) begin
                    rin_replysize = sm_reg_rdata_i[TCU_RSIZE_SIZE+TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_EP_TYPE_SIZE+16-1 : TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_EP_TYPE_SIZE+16];   //slot_size
                    next_ctrl_sm_state = S_CTRL_SM_CHECK_CREDITS;
                end
                else begin
                    rin_sm_error = TCU_ERROR_NO_REP;
                    next_ctrl_sm_state = S_CTRL_SM_FINISH;
                end
            end


            //---------------
            //check credits
            S_CTRL_SM_CHECK_CREDITS: begin
                //check if credits are available at all
                if (sep_curcrd == {TCU_CRD_SIZE{1'b0}}) begin
                    rin_sm_error = TCU_ERROR_NO_CREDITS;
                    next_ctrl_sm_state = S_CTRL_SM_FINISH;
                end
                else begin
                    //unlimited credits, invalidate send-ep for reply (crd_ep)
                    //otherwise use this send-ep
                    if (sep_curcrd == {TCU_CRD_SIZE{1'b1}}) begin
                        rin_crdep = {TCU_EP_SIZE{1'b1}};
                    end else begin
                        rin_crdep = r_sendep;
                    end

                    //extra stage only when DRAM is attached with undefined read delay
                    if (TCU_ENABLE_DRAM && (r_size != 'd0)) begin
                        next_ctrl_sm_state = S_CTRL_SM_PREPARE_MEM1;
                    end else begin
                        next_ctrl_sm_state = S_CTRL_SM_SEND_HD1;
                    end
                end
            end


            //---------------
            //send information about total size to preload it from memory
            S_CTRL_SM_PREPARE_MEM1: begin
                if (!sm_mem_stall_i) begin
                    next_ctrl_sm_state = S_CTRL_SM_PREPARE_MEM2;
                end
            end

            //check when prepared data becomes available
            S_CTRL_SM_PREPARE_MEM2: begin
                if (sm_mem_rdata_avail_i) begin
                    next_ctrl_sm_state = S_CTRL_SM_SEND_HD1;
                end

                //timeout
                else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                    rin_sm_timeout = r_sm_timeout + 32'd1;
                    if (r_sm_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_sm_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_sm_state = S_CTRL_SM_FINISH;
                    end
                end
            end

            //---------------
            //write msg header to NoC packet and send it to recv ep
            S_CTRL_SM_SEND_HD1: begin
                //first check abort condition
                if (sm_abort_i) begin
                    rin_sm_error = TCU_ERROR_ABORT;
                    next_ctrl_sm_state = S_CTRL_SM_FINISH;
                end
                else if (!noc_stall_i) begin
                    //prepare NoC header packet
                    noc_wrreq_o = 1'b1;
                    noc_burst_o = 1'b1;
                    noc_bsel_o = {(r_size[3:0] - 1), {(NOC_BSEL_SIZE/2){1'b1}}};   //aligned msg header (laddr[3:0]==0), last valid byte: size[3:0] - 1
                    noc_data0_o = r_size[15:4] + |r_size[3:0] + 1;  //burst length: palyoad + header

                    next_ctrl_sm_state = S_CTRL_SM_SEND_HD2;
                end
            end

            S_CTRL_SM_SEND_HD2: begin
                if (!noc_stall_i) begin
                    //send flit with msg header
                    noc_wrreq_o = 1'b1;
                    noc_burst_o = 1'b1;
                    noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};
                    noc_data0_o = {r_replyep, r_crdep, r_size[TCU_MSGLEN_SIZE-1:0], home_chipid_i, HOME_MODID, r_replysize, {TCU_HD_FLAG_SIZE{1'b0}}};
                    noc_data1_o = {sep_label, r_replylabel};

                    //skip payload for empty msg
                    if (r_size == 'd0) begin
                        noc_burst_o = 1'b0; //burst ends
                        next_ctrl_sm_state = S_CTRL_SM_WAIT_ACK;
                    end
                    else begin
                        next_ctrl_sm_state = S_CTRL_SM_SEND_PL;
                    end
                end
            end

            //write msg payload to NoC packet
            S_CTRL_SM_SEND_PL: begin
                if (!noc_stall_i) begin
                    if (sm_mem_stall_i && (r_size > 'd0)) begin
                        noc_burst_o = 1'b1;
                        noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};
                        next_ctrl_sm_state = S_CTRL_SM_SEND_PL;

                        //check abort condition
                        if (sm_abort_i) begin
                            noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                            rin_sm_error = TCU_ERROR_ABORT;
                            next_ctrl_sm_state = S_CTRL_SM_ABORT;
                        end

                        //timeout
                        else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                            rin_sm_timeout = r_sm_timeout + 32'd1;
                            if (r_sm_timeout > TIMEOUT_SEND_CYCLES) begin
                                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                                rin_sm_error = TCU_ERROR_TIMEOUT_MEM;
                                next_ctrl_sm_state = S_CTRL_SM_ABORT;
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
                            if (sm_abort_i) begin
                                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                                rin_sm_error = TCU_ERROR_ABORT;
                                next_ctrl_sm_state = S_CTRL_SM_ABORT;
                            end
                            else begin
                                next_ctrl_sm_state = S_CTRL_SM_SEND_PL;
                            end
                        end

                        //stop burst
                        else begin
                            noc_burst_o = 1'b0;
                            next_ctrl_sm_state = S_CTRL_SM_WAIT_ACK;
                        end
                    end
                end
            end


            //---------------
            //abort send cmd, still send flits of remaining burst but deassert bsel
            S_CTRL_SM_ABORT: begin
                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}};
                
                if (!noc_stall_i) begin
                    noc_wrreq_o = 1'b1;
                    
                    if (r_size > 'd16) begin
                        rin_size = r_size - 'd16;
                        noc_burst_o = 1'b1;
                    end

                    //stop burst
                    else begin
                        rin_size = 'd0;
                        noc_burst_o = 1'b0;
                        next_ctrl_sm_state = S_CTRL_SM_WAIT_ACK;
                    end
                end
            end


            //---------------
            S_CTRL_SM_WAIT_ACK: begin
                //check if ack was received
                //only proceed when last packet was properly send
                if (r_ack_recv && !noc_stall_i) begin
                    rin_sm_error = r_ack_error;

                    //reduce credits if they are not unlimited
                    //and if msg was received successfully
                    if ((sep_curcrd != {TCU_CRD_SIZE{1'b1}}) && (r_ack_error == {TCU_ERROR_SIZE{1'b0}})) begin
                        next_ctrl_sm_state = S_CTRL_SM_UPDATE_EP1;
                    end else begin
                        next_ctrl_sm_state = S_CTRL_SM_FINISH;
                    end
                end
                else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                    rin_sm_timeout = r_sm_timeout + 32'd1;
                    if (r_sm_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_sm_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_sm_state = S_CTRL_SM_FINISH;
                    end
                end
            end

            //update ep with new credits
            S_CTRL_SM_UPDATE_EP1: begin
                if (!sm_reg_stall_i && !sm_crd_update_stall_i) begin
                    next_ctrl_sm_state = S_CTRL_SM_UPDATE_EP2;
                end
            end

            S_CTRL_SM_UPDATE_EP2: begin
                rin_curcrd = sm_reg_rdata_i[TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];

                //check that SEP reg has not been changed, otherwise go back and read again
                if (sm_crd_update_stall_i) begin
                    next_ctrl_sm_state = S_CTRL_SM_UPDATE_EP1;
                end else begin
                    next_ctrl_sm_state = S_CTRL_SM_UPDATE_EP3;
                end
            end

            S_CTRL_SM_UPDATE_EP3: begin
                if (sm_crd_update_stall_i) begin
                    next_ctrl_sm_state = S_CTRL_SM_UPDATE_EP1;
                end
                else if (!sm_reg_stall_i) begin
                    next_ctrl_sm_state = S_CTRL_SM_FINISH;
                end
            end

            //---------------
            S_CTRL_SM_FINISH: begin
                next_ctrl_sm_state = S_CTRL_SM_IDLE;
            end

            default: next_ctrl_sm_state = S_CTRL_SM_IDLE;

        endcase //case (ctrl_sm_state)
    end


    //---------------
    //hold ack info
    always @* begin
        rin_ack_recv = r_ack_recv;
        rin_ack_error = r_ack_error;

        //if send is ongoing
        if (sm_active_o) begin
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
        sm_reg_en_o = 1'b0;
        sm_reg_wben_o = {TCU_REG_DATA_SIZE{1'b0}};
        sm_reg_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
        sm_reg_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};

        if (ctrl_sm_state == S_CTRL_SM_UPDATE_EP1) begin
            sm_reg_en_o = 1'b1;
            sm_reg_addr_o = TCU_REGADDR_EP_START + r_sendep*TCU_EP_REG_SIZE;
        end
        else if (ctrl_sm_state == S_CTRL_SM_UPDATE_EP3) begin
            sm_reg_en_o = 1'b1;
            sm_reg_wben_o = {{{TCU_REG_DATA_SIZE-TCU_CRD_SIZE}{1'b0}}, {TCU_CRD_SIZE{1'b1}}} << (TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE);
            sm_reg_addr_o = TCU_REGADDR_EP_START + r_sendep*TCU_EP_REG_SIZE;
            sm_reg_wdata_o = sep_curcrd_decr << (TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE);
        end

        else if (ctrl_sm_state == S_CTRL_SM_READ_REPLYEP1) begin
            sm_reg_en_o = 1'b1;
            sm_reg_addr_o = TCU_REGADDR_EP_START + r_replyep*TCU_EP_REG_SIZE;
        end
    end



    //---------------
    //memory interface
    always @* begin
        sm_mem_en_o = 2'b00;    //bit 0: memory access, bit 1: memory request for DRAM-like mems

        if (ctrl_sm_state == S_CTRL_SM_PREPARE_MEM1) begin
            sm_mem_en_o = 2'b10;
        end
        else if ((ctrl_sm_state == S_CTRL_SM_SEND_PL) && (r_size > 'd0)) begin    //do not enable mem during burst when last packet of burst
            sm_mem_en_o = 2'b01;
        end
    end


    assign sm_mem_addr_o = r_laddr;
    assign sm_mem_rdata_valid_o = r_sm_mem_en && !r_stall;
    assign sm_mem_wdata_o = r_size;

    assign sm_error_o = r_sm_error;
    assign sm_active_o = (ctrl_sm_state != S_CTRL_SM_IDLE);
    assign sm_noc_active_o = sm_active_o && (ctrl_sm_state < S_CTRL_SM_WAIT_ACK);
    assign sm_done_o = (ctrl_sm_state == S_CTRL_SM_FINISH);

    //always set recv ep and pe to NoC IF
    assign noc_addr_o = sep_ep;
    assign noc_chipid_o = sep_chip;
    assign noc_modid_o = sep_pe;
    assign noc_mode_o = MODE_TCU_MSG;


endmodule
