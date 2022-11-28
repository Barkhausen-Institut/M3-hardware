
#ref_clk from FMC card
create_clock -name ETH_FMC_REF_CLK_P -period 8 [get_ports "ETH_FMC_REF_CLK_P"]

create_generated_clock -name eth_fmc_ref_clk  [get_pins i_ethernet_fmc_clk_gen/mmcme4_adv_inst/CLKOUT0]
create_generated_clock -name eth_fmc_gtx_clk  [get_pins i_ethernet_fmc_clk_gen/mmcme4_adv_inst/CLKOUT1]

