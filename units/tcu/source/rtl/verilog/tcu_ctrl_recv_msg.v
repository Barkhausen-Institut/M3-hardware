
module tcu_ctrl_recv_msg #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_VIRT_PES       = 0,
    parameter TCU_ENABLE_DRAM            = 0,
    parameter TCU_ENABLE_LOG             = 0,
    parameter [31:0] TIMEOUT_RECV_CYCLES = 0
)(
    input  wire                                clk_i,
    input  wire                                reset_n_i,

    //---------------
    //reg IF
    output reg                                 rm_reg_en_o,
    output reg         [TCU_REG_DATA_SIZE-1:0] rm_reg_wben_o,
    output wire        [TCU_REG_ADDR_SIZE-1:0] rm_reg_addr_o,
    output wire        [TCU_REG_DATA_SIZE-1:0] rm_reg_wdata_o,
    input  wire        [TCU_REG_DATA_SIZE-1:0] rm_reg_rdata_i,
    input  wire                                rm_reg_stall_i,

    //---------------
    //Mem IF (only write)
    output wire                          [2:0] rm_mem_en_o,
    output wire        [TCU_MEM_BSEL_SIZE-1:0] rm_mem_wben_o,
    output wire        [TCU_MEM_ADDR_SIZE-1:0] rm_mem_addr_o,
    output wire        [TCU_MEM_DATA_SIZE-1:0] rm_mem_wdata_o,
    input  wire                                rm_mem_wdata_infifo_i,
    output reg                                 rm_mem_wabort_o,
    input  wire                                rm_mem_stall_i,

    //---------------
    //signals to activate NoC
    output reg                                 noc_fifo_pop_o,
    input  wire                                noc_wrreq_i,
    input  wire                                noc_burst_i,
    input  wire            [NOC_BSEL_SIZE-1:0] noc_bsel_i,
    input  wire                                noc_stall_i,
    output wire                                noc_wrreq_o,
    output wire            [NOC_DATA_SIZE-1:0] noc_data_o,
    output wire            [NOC_ADDR_SIZE-1:0] noc_addr_o,
    output wire          [NOC_CHIPID_SIZE-1:0] noc_chipid_o,
    output wire           [NOC_MODID_SIZE-1:0] noc_modid_o,

    //---------------
    //triggers from tcu_ctrl
    input  wire                                rm_start_i,
    input  wire              [TCU_EP_SIZE-1:0] rm_recvep_i,   //recv ep coming from sender
    input  wire                        [127:0] rm_header_i,   //header of incoming message
    input  wire                         [31:0] rm_cur_vpe_i,
    output wire                                rm_active_o,
    output wire                                rm_cur_vpe_active_o,
    output wire                                rm_crd_update_active_o,
    output reg                                 rm_done_o,

    //---------------
    //core req IF
    output reg                                 rm_core_req_push_o,
    output reg  [TCU_CORE_REQ_FORMSG_SIZE-1:0] rm_core_req_data_o,
    input  wire                                rm_core_req_stall_i,

    //---------------
    //TCU logging
    output wire        [TCU_LOG_DATA_SIZE-1:0] tcu_log_rm_o,

    //---------------
    //TCU feature settings
    input  wire                                tcu_features_virt_pes_i,

    //---------------
    //Home Chip-ID
    input  wire          [NOC_CHIPID_SIZE-1:0] home_chipid_i
);

    `include "tcu_functions.v"


    localparam CTRL_RM_STATES_SIZE          = 5;
    localparam S_CTRL_RM_IDLE               = 5'h00;
    localparam S_CTRL_RM_READ_EP1           = 5'h01;
    localparam S_CTRL_RM_READ_EP2           = 5'h02;
    localparam S_CTRL_RM_READ_EP3           = 5'h03;
    localparam S_CTRL_RM_READ_EP4           = 5'h04;
    localparam S_CTRL_RM_TAKE_HD1           = 5'h05;
    localparam S_CTRL_RM_CHECK_EP           = 5'h06;
    localparam S_CTRL_RM_FIND_SLOT          = 5'h07;
    localparam S_CTRL_RM_WRITE_PREPARE_MEM1 = 6'h08;
    localparam S_CTRL_RM_WRITE_PREPARE_MEM2 = 6'h09;
    localparam S_CTRL_RM_WRITE_MEM_HD1      = 5'h0A;
    localparam S_CTRL_RM_WRITE_MEM_HD2      = 5'h0B;
    localparam S_CTRL_RM_WRITE_MEM_PL1      = 5'h0C;
    localparam S_CTRL_RM_WRITE_MEM_PL2      = 5'h0D;
    localparam S_CTRL_RM_UPDATE_EP3         = 5'h0E;
    localparam S_CTRL_RM_UPDATE_EP4         = 5'h0F;
    localparam S_CTRL_RM_CREATE_REPLYEP1    = 5'h10;
    localparam S_CTRL_RM_CREATE_REPLYEP2    = 5'h11;
    localparam S_CTRL_RM_CREATE_REPLYEP3    = 5'h12;
    localparam S_CTRL_RM_CREATE_REPLYEP4    = 5'h13;
    localparam S_CTRL_RM_READ_SEP1          = 5'h14;
    localparam S_CTRL_RM_READ_SEP2          = 5'h15;
    localparam S_CTRL_RM_READ_SEP3          = 5'h16;
    localparam S_CTRL_RM_UPDATE_SEP1        = 5'h17;
    localparam S_CTRL_RM_UPDATE_SEP2        = 5'h18;
    localparam S_CTRL_RM_CHECK_VPE          = 5'h19;
    localparam S_CTRL_RM_UPDATE_VPE         = 5'h1A;
    localparam S_CTRL_RM_WAIT_DRAM          = 5'h1B;
    localparam S_CTRL_RM_DROP_MSG           = 5'h1C;
    localparam S_CTRL_RM_DROP_MSG_PL        = 5'h1D;
    localparam S_CTRL_RM_ERROR              = 5'h1E;
    localparam S_CTRL_RM_FINISH             = 5'h1F;

    reg [CTRL_RM_STATES_SIZE-1:0] ctrl_rm_state, next_ctrl_rm_state;



    //temp ep regs
    reg [63:0] r_rep_0, rin_rep_0;
    reg [63:0] r_rep_1, rin_rep_1;
    reg [63:0] r_rep_2, rin_rep_2;

    reg [63:0] r_sep_0, rin_sep_0;

    //temp hd reg
    reg [63:0] r_hd_0, rin_hd_0;
    reg [63:0] r_hd_1, rin_hd_1;
    reg [63:0] r_hd_2, rin_hd_2;


    reg [31:0] r_laddr, rin_laddr;  //addr to store incoming data to memory
    reg [15:0] r_size, rin_size;    //size of taken data from incoming NoC packets (bytes)

    reg                   [2:0] r_mem_en, rin_mem_en;
    reg [TCU_MEM_BSEL_SIZE-1:0] r_mem_wben, rin_mem_wben;
    reg [TCU_MEM_ADDR_SIZE-1:0] r_mem_addr;

    reg [TCU_REG_DATA_SIZE-1:0] r_reg_wben, rin_reg_wben;
    reg [TCU_REG_ADDR_SIZE-1:0] r_reg_addr, rin_reg_addr;
    reg [TCU_REG_DATA_SIZE-1:0] r_reg_wdata, rin_reg_wdata;

    //mark read data from reg available
    reg r_rm_reg_rdata_avail, rin_rm_reg_rdata_avail;

    //error code (only sent by ack)
    reg [TCU_ERROR_SIZE-1:0] r_rm_error, rin_rm_error;

    //addr of recveive ep
    reg [TCU_EP_SIZE-1:0] r_recvep, rin_recvep;
    reg [31:0] r_recvep_baseaddr, rin_recvep_baseaddr;

    //current write index
    reg [TCU_SLOT_SIZE-1:0] r_tmp_wpos, rin_tmp_wpos;

    //timeout
    reg [31:0] r_rm_timeout, rin_rm_timeout;


    //ep info
    wire [TCU_EP_TYPE_SIZE-1:0] rep_type     = r_rep_0[TCU_EP_TYPE_SIZE-1 : 0];
    wire   [TCU_VPEID_SIZE-1:0] rep_vpeid    = r_rep_0[TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] rep_rpleps   = r_rep_0[TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slots    = r_rep_0[TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slotsize = r_rep_0[2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_wpos     = r_rep_0[3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_rpos     = r_rep_0[4*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire                 [63:0] rep_buffer   = r_rep_1;
    wire                 [31:0] rep_occupied = r_rep_2[31:0];
    wire                 [31:0] rep_unread   = r_rep_2[63:32];

    wire      [TCU_CRD_SIZE-1:0] sep_curcrd      = r_sep_0[TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire [TCU_REG_DATA_SIZE-1:0] sep_curcrd_incr = sep_curcrd + 'd1;


    //hd info
    wire [TCU_HD_FLAG_SIZE-1:0] hd_flags      = r_hd_0[TCU_HD_FLAG_SIZE-1 : 0];
    wire   [TCU_RSIZE_SIZE-1:0] hd_replysize  = r_hd_0[TCU_RSIZE_SIZE+TCU_HD_FLAG_SIZE-1 : TCU_HD_FLAG_SIZE];
    wire    [TCU_PEID_SIZE-1:0] hd_sendpe     = r_hd_0[TCU_PEID_SIZE+TCU_RSIZE_SIZE+TCU_HD_FLAG_SIZE-1 : TCU_RSIZE_SIZE+TCU_HD_FLAG_SIZE];
    wire  [TCU_CHIPID_SIZE-1:0] hd_sendchip   = r_hd_0[TCU_CHIPID_SIZE+TCU_PEID_SIZE+TCU_RSIZE_SIZE+TCU_HD_FLAG_SIZE-1 : TCU_PEID_SIZE+TCU_RSIZE_SIZE+TCU_HD_FLAG_SIZE];
    wire  [TCU_MSGLEN_SIZE-1:0] hd_length     = r_hd_0[TCU_MSGLEN_SIZE+TCU_CHIPID_SIZE+TCU_PEID_SIZE+TCU_RSIZE_SIZE+TCU_HD_FLAG_SIZE-1 : TCU_CHIPID_SIZE+TCU_PEID_SIZE+TCU_RSIZE_SIZE+TCU_HD_FLAG_SIZE];
    wire      [TCU_EP_SIZE-1:0] hd_sendep     = r_hd_0[TCU_EP_SIZE+32-1 : 32];
    wire      [TCU_EP_SIZE-1:0] hd_recvep     = r_hd_0[2*TCU_EP_SIZE+32-1 : TCU_EP_SIZE+32];
    wire                 [63:0] hd_replylabel = r_hd_1;
    wire                 [63:0] hd_label      = r_hd_2;


    //some helper wires
    wire [31:0] recvep_addr   = TCU_REGADDR_EP_START + rm_recvep_i*TCU_EP_REG_SIZE;
    wire [31:0] hdrecvep_addr = TCU_REGADDR_EP_START + hd_recvep*TCU_EP_REG_SIZE;
    wire [31:0] rplep_addr    = TCU_REGADDR_EP_START + (rep_rpleps+r_tmp_wpos)*TCU_EP_REG_SIZE;

    wire     [TCU_SLOT_SIZE-1:0] tmp_pos_incr = r_tmp_wpos + 1'b1;
    wire [TCU_REG_DATA_SIZE-1:0] set_bit_wpos = 32'h1 << r_tmp_wpos;

    //max. number of slots is 32
    wire [TCU_SLOT_SIZE-1:0] max_slot = (rep_slots > 'h5) ? 'd32 : {{(TCU_SLOT_SIZE-1){1'b0}}, 1'b1} << rep_slots[2:0];

    //number of ones in wben
    wire [4:0] wben_count_ones = count_ones8(rin_mem_wben[7:0]) + count_ones8(rin_mem_wben[15:8]);

    //updated msgs count
    wire [TCU_REG_DATA_SIZE-1:0] cur_vpe_msgs_incr = rm_cur_vpe_i[TCU_VPE_MSGS_SIZE+TCU_VPEID_SIZE-1:TCU_VPEID_SIZE] + 'd1;

    //adapt width of reply size from header to slot size in EP
    wire [TCU_SLOT_SIZE-1:0] reply_msg_sz = hd_replysize;


    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_rm_state <= S_CTRL_RM_IDLE;

            r_laddr <= 32'h0;
            r_size <= 16'h0;

            r_rm_reg_rdata_avail <= 1'b0;
            r_rm_error <= TCU_ERROR_NONE;

            r_mem_en <= 3'h0;
            r_mem_wben <= {TCU_MEM_BSEL_SIZE{1'b0}};
            r_mem_addr <= {TCU_MEM_ADDR_SIZE{1'b0}};

            r_reg_wben <= {TCU_REG_DATA_SIZE{1'b0}};
            r_reg_addr <= {TCU_REG_ADDR_SIZE{1'b0}};
            r_reg_wdata <= {TCU_REG_DATA_SIZE{1'b0}};

            r_recvep <= {TCU_EP_SIZE{1'b0}};
            r_recvep_baseaddr <= 32'h0;

            r_hd_0 <= 64'h0;
            r_hd_1 <= 64'h0;
            r_hd_2 <= 64'h0;

            r_rep_0 <= 64'h0;
            r_rep_1 <= 64'h0;
            r_rep_2 <= 64'h0;

            r_sep_0 <= 64'h0;

            r_tmp_wpos <= {TCU_SLOT_SIZE{1'b0}};

            r_rm_timeout <= 32'h0;
        end
        else begin
            ctrl_rm_state <= next_ctrl_rm_state;
            
            r_laddr <= rin_laddr;
            r_size <= rin_size;

            r_rm_reg_rdata_avail <= rin_rm_reg_rdata_avail;
            r_rm_error <= rin_rm_error;

            r_mem_en <= rin_mem_en;
            r_mem_wben <= rin_mem_wben;
            r_mem_addr <= r_laddr;

            r_reg_wben <= rin_reg_wben;
            r_reg_addr <= rin_reg_addr;
            r_reg_wdata <= rin_reg_wdata;

            r_recvep <= rin_recvep;
            r_recvep_baseaddr <= rin_recvep_baseaddr;

            r_hd_0 <= rin_hd_0;
            r_hd_1 <= rin_hd_1;
            r_hd_2 <= rin_hd_2;
            
            r_rep_0 <= rin_rep_0;
            r_rep_1 <= rin_rep_1;
            r_rep_2 <= rin_rep_2;

            r_sep_0 <= rin_sep_0;

            r_tmp_wpos <= rin_tmp_wpos;

            r_rm_timeout <= rin_rm_timeout;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_rm_state = ctrl_rm_state;

        rin_laddr = r_laddr;
        rin_size = r_size;

        noc_fifo_pop_o = 1'b0;

        rin_rm_reg_rdata_avail = 1'b0;
        rin_rm_error = r_rm_error;

        rm_done_o = 1'b0;

        rin_tmp_wpos = r_tmp_wpos;

        rin_recvep = r_recvep;
        rin_recvep_baseaddr = r_recvep_baseaddr;

        rin_reg_wben = r_reg_wben;
        rin_reg_addr = r_reg_addr;
        rin_reg_wdata = r_reg_wdata;

        rin_hd_0 = r_hd_0;
        rin_hd_1 = r_hd_1;
        rin_hd_2 = r_hd_2;
            
        rin_rep_0 = r_rep_0;
        rin_rep_1 = r_rep_1;
        rin_rep_2 = r_rep_2;

        rin_sep_0 = r_sep_0;

        rm_core_req_push_o = 1'b0;
        rm_core_req_data_o = {TCU_CORE_REQ_FORMSG_SIZE{1'b0}};

        rin_rm_timeout = 32'h0;

        rm_mem_wabort_o = 1'b0;


        case (ctrl_rm_state)

            //---------------
            //wait for incoming command
            S_CTRL_RM_IDLE: begin
                if (rm_start_i) begin
                    //take incoming recv ep
                    rin_recvep = rm_recvep_i;
                    rin_recvep_baseaddr = recvep_addr;
                    rin_reg_addr = recvep_addr;

                    next_ctrl_rm_state = S_CTRL_RM_READ_EP1;
                    rin_rm_error = TCU_ERROR_NONE;
                end
            end

            //---------------
            //read ep to identify where to store payload
            S_CTRL_RM_READ_EP1: begin
                if (!rm_reg_stall_i) begin
                    rin_reg_addr = r_reg_addr + 'h8;
                    rin_rm_reg_rdata_avail = 1'b1;
                    next_ctrl_rm_state = S_CTRL_RM_READ_EP2;
                end
            end

            S_CTRL_RM_READ_EP2: begin
                if (r_rm_reg_rdata_avail) begin
                    rin_rep_0 = rm_reg_rdata_i;
                end

                if (!rm_reg_stall_i) begin
                    rin_reg_addr = r_reg_addr + 'h8;
                    rin_rm_reg_rdata_avail = 1'b1;
                    next_ctrl_rm_state = S_CTRL_RM_READ_EP3;
                end
            end

            S_CTRL_RM_READ_EP3: begin
                //first part of ep is available here
                //if wpos is outside of valid slots, start at 0
                rin_tmp_wpos = rep_wpos;

                if (r_rm_reg_rdata_avail) begin
                    rin_rep_1 = rm_reg_rdata_i;
                end

                if (!rm_reg_stall_i) begin
                    next_ctrl_rm_state = S_CTRL_RM_READ_EP4;
                end
            end

            S_CTRL_RM_READ_EP4: begin
                //just take read data
                rin_rep_2 = rm_reg_rdata_i;
                next_ctrl_rm_state = S_CTRL_RM_TAKE_HD1;
            end

            //---------------
            S_CTRL_RM_TAKE_HD1: begin
                if (noc_wrreq_i) begin
                    //take first part of header
                    rin_hd_0 = rm_header_i[63:0];
                    rin_hd_1 = rm_header_i[127:64];
                    next_ctrl_rm_state = S_CTRL_RM_CHECK_EP;
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rin_rm_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_rm_state = S_CTRL_RM_ERROR;
                    end
                end
            end

            //---------------
            //check if ep is a recv ep and msg fits to slot
            S_CTRL_RM_CHECK_EP: begin
                //interpret ep content as receive ep
                if (rep_type == TCU_EP_TYPE_RECEIVE) begin

                    //check size of received message
                    if ((hd_length+TCU_HD_REG_SIZE) <= (32'h1 << rep_slotsize)) begin

                        //check EP number
                        if ((rep_rpleps == {TCU_EP_SIZE{1'b1}}) ||
                            ((rep_rpleps + (32'h1 << rep_slots)) <= TCU_EP_REG_COUNT)) begin
                            next_ctrl_rm_state = S_CTRL_RM_FIND_SLOT;
                        end
                        else begin
                            rin_rm_error = TCU_ERROR_RECV_INV_RPL_EPS;
                            noc_fifo_pop_o = 1'b1;  //drop first part of header to get access to second part
                            next_ctrl_rm_state = S_CTRL_RM_DROP_MSG;
                        end
                    end
                    else begin
                        rin_rm_error = TCU_ERROR_RECV_OUT_OF_BOUNDS;
                        noc_fifo_pop_o = 1'b1;  //drop first part of header to get access to second part
                        next_ctrl_rm_state = S_CTRL_RM_DROP_MSG;
                    end
                end
                else begin
                    rin_rm_error = TCU_ERROR_RECV_GONE;  //invalid ep, drop payload
                    noc_fifo_pop_o = 1'b1;  //drop first part of header to get access to second part
                    next_ctrl_rm_state = S_CTRL_RM_DROP_MSG;
                end
            end

            //---------------
            //find a free write slot to store incoming payload
            S_CTRL_RM_FIND_SLOT: begin
                //find unoccupied slot starting at wpos
                if (r_tmp_wpos < max_slot) begin
                    if (!rep_occupied[r_tmp_wpos]) begin
                        rin_tmp_wpos = r_tmp_wpos;

                        //prepare addr to store header and payload (still 32-bit addresses)
                        rin_laddr = rep_buffer[31:0] + (r_tmp_wpos<<rep_slotsize);
                        rin_size = hd_length + TCU_HD_REG_SIZE; //header + payload

                        next_ctrl_rm_state = S_CTRL_RM_WRITE_PREPARE_MEM1;
                    end

                    //check if we are wrapped around
                    else if (tmp_pos_incr != rep_wpos) begin
                        rin_tmp_wpos = tmp_pos_incr;
                        next_ctrl_rm_state = S_CTRL_RM_FIND_SLOT;
                    end

                    //no slot found
                    else begin
                        rin_rm_error = TCU_ERROR_RECV_NO_SPACE;   //error, drop message
                        noc_fifo_pop_o = 1'b1;  //drop first part of header to get access to second part
                        next_ctrl_rm_state = S_CTRL_RM_DROP_MSG;
                    end
                end
                else begin
                    //at the end of valid slots, start at the beginning
                    rin_tmp_wpos = 'h0;
                    next_ctrl_rm_state = S_CTRL_RM_FIND_SLOT;
                end
            end


            //---------------
            S_CTRL_RM_WRITE_PREPARE_MEM1: begin
                if (noc_wrreq_i) begin
                    //already prepare ep update
                    rin_reg_wben = {{{TCU_REG_DATA_SIZE-TCU_SLOT_SIZE}{1'b0}}, {TCU_SLOT_SIZE{1'b1}}} << (2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE);
                    rin_reg_addr = r_recvep_baseaddr;
                    rin_reg_wdata = {{(TCU_REG_DATA_SIZE-TCU_SLOT_SIZE){1'b0}}, tmp_pos_incr} << (2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE);  //increment wpos

                    //send size info to mem, if a lot of data is expected
                    if (TCU_ENABLE_DRAM && noc_burst_i && (r_size > 'd16)) begin
                        next_ctrl_rm_state = S_CTRL_RM_WRITE_PREPARE_MEM2;
                    end

                    //only little data, do not prepare mem
                    else begin
                        next_ctrl_rm_state = S_CTRL_RM_WRITE_MEM_HD1;
                    end
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rin_rm_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_rm_state = S_CTRL_RM_ERROR;
                    end
                end
            end

            //if it is a burst, also use burst interface to memory
            S_CTRL_RM_WRITE_PREPARE_MEM2: begin
                if (!rm_mem_stall_i) begin
                    next_ctrl_rm_state = S_CTRL_RM_WRITE_MEM_HD1;
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rm_mem_wabort_o = 1'b1;
                        rin_rm_error = TCU_ERROR_TIMEOUT_MEM;
                        noc_fifo_pop_o = 1'b1;  //drop first part of header to get access to second part
                        next_ctrl_rm_state = S_CTRL_RM_DROP_MSG;
                    end
                end
            end


            //---------------
            //write msg header to memory
            S_CTRL_RM_WRITE_MEM_HD1: begin
                if (noc_wrreq_i) begin
                    if (!rm_mem_stall_i) begin
                        noc_fifo_pop_o = 1'b1;

                        //abort receive if bsel is zero
                        if (noc_bsel_i == {NOC_BSEL_SIZE{1'b0}}) begin
                            rm_mem_wabort_o = 1'b1;
                            rin_rm_error = TCU_ERROR_ABORT;
                            next_ctrl_rm_state = S_CTRL_RM_FINISH;
                        end
                        else begin
                            rin_laddr = r_laddr + 'd16;
                            rin_size = r_size - 5'd16;     //there is the second part of header which always there

                            next_ctrl_rm_state = S_CTRL_RM_WRITE_MEM_HD2;
                        end
                    end

                    //timeout
                    else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                        rin_rm_timeout = r_rm_timeout + 32'd1;
                        if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                            rm_mem_wabort_o = 1'b1;
                            rin_rm_error = TCU_ERROR_TIMEOUT_MEM;
                            noc_fifo_pop_o = 1'b1;  //drop first part of header to get access to second part
                            next_ctrl_rm_state = S_CTRL_RM_DROP_MSG;
                        end
                    end
                end
            end

            S_CTRL_RM_WRITE_MEM_HD2: begin
                if (noc_wrreq_i) begin
                    if (!rm_mem_stall_i) begin
                        //take second part of header
                        rin_hd_2 = rm_header_i[63:0];
                        noc_fifo_pop_o = 1'b1;

                        //abort receive if bsel is zero
                        if (noc_bsel_i == {NOC_BSEL_SIZE{1'b0}}) begin
                            rm_mem_wabort_o = 1'b1;
                            rin_rm_error = TCU_ERROR_ABORT;
                            next_ctrl_rm_state = S_CTRL_RM_FINISH;
                        end
                        else begin
                            rin_laddr = r_laddr + 'd16;
                            rin_size = r_size - (5'd16 - r_laddr[3:0]);     //memory row full, only write elements which still fit

                            //if burst is ongoing, there is a payload, store it
                            if (noc_burst_i) begin
                                next_ctrl_rm_state = S_CTRL_RM_WRITE_MEM_PL1;
                            end

                            //no payload, but header might take an extra store due to bad addr alignment
                            //use new calculated size (rin_size)
                            else if (rin_size > 'd0) begin
                                next_ctrl_rm_state = S_CTRL_RM_WRITE_MEM_PL2;
                            end

                            //no payload, all done
                            else begin
                                next_ctrl_rm_state = S_CTRL_RM_UPDATE_EP3;
                            end
                        end
                    end

                    //timeout
                    else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                        rin_rm_timeout = r_rm_timeout + 32'd1;
                        if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                            rm_mem_wabort_o = 1'b1;
                            rin_rm_error = TCU_ERROR_TIMEOUT_MEM;
                            next_ctrl_rm_state = S_CTRL_RM_DROP_MSG;
                        end
                    end
                end
            end

            //write msg payload to memory
            S_CTRL_RM_WRITE_MEM_PL1: begin
                if (noc_wrreq_i && !rm_mem_stall_i) begin
                    noc_fifo_pop_o = 1'b1;

                    //abort receive if bsel is zero
                    if (noc_bsel_i == {NOC_BSEL_SIZE{1'b0}}) begin
                        rm_mem_wabort_o = 1'b1;
                        rin_rm_error = TCU_ERROR_ABORT;
                        next_ctrl_rm_state = S_CTRL_RM_FINISH;
                    end
                    else begin
                        rin_size = r_size - wben_count_ones;
                        rin_laddr = r_laddr + 'd16;     //we only store the number of bytes given by bsel

                        //still a burst? -> it is not last flit
                        if (noc_burst_i) begin
                            //cancel recv even when burst is ongoing but no more packets are expected
                            if (r_size > 'd16) begin
                                next_ctrl_rm_state = S_CTRL_RM_WRITE_MEM_PL1;
                            end
                            else begin
                                rin_rm_error = TCU_ERROR_CRITICAL;
                                next_ctrl_rm_state = S_CTRL_RM_UPDATE_EP3;
                            end
                        end

                        //burst ends
                        else begin

                            //additional store is required due to size>16
                            if (r_size > 'd16) begin
                                next_ctrl_rm_state = S_CTRL_RM_WRITE_MEM_PL2;
                            end

                            //done, continue
                            else begin
                                rin_size = 'd0;
                                next_ctrl_rm_state = S_CTRL_RM_UPDATE_EP3;
                            end
                        end
                    end
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rm_mem_wabort_o = 1'b1;
                        rin_rm_error = noc_wrreq_i ? TCU_ERROR_TIMEOUT_MEM : TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_rm_state = S_CTRL_RM_ERROR;
                    end
                end
            end

            //write last part of last flit to memory
            S_CTRL_RM_WRITE_MEM_PL2: begin
                if (!rm_mem_stall_i) begin
                    rin_size = 'd0;
                    next_ctrl_rm_state = S_CTRL_RM_UPDATE_EP3;
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rm_mem_wabort_o = 1'b1;
                        rin_rm_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_rm_state = S_CTRL_RM_ERROR;
                    end
                end
            end


            //---------------
            //update ep: write to ep reg
            S_CTRL_RM_UPDATE_EP3: begin
                if (!rm_reg_stall_i) begin
                    rin_reg_wben = (set_bit_wpos<<32) | set_bit_wpos;   //set unread and occupied bitmasks;
                    rin_reg_addr = r_recvep_baseaddr + 'h10;
                    rin_reg_wdata = (set_bit_wpos<<32) | set_bit_wpos;
                    next_ctrl_rm_state = S_CTRL_RM_UPDATE_EP4;
                end
            end

            S_CTRL_RM_UPDATE_EP4: begin
                //wait until reg is free, then continue
                if (!rm_reg_stall_i) begin
                    next_ctrl_rm_state = S_CTRL_RM_CREATE_REPLYEP1;
                end
            end


            //---------------
            //create reply ep
            S_CTRL_RM_CREATE_REPLYEP1: begin
                //if this message is not a reply, create send ep for reply
                if (((hd_flags & TCU_HD_FLAG_REPLY) == {TCU_HD_FLAG_SIZE{1'b0}}) &&
                    (rep_rpleps != {TCU_EP_SIZE{1'b1}}) &&
                    (hd_recvep != {TCU_EP_SIZE{1'b1}})) begin
                    rin_reg_wben = {(1+TCU_EP_SIZE+TCU_SLOT_SIZE+2*TCU_CRD_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE){1'b1}};
                    rin_reg_addr = rplep_addr;
                    rin_reg_wdata = {1'b1,
                                     hd_sendep,
                                     reply_msg_sz,
                                     {{(TCU_CRD_SIZE-1){1'b0}}, 1'b1},
                                     {{(TCU_CRD_SIZE-1){1'b0}}, 1'b1},
                                     rep_vpeid,
                                     TCU_EP_TYPE_SEND};
                    next_ctrl_rm_state = S_CTRL_RM_CREATE_REPLYEP2;
                end else begin
                    next_ctrl_rm_state = S_CTRL_RM_READ_SEP1;
                end
            end

            S_CTRL_RM_CREATE_REPLYEP2: begin
                if (!rm_reg_stall_i) begin
                    rin_reg_wben = {(TCU_CHIPID_SIZE+TCU_PEID_SIZE+TCU_EP_SIZE){1'b1}};
                    rin_reg_addr = r_reg_addr + 'd8;
                    rin_reg_wdata = {hd_sendchip, hd_sendpe, hd_recvep};
                    next_ctrl_rm_state = S_CTRL_RM_CREATE_REPLYEP3;
                end
            end

            S_CTRL_RM_CREATE_REPLYEP3: begin
                if (!rm_reg_stall_i) begin
                    rin_reg_wben = {32{1'b1}};
                    rin_reg_addr = r_reg_addr + 'd8;
                    rin_reg_wdata = hd_replylabel;
                    next_ctrl_rm_state = S_CTRL_RM_CREATE_REPLYEP4;
                end
            end

            S_CTRL_RM_CREATE_REPLYEP4: begin
                if (!rm_reg_stall_i) begin
                    if (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) begin
                        next_ctrl_rm_state = S_CTRL_RM_CHECK_VPE;
                    end
                    else if (TCU_ENABLE_DRAM) begin
                        next_ctrl_rm_state = S_CTRL_RM_WAIT_DRAM;
                    end else begin
                        next_ctrl_rm_state = S_CTRL_RM_FINISH;
                    end
                end
            end

            //---------------
            //update send ep to give credits back
            S_CTRL_RM_READ_SEP1: begin
                if (!rm_reg_stall_i) begin
                    //if this message is a reply and reply ep exists, increment credits of original send ep
                    if (((hd_flags & TCU_HD_FLAG_REPLY) != {TCU_HD_FLAG_SIZE{1'b0}}) && (hd_recvep != {TCU_EP_SIZE{1'b1}})) begin
                        rin_reg_addr = hdrecvep_addr;
                        next_ctrl_rm_state = S_CTRL_RM_READ_SEP2;
                    end
                    else if (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) begin
                        next_ctrl_rm_state = S_CTRL_RM_CHECK_VPE;
                    end
                    else if (TCU_ENABLE_DRAM) begin
                        next_ctrl_rm_state = S_CTRL_RM_WAIT_DRAM;
                    end
                    else begin
                        next_ctrl_rm_state = S_CTRL_RM_FINISH;
                    end
                end
            end

            S_CTRL_RM_READ_SEP2: begin
                //wait for reg read data
                if (!rm_reg_stall_i) begin
                    next_ctrl_rm_state = S_CTRL_RM_READ_SEP3;
                end
            end

            S_CTRL_RM_READ_SEP3: begin
                rin_sep_0 = rm_reg_rdata_i;
                next_ctrl_rm_state = S_CTRL_RM_UPDATE_SEP1;
            end

            S_CTRL_RM_UPDATE_SEP1: begin
                rin_reg_wben = {{(TCU_REG_DATA_SIZE-TCU_CRD_SIZE){1'b0}}, {TCU_CRD_SIZE{1'b1}}} << (TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE);
                rin_reg_addr = hdrecvep_addr;
                rin_reg_wdata = sep_curcrd_incr << (TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE);
                next_ctrl_rm_state = S_CTRL_RM_UPDATE_SEP2;
            end

            S_CTRL_RM_UPDATE_SEP2: begin
                if (!rm_reg_stall_i) begin
                    if (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) begin
                        next_ctrl_rm_state = S_CTRL_RM_CHECK_VPE;
                    end
                    else if (TCU_ENABLE_DRAM) begin
                        next_ctrl_rm_state = S_CTRL_RM_WAIT_DRAM;
                    end
                    else begin
                        next_ctrl_rm_state = S_CTRL_RM_FINISH;
                    end
                end
            end

            //---------------
            //check VPE
            S_CTRL_RM_CHECK_VPE: begin
                if (TCU_ENABLE_VIRT_PES) begin
                    if (rep_vpeid == rm_cur_vpe_i[TCU_VPEID_SIZE-1:0]) begin
                        //VPE is active which belongs to this msg, incr number of msgs
                        rin_reg_wben = {{(TCU_REG_DATA_SIZE-TCU_VPE_MSGS_SIZE){1'b0}}, {TCU_VPE_MSGS_SIZE{1'b1}}} << TCU_VPEID_SIZE; //only write to msgs field
                        rin_reg_addr = TCU_REGADDR_CUR_VPE;
                        rin_reg_wdata = cur_vpe_msgs_incr << TCU_VPEID_SIZE;
                        next_ctrl_rm_state = S_CTRL_RM_UPDATE_VPE;
                    end

                    //currently wrong VPE running, inject core request
                    else begin
                        rm_core_req_push_o = 1'b1;
                        rm_core_req_data_o = {rep_vpeid, r_recvep};

                        if (!rm_core_req_stall_i) begin
                            if (TCU_ENABLE_DRAM) begin
                                next_ctrl_rm_state = S_CTRL_RM_WAIT_DRAM;
                            end else begin
                                next_ctrl_rm_state = S_CTRL_RM_FINISH;
                            end
                        end
                    end
                end
            end

            S_CTRL_RM_UPDATE_VPE: begin
                if (TCU_ENABLE_VIRT_PES) begin
                    if (!rm_reg_stall_i) begin
                        if (TCU_ENABLE_DRAM) begin
                            next_ctrl_rm_state = S_CTRL_RM_WAIT_DRAM;
                        end else begin
                            next_ctrl_rm_state = S_CTRL_RM_FINISH;
                        end
                    end
                end
            end


            //---------------
            S_CTRL_RM_WAIT_DRAM: begin
                if (!rm_mem_wdata_infifo_i) begin
                    next_ctrl_rm_state = S_CTRL_RM_FINISH;
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rm_mem_wabort_o = 1'b1;
                        rin_rm_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_rm_state = S_CTRL_RM_ERROR;
                    end
                end
            end

            //---------------
            //end up here when error occured before message could be stored
            //read second part of header before dropping NoC flits
            S_CTRL_RM_DROP_MSG: begin
                if (noc_wrreq_i) begin
                    //take second part of header
                    rin_hd_2 = rm_header_i[63:0];
                    noc_fifo_pop_o = 1'b1;

                    //if there is a payload, drop it as well
                    if (hd_length != {TCU_MSGLEN_SIZE{1'b0}}) begin
                        next_ctrl_rm_state = S_CTRL_RM_DROP_MSG_PL;
                    end else begin
                        next_ctrl_rm_state = S_CTRL_RM_FINISH;
                    end
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rin_rm_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_rm_state = S_CTRL_RM_ERROR;
                    end
                end
            end

            S_CTRL_RM_DROP_MSG_PL: begin
                if (noc_wrreq_i) begin
                    noc_fifo_pop_o = 1'b1;

                    //payload ends when NoC burst ends
                    if (!noc_burst_i) begin
                        next_ctrl_rm_state = S_CTRL_RM_FINISH;
                    end
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rin_rm_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_rm_state = S_CTRL_RM_ERROR;
                    end
                end
            end

            //---------------
            //end up here when timeout occured
            S_CTRL_RM_ERROR: begin
                if (!noc_stall_i && !rm_mem_stall_i) begin
                    rm_done_o = 1'b1;
                    next_ctrl_rm_state = S_CTRL_RM_IDLE;
                end
            end

            //---------------
            S_CTRL_RM_FINISH: begin
                if (!noc_stall_i && !rm_mem_stall_i) begin
                    rm_done_o = 1'b1;
                    next_ctrl_rm_state = S_CTRL_RM_IDLE;
                end

                //timeout
                else if (rm_mem_stall_i && (TIMEOUT_RECV_CYCLES != 32'h0)) begin
                    rin_rm_timeout = r_rm_timeout + 32'd1;
                    if (r_rm_timeout > TIMEOUT_RECV_CYCLES) begin
                        rm_mem_wabort_o = 1'b1;
                        rin_rm_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_rm_state = S_CTRL_RM_ERROR;
                    end
                end
            end

            default: next_ctrl_rm_state = S_CTRL_RM_IDLE;

        endcase //case (ctrl_rm_state)
    end





    //---------------
    //reg interface
    always @* begin
        rm_reg_en_o = 1'b0;
        rm_reg_wben_o = {TCU_REG_DATA_SIZE{1'b0}};

        if (!rm_reg_stall_i) begin
            if ((ctrl_rm_state == S_CTRL_RM_READ_EP1) ||
                (ctrl_rm_state == S_CTRL_RM_READ_EP2) ||
                (ctrl_rm_state == S_CTRL_RM_READ_EP3) ||
                (ctrl_rm_state == S_CTRL_RM_READ_SEP2)) begin
                rm_reg_en_o = 1'b1;
            end
            else if ((ctrl_rm_state == S_CTRL_RM_UPDATE_EP3) ||
                     (ctrl_rm_state == S_CTRL_RM_UPDATE_EP4) ||
                     (ctrl_rm_state == S_CTRL_RM_CREATE_REPLYEP2) ||
                     (ctrl_rm_state == S_CTRL_RM_CREATE_REPLYEP3) ||
                     (ctrl_rm_state == S_CTRL_RM_CREATE_REPLYEP4) ||
                     (ctrl_rm_state == S_CTRL_RM_UPDATE_SEP2)) begin
                rm_reg_en_o = 1'b1;
                rm_reg_wben_o = r_reg_wben;
            end
            else if (TCU_ENABLE_VIRT_PES && (ctrl_rm_state == S_CTRL_RM_UPDATE_VPE)) begin
                rm_reg_en_o = 1'b1;
                rm_reg_wben_o = r_reg_wben;
            end
        end
    end



    //---------------
    //memory interface
    always @* begin
        //bit 0: write aligned to 16 byte
        //bit 1: write aligned to any other byte
        //bit 2: write request if mem behaves like DRAM
        rin_mem_en = 3'b000;
        rin_mem_wben = r_mem_wben;

        if (!rm_mem_stall_i) begin

            //prepare mem
            if (ctrl_rm_state == S_CTRL_RM_WRITE_PREPARE_MEM2) begin
                rin_mem_en = 3'b100;
                rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}};
            end

            //write first part of msg header
            else if (noc_wrreq_i && (ctrl_rm_state == S_CTRL_RM_WRITE_MEM_HD1)) begin
                rin_mem_en = 3'b001;
                rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}} << r_laddr[3:0];
            end

            //write second part of msg header or msg payload
            else if (noc_wrreq_i && !rm_mem_wabort_o &&
                    ((ctrl_rm_state == S_CTRL_RM_WRITE_MEM_HD2) || (ctrl_rm_state == S_CTRL_RM_WRITE_MEM_PL1))) begin
                if (r_laddr[3:0] == 4'h0) begin
                    rin_mem_en = 3'b001;
                end else begin
                    rin_mem_en = 3'b010;
                end

                if (noc_burst_i) begin
                    rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}};
                end
                else if (r_size >= 'd16) begin
                    rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}};
                end
                else begin
                    rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}} >> (5'd16 - r_size[3:0]);
                end
            end

            //end of burst
            else if (ctrl_rm_state == S_CTRL_RM_WRITE_MEM_PL2) begin
                rin_mem_en = 3'b010;
                rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}} >> (5'd16 - r_size[3:0]);
            end
        end
    end

    assign rm_reg_addr_o = r_reg_addr;
    assign rm_reg_wdata_o = r_reg_wdata;

    assign rm_active_o = (ctrl_rm_state != S_CTRL_RM_IDLE);
    assign rm_cur_vpe_active_o = (ctrl_rm_state == S_CTRL_RM_CHECK_VPE) || (ctrl_rm_state == S_CTRL_RM_UPDATE_VPE); //indicate update of CUR_VPE
    assign rm_crd_update_active_o = (ctrl_rm_state == S_CTRL_RM_READ_SEP1) ||
                                    (ctrl_rm_state == S_CTRL_RM_READ_SEP2) ||
                                    (ctrl_rm_state == S_CTRL_RM_READ_SEP3) ||
                                    (ctrl_rm_state == S_CTRL_RM_UPDATE_SEP1) ||
                                    (ctrl_rm_state == S_CTRL_RM_UPDATE_SEP2);   //indicate update of credits in SEP


    assign rm_mem_en_o = r_mem_en;
    assign rm_mem_wben_o = r_mem_wben;
    assign rm_mem_addr_o = r_mem_addr;
    assign rm_mem_wdata_o = r_size;

    //for MSG ACK
    assign noc_wrreq_o = rm_done_o;
    assign noc_chipid_o = hd_sendchip;
    assign noc_modid_o = hd_sendpe;
    assign noc_addr_o = hd_label;
    assign noc_data_o = r_rm_error;

    generate
    assign tcu_log_rm_o = TCU_ENABLE_LOG ?
                            (rm_done_o ? {set_bit_wpos, rep_unread, rep_occupied, TCU_LOG_RECV_FINISH} : TCU_LOG_NONE) :
                            TCU_LOG_NONE;
    endgenerate


endmodule
