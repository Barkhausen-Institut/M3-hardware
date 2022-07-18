
module udp_noc_bridge #(
    `include "noc_parameter.vh"
    ,parameter NOC_FLIT_SIZE = (NOC_PAYLOAD_SIZE + NOC_HEADER_SIZE),
    parameter FPGA_IP_BASE   = {8'd192, 8'd168, 8'd42, 8'd240}
)
(
    input  wire                       clk_eth_i,
    input  wire                       rst_eth_n_i,

    input  wire                       noc_rx_fifo_empty_i,
    output wire                       noc_rx_read_en_o,
    input  wire   [NOC_FLIT_SIZE-1:0] noc_rx_data_i,
    input  wire                       noc_tx_fifo_full_i,
    output wire                       noc_tx_data_valid_o,
    output wire   [NOC_FLIT_SIZE-1:0] noc_tx_data_o,

    output wire                       tx_udp_hdr_valid_o,
    input  wire                       tx_udp_hdr_ready_i,
    output wire                 [5:0] tx_udp_ip_dscp_o,
    output wire                 [1:0] tx_udp_ip_ecn_o,
    output wire                 [7:0] tx_udp_ip_ttl_o,
    output wire                [31:0] tx_udp_ip_source_ip_o,
    output reg                 [31:0] tx_udp_ip_dest_ip_o,
    output wire                [15:0] tx_udp_source_port_o,
    output reg                 [15:0] tx_udp_dest_port_o,
    output wire                [15:0] tx_udp_length_o,
    output wire                [15:0] tx_udp_checksum_o,
    output reg                  [7:0] tx_udp_payload_axis_tdata_o,
    output wire                       tx_udp_payload_axis_tvalid_o,
    input  wire                       tx_udp_payload_axis_tready_i,
    output reg                        tx_udp_payload_axis_tlast_o,
    output wire                       tx_udp_payload_axis_tuser_o,

    input  wire                       rx_udp_hdr_valid_i,
    output wire                       rx_udp_hdr_ready_o,
    input  wire                [47:0] rx_udp_eth_dest_mac_i,
    input  wire                [47:0] rx_udp_eth_src_mac_i,
    input  wire                [15:0] rx_udp_eth_type_i,
    input  wire                 [3:0] rx_udp_ip_version_i,
    input  wire                 [3:0] rx_udp_ip_ihl_i,
    input  wire                 [5:0] rx_udp_ip_dscp_i,
    input  wire                 [1:0] rx_udp_ip_ecn_i,
    input  wire                [15:0] rx_udp_ip_length_i,
    input  wire                [15:0] rx_udp_ip_identification_i,
    input  wire                 [2:0] rx_udp_ip_flags_i,
    input  wire                [12:0] rx_udp_ip_fragment_offset_i,
    input  wire                 [7:0] rx_udp_ip_ttl_i,
    input  wire                 [7:0] rx_udp_ip_protocol_i,
    input  wire                [15:0] rx_udp_ip_header_checksum_i,
    input  wire                [31:0] rx_udp_ip_source_ip_i,
    input  wire                [31:0] rx_udp_ip_dest_ip_i,
    input  wire                [15:0] rx_udp_source_port_i,
    input  wire                [15:0] rx_udp_dest_port_i,
    input  wire                [15:0] rx_udp_length_i,
    input  wire                [15:0] rx_udp_checksum_i,
    input  wire                 [7:0] rx_udp_payload_axis_tdata_i,
    input  wire                       rx_udp_payload_axis_tvalid_i,
    output wire                       rx_udp_payload_axis_tready_o,
    input  wire                       rx_udp_payload_axis_tlast_i,
    input  wire                       rx_udp_payload_axis_tuser_i,

    input  wire                [15:0] fpga_port_i,
    input  wire                [31:0] fpga_ip_addr_i,
    input  wire                [15:0] host_port_i,
    input  wire                [31:0] host_ip_addr_i,
    input  wire [NOC_CHIPID_SIZE-1:0] host_chipid_i,
    output wire                [31:0] rx_udp_source_ip_o,

    output wire                [31:0] rx_udp_error_o
);


localparam RX_UDP_FIFO_DWIDTH    = 9;   //1 byte + last flag
localparam RX_UDP_FIFO_AWIDTH    = 14;  //16384
localparam RX_UDP_IP_FIFO_AWIDTH = 10;  //1024 (ca. RX_UDP_FIFO_AWIDTH/18)


reg  [4:0] r_rx_udp_tmp_count, rin_rx_udp_tmp_count;
reg [31:0] r_rx_udp_error, rin_rx_udp_error;
reg [15:0] r_rx_udp_dest_port, rin_rx_udp_dest_port;
reg [31:0] r_rx_udp_ip_dest_ip, rin_rx_udp_ip_dest_ip;

reg [31:0] r_rx_udp_ip_source_ip;
reg [31:0] r_rx_udp_ip_fifo_source_ip;

reg [NOC_FLIT_SIZE-1:0] r_noc_tx_data, rin_noc_tx_data;
reg                     r_noc_tx_data_valid, rin_noc_tx_data_valid;


//we can take the UDP packet if port and IP addr matches
wire       rx_udp_fifo_push = rx_udp_payload_axis_tvalid_i &&
                                (r_rx_udp_dest_port == fpga_port_i) &&
                                (r_rx_udp_ip_dest_ip == fpga_ip_addr_i);

wire [7:0] rx_udp_fifo_tdata;
wire       rx_udp_fifo_tlast;
wire       rx_udp_fifo_empty;
wire       rx_udp_fifo_full;
reg        rx_udp_fifo_pop;

wire        rx_udp_ip_fifo_push = !rx_udp_fifo_full && rx_udp_fifo_push && rx_udp_payload_axis_tlast_i;
wire        rx_udp_ip_fifo_pop = rx_udp_fifo_pop && rx_udp_fifo_tlast;
wire [31:0] rx_udp_ip_fifo_source_ip;


//18 bytes in NoC packet
wire tmp_count_last = (r_rx_udp_tmp_count == 5'd17);

//stall from NoC is only interesting when we want to push a NoC packet
wire noc_tx_stall = noc_tx_fifo_full_i && (tmp_count_last || (rx_udp_fifo_tlast && !rx_udp_fifo_empty));


assign noc_tx_data_valid_o = r_noc_tx_data_valid;
assign noc_tx_data_o = r_noc_tx_data;

assign rx_udp_hdr_ready_o = 1'b1;
assign rx_udp_payload_axis_tready_o = !rx_udp_fifo_full;

//source IP address to set host IP
assign rx_udp_source_ip_o = r_rx_udp_ip_fifo_source_ip;

assign rx_udp_error_o = r_rx_udp_error;

//FIFO to store UDP data
sync_fifo #(
    .DATA_WIDTH (RX_UDP_FIFO_DWIDTH),
    .ADDR_WIDTH (RX_UDP_FIFO_AWIDTH)
) i_rx_udp_fifo (
    .clk_i		(clk_eth_i),
    .resetn_i	(rst_eth_n_i),

    .wr_en_i	(rx_udp_fifo_push),
    .wdata_i	({rx_udp_payload_axis_tlast_i, rx_udp_payload_axis_tdata_i}),
    .wfull_o	(rx_udp_fifo_full),

    .rd_en_i	(rx_udp_fifo_pop),
    .rdata_o	({rx_udp_fifo_tlast, rx_udp_fifo_tdata}),
    .rempty_o	(rx_udp_fifo_empty)
);

//FIFO to store source IP address from UDP header
sync_fifo #(
    .DATA_WIDTH (32),
    .ADDR_WIDTH (RX_UDP_IP_FIFO_AWIDTH)
) i_rx_udp_ip_fifo (
    .clk_i		(clk_eth_i),
    .resetn_i	(rst_eth_n_i),

    .wr_en_i	(rx_udp_ip_fifo_push),
    .wdata_i	(r_rx_udp_ip_source_ip),
    .wfull_o	(), //ignore full and empty because it is in sync with rx_udp_fifo

    .rd_en_i	(rx_udp_ip_fifo_pop),
    .rdata_o	(rx_udp_ip_fifo_source_ip),
    .rempty_o	()
);


always @(posedge clk_eth_i or negedge rst_eth_n_i) begin
    if (rst_eth_n_i == 1'b0) begin
        r_rx_udp_tmp_count <= 5'h0;
        r_rx_udp_error <= 32'h0;
        r_rx_udp_dest_port <= 16'h0;
        r_rx_udp_ip_dest_ip <= 32'h0;
        r_rx_udp_ip_source_ip <= 32'h0;
        r_rx_udp_ip_fifo_source_ip <= 32'h0;

        r_noc_tx_data <= {NOC_FLIT_SIZE{1'b0}};
        r_noc_tx_data_valid <= 1'b0;
    end
    else begin
        r_rx_udp_tmp_count <= rin_rx_udp_tmp_count;
        r_rx_udp_error <= rin_rx_udp_error;
        r_rx_udp_dest_port <= rin_rx_udp_dest_port;
        r_rx_udp_ip_dest_ip <= rin_rx_udp_ip_dest_ip;
        r_rx_udp_ip_source_ip <= rx_udp_hdr_valid_i ? rx_udp_ip_source_ip_i : r_rx_udp_ip_source_ip;
        r_rx_udp_ip_fifo_source_ip <= rx_udp_ip_fifo_pop ? rx_udp_ip_fifo_source_ip : r_rx_udp_ip_fifo_source_ip;

        r_noc_tx_data <= rin_noc_tx_data;
        r_noc_tx_data_valid <= rin_noc_tx_data_valid;
    end
end


always @* begin
    rin_noc_tx_data = r_noc_tx_data;

    if (!rx_udp_fifo_empty && !noc_tx_stall) begin
        case (r_rx_udp_tmp_count)
            5'd00: rin_noc_tx_data[137:136] = rx_udp_fifo_tdata[1:0];     //flit has only 138 bit (NOC_FLIT_SIZE)
            5'd01: rin_noc_tx_data[135:128] = rx_udp_fifo_tdata;
            5'd02: rin_noc_tx_data[127:120] = rx_udp_fifo_tdata;
            5'd03: rin_noc_tx_data[119:112] = rx_udp_fifo_tdata;
            5'd04: rin_noc_tx_data[111:104] = rx_udp_fifo_tdata;
            5'd05: rin_noc_tx_data[103: 96] = rx_udp_fifo_tdata;
            5'd06: rin_noc_tx_data[ 95: 88] = rx_udp_fifo_tdata;
            5'd07: rin_noc_tx_data[ 87: 80] = rx_udp_fifo_tdata;
            5'd08: rin_noc_tx_data[ 79: 72] = rx_udp_fifo_tdata;
            5'd09: rin_noc_tx_data[ 71: 64] = rx_udp_fifo_tdata;
            5'd10: rin_noc_tx_data[ 63: 56] = rx_udp_fifo_tdata;
            5'd11: rin_noc_tx_data[ 55: 48] = rx_udp_fifo_tdata;
            5'd12: rin_noc_tx_data[ 47: 40] = rx_udp_fifo_tdata;
            5'd13: rin_noc_tx_data[ 39: 32] = rx_udp_fifo_tdata;
            5'd14: rin_noc_tx_data[ 31: 24] = rx_udp_fifo_tdata;
            5'd15: rin_noc_tx_data[ 23: 16] = rx_udp_fifo_tdata;
            5'd16: rin_noc_tx_data[ 15:  8] = rx_udp_fifo_tdata;
            5'd17: rin_noc_tx_data[  7:  0] = rx_udp_fifo_tdata;
            default: rin_noc_tx_data = {NOC_FLIT_SIZE{1'b0}};
        endcase
    end
end


//hold dest_port and dest_ip
always @* begin
    rin_rx_udp_dest_port = r_rx_udp_dest_port;
    rin_rx_udp_ip_dest_ip = r_rx_udp_ip_dest_ip;

    if (rx_udp_hdr_valid_i) begin
        rin_rx_udp_dest_port = rx_udp_dest_port_i;
        rin_rx_udp_ip_dest_ip = rx_udp_ip_dest_ip_i;
    end
    else if (!rx_udp_fifo_full && rx_udp_payload_axis_tvalid_i && rx_udp_payload_axis_tlast_i) begin
        rin_rx_udp_dest_port = 16'h0;
        rin_rx_udp_ip_dest_ip = 32'h0;
    end
end


always @* begin
    rx_udp_fifo_pop = 1'b0;
    rin_rx_udp_tmp_count = r_rx_udp_tmp_count;
    rin_rx_udp_error = r_rx_udp_error;

    rin_noc_tx_data_valid = r_noc_tx_data_valid;


    if (!noc_tx_stall) begin
        if (!rx_udp_fifo_empty) begin
            rx_udp_fifo_pop = 1'b1;

            if (tmp_count_last) begin
                rin_rx_udp_tmp_count = 5'h0;
                rin_noc_tx_data_valid = 1'b1;
            end
            else if (rx_udp_fifo_tlast) begin
                //last byte but packet is not full, do not push packet and indicate error
                rin_rx_udp_error = r_rx_udp_error + 1;
                rin_rx_udp_tmp_count = 5'h0;
            end
            else begin
                rin_rx_udp_tmp_count = r_rx_udp_tmp_count + 1;
            end
        end

        //deassert valid in next cycle when NoC FIFO was not full
        if (r_noc_tx_data_valid) begin
            rin_noc_tx_data_valid = 1'b0;
        end
    end
end



//------------------------------------------------------

localparam NOC_RX_FIFO_AWIDTH = 6;

localparam MAX_TX_UDP_LENGTH_BYTE = 1472;    //max number of bytes for payload
localparam MAX_TX_UDP_LENGTH_NOC = (MAX_TX_UDP_LENGTH_BYTE/18)-1;    //i.e. 80 NoC packets with 18 bytes per packet

localparam S_TX_UDP_IDLE          = 2'h0;
localparam S_TX_UDP_SEND_HDR      = 2'h1;
localparam S_TX_UDP_SEND_PAYLOAD  = 2'h2;
localparam S_TX_UDP_NEXT_NOC_FLIT = 2'h3;

reg [1:0] tx_udp_state, next_tx_udp_state;

reg  [4:0] r_tx_udp_tmp_count, rin_tx_udp_tmp_count;
reg [15:0] r_tx_udp_payload_count, rin_tx_udp_payload_count;

reg [31:0] r_tx_udp_ip_dest_ip;
reg [15:0] r_tx_udp_dest_port;

reg    [NOC_FLIT_SIZE-1:0] r_noc_rx_fifo_rdata, rin_noc_rx_fifo_rdata;
wire   [NOC_FLIT_SIZE-1:0] noc_rx_fifo_rdata;
reg                        r_noc_rx_fifo_burst;
reg  [NOC_CHIPID_SIZE-1:0] r_noc_rx_fifo_chipid;

wire                       noc_rx_fifo_burst = noc_rx_fifo_rdata[NOC_FLIT_SIZE-1];
wire [NOC_CHIPID_SIZE-1:0] noc_rx_fifo_chipid = noc_rx_fifo_rdata[NOC_CHIPID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE];

wire noc_rx_fifo_full;
wire noc_rx_fifo_push;
reg  noc_rx_fifo_pop;
wire noc_rx_fifo_empty;


wire tx_udp_hdr_active = (tx_udp_state == S_TX_UDP_SEND_HDR);
wire tx_udp_payload_active = (tx_udp_state == S_TX_UDP_SEND_PAYLOAD);

assign noc_rx_fifo_push = !noc_rx_fifo_empty_i;
assign noc_rx_read_en_o = !noc_rx_fifo_full;


sync_fifo #(
    .DATA_WIDTH (NOC_FLIT_SIZE),
    .ADDR_WIDTH (NOC_RX_FIFO_AWIDTH)
) i_noc_rx_fifo (
    .clk_i		(clk_eth_i),
    .resetn_i	(rst_eth_n_i),

    .wr_en_i	(noc_rx_fifo_push),
    .wdata_i	(noc_rx_data_i),
    .wfull_o	(noc_rx_fifo_full),

    .rd_en_i	(noc_rx_fifo_pop),
    .rdata_o	(noc_rx_fifo_rdata),
    .rempty_o	(noc_rx_fifo_empty)
);


always @(posedge clk_eth_i or negedge rst_eth_n_i) begin
    if (rst_eth_n_i == 1'b0) begin
        tx_udp_state <= S_TX_UDP_IDLE;

        r_tx_udp_tmp_count <= 5'h0;
        r_tx_udp_payload_count <= 16'h0;

        r_tx_udp_ip_dest_ip <= 32'h0;
        r_tx_udp_dest_port <= 16'h0;

        r_noc_rx_fifo_rdata <= {NOC_FLIT_SIZE{1'b0}};

        r_noc_rx_fifo_burst <= 1'b0;
        r_noc_rx_fifo_chipid <= {NOC_CHIPID_SIZE{1'b0}};
    end
    else begin
        tx_udp_state <= next_tx_udp_state;

        r_tx_udp_tmp_count <= rin_tx_udp_tmp_count;
        r_tx_udp_payload_count <= rin_tx_udp_payload_count;

        r_tx_udp_ip_dest_ip <= tx_udp_ip_dest_ip_o;
        r_tx_udp_dest_port <= tx_udp_dest_port_o;

        r_noc_rx_fifo_rdata <= rin_noc_rx_fifo_rdata;

        r_noc_rx_fifo_burst <= noc_rx_fifo_pop ? noc_rx_fifo_burst : r_noc_rx_fifo_burst;
        r_noc_rx_fifo_chipid <= (noc_rx_fifo_pop && !r_noc_rx_fifo_burst) ? noc_rx_fifo_chipid : r_noc_rx_fifo_chipid;
    end
end


always @* begin
    tx_udp_payload_axis_tdata_o = 8'h0;

    if (tx_udp_payload_active) begin
        case (r_tx_udp_tmp_count)
            5'd00: tx_udp_payload_axis_tdata_o = {6'h0, r_noc_rx_fifo_rdata[137:136]};     //flit has only 138 bit (NOC_FLIT_SIZE)
            5'd01: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[135:128];
            5'd02: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[127:120];
            5'd03: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[119:112];
            5'd04: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[111:104];
            5'd05: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[103: 96];
            5'd06: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 95: 88];
            5'd07: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 87: 80];
            5'd08: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 79: 72];
            5'd09: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 71: 64];
            5'd10: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 63: 56];
            5'd11: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 55: 48];
            5'd12: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 47: 40];
            5'd13: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 39: 32];
            5'd14: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 31: 24];
            5'd15: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 23: 16];
            5'd16: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[ 15:  8];
            5'd17: tx_udp_payload_axis_tdata_o = r_noc_rx_fifo_rdata[  7:  0];
            default: tx_udp_payload_axis_tdata_o = 8'h0;
        endcase
    end
end


always @* begin
    next_tx_udp_state = tx_udp_state;

    tx_udp_ip_dest_ip_o = r_tx_udp_ip_dest_ip;
    tx_udp_dest_port_o = r_tx_udp_dest_port;

    tx_udp_payload_axis_tlast_o = 1'b0;

    rin_tx_udp_tmp_count = r_tx_udp_tmp_count;
    rin_tx_udp_payload_count = r_tx_udp_payload_count;
    rin_noc_rx_fifo_rdata = r_noc_rx_fifo_rdata;

    noc_rx_fifo_pop = 1'b0;


    case (tx_udp_state)
        S_TX_UDP_IDLE: begin
            rin_tx_udp_tmp_count = 5'h0;
            rin_tx_udp_payload_count = 16'h0;

            if (!noc_rx_fifo_empty) begin
                rin_noc_rx_fifo_rdata = noc_rx_fifo_rdata;
                noc_rx_fifo_pop = 1'b1;
                rin_tx_udp_payload_count = 16'd1;

                //only set new addresses from chipid when this packet is not a burst or burst header flit
                //it could be a burst payload packet when the previous UDP frame was full
                if (!r_noc_rx_fifo_burst) begin
                    //target is the host
                    if (noc_rx_fifo_chipid == host_chipid_i) begin
                        tx_udp_ip_dest_ip_o = host_ip_addr_i;
                        tx_udp_dest_port_o = host_port_i;
                    end

                    //target is another FPGA
                    else begin
                        tx_udp_ip_dest_ip_o = FPGA_IP_BASE + noc_rx_fifo_chipid;
                        tx_udp_dest_port_o = fpga_port_i;
                    end
                end

                next_tx_udp_state = S_TX_UDP_SEND_HDR;
            end
        end

        S_TX_UDP_SEND_HDR: begin
            if (tx_udp_hdr_ready_i) begin
                next_tx_udp_state = S_TX_UDP_SEND_PAYLOAD;
            end
        end

        S_TX_UDP_SEND_PAYLOAD: begin
            if (tx_udp_payload_axis_tready_i) begin
                rin_tx_udp_tmp_count = r_tx_udp_tmp_count + 1;

                if (r_tx_udp_tmp_count == 5'd17) begin
                    //if frame is full, stop here
                    if (r_tx_udp_payload_count >= MAX_TX_UDP_LENGTH_NOC) begin
                        tx_udp_payload_axis_tlast_o = 1'b1;
                        next_tx_udp_state = S_TX_UDP_IDLE;
                    end

                    //only add another NoC flit to frame if
                    // -we continue current burst
                    // -it is a non-burst packet to the same chipid
                    else if (r_noc_rx_fifo_burst || (!noc_rx_fifo_empty && !noc_rx_fifo_burst && (noc_rx_fifo_chipid == r_noc_rx_fifo_chipid))) begin
                        next_tx_udp_state = S_TX_UDP_NEXT_NOC_FLIT;
                    end

                    //otherwise stop here
                    else begin
                        tx_udp_payload_axis_tlast_o = 1'b1;
                        next_tx_udp_state = S_TX_UDP_IDLE;
                    end
                end
            end
        end

        S_TX_UDP_NEXT_NOC_FLIT: begin
            rin_tx_udp_tmp_count = 5'h0;

            if (!noc_rx_fifo_empty) begin
                rin_noc_rx_fifo_rdata = noc_rx_fifo_rdata;
                noc_rx_fifo_pop = 1'b1;
                rin_tx_udp_payload_count = r_tx_udp_payload_count + 1;
                next_tx_udp_state = S_TX_UDP_SEND_PAYLOAD;
            end
        end

    endcase
end



assign tx_udp_ip_dscp_o = 6'h0;
assign tx_udp_ip_ecn_o = 2'h0;
assign tx_udp_ip_ttl_o = 8'd64;
assign tx_udp_ip_source_ip_o = fpga_ip_addr_i;
assign tx_udp_source_port_o = fpga_port_i;
assign tx_udp_length_o = 16'h0;     //will be calculated later in UDP/IP stack
assign tx_udp_checksum_o = 16'h0;   //will be calculated later in UDP/IP stack

assign tx_udp_hdr_valid_o = tx_udp_hdr_active;
assign tx_udp_payload_axis_tvalid_o = tx_udp_payload_active;
assign tx_udp_payload_axis_tuser_o = 1'b0;



endmodule
