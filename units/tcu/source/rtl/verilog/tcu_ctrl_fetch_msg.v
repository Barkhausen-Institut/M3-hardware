
module tcu_ctrl_fetch_msg #(
    `include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_VIRT_PES = 0
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //reg IF (only write)
    output reg                           fm_reg_en_o,
    output reg   [TCU_REG_DATA_SIZE-1:0] fm_reg_wben_o,
    output wire  [TCU_REG_ADDR_SIZE-1:0] fm_reg_addr_o,
    output wire  [TCU_REG_DATA_SIZE-1:0] fm_reg_wdata_o,
    input  wire                          fm_reg_stall_i,

    //---------------
    //triggers from tcu_ctrl
    input  wire                          fm_start_i,
    input  wire    [TCU_OPCODE_SIZE-1:0] fm_opcode_i,
    input  wire        [TCU_EP_SIZE-1:0] fm_recvep_i,
    input  wire               [3*64-1:0] fm_epdata_i,
    input  wire                   [31:0] fm_cur_vpe_i,
    output wire                          fm_active_o,
    output wire                   [31:0] fm_msgoffset_o,
    output wire                          fm_fetch_success_o,
    output wire                          fm_done_o,
    output wire     [TCU_ERROR_SIZE-1:0] fm_error_o,

    //---------------
    //TCU feature settings
    input  wire                          tcu_features_virt_pes_i
);


    localparam CTRL_FM_STATES_SIZE  = 3;
    localparam S_CTRL_FM_IDLE       = 3'h0;
    localparam S_CTRL_FM_FIND_SLOT  = 3'h1;
    localparam S_CTRL_FM_UPDATE_EP1 = 3'h2;
    localparam S_CTRL_FM_UPDATE_EP2 = 3'h3;
    localparam S_CTRL_FM_UPDATE_VPE = 3'h4;
    localparam S_CTRL_FM_SET_ARG1   = 3'h5;
    localparam S_CTRL_FM_FINISH     = 3'h7;

    reg [CTRL_FM_STATES_SIZE-1:0] ctrl_fm_state, next_ctrl_fm_state;



    //temp ep regs
    reg [63:0] r_rep_0, rin_rep_0;
    reg [63:0] r_rep_2, rin_rep_2;

    reg [TCU_REG_DATA_SIZE-1:0] r_reg_wben, rin_reg_wben;
    reg [TCU_REG_ADDR_SIZE-1:0] r_reg_addr, rin_reg_addr;
    reg [TCU_REG_DATA_SIZE-1:0] r_reg_wdata, rin_reg_wdata;


    //addr of recveive ep
    reg [31:0] r_recvep_baseaddr, rin_recvep_baseaddr;

    //current read index
    reg [TCU_SLOT_SIZE-1:0] r_tmp_rpos, rin_tmp_rpos;

    //indicate if there really was a message (only used for TCU logging)
    reg r_fetch_success, rin_fetch_success;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_fm_error, rin_fm_error;


    //ep info
    wire [TCU_EP_TYPE_SIZE-1:0] rep_type_s     = fm_epdata_i[TCU_EP_TYPE_SIZE-1 : 0];
    wire   [TCU_VPEID_SIZE-1:0] rep_vpeid_s    = fm_epdata_i[TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] rep_rpleps_s   = fm_epdata_i[TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slots_s    = fm_epdata_i[TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slotsize_s = fm_epdata_i[2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_wpos_s     = fm_epdata_i[3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_rpos_s     = fm_epdata_i[4*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire                 [31:0] rep_occupied_s = fm_epdata_i[2*64+32-1 : 2*64];
    wire                 [31:0] rep_unread_s   = fm_epdata_i[3*64-1 : 2*64+32];

    //ep info (from reg)
    wire [TCU_EP_TYPE_SIZE-1:0] rep_type     = r_rep_0[TCU_EP_TYPE_SIZE-1 : 0];
    wire   [TCU_VPEID_SIZE-1:0] rep_vpeid    = r_rep_0[TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] rep_rpleps   = r_rep_0[TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slots    = r_rep_0[TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slotsize = r_rep_0[2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_wpos     = r_rep_0[3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_rpos     = r_rep_0[4*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire                 [31:0] rep_occupied = r_rep_2[31:0];
    wire                 [31:0] rep_unread   = r_rep_2[63:32];

    wire [31:0] recvep_addr = TCU_REGADDR_EP_START + fm_recvep_i*TCU_EP_REG_SIZE;

    wire     [TCU_SLOT_SIZE-1:0] tmp_pos_incr = r_tmp_rpos + 1'b1;
    wire [TCU_REG_DATA_SIZE-1:0] set_bit_rpos = 32'h1 << r_tmp_rpos;

    //max. number of slots is 32
    wire [TCU_SLOT_SIZE-1:0] max_slot = (rep_slots > 'h5) ? 'd32 : {{(TCU_SLOT_SIZE-1){1'b0}}, 1'b1} << rep_slots[2:0];

    //updated msgs count
    wire [TCU_REG_DATA_SIZE-1:0] cur_vpe_msgs_decr = fm_cur_vpe_i[TCU_VPE_MSGS_SIZE+TCU_VPEID_SIZE-1:TCU_VPEID_SIZE] - 'd1;

    //msg offset is result of FETCH command
    wire [31:0] msgoffset = r_tmp_rpos << rep_slotsize;


    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_fm_state <= S_CTRL_FM_IDLE;

            r_reg_wben <= {TCU_REG_DATA_SIZE{1'b0}};
            r_reg_addr <= {TCU_REG_ADDR_SIZE{1'b0}};
            r_reg_wdata <= {TCU_REG_DATA_SIZE{1'b0}};

            r_recvep_baseaddr <= 32'h0;

            r_rep_0 <= 64'h0;
            r_rep_2 <= 64'h0;

            r_tmp_rpos <= {TCU_SLOT_SIZE{1'b0}};

            r_fetch_success <= 1'b0;

            r_fm_error <= TCU_ERROR_NONE;
        end
        else begin
            ctrl_fm_state <= next_ctrl_fm_state;

            r_reg_wben <= rin_reg_wben;
            r_reg_addr <= rin_reg_addr;
            r_reg_wdata <= rin_reg_wdata;

            r_recvep_baseaddr <= rin_recvep_baseaddr;

            r_rep_0 <= rin_rep_0;
            r_rep_2 <= rin_rep_2;

            r_tmp_rpos <= rin_tmp_rpos;

            r_fetch_success <= rin_fetch_success;

            r_fm_error <= rin_fm_error;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_fm_state = ctrl_fm_state;

        rin_recvep_baseaddr = r_recvep_baseaddr;

        rin_reg_wben = r_reg_wben;
        rin_reg_addr = r_reg_addr;
        rin_reg_wdata = r_reg_wdata;

        rin_rep_0 = r_rep_0;
        rin_rep_2 = r_rep_2;

        rin_tmp_rpos = r_tmp_rpos;

        rin_fetch_success = r_fetch_success;

        rin_fm_error = r_fm_error;


        case (ctrl_fm_state)

            //---------------
            //wait for incoming command
            S_CTRL_FM_IDLE: begin
                rin_fetch_success = 1'b0;

                if (fm_start_i && (fm_opcode_i == TCU_OPCODE_FETCH)) begin
                    
                    //interpret ep content as recv ep
                    if (rep_type_s == TCU_EP_TYPE_RECEIVE) begin

                        //check VPE
                        if (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (fm_cur_vpe_i[TCU_VPEID_SIZE-1:0] == rep_vpeid_s)) begin

                            //check if unread messages are available
                            if ((rep_unread_s == 32'h0) ||
                                (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i
                                    && (fm_cur_vpe_i[TCU_VPE_MSGS_SIZE+TCU_VPEID_SIZE-1:TCU_VPEID_SIZE] == {TCU_VPE_MSGS_SIZE{1'b0}}))) begin
                                //if there is no message, set arg1 reg to -1
                                rin_reg_addr = TCU_REGADDR_ARG1;
                                rin_reg_wdata = {TCU_REG_DATA_SIZE{1'b1}};

                                next_ctrl_fm_state = S_CTRL_FM_SET_ARG1;
                            end
                            else begin
                                rin_rep_0 = fm_epdata_i[63:0];
                                rin_rep_2 = fm_epdata_i[3*64-1:2*64];

                                rin_tmp_rpos = rep_rpos_s;

                                //take incoming recv ep
                                rin_recvep_baseaddr = recvep_addr;
                                rin_reg_addr = recvep_addr;

                                next_ctrl_fm_state = S_CTRL_FM_FIND_SLOT;
                            end

                            rin_fm_error = TCU_ERROR_NONE;
                        end
                        else begin
                            rin_fm_error = TCU_ERROR_FOREIGN_EP;
                            next_ctrl_fm_state = S_CTRL_FM_FINISH;
                        end
                    end
                    else begin
                        rin_fm_error = TCU_ERROR_NO_REP;
                        next_ctrl_fm_state = S_CTRL_FM_FINISH;
                    end
                end
            end


            //---------------
            //find a slot where read data is available
            S_CTRL_FM_FIND_SLOT: begin
                //find unread slot starting at rpos
                if (r_tmp_rpos < max_slot) begin
                    if (rep_unread[r_tmp_rpos]) begin
                        rin_reg_wben = {{{TCU_REG_DATA_SIZE-TCU_SLOT_SIZE}{1'b0}}, {TCU_SLOT_SIZE{1'b1}}} << (3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE);
                        rin_reg_wdata = {{(TCU_REG_DATA_SIZE-TCU_SLOT_SIZE){1'b0}}, tmp_pos_incr} << (3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE);  //increment rpos
                        rin_fetch_success = 1'b1;
                        next_ctrl_fm_state = S_CTRL_FM_UPDATE_EP1;
                    end

                    //check if we are wrapped around
                    else if (tmp_pos_incr != rep_rpos) begin
                        rin_tmp_rpos = tmp_pos_incr;
                        next_ctrl_fm_state = S_CTRL_FM_FIND_SLOT;
                    end
                    else begin
                        //cannot happen (ep data would be invalid)
                        rin_reg_addr = TCU_REGADDR_ARG1;
                        rin_reg_wdata = {TCU_REG_DATA_SIZE{1'b1}};

                        rin_fm_error = TCU_ERROR_CRITICAL;
                        next_ctrl_fm_state = S_CTRL_FM_SET_ARG1;
                    end
                end
                else begin
                    //at the end of valid slots, start at the beginning
                    rin_tmp_rpos = 'h0;
                    next_ctrl_fm_state = S_CTRL_FM_FIND_SLOT;
                end
            end

            //---------------
            //update ep: set idx, incr rpos
            S_CTRL_FM_UPDATE_EP1: begin
                if (!fm_reg_stall_i) begin
                    rin_reg_wben = set_bit_rpos << 32;  //unread mask is in upper 32 bit
                    rin_reg_addr = r_recvep_baseaddr + 'h10;
                    rin_reg_wdata = {TCU_REG_DATA_SIZE{1'b0}};
                    next_ctrl_fm_state = S_CTRL_FM_UPDATE_EP2;
                end
            end

            S_CTRL_FM_UPDATE_EP2: begin
                //wait until reg is free, then continue
                if (!fm_reg_stall_i) begin
                    if (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) begin
                        rin_reg_wben = {{(TCU_REG_DATA_SIZE-TCU_VPE_MSGS_SIZE){1'b0}}, {TCU_VPE_MSGS_SIZE{1'b1}}} << TCU_VPEID_SIZE; //only write to msgs field
                        rin_reg_addr = TCU_REGADDR_CUR_VPE;
                        rin_reg_wdata = cur_vpe_msgs_decr << TCU_VPEID_SIZE;
                        next_ctrl_fm_state = S_CTRL_FM_UPDATE_VPE;
                    end
                    else begin
                        //write offset of message to arg1 reg
                        rin_reg_addr = TCU_REGADDR_ARG1;
                        rin_reg_wdata = msgoffset;
                        next_ctrl_fm_state = S_CTRL_FM_SET_ARG1;
                    end
                end
            end


            //---------------
            //decr number of msgs in CUR_VPE reg
            S_CTRL_FM_UPDATE_VPE: begin
                if (TCU_ENABLE_VIRT_PES) begin
                    if (!fm_reg_stall_i) begin
                        //write offset of message to arg1 reg
                        rin_reg_addr = TCU_REGADDR_ARG1;
                        rin_reg_wdata = msgoffset;
                        next_ctrl_fm_state = S_CTRL_FM_SET_ARG1;
                    end
                end
            end


            //---------------
            //update arg1 reg
            S_CTRL_FM_SET_ARG1: begin
                if (!fm_reg_stall_i) begin
                    next_ctrl_fm_state = S_CTRL_FM_FINISH;
                end
            end


            //---------------
            S_CTRL_FM_FINISH: begin
                next_ctrl_fm_state = S_CTRL_FM_IDLE;
            end

            default: next_ctrl_fm_state = S_CTRL_FM_IDLE;

        endcase //case (ctrl_fm_state)
    end





    //---------------
    //reg interface
    always @* begin
        fm_reg_en_o = 1'b0;
        fm_reg_wben_o = {TCU_REG_DATA_SIZE{1'b0}};

        if ((ctrl_fm_state == S_CTRL_FM_UPDATE_EP1) ||
            (ctrl_fm_state == S_CTRL_FM_UPDATE_EP2)) begin
            fm_reg_en_o = 1'b1;
            fm_reg_wben_o = r_reg_wben;
        end
        else if (ctrl_fm_state == S_CTRL_FM_SET_ARG1) begin
            fm_reg_en_o = 1'b1;
            fm_reg_wben_o = {TCU_REG_DATA_SIZE{1'b1}};
        end
        else if (TCU_ENABLE_VIRT_PES && (ctrl_fm_state == S_CTRL_FM_UPDATE_VPE)) begin
            fm_reg_en_o = 1'b1;
            fm_reg_wben_o = r_reg_wben;
        end
    end

    assign fm_reg_addr_o = r_reg_addr;
    assign fm_reg_wdata_o = r_reg_wdata;

    assign fm_active_o = (ctrl_fm_state != S_CTRL_FM_IDLE);
    assign fm_fetch_success_o = r_fetch_success;
    assign fm_msgoffset_o = msgoffset;
    assign fm_done_o = (ctrl_fm_state == S_CTRL_FM_FINISH);
    assign fm_error_o = r_fm_error;


endmodule
