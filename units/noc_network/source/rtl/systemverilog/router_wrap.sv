
module router_wrap #(
    `include "noc_parameter.vh"
    ,parameter  PORT_QUANT                                  = 3,    //number of links + modules
    parameter   MODULES_PER_ROUTER                          = 1,
    parameter   LINKS_PER_ROUTER                            = PORT_QUANT-MODULES_PER_ROUTER,    //number of links to other on-chip routers

    //LUT 8 bit mapping (MSB -> LSB) --> N,NE,E,SE,S,SW,W,NW
    parameter   [LUT_SIZE*LINKS_PER_ROUTER-1:0] LUT_RESET_VALUE = 0,
    parameter   [MOD_X_COORD_SIZE-1:0]      DIRECTION_ADD_X = 0,
    parameter   [MOD_Y_COORD_SIZE-1:0]      DIRECTION_ADD_Y = 0,
    parameter                                   SYNC_ROUTER = 0,
    parameter   INSTANCE_NAME                                   = "R0"
)
(
    input  wire                          clk_i,
    input  wire                          reset_q_i,
    input  wire                          testmode_i,
    input  wire    [NOC_CHIPID_SIZE-1:0] home_chipid_i,

    // Rx (input) NoC links
    noc_link_if.rx              rx_if[0:PORT_QUANT-1],

    // Tx (output) NoC links
    noc_link_if.tx              tx_if[0:PORT_QUANT-1]
);

//========================================================================================================================================//
//=================================================== internal wire declarations =========================================================//
//========================================================================================================================================//
wire    [PORT_QUANT-1:0]                        tx_wrreq;
wire    [PORT_QUANT-1:0]                        tx_stall;
wire    [NOC_HEADER_SIZE*PORT_QUANT-1:0]        tx_header;
wire    [NOC_PAYLOAD_SIZE*PORT_QUANT-1:0]       tx_payload;

wire    [PORT_QUANT-1:0]                        rx_rdreq;
wire    [NOC_HEADER_SIZE*PORT_QUANT-1:0]        rx_header;
wire    [NOC_PAYLOAD_SIZE*PORT_QUANT-1:0]       rx_payload;
wire    [PORT_QUANT-1:0]                        rx_fifo_empty;

wire                                            clk_router_s;
wire                                            reset_q_router_s;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

util_clkbuf i_util_clkbuf_router (
    .I(clk_i),
    .Z(clk_router_s)
);

util_reset_sync i_util_reset_sync_router (
    .clk_i(clk_router_s),
    .reset_q_i(reset_q_i),
    .scan_mode_i(testmode_i),
    .sync_reset_q_o(reset_q_router_s)
);


//========================================================================================================================================//
//============================================= NoC FIFO transmitter/receiver instances  =================================================//
//========================================================================================================================================//

genvar gen_i;
generate
    //NoC links between router and modules
    for (gen_i=0; gen_i<MODULES_PER_ROUTER; gen_i=gen_i+1) begin: FIFO_MOD_GEN
        noc_link_phy #(
            .SYNCHRONOUS        (0)
        ) FIFO_InOut (
            .clk_i              (clk_router_s),
            .rst_q_i            (reset_q_router_s),
            .testmode_i         (testmode_i),

            .tx_wrreq_i         (tx_wrreq[gen_i]),
            .tx_header_i        (tx_header [(gen_i+1)*NOC_HEADER_SIZE-1 : gen_i*NOC_HEADER_SIZE]),
            .tx_payload_i       (tx_payload [(gen_i+1)*NOC_PAYLOAD_SIZE-1 : gen_i*NOC_PAYLOAD_SIZE]),
            .tx_stall_o         (tx_stall[gen_i]),
            .tx_if              (tx_if[gen_i]),

            .rx_rdreq_i         (rx_rdreq[gen_i]),
            .rx_header_o        (rx_header[(gen_i+1)*NOC_HEADER_SIZE-1 : gen_i*NOC_HEADER_SIZE]),
            .rx_payload_o       (rx_payload[(gen_i+1)*NOC_PAYLOAD_SIZE-1 : gen_i*NOC_PAYLOAD_SIZE]),
            .rx_fifo_empty_o    (rx_fifo_empty[gen_i]),
            .rx_if              (rx_if[gen_i])
        );
    end

    //NoC links between routers
    for (gen_i=MODULES_PER_ROUTER; gen_i<PORT_QUANT; gen_i=gen_i+1) begin: FIFO_ROUTER_GEN
        noc_link_phy #(
            .SYNCHRONOUS        (SYNC_ROUTER)
        ) FIFO_InOut (
            .clk_i              (clk_router_s),
            .rst_q_i            (reset_q_router_s),
            .testmode_i         (testmode_i),

            .tx_wrreq_i         (tx_wrreq[gen_i]),
            .tx_header_i        (tx_header [(gen_i+1)*NOC_HEADER_SIZE-1 : gen_i*NOC_HEADER_SIZE]),
            .tx_payload_i       (tx_payload [(gen_i+1)*NOC_PAYLOAD_SIZE-1 : gen_i*NOC_PAYLOAD_SIZE]),
            .tx_stall_o         (tx_stall[gen_i]),
            .tx_if              (tx_if[gen_i]),

            .rx_rdreq_i         (rx_rdreq[gen_i]),
            .rx_header_o        (rx_header[(gen_i+1)*NOC_HEADER_SIZE-1 : gen_i*NOC_HEADER_SIZE]),
            .rx_payload_o       (rx_payload[(gen_i+1)*NOC_PAYLOAD_SIZE-1 : gen_i*NOC_PAYLOAD_SIZE]),
            .rx_fifo_empty_o    (rx_fifo_empty[gen_i]),
            .rx_if              (rx_if[gen_i])
        );
    end
endgenerate


//========================================================================================================================================//
//=========================================================== Real Router Block  =========================================================//
//========================================================================================================================================//
router_top #(
    .INSTANCE_NAME              (INSTANCE_NAME),
    .TOTAL_PORT_QUANT           (PORT_QUANT+1), //add one port for router
    .MODULES_PER_ROUTER         (MODULES_PER_ROUTER),
    .LUT_RESET_VALUE            (LUT_RESET_VALUE),
    .DIRECTION_ADD_X            (DIRECTION_ADD_X),
    .DIRECTION_ADD_Y            (DIRECTION_ADD_Y)
) i_router_top (
    .clk_i                      (clk_router_s),
    .reset_q_i                  (reset_q_router_s),
    .home_chipid_i              (home_chipid_i),

    // NoC RX
    .header_i                   (rx_header),
    .payload_i                  (rx_payload),
    .rdreq_o                    (rx_rdreq),
    .flit_avail_q_i             (rx_fifo_empty),

    // NoC TX
    .header_o                   (tx_header),
    .payload_o                  (tx_payload),
    .wrreq_o                    (tx_wrreq),
    .stall_i                    (tx_stall)
);


endmodule
