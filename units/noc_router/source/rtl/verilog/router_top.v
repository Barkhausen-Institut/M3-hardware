`ifndef tROUTER_XY_BE_ONLY_Kachel_router_top
`define tROUTER_XY_BE_ONLY_Kachel_router_top


// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module router_top #(
    `include "noc_parameter.vh"
    ,parameter                                  INSTANCE_NAME       = "R1",
    parameter                                   TOTAL_PORT_QUANT    = 1,                        //number of links + modules + router
    parameter                                   INPORT_QUANT        = TOTAL_PORT_QUANT-1,       //number of links + modules (without router)
    parameter                                   OUTPORT_QUANT       = TOTAL_PORT_QUANT-1,       //number of links + modules (without router)
    parameter                                   MODULES_PER_ROUTER  = 1,
    parameter                                   LINKS_PER_ROUTER    = TOTAL_PORT_QUANT-1-MODULES_PER_ROUTER,    //number of links to other on-chip routers
    parameter   [LUT_SIZE*LINKS_PER_ROUTER-1:0] LUT_RESET_VALUE     = 0,
    //// router's own address (Z not relevant here -> used for modules only)
    parameter   [MOD_X_COORD_SIZE-1:0]          DIRECTION_ADD_X     = 0,
    parameter   [MOD_Y_COORD_SIZE-1:0]          DIRECTION_ADD_Y     = 0
)
(
    input   wire                                            clk_i,
    input   wire                                            reset_q_i,
    // Header: burst(1)+bsel+srcModId+srcChipId+trgX+trgY+trgZ+trgModId+trgChipId
    // Payload: mode+address+data
    // input port connections
    input   wire    [INPORT_QUANT*NOC_HEADER_SIZE-1:0]      header_i,
    input   wire    [INPORT_QUANT*NOC_PAYLOAD_SIZE-1:0]     payload_i,
    output  wire    [INPORT_QUANT-1:0]                      rdreq_o,
    input   wire    [INPORT_QUANT-1:0]                      flit_avail_q_i,
    // output port connections
    output  wire    [OUTPORT_QUANT*NOC_HEADER_SIZE-1:0]     header_o,
    output  wire    [OUTPORT_QUANT*NOC_PAYLOAD_SIZE-1:0]    payload_o,
    output  wire    [OUTPORT_QUANT-1:0]                     wrreq_o,
    input   wire    [OUTPORT_QUANT-1:0]                     stall_i,

    input   wire    [NOC_CHIPID_SIZE-1:0]                   home_chipid_i
);

    // wires between router and outfifo
    wire                                router2outfifo_rdreq;
    wire                                outfifo2router_flit_avail_q;
    wire    [NOC_HEADER_SIZE-1:0]       outfifo2router_header;
    wire    [NOC_PAYLOAD_SIZE-1:0]      outfifo2router_payload;

    // wires between outfifo and nocif
    wire                                nocif2outfifo_wrreq;
    wire                                outfifo2nocif_stall;
    wire    [NOC_HEADER_SIZE-1:0]       nocif2outfifo_header;
    wire    [NOC_PAYLOAD_SIZE-1:0]      nocif2outfifo_payload;

    // wires between router and infifo
    wire                                router2infifo_wrreq;
    wire                                infifo2router_stall;
    wire    [NOC_HEADER_SIZE-1:0]       router2infifo_header;
    wire    [NOC_PAYLOAD_SIZE-1:0]      router2infifo_payload;

    // wires between infifo and nocif
    wire                                nocif2infifo_rdreq;
    wire                                infifo2nocif_flit_avail_q;
    wire    [NOC_HEADER_SIZE-1:0]       infifo2nocif_header;
    wire    [NOC_PAYLOAD_SIZE-1:0]      infifo2nocif_payload;

    // wires between router-module and nocif

    //router-module to nocif
    wire                                rm2nocif_wrreq;
    wire    [CHIP_X_COORD_SIZE-1:0]     rm2nocif_trg_chip_x_coord;
    wire    [CHIP_Y_COORD_SIZE-1:0]     rm2nocif_trg_chip_y_coord;
    wire    [CHIP_Z_COORD_SIZE-1:0]     rm2nocif_trg_chip_z_coord;
    wire    [MOD_X_COORD_SIZE-1:0]      rm2nocif_trg_mod_x_coord;
    wire    [MOD_Y_COORD_SIZE-1:0]      rm2nocif_trg_mod_y_coord;
    wire    [MOD_Z_COORD_SIZE-1:0]      rm2nocif_trg_mod_z_coord;
    wire    [CHIP_X_COORD_SIZE-1:0]     rm2nocif_src_chip_x_coord;
    wire    [CHIP_Y_COORD_SIZE-1:0]     rm2nocif_src_chip_y_coord;
    wire    [CHIP_Z_COORD_SIZE-1:0]     rm2nocif_src_chip_z_coord;
    wire    [MOD_X_COORD_SIZE-1:0]      rm2nocif_src_mod_x_coord;
    wire    [MOD_Y_COORD_SIZE-1:0]      rm2nocif_src_mod_y_coord;
    wire    [MOD_Z_COORD_SIZE-1:0]      rm2nocif_src_mod_z_coord;

    wire                                rm2nocif_burst;
    wire                                rm2nocif_arq;
    wire    [NOC_BSEL_SIZE-1:0]         rm2nocif_bsel;
    wire    [NOC_DATA_SIZE-1:0]         rm2nocif_data0;
    wire    [NOC_DATA_SIZE-1:0]         rm2nocif_data1;
    wire    [NOC_ADDR_SIZE-1:0]         rm2nocif_addr;
    wire    [NOC_MODE_SIZE-1:0]         rm2nocif_mode;
    wire                                nocif2rm_stall;

    // nocif to router-module
    wire                                nocif2rm_wrreq;
    wire    [CHIP_X_COORD_SIZE-1:0]     nocif2rm_trg_chip_x_coord;
    wire    [CHIP_Y_COORD_SIZE-1:0]     nocif2rm_trg_chip_y_coord;
    wire    [CHIP_Z_COORD_SIZE-1:0]     nocif2rm_trg_chip_z_coord;
    wire    [MOD_X_COORD_SIZE-1:0]      nocif2rm_trg_mod_x_coord;
    wire    [MOD_Y_COORD_SIZE-1:0]      nocif2rm_trg_mod_y_coord;
    wire    [MOD_Z_COORD_SIZE-1:0]      nocif2rm_trg_mod_z_coord;
    wire    [CHIP_X_COORD_SIZE-1:0]     nocif2rm_src_chip_x_coord;
    wire    [CHIP_Y_COORD_SIZE-1:0]     nocif2rm_src_chip_y_coord;
    wire    [CHIP_Z_COORD_SIZE-1:0]     nocif2rm_src_chip_z_coord;
    wire    [MOD_X_COORD_SIZE-1:0]      nocif2rm_src_mod_x_coord;
    wire    [MOD_Y_COORD_SIZE-1:0]      nocif2rm_src_mod_y_coord;
    wire    [MOD_Z_COORD_SIZE-1:0]      nocif2rm_src_mod_z_coord;

    wire                                nocif2rm_burst;
    wire                                nocif2rm_arq;
    wire    [NOC_BSEL_SIZE-1:0]         nocif2rm_bsel;
    wire    [NOC_DATA_SIZE-1:0]         nocif2rm_data0;
    wire    [NOC_DATA_SIZE-1:0]         nocif2rm_data1;
    wire    [NOC_ADDR_SIZE-1:0]         nocif2rm_addr;
    wire    [NOC_MODE_SIZE-1:0]         nocif2rm_mode;
    wire                                rm2nocif_stall;

    // wires between rm and router
    wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0]     rm2router_rin_routing_lut;
    wire    [LUT_SIZE*LINKS_PER_ROUTER-1:0]     router2rm_r_routing_lut;
    wire    [clogb2(INPORT_QUANT+1)-1:0]        rm2router_sel_lut;
    wire    [(INPORT_QUANT+1)-1:0]              rm2router_lut_update_en;

    wire    [CNT_SIZE-1:0]                      cnt_data;
    wire    [clogb2(TOTAL_PORT_QUANT)-1:0]      cnt_port_sel;
    wire                                        cnt_rst;

    wire    [INPORT_QUANT-1:0]                  rdreq;

    wire    [TOTAL_PORT_QUANT-1:0]              rst_burst;
    wire    [TOTAL_PORT_QUANT-1:0]              burstActive;


    function integer clogb2 (input [31:0] value_in);
        reg [31:0] value;
        begin
            value = value_in - 1;
            for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
                value = value >> 1;
        end
    endfunction


    // submodule instatiation
    router_OnOff_lut #(
        .INSTANCE_NAME              (INSTANCE_NAME),
        .INPORT_QUANT               (TOTAL_PORT_QUANT),
        .OUTPORT_QUANT              (TOTAL_PORT_QUANT),
        .MODULES_PER_ROUTER         (MODULES_PER_ROUTER),
        .LUT_RESET_VALUE            (LUT_RESET_VALUE),
        .DIRECTION_ADD_X            (DIRECTION_ADD_X),
        .DIRECTION_ADD_Y            (DIRECTION_ADD_Y)
    )
    router_i (
        .clk_i                      (clk_i),
        .reset_q_i                  (reset_q_i),
        .home_chipid_i              (home_chipid_i),
        .header_i                   ({outfifo2router_header, header_i}),
        .payload_i                  ({outfifo2router_payload, payload_i}),
        .rdreq_o                    ({router2outfifo_rdreq, rdreq}),
        .flit_avail_q_i             ({outfifo2router_flit_avail_q, flit_avail_q_i}),

        .header_o                   ({router2infifo_header, header_o}),
        .payload_o                  ({router2infifo_payload, payload_o}),
        .wrreq_o                    ({router2infifo_wrreq, wrreq_o}),
        .stall_i                    ({infifo2router_stall, stall_i}),

        .rin_routing_lut_i          (rm2router_rin_routing_lut),
        .r_routing_lut_o            (router2rm_r_routing_lut),
        .sel_lut_i                  (rm2router_sel_lut),
        .lut_update_en_i            (rm2router_lut_update_en),

        .cnt_data_o                 (cnt_data),
        .cnt_port_sel_i             (cnt_port_sel),
        .cnt_rst_i                  (cnt_rst),

        .rst_burst_i                (rst_burst),
        .burstActive_o              (burstActive)
    );
    assign rdreq_o  = rdreq;

    router_module #(
        .INSTANCE_NAME              (INSTANCE_NAME),
        .INPORT_QUANT               (TOTAL_PORT_QUANT),
        .OUTPORT_QUANT              (TOTAL_PORT_QUANT),
        .MODULES_PER_ROUTER         (MODULES_PER_ROUTER),
        .DIRECTION_ADD_X            (DIRECTION_ADD_X),
        .DIRECTION_ADD_Y            (DIRECTION_ADD_Y)
    )
    router_module_i (
        .clk_i                      (clk_i),
        .reset_q_i                  (reset_q_i),

        .rm_wrreq_o                 (rm2nocif_wrreq),
        .rm_src_chip_x_coord_o      (rm2nocif_src_chip_x_coord),
        .rm_src_chip_y_coord_o      (rm2nocif_src_chip_y_coord),
        .rm_src_chip_z_coord_o      (rm2nocif_src_chip_z_coord),
        .rm_src_mod_x_coord_o       (rm2nocif_src_mod_x_coord),
        .rm_src_mod_y_coord_o       (rm2nocif_src_mod_y_coord),
        .rm_src_mod_z_coord_o       (rm2nocif_src_mod_z_coord),
        .rm_trg_chip_x_coord_o      (rm2nocif_trg_chip_x_coord),
        .rm_trg_chip_y_coord_o      (rm2nocif_trg_chip_y_coord),
        .rm_trg_chip_z_coord_o      (rm2nocif_trg_chip_z_coord),
        .rm_trg_mod_x_coord_o       (rm2nocif_trg_mod_x_coord),
        .rm_trg_mod_y_coord_o       (rm2nocif_trg_mod_y_coord),
        .rm_trg_mod_z_coord_o       (rm2nocif_trg_mod_z_coord),

        .rm_burst_o                 (rm2nocif_burst),
        .rm_arq_o                   (rm2nocif_arq),
        .rm_bsel_o                  (rm2nocif_bsel),
        .rm_data0_o                 (rm2nocif_data0),
        .rm_data1_o                 (rm2nocif_data1),
        .rm_addr_o                  (rm2nocif_addr),
        .rm_mode_o                  (rm2nocif_mode),
        .rm_stall_i                 (nocif2rm_stall),
        .rm_wrreq_i                 (nocif2rm_wrreq),

        .rm_trg_chip_x_coord_i      (nocif2rm_trg_chip_x_coord),
        .rm_trg_chip_y_coord_i      (nocif2rm_trg_chip_y_coord),
        .rm_trg_chip_z_coord_i      (nocif2rm_trg_chip_z_coord),
        .rm_trg_mod_x_coord_i       (nocif2rm_trg_mod_x_coord),
        .rm_trg_mod_y_coord_i       (nocif2rm_trg_mod_y_coord),
        .rm_trg_mod_z_coord_i       (nocif2rm_trg_mod_z_coord),
        .rm_src_chip_x_coord_i      (nocif2rm_src_chip_x_coord),
        .rm_src_chip_y_coord_i      (nocif2rm_src_chip_y_coord),
        .rm_src_chip_z_coord_i      (nocif2rm_src_chip_z_coord),
        .rm_src_mod_x_coord_i       (nocif2rm_src_mod_x_coord),
        .rm_src_mod_y_coord_i       (nocif2rm_src_mod_y_coord),
        .rm_src_mod_z_coord_i       (nocif2rm_src_mod_z_coord),
        .rm_bsel_i                  (nocif2rm_bsel),
        .rm_data0_i                 (nocif2rm_data0),
        .rm_data1_i                 (nocif2rm_data1),
        .rm_addr_i                  (nocif2rm_addr),
        .rm_mode_i                  (nocif2rm_mode),
        .rm_stall_o                 (rm2nocif_stall),

        .rin_routing_lut_o          (rm2router_rin_routing_lut),
        .r_routing_lut_i            (router2rm_r_routing_lut),
        .sel_lut_o                  (rm2router_sel_lut),
        .lut_update_en_o            (rm2router_lut_update_en),

        .cnt_data_i                 (cnt_data),
        .cnt_port_sel_o             (cnt_port_sel),
        .cnt_rst_o                  (cnt_rst),

        .rst_burst_o                (rst_burst),
        .burstActive_i              (burstActive)
    );

    nocif #(
        .ENABLE_ARQ                 (0)
    ) nocif_i (
        .clk_i                      (clk_i),
        .reset_q_i                  (reset_q_i),

        .header_i                   (infifo2nocif_header),
        .payload_i                  (infifo2nocif_payload),
        .rdreq_o                    (nocif2infifo_rdreq),
        .flit_avail_q_i             (infifo2nocif_flit_avail_q),

        .header_o                   (nocif2outfifo_header),
        .payload_o                  (nocif2outfifo_payload),
        .wrreq_o                    (nocif2outfifo_wrreq),
        .stall_i                    (outfifo2nocif_stall),

        .mod_wrreq_o                (nocif2rm_wrreq),
        .src_chip_x_coord_o         (nocif2rm_src_chip_x_coord),
        .src_chip_y_coord_o         (nocif2rm_src_chip_y_coord),
        .src_chip_z_coord_o         (nocif2rm_src_chip_z_coord),
        .src_mod_x_coord_o          (nocif2rm_src_mod_x_coord),
        .src_mod_y_coord_o          (nocif2rm_src_mod_y_coord),
        .src_mod_z_coord_o          (nocif2rm_src_mod_z_coord),

        .trg_chip_x_coord_o         (nocif2rm_trg_chip_x_coord),
        .trg_chip_y_coord_o         (nocif2rm_trg_chip_y_coord),
        .trg_chip_z_coord_o         (nocif2rm_trg_chip_z_coord),
        .trg_mod_x_coord_o          (nocif2rm_trg_mod_x_coord),
        .trg_mod_y_coord_o          (nocif2rm_trg_mod_y_coord),
        .trg_mod_z_coord_o          (nocif2rm_trg_mod_z_coord),

        .mod_burst_o                (nocif2rm_burst),
        .mod_arq_o                  (nocif2rm_arq),
        .mod_bsel_o                 (nocif2rm_bsel),
        .mod_data0_o                (nocif2rm_data0),
        .mod_data1_o                (nocif2rm_data1),
        .mod_addr_o                 (nocif2rm_addr),
        .mod_mode_o                 (nocif2rm_mode),
        .mod_stall_i                (rm2nocif_stall),

        .mod_wrreq_i                (rm2nocif_wrreq),
        .src_chip_x_coord_i         (rm2nocif_src_chip_x_coord),
        .src_chip_y_coord_i         (rm2nocif_src_chip_y_coord),
        .src_chip_z_coord_i         (rm2nocif_src_chip_z_coord),
        .src_mod_x_coord_i          (rm2nocif_src_mod_x_coord),
        .src_mod_y_coord_i          (rm2nocif_src_mod_y_coord),
        .src_mod_z_coord_i          (rm2nocif_src_mod_z_coord),
        .trg_chip_x_coord_i         (rm2nocif_trg_chip_x_coord),
        .trg_chip_y_coord_i         (rm2nocif_trg_chip_y_coord),
        .trg_chip_z_coord_i         (rm2nocif_trg_chip_z_coord),
        .trg_mod_x_coord_i          (rm2nocif_trg_mod_x_coord),
        .trg_mod_y_coord_i          (rm2nocif_trg_mod_y_coord),
        .trg_mod_z_coord_i          (rm2nocif_trg_mod_z_coord),

        .mod_burst_i                (rm2nocif_burst),
        .mod_arq_i                  (rm2nocif_arq),
        .mod_bsel_i                 (rm2nocif_bsel),
        .mod_data0_i                (rm2nocif_data0),
        .mod_data1_i                (rm2nocif_data1),
        .mod_addr_i                 (rm2nocif_addr),
        .mod_mode_i                 (rm2nocif_mode),
        .mod_stall_o                (nocif2rm_stall)
    );

    // outfifo
    regFile1 #(
        .FLIT_SIZE      (NOC_HEADER_SIZE+NOC_PAYLOAD_SIZE),
        .FIFO_SIZE      (FIFO_SIZE),
        .USEDW_SIZE     (FIFO_SIZEWID)
    )
    outfifo_i (
        .rstq_i         (reset_q_i),
        .clk_i          (clk_i),
        .data_i         ({nocif2outfifo_header, nocif2outfifo_payload}),
        .rdreq_i        (router2outfifo_rdreq),
        .wrreq_i        (nocif2outfifo_wrreq),
        .empty_o        (outfifo2router_flit_avail_q),
        .full_o         (outfifo2nocif_stall),
        .data_o         ({outfifo2router_header, outfifo2router_payload}),
        .usedw_o        ()  // not used
    );

    // infifo
    regFile1 #(
        .FLIT_SIZE      (NOC_HEADER_SIZE+NOC_PAYLOAD_SIZE),
        .FIFO_SIZE      (FIFO_SIZE),
        .USEDW_SIZE     (FIFO_SIZEWID)
    )
    infifo_i (
        .rstq_i         (reset_q_i),
        .clk_i          (clk_i),
        .data_i         ({router2infifo_header, router2infifo_payload}),
        .rdreq_i        (nocif2infifo_rdreq),
        .wrreq_i        (router2infifo_wrreq),
        .empty_o        (infifo2nocif_flit_avail_q),
        .full_o         (infifo2router_stall),
        .data_o         ({infifo2nocif_header, infifo2nocif_payload}),
        .usedw_o        ()  // not used
    );

endmodule

`endif //  `ifndef tROUTER_DXY_BE_ONLY_STAR_MESH_HEX_LUT_WRAPPER
