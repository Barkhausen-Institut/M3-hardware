
/*************************************************************/
/*  2x2 star-mesh NoC with 2 modules per router              */
/*************************************************************/

module onchip_network #(
    `include "noc_parameter.vh"
    ,parameter PORT_QUANT_R0 = 5,
    parameter PORT_QUANT_R1  = 5,
    parameter PORT_QUANT_R2  = 5,
    parameter PORT_QUANT_R3  = 5,
    parameter SYNC_ROUTER    = 0
)
(
    input  wire                                   clk_i,
    input  wire                                   reset_q_i,
    input  wire             [NOC_CHIPID_SIZE-1:0] home_chipid_i,

    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile0_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile0_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile1_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile1_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile2_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile2_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile3_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile3_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile4_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile4_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile5_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile5_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile6_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile6_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile7_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile7_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile8_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile8_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile9_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile9_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile10_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile10_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_out_waddr_i,
    output wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile11_noc_fifo_in_data_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_in_raddr_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_in_waddr_o,
    input  wire  [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile11_noc_fifo_out_data_i,
    output wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_out_raddr_o,
    input  wire         [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_out_waddr_i
);

    //========================================================================================================================================//
    //============================================ internal wire declarations & interfaces ===================================================//
    //========================================================================================================================================//

    wire testmode_s = 1'b0;

    // NoC links (router <-> router and router <-> module)
    noc_link_if rx_if_R0[0:PORT_QUANT_R0-1]();
    noc_link_if rx_if_R1[0:PORT_QUANT_R1-1]();
    noc_link_if rx_if_R2[0:PORT_QUANT_R2-1]();
    noc_link_if rx_if_R3[0:PORT_QUANT_R3-1]();

    noc_link_if tx_if_R0[0:PORT_QUANT_R0-1]();
    noc_link_if tx_if_R1[0:PORT_QUANT_R1-1]();
    noc_link_if tx_if_R2[0:PORT_QUANT_R2-1]();
    noc_link_if tx_if_R3[0:PORT_QUANT_R3-1]();


    //========================================================================================================================================//
    //========================================================= router instances =============================================================//
    //========================================================================================================================================//
    // router instances
    //    ^ Y-axis
    //    |
    //  1 |  R0---R1
    //    |  |    |
    //  0 |  R2---R3
    //  -------------> X-axis
    //       0    1   (X,Y)



    // Router R0 (connected to R1, R2, and Tile0, Tile1, Tile2) ////////////////////////////////////////////////////////////////////////////////
    assign rx_if_R0[0].fifo_write_addr = tile0_noc_fifo_out_waddr_i;
    assign rx_if_R0[0].fifo_read_data = tile0_noc_fifo_out_data_i;
    assign tile0_noc_fifo_out_raddr_o = rx_if_R0[0].fifo_read_addr;

    assign rx_if_R0[1].fifo_write_addr = tile1_noc_fifo_out_waddr_i;
    assign rx_if_R0[1].fifo_read_data = tile1_noc_fifo_out_data_i;
    assign tile1_noc_fifo_out_raddr_o = rx_if_R0[1].fifo_read_addr;

    assign rx_if_R0[2].fifo_write_addr = tile2_noc_fifo_out_waddr_i;
    assign rx_if_R0[2].fifo_read_data = tile2_noc_fifo_out_data_i;
    assign tile2_noc_fifo_out_raddr_o = rx_if_R0[2].fifo_read_addr;

    assign rx_if_R0[3].fifo_write_addr = tx_if_R1[4].fifo_write_addr;
    assign rx_if_R0[3].fifo_read_data = tx_if_R1[4].fifo_read_data;
    assign tx_if_R1[4].fifo_read_addr = rx_if_R0[3].fifo_read_addr;

    assign rx_if_R0[4].fifo_write_addr = tx_if_R2[3].fifo_write_addr;
    assign rx_if_R0[4].fifo_read_data = tx_if_R2[3].fifo_read_data;
    assign tx_if_R2[3].fifo_read_addr = rx_if_R0[4].fifo_read_addr;


    assign tile0_noc_fifo_in_waddr_o = tx_if_R0[0].fifo_write_addr;
    assign tile0_noc_fifo_in_data_o = tx_if_R0[0].fifo_read_data;
    assign tx_if_R0[0].fifo_read_addr = tile0_noc_fifo_in_raddr_i;

    assign tile1_noc_fifo_in_waddr_o = tx_if_R0[1].fifo_write_addr;
    assign tile1_noc_fifo_in_data_o = tx_if_R0[1].fifo_read_data;
    assign tx_if_R0[1].fifo_read_addr = tile1_noc_fifo_in_raddr_i;

    assign tile2_noc_fifo_in_waddr_o = tx_if_R0[2].fifo_write_addr;
    assign tile2_noc_fifo_in_data_o = tx_if_R0[2].fifo_read_data;
    assign tx_if_R0[2].fifo_read_addr = tile2_noc_fifo_in_raddr_i;

    assign rx_if_R1[4].fifo_write_addr = tx_if_R0[3].fifo_write_addr;
    assign rx_if_R1[4].fifo_read_data = tx_if_R0[3].fifo_read_data;
    assign tx_if_R0[3].fifo_read_addr = rx_if_R1[4].fifo_read_addr;

    assign rx_if_R2[3].fifo_write_addr = tx_if_R0[4].fifo_write_addr;
    assign rx_if_R2[3].fifo_read_data = tx_if_R0[4].fifo_read_data;
    assign tx_if_R0[4].fifo_read_addr = rx_if_R2[3].fifo_read_addr;

    router_wrap #(
        .PORT_QUANT         (PORT_QUANT_R0),   // 2 router links + tiles
        .MODULES_PER_ROUTER (3),
        //LUT 8 bit mapping (MSB -> LSB) --> N,NE,E,SE,S,SW,W,NW
        .LUT_RESET_VALUE    ({8'b00001000,     // output S
                              8'b00110000}),   // output E
        .DIRECTION_ADD_X    (0),
        .DIRECTION_ADD_Y    (1),
        .SYNC_ROUTER        (SYNC_ROUTER),
        .INSTANCE_NAME      ("R0")
    ) router_wrap_r0 (
        .clk_i              (clk_i),
        .reset_q_i          (reset_q_i),
        .testmode_i         (testmode_s),
        .home_chipid_i      (home_chipid_i),

        .rx_if              (rx_if_R0),
        .tx_if              (tx_if_R0)
    );


    // Router R1 (connected to R0, R3, and Tile3, Tile4, Tile5) ////////////////////////////////////////////////////////////////////////////////
    assign rx_if_R1[0].fifo_write_addr = tile3_noc_fifo_out_waddr_i;
    assign rx_if_R1[0].fifo_read_data = tile3_noc_fifo_out_data_i;
    assign tile3_noc_fifo_out_raddr_o = rx_if_R1[0].fifo_read_addr;

    assign rx_if_R1[1].fifo_write_addr = tile4_noc_fifo_out_waddr_i;
    assign rx_if_R1[1].fifo_read_data = tile4_noc_fifo_out_data_i;
    assign tile4_noc_fifo_out_raddr_o = rx_if_R1[1].fifo_read_addr;

    assign rx_if_R1[2].fifo_write_addr = tile5_noc_fifo_out_waddr_i;
    assign rx_if_R1[2].fifo_read_data = tile5_noc_fifo_out_data_i;
    assign tile5_noc_fifo_out_raddr_o = rx_if_R1[2].fifo_read_addr;

    assign rx_if_R1[3].fifo_write_addr = tx_if_R3[3].fifo_write_addr;
    assign rx_if_R1[3].fifo_read_data = tx_if_R3[3].fifo_read_data;
    assign tx_if_R3[3].fifo_read_addr = rx_if_R1[3].fifo_read_addr;

    assign rx_if_R1[4].fifo_write_addr = tx_if_R0[3].fifo_write_addr;
    assign rx_if_R1[4].fifo_read_data = tx_if_R0[3].fifo_read_data;
    assign tx_if_R0[3].fifo_read_addr = rx_if_R1[4].fifo_read_addr;


    assign tile3_noc_fifo_in_waddr_o = tx_if_R1[0].fifo_write_addr;
    assign tile3_noc_fifo_in_data_o = tx_if_R1[0].fifo_read_data;
    assign tx_if_R1[0].fifo_read_addr = tile3_noc_fifo_in_raddr_i;

    assign tile4_noc_fifo_in_waddr_o = tx_if_R1[1].fifo_write_addr;
    assign tile4_noc_fifo_in_data_o = tx_if_R1[1].fifo_read_data;
    assign tx_if_R1[1].fifo_read_addr = tile4_noc_fifo_in_raddr_i;

    assign tile5_noc_fifo_in_waddr_o = tx_if_R1[2].fifo_write_addr;
    assign tile5_noc_fifo_in_data_o = tx_if_R1[2].fifo_read_data;
    assign tx_if_R1[2].fifo_read_addr = tile5_noc_fifo_in_raddr_i;

    assign rx_if_R3[3].fifo_write_addr = tx_if_R1[3].fifo_write_addr;
    assign rx_if_R3[3].fifo_read_data = tx_if_R1[3].fifo_read_data;
    assign tx_if_R1[3].fifo_read_addr = rx_if_R3[3].fifo_read_addr;

    assign rx_if_R0[3].fifo_write_addr = tx_if_R1[4].fifo_write_addr;
    assign rx_if_R0[3].fifo_read_data = tx_if_R1[4].fifo_read_data;
    assign tx_if_R1[4].fifo_read_addr = rx_if_R0[3].fifo_read_addr;

    router_wrap #(
        .PORT_QUANT         (PORT_QUANT_R1),   // 2 router links + tiles
        .MODULES_PER_ROUTER (3),
        //LUT 8 bit mapping (MSB -> LSB) --> N,NE,E,SE,S,SW,W,NW
        .LUT_RESET_VALUE    ({8'b00000110,     // output W
                              8'b00001000}),   // output S
        .DIRECTION_ADD_X    (1),
        .DIRECTION_ADD_Y    (1),
        .SYNC_ROUTER        (SYNC_ROUTER),
        .INSTANCE_NAME      ("R1")
    ) router_wrap_r1 (
        .clk_i              (clk_i),
        .reset_q_i          (reset_q_i),
        .testmode_i         (testmode_s),
        .home_chipid_i      (home_chipid_i),

        .rx_if              (rx_if_R1),
        .tx_if              (tx_if_R1)
    );



    // Router R2 (connected to R0, R3, and Tile6, Tile7, Tile8) ////////////////////////////////////////////////////////////////////////////////
    assign rx_if_R2[0].fifo_write_addr = tile6_noc_fifo_out_waddr_i;
    assign rx_if_R2[0].fifo_read_data = tile6_noc_fifo_out_data_i;
    assign tile6_noc_fifo_out_raddr_o = rx_if_R2[0].fifo_read_addr;

    assign rx_if_R2[1].fifo_write_addr = tile7_noc_fifo_out_waddr_i;
    assign rx_if_R2[1].fifo_read_data = tile7_noc_fifo_out_data_i;
    assign tile7_noc_fifo_out_raddr_o = rx_if_R2[1].fifo_read_addr;

    assign rx_if_R2[2].fifo_write_addr = tile8_noc_fifo_out_waddr_i;
    assign rx_if_R2[2].fifo_read_data = tile8_noc_fifo_out_data_i;
    assign tile8_noc_fifo_out_raddr_o = rx_if_R2[2].fifo_read_addr;

    assign rx_if_R2[3].fifo_write_addr = tx_if_R0[4].fifo_write_addr;
    assign rx_if_R2[3].fifo_read_data = tx_if_R0[4].fifo_read_data;
    assign tx_if_R0[4].fifo_read_addr = rx_if_R2[3].fifo_read_addr;

    assign rx_if_R2[4].fifo_write_addr = tx_if_R3[4].fifo_write_addr;
    assign rx_if_R2[4].fifo_read_data = tx_if_R3[4].fifo_read_data;
    assign tx_if_R3[4].fifo_read_addr = rx_if_R2[4].fifo_read_addr;


    assign tile6_noc_fifo_in_waddr_o = tx_if_R2[0].fifo_write_addr;
    assign tile6_noc_fifo_in_data_o = tx_if_R2[0].fifo_read_data;
    assign tx_if_R2[0].fifo_read_addr = tile6_noc_fifo_in_raddr_i;

    assign tile7_noc_fifo_in_waddr_o = tx_if_R2[1].fifo_write_addr;
    assign tile7_noc_fifo_in_data_o = tx_if_R2[1].fifo_read_data;
    assign tx_if_R2[1].fifo_read_addr = tile7_noc_fifo_in_raddr_i;

    assign tile8_noc_fifo_in_waddr_o = tx_if_R2[2].fifo_write_addr;
    assign tile8_noc_fifo_in_data_o = tx_if_R2[2].fifo_read_data;
    assign tx_if_R2[2].fifo_read_addr = tile8_noc_fifo_in_raddr_i;

    assign rx_if_R0[4].fifo_write_addr = tx_if_R2[3].fifo_write_addr;
    assign rx_if_R0[4].fifo_read_data = tx_if_R2[3].fifo_read_data;
    assign tx_if_R2[3].fifo_read_addr = rx_if_R0[4].fifo_read_addr;

    assign rx_if_R3[4].fifo_write_addr = tx_if_R2[4].fifo_write_addr;
    assign rx_if_R3[4].fifo_read_data = tx_if_R2[4].fifo_read_data;
    assign tx_if_R2[4].fifo_read_addr = rx_if_R3[4].fifo_read_addr;

    router_wrap #(
        .PORT_QUANT         (PORT_QUANT_R2),   // 2 router links + tiles
        .MODULES_PER_ROUTER (3),
        //LUT 8 bit mapping (MSB -> LSB) --> N,NE,E,SE,S,SW,W,NW
        .LUT_RESET_VALUE    ({8'b01100000,     // output E
                              8'b10000000}),   // output N
        .DIRECTION_ADD_X    (0),
        .DIRECTION_ADD_Y    (0),
        .SYNC_ROUTER        (SYNC_ROUTER),
        .INSTANCE_NAME      ("R2")
    ) router_wrap_r2 (
        .clk_i              (clk_i),
        .reset_q_i          (reset_q_i),
        .testmode_i         (testmode_s),
        .home_chipid_i      (home_chipid_i),

        .rx_if              (rx_if_R2),
        .tx_if              (tx_if_R2)
    );


    // Router R3 (connected to R1, R2, and Tile9, Tile10, Tile11) ////////////////////////////////////////////////////////////////////////////////
    assign rx_if_R3[0].fifo_write_addr = tile9_noc_fifo_out_waddr_i;
    assign rx_if_R3[0].fifo_read_data = tile9_noc_fifo_out_data_i;
    assign tile9_noc_fifo_out_raddr_o = rx_if_R3[0].fifo_read_addr;

    assign rx_if_R3[1].fifo_write_addr = tile10_noc_fifo_out_waddr_i;
    assign rx_if_R3[1].fifo_read_data = tile10_noc_fifo_out_data_i;
    assign tile10_noc_fifo_out_raddr_o = rx_if_R3[1].fifo_read_addr;

    assign rx_if_R3[2].fifo_write_addr = tile11_noc_fifo_out_waddr_i;
    assign rx_if_R3[2].fifo_read_data = tile11_noc_fifo_out_data_i;
    assign tile11_noc_fifo_out_raddr_o = rx_if_R3[2].fifo_read_addr;

    assign rx_if_R3[3].fifo_write_addr = tx_if_R1[3].fifo_write_addr;
    assign rx_if_R3[3].fifo_read_data = tx_if_R1[3].fifo_read_data;
    assign tx_if_R1[3].fifo_read_addr = rx_if_R3[3].fifo_read_addr;

    assign rx_if_R3[4].fifo_write_addr = tx_if_R2[4].fifo_write_addr;
    assign rx_if_R3[4].fifo_read_data = tx_if_R2[4].fifo_read_data;
    assign tx_if_R2[4].fifo_read_addr = rx_if_R3[4].fifo_read_addr;


    assign tile9_noc_fifo_in_waddr_o = tx_if_R3[0].fifo_write_addr;
    assign tile9_noc_fifo_in_data_o = tx_if_R3[0].fifo_read_data;
    assign tx_if_R3[0].fifo_read_addr = tile9_noc_fifo_in_raddr_i;

    assign tile10_noc_fifo_in_waddr_o = tx_if_R3[1].fifo_write_addr;
    assign tile10_noc_fifo_in_data_o = tx_if_R3[1].fifo_read_data;
    assign tx_if_R3[1].fifo_read_addr = tile10_noc_fifo_in_raddr_i;

    assign tile11_noc_fifo_in_waddr_o = tx_if_R3[2].fifo_write_addr;
    assign tile11_noc_fifo_in_data_o = tx_if_R3[2].fifo_read_data;
    assign tx_if_R3[2].fifo_read_addr = tile11_noc_fifo_in_raddr_i;

    assign rx_if_R1[3].fifo_write_addr = tx_if_R3[3].fifo_write_addr;
    assign rx_if_R1[3].fifo_read_data = tx_if_R3[3].fifo_read_data;
    assign tx_if_R3[3].fifo_read_addr = rx_if_R1[3].fifo_read_addr;

    assign rx_if_R2[4].fifo_write_addr = tx_if_R3[4].fifo_write_addr;
    assign rx_if_R2[4].fifo_read_data = tx_if_R3[4].fifo_read_data;
    assign tx_if_R3[4].fifo_read_addr = rx_if_R2[4].fifo_read_addr;

    router_wrap #(
        .PORT_QUANT         (PORT_QUANT_R3),   // 2 router links + tiles
        .MODULES_PER_ROUTER (3),
        //LUT 8 bit mapping (MSB -> LSB) --> N,NE,E,SE,S,SW,W,NW
        .LUT_RESET_VALUE    ({8'b00000011,     // output W
                              8'b10000000}),   // output N
        .DIRECTION_ADD_X    (1),
        .DIRECTION_ADD_Y    (0),
        .SYNC_ROUTER        (SYNC_ROUTER),
        .INSTANCE_NAME      ("R3")
    ) router_wrap_r3 (
        .clk_i              (clk_i),
        .reset_q_i          (reset_q_i),
        .testmode_i         (testmode_s),
        .home_chipid_i      (home_chipid_i),

        .rx_if              (rx_if_R3),
        .tx_if              (tx_if_R3)
    );

endmodule
