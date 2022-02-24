
module noc_arq_tx #(
    `include "noc_parameter.vh"
    ,parameter ARQ_TX_BUFFER_ADDR_WIDTH = 8
)(
    input  wire                        clk_i,
    input  wire                        reset_q_i,

    //from module to NoC
    input  wire                        mod_wrreq_i,
    input  wire  [NOC_HEADER_SIZE-1:0] mod_header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] mod_payload_i,
    output wire                        mod_stall_o,
    output reg                         noc_wrreq_o,
    output reg   [NOC_HEADER_SIZE-1:0] noc_header_o,
    output reg  [NOC_PAYLOAD_SIZE-1:0] noc_payload_o,
    input  wire                        noc_stall_i,

    //incoming ACKs
    input  wire                        ack_wrreq_i,
    input  wire  [NOC_HEADER_SIZE-1:0] ack_header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] ack_payload_i,
    output wire                        ack_stall_o,

    input  wire                  [1:0] arq_enable_i,

    //infos to regfile
    output wire                 [31:0] arq_tx_bvt_mod_wr_ptr_o,
    output wire                 [31:0] arq_tx_bvt_ack_wr_ptr_o,
    output wire                 [31:0] arq_tx_bvt_occ_ptr_o,
    output wire                 [31:0] arq_tx_bvt_rd_ptr_o
);

    //one more bit to detect when ptr wraps around in buffer
    localparam PTR_ADDR_WIDTH = ARQ_TX_BUFFER_ADDR_WIDTH + 1;
    localparam BVT_DATA_SIZE = 2*ARQ_TX_BUFFER_ADDR_WIDTH + NOC_MODID_SIZE + NOC_CHIPID_SIZE + NOC_ADDR_SIZE;
    localparam ARQ_TX_BUFFER_DEPTH = 1 << ARQ_TX_BUFFER_ADDR_WIDTH;
    localparam ACK_FIFO_DATA_SIZE = NOC_MODID_SIZE + NOC_CHIPID_SIZE + NOC_ADDR_SIZE + 1;

    //FSM to write to tx_buffer
    localparam S_TXB_WRITE_FILL_BUF = 1'b0;
    localparam S_TXB_WRITE_SET_BVT  = 1'b1;
    reg txb_write_state, next_txb_write_state;

    //FSM to read from tx_buffer
    localparam S_TXB_READ_IDLE   = 2'h0;
    localparam S_TXB_READ_SEND   = 2'h1;
    localparam S_TXB_READ_RESEND = 2'h2;
    localparam S_TXB_READ_FINISH = 2'h3;
    reg [1:0] txb_read_state, next_txb_read_state;

    //FSM to handle incoming ACKs
    localparam S_ACK_IDLE         = 3'h0;
    localparam S_ACK_CHECK        = 3'h1;
    localparam S_ACK_INCR_OCC_PTR = 3'h2;
    localparam S_ACK_UPDATE_BVT   = 3'h3;
    localparam S_ACK_RESEND_START = 3'h4;
    localparam S_ACK_RESEND       = 3'h5;
    reg [2:0] ack_state, next_ack_state;


    //ptr in tx_buffer
    reg            [PTR_ADDR_WIDTH-1:0] r_txb_wr_ptr, rin_txb_wr_ptr;
    reg            [PTR_ADDR_WIDTH-1:0] r_txb_occ_ptr, rin_txb_occ_ptr;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_txb_mod_rd_ptr, rin_txb_mod_rd_ptr;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_txb_resend_rd_ptr, rin_txb_resend_rd_ptr;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] txb_rd_ptr;
    reg                                 r_txb_write_active, rin_txb_write_active;

    reg                         r_txb_rdata_fromreg, rin_txb_rdata_fromreg;
    reg                         r_txb_arq_out, rin_txb_arq_out;
    reg   [NOC_HEADER_SIZE-1:0] r_txb_header_out, rin_txb_header_out;
    reg  [NOC_PAYLOAD_SIZE-1:0] r_txb_payload_out, rin_txb_payload_out;

    reg txb_wr_en;
    reg r_txb_rd_en, rin_txb_rd_en;
    reg txb_arq_out;

    //ptr in buffer-valid table
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_bvt_mod_wr_ptr, rin_bvt_mod_wr_ptr;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_bvt_ack_wr_ptr, rin_bvt_ack_wr_ptr;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_bvt_occ_ptr, rin_bvt_occ_ptr;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_bvt_rd_ptr, rin_bvt_rd_ptr;

    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_bvt_wdata_pos, rin_bvt_wdata_pos;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_bvt_wdata_length, rin_bvt_wdata_length;
    reg            [NOC_MODID_SIZE-1:0] r_bvt_wdata_modid, rin_bvt_wdata_modid;
    reg           [NOC_CHIPID_SIZE-1:0] r_bvt_wdata_chipid, rin_bvt_wdata_chipid;
    reg             [NOC_ADDR_SIZE-1:0] r_bvt_wdata_addr, rin_bvt_wdata_addr;

    //mark valid entries in BVT
    reg [ARQ_TX_BUFFER_DEPTH-1:0] r_bvt_valid_entry, rin_bvt_valid_entry;

    //indicate that packet must be send again due to NACK
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_resend_pos, rin_resend_pos;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] r_resend_length, rin_resend_length;


    reg                                 bvt_wr_en;
    reg  [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] bvt_wr_ptr;
    reg             [BVT_DATA_SIZE-1:0] bvt_wdata;
    reg                                 bvt_rd_en;

    wire [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] bvt_rdata_pos;
    wire [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] bvt_rdata_length;
    wire           [NOC_MODID_SIZE-1:0] bvt_rdata_modid;
    wire          [NOC_CHIPID_SIZE-1:0] bvt_rdata_chipid;
    wire            [NOC_ADDR_SIZE-1:0] bvt_rdata_addr;


    //indicate packet forwarding when ACK is disabled
    reg r_forward, rin_forward;
    reg r_mod_burst;
    reg r_noc_stall;


    wire                       mod_burst = mod_header_i[NOC_HEADER_SIZE-1];
    wire                       mod_arq = mod_header_i[2*NOC_MODID_SIZE+2*NOC_CHIPID_SIZE+NOC_BSEL_SIZE +: NOC_ARQ_SIZE];
    wire  [NOC_MODID_SIZE-1:0] mod_trg_modid = mod_header_i[NOC_MODID_SIZE+NOC_CHIPID_SIZE-1 : NOC_CHIPID_SIZE];
    wire [NOC_CHIPID_SIZE-1:0] mod_trg_chipid = mod_header_i[NOC_CHIPID_SIZE-1:0];
    wire   [NOC_ADDR_SIZE-1:0] mod_addr = mod_payload_i[NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_DATA_SIZE];


    wire  [NOC_HEADER_SIZE-1:0] txb_header_out;
    wire [NOC_PAYLOAD_SIZE-1:0] txb_payload_out;

    //TXB is full when wr_ptr reached occ_ptr
    wire txb_full = (r_txb_wr_ptr[ARQ_TX_BUFFER_ADDR_WIDTH-1:0] == r_txb_occ_ptr[ARQ_TX_BUFFER_ADDR_WIDTH-1:0]) &&
                            (r_txb_wr_ptr[ARQ_TX_BUFFER_ADDR_WIDTH] != r_txb_occ_ptr[ARQ_TX_BUFFER_ADDR_WIDTH]);

    //data in TXB is available when rd_ptr behind wr_ptr and rd_ptr must not take data which is currently written to TXB
    wire txb_data_avail = (r_txb_wr_ptr[ARQ_TX_BUFFER_ADDR_WIDTH-1:0] != r_txb_mod_rd_ptr) &&
                            !(r_txb_write_active && (r_txb_mod_rd_ptr == r_bvt_wdata_pos));

    wire txb_read_active = (txb_read_state != S_TXB_READ_IDLE);

    wire [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] resend_end_ptr = r_resend_pos + r_resend_length;

    wire [ARQ_TX_BUFFER_ADDR_WIDTH-1:0] bvt_rd_ptr_decr = r_bvt_rd_ptr - 1;

    wire [ARQ_TX_BUFFER_DEPTH-1:0] ptr_to_bit_mask = 1 << bvt_wr_ptr;

    //take addr and src-ids from ACK
    wire  [NOC_MODID_SIZE-1:0] ack_src_modid = ack_header_i[NOC_MODID_SIZE+2*NOC_CHIPID_SIZE +: NOC_MODID_SIZE];
    wire [NOC_CHIPID_SIZE-1:0] ack_src_chipid = ack_header_i[NOC_MODID_SIZE+NOC_CHIPID_SIZE +: NOC_CHIPID_SIZE];
    wire   [NOC_ADDR_SIZE-1:0] ack_addr = ack_payload_i[NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_DATA_SIZE];

    //0: NACK, 1: ACK
    wire ack_type = ack_payload_i[0];

    //signals to read from ACK FIFO
    reg                        ack_fifo_pop;
    wire                       ack_fifo_empty;
    wire  [NOC_MODID_SIZE-1:0] ack_fifo_src_modid;
    wire [NOC_CHIPID_SIZE-1:0] ack_fifo_src_chipid;
    wire   [NOC_ADDR_SIZE-1:0] ack_fifo_addr;
    wire                       ack_fifo_type;




    //buffer outgoing flits to send them again when NACK arrives
    mem_tp_wrap #(
        .MEM_TYPE      ("auto"),
        .MEM_DATAWIDTH (NOC_HEADER_SIZE+NOC_PAYLOAD_SIZE),
        .MEM_ADDRWIDTH (ARQ_TX_BUFFER_ADDR_WIDTH)
    ) arq_tx_buffer (
        .clk     (clk_i),
        .reset   (~reset_q_i),

        .ena     (txb_wr_en),
        .wea     ({((NOC_HEADER_SIZE+NOC_PAYLOAD_SIZE+7)/8){1'b1}}),
        .addra   (r_txb_wr_ptr[ARQ_TX_BUFFER_ADDR_WIDTH-1:0]),
        .dina    ({mod_header_i, mod_payload_i}),

        .enb     (rin_txb_rd_en),
        .addrb   (txb_rd_ptr),
        .doutb   ({txb_header_out, txb_payload_out})
    );


    //buffer-valid table (BVT)
    mem_tp_wrap #(
        .MEM_TYPE      ("auto"),
        .MEM_DATAWIDTH (BVT_DATA_SIZE),
        .MEM_ADDRWIDTH (ARQ_TX_BUFFER_ADDR_WIDTH)
    ) arq_bvt (
        .clk     (clk_i),
        .reset   (~reset_q_i),

        .ena     (bvt_wr_en),
        .wea     ({((BVT_DATA_SIZE+7)/8){1'b1}}),
        .addra   (bvt_wr_ptr),
        .dina    (bvt_wdata),

        .enb     (bvt_rd_en),
        .addrb   (r_bvt_rd_ptr),
        .doutb   ({bvt_rdata_pos, bvt_rdata_length, bvt_rdata_modid, bvt_rdata_chipid, bvt_rdata_addr})
    );


    //FIFO to store incoming ACKs
    sync_fifo #(
        .DATA_WIDTH (ACK_FIFO_DATA_SIZE),
        .ADDR_WIDTH (3)
    ) ack_fifo (
        .clk_i		(clk_i),
        .resetn_i	(reset_q_i),

        .wr_en_i	(ack_wrreq_i),
        .wdata_i	({ack_src_modid, ack_src_chipid, ack_addr, ack_type}),
        .wfull_o	(ack_stall_o),

        .rd_en_i	(ack_fifo_pop),
        .rdata_o	({ack_fifo_src_modid, ack_fifo_src_chipid, ack_fifo_addr, ack_fifo_type}),
        .rempty_o	(ack_fifo_empty)
    );



    always @(posedge clk_i or negedge reset_q_i) begin
        if (reset_q_i == 1'b0) begin
            txb_write_state <= S_TXB_WRITE_FILL_BUF;
            txb_read_state <= S_TXB_READ_IDLE;
            ack_state <= S_ACK_IDLE;

            r_txb_wr_ptr <= {PTR_ADDR_WIDTH{1'b0}};
            r_txb_occ_ptr <= {PTR_ADDR_WIDTH{1'b0}};
            r_txb_mod_rd_ptr <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
            r_txb_resend_rd_ptr <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
            r_txb_rd_en <= 1'b0;
            r_txb_write_active <= 1'b0;

            r_txb_rdata_fromreg <= 1'b0;
            r_txb_arq_out <= 1'b0;
            r_txb_header_out <= {NOC_HEADER_SIZE{1'b0}};
            r_txb_payload_out <= {NOC_PAYLOAD_SIZE{1'b0}};

            r_bvt_mod_wr_ptr <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
            r_bvt_ack_wr_ptr <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
            r_bvt_occ_ptr <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
            r_bvt_rd_ptr <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};

            r_bvt_wdata_pos <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
            r_bvt_wdata_length <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
            r_bvt_wdata_modid <= {NOC_MODID_SIZE{1'b0}};
            r_bvt_wdata_chipid <= {NOC_CHIPID_SIZE{1'b0}};
            r_bvt_wdata_addr <= {NOC_ADDR_SIZE{1'b0}};

            r_bvt_valid_entry <= {ARQ_TX_BUFFER_DEPTH{1'b0}};

            r_resend_pos <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
            r_resend_length <= {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};

            r_forward <= 1'b0;
            r_mod_burst <= 1'b0;
            r_noc_stall <= 1'b0;
        end
        else begin
            txb_write_state <= next_txb_write_state;
            txb_read_state <= next_txb_read_state;
            ack_state <= next_ack_state;

            r_txb_wr_ptr <= rin_txb_wr_ptr;
            r_txb_mod_rd_ptr <= rin_txb_mod_rd_ptr;
            r_txb_resend_rd_ptr <= rin_txb_resend_rd_ptr;
            r_txb_occ_ptr <= rin_txb_occ_ptr;
            r_txb_rd_en <= rin_txb_rd_en;
            r_txb_write_active <= rin_txb_write_active;

            r_txb_rdata_fromreg <= rin_txb_rdata_fromreg;
            r_txb_arq_out <= rin_txb_arq_out;
            r_txb_header_out <= rin_txb_header_out;
            r_txb_payload_out <= rin_txb_payload_out;

            r_bvt_mod_wr_ptr <= rin_bvt_mod_wr_ptr;
            r_bvt_ack_wr_ptr <= rin_bvt_ack_wr_ptr;
            r_bvt_occ_ptr <= rin_bvt_occ_ptr;
            r_bvt_rd_ptr <= rin_bvt_rd_ptr;

            r_bvt_wdata_pos <= rin_bvt_wdata_pos;
            r_bvt_wdata_length <= rin_bvt_wdata_length;
            r_bvt_wdata_modid <= rin_bvt_wdata_modid;
            r_bvt_wdata_chipid <= rin_bvt_wdata_chipid;
            r_bvt_wdata_addr <= rin_bvt_wdata_addr;

            r_bvt_valid_entry <= rin_bvt_valid_entry;

            r_resend_pos <= rin_resend_pos;
            r_resend_length <= rin_resend_length;

            r_forward <= rin_forward;
            r_mod_burst <= (mod_wrreq_i && !mod_stall_o) ? mod_burst : r_mod_burst;
            r_noc_stall <= noc_stall_i;
        end
    end




    //handle packets from module
    always @* begin
        next_txb_write_state = txb_write_state;

        rin_txb_write_active = r_txb_write_active;

        txb_wr_en = 1'b0;
        rin_txb_wr_ptr = r_txb_wr_ptr;

        rin_bvt_mod_wr_ptr = r_bvt_mod_wr_ptr;

        rin_bvt_wdata_pos = r_bvt_wdata_pos;
        rin_bvt_wdata_length = r_bvt_wdata_length;
        rin_bvt_wdata_modid = r_bvt_wdata_modid;
        rin_bvt_wdata_chipid = r_bvt_wdata_chipid;
        rin_bvt_wdata_addr = r_bvt_wdata_addr;

        case(txb_write_state)
            S_TXB_WRITE_FILL_BUF: begin
                if (mod_wrreq_i && !rin_forward && !txb_full) begin
                    //write to TXB is active when entering here and stops in next txb_write_state
                    rin_txb_write_active = 1'b1;

                    txb_wr_en = 1'b1;
                    rin_txb_wr_ptr = r_txb_wr_ptr + 1;

                    if (!r_mod_burst) begin
                        //set packet info
                        rin_bvt_wdata_pos = r_txb_wr_ptr;
                        rin_bvt_wdata_modid = mod_trg_modid;
                        rin_bvt_wdata_chipid = mod_trg_chipid;
                        rin_bvt_wdata_addr = mod_addr;

                        //burst starts
                        if (mod_burst) begin
                            rin_bvt_wdata_length = mod_payload_i[ARQ_TX_BUFFER_ADDR_WIDTH-1:0] + 1; //burst length: payload flits + header flit
                        end

                        //single packet
                        else begin
                            rin_bvt_wdata_length = 1;
                        end
                    end

                    //mark packet in BVT when last packet of burst or single packet
                    if (!mod_burst) begin
                        next_txb_write_state = S_TXB_WRITE_SET_BVT;
                    end
                end
            end

            S_TXB_WRITE_SET_BVT: begin
                rin_txb_write_active = 1'b0;

                //go back when there is no write to BVT from ACK FSM
                if (ack_state != S_ACK_UPDATE_BVT) begin
                    rin_bvt_mod_wr_ptr = r_bvt_mod_wr_ptr + 1;
                    next_txb_write_state = S_TXB_WRITE_FILL_BUF;
                end
            end
        endcase
    end


    //check if packet from module can be forwarded
    always @* begin
        rin_forward = 1'b0;

        if (!r_mod_burst) begin
            //if ACK is enabled, store flits from module to buffer
            //otherwise directly send packet
            case(arq_enable_i)
                NOC_ARQ_ENABLE_OFF: begin
                    rin_forward = 1'b1;
                end
                NOC_ARQ_ENABLE_ON: begin
                    rin_forward = 1'b0;
                end
                default: begin
                    //do not check mod_wrreq_i to prevent timing loop
                    //unvalid values of rin_forward do not change behavior because mod_wrreq_i is also checked later
                    if (mod_arq) begin
                        rin_forward = 1'b0;
                    end else begin
                        rin_forward = 1'b1;
                    end
                end
            endcase
        end

        //keep forward flag during burst
        else if (r_forward) begin
            rin_forward = r_forward;
        end
    end


    //read flits from buffer and send it to the NoC
    always @* begin
        next_txb_read_state = txb_read_state;

        rin_txb_rd_en = 1'b0;
        rin_txb_mod_rd_ptr = r_txb_mod_rd_ptr;
        rin_txb_resend_rd_ptr = r_txb_resend_rd_ptr;
        txb_rd_ptr = {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};

        case(txb_read_state)
            //wait for something to send
            S_TXB_READ_IDLE: begin
                //resend due to NACK
                if (ack_state == S_ACK_RESEND_START) begin
                    rin_txb_resend_rd_ptr = r_resend_pos;
                    next_txb_read_state = S_TXB_READ_RESEND;
                end

                //send from tx_buffer
                else if (txb_data_avail) begin
                    next_txb_read_state = S_TXB_READ_SEND;
                end
            end

            //send data from tx_buffer
            S_TXB_READ_SEND: begin
                txb_rd_ptr = r_txb_mod_rd_ptr;

                if (!noc_stall_i) begin
                    if (txb_data_avail) begin
                        rin_txb_rd_en = 1'b1;
                        rin_txb_mod_rd_ptr = r_txb_mod_rd_ptr + 1;
                    end

                    //stop when there is nothing more
                    else begin
                        next_txb_read_state = S_TXB_READ_FINISH;
                    end
                end
                else begin
                    rin_txb_rd_en = r_txb_rd_en;
                end
            end

            //resend data from tx_buffer due to NACK
            S_TXB_READ_RESEND: begin
                txb_rd_ptr = r_txb_resend_rd_ptr;

                if (!noc_stall_i) begin
                    if (r_txb_resend_rd_ptr != resend_end_ptr) begin
                        rin_txb_rd_en = 1'b1;
                        rin_txb_resend_rd_ptr = r_txb_resend_rd_ptr + 1;
                    end

                    //stop when there is nothing more
                    else begin
                        next_txb_read_state = S_TXB_READ_FINISH;
                    end
                end
                else begin
                    rin_txb_rd_en = r_txb_rd_en;
                end
            end

            S_TXB_READ_FINISH: begin
                next_txb_read_state = S_TXB_READ_IDLE;
            end
        endcase
    end


    //register data from tx_buffer when NoC stalls
    always @* begin
        rin_txb_rdata_fromreg = r_txb_rdata_fromreg;
        rin_txb_arq_out = r_txb_arq_out;
        rin_txb_header_out = r_txb_header_out;
        rin_txb_payload_out = r_txb_payload_out;

        if (r_txb_rd_en && noc_stall_i && !r_noc_stall) begin
            rin_txb_rdata_fromreg = 1'b1;
            rin_txb_arq_out = txb_arq_out;
            rin_txb_header_out = txb_header_out;
            rin_txb_payload_out = txb_payload_out;
        end
        else if (!noc_stall_i) begin
            rin_txb_rdata_fromreg = 1'b0;
        end
    end


    always @* begin
        //check if arq bit must be forced to a given value
        case(arq_enable_i)
            NOC_ARQ_ENABLE_OFF: begin
                txb_arq_out = 1'b0;
            end
            NOC_ARQ_ENABLE_ON: begin
                txb_arq_out = 1'b1;
            end
            default: begin
                txb_arq_out = txb_header_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-1];
            end
        endcase

        //take packets from tx_buffer or from reg if NoC stalled in last cycle
        noc_wrreq_o = r_txb_rd_en;
        noc_header_o = r_txb_rdata_fromreg ?
                        {r_txb_header_out[NOC_HEADER_SIZE-1], r_txb_arq_out, r_txb_header_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-1:0]} :
                        {txb_header_out[NOC_HEADER_SIZE-1], txb_arq_out, txb_header_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-1:0]};
        noc_payload_o = r_txb_rdata_fromreg ? r_txb_payload_out : txb_payload_out;
        

        //forward packets
        //in this case arq bit is either zero or is forced to zero
        if (rin_forward && !txb_read_active) begin
            noc_wrreq_o = mod_wrreq_i;
            noc_header_o = {mod_header_i[NOC_HEADER_SIZE-1], 1'b0, mod_header_i[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-1:0]};
            noc_payload_o = mod_payload_i;
        end
    end

    assign mod_stall_o = rin_forward ? (noc_stall_i || txb_read_active) : (txb_full || (txb_write_state == S_TXB_WRITE_SET_BVT));



    //handle ACKs in state machine
    always @* begin
        next_ack_state = ack_state;

        rin_txb_occ_ptr = r_txb_occ_ptr;

        bvt_rd_en = 1'b0;
        rin_bvt_ack_wr_ptr = r_bvt_ack_wr_ptr;
        rin_bvt_occ_ptr = r_bvt_occ_ptr;
        rin_bvt_rd_ptr = r_bvt_rd_ptr;

        rin_resend_pos = r_resend_pos;
        rin_resend_length = r_resend_length;

        ack_fifo_pop = 1'b0;


        case(ack_state)
            //check incoming ACKs
            S_ACK_IDLE: begin
                if (!ack_fifo_empty) begin
                    bvt_rd_en = 1'b1;
                    rin_bvt_rd_ptr = r_bvt_rd_ptr + 1;
                    next_ack_state = S_ACK_CHECK;
                end
            end

            S_ACK_CHECK: begin
                bvt_rd_en = 1'b1;
                rin_bvt_rd_ptr = r_bvt_rd_ptr + 1;

                //check if it is a valid entry and if it is the ACK for the current occupied packet in buffer
                if (r_bvt_valid_entry[bvt_rd_ptr_decr] &&
                    (ack_fifo_src_modid == bvt_rdata_modid) &&
                    (ack_fifo_src_chipid == bvt_rdata_chipid) &&
                    (ack_fifo_addr == bvt_rdata_addr)) begin
                    ack_fifo_pop = 1'b1;

                    //ack packet in buffer
                    if (ack_fifo_type) begin
                        //move forward with bvt_occ_ptr when first packet in tx_buffer was acknowledged
                        //compare with rd_ptr-1 because we incremented it already
                        if (r_bvt_occ_ptr == bvt_rd_ptr_decr) begin
                            rin_bvt_occ_ptr = r_bvt_occ_ptr + 1;
                            rin_txb_occ_ptr = r_txb_occ_ptr + bvt_rdata_length;

                            next_ack_state = S_ACK_INCR_OCC_PTR;
                        end
                        else begin
                            next_ack_state = S_ACK_UPDATE_BVT;
                        end

                        //mark entry to remove from BVT
                        rin_bvt_ack_wr_ptr = bvt_rd_ptr_decr;
                    end

                    //NACK: send packet again
                    else begin
                        rin_resend_pos = bvt_rdata_pos;
                        rin_resend_length = bvt_rdata_length;
                        next_ack_state = S_ACK_RESEND_START;
                    end
                end

                //at the end, start from the beginning
                //this should not happen
                else if (r_bvt_rd_ptr == r_bvt_mod_wr_ptr) begin
                    rin_bvt_rd_ptr = r_bvt_occ_ptr;
                end
            end

            //increment occ_ptr until there is a valid entry in BVT or last entry is reached
            //goal is not to leave gaps with empty entries in BVT and tx_buffer
            S_ACK_INCR_OCC_PTR: begin
                bvt_rd_en = 1'b1;
                rin_bvt_rd_ptr = r_bvt_rd_ptr + 1;
                
                if (r_bvt_valid_entry[bvt_rd_ptr_decr] || (r_bvt_occ_ptr == r_bvt_mod_wr_ptr)) begin
                    next_ack_state = S_ACK_UPDATE_BVT;
                end
                else begin
                    //still increment occ_ptr
                    rin_bvt_occ_ptr = r_bvt_occ_ptr + 1;
                    rin_txb_occ_ptr = r_txb_occ_ptr + bvt_rdata_length;
                end
            end

            //remove entry that was ACKed
            S_ACK_UPDATE_BVT: begin
                //reset rd_ptr to start at the beginning with next incoming ACK
                //and to keep order of ACKs from same module
                rin_bvt_rd_ptr = r_bvt_occ_ptr;
                next_ack_state = S_ACK_IDLE;
            end


            //wait until resend can start
            S_ACK_RESEND_START: begin
                if (!txb_read_active) begin
                    next_ack_state = S_ACK_RESEND;
                end
            end

            //wait until resend is finished
            S_ACK_RESEND: begin
                if (!txb_read_active) begin
                    //reset rd_ptr to start at the beginning with next incoming ACK
                    //and to keep order of ACKs from same module
                    rin_bvt_rd_ptr = r_bvt_occ_ptr;
                    next_ack_state = S_ACK_IDLE;
                end
            end

            default: next_ack_state = S_ACK_IDLE;
        endcase
    end


    //write to BVT
    always @* begin
        bvt_wr_en = 1'b0;
        bvt_wr_ptr = {ARQ_TX_BUFFER_ADDR_WIDTH{1'b0}};
        bvt_wdata = {BVT_DATA_SIZE{1'b0}};

        rin_bvt_valid_entry = r_bvt_valid_entry;


        //incoming ACK: remove entry from BVT
        if (ack_state == S_ACK_UPDATE_BVT) begin
            //just set ptr, do not delete values at entry
            bvt_wr_ptr = r_bvt_ack_wr_ptr;

            //unset bit at ptr
            rin_bvt_valid_entry = r_bvt_valid_entry ^ ptr_to_bit_mask;
        end

        //new packet from module
        else if (txb_write_state == S_TXB_WRITE_SET_BVT) begin
            bvt_wr_en = 1'b1;
            bvt_wr_ptr = r_bvt_mod_wr_ptr;
            bvt_wdata = {r_bvt_wdata_pos, r_bvt_wdata_length, r_bvt_wdata_modid, r_bvt_wdata_chipid, r_bvt_wdata_addr};

            //set bit at ptr
            rin_bvt_valid_entry = r_bvt_valid_entry ^ ptr_to_bit_mask;
        end
    end


    assign arq_tx_bvt_mod_wr_ptr_o = {{(32-ARQ_TX_BUFFER_ADDR_WIDTH){1'b0}}, r_bvt_mod_wr_ptr};
    assign arq_tx_bvt_ack_wr_ptr_o = {{(32-ARQ_TX_BUFFER_ADDR_WIDTH){1'b0}}, r_bvt_ack_wr_ptr};
    assign arq_tx_bvt_occ_ptr_o = {{(32-ARQ_TX_BUFFER_ADDR_WIDTH){1'b0}}, r_bvt_occ_ptr};
    assign arq_tx_bvt_rd_ptr_o = {{(32-ARQ_TX_BUFFER_ADDR_WIDTH){1'b0}}, r_bvt_rd_ptr};

endmodule
