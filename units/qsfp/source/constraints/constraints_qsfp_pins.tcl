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
#set_property DIFF_TERM TRUE [get_ports ETH_FMC_REF_CLK_P]
#set_property DIFF_TERM TRUE [get_ports ETH_FMC_REF_CLK_N]
#set_property IOSTANDARD LVDS [get_ports ETH_FMC_REF_CLK_P]
#set_property IOSTANDARD LVDS [get_ports ETH_FMC_REF_CLK_N]
#set_property PACKAGE_PIN BC9 [get_ports ETH_FMC_REF_CLK_P]
#set_property PACKAGE_PIN BC8 [get_ports ETH_FMC_REF_CLK_N]

#set_property IOSTANDARD LVCMOS18 [get_ports "QSFP1_RX1_N"];
#set_property IOSTANDARD LVCMOS18 [get_ports "QSFP1_RX1_P"];
#set_property IOSTANDARD LVCMOS18 [get_ports "QSFP1_TX1_N"];
#set_property IOSTANDARD LVCMOS18 [get_ports "QSFP1_TX1_P"];
#set_property IOSTANDARD LVCMOS18 [get_ports "QSFP1_SI570_CLOCK_N"];
#set_property IOSTANDARD LVCMOS18 [get_ports "QSFP1_SI570_CLOCK_P"];

set_property PACKAGE_PIN G54      [get_ports "QSFP1_RX1_N"];
set_property PACKAGE_PIN G53      [get_ports "QSFP1_RX1_P"];
set_property PACKAGE_PIN G49      [get_ports "QSFP1_TX1_N"];
set_property PACKAGE_PIN G48      [get_ports "QSFP1_TX1_P"];
set_property PACKAGE_PIN P43      [get_ports "QSFP1_SI570_CLOCK_N"];
set_property PACKAGE_PIN P42      [get_ports "QSFP1_SI570_CLOCK_P"];
set_property PACKAGE_PIN T43      [get_ports "QSFP2_SI570_CLOCK_N"];
set_property PACKAGE_PIN T42      [get_ports "QSFP2_SI570_CLOCK_P"];

#set_property PACKAGE_PIN BN25     [get_ports "QSFP1_RESETL_LS"];
#set_property IOSTANDARD  LVCMOS18 [get_ports "QSFP1_RESETL_LS"];

