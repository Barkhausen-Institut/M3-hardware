
module tcu_noc_fifo #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_NOC_FIFO       = 0,
    parameter FIFO_DEPTH                 = $clog2(MAX_BURST_LENGTH_MSG),
    parameter NOC_MASTER                 = 0,  //master mode: set to 1 if wrreq should be combined with stall
    parameter FIFO_POP_FULL_BURST_ONLY   = 1,  //FIFO will pop burst packet only when burst is completely inside FIFO
    parameter FIFO_PUSH_EMPTY_BURST_ONLY = 0   //FIFO will not take burst packets as long as FIFO is not empty
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    input  wire                          noc_wrreq_i,
    input  wire                          noc_burst_i,
    input  wire      [NOC_BSEL_SIZE-1:0] noc_bsel_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_src_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_src_modid_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_trg_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_trg_modid_i,
    input  wire      [NOC_MODE_SIZE-1:0] noc_mode_i,
    input  wire      [NOC_ADDR_SIZE-1:0] noc_addr_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_data0_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_data1_i,
    output wire                          noc_stall_o,

    output wire                          noc_wrreq_o,
    output wire                          noc_burst_o,
    output wire      [NOC_BSEL_SIZE-1:0] noc_bsel_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_src_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_src_modid_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_trg_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_trg_modid_o,
    output wire      [NOC_MODE_SIZE-1:0] noc_mode_o,
    output wire      [NOC_ADDR_SIZE-1:0] noc_addr_o,
    output wire      [NOC_DATA_SIZE-1:0] noc_data0_o,
    output wire      [NOC_DATA_SIZE-1:0] noc_data1_o,
    input  wire                          noc_stall_i
);

    localparam FIFO_WIDTH = NOC_HEADER_SIZE + NOC_PAYLOAD_SIZE - NOC_ARQ_SIZE;  //TCU controller does not handle ARQ bit

    localparam COUNT_SIZE = 8+1;    //+1 for overflow flag


    generate
    if (TCU_ENABLE_NOC_FIFO) begin: enable_fifo

        reg [FIFO_WIDTH-1:0] rin_fifo_wdata;

        reg                  rin_noc_wrreq_out;
        reg                  r_noc_burst_in;
        reg                  r_noc_burst_out;
        reg [COUNT_SIZE-1:0] r_burst_count_in, rin_burst_count_in;
        reg [COUNT_SIZE-1:0] r_burst_count_out, rin_burst_count_out;


        wire [FIFO_WIDTH-1:0] fifo_wdata_noburst = {noc_burst_i,
                                                    noc_bsel_i,
                                                    noc_src_modid_i,
                                                    noc_src_chipid_i,
                                                    noc_trg_modid_i,
                                                    noc_trg_chipid_i,
                                                    noc_mode_i,
                                                    noc_addr_i,
                                                    noc_data0_i};

        wire [FIFO_WIDTH-1:0] fifo_wdata_burst = {noc_burst_i,
                                                    noc_bsel_i,
                                                    noc_data1_i,
                                                    noc_data0_i};

        wire [FIFO_WIDTH-1:0] fifo_rdata;

        wire fifo_empty;
        wire fifo_full;
        wire fifo_pop = rin_noc_wrreq_out && !noc_stall_i;
        reg fifo_push;
        wire noc_burst_out = fifo_rdata[FIFO_WIDTH-1];  //MSB
        
        //counter detect number of finished bursts
        wire burst_ready = ((r_burst_count_in[COUNT_SIZE-2:0] > r_burst_count_out[COUNT_SIZE-2:0]) &&
                            (r_burst_count_in[COUNT_SIZE-1] == r_burst_count_out[COUNT_SIZE-1])) ||
                                ((r_burst_count_in[COUNT_SIZE-2:0] < r_burst_count_out[COUNT_SIZE-2:0]) &&
                                (r_burst_count_in[COUNT_SIZE-1] != r_burst_count_out[COUNT_SIZE-1]));

        //in master mode stall is 1 by default, stall is deasserted when wrreq is there and flit can be taken (FIFO not full)
        assign noc_stall_o = (NOC_MASTER == 1) ? (fifo_full || !fifo_push) : fifo_full;


        sync_fifo #(
            .DATA_WIDTH (FIFO_WIDTH),
            .ADDR_WIDTH (FIFO_DEPTH),
            .USE_MEM    (1)
        ) i_fifo (
            .clk_i      (clk_i),
            .resetn_i   (reset_n_i),

            .wr_en_i    (fifo_push),
            .wdata_i    (rin_fifo_wdata),
            .wfull_o    (fifo_full),

            .rd_en_i    (fifo_pop),
            .rdata_o    (fifo_rdata),
            .rempty_o   (fifo_empty)
        );



        always @(posedge clk_i or negedge reset_n_i) begin
            if (reset_n_i == 1'b0) begin
                r_noc_burst_in <= 1'b0;
                r_noc_burst_out <= 1'b0;
                r_burst_count_in <= {COUNT_SIZE{1'b0}};
                r_burst_count_out <= {COUNT_SIZE{1'b0}};
            end else begin
                r_noc_burst_in <= (noc_wrreq_i && !noc_stall_o) ? noc_burst_i : r_noc_burst_in;
                r_noc_burst_out <= (noc_wrreq_o && !noc_stall_i) ? noc_burst_out : r_noc_burst_out;
                r_burst_count_in <= rin_burst_count_in;
                r_burst_count_out <= rin_burst_count_out;
            end
        end


        //FIFO input handling
        always @* begin
            fifo_push = 1'b0;
            rin_burst_count_in = r_burst_count_in;
            rin_fifo_wdata = {FIFO_WIDTH{1'b0}};

            //reset counter if FIFO is empty
            if (fifo_empty) begin
                rin_burst_count_in = {COUNT_SIZE{1'b0}};
            end

            //despite an empty FIFO there could be a wrreq where the counter has to be incremented
            if (noc_wrreq_i && !fifo_full) begin
                //single packet or header of burst
                if (!r_noc_burst_in) begin
                    rin_fifo_wdata = fifo_wdata_noburst;

                    //if FIFO_PUSH_EMPTY_BURST_ONLY=1 only push when FIFO empty
                    if (noc_burst_i) begin
                        if (!FIFO_PUSH_EMPTY_BURST_ONLY || fifo_empty) begin
                            fifo_push = 1'b1;
                        end
                    end

                    //single packet: always push
                    else begin
                        fifo_push = 1'b1;
                    end
                end
                
                //burst packet
                else begin
                    fifo_push = 1'b1;
                    rin_fifo_wdata = fifo_wdata_burst;

                    //if it is last flit of burst increment counter
                    if (!noc_burst_i) begin
                        //only if FIFO is empty, this is always the first burst
                        if (fifo_empty) begin
                            rin_burst_count_in = 1;
                        end else begin
                            rin_burst_count_in = r_burst_count_in + 1;
                        end
                    end
                end
            end
        end


        //FIFO output handling
        always @* begin
            rin_noc_wrreq_out = 1'b0;
            rin_burst_count_out = r_burst_count_out;

            if (!fifo_empty) begin
                //if it is not a burst or last flit of burst has arrived in FIFO - take it
                //parameter FIFO_POP_FULL_BURST_ONLY ensures that wrreq is always set
                if (!FIFO_POP_FULL_BURST_ONLY || !noc_burst_out || burst_ready) begin
                    rin_noc_wrreq_out = 1'b1;
                end

                //detect last flit of outgoing burst to increment counter
                if (!noc_burst_out && r_noc_burst_out && !noc_stall_i) begin
                    rin_burst_count_out = r_burst_count_out + 1;
                end
            end
            else begin
                rin_burst_count_out = {COUNT_SIZE{1'b0}};
            end
        end



        //FIFO output data
        assign noc_wrreq_o      = rin_noc_wrreq_out;
        assign noc_burst_o      = noc_burst_out;
        assign noc_bsel_o       = fifo_rdata[FIFO_WIDTH-NOC_BURST_SIZE-1 : FIFO_WIDTH-NOC_BURST_SIZE-NOC_BSEL_SIZE];
        assign noc_src_modid_o  = fifo_rdata[NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE+2*NOC_MODID_SIZE+2*NOC_CHIPID_SIZE-1 :
                                                NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE+NOC_MODID_SIZE+2*NOC_CHIPID_SIZE];
        assign noc_src_chipid_o = fifo_rdata[NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE+NOC_MODID_SIZE+2*NOC_CHIPID_SIZE-1 :
                                                NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE+NOC_MODID_SIZE+NOC_CHIPID_SIZE];
        assign noc_trg_modid_o  = fifo_rdata[NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE+NOC_MODID_SIZE+NOC_CHIPID_SIZE-1 :
                                                NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE+NOC_CHIPID_SIZE];
        assign noc_trg_chipid_o = fifo_rdata[NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE+NOC_CHIPID_SIZE-1 :
                                                NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE];
        assign noc_mode_o       = fifo_rdata[NOC_DATA_SIZE+NOC_ADDR_SIZE+NOC_MODE_SIZE-1 : NOC_DATA_SIZE+NOC_ADDR_SIZE];
        assign noc_addr_o       = fifo_rdata[NOC_DATA_SIZE+NOC_ADDR_SIZE-1 : NOC_DATA_SIZE];
        assign noc_data1_o      = fifo_rdata[2*NOC_DATA_SIZE-1 : NOC_DATA_SIZE];
        assign noc_data0_o      = fifo_rdata[NOC_DATA_SIZE-1 : 0];

        
    end
    else begin: disable_fifo

        assign noc_wrreq_o      = noc_wrreq_i;
        assign noc_burst_o      = noc_burst_i;
        assign noc_bsel_o       = noc_bsel_i;
        assign noc_src_chipid_o = noc_src_chipid_i;
        assign noc_src_modid_o  = noc_src_modid_i;
        assign noc_trg_chipid_o = noc_trg_chipid_i;
        assign noc_trg_modid_o  = noc_trg_modid_i;
        assign noc_mode_o       = noc_mode_i;
        assign noc_addr_o       = noc_addr_i;
        assign noc_data0_o      = noc_data0_i;
        assign noc_data1_o      = noc_data1_i;
        assign noc_stall_o      = noc_stall_i;

    end
    endgenerate


endmodule
