# These constraints are suitable for VCU118
# -----------------------------------------
# These constraints are for the vcu118-axieth design which
# uses 4x AXI Ethernet Subsystem IPs

# Notes on VCU118 HPC1 connector
# ------------------------------
#
# Ethernet FMC Port 0:
# --------------------
# * Requires LA00_CC, LA02, LA03, LA04, LA05, LA06, LA07, LA08
# * All are routed to Bank 66
# * LA00_CC is routed to a clock capable pin
#
# Ethernet FMC Port 1:
# --------------------
# * Requires LA01_CC, LA06, LA09, LA10, LA11, LA12, LA13, LA14, LA15, LA16
# * All are routed to Bank 66
# * LA01_CC is NOT routed to a clock capable pin
#
# Ethernet FMC Port 2:
# --------------------
# * Requires LA17_CC, LA19, LA20, LA21, LA22, LA23, LA24, LA25
# * All are routed to Bank 67
# * LA17_CC is routed to a clock capable pin
#
# Ethernet FMC Port 3:
# --------------------
# * Requires LA18_CC, LA26, LA27, LA28, LA29, LA30, LA31, LA32
# * All are routed to Bank 67
# * LA18_CC is NOT routed to a clock capable pin
#

# Enable internal termination resistor on LVDS 125MHz ref_clk
set_property DIFF_TERM TRUE [get_ports ETH_FMC_REF_CLK_P]
set_property DIFF_TERM TRUE [get_ports ETH_FMC_REF_CLK_N]
set_property IOSTANDARD LVDS [get_ports ETH_FMC_REF_CLK_P]
set_property IOSTANDARD LVDS [get_ports ETH_FMC_REF_CLK_N]
set_property PACKAGE_PIN BC9 [get_ports ETH_FMC_REF_CLK_P]
set_property PACKAGE_PIN BC8 [get_ports ETH_FMC_REF_CLK_N]


# Define I/O standards
set_property IOSTANDARD LVCMOS18 [get_ports {ETH_FMC_PHY1_RGMII_RD[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY1_RGMII_RXC]
set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY1_RGMII_RX_CTL]
set_property IOSTANDARD LVCMOS18 [get_ports {ETH_FMC_PHY1_RGMII_TD[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY1_RGMII_TXC]
set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY1_RGMII_TX_CTL]
set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY1_RESET_N]
set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY1_MDIO]
set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY1_MDC]

if {$ETHERNET_FMC_PORT_COUNT >= 2} {
    set_property IOSTANDARD LVCMOS18 [get_ports {ETH_FMC_PHY2_RGMII_RD[*]}]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY2_RGMII_RXC]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY2_RGMII_RX_CTL]
    set_property IOSTANDARD LVCMOS18 [get_ports {ETH_FMC_PHY2_RGMII_TD[*]}]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY2_RGMII_TXC]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY2_RGMII_TX_CTL]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY2_RESET_N]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY2_MDIO]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY2_MDC]
}

if {$ETHERNET_FMC_PORT_COUNT >= 3} {
    set_property IOSTANDARD LVCMOS18 [get_ports {ETH_FMC_PHY3_RGMII_RD[*]}]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY3_RGMII_RXC]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY3_RGMII_RX_CTL]
    set_property IOSTANDARD LVCMOS18 [get_ports {ETH_FMC_PHY3_RGMII_TD[*]}]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY3_RGMII_TXC]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY3_RGMII_TX_CTL]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY3_RESET_N]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY3_MDIO]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY3_MDC]
}

if {$ETHERNET_FMC_PORT_COUNT == 4} {
    set_property IOSTANDARD LVCMOS18 [get_ports {ETH_FMC_PHY4_RGMII_RD[*]}]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY4_RGMII_RXC]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY4_RGMII_RX_CTL]
    set_property IOSTANDARD LVCMOS18 [get_ports {ETH_FMC_PHY4_RGMII_TD[*]}]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY4_RGMII_TXC]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY4_RGMII_TX_CTL]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY4_RESET_N]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY4_MDIO]
    set_property IOSTANDARD LVCMOS18 [get_ports ETH_FMC_PHY4_MDC]
}



set_property PACKAGE_PIN BC11 [get_ports {ETH_FMC_PHY1_RGMII_RD[0]}]
set_property PACKAGE_PIN BD11 [get_ports {ETH_FMC_PHY1_RGMII_RD[1]}]
set_property PACKAGE_PIN BD12 [get_ports {ETH_FMC_PHY1_RGMII_RD[2]}]
set_property PACKAGE_PIN BE12 [get_ports {ETH_FMC_PHY1_RGMII_RD[3]}]
set_property PACKAGE_PIN AY9  [get_ports ETH_FMC_PHY1_RGMII_RXC]
set_property PACKAGE_PIN BA9  [get_ports ETH_FMC_PHY1_RGMII_RX_CTL]
set_property PACKAGE_PIN BF12 [get_ports {ETH_FMC_PHY1_RGMII_TD[0]}]
set_property PACKAGE_PIN BE15 [get_ports {ETH_FMC_PHY1_RGMII_TD[1]}]
set_property PACKAGE_PIN BF15 [get_ports {ETH_FMC_PHY1_RGMII_TD[2]}]
set_property PACKAGE_PIN BC15 [get_ports {ETH_FMC_PHY1_RGMII_TD[3]}]
set_property PACKAGE_PIN BF11 [get_ports ETH_FMC_PHY1_RGMII_TXC]
set_property PACKAGE_PIN BD15 [get_ports ETH_FMC_PHY1_RGMII_TX_CTL]
set_property PACKAGE_PIN BF14 [get_ports ETH_FMC_PHY1_RESET_N]
set_property PACKAGE_PIN BE13 [get_ports ETH_FMC_PHY1_MDIO]
set_property PACKAGE_PIN BE14 [get_ports ETH_FMC_PHY1_MDC]

if {$ETHERNET_FMC_PORT_COUNT >= 2} {
    set_property PACKAGE_PIN BD13 [get_ports {ETH_FMC_PHY2_RGMII_RD[0]}]
    set_property PACKAGE_PIN BA14 [get_ports {ETH_FMC_PHY2_RGMII_RD[1]}]
    set_property PACKAGE_PIN BB12 [get_ports {ETH_FMC_PHY2_RGMII_RD[2]}]
    set_property PACKAGE_PIN BB14 [get_ports {ETH_FMC_PHY2_RGMII_RD[3]}]
    set_property PACKAGE_PIN BF10 [get_ports ETH_FMC_PHY2_RGMII_RXC]
    set_property PACKAGE_PIN BF9  [get_ports ETH_FMC_PHY2_RGMII_RX_CTL]
    set_property PACKAGE_PIN BC13 [get_ports {ETH_FMC_PHY2_RGMII_TD[0]}]
    set_property PACKAGE_PIN BA16 [get_ports {ETH_FMC_PHY2_RGMII_TD[1]}]
    set_property PACKAGE_PIN AV9  [get_ports {ETH_FMC_PHY2_RGMII_TD[2]}]
    set_property PACKAGE_PIN AV8  [get_ports {ETH_FMC_PHY2_RGMII_TD[3]}]
    set_property PACKAGE_PIN BA15 [get_ports ETH_FMC_PHY2_RGMII_TXC]
    set_property PACKAGE_PIN BB16 [get_ports ETH_FMC_PHY2_RGMII_TX_CTL]
    set_property PACKAGE_PIN BC16 [get_ports ETH_FMC_PHY2_RESET_N]
    set_property PACKAGE_PIN AW7  [get_ports ETH_FMC_PHY2_MDIO]
    set_property PACKAGE_PIN AY7  [get_ports ETH_FMC_PHY2_MDC]
}

if {$ETHERNET_FMC_PORT_COUNT >= 3} {
    set_property PACKAGE_PIN AY10 [get_ports {ETH_FMC_PHY3_RGMII_RD[0]}]
    set_property PACKAGE_PIN AW12 [get_ports {ETH_FMC_PHY3_RGMII_RD[1]}]
    set_property PACKAGE_PIN AN16 [get_ports {ETH_FMC_PHY3_RGMII_RD[2]}]
    set_property PACKAGE_PIN AP16 [get_ports {ETH_FMC_PHY3_RGMII_RD[3]}]
    set_property PACKAGE_PIN AR14 [get_ports ETH_FMC_PHY3_RGMII_RXC]
    set_property PACKAGE_PIN AW11 [get_ports ETH_FMC_PHY3_RGMII_RX_CTL]
    set_property PACKAGE_PIN AY12 [get_ports {ETH_FMC_PHY3_RGMII_TD[0]}]
    set_property PACKAGE_PIN AW13 [get_ports {ETH_FMC_PHY3_RGMII_TD[1]}]
    set_property PACKAGE_PIN AY13 [get_ports {ETH_FMC_PHY3_RGMII_TD[2]}]
    set_property PACKAGE_PIN AV11 [get_ports {ETH_FMC_PHY3_RGMII_TD[3]}]
    set_property PACKAGE_PIN AU11 [get_ports ETH_FMC_PHY3_RGMII_TXC]
    set_property PACKAGE_PIN AT12 [get_ports ETH_FMC_PHY3_RGMII_TX_CTL]
    set_property PACKAGE_PIN AR13 [get_ports ETH_FMC_PHY3_RESET_N]
    set_property PACKAGE_PIN AU12 [get_ports ETH_FMC_PHY3_MDIO]
    set_property PACKAGE_PIN AP13 [get_ports ETH_FMC_PHY3_MDC]
}

if {$ETHERNET_FMC_PORT_COUNT == 4} {
    set_property PACKAGE_PIN AK15 [get_ports {ETH_FMC_PHY4_RGMII_RD[0]}]
    set_property PACKAGE_PIN AL14 [get_ports {ETH_FMC_PHY4_RGMII_RD[1]}]
    set_property PACKAGE_PIN AL15 [get_ports {ETH_FMC_PHY4_RGMII_RD[2]}]
    set_property PACKAGE_PIN AM14 [get_ports {ETH_FMC_PHY4_RGMII_RD[3]}]
    set_property PACKAGE_PIN AP12 [get_ports ETH_FMC_PHY4_RGMII_RXC]
    set_property PACKAGE_PIN AR12 [get_ports ETH_FMC_PHY4_RGMII_RX_CTL]
    set_property PACKAGE_PIN AP15 [get_ports {ETH_FMC_PHY4_RGMII_TD[0]}]
    set_property PACKAGE_PIN AV10 [get_ports {ETH_FMC_PHY4_RGMII_TD[1]}]
    set_property PACKAGE_PIN AM13 [get_ports {ETH_FMC_PHY4_RGMII_TD[2]}]
    set_property PACKAGE_PIN AM12 [get_ports {ETH_FMC_PHY4_RGMII_TD[3]}]
    set_property PACKAGE_PIN AW10 [get_ports ETH_FMC_PHY4_RGMII_TXC]
    set_property PACKAGE_PIN AK12 [get_ports ETH_FMC_PHY4_RGMII_TX_CTL]
    set_property PACKAGE_PIN AJ12 [get_ports ETH_FMC_PHY4_RESET_N]
    set_property PACKAGE_PIN AJ13 [get_ports ETH_FMC_PHY4_MDIO]
    set_property PACKAGE_PIN AL12 [get_ports ETH_FMC_PHY4_MDC]
}

