
######################################################################################
#  I/O standards
######################################################################################

set_property PACKAGE_PIN BN27     [get_ports "ENET_MDC"] ;# Bank  67 VCCO - VCC1V8   - IO_T1U_N12_67
set_property IOSTANDARD  LVCMOS18 [get_ports "ENET_MDC"] ;# Bank  67 VCCO - VCC1V8   - IO_T1U_N12_67

set_property PACKAGE_PIN BG23     [get_ports "ENET_MDIO"] ;# Bank  67 VCCO - VCC1V8   - IO_T3U_N12_67
set_property IOSTANDARD  LVCMOS18 [get_ports "ENET_MDIO"] ;# Bank  67 VCCO - VCC1V8   - IO_T3U_N12_67

set_property PACKAGE_PIN BH22     [get_ports "ENET_SGMII_IN_N"] ;# Bank  67 VCCO - VCC1V8   - IO_L23N_T3U_N9_67
set_property IOSTANDARD  LVDS     [get_ports "ENET_SGMII_IN_N"] ;# Bank  67 VCCO - VCC1V8   - IO_L23N_T3U_N9_67
set_property PACKAGE_PIN BG22     [get_ports "ENET_SGMII_IN_P"] ;# Bank  67 VCCO - VCC1V8   - IO_L23P_T3U_N8_67
set_property IOSTANDARD  LVDS     [get_ports "ENET_SGMII_IN_P"] ;# Bank  67 VCCO - VCC1V8   - IO_L23P_T3U_N8_67

set_property PACKAGE_PIN BK21     [get_ports "ENET_SGMII_OUT_N"] ;# Bank  67 VCCO - VCC1V8   - IO_L21N_T3L_N5_AD8N_67
set_property IOSTANDARD  LVDS     [get_ports "ENET_SGMII_OUT_N"] ;# Bank  67 VCCO - VCC1V8   - IO_L21N_T3L_N5_AD8N_67
set_property PACKAGE_PIN BJ22     [get_ports "ENET_SGMII_OUT_P"] ;# Bank  67 VCCO - VCC1V8   - IO_L21P_T3L_N4_AD8P_67
set_property IOSTANDARD  LVDS     [get_ports "ENET_SGMII_OUT_P"] ;# Bank  67 VCCO - VCC1V8   - IO_L21P_T3L_N4_AD8P_67

set_property PACKAGE_PIN BJ27     [get_ports "ENET_SGMII_CLK_N"] ;# Bank  67 VCCO - VCC1V8   - IO_L12N_T1U_N11_GC_67
set_property IOSTANDARD  LVDS     [get_ports "ENET_SGMII_CLK_N"] ;# Bank  67 VCCO - VCC1V8   - IO_L12N_T1U_N11_GC_67
set_property PACKAGE_PIN BH27     [get_ports "ENET_SGMII_CLK_P"] ;# Bank  67 VCCO - VCC1V8   - IO_L12P_T1U_N10_GC_67
set_property IOSTANDARD  LVDS     [get_ports "ENET_SGMII_CLK_P"] ;# Bank  67 VCCO - VCC1V8   - IO_L12P_T1U_N10_GC_67
