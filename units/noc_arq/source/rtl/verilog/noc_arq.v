
module noc_arq #(
    `include "noc_parameter.vh"
    ,parameter ARQ_BUFFER_SIZE = MAX_BURST_LENGTH_MSG
)(
    input  wire                        clk_i,
    input  wire                        reset_q_i,

    //from module to NoC
    input  wire                        mod_tx_wrreq_i,
    input  wire  [NOC_HEADER_SIZE-1:0] mod_tx_header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] mod_tx_payload_i,
    output wire                        mod_tx_stall_o,
    output wire                        noc_tx_wrreq_o,
    output wire  [NOC_HEADER_SIZE-1:0] noc_tx_header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] noc_tx_payload_o,
    input  wire                        noc_tx_stall_i,

    //from NoC to module
    input  wire                        noc_rx_wrreq_i,
    input  wire  [NOC_HEADER_SIZE-1:0] noc_rx_header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] noc_rx_payload_i,
    output wire                        noc_rx_stall_o,
    output wire                        mod_rx_wrreq_o,
    output wire  [NOC_HEADER_SIZE-1:0] mod_rx_header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] mod_rx_payload_o,
    input  wire                        mod_rx_stall_i
);


    //function clog2 should give ceiling of log of base 2
    localparam ARQ_BUFFER_ADDR_WIDTH = $clog2(ARQ_BUFFER_SIZE);

    wire                        reg_tx_wrreq, reg_rx_wrreq;
    wire  [NOC_HEADER_SIZE-1:0] reg_tx_header, reg_rx_header;
    wire [NOC_PAYLOAD_SIZE-1:0] reg_tx_payload, reg_rx_payload;
    wire                        reg_tx_stall, reg_rx_stall;

    wire                        reg_tx_mux_wrreq;
    wire  [NOC_HEADER_SIZE-1:0] reg_tx_mux_header;
    wire [NOC_PAYLOAD_SIZE-1:0] reg_tx_mux_payload;
    wire                        reg_tx_mux_stall;

    wire                        arq_tx_wrreq, arq_rx_wrreq;
    wire  [NOC_HEADER_SIZE-1:0] arq_tx_header, arq_rx_header;
    wire [NOC_PAYLOAD_SIZE-1:0] arq_tx_payload, arq_rx_payload;
    wire                        arq_tx_stall, arq_rx_stall;

    wire                        ack_tx_wrreq, ack_rx_wrreq;
    wire  [NOC_HEADER_SIZE-1:0] ack_tx_header, ack_rx_header;
    wire [NOC_PAYLOAD_SIZE-1:0] ack_tx_payload, ack_rx_payload;
    wire                        ack_tx_stall, ack_rx_stall;

    wire                  [1:0] arq_enable;
    wire                 [31:0] arq_timeout_rx_cycles;
    wire                 [31:0] noc_rx_count;
    wire                 [31:0] noc_rx_drop;

    wire                 [31:0] arq_tx_bvt_mod_wr_ptr;
    wire                 [31:0] arq_tx_bvt_ack_wr_ptr;
    wire                 [31:0] arq_tx_bvt_occ_ptr;
    wire                 [31:0] arq_tx_bvt_rd_ptr;

    wire                 [31:0] arq_rx_status;


    noc_arq_regfile i_noc_arq_regfile (
        .clk_i                   (clk_i),
        .reset_q_i               (reset_q_i),

        //input
        .wrreq_i                 (reg_rx_wrreq),
        .header_i                (reg_rx_header),
        .payload_i               (reg_rx_payload),
        .stall_o                 (reg_rx_stall),

        //output
        .wrreq_o                 (reg_tx_wrreq),
        .header_o                (reg_tx_header),
        .payload_o               (reg_tx_payload),
        .stall_i                 (reg_tx_stall),

        //regfile-specific data
        .arq_enable_o            (arq_enable),
        .arq_timeout_rx_cycles_o (arq_timeout_rx_cycles),
        .noc_rx_count_i          (noc_rx_count),
        .noc_rx_drop_i           (noc_rx_drop),
        .arq_tx_bvt_mod_wr_ptr_i (arq_tx_bvt_mod_wr_ptr),
        .arq_tx_bvt_ack_wr_ptr_i (arq_tx_bvt_ack_wr_ptr),
        .arq_tx_bvt_occ_ptr_i    (arq_tx_bvt_occ_ptr),
        .arq_tx_bvt_rd_ptr_i     (arq_tx_bvt_rd_ptr),
        .arq_rx_status_i         (arq_rx_status)
    );


    noc_arq_2to1mux i_noc_arq_reg_tx_mux (
        .clk_i         (clk_i),
        .reset_q_i     (reset_q_i),

        //input 1: from module
        .wrreq1_i      (mod_tx_wrreq_i),
        .header1_i     (mod_tx_header_i),
        .payload1_i    (mod_tx_payload_i),
        .stall1_o      (mod_tx_stall_o),

        //input 2: from regfile
        .wrreq2_i      (reg_tx_wrreq),
        .header2_i     (reg_tx_header),
        .payload2_i    (reg_tx_payload),
        .stall2_o      (reg_tx_stall),

        //output arq_tx
        .wrreq_o       (reg_tx_mux_wrreq),
        .header_o      (reg_tx_mux_header),
        .payload_o     (reg_tx_mux_payload),
        .stall_i       (reg_tx_mux_stall)
    );


    noc_arq_tx #(
        .ARQ_TX_BUFFER_ADDR_WIDTH (ARQ_BUFFER_ADDR_WIDTH+1)
    ) i_noc_arq_tx (
        .clk_i         (clk_i),
        .reset_q_i     (reset_q_i),

        //from reg_tx_mux to ack_tx_mux
        .mod_wrreq_i   (reg_tx_mux_wrreq),
        .mod_header_i  (reg_tx_mux_header),
        .mod_payload_i (reg_tx_mux_payload),
        .mod_stall_o   (reg_tx_mux_stall),
        .noc_wrreq_o   (arq_tx_wrreq),
        .noc_header_o  (arq_tx_header),
        .noc_payload_o (arq_tx_payload),
        .noc_stall_i   (arq_tx_stall),

        //incoming ACKs
        .ack_wrreq_i   (ack_rx_wrreq),
        .ack_header_i  (ack_rx_header),
        .ack_payload_i (ack_rx_payload),
        .ack_stall_o   (ack_rx_stall),

        //infos for regfile
        .arq_enable_i            (arq_enable),
        .arq_tx_bvt_mod_wr_ptr_o (arq_tx_bvt_mod_wr_ptr),
        .arq_tx_bvt_ack_wr_ptr_o (arq_tx_bvt_ack_wr_ptr),
        .arq_tx_bvt_occ_ptr_o    (arq_tx_bvt_occ_ptr),
        .arq_tx_bvt_rd_ptr_o     (arq_tx_bvt_rd_ptr)
    );


    noc_arq_2to1mux i_noc_arq_ack_tx_mux (
        .clk_i         (clk_i),
        .reset_q_i     (reset_q_i),

        //input 1: ACKs
        .wrreq1_i      (ack_tx_wrreq),
        .header1_i     (ack_tx_header),
        .payload1_i    (ack_tx_payload),
        .stall1_o      (ack_tx_stall),

        //input 2: from arq_tx
        .wrreq2_i      (arq_tx_wrreq),
        .header2_i     (arq_tx_header),
        .payload2_i    (arq_tx_payload),
        .stall2_o      (arq_tx_stall),

        //output to NoC
        .wrreq_o       (noc_tx_wrreq_o),
        .header_o      (noc_tx_header_o),
        .payload_o     (noc_tx_payload_o),
        .stall_i       (noc_tx_stall_i)
    );


    noc_arq_rx #(
        .ARQ_RX_BUFFER_ADDR_WIDTH (ARQ_BUFFER_ADDR_WIDTH)
    ) i_noc_arq_rx (
        .clk_i                   (clk_i),
        .reset_q_i               (reset_q_i),

        //from rx_mux to module
        .noc_wrreq_i             (arq_rx_wrreq),
        .noc_header_i            (arq_rx_header),
        .noc_payload_i           (arq_rx_payload),
        .noc_stall_o             (arq_rx_stall),
        .mod_wrreq_o             (mod_rx_wrreq_o),
        .mod_header_o            (mod_rx_header_o),
        .mod_payload_o           (mod_rx_payload_o),
        .mod_stall_i             (mod_rx_stall_i),

        //to tx_mux to send ACK
        .ack_wrreq_o             (ack_tx_wrreq),
        .ack_header_o            (ack_tx_header),
        .ack_payload_o           (ack_tx_payload),
        .ack_stall_i             (ack_tx_stall),

        //to regfile
        .reg_wrreq_o             (reg_rx_wrreq),
        .reg_header_o            (reg_rx_header),
        .reg_payload_o           (reg_rx_payload),
        .reg_stall_i             (reg_rx_stall),

        .arq_timeout_rx_cycles_i (arq_timeout_rx_cycles),
        .noc_rx_count_o          (noc_rx_count),
        .noc_rx_drop_o           (noc_rx_drop),
        .arq_rx_status_o         (arq_rx_status)
    );


    noc_arq_1to2mux i_noc_arq_rx_mux (
        .clk_i         (clk_i),
        .reset_q_i     (reset_q_i),

        //input from NoC
        .wrreq_i       (noc_rx_wrreq_i),
        .header_i      (noc_rx_header_i),
        .payload_i     (noc_rx_payload_i),
        .stall_o       (noc_rx_stall_o),

        //output with ACKs to arq_tx
        .ack_wrreq_o   (ack_rx_wrreq),
        .ack_header_o  (ack_rx_header),
        .ack_payload_o (ack_rx_payload),
        .ack_stall_i   (ack_rx_stall),

        //output to arq_rx
        .wrreq_o       (arq_rx_wrreq),
        .header_o      (arq_rx_header),
        .payload_o     (arq_rx_payload),
        .stall_i       (arq_rx_stall)
    );



endmodule
