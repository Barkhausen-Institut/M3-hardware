`ifndef tTRG_PORT_CANDIDATE_CALCULATOR_STAR_MESH_LUT
`define tTRG_PORT_CANDIDATE_CALCULATOR_STAR_MESH_LUT

// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module tTrgPortCandidateCalc_OnOff_lut #(
    `include "noc_parameter.vh"
    ,`include "mod_ids.vh"
    ,parameter                                              INPORT_ID                   = 1,
    parameter                                               OUTPORT_QUANT               = 1,    //number of links + modules + router!!!
    parameter                                               INSTANCE_NAME               = "R1",
    parameter                                               MODULES_PER_ROUTER          = 1,
    parameter                                               LINKS_PER_ROUTER            = OUTPORT_QUANT-1-MODULES_PER_ROUTER,   //number of links to other on-chip routers
    parameter   [LUT_SIZE*LINKS_PER_ROUTER-1:0]             LUT_RESET_VALUE             = 0,
    parameter   [MOD_X_COORD_SIZE-1:0]                      DIRECTION_ADD_X             = 0,
    parameter   [MOD_Y_COORD_SIZE-1:0]                      DIRECTION_ADD_Y             = 0
)
(
    input   wire                                            clk_i,
    input   wire                                            rstq_i,
    input   wire    [NOC_CHIPID_SIZE-1:0]                   home_chipid_i,

    input   wire    [NOC_HEADER_SIZE-1:0]                   header_i,
    input   wire                                            flitReady_i,
    input   wire                                            burst_active_i,
    input   wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0]         rin_routing_lut_i,
    output  wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0]         r_routing_lut_o,
    input   wire                                            lut_update_en_i,
    output  wire    [OUTPORT_QUANT-1:0]                     candidateList_o
);


    reg     [OUTPORT_QUANT-1:0]                             rin_candidateList;
    reg     [OUTPORT_QUANT-1:0]                             r_candidateList_stored, r_candidateList_out;
    reg     [OUTPORT_QUANT-1:0]                             rin_candidateList_stored;

    reg     [LUT_SIZE*LINKS_PER_ROUTER-1:0]                 r_routing_lut;
    reg     [LUT_SIZE-1:0]                                  routing_lut_array [0:LINKS_PER_ROUTER-1];

    wire    [MOD_X_COORD_SIZE-1:0]                          trg_mod_x;
    wire    [MOD_Y_COORD_SIZE-1:0]                          trg_mod_y;
    wire    [MOD_Z_COORD_SIZE-1:0]                          trg_mod_z;
    wire    [MOD_X_COORD_SIZE-1:0]                          trg_mod_x_OffChip;
    wire    [MOD_Y_COORD_SIZE-1:0]                          trg_mod_y_OffChip;
    wire    [MOD_Z_COORD_SIZE-1:0]                          trg_mod_z_OffChip;

    wire    [NOC_CHIPID_SIZE-1:0]                           trg_chipID;
    

    reg     go_home;
    reg     go_left;
    reg     go_right;
    reg     go_up;
    reg     go_down;
    reg     go_OnTemp_offchip;
    reg     go_OnTemp_left;
    reg     go_OnTemp_right;
    reg     go_OnTemp_up;
    reg     go_OnTemp_down;
    reg     go_OffTemp_left;
    reg     go_OffTemp_right;
    reg     go_OffTemp_up;
    reg     go_OffTemp_down;

    reg     [2:0] routing_lut_bit_sel;


    /*
     * currently 2 bits for z coordinate of mod-id
     *  2'd0: first PM
     *  2'd1: second PM
     *  2'd2: third PM
     *  2'd3: router module
     */
    assign trg_mod_z  = header_i[MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1:CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE];

    assign r_routing_lut_o  = r_routing_lut;
    assign candidateList_o  = r_candidateList_out;

    always @* begin
        if( burst_active_i) begin
            r_candidateList_out      = r_candidateList_stored;
        end else begin
            r_candidateList_out      = rin_candidateList & {OUTPORT_QUANT{flitReady_i}};
        end
    end

    always @(posedge clk_i, negedge rstq_i) begin
        if(rstq_i == 1'b0) begin
            r_candidateList_stored  <= {OUTPORT_QUANT{1'b0}};
        end else begin
            r_candidateList_stored  <= rin_candidateList_stored;
        end
    end

    always @* begin
        rin_candidateList_stored   = r_candidateList_stored;
        if(burst_active_i==0) begin
            rin_candidateList_stored      = rin_candidateList;
        end else begin
            rin_candidateList_stored      = r_candidateList_stored;
        end
    end

    always @(posedge clk_i, negedge rstq_i) begin: routing_lut_register
        if (rstq_i == 1'b0) begin
            r_routing_lut   <=  LUT_RESET_VALUE;
        end else begin
            if (lut_update_en_i == 1'b1) begin
                r_routing_lut   <=  rin_routing_lut_i;
            end
        end
    end


    assign trg_chipID   = header_i[CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1:0];

    assign trg_mod_x    = header_i[MOD_X_COORD_SIZE+MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1 : MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE];
    assign trg_mod_y    = header_i[MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1 : MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE];

    //going off-chip means to send it to Ethernet
    assign trg_mod_x_OffChip = MODID_ETH[MOD_X_COORD_SIZE+MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE-1 : MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE];
    assign trg_mod_y_OffChip = MODID_ETH[MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE-1 : MOD_Z_COORD_SIZE];
    assign trg_mod_z_OffChip = MODID_ETH[MOD_Z_COORD_SIZE-1 : 0];


    always @* begin: tempOff_xy_set_direction
        if (trg_chipID == home_chipid_i) begin //target is on-chip
            go_OffTemp_left     = 1'b0;
            go_OffTemp_right    = 1'b0;
            go_OffTemp_up       = 1'b0;
            go_OffTemp_down     = 1'b0;
        end else begin // This is for Off-chip Routing inside OnChip
            if (trg_mod_x_OffChip < DIRECTION_ADD_X) begin
                go_OffTemp_left     = 1'b1;
                go_OffTemp_right    = 1'b0;
            end else if (trg_mod_x_OffChip > DIRECTION_ADD_X) begin
                go_OffTemp_left     = 1'b0;
                go_OffTemp_right    = 1'b1;
            end else begin
                go_OffTemp_left     = 1'b0;
                go_OffTemp_right    = 1'b0;
            end
            if (trg_mod_y_OffChip < DIRECTION_ADD_Y) begin
                go_OffTemp_up       = 1'b0;
                go_OffTemp_down     = 1'b1;
            end else if (trg_mod_y_OffChip > DIRECTION_ADD_Y) begin
                go_OffTemp_up       = 1'b1;
                go_OffTemp_down     = 1'b0;
            end else begin
                go_OffTemp_up       = 1'b0;
                go_OffTemp_down     = 1'b0;
            end
        end
    end


    always @* begin: OnChip_set_direction
        if (trg_chipID != home_chipid_i) begin //target is off-chip
            go_OnTemp_offchip   = 1'b1;
            go_OnTemp_left      = 1'b0;
            go_OnTemp_right     = 1'b0;
            go_OnTemp_up        = 1'b0;
            go_OnTemp_down      = 1'b0;
        end else begin // This is for On-chip Routing
            go_OnTemp_offchip = 1'b0;
            if (trg_mod_x < DIRECTION_ADD_X) begin
                go_OnTemp_left      = 1'b1;
                go_OnTemp_right = 1'b0;
            end else if (trg_mod_x > DIRECTION_ADD_X) begin
                go_OnTemp_left      = 1'b0;
                go_OnTemp_right = 1'b1;
            end else begin
                go_OnTemp_left      = 1'b0;
                go_OnTemp_right = 1'b0;
            end
            if (trg_mod_y < DIRECTION_ADD_Y) begin
                go_OnTemp_up        = 1'b0;
                go_OnTemp_down      = 1'b1;
            end else if (trg_mod_y > DIRECTION_ADD_Y) begin
                go_OnTemp_up        = 1'b1;
                go_OnTemp_down      = 1'b0;
            end else begin
                go_OnTemp_up        = 1'b0;
                go_OnTemp_down      = 1'b0;
            end
        end
    end

    always @* begin: Final_set_direction
        if (trg_chipID == home_chipid_i) begin //Target is On-chip
            go_left    = go_OnTemp_left;
            go_right   = go_OnTemp_right;
            go_up      = go_OnTemp_up;
            go_down    = go_OnTemp_down;
            go_home    = ~ (go_OnTemp_left | go_OnTemp_right | go_OnTemp_up | go_OnTemp_down);
        end else begin
            go_left    = go_OffTemp_left;
            go_right   = go_OffTemp_right;
            go_up      = go_OffTemp_up;
            go_down    = go_OffTemp_down;
            go_home    = ~ (go_OffTemp_left | go_OffTemp_right | go_OffTemp_up | go_OffTemp_down);
        end
    end


    //NW,W,SW,S,SE,E,NE,N
    always @* begin: set_lut_addr
        case ({go_left, go_right, go_up, go_down})
            4'b0010:    routing_lut_bit_sel = 3'd7; // N
            4'b0110:    routing_lut_bit_sel = 3'd6; // NE
            4'b0100:    routing_lut_bit_sel = 3'd5; // E
            4'b0101:    routing_lut_bit_sel = 3'd4; // SE
            4'b0001:    routing_lut_bit_sel = 3'd3; // S
            4'b1001:    routing_lut_bit_sel = 3'd2; // SW
            4'b1000:    routing_lut_bit_sel = 3'd1; // W
            4'b1010:    routing_lut_bit_sel = 3'd0; // NW
            default:    routing_lut_bit_sel = 3'd0; // use PM or router module
        endcase
    end

    genvar i;
    generate
        for (i=0; i<OUTPORT_QUANT; i=i+1) begin: set_possible_outPort_remote
            always @* begin
                rin_candidateList[i] = 1'b0;

                //set list for modules
                if (i < MODULES_PER_ROUTER) begin
                    if (go_home == 1'b1) begin //target is this router
                        if (go_OnTemp_offchip == 1'b1) begin //but another chip
                            if (i == trg_mod_z_OffChip) begin //use off-chip link at this router (FPGA IF)
                                rin_candidateList[i] = 1'b1;
                            end
                        end else if (i == trg_mod_z) begin  //select a PM
                            rin_candidateList[i] = 1'b1;
                        end
                    end
                end

                //set list for links to other routers
                else if (i < (OUTPORT_QUANT-1)) begin
                    if (go_home == 1'b0) begin
                        rin_candidateList[i] = routing_lut_array[i-MODULES_PER_ROUTER][routing_lut_bit_sel];
                    end
                end

                //set list for router module
                else begin
                    if ((go_home == 1'b1) && (trg_mod_z == {MOD_Z_COORD_SIZE{1'b1}})) begin //target is this router
                        rin_candidateList[i] = 1'b1;    //select router module with mod-id (router is at last possible mod-id)
                    end
                end
            end // always
        end // block: set_possible_outPort
    endgenerate

    // create array from routing_lut vector for easier access above
    genvar j;
    generate
        for (j=0; j<LINKS_PER_ROUTER; j=j+1) begin: lut_vector2array
            always @* begin
                routing_lut_array [j]   = r_routing_lut [LUT_SIZE*(j+1)-1:LUT_SIZE*j];
            end
        end
    endgenerate

endmodule

`endif
