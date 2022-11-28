
source $REPO_DIR/ethernet_fmc/source/IP/bd_axi4_mux_1to2.tcl
source $REPO_DIR/ethernet_fmc/source/IP/bd_axi4_mux_2to1.tcl
source $REPO_DIR/ethernet_fmc/source/IP/bd_axi_dma_eth_fmc.tcl
if {$ETHERNET_FMC_PORT_COUNT > 1} {
    source $REPO_DIR/ethernet_fmc/source/IP/bd_axi_dma_eth_fmc_nsl.tcl
}

#comment this line when Rocket instead of BOOM core should be used in Ethernet FMC
#set ETHFMC_USE_BOOM 1


lappend VERILOG_FILES $REPO_DIR/ethernet_fmc/source/rtl/verilog/ethernet_fmc_rocket_trace.v
lappend VERILOG_FILES $REPO_DIR/ethernet_fmc/source/rtl/verilog/ethernet_fmc_rocket_ctrl.v
lappend VERILOG_FILES $REPO_DIR/ethernet_fmc/source/rtl/verilog/ethernet_fmc_rocket_core.v
lappend VERILOG_FILES $REPO_DIR/ethernet_fmc/source/rtl/verilog/ethernet_fmc_clk_gen.v
lappend VERILOG_FILES $REPO_DIR/ethernet_fmc/source/rtl/verilog/ethernet_fmc_regfile.v
lappend VERILOG_FILES $REPO_DIR/ethernet_fmc/source/rtl/verilog/ethernet_fmc_wrap.v
lappend VERILOG_FILES $REPO_DIR/ethernet_fmc/source/rtl/verilog/ethernet_fmc_domain.v

if {[info exists ETHFMC_USE_BOOM]} {
    lappend DEF_MACROS "ETHFMC_USE_BOOM"
}

