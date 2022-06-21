`ifndef _tROUTER_MODULE
`define _tROUTER_MODULE

// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module router_module #(
    `include "noc_parameter.vh"
    ,parameter                          INSTANCE_NAME       = "R1",
    parameter                           INPORT_QUANT        = 1,        //number of links + modules + router!!!
    parameter                           OUTPORT_QUANT       = 1,        //number of links + modules + router!!!
    parameter                           MODULES_PER_ROUTER  = 1,
    parameter                           LINKS_PER_ROUTER    = INPORT_QUANT-1-MODULES_PER_ROUTER,    //number of links to other on-chip routers
    //// router's own address (Z not relevant here -> used for modules only)
    parameter  [MOD_X_COORD_SIZE-1:0]   DIRECTION_ADD_X     = 0,
    parameter  [MOD_Y_COORD_SIZE-1:0]   DIRECTION_ADD_Y     = 0
)
(
    input   wire                                clk_i,
    input   wire                                reset_q_i,

    // interface to nocif
    output  wire                                rm_wrreq_o,
    output  wire    [CHIP_X_COORD_SIZE-1:0]     rm_trg_chip_x_coord_o,
    output  wire    [CHIP_Y_COORD_SIZE-1:0]     rm_trg_chip_y_coord_o,
    output  wire    [CHIP_Z_COORD_SIZE-1:0]     rm_trg_chip_z_coord_o,
    output  wire    [MOD_X_COORD_SIZE-1:0]      rm_trg_mod_x_coord_o,
    output  wire    [MOD_Y_COORD_SIZE-1:0]      rm_trg_mod_y_coord_o,
    output  wire    [MOD_Z_COORD_SIZE-1:0]      rm_trg_mod_z_coord_o,
    output  wire    [CHIP_X_COORD_SIZE-1:0]     rm_src_chip_x_coord_o,
    output  wire    [CHIP_Y_COORD_SIZE-1:0]     rm_src_chip_y_coord_o,
    output  wire    [CHIP_Z_COORD_SIZE-1:0]     rm_src_chip_z_coord_o,
    output  wire    [MOD_X_COORD_SIZE-1:0]      rm_src_mod_x_coord_o,
    output  wire    [MOD_Y_COORD_SIZE-1:0]      rm_src_mod_y_coord_o,
    output  wire    [MOD_Z_COORD_SIZE-1:0]      rm_src_mod_z_coord_o,
    output  wire    [NOC_BSEL_SIZE-1:0]         rm_bsel_o,
    output  wire                                rm_burst_o,
    output  wire                                rm_arq_o,
    output  wire    [NOC_DATA_SIZE-1:0]         rm_data0_o,
    output  wire    [NOC_DATA_SIZE-1:0]         rm_data1_o,
    output  wire    [NOC_ADDR_SIZE-1:0]         rm_addr_o,
    output  wire    [NOC_MODE_SIZE-1:0]         rm_mode_o,
    input   wire                                rm_stall_i,

    // interface from nocif
    input   wire                                rm_wrreq_i,
    input   wire    [CHIP_X_COORD_SIZE-1:0]     rm_trg_chip_x_coord_i,
    input   wire    [CHIP_Y_COORD_SIZE-1:0]     rm_trg_chip_y_coord_i,
    input   wire    [CHIP_Z_COORD_SIZE-1:0]     rm_trg_chip_z_coord_i,
    input   wire    [MOD_X_COORD_SIZE-1:0]      rm_trg_mod_x_coord_i,
    input   wire    [MOD_Y_COORD_SIZE-1:0]      rm_trg_mod_y_coord_i,
    input   wire    [MOD_Z_COORD_SIZE-1:0]      rm_trg_mod_z_coord_i,
    input   wire    [CHIP_X_COORD_SIZE-1:0]     rm_src_chip_x_coord_i,
    input   wire    [CHIP_Y_COORD_SIZE-1:0]     rm_src_chip_y_coord_i,
    input   wire    [CHIP_Z_COORD_SIZE-1:0]     rm_src_chip_z_coord_i,
    input   wire    [MOD_X_COORD_SIZE-1:0]      rm_src_mod_x_coord_i,
    input   wire    [MOD_Y_COORD_SIZE-1:0]      rm_src_mod_y_coord_i,
    input   wire    [MOD_Z_COORD_SIZE-1:0]      rm_src_mod_z_coord_i,

    input   wire    [NOC_BSEL_SIZE-1:0]         rm_bsel_i,
    input   wire    [NOC_DATA_SIZE-1:0]         rm_data0_i,
    input   wire    [NOC_DATA_SIZE-1:0]         rm_data1_i,
    input   wire    [NOC_ADDR_SIZE-1:0]         rm_addr_i,
    input   wire    [NOC_MODE_SIZE-1:0]         rm_mode_i,
    output  wire                                rm_stall_o,

    // access routing lut
    output  wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0] rin_routing_lut_o,
    input   wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0] r_routing_lut_i,
    output  wire    [clogb2(INPORT_QUANT)-1:0]      sel_lut_o,
    output  wire    [INPORT_QUANT-1:0]              lut_update_en_o,

    // read/reset traffic counter
    input   wire    [CNT_SIZE-1:0]              cnt_data_i,
    output  wire    [clogb2(OUTPORT_QUANT)-1:0] cnt_port_sel_o,
    output  wire                                cnt_rst_o,

    // configure traffic counter
    output  wire    [OUTPORT_QUANT-1:0]     rst_burst_o,
    input   wire    [OUTPORT_QUANT-1:0]     burstActive_i
);

    function integer clogb2 (input [31:0] value_in);
        reg [31:0] value;
        begin
            value = value_in - 1;
            for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
                value = value >> 1;
        end
    endfunction

    // output register
    reg     [CHIP_X_COORD_SIZE-1:0]     r_rm_trg_chip_x_coord;
    reg     [CHIP_Y_COORD_SIZE-1:0]     r_rm_trg_chip_y_coord;
    reg     [CHIP_Z_COORD_SIZE-1:0]     r_rm_trg_chip_z_coord;
    reg     [MOD_X_COORD_SIZE-1:0]      r_rm_trg_mod_x_coord;
    reg     [MOD_Y_COORD_SIZE-1:0]      r_rm_trg_mod_y_coord;
    reg     [MOD_Z_COORD_SIZE-1:0]      r_rm_trg_mod_z_coord;
    reg     [CHIP_X_COORD_SIZE-1:0]     r_rm_src_chip_x_coord;
    reg     [CHIP_Y_COORD_SIZE-1:0]     r_rm_src_chip_y_coord;
    reg     [CHIP_Z_COORD_SIZE-1:0]     r_rm_src_chip_z_coord;

    reg     [MOD_X_COORD_SIZE-1:0]      r_rm_src_mod_x_coord;
    reg     [MOD_Y_COORD_SIZE-1:0]      r_rm_src_mod_y_coord;
    reg     [MOD_Z_COORD_SIZE-1:0]      r_rm_src_mod_z_coord;

    reg                             r_rm_burst;
    reg     [NOC_BSEL_SIZE-1:0]     r_rm_bsel;
    reg     [NOC_DATA_SIZE-1:0]     r_rm_data0;
    reg     [NOC_DATA_SIZE-1:0]     r_rm_data1;
    reg     [NOC_ADDR_SIZE-1:0]     r_rm_addr;
    reg     [NOC_MODE_SIZE-1:0]     r_rm_mode;

    reg     [NOC_CHIPID_SIZE-1:0]   rin_rm_trg_chipid;
    reg     [CHIP_X_COORD_SIZE-1:0] rin_rm_trg_chip_x_coord;
    reg     [CHIP_Y_COORD_SIZE-1:0] rin_rm_trg_chip_y_coord;
    reg     [CHIP_Z_COORD_SIZE-1:0] rin_rm_trg_chip_z_coord;

    reg     [NOC_MODID_SIZE-1:0]    rin_rm_trg_modid;
    reg     [MOD_X_COORD_SIZE-1:0]  rin_rm_trg_mod_x_coord;
    reg     [MOD_Y_COORD_SIZE-1:0]  rin_rm_trg_mod_y_coord;
    reg     [MOD_Z_COORD_SIZE-1:0]  rin_rm_trg_mod_z_coord;

    reg     [NOC_CHIPID_SIZE-1:0]   rin_rm_src_chipid;
    reg     [CHIP_X_COORD_SIZE-1:0] rin_rm_src_chip_x_coord;
    reg     [CHIP_Y_COORD_SIZE-1:0] rin_rm_src_chip_y_coord;
    reg     [CHIP_Z_COORD_SIZE-1:0] rin_rm_src_chip_z_coord;

    reg     [NOC_MODID_SIZE-1:0]    rin_rm_src_modid;
    reg     [MOD_X_COORD_SIZE-1:0]  rin_rm_src_mod_x_coord;
    reg     [MOD_Y_COORD_SIZE-1:0]  rin_rm_src_mod_y_coord;
    reg     [MOD_Z_COORD_SIZE-1:0]  rin_rm_src_mod_z_coord;

    reg                             rin_rm_burst;
    reg     [NOC_BSEL_SIZE-1:0]     rin_rm_bsel;
    reg     [NOC_DATA_SIZE-1:0]     rin_rm_data0;
    reg     [NOC_DATA_SIZE-1:0]     rin_rm_data1;
    reg     [NOC_ADDR_SIZE-1:0]     rin_rm_addr;
    reg     [NOC_MODE_SIZE-1:0]     rin_rm_mode;


    wire    [NOC_DATA_SIZE-1:0]     data_out_lut_read;
    wire    [NOC_DATA_SIZE-1:0]     data_out_cntr_read;
    wire    [NOC_DATA_SIZE-1:0]     data_out_burst_read;

    // mask register
    reg     [NOC_MODID_SIZE-1:0]    r_mask_modid;
    reg     [NOC_CHIPID_SIZE-1:0]   r_mask_chipid;
    reg     [NOC_MODID_SIZE-1:0]    rin_mask_modid;
    reg     [NOC_CHIPID_SIZE-1:0]   rin_mask_chipid;
    reg                             mask_we;
    reg                             mask_we_req;
    reg     [NOC_MODID_SIZE-1:0]    r_mask_1st_user_modid;
    reg     [NOC_CHIPID_SIZE-1:0]   r_mask_1st_user_chipid;
    reg                             r_mask_1st_user_done;
    reg                             mask_1st_we;
    reg                             read_mask;

    // flow control signals
    wire                            flit_done;
    wire                            rm_stall;
    reg                             read_req;
    reg                             read_cntr;
    reg                             read_lut;
    reg                             read_burst;
    reg                             r_outreg_used;
    reg                             rin_outreg_used;

    // router signals
    reg     [INPORT_QUANT-1:0]          lut_update_en;  //input port number + router module port
    reg     [LUT_SIZE*LINKS_PER_ROUTER-1:0] rin_routing_lut;
    reg     [clogb2(INPORT_QUANT)-1:0]  sel_lut;

    reg     [clogb2(INPORT_QUANT)-1:0]  cnt_port_sel;
    reg                                 cnt_rst;

    // count mode signals
    reg     [INPORT_QUANT-1:0]          rin_cnt_mode;
    reg                                 rin_cnt_source;

    // burst flag
    reg     [OUTPORT_QUANT-1:0]         rst_burst;
    reg                                 rst_burst_en;

    // check input values
    always @* begin: data_path
        // default values
        read_req            = 1'b0;
        read_cntr           = 1'b0;
        read_lut            = 1'b0;
        read_burst          = 1'b0;
        sel_lut             = {clogb2(INPORT_QUANT){1'b0}};
        lut_update_en       = {INPORT_QUANT{1'b0}};
        rin_routing_lut     = {LUT_SIZE*LINKS_PER_ROUTER{1'b0}};
        cnt_port_sel        = {clogb2(INPORT_QUANT){1'b0}};
        cnt_rst             = 1'b0;
        rst_burst_en        = 1'b0;

        if (rm_wrreq_i == 1'b1 && rm_stall == 1'b0) begin   // only process data if its valid and theres no stall
            case (rm_mode_i)
                MODE_WRITE_POSTED: begin
                    // WRITE TO LUTS
                    rin_routing_lut = rm_data0_i [LUT_SIZE*LINKS_PER_ROUTER-1:0]; //lut(9bits) for one port * port quantity (router module is excluded)
                    case (rm_addr_i [NOC_ADDR_SIZE-1:NOC_ADDR_SIZE-4])      //upper 4bits of Payload address 30bits
                        4'b0000: begin  // WRITE TO SINGLE LUTS
                            case (rm_addr_i [NOC_ADDR_SIZE-5:NOC_ADDR_SIZE-8])  //next 4bits(upper 4bits) of Payload address 30bits
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                // WRITE TO ROUTER_MODULE LUT /////////////////////////////////////////////////////////////////
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                4'b0000: begin  // write to router_module LUT itself
                                    lut_update_en [INPORT_QUANT-1]  = 1'b1;
                                end
                                // WRITE TO MODULE LUTS
                                4'b0001: begin  // write to first Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 0) begin
                                        lut_update_en [0]   = 1'b1;
                                    end
                                end
                                4'b0010: begin  // write to second Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 1) begin
                                        lut_update_en [1]   = 1'b1;
                                    end
                                end
                                4'b0011: begin  // write to third Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 2) begin
                                        lut_update_en [2]   = 1'b1;
                                    end
                                end
                                4'b0100: begin  // write to forth Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 3) begin
                                        lut_update_en [3]   = 1'b1;
                                    end
                                end
                                4'b0101: begin  // write to 5th Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 4) begin
                                        lut_update_en [4]   = 1'b1;
                                    end
                                end
                                4'b0110: begin  // write to 6th Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 5) begin
                                        lut_update_en [5]   = 1'b1;
                                    end
                                end
                                4'b0111: begin  // write to 7th Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 6) begin
                                        lut_update_en [6]   = 1'b1;
                                    end
                                end
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                // WRITE TO NEIGHBOUR LUTS (Output Port LUT Between router) ///////////////////////////////////
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                4'b1000: begin  // write to first InOut port LUT (Offchip)
                                    if (LINKS_PER_ROUTER > 0) begin
                                        lut_update_en [0+MODULES_PER_ROUTER]    = 1'b1;
                                    end
                                end
                                4'b1001: begin  // write to second InOut port LUT
                                    if (LINKS_PER_ROUTER > 1) begin
                                        lut_update_en [1+MODULES_PER_ROUTER]    = 1'b1;
                                    end
                                end
                                4'b1010: begin  // write to third InOut port LUT
                                    if (LINKS_PER_ROUTER > 2) begin
                                        lut_update_en [2+MODULES_PER_ROUTER]    = 1'b1;
                                    end
                                end
                                4'b1011: begin  // write to forth InOut port LUT
                                    if (LINKS_PER_ROUTER > 3) begin
                                        lut_update_en [3+MODULES_PER_ROUTER]    = 1'b1;
                                    end
                                end
                                4'b1100: begin  // write to 5th InOut port LUT
                                    if (LINKS_PER_ROUTER > 4) begin
                                        lut_update_en [4+MODULES_PER_ROUTER]    = 1'b1;
                                    end
                                end
                                4'b1101: begin  // write to 6th InOut port LUT
                                    if (LINKS_PER_ROUTER > 5) begin
                                        lut_update_en [5+MODULES_PER_ROUTER]    = 1'b1;
                                    end
                                end
                                4'b1110: begin  // write to 7th InOut port LUT
                                    if (LINKS_PER_ROUTER > 6) begin
                                        lut_update_en [6+MODULES_PER_ROUTER]    = 1'b1;
                                    end
                                end
                                4'b1111: begin  // write to 8th InOut port LUT
                                    if (LINKS_PER_ROUTER > 7) begin
                                        lut_update_en [7+MODULES_PER_ROUTER]    = 1'b1;
                                    end
                                end
                                default: begin
                                    lut_update_en   = {INPORT_QUANT{1'b0}};
                                end
                            endcase
                        end
                        4'b0001: begin  // WRITE TO ALL LUTS EXCEPT ONE
                            lut_update_en = {INPORT_QUANT{1'b1}};
                            case (rm_addr_i [NOC_ADDR_SIZE-5:NOC_ADDR_SIZE-8])
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                // WRITE TO ALL LUTS EXCEPT ROUTER_MODULE LUT//////////////////////////////////////////////////
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                4'b0000: begin  // write except router_module LUT
                                    lut_update_en [INPORT_QUANT-1]  = 1'b0;
                                end
                                // WRITE TO ALL LUTS EXCEPT ONE MODULE LUT
                                4'b0001: begin  // write to all LUTs except first Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 0) begin
                                        lut_update_en [0]   = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b0010: begin  // write to all LUTs except second Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 1) begin
                                        lut_update_en [1]   = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b0011: begin  // write to all LUTs except third Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 2) begin
                                        lut_update_en [2]   = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b0100: begin  // write to all LUTs except module forth Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 3) begin
                                        lut_update_en [3]   = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b0101: begin  // write to all LUTs except module 5th Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 4) begin
                                        lut_update_en [4]   = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b0110: begin  // write to all LUTs except module 6th Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 5) begin
                                        lut_update_en [5]   = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b0111: begin  // write to all LUTs except module 7th Module LUT connected with one router
                                    if (MODULES_PER_ROUTER > 6) begin
                                        lut_update_en [6]   = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                // WRITE TO ALL LUTS EXCEPT ONE NEIGHBOUR LUT /////////////////////////////////////////////////
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                4'b1000: begin  // write to all LUTs except first InOut port LUT (Offchip)
                                    if (LINKS_PER_ROUTER > 0) begin
                                        lut_update_en [0+MODULES_PER_ROUTER] = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b1001: begin  // write to all LUTs except second InOut port LUT
                                    if (LINKS_PER_ROUTER > 1) begin
                                        lut_update_en [1+MODULES_PER_ROUTER]    = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b1010: begin  // write to all LUTs except third InOut port LUT
                                    if (LINKS_PER_ROUTER > 2) begin
                                        lut_update_en [2+MODULES_PER_ROUTER]    = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b1011: begin  // write to all LUTs except forth InOut port LUT
                                    if (LINKS_PER_ROUTER > 3) begin
                                        lut_update_en [3+MODULES_PER_ROUTER]    = 1'b0;
                                    end
                                end
                                4'b1100: begin  // write to all LUTs except 5th InOut port LUT
                                    if (LINKS_PER_ROUTER > 4) begin
                                        lut_update_en [4+MODULES_PER_ROUTER]    = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b1101: begin  // write to all LUTs except 6th InOut port LUT
                                    if (LINKS_PER_ROUTER > 5) begin
                                        lut_update_en [5+MODULES_PER_ROUTER]    = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b1110: begin  // write to all LUTs except 7th InOut port LUT
                                    if (LINKS_PER_ROUTER > 6) begin
                                        lut_update_en [6+MODULES_PER_ROUTER]    = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                4'b1111: begin  // write to all LUTs except 8th InOut port LUT
                                    if (LINKS_PER_ROUTER > 7) begin
                                        lut_update_en [7+MODULES_PER_ROUTER]    = 1'b0;
                                    end else begin
                                        lut_update_en   = {INPORT_QUANT{1'b0}};
                                    end
                                end
                                default: begin
                                    lut_update_en   = {INPORT_QUANT{1'b0}};
                                end
                            endcase
                        end
                        4'b0010: begin
                            ///////////////////////////////////////////////////////////////////////////////////////////////
                            // WRITE TO ALL LUTS  OR  WRITE TO BURST_FLAG   /////////////////////////////////////////////
                            ///////////////////////////////////////////////////////////////////////////////////////////////
                            case (rm_addr_i [NOC_ADDR_SIZE-5:NOC_ADDR_SIZE-8])
                                4'b0001: begin  // write to ALL luts
                                    lut_update_en   = {INPORT_QUANT{1'b1}};
                                end
                                4'b0100: begin  // write to burst flags
                                    rst_burst_en        = 1'b1;
                                end
                                default: begin
                                    lut_update_en       = {INPORT_QUANT{1'b0}};
                                    rst_burst_en        = 1'b0;
                                end
                            endcase
                        end
                        // ************************************************
                        // add more addresses for write access here
                        // ************************************************
                        default: begin
                            lut_update_en       = {INPORT_QUANT{1'b0}};
                            rst_burst_en        = 1'b0;
                        end
                    endcase
                end
                MODE_READ_REQ: begin
                    read_req = 1'b1;
                    case (rm_addr_i [NOC_ADDR_SIZE-1:NOC_ADDR_SIZE-4])
                        4'b0000: begin  // READ LUTS
                            case (rm_addr_i [NOC_ADDR_SIZE-5:NOC_ADDR_SIZE-8])
                                4'b0000: begin  // read from router_module LUT itself
                                    read_lut    = 1'b1;
                                end
                                // READ FROM MODULE LUTS connected with one router
                                4'b0001: begin  // read from module 1 LUT
                                    if (MODULES_PER_ROUTER > 0) begin
                                        sel_lut = 0;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b0010: begin  // read from module 2 LUT
                                    if (MODULES_PER_ROUTER > 1) begin
                                        sel_lut = 1;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b0011: begin  //read from module 3 LUT
                                    if (MODULES_PER_ROUTER > 2) begin
                                        sel_lut = 2;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b0100: begin  // read from module 4 LUT
                                    if (MODULES_PER_ROUTER > 3) begin
                                        sel_lut = 3;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b0101: begin  // read from module 5 LUT
                                    if (MODULES_PER_ROUTER > 4) begin
                                        sel_lut = 4;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b0110: begin  // read from module 6 LUT
                                    if (MODULES_PER_ROUTER > 5) begin
                                        sel_lut = 5;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b0111: begin  // read from module 7 LUT
                                    if (MODULES_PER_ROUTER > 6) begin
                                        sel_lut = 6;
                                        read_lut    = 1'b1;
                                    end
                                end
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                // READ FROM NEIGHBOUR LUTS ///////////////////////////////////////////////////////////////////
                                ///////////////////////////////////////////////////////////////////////////////////////////////
                                4'b1000: begin  // read from module 0 LUT
                                    if (LINKS_PER_ROUTER > 0) begin
                                        sel_lut = 0+MODULES_PER_ROUTER;
                                        read_lut    = 1'b1;
                                    end
                                end
                                // READ FROM MODULE LUTS
                                4'b1001: begin  // read from module 1 LUT
                                    if (LINKS_PER_ROUTER > 1) begin
                                        sel_lut = 1+MODULES_PER_ROUTER;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b1010: begin  // read from module 2 LUT
                                    if (LINKS_PER_ROUTER > 2) begin
                                        sel_lut = 2+MODULES_PER_ROUTER;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b1011: begin  //read from module 3 LUT
                                    if (LINKS_PER_ROUTER > 3) begin
                                        sel_lut = 3+MODULES_PER_ROUTER;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b1100: begin  // read from module 4 LUT
                                    if (LINKS_PER_ROUTER > 4) begin
                                        sel_lut = 4+MODULES_PER_ROUTER;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b1101: begin  // read from module 5 LUT
                                    if (LINKS_PER_ROUTER > 5) begin
                                        sel_lut = 5+MODULES_PER_ROUTER;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b1110: begin  // read from module 6 LUT
                                    if (LINKS_PER_ROUTER > 6) begin
                                        sel_lut = 6+MODULES_PER_ROUTER;
                                        read_lut    = 1'b1;
                                    end
                                end
                                4'b1111: begin  // read from module 7 LUT
                                    if (LINKS_PER_ROUTER > 7) begin
                                        sel_lut = 7+MODULES_PER_ROUTER;
                                        read_lut    = 1'b1;
                                    end
                                end
                                default: begin
                                    sel_lut = {clogb2(INPORT_QUANT){1'b0}};
                                    read_lut    = 1'b0;
                                end
                            endcase
                        end
                        4'b0010: begin  // READ count_mode & burst flags
                            case (rm_addr_i [NOC_ADDR_SIZE-5:NOC_ADDR_SIZE-8])
                                4'b0100: begin  // READ burst flags
                                    read_burst      = 1'b1;
                                end
                                default: begin
                                    read_burst      = 1'b0;
                                end
                            endcase
                        end
                        4'b0011: begin  // READ TRAFFIC COUNTER VALUE
                            case (rm_addr_i [NOC_ADDR_SIZE-5:NOC_ADDR_SIZE-8])
                                4'b1000: begin  // read from neighbour 0 counter
                                    if (INPORT_QUANT > 0) begin
                                        cnt_port_sel    = 0;
                                        read_cntr   = 1'b1;
                                    end
                                end
                                4'b1001: begin  // read from neighbour 1 counter
                                    if (INPORT_QUANT > 1) begin
                                        cnt_port_sel    = 1;
                                        read_cntr   = 1'b1;
                                    end
                                end
                                4'b1010: begin  // read from neighbour 2 counter
                                    if (INPORT_QUANT > 2) begin
                                        cnt_port_sel    = 2;
                                        read_cntr   = 1'b1;
                                    end
                                end
                                4'b1011: begin  // read from neighbour 3 counter
                                    if (INPORT_QUANT > 3) begin
                                        cnt_port_sel    = 3;
                                        read_cntr   = 1'b1;
                                    end
                                end
                                4'b1100: begin  // read from neighbour 4 counter
                                    if (INPORT_QUANT > 4) begin
                                        cnt_port_sel    = 4;
                                        read_cntr   = 1'b1;
                                    end
                                end
                                4'b1101: begin  // read from neighbour 5 counter
                                    if (INPORT_QUANT > 5) begin
                                        cnt_port_sel    = 5;
                                        read_cntr   = 1'b1;
                                    end
                                end
                                4'b1110: begin  // read from neighbour 6 counter
                                    if (INPORT_QUANT > 6) begin
                                        cnt_port_sel    = 6;
                                        read_cntr   = 1'b1;
                                    end
                                end
                                default: begin
                                    cnt_port_sel    = 0;
                                    read_cntr       = 1'b0;
                                end
                            endcase
                        end
                        4'b0100: begin  // READ TRAFFIC COUNTER VALUES (+RESET COUNTER)
                            case (rm_addr_i [NOC_ADDR_SIZE-5:NOC_ADDR_SIZE-8])
                                4'b1000: begin  // read from neighbour 0 counter
                                    if (INPORT_QUANT > 0) begin
                                        cnt_port_sel    = 0;
                                        read_cntr   = 1'b1;
                                        cnt_rst     = 1'b1;
                                    end
                                end
                                4'b1001: begin  // read from neighbour 1 counter
                                    if (INPORT_QUANT > 1) begin
                                        cnt_port_sel    = 1;
                                        read_cntr   = 1'b1;
                                        cnt_rst     = 1'b1;
                                    end
                                end
                                4'b1010: begin  // read from neighbour 2 counter
                                    if (INPORT_QUANT > 2) begin
                                        cnt_port_sel    = 2;
                                        read_cntr   = 1'b1;
                                        cnt_rst     = 1'b1;
                                    end
                                end
                                4'b1011: begin  // read from neighbour 3 counter
                                    if (INPORT_QUANT > 3) begin
                                        cnt_port_sel    = 3;
                                        read_cntr   = 1'b1;
                                        cnt_rst     = 1'b1;
                                    end
                                end
                                4'b1100: begin  // read from neighbour 4 counter
                                    if (INPORT_QUANT > 4) begin
                                        cnt_port_sel    = 4;
                                        read_cntr   = 1'b1;
                                        cnt_rst     = 1'b1;
                                    end
                                end
                                4'b1101: begin  // read from neighbour 5 counter
                                    if (INPORT_QUANT > 5) begin
                                        cnt_port_sel    = 5;
                                        read_cntr   = 1'b1;
                                        cnt_rst     = 1'b1;
                                    end
                                end
                                4'b1110: begin  // read from neighbour 6 counter
                                    if (INPORT_QUANT > 6) begin
                                        cnt_port_sel    = 6;
                                        read_cntr   = 1'b1;
                                        cnt_rst     = 1'b1;
                                    end
                                end
                                default: begin
                                    cnt_port_sel    = 0;
                                    read_cntr       = 1'b0;
                                    cnt_rst         = 1'b0;
                                end
                            endcase
                        end
                        // ************************************************
                        // add more addresses for read access here
                        // ************************************************
                        default: begin
                            sel_lut         = 0;
                            read_lut        = 0;
                            read_burst      = 0;
                            cnt_port_sel    = 0;
                            read_cntr       = 1'b0;
                            cnt_rst         = 1'b0;
                        end
                    endcase
                end

                default: begin
                    read_req            = 1'b0;
                    read_cntr           = 1'b0;
                    read_lut            = 1'b0;
                    read_burst          = 1'b0;
                    sel_lut             = {clogb2(INPORT_QUANT){1'b0}};
                    lut_update_en       = {INPORT_QUANT{1'b0}};
                    rin_routing_lut     = {LUT_SIZE*LINKS_PER_ROUTER{1'b0}};
                    cnt_port_sel        = {clogb2(INPORT_QUANT){1'b0}};
                    cnt_rst             = 1'b0;
                    rst_burst_en        = 1'b0;
                end
            endcase
        end  // if input valid
    end


    // burst flag
    always @* begin
        if (rst_burst_en == 1'b1) begin
            rst_burst   = rm_data0_i [OUTPORT_QUANT-1:0];
        end else begin
            rst_burst   = {OUTPORT_QUANT{1'b0}};
        end
    end

    // output registers to nocif (avoiding combinational loop stall->wreq->stall)
    always @(posedge clk_i, negedge reset_q_i) begin: out_register
        if (reset_q_i == 1'b0) begin
            r_rm_trg_chip_x_coord <= {CHIP_X_COORD_SIZE{1'b0}};
            r_rm_trg_chip_y_coord <= {CHIP_Y_COORD_SIZE{1'b0}};
            r_rm_trg_chip_z_coord <= {CHIP_Z_COORD_SIZE{1'b0}};
            r_rm_trg_mod_x_coord <= {MOD_X_COORD_SIZE{1'b0}};
            r_rm_trg_mod_y_coord <= {MOD_Y_COORD_SIZE{1'b0}};
            r_rm_trg_mod_z_coord <= {MOD_Z_COORD_SIZE{1'b0}};
            r_rm_src_chip_x_coord <= {CHIP_X_COORD_SIZE{1'b0}};
            r_rm_src_chip_y_coord <= {CHIP_Y_COORD_SIZE{1'b0}};
            r_rm_src_chip_z_coord <= {CHIP_Z_COORD_SIZE{1'b0}};
            r_rm_src_mod_x_coord <= {MOD_X_COORD_SIZE{1'b0}};
            r_rm_src_mod_y_coord <= {MOD_Y_COORD_SIZE{1'b0}};
            r_rm_src_mod_z_coord <= {MOD_Z_COORD_SIZE{1'b0}};
            r_rm_burst      <= 1'b0;
            r_rm_bsel       <= {NOC_BSEL_SIZE{1'b0}};
            r_rm_data0      <= {NOC_DATA_SIZE{1'b0}};
            r_rm_data1      <= {NOC_DATA_SIZE{1'b0}};
            r_rm_addr       <= {NOC_ADDR_SIZE{1'b0}};
            r_rm_mode       <= {NOC_MODE_SIZE{1'b0}};
        end
        else if (read_req == 1'b1) begin
            {r_rm_trg_chip_x_coord,r_rm_trg_chip_y_coord,r_rm_trg_chip_z_coord} <= rin_rm_trg_chipid;
            {r_rm_trg_mod_x_coord,r_rm_trg_mod_y_coord,r_rm_trg_mod_z_coord}    <= rin_rm_trg_modid;
            {r_rm_src_chip_x_coord,r_rm_src_chip_y_coord,r_rm_src_chip_z_coord} <= rin_rm_src_chipid;
            {r_rm_src_mod_x_coord,r_rm_src_mod_y_coord,r_rm_src_mod_z_coord}    <= rin_rm_src_modid;
            r_rm_burst      <= rin_rm_burst;
            r_rm_bsel       <= rin_rm_bsel;
            r_rm_data0      <= rin_rm_data0;
            r_rm_data1      <= rin_rm_data1;
            r_rm_addr       <= rin_rm_addr;
            r_rm_mode       <= rin_rm_mode;
        end
    end

    always @* begin
        rin_rm_trg_chipid   = {rm_src_chip_x_coord_i,rm_src_chip_y_coord_i,rm_src_chip_z_coord_i};//rm_src_chipid_i;
        rin_rm_trg_modid    = {rm_src_mod_x_coord_i,rm_src_mod_y_coord_i,rm_src_mod_z_coord_i};//rm_src_modid_i;
        rin_rm_src_chipid   = {rm_trg_chip_x_coord_i,rm_trg_chip_y_coord_i,rm_trg_chip_z_coord_i};//rm_trg_chipid_i;
        rin_rm_src_modid    = {rm_trg_mod_x_coord_i,rm_trg_mod_y_coord_i,rm_trg_mod_z_coord_i};//rm_trg_modid_i;
        rin_rm_burst        = 1'b0;
        if (read_cntr == 1'b1) begin
            rin_rm_data0        = data_out_cntr_read;
            rin_rm_data1        = {NOC_DATA_SIZE{1'b0}};
        end else if (read_lut == 1'b1) begin
            rin_rm_data0        = data_out_lut_read;
            rin_rm_data1        = {NOC_DATA_SIZE{1'b0}};///lut fits in datasize of 64 bits
        end else if (read_burst == 1'b1) begin
            rin_rm_data0        = data_out_burst_read;
            rin_rm_data1        = {NOC_DATA_SIZE{1'b0}};
        end else begin
            rin_rm_data0        = {NOC_DATA_SIZE{1'b1}};    // invalid address
            rin_rm_data1        = {NOC_DATA_SIZE{1'b1}};    // invalid address
        end
        rin_rm_addr         = rm_data0_i[NOC_ADDR_SIZE-1:0];   //lower data bits are return addr
        rin_rm_mode         = MODE_READ_RSP;
        rin_rm_bsel         = {NOC_BSEL_SIZE{1'b1}};
    end

    // this line should create an error if NOC_CHIPID_SIZE or NOC_MODID_SIZE > 8
    assign data_out_cntr_read   = {{(NOC_DATA_SIZE-CNT_SIZE){1'b0}}, cnt_data_i};
    assign data_out_lut_read    = {{(NOC_DATA_SIZE-LUT_SIZE*LINKS_PER_ROUTER){1'b0}}, r_routing_lut_i};
    assign data_out_burst_read  = {{(NOC_DATA_SIZE-OUTPORT_QUANT){1'b0}}, burstActive_i};


    // flow control register
    always @(posedge clk_i, negedge reset_q_i) begin: flow_ctrl_reg
        if (reset_q_i == 1'b0) begin
            r_outreg_used   <= 1'b0;
        end
        else begin
            r_outreg_used   <= rin_outreg_used;
        end
    end

    always @* begin
        if ((read_req == 1'b1)/* || (LUTUpRespEn == 1'b1)*/) begin
            rin_outreg_used = 1'b1;
        end else if (r_outreg_used == 1'b1 && rm_stall_i == 1'b0) begin
            rin_outreg_used = 1'b0;
        end else begin
            rin_outreg_used = r_outreg_used;
        end
    end


    // outputs to router
    assign rin_routing_lut_o    = rin_routing_lut;
    assign sel_lut_o            = sel_lut;
    assign lut_update_en_o      = lut_update_en;

    assign cnt_port_sel_o       = cnt_port_sel;
    assign cnt_rst_o            = cnt_rst;

    assign rst_burst_o          = rst_burst;

    // flow control
    assign flit_done        = 1'b1;                                                 // change this to for waits in re-programming
    assign rm_stall         = (r_outreg_used || ~flit_done) ? 1'b1 : rm_stall_i;    // dont read input if last flit was READ OR output blocked

    // flow control outputs to nocif
    assign rm_stall_o       = rm_stall;
    assign rm_wrreq_o       = r_outreg_used;

    // outputs from output register
    assign rm_trg_chip_x_coord_o  = r_rm_trg_chip_x_coord;
    assign rm_trg_chip_y_coord_o  = r_rm_trg_chip_y_coord;
    assign rm_trg_chip_z_coord_o  = r_rm_trg_chip_z_coord;
    assign rm_trg_mod_x_coord_o = r_rm_trg_mod_x_coord;
    assign rm_trg_mod_y_coord_o = r_rm_trg_mod_y_coord;
    assign rm_trg_mod_z_coord_o = r_rm_trg_mod_z_coord;

    assign rm_src_chip_x_coord_o  = r_rm_src_chip_x_coord;
    assign rm_src_chip_y_coord_o  = r_rm_src_chip_y_coord;
    assign rm_src_chip_z_coord_o  = r_rm_src_chip_z_coord;

    assign rm_src_mod_x_coord_o   = r_rm_src_mod_x_coord;
    assign rm_src_mod_y_coord_o   = r_rm_src_mod_y_coord;
    assign rm_src_mod_z_coord_o   = r_rm_src_mod_z_coord;

    assign rm_burst_o       = r_rm_burst;
    assign rm_arq_o         = 1'b0;       //ARQ in NoC router is disabled
    assign rm_bsel_o        = r_rm_bsel;
    assign rm_data0_o       = r_rm_data0;
    assign rm_data1_o       = r_rm_data1; // lut fits in one flit
    assign rm_addr_o        = r_rm_addr;
    assign rm_mode_o        = r_rm_mode;


endmodule // router_module

`endif
