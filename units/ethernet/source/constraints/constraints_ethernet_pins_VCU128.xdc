
######################################################################################
#  I/O standards
######################################################################################


set_property PACKAGE_PIN AV24       [get_ports "PHY1_SGMII_OUT_N"];
set_property IOSTANDARD  LVDS       [get_ports "PHY1_SGMII_OUT_N"];
set_property DIFF_TERM_ADV TERM_100 [get_ports "PHY1_SGMII_OUT_N"];
set_property PACKAGE_PIN AU24       [get_ports "PHY1_SGMII_OUT_P"];
set_property IOSTANDARD  LVDS       [get_ports "PHY1_SGMII_OUT_P"]
set_property DIFF_TERM_ADV TERM_100 [get_ports "PHY1_SGMII_OUT_P"];;
set_property PACKAGE_PIN AV21       [get_ports "PHY1_SGMII_IN_N"];
set_property IOSTANDARD  LVDS       [get_ports "PHY1_SGMII_IN_N"];
set_property PACKAGE_PIN AU21       [get_ports "PHY1_SGMII_IN_P"];
set_property IOSTANDARD  LVDS       [get_ports "PHY1_SGMII_IN_P"];

set_property PACKAGE_PIN AR23       [get_ports "PHY1_MDIO"];
set_property IOSTANDARD  LVCMOS18   [get_ports "PHY1_MDIO"];
set_property PACKAGE_PIN AV23       [get_ports "PHY1_MDC"];
set_property IOSTANDARD  LVCMOS18   [get_ports "PHY1_MDC"];

set_property PACKAGE_PIN AU22       [get_ports "PHY1_SGMII_CLK_N"];
set_property IOSTANDARD  LVDS       [get_ports "PHY1_SGMII_CLK_N"];
set_property DIFF_TERM_ADV TERM_100 [get_ports "PHY1_SGMII_CLK_N"];
set_property PACKAGE_PIN AT22       [get_ports "PHY1_SGMII_CLK_P"];
set_property IOSTANDARD  LVDS       [get_ports "PHY1_SGMII_CLK_P"];
set_property DIFF_TERM_ADV TERM_100 [get_ports "PHY1_SGMII_CLK_P"];

set_property PACKAGE_PIN BA21       [get_ports "PHY1_RESET_B"];
set_property IOSTANDARD  LVCMOS18   [get_ports "PHY1_RESET_B"];
set_property SLEW        SLOW       [get_ports "PHY1_RESET_B"];
set_property DRIVE       8          [get_ports "PHY1_RESET_B"];

