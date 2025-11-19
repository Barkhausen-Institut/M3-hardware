
source $REPO_DIR/ddr4/source/IP/ddr4_generate_ip.tcl

lappend INCLUDE_DIRS $REPO_DIR/ddr4/source/rtl/verilog

lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_regfile.v
lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_app_sync.v
lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_mem_app_bridge.v
lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_wrap.v
lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_domain.v

if {[info exists SIMULATION]} {

    lappend INCLUDE_DIRS $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/map
    lappend INCLUDE_DIRS $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/ip_top
    lappend INCLUDE_DIRS $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal


    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_6/sim/bd_9915_lmb_bram_I_0.v
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_9/sim/bd_9915_second_lmb_bram_I_0.v
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/sim/bd_9915.v
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_0/sim/ddr4_xcvu37p_microblaze_mcs.v
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy_behav.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/iob/ddr4_phy_v2_2_iob_byte.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/iob/ddr4_phy_v2_2_iob.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/clocking/ddr4_phy_v2_2_pll.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_tristate_wrapper.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_riuor_wrapper.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_control_wrapper.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_byte_wrapper.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_bitslice_wrapper.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/phy/ddr4_xcvu37p_phy_ddr4.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/ip_1/rtl/ip_top/ddr4_xcvu37p_phy.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_wtr.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_ref.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_rd_wr.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_periodic.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_group.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_ecc_merge_enc.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_ecc_gen.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_ecc_fi_xor.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_ecc_dec_fix.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_ecc_buf.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_ecc.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_ctl.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_cmd_mux_c.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_cmd_mux_ap.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_arb_p.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_arb_mux_p.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_arb_c.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_arb_a.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_act_timer.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc_act_rank.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/controller/ddr4_v2_2_mc.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/ui/ddr4_v2_2_ui_wr_data.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/ui/ddr4_v2_2_ui_rd_data.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/ui/ddr4_v2_2_ui_cmd.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/ui/ddr4_v2_2_ui.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/clocking/ddr4_v2_2_infrastructure.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_xsdb_bram.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_write.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_wr_byte.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_wr_bit.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_sync.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_read.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_rd_en.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_pi.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_mc_odt.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_debug_microblaze.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_cplx_data.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_cplx.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_config_rom.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_addr_decode.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_top.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal_xsdb_arbiter.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_cal.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_chipscope_xsdb_slave.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_v2_2_dp_AB9.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/ip_top/ddr4_xcvu37p.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/ip_top/ddr4_xcvu37p_ddr4.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/ip_top/ddr4_xcvu37p_ddr4_mem_intfc.sv
    lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/rtl/cal/ddr4_xcvu37p_ddr4_cal_riu.sv
    #lappend VERILOG_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/tb/microblaze_mcs_0.sv

}



if {[info exists SIMULATION]} {
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_0/sim/bd_9915_microblaze_I_0.vhd
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_1/sim/bd_9915_rst_0_0.vhd
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_2/sim/bd_9915_ilmb_0.vhd
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_3/sim/bd_9915_dlmb_0.vhd
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_4/sim/bd_9915_dlmb_cntlr_0.vhd
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_5/sim/bd_9915_ilmb_cntlr_0.vhd
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_7/sim/bd_9915_second_dlmb_cntlr_0.vhd
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_8/sim/bd_9915_second_ilmb_cntlr_0.vhd
    lappend VHDL_FILES $REPO_DIR/../tmp/vivado_ip/ddr4_xcvu37p/bd_0/ip/ip_10/sim/bd_9915_iomodule_0_0.vhd


}
