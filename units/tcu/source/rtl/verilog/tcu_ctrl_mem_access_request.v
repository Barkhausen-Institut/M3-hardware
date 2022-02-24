
module tcu_ctrl_mem_access_request #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter [31:0] TIMEOUT_SEND_CYCLES = 0
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    input  wire                          noc_stall_i,
    output reg                           noc_wrreq_o,
    output reg       [NOC_DATA_SIZE-1:0] noc_data0_o,
    output wire      [NOC_ADDR_SIZE-1:0] noc_addr_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_modid_o,
    input  wire                          noc_rsp_recv_i,
    input  wire     [TCU_ERROR_SIZE-1:0] noc_rsp_error_i,
    input  wire                   [31:0] noc_rsp_size_i,    //number of bytes
    
    //---------------
    //triggers from tcu_ctrl
    input  wire                          marq_start_i,
    input  wire    [TCU_OPCODE_SIZE-1:0] marq_opcode_i,
    input  wire                   [31:0] marq_laddr_i,
    input  wire                   [31:0] marq_raddr_i,
    input  wire                   [31:0] marq_size_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] marq_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] marq_modid_i,
    input  wire                          marq_abort_i,
    output wire                          marq_read_wait_o,
    output wire                          marq_active_o,
    output wire                          marq_noc_active_o,
    output wire                          marq_done_o,
    output wire     [TCU_ERROR_SIZE-1:0] marq_error_o
);

    localparam CTRL_MARQ_STATES_SIZE = 2;
    localparam S_CTRL_MARQ_IDLE      = 2'h0;
    localparam S_CTRL_MARQ_SEND_REQ  = 2'h1;
    localparam S_CTRL_MARQ_WAIT      = 2'h2;
    localparam S_CTRL_MARQ_FINISH    = 2'h3;

    reg [CTRL_MARQ_STATES_SIZE-1:0] ctrl_marq_state, next_ctrl_marq_state;



    reg                [31:0] r_laddr, rin_laddr;          //local addr
    reg                [31:0] r_size, rin_size;            //total size
    reg                [31:0] r_raddr, rin_raddr;          //remote addr
    reg [NOC_CHIPID_SIZE-1:0] r_chipid, rin_chipid;
    reg  [NOC_MODID_SIZE-1:0] r_modid, rin_modid;

    //response size in number of packets
    reg [31:0] r_rsp_size, rin_rsp_size;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_marq_error, rin_marq_error;

    //timeout to prevent hanging
    reg [31:0] r_marq_timeout, rin_marq_timeout;


    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_marq_state <= S_CTRL_MARQ_IDLE;
            
            r_laddr    <= 32'h0;
            r_raddr    <= 32'h0;
            r_size     <= 32'h0;
            r_chipid   <= {NOC_CHIPID_SIZE{1'b0}};
            r_modid    <= {NOC_MODID_SIZE{1'b0}};

            r_rsp_size <= 32'h0;
            r_marq_error <= {TCU_ERROR_SIZE{1'b0}};
            r_marq_timeout <= 32'h0;
        end
        else begin
            ctrl_marq_state <= next_ctrl_marq_state;
            
            r_laddr    <= rin_laddr;
            r_raddr    <= rin_raddr;
            r_size     <= rin_size;
            r_chipid   <= rin_chipid;
            r_modid    <= rin_modid;

            r_rsp_size <= rin_rsp_size;
            r_marq_error <= rin_marq_error;
            r_marq_timeout <= rin_marq_timeout;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_marq_state = ctrl_marq_state;

        rin_rsp_size = r_rsp_size;
        rin_marq_error = r_marq_error;
        rin_marq_timeout = 32'h0;

        noc_wrreq_o = 1'b0;
        noc_data0_o = {NOC_DATA_SIZE{1'b0}};

        rin_laddr = r_laddr;
        rin_size = r_size;
        rin_raddr = r_raddr;
        rin_chipid = r_chipid;
        rin_modid = r_modid;


        case (ctrl_marq_state)

            //---------------
            //wait for incoming commsnd
            S_CTRL_MARQ_IDLE: begin
                if (marq_start_i && (marq_opcode_i == TCU_OPCODE_READ)) begin
                    rin_rsp_size = 'h0;
                    rin_marq_error = TCU_ERROR_NONE;
                    
                    rin_laddr  = marq_laddr_i;
                    rin_raddr  = marq_raddr_i;
                    rin_size   = marq_size_i;
                    rin_chipid = marq_chipid_i;
                    rin_modid  = marq_modid_i;

                    next_ctrl_marq_state = S_CTRL_MARQ_SEND_REQ;
                end
            end

            //---------------
            //TCU cmd: read data from ep mem and write it to local mem
            //only send read req packet here
            S_CTRL_MARQ_SEND_REQ: begin
                //again check abort condition before sending request
                if (marq_abort_i) begin
                    rin_marq_error = TCU_ERROR_ABORT;
                    next_ctrl_marq_state = S_CTRL_MARQ_FINISH;
                end
                else begin
                    noc_wrreq_o = 1'b1;
                    noc_data0_o = {r_size, r_laddr};  //read req packet has burst length in number of bytes

                    if (!noc_stall_i) begin
                        //wait for response: while waiting NoC FSM can take incoming packets, but cannot send new packets
                        next_ctrl_marq_state = S_CTRL_MARQ_WAIT;
                    end
                end
            end

            //---------------
            //wait for incoming NoC packet (read-rsp)
            S_CTRL_MARQ_WAIT: begin
                //correct rsp received
                if (noc_rsp_recv_i) begin
                    //check if there was an error
                    if (noc_rsp_error_i == TCU_ERROR_NONE) begin
                        rin_rsp_size = r_rsp_size + noc_rsp_size_i;

                        //check if this is all we need (take value just calculated)
                        if (rin_rsp_size >= r_size) begin
                            next_ctrl_marq_state = S_CTRL_MARQ_FINISH;
                        end
                    end
                    else begin
                        rin_marq_error = noc_rsp_error_i;
                        next_ctrl_marq_state = S_CTRL_MARQ_FINISH;
                    end
                end

                //waiting
                else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                    rin_marq_timeout = r_marq_timeout + 32'd1;
                    if (r_marq_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_marq_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_marq_state = S_CTRL_MARQ_FINISH;
                    end
                end
            end

            //---------------
            S_CTRL_MARQ_FINISH: begin
                next_ctrl_marq_state = S_CTRL_MARQ_IDLE;
            end

        endcase //case (ctrl_marq_state)
    end




    assign marq_read_wait_o = (ctrl_marq_state == S_CTRL_MARQ_WAIT);
    assign marq_active_o = (ctrl_marq_state != S_CTRL_MARQ_IDLE);
    assign marq_noc_active_o = marq_active_o && (ctrl_marq_state < S_CTRL_MARQ_WAIT);
    assign marq_done_o = (ctrl_marq_state == S_CTRL_MARQ_FINISH);
    assign marq_error_o = r_marq_error;

    assign noc_addr_o = r_raddr;
    assign noc_chipid_o = r_chipid;
    assign noc_modid_o = r_modid;
    

endmodule
