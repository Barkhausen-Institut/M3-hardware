
module tcu_ctrl_mem_access_recv #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_DRAM           = 0,
    parameter [31:0] TIMEOUT_RECV_CYCLES = 0
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //Mem IF
    output wire                    [2:0] mar_mem_en_o,
    output wire  [TCU_MEM_BSEL_SIZE-1:0] mar_mem_wben_o,
    output wire  [TCU_MEM_ADDR_SIZE-1:0] mar_mem_addr_o,
    output wire  [TCU_MEM_DATA_SIZE-1:0] mar_mem_wdata_o,
    input  wire                          mar_mem_wdata_infifo_i,
    output reg                           mar_mem_wabort_o,
    input  wire                          mar_mem_stall_i,

    //---------------
    //signals to activate NoC
    output reg                           noc_fifo_pop_o,
    input  wire                          noc_wrreq_i,
    input  wire                          noc_burst_i,
    input  wire      [NOC_BSEL_SIZE-1:0] noc_bsel_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_modid_i,
    input  wire      [NOC_ADDR_SIZE-1:0] noc_addr_i,
    input  wire      [NOC_MODE_SIZE-1:0] noc_mode_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_data0_i,
    input  wire                          noc_stall_i,
    output wire                          noc_wrreq_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_modid_o,
    output wire      [NOC_ADDR_SIZE-1:0] noc_addr_o,
    output wire                   [31:0] noc_data_o,

    //---------------
    //triggers from tcu_ctrl
    input  wire                          mar_start_i,
    input  wire                          mar_abort_i,
    output wire                          mar_active_o,
    output reg                           mar_done_o,
    output wire     [TCU_ERROR_SIZE-1:0] mar_error_o,
    output wire                    [3:0] mar_shift_o
);

    `include "tcu_functions.v"

    localparam DELAY_SIZE = 2;

    localparam CTRL_MAR_STATES_SIZE        = 4;
    localparam S_CTRL_MAR_IDLE             = 4'h0;
    localparam S_CTRL_MAR_PACKET_CHECK     = 4'h1;
    localparam S_CTRL_MAR_PREPARE_MEM      = 4'h2;
    localparam S_CTRL_MAR_MEM_WRITE1       = 4'h3;
    localparam S_CTRL_MAR_MEM_WRITE1_SPLIT = 4'h4;
    localparam S_CTRL_MAR_MEM_WRITE2       = 4'h5;
    localparam S_CTRL_MAR_MEM_WRITE3       = 4'h6;
    localparam S_CTRL_MAR_MEM_WRITE4       = 4'h7;
    localparam S_CTRL_MAR_WAIT_DRAM        = 4'h8;
    localparam S_CTRL_MAR_ERROR            = 4'h9;
    localparam S_CTRL_MAR_FINISH           = 4'hF;

    reg [CTRL_MAR_STATES_SIZE-1:0] ctrl_mar_state, next_ctrl_mar_state;



    reg [31:0] r_laddr, rin_laddr;              //local addr
    reg [15:0] r_size, rin_size;                //size of incoming burst (bytes)
    reg  [3:0] r_start_shift, rin_start_shift;  //bsel from NoC header: number of valid bytes in first burst flit
    reg  [4:0] r_end_shift, rin_end_shift;      //bsel from NoC header: number of valid bytes in last burst flit
    reg  [3:0] r_shift, rin_shift;              //data shift for mem mux in tcu_ctrl

    //hold information for WRITE ACK
    reg                       r_mode_write_posted, rin_mode_write_posted;
    reg [NOC_CHIPID_SIZE-1:0] r_ack_chipid, rin_ack_chipid;
    reg  [NOC_MODID_SIZE-1:0] r_ack_modid, rin_ack_modid;
    reg   [NOC_ADDR_SIZE-1:0] r_ack_addr, rin_ack_addr;
    reg                [31:0] r_ack_size, rin_ack_size;

    reg                   [2:0] r_mem_en, rin_mem_en;
    reg [TCU_MEM_BSEL_SIZE-1:0] r_mem_wben, rin_mem_wben;
    reg [TCU_MEM_ADDR_SIZE-1:0] r_mem_addr;

    reg [TCU_MEM_BSEL_SIZE-1:0] r_wben, rin_wben;
    reg                         r2_wben_msb, rin2_wben_msb;

    reg [12:0] r_burst_length, rin_burst_length;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_mar_error, rin_mar_error;

    //timeout
    reg [31:0] r_mar_timeout, rin_mar_timeout;

    //some delay
    reg [DELAY_SIZE-1:0] r_dram_delay, rin_dram_delay;


    wire  [3:0] start_shift  = ~noc_bsel_i[3:0];
    wire  [4:0] end_shift    = noc_bsel_i[7:4] + 5'd1;
    wire [12:0] burst_length = noc_data0_i[12:0];   //number of 16-byte packets

    wire  [3:0] bsel_count_ones = count_ones8(noc_bsel_i);
    wire  [4:0] wben_count_ones = count_ones8(r_wben[7:0]) + count_ones8(r_wben[15:8]);

    wire  [2:0] bsel_firstone = get_firstone8(noc_bsel_i);



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_mar_state <= S_CTRL_MAR_IDLE;
            
            r_laddr <= 32'h0;
            r_size <= 16'h0;
            r_start_shift <= 4'h0;
            r_end_shift <= 5'h0;
            r_shift <= 4'h0;

            r_mode_write_posted <= 1'b0;
            r_ack_chipid <= {NOC_CHIPID_SIZE{1'b0}};
            r_ack_modid <= {NOC_MODID_SIZE{1'b0}};
            r_ack_addr <= {NOC_ADDR_SIZE{1'b0}};
            r_ack_size <= 32'h0;

            r_mem_en <= 3'h0;
            r_mem_wben <= {TCU_MEM_BSEL_SIZE{1'b0}};
            r_mem_addr <= {TCU_MEM_ADDR_SIZE{1'b0}};

            r_wben <= {TCU_MEM_BSEL_SIZE{1'b0}};
            r2_wben_msb <= 1'b0;

            r_burst_length <= 13'h0;

            r_mar_error <= TCU_ERROR_NONE;
            r_dram_delay <= {DELAY_SIZE{1'b1}};

            r_mar_timeout <= 32'h0;
        end
        else begin
            ctrl_mar_state <= next_ctrl_mar_state;
            
            r_laddr <= rin_laddr;
            r_size <= rin_size;
            r_start_shift <= rin_start_shift;
            r_end_shift <= rin_end_shift;
            r_shift <= rin_shift;

            r_mode_write_posted <= rin_mode_write_posted;
            r_ack_chipid <= rin_ack_chipid;
            r_ack_modid <= rin_ack_modid;
            r_ack_addr <= rin_ack_addr;
            r_ack_size <= rin_ack_size;

            r_mem_en <= rin_mem_en;
            r_mem_wben <= rin_mem_wben;
            r_mem_addr <= r_laddr;

            r_wben <= rin_wben;
            r2_wben_msb <= rin2_wben_msb;

            r_burst_length <= rin_burst_length;

            r_mar_error <= rin_mar_error;
            r_dram_delay <= rin_dram_delay;

            r_mar_timeout <= rin_mar_timeout;
        end
    end




    //---------------
    //state machine
    always @* begin
        next_ctrl_mar_state = ctrl_mar_state;

        rin_laddr = r_laddr;
        rin_size = r_size;
        rin_start_shift = r_start_shift;
        rin_end_shift = r_end_shift;

        rin_mode_write_posted = r_mode_write_posted;
        rin_ack_chipid = r_ack_chipid;
        rin_ack_modid = r_ack_modid;
        rin_ack_addr = r_ack_addr;
        rin_ack_size = r_ack_size;

        rin_wben = r_wben;
        rin2_wben_msb = r2_wben_msb;

        rin_burst_length = r_burst_length;

        noc_fifo_pop_o = 1'b0;

        rin_mar_error = r_mar_error;
        mar_done_o = 1'b0;

        rin_mar_timeout = 32'h0;
        rin_dram_delay = {DELAY_SIZE{1'b1}};

        mar_mem_wabort_o = 1'b0;


        case (ctrl_mar_state)

            //---------------
            //wait for incoming command
            S_CTRL_MAR_IDLE: begin
                if (mar_start_i) begin
                    //set info for WRITE ACK
                    rin_mode_write_posted = (noc_mode_i == MODE_WRITE_POSTED);
                    rin_ack_chipid = noc_chipid_i;
                    rin_ack_modid = noc_modid_i;
                    rin_ack_addr = noc_addr_i;
                    if (noc_burst_i) begin
                        rin_size = {burst_length, 4'h0} - start_shift - (5'd16 - end_shift);
                        rin_ack_size = {burst_length, 4'h0} - start_shift - (5'd16 - end_shift);
                    end else begin
                        rin_size = bsel_count_ones;
                        rin_ack_size = bsel_count_ones;
                    end

                    //check abort condition
                    if (mar_abort_i) begin
                        rin_mar_error = TCU_ERROR_ABORT;
                        next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                    end
                    else begin
                        rin_laddr = noc_addr_i;

                        rin_mar_error = TCU_ERROR_NONE;
                        next_ctrl_mar_state = S_CTRL_MAR_PACKET_CHECK;
                    end
                end
            end

            
            //---------------
            //do not take packets from msg passing
            S_CTRL_MAR_PACKET_CHECK: begin
                //first check abort condition
                if (mar_abort_i) begin
                    rin_mar_error = TCU_ERROR_ABORT;
                    next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                end
                else if (noc_wrreq_i &&
                        ((noc_mode_i == MODE_WRITE_POSTED) || (noc_mode_i == MODE_READ_RSP) ||
                        (noc_mode_i == MODE_WRITE_POSTED_2) || (noc_mode_i == MODE_READ_RSP_2))) begin

                    //send size info to mem, if a lot of data is expected
                    if (TCU_ENABLE_DRAM && noc_burst_i && (burst_length > 'd1)) begin
                        next_ctrl_mar_state = S_CTRL_MAR_PREPARE_MEM;
                    end

                    //only little data, do not prepare mem
                    else begin
                        next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE1;
                    end
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_mar_timeout = r_mar_timeout + 32'd1;
                    if (r_mar_timeout > TIMEOUT_RECV_CYCLES) begin
                        rin_mar_error = TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                    end
                end
            end

            //if it is a burst, also use burst interface to memory
            S_CTRL_MAR_PREPARE_MEM: begin
                if (!mar_mem_stall_i) begin
                    next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE1;
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_mar_timeout = r_mar_timeout + 32'd1;
                    if (r_mar_timeout > TIMEOUT_RECV_CYCLES) begin
                        rin_mar_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                    end
                end
            end


            //---------------
            //read data from NoC and write it to local mem
            S_CTRL_MAR_MEM_WRITE1: begin
                if (noc_wrreq_i) begin
                    if (!mar_mem_stall_i) begin
                        //if burst, only release header packet and read bsel info
                        if (noc_burst_i) begin
                            noc_fifo_pop_o = 1'b1;

                            rin_start_shift = start_shift;    //right shift for data
                            rin_end_shift = end_shift;

                            rin_wben = ({TCU_MEM_BSEL_SIZE{1'b1}} >> start_shift) << r_laddr[3:0];
                            rin2_wben_msb = r_wben[TCU_MEM_BSEL_SIZE-1];

                            rin_burst_length = burst_length;

                            //if there is only one flit in burst, skip next stage
                            if (burst_length == 'd1) begin
                                next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE3;
                            end else begin
                                next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE2;
                            end
                        end

                        //no burst, write single bytes to memory
                        else begin
                            //check if two memory writes are necessary due to bad recv addr alignment
                            //if so, do not pop FIFO yet
                            if ((5'd16 - r_laddr[3:0]) < bsel_count_ones) begin
                                rin_laddr = {(r_laddr[31:4]+'d1), 4'h0}; //increment to full next 16 bytes
                                rin_size = r_size - (5'd16 - r_laddr[3:0]);
                                next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE1_SPLIT;
                            end
                            else begin
                                noc_fifo_pop_o = 1'b1;
                                rin_size = 'd0;
                                if (TCU_ENABLE_DRAM) begin
                                    next_ctrl_mar_state = S_CTRL_MAR_WAIT_DRAM;
                                end
                                else begin
                                    next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                                end
                            end
                        end
                    end

                    //timeout
                    else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                        rin_mar_timeout = r_mar_timeout + 32'd1;
                        if (r_mar_timeout > TIMEOUT_RECV_CYCLES) begin
                            rin_mar_error = TCU_ERROR_TIMEOUT_MEM;
                            next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                        end
                    end
                end
            end

            //single packet but two memory writes
            S_CTRL_MAR_MEM_WRITE1_SPLIT: begin
                if (!mar_mem_stall_i) begin
                    noc_fifo_pop_o = 1'b1;
                    rin_size = 'd0;
                    if (TCU_ENABLE_DRAM) begin
                        next_ctrl_mar_state = S_CTRL_MAR_WAIT_DRAM;
                    end
                    else begin
                        next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                    end
                end
            end

            //handle next coming flits in burst packet
            S_CTRL_MAR_MEM_WRITE2: begin
                if (noc_wrreq_i && !mar_mem_stall_i) begin
                    noc_fifo_pop_o = 1'b1;

                    //first check abort condition
                    if (mar_abort_i) begin
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = TCU_ERROR_ABORT;
                        next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                    end

                    //also abort receive if bsel is zero
                    else if (noc_bsel_i == {NOC_BSEL_SIZE{1'b0}}) begin
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = TCU_ERROR_ABORT;
                        next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                    end
                    else begin
                        rin_laddr = r_laddr + (5'd16 - r_start_shift);

                        //check if this memory row is already full
                        if (r_start_shift > r_laddr[3:0]) begin
                            rin_size = r_size - (5'd16 - r_start_shift);    //memory row not full, not enough elements in current packet
                            rin_wben = ~r_wben & ({TCU_MEM_BSEL_SIZE{1'b1}} << r_laddr[3:0]);
                            rin2_wben_msb = r_wben[TCU_MEM_BSEL_SIZE-1];
                        end
                        else begin
                            rin_size = r_size - (5'd16 - r_laddr[3:0]);     //memory row full, only write elements which still fit
                            rin_wben = {TCU_MEM_BSEL_SIZE{1'b1}};
                            rin2_wben_msb = r_wben[TCU_MEM_BSEL_SIZE-1];
                        end

                        //if this is already the end of burst, skip next stage
                        if (noc_burst_i) begin
                            next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE3;
                        end
                        else if (TCU_ENABLE_DRAM) begin
                            next_ctrl_mar_state = S_CTRL_MAR_WAIT_DRAM;
                        end
                        else begin
                            next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                        end
                    end
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_mar_timeout = r_mar_timeout + 32'd1;
                    if (r_mar_timeout > TIMEOUT_RECV_CYCLES) begin
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = noc_wrreq_i ? TCU_ERROR_TIMEOUT_MEM : TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                    end
                end
            end

            //during burst
            S_CTRL_MAR_MEM_WRITE3: begin
                if (noc_wrreq_i && !mar_mem_stall_i) begin
                    noc_fifo_pop_o = 1'b1;

                    //first check abort condition
                    if (mar_abort_i) begin
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = TCU_ERROR_ABORT;
                        next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                    end

                    //also abort receive if bsel is zero
                    else if (noc_bsel_i == {NOC_BSEL_SIZE{1'b0}}) begin
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = TCU_ERROR_ABORT;
                        next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                    end
                    else begin
                        //still a burst? -> it is not last flit
                        if (noc_burst_i) begin
                            rin_wben = {TCU_MEM_BSEL_SIZE{1'b1}};
                            rin2_wben_msb = r_wben[TCU_MEM_BSEL_SIZE-1];
                            rin_laddr = r_laddr + 'd16;
                            rin_size = r_size - wben_count_ones;    //we only store the number of bytes given by last bsel

                            //cancel recv even when burst is ongoing but no more packets are expected
                            if (r_size > 'd16) begin
                                noc_fifo_pop_o = 1'b1;
                                next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE3;
                            end
                            else begin
                                rin_mar_error = TCU_ERROR_CRITICAL;
                                next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                            end
                        end

                        //burst ends
                        else begin

                            //check if additional store is required
                            if (r_size > 'd16) begin
                                rin_wben = ({TCU_MEM_BSEL_SIZE{1'b1}} >> (5'd16 - r_size[3:0]));
                                rin2_wben_msb = r_wben[TCU_MEM_BSEL_SIZE-1];

                                rin_size = r_size - 'd16;
                                rin_laddr = r_laddr + 'd16;
                                next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE4;
                            end

                            //when there are more stores required
                            else if (((r_size + r_laddr[3:0]) > 'd16) && ((r_end_shift + r_laddr[3:0]) > 'd16)) begin
                                rin_wben = {TCU_MEM_BSEL_SIZE{1'b1}} >> (6'd32 - r_size - r_laddr[3:0]);    //16-new_r_size
                                rin2_wben_msb = r_wben[TCU_MEM_BSEL_SIZE-1];
                                rin_laddr = r_laddr + 'd16;
                                rin_size = r_size - (5'd16 - r_laddr[3:0]);
                                next_ctrl_mar_state = S_CTRL_MAR_MEM_WRITE4;
                            end

                            //done, continue
                            else begin
                                rin_size = 'd0;

                                if (TCU_ENABLE_DRAM) begin
                                    next_ctrl_mar_state = S_CTRL_MAR_WAIT_DRAM;
                                end else begin
                                    next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                                end
                            end
                        end
                    end
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_mar_timeout = r_mar_timeout + 32'd1;
                    if (r_mar_timeout > TIMEOUT_RECV_CYCLES) begin
                        rin_mar_timeout = 32'h0; //init timeout to start new timer in FINISH state if necessary
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = noc_wrreq_i ? TCU_ERROR_TIMEOUT_MEM : TCU_ERROR_TIMEOUT_NOC;
                        next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                    end
                end
            end

            //write last part of last flit to memory
            S_CTRL_MAR_MEM_WRITE4: begin
                if (!mar_mem_stall_i) begin
                    rin_size = 'd0;
                    if (TCU_ENABLE_DRAM) begin
                        next_ctrl_mar_state = S_CTRL_MAR_WAIT_DRAM;
                    end else begin
                        next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                    end
                end

                //timeout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_mar_timeout = r_mar_timeout + 32'd1;
                    if (r_mar_timeout > TIMEOUT_RECV_CYCLES) begin
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                    end
                end
            end

            //---------------
            S_CTRL_MAR_WAIT_DRAM: begin
                //additionally wait a few cycles until write data has arrived in bridge to DRAM-like interface
                rin_dram_delay = r_dram_delay;
                if (r_dram_delay != {DELAY_SIZE{1'b0}}) begin
                    rin_dram_delay = r_dram_delay - 1;
                end
                else if (!mar_mem_wdata_infifo_i) begin
                    next_ctrl_mar_state = S_CTRL_MAR_FINISH;
                end

                //timout
                else if (TIMEOUT_RECV_CYCLES != 32'h0) begin
                    rin_mar_timeout = r_mar_timeout + 32'd1;
                    if (r_mar_timeout > TIMEOUT_RECV_CYCLES) begin
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                    end
                end
            end

            //---------------
            //end up here when timeout occured
            S_CTRL_MAR_ERROR: begin
                if (!noc_stall_i && !mar_mem_stall_i) begin
                    mar_done_o = 1'b1;
                    next_ctrl_mar_state = S_CTRL_MAR_IDLE;
                end
            end

            //---------------
            S_CTRL_MAR_FINISH: begin
                //wait until there is no stall anymore to properly write last data to mem
                if (!noc_stall_i && !mar_mem_stall_i) begin
                    mar_done_o = 1'b1;
                    next_ctrl_mar_state = S_CTRL_MAR_IDLE;
                end

                //timout
                else if (mar_mem_stall_i && (TIMEOUT_RECV_CYCLES != 32'h0)) begin
                    rin_mar_timeout = r_mar_timeout + 32'd1;
                    if (r_mar_timeout > TIMEOUT_RECV_CYCLES) begin
                        mar_mem_wabort_o = 1'b1;
                        rin_mar_error = TCU_ERROR_TIMEOUT_MEM;
                        next_ctrl_mar_state = S_CTRL_MAR_ERROR;
                    end
                end
            end

            default: next_ctrl_mar_state = S_CTRL_MAR_IDLE;

        endcase //case (ctrl_mar_state)
    end




    //---------------
    //memory interface
    always @* begin
        //bit 0: write aligned to 16 byte
        //bit 1: write aligned to any other byte
        //bit 2: write request if mem behaves like DRAM
        rin_mem_en = 3'b000;
        rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b0}};

        rin_shift = 4'h0;

        if (!mar_mem_stall_i) begin
            //prepare mem
            if (ctrl_mar_state == S_CTRL_MAR_PREPARE_MEM) begin
                rin_mem_en = 3'b100;
                rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}};
            end

            //no burst
            else if (noc_wrreq_i && (ctrl_mar_state == S_CTRL_MAR_MEM_WRITE1) && !noc_burst_i) begin
                rin_mem_en = 3'b001;
                rin_shift = bsel_firstone;
                rin_mem_wben = ({{(TCU_MEM_BSEL_SIZE/2){1'b0}}, noc_bsel_i} >> bsel_firstone) << r_laddr[3:0];
            end

            //second write for non-burst packet
            else if (ctrl_mar_state == S_CTRL_MAR_MEM_WRITE1_SPLIT) begin
                rin_mem_en = 3'b001;
                rin_shift = bsel_firstone + bsel_count_ones - r_size[3:0];
                rin_mem_wben = ({{(TCU_MEM_BSEL_SIZE/2){1'b0}}, noc_bsel_i} >> bsel_firstone) >> (bsel_count_ones - r_size[3:0]);
            end

            //first part of burst
            else if (noc_wrreq_i && (ctrl_mar_state == S_CTRL_MAR_MEM_WRITE2) && !mar_mem_wabort_o) begin
                rin_shift = r_start_shift;
                rin_mem_en = 3'b001;
                rin_mem_wben = r_wben;
            end

            //during burst
            else if (noc_wrreq_i && (ctrl_mar_state == S_CTRL_MAR_MEM_WRITE3) && !mar_mem_wabort_o) begin
                
                //if there is only one packet in burst, we directly end up here
                //we need to shift data according to start_shift like in the case above
                if (r_burst_length == 'd1) begin
                    rin_shift = r_start_shift;
                    rin_mem_en = 3'b001;
                end
                else begin
                    rin_shift = 4'h0;
                    if (r_laddr[3:0] == 4'h0) begin
                        rin_mem_en = 3'b001;
                    end else begin
                        rin_mem_en = 3'b010;
                    end
                end

                if (noc_burst_i) begin
                    rin_mem_wben = r_wben;
                end
                else begin

                    if ((r_size > 'd16) || ((r_end_shift + r_laddr[3:0]) > 'd16)) begin
                        rin_mem_wben = r_wben;
                    end
                    else if (r_size == 'd16) begin
                        rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}};
                    end
                    else begin
                        //if MSB of last ben was set, we must not shift ben to left according to addr
                        //but only if we do not end up here directly from stage 1
                        if ((r_burst_length != 'd1) && r2_wben_msb) begin
                            rin_mem_wben = {TCU_MEM_BSEL_SIZE{1'b1}} >> (5'd16 - r_size[3:0]);
                        end else begin
                            rin_mem_wben = ({TCU_MEM_BSEL_SIZE{1'b1}} >> (5'd16 - r_size[3:0])) << r_laddr[3:0];
                        end
                    end
                end
            end

            //end of burst
            else if (ctrl_mar_state == S_CTRL_MAR_MEM_WRITE4) begin
                //only for short packets
                if (r_burst_length == 'd1) begin
                    rin_shift = r_start_shift; //start_shift determines how many bytes we already stored -> shift out already used bytes
                end
                rin_mem_en = 3'b010;
                rin_mem_wben = r_wben;
            end
        end
    end


    assign mar_mem_en_o = r_mem_en;
    assign mar_mem_wben_o = r_mem_wben;
    assign mar_mem_addr_o = r_mem_addr;
    assign mar_mem_wdata_o = r_size;

    assign mar_error_o = r_mar_error;
    assign mar_active_o = (ctrl_mar_state != S_CTRL_MAR_IDLE);
    assign mar_shift_o = r_shift;

    //for WRITE ACK
    assign noc_wrreq_o = mar_done_o && r_mode_write_posted;
    assign noc_chipid_o = r_ack_chipid;
    assign noc_modid_o = r_ack_modid;
    assign noc_addr_o = r_ack_addr;
    assign noc_data_o = r_ack_size;

endmodule
