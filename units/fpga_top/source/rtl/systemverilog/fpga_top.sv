//------------------------------------------------------------
// top level for fpga
//------------------------------------------------------------

module fpga_top #(
    `include "pm_types.vh"
    ,`include "mod_ids.vh"
    ,`include "noc_parameter.vh"
`ifdef USE_DDR4
    ,`include "ddr4_user_parameter.vh"
`endif
    ,parameter FPGA_MAC_BASE      = 48'h080028_030405,

    parameter HOST_IP             = {8'd192, 8'd168, 8'd42, 8'd25},
    parameter FPGA_IP_BASE        = {8'd192, 8'd168, 8'd42, 8'd240},

    parameter GATEWAY_IP_ADDR     = {8'd192, 8'd168, 8'd42, 8'd1},
    parameter SUBNET_MASK         = {8'd255, 8'd255, 8'd255, 8'd0},

    parameter HOST_PORT           = 16'd1800,
    parameter FPGA_PORT           = 16'd1800,

    parameter PM_COUNT            = 8,
    parameter int PM_DOMAIN_TYPE[PM_COUNT] = '{PM_TYPE_ACC,
                                               PM_TYPE_NONE,
                                               PM_TYPE_NONE,
                                               PM_TYPE_NONE,
                                               PM_TYPE_NONE,
                                               PM_TYPE_NONE,
                                               PM_TYPE_NONE,
                                               PM_TYPE_NONE},
    parameter int CLKFREQ_PM_MHZ[PM_COUNT] = '{100, 100, 100, 100, 100, 100, 100, 100},
    parameter int PM_UART_ATTACHED[PM_COUNT] = '{1, 0, 0, 0, 0, 0, 0, 0},   //only one PM can be connected to UART

    parameter SIMULATION_ETH      = 0,
    parameter SIMULATION_DDR4     = 0
)
(

    // *** clocks ***
    input   wire            SYSCLK1_300_N,  //system clock 300 MHz
    input   wire            SYSCLK1_300_P,

    input   wire            CLK_125MHZ_N,   //system clock 125 MHz
    input   wire            CLK_125MHZ_P,


    // *** Ethernet PHY ***
    output  wire            PHY1_RESET_B,

    input   wire            PHY1_SGMII_OUT_N,
    input   wire            PHY1_SGMII_OUT_P,
    output  wire            PHY1_SGMII_IN_N,
    output  wire            PHY1_SGMII_IN_P,
    input   wire            PHY1_SGMII_CLK_N,
    input   wire            PHY1_SGMII_CLK_P,

    inout   wire            PHY1_MDIO,
    output  wire            PHY1_MDC,


    // *** Ethernet FMC PHYs ***
`ifdef USE_ETHERNET_FMC
    input   wire            ETH_FMC_REF_CLK_N,
    input   wire            ETH_FMC_REF_CLK_P,

    input   wire      [3:0] ETH_FMC_PHY1_RGMII_RD,
    input   wire            ETH_FMC_PHY1_RGMII_RX_CTL,
    input   wire            ETH_FMC_PHY1_RGMII_RXC,
    output  wire      [3:0] ETH_FMC_PHY1_RGMII_TD,
    output  wire            ETH_FMC_PHY1_RGMII_TX_CTL,
    output  wire            ETH_FMC_PHY1_RGMII_TXC,
    output  wire            ETH_FMC_PHY1_RESET_N,
    inout   wire            ETH_FMC_PHY1_MDIO,
    output  wire            ETH_FMC_PHY1_MDC,

`ifdef USE_ETHERNET_FMC_PHY2
    input   wire      [3:0] ETH_FMC_PHY2_RGMII_RD,
    input   wire            ETH_FMC_PHY2_RGMII_RX_CTL,
    input   wire            ETH_FMC_PHY2_RGMII_RXC,
    output  wire      [3:0] ETH_FMC_PHY2_RGMII_TD,
    output  wire            ETH_FMC_PHY2_RGMII_TX_CTL,
    output  wire            ETH_FMC_PHY2_RGMII_TXC,
    output  wire            ETH_FMC_PHY2_RESET_N,
    inout   wire            ETH_FMC_PHY2_MDIO,
    output  wire            ETH_FMC_PHY2_MDC,
`endif

`ifdef USE_ETHERNET_FMC_PHY3
    input   wire      [3:0] ETH_FMC_PHY3_RGMII_RD,
    input   wire            ETH_FMC_PHY3_RGMII_RX_CTL,
    input   wire            ETH_FMC_PHY3_RGMII_RXC,
    output  wire      [3:0] ETH_FMC_PHY3_RGMII_TD,
    output  wire            ETH_FMC_PHY3_RGMII_TX_CTL,
    output  wire            ETH_FMC_PHY3_RGMII_TXC,
    output  wire            ETH_FMC_PHY3_RESET_N,
    inout   wire            ETH_FMC_PHY3_MDIO,
    output  wire            ETH_FMC_PHY3_MDC,
`endif

`ifdef USE_ETHERNET_FMC_PHY4
    input   wire      [3:0] ETH_FMC_PHY4_RGMII_RD,
    input   wire            ETH_FMC_PHY4_RGMII_RX_CTL,
    input   wire            ETH_FMC_PHY4_RGMII_RXC,
    output  wire      [3:0] ETH_FMC_PHY4_RGMII_TD,
    output  wire            ETH_FMC_PHY4_RGMII_TX_CTL,
    output  wire            ETH_FMC_PHY4_RGMII_TXC,
    output  wire            ETH_FMC_PHY4_RESET_N,
    inout   wire            ETH_FMC_PHY4_MDIO,
    output  wire            ETH_FMC_PHY4_MDC,
`endif

`endif

    // *** Switches ***
    input   wire      [3:0] GPIO_DIP_SW,    //SW12
    input   wire            GPIO_SW_N,      //user pushbuttons
    input   wire            GPIO_SW_W,
    input   wire            GPIO_SW_S,
    input   wire            GPIO_SW_E,
    input   wire            GPIO_SW_C,
    input   wire            CPU_RESET,


    // *** LEDs ***
    output  wire      [7:0] GPIO_LED,

    // *** UART ***
    output  wire            UART_TX,
    input   wire            UART_RX

    // *** SDRAM ***
`ifdef USE_DDR4_C1
    ,input  wire            DDR4_C1_250MHZ_CLK_N,
    input   wire            DDR4_C1_250MHZ_CLK_P,
    output  wire            DDR4_C1_ACT_B,
    output  wire     [16:0] DDR4_C1_ADDR,
    output  wire      [1:0] DDR4_C1_BA,
    output  wire            DDR4_C1_BG,
    output  wire            DDR4_C1_CKE,
    output  wire            DDR4_C1_ODT,
    output  wire            DDR4_C1_CS_B,
    output  wire            DDR4_C1_CK_T,
    output  wire            DDR4_C1_CK_C,
    output  wire            DDR4_C1_RESET_B,
    inout   wire      [9:0] DDR4_C1_DM,
    inout   wire     [79:0] DDR4_C1_DQ,
    inout   wire      [9:0] DDR4_C1_DQS_T,
    inout   wire      [9:0] DDR4_C1_DQS_C
`endif

`ifdef USE_DDR4_C2
    ,input  wire            DDR4_C2_250MHZ_CLK_N,
    input   wire            DDR4_C2_250MHZ_CLK_P,
    output  wire            DDR4_C2_ACT_B,
    output  wire     [16:0] DDR4_C2_ADDR,
    output  wire      [1:0] DDR4_C2_BA,
    output  wire            DDR4_C2_BG,
    output  wire            DDR4_C2_CKE,
    output  wire            DDR4_C2_ODT,
    output  wire            DDR4_C2_CS_B,
    output  wire            DDR4_C2_CK_T,
    output  wire            DDR4_C2_CK_C,
    output  wire            DDR4_C2_RESET_B,
    inout   wire      [9:0] DDR4_C2_DM,
    inout   wire     [79:0] DDR4_C2_DQ,
    inout   wire      [9:0] DDR4_C2_DQS_T,
    inout   wire      [9:0] DDR4_C2_DQS_C
`endif

`ifdef SIMULATION
    ,output wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tb_noc_fifo_in_data_o,
    input   wire        [NOC_ASYNC_FIFO_AWIDTH:0] tb_noc_fifo_in_raddr_i,
    output  wire        [NOC_ASYNC_FIFO_AWIDTH:0] tb_noc_fifo_in_waddr_o,
    input   wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tb_noc_fifo_out_data_i,
    output  wire        [NOC_ASYNC_FIFO_AWIDTH:0] tb_noc_fifo_out_raddr_o,
    input   wire        [NOC_ASYNC_FIFO_AWIDTH:0] tb_noc_fifo_out_waddr_i
`endif
);


    // ******************** global clock / reset signals ********************
    wire            sys_reset;
    wire            pm0_clk;
    wire            pm1_clk;
    wire            pm2_clk;
    wire            pm3_clk;
    wire            pm4_clk;
    wire            pm5_clk;
    wire            pm6_clk;
    wire            pm7_clk;
    wire            noc_clk;
    wire            ddr4_c1_clk;
    wire            ddr4_c2_clk;
    wire            eth_clk;
    wire            mmcme0_locked;
    wire            mmcme1_locked;

    wire            mdio_i, mdio_o, mdio_t;

    wire            phy_reset_n;
    wire     [15:0] eth_status_vector;
    wire            eth_system_reset;

`ifdef USE_ETHERNET_FMC
    wire            eth_fmc_mmcme_locked;
    wire            eth_fmc_ref_clk;
    wire            eth_fmc_gtx_clk;
`else
    wire            eth_fmc_mmcme_locked = 1'b1;
`endif

`ifdef USE_DDR4_C1
    wire                        ddr4_c1_init_calib_complete;
    wire [DDR4_STATUS_SIZE-1:0] ddr4_c1_status;
`endif

`ifdef USE_DDR4_C2
    wire                        ddr4_c2_init_calib_complete;
    wire [DDR4_STATUS_SIZE-1:0] ddr4_c2_status;
`endif



    wire [NOC_CHIPID_SIZE-1:0] home_chipid_s;
    wire [NOC_CHIPID_SIZE-1:0] host_chipid_s;

    //NoC connections
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile0_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile0_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile0_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile1_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile1_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile1_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile2_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile2_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile2_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile3_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile3_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile3_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile4_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile4_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile4_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile5_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile5_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile5_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile6_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile6_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile6_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile7_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile7_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile7_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile8_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile8_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile8_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile9_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile9_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile9_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile10_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile10_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile10_noc_fifo_out_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile11_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tile11_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] tile11_noc_fifo_out_waddr_s;

    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] eth_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] eth_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] eth_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] eth_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] eth_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] eth_noc_fifo_out_waddr_s;

`ifdef USE_DDR4_C1
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] ddr4_c1_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] ddr4_c1_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] ddr4_c1_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] ddr4_c1_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] ddr4_c1_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] ddr4_c1_noc_fifo_out_waddr_s;
`endif

`ifdef USE_DDR4_C2
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] ddr4_c2_noc_fifo_in_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] ddr4_c2_noc_fifo_in_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] ddr4_c2_noc_fifo_in_waddr_s;
    wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] ddr4_c2_noc_fifo_out_data_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] ddr4_c2_noc_fifo_out_raddr_s;
    wire           [NOC_ASYNC_FIFO_AWIDTH:0] ddr4_c2_noc_fifo_out_waddr_s;
`endif

    wire pm0_jtag_tck;
    wire pm0_jtag_tms;
    wire pm0_jtag_tdi;
    wire pm0_jtag_tdo;
    wire pm0_jtag_tdo_en;
    wire pm0_jtag_sel;

    wire pm1_jtag_tck;
    wire pm1_jtag_tms;
    wire pm1_jtag_tdi;
    wire pm1_jtag_tdo;
    wire pm1_jtag_tdo_en;
    wire pm1_jtag_sel;

    wire pm2_jtag_tck;
    wire pm2_jtag_tms;
    wire pm2_jtag_tdi;
    wire pm2_jtag_tdo;
    wire pm2_jtag_tdo_en;
    wire pm2_jtag_sel;

    wire pm3_jtag_tck;
    wire pm3_jtag_tms;
    wire pm3_jtag_tdi;
    wire pm3_jtag_tdo;
    wire pm3_jtag_tdo_en;
    wire pm3_jtag_sel;

    wire pm4_jtag_tck;
    wire pm4_jtag_tms;
    wire pm4_jtag_tdi;
    wire pm4_jtag_tdo;
    wire pm4_jtag_tdo_en;
    wire pm4_jtag_sel;

    wire pm5_jtag_tck;
    wire pm5_jtag_tms;
    wire pm5_jtag_tdi;
    wire pm5_jtag_tdo;
    wire pm5_jtag_tdo_en;
    wire pm5_jtag_sel;

    wire pm6_jtag_tck;
    wire pm6_jtag_tms;
    wire pm6_jtag_tdi;
    wire pm6_jtag_tdo;
    wire pm6_jtag_tdo_en;
    wire pm6_jtag_sel;

    wire pm7_jtag_tck;
    wire pm7_jtag_tms;
    wire pm7_jtag_tdi;
    wire pm7_jtag_tdo;
    wire pm7_jtag_tdo_en;
    wire pm7_jtag_sel;

    wire [PM_COUNT-1:0] pm_uart_tx;
    wire [PM_COUNT-1:0] pm_uart_rx;

    //only one PM is connected to UART
    genvar pm;
    generate
        for (pm=0; pm<PM_COUNT; pm=pm+1) begin
            if (PM_UART_ATTACHED[pm]) begin
                assign pm_uart_rx[pm] = UART_RX;
                assign UART_TX = pm_uart_tx[pm];
            end else begin
                assign pm_uart_rx[pm] = 1'b1;
            end
        end
    endgenerate



    // ******************** CLOCKS/RESETS ********************
    assign sys_reset = CPU_RESET || ~mmcme0_locked || ~mmcme1_locked || ~eth_fmc_mmcme_locked;

    assign GPIO_LED[0] = sys_reset;
    assign GPIO_LED[1] = eth_status_vector[0] && eth_status_vector[1];	//internal link is up + sync has been obtained
    assign GPIO_LED[2] = eth_status_vector[7]; //external link is up

`ifdef USE_DDR4_C1
    `ifdef USE_DDR4_C2
        assign GPIO_LED[3] = ddr4_c1_init_calib_complete && ddr4_c2_init_calib_complete;
    `else
        assign GPIO_LED[3] = ddr4_c1_init_calib_complete;
    `endif
`elsif USE_DDR4_C2
    assign GPIO_LED[3] = ddr4_c2_init_calib_complete;
`else
    assign GPIO_LED[3] = 1'b0;
`endif

    assign GPIO_LED[4] = pm0_jtag_sel;
    assign GPIO_LED[5] = pm1_jtag_sel;
    assign GPIO_LED[6] = pm2_jtag_sel;
    assign GPIO_LED[7] = pm3_jtag_sel;

    assign PHY1_RESET_B = phy_reset_n;


    //----------------------------------------------------------------------------
    // clock generators
    fpga_clk_gen_300 #(
        .CLKOUT0_MHZ  (125),
        .CLKOUT1_MHZ  (100),
        .CLKOUT2_MHZ  (100),
        .CLKOUT3_MHZ  (100),
        .CLKOUT4_MHZ  (CLKFREQ_PM_MHZ[0]),
        .CLKOUT5_MHZ  (CLKFREQ_PM_MHZ[1]),
        .CLKOUT6_MHZ  (CLKFREQ_PM_MHZ[2])
    ) i_fpga_clk_gen_300 (
        .clk0_out     (eth_clk),
        .clk1_out     (noc_clk),
        .clk2_out     (ddr4_c1_clk),
        .clk3_out     (ddr4_c2_clk),
        .clk4_out     (pm0_clk),
        .clk5_out     (pm1_clk),
        .clk6_out     (pm2_clk),

        .reset        (CPU_RESET || eth_system_reset),
        .locked       (mmcme0_locked),
        .clk_in_300_p (SYSCLK1_300_P),
        .clk_in_300_n (SYSCLK1_300_N)
    );

    fpga_clk_gen_125 #(
        .CLKOUT0_MHZ  (CLKFREQ_PM_MHZ[3]),
        .CLKOUT1_MHZ  (CLKFREQ_PM_MHZ[4]),
        .CLKOUT2_MHZ  (CLKFREQ_PM_MHZ[5]),
        .CLKOUT3_MHZ  (CLKFREQ_PM_MHZ[6]),
        .CLKOUT4_MHZ  (CLKFREQ_PM_MHZ[7])
    ) i_fpga_clk_gen_125 (
        .clk0_out     (pm3_clk),
        .clk1_out     (pm4_clk),
        .clk2_out     (pm5_clk),
        .clk3_out     (pm6_clk),
        .clk4_out     (pm7_clk),
        .clk5_out     (),
        .clk6_out     (),

        .reset        (CPU_RESET || eth_system_reset),
        .locked       (mmcme1_locked),
        .clk_in_125_p (CLK_125MHZ_P),
        .clk_in_125_n (CLK_125MHZ_N)
    );


    //----------------------------------------------------------------------------



    IOBUF mdio_iobuf (
        .I(mdio_o),
        .IO(PHY1_MDIO),
        .O(mdio_i),
        .T(mdio_t)
    );

    ethernet_domain #(
        .HOST_IP              (HOST_IP),
        .HOST_PORT            (HOST_PORT),
        .FPGA_IP_BASE         (FPGA_IP_BASE),
        .FPGA_PORT            (FPGA_PORT),
        .FPGA_MAC_BASE        (FPGA_MAC_BASE),
        .GATEWAY_IP_ADDR      (GATEWAY_IP_ADDR),
        .SUBNET_MASK          (SUBNET_MASK),
        .HOME_MODID           (MODID_ETH),
        .SIMULATION           (SIMULATION_ETH)
    )
    i_ethernet_domain (
        .clk_eth_i            (eth_clk),
        .reset_eth_n_i        (~sys_reset),

        // NoC interface
        .noc_fifo_in_data_i   (eth_noc_fifo_in_data_s),
        .noc_fifo_in_raddr_o  (eth_noc_fifo_in_raddr_s),
        .noc_fifo_in_waddr_i  (eth_noc_fifo_in_waddr_s),
        .noc_fifo_out_data_o  (eth_noc_fifo_out_data_s),
        .noc_fifo_out_raddr_i (eth_noc_fifo_out_raddr_s),
        .noc_fifo_out_waddr_o (eth_noc_fifo_out_waddr_s),

        // physical interface
        .sgmii_rxn            (PHY1_SGMII_OUT_N),
        .sgmii_rxp            (PHY1_SGMII_OUT_P),
        .sgmii_txn            (PHY1_SGMII_IN_N),
        .sgmii_txp            (PHY1_SGMII_IN_P),
        .sgmii_clk_n          (PHY1_SGMII_CLK_N),
        .sgmii_clk_p          (PHY1_SGMII_CLK_P),

        .mdio_mdc             (PHY1_MDC),
        .mdio_mdio_i          (mdio_i),
        .mdio_mdio_o          (mdio_o),
        .mdio_mdio_t          (mdio_t),

        .eth_status_vector_o  (eth_status_vector),
        .eth_system_reset_o   (eth_system_reset),
        .home_chipid_o        (home_chipid_s),
        .host_chipid_o        (host_chipid_s),

        .phy_reset_n          (phy_reset_n),

        .gpio_dip_sw_i        (GPIO_DIP_SW)
    );


    assign eth_noc_fifo_in_data_s     = tile1_noc_fifo_in_data_s;
    assign eth_noc_fifo_in_waddr_s    = tile1_noc_fifo_in_waddr_s;
    assign eth_noc_fifo_out_raddr_s   = tile1_noc_fifo_out_raddr_s;
    assign tile1_noc_fifo_out_data_s  = eth_noc_fifo_out_data_s;
    assign tile1_noc_fifo_in_raddr_s  = eth_noc_fifo_in_raddr_s;
    assign tile1_noc_fifo_out_waddr_s = eth_noc_fifo_out_waddr_s;



`ifdef USE_DDR4_C1

    ddr4_domain #(
        .INST                       ("C1"),
        .HOME_MODID                 (MODID_DRAM1),
        .SIMULATION                 (SIMULATION_DDR4)
    ) i_ddr4_c1_domain (
        .sys_clk_p                  (DDR4_C1_250MHZ_CLK_P),
        .sys_clk_n                  (DDR4_C1_250MHZ_CLK_N),
        .sys_rst                    (sys_reset),
        .home_chipid_i              (home_chipid_s),
        .ddr4_clk_i                 (ddr4_c1_clk),
        .ddr4_init_calib_complete_o (ddr4_c1_init_calib_complete),
        .ddr4_status_o              (ddr4_c1_status),

        // NoC interface
        .noc_fifo_in_data_i         (ddr4_c1_noc_fifo_in_data_s),
        .noc_fifo_in_raddr_o        (ddr4_c1_noc_fifo_in_raddr_s),
        .noc_fifo_in_waddr_i        (ddr4_c1_noc_fifo_in_waddr_s),
        .noc_fifo_out_data_o        (ddr4_c1_noc_fifo_out_data_s),
        .noc_fifo_out_raddr_i       (ddr4_c1_noc_fifo_out_raddr_s),
        .noc_fifo_out_waddr_o       (ddr4_c1_noc_fifo_out_waddr_s),

        .ddr4_act_n                 (DDR4_C1_ACT_B),
        .ddr4_addr                  (DDR4_C1_ADDR),
        .ddr4_ba                    (DDR4_C1_BA),
        .ddr4_bg                    (DDR4_C1_BG),
        .ddr4_cke                   (DDR4_C1_CKE),
        .ddr4_odt                   (DDR4_C1_ODT),
        .ddr4_cs_n                  (DDR4_C1_CS_B),
        .ddr4_ck_t                  (DDR4_C1_CK_T),
        .ddr4_ck_c                  (DDR4_C1_CK_C),
        .ddr4_reset_n               (DDR4_C1_RESET_B),
        .ddr4_dm_dbi_n              (DDR4_C1_DM),
        .ddr4_dq                    (DDR4_C1_DQ),
        .ddr4_dqs_c                 (DDR4_C1_DQS_C),
        .ddr4_dqs_t                 (DDR4_C1_DQS_T)
    );

    assign tile3_noc_fifo_in_raddr_s    = ddr4_c1_noc_fifo_in_raddr_s;
    assign tile3_noc_fifo_out_data_s    = ddr4_c1_noc_fifo_out_data_s;
    assign tile3_noc_fifo_out_waddr_s   = ddr4_c1_noc_fifo_out_waddr_s;
    assign ddr4_c1_noc_fifo_in_data_s   = tile3_noc_fifo_in_data_s;
    assign ddr4_c1_noc_fifo_in_waddr_s  = tile3_noc_fifo_in_waddr_s;
    assign ddr4_c1_noc_fifo_out_raddr_s = tile3_noc_fifo_out_raddr_s;

`else

    assign tile3_noc_fifo_in_raddr_s  = {NOC_ASYNC_FIFO_AWIDTH{1'b0}};
    assign tile3_noc_fifo_out_data_s  = {NOC_ASYNC_FIFO_PACKET_SIZE{1'b0}};
    assign tile3_noc_fifo_out_waddr_s = {NOC_ASYNC_FIFO_AWIDTH{1'b0}};

`endif


`ifdef USE_DDR4_C2

    ddr4_domain #(
        .INST                       ("C2"),
        .HOME_MODID                 (MODID_DRAM2),
        .SIMULATION                 (SIMULATION_DDR4)
    ) i_ddr4_c2_domain (
        .sys_clk_p                  (DDR4_C2_250MHZ_CLK_P),
        .sys_clk_n                  (DDR4_C2_250MHZ_CLK_N),
        .sys_rst                    (sys_reset),
        .home_chipid_i              (home_chipid_s),
        .ddr4_clk_i                 (ddr4_c2_clk),
        .ddr4_init_calib_complete_o (ddr4_c2_init_calib_complete),
        .ddr4_status_o              (ddr4_c2_status),

        // NoC interface
        .noc_fifo_in_data_i         (ddr4_c2_noc_fifo_in_data_s),
        .noc_fifo_in_raddr_o        (ddr4_c2_noc_fifo_in_raddr_s),
        .noc_fifo_in_waddr_i        (ddr4_c2_noc_fifo_in_waddr_s),
        .noc_fifo_out_data_o        (ddr4_c2_noc_fifo_out_data_s),
        .noc_fifo_out_raddr_i       (ddr4_c2_noc_fifo_out_raddr_s),
        .noc_fifo_out_waddr_o       (ddr4_c2_noc_fifo_out_waddr_s),

        .ddr4_act_n                 (DDR4_C2_ACT_B),
        .ddr4_addr                  (DDR4_C2_ADDR),
        .ddr4_ba                    (DDR4_C2_BA),
        .ddr4_bg                    (DDR4_C2_BG),
        .ddr4_cke                   (DDR4_C2_CKE),
        .ddr4_odt                   (DDR4_C2_ODT),
        .ddr4_cs_n                  (DDR4_C2_CS_B),
        .ddr4_ck_t                  (DDR4_C2_CK_T),
        .ddr4_ck_c                  (DDR4_C2_CK_C),
        .ddr4_reset_n               (DDR4_C2_RESET_B),
        .ddr4_dm_dbi_n              (DDR4_C2_DM),
        .ddr4_dq                    (DDR4_C2_DQ),
        .ddr4_dqs_c                 (DDR4_C2_DQS_C),
        .ddr4_dqs_t                 (DDR4_C2_DQS_T)
    );


    assign tile11_noc_fifo_in_raddr_s   = ddr4_c2_noc_fifo_in_raddr_s;
    assign tile11_noc_fifo_out_data_s   = ddr4_c2_noc_fifo_out_data_s;
    assign tile11_noc_fifo_out_waddr_s  = ddr4_c2_noc_fifo_out_waddr_s;
    assign ddr4_c2_noc_fifo_in_data_s   = tile11_noc_fifo_in_data_s;
    assign ddr4_c2_noc_fifo_in_waddr_s  = tile11_noc_fifo_in_waddr_s;
    assign ddr4_c2_noc_fifo_out_raddr_s = tile11_noc_fifo_out_raddr_s;

`else

    assign tile11_noc_fifo_in_raddr_s  = {NOC_ASYNC_FIFO_AWIDTH{1'b0}};
    assign tile11_noc_fifo_out_data_s  = {NOC_ASYNC_FIFO_PACKET_SIZE{1'b0}};
    assign tile11_noc_fifo_out_waddr_s = {NOC_ASYNC_FIFO_AWIDTH{1'b0}};

`endif


    //tile0 can be used as off-chip link in simulation
`ifdef SIMULATION
    assign tile0_noc_fifo_in_raddr_s  = tb_noc_fifo_in_raddr_i;
    assign tile0_noc_fifo_out_data_s  = tb_noc_fifo_out_data_i;
    assign tile0_noc_fifo_out_waddr_s = tb_noc_fifo_out_waddr_i;
    assign tb_noc_fifo_in_data_o      = tile0_noc_fifo_in_data_s;
    assign tb_noc_fifo_in_waddr_o     = tile0_noc_fifo_in_waddr_s;
    assign tb_noc_fifo_out_raddr_o    = tile0_noc_fifo_out_raddr_s;
`else
    assign tile0_noc_fifo_in_raddr_s  = {NOC_ASYNC_FIFO_AWIDTH{1'b0}};
    assign tile0_noc_fifo_out_data_s  = {NOC_ASYNC_FIFO_PACKET_SIZE{1'b0}};
    assign tile0_noc_fifo_out_waddr_s = {NOC_ASYNC_FIFO_AWIDTH{1'b0}};
`endif


    noc_domain i_noc_domain (
        .clk_noc_i                    (noc_clk),
        .reset_n_i                    (~sys_reset),
        .home_chipid_i                (home_chipid_s),

        .tile0_noc_fifo_in_data_o     (tile0_noc_fifo_in_data_s),
        .tile0_noc_fifo_in_raddr_i    (tile0_noc_fifo_in_raddr_s),
        .tile0_noc_fifo_in_waddr_o    (tile0_noc_fifo_in_waddr_s),
        .tile0_noc_fifo_out_data_i    (tile0_noc_fifo_out_data_s),
        .tile0_noc_fifo_out_raddr_o   (tile0_noc_fifo_out_raddr_s),
        .tile0_noc_fifo_out_waddr_i   (tile0_noc_fifo_out_waddr_s),
        .tile1_noc_fifo_in_data_o     (tile1_noc_fifo_in_data_s),
        .tile1_noc_fifo_in_raddr_i    (tile1_noc_fifo_in_raddr_s),
        .tile1_noc_fifo_in_waddr_o    (tile1_noc_fifo_in_waddr_s),
        .tile1_noc_fifo_out_data_i    (tile1_noc_fifo_out_data_s),
        .tile1_noc_fifo_out_raddr_o   (tile1_noc_fifo_out_raddr_s),
        .tile1_noc_fifo_out_waddr_i   (tile1_noc_fifo_out_waddr_s),
        .tile2_noc_fifo_in_data_o     (tile2_noc_fifo_in_data_s),
        .tile2_noc_fifo_in_raddr_i    (tile2_noc_fifo_in_raddr_s),
        .tile2_noc_fifo_in_waddr_o    (tile2_noc_fifo_in_waddr_s),
        .tile2_noc_fifo_out_data_i    (tile2_noc_fifo_out_data_s),
        .tile2_noc_fifo_out_raddr_o   (tile2_noc_fifo_out_raddr_s),
        .tile2_noc_fifo_out_waddr_i   (tile2_noc_fifo_out_waddr_s),
        .tile3_noc_fifo_in_data_o     (tile3_noc_fifo_in_data_s),
        .tile3_noc_fifo_in_raddr_i    (tile3_noc_fifo_in_raddr_s),
        .tile3_noc_fifo_in_waddr_o    (tile3_noc_fifo_in_waddr_s),
        .tile3_noc_fifo_out_data_i    (tile3_noc_fifo_out_data_s),
        .tile3_noc_fifo_out_raddr_o   (tile3_noc_fifo_out_raddr_s),
        .tile3_noc_fifo_out_waddr_i   (tile3_noc_fifo_out_waddr_s),
        .tile4_noc_fifo_in_data_o     (tile4_noc_fifo_in_data_s),
        .tile4_noc_fifo_in_raddr_i    (tile4_noc_fifo_in_raddr_s),
        .tile4_noc_fifo_in_waddr_o    (tile4_noc_fifo_in_waddr_s),
        .tile4_noc_fifo_out_data_i    (tile4_noc_fifo_out_data_s),
        .tile4_noc_fifo_out_raddr_o   (tile4_noc_fifo_out_raddr_s),
        .tile4_noc_fifo_out_waddr_i   (tile4_noc_fifo_out_waddr_s),
        .tile5_noc_fifo_in_data_o     (tile5_noc_fifo_in_data_s),
        .tile5_noc_fifo_in_raddr_i    (tile5_noc_fifo_in_raddr_s),
        .tile5_noc_fifo_in_waddr_o    (tile5_noc_fifo_in_waddr_s),
        .tile5_noc_fifo_out_data_i    (tile5_noc_fifo_out_data_s),
        .tile5_noc_fifo_out_raddr_o   (tile5_noc_fifo_out_raddr_s),
        .tile5_noc_fifo_out_waddr_i   (tile5_noc_fifo_out_waddr_s),
        .tile6_noc_fifo_in_data_o     (tile6_noc_fifo_in_data_s),
        .tile6_noc_fifo_in_raddr_i    (tile6_noc_fifo_in_raddr_s),
        .tile6_noc_fifo_in_waddr_o    (tile6_noc_fifo_in_waddr_s),
        .tile6_noc_fifo_out_data_i    (tile6_noc_fifo_out_data_s),
        .tile6_noc_fifo_out_raddr_o   (tile6_noc_fifo_out_raddr_s),
        .tile6_noc_fifo_out_waddr_i   (tile6_noc_fifo_out_waddr_s),
        .tile7_noc_fifo_in_data_o     (tile7_noc_fifo_in_data_s),
        .tile7_noc_fifo_in_raddr_i    (tile7_noc_fifo_in_raddr_s),
        .tile7_noc_fifo_in_waddr_o    (tile7_noc_fifo_in_waddr_s),
        .tile7_noc_fifo_out_data_i    (tile7_noc_fifo_out_data_s),
        .tile7_noc_fifo_out_raddr_o   (tile7_noc_fifo_out_raddr_s),
        .tile7_noc_fifo_out_waddr_i   (tile7_noc_fifo_out_waddr_s),
        .tile8_noc_fifo_in_data_o     (tile8_noc_fifo_in_data_s),
        .tile8_noc_fifo_in_raddr_i    (tile8_noc_fifo_in_raddr_s),
        .tile8_noc_fifo_in_waddr_o    (tile8_noc_fifo_in_waddr_s),
        .tile8_noc_fifo_out_data_i    (tile8_noc_fifo_out_data_s),
        .tile8_noc_fifo_out_raddr_o   (tile8_noc_fifo_out_raddr_s),
        .tile8_noc_fifo_out_waddr_i   (tile8_noc_fifo_out_waddr_s),
        .tile9_noc_fifo_in_data_o     (tile9_noc_fifo_in_data_s),
        .tile9_noc_fifo_in_raddr_i    (tile9_noc_fifo_in_raddr_s),
        .tile9_noc_fifo_in_waddr_o    (tile9_noc_fifo_in_waddr_s),
        .tile9_noc_fifo_out_data_i    (tile9_noc_fifo_out_data_s),
        .tile9_noc_fifo_out_raddr_o   (tile9_noc_fifo_out_raddr_s),
        .tile9_noc_fifo_out_waddr_i   (tile9_noc_fifo_out_waddr_s),
        .tile10_noc_fifo_in_data_o    (tile10_noc_fifo_in_data_s),
        .tile10_noc_fifo_in_raddr_i   (tile10_noc_fifo_in_raddr_s),
        .tile10_noc_fifo_in_waddr_o   (tile10_noc_fifo_in_waddr_s),
        .tile10_noc_fifo_out_data_i   (tile10_noc_fifo_out_data_s),
        .tile10_noc_fifo_out_raddr_o  (tile10_noc_fifo_out_raddr_s),
        .tile10_noc_fifo_out_waddr_i  (tile10_noc_fifo_out_waddr_s),
        .tile11_noc_fifo_in_data_o    (tile11_noc_fifo_in_data_s),
        .tile11_noc_fifo_in_raddr_i   (tile11_noc_fifo_in_raddr_s),
        .tile11_noc_fifo_in_waddr_o   (tile11_noc_fifo_in_waddr_s),
        .tile11_noc_fifo_out_data_i   (tile11_noc_fifo_out_data_s),
        .tile11_noc_fifo_out_raddr_o  (tile11_noc_fifo_out_raddr_s),
        .tile11_noc_fifo_out_waddr_i  (tile11_noc_fifo_out_waddr_s)
    );



    jtag_tunnel_mc8 i_jtag_tunnel (
        .jtag_c0_tck_o              (pm0_jtag_tck),
        .jtag_c0_tms_o              (pm0_jtag_tms),
        .jtag_c0_tdi_o              (pm0_jtag_tdi),
        .jtag_c0_tdo_i              (pm0_jtag_tdo),
        .jtag_c0_tdo_en_i           (pm0_jtag_tdo_en),
        .jtag_c0_sel_o              (pm0_jtag_sel),

        .jtag_c1_tck_o              (pm1_jtag_tck),
        .jtag_c1_tms_o              (pm1_jtag_tms),
        .jtag_c1_tdi_o              (pm1_jtag_tdi),
        .jtag_c1_tdo_i              (pm1_jtag_tdo),
        .jtag_c1_tdo_en_i           (pm1_jtag_tdo_en),
        .jtag_c1_sel_o              (pm1_jtag_sel),

        .jtag_c2_tck_o              (pm2_jtag_tck),
        .jtag_c2_tms_o              (pm2_jtag_tms),
        .jtag_c2_tdi_o              (pm2_jtag_tdi),
        .jtag_c2_tdo_i              (pm2_jtag_tdo),
        .jtag_c2_tdo_en_i           (pm2_jtag_tdo_en),
        .jtag_c2_sel_o              (pm2_jtag_sel),

        .jtag_c3_tck_o              (pm3_jtag_tck),
        .jtag_c3_tms_o              (pm3_jtag_tms),
        .jtag_c3_tdi_o              (pm3_jtag_tdi),
        .jtag_c3_tdo_i              (pm3_jtag_tdo),
        .jtag_c3_tdo_en_i           (pm3_jtag_tdo_en),
        .jtag_c3_sel_o              (pm3_jtag_sel),

        .jtag_c4_tck_o              (pm4_jtag_tck),
        .jtag_c4_tms_o              (pm4_jtag_tms),
        .jtag_c4_tdi_o              (pm4_jtag_tdi),
        .jtag_c4_tdo_i              (pm4_jtag_tdo),
        .jtag_c4_tdo_en_i           (pm4_jtag_tdo_en),
        .jtag_c4_sel_o              (pm4_jtag_sel),

        .jtag_c5_tck_o              (pm5_jtag_tck),
        .jtag_c5_tms_o              (pm5_jtag_tms),
        .jtag_c5_tdi_o              (pm5_jtag_tdi),
        .jtag_c5_tdo_i              (pm5_jtag_tdo),
        .jtag_c5_tdo_en_i           (pm5_jtag_tdo_en),
        .jtag_c5_sel_o              (pm5_jtag_sel),

        .jtag_c6_tck_o              (pm6_jtag_tck),
        .jtag_c6_tms_o              (pm6_jtag_tms),
        .jtag_c6_tdi_o              (pm6_jtag_tdi),
        .jtag_c6_tdo_i              (pm6_jtag_tdo),
        .jtag_c6_tdo_en_i           (pm6_jtag_tdo_en),
        .jtag_c6_sel_o              (pm6_jtag_sel),

        .jtag_c7_tck_o              (pm7_jtag_tck),
        .jtag_c7_tms_o              (pm7_jtag_tms),
        .jtag_c7_tdi_o              (pm7_jtag_tdi),
        .jtag_c7_tdo_i              (pm7_jtag_tdo),
        .jtag_c7_tdo_en_i           (pm7_jtag_tdo_en),
        .jtag_c7_sel_o              (pm7_jtag_sel)
    );



`ifdef USE_ETHERNET_FMC
    ethernet_fmc_clk_gen i_ethernet_fmc_clk_gen (
        .clk_out1     (eth_fmc_ref_clk),    //333.333 MHz
        .clk_out2     (eth_fmc_gtx_clk),    //125 MHz
        .reset        (CPU_RESET || eth_system_reset),
        .locked       (eth_fmc_mmcme_locked),
        .clk_in1_p    (ETH_FMC_REF_CLK_P),
        .clk_in1_n    (ETH_FMC_REF_CLK_N)
    );
`endif


    generate
    if (PM_DOMAIN_TYPE[0] == PM_TYPE_ETHFMC) begin: PM0_ETHFMC
`ifdef USE_ETHERNET_FMC
        ethernet_fmc_domain #(
            .ETH_INCLUDE_SHARED_LOGIC (1),
            .HOME_MODID               (MODID_PM0),
            .PM_UART_ATTACHED         (PM_UART_ATTACHED[0]),
            .CLKFREQ_MHZ              (CLKFREQ_PM_MHZ[0])
        ) i_ethernet_fmc_domain (
            .clk_axi_i            (pm0_clk),
            .reset_h_i            (sys_reset),

            // NoC interface
            .noc_fifo_in_data_i   (tile2_noc_fifo_in_data_s),
            .noc_fifo_in_raddr_o  (tile2_noc_fifo_in_raddr_s),
            .noc_fifo_in_waddr_i  (tile2_noc_fifo_in_waddr_s),
            .noc_fifo_out_data_o  (tile2_noc_fifo_out_data_s),
            .noc_fifo_out_raddr_i (tile2_noc_fifo_out_raddr_s),
            .noc_fifo_out_waddr_o (tile2_noc_fifo_out_waddr_s),

            // physical interface
            .rgmii_rxd            (ETH_FMC_PHY1_RGMII_RD),
            .rgmii_rx_ctl         (ETH_FMC_PHY1_RGMII_RX_CTL),
            .rgmii_rxc            (ETH_FMC_PHY1_RGMII_RXC),
            .rgmii_txd            (ETH_FMC_PHY1_RGMII_TD),
            .rgmii_tx_ctl         (ETH_FMC_PHY1_RGMII_TX_CTL),
            .rgmii_txc            (ETH_FMC_PHY1_RGMII_TXC),
            .gtx_clk_i            (eth_fmc_gtx_clk),
            .ref_clk_i            (eth_fmc_ref_clk),

            .mdio_mdc_o           (ETH_FMC_PHY1_MDC),
            .mdio_io              (ETH_FMC_PHY1_MDIO),

            .home_chipid_i        (home_chipid_s),
            .host_chipid_i        (host_chipid_s),
            .phy_reset_n          (ETH_FMC_PHY1_RESET_N),

            .jtag_tck_i           (pm0_jtag_tck),
            .jtag_tms_i           (pm0_jtag_tms),
            .jtag_tdi_i           (pm0_jtag_tdi),
            .jtag_tdo_o           (pm0_jtag_tdo),
            .jtag_tdo_en_o        (pm0_jtag_tdo_en),

            .uart_tx_o            (pm_uart_tx[0]),
            .uart_rx_i            (pm_uart_rx[0])
        );
`endif
    end
    else begin: PM0
        pm_domain #(
            .HOME_MODID                 (MODID_PM0),
            .PM_CORE_SELECT             (PM_DOMAIN_TYPE[0]),
            .PM_UART_ATTACHED           (PM_UART_ATTACHED[0]),
            .CLKFREQ_MHZ                (CLKFREQ_PM_MHZ[0])
        ) i_pm_domain (
            .clk_pm_i                   (pm0_clk),
            .reset_pm_n_i               (~sys_reset),
            .home_chipid_i              (home_chipid_s),
            .host_chipid_i              (host_chipid_s),
            .noc_fifo_pm_in_data_i      (tile2_noc_fifo_in_data_s),
            .noc_fifo_pm_in_raddr_o     (tile2_noc_fifo_in_raddr_s),
            .noc_fifo_pm_in_waddr_i     (tile2_noc_fifo_in_waddr_s),
            .noc_fifo_pm_out_data_o     (tile2_noc_fifo_out_data_s),
            .noc_fifo_pm_out_raddr_i    (tile2_noc_fifo_out_raddr_s),
            .noc_fifo_pm_out_waddr_o    (tile2_noc_fifo_out_waddr_s),
            .jtag_tck_i                 (pm0_jtag_tck),
            .jtag_tms_i                 (pm0_jtag_tms),
            .jtag_tdi_i                 (pm0_jtag_tdi),
            .jtag_tdo_o                 (pm0_jtag_tdo),
            .jtag_tdo_en_o              (pm0_jtag_tdo_en),
            .uart_tx_o                  (pm_uart_tx[0]),
            .uart_rx_i                  (pm_uart_rx[0])
        );
    end
    endgenerate

    generate
    if (PM_DOMAIN_TYPE[1] == PM_TYPE_ETHFMC) begin: PM1_ETHFMC
`ifdef USE_ETHERNET_FMC
        ethernet_fmc_domain #(
            .ETH_INCLUDE_SHARED_LOGIC (0),
            .HOME_MODID               (MODID_PM1),
            .PM_UART_ATTACHED         (PM_UART_ATTACHED[1]),
            .CLKFREQ_MHZ              (CLKFREQ_PM_MHZ[1])
        ) i_ethernet_fmc_domain (
            .clk_axi_i            (pm1_clk),
            .reset_h_i            (sys_reset),

            // NoC interface
            .noc_fifo_in_data_i   (tile4_noc_fifo_in_data_s),
            .noc_fifo_in_raddr_o  (tile4_noc_fifo_in_raddr_s),
            .noc_fifo_in_waddr_i  (tile4_noc_fifo_in_waddr_s),
            .noc_fifo_out_data_o  (tile4_noc_fifo_out_data_s),
            .noc_fifo_out_raddr_i (tile4_noc_fifo_out_raddr_s),
            .noc_fifo_out_waddr_o (tile4_noc_fifo_out_waddr_s),

            // physical interface
            .rgmii_rxd            (ETH_FMC_PHY2_RGMII_RD),
            .rgmii_rx_ctl         (ETH_FMC_PHY2_RGMII_RX_CTL),
            .rgmii_rxc            (ETH_FMC_PHY2_RGMII_RXC),
            .rgmii_txd            (ETH_FMC_PHY2_RGMII_TD),
            .rgmii_tx_ctl         (ETH_FMC_PHY2_RGMII_TX_CTL),
            .rgmii_txc            (ETH_FMC_PHY2_RGMII_TXC),
            .gtx_clk_i            (eth_fmc_gtx_clk),
            .ref_clk_i            (eth_fmc_ref_clk),

            .mdio_mdc_o           (ETH_FMC_PHY2_MDC),
            .mdio_io              (ETH_FMC_PHY2_MDIO),

            .home_chipid_i        (home_chipid_s),
            .host_chipid_i        (host_chipid_s),
            .phy_reset_n          (ETH_FMC_PHY2_RESET_N),

            .jtag_tck_i           (pm1_jtag_tck),
            .jtag_tms_i           (pm1_jtag_tms),
            .jtag_tdi_i           (pm1_jtag_tdi),
            .jtag_tdo_o           (pm1_jtag_tdo),
            .jtag_tdo_en_o        (pm1_jtag_tdo_en),

            .uart_tx_o            (pm_uart_tx[1]),
            .uart_rx_i            (pm_uart_rx[1])
        );
`endif
    end
    else begin: PM1
        pm_domain #(
            .HOME_MODID                 (MODID_PM1),
            .PM_CORE_SELECT             (PM_DOMAIN_TYPE[1]),
            .PM_UART_ATTACHED           (PM_UART_ATTACHED[1]),
            .CLKFREQ_MHZ                (CLKFREQ_PM_MHZ[1])
        ) i_pm_domain (
            .clk_pm_i                   (pm1_clk),
            .reset_pm_n_i               (~sys_reset),
            .home_chipid_i              (home_chipid_s),
            .host_chipid_i              (host_chipid_s),
            .noc_fifo_pm_in_data_i      (tile4_noc_fifo_in_data_s),
            .noc_fifo_pm_in_raddr_o     (tile4_noc_fifo_in_raddr_s),
            .noc_fifo_pm_in_waddr_i     (tile4_noc_fifo_in_waddr_s),
            .noc_fifo_pm_out_data_o     (tile4_noc_fifo_out_data_s),
            .noc_fifo_pm_out_raddr_i    (tile4_noc_fifo_out_raddr_s),
            .noc_fifo_pm_out_waddr_o    (tile4_noc_fifo_out_waddr_s),
            .jtag_tck_i                 (pm1_jtag_tck),
            .jtag_tms_i                 (pm1_jtag_tms),
            .jtag_tdi_i                 (pm1_jtag_tdi),
            .jtag_tdo_o                 (pm1_jtag_tdo),
            .jtag_tdo_en_o              (pm1_jtag_tdo_en),
            .uart_tx_o                  (pm_uart_tx[1]),
            .uart_rx_i                  (pm_uart_rx[1])
        );
    end
    endgenerate

    generate
    if (PM_DOMAIN_TYPE[2] == PM_TYPE_ETHFMC) begin: PM2_ETHFMC
`ifdef USE_ETHERNET_FMC
        ethernet_fmc_domain #(
            .ETH_INCLUDE_SHARED_LOGIC (0),
            .HOME_MODID               (MODID_PM2),
            .PM_UART_ATTACHED         (PM_UART_ATTACHED[2]),
            .CLKFREQ_MHZ              (CLKFREQ_PM_MHZ[2])
        ) i_ethernet_fmc_domain (
            .clk_axi_i            (pm2_clk),
            .reset_h_i            (sys_reset),

            // NoC interface
            .noc_fifo_in_data_i   (tile5_noc_fifo_in_data_s),
            .noc_fifo_in_raddr_o  (tile5_noc_fifo_in_raddr_s),
            .noc_fifo_in_waddr_i  (tile5_noc_fifo_in_waddr_s),
            .noc_fifo_out_data_o  (tile5_noc_fifo_out_data_s),
            .noc_fifo_out_raddr_i (tile5_noc_fifo_out_raddr_s),
            .noc_fifo_out_waddr_o (tile5_noc_fifo_out_waddr_s),

            // physical interface
            .rgmii_rxd            (ETH_FMC_PHY3_RGMII_RD),
            .rgmii_rx_ctl         (ETH_FMC_PHY3_RGMII_RX_CTL),
            .rgmii_rxc            (ETH_FMC_PHY3_RGMII_RXC),
            .rgmii_txd            (ETH_FMC_PHY3_RGMII_TD),
            .rgmii_tx_ctl         (ETH_FMC_PHY3_RGMII_TX_CTL),
            .rgmii_txc            (ETH_FMC_PHY3_RGMII_TXC),
            .gtx_clk_i            (eth_fmc_gtx_clk),
            .ref_clk_i            (eth_fmc_ref_clk),

            .mdio_mdc_o           (ETH_FMC_PHY3_MDC),
            .mdio_io              (ETH_FMC_PHY3_MDIO),

            .home_chipid_i        (home_chipid_s),
            .host_chipid_i        (host_chipid_s),
            .phy_reset_n          (ETH_FMC_PHY3_RESET_N),

            .jtag_tck_i           (pm2_jtag_tck),
            .jtag_tms_i           (pm2_jtag_tms),
            .jtag_tdi_i           (pm2_jtag_tdi),
            .jtag_tdo_o           (pm2_jtag_tdo),
            .jtag_tdo_en_o        (pm2_jtag_tdo_en),

            .uart_tx_o            (pm_uart_tx[2]),
            .uart_rx_i            (pm_uart_rx[2])
        );
`endif
    end
    else begin: PM2
        pm_domain #(
            .HOME_MODID                 (MODID_PM2),
            .PM_CORE_SELECT             (PM_DOMAIN_TYPE[2]),
            .PM_UART_ATTACHED           (PM_UART_ATTACHED[2]),
            .CLKFREQ_MHZ                (CLKFREQ_PM_MHZ[2])
        ) i_pm_domain (
            .clk_pm_i                   (pm2_clk),
            .reset_pm_n_i               (~sys_reset),
            .home_chipid_i              (home_chipid_s),
            .host_chipid_i              (host_chipid_s),
            .noc_fifo_pm_in_data_i      (tile5_noc_fifo_in_data_s),
            .noc_fifo_pm_in_raddr_o     (tile5_noc_fifo_in_raddr_s),
            .noc_fifo_pm_in_waddr_i     (tile5_noc_fifo_in_waddr_s),
            .noc_fifo_pm_out_data_o     (tile5_noc_fifo_out_data_s),
            .noc_fifo_pm_out_raddr_i    (tile5_noc_fifo_out_raddr_s),
            .noc_fifo_pm_out_waddr_o    (tile5_noc_fifo_out_waddr_s),
            .jtag_tck_i                 (pm2_jtag_tck),
            .jtag_tms_i                 (pm2_jtag_tms),
            .jtag_tdi_i                 (pm2_jtag_tdi),
            .jtag_tdo_o                 (pm2_jtag_tdo),
            .jtag_tdo_en_o              (pm2_jtag_tdo_en),
            .uart_tx_o                  (pm_uart_tx[2]),
            .uart_rx_i                  (pm_uart_rx[2])
        );
    end
    endgenerate

    generate
    if (PM_DOMAIN_TYPE[3] == PM_TYPE_ETHFMC) begin: PM3_ETHFMC
`ifdef USE_ETHERNET_FMC
        ethernet_fmc_domain #(
            .ETH_INCLUDE_SHARED_LOGIC (0),
            .HOME_MODID               (MODID_PM3),
            .PM_UART_ATTACHED         (PM_UART_ATTACHED[3]),
            .CLKFREQ_MHZ              (CLKFREQ_PM_MHZ[3])
        ) i_ethernet_fmc_domain (
            .clk_axi_i            (pm3_clk),
            .reset_h_i            (sys_reset),

            // NoC interface
            .noc_fifo_in_data_i   (tile6_noc_fifo_in_data_s),
            .noc_fifo_in_raddr_o  (tile6_noc_fifo_in_raddr_s),
            .noc_fifo_in_waddr_i  (tile6_noc_fifo_in_waddr_s),
            .noc_fifo_out_data_o  (tile6_noc_fifo_out_data_s),
            .noc_fifo_out_raddr_i (tile6_noc_fifo_out_raddr_s),
            .noc_fifo_out_waddr_o (tile6_noc_fifo_out_waddr_s),

            // physical interface
            .rgmii_rxd            (ETH_FMC_PHY4_RGMII_RD),
            .rgmii_rx_ctl         (ETH_FMC_PHY4_RGMII_RX_CTL),
            .rgmii_rxc            (ETH_FMC_PHY4_RGMII_RXC),
            .rgmii_txd            (ETH_FMC_PHY4_RGMII_TD),
            .rgmii_tx_ctl         (ETH_FMC_PHY4_RGMII_TX_CTL),
            .rgmii_txc            (ETH_FMC_PHY4_RGMII_TXC),
            .gtx_clk_i            (eth_fmc_gtx_clk),
            .ref_clk_i            (eth_fmc_ref_clk),

            .mdio_mdc_o           (ETH_FMC_PHY4_MDC),
            .mdio_io              (ETH_FMC_PHY4_MDIO),

            .home_chipid_i        (home_chipid_s),
            .host_chipid_i        (host_chipid_s),
            .phy_reset_n          (ETH_FMC_PHY4_RESET_N),

            .jtag_tck_i           (pm3_jtag_tck),
            .jtag_tms_i           (pm3_jtag_tms),
            .jtag_tdi_i           (pm3_jtag_tdi),
            .jtag_tdo_o           (pm3_jtag_tdo),
            .jtag_tdo_en_o        (pm3_jtag_tdo_en),

            .uart_tx_o            (pm_uart_tx[3]),
            .uart_rx_i            (pm_uart_rx[3])
        );
`endif
    end
    else begin: PM3
        pm_domain #(
            .HOME_MODID                 (MODID_PM3),
            .PM_CORE_SELECT             (PM_DOMAIN_TYPE[3]),
            .PM_UART_ATTACHED           (PM_UART_ATTACHED[3]),
            .CLKFREQ_MHZ                (CLKFREQ_PM_MHZ[3])
        ) i_pm_domain (
            .clk_pm_i                   (pm3_clk),
            .reset_pm_n_i               (~sys_reset),
            .home_chipid_i              (home_chipid_s),
            .host_chipid_i              (host_chipid_s),
            .noc_fifo_pm_in_data_i      (tile6_noc_fifo_in_data_s),
            .noc_fifo_pm_in_raddr_o     (tile6_noc_fifo_in_raddr_s),
            .noc_fifo_pm_in_waddr_i     (tile6_noc_fifo_in_waddr_s),
            .noc_fifo_pm_out_data_o     (tile6_noc_fifo_out_data_s),
            .noc_fifo_pm_out_raddr_i    (tile6_noc_fifo_out_raddr_s),
            .noc_fifo_pm_out_waddr_o    (tile6_noc_fifo_out_waddr_s),
            .jtag_tck_i                 (pm3_jtag_tck),
            .jtag_tms_i                 (pm3_jtag_tms),
            .jtag_tdi_i                 (pm3_jtag_tdi),
            .jtag_tdo_o                 (pm3_jtag_tdo),
            .jtag_tdo_en_o              (pm3_jtag_tdo_en),
            .uart_tx_o                  (pm_uart_tx[3]),
            .uart_rx_i                  (pm_uart_rx[3])
        );
    end
    endgenerate

    generate
    if (PM_DOMAIN_TYPE[4] == PM_TYPE_ETHFMC) begin: PM4_ETHFMC
`ifdef USE_ETHERNET_FMC
        ethernet_fmc_domain #(
            .ETH_INCLUDE_SHARED_LOGIC (1),
            .HOME_MODID               (MODID_PM4),
            .PM_UART_ATTACHED         (PM_UART_ATTACHED[4]),
            .CLKFREQ_MHZ              (CLKFREQ_PM_MHZ[4])
        ) i_ethernet_fmc_domain (
            .clk_axi_i            (pm4_clk),
            .reset_h_i            (sys_reset),

            // NoC interface
            .noc_fifo_in_data_i   (tile7_noc_fifo_in_data_s),
            .noc_fifo_in_raddr_o  (tile7_noc_fifo_in_raddr_s),
            .noc_fifo_in_waddr_i  (tile7_noc_fifo_in_waddr_s),
            .noc_fifo_out_data_o  (tile7_noc_fifo_out_data_s),
            .noc_fifo_out_raddr_i (tile7_noc_fifo_out_raddr_s),
            .noc_fifo_out_waddr_o (tile7_noc_fifo_out_waddr_s),

            // physical interface
            .rgmii_rxd            (ETH_FMC_PHY1_RGMII_RD),
            .rgmii_rx_ctl         (ETH_FMC_PHY1_RGMII_RX_CTL),
            .rgmii_rxc            (ETH_FMC_PHY1_RGMII_RXC),
            .rgmii_txd            (ETH_FMC_PHY1_RGMII_TD),
            .rgmii_tx_ctl         (ETH_FMC_PHY1_RGMII_TX_CTL),
            .rgmii_txc            (ETH_FMC_PHY1_RGMII_TXC),
            .gtx_clk_i            (eth_fmc_gtx_clk),
            .ref_clk_i            (eth_fmc_ref_clk),

            .mdio_mdc_o           (ETH_FMC_PHY1_MDC),
            .mdio_io              (ETH_FMC_PHY1_MDIO),

            .home_chipid_i        (home_chipid_s),
            .host_chipid_i        (host_chipid_s),
            .phy_reset_n          (ETH_FMC_PHY1_RESET_N),

            .jtag_tck_i           (pm4_jtag_tck),
            .jtag_tms_i           (pm4_jtag_tms),
            .jtag_tdi_i           (pm4_jtag_tdi),
            .jtag_tdo_o           (pm4_jtag_tdo),
            .jtag_tdo_en_o        (pm4_jtag_tdo_en),

            .uart_tx_o            (pm_uart_tx[4]),
            .uart_rx_i            (pm_uart_rx[4])
        );
`endif
    end
    else begin: PM4
        pm_domain #(
            .HOME_MODID                 (MODID_PM4),
            .PM_CORE_SELECT             (PM_DOMAIN_TYPE[4]),
            .PM_UART_ATTACHED           (PM_UART_ATTACHED[4]),
            .CLKFREQ_MHZ                (CLKFREQ_PM_MHZ[4])
        ) i_pm_domain (
            .clk_pm_i                   (pm4_clk),
            .reset_pm_n_i               (~sys_reset),
            .home_chipid_i              (home_chipid_s),
            .host_chipid_i              (host_chipid_s),
            .noc_fifo_pm_in_data_i      (tile7_noc_fifo_in_data_s),
            .noc_fifo_pm_in_raddr_o     (tile7_noc_fifo_in_raddr_s),
            .noc_fifo_pm_in_waddr_i     (tile7_noc_fifo_in_waddr_s),
            .noc_fifo_pm_out_data_o     (tile7_noc_fifo_out_data_s),
            .noc_fifo_pm_out_raddr_i    (tile7_noc_fifo_out_raddr_s),
            .noc_fifo_pm_out_waddr_o    (tile7_noc_fifo_out_waddr_s),
            .jtag_tck_i                 (pm4_jtag_tck),
            .jtag_tms_i                 (pm4_jtag_tms),
            .jtag_tdi_i                 (pm4_jtag_tdi),
            .jtag_tdo_o                 (pm4_jtag_tdo),
            .jtag_tdo_en_o              (pm4_jtag_tdo_en),
            .uart_tx_o                  (pm_uart_tx[4]),
            .uart_rx_i                  (pm_uart_rx[4])
        );
    end
    endgenerate

    generate
    if (PM_DOMAIN_TYPE[5] == PM_TYPE_ETHFMC) begin: PM5_ETHFMC
`ifdef USE_ETHERNET_FMC
        ethernet_fmc_domain #(
            .ETH_INCLUDE_SHARED_LOGIC (0),
            .HOME_MODID               (MODID_PM5),
            .PM_UART_ATTACHED         (PM_UART_ATTACHED[5]),
            .CLKFREQ_MHZ              (CLKFREQ_PM_MHZ[5])
        ) i_ethernet_fmc_domain (
            .clk_axi_i            (pm5_clk),
            .reset_h_i            (sys_reset),

            // NoC interface
            .noc_fifo_in_data_i   (tile8_noc_fifo_in_data_s),
            .noc_fifo_in_raddr_o  (tile8_noc_fifo_in_raddr_s),
            .noc_fifo_in_waddr_i  (tile8_noc_fifo_in_waddr_s),
            .noc_fifo_out_data_o  (tile8_noc_fifo_out_data_s),
            .noc_fifo_out_raddr_i (tile8_noc_fifo_out_raddr_s),
            .noc_fifo_out_waddr_o (tile8_noc_fifo_out_waddr_s),

            // physical interface
            .rgmii_rxd            (ETH_FMC_PHY2_RGMII_RD),
            .rgmii_rx_ctl         (ETH_FMC_PHY2_RGMII_RX_CTL),
            .rgmii_rxc            (ETH_FMC_PHY2_RGMII_RXC),
            .rgmii_txd            (ETH_FMC_PHY2_RGMII_TD),
            .rgmii_tx_ctl         (ETH_FMC_PHY2_RGMII_TX_CTL),
            .rgmii_txc            (ETH_FMC_PHY2_RGMII_TXC),
            .gtx_clk_i            (eth_fmc_gtx_clk),
            .ref_clk_i            (eth_fmc_ref_clk),

            .mdio_mdc_o           (ETH_FMC_PHY2_MDC),
            .mdio_io              (ETH_FMC_PHY2_MDIO),

            .home_chipid_i        (home_chipid_s),
            .host_chipid_i        (host_chipid_s),
            .phy_reset_n          (ETH_FMC_PHY2_RESET_N),

            .jtag_tck_i           (pm5_jtag_tck),
            .jtag_tms_i           (pm5_jtag_tms),
            .jtag_tdi_i           (pm5_jtag_tdi),
            .jtag_tdo_o           (pm5_jtag_tdo),
            .jtag_tdo_en_o        (pm5_jtag_tdo_en),

            .uart_tx_o            (pm_uart_tx[5]),
            .uart_rx_i            (pm_uart_rx[5])
        );
`endif
    end
    else begin: PM5
        pm_domain #(
            .HOME_MODID                 (MODID_PM5),
            .PM_CORE_SELECT             (PM_DOMAIN_TYPE[5]),
            .PM_UART_ATTACHED           (PM_UART_ATTACHED[5]),
            .CLKFREQ_MHZ                (CLKFREQ_PM_MHZ[5])
        ) i_pm_domain (
            .clk_pm_i                   (pm5_clk),
            .reset_pm_n_i               (~sys_reset),
            .home_chipid_i              (home_chipid_s),
            .host_chipid_i              (host_chipid_s),
            .noc_fifo_pm_in_data_i      (tile8_noc_fifo_in_data_s),
            .noc_fifo_pm_in_raddr_o     (tile8_noc_fifo_in_raddr_s),
            .noc_fifo_pm_in_waddr_i     (tile8_noc_fifo_in_waddr_s),
            .noc_fifo_pm_out_data_o     (tile8_noc_fifo_out_data_s),
            .noc_fifo_pm_out_raddr_i    (tile8_noc_fifo_out_raddr_s),
            .noc_fifo_pm_out_waddr_o    (tile8_noc_fifo_out_waddr_s),
            .jtag_tck_i                 (pm5_jtag_tck),
            .jtag_tms_i                 (pm5_jtag_tms),
            .jtag_tdi_i                 (pm5_jtag_tdi),
            .jtag_tdo_o                 (pm5_jtag_tdo),
            .jtag_tdo_en_o              (pm5_jtag_tdo_en),
            .uart_tx_o                  (pm_uart_tx[5]),
            .uart_rx_i                  (pm_uart_rx[5])
        );
    end
    endgenerate

    generate
    if (PM_DOMAIN_TYPE[6] == PM_TYPE_ETHFMC) begin: PM6_ETHFMC
`ifdef USE_ETHERNET_FMC
        ethernet_fmc_domain #(
            .ETH_INCLUDE_SHARED_LOGIC (1),
            .HOME_MODID               (MODID_PM6),
            .PM_UART_ATTACHED         (PM_UART_ATTACHED[6]),
            .CLKFREQ_MHZ              (CLKFREQ_PM_MHZ[6])
        ) i_ethernet_fmc_domain (
            .clk_axi_i            (pm6_clk),
            .reset_h_i            (sys_reset),

            // NoC interface
            .noc_fifo_in_data_i   (tile9_noc_fifo_in_data_s),
            .noc_fifo_in_raddr_o  (tile9_noc_fifo_in_raddr_s),
            .noc_fifo_in_waddr_i  (tile9_noc_fifo_in_waddr_s),
            .noc_fifo_out_data_o  (tile9_noc_fifo_out_data_s),
            .noc_fifo_out_raddr_i (tile9_noc_fifo_out_raddr_s),
            .noc_fifo_out_waddr_o (tile9_noc_fifo_out_waddr_s),

            // physical interface
            .rgmii_rxd            (ETH_FMC_PHY3_RGMII_RD),
            .rgmii_rx_ctl         (ETH_FMC_PHY3_RGMII_RX_CTL),
            .rgmii_rxc            (ETH_FMC_PHY3_RGMII_RXC),
            .rgmii_txd            (ETH_FMC_PHY3_RGMII_TD),
            .rgmii_tx_ctl         (ETH_FMC_PHY3_RGMII_TX_CTL),
            .rgmii_txc            (ETH_FMC_PHY3_RGMII_TXC),
            .gtx_clk_i            (eth_fmc_gtx_clk),
            .ref_clk_i            (eth_fmc_ref_clk),

            .mdio_mdc_o           (ETH_FMC_PHY3_MDC),
            .mdio_io              (ETH_FMC_PHY3_MDIO),

            .home_chipid_i        (home_chipid_s),
            .host_chipid_i        (host_chipid_s),
            .phy_reset_n          (ETH_FMC_PHY3_RESET_N),

            .jtag_tck_i           (pm6_jtag_tck),
            .jtag_tms_i           (pm6_jtag_tms),
            .jtag_tdi_i           (pm6_jtag_tdi),
            .jtag_tdo_o           (pm6_jtag_tdo),
            .jtag_tdo_en_o        (pm6_jtag_tdo_en),

            .uart_tx_o            (pm_uart_tx[6]),
            .uart_rx_i            (pm_uart_rx[6])
        );
`endif
    end
    else begin: PM6
        pm_domain #(
            .HOME_MODID                 (MODID_PM6),
            .PM_CORE_SELECT             (PM_DOMAIN_TYPE[6]),
            .PM_UART_ATTACHED           (PM_UART_ATTACHED[6]),
            .CLKFREQ_MHZ                (CLKFREQ_PM_MHZ[6])
        ) i_pm_domain (
            .clk_pm_i                   (pm6_clk),
            .reset_pm_n_i               (~sys_reset),
            .home_chipid_i              (home_chipid_s),
            .host_chipid_i              (host_chipid_s),
            .noc_fifo_pm_in_data_i      (tile9_noc_fifo_in_data_s),
            .noc_fifo_pm_in_raddr_o     (tile9_noc_fifo_in_raddr_s),
            .noc_fifo_pm_in_waddr_i     (tile9_noc_fifo_in_waddr_s),
            .noc_fifo_pm_out_data_o     (tile9_noc_fifo_out_data_s),
            .noc_fifo_pm_out_raddr_i    (tile9_noc_fifo_out_raddr_s),
            .noc_fifo_pm_out_waddr_o    (tile9_noc_fifo_out_waddr_s),
            .jtag_tck_i                 (pm6_jtag_tck),
            .jtag_tms_i                 (pm6_jtag_tms),
            .jtag_tdi_i                 (pm6_jtag_tdi),
            .jtag_tdo_o                 (pm6_jtag_tdo),
            .jtag_tdo_en_o              (pm6_jtag_tdo_en),
            .uart_tx_o                  (pm_uart_tx[6]),
            .uart_rx_i                  (pm_uart_rx[6])
        );
    end
    endgenerate

    generate
    if (PM_DOMAIN_TYPE[7] == PM_TYPE_ETHFMC) begin: PM7_ETHFMC
`ifdef USE_ETHERNET_FMC
        ethernet_fmc_domain #(
            .ETH_INCLUDE_SHARED_LOGIC (0),
            .HOME_MODID               (MODID_PM7),
            .PM_UART_ATTACHED         (PM_UART_ATTACHED[7]),
            .CLKFREQ_MHZ              (CLKFREQ_PM_MHZ[7])
        ) i_ethernet_fmc_domain (
            .clk_axi_i            (pm7_clk),
            .reset_h_i            (sys_reset),

            // NoC interface
            .noc_fifo_in_data_i   (tile10_noc_fifo_in_data_s),
            .noc_fifo_in_raddr_o  (tile10_noc_fifo_in_raddr_s),
            .noc_fifo_in_waddr_i  (tile10_noc_fifo_in_waddr_s),
            .noc_fifo_out_data_o  (tile10_noc_fifo_out_data_s),
            .noc_fifo_out_raddr_i (tile10_noc_fifo_out_raddr_s),
            .noc_fifo_out_waddr_o (tile10_noc_fifo_out_waddr_s),

            // physical interface
            .rgmii_rxd            (ETH_FMC_PHY4_RGMII_RD),
            .rgmii_rx_ctl         (ETH_FMC_PHY4_RGMII_RX_CTL),
            .rgmii_rxc            (ETH_FMC_PHY4_RGMII_RXC),
            .rgmii_txd            (ETH_FMC_PHY4_RGMII_TD),
            .rgmii_tx_ctl         (ETH_FMC_PHY4_RGMII_TX_CTL),
            .rgmii_txc            (ETH_FMC_PHY4_RGMII_TXC),
            .gtx_clk_i            (eth_fmc_gtx_clk),
            .ref_clk_i            (eth_fmc_ref_clk),

            .mdio_mdc_o           (ETH_FMC_PHY4_MDC),
            .mdio_io              (ETH_FMC_PHY4_MDIO),

            .home_chipid_i        (home_chipid_s),
            .host_chipid_i        (host_chipid_s),
            .phy_reset_n          (ETH_FMC_PHY4_RESET_N),

            .jtag_tck_i           (pm7_jtag_tck),
            .jtag_tms_i           (pm7_jtag_tms),
            .jtag_tdi_i           (pm7_jtag_tdi),
            .jtag_tdo_o           (pm7_jtag_tdo),
            .jtag_tdo_en_o        (pm7_jtag_tdo_en),

            .uart_tx_o            (pm_uart_tx[7]),
            .uart_rx_i            (pm_uart_rx[7])
        );
`endif
    end
    else begin: PM7
        pm_domain #(
            .HOME_MODID                 (MODID_PM7),
            .PM_CORE_SELECT             (PM_DOMAIN_TYPE[7]),
            .PM_UART_ATTACHED           (PM_UART_ATTACHED[7]),
            .CLKFREQ_MHZ                (CLKFREQ_PM_MHZ[7])
        ) i_pm_domain (
            .clk_pm_i                   (pm7_clk),
            .reset_pm_n_i               (~sys_reset),
            .home_chipid_i              (home_chipid_s),
            .host_chipid_i              (host_chipid_s),
            .noc_fifo_pm_in_data_i      (tile10_noc_fifo_in_data_s),
            .noc_fifo_pm_in_raddr_o     (tile10_noc_fifo_in_raddr_s),
            .noc_fifo_pm_in_waddr_i     (tile10_noc_fifo_in_waddr_s),
            .noc_fifo_pm_out_data_o     (tile10_noc_fifo_out_data_s),
            .noc_fifo_pm_out_raddr_i    (tile10_noc_fifo_out_raddr_s),
            .noc_fifo_pm_out_waddr_o    (tile10_noc_fifo_out_waddr_s),
            .jtag_tck_i                 (pm7_jtag_tck),
            .jtag_tms_i                 (pm7_jtag_tms),
            .jtag_tdi_i                 (pm7_jtag_tdi),
            .jtag_tdo_o                 (pm7_jtag_tdo),
            .jtag_tdo_en_o              (pm7_jtag_tdo_en),
            .uart_tx_o                  (pm_uart_tx[7]),
            .uart_rx_i                  (pm_uart_rx[7])
        );
    end
    endgenerate



endmodule
