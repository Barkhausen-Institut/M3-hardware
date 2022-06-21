`ifndef tROUTER_XY_BE_ONLY_STAR_MESH_LUT
`define tROUTER_XY_BE_ONLY_STAR_MESH_LUT


// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module router_OnOff_lut #(
    `include "noc_parameter.vh"
    ,parameter                              INSTANCE_NAME       = "R1",
    parameter                               INPORT_QUANT        = 1,        //number of links + modules + router!!!
    parameter                               OUTPORT_QUANT       = 1,        //number of links + modules + router!!!
    parameter                               MODULES_PER_ROUTER  = 1,
    parameter                               LINKS_PER_ROUTER    = INPORT_QUANT-1-MODULES_PER_ROUTER,    //number of links to other on-chip routers
    //parameter [LUT_SIZE*INPORT_QUANT-1:0] LUT_RESET_VALUE     = 0,
    parameter   [LUT_SIZE*LINKS_PER_ROUTER-1:0] LUT_RESET_VALUE = 0,
    // router's own address (Z not relevant here -> used for modules only)
    parameter   [MOD_X_COORD_SIZE-1:0]      DIRECTION_ADD_X     = 0,
    parameter   [MOD_Y_COORD_SIZE-1:0]      DIRECTION_ADD_Y     = 0
    )
(
    input   wire                                                clk_i,
    input   wire                                                reset_q_i,
    input   wire    [NOC_CHIPID_SIZE-1:0]                       home_chipid_i,

    // input port connections
    input   wire    [INPORT_QUANT*NOC_HEADER_SIZE-1:0]          header_i,
    input   wire    [INPORT_QUANT*NOC_PAYLOAD_SIZE-1:0]         payload_i,
    output  wire    [INPORT_QUANT-1:0]                          rdreq_o,
    input   wire    [INPORT_QUANT-1:0]                          flit_avail_q_i,

    // output port connections
    output  wire    [OUTPORT_QUANT*NOC_HEADER_SIZE-1:0]         header_o,
    output  wire    [OUTPORT_QUANT*NOC_PAYLOAD_SIZE-1:0]        payload_o,
    output  wire    [OUTPORT_QUANT-1:0]                         wrreq_o,
    input   wire    [OUTPORT_QUANT-1:0]                         stall_i,

    // router_module port connections
    input   wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0]             rin_routing_lut_i,
    output  wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0]             r_routing_lut_o,
    input   wire    [clogb2(INPORT_QUANT)-1:0]                  sel_lut_i,
    input   wire    [INPORT_QUANT-1:0]                          lut_update_en_i,

    output  wire    [CNT_SIZE-1:0]                              cnt_data_o,
    input   wire    [clogb2(OUTPORT_QUANT)-1:0]                 cnt_port_sel_i,
    input   wire                                                cnt_rst_i,

    input   wire    [OUTPORT_QUANT-1:0]                         rst_burst_i,
    output  wire    [OUTPORT_QUANT-1:0]                         burstActive_o
);

    function integer clogb2 (input [31:0] value_in);
        reg [31:0] value;
        begin
            value = value_in - 1;
            for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
                value = value >> 1;
        end
    endfunction

    // wire declarations
    wire    [NOC_HEADER_SIZE-1:0]               BEheader_in [0:INPORT_QUANT-1];
    wire    [NOC_PAYLOAD_SIZE-1:0]              BEpayload_in [0:INPORT_QUANT-1];
    wire    [INPORT_QUANT-1:0]                  BEflitAvail_in;
    reg     [INPORT_QUANT-1:0]                  rin_BEflitReq_in;
    reg     [NOC_HEADER_SIZE-1:0]               rin_flitHeader_out [0:OUTPORT_QUANT-1];
    reg     [NOC_PAYLOAD_SIZE-1:0]              rin_flitPayload_out [0:OUTPORT_QUANT-1];
    reg     [OUTPORT_QUANT-1:0]                 rin_flitWrreq_out;
    wire    [OUTPORT_QUANT-1:0]                 flitStall_out;
    wire    [OUTPORT_QUANT-1:0]                 outPortCandidateList [0:INPORT_QUANT-1];
    wire    [INPORT_QUANT-1:0]                  inPortCandidateList [0:OUTPORT_QUANT-1];
    wire    [INPORT_QUANT-1:0]                  BEaccepted [0:OUTPORT_QUANT-1];
    wire    [INPORT_QUANT-1:0]                  inPortDropFlit;
    reg     [INPORT_QUANT-1:0]                  rin_roundRobinSrcPort [0:OUTPORT_QUANT-1];
    reg     [INPORT_QUANT-1:0]                  r_roundRobinSrcPort [0:OUTPORT_QUANT-1];
    reg     [INPORT_QUANT-1:0]                  rin_BEtaken;
    reg     [OUTPORT_QUANT-1:0]                 tmp_burstActive, r_burstActive;
    reg     [INPORT_QUANT-1:0]                  tmp_burstActive_inport, r_burstActive_inport;
    wire    [OUTPORT_QUANT-1:0]                 rin_burstActive;
    wire    [INPORT_QUANT-1:0]                  rin_burstActive_inport;
    wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0]     r_routing_lut [0:INPORT_QUANT-1];
    wire    [OUTPORT_QUANT-1:0]                 cnt_en;
    wire    [OUTPORT_QUANT-1:0]                 tmp_rdreq;

    wire    [OUTPORT_QUANT*NOC_PAYLOAD_SIZE-1:0]    tmp0_payload;


    genvar gen_i, gen_j;
    generate
        for (gen_i=0; gen_i<INPORT_QUANT; gen_i=gen_i+1) begin: inPortInstantiate
            tPortIn inPort_inst (
                .header_i                   (header_i [(gen_i+1)*NOC_HEADER_SIZE-1 : gen_i*NOC_HEADER_SIZE]),
                .payload_i                  (payload_i [(gen_i+1)*NOC_PAYLOAD_SIZE-1 : gen_i*NOC_PAYLOAD_SIZE]),
                .rdreq_o                    (tmp_rdreq [gen_i]),
                .flit_avail_q_i             (flit_avail_q_i [gen_i]),

                .BEheader_o                 (BEheader_in [gen_i]),
                .BEpayload_o                (BEpayload_in [gen_i]),
                .BEflitAvail_o              (BEflitAvail_in [gen_i]),
                .BEflitReq_i                (rin_BEflitReq_in [gen_i])
            );

            tTrgPortCandidateCalc_OnOff_lut #(
                .INPORT_ID                  (gen_i),
                .OUTPORT_QUANT              (OUTPORT_QUANT),
                .INSTANCE_NAME              (INSTANCE_NAME),
                .MODULES_PER_ROUTER         (MODULES_PER_ROUTER),
                .LUT_RESET_VALUE            (LUT_RESET_VALUE),
                .DIRECTION_ADD_X            (DIRECTION_ADD_X),
                .DIRECTION_ADD_Y            (DIRECTION_ADD_Y)
            )
            trgPortCandidate (
                .clk_i                      (clk_i),
                .rstq_i                     (reset_q_i),
                .home_chipid_i              (home_chipid_i),
                .header_i                   (BEheader_in [gen_i]),
                .flitReady_i                (BEflitAvail_in [gen_i]),
                .burst_active_i             (r_burstActive_inport[gen_i]),
                .rin_routing_lut_i          (rin_routing_lut_i),
                .r_routing_lut_o            (r_routing_lut [gen_i]),
                .lut_update_en_i            (lut_update_en_i [gen_i]),
                .candidateList_o            (outPortCandidateList [gen_i])
            );

            assign inPortDropFlit[gen_i] = (BEflitAvail_in [gen_i] && (outPortCandidateList [gen_i] == {OUTPORT_QUANT{1'b0}})) ? 1'b1 : 1'b0;
        end
    endgenerate
    assign rdreq_o      = tmp_rdreq;    // intermediate to use as enable signal for the traffic counters

    generate
        for (gen_i=0; gen_i<OUTPORT_QUANT; gen_i=gen_i+1) begin: outPortInstantiate
            tPortOut outPort_inst (
                .header_o               (header_o [(gen_i+1)*NOC_HEADER_SIZE-1 : gen_i*NOC_HEADER_SIZE]),
                .payload_o              (tmp0_payload [(gen_i+1)*NOC_PAYLOAD_SIZE-1 : gen_i*NOC_PAYLOAD_SIZE]),
                .wrreq_o                (wrreq_o [gen_i]),
                .BEstall_i              (stall_i [gen_i]),

                .flitHeader_i           (rin_flitHeader_out [gen_i]),
                .flitPayload_i          (rin_flitPayload_out [gen_i]),
                .flitWrreq_i            (rin_flitWrreq_out [gen_i]),
                .flitStall_o            (flitStall_out [gen_i])
            );

            inPortSelectBE #(
                .INPORT_QUANT(INPORT_QUANT)
            )
            inPortSel_inst (
                .candidateList_i        (inPortCandidateList [gen_i]),
                .inPortSel_o            (BEaccepted [gen_i]),

                .roundRobinSrcPort_i    (r_roundRobinSrcPort [gen_i]),
                .burstActive_i          (r_burstActive [gen_i])
            );

            for (gen_j=0; gen_j<INPORT_QUANT; gen_j=gen_j+1) begin: candListTransform
                assign inPortCandidateList [gen_i][gen_j]   = outPortCandidateList [gen_j][gen_i];
            end
        end
    endgenerate


    assign payload_o    = tmp0_payload;

    flit_counter_wrap #(
        .OUTPORT_QUANT      (OUTPORT_QUANT)
    )
    i_flit_counter_wrap (
        .clk_i              (clk_i),
        .reset_q_i          (reset_q_i),
        .cnt_en_i           (cnt_en),
        .cnt_data_o         (cnt_data_o),
        .cnt_port_sel_i     (cnt_port_sel_i),
        .cnt_rst_i          (cnt_rst_i)
    );
    assign cnt_en   = tmp_rdreq [OUTPORT_QUANT-1:0];    // lower part of rdreq are related to the inter-router links which are counted

    //*******************************************************//
    //************** Data Path ******************************//
    always @(posedge clk_i, negedge reset_q_i) begin: dataPath_seq
        integer i;
        if (!reset_q_i) begin
            for (i=0; i<OUTPORT_QUANT; i=i+1) begin
                r_roundRobinSrcPort [i] <= {INPORT_QUANT{1'b0}};
            end
            r_burstActive               <= {OUTPORT_QUANT{1'b0}};
            r_burstActive_inport        <= {INPORT_QUANT{1'b0}};
        end
        else begin
            for (i=0; i<OUTPORT_QUANT; i=i+1) begin
                r_roundRobinSrcPort [i] <= rin_roundRobinSrcPort [i];
            end
            r_burstActive               <= rin_burstActive;
            r_burstActive_inport        <= rin_burstActive_inport;
        end
    end
    assign burstActive_o    = r_burstActive;

    assign rin_burstActive  = tmp_burstActive & ~rst_burst_i;   // NEW - reset burst flag
    assign rin_burstActive_inport   = tmp_burstActive_inport;   // NEW - reset burst flag

    always @* begin: dataPath_comb
        integer i, outPort, inPort;
        for (i=0; i<OUTPORT_QUANT; i=i+1) begin
            rin_flitHeader_out [i]      = {NOC_HEADER_SIZE{1'b0}};
            rin_flitPayload_out [i]     = {NOC_PAYLOAD_SIZE{1'b0}};
            rin_roundRobinSrcPort [i]   = r_roundRobinSrcPort [i];
        end
        rin_flitWrreq_out      = {OUTPORT_QUANT{1'b0}};
        tmp_burstActive        = r_burstActive;
        tmp_burstActive_inport = r_burstActive_inport;
        rin_BEtaken            = {INPORT_QUANT{1'b0}};
        for (outPort=0; outPort<OUTPORT_QUANT; outPort=outPort+1) begin
            if (!flitStall_out [outPort]) begin
                for (inPort=0; inPort<INPORT_QUANT; inPort=inPort+1) begin
                    if (BEaccepted [outPort][inPort] && BEflitAvail_in[inPort]) begin
                        rin_flitHeader_out [outPort]  = BEheader_in [inPort];
                        rin_flitPayload_out [outPort] = BEpayload_in [inPort];
                        rin_flitWrreq_out [outPort]   = 1'b1;
                        rin_BEtaken [inPort]          = 1'b1;

                        if (BEheader_in [inPort][NOC_HEADER_SIZE-1]) begin
                            tmp_burstActive [outPort]       = 1'b1;
                            tmp_burstActive_inport [inPort] = 1'b1;
                            rin_roundRobinSrcPort [outPort] = inPort;
                        end else begin
                            tmp_burstActive [outPort]       = 1'b0;
                            tmp_burstActive_inport [inPort] = 1'b0;
                            rin_roundRobinSrcPort [outPort] = (inPort+1)%INPORT_QUANT;
                        end
                    end

                    //if flit available but no output, drop it
                    else if (inPortDropFlit[inPort]) begin
                        rin_BEtaken [inPort] = 1'b1;

                        if (BEheader_in [inPort][NOC_HEADER_SIZE-1]) begin
                            tmp_burstActive_inport [inPort] = 1'b1;
                        end else begin
                            tmp_burstActive_inport [inPort] = 1'b0;
                        end
                    end
                end // for (inPort=0; inPort<INPORT_QUANT; inPort=inPort+1)
            end // if ( !flitStall_out[outPort] )
        end // for (outPort=0; outPort<OUTPORT_QUANT; outPort=outPort+1)
    end // always@ *
    //************** Data Path ******************************//
    //*******************************************************//


    //*******************************************************//
    //********** Request next BE flit ***********************//
    always @* begin: BEreq_comb
        rin_BEflitReq_in    = rin_BEtaken;
    end
    //********** Request next BE flit ***********************//
    //*******************************************************//

    //*******************************************************//
    //************** select LUT value ***********************//
    assign r_routing_lut_o = r_routing_lut [sel_lut_i];

    //************** select LUT value ***********************//
    //*******************************************************//

endmodule // router_shm_lut

`endif //  `ifndef tROUTER_DXY_BE_ONLY_STAR_MESH_HEX_LUT
