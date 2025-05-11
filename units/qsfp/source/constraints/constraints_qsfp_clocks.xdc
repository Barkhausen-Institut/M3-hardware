
#ref_clk from FMC card
#create_clock -name QSFP2_SI570_CLOCK_P -period 8 [get_ports "QSFP2_SI570_CLOCK_P"]

#create_generated_clock -name qsfp_ref_clk  [get_pins i_qsfp_clk_gen/mmcme4_adv_inst/CLKOUT0]
#create_generated_clock -name eth_fmc_gtx_clk  [get_pins i_ethernet_fmc_clk_gen/mmcme4_adv_inst/CLKOUT1]

