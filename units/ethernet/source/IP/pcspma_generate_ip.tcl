
set IP_NAME    gig_ethernet_pcs_pma_xcvu9p
set IP_TYPE    xilinx.com:ip:gig_ethernet_pcs_pma:16.*
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

#set version of precompiled PCS/PMA lib
if {[info exists SIMULATION]} {
    set vivado_versions [list 2019.1 2019.2 2020.1 2020.2 2020.2.2 2020.3 2021.1 2021.1.1 2021.2 2021.2.1 2022.1]
    set pcspma_versions [list 16_1_6 16_1_7 16_2 16_2_1 16_2_2 16_2_3 16_2_4 16_2_5 16_2_6 16_2_7 16_2_8]
    set pcspma_curr_version [lindex $pcspma_versions [lsearch $vivado_versions [version -short]]]
}
