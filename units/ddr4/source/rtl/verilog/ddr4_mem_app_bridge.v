
module ddr4_mem_app_bridge #(
    `include "noc_parameter.vh"
    ,`include "ddr4_user_parameter.vh"
    ,`include "tcu_parameter.vh"
)
(
    input  wire                             mem_clk_i,
    input  wire                             mem_reset_n_i,

    //Mem IF
    input  wire                             mem_en_i,
    input  wire                             mem_req_i,          //read request
    input  wire     [TCU_MEM_BSEL_SIZE-1:0] mem_wben_i,
    input  wire     [TCU_MEM_ADDR_SIZE-1:0] mem_addr_i,
    input  wire     [TCU_MEM_DATA_SIZE-1:0] mem_wdata_i,
    output wire     [TCU_MEM_DATA_SIZE-1:0] mem_rdata_o,
    output wire                             mem_rdata_avail_o,
    output wire                             mem_wstall_o,
    output wire                             mem_rstall_o,
    input  wire                             mem_access_i,       //indicates that mem access of this request is still ongoing

    //APP IF - synchronous to mem_clk
    output reg    [DDR4_APP_ADDR_WIDTH-1:0] ddr4_app_addr_o,
    output reg     [DDR4_APP_CMD_WIDTH-1:0] ddr4_app_cmd_o,
    output reg                              ddr4_app_en_o,
    output wire   [DDR4_APP_DATA_WIDTH-1:0] ddr4_app_wdf_data_o,
    output reg                              ddr4_app_wdf_end_o,
    output wire [DDR4_APP_DATA_WIDTH/8-1:0] ddr4_app_wdf_mask_o,
    output reg                              ddr4_app_wdf_wren_o,

    input  wire   [DDR4_APP_DATA_WIDTH-1:0] ddr4_app_rd_data_i,
    input  wire                             ddr4_app_rd_data_end_i,
    input  wire                             ddr4_app_rd_data_valid_i,
    input  wire                             ddr4_app_rdy_i,
    input  wire                             ddr4_app_wdf_rdy_i,

    output wire      [DDR4_STATUS_SIZE-1:0] ddr4_status_o
);


    function [DDR4_APP_DATA_CUT_WIDTH-1:0] shift_data128;
        input [1:0] addr;
        input [127:0] data;
        begin
            case(addr)
                2'd0: shift_data128 = {384'h0, data};
                2'd1: shift_data128 = {256'h0, data, 128'h0};
                2'd2: shift_data128 = {128'h0, data, 256'h0};
                2'd3: shift_data128 = {data, 384'h0};
            endcase
        end
    endfunction

    function [DDR4_APP_DATA_CUT_WIDTH/8-1:0] shift_bsel128;
        input [1:0] addr;
        input [15:0] bsel;   //should be already inverted
        begin
            case(addr)
                2'd0: shift_bsel128 = {48'hFFFF_FFFF_FFFF, bsel};
                2'd1: shift_bsel128 = {32'hFFFF_FFFF, bsel, 16'hFFFF};
                2'd2: shift_bsel128 = {16'hFFFF, bsel, 32'hFFFF_FFFF};
                2'd3: shift_bsel128 = {bsel, 48'hFFFF_FFFF_FFFF};
            endcase
        end
    endfunction

    //only if DDR4_APP_DATA_CUT_WIDTH/TCU_MEM_DATA_SIZE=4
    function [TCU_MEM_DATA_SIZE-1:0] sel_data512;
        input [1:0] addr;
        input [DDR4_APP_DATA_CUT_WIDTH-1:0] data;
        begin
            case(addr)
                2'd0: sel_data512 = data[  TCU_MEM_DATA_SIZE-1 :                   0];
                2'd1: sel_data512 = data[2*TCU_MEM_DATA_SIZE-1 :   TCU_MEM_DATA_SIZE];
                2'd2: sel_data512 = data[3*TCU_MEM_DATA_SIZE-1 : 2*TCU_MEM_DATA_SIZE];
                2'd3: sel_data512 = data[4*TCU_MEM_DATA_SIZE-1 : 3*TCU_MEM_DATA_SIZE];
            endcase
        end
    endfunction


    localparam [DDR4_APP_CMD_WIDTH-1:0] APP_CMD_WRITE = 0;
    localparam [DDR4_APP_CMD_WIDTH-1:0] APP_CMD_READ  = 1;

    localparam AUXMEM_ADDR_WIDTH = 9;

    localparam [AUXMEM_ADDR_WIDTH-1:0] RD_WR_THRESHOLD = 40;     //max 40 cycles read latency

    localparam ADDR_SHIFT_POWER2 = (32'h1 << DDR4_ADDR_SHIFT);

    localparam NUM_STATES        = 3;
    localparam S_IDLE            = 3'h0;
    localparam S_READ            = 3'h1;
    localparam S_READ_WAIT       = 3'h2;
    localparam S_READ_WAIT_FETCH = 3'h3;
    localparam S_FINISH          = 3'h7;

    reg [NUM_STATES-1:0] state, next_state;

    /*
     *  DDR4 "ROW_COLUMN_BANK" Mapping:
     *
     *  SDRAM
     *      app_addr Mapping -> app_addr[2:0] ignored
     *  ------------------------------------------------------
     *  Rank
     *      (RANKS == 1) ? 1'b0:
     *      (S_HEIGHT == 1) ? app_addr[COL_WIDTH + ROW_WIDTH + BANK_WIDTH + BANK_GROUP_WIDTH +: RANK_WIDTH]:
     *      app_addr[COL_WIDTH + ROW_WIDTH + BANK_WIDTH + BANK_GROUP_WIDTH + LR_WIDTH +: RANK_WIDTH]
     *      -> 1'b0
     *  Logical Rank (3DS)
     *      (S_HEIGHT==1) ? 1'b0:
     *      app_ddr[BANK_GROUP_WIDTH + BANK_WIDTH + COL_WIDTH + ROW_WIDTH +: LR_WIDTH]
     *      -> 1'b0
     *  Row
     *      app_addr[BANK_GROUP_WIDTH + BANK_WIDTH + COL_WIDTH +: ROW_WIDTH]
     *      -> app_addr[27:13]
     *  Column
     *      app_addr[3 + BANK_GROUP_WIDTH + BANK_WIDTH +: COL_WIDTH ? 3], app_addr[2:0]
     *      -> app_addr[12:6]
     *  Bank
     *      app_addr[3 + BANK_GROUP_WIDTH +: BANK_WIDTH]
     *      -> app_addr[5:4]
     *  Bank Group
     *      app_addr[3 +: BANK_GROUP_WIDTH]
     *      -> app_addr[3]
     *  ------------------------------------------------------
     */


    reg   [DDR4_APP_DATA_CUT_WIDTH-1:0] ddr4_app_wdf_data_cut;
    reg [DDR4_APP_DATA_CUT_WIDTH/8-1:0] ddr4_app_wdf_mask_cut;

    reg [TCU_MEM_ADDR_SIZE-1:0] r_mem_addr;
    reg [TCU_MEM_ADDR_SIZE-1:0] r_mem_addr_out, rin_mem_addr_out;


    reg [AUXMEM_ADDR_WIDTH-1:0] r_auxmem_waddr, rin_auxmem_waddr;
    reg [AUXMEM_ADDR_WIDTH-1:0] r_auxmem_raddr, rin_auxmem_raddr;
    reg                         rin_auxmem_ren;

    //number of loops in auxmem (could also be upper bits of auxmem_addr)
    reg                  [15:0] r_auxmem_wloops, rin_auxmem_wloops;
    reg                  [15:0] r_auxmem_rloops, rin_auxmem_rloops;

    reg [31:0] r_req_size, rin_req_size;
    reg [32-DDR4_ADDR_SHIFT-1:0] r_req_count, rin_req_count;

    reg req_wfifo_pop;
    reg req_rfifo_pop;

    reg r_read_stall;

    wire [TCU_MEM_BSEL_SIZE-1:0] mem_wben_wout;
    wire [TCU_MEM_ADDR_SIZE-1:0] mem_addr_wout;
    wire [TCU_MEM_DATA_SIZE-1:0] mem_wdata_wout;
    wire [TCU_MEM_ADDR_SIZE-1:0] mem_addr_rout;
    wire                  [31:0] mem_wdata_rout;

    wire [DDR4_APP_DATA_CUT_WIDTH-1:0] auxmem_data_out;

    wire req_wfifo_full;
    wire req_wfifo_empty;
    wire req_rfifo_full;
    wire req_rfifo_empty;

    //mem_en:
    // bit 0: write/read to DRAM (i.e. read from auxmem)
    // bit 1: read request, data size (in bytes) in wdata field
    wire req_wfifo_push = (mem_en_i && |mem_wben_i);
    wire req_rfifo_push = (mem_req_i && !mem_wben_i);

    //number of already requested data
    wire [32-DDR4_ADDR_SHIFT-1:0] tmp_req_count = rin_auxmem_waddr + {rin_auxmem_wloops, {AUXMEM_ADDR_WIDTH{1'b0}}};

    wire wloops_greater_rloops = (r_auxmem_wloops > r_auxmem_rloops);

    //check auxmem overflow, occurs if waddr gets too close to raddr, except when they are equal at start
    wire auxmem_overflow = ((r_auxmem_raddr - r_auxmem_waddr) <= RD_WR_THRESHOLD) && (r_auxmem_raddr != r_auxmem_waddr);

    //data is available when waddr is ahead of raddr
    wire mem_rdata_avail = ((r_auxmem_waddr > r_auxmem_raddr) || wloops_greater_rloops) && mem_access_i;

    wire auxmem_wen = ddr4_app_rd_data_valid_i && ddr4_app_rd_data_end_i;

    wire [AUXMEM_ADDR_WIDTH-1:0] auxmem_raddr_incr = rin_auxmem_raddr + 1;

    //use reg-inputs for computations to shorten critical path towards TCU
    //stall TCU when reading is faster than data come from memory interface
    wire read_stall = (rin_auxmem_waddr == auxmem_raddr_incr) && (tmp_req_count < r_req_count);



    //memory to buffer DRAM read data
    mem_tp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(DDR4_APP_DATA_CUT_WIDTH),
        .MEM_ADDRWIDTH(AUXMEM_ADDR_WIDTH)
    ) ddr4_auxmem (
        .clk    (mem_clk_i),
        .reset  (~mem_reset_n_i),

        .ena    (auxmem_wen),
        .wea    ({(DDR4_APP_DATA_CUT_WIDTH/8){1'b1}}),
        .addra  (r_auxmem_waddr),
        .dina   (ddr4_app_rd_data_i[DDR4_APP_DATA_CUT_WIDTH-1:0]),

        .enb    (rin_auxmem_ren),
        .addrb  (rin_auxmem_raddr),
        .doutb  (auxmem_data_out)
    );




    //FIFO to store incoming writes
    sync_fifo #(
        .DATA_WIDTH (TCU_MEM_BSEL_SIZE+TCU_MEM_ADDR_SIZE+TCU_MEM_DATA_SIZE),
        .ADDR_WIDTH (2)
    ) req_wfifo (
        .clk_i      (mem_clk_i),
        .resetn_i   (mem_reset_n_i),

        .wr_en_i    (req_wfifo_push),
        .wdata_i    ({mem_wben_i, mem_addr_i, mem_wdata_i}),
        .wfull_o    (req_wfifo_full),

        .rd_en_i    (req_wfifo_pop),
        .rdata_o    ({mem_wben_wout, mem_addr_wout, mem_wdata_wout}),
        .rempty_o   (req_wfifo_empty)
    );


    //FIFO to store incoming read requests
    sync_fifo #(
        .DATA_WIDTH (TCU_MEM_ADDR_SIZE+32),
        .ADDR_WIDTH (2)
    ) req_rfifo (
        .clk_i      (mem_clk_i),
        .resetn_i   (mem_reset_n_i),

        .wr_en_i    (req_rfifo_push),
        .wdata_i    ({mem_addr_i, mem_wdata_i[31:0]}),
        .wfull_o    (req_rfifo_full),

        .rd_en_i    (req_rfifo_pop),
        .rdata_o    ({mem_addr_rout, mem_wdata_rout}),
        .rempty_o   (req_rfifo_empty)
    );



    always @(posedge mem_clk_i or negedge mem_reset_n_i) begin
        if (mem_reset_n_i == 1'b0) begin
            state <= S_IDLE;

            r_mem_addr <= {TCU_MEM_ADDR_SIZE{1'b0}};
            r_mem_addr_out <= {TCU_MEM_ADDR_SIZE{1'b0}};

            r_auxmem_waddr <= {AUXMEM_ADDR_WIDTH{1'b0}};
            r_auxmem_raddr <= {AUXMEM_ADDR_WIDTH{1'b0}};

            r_auxmem_wloops <= 16'h0;
            r_auxmem_rloops <= 16'h0;

            r_req_size <= 32'h0;
            r_req_count <= {(32-DDR4_ADDR_SHIFT){1'b0}};

            r_read_stall <= 1'b0;
        end
        else begin
            state <= next_state;

            r_mem_addr <= mem_addr_i;
            r_mem_addr_out <= rin_mem_addr_out;

            r_auxmem_waddr <= rin_auxmem_waddr;
            r_auxmem_raddr <= rin_auxmem_raddr;

            r_auxmem_wloops <= rin_auxmem_wloops;
            r_auxmem_rloops <= rin_auxmem_rloops;

            r_req_size <= rin_req_size;
            r_req_count <= rin_req_count;

            r_read_stall <= read_stall;
        end
    end



    //---------------
    //control auxmem
    always @* begin
        rin_auxmem_ren = 1'b0;
        rin_auxmem_raddr = r_auxmem_raddr;
        rin_auxmem_rloops = r_auxmem_rloops;

        //when read access to auxmem (mem_addr_rout is not defined in state S_FINISH anymore)
        if (state == S_FINISH) begin
            rin_auxmem_raddr = {AUXMEM_ADDR_WIDTH{1'b0}};
            rin_auxmem_rloops = 16'h0;
        end
        else if (mem_en_i && !mem_wben_i) begin
            rin_auxmem_ren = 1'b1;

            //calculate addr of auxmem with start addr as offset
            rin_auxmem_raddr = mem_addr_i[TCU_MEM_ADDR_SIZE-1:DDR4_ADDR_SHIFT] - mem_addr_rout[TCU_MEM_ADDR_SIZE-1:DDR4_ADDR_SHIFT];

            //loops during edge from highest to lowest address, wloops can only be 1 loop ahead of rloops
            if ((r_auxmem_raddr == {AUXMEM_ADDR_WIDTH{1'b0}}) && wloops_greater_rloops) begin
                rin_auxmem_rloops = r_auxmem_rloops + 'h1;
            end
        end
    end

    always @* begin
        rin_auxmem_waddr = r_auxmem_waddr;
        rin_auxmem_wloops = r_auxmem_wloops;

        //if data comes from DRAM, write it to memory
        if (auxmem_wen) begin
            rin_auxmem_waddr = r_auxmem_waddr + 'h1;

            //check how many times waddr loops through auxmem
            if (r_auxmem_waddr == {AUXMEM_ADDR_WIDTH{1'b1}}) begin
                rin_auxmem_wloops = r_auxmem_wloops + 'd1;
            end
        end
        else if (state == S_FINISH) begin
            rin_auxmem_waddr = {AUXMEM_ADDR_WIDTH{1'b0}};
            rin_auxmem_wloops = 16'h0;
        end
    end


    //---------------
    //state machine
    always @* begin
        next_state = state;

        req_wfifo_pop = 1'b0;
        req_rfifo_pop = 1'b0;

        rin_req_size = r_req_size;
        rin_req_count = r_req_count;

        ddr4_app_en_o = 1'b0;
        ddr4_app_cmd_o = APP_CMD_WRITE;
        ddr4_app_addr_o = {DDR4_APP_ADDR_WIDTH{1'b0}};  //addr bits app_addr[2:0] are ignored by DRAM controller
        ddr4_app_wdf_data_cut = {DDR4_APP_DATA_CUT_WIDTH{1'b0}};
        ddr4_app_wdf_mask_cut = {(DDR4_APP_DATA_CUT_WIDTH/8){1'b1}};
        ddr4_app_wdf_end_o = 1'b0;
        ddr4_app_wdf_wren_o = 1'b0;

        rin_mem_addr_out = r_mem_addr_out;


        //---------------
        //writes are simple and do not need a state machine
        //we can write when there is no read or read is paused due to auxmem overflow
        if (ddr4_app_rdy_i && ddr4_app_wdf_rdy_i &&
            !req_wfifo_empty &&
            ((state != S_READ) || ((state == S_READ) && auxmem_overflow))) begin
            req_wfifo_pop = 1'b1;

            ddr4_app_en_o = 1'b1;
            ddr4_app_cmd_o = APP_CMD_WRITE;
            ddr4_app_addr_o = {mem_addr_wout[DDR4_APP_ADDR_WIDTH+DDR4_ADDR_SHIFT-3-1:DDR4_ADDR_SHIFT], 3'h0};
            ddr4_app_wdf_data_cut = shift_data128(mem_addr_wout[DDR4_ADDR_SHIFT-1:DDR4_ADDR_SHIFT-2], mem_wdata_wout);
            ddr4_app_wdf_mask_cut = shift_bsel128(mem_addr_wout[DDR4_ADDR_SHIFT-1:DDR4_ADDR_SHIFT-2], ~mem_wben_wout);
            ddr4_app_wdf_end_o = 1'b1;
            ddr4_app_wdf_wren_o = 1'b1;
        end


        //---------------
        //state machine to handle reads
        case (state)

            //---------------
            //wait for incoming read access
            S_IDLE: begin
                if (!req_rfifo_empty) begin
                    rin_mem_addr_out = mem_addr_rout;
                    rin_req_size = mem_wdata_rout;

                    next_state = S_READ;
                end
            end

            //---------------
            //read from DDR4
            S_READ: begin
                if (ddr4_app_rdy_i && !auxmem_overflow) begin
                    ddr4_app_en_o = 1'b1;
                    ddr4_app_cmd_o = APP_CMD_READ;
                    ddr4_app_addr_o = {r_mem_addr_out[DDR4_APP_ADDR_WIDTH+DDR4_ADDR_SHIFT-3-1:DDR4_ADDR_SHIFT], 3'h0};

                    rin_mem_addr_out = r_mem_addr_out + 'd64;
                    rin_req_count = r_req_count + 'd1;

                    if ((r_req_size + mem_addr_rout[DDR4_ADDR_SHIFT-1:0]) > 'd64) begin
                        rin_req_size = r_req_size - 'd64;
                        next_state = S_READ;
                    end
                    else begin
                        rin_req_size = 'd0;

                        //skip wait stage if first data has already arrived
                        //data could also be already fetched
                        if (mem_rdata_avail) begin
                            next_state = S_READ_WAIT_FETCH;
                        end else begin
                            next_state = S_READ_WAIT;
                        end
                    end
                end
            end

            //wait until no more data is available, then request has finished
            S_READ_WAIT: begin
                if (mem_rdata_avail) begin
                    next_state = S_READ_WAIT_FETCH;
                end
            end

            //wait until last data from auxmem is fetched
            S_READ_WAIT_FETCH: begin
                if (!mem_rdata_avail) begin
                    req_rfifo_pop = 1'b1;
                    next_state = S_FINISH;
                end
            end


            //---------------
            S_FINISH: begin
                rin_req_count = 'd0;

                next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end



    assign ddr4_app_wdf_data_o = {128'h0, ddr4_app_wdf_data_cut};
    assign ddr4_app_wdf_mask_o = {16'hFFFF, ddr4_app_wdf_mask_cut};

    assign mem_rdata_o = sel_data512(r_mem_addr[DDR4_ADDR_SHIFT-1:DDR4_ADDR_SHIFT-2], auxmem_data_out);

    //always check if first data has already arrived in auxmem
    assign mem_rdata_avail_o = mem_rdata_avail;
    assign mem_wstall_o = req_wfifo_full;
    assign mem_rstall_o = req_rfifo_full || (r_read_stall && mem_rdata_avail);

    assign ddr4_status_o = state;


endmodule
