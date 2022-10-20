
module tcu_ctrl_noc_req #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter REQFIFO_DATA_SIZE = 128,
    parameter REQFIFO_ADDR_SIZE  = 3
)(
    input  wire                         clk_i,
    input  wire                         reset_n_i,

    //---------------
    //FIFO signals
    input  wire                         reqfifo_push_i,
    output wire                         reqfifo_full_o,
    input  wire [REQFIFO_DATA_SIZE-1:0] reqfifo_wdata_i,
    output wire [REQFIFO_DATA_SIZE-1:0] reqfifo_rdata_o,

    //---------------
    //reg IF
    output wire                         reg_en_o,
    input  wire [TCU_REG_DATA_SIZE-1:0] reg_rdata_i,
    output wire [TCU_REG_DATA_SIZE-1:0] reg_retdata_o,
    input  wire                         reg_stall_i,

    //---------------
    //link to mem_access_send
    output wire                         start_noc_send_o,
    input  wire                         noc_stall_i,

    //---------------
    //stall and done
    input  wire                         noc_req_stall_i,
    output wire                         noc_req_done_o
);


    localparam NOC_REQ_STATES_SIZE          = 3;
    localparam S_NOC_REQ_IDLE               = 3'h0;
    localparam S_NOC_REQ_TCU_REG_READ       = 3'h1;
    localparam S_NOC_REQ_TCU_REG_READ_VALID = 3'h2;
    localparam S_NOC_REQ_MEM_READ           = 3'h3;
    localparam S_NOC_REQ_FINISH             = 3'h7;

    reg [NOC_REQ_STATES_SIZE-1:0] noc_req_state, next_noc_req_state;

    reg [TCU_REG_DATA_SIZE-1:0] r_reg_retdata, rin_reg_retdata;
    
    reg reqfifo_pop;


    wire reqfifo_empty;

    //addr is at uppermost bits of FIFO read data
    wire [NOC_ADDR_SIZE-1:0] reqfifo_addr = reqfifo_rdata_o[REQFIFO_DATA_SIZE-1 : REQFIFO_DATA_SIZE-NOC_ADDR_SIZE];



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            noc_req_state <= S_NOC_REQ_IDLE;

            r_reg_retdata <= {TCU_REG_DATA_SIZE{1'b0}};
        end
        else begin
            noc_req_state <= next_noc_req_state;

            r_reg_retdata <= rin_reg_retdata;
        end
    end




    //FIFO to store incoming read requests
    //laddr, retaddr, read_size, mode, chipid, modid, bsel
    sync_fifo #(
        .DATA_WIDTH (REQFIFO_DATA_SIZE),
        .ADDR_WIDTH (REQFIFO_ADDR_SIZE)
    ) reqfifo (
        .clk_i      (clk_i),
        .resetn_i   (reset_n_i),

        .wr_en_i    (reqfifo_push_i),
        .wdata_i    (reqfifo_wdata_i),
        .wfull_o    (reqfifo_full_o),

        .rd_en_i    (reqfifo_pop),
        .rdata_o    (reqfifo_rdata_o),
        .rempty_o   (reqfifo_empty)
    );



    //---------------
    //state machine for request FIFO
    always @* begin
        next_noc_req_state = noc_req_state;

        rin_reg_retdata = r_reg_retdata;
        reqfifo_pop = 1'b0;


        case (noc_req_state)

            //---------------
            //wait until a request is in FIFO and nothing else to send
            //except memory request to enable self read
            S_NOC_REQ_IDLE: begin
                if (!reqfifo_empty && !noc_req_stall_i) begin

                    //access to TCU reg
                    if (reqfifo_addr[(NOC_ADDR_SIZE-4)+:4] == TCU_REGADDR_START[(NOC_ADDR_SIZE-4)+:4]) begin
                        next_noc_req_state = S_NOC_REQ_TCU_REG_READ;
                    end

                    //access to mem
                    else begin
                        next_noc_req_state = S_NOC_REQ_MEM_READ;
                    end
                end

            end


            //---------------
            S_NOC_REQ_TCU_REG_READ: begin
                if (!reg_stall_i) begin
                    next_noc_req_state = S_NOC_REQ_TCU_REG_READ_VALID;
                end
            end

            //TCU reg data is available in next cycle
            S_NOC_REQ_TCU_REG_READ_VALID: begin
                rin_reg_retdata = reg_rdata_i;
                next_noc_req_state = S_NOC_REQ_FINISH;
            end


            //---------------
            S_NOC_REQ_MEM_READ: begin
                reqfifo_pop = 1'b1;
                next_noc_req_state = S_NOC_REQ_IDLE;
            end


            //---------------
            S_NOC_REQ_FINISH: begin
                //wait until NoC is free to send out packet
                if (!noc_stall_i) begin
                    reqfifo_pop = 1'b1;
                    next_noc_req_state = S_NOC_REQ_IDLE;
                end
            end

            default: next_noc_req_state = S_NOC_REQ_IDLE;

        endcase //case (noc_req_state)
    end


    assign reg_en_o = (noc_req_state == S_NOC_REQ_TCU_REG_READ);
    assign reg_retdata_o = r_reg_retdata;

    assign start_noc_send_o = (noc_req_state == S_NOC_REQ_MEM_READ);

    assign noc_req_done_o = (noc_req_state == S_NOC_REQ_FINISH) && !noc_stall_i;


endmodule
