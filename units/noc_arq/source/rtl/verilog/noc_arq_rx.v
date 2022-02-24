
module noc_arq_rx #(
    `include "noc_parameter.vh"
    ,parameter ARQ_RX_BUFFER_ADDR_WIDTH = 8
)(
    input  wire                        clk_i,
    input  wire                        reset_q_i,

    //from NoC to module
    input  wire                        noc_wrreq_i,
    input  wire  [NOC_HEADER_SIZE-1:0] noc_header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] noc_payload_i,
    output wire                        noc_stall_o,
    output reg                         mod_wrreq_o,
    output wire  [NOC_HEADER_SIZE-1:0] mod_header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] mod_payload_o,
    input  wire                        mod_stall_i,

    //to send ACK
    output wire                        ack_wrreq_o,
    output wire  [NOC_HEADER_SIZE-1:0] ack_header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] ack_payload_o,
    input  wire                        ack_stall_i,

    //to regfile
    output reg                         reg_wrreq_o,
    output wire  [NOC_HEADER_SIZE-1:0] reg_header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] reg_payload_o,
    input  wire                        reg_stall_i,

    input  wire                 [31:0] arq_timeout_rx_cycles_i,
    output wire                 [31:0] noc_rx_count_o,
    output wire                 [31:0] noc_rx_drop_o,
    output wire                 [31:0] arq_rx_status_o
);

    localparam PACKET_ID_SIZE = ARQ_RX_BUFFER_ADDR_WIDTH;
    localparam COUNT_SIZE = ARQ_RX_BUFFER_ADDR_WIDTH;

    //FSM to read from rx_fifo
    localparam S_RXF_IDLE           = 3'h0;
    localparam S_RXF_POP            = 3'h1;
    localparam S_RXF_POPNACK        = 3'h2;
    localparam S_RXF_DROP           = 3'h3;
    localparam S_RXF_POP_ARQ_CONFIG = 3'h4;
    localparam S_RXF_ACK            = 3'h5;
    localparam S_RXF_NACK           = 3'h6;
    reg [2:0] rxf_state, next_rxf_state;

    reg [31:0] r_timeout, rin_timeout;

    reg               [31:0] r_noc_packet_id, rin_noc_packet_id;    //also used as packet counter
    reg [PACKET_ID_SIZE-1:0] r_drop_packet_id, rin_drop_packet_id;

    reg [COUNT_SIZE-1:0] r_burst_count_in, rin_burst_count_in;
    reg [COUNT_SIZE-1:0] r_burst_count_out, rin_burst_count_out;

    reg  [NOC_MODID_SIZE-1:0] r_rxf_src_modid, rin_rxf_src_modid;
    reg [NOC_CHIPID_SIZE-1:0] r_rxf_src_chipid, rin_rxf_src_chipid;
    reg  [NOC_MODID_SIZE-1:0] r_rxf_trg_modid, rin_rxf_trg_modid;
    reg [NOC_CHIPID_SIZE-1:0] r_rxf_trg_chipid, rin_rxf_trg_chipid;
    reg   [NOC_ADDR_SIZE-1:0] r_rxf_addr, rin_rxf_addr;

    //number of dropped packets
    reg [31:0] r_noc_rx_drop, rin_noc_rx_drop;

    reg r_noc_burst;
    reg r_rxf_burst;
    reg r_rxf_mode_type2;

    reg arq_type;


    reg                         rxf_pop;
    wire                        rxf_full;
    wire                        rxf_empty;
    wire   [PACKET_ID_SIZE-1:0] rxf_packet_id_out;
    wire  [NOC_HEADER_SIZE-1:0] rxf_header_out;
    wire [NOC_PAYLOAD_SIZE-1:0] rxf_payload_out;


    wire                       noc_burst = noc_header_i[NOC_HEADER_SIZE-1];

    wire                       rxf_burst_out = mod_header_o[NOC_HEADER_SIZE-1];
    wire                       rxf_arq_out = mod_header_o[2*NOC_MODID_SIZE+2*NOC_CHIPID_SIZE+NOC_BSEL_SIZE +: NOC_ARQ_SIZE];
    wire  [NOC_MODID_SIZE-1:0] rxf_src_modid_out = mod_header_o[NOC_MODID_SIZE+2*NOC_CHIPID_SIZE +: NOC_MODID_SIZE];
    wire [NOC_CHIPID_SIZE-1:0] rxf_src_chipid_out = mod_header_o[NOC_MODID_SIZE+NOC_CHIPID_SIZE +: NOC_CHIPID_SIZE];
    wire  [NOC_MODID_SIZE-1:0] rxf_trg_modid_out = mod_header_o[NOC_MODID_SIZE+NOC_CHIPID_SIZE-1 : NOC_CHIPID_SIZE];
    wire [NOC_CHIPID_SIZE-1:0] rxf_trg_chipid_out = mod_header_o[NOC_CHIPID_SIZE-1:0];
    wire   [NOC_MODE_SIZE-1:0] rxf_mode_out = mod_payload_o[NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_ADDR_SIZE+NOC_DATA_SIZE];
    wire   [NOC_ADDR_SIZE-1:0] rxf_addr_out = mod_payload_o[NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_DATA_SIZE];

    //0: normal modes, 1: special modes
    wire rxf_mode_type2 = ((rxf_mode_out == MODE_READ_REQ_2) ||
                            (rxf_mode_out == MODE_READ_RSP_2) ||
                            (rxf_mode_out == MODE_WRITE_POSTED_2)) ? 1'b1 : 1'b0;

    //check if it is an ARQ config packet
    wire rxf_mode_arq_config = ((rxf_mode_out == MODE_ARQ_READ_REQ) ||
                                (rxf_mode_out == MODE_ARQ_WRITE_POSTED)) ? 1'b1 : 1'b0;

    //counter detect number of finished bursts
    wire burst_ready = (r_burst_count_in > r_burst_count_out);

    //overflow when count_in reaches limit - reset counter and keep difference
    wire count_limit = (r_burst_count_in == {COUNT_SIZE{1'b1}});

    wire reset_burst_count = count_limit && noc_wrreq_i && !rxf_full && !r_noc_burst;



    //FIFO to store incoming flits (RXF)
    sync_fifo #(
        .DATA_WIDTH (NOC_HEADER_SIZE+NOC_PAYLOAD_SIZE+PACKET_ID_SIZE),
        .ADDR_WIDTH (ARQ_RX_BUFFER_ADDR_WIDTH)
    ) arq_rx_fifo (
        .clk_i      (clk_i),
        .resetn_i   (reset_q_i),

        .wr_en_i    (noc_wrreq_i && !rxf_full),
        .wdata_i    ({noc_header_i, noc_payload_i, r_noc_packet_id[PACKET_ID_SIZE-1:0]}),
        .wfull_o    (rxf_full),

        .rd_en_i    (rxf_pop),
        .rdata_o    ({rxf_header_out, rxf_payload_out, rxf_packet_id_out}),
        .rempty_o   (rxf_empty)
    );

    assign noc_stall_o = rxf_full;



    always @(posedge clk_i or negedge reset_q_i) begin
        if (reset_q_i == 1'b0) begin
            rxf_state <= S_RXF_IDLE;

            r_timeout <= 32'h0;

            r_noc_packet_id <= 32'h0;
            r_drop_packet_id <= {PACKET_ID_SIZE{1'b0}};

            r_burst_count_in <= {COUNT_SIZE{1'b0}};
            r_burst_count_out <= {COUNT_SIZE{1'b0}};

            r_rxf_src_modid <= {NOC_MODID_SIZE{1'b0}};
            r_rxf_src_chipid <= {NOC_CHIPID_SIZE{1'b0}};
            r_rxf_trg_modid <= {NOC_MODID_SIZE{1'b0}};
            r_rxf_trg_chipid <= {NOC_CHIPID_SIZE{1'b0}};
            r_rxf_addr <= {NOC_ADDR_SIZE{1'b0}};

            r_noc_rx_drop <= 32'h0;

            r_noc_burst <= 1'b0;
            r_rxf_burst <= 1'b0;
            r_rxf_mode_type2 <= 1'b0;
        end
        else begin
            rxf_state <= next_rxf_state;

            r_timeout <= rin_timeout;

            r_noc_packet_id <= rin_noc_packet_id;
            r_drop_packet_id <= rin_drop_packet_id;

            r_burst_count_in <= rin_burst_count_in;
            r_burst_count_out <= rin_burst_count_out;

            r_rxf_src_modid <= rin_rxf_src_modid;
            r_rxf_src_chipid <= rin_rxf_src_chipid;
            r_rxf_trg_modid <= rin_rxf_trg_modid;
            r_rxf_trg_chipid <= rin_rxf_trg_chipid;
            r_rxf_addr <= rin_rxf_addr;

            r_noc_rx_drop <= rin_noc_rx_drop;

            r_noc_burst <= (noc_wrreq_i && !noc_stall_o) ? noc_burst : r_noc_burst;
            r_rxf_burst <= rxf_pop ? rxf_burst_out : r_rxf_burst;
            r_rxf_mode_type2 <= (rxf_pop && !r_rxf_burst) ? rxf_mode_type2 : r_rxf_mode_type2;
        end
    end


    //FIFO input handling
    always @* begin
        rin_noc_packet_id = r_noc_packet_id;
        rin_burst_count_in = r_burst_count_in;


        if (noc_wrreq_i && !rxf_full) begin
            //assign packet id when single packet or last burst flit 
            if (!noc_burst) begin
                //set and count received packets
                rin_noc_packet_id = r_noc_packet_id + 1;
            end

            //single packet or header of burst
            if (!r_noc_burst) begin
                //overflow: decrement counter and keep difference to count_out
                if (count_limit) begin
                    rin_burst_count_in = r_burst_count_in - r_burst_count_out;
                end
            end
            
            //if it is last flit of burst increment counter
            else if (!noc_burst) begin
                rin_burst_count_in = r_burst_count_in + 1;
            end
        end

        //reset counter if no wrreq anymore and FIFO becomes empty
        else if (rxf_empty) begin
            rin_burst_count_in = {COUNT_SIZE{1'b0}};
        end
    end



    //FIFO output handling
    always @* begin
        next_rxf_state = rxf_state;

        rin_timeout = 32'h0;

        rin_burst_count_out = r_burst_count_out;

        rin_drop_packet_id = r_drop_packet_id;

        rin_rxf_src_modid = r_rxf_src_modid;
        rin_rxf_src_chipid = r_rxf_src_chipid;
        rin_rxf_trg_modid = r_rxf_trg_modid;
        rin_rxf_trg_chipid = r_rxf_trg_chipid;
        rin_rxf_addr = r_rxf_addr;

        rin_noc_rx_drop = r_noc_rx_drop;

        mod_wrreq_o = 1'b0;
        rxf_pop = 1'b0;

        arq_type = 1'b0;

        reg_wrreq_o = 1'b0;


        //overflow or RXF empty: reset count_out together with count_in
        if (rxf_empty || reset_burst_count) begin
            rin_burst_count_out = {COUNT_SIZE{1'b0}};
        end


        case(rxf_state)
            S_RXF_IDLE: begin
                if (!rxf_empty) begin
                    //keep ids for ACK (this is always a single flit or burst header)
                    rin_rxf_src_modid = rxf_src_modid_out;
                    rin_rxf_src_chipid = rxf_src_chipid_out;
                    rin_rxf_trg_modid = rxf_trg_modid_out;
                    rin_rxf_trg_chipid = rxf_trg_chipid_out;
                    rin_rxf_addr = rxf_addr_out;

                    //check if it is an ARQ config packet (must not be a burst)
                    if (rxf_mode_arq_config && !rxf_burst_out) begin
                        next_rxf_state = S_RXF_POP_ARQ_CONFIG;
                    end

                    //no config packet, check ARQ bit
                    else if (rxf_arq_out) begin
                        next_rxf_state = S_RXF_POPNACK;
                    end

                    //if ARQ is disabled, just pop FIFO (we do not expect to drop these packets)
                    else begin
                        next_rxf_state = S_RXF_POP;
                    end
                end
            end

            //no ACK expected, just forward packets
            S_RXF_POP: begin
                if (!rxf_empty) begin
                    mod_wrreq_o = 1'b1;

                    if (!mod_stall_i) begin
                        rxf_pop = 1'b1;

                        //detect last flit of outgoing burst to increment counter
                        if (!rxf_burst_out && r_rxf_burst) begin
                            rin_burst_count_out = r_burst_count_out + 1;

                            //if incr and reset is at the same time, only take the +1
                            if (reset_burst_count) begin
                                rin_burst_count_out = 1;
                            end
                        end

                        //stop
                        if (!rxf_burst_out) begin
                            next_rxf_state = S_RXF_IDLE;
                        end
                    end
                end
            end


            //forward packets and send ACK afterwards
            S_RXF_POPNACK: begin
                //if it is not a burst or last flit of burst has arrived in FIFO - take it
                if (!rxf_empty && (!rxf_burst_out || burst_ready)) begin
                    mod_wrreq_o = 1'b1;

                    if (!mod_stall_i) begin
                        rxf_pop = 1'b1;

                        //detect last flit of outgoing burst to increment counter
                        if (!rxf_burst_out && r_rxf_burst) begin
                            rin_burst_count_out = r_burst_count_out + 1;

                            //if incr and reset is at the same time, only take the +1
                            if (reset_burst_count) begin
                                rin_burst_count_out = 1;
                            end
                        end

                        //stop
                        if (!rxf_burst_out) begin
                            next_rxf_state = S_RXF_ACK;
                        end
                    end

                    //timeout if module stucks for certain time
                    else begin
                        rin_timeout = r_timeout + 32'd1;
                        if (r_timeout > arq_timeout_rx_cycles_i) begin
                            rin_drop_packet_id = r_noc_packet_id[PACKET_ID_SIZE-1:0];
                            next_rxf_state = S_RXF_DROP;
                        end
                    end
                end
            end


            //timeout: drop packets
            S_RXF_DROP: begin
                if (!rxf_empty) begin
                    rxf_pop = 1'b1;

                    //stop when last packet of burst or non-burst packet
                    if (!rxf_burst_out) begin
                        //count dropped packets
                        rin_noc_rx_drop = r_noc_rx_drop + 1;

                        //mark dropped burst in burst counter, too
                        if (r_rxf_burst) begin
                            rin_burst_count_out = r_burst_count_out + 1;

                            //if incr and reset is at the same time, only take the +1
                            if (reset_burst_count) begin
                                rin_burst_count_out = 1;
                            end
                        end

                        next_rxf_state = S_RXF_NACK;
                    end
                end
            end


            //forward packet to regfile
            S_RXF_POP_ARQ_CONFIG: begin
                if (!rxf_empty) begin
                    reg_wrreq_o = 1'b1;

                    if (!reg_stall_i) begin
                        rxf_pop = 1'b1;

                        //maybe we must send an ACK, too
                        if (rxf_arq_out) begin
                            next_rxf_state = S_RXF_ACK;
                        end else begin
                            next_rxf_state = S_RXF_IDLE;
                        end
                    end
                end
            end


            //send ACK back to sender
            S_RXF_ACK: begin
                if (!ack_stall_i) begin
                    arq_type = 1'b1;
                    next_rxf_state = S_RXF_IDLE;
                end
            end

            //timeout: send NACK back to sender
            S_RXF_NACK: begin
                if (!ack_stall_i) begin
                    arq_type = 1'b0;

                    if (!rxf_empty) begin
                        //drop until marked packet id is reached or when NoC mode switches (normal and special modes)
                        if ((rxf_packet_id_out == r_drop_packet_id) || (!r_rxf_burst && (rxf_mode_type2 != r_rxf_mode_type2))) begin
                            next_rxf_state = S_RXF_IDLE;
                        end
                        
                        //go back and drop more packets
                        else begin
                            //store NACK info of new packet
                            rin_rxf_src_modid = rxf_src_modid_out;
                            rin_rxf_src_chipid = rxf_src_chipid_out;
                            rin_rxf_trg_modid = rxf_trg_modid_out;
                            rin_rxf_trg_chipid = rxf_trg_chipid_out;
                            rin_rxf_addr = rxf_addr_out;

                            next_rxf_state = S_RXF_DROP;
                        end
                    end
                    else begin
                        next_rxf_state = S_RXF_IDLE;
                    end
                end
            end

            default: next_rxf_state = S_RXF_IDLE;
        endcase
    end

    assign mod_header_o = rxf_header_out;
    assign mod_payload_o = rxf_payload_out;

    assign reg_header_o = rxf_header_out;
    assign reg_payload_o = rxf_payload_out;

    assign ack_wrreq_o = (rxf_state == S_RXF_ACK) || (rxf_state == S_RXF_NACK);
    assign ack_header_o = {1'b0,                    //burst
                            1'b0,                   //arq
                            {NOC_BSEL_SIZE{1'b1}},  //bsel
                            r_rxf_trg_modid,        //swap src and trg because we send it back
                            r_rxf_trg_chipid,
                            r_rxf_src_modid,
                            r_rxf_src_chipid};
    assign ack_payload_o = {MODE_ARQ_ACK,                           //mode
                            r_rxf_addr,                             //addr
                            {{(NOC_DATA_SIZE-1){1'b0}}, arq_type}}; //data


    assign noc_rx_count_o = r_noc_packet_id;
    assign noc_rx_drop_o = r_noc_rx_drop;

    assign arq_rx_status_o = {27'h0, rxf_empty, rxf_full, rxf_state};

endmodule
