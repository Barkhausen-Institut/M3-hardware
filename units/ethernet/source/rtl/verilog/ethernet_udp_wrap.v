
module ethernet_udp_wrap #(
    `include "noc_parameter.vh"
    ,parameter NOC_FLIT_SIZE = (NOC_PAYLOAD_SIZE + NOC_HEADER_SIZE),
    parameter FPGA_IP_BASE   = {8'd192, 8'd168, 8'd42, 8'd240}
)
(
    input  wire                       clk_eth_i,
    input  wire                       rst_eth_n_i,

    //NoC interface
    input  wire                       noc_rx_fifo_empty_i,
    output wire                       noc_rx_read_en_o,
    input  wire   [NOC_FLIT_SIZE-1:0] noc_rx_data_i,
    input  wire                       noc_tx_fifo_full_i,
    output wire                       noc_tx_data_valid_o,
    output wire   [NOC_FLIT_SIZE-1:0] noc_tx_data_o,

    //GMII
    input  wire                       gmii_clk,
    input  wire                       gmii_rst,
    input  wire                       gmii_clk_en,
    output wire                 [7:0] gmii_txd,
    output wire                       gmii_tx_en,
    output wire                       gmii_tx_er,
    input  wire                 [7:0] gmii_rxd,
    input  wire                       gmii_rx_dv,
    input  wire                       gmii_rx_er,

    input  wire                [15:0] fpga_port_i,
    input  wire                [31:0] fpga_ip_addr_i,
    input  wire                [47:0] fpga_mac_addr_i,
    input  wire                [15:0] host_port_i,
    input  wire                [31:0] host_ip_addr_i,
    input  wire [NOC_CHIPID_SIZE-1:0] host_chipid_i,
    output wire                [31:0] rx_udp_source_ip_o,
    input  wire                [31:0] gateway_ip_addr_i,
    input  wire                [31:0] subnet_mask_i,


    output wire                [31:0] udp_status_o,
    output wire                [31:0] rx_udp_error_o,
    output wire                [31:0] mac_status_o
);



// AXI between MAC and Ethernet modules
wire  [7:0] rx_axis_tdata;
wire        rx_axis_tvalid;
wire        rx_axis_tready;
wire        rx_axis_tlast;
wire        rx_axis_tuser;

wire  [7:0] tx_axis_tdata;
wire        tx_axis_tvalid;
wire        tx_axis_tready;
wire        tx_axis_tlast;
wire        tx_axis_tuser;

// Ethernet frame between Ethernet modules and UDP stack
wire        rx_eth_hdr_ready;
wire        rx_eth_hdr_valid;
wire [47:0] rx_eth_dest_mac;
wire [47:0] rx_eth_src_mac;
wire [15:0] rx_eth_type;
wire  [7:0] rx_eth_payload_axis_tdata;
wire        rx_eth_payload_axis_tvalid;
wire        rx_eth_payload_axis_tready;
wire        rx_eth_payload_axis_tlast;
wire        rx_eth_payload_axis_tuser;

wire        tx_eth_hdr_ready;
wire        tx_eth_hdr_valid;
wire [47:0] tx_eth_dest_mac;
wire [47:0] tx_eth_src_mac;
wire [15:0] tx_eth_type;
wire  [7:0] tx_eth_payload_axis_tdata;
wire        tx_eth_payload_axis_tvalid;
wire        tx_eth_payload_axis_tready;
wire        tx_eth_payload_axis_tlast;
wire        tx_eth_payload_axis_tuser;

// IP frame connections
wire        rx_ip_hdr_valid;
wire        rx_ip_hdr_ready;
wire [47:0] rx_ip_eth_dest_mac;
wire [47:0] rx_ip_eth_src_mac;
wire [15:0] rx_ip_eth_type;
wire  [3:0] rx_ip_version;
wire  [3:0] rx_ip_ihl;
wire  [5:0] rx_ip_dscp;
wire  [1:0] rx_ip_ecn;
wire [15:0] rx_ip_length;
wire [15:0] rx_ip_identification;
wire  [2:0] rx_ip_flags;
wire [12:0] rx_ip_fragment_offset;
wire  [7:0] rx_ip_ttl;
wire  [7:0] rx_ip_protocol;
wire [15:0] rx_ip_header_checksum;
wire [31:0] rx_ip_source_ip;
wire [31:0] rx_ip_dest_ip;
wire  [7:0] rx_ip_payload_axis_tdata;
wire        rx_ip_payload_axis_tvalid;
wire        rx_ip_payload_axis_tready;
wire        rx_ip_payload_axis_tlast;
wire        rx_ip_payload_axis_tuser;

wire        tx_ip_hdr_valid;
wire        tx_ip_hdr_ready;
wire  [5:0] tx_ip_dscp;
wire  [1:0] tx_ip_ecn;
wire [15:0] tx_ip_length;
wire  [7:0] tx_ip_ttl;
wire  [7:0] tx_ip_protocol;
wire [31:0] tx_ip_source_ip;
wire [31:0] tx_ip_dest_ip;
wire  [7:0] tx_ip_payload_axis_tdata;
wire        tx_ip_payload_axis_tvalid;
wire        tx_ip_payload_axis_tready;
wire        tx_ip_payload_axis_tlast;
wire        tx_ip_payload_axis_tuser;

// UDP frame connections
wire        rx_udp_hdr_valid;
wire        rx_udp_hdr_ready;
wire [47:0] rx_udp_eth_dest_mac;
wire [47:0] rx_udp_eth_src_mac;
wire [15:0] rx_udp_eth_type;
wire  [3:0] rx_udp_ip_version;
wire  [3:0] rx_udp_ip_ihl;
wire  [5:0] rx_udp_ip_dscp;
wire  [1:0] rx_udp_ip_ecn;
wire [15:0] rx_udp_ip_length;
wire [15:0] rx_udp_ip_identification;
wire  [2:0] rx_udp_ip_flags;
wire [12:0] rx_udp_ip_fragment_offset;
wire  [7:0] rx_udp_ip_ttl;
wire  [7:0] rx_udp_ip_protocol;
wire [15:0] rx_udp_ip_header_checksum;
wire [31:0] rx_udp_ip_source_ip;
wire [31:0] rx_udp_ip_dest_ip;
wire [15:0] rx_udp_source_port;
wire [15:0] rx_udp_dest_port;
wire [15:0] rx_udp_length;
wire [15:0] rx_udp_checksum;
wire  [7:0] rx_udp_payload_axis_tdata;
wire        rx_udp_payload_axis_tvalid;
wire        rx_udp_payload_axis_tready;
wire        rx_udp_payload_axis_tlast;
wire        rx_udp_payload_axis_tuser;

wire        tx_udp_hdr_valid;
wire        tx_udp_hdr_ready;
wire  [5:0] tx_udp_ip_dscp;
wire  [1:0] tx_udp_ip_ecn;
wire  [7:0] tx_udp_ip_ttl;
wire [31:0] tx_udp_ip_source_ip;
wire [31:0] tx_udp_ip_dest_ip;
wire [15:0] tx_udp_source_port;
wire [15:0] tx_udp_dest_port;
wire [15:0] tx_udp_length;
wire [15:0] tx_udp_checksum;
wire  [7:0] tx_udp_payload_axis_tdata;
wire        tx_udp_payload_axis_tvalid;
wire        tx_udp_payload_axis_tready;
wire        tx_udp_payload_axis_tlast;
wire        tx_udp_payload_axis_tuser;

wire mac_tx_error_underflow;
wire mac_tx_fifo_overflow;
wire mac_tx_fifo_bad_frame;
wire mac_tx_fifo_good_frame;
wire mac_rx_error_bad_frame;
wire mac_rx_error_bad_fcs;
wire mac_rx_fifo_overflow;
wire mac_rx_fifo_bad_frame;
wire mac_rx_fifo_good_frame;
wire axis_rx_error_header_early_termination;

wire ip_rx_error_header_early_termination;
wire ip_rx_error_payload_early_termination;
wire ip_rx_error_invalid_header;
wire ip_rx_error_invalid_checksum;
wire ip_tx_error_payload_early_termination;
wire ip_tx_error_arp_failed;
wire udp_rx_error_header_early_termination;
wire udp_rx_error_payload_early_termination;
wire udp_tx_error_payload_early_termination;

// IP ports not used
assign rx_ip_hdr_ready = 1;
assign rx_ip_payload_axis_tready = 1;

assign tx_ip_hdr_valid = 0;
assign tx_ip_dscp = 0;
assign tx_ip_ecn = 0;
assign tx_ip_length = 0;
assign tx_ip_ttl = 0;
assign tx_ip_protocol = 0;
assign tx_ip_source_ip = 0;
assign tx_ip_dest_ip = 0;
assign tx_ip_payload_axis_tdata = 0;
assign tx_ip_payload_axis_tvalid = 0;
assign tx_ip_payload_axis_tlast = 0;
assign tx_ip_payload_axis_tuser = 0;


eth_mac_1g_fifo #(
    .ENABLE_PADDING     (1),
    .MIN_FRAME_LENGTH   (64),
    .TX_FIFO_DEPTH      (16384),
    .TX_FRAME_FIFO      (1),
    .RX_FIFO_DEPTH      (16384),
    .RX_FRAME_FIFO      (1)
) i_eth_mac_1g_fifo (
    .rx_clk             (gmii_clk),
    .rx_rst             (gmii_rst),
    .tx_clk             (gmii_clk),
    .tx_rst             (gmii_rst),
    .logic_clk          (clk_eth_i),
    .logic_rst          (~rst_eth_n_i),

    .tx_axis_tdata      (tx_axis_tdata),
    .tx_axis_tkeep      (1'b0),
    .tx_axis_tvalid     (tx_axis_tvalid),
    .tx_axis_tready     (tx_axis_tready),
    .tx_axis_tlast      (tx_axis_tlast),
    .tx_axis_tuser      (tx_axis_tuser),

    .rx_axis_tdata      (rx_axis_tdata),
    .rx_axis_tkeep      (),
    .rx_axis_tvalid     (rx_axis_tvalid),
    .rx_axis_tready     (rx_axis_tready),
    .rx_axis_tlast      (rx_axis_tlast),
    .rx_axis_tuser      (rx_axis_tuser),

    .gmii_rxd           (gmii_rxd),
    .gmii_rx_dv         (gmii_rx_dv),
    .gmii_rx_er         (gmii_rx_er),
    .gmii_txd           (gmii_txd),
    .gmii_tx_en         (gmii_tx_en),
    .gmii_tx_er         (gmii_tx_er),

    .rx_clk_enable      (gmii_clk_en),
    .tx_clk_enable      (gmii_clk_en),
    .rx_mii_select      (1'b0),
    .tx_mii_select      (1'b0),

    .tx_error_underflow (mac_tx_error_underflow),
    .tx_fifo_overflow   (mac_tx_fifo_overflow),
    .tx_fifo_bad_frame  (mac_tx_fifo_bad_frame),
    .tx_fifo_good_frame (mac_tx_fifo_good_frame),
    .rx_error_bad_frame (mac_rx_error_bad_frame),
    .rx_error_bad_fcs   (mac_rx_error_bad_fcs),
    .rx_fifo_overflow   (mac_rx_fifo_overflow),
    .rx_fifo_bad_frame  (mac_rx_fifo_bad_frame),
    .rx_fifo_good_frame (mac_rx_fifo_good_frame),

    .cfg_ifg            (8'd12),
    .cfg_tx_enable      (1'b1),
    .cfg_rx_enable      (1'b1)
);


eth_axis_rx i_eth_axis_rx_inst (
    .clk                            (clk_eth_i),
    .rst                            (~rst_eth_n_i),

    // AXI input
    .s_axis_tdata                   (rx_axis_tdata),
    .s_axis_tkeep                   (1'b0),
    .s_axis_tvalid                  (rx_axis_tvalid),
    .s_axis_tready                  (rx_axis_tready),
    .s_axis_tlast                   (rx_axis_tlast),
    .s_axis_tuser                   (rx_axis_tuser),

    // Ethernet frame output
    .m_eth_hdr_valid                (rx_eth_hdr_valid),
    .m_eth_hdr_ready                (rx_eth_hdr_ready),
    .m_eth_dest_mac                 (rx_eth_dest_mac),
    .m_eth_src_mac                  (rx_eth_src_mac),
    .m_eth_type                     (rx_eth_type),
    .m_eth_payload_axis_tdata       (rx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep       (),
    .m_eth_payload_axis_tvalid      (rx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready      (rx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast       (rx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser       (rx_eth_payload_axis_tuser),

    // Status signals
    .busy                           (),
    .error_header_early_termination (axis_rx_error_header_early_termination)
);


eth_axis_tx i_eth_axis_tx (
    .clk                            (clk_eth_i),
    .rst                            (~rst_eth_n_i),

    // Ethernet frame input
    .s_eth_hdr_valid                (tx_eth_hdr_valid),
    .s_eth_hdr_ready                (tx_eth_hdr_ready),
    .s_eth_dest_mac                 (tx_eth_dest_mac),
    .s_eth_src_mac                  (tx_eth_src_mac),
    .s_eth_type                     (tx_eth_type),
    .s_eth_payload_axis_tdata       (tx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep       (1'b0),
    .s_eth_payload_axis_tvalid      (tx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready      (tx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast       (tx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser       (tx_eth_payload_axis_tuser),

    // AXI output
    .m_axis_tdata                   (tx_axis_tdata),
    .m_axis_tkeep                   (),
    .m_axis_tvalid                  (tx_axis_tvalid),
    .m_axis_tready                  (tx_axis_tready),
    .m_axis_tlast                   (tx_axis_tlast),
    .m_axis_tuser                   (tx_axis_tuser),

    // Status signals
    .busy                           ()
);


reg r_mac_tx_error_underflow;
reg r_mac_tx_fifo_overflow;
reg r_mac_tx_fifo_bad_frame;
reg r_mac_tx_fifo_good_frame;
reg r_mac_rx_error_bad_frame;
reg r_mac_rx_error_bad_fcs;
reg r_mac_rx_fifo_overflow;
reg r_mac_rx_fifo_bad_frame;
reg r_mac_rx_fifo_good_frame;
reg r_axis_rx_error_header_early_termination;

always @(posedge clk_eth_i or negedge rst_eth_n_i) begin
    if (rst_eth_n_i == 1'b0) begin
        r_mac_tx_error_underflow                 <= 1'b0;
        r_mac_tx_fifo_overflow                   <= 1'b0;
        r_mac_tx_fifo_bad_frame                  <= 1'b0;
        r_mac_tx_fifo_good_frame                 <= 1'b0;
        r_mac_rx_error_bad_frame                 <= 1'b0;
        r_mac_rx_error_bad_fcs                   <= 1'b0;
        r_mac_rx_fifo_overflow                   <= 1'b0;
        r_mac_rx_fifo_bad_frame                  <= 1'b0;
        r_mac_rx_fifo_good_frame                 <= 1'b0;
        r_axis_rx_error_header_early_termination <= 1'b0;
    end
    else begin
        r_mac_tx_error_underflow                 <= mac_tx_error_underflow ? 1'b1 : r_mac_tx_error_underflow;
        r_mac_tx_fifo_overflow                   <= mac_tx_fifo_overflow ? 1'b1 : r_mac_tx_fifo_overflow;
        r_mac_tx_fifo_bad_frame                  <= mac_tx_fifo_bad_frame ? 1'b1 : r_mac_tx_fifo_bad_frame;
        r_mac_tx_fifo_good_frame                 <= mac_tx_fifo_good_frame ? 1'b1 : r_mac_tx_fifo_good_frame;
        r_mac_rx_error_bad_frame                 <= mac_rx_error_bad_frame ? 1'b1 : r_mac_rx_error_bad_frame;
        r_mac_rx_error_bad_fcs                   <= mac_rx_error_bad_fcs ? 1'b1 : r_mac_rx_error_bad_fcs;
        r_mac_rx_fifo_overflow                   <= mac_rx_fifo_overflow ? 1'b1 : r_mac_rx_fifo_overflow;
        r_mac_rx_fifo_bad_frame                  <= mac_rx_fifo_bad_frame ? 1'b1 : r_mac_rx_fifo_bad_frame;
        r_mac_rx_fifo_good_frame                 <= mac_rx_fifo_good_frame ? 1'b1 : r_mac_rx_fifo_good_frame;
        r_axis_rx_error_header_early_termination <= axis_rx_error_header_early_termination ? 1'b1 : r_axis_rx_error_header_early_termination;
    end
end

assign mac_status_o = {22'h0,
                        r_axis_rx_error_header_early_termination,
                        r_mac_rx_fifo_good_frame,
                        r_mac_rx_fifo_bad_frame,
                        r_mac_rx_fifo_overflow,
                        r_mac_rx_error_bad_fcs,
                        r_mac_rx_error_bad_frame,
                        r_mac_tx_fifo_good_frame,
                        r_mac_tx_fifo_bad_frame,
                        r_mac_tx_fifo_overflow,
                        r_mac_tx_error_underflow};


udp_complete i_udp_complete (
    .clk                        (clk_eth_i),
    .rst                        (~rst_eth_n_i),

    // Ethernet frame input
    .s_eth_hdr_valid            (rx_eth_hdr_valid),
    .s_eth_hdr_ready            (rx_eth_hdr_ready),
    .s_eth_dest_mac             (rx_eth_dest_mac),
    .s_eth_src_mac              (rx_eth_src_mac),
    .s_eth_type                 (rx_eth_type),
    .s_eth_payload_axis_tdata   (rx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tvalid  (rx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready  (rx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast   (rx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser   (rx_eth_payload_axis_tuser),

    // Ethernet frame output
    .m_eth_hdr_valid            (tx_eth_hdr_valid),
    .m_eth_hdr_ready            (tx_eth_hdr_ready),
    .m_eth_dest_mac             (tx_eth_dest_mac),
    .m_eth_src_mac              (tx_eth_src_mac),
    .m_eth_type                 (tx_eth_type),
    .m_eth_payload_axis_tdata   (tx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tvalid  (tx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready  (tx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast   (tx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser   (tx_eth_payload_axis_tuser),

    // IP frame input (unused)
    .s_ip_hdr_valid             (tx_ip_hdr_valid),
    .s_ip_hdr_ready             (tx_ip_hdr_ready),
    .s_ip_dscp                  (tx_ip_dscp),
    .s_ip_ecn                   (tx_ip_ecn),
    .s_ip_length                (tx_ip_length),
    .s_ip_ttl                   (tx_ip_ttl),
    .s_ip_protocol              (tx_ip_protocol),
    .s_ip_source_ip             (tx_ip_source_ip),
    .s_ip_dest_ip               (tx_ip_dest_ip),
    .s_ip_payload_axis_tdata    (tx_ip_payload_axis_tdata),
    .s_ip_payload_axis_tvalid   (tx_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready   (tx_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast    (tx_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser    (tx_ip_payload_axis_tuser),

    // IP frame output (unused)
    .m_ip_hdr_valid             (rx_ip_hdr_valid),
    .m_ip_hdr_ready             (rx_ip_hdr_ready),
    .m_ip_eth_dest_mac          (rx_ip_eth_dest_mac),
    .m_ip_eth_src_mac           (rx_ip_eth_src_mac),
    .m_ip_eth_type              (rx_ip_eth_type),
    .m_ip_version               (rx_ip_version),
    .m_ip_ihl                   (rx_ip_ihl),
    .m_ip_dscp                  (rx_ip_dscp),
    .m_ip_ecn                   (rx_ip_ecn),
    .m_ip_length                (rx_ip_length),
    .m_ip_identification        (rx_ip_identification),
    .m_ip_flags                 (rx_ip_flags),
    .m_ip_fragment_offset       (rx_ip_fragment_offset),
    .m_ip_ttl                   (rx_ip_ttl),
    .m_ip_protocol              (rx_ip_protocol),
    .m_ip_header_checksum       (rx_ip_header_checksum),
    .m_ip_source_ip             (rx_ip_source_ip),
    .m_ip_dest_ip               (rx_ip_dest_ip),
    .m_ip_payload_axis_tdata    (rx_ip_payload_axis_tdata),
    .m_ip_payload_axis_tvalid   (rx_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready   (rx_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast    (rx_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser    (rx_ip_payload_axis_tuser),

    // UDP frame input
    .s_udp_hdr_valid            (tx_udp_hdr_valid),
    .s_udp_hdr_ready            (tx_udp_hdr_ready),
    .s_udp_ip_dscp              (tx_udp_ip_dscp),
    .s_udp_ip_ecn               (tx_udp_ip_ecn),
    .s_udp_ip_ttl               (tx_udp_ip_ttl),
    .s_udp_ip_source_ip         (tx_udp_ip_source_ip),
    .s_udp_ip_dest_ip           (tx_udp_ip_dest_ip),
    .s_udp_source_port          (tx_udp_source_port),
    .s_udp_dest_port            (tx_udp_dest_port),
    .s_udp_length               (tx_udp_length),
    .s_udp_checksum             (tx_udp_checksum),
    .s_udp_payload_axis_tdata   (tx_udp_payload_axis_tdata),
    .s_udp_payload_axis_tvalid  (tx_udp_payload_axis_tvalid),
    .s_udp_payload_axis_tready  (tx_udp_payload_axis_tready),
    .s_udp_payload_axis_tlast   (tx_udp_payload_axis_tlast),
    .s_udp_payload_axis_tuser   (tx_udp_payload_axis_tuser),

    // UDP frame output
    .m_udp_hdr_valid            (rx_udp_hdr_valid),
    .m_udp_hdr_ready            (rx_udp_hdr_ready),
    .m_udp_eth_dest_mac         (rx_udp_eth_dest_mac),
    .m_udp_eth_src_mac          (rx_udp_eth_src_mac),
    .m_udp_eth_type             (rx_udp_eth_type),
    .m_udp_ip_version           (rx_udp_ip_version),
    .m_udp_ip_ihl               (rx_udp_ip_ihl),
    .m_udp_ip_dscp              (rx_udp_ip_dscp),
    .m_udp_ip_ecn               (rx_udp_ip_ecn),
    .m_udp_ip_length            (rx_udp_ip_length),
    .m_udp_ip_identification    (rx_udp_ip_identification),
    .m_udp_ip_flags             (rx_udp_ip_flags),
    .m_udp_ip_fragment_offset   (rx_udp_ip_fragment_offset),
    .m_udp_ip_ttl               (rx_udp_ip_ttl),
    .m_udp_ip_protocol          (rx_udp_ip_protocol),
    .m_udp_ip_header_checksum   (rx_udp_ip_header_checksum),
    .m_udp_ip_source_ip         (rx_udp_ip_source_ip),
    .m_udp_ip_dest_ip           (rx_udp_ip_dest_ip),
    .m_udp_source_port          (rx_udp_source_port),
    .m_udp_dest_port            (rx_udp_dest_port),
    .m_udp_length               (rx_udp_length),
    .m_udp_checksum             (rx_udp_checksum),
    .m_udp_payload_axis_tdata   (rx_udp_payload_axis_tdata),
    .m_udp_payload_axis_tvalid  (rx_udp_payload_axis_tvalid),
    .m_udp_payload_axis_tready  (rx_udp_payload_axis_tready),
    .m_udp_payload_axis_tlast   (rx_udp_payload_axis_tlast),
    .m_udp_payload_axis_tuser   (rx_udp_payload_axis_tuser),

    // Status signals
    .ip_rx_busy                             (),
    .ip_tx_busy                             (),
    .udp_rx_busy                            (),
    .udp_tx_busy                            (),
    .ip_rx_error_header_early_termination   (ip_rx_error_header_early_termination),
    .ip_rx_error_payload_early_termination  (ip_rx_error_payload_early_termination),
    .ip_rx_error_invalid_header             (ip_rx_error_invalid_header),
    .ip_rx_error_invalid_checksum           (ip_rx_error_invalid_checksum),
    .ip_tx_error_payload_early_termination  (ip_tx_error_payload_early_termination),
    .ip_tx_error_arp_failed                 (ip_tx_error_arp_failed),
    .udp_rx_error_header_early_termination  (udp_rx_error_header_early_termination),
    .udp_rx_error_payload_early_termination (udp_rx_error_payload_early_termination),
    .udp_tx_error_payload_early_termination (udp_tx_error_payload_early_termination),

    // Configuration
    .local_mac                              (fpga_mac_addr_i),
    .local_ip                               (fpga_ip_addr_i),
    .gateway_ip                             (gateway_ip_addr_i),
    .subnet_mask                            (subnet_mask_i),
    .clear_arp_cache                        (1'b0)
);


reg r_ip_rx_error_header_early_termination;
reg r_ip_rx_error_payload_early_termination;
reg r_ip_rx_error_invalid_header;
reg r_ip_rx_error_invalid_checksum;
reg r_ip_tx_error_payload_early_termination;
reg r_ip_tx_error_arp_failed;
reg r_udp_rx_error_header_early_termination;
reg r_udp_rx_error_payload_early_termination;
reg r_udp_tx_error_payload_early_termination;

always @(posedge clk_eth_i or negedge rst_eth_n_i) begin
    if (rst_eth_n_i == 1'b0) begin
        r_ip_rx_error_header_early_termination   <= 1'b0;
        r_ip_rx_error_payload_early_termination  <= 1'b0;
        r_ip_rx_error_invalid_header             <= 1'b0;
        r_ip_rx_error_invalid_checksum           <= 1'b0;
        r_ip_tx_error_payload_early_termination  <= 1'b0;
        r_ip_tx_error_arp_failed                 <= 1'b0;
        r_udp_rx_error_header_early_termination  <= 1'b0;
        r_udp_rx_error_payload_early_termination <= 1'b0;
        r_udp_tx_error_payload_early_termination <= 1'b0;
    end
    else begin
        r_ip_rx_error_header_early_termination   <= ip_rx_error_header_early_termination ? 1'b1 : r_ip_rx_error_header_early_termination;
        r_ip_rx_error_payload_early_termination  <= ip_rx_error_payload_early_termination ? 1'b1 : r_ip_rx_error_payload_early_termination;
        r_ip_rx_error_invalid_header             <= ip_rx_error_invalid_header ? 1'b1 : r_ip_rx_error_invalid_header;
        r_ip_rx_error_invalid_checksum           <= ip_rx_error_invalid_checksum ? 1'b1 : r_ip_rx_error_invalid_checksum;
        r_ip_tx_error_payload_early_termination  <= ip_tx_error_payload_early_termination ? 1'b1 : r_ip_tx_error_payload_early_termination;
        r_ip_tx_error_arp_failed                 <= ip_tx_error_arp_failed ? 1'b1 : r_ip_tx_error_arp_failed;
        r_udp_rx_error_header_early_termination  <= udp_rx_error_header_early_termination ? 1'b1 : r_udp_rx_error_header_early_termination;
        r_udp_rx_error_payload_early_termination <= udp_rx_error_payload_early_termination ? 1'b1 : r_udp_rx_error_payload_early_termination;
        r_udp_tx_error_payload_early_termination <= udp_tx_error_payload_early_termination ? 1'b1 : r_udp_tx_error_payload_early_termination;
    end
end

assign udp_status_o = {23'h0,
                        r_udp_tx_error_payload_early_termination,
                        r_udp_rx_error_payload_early_termination,
                        r_udp_rx_error_header_early_termination,
                        r_ip_tx_error_arp_failed,
                        r_ip_tx_error_payload_early_termination,
                        r_ip_rx_error_invalid_checksum,
                        r_ip_rx_error_invalid_header,
                        r_ip_rx_error_payload_early_termination,
                        r_ip_rx_error_header_early_termination};


// map ethernet frame to noc packet
udp_noc_bridge #(
    .FPGA_IP_BASE                   (FPGA_IP_BASE)
) i_udp_noc_bridge (
    .clk_eth_i                      (clk_eth_i),
    .rst_eth_n_i                    (rst_eth_n_i),

    .noc_rx_fifo_empty_i            (noc_rx_fifo_empty_i),
    .noc_rx_read_en_o               (noc_rx_read_en_o),
    .noc_rx_data_i                  (noc_rx_data_i),
    .noc_tx_fifo_full_i             (noc_tx_fifo_full_i),
    .noc_tx_data_valid_o            (noc_tx_data_valid_o),
    .noc_tx_data_o                  (noc_tx_data_o),

    .tx_udp_hdr_valid_o             (tx_udp_hdr_valid),
    .tx_udp_hdr_ready_i             (tx_udp_hdr_ready),
    .tx_udp_ip_dscp_o               (tx_udp_ip_dscp),
    .tx_udp_ip_ecn_o                (tx_udp_ip_ecn),
    .tx_udp_ip_ttl_o                (tx_udp_ip_ttl),
    .tx_udp_ip_source_ip_o          (tx_udp_ip_source_ip),
    .tx_udp_ip_dest_ip_o            (tx_udp_ip_dest_ip),
    .tx_udp_source_port_o           (tx_udp_source_port),
    .tx_udp_dest_port_o             (tx_udp_dest_port),
    .tx_udp_length_o                (tx_udp_length),
    .tx_udp_checksum_o              (tx_udp_checksum),
    .tx_udp_payload_axis_tdata_o    (tx_udp_payload_axis_tdata),
    .tx_udp_payload_axis_tvalid_o   (tx_udp_payload_axis_tvalid),
    .tx_udp_payload_axis_tready_i   (tx_udp_payload_axis_tready),
    .tx_udp_payload_axis_tlast_o    (tx_udp_payload_axis_tlast),
    .tx_udp_payload_axis_tuser_o    (tx_udp_payload_axis_tuser),

    .rx_udp_hdr_valid_i             (rx_udp_hdr_valid),
    .rx_udp_hdr_ready_o             (rx_udp_hdr_ready),
    .rx_udp_eth_dest_mac_i          (rx_udp_eth_dest_mac),
    .rx_udp_eth_src_mac_i           (rx_udp_eth_src_mac),
    .rx_udp_eth_type_i              (rx_udp_eth_type),
    .rx_udp_ip_version_i            (rx_udp_ip_version),
    .rx_udp_ip_ihl_i                (rx_udp_ip_ihl),
    .rx_udp_ip_dscp_i               (rx_udp_ip_dscp),
    .rx_udp_ip_ecn_i                (rx_udp_ip_ecn),
    .rx_udp_ip_length_i             (rx_udp_ip_length),
    .rx_udp_ip_identification_i     (rx_udp_ip_identification),
    .rx_udp_ip_flags_i              (rx_udp_ip_flags),
    .rx_udp_ip_fragment_offset_i    (rx_udp_ip_fragment_offset),
    .rx_udp_ip_ttl_i                (rx_udp_ip_ttl),
    .rx_udp_ip_protocol_i           (rx_udp_ip_protocol),
    .rx_udp_ip_header_checksum_i    (rx_udp_ip_header_checksum),
    .rx_udp_ip_source_ip_i          (rx_udp_ip_source_ip),
    .rx_udp_ip_dest_ip_i            (rx_udp_ip_dest_ip),
    .rx_udp_source_port_i           (rx_udp_source_port),
    .rx_udp_dest_port_i             (rx_udp_dest_port),
    .rx_udp_length_i                (rx_udp_length),
    .rx_udp_checksum_i              (rx_udp_checksum),
    .rx_udp_payload_axis_tdata_i    (rx_udp_payload_axis_tdata),
    .rx_udp_payload_axis_tvalid_i   (rx_udp_payload_axis_tvalid),
    .rx_udp_payload_axis_tready_o   (rx_udp_payload_axis_tready),
    .rx_udp_payload_axis_tlast_i    (rx_udp_payload_axis_tlast),
    .rx_udp_payload_axis_tuser_i    (rx_udp_payload_axis_tuser),

    .fpga_port_i                    (fpga_port_i),
    .fpga_ip_addr_i                 (fpga_ip_addr_i),
    .host_port_i                    (host_port_i),
    .host_ip_addr_i                 (host_ip_addr_i),
    .host_chipid_i                  (host_chipid_i),
    .rx_udp_source_ip_o             (rx_udp_source_ip_o),

    .rx_udp_error_o                 (rx_udp_error_o)
);


endmodule
