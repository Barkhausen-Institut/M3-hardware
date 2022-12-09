
set TC          [file tail [pwd]]
set TB          tb_fpga_top
set TOPLEVEL    fpga_top
set BOARD       xilinx.com:vcu118:part0:2.3
set PART        xcvu9p-flga2104-2L-e
set XILINX_PATH $env(XILINX_VIVADO)
set IP_DIR      $env(VIVADO_IP_DIR)
set REPO_DIR    $env(FPGA_DESIGN)/units
set SIM_DIR     $env(VIVADO_SIM_DIR)/$TB/$TC

#comment when DDR4 should be taken out of simulation
set USE_DDR4_C1 1
set USE_DDR4_C2 1

#comment when Ethernet FMC design should be taken out from simulation
#set USE_ETHERNET_FMC 1


#-----------------------------------------------------------------
#this is simulation
set SIMULATION 1

#verilog and vhdl files
set vlog_file $SIM_DIR/vlog.prj
set vhdl_file $SIM_DIR/vhdl.prj

#macros for Verilog files
set DEF_MACROS XILINX_FPGA
lappend DEF_MACROS SIMULATION
if {[info exists USE_DDR4_C1]} {
	lappend DEF_MACROS USE_DDR4_C1
}
if {[info exists USE_DDR4_C2]} {
	lappend DEF_MACROS USE_DDR4_C2
}
if {[info exists USE_DDR4_C1] || [info exists USE_DDR4_C2]} {
	lappend DEF_MACROS USE_DDR4
}
if {[info exists USE_ETHERNET_FMC]} {
	lappend DEF_MACROS USE_ETHERNET_FMC
}

#-----------------------------------------------------------------
#create project
create_project -name $SIM_DIR/vivado_proj/xsim -part $PART -force
set_property board_part $BOARD [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language verilog [current_project]
set_property MANAGED_IP true [current_project]

#turn off webtalk
config_webtalk -user off


#-----------------------------------------------------------------
#get source files
source $REPO_DIR/fpga_top/source/fpga_files.tcl

lappend VERILOG_FILES   $XILINX_PATH/data/verilog/src/glbl.v


#-----------------------------------------------------------------
#prepare compile command for verilog files
set     VERILOG_CMD     xvlog
lappend VERILOG_CMD     --incr
lappend VERILOG_CMD     --relax
lappend VERILOG_CMD     -prj $vlog_file
lappend VERILOG_CMD     -log logfiles/xvlog.log



#write verilog files to file
set vlog_fileId [open $vlog_file "w"]
puts $vlog_fileId "sv xil_defaultlib \\"
foreach def $DEF_MACROS {
    puts $vlog_fileId "-d \"$def\" \\"
}
foreach dir $INCLUDE_DIRS {
    puts $vlog_fileId "-i \"$dir\" \\"
}
foreach vfile $VERILOG_FILES {
    puts $vlog_fileId "\"$vfile\" \\" 
}
puts $vlog_fileId ""
puts $vlog_fileId "nosort"
close $vlog_fileId


#-----------------------------------------------------------------
#prepare compile command for vhdl files

if {[info exists VHDL_FILES]} {
	set     VHDL_CMD    xvhdl
	lappend VHDL_CMD    --incr
    lappend VHDL_CMD    --relax
    lappend VHDL_CMD    -prj $vhdl_file
    lappend VHDL_CMD    -log logfiles/xvhdl.log

    #write vhdl files to file
    set vhdl_fileId [open $vhdl_file "w"]
    puts $vhdl_fileId "vhdl xil_defaultlib \\"
    foreach vhdlfile $VHDL_FILES {
        puts $vhdl_fileId "\"$vhdlfile\" \\" 
    }
    puts $vhdl_fileId ""
    puts $vhdl_fileId "nosort"
    close $vhdl_fileId
}


#-----------------------------------------------------------------
#compile (print output of command on active console, too)
eval exec $VERILOG_CMD | tee /dev/tty

if {[info exists VHDL_FILES]} {
	eval exec $VHDL_CMD | tee /dev/tty
}


#-----------------------------------------------------------------
#elab

#set version of IPs and precompiled libs
if {[info exists SIMULATION]} {
    set vivado_versions  [list 2019.1 2019.2 2020.1 2020.2 2020.3 2021.1 2021.2 2021.2.1 2022.1 2022.2]
    set pcspma_versions  [list 16_1_6 16_1_7 16_2   16_2_1 16_2_3 16_2_4 16_2_6 16_2_7   16_2_8 16_2_9]
    set xlconst_versions [list 1_1_6  1_1_6  1_1_7  1_1_7  1_1_7  1_1_7  1_1_7  1_1_7    1_1_7  1_1_7]
    set temac_versions   [list 9_0_14 9_0_15 9_0_16 9_0_17 9_0_18 9_0_19 9_0_20 9_0_21   9_0_22 9_0_23]
    set utilvl_versions  [list 2_0_1  2_0_1  2_0_1  2_0_1  2_0_1  2_0_1  2_0_1  2_0_1    2_0_2  2_0_2]

    set pcspma_curr_version [lindex $pcspma_versions [lsearch $vivado_versions [version -short]]]
    set xlconst_curr_version [lindex $xlconst_versions [lsearch $vivado_versions [version -short]]]
    set temac_curr_version [lindex $temac_versions [lsearch $vivado_versions [version -short]]]
    set utilvl_curr_version [lindex $utilvl_versions [lsearch $vivado_versions [version -short]]]
}


set ELAB_CMD xelab
lappend ELAB_CMD --relax
lappend ELAB_CMD --incr
lappend ELAB_CMD --debug typical
lappend ELAB_CMD --mt 8
lappend ELAB_CMD -log logfiles/xelab.log

lappend ELAB_CMD -L xil_defaultlib
lappend ELAB_CMD -L xbip_utils_v3_0_10
lappend ELAB_CMD -L xbip_pipe_v3_0_6
lappend ELAB_CMD -L xbip_bram18k_v3_0_6
lappend ELAB_CMD -L mult_gen_v12_0_15
lappend ELAB_CMD -L axi_lite_ipif_v3_0_4
lappend ELAB_CMD -L gig_ethernet_pcs_pma_v$pcspma_curr_version
lappend ELAB_CMD -L xlconstant_v$xlconst_curr_version
lappend ELAB_CMD -L c_reg_fd_v12_0_6
lappend ELAB_CMD -L c_mux_bit_v12_0_6
lappend ELAB_CMD -L c_shift_ram_v12_0_13
lappend ELAB_CMD -L xbip_dsp48_wrapper_v3_0_4
lappend ELAB_CMD -L xbip_dsp48_addsub_v3_0_6
lappend ELAB_CMD -L xbip_addsub_v3_0_6
lappend ELAB_CMD -L c_addsub_v12_0_13
lappend ELAB_CMD -L c_gate_bit_v12_0_6
lappend ELAB_CMD -L xbip_counter_v3_0_6
lappend ELAB_CMD -L c_counter_binary_v12_0_13
lappend ELAB_CMD -L util_vector_logic_v$utilvl_curr_version
lappend ELAB_CMD -L unisims_ver
lappend ELAB_CMD -L unimacro_ver
lappend ELAB_CMD -L secureip
lappend ELAB_CMD -L xpm


if {[info exists USE_DDR4_C1] || [info exists USE_DDR4_C2] || [info exists USE_ETHERNET_FMC]} {
    lappend ELAB_CMD -L blk_mem_gen_v8_4_3
    lappend ELAB_CMD -L microblaze_v11_0_1
    lappend ELAB_CMD -L proc_sys_reset_v5_0_13
    lappend ELAB_CMD -L lmb_v10_v3_0_9
    lappend ELAB_CMD -L lmb_bram_if_cntlr_v4_0_16
    lappend ELAB_CMD -L iomodule_v3_1_4
    lappend ELAB_CMD -L lib_cdc_v1_0_2

    if {[info exists USE_ETHERNET_FMC]} {
        lappend ELAB_CMD -L tri_mode_ethernet_mac_v$temac_curr_version
        lappend ELAB_CMD -L smartconnect_v1_0
        lappend ELAB_CMD -L lib_pkg_v1_0_2
        lappend ELAB_CMD -L axi_ethernet_buffer_v2_0_20
        lappend ELAB_CMD -L lib_bmg_v1_0_12
    }
}

lappend ELAB_CMD --snapshot $TB xil_defaultlib.$TB xil_defaultlib.glbl

eval exec $ELAB_CMD | tee /dev/tty

quit

