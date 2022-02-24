
module mem_axi4_bridge #(
    `include "noc_parameter.vh"
    ,parameter AXI_ID_WIDTH   = 4,
    parameter AXI_ADDR_WIDTH  = 32,
    parameter AXI_DATA_WIDTH  = 128
)
(
    input  wire                        clk_i,
    input  wire                        reset_n_i,

    output wire                 [31:0] mem_axi4_error_o,    //0: ok, >0: error

	//Mem IF
    input  wire                        mem_en_i,
    input  wire                        mem_req_i,          //read or write request
    input  wire   [AXI_ADDR_WIDTH-1:0] mem_addr_i,
    input  wire [AXI_DATA_WIDTH/8-1:0] mem_wben_i,
    input  wire   [AXI_DATA_WIDTH-1:0] mem_wdata_i,
    output wire   [AXI_DATA_WIDTH-1:0] mem_rdata_o,
    output wire                        mem_rdata_avail_o,  //indicates that read data is in buffer
    output wire                        mem_wdata_infifo_o, //indicates that write data is still in FIFO
    input  wire                        mem_wabort_i,       //abort current AXI write
    output wire                        mem_wstall_o,
    output wire                        mem_rstall_o,
    input  wire                        mem_access_i,       //indicates that mem access of this request is still ongoing

    //AXI4 Master IF
	input  wire                        axi4_aw_ready_i,
    output reg                         axi4_aw_valid_o,
    output wire     [AXI_ID_WIDTH-1:0] axi4_aw_id_o,
    output reg    [AXI_ADDR_WIDTH-1:0] axi4_aw_addr_o,
    output reg                   [7:0] axi4_aw_len_o,
    output wire                  [2:0] axi4_aw_size_o,
    output wire                  [1:0] axi4_aw_burst_o,
    input  wire                        axi4_w_ready_i,
    output reg                         axi4_w_valid_o,
    output reg    [AXI_DATA_WIDTH-1:0] axi4_w_data_o,
    output reg  [AXI_DATA_WIDTH/8-1:0] axi4_w_strb_o,
    output reg                         axi4_w_last_o,
    output wire                        axi4_b_ready_o,
    input  wire                        axi4_b_valid_i,
    input  wire     [AXI_ID_WIDTH-1:0] axi4_b_id_i,
    input  wire                  [1:0] axi4_b_resp_i,
    input  wire                        axi4_ar_ready_i,
    output reg                         axi4_ar_valid_o,
    output wire     [AXI_ID_WIDTH-1:0] axi4_ar_id_o,
    output reg    [AXI_ADDR_WIDTH-1:0] axi4_ar_addr_o,
    output reg                   [7:0] axi4_ar_len_o,
    output wire                  [2:0] axi4_ar_size_o,
    output wire                  [1:0] axi4_ar_burst_o,
    output wire                        axi4_r_ready_o,
    input  wire                        axi4_r_valid_i,
    input  wire     [AXI_ID_WIDTH-1:0] axi4_r_id_i,
    input  wire   [AXI_DATA_WIDTH-1:0] axi4_r_data_i,
    input  wire                  [1:0] axi4_r_resp_i,
    input  wire                        axi4_r_last_i
);

    localparam AUXMEM_ADDR_WIDTH = 9;

    localparam NUM_STATES_WFIFO    = 3;
    localparam S_WFIFO_IDLE        = 3'h0;
    localparam S_WFIFO_WRITE_WAIT  = 3'h1;
    localparam S_WFIFO_WRITE_BURST = 3'h2;
    localparam S_WFIFO_WAIT_BRESP  = 3'h3;
    localparam S_WFIFO_ABORT       = 3'h4;
    localparam S_WFIFO_ERROR       = 3'h5;
    localparam S_WFIFO_FINISH      = 3'h7;

    localparam NUM_STATES_RFIFO   = 3;
    localparam S_RFIFO_IDLE       = 3'h0;
    localparam S_RFIFO_REQNREAD   = 3'h1;
    localparam S_RFIFO_WAIT_FETCH = 3'h2;
    localparam S_RFIFO_ERROR      = 3'h4;
    localparam S_RFIFO_FINISH     = 3'h7;

    localparam AXI_BURST_TYPE_FIXED = 2'h0;
    localparam AXI_BURST_TYPE_INCR  = 2'h1;
    localparam AXI_BURST_TYPE_WRAP  = 2'h2;

    localparam AXI_RESP_TYPE_OKAY   = 2'h0;
    localparam AXI_RESP_TYPE_EXOKAY = 2'h1;
    localparam AXI_RESP_TYPE_SLVERR = 2'h2;
    localparam AXI_RESP_TYPE_DECERR = 2'h3;

    //number of bytes per memory row
    localparam DATA_BYTES = AXI_DATA_WIDTH/8;
    localparam LOG_DATA_BYTES = $clog2(DATA_BYTES);

    localparam [AUXMEM_ADDR_WIDTH-1:0] RD_WR_THRESHOLD = 5;	//threshold may be small due to available r_ready signal


    reg [NUM_STATES_WFIFO-1:0] state_wfifo, next_state_wfifo;
    reg [NUM_STATES_RFIFO-1:0] state_rfifo, next_state_rfifo;



    reg [AUXMEM_ADDR_WIDTH-1:0] r_auxmem_waddr, rin_auxmem_waddr;
    reg	[AUXMEM_ADDR_WIDTH-1:0] r_auxmem_raddr, rin_auxmem_raddr;
    reg                         rin_auxmem_ren;
    reg                  [15:0] r_auxmem_wloops, rin_auxmem_wloops;
    reg                  [15:0] r_auxmem_rloops, rin_auxmem_rloops;

    reg req_wfifo_pop;
    reg r_req_rfifo_pop, rin_req_rfifo_pop;

    reg r_read_stall;

    //error count
    reg [31:0] r_error, rin_error;

    //abort reg for AXI write
    reg r_wabort, rin_wabort;

    reg   [AXI_ADDR_WIDTH-1:0] r_write_addr, rin_write_addr;
    reg  [31-LOG_DATA_BYTES:0] r_write_count, rin_write_count;
    reg                  [8:0] r_tmp_write_count, rin_tmp_write_count;

    reg [AXI_DATA_WIDTH/8-1:0] r_tmp_wben, rin_tmp_wben;
    reg   [AXI_DATA_WIDTH-1:0] r_tmp_wdata, rin_tmp_wdata;

    reg   [AXI_ADDR_WIDTH-1:0] r_ar_addr, rin_ar_addr;
    reg  [31-LOG_DATA_BYTES:0] r_req_count, rin_req_count;

    wire reset_sync_n;

    wire [AXI_DATA_WIDTH/8-1:0] mem_wben_wout;
    wire   [AXI_ADDR_WIDTH-1:0] mem_addr_wout;
    wire   [AXI_DATA_WIDTH-1:0] mem_wdata_wout;
    wire                        mem_wreq_wout;
    wire   [AXI_ADDR_WIDTH-1:0] mem_addr_rout;
    wire   [AXI_DATA_WIDTH-1:0] mem_wdata_rout;

    wire req_wfifo_empty, req_wfifo_full;
    wire req_rfifo_empty, req_rfifo_full;


    //number of requested (incoming) beats:
    //number of bytes/data width
    //+1 if size or addr is not 16-byte aligned
    //+1 if size+addr exceeds 16-byte alignment
    wire    [LOG_DATA_BYTES:0] extra_req_count = mem_wdata_rout[LOG_DATA_BYTES-1:0] + mem_addr_rout[LOG_DATA_BYTES-1:0];
    wire [31-LOG_DATA_BYTES:0] req_count = mem_wdata_rout[31:LOG_DATA_BYTES] +
                                                ((extra_req_count != 'h0) ? 1 : 0) +
                                                ((extra_req_count > DATA_BYTES) ? 1 : 0);

    //AXI supports burst sizes up to 256 beats
    wire req_count_overflow = (req_count > 'd256);

    //number of already requested beats
    wire [31-LOG_DATA_BYTES:0] tmp_req_count = rin_auxmem_waddr + {rin_auxmem_wloops, {AUXMEM_ADDR_WIDTH{1'b0}}};


    //mem_en:
    // bit 0: write/read to AXI (i.e. read from auxmem)
    // bit 1: write/read request, data size (in bytes) in wdata field
    wire req_wfifo_push = (mem_en_i || mem_req_i) && |mem_wben_i;
    wire req_rfifo_push = mem_req_i && !mem_wben_i;

    //indicates a write request
    wire mem_wreq = mem_req_i && |mem_wben_i;

    wire    [LOG_DATA_BYTES:0] extra_write_count = mem_wdata_wout[LOG_DATA_BYTES-1:0] + mem_addr_wout[LOG_DATA_BYTES-1:0];
    wire [31-LOG_DATA_BYTES:0] write_count = mem_wdata_wout[31:LOG_DATA_BYTES] +
                                                ((extra_write_count != 'h0) ? 1 : 0) +
                                                ((extra_write_count > DATA_BYTES) ? 1 : 0);

    wire write_count_overflow = (write_count > 'd256);


    wire wloops_greater_rloops = (r_auxmem_wloops > r_auxmem_rloops);

    //check auxmem overflow, occurs if raddr gets too close to waddr
    wire auxmem_overflow = ((r_auxmem_raddr - r_auxmem_waddr) == RD_WR_THRESHOLD) && (r_auxmem_raddr != r_auxmem_waddr);

    //data is available when waddr is ahead of raddr
    wire mem_rdata_avail = ((r_auxmem_waddr > r_auxmem_raddr) || wloops_greater_rloops) && mem_access_i;

    wire auxmem_wen = axi4_r_valid_i && (axi4_r_id_i == 'h1) && axi4_r_ready_o;

    wire [AUXMEM_ADDR_WIDTH-1:0] auxmem_raddr_incr = rin_auxmem_raddr + 1;

    //stall when waddr is only one address ahead of raddr, except when read request has finished
    //use reg-inputs for computations to shorten critical path towards TCU
    wire read_stall = (rin_auxmem_waddr == auxmem_raddr_incr) && (tmp_req_count < req_count);


    util_reset_sync i_reset_sync_axi4_bridge (
        .clk_i           (clk_i),
        .reset_q_i       (reset_n_i & (~r_wabort)),
        .scan_mode_i     (1'b0),
        .sync_reset_q_o  (reset_sync_n)
    );


    //memory to buffer AXI read data
    mem_tp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(AXI_DATA_WIDTH),
        .MEM_ADDRWIDTH(AUXMEM_ADDR_WIDTH)
    ) auxmem (
        .clk	(clk_i),
        .reset  (~reset_n_i),

        .ena	(auxmem_wen),
        .wea	(16'hFFFF),
        .addra	(r_auxmem_waddr),
        .dina	(axi4_r_data_i),

        .enb	(rin_auxmem_ren),
        .addrb	(rin_auxmem_raddr),
        .doutb	(mem_rdata_o)
    );


    //FIFO to store incoming writes
    sync_fifo #(
        .DATA_WIDTH (AXI_DATA_WIDTH/8+AXI_ADDR_WIDTH+AXI_DATA_WIDTH+1),
        .ADDR_WIDTH ($clog2(MAX_BURST_LENGTH_MSG))
    ) req_wfifo (
        .clk_i		(clk_i),
        .resetn_i	(reset_sync_n),

        .wr_en_i	(req_wfifo_push),
        .wdata_i	({mem_wben_i, mem_addr_i, mem_wdata_i, mem_wreq}),
        .wfull_o	(req_wfifo_full),

        .rd_en_i	(req_wfifo_pop),
        .rdata_o	({mem_wben_wout, mem_addr_wout, mem_wdata_wout, mem_wreq_wout}),
        .rempty_o	(req_wfifo_empty)
    );


    //FIFO to store incoming read requests
    sync_fifo #(
        .DATA_WIDTH (AXI_ADDR_WIDTH+AXI_DATA_WIDTH),
        .ADDR_WIDTH (2)
    ) req_rfifo (
        .clk_i		(clk_i),
        .resetn_i	(reset_n_i),

        .wr_en_i	(req_rfifo_push),
        .wdata_i	({mem_addr_i, mem_wdata_i}),
        .wfull_o	(req_rfifo_full),

        .rd_en_i	(r_req_rfifo_pop),
        .rdata_o	({mem_addr_rout, mem_wdata_rout}),
        .rempty_o	(req_rfifo_empty)
    );



    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            state_wfifo <= S_WFIFO_IDLE;
            state_rfifo <= S_RFIFO_IDLE;

            r_auxmem_waddr <= {AUXMEM_ADDR_WIDTH{1'b0}};
            r_auxmem_raddr <= {AUXMEM_ADDR_WIDTH{1'b0}};

            r_auxmem_wloops <= 16'h0;
            r_auxmem_rloops <= 16'h0;

            r_req_rfifo_pop <= 1'b0;

            r_read_stall <= 1'b0;

            r_error <= 32'h0;
            r_wabort <= 1'b0;

            r_write_addr <= {AXI_ADDR_WIDTH{1'b0}};
            r_write_count <= {(32-LOG_DATA_BYTES){1'b0}};
            r_tmp_write_count <= 9'h0;

            r_tmp_wben <= {(AXI_ADDR_WIDTH/8){1'b0}};
            r_tmp_wdata <= {AXI_ADDR_WIDTH{1'b0}};

            r_ar_addr <= {AXI_ADDR_WIDTH{1'b0}};
            r_req_count <= {(32-LOG_DATA_BYTES){1'b0}};
        end
        else begin
            state_wfifo <= next_state_wfifo;
            state_rfifo <= next_state_rfifo;

            r_auxmem_waddr <= rin_auxmem_waddr;
            r_auxmem_raddr <= rin_auxmem_raddr;

            r_auxmem_wloops <= rin_auxmem_wloops;
            r_auxmem_rloops <= rin_auxmem_rloops;

            r_req_rfifo_pop <= rin_req_rfifo_pop;

            r_read_stall <= read_stall;

            r_error <= rin_error;
            r_wabort <= rin_wabort;

            r_write_addr <= rin_write_addr;
            r_write_count <= rin_write_count;
            r_tmp_write_count <= rin_tmp_write_count;

            r_tmp_wben <= rin_tmp_wben;
            r_tmp_wdata <= rin_tmp_wdata;

            r_ar_addr <= rin_ar_addr;
            r_req_count <= rin_req_count;
        end
    end



    //---------------
    //control auxmem
    always @* begin
        rin_auxmem_ren = 1'b0;
        rin_auxmem_raddr = r_auxmem_raddr;
        rin_auxmem_rloops = r_auxmem_rloops;

        //reset auxmem_raddr, mem_addr_rout is not defined in state S_RFIFO_FINISH anymore
        if (state_rfifo == S_RFIFO_FINISH) begin
            rin_auxmem_raddr = {AUXMEM_ADDR_WIDTH{1'b0}};
            rin_auxmem_rloops = 16'h0;
        end

        //read from auxmem
        else if ((state_rfifo != S_RFIFO_IDLE) && mem_en_i && !mem_wben_i) begin
            rin_auxmem_ren = 1'b1;

            //calculate addr of auxmem with start addr as offset
            rin_auxmem_raddr = mem_addr_i[AXI_ADDR_WIDTH-1:LOG_DATA_BYTES] - mem_addr_rout[AXI_ADDR_WIDTH-1:LOG_DATA_BYTES];

            //loops during edge from highest to lowest address, wloops can only be 1 loop ahead of rloops
            if ((r_auxmem_raddr == {AUXMEM_ADDR_WIDTH{1'b0}}) && wloops_greater_rloops) begin
                rin_auxmem_rloops = r_auxmem_rloops + 'd1;
            end
        end
    end


    always @* begin
        rin_auxmem_waddr = r_auxmem_waddr;
        rin_auxmem_wloops = r_auxmem_wloops;

        //reset auxmem_waddr
        if (state_rfifo == S_RFIFO_FINISH) begin
            rin_auxmem_waddr = {AUXMEM_ADDR_WIDTH{1'b0}};
            rin_auxmem_wloops = 16'h0;
        end

        //if data comes from AXI, write it to auxmem
        else if ((state_rfifo == S_RFIFO_REQNREAD) && auxmem_wen) begin
            rin_auxmem_waddr = r_auxmem_waddr + 'h1;

            //check how many times waddr loops through auxmem
            if (r_auxmem_waddr == {AUXMEM_ADDR_WIDTH{1'b1}}) begin
                rin_auxmem_wloops = r_auxmem_wloops + 'd1;
            end
        end
    end


    //error count
    always @* begin
        rin_error = r_error;
        if ((state_wfifo == S_WFIFO_ERROR) || (state_rfifo == S_RFIFO_ERROR)) begin
            rin_error = r_error + 1;
        end
    end

    assign mem_axi4_error_o = r_error;


    //set abort register to reset write-FIFO
    always @* begin
        rin_wabort = r_wabort;

        if (mem_wabort_i) begin
            rin_wabort = 1'b1;
        end
        else if ((state_wfifo == S_WFIFO_FINISH) ||
                 (state_wfifo == S_WFIFO_IDLE)) begin
            rin_wabort = 1'b0;
        end
    end


    //always check if first data has already arrived in auxmem
    assign mem_rdata_avail_o = mem_rdata_avail;
    assign mem_wdata_infifo_o = (r_write_count > 'd0) || (r_tmp_write_count > 'd0) ||
                                (state_wfifo == S_WFIFO_WAIT_BRESP);  //if something must still be written to AXI interface
    assign mem_wstall_o = req_wfifo_full || r_wabort;
    assign mem_rstall_o = req_rfifo_full || (r_read_stall && mem_rdata_avail);


    //fix these values
    assign axi4_aw_id_o = 'h1;
    assign axi4_aw_size_o = LOG_DATA_BYTES;
    assign axi4_aw_burst_o = AXI_BURST_TYPE_INCR;

    assign axi4_b_ready_o = (state_wfifo == S_WFIFO_WAIT_BRESP);


    //---------------
    //state machine for writes
    always @* begin
        next_state_wfifo = state_wfifo;

        req_wfifo_pop = 1'b0;

        axi4_aw_valid_o = 1'b0;
        axi4_aw_addr_o = {AXI_ADDR_WIDTH{1'b0}};
        axi4_aw_len_o = 8'h0;
        axi4_w_valid_o = 1'b0;
        axi4_w_data_o = mem_wdata_wout;
        axi4_w_strb_o = mem_wben_wout;
        axi4_w_last_o = 1'b0;

        rin_write_addr = r_write_addr;
        rin_write_count = r_write_count;
        rin_tmp_write_count = r_tmp_write_count;

        rin_tmp_wben = r_tmp_wben;
        rin_tmp_wdata = r_tmp_wdata;

        case (state_wfifo)

            //---------------
            //wait for incoming mem write
            S_WFIFO_IDLE: begin
                if (!req_wfifo_empty) begin

                    //if it is a request
                    if (mem_wreq_wout) begin
                        //only set address channel
                        axi4_aw_valid_o = 1'b1;
                        axi4_aw_addr_o = mem_addr_wout;
                        rin_write_addr = mem_addr_wout;

                        //if necessary split write data to multiple AXI bursts
                        if (write_count_overflow) begin
                            axi4_aw_len_o = 'd255;
                            rin_write_count = write_count - 'd256;
                            rin_tmp_write_count = 'd256;
                        end
                        else begin
                            axi4_aw_len_o = write_count - 1;    //len = number of beats - 1
                            rin_write_count = 'd0;
                            rin_tmp_write_count = write_count;
                        end


                        if (axi4_aw_ready_i) begin
                            req_wfifo_pop = 1'b1;

                            if (r_wabort) begin
                                next_state_wfifo = S_WFIFO_ABORT;
                            end else begin
                                next_state_wfifo = S_WFIFO_WRITE_BURST;
                            end
                        end
                        else if (r_wabort) begin
                            next_state_wfifo = S_WFIFO_ERROR;
                        end
                    end

                    //if there is something left over from last time
                    else if (r_write_count > 'h0) begin
                        axi4_aw_valid_o = 1'b1;
                        axi4_aw_addr_o = r_write_addr;

                        //if necessary split write data to multiple AXI bursts
                        if (r_write_count > 'd256) begin
                            axi4_aw_len_o = 'd255;
                            rin_tmp_write_count = 'd256;
                        end
                        else begin
                            axi4_aw_len_o = r_write_count - 1;    //len = number of beats - 1
                            rin_tmp_write_count = r_write_count;
                        end

                        if (axi4_aw_ready_i) begin
                            //set write_count here to prevent multiple assignments if !aw_ready
                            if (r_write_count > 'd256) begin
                                rin_write_count = r_write_count - 'd256;
                            end else begin
                                rin_write_count = 'd0;
                            end

                            if (r_wabort) begin
                                next_state_wfifo = S_WFIFO_ABORT;
                            end else begin
                                next_state_wfifo = S_WFIFO_WRITE_BURST;
                            end
                        end
                        else if (r_wabort) begin
                            next_state_wfifo = S_WFIFO_ERROR;
                        end
                    end

                    //single write
                    else begin
                        //send valid and wait for ready
                        axi4_aw_valid_o = 1'b1;
                        axi4_aw_len_o = 8'h0;    //1 beat -> len = 0
                        axi4_aw_addr_o = mem_addr_wout;

                        if (axi4_aw_ready_i) begin
                            //if write channel is also ready, send data now
                            axi4_w_valid_o = 1'b1;
                            axi4_w_last_o = 1'b1;
                            
                            if (axi4_w_ready_i) begin
                                req_wfifo_pop = 1'b1;
                                next_state_wfifo = S_WFIFO_WAIT_BRESP;
                            end
                            else if (r_wabort) begin
                                rin_tmp_write_count = 'd1;
                                next_state_wfifo = S_WFIFO_ABORT;
                            end
                            else begin
                                next_state_wfifo = S_WFIFO_WRITE_WAIT;
                            end
                        end
                        if (r_wabort) begin
                            next_state_wfifo = S_WFIFO_ERROR;
                        end
                    end
                end
            end

            //---------------
            //wait for write channel ready
            S_WFIFO_WRITE_WAIT: begin
                axi4_w_valid_o = 1'b1;
                axi4_w_last_o = 1'b1;
            
                if (axi4_w_ready_i) begin
                    req_wfifo_pop = 1'b1;
                    next_state_wfifo = S_WFIFO_WAIT_BRESP;
                end
                else if (r_wabort) begin
                    rin_tmp_write_count = 'd1;
                    next_state_wfifo = S_WFIFO_ABORT;
                end
            end

            //---------------
            //write data in burst mode
            S_WFIFO_WRITE_BURST: begin
                if (r_wabort) begin
                    next_state_wfifo = S_WFIFO_ABORT;
                end
                else if (!req_wfifo_empty) begin
                    
                    //must not be a request
                    if (!mem_wreq_wout) begin
                        //check if next FIFO data may have some data for the same address, if so hold it
                        //normal write if: MSB of wben is 1, wben=0, last write
                        if (mem_wben_wout[AXI_DATA_WIDTH/8-1] || !(|mem_wben_wout) || (r_tmp_write_count == 'd1)) begin
                            axi4_w_valid_o = 1'b1;

                            if (axi4_w_ready_i) begin
                                req_wfifo_pop = 1'b1;
                                rin_tmp_write_count = r_tmp_write_count - 1;

                                //there was some data before which must be stored here as well
                                axi4_w_data_o = r_tmp_wdata | mem_wdata_wout;
                                axi4_w_strb_o = r_tmp_wben | mem_wben_wout;

                                if (r_tmp_wben) begin
                                    rin_tmp_wben = {(AXI_DATA_WIDTH/8){1'b0}};  //reset temp data again
                                    rin_tmp_wdata = {AXI_DATA_WIDTH{1'b0}};
                                end

                                if (r_tmp_write_count == 'd1) begin
                                    axi4_w_last_o = 1'b1;
                                    next_state_wfifo = S_WFIFO_WAIT_BRESP;
                                end
                            end
                        end

                        //hold data
                        else begin
                            rin_tmp_wben = mem_wben_wout;
                            rin_tmp_wdata = mem_wdata_wout;

                            req_wfifo_pop = 1'b1;
                        end
                    end
                    else begin
                        //should not happen -> abort
                        next_state_wfifo = S_WFIFO_ABORT;
                    end
                end
            end

            //---------------
            //wait for incoming write ack
            S_WFIFO_WAIT_BRESP: begin
                if (axi4_b_valid_i && (axi4_b_id_i == 'h1)) begin
                    if (axi4_b_resp_i == AXI_RESP_TYPE_OKAY) begin
                        if (r_wabort) begin
                            next_state_wfifo = S_WFIFO_ERROR;
                        end else begin
                            next_state_wfifo = S_WFIFO_FINISH;
                        end
                    end
                    else begin
                        next_state_wfifo = S_WFIFO_ERROR;
                    end
                end
            end

            //---------------
            //write has been aborted, fill remaining AXI burst with bsel=0
            S_WFIFO_ABORT: begin
                if (r_tmp_write_count != 'd0) begin
                    axi4_w_valid_o = 1'b1;
                    axi4_w_data_o = {AXI_DATA_WIDTH{1'b0}};
                    axi4_w_strb_o = {(AXI_DATA_WIDTH/8){1'b0}};

                    if (axi4_w_ready_i) begin
                        rin_tmp_write_count = r_tmp_write_count - 1;

                        if (r_tmp_write_count == 'd1) begin
                            axi4_w_last_o = 1'b1;
                            next_state_wfifo = S_WFIFO_WAIT_BRESP;
                        end
                    end
                end
                else begin
                    next_state_wfifo = S_WFIFO_ERROR;
                end
            end

            //---------------
            //end up here when something went wrong
            S_WFIFO_ERROR: begin
                rin_write_count = 'd0;

                //indicate error just for one cycle
                next_state_wfifo = S_WFIFO_FINISH;
            end

            //---------------
            S_WFIFO_FINISH: begin
                //increment address if there is more data to write
                rin_write_addr = r_write_addr + ('d256 << LOG_DATA_BYTES);

                //reset temp data
                rin_tmp_wben = {(AXI_DATA_WIDTH/8){1'b0}};
                rin_tmp_wdata = {AXI_DATA_WIDTH{1'b0}};

                next_state_wfifo = S_WFIFO_IDLE;
            end

            default: next_state_wfifo = S_WFIFO_IDLE;
        endcase
    end


    //always send fixed length beats in burst
    assign axi4_ar_id_o = 'h1;
    assign axi4_ar_size_o = LOG_DATA_BYTES;
    assign axi4_ar_burst_o = AXI_BURST_TYPE_INCR;

    assign axi4_r_ready_o = !auxmem_overflow;


    //---------------
    //state machine for reads
    always @* begin
        next_state_rfifo = state_rfifo;

        rin_req_rfifo_pop = 1'b0;
        rin_req_count = r_req_count;
        rin_ar_addr = r_ar_addr;

        axi4_ar_valid_o = 1'b0;
        axi4_ar_len_o = 8'h0;
        axi4_ar_addr_o = {AXI_ADDR_WIDTH{1'b0}};


        case (state_rfifo)

            //---------------
            //wait for incoming mem read
            S_RFIFO_IDLE: begin
                //only request data when auxmem is free
                if (!req_rfifo_empty && !auxmem_overflow) begin

                    //send valid and wait for ready
                    axi4_ar_addr_o = mem_addr_rout;
                    axi4_ar_valid_o = 1'b1;

                    if (req_count_overflow) begin
                        //split request to multiple bursts
                        axi4_ar_len_o = 'd255;  //len = number of beats - 1
                    end

                    //only single request
                    else begin
                        axi4_ar_len_o = req_count - 1;  //len = number of beats - 1
                    end

                    if (axi4_ar_ready_i) begin
                        if (req_count_overflow) begin
                            rin_req_count = req_count - 'd256;
                            rin_ar_addr = mem_addr_rout + ('d256 << LOG_DATA_BYTES);
                        end
                        else begin
                            rin_req_count = 'h0;
                        end

                        next_state_rfifo = S_RFIFO_REQNREAD;
                    end
                end
            end

            //wait until all data has arrived, meanwhile request further data
            S_RFIFO_REQNREAD: begin

                //check if we must request data
                if ((r_req_count > 'h0) && !auxmem_overflow) begin
                    //send valid and wait for ready
                    axi4_ar_addr_o = r_ar_addr;
                    axi4_ar_valid_o = 1'b1;

                    if (r_req_count > 'd256) begin
                        axi4_ar_len_o = 'd255;  //len = number of beats - 1
                    end else begin
                        axi4_ar_len_o = r_req_count - 1;  //len = number of beats - 1
                    end

                    if (axi4_ar_ready_i) begin
                        if (r_req_count > 'd256) begin
                            //still requests required
                            rin_req_count = r_req_count - 'd256;
                            rin_ar_addr = r_ar_addr + ('d256 << LOG_DATA_BYTES);
                        end
                        else begin
                            rin_req_count = 'h0;
                        end
                    end
                end

                //check when last data arrives
                if (axi4_r_valid_i) begin
                    if (axi4_r_resp_i != AXI_RESP_TYPE_OKAY) begin
                        rin_req_rfifo_pop = 1'b1;
                        next_state_rfifo = S_RFIFO_ERROR;
                    end
                    else if (axi4_r_last_i && (r_req_count == 'h0)) begin
                        //compare number of requested elements and actual incoming elements
                        if (tmp_req_count == req_count) begin
                            next_state_rfifo = S_RFIFO_WAIT_FETCH;
                        end

                        //should not happen
                        else if (tmp_req_count > req_count) begin
                            rin_req_rfifo_pop = 1'b1;
                            next_state_rfifo = S_RFIFO_ERROR;
                        end
                    end
                end

                //end here if master already stops fetching data from auxmem
                if (!mem_access_i) begin
                    rin_req_rfifo_pop = 1'b1;
                    next_state_rfifo = S_RFIFO_FINISH;
                end
            end

            //wait until fetching data from auxmem has finished
            S_RFIFO_WAIT_FETCH: begin
                if (!mem_rdata_avail) begin
                    rin_req_rfifo_pop = 1'b1;
                    next_state_rfifo = S_RFIFO_FINISH;
                end
            end

            //---------------
            //end up here when an ack is negative or read request not valid
            S_RFIFO_ERROR: begin
                //indicate error just for one cycle
                next_state_rfifo = S_RFIFO_FINISH;
            end

            //---------------
            S_RFIFO_FINISH: begin
                next_state_rfifo = S_RFIFO_IDLE;
            end

            default: next_state_rfifo = S_RFIFO_IDLE;
        endcase
    end


endmodule
