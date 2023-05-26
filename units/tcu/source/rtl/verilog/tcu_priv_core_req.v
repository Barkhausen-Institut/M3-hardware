
`include "tcu_defines.vh"

module tcu_priv_core_req #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter TCU_REGADDR_CORE_REQ_INT = TCU_REGADDR_CORE_CFG_START + 'h8,
    parameter HOME_MODID                = {NOC_MODID_SIZE{1'b0}}
)(
    input  wire                                 clk_i,
    input  wire                                 reset_n_i,

    //---------------
    //reg IF
    output reg                                  core_req_reg_en_o,
    output reg          [TCU_REG_BSEL_SIZE-1:0] core_req_reg_wben_o,
    output reg          [TCU_REG_ADDR_SIZE-1:0] core_req_reg_addr_o,
    output reg          [TCU_REG_DATA_SIZE-1:0] core_req_reg_wdata_o,
    input  wire         [TCU_REG_DATA_SIZE-1:0] core_req_reg_rdata_i,
    input  wire                                 core_req_reg_stall_i,

    //---------------
    //foreign msg requests
    input  wire                                 core_req_formsg_push_i,
    input  wire  [TCU_CORE_REQ_FORMSG_SIZE-1:0] core_req_formsg_data_i,
    output wire                                 core_req_formsg_stall_o,

    //---------------
    //PMP failures
    input  wire                                 core_req_pmpfail_push_i,
    input  wire [TCU_CORE_REQ_PMPFAIL_SIZE-1:0] core_req_pmpfail_data_i,
    output wire                                 core_req_pmpfail_stall_o,

    //---------------
    //logging
    output reg          [TCU_LOG_DATA_SIZE-1:0] tcu_log_core_req_data_o,

    //---------------
    //for debugging
    input  wire           [NOC_CHIPID_SIZE-1:0] home_chipid_i
);


    localparam CORE_REQ_TYPE_SIZE    = 3;
    localparam CORE_REQ_TYPE_IDLE    = 3'h0;
    localparam CORE_REQ_TYPE_RESP    = 3'h1;
    localparam CORE_REQ_TYPE_FORMSG  = 3'h2;
    localparam CORE_REQ_TYPE_PMPFAIL = 3'h3;

    localparam CORE_REQ_FIFO_WIDTH = (TCU_CORE_REQ_FORMSG_SIZE > TCU_CORE_REQ_PMPFAIL_SIZE) ?
                                        (TCU_CORE_REQ_FORMSG_SIZE + CORE_REQ_TYPE_SIZE) :
                                        (TCU_CORE_REQ_PMPFAIL_SIZE + CORE_REQ_TYPE_SIZE);

    localparam CORE_REQ_CTRL_STATES_SIZE         = 4;
    localparam S_CORE_REQ_CTRL_IDLE              = 4'h0;
    localparam S_CORE_REQ_CTRL_READ_INT1         = 4'h1;
    localparam S_CORE_REQ_CTRL_READ_INT2         = 4'h2;
    localparam S_CORE_REQ_CTRL_FORMSG_WRITE_REG  = 4'h3;
    localparam S_CORE_REQ_CTRL_FORMSG_INT        = 4'h4;
    localparam S_CORE_REQ_CTRL_PMPFAIL_WRITE_REG = 4'h5;
    localparam S_CORE_REQ_CTRL_PMPFAIL_INT       = 4'h6;
    localparam S_CORE_REQ_CTRL_CHECK_RSP1        = 4'h7;
    localparam S_CORE_REQ_CTRL_CHECK_RSP2        = 4'h8;
    localparam S_CORE_REQ_CTRL_FINISH            = 4'hF;

    reg [CORE_REQ_CTRL_STATES_SIZE-1:0] core_req_ctrl_state, next_core_req_ctrl_state;


    reg  [CORE_REQ_FIFO_WIDTH-1:0] r_fifo_wdata, rin_fifo_wdata;
    reg                            r_fifo_push, rin_fifo_push;


    wire                           fifo_pop = (core_req_ctrl_state == S_CORE_REQ_CTRL_FINISH);
    wire                           fifo_empty;
    wire                           fifo_full;
    wire [CORE_REQ_FIFO_WIDTH-1:0] fifo_rdata;


    //split FIFO data
    //data is organized like CORE_REQ reg but gaps are filled up (shifted right)
    wire [CORE_REQ_TYPE_SIZE-1:0] core_req_type    = fifo_rdata[CORE_REQ_TYPE_SIZE-1 : 0];

    wire        [TCU_EP_SIZE-1:0] formsg_req_ep    = fifo_rdata[TCU_EP_SIZE+CORE_REQ_TYPE_SIZE-1 : CORE_REQ_TYPE_SIZE];
    wire     [TCU_VPEID_SIZE-1:0] formsg_req_vpeid = fifo_rdata[TCU_VPEID_SIZE+TCU_EP_SIZE+CORE_REQ_TYPE_SIZE-1 : TCU_EP_SIZE+CORE_REQ_TYPE_SIZE];

    wire                          pmpfail_write    = fifo_rdata[CORE_REQ_TYPE_SIZE];
    wire     [TCU_ERROR_SIZE-1:0] pmpfail_error    = fifo_rdata[TCU_ERROR_SIZE+1+CORE_REQ_TYPE_SIZE-1 : 1+CORE_REQ_TYPE_SIZE];
    wire  [TCU_PHYSADDR_SIZE-1:0] pmpfail_addr     = fifo_rdata[TCU_PHYSADDR_SIZE+TCU_ERROR_SIZE+1+CORE_REQ_TYPE_SIZE-1 : TCU_ERROR_SIZE+1+CORE_REQ_TYPE_SIZE];


    assign core_req_formsg_stall_o = fifo_full;
    assign core_req_pmpfail_stall_o = fifo_full || core_req_formsg_push_i;  //foreign msg. req. has prio



    //FIFO to store core requests
    sync_fifo #(
        .DATA_WIDTH (CORE_REQ_FIFO_WIDTH),
        .ADDR_WIDTH (3)
    ) core_req_fifo (
        .clk_i		(clk_i),
        .resetn_i	(reset_n_i),

        .wr_en_i	(r_fifo_push),
        .wdata_i	(r_fifo_wdata),
        .wfull_o	(fifo_full),

        .rd_en_i	(fifo_pop),
        .rdata_o	(fifo_rdata),
        .rempty_o	(fifo_empty)
    );



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            core_req_ctrl_state <= S_CORE_REQ_CTRL_IDLE;

            r_fifo_wdata <= {CORE_REQ_FIFO_WIDTH{1'b0}};
            r_fifo_push <= 1'b0;
        end
        else begin
            core_req_ctrl_state <= next_core_req_ctrl_state;

            r_fifo_wdata <= rin_fifo_wdata;
            r_fifo_push <= rin_fifo_push;
        end
    end


    //---------------
    //FIFO input
    always @* begin
        rin_fifo_push = 1'b0;
        rin_fifo_wdata = {CORE_REQ_FIFO_WIDTH{1'b0}};

        if (!fifo_full) begin
            if (core_req_formsg_push_i) begin
                rin_fifo_push = 1'b1;
                rin_fifo_wdata = {core_req_formsg_data_i, CORE_REQ_TYPE_FORMSG};
            end
            else if (core_req_pmpfail_push_i) begin
                rin_fifo_push = 1'b1;
                rin_fifo_wdata = {core_req_pmpfail_data_i, CORE_REQ_TYPE_PMPFAIL};
            end
        end
    end


    //---------------
    //state machine to read FIFO
    always @* begin
        next_core_req_ctrl_state = core_req_ctrl_state;

        tcu_log_core_req_data_o = TCU_LOG_NONE;


        case(core_req_ctrl_state)

            S_CORE_REQ_CTRL_IDLE: begin
                if (!fifo_empty) begin
                    //first check interrupt pin if it is not set anymore
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_READ_INT1;
                end
            end


            //---------------
            //read interrrupt
            S_CORE_REQ_CTRL_READ_INT1: begin
                if (!core_req_reg_stall_i) begin
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_READ_INT2;
                end
            end

            S_CORE_REQ_CTRL_READ_INT2: begin
                if (core_req_reg_rdata_i == {TCU_REG_DATA_SIZE{1'b0}}) begin
                    if (core_req_type == CORE_REQ_TYPE_FORMSG) begin
                        next_core_req_ctrl_state = S_CORE_REQ_CTRL_FORMSG_WRITE_REG;
                    end
                    else if (core_req_type == CORE_REQ_TYPE_PMPFAIL) begin
                        next_core_req_ctrl_state = S_CORE_REQ_CTRL_PMPFAIL_WRITE_REG;
                    end

                    //should not happen because no other core req. type exists
                    else begin
                        next_core_req_ctrl_state = S_CORE_REQ_CTRL_FINISH;
                    end
                end

                //interrupt pin still set, wait for completion, check again
                else begin
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_READ_INT1;
                end
            end


            //---------------
            //context switching request
            //set CORE_REQ reg
            S_CORE_REQ_CTRL_FORMSG_WRITE_REG: begin
                if (!core_req_reg_stall_i) begin
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_FORMSG_INT;
                end
            end

            //set interrrupt
            S_CORE_REQ_CTRL_FORMSG_INT: begin
                if (!core_req_reg_stall_i) begin
                    `TCU_DEBUG(("CORE_REQ_FORMSG, vpeid: 0x%0x, ep: %0d", formsg_req_vpeid, formsg_req_ep));
                    tcu_log_core_req_data_o = {formsg_req_ep, formsg_req_vpeid, TCU_LOG_PRIV_CORE_REQ_FORMSG};
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_CHECK_RSP1;
                end
            end


            //---------------
            //PMP fail request
            //set CORE_REQ reg
            S_CORE_REQ_CTRL_PMPFAIL_WRITE_REG: begin
                if (!core_req_reg_stall_i) begin
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_PMPFAIL_INT;
                end
            end

            //set interrrupt
            S_CORE_REQ_CTRL_PMPFAIL_INT: begin
                if (!core_req_reg_stall_i) begin
                    `TCU_DEBUG(("CORE_REQ_PMPFAIL, addr: 0x%0x, write: %d, error: %0d", pmpfail_addr, pmpfail_write, pmpfail_error));
                    tcu_log_core_req_data_o = {pmpfail_addr, pmpfail_error, pmpfail_write, TCU_LOG_PRIV_CORE_REQ_PMPFAIL};
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_CHECK_RSP1;
                end
            end


            //---------------
            //wait for core req response
            S_CORE_REQ_CTRL_CHECK_RSP1: begin
                if (!core_req_reg_stall_i) begin
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_CHECK_RSP2;
                end
            end

            S_CORE_REQ_CTRL_CHECK_RSP2: begin
                //check if response has arrived, otherwise read again
                if (core_req_reg_rdata_i[CORE_REQ_TYPE_SIZE-1:0] == CORE_REQ_TYPE_RESP) begin
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_FINISH;
                end
                else begin
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_CHECK_RSP1;
                end
            end

            //---------------
            S_CORE_REQ_CTRL_FINISH: begin
                if (!core_req_reg_stall_i) begin
                    `TCU_DEBUG(("CORE_REQ_FINISH"));
                    tcu_log_core_req_data_o = {TCU_LOG_PRIV_CORE_REQ_FINISH};
                    next_core_req_ctrl_state = S_CORE_REQ_CTRL_IDLE;
                end
            end

            //default: next_core_req_ctrl_state = S_CORE_REQ_CTRL_IDLE;

        endcase //case (core_req_ctrl_state)
    end


    //---------------
    //reg interface
    always @* begin
        core_req_reg_en_o = 1'b0;
        core_req_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
        core_req_reg_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
        core_req_reg_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};

        //write
        if (core_req_ctrl_state == S_CORE_REQ_CTRL_FORMSG_WRITE_REG) begin
            core_req_reg_en_o = 1'b1;
            core_req_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b1}};
            core_req_reg_addr_o = TCU_REGADDR_CORE_REQ;
            core_req_reg_wdata_o = {formsg_req_vpeid,
                                    {(TCU_REG_DATA_SIZE-TCU_VPEID_SIZE-TCU_EP_SIZE-CORE_REQ_TYPE_SIZE){1'b0}},
                                    formsg_req_ep,
                                    core_req_type};
        end
        else if (core_req_ctrl_state == S_CORE_REQ_CTRL_PMPFAIL_WRITE_REG) begin
            core_req_reg_en_o = 1'b1;
            core_req_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b1}};
            core_req_reg_addr_o = TCU_REGADDR_CORE_REQ;
            core_req_reg_wdata_o = {pmpfail_addr,
                                    {(TCU_PHYSADDR_SIZE-TCU_ERROR_SIZE-1-CORE_REQ_TYPE_SIZE){1'b0}},
                                    pmpfail_error, pmpfail_write, core_req_type};
        end
        else if ((core_req_ctrl_state == S_CORE_REQ_CTRL_FORMSG_INT) || (core_req_ctrl_state == S_CORE_REQ_CTRL_PMPFAIL_INT)) begin
            core_req_reg_en_o = 1'b1;
            core_req_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b1}};
            core_req_reg_addr_o = TCU_REGADDR_CORE_REQ_INT;
            core_req_reg_wdata_o = 'h1;
        end

        //read
        else if (core_req_ctrl_state == S_CORE_REQ_CTRL_READ_INT1) begin
            core_req_reg_en_o = 1'b1;
            core_req_reg_addr_o = TCU_REGADDR_CORE_REQ_INT;
        end
        else if (core_req_ctrl_state == S_CORE_REQ_CTRL_CHECK_RSP1) begin
            core_req_reg_en_o = 1'b1;
            core_req_reg_addr_o = TCU_REGADDR_CORE_REQ;
        end

        //reset core_req reg
        else if (core_req_ctrl_state == S_CORE_REQ_CTRL_FINISH) begin
            core_req_reg_en_o = 1'b1;
            core_req_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b1}};
            core_req_reg_addr_o = TCU_REGADDR_CORE_REQ;
        end
    end


endmodule
