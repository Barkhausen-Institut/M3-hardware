# These constraints are suitable for VCU118
# -----------------------------------------


set_property PACKAGE_PIN G54      [get_ports QSFP1_RX1_N];
set_property PACKAGE_PIN G53      [get_ports QSFP1_RX1_P];
set_property PACKAGE_PIN G49      [get_ports QSFP1_TX1_N];
set_property PACKAGE_PIN G48      [get_ports QSFP1_TX1_P];
set_property PACKAGE_PIN P43      [get_ports QSFP1_SI570_CLOCK_N];
set_property PACKAGE_PIN P42      [get_ports QSFP1_SI570_CLOCK_P];

#set_property IOSTANDARD LVDS      [get_ports QSFP1_SI570_CLOCK_P]
#set_property IOSTANDARD LVDS      [get_ports QSFP1_SI570_CLOCK_N]
#set_property PACKAGE_PIN T43      [get_ports "QSFP2_SI570_CLOCK_N"];
#set_property PACKAGE_PIN T42      [get_ports "QSFP2_SI570_CLOCK_P"];

#set_property PACKAGE_PIN BN25     [get_ports "QSFP1_RESETL_LS"];
#set_property IOSTANDARD  LVCMOS18 [get_ports "QSFP1_RESETL_LS"];

