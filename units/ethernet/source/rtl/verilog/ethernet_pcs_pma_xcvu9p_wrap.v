
module ethernet_pcs_pma_xcvu9p_wrap #(
    parameter SIMULATION = 0
)
(
    input  wire         rst_eth_n_i,
    
    //SGMII
    input  wire         sgmii_rxn,
	input  wire         sgmii_rxp,
	output wire         sgmii_txn,
	output wire         sgmii_txp,
    input  wire         sgmii_clk_n,
	input  wire         sgmii_clk_p,
	output wire         phy_rst_n,

    //GMII
    output wire         gmii_clk,
    output wire         gmii_rst,
    output wire         gmii_clk_en,
    input  wire   [7:0] gmii_txd,
    input  wire         gmii_tx_en,
    input  wire         gmii_tx_er,
    output wire   [7:0] gmii_rxd,
    output wire         gmii_rx_dv,
    output wire         gmii_rx_er,

    output wire  [15:0] eth_status_vector_o,
    input  wire  [31:0] eth_config_vector_i,
    output wire         eth_an_complete_o,
    output wire   [1:0] eth_pll_lock_o
);



wire [15:0] pcspma_status_vector;
assign eth_status_vector_o = pcspma_status_vector;

wire        pcspma_status_link_status          = pcspma_status_vector[0];
wire        pcspma_status_link_synchronization = pcspma_status_vector[1];
wire        pcspma_status_rudi_c               = pcspma_status_vector[2];
wire        pcspma_status_rudi_i               = pcspma_status_vector[3];
wire        pcspma_status_rudi_invalid         = pcspma_status_vector[4];
wire        pcspma_status_rxdisperr            = pcspma_status_vector[5];
wire        pcspma_status_rxnotintable         = pcspma_status_vector[6];
wire        pcspma_status_phy_link_status      = pcspma_status_vector[7];
wire  [1:0] pcspma_status_remote_fault_encdg   = pcspma_status_vector[9:8];
wire  [1:0] pcspma_status_speed                = pcspma_status_vector[11:10];
wire        pcspma_status_duplex               = pcspma_status_vector[12];
wire        pcspma_status_remote_fault         = pcspma_status_vector[13];
wire  [1:0] pcspma_status_pause                = pcspma_status_vector[15:14];

wire  [4:0] pcspma_config_vector = SIMULATION ? {1'b0, eth_config_vector_i[19:16]} : eth_config_vector_i[20:16];    //autonegotiation turned off in simulation
wire [15:0] pcspma_an_config_vector = eth_config_vector_i[15:0];
wire        pcspma_an_restart_config = eth_config_vector_i[21];
wire        pcspma_interrupt;

wire tx_locked, rx_locked;

assign eth_an_complete_o = pcspma_interrupt;
assign phy_rst_n = rst_eth_n_i;
assign eth_pll_lock_o = {tx_locked, rx_locked};



gig_ethernet_pcs_pma_xcvu9p i_gig_ethernet_pcs_pma_xcvu9p (
    // SGMII
    .txp_0                  (sgmii_txp),
    .txn_0                  (sgmii_txn),
    .rxp_0                  (sgmii_rxp),
    .rxn_0                  (sgmii_rxn),

    // Ref clock from PHY
    .refclk625_p            (sgmii_clk_p),
    .refclk625_n            (sgmii_clk_n),

    // async reset
    .reset                  (~rst_eth_n_i),

    // clock and reset outputs
    .clk125_out             (gmii_clk),
    .clk312_out             (),
    .rst_125_out            (gmii_rst),
    .tx_logic_reset         (),
    .rx_logic_reset         (),
    .tx_locked              (tx_locked),
    .rx_locked              (rx_locked),
    .tx_pll_clk_out         (),
    .rx_pll_clk_out         (),

    // MAC clocking
    .sgmii_clk_r_0          (),
    .sgmii_clk_f_0          (),
    .sgmii_clk_en_0         (gmii_clk_en),
    
    // Speed control
    .speed_is_10_100_0      (pcspma_status_speed != 2'b10),
    .speed_is_100_0         (pcspma_status_speed == 2'b01),

    // Internal GMII
    .gmii_txd_0             (gmii_txd),
    .gmii_tx_en_0           (gmii_tx_en),
    .gmii_tx_er_0           (gmii_tx_er),
    .gmii_rxd_0             (gmii_rxd),
    .gmii_rx_dv_0           (gmii_rx_dv),
    .gmii_rx_er_0           (gmii_rx_er),
    .gmii_isolate_0         (),

    // Configuration
    .configuration_vector_0 (pcspma_config_vector),

    .an_interrupt_0         (pcspma_interrupt),
    .an_adv_config_vector_0 (pcspma_an_config_vector),
    .an_restart_config_0    (pcspma_an_restart_config),

    // Status
    .status_vector_0        (pcspma_status_vector),
    .signal_detect_0        (1'b1),

    // Cascade
    .tx_bsc_rst_out         (),
    .rx_bsc_rst_out         (),
    .tx_bs_rst_out          (),
    .rx_bs_rst_out          (),
    .tx_rst_dly_out         (),
    .rx_rst_dly_out         (),
    .tx_bsc_en_vtc_out      (),
    .rx_bsc_en_vtc_out      (),
    .tx_bs_en_vtc_out       (),
    .rx_bs_en_vtc_out       (),
    .riu_clk_out            (),
    .riu_addr_out           (),
    .riu_wr_data_out        (),
    .riu_wr_en_out          (),
    .riu_nibble_sel_out     (),
    .riu_rddata_1           (16'b0),
    .riu_valid_1            (1'b0),
    .riu_prsnt_1            (1'b0),
    .riu_rddata_2           (16'b0),
    .riu_valid_2            (1'b0),
    .riu_prsnt_2            (1'b0),
    .riu_rddata_3           (16'b0),
    .riu_valid_3            (1'b0),
    .riu_prsnt_3            (1'b0),
    .rx_btval_1             (),
    .rx_btval_2             (),
    .rx_btval_3             (),
    .tx_dly_rdy_1           (1'b1),
    .rx_dly_rdy_1           (1'b1),
    .rx_vtc_rdy_1           (1'b1),
    .tx_vtc_rdy_1           (1'b1),
    .tx_dly_rdy_2           (1'b1),
    .rx_dly_rdy_2           (1'b1),
    .rx_vtc_rdy_2           (1'b1),
    .tx_vtc_rdy_2           (1'b1),
    .tx_dly_rdy_3           (1'b1),
    .rx_dly_rdy_3           (1'b1),
    .rx_vtc_rdy_3           (1'b1),
    .tx_vtc_rdy_3           (1'b1),
    .tx_rdclk_out           ()
);


endmodule
