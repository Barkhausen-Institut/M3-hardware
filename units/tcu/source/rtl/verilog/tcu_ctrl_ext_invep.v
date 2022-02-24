
module tcu_ctrl_ext_invep #(
    `include "tcu_parameter.vh"
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //reg IF (only write)
    output reg                           ext_invep_reg_en_o,
    output reg   [TCU_REG_ADDR_SIZE-1:0] ext_invep_reg_addr_o,
    output reg   [TCU_REG_DATA_SIZE-1:0] ext_invep_reg_wdata_o,
    input  wire                          ext_invep_reg_stall_i,

    //---------------
    //triggers from tcu_ctrl
    input  wire                          ext_invep_start_i,
    input  wire    [TCU_OPCODE_SIZE-1:0] ext_invep_opcode_i,
    input  wire   [TCU_EXT_ARG_SIZE-1:0] ext_invep_arg_i,
    input  wire               [3*64-1:0] ext_invep_epdata_i,
    output wire                          ext_invep_active_o,
    output wire                          ext_invep_done_o,
    output wire     [TCU_ERROR_SIZE-1:0] ext_invep_error_o,
    output wire   [TCU_EXT_ARG_SIZE-1:0] ext_invep_arg_o
);


    localparam CTRL_EXT_INVEP_STATES_SIZE = 2;
    localparam S_CTRL_EXT_INVEP_IDLE      = 2'h0;
    localparam S_CTRL_EXT_INVEP_UPDATE_EP = 2'h1;
    localparam S_CTRL_EXT_INVEP_FINISH    = 2'h3;

    reg [CTRL_EXT_INVEP_STATES_SIZE-1:0] ctrl_ext_invep_state, next_ctrl_ext_invep_state;



    //temp ep reg
    reg [63:0] r_ep_0, rin_ep_0;

    reg [31:0] r_reg_addr, rin_reg_addr;
    reg [31:0] r_tmp_arg, rin_tmp_arg;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_ext_invep_error, rin_ext_invep_error;
    


    //ep info
    wire [TCU_EP_TYPE_SIZE-1:0] type_s       = ext_invep_epdata_i[TCU_EP_TYPE_SIZE-1 : 0];
    wire     [TCU_CRD_SIZE-1:0] sep_curcrd_s = ext_invep_epdata_i[TCU_CRD_SIZE+TCU_EP_TYPE_SIZE+16-1 : TCU_EP_TYPE_SIZE+16];
    wire     [TCU_CRD_SIZE-1:0] sep_maxcrd_s = ext_invep_epdata_i[2*TCU_CRD_SIZE+TCU_EP_TYPE_SIZE+16-1 : TCU_CRD_SIZE+TCU_EP_TYPE_SIZE+16];
    wire                 [31:0] rep_unread_s = ext_invep_epdata_i[3*64-1 : 2*64+32];

    //arg input
    wire [TCU_EP_SIZE-1:0] epid_s = ext_invep_arg_i[TCU_EP_SIZE-1:0];
    wire                  force_s = ext_invep_arg_i[TCU_EP_SIZE];



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_ext_invep_state <= S_CTRL_EXT_INVEP_IDLE;

            r_reg_addr <= 32'h0;
            r_tmp_arg <= 32'h0;
            r_ep_0 <= 64'h0;

            r_ext_invep_error <= TCU_ERROR_NONE;
        end
        else begin
            ctrl_ext_invep_state <= next_ctrl_ext_invep_state;

            r_reg_addr <= rin_reg_addr;
            r_tmp_arg <= rin_tmp_arg;
            r_ep_0 <= rin_ep_0;

            r_ext_invep_error <= rin_ext_invep_error;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_ext_invep_state = ctrl_ext_invep_state;

        rin_reg_addr = r_reg_addr;
        rin_tmp_arg = r_tmp_arg;
        rin_ep_0 = r_ep_0;

        rin_ext_invep_error = r_ext_invep_error;


        case (ctrl_ext_invep_state)

            //---------------
            //wait for incoming command
            S_CTRL_EXT_INVEP_IDLE: begin
                if (ext_invep_start_i && (ext_invep_opcode_i == TCU_OPCODE_EXT_INVEP)) begin
                    rin_ep_0 = ext_invep_epdata_i[63:0];
                    rin_reg_addr = TCU_REGADDR_EP_START + epid_s*TCU_EP_REG_SIZE;

                    //if it is a send ep
                    if (!force_s && (type_s == TCU_EP_TYPE_SEND) && (sep_curcrd_s != sep_maxcrd_s)) begin
                        rin_tmp_arg = 'h0;
                        rin_ext_invep_error = TCU_ERROR_NO_CREDITS;
                        next_ctrl_ext_invep_state = S_CTRL_EXT_INVEP_FINISH;
                    end

                    //if it is a recv ep
                    else if (!force_s && (type_s == TCU_EP_TYPE_RECEIVE)) begin
                        rin_tmp_arg = rep_unread_s;
                        rin_ext_invep_error = TCU_ERROR_NONE;
                        next_ctrl_ext_invep_state = S_CTRL_EXT_INVEP_UPDATE_EP;
                    end

                    //anything else
                    else begin
                        rin_tmp_arg = 'h0;
                        rin_ext_invep_error = TCU_ERROR_NONE;
                        next_ctrl_ext_invep_state = S_CTRL_EXT_INVEP_UPDATE_EP;
                    end
                end
            end


            //---------------
            //update ep: invalidate type
            S_CTRL_EXT_INVEP_UPDATE_EP: begin
                //wait until reg is free, then continue
                if (!ext_invep_reg_stall_i) begin
                    next_ctrl_ext_invep_state = S_CTRL_EXT_INVEP_FINISH;
                end
            end

            //---------------
            S_CTRL_EXT_INVEP_FINISH: begin
                next_ctrl_ext_invep_state = S_CTRL_EXT_INVEP_IDLE;
            end

            default: next_ctrl_ext_invep_state = S_CTRL_EXT_INVEP_IDLE;

        endcase //case (ctrl_ext_invep_state)
    end





    //---------------
    //reg interface
    always @* begin
        ext_invep_reg_en_o = 1'b0;
        ext_invep_reg_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
        ext_invep_reg_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};

        if (ctrl_ext_invep_state == S_CTRL_EXT_INVEP_UPDATE_EP) begin
            ext_invep_reg_en_o = 1'b1;
            ext_invep_reg_addr_o = r_reg_addr;
            ext_invep_reg_wdata_o = {r_ep_0[63:TCU_EP_TYPE_SIZE], TCU_EP_TYPE_INVALID};
        end
    end


    assign ext_invep_active_o = (ctrl_ext_invep_state != S_CTRL_EXT_INVEP_IDLE);
    assign ext_invep_done_o = (ctrl_ext_invep_state == S_CTRL_EXT_INVEP_FINISH);
    assign ext_invep_error_o = r_ext_invep_error;
    assign ext_invep_arg_o = {{(TCU_EXT_ARG_SIZE-32){1'b0}}, r_tmp_arg};


endmodule
