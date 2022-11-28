
# If there is more than one port of the FMC card used, only the MAC 
# in the first port must include shared logic while the others must not.
# The current setting in this file assumes that ports 0 to 3 are at
# PM0 to PM3 (or PM4 to PM7) with only PM0 (or PM4) including the MAC with shared logic.

set ethfmc_port0 PM0_ETHFMC.i_ethernet_fmc_domain/i_ethernet_fmc_wrap/AXI_ETH.i_bd_axi_dma_eth_fmc_wrapper/bd_axi_dma_eth_fmc_i/axi_ethernet_0
set ethfmc_port1 PM1_ETHFMC.i_ethernet_fmc_domain/i_ethernet_fmc_wrap/AXI_ETH_NSL.i_bd_axi_dma_eth_fmc_nsl_wrapper/bd_axi_dma_eth_fmc_nsl_i/axi_ethernet_0
set ethfmc_port2 PM2_ETHFMC.i_ethernet_fmc_domain/i_ethernet_fmc_wrap/AXI_ETH_NSL.i_bd_axi_dma_eth_fmc_nsl_wrapper/bd_axi_dma_eth_fmc_nsl_i/axi_ethernet_0
set ethfmc_port3 PM3_ETHFMC.i_ethernet_fmc_domain/i_ethernet_fmc_wrap/AXI_ETH_NSL.i_bd_axi_dma_eth_fmc_nsl_wrapper/bd_axi_dma_eth_fmc_nsl_i/axi_ethernet_0


# Demote the error created by the sub-optimal RXC clock assignment
# -------------------------------------------------------------------
# The VCU118 HPC FMC connector routes LA01_CC and LA18_CC to 
# non-clock capable pins, creating the following error:
#
# ERROR: Sub-optimal placement for a global clock-capable IO pin 
# and BUFG pair.If this sub optimal condition is acceptable for this 
# design, you may use the CLOCK_DEDICATED_ROUTE constraint in the 
# .xdc file to demote this message to a WARNING. However, the use 
# of this override is highly discouraged. These examples can be used 
# directly in the .xdc file to override this clock rule.

if {$ETHERNET_FMC_PORT_COUNT >= 2} {
    set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ${ethfmc_port1}/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]
}
if {$ETHERNET_FMC_PORT_COUNT == 4} {
    set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ${ethfmc_port3}/inst/mac/inst/rgmii_interface/rgmii_rxc_ibuf_i/O]
}


# Rule violation (PDRC-203) BITSLICE0 not available during BISC - 
# The port mdio_io_port_3_mdio_io is assigned to a PACKAGE_PIN that 
# uses BITSLICE_1 of a Byte that will be using calibration. The 
# signal connected to mdio_io_port_3_mdio_io will not be available 
# during calibration and will only be available after RDY asserts. 
# If this condition is not acceptable for your design and board 
# layout, mdio_io_port_3_mdio_io will have to be moved to another 
# PACKAGE_PIN that is not undergoing calibration or be moved to a 
# PACKAGE_PIN location that is not BITSLICE_0 or BITSLICE_6 on 
# that same Byte. If this condition is acceptable for your design 
# and board layout, this DRC can be bypassed by acknowledging the 
# condition and setting the following XDC constraint: 

if {$ETHERNET_FMC_PORT_COUNT >= 2} {
    set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports ETH_FMC_PHY2_RGMII_RXC]
}
if {$ETHERNET_FMC_PORT_COUNT == 4} {
    set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports ETH_FMC_PHY4_MDIO]
    set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports ETH_FMC_PHY4_RGMII_RXC]
}




# The following constraints help timing closure on ports 1 and 3

if {$ETHERNET_FMC_PORT_COUNT >= 2} {
    set_property CLOCK_REGION X4Y7 [get_cells ${ethfmc_port1}/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
}
if {$ETHERNET_FMC_PORT_COUNT == 4} {
    set_property CLOCK_REGION X4Y8 [get_cells ${ethfmc_port3}/inst/mac/inst/rgmii_interface/bufg_rgmii_rx_clk_iddr]
}

if {$ETHERNET_FMC_PORT_COUNT >= 2} {
    set_property DELAY_VALUE 1100 [get_cells ${ethfmc_port1}/inst/mac/inst/rgmii_interface/rxdata_bus[*].delay_rgmii_rxd]
    set_property DELAY_VALUE 1100 [get_cells ${ethfmc_port1}/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
}
if {$ETHERNET_FMC_PORT_COUNT == 4} {
    set_property DELAY_VALUE 1100 [get_cells ${ethfmc_port3}/inst/mac/inst/rgmii_interface/rxdata_bus[*].delay_rgmii_rxd]
    set_property DELAY_VALUE 1100 [get_cells ${ethfmc_port3}/inst/mac/inst/rgmii_interface/delay_rgmii_rx_ctl]
}


# For timing closure on port 2

if {$ETHERNET_FMC_PORT_COUNT >= 3} {
    set_property DELAY_VALUE 1000 [get_cells ${ethfmc_port2}/inst/mac/inst/rgmii_interface/delay_rgmii_tx_clk]
}



set phy1_rgmii_rx_clk_int ${ethfmc_port0}/inst/mac/inst_rgmii_rx_clk
set phy2_rgmii_rx_clk_int ${ethfmc_port1}/inst/mac/inst_rgmii_rx_clk
set phy3_rgmii_rx_clk_int ${ethfmc_port2}/inst/mac/inst_rgmii_rx_clk
set phy4_rgmii_rx_clk_int ${ethfmc_port3}/inst/mac/inst_rgmii_rx_clk

# Use these constraints to modify input delay on RGMII signals
set_input_delay -clock [get_clocks $phy1_rgmii_rx_clk_int] -max -1.4 [get_ports {ETH_FMC_PHY1_RGMII_RD[*] ETH_FMC_PHY1_RGMII_RX_CTL}]
set_input_delay -clock [get_clocks $phy1_rgmii_rx_clk_int] -min -2.8 [get_ports {ETH_FMC_PHY1_RGMII_RD[*] ETH_FMC_PHY1_RGMII_RX_CTL}]
set_input_delay -clock [get_clocks $phy1_rgmii_rx_clk_int] -clock_fall -max -1.4 -add_delay [get_ports {ETH_FMC_PHY1_RGMII_RD[*] ETH_FMC_PHY1_RGMII_RX_CTL}]
set_input_delay -clock [get_clocks $phy1_rgmii_rx_clk_int] -clock_fall -min -2.8 -add_delay [get_ports {ETH_FMC_PHY1_RGMII_RD[*] ETH_FMC_PHY1_RGMII_RX_CTL}]

if {$ETHERNET_FMC_PORT_COUNT >= 2} {
    set_input_delay -clock [get_clocks $phy2_rgmii_rx_clk_int] -max -1.4 [get_ports {ETH_FMC_PHY2_RGMII_RD[*] ETH_FMC_PHY2_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy2_rgmii_rx_clk_int] -min -2.8 [get_ports {ETH_FMC_PHY2_RGMII_RD[*] ETH_FMC_PHY2_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy2_rgmii_rx_clk_int] -clock_fall -max -1.4 -add_delay [get_ports {ETH_FMC_PHY2_RGMII_RD[*] ETH_FMC_PHY2_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy2_rgmii_rx_clk_int] -clock_fall -min -2.8 -add_delay [get_ports {ETH_FMC_PHY2_RGMII_RD[*] ETH_FMC_PHY2_RGMII_RX_CTL}]
}

if {$ETHERNET_FMC_PORT_COUNT >= 3} {
    set_input_delay -clock [get_clocks $phy3_rgmii_rx_clk_int] -max -1.4 [get_ports {ETH_FMC_PHY3_RGMII_RD[*] ETH_FMC_PHY3_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy3_rgmii_rx_clk_int] -min -2.8 [get_ports {ETH_FMC_PHY3_RGMII_RD[*] ETH_FMC_PHY3_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy3_rgmii_rx_clk_int] -clock_fall -max -1.4 -add_delay [get_ports {ETH_FMC_PHY3_RGMII_RD[*] ETH_FMC_PHY3_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy3_rgmii_rx_clk_int] -clock_fall -min -2.8 -add_delay [get_ports {ETH_FMC_PHY3_RGMII_RD[*] ETH_FMC_PHY3_RGMII_RX_CTL}]
}

if {$ETHERNET_FMC_PORT_COUNT == 4} {
    set_input_delay -clock [get_clocks $phy4_rgmii_rx_clk_int] -max -1.4 [get_ports {ETH_FMC_PHY4_RGMII_RD[*] ETH_FMC_PHY4_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy4_rgmii_rx_clk_int] -min -2.8 [get_ports {ETH_FMC_PHY4_RGMII_RD[*] ETH_FMC_PHY4_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy4_rgmii_rx_clk_int] -clock_fall -max -1.4 -add_delay [get_ports {ETH_FMC_PHY4_RGMII_RD[*] ETH_FMC_PHY4_RGMII_RX_CTL}]
    set_input_delay -clock [get_clocks $phy4_rgmii_rx_clk_int] -clock_fall -min -2.8 -add_delay [get_ports {ETH_FMC_PHY4_RGMII_RD[*] ETH_FMC_PHY4_RGMII_RX_CTL}]
}
