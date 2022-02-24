
module tcu_ctrl_ack_msg #(
    `include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_VIRT_PES = 0
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //reg IF
    output reg                           am_reg_en_o,
    output reg   [TCU_REG_DATA_SIZE-1:0] am_reg_wben_o,
    output wire  [TCU_REG_ADDR_SIZE-1:0] am_reg_addr_o,
    output wire  [TCU_REG_DATA_SIZE-1:0] am_reg_wdata_o,
    input  wire  [TCU_REG_DATA_SIZE-1:0] am_reg_rdata_i,
    input  wire                          am_reg_stall_i,

    //---------------
    //triggers from tcu_ctrl
    input  wire                          am_start_i,
    input  wire    [TCU_OPCODE_SIZE-1:0] am_opcode_i,
    input  wire                   [31:0] am_rmsgoffset_i,
    input  wire        [TCU_EP_SIZE-1:0] am_recvep_i,
    input  wire               [3*64-1:0] am_epdata_i,
    input  wire                   [31:0] am_cur_vpe_i,
    output wire                          am_active_o,
    output wire                          am_done_o,
    output wire     [TCU_ERROR_SIZE-1:0] am_error_o,

    //---------------
    //TCU feature settings
    input  wire                          tcu_features_virt_pes_i
);

    localparam CTRL_AM_STATES_SIZE   = 3;
    localparam S_CTRL_AM_IDLE        = 3'h0;
    localparam S_CTRL_AM_UPDATE_EP1  = 3'h1;
    localparam S_CTRL_AM_UPDATE_EP2  = 3'h2;
    localparam S_CTRL_AM_READ_SEP    = 3'h3;
    localparam S_CTRL_AM_UPDATE_SEP  = 3'h4;
    localparam S_CTRL_AM_UPDATE_VPE1 = 3'h5;
    localparam S_CTRL_AM_UPDATE_VPE2 = 3'h6;
    localparam S_CTRL_AM_FINISH      = 3'h7;

    reg [CTRL_AM_STATES_SIZE-1:0] ctrl_am_state, next_ctrl_am_state;

    //current index
    reg [TCU_SLOT_SIZE-1:0] r_tmp_pos, rin_tmp_pos;

    //temp ep regs
    reg [63:0] r_rep_0, rin_rep_0;
    reg [63:0] r_rep_2, rin_rep_2;

    reg [TCU_REG_DATA_SIZE-1:0] r_reg_wben, rin_reg_wben;
    reg [TCU_REG_ADDR_SIZE-1:0] r_reg_addr, rin_reg_addr;
    reg [TCU_REG_DATA_SIZE-1:0] r_reg_wdata, rin_reg_wdata;

    //addr of recveive ep
    reg [31:0] r_recvep_baseaddr, rin_recvep_baseaddr;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_am_error, rin_am_error;


    //ep info
    wire [TCU_EP_TYPE_SIZE-1:0] rep_type_s     = am_epdata_i[TCU_EP_TYPE_SIZE-1 : 0];
    wire   [TCU_VPEID_SIZE-1:0] rep_vpeid_s    = am_epdata_i[TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_TYPE_SIZE];
    wire      [TCU_EP_SIZE-1:0] rep_rpleps_s   = am_epdata_i[TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slots_s    = am_epdata_i[TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_slotsize_s = am_epdata_i[2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_wpos_s     = am_epdata_i[3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 2*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_SLOT_SIZE-1:0] rep_rpos_s     = am_epdata_i[4*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : 3*TCU_SLOT_SIZE+TCU_EP_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire                 [31:0] rep_occupied_s = am_epdata_i[2*64+32-1 : 2*64];
    wire                 [31:0] rep_unread_s   = am_epdata_i[3*64-1 : 2*64+32];

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

    //calc index (offset/slot_size)
    wire     [TCU_SLOT_SIZE-1:0] tmp_pos = am_rmsgoffset_i >> rep_slotsize_s;
    wire [TCU_REG_DATA_SIZE-1:0] set_bit_pos = 32'h1 << r_tmp_pos;

    wire [31:0] recvep_addr = TCU_REGADDR_EP_START + am_recvep_i*TCU_EP_REG_SIZE;

    //updated msgs count
    wire [TCU_REG_DATA_SIZE-1:0] cur_vpe_msgs_decr = am_cur_vpe_i[TCU_VPE_MSGS_SIZE+TCU_VPEID_SIZE-1:TCU_VPEID_SIZE] - 'd1;


    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_am_state <= S_CTRL_AM_IDLE;

            r_reg_wben <= {TCU_REG_DATA_SIZE{1'b0}};
            r_reg_addr <= {TCU_REG_ADDR_SIZE{1'b0}};
            r_reg_wdata <= {TCU_REG_DATA_SIZE{1'b0}};

            r_tmp_pos <= {TCU_SLOT_SIZE{1'b0}};

            r_rep_0 <= 64'h0;
            r_rep_2 <= 64'h0;

            r_recvep_baseaddr <= 32'h0;

            r_am_error <= TCU_ERROR_NONE;
        end
        else begin
            ctrl_am_state <= next_ctrl_am_state;

            r_reg_wben <= rin_reg_wben;
            r_reg_addr  <= rin_reg_addr;
            r_reg_wdata <= rin_reg_wdata;

            r_tmp_pos <= rin_tmp_pos;

            r_rep_0 <= rin_rep_0;
            r_rep_2 <= rin_rep_2;

            r_recvep_baseaddr <= rin_recvep_baseaddr;

            r_am_error <= rin_am_error;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_am_state = ctrl_am_state;

        rin_tmp_pos = r_tmp_pos;
        
        rin_rep_0 = r_rep_0;
        rin_rep_2 = r_rep_2;

        rin_recvep_baseaddr = r_recvep_baseaddr;

        rin_reg_wben = r_reg_wben;
        rin_reg_addr = r_reg_addr;
        rin_reg_wdata = r_reg_wdata;

        rin_am_error = r_am_error;


        case (ctrl_am_state)

            //---------------
            //wait for incoming command
            S_CTRL_AM_IDLE: begin
                if (am_start_i && (am_opcode_i == TCU_OPCODE_ACK_MSG)) begin

                    //interpret ep content as recv ep
                    if (rep_type_s == TCU_EP_TYPE_RECEIVE) begin

                        //check EP number
                        if ((rep_rpleps_s == {TCU_EP_SIZE{1'b1}}) || (rep_rpleps_s+(32'h1 << rep_slots_s) <= TCU_EP_REG_COUNT)) begin

                            //check VPE
                            if (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (am_cur_vpe_i[TCU_VPEID_SIZE-1:0] == rep_vpeid_s)) begin

                                //check if offset < number of slots
                                if (tmp_pos < ({{(TCU_SLOT_SIZE-1){1'b0}}, 1'b1} << rep_slots_s)) begin
                                    rin_tmp_pos = tmp_pos;

                                    rin_rep_0 = am_epdata_i[63:0];
                                    rin_rep_2 = am_epdata_i[3*64-1:2*64];

                                    //take incoming recv ep
                                    rin_recvep_baseaddr = recvep_addr;

                                    rin_am_error = TCU_ERROR_NONE;

                                    if (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) begin
                                        next_ctrl_am_state = S_CTRL_AM_UPDATE_VPE1;
                                    end else begin
                                        next_ctrl_am_state = S_CTRL_AM_UPDATE_EP1;
                                    end
                                end
                                else begin
                                    rin_am_error = TCU_ERROR_INV_MSG_OFF;
                                    next_ctrl_am_state = S_CTRL_AM_FINISH;
                                end
                            end
                            else begin
                                rin_am_error = TCU_ERROR_FOREIGN_EP;
                                next_ctrl_am_state = S_CTRL_AM_FINISH;
                            end
                        end
                        else begin
                            rin_am_error = TCU_ERROR_RECV_INV_RPL_EPS;
                            next_ctrl_am_state = S_CTRL_AM_FINISH;
                        end
                    end
                    else begin
                        rin_am_error = TCU_ERROR_NO_REP;
                        next_ctrl_am_state = S_CTRL_AM_FINISH;
                    end
                end
            end

            //---------------
            //decr number of msgs in CUR_VPE reg
            S_CTRL_AM_UPDATE_VPE1: begin
                if (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) begin
                    if (rep_unread[r_tmp_pos]) begin
                        //wait until reg is free to read CUR_VPE reg
                        rin_reg_wben = {{(TCU_REG_DATA_SIZE-TCU_VPE_MSGS_SIZE){1'b0}}, {TCU_VPE_MSGS_SIZE{1'b1}}} << TCU_VPEID_SIZE; //only write to msgs field
                        rin_reg_addr = TCU_REGADDR_CUR_VPE;
                        rin_reg_wdata = cur_vpe_msgs_decr << TCU_VPEID_SIZE;

                        next_ctrl_am_state = S_CTRL_AM_UPDATE_VPE2;
                    end
                    else begin
                        next_ctrl_am_state = S_CTRL_AM_UPDATE_EP1;
                    end
                end
            end

            S_CTRL_AM_UPDATE_VPE2: begin
                if (TCU_ENABLE_VIRT_PES) begin
                    if (!am_reg_stall_i) begin
                        next_ctrl_am_state = S_CTRL_AM_UPDATE_EP1;
                    end
                end
            end

            //---------------
            //write updated ep: clear bits in masks
            S_CTRL_AM_UPDATE_EP1: begin
                rin_reg_wben = (set_bit_pos<<32) | set_bit_pos;
                rin_reg_addr = r_recvep_baseaddr + 'h10;
                rin_reg_wdata = {TCU_REG_DATA_SIZE{1'b0}};

                next_ctrl_am_state = S_CTRL_AM_UPDATE_EP2;
            end

            S_CTRL_AM_UPDATE_EP2: begin
                if (!am_reg_stall_i) begin
                    //invalidate reply ep if it exists
                    if (rep_rpleps != {TCU_EP_SIZE{1'b1}}) begin
                        rin_reg_wben = {TCU_EP_TYPE_SIZE{1'b1}};
                        rin_reg_addr = TCU_REGADDR_EP_START + (rep_rpleps+r_tmp_pos)*TCU_EP_REG_SIZE;
                        rin_reg_wdata = TCU_EP_TYPE_INVALID;

                        next_ctrl_am_state = S_CTRL_AM_UPDATE_SEP;
                    end
                    else begin
                        next_ctrl_am_state = S_CTRL_AM_FINISH;
                    end
                end
            end

            //---------------
            //invalidate reply ep
            S_CTRL_AM_UPDATE_SEP: begin
                //wait until reg is free, then continue
                if (!am_reg_stall_i) begin
                    next_ctrl_am_state = S_CTRL_AM_FINISH;
                end
            end

            //---------------
            S_CTRL_AM_FINISH: begin
                next_ctrl_am_state = S_CTRL_AM_IDLE;
            end

            //default: next_ctrl_am_state = S_CTRL_AM_IDLE;

        endcase //case (ctrl_am_state)
    end





    //---------------
    //reg interface
    always @* begin
        am_reg_en_o = 1'b0;
        am_reg_wben_o = {TCU_REG_DATA_SIZE{1'b0}};

        if ((ctrl_am_state == S_CTRL_AM_UPDATE_EP2) ||
            (ctrl_am_state == S_CTRL_AM_UPDATE_SEP)) begin
            am_reg_en_o = 1'b1;
            am_reg_wben_o = r_reg_wben;
        end
        else if (ctrl_am_state == S_CTRL_AM_READ_SEP) begin
            am_reg_en_o = 1'b1;
            am_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
        end
        else if (TCU_ENABLE_VIRT_PES && (ctrl_am_state == S_CTRL_AM_UPDATE_VPE2)) begin
            am_reg_en_o = 1'b1;
            am_reg_wben_o = r_reg_wben;
        end
    end

    assign am_reg_addr_o = r_reg_addr;
    assign am_reg_wdata_o = r_reg_wdata;

    assign am_error_o = r_am_error;
    assign am_active_o = (ctrl_am_state != S_CTRL_AM_IDLE);
    assign am_done_o = (ctrl_am_state == S_CTRL_AM_FINISH);


endmodule
