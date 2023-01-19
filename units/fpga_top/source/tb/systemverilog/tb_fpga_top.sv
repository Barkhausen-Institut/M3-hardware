
`timescale 1ps/1ps

`ifdef XILINX_SIMULATOR
    module short(in1, in1);
        inout in1;
    endmodule
`endif


module tb_fpga_top #(
    `include "chip_ids.vh"
    ,`include "mod_ids.vh"
    ,`include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,parameter HOME_CHIPID = {NOC_CHIPID_SIZE{1'b0}}
)();



// *** Ethernet PHY ***
wire PHY1_RESET_B;

wire sgmii_txp_dut, sgmii_txn_dut;
wire sgmii_rxp_dut, sgmii_rxn_dut;
reg sgmii_clk_n;

wire PHY1_MDIO;
wire PHY1_MDC;

// clocks
reg axi_clk_n;
reg mgt_clk1_n, mgt_clk2_n, mgt_clk3_n;
reg clk_125mhz_n;

// system clock 300 MHz
reg sysclk1_n;

//300 MHz clock
reg user_clk_n;

wire [7:0] GPIO_LED;
wire [3:0] GPIO_DIP_SW = HOME_CHIPID[3:0];  //SW12 - determines chip-id

wire eth_link_status = GPIO_LED[1];

wire uart_tx;
wire uart_rx = 1'b1;

//to connect two DUTs via "off-chip" link
wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tb_noc_fifo_in_data_s;
wire        [NOC_ASYNC_FIFO_AWIDTH:0] tb_noc_fifo_in_raddr_s;
wire        [NOC_ASYNC_FIFO_AWIDTH:0] tb_noc_fifo_in_waddr_s;
wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tb_noc_fifo_out_data_s;
wire        [NOC_ASYNC_FIFO_AWIDTH:0] tb_noc_fifo_out_raddr_s;
wire        [NOC_ASYNC_FIFO_AWIDTH:0] tb_noc_fifo_out_waddr_s;


reg reset_l, reset_h;


localparam CLKPERIODE_100MHZ = 10000;
localparam CLKPERIODE_300MHZ = 3333;
localparam CLKPERIODE_125MHZ = 8000;
localparam CLKPERIODE_625MHZ = 1600;



fpga_top #(
    .SIMULATION_ETH             (1),
    .SIMULATION_DDR4            (1)
) u_dut (
    .SYSCLK1_300_N              (sysclk1_n),    //system clock 300 MHz
    .SYSCLK1_300_P              (~sysclk1_n),

    .CLK_125MHZ_N               (clk_125mhz_n), //system clock 125 MHz
    .CLK_125MHZ_P               (~clk_125mhz_n),


    // *** Ethernet PHY ***
    .PHY1_RESET_B               (PHY1_RESET_B),

    .PHY1_SGMII_OUT_N           (sgmii_rxn_dut),
    .PHY1_SGMII_OUT_P           (sgmii_rxp_dut),
    .PHY1_SGMII_IN_N            (sgmii_txn_dut),
    .PHY1_SGMII_IN_P            (sgmii_txp_dut),
    .PHY1_SGMII_CLK_N           (sgmii_clk_n),
    .PHY1_SGMII_CLK_P           (~sgmii_clk_n),

    .PHY1_MDIO                  (PHY1_MDIO),
    .PHY1_MDC                   (PHY1_MDC),


    // *** Ethernet FMC PHYs ***
`ifdef USE_ETHERNET_FMC
    .ETH_FMC_REF_CLK_N          (clk_125mhz_n),
    .ETH_FMC_REF_CLK_P          (~clk_125mhz_n),

    .ETH_FMC_PHY1_RGMII_RD      (4'h0),
    .ETH_FMC_PHY1_RGMII_RX_CTL  (1'b0),
    .ETH_FMC_PHY1_RGMII_RXC     (clk_125mhz_n), //125 MHz at 1 Gbit/s
    .ETH_FMC_PHY1_RGMII_TD      (),
    .ETH_FMC_PHY1_RGMII_TX_CTL  (),
    .ETH_FMC_PHY1_RGMII_TXC     (),
    .ETH_FMC_PHY1_RESET_N       (),
    .ETH_FMC_PHY1_MDIO          (),
    .ETH_FMC_PHY1_MDC           (),
`endif

    // *** Switches ***
    .GPIO_DIP_SW                (GPIO_DIP_SW),   //SW12
    .GPIO_SW_N                  (1'b0),          //user pushbuttons
    .GPIO_SW_W                  (1'b0),
    .GPIO_SW_S                  (1'b0),
    .GPIO_SW_E                  (1'b0),
    .GPIO_SW_C                  (1'b0),
    .CPU_RESET                  (reset_h),


    // *** LEDs ***
    .GPIO_LED                   (GPIO_LED),

    // *** UART ***
    .UART_TX                    (uart_tx),
    .UART_RX                    (uart_rx)

`ifdef USE_DDR4_C1
    ,.DDR4_C1_250MHZ_CLK_N      (1'b0),
    .DDR4_C1_250MHZ_CLK_P       (1'b1),
    .DDR4_C1_ACT_B              (),
    .DDR4_C1_ADDR               (),
    .DDR4_C1_BA                 (),
    .DDR4_C1_BG                 (),
    .DDR4_C1_CKE                (),
    .DDR4_C1_ODT                (),
    .DDR4_C1_CS_B               (),
    .DDR4_C1_CK_T               (),
    .DDR4_C1_CK_C               (),
    .DDR4_C1_RESET_B            (),
    .DDR4_C1_DM                 (),
    .DDR4_C1_DQ                 (),
    .DDR4_C1_DQS_T              (),
    .DDR4_C1_DQS_C              ()
`endif

`ifdef USE_DDR4_C2
    ,.DDR4_C2_250MHZ_CLK_N      (1'b0),
    .DDR4_C2_250MHZ_CLK_P       (1'b1),
    .DDR4_C2_ACT_B              (),
    .DDR4_C2_ADDR               (),
    .DDR4_C2_BA                 (),
    .DDR4_C2_BG                 (),
    .DDR4_C2_CKE                (),
    .DDR4_C2_ODT                (),
    .DDR4_C2_CS_B               (),
    .DDR4_C2_CK_T               (),
    .DDR4_C2_CK_C               (),
    .DDR4_C2_RESET_B            (),
    .DDR4_C2_DM                 (),
    .DDR4_C2_DQ                 (),
    .DDR4_C2_DQS_T              (),
    .DDR4_C2_DQS_C              ()
`endif

    ,.tb_noc_fifo_in_data_o     (tb_noc_fifo_in_data_s),
    .tb_noc_fifo_in_raddr_i     (tb_noc_fifo_in_raddr_s),
    .tb_noc_fifo_in_waddr_o     (tb_noc_fifo_in_waddr_s),
    .tb_noc_fifo_out_data_i     (tb_noc_fifo_out_data_s),
    .tb_noc_fifo_out_raddr_o    (tb_noc_fifo_out_raddr_s),
    .tb_noc_fifo_out_waddr_i    (tb_noc_fifo_out_waddr_s)
);


assign tb_noc_fifo_in_raddr_s = {(NOC_ASYNC_FIFO_AWIDTH+1){1'b0}};
assign tb_noc_fifo_out_data_s = {NOC_ASYNC_FIFO_PACKET_SIZE{1'b0}};
assign tb_noc_fifo_out_waddr_s = {(NOC_ASYNC_FIFO_AWIDTH+1){1'b0}};



//----------------------------------------------------------------------------
// Clock and reset drivers
//----------------------------------------------------------------------------

initial sgmii_clk_n = 1'b0;
initial sysclk1_n = 1'b0;
initial user_clk_n = 1'b0;
initial axi_clk_n = 1'b0;
initial clk_125mhz_n = 1'b0;
initial mgt_clk1_n = 1'b0;
initial mgt_clk2_n = 1'b0;
initial mgt_clk3_n = 1'b0;

always #(CLKPERIODE_100MHZ/2.0) begin
    axi_clk_n = ~axi_clk_n;
end

always #(CLKPERIODE_125MHZ/2.0) begin
    clk_125mhz_n = ~clk_125mhz_n;
end

always #(CLKPERIODE_300MHZ/2.0) begin
    sysclk1_n = ~sysclk1_n;
end

always #(CLKPERIODE_300MHZ/2.0) begin
    user_clk_n = ~user_clk_n;
end

always #(CLKPERIODE_625MHZ/2.0) begin
    sgmii_clk_n = ~sgmii_clk_n;
end


initial begin
    reset_l = 1'b0;
    reset_h = 1'b1;
    #((40*CLKPERIODE_100MHZ) + (0.3*CLKPERIODE_100MHZ));    // 40,3 cycles
    reset_l = 1'b1;
    reset_h = 1'b0;
    #(1_500_000*CLKPERIODE_100MHZ);     // 1.5 mio cycles (15 ms)
    $stop;
end


//ethernet testbench
`include "tb_ethernet.v"


// Template for testcase specific pattern generation
// File has to be situated in simulation/vivado/[testcase] directory
`include "testcase.v"


endmodule
