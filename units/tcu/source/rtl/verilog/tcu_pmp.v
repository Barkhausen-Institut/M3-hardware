
`include "tcu_defines.vh"

module tcu_pmp #(
    `include "tcu_parameter.vh"
    ,`include "noc_parameter.vh"
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,
    input  wire                          tcu_reset_i,

    input  wire    [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] home_modid_i,
    output wire [TCU_FLITCOUNT_SIZE-1:0] pmp_drop_flit_count_o, 

    //---------------
    //Reg IF (only read)
    output reg                           reg_en_o,
    output wire  [TCU_REG_ADDR_SIZE-1:0] reg_addr_o,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_rdata_i,
    input  wire                          reg_stall_i,

    //---------------
    //NoC IF to/from core
    input  wire                          noc_in_tx_wrreq_i,
    input  wire                          noc_in_tx_burst_i,
    input  wire                          noc_in_tx_arq_i,
    input  wire      [NOC_BSEL_SIZE-1:0] noc_in_tx_bsel_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_in_tx_src_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_in_tx_src_modid_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] noc_in_tx_trg_chipid_i,
    input  wire     [NOC_MODID_SIZE-1:0] noc_in_tx_trg_modid_i,
    input  wire      [NOC_MODE_SIZE-1:0] noc_in_tx_mode_i,
    input  wire      [NOC_ADDR_SIZE-1:0] noc_in_tx_addr_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_in_tx_data0_i,
    input  wire      [NOC_DATA_SIZE-1:0] noc_in_tx_data1_i,
    output wire                          noc_in_tx_stall_o,

    output reg                           noc_in_rx_wrreq_o,
    output reg                           noc_in_rx_burst_o,
    output reg                           noc_in_rx_arq_o,
    output reg       [NOC_BSEL_SIZE-1:0] noc_in_rx_bsel_o,
    output reg     [NOC_CHIPID_SIZE-1:0] noc_in_rx_src_chipid_o,
    output reg      [NOC_MODID_SIZE-1:0] noc_in_rx_src_modid_o,
    output reg     [NOC_CHIPID_SIZE-1:0] noc_in_rx_trg_chipid_o,
    output reg      [NOC_MODID_SIZE-1:0] noc_in_rx_trg_modid_o,
    output reg       [NOC_MODE_SIZE-1:0] noc_in_rx_mode_o,
    output reg       [NOC_ADDR_SIZE-1:0] noc_in_rx_addr_o,
    output reg       [NOC_DATA_SIZE-1:0] noc_in_rx_data0_o,
    output reg       [NOC_DATA_SIZE-1:0] noc_in_rx_data1_o,
    input  wire                          noc_in_rx_stall_i,

    //---------------
    //NoC IF to/from NoC via NoC-MUX
    output reg                           noc_out_tx_wrreq_o,
    output wire                          noc_out_tx_burst_o,
    output wire                          noc_out_tx_arq_o,
    output wire      [NOC_BSEL_SIZE-1:0] noc_out_tx_bsel_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_out_tx_src_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_out_tx_src_modid_o,
    output wire    [NOC_CHIPID_SIZE-1:0] noc_out_tx_trg_chipid_o,
    output wire     [NOC_MODID_SIZE-1:0] noc_out_tx_trg_modid_o,
    output wire      [NOC_MODE_SIZE-1:0] noc_out_tx_mode_o,
    output wire      [NOC_ADDR_SIZE-1:0] noc_out_tx_addr_o,
    output wire      [NOC_DATA_SIZE-1:0] noc_out_tx_data0_o,
    output wire      [NOC_DATA_SIZE-1:0] noc_out_tx_data1_o,
    input  wire                          noc_out_tx_stall_i,

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
    //PMP failures
    input  wire                                 core_req_enable_i,
    output reg                                  core_req_push_o,
    output reg  [TCU_CORE_REQ_PMPFAIL_SIZE-1:0] core_req_data_o,
    input  wire                                 core_req_stall_i,

    //---------------
    //logging
    output reg   [TCU_LOG_DATA_SIZE-1:0] tcu_log_pmp_o
);

    `include "tcu_functions.v"

    localparam FIFO_WIDTH = NOC_HEADER_SIZE + NOC_PAYLOAD_SIZE;

    localparam PMP_STATES_SIZE    = 4;
    localparam S_PMP_IDLE         = 4'h0;
    localparam S_PMP_READEP_REG1  = 4'h1;
    localparam S_PMP_READEP_REG2  = 4'h2;
    localparam S_PMP_READEP_REG3  = 4'h3;
    localparam S_PMP_READEP_REG4  = 4'h4;
    localparam S_PMP_CHECK_EP     = 4'h5;
    localparam S_PMP_CHECK_ACCESS = 4'h6;
    localparam S_PMP_CHECK_OFFSET = 4'h7;
    localparam S_PMP_FAIL1        = 4'h8;
    localparam S_PMP_FAIL2        = 4'h9;
    localparam S_PMP_RUN          = 4'hA;
    localparam S_PMP_ERROR_RSP    = 4'hB;
    localparam S_PMP_DROP_PACKET  = 4'hC;
    localparam S_PMP_FINISH       = 4'hF;

    reg [PMP_STATES_SIZE-1:0] pmp_state, next_pmp_state;


    reg                         r_reg_en;
    reg [TCU_REG_ADDR_SIZE-1:0] r_reg_addr, rin_reg_addr;

    reg r_noc_in_tx_burst;
    reg r_noc_out_rx_burst;

    reg [63:0] r_mep_0, rin_mep_0;
    reg [63:0] r_mep_1, rin_mep_1;
    reg [63:0] r_mep_2, rin_mep_2;

    //size (in bytes) of memory access
    reg [15:0] r_size, rin_size;

    //number of dropped flits
    reg [TCU_FLITCOUNT_SIZE-1:0] r_drop_flit_count, rin_drop_flit_count;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_pmp_error, rin_pmp_error;

    reg  fifo_pop;
    wire fifo_push = noc_in_tx_wrreq_i && !noc_in_tx_stall_o;
    wire fifo_empty;
    wire fifo_full;

    wire [FIFO_WIDTH-1:0] fifo_dataout;
    wire [FIFO_WIDTH-1:0] fifo_datain = r_noc_in_tx_burst ? {
        noc_in_tx_burst_i,
        noc_in_tx_arq_i,
        noc_in_tx_bsel_i,
        noc_in_tx_data1_i,
        noc_in_tx_data0_i} : {
        noc_in_tx_burst_i,
        noc_in_tx_arq_i,
        noc_in_tx_bsel_i,
        noc_in_tx_src_modid_i,
        noc_in_tx_src_chipid_i,
        noc_in_tx_trg_modid_i,
        noc_in_tx_trg_chipid_i,
        noc_in_tx_mode_i,
        noc_in_tx_addr_i,
        noc_in_tx_data0_i};

    wire                       fifo_dataout_burst      = fifo_dataout[FIFO_WIDTH-1];
    wire                       fifo_dataout_arq        = fifo_dataout[FIFO_WIDTH-NOC_BURST_SIZE-1];
    wire   [NOC_BSEL_SIZE-1:0] fifo_dataout_bsel       = fifo_dataout[NOC_BSEL_SIZE+2*NOC_CHIPID_SIZE+2*NOC_MODID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 :
                                                                        2*NOC_CHIPID_SIZE+2*NOC_MODID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE];
    wire  [NOC_MODID_SIZE-1:0] fifo_dataout_src_modid  = fifo_dataout[2*NOC_CHIPID_SIZE+2*NOC_MODID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 :
                                                                        2*NOC_CHIPID_SIZE+NOC_MODID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE];
    wire [NOC_CHIPID_SIZE-1:0] fifo_dataout_src_chipid = fifo_dataout[2*NOC_CHIPID_SIZE+NOC_MODID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 :
                                                                        NOC_CHIPID_SIZE+NOC_MODID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE];
    wire  [NOC_MODID_SIZE-1:0] fifo_dataout_trg_modid  = fifo_dataout[NOC_CHIPID_SIZE+NOC_MODID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 :
                                                                        NOC_CHIPID_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE];
    wire [NOC_CHIPID_SIZE-1:0] fifo_dataout_trg_chipid = fifo_dataout[NOC_CHIPID_SIZE+NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 :
                                                                        NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE];
    wire   [NOC_MODE_SIZE-1:0] fifo_dataout_mode       = fifo_dataout[NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_ADDR_SIZE+NOC_DATA_SIZE];
    wire   [NOC_ADDR_SIZE-1:0] fifo_dataout_addr       = fifo_dataout[NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_DATA_SIZE];
    wire   [NOC_DATA_SIZE-1:0] fifo_dataout_data1      = fifo_dataout[2*NOC_DATA_SIZE-1 : NOC_DATA_SIZE];
    wire   [NOC_DATA_SIZE-1:0] fifo_dataout_data0      = fifo_dataout[NOC_DATA_SIZE-1 : 0];


    wire  [3:0] start_shift  = ~fifo_dataout_bsel[3:0];
    wire  [4:0] end_shift    = fifo_dataout_bsel[7:4] + 5'd1;
    wire [12:0] burst_length = fifo_dataout_data0[12:0];   //number of 16-byte packets

    wire  [3:0] bsel_count_ones = count_ones8(fifo_dataout_bsel);


    //subtract addr offset of RISC-V Rocket core
    wire [NOC_ADDR_SIZE-1:0] pmp_addr = fifo_dataout_addr - 32'h10000000;

    //upper 2 bits of address determine the EP
    wire [1:0] epidx = pmp_addr[31:30];

    wire [29:0] pmp_offset = pmp_addr[29:0];

    wire [NOC_MODE_SIZE-1:0] pmp_mode = fifo_dataout_mode;
    wire [1:0] access_rw = ((pmp_mode == MODE_READ_REQ) || (pmp_mode == MODE_READ_REQ_2)) ? TCU_MEMFLAG_R :
                            ((pmp_mode == MODE_WRITE_POSTED) || (pmp_mode == MODE_WRITE_POSTED_2) || (pmp_mode == MODE_READ_RSP) || (pmp_mode == MODE_READ_RSP_2)) ? TCU_MEMFLAG_W :
                            2'h0;


    //split mep data
    wire [TCU_EP_TYPE_SIZE-1:0] mep_type    = r_mep_0[TCU_EP_TYPE_SIZE-1:0];
    wire [TCU_MEMFLAG_SIZE-1:0] mep_memflag = r_mep_0[TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire    [TCU_PEID_SIZE-1:0] mep_pe      = r_mep_0[TCU_PEID_SIZE+TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire  [TCU_CHIPID_SIZE-1:0] mep_chip    = r_mep_0[TCU_CHIPID_SIZE+TCU_PEID_SIZE+TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE-1 : TCU_PEID_SIZE+TCU_MEMFLAG_SIZE+TCU_VPEID_SIZE+TCU_EP_TYPE_SIZE];
    wire                 [63:0] mep_addr    = r_mep_1;
    wire                 [63:0] mep_size    = r_mep_2;



    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            pmp_state <= S_PMP_IDLE;

            r_reg_en <= 1'b0;
            r_reg_addr <= {TCU_REG_ADDR_SIZE{1'b0}};

            r_noc_in_tx_burst <= 1'b0;
            r_noc_out_rx_burst <= 1'b0;

            r_mep_0 <= 64'h0;
            r_mep_1 <= 64'h0;
            r_mep_2 <= 64'h0;

            r_size <= 16'h0;

            r_drop_flit_count <= {TCU_FLITCOUNT_SIZE{1'b0}};

            r_pmp_error <= TCU_ERROR_NONE;
        end
        else begin
            pmp_state <= next_pmp_state;

            r_reg_en <= reg_en_o;
            r_reg_addr <= rin_reg_addr;

            r_noc_in_tx_burst <= (noc_in_tx_wrreq_i && !noc_in_tx_stall_o) ? noc_in_tx_burst_i : r_noc_in_tx_burst;
            r_noc_out_rx_burst <= (noc_out_rx_wrreq_i && !noc_out_rx_stall_o) ? noc_out_rx_burst_i : r_noc_out_rx_burst;

            r_mep_0 <= rin_mep_0;
            r_mep_1 <= rin_mep_1;
            r_mep_2 <= rin_mep_2;

            r_size <= rin_size;

            r_drop_flit_count <= rin_drop_flit_count;

            r_pmp_error <= rin_pmp_error;
        end
    end


    always @* begin
        rin_drop_flit_count = r_drop_flit_count;

        if (tcu_reset_i) begin
            rin_drop_flit_count = {TCU_FLITCOUNT_SIZE{1'b0}};
        end
        else if ((pmp_state == S_PMP_DROP_PACKET) && !fifo_empty) begin
            rin_drop_flit_count = r_drop_flit_count + 1;
        end
    end


    //FIFO to store packets from core
    sync_fifo #(
        .DATA_WIDTH (FIFO_WIDTH),
        .ADDR_WIDTH (2)
    ) req_wfifo (
        .clk_i		(clk_i),
        .resetn_i	(reset_n_i),

        .wr_en_i	(fifo_push),
        .wdata_i	(fifo_datain),
        .wfull_o	(fifo_full),

        .rd_en_i	(fifo_pop),
        .rdata_o	(fifo_dataout),
        .rempty_o	(fifo_empty)
    );

    


    //---------------
    //state machine to determine physical memory location
    always @* begin
        next_pmp_state = pmp_state;

        reg_en_o = 1'b0;
        rin_reg_addr = r_reg_addr;

        rin_mep_0 = r_mep_0;
        rin_mep_1 = r_mep_1;
        rin_mep_2 = r_mep_2;

        rin_size = r_size;

        rin_pmp_error = r_pmp_error;

        fifo_pop = 1'b0;

        noc_out_tx_wrreq_o = 1'b0;

        tcu_log_pmp_o = TCU_LOG_NONE;

        core_req_push_o = 1'b0;
        core_req_data_o = {TCU_CORE_REQ_PMPFAIL_SIZE{1'b0}};


        case (pmp_state)

            //---------------
            //wait until a packet is in FIFO
            S_PMP_IDLE: begin
                if (!fifo_empty) begin
                    rin_reg_addr = TCU_REGADDR_EP_START + epidx*TCU_EP_REG_SIZE;
                    rin_size = 'd0;
                    rin_pmp_error = TCU_ERROR_NONE;

                    //write
                    if (access_rw & TCU_MEMFLAG_W) begin
                        //if it is a burst
                        if (fifo_dataout_burst) begin
                            rin_size = {burst_length, 4'h0} - start_shift - (5'd16 - end_shift);
                        end

                        //no burst
                        else begin
                            rin_size = bsel_count_ones;
                        end
                    end

                    //read (this should not be a burst)
                    else if ((access_rw & TCU_MEMFLAG_R) && !fifo_dataout_burst) begin
                        rin_size = fifo_dataout_data0[NOC_DATA_SIZE-1:32];
                    end

                    next_pmp_state = S_PMP_READEP_REG1;
                end
            end


            //---------------
            //read EP
            S_PMP_READEP_REG1: begin
                if (!reg_stall_i) begin
                    reg_en_o = 1'b1;
                    rin_reg_addr = r_reg_addr + 'd8;
                    next_pmp_state = S_PMP_READEP_REG2;
                end
            end

            S_PMP_READEP_REG2: begin
                if (r_reg_en) begin
                    rin_mep_0 = reg_rdata_i;
                end

                if (!reg_stall_i) begin
                    reg_en_o = 1'b1;
                    rin_reg_addr = r_reg_addr + 'd8;
                    next_pmp_state = S_PMP_READEP_REG3;
                end
            end

            S_PMP_READEP_REG3: begin
                if (r_reg_en) begin
                    rin_mep_1 = reg_rdata_i;
                end

                if (!reg_stall_i) begin
                    reg_en_o = 1'b1;
                    next_pmp_state = S_PMP_READEP_REG4;
                end
            end

            S_PMP_READEP_REG4: begin
                rin_mep_2 = reg_rdata_i;
                next_pmp_state = S_PMP_CHECK_EP;
            end


            //---------------
            //check if memory access is allowed
            S_PMP_CHECK_EP: begin
                if (mep_type == TCU_EP_TYPE_MEMORY) begin
                    next_pmp_state = S_PMP_CHECK_ACCESS;
                end
                else begin
                    rin_pmp_error = TCU_ERROR_NO_MEP;
                    next_pmp_state = S_PMP_FAIL1;
                end
            end

            S_PMP_CHECK_ACCESS: begin
                if (mep_memflag & access_rw) begin
                    next_pmp_state = S_PMP_CHECK_OFFSET;
                end
                else begin
                    rin_pmp_error = TCU_ERROR_NO_PERM;
                    next_pmp_state = S_PMP_FAIL1;
                end
            end

            S_PMP_CHECK_OFFSET: begin
                if ((pmp_offset + r_size) <= mep_size) begin
                    next_pmp_state = S_PMP_RUN;
                end
                else begin
                    rin_pmp_error = TCU_ERROR_OUT_OF_BOUNDS;
                    next_pmp_state = S_PMP_FAIL1;
                end
            end

            S_PMP_FAIL1: begin
                //if enabled, set core request
                if (core_req_enable_i) begin
                    if (!core_req_stall_i) begin
                        core_req_push_o = 1'b1;
                        core_req_data_o = {fifo_dataout_addr,
                                            r_pmp_error,
                                            (access_rw & TCU_MEMFLAG_W) ? 1'b1 : 1'b0};
                        next_pmp_state = S_PMP_FAIL2;
                    end
                end
                else begin
                    next_pmp_state = S_PMP_FAIL2;
                end
            end

            S_PMP_FAIL2: begin
                `TCU_DEBUG(("PMP_ACCESS_DENIED, mode: %d, addr: 0x%x, size: %0d", pmp_mode, fifo_dataout_addr, r_size));
                tcu_log_pmp_o = {r_size, fifo_dataout_addr, pmp_mode, TCU_LOG_PMP_ACCESS_DENIED};

                //send error only for read
                if (access_rw & TCU_MEMFLAG_R) begin
                    next_pmp_state = S_PMP_ERROR_RSP;
                end
                else begin
                    next_pmp_state = S_PMP_DROP_PACKET;
                end
            end

            S_PMP_RUN: begin
                if (!fifo_empty) begin
                    noc_out_tx_wrreq_o = 1'b1;

                    if (!noc_out_tx_stall_i) begin
                        //if it is a burst, stay here and forward whole burst
                        if (fifo_dataout_burst) begin
                            fifo_pop = 1'b1;
                        end
                        else begin
                            next_pmp_state = S_PMP_FINISH;
                        end
                    end
                end
            end


            //---------------
            //memory access not allowed, send error response packet
            S_PMP_ERROR_RSP: begin
                if (!noc_out_rx_wrreq_i && !r_noc_out_rx_burst && !noc_in_rx_stall_i) begin
                    next_pmp_state = S_PMP_DROP_PACKET;
                end
            end

            //drop packets
            S_PMP_DROP_PACKET: begin
                if (!fifo_empty) begin
                    //drop packets as long as burst is ongoing
                    //last burst packet is dropped in finish state
                    if (fifo_dataout_burst) begin
                        fifo_pop = 1'b1;
                    end
                    else begin
                        next_pmp_state = S_PMP_FINISH;
                    end
                end
            end

            //---------------
            S_PMP_FINISH: begin
                fifo_pop = 1'b1;
                next_pmp_state = S_PMP_IDLE;
            end

            default: next_pmp_state = S_PMP_IDLE;
        endcase
    end


    //---------------
    //mux between incoming NoC packets and error response
    always @* begin
        noc_in_rx_wrreq_o      = 1'b0;
        noc_in_rx_burst_o      = 1'b0;
        noc_in_rx_arq_o        = 1'b0;
        noc_in_rx_bsel_o       = {NOC_BSEL_SIZE{1'b0}};
        noc_in_rx_src_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
        noc_in_rx_src_modid_o  = {NOC_MODID_SIZE{1'b0}};
        noc_in_rx_trg_chipid_o = {NOC_CHIPID_SIZE{1'b0}};
        noc_in_rx_trg_modid_o  = {NOC_MODID_SIZE{1'b0}};
        noc_in_rx_mode_o       = {NOC_MODE_SIZE{1'b0}};
        noc_in_rx_addr_o       = {NOC_ADDR_SIZE{1'b0}};
        noc_in_rx_data0_o      = {NOC_DATA_SIZE{1'b0}};
        noc_in_rx_data1_o      = {NOC_DATA_SIZE{1'b0}};
        noc_out_rx_stall_o     = 1'b1;

        //pass through packets from NoC
        if (noc_out_rx_wrreq_i) begin
            noc_in_rx_wrreq_o      = noc_out_rx_wrreq_i;
            noc_in_rx_burst_o      = noc_out_rx_burst_i;
            noc_in_rx_arq_o        = noc_out_rx_arq_i;
            noc_in_rx_bsel_o       = noc_out_rx_bsel_i;
            noc_in_rx_src_chipid_o = noc_out_rx_src_chipid_i;
            noc_in_rx_src_modid_o  = noc_out_rx_src_modid_i;
            noc_in_rx_trg_chipid_o = noc_out_rx_trg_chipid_i;
            noc_in_rx_trg_modid_o  = noc_out_rx_trg_modid_i;
            noc_in_rx_mode_o       = noc_out_rx_mode_i;
            noc_in_rx_addr_o       = noc_out_rx_addr_i;
            noc_in_rx_data0_o      = noc_out_rx_data0_i;
            noc_in_rx_data1_o      = noc_out_rx_data1_i;
            noc_out_rx_stall_o     = noc_in_rx_stall_i;
        end

        //send error response packet (do not interrupt burst from NoC)
        else if ((pmp_state == S_PMP_ERROR_RSP) && !r_noc_out_rx_burst) begin
            noc_in_rx_wrreq_o      = 1'b1;
            noc_in_rx_bsel_o       = {NOC_BSEL_SIZE{1'b1}};
            noc_in_rx_src_chipid_o = home_chipid_i;
            noc_in_rx_src_modid_o  = home_modid_i;
            noc_in_rx_trg_chipid_o = home_chipid_i;
            noc_in_rx_trg_modid_o  = home_modid_i;
            noc_in_rx_mode_o       = MODE_ERROR;
            noc_in_rx_addr_o       = fifo_dataout_addr;
            noc_in_rx_data0_o      = {NOC_DATA_SIZE{1'b0}}; //todo: return TCU error
        end
    end


    assign pmp_drop_flit_count_o = r_drop_flit_count;

    assign reg_addr_o = r_reg_addr;

    //assign data from FIFO to NoC interface
    assign noc_out_tx_burst_o      = fifo_dataout_burst;
    assign noc_out_tx_arq_o        = fifo_dataout_arq;
    assign noc_out_tx_bsel_o       = fifo_dataout_bsel;
    assign noc_out_tx_src_modid_o  = home_modid_i;
    assign noc_out_tx_trg_modid_o  = mep_pe;
    assign noc_out_tx_src_chipid_o = home_chipid_i;
    assign noc_out_tx_trg_chipid_o = mep_chip;
    assign noc_out_tx_mode_o       = fifo_dataout_mode;
    assign noc_out_tx_addr_o       = mep_addr + pmp_offset;
    assign noc_out_tx_data0_o      = fifo_dataout_data0;
    assign noc_out_tx_data1_o      = fifo_dataout_data1;

    //stall to core when FIFO full
    assign noc_in_tx_stall_o = fifo_full;


endmodule
