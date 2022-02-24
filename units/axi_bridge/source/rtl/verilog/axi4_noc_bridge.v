
module axi4_noc_bridge #(
    `include "noc_parameter.vh"
    ,parameter AXI_ID_WIDTH   = 4,
    parameter AXI_ADDR_WIDTH  = NOC_ADDR_SIZE,
    parameter AXI_DATA_WIDTH  = 2*NOC_DATA_SIZE //required for bursts
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    output wire                   [31:0] noc_error_o,

    //---------------
    //AXI4 Master IF
    output reg                           axi4_aw_ready_o,
    input  wire                          axi4_aw_valid_i,
    input  wire       [AXI_ID_WIDTH-1:0] axi4_aw_id_i,
    input  wire     [AXI_ADDR_WIDTH-1:0] axi4_aw_addr_i,
    input  wire                    [7:0] axi4_aw_len_i,
    input  wire                    [2:0] axi4_aw_size_i,
    input  wire                    [1:0] axi4_aw_burst_i,
    output reg                           axi4_w_ready_o,
    input  wire                          axi4_w_valid_i,
    input  wire     [AXI_DATA_WIDTH-1:0] axi4_w_data_i,
    input  wire   [AXI_DATA_WIDTH/8-1:0] axi4_w_strb_i,
    input  wire                          axi4_w_last_i,
    input  wire                          axi4_b_ready_i,
    output reg                           axi4_b_valid_o,
    output wire       [AXI_ID_WIDTH-1:0] axi4_b_id_o,
    output reg                     [1:0] axi4_b_resp_o,
    output reg                           axi4_ar_ready_o,
    input  wire                          axi4_ar_valid_i,
    input  wire       [AXI_ID_WIDTH-1:0] axi4_ar_id_i,
    input  wire     [AXI_ADDR_WIDTH-1:0] axi4_ar_addr_i,
    input  wire                    [7:0] axi4_ar_len_i,
    input  wire                    [2:0] axi4_ar_size_i,
    input  wire                    [1:0] axi4_ar_burst_i,
    input  wire                          axi4_r_ready_i,
    output reg                           axi4_r_valid_o,
    output wire       [AXI_ID_WIDTH-1:0] axi4_r_id_o,
    output reg      [AXI_DATA_WIDTH-1:0] axi4_r_data_o,
    output reg                     [1:0] axi4_r_resp_o,
    output reg                           axi4_r_last_o,

    //---------------
    //NoC IF
    input  wire                          noc_rx_wrreq_i,
    input  wire                          noc_rx_burst_i,
    input  wire      [NOC_BSEL_SIZE-1:0] noc_rx_bsel_i,         //unused
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_rx_src_chipid_i,   //unused
    input  wire     [NOC_MODID_SIZE-1:0] noc_rx_src_modid_i,    //unused
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_rx_trg_chipid_i,   //unused
    input  wire     [NOC_MODID_SIZE-1:0] noc_rx_trg_modid_i,    //unused
    input  wire      [NOC_MODE_SIZE-1:0] noc_rx_mode_i,         //unused
    input  wire      [NOC_ADDR_SIZE-1:0] noc_rx_addr_i,         //unused
    input  wire      [NOC_DATA_SIZE-1:0] noc_rx_data0_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_rx_data1_i,
    output reg                           noc_rx_stall_o,

    output reg                           noc_tx_wrreq_o,
    output reg                           noc_tx_burst_o,
    output reg       [NOC_BSEL_SIZE-1:0] noc_tx_bsel_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_tx_src_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_tx_src_modid_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_tx_trg_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_tx_trg_modid_o,
    output reg       [NOC_MODE_SIZE-1:0] noc_tx_mode_o,
    output reg       [NOC_ADDR_SIZE-1:0] noc_tx_addr_o,
    output reg       [NOC_DATA_SIZE-1:0] noc_tx_data0_o,
    output reg       [NOC_DATA_SIZE-1:0] noc_tx_data1_o,
    input  wire                          noc_tx_stall_i
);


    localparam AXI4_STATES_SIZE       = 4;
    localparam S_AXI4_IDLE            = 4'h0;
    localparam S_AXI4_READ            = 4'h1;
    localparam S_AXI4_WRITE           = 4'h2;
    localparam S_AXI4_WRITE_ACK       = 4'h3;
    localparam S_AXI4_WAIT_WVALID     = 4'h4;
    localparam S_AXI4_WRITE_ABORT     = 4'h5;
    localparam S_AXI4_READ_DROP       = 4'h6;
    localparam S_AXI4_READ_ABORT      = 4'h7;
    localparam S_AXI4_DROP_NOC_PACKET = 4'h8;

    localparam AXI_BURST_TYPE_FIXED = 2'h0;
    localparam AXI_BURST_TYPE_INCR  = 2'h1;
    localparam AXI_BURST_TYPE_WRAP  = 2'h2;

    localparam AXI_RESP_TYPE_OKAY   = 2'h0;
    localparam AXI_RESP_TYPE_EXOKAY = 2'h1;
    localparam AXI_RESP_TYPE_SLVERR = 2'h2;
    localparam AXI_RESP_TYPE_DECERR = 2'h3;

    localparam LOG_DATA_BYTES = $clog2(AXI_DATA_WIDTH/8);

    /*
    function automatic [AXI_ADDR_WIDTH-1:0] get_wrap_boundary;
        input [AXI_ADDR_WIDTH-1:0] unaligned_address;
        input [7:0] len;
        begin
            get_wrap_boundary = {AXI_ADDR_WIDTH{1'b0}};

            //for wrapping transfers len can only be of size 1, 3, 7 or 15
            if (len == 4'b1) begin
                get_wrap_boundary[AXI_ADDR_WIDTH-1:1+LOG_DATA_BYTES] = unaligned_address[AXI_ADDR_WIDTH-1:1+LOG_DATA_BYTES];
            end else if (len == 4'b11) begin
                get_wrap_boundary[AXI_ADDR_WIDTH-1:2+LOG_DATA_BYTES] = unaligned_address[AXI_ADDR_WIDTH-1:2+LOG_DATA_BYTES];
            end else if (len == 4'b111) begin
                get_wrap_boundary[AXI_ADDR_WIDTH-1:3+LOG_DATA_BYTES] = unaligned_address[AXI_ADDR_WIDTH-3:2+LOG_DATA_BYTES];
            end else if (len == 4'b1111) begin
                get_wrap_boundary[AXI_ADDR_WIDTH-1:4+LOG_DATA_BYTES] = unaligned_address[AXI_ADDR_WIDTH-3:4+LOG_DATA_BYTES];
            end
        end
    endfunction


    function automatic [AXI_ADDR_WIDTH-1:0] get_new_addr;
        input [1:0] burst_type;
        input [AXI_ADDR_WIDTH-1:0] base_addr;
        input [7:0] base_len;
        input [7:0] tmp_len;
        reg [AXI_ADDR_WIDTH-1:0] aligned_address;
        reg [AXI_ADDR_WIDTH-1:0] wrap_boundary;
        reg [AXI_ADDR_WIDTH-1:0] upper_wrap_boundary;
        reg [AXI_ADDR_WIDTH-1:0] cons_addr;
        begin

            //calculate new address
            aligned_address = {base_addr[AXI_ADDR_WIDTH-1:LOG_DATA_BYTES], {LOG_DATA_BYTES{1'b0}}};
            wrap_boundary = get_wrap_boundary(base_addr, base_len);
            upper_wrap_boundary = wrap_boundary + ((base_len + 'h1) << LOG_DATA_BYTES);
            cons_addr = aligned_address + (tmp_len << LOG_DATA_BYTES);

            //select new address according burst type
            case (burst_type)
                //AXI_BURST_TYPE_FIXED: begin
                //  ;no addr increment
                //end

                AXI_BURST_TYPE_INCR: begin
                    get_new_addr = cons_addr;
                end

                AXI_BURST_TYPE_WRAP: begin
                    //check if the address reached warp boundary
                    if (cons_addr == upper_wrap_boundary) begin
                        get_new_addr = wrap_boundary;
                    end

                    //address wraped beyond boundary
                    else if (cons_addr > upper_wrap_boundary) begin
                        get_new_addr = base_addr + ((tmp_len - base_len) << LOG_DATA_BYTES);
                    end

                    //we still do normal increment
                    else begin
                        get_new_addr = cons_addr;
                    end
                end

                default: begin
                    get_new_addr = base_addr;
                end
            endcase
        end
    endfunction
    */


    reg [AXI4_STATES_SIZE-1:0] state, next_state;

    //temp regs for read or write request
    reg   [AXI_ID_WIDTH-1:0] r_axi_req_id, rin_axi_req_id;
    reg [AXI_ADDR_WIDTH-1:0] r_axi_req_addr, rin_axi_req_addr;
    reg                [7:0] r_axi_req_len, rin_axi_req_len;
    //reg                [1:0] r_axi_req_burst, rin_axi_req_burst;

    //reg [AXI_ADDR_WIDTH-1:0] r_tmp_addr, rin_tmp_addr;  //tmp addr of AXI read
    reg                [7:0] r_tmp_len, rin_tmp_len;    //tmp burst size of AXI read and write

    reg                      r_noc_rx_burst;

    //error count
    reg [31:0] r_error, rin_error;

    //new address depends on burst type
    //wire [AXI_ADDR_WIDTH-1:0] new_addr = get_new_addr(r_axi_req_burst, r_axi_req_addr, r_axi_req_len, r_tmp_len);

    //start from addr 0x0 (add addr offset)
    //wire [AXI_ADDR_WIDTH-1:0] axi4_ar_addr_s = axi4_ar_addr_i;
    //wire [AXI_ADDR_WIDTH-1:0] axi4_aw_addr_s = axi4_aw_addr_i;

    assign noc_error_o = r_error;


    //default assignments
    assign axi4_r_id_o = r_axi_req_id;
    assign axi4_b_id_o = r_axi_req_id;

    //must be set later
    assign noc_tx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
    assign noc_tx_src_modid_o = {NOC_MODID_SIZE{1'b0}};
    assign noc_tx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
    assign noc_tx_trg_modid_o = {NOC_MODID_SIZE{1'b0}};



    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            state <= S_AXI4_IDLE;

            r_axi_req_id <= {AXI_ID_WIDTH{1'b0}};
            r_axi_req_addr <= {AXI_ADDR_WIDTH{1'b0}};
            r_axi_req_len <= 8'h0;
            //r_axi_req_burst <= 2'h0;

            //r_tmp_addr <= {AXI_ADDR_WIDTH{1'b0}};
            r_tmp_len <= 8'h0;

            r_noc_rx_burst <= 1'b0;

            r_error <= 32'h0;
        end
        else begin
            state <= next_state;

            r_axi_req_id <= rin_axi_req_id;
            r_axi_req_addr <= rin_axi_req_addr;
            r_axi_req_len <= rin_axi_req_len;
            //r_axi_req_burst <= rin_axi_req_burst;

            //r_tmp_addr <= rin_tmp_addr;
            r_tmp_len <= rin_tmp_len;

            r_noc_rx_burst <= (noc_rx_wrreq_i && !noc_rx_stall_o) ? noc_rx_burst_i : r_noc_rx_burst;

            r_error <= rin_error;
        end
    end




    always @* begin
        next_state = state;

        rin_axi_req_id = r_axi_req_id;
        rin_axi_req_addr = r_axi_req_addr;
        rin_axi_req_len = r_axi_req_len;
        //rin_axi_req_burst = r_axi_req_burst;

        //rin_tmp_addr = r_tmp_addr;
        rin_tmp_len = r_tmp_len;

        noc_tx_wrreq_o = 1'b0;
        noc_tx_burst_o = 1'b0;
        noc_tx_bsel_o = {NOC_BSEL_SIZE{1'b0}};
        noc_tx_mode_o = MODE_WRITE_POSTED;
        noc_tx_addr_o = {NOC_ADDR_SIZE{1'b0}};
        noc_tx_data0_o = {NOC_DATA_SIZE{1'b0}};
        noc_tx_data1_o = {NOC_DATA_SIZE{1'b0}};

        noc_rx_stall_o = 1'b1;

        axi4_aw_ready_o = 1'b0;
        axi4_ar_ready_o = 1'b0;

        axi4_r_valid_o = 1'b0;
        axi4_r_data_o = {AXI_DATA_WIDTH{1'b0}};
        axi4_r_last_o = 1'b0;
        axi4_b_resp_o = AXI_RESP_TYPE_OKAY;

        axi4_w_ready_o = 1'b0;

        axi4_r_resp_o = AXI_RESP_TYPE_OKAY;
        axi4_b_valid_o = 1'b0;

        rin_error = r_error;



        case (state)

            //---------------
            //wait for read or write from core
            S_AXI4_IDLE: begin
                rin_tmp_len = 'h0;

                //first check if there is an unexpected NoC packet (e.g. error after write), drop it
                if (noc_rx_wrreq_i) begin
                    next_state = S_AXI4_DROP_NOC_PACKET;
                end

                //read
                else if (axi4_ar_valid_i) begin
                    rin_axi_req_id = axi4_ar_id_i;
                    rin_axi_req_addr = axi4_ar_addr_i;
                    rin_axi_req_len = axi4_ar_len_i;
                    //rin_axi_req_burst = axi4_ar_burst_i;

                    //rin_tmp_addr = axi4_ar_addr_i;
                    noc_tx_addr_o = axi4_ar_addr_i;
                    noc_tx_mode_o = MODE_READ_REQ_2; //indicate special packet

                    if (!noc_tx_stall_i) begin
                        axi4_ar_ready_o = 1'b1;

                        //size must fit to data width, otherwise burst not allowed
                        //and: only incr burst type supported because receiver could have no AXI interface
                        if ((axi4_ar_size_i != LOG_DATA_BYTES) && (axi4_ar_len_i != 8'h0) ||
                            (axi4_ar_burst_i != AXI_BURST_TYPE_INCR)) begin
                            next_state = S_AXI4_READ_ABORT;
                        end
                        else begin
                            //send NoC request packet
                            noc_tx_wrreq_o = 1'b1;
                            noc_tx_bsel_o = {NOC_BSEL_SIZE{1'b1}};     //unused
                            noc_tx_data0_o = {(axi4_ar_len_i+1), {LOG_DATA_BYTES{1'b0}}, axi4_ar_addr_i};   //burst length in number of bytes and return addr
                            next_state = S_AXI4_READ;
                        end
                    end
                end

                //write
                else if (axi4_aw_valid_i) begin
                    rin_axi_req_id = axi4_aw_id_i;
                    rin_axi_req_addr = axi4_aw_addr_i;
                    rin_axi_req_len = axi4_aw_len_i;
                    //rin_axi_req_burst = axi4_aw_burst_i;

                    noc_tx_addr_o = axi4_aw_addr_i;
                    noc_tx_mode_o = MODE_WRITE_POSTED_2;  //indicate special packet

                    //size must fit to data width, otherwise burst not allowed
                    //and: only incr burst type supported because receiver could have no AXI interface
                    if (((axi4_aw_size_i != LOG_DATA_BYTES) && (axi4_aw_len_i != 8'h0)) ||
                        (axi4_aw_burst_i != AXI_BURST_TYPE_INCR)) begin
                        next_state = S_AXI4_WRITE_ABORT;
                    end

                    //transfer ok
                    //we get delayed because NoC stalls, stay in this state
                    else if (!noc_tx_stall_i) begin
                        axi4_aw_ready_o = 1'b1;

                        //check if we need a NoC burst: if size > log(8 byte)
                        if ((axi4_aw_size_i > 3'h3) || (axi4_aw_len_i != 8'h0)) begin

                            //it is a burst: send NoC header packet
                            noc_tx_wrreq_o = 1'b1;
                            noc_tx_burst_o = 1'b1;
                            noc_tx_bsel_o = {NOC_BSEL_SIZE{1'b1}};  //always full burst flits
                            noc_tx_data0_o = axi4_aw_len_i + 1;     //burst length, TODO: check with max. NoC burst length

                            next_state = S_AXI4_WRITE;
                        end

                        //no burst
                        else begin
                            axi4_w_ready_o = 1'b1;

                            //data is there when w_valid gets high
                            if (axi4_w_valid_i) begin
                                noc_tx_wrreq_o = 1'b1;
                                noc_tx_bsel_o = axi4_w_strb_i;
                                noc_tx_data0_o = axi4_w_data_i[NOC_DATA_SIZE-1:0];     //TODO: always lower 64 bit?

                                //this should be the end of burst, error if not
                                if (axi4_w_last_i) begin
                                    next_state = S_AXI4_WRITE_ACK;
                                end else begin
                                    next_state = S_AXI4_WRITE_ABORT;
                                end
                            end

                            //wait until write data is there
                            else begin
                                next_state = S_AXI4_WAIT_WVALID;
                            end
                        end
                    end
                end
            end

            //---------------
            //wait until NoC is free and write data is there
            S_AXI4_WAIT_WVALID: begin
                noc_tx_addr_o = r_axi_req_addr;
                noc_tx_mode_o = MODE_WRITE_POSTED_2;    //indicate special packet

                if (!noc_tx_stall_i) begin
                    axi4_w_ready_o = 1'b1;

                    if (axi4_w_valid_i) begin
                        noc_tx_wrreq_o = 1'b1;
                        noc_tx_bsel_o = axi4_w_strb_i;
                        noc_tx_data0_o = axi4_w_data_i[NOC_DATA_SIZE-1:0];     //TODO: always lower 64 bit?

                        //this should be the end of burst, error if not
                        if (axi4_w_last_i) begin
                            next_state = S_AXI4_WRITE_ACK;
                        end else begin
                            next_state = S_AXI4_WRITE_ABORT;
                        end
                    end
                end
            end


            //---------------
            S_AXI4_READ: begin
                //waiting for incoming packet
                if (noc_rx_wrreq_i) begin

                    //we only expect packets with mode MODE_READ_RSP_2, otherwise drop packet
                    if (!r_noc_rx_burst && (noc_rx_mode_i != MODE_READ_RSP_2)) begin
                        next_state = S_AXI4_READ_DROP;
                    end

                    //check if NoC header
                    else if (!r_noc_rx_burst && noc_rx_burst_i) begin
                        //read burst length
                        rin_tmp_len = r_tmp_len + noc_rx_data0_i[7:0] - 'h1;
                        noc_rx_stall_o = 1'b0;
                    end

                    //payload or single packet
                    else begin
                        axi4_r_valid_o = 1'b1;
                        axi4_r_data_o = {noc_rx_data1_i, noc_rx_data0_i};

                        if (axi4_r_ready_i) begin
                            noc_rx_stall_o = 1'b0;

                            //check if end of burst
                            //TODO: if req_len is not achieved send error or wait for next burst (support multiple bursts)
                            if (!noc_rx_burst_i && (r_tmp_len == r_axi_req_len)) begin
                                axi4_r_last_o = 1'b1;
                                next_state = S_AXI4_IDLE;
                            end
                        end
                    end
                end
            end

            //---------------
            //continue write transfer
            S_AXI4_WRITE: begin
                //take new address
                //mem_addr_o = new_addr;

                //we are only ready when NoC does not stall
                if (!noc_tx_stall_i) begin
                    axi4_w_ready_o = 1'b1;

                    if (axi4_w_valid_i) begin
                        noc_tx_wrreq_o = 1'b1;
                        noc_tx_bsel_o = axi4_w_strb_i;  //TODO: wstrb is not evaluated for burst flits
                        noc_tx_data0_o = axi4_w_data_i[NOC_DATA_SIZE-1:0];
                        noc_tx_data1_o = axi4_w_data_i[2*NOC_DATA_SIZE-1:NOC_DATA_SIZE];

                        //rin_tmp_len = r_tmp_len + 'h1;

                        //leave this state when end of burst
                        if (axi4_w_last_i) begin
                            next_state = S_AXI4_WRITE_ACK;
                        end

                        //else burst is ongoing
                        else begin
                            noc_tx_burst_o = 1'b1;
                        end
                    end
                end
            end

            //---------------
            //send write ack
            S_AXI4_WRITE_ACK: begin
                axi4_b_valid_o = 1'b1;
                axi4_b_resp_o = AXI_RESP_TYPE_OKAY;

                if (axi4_b_ready_i) begin
                    next_state = S_AXI4_IDLE;
                end
            end

            //---------------
            //no valid write request, just send error
            S_AXI4_WRITE_ABORT: begin
                axi4_b_valid_o = 1'b1;
                axi4_b_resp_o = AXI_RESP_TYPE_SLVERR;

                if (axi4_b_ready_i) begin
                    next_state = S_AXI4_IDLE;
                end
            end

            //---------------
            S_AXI4_READ_DROP: begin
                if (noc_rx_wrreq_i) begin
                    noc_rx_stall_o = 1'b0;

                    //stay here to drop whole NoC burst
                    if (!noc_rx_burst_i) begin
                        rin_error = r_error + 1;
                        next_state = S_AXI4_READ_ABORT;
                    end
                end
            end

            //no valid read request, send error in each data transfer of AXI burst
            S_AXI4_READ_ABORT: begin
                axi4_r_valid_o = 1'b1;
                axi4_r_resp_o = AXI_RESP_TYPE_SLVERR;

                if (r_tmp_len == r_axi_req_len) begin
                    axi4_r_last_o = 1'b1;
                end

                if (axi4_r_ready_i) begin
                    rin_tmp_len = r_tmp_len + 1;

                    if (r_tmp_len == r_axi_req_len) begin
                        next_state = S_AXI4_IDLE;
                    end
                end
            end

            //---------------
            //drop unexpected packet
            S_AXI4_DROP_NOC_PACKET: begin
                if (noc_rx_wrreq_i) begin
                    noc_rx_stall_o = 1'b0;

                    //stay here to drop whole NoC burst
                    if (!noc_rx_burst_i) begin
                        rin_error = r_error + 1;
                        next_state = S_AXI4_IDLE;
                    end
                end
            end

            default: begin
                next_state = S_AXI4_IDLE;
            end
        endcase
    end

endmodule
