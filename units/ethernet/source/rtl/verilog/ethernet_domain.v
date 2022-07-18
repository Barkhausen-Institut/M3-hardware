// ************************************************************************************************************
// this module wraps the udp-block, the fpgaIF and the NoCIF
// ************************************************************************************************************


module ethernet_domain #(
    `include "noc_parameter.vh"
    ,parameter HOST_IP        = {8'd192, 8'd168, 8'd42, 8'd25},
    parameter HOST_PORT       = 16'd1800,
    parameter FPGA_IP_BASE    = {8'd192, 8'd168, 8'd42, 8'd240},
    parameter FPGA_PORT       = 16'd1800,
    parameter FPGA_MAC_BASE   = 48'h080028_030405,
    parameter GATEWAY_IP_ADDR = {8'd192, 8'd168, 8'd42, 8'd1},
    parameter SUBNET_MASK     = {8'd255, 8'd255, 8'd255, 8'd0},
    parameter HOME_MODID      = {NOC_MODID_SIZE{1'b0}},
    parameter SIMULATION      = 0
)
(
    input  wire                                  clk_eth_i,
    input  wire                                  reset_eth_n_i,
    
    // NoC interface
    input  wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_in_data_i,
    output wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_raddr_o,
    input  wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_waddr_i,
    output wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_out_data_o,
    input  wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_raddr_i,
    output wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_waddr_o,
    
    // physical interface
    input  wire                                  sgmii_rxn,
    input  wire                                  sgmii_rxp,
    output wire                                  sgmii_txn,
    output wire                                  sgmii_txp,
    input  wire                                  sgmii_clk_n,
    input  wire                                  sgmii_clk_p,

    //MDIO
    output wire                                  mdio_mdc,
    input  wire                                  mdio_mdio_i,
    output wire                                  mdio_mdio_o,
    output wire                                  mdio_mdio_t,

    output wire                           [15:0] eth_status_vector_o,
    output wire                                  eth_system_reset_o,
    output wire	           [NOC_CHIPID_SIZE-1:0] home_chipid_o,
    output wire	           [NOC_CHIPID_SIZE-1:0] host_chipid_o,

    output wire                                  phy_reset_n,

    input  wire                            [3:0] gpio_dip_sw_i
);



wire        gmii_clk;
wire        gmii_rst;
wire        gmii_clk_en;
wire  [7:0] gmii_txd;
wire        gmii_tx_en;
wire        gmii_tx_er;
wire  [7:0] gmii_rxd;
wire        gmii_rx_dv;
wire        gmii_rx_er;


wire [31:0] fpga_ip_addr;
wire [47:0] fpga_mac_addr;

wire [15:0] eth_status_vector_s;
assign eth_status_vector_o = eth_status_vector_s;

wire [31:0] eth_config_vector_s;
wire        eth_an_complete_s;
wire  [1:0] eth_pll_lock_s;

wire reset_eth_sync_n_s;


util_reset_sync i_util_reset_sync_ref (
    .clk_i(clk_eth_i),
    .reset_q_i(reset_eth_n_i),
    .scan_mode_i(1'b0),
    .sync_reset_q_o(reset_eth_sync_n_s)
);


ethernet_fpga_config #(
    .FPGA_IP_BASE           (FPGA_IP_BASE),
    .FPGA_MAC_BASE          (FPGA_MAC_BASE)
) i_ethernet_fpga_config (
    .switches_i             (gpio_dip_sw_i),
    .fpga_ip_addr_o         (fpga_ip_addr),
    .fpga_mac_addr_o        (fpga_mac_addr),
    .home_chipid_o          (home_chipid_o)
);



ethernet_pcs_pma_xcvu9p_wrap #(
    .SIMULATION          (SIMULATION)
) i_ethernet_pcs_pma_xcvu9p_wrap (
    .rst_eth_n_i         (reset_eth_sync_n_s),

    //SGMII
    .sgmii_rxn           (sgmii_rxn),
	.sgmii_rxp           (sgmii_rxp),
	.sgmii_txn           (sgmii_txn),
	.sgmii_txp           (sgmii_txp),
    .sgmii_clk_n         (sgmii_clk_n),
	.sgmii_clk_p         (sgmii_clk_p),
	.phy_rst_n           (phy_reset_n),

    //GMII
    .gmii_clk            (gmii_clk),
    .gmii_rst            (gmii_rst),
    .gmii_clk_en         (gmii_clk_en),
    .gmii_txd            (gmii_txd),
    .gmii_tx_en          (gmii_tx_en),
    .gmii_tx_er          (gmii_tx_er),
    .gmii_rxd            (gmii_rxd),
    .gmii_rx_dv          (gmii_rx_dv),
    .gmii_rx_er          (gmii_rx_er),

    .eth_status_vector_o (eth_status_vector_s),
    .eth_config_vector_i (eth_config_vector_s),
    .eth_an_complete_o   (eth_an_complete_s),
    .eth_pll_lock_o      (eth_pll_lock_s)
);


ethernet_mdio_wrap #(
    .SIMULATION         (SIMULATION)
) i_ethernet_mdio_wrap (
    .clk_eth_i          (clk_eth_i),
    .rst_eth_n_i        (reset_eth_sync_n_s),
    .mdio_mdc           (mdio_mdc),
    .mdio_mdio_i        (mdio_mdio_i),
    .mdio_mdio_o        (mdio_mdio_o),
    .mdio_mdio_t        (mdio_mdio_t)
);


ethernet_wrap #(
    .HOST_IP                (HOST_IP),
    .HOST_PORT              (HOST_PORT),
    .FPGA_IP_BASE           (FPGA_IP_BASE),
    .FPGA_PORT              (FPGA_PORT),
    .GATEWAY_IP_ADDR        (GATEWAY_IP_ADDR),
    .SUBNET_MASK            (SUBNET_MASK),
    .HOME_MODID             (HOME_MODID)
) i_ethernet_wrap (
    .clk_eth_i              (clk_eth_i),
    .rst_eth_n_i            (reset_eth_sync_n_s),

    .noc_fifo_in_data_i     (noc_fifo_in_data_i),
    .noc_fifo_in_raddr_o    (noc_fifo_in_raddr_o),
    .noc_fifo_in_waddr_i    (noc_fifo_in_waddr_i),
    .noc_fifo_out_data_o    (noc_fifo_out_data_o),
    .noc_fifo_out_raddr_i   (noc_fifo_out_raddr_i),
    .noc_fifo_out_waddr_o   (noc_fifo_out_waddr_o),

    //GMII
    .gmii_clk               (gmii_clk),
    .gmii_rst               (gmii_rst),
    .gmii_clk_en            (gmii_clk_en),
    .gmii_txd               (gmii_txd),
    .gmii_tx_en             (gmii_tx_en),
    .gmii_tx_er             (gmii_tx_er),
    .gmii_rxd               (gmii_rxd),
    .gmii_rx_dv             (gmii_rx_dv),
    .gmii_rx_er             (gmii_rx_er),

    .eth_status_vector_i    (eth_status_vector_s),
    .eth_config_vector_o    (eth_config_vector_s),
    .eth_an_complete_i      (eth_an_complete_s),
    .eth_pll_lock_i         (eth_pll_lock_s),
    .eth_system_reset_o     (eth_system_reset_o),
    .fpga_ip_addr_i         (fpga_ip_addr),
    .fpga_mac_addr_i        (fpga_mac_addr),
    .home_chipid_i          (home_chipid_o),
    .host_chipid_o          (host_chipid_o)
);



endmodule
