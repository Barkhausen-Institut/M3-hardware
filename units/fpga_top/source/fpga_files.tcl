
source $REPO_DIR/util/source/util_files.tcl
source $REPO_DIR/ethernet/source/ethernet_files.tcl
if {[info exists USE_ETHERNET_FMC]} {
	source $REPO_DIR/ethernet_fmc/source/ethernet_fmc_files.tcl
}
source $REPO_DIR/mem/source/mem_files.tcl
source $REPO_DIR/rocket/source/rocket_files.tcl
source $REPO_DIR/boom/source/boom_files.tcl
source $REPO_DIR/tcu/source/tcu_files.tcl
source $REPO_DIR/acc_domain/source/acc_files.tcl
if {[info exists USE_DDR4_C1] || [info exists USE_DDR4_C2]} {
	source $REPO_DIR/ddr4/source/ddr4_files.tcl
}


lappend INCLUDE_DIRS $REPO_DIR/../global_src/verilog

lappend VERILOG_FILES $REPO_DIR/pm_domain/source/rtl/verilog/pm_domain.v

lappend VERILOG_FILES $REPO_DIR/jtag/source/rtl/verilog/jtag_tunnel_mc8.v

lappend VERILOG_FILES $REPO_DIR/fpga_clk_gen/source/rtl/verilog/fpga_clk_gen_125.v
lappend VERILOG_FILES $REPO_DIR/fpga_clk_gen/source/rtl/verilog/fpga_clk_gen_300.v

lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/flit_counter.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/flit_counter_wrap.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/inPortSelectBE.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/regFile1.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/tPortIn.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/tPortOut.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/tTrgPortCandidateCalc_OnOff_lut.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/router_module.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/router_OnOff_lut.v
lappend VERILOG_FILES $REPO_DIR/noc_router/source/rtl/verilog/router_top.v

lappend VERILOG_FILES $REPO_DIR/noc_network/source/rtl/systemverilog/router_wrap.sv
lappend VERILOG_FILES $REPO_DIR/noc_network/source/rtl/systemverilog/onchip_network.sv

lappend VERILOG_FILES $REPO_DIR/noc_domain/source/rtl/systemverilog/noc_domain.sv

lappend VERILOG_FILES $REPO_DIR/noc_arq/source/rtl/verilog/noc_arq_tx.v
lappend VERILOG_FILES $REPO_DIR/noc_arq/source/rtl/verilog/noc_arq_rx.v
lappend VERILOG_FILES $REPO_DIR/noc_arq/source/rtl/verilog/noc_arq_mux.v
lappend VERILOG_FILES $REPO_DIR/noc_arq/source/rtl/verilog/noc_arq_regfile.v
lappend VERILOG_FILES $REPO_DIR/noc_arq/source/rtl/verilog/noc_arq.v

lappend VERILOG_FILES $REPO_DIR/nocif/source/rtl/verilog/nocif.v
lappend VERILOG_FILES $REPO_DIR/nocif/source/rtl/verilog/nocif_slave.v

lappend VERILOG_FILES $REPO_DIR/noc_link/source/rtl/systemverilog/noc_link_if.sv
lappend VERILOG_FILES $REPO_DIR/noc_link_phy/source/rtl/verilog/noc_link_par_phy.v
lappend VERILOG_FILES $REPO_DIR/noc_link_phy/source/rtl/verilog/noc_link_par_async_phy.v
lappend VERILOG_FILES $REPO_DIR/noc_link_phy/source/rtl/systemverilog/noc_link_phy.sv


lappend VERILOG_FILES $REPO_DIR/async_fifo/source/rtl/verilog/async_fifo.v
lappend VERILOG_FILES $REPO_DIR/async_fifo/source/rtl/verilog/async_fifo_fifomem.v
lappend VERILOG_FILES $REPO_DIR/async_fifo/source/rtl/verilog/async_fifo_in.v
lappend VERILOG_FILES $REPO_DIR/async_fifo/source/rtl/verilog/async_fifo_out.v
lappend VERILOG_FILES $REPO_DIR/async_fifo/source/rtl/verilog/async_fifo_rptr_empty_ctrl.v
lappend VERILOG_FILES $REPO_DIR/async_fifo/source/rtl/verilog/async_fifo_wptr_full_ctrl.v
lappend VERILOG_FILES $REPO_DIR/sync_fifo/source/rtl/verilog/sync_fifo.v
lappend VERILOG_FILES $REPO_DIR/sync_fifo/source/rtl/verilog/sync_fifo_in.v
lappend VERILOG_FILES $REPO_DIR/sync_fifo/source/rtl/verilog/sync_fifo_out.v

lappend VERILOG_FILES $REPO_DIR/axi_bridge/source/rtl/verilog/axi4_mem_bridge.v
lappend VERILOG_FILES $REPO_DIR/axi_bridge/source/rtl/verilog/axi4_noc_bridge.v
lappend VERILOG_FILES $REPO_DIR/axi_bridge/source/rtl/verilog/mem_axi4_bridge.v

lappend VERILOG_FILES $REPO_DIR/fpga_top/source/rtl/systemverilog/fpga_top.sv

if {[info exists SIMULATION]} {
	lappend VERILOG_FILES $REPO_DIR/fpga_top/source/tb/systemverilog/tb_fpga_top.sv
}
