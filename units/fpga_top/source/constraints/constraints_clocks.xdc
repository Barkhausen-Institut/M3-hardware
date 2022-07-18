# #####################################################################################
#  define clocks / syncs
# #####################################################################################

#sys_clk for MMCME
create_clock -name sys_clk1_300_p -period 3.333 [get_ports "SYSCLK1_300_P"]

#125 MHz clock
create_clock -name clk_125_n -period 8 [get_ports "CLK_125MHZ_N"]

# JTAG Clock
create_clock -name TCK -period 50 -waveform {0 25} [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK]
create_clock -name TCK_cfg -period 50 -waveform {0 25} [get_pins i_jtag_tunnel/BSCANE2_config_inst/INTERNAL_TCK]


create_generated_clock -name eth_clk        [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT0]
create_generated_clock -name noc_clk        [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT1]
create_generated_clock -name ddr4_c1_clk    [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT2]
create_generated_clock -name ddr4_c2_clk    [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT3]
create_generated_clock -name pm0_clk        [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT4]
create_generated_clock -name pm1_clk        [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT5]
create_generated_clock -name pm2_clk        [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT6]
create_generated_clock -name pm3_clk        [get_pins i_fpga_clk_gen_125/mmcme4_adv_inst/CLKOUT0]
create_generated_clock -name pm4_clk        [get_pins i_fpga_clk_gen_125/mmcme4_adv_inst/CLKOUT1]
create_generated_clock -name pm5_clk        [get_pins i_fpga_clk_gen_125/mmcme4_adv_inst/CLKOUT2]
create_generated_clock -name pm6_clk        [get_pins i_fpga_clk_gen_125/mmcme4_adv_inst/CLKOUT3]
create_generated_clock -name pm7_clk        [get_pins i_fpga_clk_gen_125/mmcme4_adv_inst/CLKOUT4]

#asynchronous NoC
create_generated_clock -name noc_clk_r0 -source [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT1] -divide_by 1 [get_pins i_noc_domain/i_onchip_network/router_wrap_r0/clk_i]
create_generated_clock -name noc_clk_r1 -source [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT1] -divide_by 1 [get_pins i_noc_domain/i_onchip_network/router_wrap_r1/clk_i]
create_generated_clock -name noc_clk_r2 -source [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT1] -divide_by 1 [get_pins i_noc_domain/i_onchip_network/router_wrap_r2/clk_i]
create_generated_clock -name noc_clk_r3 -source [get_pins i_fpga_clk_gen_300/mmcme4_adv_inst/CLKOUT1] -divide_by 1 [get_pins i_noc_domain/i_onchip_network/router_wrap_r3/clk_i]

create_generated_clock -name GTCK_J0 -source [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/jtag_c0_tck_o]
create_generated_clock -name GTCK_J1 -source [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/jtag_c1_tck_o]
create_generated_clock -name GTCK_J2 -source [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/jtag_c2_tck_o]
create_generated_clock -name GTCK_J3 -source [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/jtag_c3_tck_o]
create_generated_clock -name GTCK_J4 -source [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/jtag_c4_tck_o]
create_generated_clock -name GTCK_J5 -source [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/jtag_c5_tck_o]
create_generated_clock -name GTCK_J6 -source [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/jtag_c6_tck_o]
create_generated_clock -name GTCK_J7 -source [get_pins i_jtag_tunnel/BSCANE2_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/jtag_c7_tck_o]
create_generated_clock -name DRCK_cfg -source [get_pins i_jtag_tunnel/BSCANE2_config_inst/INTERNAL_TCK] -divide_by 1 [get_pins i_jtag_tunnel/BSCANE2_config_inst/DRCK]

set_clock_groups -name r0_gr            -asynchronous -group [get_clocks noc_clk_r0]
set_clock_groups -name r1_gr            -asynchronous -group [get_clocks noc_clk_r1]
set_clock_groups -name r2_gr            -asynchronous -group [get_clocks noc_clk_r2]
set_clock_groups -name r3_gr            -asynchronous -group [get_clocks noc_clk_r3]

#asynchronous links to modules
set_clock_groups -name eth_gr           -asynchronous -group [get_clocks eth_clk]
set_clock_groups -name ddr4_c1_gr       -asynchronous -group [get_clocks ddr4_c1_clk]
set_clock_groups -name ddr4_c2_gr       -asynchronous -group [get_clocks ddr4_c2_clk]
set_clock_groups -name pm0_gr           -asynchronous -group [get_clocks pm0_clk]
set_clock_groups -name pm1_gr           -asynchronous -group [get_clocks pm1_clk]
set_clock_groups -name pm2_gr           -asynchronous -group [get_clocks pm2_clk]
set_clock_groups -name pm3_gr           -asynchronous -group [get_clocks pm3_clk]
set_clock_groups -name pm4_gr           -asynchronous -group [get_clocks pm4_clk]
set_clock_groups -name pm5_gr           -asynchronous -group [get_clocks pm5_clk]
set_clock_groups -name pm6_gr           -asynchronous -group [get_clocks pm6_clk]
set_clock_groups -name pm7_gr           -asynchronous -group [get_clocks pm7_clk]


# JTAG clocks
set_clock_groups -name DRCK_cfg_gr      -asynchronous -group [get_clocks DRCK_cfg]
set_clock_groups -name TCK_cfg_gr       -asynchronous -group [get_clocks TCK_cfg]
set_clock_groups -name TCK_gr           -asynchronous -group [get_clocks TCK]
set_clock_groups -name GTCK_J0_gr       -asynchronous -group [get_clocks GTCK_J0]
set_clock_groups -name GTCK_J1_gr       -asynchronous -group [get_clocks GTCK_J1]
set_clock_groups -name GTCK_J2_gr       -asynchronous -group [get_clocks GTCK_J2]
set_clock_groups -name GTCK_J3_gr       -asynchronous -group [get_clocks GTCK_J3]
set_clock_groups -name GTCK_J4_gr       -asynchronous -group [get_clocks GTCK_J4]
set_clock_groups -name GTCK_J5_gr       -asynchronous -group [get_clocks GTCK_J5]
set_clock_groups -name GTCK_J6_gr       -asynchronous -group [get_clocks GTCK_J6]
set_clock_groups -name GTCK_J7_gr       -asynchronous -group [get_clocks GTCK_J7]

