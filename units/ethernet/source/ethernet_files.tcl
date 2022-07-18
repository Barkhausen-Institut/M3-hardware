
source $REPO_DIR/ethernet/source/IP/pcspma_generate_ip.tcl

if {[info exists SIMULATION]} {
    lappend INCLUDE_DIRS $REPO_DIR/ethernet/source/tb/verilog
    lappend VERILOG_FILES $REPO_DIR/ethernet/source/tb/verilog/axi_ethernet_xcvu9p_frame_typ.v
}


lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/example/VCU118/fpga_1g/rtl/mdio_master.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/eth_mac_1g_fifo.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/eth_mac_1g.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/axis_gmii_rx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/axis_gmii_tx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/lfsr.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/eth_axis_rx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/eth_axis_tx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/udp_complete.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/udp_checksum_gen.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/udp.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/udp_ip_rx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/udp_ip_tx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/ip_complete.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/ip.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/ip_eth_rx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/ip_eth_tx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/ip_arb_mux.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/arp.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/arp_cache.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/arp_eth_rx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/arp_eth_tx.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/rtl/eth_arb_mux.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/lib/axis/rtl/arbiter.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/lib/axis/rtl/priority_encoder.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/lib/axis/rtl/axis_fifo.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/lib/axis/rtl/axis_async_fifo.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/IP/verilog-ethernet/lib/axis/rtl/axis_async_fifo_adapter.v


lappend VERILOG_FILES $REPO_DIR/ethernet/source/rtl/verilog/udp_noc_bridge.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/rtl/verilog/ethernet_fpga_config.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/rtl/verilog/ethernet_udp_wrap.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/rtl/verilog/ethernet_regfile.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/rtl/verilog/ethernet_mdio_wrap.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/rtl/verilog/ethernet_pcs_pma_xcvu9p_wrap.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/rtl/verilog/ethernet_wrap.v
lappend VERILOG_FILES $REPO_DIR/ethernet/source/rtl/verilog/ethernet_domain.v



