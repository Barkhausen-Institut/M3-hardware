
module tcu_ctrl_mem_access_send #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_DRAM           = 0,
    parameter [31:0] TIMEOUT_SEND_CYCLES = 0
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //Mem IF
    output reg                     [1:0] mas_mem_en_o,
    output wire  [TCU_MEM_ADDR_SIZE-1:0] mas_mem_addr_o,
    output wire                          mas_mem_rdata_valid_o,
    input  wire                          mas_mem_rdata_avail_i,
    output wire  [TCU_MEM_DATA_SIZE-1:0] mas_mem_wdata_o,
    input  wire                          mas_mem_stall_i,

    input  wire                          noc_stall_i,
    output reg                           noc_wrreq_o,
    output reg                           noc_burst_o,
    output reg       [NOC_BSEL_SIZE-1:0] noc_bsel_o,
    output reg       [NOC_DATA_SIZE-1:0] noc_data0_o,
    output wire      [NOC_ADDR_SIZE-1:0] noc_addr_o,
    output reg       [NOC_MODE_SIZE-1:0] noc_mode_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_modid_o,
    input  wire                          noc_ack_recv_i,
    input  wire      [NOC_ADDR_SIZE-1:0] noc_ack_addr_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_ack_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_ack_modid_i,
    input  wire                   [31:0] noc_ack_size_i,    //number of bytes

    //---------------
    //triggers from tcu_ctrl
    input  wire                          mas_start_i,
    input  wire    [TCU_OPCODE_SIZE-1:0] mas_opcode_i,
    input  wire                   [31:0] mas_laddr_i,
    input  wire                   [31:0] mas_raddr_i,
    input  wire                   [31:0] mas_size_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] mas_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] mas_modid_i,
    input  wire                          mas_abort_i,
    output wire                          mas_active_o,
    output wire                          mas_noc_active_o,
    output wire                          mas_done_o,
    output wire     [TCU_ERROR_SIZE-1:0] mas_error_o
);

    `include "tcu_functions.v"


    localparam CTRL_MAS_STATES_SIZE     = 4;
    localparam S_CTRL_MAS_IDLE          = 4'h0;
    localparam S_CTRL_MAS_PREPARE_MEM1  = 4'h1;
    localparam S_CTRL_MAS_PREPARE_MEM2  = 4'h2;
    localparam S_CTRL_MAS_MEM_WRITE1    = 4'h3;
    localparam S_CTRL_MAS_MEM_WRITE2    = 4'h4;
    localparam S_CTRL_MAS_MEM_WRITE3    = 4'h5;
    localparam S_CTRL_MAS_REQ_ERROR     = 4'h6;
    localparam S_CTRL_MAS_ABORT         = 4'h7;
    localparam S_CTRL_MAS_WAIT_ACK      = 4'h8;
    localparam S_CTRL_MAS_FINISH        = 4'hF;

    reg [CTRL_MAS_STATES_SIZE-1:0] ctrl_mas_state, next_ctrl_mas_state;



    reg [TCU_OPCODE_SIZE-1:0] r_opcode, rin_opcode;
    reg                [31:0] r_laddr, rin_laddr;          //local addr
    reg                [31:0] r_size, rin_size;            //total size
    reg                [31:0] r_write_size, rin_write_size;//total size of writes, to be compared with ACKs
    reg                [15:0] r_tmp_size, rin_tmp_size;    //size for one burst
    reg                [31:0] r_raddr, rin_raddr;          //remote addr
    reg                [31:0] r_write_raddr, rin_write_raddr; //remote addr, to be compared with ACKs
    reg [NOC_CHIPID_SIZE-1:0] r_chipid, rin_chipid;
    reg  [NOC_MODID_SIZE-1:0] r_modid, rin_modid;

    reg r_stall;
    reg r_mas_mem_en;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_mas_error, rin_mas_error;

    //timeout
    reg [31:0] r_mas_timeout, rin_mas_timeout;

    //size of WRITE ACKs
    reg [31:0] r_ack_size, rin_ack_size;


    //end addr to check if data exceed 16-byte alignment
    wire [5:0] end_addr = r_laddr[3:0] + r_tmp_size[3:0];

    //read burst length (number of 16-byte packets)
    wire [12:0] burst_length = noc_data0_o;

    //address range of WRITE
    wire [31:0] write_addr_end = r_write_raddr + r_write_size;


    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_mas_state <= S_CTRL_MAS_IDLE;
            
            r_opcode <= {TCU_OPCODE_SIZE{1'b0}};
            r_laddr <= 32'h0;
            r_raddr <= 32'h0;
            r_write_raddr <= 32'h0;
            r_size <= 32'h0;
            r_write_size <= 32'h0;
            r_tmp_size <= 16'h0;
            r_chipid <= {NOC_CHIPID_SIZE{1'b0}};
            r_modid <= {NOC_MODID_SIZE{1'b0}};

            r_stall <= 1'b0;
            r_mas_mem_en <= 1'b0;

            r_mas_error <= TCU_ERROR_NONE;

            r_mas_timeout <= 32'h0;

            r_ack_size <= 32'h0;
        end
        else begin
            ctrl_mas_state <= next_ctrl_mas_state;
            
            r_opcode <= rin_opcode;
            r_laddr <= rin_laddr;
            r_raddr <= rin_raddr;
            r_write_raddr <= rin_write_raddr;
            r_size <= rin_size;
            r_write_size <= rin_write_size;
            r_tmp_size <= rin_tmp_size;
            r_chipid <= rin_chipid;
            r_modid <= rin_modid;

            r_stall <= noc_stall_i || mas_mem_stall_i;
            r_mas_mem_en <= mas_mem_en_o[0];

            r_mas_error <= rin_mas_error;

            r_mas_timeout <= rin_mas_timeout;

            r_ack_size <= rin_ack_size;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_mas_state = ctrl_mas_state;

        noc_wrreq_o = 1'b0;
        noc_burst_o = 1'b0;
        noc_bsel_o = {NOC_BSEL_SIZE{1'b0}};
        noc_data0_o = {NOC_DATA_SIZE{1'b0}};

        rin_opcode = r_opcode;
        rin_laddr = r_laddr;
        rin_size = r_size;
        rin_write_size = r_write_size;
        rin_tmp_size = r_tmp_size;
        rin_raddr = r_raddr;
        rin_write_raddr = r_write_raddr;
        rin_chipid = r_chipid;
        rin_modid = r_modid;

        rin_mas_error = r_mas_error;

        rin_mas_timeout = 32'h0;


        case (ctrl_mas_state)

            //---------------
            //wait for incoming commsnd
            S_CTRL_MAS_IDLE: begin
                if (mas_start_i) begin
                    rin_opcode = mas_opcode_i;
                    rin_laddr = mas_laddr_i;
                    rin_raddr = mas_raddr_i;
                    rin_write_raddr = mas_raddr_i;
                    rin_size = mas_size_i;
                    rin_write_size = mas_size_i;
                    rin_chipid = mas_chipid_i;
                    rin_modid = mas_modid_i;

                    //one additional burst packet if data is not aligned to 16 byte
                    if (mas_size_i[31:4] >= MAX_BURST_LENGTH) begin
                        if (mas_laddr_i[3:0] != 'd0) begin
                            rin_tmp_size = (MAX_BURST_LENGTH << 4) - mas_laddr_i[3:0];
                        end else begin
                            rin_tmp_size = MAX_BURST_LENGTH << 4;
                        end
                    end else begin
                        rin_tmp_size = mas_size_i;
                    end
                    
                    //read memory access type
                    if ((mas_opcode_i == TCU_OPCODE_WRITE) ||
                        (mas_opcode_i == TCU_OPCODE_WRITE_RSP) ||
                        (mas_opcode_i == TCU_OPCODE_WRITE_RSP_2)) begin

                        //extra stage only when DRAM is attached with undefined read delay
                        if (TCU_ENABLE_DRAM) begin
                            next_ctrl_mas_state = S_CTRL_MAS_PREPARE_MEM1;
                        end

                        //determine the number of packets and send burst or single flit
                        else if (mas_size_i > 'd8) begin
                            next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE2;
                        end else begin
                            next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE1;
                        end
                    end

                    else begin
                        next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                    end

                    rin_mas_error = TCU_ERROR_NONE;
                end
            end

            //---------------
            //send information about total size to preload it from memory
            S_CTRL_MAS_PREPARE_MEM1: begin
                if (!mas_mem_stall_i) begin
                    next_ctrl_mas_state = S_CTRL_MAS_PREPARE_MEM2;
                end
            end

            S_CTRL_MAS_PREPARE_MEM2: begin
                //check when prepared data becomes available
                if (mas_mem_rdata_avail_i) begin

                    //continue: determine the number of packets and send burst or single flit
                    if (r_size > 'd8) begin
                        next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE2;
                    end else begin
                        next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE1;
                    end
                end

                //timout
                else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                    rin_mas_timeout = r_mas_timeout + 32'd1;
                    if (r_mas_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_mas_error = TCU_ERROR_TIMEOUT_MEM;

                        //if response, this send was initiated by NoC request
                        //send error code to requester
                        if ((r_opcode == TCU_OPCODE_WRITE_RSP) || (r_opcode == TCU_OPCODE_WRITE_RSP_2)) begin
                            rin_opcode = TCU_OPCODE_WRITE_ERROR;
                            next_ctrl_mas_state = S_CTRL_MAS_REQ_ERROR;
                        end
                        else begin
                            next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                        end
                    end
                end
            end

            //---------------
            //read data from local mem and send it to the NoC
            S_CTRL_MAS_MEM_WRITE1: begin
                if (!mas_mem_stall_i && !noc_stall_i) begin
                    noc_bsel_o = set_bsel8(r_laddr[2:0], r_size[3:0]);

                    //less or equal than 8 bytes but across 8-byte alignment -> 2 packets
                    if ((r_laddr[2:0] + r_size[3:0]) > 4'h8) begin
                        rin_laddr = {(r_laddr[31:3]+'h1), 3'h0};   //start at 8-byte alignment again
                        rin_size = r_size - (4'h8 - r_laddr[2:0]);
                        rin_raddr = r_raddr + (4'h8 - r_laddr[2:0]);

                        next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE1;
                    end

                    //only single packet
                    else begin
                        rin_tmp_size = 'd0;
                        //wait for ACK if it is a WRITE
                        if (r_opcode == TCU_OPCODE_WRITE) begin
                            next_ctrl_mas_state = S_CTRL_MAS_WAIT_ACK;
                        end else begin
                            next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                        end
                    end
                end

                //timout
                else if (mas_mem_stall_i && (TIMEOUT_SEND_CYCLES != 32'h0)) begin
                    rin_mas_timeout = r_mas_timeout + 32'd1;
                    if (r_mas_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_mas_error = TCU_ERROR_TIMEOUT_MEM;

                        //if response, this send was initiated by NoC request
                        //send error code to requester
                        if ((r_opcode == TCU_OPCODE_WRITE_RSP) || (r_opcode == TCU_OPCODE_WRITE_RSP_2)) begin
                            rin_opcode = TCU_OPCODE_WRITE_ERROR;
                            next_ctrl_mas_state = S_CTRL_MAS_REQ_ERROR;
                        end
                        else begin
                            next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                        end
                    end
                end
            end

            S_CTRL_MAS_MEM_WRITE2: begin
                //first check abort cmd condition
                if (mas_abort_i) begin
                    rin_mas_error = TCU_ERROR_ABORT;
                    next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                end
                else if (!mas_mem_stall_i && !noc_stall_i) begin
                    rin_size = r_size - r_tmp_size;

                    //long payload, need burst
                    if (r_tmp_size > 'd8) begin

                        //prepare NoC header packet
                        noc_wrreq_o = 1'b1;
                        noc_burst_o = 1'b1;

                        //only when there are not multiple bursts or for the last burst
                        if (r_size[31:4] < MAX_BURST_LENGTH) begin
                            noc_bsel_o = {(((r_laddr[3:0]+r_tmp_size[3:0]) & 4'hF) - 'b1), ~r_laddr[3:0]};   //indicate addr of first and last valid byte: ((addr[3:0]+tmp_size[3:0]) mod 16) - 1

                            //burst length: number of 16-byte packets
                            //+1 if size or addr is not 16-byte aligned
                            //+1 if end addr exceeds 16-byte alignment
                            noc_data0_o = r_tmp_size[15:4] + ((end_addr != 5'd0) ? 1 : 0) + ((end_addr > 5'd16) ? 1 : 0);
                        end
                        else begin
                            noc_bsel_o = {{(NOC_BSEL_SIZE/2){1'b1}}, ~r_laddr[3:0]};
                            noc_data0_o = MAX_BURST_LENGTH;    //burst length: number of 16 byte packets
                        end

                        rin_laddr = r_laddr + 'd16;
                        rin_raddr = r_raddr + (5'd16 - r_laddr[3:0]);

                        //if there is only one flit in burst, clear tmp_size
                        if (burst_length == 'd1) begin
                            rin_tmp_size = 'd0;
                        end else begin
                            rin_tmp_size = r_tmp_size - (5'd16 - r_laddr[3:0]);
                        end

                        next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE3;
                    end

                    //when multiple bursts are necessary, but last burst has less than 8 bytes (i.e. no burst)
                    else begin
                        rin_tmp_size = 'd0;
                        noc_burst_o = 1'b0;
                        noc_bsel_o = set_bsel8(r_laddr[2:0], r_tmp_size[3:0]);

                        //wait for ACK if it is a WRITE
                        if (r_opcode == TCU_OPCODE_WRITE) begin
                            next_ctrl_mas_state = S_CTRL_MAS_WAIT_ACK;
                        end else begin
                            next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                        end
                    end
                end

                //timout
                else if (mas_mem_stall_i && (TIMEOUT_SEND_CYCLES != 32'h0)) begin
                    rin_mas_timeout = r_mas_timeout + 32'd1;
                    if (r_mas_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_mas_error = TCU_ERROR_TIMEOUT_MEM;
                        
                        //if response, this send was initiated by NoC request
                        //send error code to requester
                        if ((r_opcode == TCU_OPCODE_WRITE_RSP) || (r_opcode == TCU_OPCODE_WRITE_RSP_2)) begin
                            rin_opcode = TCU_OPCODE_WRITE_ERROR;
                            next_ctrl_mas_state = S_CTRL_MAS_REQ_ERROR;
                        end
                        else begin
                            next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                        end
                    end
                end
            end

            S_CTRL_MAS_MEM_WRITE3: begin
                if (!noc_stall_i) begin
                    //hold burst and bsel during stall
                    if (mas_mem_stall_i && (r_tmp_size > 'd0)) begin
                        noc_burst_o = 1'b1;
                        noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};
                        next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE3;

                        //check abort cmd condition
                        if (mas_abort_i) begin
                            noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                            rin_mas_error = TCU_ERROR_ABORT;
                            next_ctrl_mas_state = S_CTRL_MAS_ABORT;
                        end

                        //timeout
                        else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                            rin_mas_timeout = r_mas_timeout + 32'd1;
                            if (r_mas_timeout > TIMEOUT_SEND_CYCLES) begin
                                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                                rin_mas_error = TCU_ERROR_TIMEOUT_MEM;
                                next_ctrl_mas_state = S_CTRL_MAS_ABORT;
                            end
                        end
                    end
                    else begin
                        noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};

                        //continue burst
                        if (r_tmp_size > 'd0) begin
                            
                            rin_laddr = r_laddr + 'd16;
                            rin_tmp_size  = (r_tmp_size > 'd16) ? (r_tmp_size - 'd16) : 'd0;
                            rin_raddr = r_raddr + 'd16;

                            noc_burst_o = 1'b1;

                            //check abort cmd condition
                            if (mas_abort_i) begin
                                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}}; //abort send, deassert bsel
                                rin_mas_error = TCU_ERROR_ABORT;
                                next_ctrl_mas_state = S_CTRL_MAS_ABORT;
                            end
                            else begin
                                next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE3;
                            end
                        end

                        //stop burst
                        else begin
                            noc_burst_o = 1'b0;
                        
                            //go back and send next burst
                            if (r_size > 'h0) begin
                                rin_laddr = {r_laddr[31:4], 4'h0};   //go on with aligned memory access

                                if (r_size[31:4] < MAX_BURST_LENGTH) begin
                                    rin_tmp_size = r_size[15:0]; 
                                end else begin
                                    rin_tmp_size = MAX_BURST_LENGTH << 4;
                                end

                                next_ctrl_mas_state = S_CTRL_MAS_MEM_WRITE2;
                            end

                            //finish: wait for ACK if it is a WRITE
                            else if (r_opcode == TCU_OPCODE_WRITE) begin
                                next_ctrl_mas_state = S_CTRL_MAS_WAIT_ACK;
                            end else begin
                                next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                            end
                        end
                    end
                end
            end


            //---------------
            //send error code to original requester
            S_CTRL_MAS_REQ_ERROR: begin
                if (!noc_stall_i) begin
                    noc_wrreq_o = 1'b1;
                    noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};
                    noc_data0_o = r_mas_error;

                    next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                end
            end


            //---------------
            //abort send cmd, still send flits of remaining burst but deassert bsel
            S_CTRL_MAS_ABORT: begin
                noc_bsel_o = {NOC_BSEL_SIZE{1'b0}};
                
                if (!noc_stall_i) begin
                    noc_wrreq_o = 1'b1;

                    if (r_tmp_size > 'd16) begin
                        rin_tmp_size = r_tmp_size - 'd16;
                        noc_burst_o = 1'b1;
                    end

                    //stop burst
                    else begin
                        rin_size = 'd0;
                        rin_tmp_size = 'd0;
                        noc_burst_o = 1'b0;
                        next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                    end
                end
            end


            //---------------
            //wait until all ACKs from WRITE have been received
            S_CTRL_MAS_WAIT_ACK: begin
                //WRITE to TCU regfile returns no ACK, do not wait in this case
                if ((r_write_raddr >= TCU_REGADDR_START) || (r_ack_size >= r_write_size)) begin
                    next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                end

                //timeout
                else if (TIMEOUT_SEND_CYCLES != 32'h0) begin
                    rin_mas_timeout = r_mas_timeout + 32'd1;
                    if (r_mas_timeout > TIMEOUT_SEND_CYCLES) begin
                        rin_mas_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_mas_state = S_CTRL_MAS_FINISH;
                    end
                end
            end

            //---------------
            S_CTRL_MAS_FINISH: begin
                //wait until NoC does not stall anymore, so that last packet can be properly send
                if (!noc_stall_i) begin
                    next_ctrl_mas_state = S_CTRL_MAS_IDLE;
                end
            end

            default: next_ctrl_mas_state = S_CTRL_MAS_IDLE;

        endcase //case (ctrl_mas_state)
    end


    //---------------
    //accumulate ACK info
    always @* begin
        rin_ack_size = r_ack_size;

        //only when write is ongoing
        if (mas_active_o && (r_opcode == TCU_OPCODE_WRITE)) begin
            if (noc_ack_recv_i &&
                (noc_ack_chipid_i == r_chipid) &&
                (noc_ack_modid_i == r_modid) &&
                (noc_ack_addr_i >= r_write_raddr) && (noc_ack_addr_i < write_addr_end)) begin
                rin_ack_size = r_ack_size + noc_ack_size_i;
            end
        end
        else begin
            rin_ack_size = 32'h0;
        end
    end


    //---------------
    //memory interface
    always @* begin
        mas_mem_en_o = 2'b00;

        if (ctrl_mas_state == S_CTRL_MAS_PREPARE_MEM1) begin
            mas_mem_en_o = 2'b10;
        end
        if ((ctrl_mas_state == S_CTRL_MAS_MEM_WRITE1) ||
            (ctrl_mas_state == S_CTRL_MAS_MEM_WRITE2) ||
            ((ctrl_mas_state == S_CTRL_MAS_MEM_WRITE3) && (r_tmp_size > 'd0))) begin    //do not enable mem during burst when last packet of burst
            mas_mem_en_o = 2'b01;
        end
    end


    assign mas_mem_addr_o = r_laddr;
    assign mas_mem_rdata_valid_o = r_mas_mem_en && !r_stall;
    assign mas_mem_wdata_o = r_size;

    assign mas_error_o = r_mas_error;
    assign mas_active_o = (ctrl_mas_state != S_CTRL_MAS_IDLE);
    assign mas_noc_active_o = mas_active_o && (ctrl_mas_state < S_CTRL_MAS_WAIT_ACK);
    assign mas_done_o = (ctrl_mas_state == S_CTRL_MAS_FINISH) && !noc_stall_i;

    assign noc_addr_o = r_raddr;
    assign noc_chipid_o = r_chipid;
    assign noc_modid_o = r_modid;
    
    
    //set mode according to opcode
    always @* begin
        case (r_opcode)
            TCU_OPCODE_WRITE:       noc_mode_o = MODE_WRITE_POSTED;
            TCU_OPCODE_WRITE_RSP:   noc_mode_o = MODE_READ_RSP;
            TCU_OPCODE_WRITE_RSP_2: noc_mode_o = MODE_READ_RSP_2;
            TCU_OPCODE_WRITE_ERROR: noc_mode_o = MODE_ERROR;
            default:                noc_mode_o = MODE_WRITE_POSTED;
        endcase
    end

    
endmodule
