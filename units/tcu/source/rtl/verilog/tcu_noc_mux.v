
module tcu_noc_mux #(
    `include "tcu_parameter.vh"
    ,`include "noc_parameter.vh"
    ,parameter [0:0] TX_IF1_PRIO          = 1'b0,        //if 1, IF1 has priority, otherwise IF 2
    parameter  [0:0] RX_IF1_PRIO          = 1'b0,        //if 1, IF1 has priority, otherwise IF 2
    parameter [31:0] RX_IF1_ADDR_START    = 32'h0,       //address range for IF1 (disabled when size = 0)
    parameter [31:0] RX_IF1_ADDR_END      = 32'hFFFFFFFF,
    parameter  [0:0] RX_IF1_ONLY_HOMECHIP = 1'b0,        //if 1, IF1 only takes packets addressed to home_chipid
    parameter  [0:0] RX_IF1_ONLY_MODE_2   = 1'b0,        //if 1, IF1 only takes packets with mode _2
    parameter [31:0] RX_IF2_ADDR_START    = 32'h0,       //address range for IF2 (disabled when size = 0)
    parameter [31:0] RX_IF2_ADDR_END      = 32'hFFFFFFFF,
    parameter  [0:0] RX_IF2_ONLY_MODE_2   = 1'b0,        //if 1, IF2 only takes packets with mode _2
    parameter  [0:0] RX_IF2_ONLY_HOMECHIP = 1'b0         //if 1, IF2 only takes packets addressed to home_chipid

)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,
    input  wire                          tcu_reset_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] home_chipid_i,

    //---------------
    //NoC IF 1
    input  wire                          noc1_tx_wrreq_i,
    input  wire                          noc1_tx_burst_i,
    input  wire                          noc1_tx_arq_i,
    input  wire      [NOC_BSEL_SIZE-1:0] noc1_tx_bsel_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc1_tx_src_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc1_tx_src_modid_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc1_tx_trg_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc1_tx_trg_modid_i,
    input  wire      [NOC_MODE_SIZE-1:0] noc1_tx_mode_i,
    input  wire      [NOC_ADDR_SIZE-1:0] noc1_tx_addr_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc1_tx_data0_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc1_tx_data1_i,
    output wire                          noc1_tx_stall_o,

    output reg                           noc1_rx_wrreq_o,
    output reg                           noc1_rx_burst_o,
    output reg                           noc1_rx_arq_o,
    output reg       [NOC_BSEL_SIZE-1:0] noc1_rx_bsel_o,
    output reg     [NOC_CHIPID_SIZE-1:0] noc1_rx_src_chipid_o,
    output reg      [NOC_MODID_SIZE-1:0] noc1_rx_src_modid_o,
    output reg     [NOC_CHIPID_SIZE-1:0] noc1_rx_trg_chipid_o,
    output reg      [NOC_MODID_SIZE-1:0] noc1_rx_trg_modid_o,
    output reg       [NOC_MODE_SIZE-1:0] noc1_rx_mode_o,
    output reg       [NOC_ADDR_SIZE-1:0] noc1_rx_addr_o,
    output reg       [NOC_DATA_SIZE-1:0] noc1_rx_data0_o,
    output reg       [NOC_DATA_SIZE-1:0] noc1_rx_data1_o,
    input  wire                          noc1_rx_stall_i,   //stall is 1 by default, 0 when packet can be accepted (like a ready signal)

    //---------------
    //NoC IF 2
    input  wire                          noc2_tx_wrreq_i,
    input  wire                          noc2_tx_burst_i,
    input  wire                          noc2_tx_arq_i,
    input  wire      [NOC_BSEL_SIZE-1:0] noc2_tx_bsel_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc2_tx_src_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc2_tx_src_modid_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc2_tx_trg_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc2_tx_trg_modid_i,
    input  wire      [NOC_MODE_SIZE-1:0] noc2_tx_mode_i,
    input  wire      [NOC_ADDR_SIZE-1:0] noc2_tx_addr_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc2_tx_data0_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc2_tx_data1_i,
    output wire                          noc2_tx_stall_o,

    output reg                           noc2_rx_wrreq_o,
    output reg                           noc2_rx_burst_o,
    output reg                           noc2_rx_arq_o,
    output reg       [NOC_BSEL_SIZE-1:0] noc2_rx_bsel_o,
    output reg     [NOC_CHIPID_SIZE-1:0] noc2_rx_src_chipid_o,
    output reg      [NOC_MODID_SIZE-1:0] noc2_rx_src_modid_o,
    output reg     [NOC_CHIPID_SIZE-1:0] noc2_rx_trg_chipid_o,
    output reg      [NOC_MODID_SIZE-1:0] noc2_rx_trg_modid_o,
    output reg       [NOC_MODE_SIZE-1:0] noc2_rx_mode_o,
    output reg       [NOC_ADDR_SIZE-1:0] noc2_rx_addr_o,
    output reg       [NOC_DATA_SIZE-1:0] noc2_rx_data0_o,
    output reg       [NOC_DATA_SIZE-1:0] noc2_rx_data1_o,
    input  wire                          noc2_rx_stall_i,   //stall is 1 by default, 0 when packet can be accepted (like a ready signal)

    //---------------
    //NoC IF out (TCU output to NoC)
    output reg                           noc_out_tx_wrreq_o,
    output reg                           noc_out_tx_burst_o,
    output reg                           noc_out_tx_arq_o,
    output reg       [NOC_BSEL_SIZE-1:0] noc_out_tx_bsel_o,
    output reg     [NOC_CHIPID_SIZE-1:0] noc_out_tx_src_chipid_o,
    output reg      [NOC_MODID_SIZE-1:0] noc_out_tx_src_modid_o,
    output reg     [NOC_CHIPID_SIZE-1:0] noc_out_tx_trg_chipid_o,
    output reg      [NOC_MODID_SIZE-1:0] noc_out_tx_trg_modid_o,
    output reg       [NOC_MODE_SIZE-1:0] noc_out_tx_mode_o,
    output reg       [NOC_ADDR_SIZE-1:0] noc_out_tx_addr_o,
    output reg       [NOC_DATA_SIZE-1:0] noc_out_tx_data0_o,
    output reg       [NOC_DATA_SIZE-1:0] noc_out_tx_data1_o,
    input  wire                          noc_out_tx_stall_i,    //indicates NoC FIFO full (it is 0 by default)

    input  wire                          noc_out_rx_wrreq_i,
    input  wire                          noc_out_rx_burst_i,
    input  wire                          noc_out_rx_arq_i,
    input  wire      [NOC_BSEL_SIZE-1:0] noc_out_rx_bsel_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_out_rx_src_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_out_rx_src_modid_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_out_rx_trg_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_out_rx_trg_modid_i,
    input  wire      [NOC_MODE_SIZE-1:0] noc_out_rx_mode_i,
    input  wire      [NOC_ADDR_SIZE-1:0] noc_out_rx_addr_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_out_rx_data0_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_out_rx_data1_i,
    output reg                           noc_out_rx_stall_o,

    //---------------
    //Flit counter
    output wire [TCU_FLITCOUNT_SIZE-1:0] noc1_rx_flit_count_o,
    output wire [TCU_FLITCOUNT_SIZE-1:0] noc2_rx_flit_count_o,
    output wire [TCU_FLITCOUNT_SIZE-1:0] noc1_tx_flit_count_o,
    output wire [TCU_FLITCOUNT_SIZE-1:0] noc2_tx_flit_count_o
);

    localparam OUT_TX_IF0 = 2'h0; //neither IF1 or IF2
    localparam OUT_TX_IF1 = 2'h1;
    localparam OUT_TX_IF2 = 2'h2;

    localparam OUT_RX_IF0 = 2'h0; //neither IF1 or IF2
    localparam OUT_RX_IF1 = 2'h1;
    localparam OUT_RX_IF2 = 2'h2;


    reg  [1:0] r_tx_arbiter_result, rin_tx_arbiter_result;
    reg        tx_stall_if1, tx_stall_if2;
    reg        r_tx_burst_active, rin_tx_burst_active;

    reg  [1:0] r_rx_arbiter_result, rin_rx_arbiter_result;
    reg        r_rx_burst_active, rin_rx_burst_active;

    reg [TCU_FLITCOUNT_SIZE-1:0] r_noc1_rx_flit_count, rin_noc1_rx_flit_count;
    reg [TCU_FLITCOUNT_SIZE-1:0] r_noc2_rx_flit_count, rin_noc2_rx_flit_count;
    reg [TCU_FLITCOUNT_SIZE-1:0] r_noc1_tx_flit_count, rin_noc1_tx_flit_count;
    reg [TCU_FLITCOUNT_SIZE-1:0] r_noc2_tx_flit_count, rin_noc2_tx_flit_count;


    //only mode_2 packets
    wire rx_mode_2 = (noc_out_rx_mode_i == MODE_WRITE_POSTED_2) ||
                        (noc_out_rx_mode_i == MODE_READ_REQ_2) ||
                        (noc_out_rx_mode_i == MODE_READ_RSP_2);

    //check chipid
    wire rx_to_homechip = (noc_out_rx_trg_chipid_i == home_chipid_i);

    //check if addr valid
    wire if1_rx_addr_valid = (noc_out_rx_addr_i >= RX_IF1_ADDR_START) && (noc_out_rx_addr_i <= RX_IF1_ADDR_END) && (!RX_IF1_ONLY_HOMECHIP || rx_to_homechip);
    wire if2_rx_addr_valid = (noc_out_rx_addr_i >= RX_IF2_ADDR_START) && (noc_out_rx_addr_i <= RX_IF2_ADDR_END) && (!RX_IF2_ONLY_HOMECHIP || rx_to_homechip);



    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            r_tx_arbiter_result <= OUT_TX_IF0;
            r_tx_burst_active <= 1'b0;

            r_rx_arbiter_result <= OUT_RX_IF0;
            r_rx_burst_active <= 1'b0;

            r_noc1_rx_flit_count <= {TCU_FLITCOUNT_SIZE{1'b0}};
            r_noc2_rx_flit_count <= {TCU_FLITCOUNT_SIZE{1'b0}};
            r_noc1_tx_flit_count <= {TCU_FLITCOUNT_SIZE{1'b0}};
            r_noc2_tx_flit_count <= {TCU_FLITCOUNT_SIZE{1'b0}};
        end
        else begin
            r_tx_arbiter_result <= rin_tx_arbiter_result;
            r_tx_burst_active <= rin_tx_burst_active;

            r_rx_arbiter_result <= rin_rx_arbiter_result;
            r_rx_burst_active <= rin_rx_burst_active;

            r_noc1_rx_flit_count <= rin_noc1_rx_flit_count;
            r_noc2_rx_flit_count <= rin_noc2_rx_flit_count;
            r_noc1_tx_flit_count <= rin_noc1_tx_flit_count;
            r_noc2_tx_flit_count <= rin_noc2_tx_flit_count;
        end
    end



    //------------------------
    //select TX output
    generate
    if (TX_IF1_PRIO) begin: TX_IF1

        always @* begin
            rin_tx_arbiter_result = r_tx_arbiter_result;
            tx_stall_if1 = 1'b0;
            tx_stall_if2 = 1'b0;

            //only change arbiter when there is no burst ongoing
            if (!r_tx_burst_active) begin
                if (noc1_tx_wrreq_i) begin
                    rin_tx_arbiter_result = OUT_TX_IF1;
                    tx_stall_if2 = 1'b1;
                end
                else if (noc2_tx_wrreq_i) begin
                    rin_tx_arbiter_result = OUT_TX_IF2;
                end
                else begin
                    rin_tx_arbiter_result = OUT_TX_IF0;
                end
            end

            //keep stalls when burst is active
            else if (r_tx_arbiter_result == OUT_TX_IF1) begin
                tx_stall_if2 = 1'b1;
            end
            else if (r_tx_arbiter_result == OUT_TX_IF2) begin
                tx_stall_if1 = 1'b1;
            end
        end

    end
    else begin: TX_IF2

        always @* begin
            rin_tx_arbiter_result = r_tx_arbiter_result;
            tx_stall_if1 = 1'b0;
            tx_stall_if2 = 1'b0;

            //only change arbiter when there is no burst ongoing
            if (!r_tx_burst_active) begin
                if (noc2_tx_wrreq_i) begin
                    rin_tx_arbiter_result = OUT_TX_IF2;
                    tx_stall_if1 = 1'b1;
                end
                else if (noc1_tx_wrreq_i) begin
                    rin_tx_arbiter_result = OUT_TX_IF1;
                end
                else begin
                    rin_tx_arbiter_result = OUT_TX_IF0;
                end
            end

            //keep stalls when burst is active
            else if (r_tx_arbiter_result == OUT_TX_IF1) begin
                tx_stall_if2 = 1'b1;
            end
            else if (r_tx_arbiter_result == OUT_TX_IF2) begin
                tx_stall_if1 = 1'b1;
            end
        end

    end
    endgenerate



    //check if burst
    always @* begin
        rin_tx_burst_active = r_tx_burst_active;

        if (!noc_out_tx_stall_i && noc_out_tx_wrreq_o) begin
            if (noc_out_tx_burst_o) begin
                rin_tx_burst_active = 1'b1; //on during burst
            end else begin
                rin_tx_burst_active = 1'b0; //off when last flit
            end
        end
    end


    //select output
    always @* begin
        case(rin_tx_arbiter_result)
            OUT_TX_IF1: begin
                noc_out_tx_wrreq_o      = noc1_tx_wrreq_i;
                noc_out_tx_burst_o      = noc1_tx_burst_i;
                noc_out_tx_arq_o        = noc1_tx_arq_i;
                noc_out_tx_bsel_o       = noc1_tx_bsel_i;
                noc_out_tx_src_chipid_o = noc1_tx_src_chipid_i;
                noc_out_tx_src_modid_o  = noc1_tx_src_modid_i;
                noc_out_tx_trg_chipid_o = noc1_tx_trg_chipid_i;
                noc_out_tx_trg_modid_o  = noc1_tx_trg_modid_i;
                noc_out_tx_mode_o       = noc1_tx_mode_i;
                noc_out_tx_addr_o       = noc1_tx_addr_i;
                noc_out_tx_data0_o      = noc1_tx_data0_i;
                noc_out_tx_data1_o      = noc1_tx_data1_i;
            end

            OUT_TX_IF2: begin
                noc_out_tx_wrreq_o      = noc2_tx_wrreq_i;
                noc_out_tx_burst_o      = noc2_tx_burst_i;
                noc_out_tx_arq_o        = noc2_tx_arq_i;
                noc_out_tx_bsel_o       = noc2_tx_bsel_i;
                noc_out_tx_src_chipid_o = noc2_tx_src_chipid_i;
                noc_out_tx_src_modid_o  = noc2_tx_src_modid_i;
                noc_out_tx_trg_chipid_o = noc2_tx_trg_chipid_i;
                noc_out_tx_trg_modid_o  = noc2_tx_trg_modid_i;
                noc_out_tx_mode_o       = noc2_tx_mode_i;
                noc_out_tx_addr_o       = noc2_tx_addr_i;
                noc_out_tx_data0_o      = noc2_tx_data0_i;
                noc_out_tx_data1_o      = noc2_tx_data1_i;
            end

            default: begin
                noc_out_tx_wrreq_o      = 1'b0;
                noc_out_tx_burst_o      = 1'b0;
                noc_out_tx_arq_o        = 1'b0;
                noc_out_tx_bsel_o       = {NOC_BSEL_SIZE{1'b0}};
                noc_out_tx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc_out_tx_src_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc_out_tx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc_out_tx_trg_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc_out_tx_mode_o       = {NOC_MODE_SIZE{1'b0}};
                noc_out_tx_addr_o       = {NOC_ADDR_SIZE{1'b0}};
                noc_out_tx_data0_o      = {NOC_DATA_SIZE{1'b0}};
                noc_out_tx_data1_o      = {NOC_DATA_SIZE{1'b0}};
            end
        endcase
    end


    assign noc1_tx_stall_o = noc_out_tx_stall_i || tx_stall_if1;
    assign noc2_tx_stall_o = noc_out_tx_stall_i || tx_stall_if2;


    //flit counter
    always @* begin
        rin_noc1_tx_flit_count = r_noc1_tx_flit_count;
        if (tcu_reset_i) begin
            rin_noc1_tx_flit_count = 0;
        end

        //wrreq only turns on when stall is zero
        else if (noc1_tx_wrreq_i) begin
            rin_noc1_tx_flit_count = r_noc1_tx_flit_count + 1;
        end
    end

    always @* begin
        rin_noc2_tx_flit_count = r_noc2_tx_flit_count;
        if (tcu_reset_i) begin
            rin_noc2_tx_flit_count = 0;
        end

        //wrreq only turns on when stall is zero
        else if (noc2_tx_wrreq_i) begin
            rin_noc2_tx_flit_count = r_noc2_tx_flit_count + 1;
        end
    end

    assign noc1_tx_flit_count_o = r_noc1_tx_flit_count;
    assign noc2_tx_flit_count_o = r_noc2_tx_flit_count;



    //------------------------
    //select RX output
    always @* begin
        rin_rx_arbiter_result = r_rx_arbiter_result;

        //only change arbiter when there is no burst ongoing
        if (noc_out_rx_wrreq_i && !r_rx_burst_active) begin
            casez({rx_mode_2, if1_rx_addr_valid, if2_rx_addr_valid, RX_IF1_PRIO, RX_IF1_ONLY_MODE_2, RX_IF2_ONLY_MODE_2})
                //rx_mode_1 packets
                6'b01??01: rin_rx_arbiter_result = OUT_RX_IF1;
                6'b0?1?10: rin_rx_arbiter_result = OUT_RX_IF2;
                6'b01?100: rin_rx_arbiter_result = OUT_RX_IF1;
                6'b001100: rin_rx_arbiter_result = OUT_RX_IF2;
                6'b0?1000: rin_rx_arbiter_result = OUT_RX_IF2;
                6'b010000: rin_rx_arbiter_result = OUT_RX_IF1;

                //rx_mode_2 packets
                6'b11?1??: rin_rx_arbiter_result = OUT_RX_IF1;
                6'b1011??: rin_rx_arbiter_result = OUT_RX_IF2;
                6'b1?10??: rin_rx_arbiter_result = OUT_RX_IF2;
                6'b1100??: rin_rx_arbiter_result = OUT_RX_IF1;

                default: rin_rx_arbiter_result = OUT_RX_IF0;
            endcase
        end
    end


    //check if burst
    always @* begin
        rin_rx_burst_active = r_rx_burst_active;

        if (noc_out_rx_wrreq_i && !noc1_rx_stall_i && !noc2_rx_stall_i) begin
            if (noc_out_rx_burst_i) begin
                rin_rx_burst_active = 1'b1; //on during burst
            end else begin
                rin_rx_burst_active = 1'b0; //off when last flit
            end
        end
    end


    //select output
    always @* begin
        case(rin_rx_arbiter_result)
            OUT_RX_IF1: begin
                noc1_rx_wrreq_o      = noc_out_rx_wrreq_i;
                noc1_rx_burst_o      = noc_out_rx_burst_i;
                noc1_rx_arq_o        = noc_out_rx_arq_i;
                noc1_rx_bsel_o       = noc_out_rx_bsel_i;
                noc1_rx_src_chipid_o = noc_out_rx_src_chipid_i;
                noc1_rx_src_modid_o  = noc_out_rx_src_modid_i;
                noc1_rx_trg_chipid_o = noc_out_rx_trg_chipid_i;
                noc1_rx_trg_modid_o  = noc_out_rx_trg_modid_i;
                noc1_rx_mode_o       = noc_out_rx_mode_i;
                noc1_rx_addr_o       = noc_out_rx_addr_i;
                noc1_rx_data0_o      = noc_out_rx_data0_i;
                noc1_rx_data1_o      = noc_out_rx_data1_i;

                noc2_rx_wrreq_o      = 1'b0;
                noc2_rx_burst_o      = 1'b0;
                noc2_rx_arq_o        = 1'b0;
                noc2_rx_bsel_o       = {NOC_BSEL_SIZE{1'b0}};
                noc2_rx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc2_rx_src_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc2_rx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc2_rx_trg_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc2_rx_mode_o       = {NOC_MODE_SIZE{1'b0}};
                noc2_rx_addr_o       = {NOC_ADDR_SIZE{1'b0}};
                noc2_rx_data0_o      = {NOC_DATA_SIZE{1'b0}};
                noc2_rx_data1_o      = {NOC_DATA_SIZE{1'b0}};

                noc_out_rx_stall_o   = noc1_rx_stall_i;
            end

            OUT_RX_IF2: begin
                noc1_rx_wrreq_o      = 1'b0;
                noc1_rx_burst_o      = 1'b0;
                noc1_rx_arq_o        = 1'b0;
                noc1_rx_bsel_o       = {NOC_BSEL_SIZE{1'b0}};
                noc1_rx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc1_rx_src_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc1_rx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc1_rx_trg_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc1_rx_mode_o       = {NOC_MODE_SIZE{1'b0}};
                noc1_rx_addr_o       = {NOC_ADDR_SIZE{1'b0}};
                noc1_rx_data0_o      = {NOC_DATA_SIZE{1'b0}};
                noc1_rx_data1_o      = {NOC_DATA_SIZE{1'b0}};

                noc2_rx_wrreq_o      = noc_out_rx_wrreq_i;
                noc2_rx_burst_o      = noc_out_rx_burst_i;
                noc2_rx_arq_o        = noc_out_rx_arq_i;
                noc2_rx_bsel_o       = noc_out_rx_bsel_i;
                noc2_rx_src_chipid_o = noc_out_rx_src_chipid_i;
                noc2_rx_src_modid_o  = noc_out_rx_src_modid_i;
                noc2_rx_trg_chipid_o = noc_out_rx_trg_chipid_i;
                noc2_rx_trg_modid_o  = noc_out_rx_trg_modid_i;
                noc2_rx_mode_o       = noc_out_rx_mode_i;
                noc2_rx_addr_o       = noc_out_rx_addr_i;
                noc2_rx_data0_o      = noc_out_rx_data0_i;
                noc2_rx_data1_o      = noc_out_rx_data1_i;

                noc_out_rx_stall_o   = noc2_rx_stall_i;
            end

            default: begin
                noc1_rx_wrreq_o      = 1'b0;
                noc1_rx_burst_o      = 1'b0;
                noc1_rx_arq_o        = 1'b0;
                noc1_rx_bsel_o       = {NOC_BSEL_SIZE{1'b0}};
                noc1_rx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc1_rx_src_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc1_rx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc1_rx_trg_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc1_rx_mode_o       = {NOC_MODE_SIZE{1'b0}};
                noc1_rx_addr_o       = {NOC_ADDR_SIZE{1'b0}};
                noc1_rx_data0_o      = {NOC_DATA_SIZE{1'b0}};
                noc1_rx_data1_o      = {NOC_DATA_SIZE{1'b0}};

                noc2_rx_wrreq_o      = 1'b0;
                noc2_rx_burst_o      = 1'b0;
                noc2_rx_arq_o        = 1'b0;
                noc2_rx_bsel_o       = {NOC_BSEL_SIZE{1'b0}};
                noc2_rx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc2_rx_src_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc2_rx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
                noc2_rx_trg_modid_o  = {NOC_MODID_SIZE{1'b0}};
                noc2_rx_mode_o       = {NOC_MODE_SIZE{1'b0}};
                noc2_rx_addr_o       = {NOC_ADDR_SIZE{1'b0}};
                noc2_rx_data0_o      = {NOC_DATA_SIZE{1'b0}};
                noc2_rx_data1_o      = {NOC_DATA_SIZE{1'b0}};

                noc_out_rx_stall_o   = 1'b1;
            end
        endcase
    end

    //flit counter
    always @* begin
        rin_noc1_rx_flit_count = r_noc1_rx_flit_count;
        if (tcu_reset_i) begin
            rin_noc1_rx_flit_count = 0;
        end
        else if (noc1_rx_wrreq_o && !noc1_rx_stall_i) begin
            rin_noc1_rx_flit_count = r_noc1_rx_flit_count + 1;
        end
    end

    always @* begin
        rin_noc2_rx_flit_count = r_noc2_rx_flit_count;
        if (tcu_reset_i) begin
            rin_noc2_rx_flit_count = 0;
        end
        else if (noc2_rx_wrreq_o && !noc2_rx_stall_i) begin
            rin_noc2_rx_flit_count = r_noc2_rx_flit_count + 1;
        end
    end

    assign noc1_rx_flit_count_o = r_noc1_rx_flit_count;
    assign noc2_rx_flit_count_o = r_noc2_rx_flit_count;


endmodule
