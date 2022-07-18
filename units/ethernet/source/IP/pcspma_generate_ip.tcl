
set IP_NAME    gig_ethernet_pcs_pma_xcvu9p
set IP_TYPE    xilinx.com:ip:gig_ethernet_pcs_pma:16.1
set BOARD      xilinx.com:vcu118:part0:2.3
set PART       xcvu9p-flga2104-2L-e


#skip generating IP if it already exists
if {[file exists $IP_DIR/$IP_NAME/$IP_NAME.xci]} {
    read_ip -verbose $IP_DIR/$IP_NAME/$IP_NAME.xci
    set ipi [get_ips $IP_NAME]
} else {
    puts "Generate Ethernet PCS-PMA IP"
    file mkdir $IP_DIR

    create_ip -vlnv $IP_TYPE -module_name $IP_NAME -dir $IP_DIR -force
    set ipi [get_ips $IP_NAME]

    set props {}
    lappend props CONFIG.Standard {SGMII}
    lappend props CONFIG.Physical_Interface {LVDS}
    lappend props CONFIG.Management_Interface {false}
    lappend props CONFIG.SupportLevel {Include_Shared_Logic_in_Core}
    lappend props CONFIG.LvdsRefClk {625}
    lappend props CONFIG.TxLane0_Placement {DIFF_PAIR_2}
    lappend props CONFIG.RxLane0_Placement {DIFF_PAIR_0}
    lappend props CONFIG.Tx_In_Upper_Nibble {0}
    lappend props PARAM_VALUE.DIFFCLK_BOARD_INTERFACE {sgmii_phyclk}
    lappend props PARAM_VALUE.ETHERNET_BOARD_INTERFACE {sgmii_lvds}

    set_property -dict $props $ipi
    generate_target all $ipi
}


#generate design check point for synthesis
if {[info exists SYNTHESIS] && ![file exists $IP_DIR/$IP_NAME/$IP_NAME.dcp]} {
    set_property generate_synth_checkpoint true [get_files $IP_DIR/$IP_NAME/$IP_NAME.xci]
    create_ip_run $ipi
    launch_runs [get_runs ${IP_NAME}_synth_1]
    wait_on_run [get_runs ${IP_NAME}_synth_1]
}


#add IP files for simulation
if {[info exists SIMULATION]} {
    foreach verfile [get_files -of_object $ipi -filter {FILE_TYPE == VERILOG && NAME !~ "*stub*" && NAME !~ "*netlist*"}] {
        lappend VERILOG_FILES $verfile
    }
    foreach vhdlfile [get_files -of_object $ipi -filter {FILE_TYPE == VHDL && NAME !~ "*stub*" && NAME !~ "*netlist*"}] {
        lappend VHDL_FILES $vhdlfile
    }
}

