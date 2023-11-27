
module ethernet_fmc_domain #(
    `include "noc_parameter.vh"
    ,parameter ETH_INCLUDE_SHARED_LOGIC = 1,
    parameter PM_UART_ATTACHED          = 0,
    parameter HOME_MODID                = {NOC_MODID_SIZE{1'b0}},
    parameter CLKFREQ_MHZ               = 100
)
(
    input  wire                                  clk_axi_i,
    input  wire                                  reset_h_i,

    // NoC interface
    input  wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_in_data_i,
    output wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_raddr_o,
    input  wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_in_waddr_i,
    output wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_out_data_o,
    input  wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_raddr_i,
    output wire        [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_out_waddr_o,

    // physical interface
    input  wire                            [3:0] rgmii_rxd,
    input  wire                                  rgmii_rx_ctl,
    input  wire                                  rgmii_rxc,
    output wire                            [3:0] rgmii_txd,
    output wire                                  rgmii_tx_ctl,
    output wire                                  rgmii_txc,

    input  wire                                  gtx_clk_i,
    input  wire                                  ref_clk_i,

    //MDIO
    output wire                                  mdio_mdc_o,
    inout  wire                                  mdio_io,

    input  wire            [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input  wire            [NOC_CHIPID_SIZE-1:0] host_chipid_i,
    output wire                                  phy_reset_n,

    input  wire                                  jtag_tck_i,
    input  wire                                  jtag_tms_i,
    input  wire                                  jtag_tdi_i,
    output wire                                  jtag_tdo_o,
    output wire                                  jtag_tdo_en_o,

    output wire                                  uart_tx_o,
    input  wire                                  uart_rx_i
);


wire reset_sync_n_s;

wire [NOC_CHIPID_SIZE-1:0] home_chipid_s;
wire [NOC_CHIPID_SIZE-1:0] host_chipid_s;


ethernet_fmc_wrap #(
    .ETH_INCLUDE_SHARED_LOGIC   (ETH_INCLUDE_SHARED_LOGIC),
    .PM_UART_ATTACHED           (PM_UART_ATTACHED),
    .HOME_MODID                 (HOME_MODID),
    .CLKFREQ_MHZ                (CLKFREQ_MHZ)
) i_ethernet_fmc_wrap (
    .clk_axi_i                  (clk_axi_i),
    .reset_n_i                  (reset_sync_n_s),
    .home_chipid_i              (home_chipid_s),
    .host_chipid_i              (host_chipid_s),

    .noc_fifo_eth_in_data_i     (noc_fifo_in_data_i),
    .noc_fifo_eth_in_raddr_o    (noc_fifo_in_raddr_o),
    .noc_fifo_eth_in_waddr_i    (noc_fifo_in_waddr_i),
    .noc_fifo_eth_out_data_o    (noc_fifo_out_data_o),
    .noc_fifo_eth_out_raddr_i   (noc_fifo_out_raddr_i),
    .noc_fifo_eth_out_waddr_o   (noc_fifo_out_waddr_o),

    //RGMII
    .rgmii_rxd                  (rgmii_rxd),
    .rgmii_rx_ctl               (rgmii_rx_ctl),
    .rgmii_rxc                  (rgmii_rxc),
    .rgmii_txd                  (rgmii_txd),
    .rgmii_tx_ctl               (rgmii_tx_ctl),
    .rgmii_txc                  (rgmii_txc),

    .gtx_clk_i                  (gtx_clk_i),
    .ref_clk_i                  (ref_clk_i),

    //MDIO
    .mdio_mdc_o                 (mdio_mdc_o),
    .mdio_io                    (mdio_io),

    .phy_reset_n                (phy_reset_n),

    .jtag_tck_i                 (jtag_tck_i),
    .jtag_tms_i                 (jtag_tms_i),
    .jtag_tdi_i                 (jtag_tdi_i),
    .jtag_tdo_o                 (jtag_tdo_o),
    .jtag_tdo_en_o              (jtag_tdo_en_o),

    .uart_tx_o                  (uart_tx_o),
    .uart_rx_i                  (uart_rx_i)
);

util_reset_sync i_util_reset_sync_ref (
    .clk_i(clk_axi_i),
    .reset_q_i(~reset_h_i),
    .scan_mode_i(1'b0),
    .sync_reset_q_o(reset_sync_n_s)
);

util_sync #(
    .WIDTH(NOC_CHIPID_SIZE)
) i_util_sync_host_chipid (
    .clk_i(clk_axi_i),
    .reset_n_i(reset_sync_n_s),
    .data_i(host_chipid_i),
    .data_o(host_chipid_s)
);

util_sync #(
    .WIDTH(NOC_CHIPID_SIZE)
) i_util_sync_home_chipid (
    .clk_i(clk_axi_i),
    .reset_n_i(reset_sync_n_s),
    .data_i(home_chipid_i),
    .data_o(home_chipid_s)
);

endmodule
