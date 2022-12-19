
`include "tcu_defines.vh"

module tcu_priv_ctrl #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter TIMER_SIZE              = 32,
    parameter TLB_DEPTH                = 32,
    parameter TCU_ENABLE_VIRT_PES      = 0,
    parameter TCU_REGADDR_CORE_REQ_INT = TCU_REGADDR_CORE_CFG_START + 'h8,
    parameter TCU_REGADDR_TIMER_INT    = TCU_REGADDR_CORE_CFG_START + 'h10,
    parameter TCU_ENABLE_LOG           = 0,
    parameter HOME_MODID               = {NOC_MODID_SIZE{1'b0}},
    parameter CLKFREQ_MHZ              = 100
)(
    input  wire                                clk_i,
    input  wire                                reset_n_i,

    //---------------
    //reg IF
    output reg                                 priv_reg_en_o,
    output reg         [TCU_REG_BSEL_SIZE-1:0] priv_reg_wben_o,
    output reg         [TCU_REG_ADDR_SIZE-1:0] priv_reg_addr_o,
    output reg         [TCU_REG_DATA_SIZE-1:0] priv_reg_wdata_o,
    input  wire        [TCU_REG_DATA_SIZE-1:0] priv_reg_rdata_i,
    input  wire                                priv_reg_stall_i,

    //---------------
    //TLB IF to translate addr of unprivileged cmds
    input  wire                                unpriv_tlb_read_i,
    input  wire       [TCU_TLB_VPEID_SIZE-1:0] unpriv_tlb_vpeid_i,
    input  wire    [TCU_TLB_VIRTPAGE_SIZE-1:0] unpriv_tlb_virtpage_i,
    input  wire                          [1:0] unpriv_tlb_read_perm_i,
    output reg     [TCU_TLB_PHYSPAGE_SIZE-1:0] unpriv_tlb_physpage_o,
    output wire                                unpriv_tlb_active_o,
    output reg                                 unpriv_tlb_read_done_o,    //becomes high when correct data is in physpage
    output reg            [TCU_ERROR_SIZE-1:0] unpriv_tlb_read_error_o,

    //---------------
    //core req: foreign msg
    input  wire                                core_req_formsg_push_i,
    input  wire [TCU_CORE_REQ_FORMSG_SIZE-1:0] core_req_formsg_data_i,
    output wire                                core_req_formsg_stall_o,

    //---------------
    //signals to unpriv cmds
    input  wire          [TCU_OPCODE_SIZE-1:0] unpriv_cmd_opcode_i,
    output wire                                unpriv_write_abort_o,  //abort transfer of unpriv cmd
    output wire                                unpriv_read_abort_o,
    output wire                                unpriv_send_abort_o,
    output wire                                unpriv_reply_abort_o,

    //---------------
    //triggers from tcu_ctrl
    input  wire                                priv_cmd_start_i,
    input  wire          [TCU_OPCODE_SIZE-1:0] priv_cmd_opcode_i,
    input  wire        [TCU_PRIV_ARG_SIZE-1:0] priv_cmd_arg0_i,
    input  wire                         [63:0] priv_cmd_arg1_i,
    input  wire                         [31:0] priv_cmd_cur_vpe_i,
    input  wire                                priv_cmd_stall_i,

    //---------------
    //TCU feature settings
    input  wire                                tcu_features_virt_pes_i,

    //---------------
    //logging
    output wire                                log_priv_fifo_empty_o,
    output wire        [TCU_LOG_DATA_SIZE-1:0] log_priv_fifo_data_out_o,
    input  wire                                log_priv_fifo_pop_i,

    //---------------
    //for debugging
    input  wire          [NOC_CHIPID_SIZE-1:0] home_chipid_i
);

    `include "tcu_functions.v"

    localparam PRIV_CTRL_STATES_SIZE     = 4;
    localparam S_PRIV_CTRL_IDLE          = 4'h0;
    localparam S_PRIV_CTRL_INV_PAGE      = 4'h1;
    localparam S_PRIV_CTRL_INV_PAGE_WAIT = 4'h2;
    localparam S_PRIV_CTRL_INV_TLB       = 4'h3;
    localparam S_PRIV_CTRL_INV_TLB_WAIT  = 4'h4;
    localparam S_PRIV_CTRL_INS_TLB       = 4'h5;
    localparam S_PRIV_CTRL_INS_TLB_WAIT  = 4'h6;
    localparam S_PRIV_CTRL_XCHG_VPE1     = 4'h7;
    localparam S_PRIV_CTRL_XCHG_VPE2     = 4'h8;
    localparam S_PRIV_CTRL_SET_TIMER     = 4'h9;
    localparam S_PRIV_CTRL_ABORT_CMD     = 4'hA;
    localparam S_PRIV_CTRL_ABORT_WAIT    = 4'hB;
    localparam S_PRIV_CTRL_FINISH        = 4'hF;

    reg [PRIV_CTRL_STATES_SIZE-1:0] priv_ctrl_state, next_priv_ctrl_state;


    localparam UNPRIV_TLB_STATES_SIZE = 1;
    localparam S_UNPRIV_TLB_IDLE      = 1'h0;
    localparam S_UNPRIV_TLB_READ      = 1'h1;

    reg [UNPRIV_TLB_STATES_SIZE-1:0] unpriv_tlb_state, next_unpriv_tlb_state;


    //output arg
    reg [TCU_PRIV_ARG_SIZE-1:0] r_priv_cmd_arg_out, rin_priv_cmd_arg_out;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_priv_cmd_error, rin_priv_cmd_error;

    //TLB signals
    reg                         ctrl_tlb_en;
    reg  [TCU_TLB_CMD_SIZE-1:0] ctrl_tlb_cmd;
    reg [TCU_TLB_DATA_SIZE-1:0] ctrl_tlb_wdata;

    reg unpriv_tlb_en;

    reg                         r_tlb_en, rin_tlb_en;
    reg  [TCU_TLB_CMD_SIZE-1:0] r_tlb_cmd, rin_tlb_cmd;
    reg [TCU_TLB_DATA_SIZE-1:0] r_tlb_wdata, rin_tlb_wdata;


    //abort signals
    reg r_unpriv_write_abort, rin_unpriv_write_abort;
    reg r_unpriv_read_abort, rin_unpriv_read_abort;
    reg r_unpriv_send_abort, rin_unpriv_send_abort;
    reg r_unpriv_reply_abort, rin_unpriv_reply_abort;


    wire  [TCU_TLB_DATA_SIZE-1:0] tlb_rdata;
    wire                          tlb_active;
    wire                          tlb_done;
    wire     [TCU_ERROR_SIZE-1:0] tlb_error;


    //assign args
    wire    [TCU_TLB_VPEID_SIZE-1:0] priv_cmd_inv_page_vpeid = priv_cmd_arg0_i[TCU_TLB_VPEID_SIZE-1:0];
    wire    [TCU_TLB_VPEID_SIZE-1:0] priv_cmd_ins_tlb_vpeid  = priv_cmd_arg0_i[32+TCU_TLB_VPEID_SIZE-1:32];
    wire [TCU_TLB_VIRTPAGE_SIZE-1:0] priv_cmd_virtpage       = priv_cmd_arg1_i[TCU_VIRTADDR_SIZE-TCU_TLB_VIRTPAGE_SIZE +: TCU_TLB_VIRTPAGE_SIZE];
    wire     [TCU_TLB_PERM_SIZE-1:0] priv_cmd_perm           = priv_cmd_arg0_i[TCU_TLB_PERM_SIZE-1:0];
    wire [TCU_TLB_PHYSPAGE_SIZE-1:0] priv_cmd_physpage       = priv_cmd_arg0_i[TCU_PHYSADDR_SIZE-TCU_TLB_PHYSPAGE_SIZE +: TCU_TLB_PHYSPAGE_SIZE];

    wire                      [31:0] priv_cmd_xchg_vpe = priv_cmd_arg0_i[31:0];


    wire set_timer = (priv_ctrl_state == S_PRIV_CTRL_SET_TIMER);
    wire timer_int;

    wire                         core_req_reg_en;
    wire [TCU_REG_BSEL_SIZE-1:0] core_req_reg_wben;
    wire [TCU_REG_ADDR_SIZE-1:0] core_req_reg_addr;
    wire [TCU_REG_DATA_SIZE-1:0] core_req_reg_wdata;


    //logging
    reg  [TCU_LOG_DATA_SIZE-1:0] tcu_log_priv_cmd_data;
    wire [TCU_LOG_DATA_SIZE-1:0] tcu_log_core_req_data;


    assign unpriv_write_abort_o = r_unpriv_write_abort;
    assign unpriv_read_abort_o = r_unpriv_read_abort;
    assign unpriv_send_abort_o = r_unpriv_send_abort;
    assign unpriv_reply_abort_o = r_unpriv_reply_abort;


    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            priv_ctrl_state <= S_PRIV_CTRL_IDLE;
            unpriv_tlb_state <= S_UNPRIV_TLB_IDLE;

            r_tlb_en <= 1'b0;
            r_tlb_cmd <= TCU_TLB_CMD_READ_ENTRY;
            r_tlb_wdata <= {TCU_TLB_DATA_SIZE{1'b0}};

            r_unpriv_write_abort <= 1'b0;
            r_unpriv_read_abort <= 1'b0;
            r_unpriv_send_abort <= 1'b0;
            r_unpriv_reply_abort <= 1'b0;

            r_priv_cmd_arg_out <= {TCU_PRIV_ARG_SIZE{1'b0}};
            r_priv_cmd_error <= TCU_ERROR_NONE;
        end
        else begin
            priv_ctrl_state <= next_priv_ctrl_state;
            unpriv_tlb_state <= next_unpriv_tlb_state;

            r_tlb_en <= rin_tlb_en;
            r_tlb_cmd <= rin_tlb_cmd;
            r_tlb_wdata <= rin_tlb_wdata;

            r_unpriv_write_abort <= rin_unpriv_write_abort;
            r_unpriv_read_abort <= rin_unpriv_read_abort;
            r_unpriv_send_abort <= rin_unpriv_send_abort;
            r_unpriv_reply_abort <= rin_unpriv_reply_abort;

            r_priv_cmd_arg_out <= rin_priv_cmd_arg_out;
            r_priv_cmd_error <= rin_priv_cmd_error;
        end
    end




    //---------------
    //state machine for priv cmds
    always @* begin
        next_priv_ctrl_state = priv_ctrl_state;

        ctrl_tlb_en = 1'b0;
        ctrl_tlb_cmd = TCU_TLB_CMD_READ_ENTRY;
        ctrl_tlb_wdata = {TCU_TLB_DATA_SIZE{1'b0}};

        rin_priv_cmd_arg_out = r_priv_cmd_arg_out;
        rin_priv_cmd_error = r_priv_cmd_error;

        rin_unpriv_write_abort = r_unpriv_write_abort;
        rin_unpriv_read_abort = r_unpriv_read_abort;
        rin_unpriv_send_abort = r_unpriv_send_abort;
        rin_unpriv_reply_abort = r_unpriv_reply_abort;

        tcu_log_priv_cmd_data = TCU_LOG_NONE;


        case(priv_ctrl_state)

            S_PRIV_CTRL_IDLE: begin
                if (priv_cmd_start_i) begin
                    rin_priv_cmd_error = TCU_ERROR_NONE;
                    rin_priv_cmd_arg_out = 'h0;

                    //read opcode
                    case (priv_cmd_opcode_i)

                        TCU_OPCODE_PRIV_INV_PAGE: begin
                            `TCU_DEBUG(("CMD_PRIV_INV_PAGE, vpeid: %0d, virt: 0x%x", priv_cmd_inv_page_vpeid, priv_cmd_virtpage));
                            tcu_log_priv_cmd_data = {priv_cmd_virtpage, priv_cmd_inv_page_vpeid, TCU_LOG_CMD_PRIV_INV_PAGE};

                            next_priv_ctrl_state = S_PRIV_CTRL_INV_PAGE;
                        end

                        TCU_OPCODE_PRIV_INV_TLB: begin
                            `TCU_DEBUG(("CMD_PRIV_INV_TLB"));
                            tcu_log_priv_cmd_data = TCU_LOG_CMD_PRIV_INV_TLB;

                            next_priv_ctrl_state = S_PRIV_CTRL_INV_TLB;
                        end

                        TCU_OPCODE_PRIV_INS_TLB: begin
                            `TCU_DEBUG(("CMD_PRIV_INS_TLB, vpeid: %0d, virt: 0x%x, phys: 0x%x", priv_cmd_ins_tlb_vpeid, priv_cmd_virtpage, priv_cmd_physpage));
                            tcu_log_priv_cmd_data = {priv_cmd_physpage, priv_cmd_virtpage, priv_cmd_ins_tlb_vpeid, TCU_LOG_CMD_PRIV_INS_TLB};

                            next_priv_ctrl_state = S_PRIV_CTRL_INS_TLB;
                        end

                        TCU_OPCODE_PRIV_XCHG_VPE: begin
                            if (TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) begin
                                next_priv_ctrl_state = S_PRIV_CTRL_XCHG_VPE1;
                            end
                        end

                        TCU_OPCODE_PRIV_SET_TIMER: begin
                            `TCU_DEBUG(("CMD_PRIV_SET_TIMER, nanos: %0d", priv_cmd_arg0_i));
                            tcu_log_priv_cmd_data = {priv_cmd_arg0_i, TCU_LOG_CMD_PRIV_SET_TIMER};

                            next_priv_ctrl_state = S_PRIV_CTRL_SET_TIMER;
                        end

                        TCU_OPCODE_PRIV_ABORT_CMD: begin
                            `TCU_DEBUG(("CMD_PRIV_ABORT_CMD"));
                            tcu_log_priv_cmd_data = TCU_LOG_CMD_PRIV_ABORT;

                            next_priv_ctrl_state = S_PRIV_CTRL_ABORT_CMD;
                        end

                        //---------------
                        //everthing else leads to an unknown command
                        default: begin
                            rin_priv_cmd_error = TCU_ERROR_UNKNOWN_CMD;
                            next_priv_ctrl_state = S_PRIV_CTRL_FINISH;
                        end
                    endcase
                end
            end


            //---------------
            S_PRIV_CTRL_INV_PAGE: begin
                if (!tlb_active && !unpriv_tlb_en) begin
                    ctrl_tlb_en = 1'b1;
                    ctrl_tlb_cmd = TCU_TLB_CMD_DEL_ENTRY;
                    ctrl_tlb_wdata = {TCU_MEMFLAG_R, {TCU_TLB_PHYSPAGE_SIZE{1'b0}}, priv_cmd_virtpage, priv_cmd_inv_page_vpeid};

                    next_priv_ctrl_state = S_PRIV_CTRL_INV_PAGE_WAIT;
                end
            end

            S_PRIV_CTRL_INV_PAGE_WAIT: begin
                if (tlb_done) begin
                    rin_priv_cmd_error = tlb_error;
                    next_priv_ctrl_state = S_PRIV_CTRL_FINISH;
                end
            end


            //---------------
            S_PRIV_CTRL_INV_TLB: begin
                if (!tlb_active && !unpriv_tlb_en) begin
                    ctrl_tlb_en = 1'b1;
                    ctrl_tlb_cmd = TCU_TLB_CMD_CLEAR;

                    next_priv_ctrl_state = S_PRIV_CTRL_INV_TLB_WAIT;
                end
            end

            S_PRIV_CTRL_INV_TLB_WAIT: begin
                if (tlb_done) begin
                    next_priv_ctrl_state = S_PRIV_CTRL_FINISH;
                end
            end


            //---------------
            S_PRIV_CTRL_INS_TLB: begin
                if (!tlb_active && !unpriv_tlb_en) begin
                    ctrl_tlb_en = 1'b1;
                    ctrl_tlb_cmd = TCU_TLB_CMD_WRITE_ENTRY;
                    ctrl_tlb_wdata = {priv_cmd_perm, priv_cmd_physpage, priv_cmd_virtpage, priv_cmd_ins_tlb_vpeid};

                    next_priv_ctrl_state = S_PRIV_CTRL_INS_TLB_WAIT;
                end
            end

            S_PRIV_CTRL_INS_TLB_WAIT: begin
                if (tlb_done) begin
                    rin_priv_cmd_error = tlb_error;
                    next_priv_ctrl_state = S_PRIV_CTRL_FINISH;
                end
            end


            //---------------
            S_PRIV_CTRL_XCHG_VPE1: begin
                if (TCU_ENABLE_VIRT_PES) begin
                    //ARG <- CUR_VPE
                    if (!priv_cmd_stall_i && !priv_reg_stall_i && !timer_int && !core_req_reg_en) begin
                        next_priv_ctrl_state = S_PRIV_CTRL_XCHG_VPE2;
                    end
                end
            end

            S_PRIV_CTRL_XCHG_VPE2: begin
                if (TCU_ENABLE_VIRT_PES) begin
                    //start again if unpriv. command became active
                    if (priv_cmd_stall_i) begin
                        next_priv_ctrl_state = S_PRIV_CTRL_XCHG_VPE1;
                    end

                    //CUR_VPE <- ARG0
                    else if (!priv_reg_stall_i && !timer_int && !core_req_reg_en) begin
                        `TCU_DEBUG(("CMD_PRIV_XCHG_VPE, cur_vpe: 0x%0x, xchg_vpe: 0x%0x", priv_cmd_cur_vpe_i, priv_cmd_xchg_vpe));
                        tcu_log_priv_cmd_data = {priv_cmd_xchg_vpe, priv_cmd_cur_vpe_i, TCU_LOG_CMD_PRIV_XCHG_VPE};

                        next_priv_ctrl_state = S_PRIV_CTRL_FINISH;
                    end
                end
            end

            //---------------
            S_PRIV_CTRL_SET_TIMER: begin
                next_priv_ctrl_state = S_PRIV_CTRL_FINISH;
            end

            //---------------
            //check if an unpriv cmd is currently running
            S_PRIV_CTRL_ABORT_CMD: begin
                //check current unpriv cmd
                if (unpriv_cmd_opcode_i == TCU_OPCODE_WRITE) begin
                    rin_unpriv_write_abort = 1'b1;
                    next_priv_ctrl_state = S_PRIV_CTRL_ABORT_WAIT;
                end
                else if (unpriv_cmd_opcode_i == TCU_OPCODE_READ) begin
                    rin_unpriv_read_abort = 1'b1;
                    next_priv_ctrl_state = S_PRIV_CTRL_ABORT_WAIT;
                end
                else if (unpriv_cmd_opcode_i == TCU_OPCODE_SEND) begin
                    rin_unpriv_send_abort = 1'b1;
                    next_priv_ctrl_state = S_PRIV_CTRL_ABORT_WAIT;
                end
                else if (unpriv_cmd_opcode_i == TCU_OPCODE_REPLY) begin
                    rin_unpriv_reply_abort = 1'b1;
                    next_priv_ctrl_state = S_PRIV_CTRL_ABORT_WAIT;
                end
                else begin
                    next_priv_ctrl_state = S_PRIV_CTRL_FINISH;
                end
            end

            //wait until command has been aborted
            S_PRIV_CTRL_ABORT_WAIT: begin
                if (unpriv_cmd_opcode_i == TCU_OPCODE_IDLE) begin
                    if (r_unpriv_write_abort ||
                        r_unpriv_read_abort ||
                        r_unpriv_send_abort ||
                        r_unpriv_reply_abort) begin
                        rin_priv_cmd_arg_out = 'h1;
                    end

                    rin_unpriv_write_abort = 1'b0;
                    rin_unpriv_read_abort = 1'b0;
                    rin_unpriv_send_abort = 1'b0;
                    rin_unpriv_reply_abort = 1'b0;
                    next_priv_ctrl_state = S_PRIV_CTRL_FINISH;
                end
            end

            //---------------
            S_PRIV_CTRL_FINISH: begin
                if (!priv_reg_stall_i && !timer_int && !core_req_reg_en) begin
                    next_priv_ctrl_state = S_PRIV_CTRL_IDLE;

                    `TCU_DEBUG(("CMD_PRIV_FINISH, error: %0d", r_priv_cmd_error));
                    if (r_priv_cmd_error != TCU_ERROR_NONE) begin
                        tcu_log_priv_cmd_data = {r_priv_cmd_error, TCU_LOG_CMD_PRIV_FINISH};
                    end
                end
            end

            default: next_priv_ctrl_state = S_PRIV_CTRL_IDLE;

        endcase //case (priv_ctrl_state)
    end




    //---------------
    //TLB lookups from unpriv cmds
    always @* begin
        next_unpriv_tlb_state = unpriv_tlb_state;

        unpriv_tlb_en = 1'b0;

        unpriv_tlb_read_done_o = 1'b0;
        unpriv_tlb_read_error_o = TCU_ERROR_NONE;
        unpriv_tlb_physpage_o = {TCU_TLB_PHYSPAGE_SIZE{1'b0}};


        case(unpriv_tlb_state)

            S_UNPRIV_TLB_IDLE: begin
                if (unpriv_tlb_read_i && !tlb_active) begin
                    unpriv_tlb_en = 1'b1;
                    next_unpriv_tlb_state = S_UNPRIV_TLB_READ;
                end
            end

            //---------------
            //TLB read
            S_UNPRIV_TLB_READ: begin
                if (tlb_done) begin
                    unpriv_tlb_read_done_o = 1'b1;

                    if (tlb_error == TCU_ERROR_NONE) begin
                        unpriv_tlb_physpage_o = tlb_rdata[TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE];
                    end

                    //if entry is not in TLB
                    else begin
                        unpriv_tlb_read_error_o = TCU_ERROR_TRANSLATION_FAULT;
                    end

                    next_unpriv_tlb_state = S_UNPRIV_TLB_IDLE;
                end
            end

        endcase
    end

    assign unpriv_tlb_active_o = (unpriv_tlb_state != S_UNPRIV_TLB_IDLE) || tlb_active;



    //---------------
    //reg interface
    always @* begin
        priv_reg_en_o = 1'b0;
        priv_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
        priv_reg_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
        priv_reg_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};

        if (timer_int) begin
            priv_reg_en_o = 1'b1;
            priv_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b1}};
            priv_reg_addr_o = TCU_REGADDR_TIMER_INT;
            priv_reg_wdata_o = 'h1;
        end
        else if (core_req_reg_en) begin
            priv_reg_en_o = 1'b1;
            priv_reg_wben_o = core_req_reg_wben;
            priv_reg_addr_o = core_req_reg_addr;
            priv_reg_wdata_o = core_req_reg_wdata;
        end
        else if (TCU_ENABLE_VIRT_PES && (priv_ctrl_state == S_PRIV_CTRL_XCHG_VPE1)) begin
            priv_reg_en_o = 1'b1;
            priv_reg_wben_o = 8'h0F;
            priv_reg_addr_o = TCU_REGADDR_PRIV_CMD_ARG;
            priv_reg_wdata_o = priv_cmd_cur_vpe_i;
        end
        else if (TCU_ENABLE_VIRT_PES && (priv_ctrl_state == S_PRIV_CTRL_XCHG_VPE2)) begin
            priv_reg_en_o = 1'b1;
            priv_reg_wben_o = 8'h0F;
            priv_reg_addr_o = TCU_REGADDR_CUR_VPE;
            priv_reg_wdata_o = priv_cmd_xchg_vpe;
        end
        else if (priv_ctrl_state == S_PRIV_CTRL_FINISH) begin
            priv_reg_en_o = 1'b1;
            priv_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b1}};
            priv_reg_addr_o = TCU_REGADDR_PRIV_CMD;
            priv_reg_wdata_o = {r_priv_cmd_arg_out, r_priv_cmd_error, TCU_OPCODE_PRIV_IDLE};
        end
    end



    //---------------
    //MUX for TLB IF
    always @* begin
        rin_tlb_en = 1'b0;
        rin_tlb_cmd = r_tlb_cmd;
        rin_tlb_wdata = r_tlb_wdata;

        if (!tlb_active) begin
            //TLB accesses from unpriv cmds have prio
            if (unpriv_tlb_en) begin
                rin_tlb_en = 1'b1;
                rin_tlb_cmd = TCU_TLB_CMD_READ_ENTRY;
                rin_tlb_wdata = {unpriv_tlb_read_perm_i, {TCU_TLB_PHYSPAGE_SIZE{1'b0}}, unpriv_tlb_virtpage_i, unpriv_tlb_vpeid_i};
            end
            else if (ctrl_tlb_en) begin
                rin_tlb_en = 1'b1;
                rin_tlb_cmd = ctrl_tlb_cmd;
                rin_tlb_wdata = ctrl_tlb_wdata;
            end
        end
    end

    



    tcu_priv_tlb #(
        .TLB_DEPTH               (TLB_DEPTH),
        .TCU_ENABLE_VIRT_PES     (TCU_ENABLE_VIRT_PES)
    ) i_tcu_priv_tlb (
        .clk_i                   (clk_i),
        .reset_n_i               (reset_n_i),

        .tcu_features_virt_pes_i (tcu_features_virt_pes_i),

        .tlb_en_i                (r_tlb_en),
        .tlb_cmd_i               (r_tlb_cmd),
        .tlb_wdata_i             (r_tlb_wdata),

        .tlb_rdata_o             (tlb_rdata),
        .tlb_active_o            (tlb_active),
        .tlb_done_o              (tlb_done),
        .tlb_error_o             (tlb_error)
    );


    tcu_priv_timer #(
        .TIMER_SIZE              (TIMER_SIZE),
        .CLKFREQ_MHZ             (CLKFREQ_MHZ)
    ) i_tcu_priv_timer (
        .clk_i                   (clk_i),
        .reset_n_i               (reset_n_i),

        .timer_value_valid_i     (set_timer),
        .timer_value_i           (priv_cmd_arg0_i[TIMER_SIZE-1:0]),

        .timer_int_stall_i       (priv_reg_stall_i),
        .timer_int_valid_o       (timer_int)
    );


    //core request only for foreign messages, not required when VPEs are disabled
    generate
    if (TCU_ENABLE_VIRT_PES) begin: CORE_REQ
        tcu_priv_core_req #(
            .TCU_REGADDR_CORE_REQ_INT(TCU_REGADDR_CORE_REQ_INT),
            .HOME_MODID              (HOME_MODID)
        ) i_tcu_priv_core_req (
            .clk_i                   (clk_i),
            .reset_n_i               (reset_n_i),

            .core_req_reg_en_o       (core_req_reg_en),
            .core_req_reg_wben_o     (core_req_reg_wben),
            .core_req_reg_addr_o     (core_req_reg_addr),
            .core_req_reg_wdata_o    (core_req_reg_wdata),
            .core_req_reg_rdata_i    (priv_reg_rdata_i),
            .core_req_reg_stall_i    (priv_reg_stall_i || timer_int),   //only timer interrupt has prio over core req

            .core_req_formsg_push_i  (core_req_formsg_push_i),
            .core_req_formsg_data_i  (core_req_formsg_data_i),
            .core_req_formsg_stall_o (core_req_formsg_stall_o),

            .tcu_log_core_req_data_o (tcu_log_core_req_data),

            .home_chipid_i           (home_chipid_i)
        );
    end
    else begin: NO_CORE_REQ
        assign core_req_reg_en = 1'b0;
        assign core_req_reg_wben = {TCU_REG_BSEL_SIZE{1'b0}};
        assign core_req_reg_addr = {TCU_REG_ADDR_SIZE{1'b0}};
        assign core_req_reg_wdata = {TCU_REG_DATA_SIZE{1'b0}};
        assign core_req_formsg_stall_o = 1'b0;
    end
    endgenerate



    generate
    if (TCU_ENABLE_LOG) begin: LOGGING
        reg  [TCU_LOG_DATA_SIZE-1:0] log_priv_fifo_data_out;

        wire                         log_priv_cmd_fifo_push = (tcu_log_priv_cmd_data[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_priv_cmd_fifo_pop;
        wire                         log_priv_cmd_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_priv_cmd_fifo_data_out;

        wire                         log_core_req_fifo_push = (tcu_log_core_req_data[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_core_req_fifo_pop;
        wire                         log_core_req_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_core_req_fifo_data_out;

        reg  [TCU_LOG_DATA_SIZE-1:0] tcu_log_tlb_data;
        wire                         log_tlb_fifo_push = (tcu_log_tlb_data[TCU_LOG_ID_SIZE-1:0] != TCU_LOG_NONE);
        reg                          log_tlb_fifo_pop;
        wire                         log_tlb_fifo_empty;
        wire [TCU_LOG_DATA_SIZE-1:0] log_tlb_fifo_data_out;

        wire                         log_timer_fifo_push = timer_int && !priv_reg_stall_i;
        reg                          log_timer_fifo_pop;
        wire                         log_timer_fifo_empty;
        wire   [TCU_LOG_ID_SIZE-1:0] log_timer_fifo_data_out;

        //use FIFOs because logs may occure at the same time
        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (1)
        ) log_priv_cmd_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_priv_cmd_fifo_push),
            .wdata_i	(tcu_log_priv_cmd_data),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_priv_cmd_fifo_pop),
            .rdata_o	(log_priv_cmd_fifo_data_out),
            .rempty_o	(log_priv_cmd_fifo_empty)
        );

        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (1)
        ) log_core_req_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_core_req_fifo_push),
            .wdata_i	(tcu_log_core_req_data),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_core_req_fifo_pop),
            .rdata_o	(log_core_req_fifo_data_out),
            .rempty_o	(log_core_req_fifo_empty)
        );

        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_DATA_SIZE),
            .ADDR_WIDTH (1)
        ) log_tlb_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_tlb_fifo_push),
            .wdata_i	(tcu_log_tlb_data),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_tlb_fifo_pop),
            .rdata_o	(log_tlb_fifo_data_out),
            .rempty_o	(log_tlb_fifo_empty)
        );

        sync_fifo #(
            .DATA_WIDTH (TCU_LOG_ID_SIZE),
            .ADDR_WIDTH (1)
        ) log_timer_fifo (
            .clk_i		(clk_i),
            .resetn_i	(reset_n_i),

            .wr_en_i	(log_timer_fifo_push),
            .wdata_i	(TCU_LOG_PRIV_TIMER_INTR),
            .wfull_o	(),     //we do not expect a full FIFO

            .rd_en_i	(log_timer_fifo_pop),
            .rdata_o	(log_timer_fifo_data_out),
            .rempty_o	(log_timer_fifo_empty)
        );

        always @* begin
            tcu_log_tlb_data = TCU_LOG_NONE;

            if (tlb_done) begin
                case(r_tlb_cmd)
                    TCU_TLB_CMD_WRITE_ENTRY: begin
                        `TCU_DEBUG(("TLB_WRITE_ENTRY, vpeid: 0x%0x, virt: 0x%x, phys: 0x%x, perm: 0x%x",
                                    r_tlb_wdata[TCU_TLB_VPEID_SIZE-1 : 0],
                                    r_tlb_wdata[TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VPEID_SIZE],
                                    r_tlb_wdata[TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE],
                                    r_tlb_wdata[TCU_TLB_DATA_SIZE-1 : TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE]));
                        tcu_log_tlb_data = {r_tlb_wdata, TCU_LOG_PRIV_TLB_WRITE_ENTRY};
                    end
                    TCU_TLB_CMD_READ_ENTRY: begin
                        `TCU_DEBUG(("TLB_READ_ENTRY, vpeid: 0x%0x, virt: 0x%x, read phys: 0x%x, read perm: 0x%x",
                                    r_tlb_wdata[TCU_TLB_VPEID_SIZE-1 : 0],
                                    r_tlb_wdata[TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VPEID_SIZE],
                                    tlb_rdata[TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE],
                                    tlb_rdata[TCU_TLB_DATA_SIZE-1 : TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE]));
                        tcu_log_tlb_data = {tlb_rdata[TCU_TLB_DATA_SIZE-1 : TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE],
                                            r_tlb_wdata[TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : 0],
                                            TCU_LOG_PRIV_TLB_READ_ENTRY};
                    end
                    TCU_TLB_CMD_DEL_ENTRY: begin
                        `TCU_DEBUG(("TLB_DEL_ENTRY, vpeid: 0x%0x, virt: 0x%x",
                                    r_tlb_wdata[TCU_TLB_VPEID_SIZE-1 : 0],
                                    r_tlb_wdata[TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VPEID_SIZE]));
                        tcu_log_tlb_data = {r_tlb_wdata[TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE : 0], TCU_LOG_PRIV_TLB_DEL_ENTRY};
                    end
                    TCU_TLB_CMD_CLEAR: begin
                        `TCU_DEBUG(("TLB_CLEAR"));
                        tcu_log_tlb_data = TCU_LOG_NONE;    //no extra log
                    end
                endcase
            end
        end


        always @* begin
            log_priv_fifo_data_out = TCU_LOG_NONE;

            log_priv_cmd_fifo_pop = 1'b0;
            log_core_req_fifo_pop = 1'b0;
            log_tlb_fifo_pop = 1'b0;
            log_timer_fifo_pop = 1'b0;

            if (!log_priv_cmd_fifo_empty) begin
                log_priv_fifo_data_out = log_priv_cmd_fifo_data_out;
                log_priv_cmd_fifo_pop = log_priv_fifo_pop_i;
            end
            else if (!log_core_req_fifo_empty) begin
                log_priv_fifo_data_out = log_core_req_fifo_data_out;
                log_core_req_fifo_pop = log_priv_fifo_pop_i;
            end
            else if (!log_tlb_fifo_empty) begin
                log_priv_fifo_data_out = log_tlb_fifo_data_out;
                log_tlb_fifo_pop = log_priv_fifo_pop_i;
            end
            else if (!log_timer_fifo_empty) begin
                log_priv_fifo_data_out = log_timer_fifo_data_out;
                log_timer_fifo_pop = log_priv_fifo_pop_i;
            end
        end

        assign log_priv_fifo_empty_o = log_priv_cmd_fifo_empty && log_core_req_fifo_empty && log_tlb_fifo_empty && log_timer_fifo_empty;
        assign log_priv_fifo_data_out_o = log_priv_fifo_data_out;
    end
    else begin: NO_LOGGING
        assign log_priv_fifo_empty_o = 1'b1;
        assign log_priv_fifo_data_out_o = TCU_LOG_NONE;
    end
    endgenerate


endmodule
