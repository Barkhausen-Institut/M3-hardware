
set IP_NAME_C1 ddr4_c1_xcvu9p
set IP_NAME_C2 ddr4_c2_xcvu9p
set IP_TYPE    xilinx.com:ip:ddr4:2.2
set BOARD      xilinx.com:vcu118:part0:2.3
set PART       xcvu9p-flga2104-2L-e


#DDR4 component 1
if {[info exists USE_DDR4_C1]} {
    #skip generating IP if it already exists
    if {[file exists $IP_DIR/$IP_NAME_C1/$IP_NAME_C1.xci]} {
        read_ip -verbose $IP_DIR/$IP_NAME_C1/$IP_NAME_C1.xci
        set ipi_c1 [get_ips $IP_NAME_C1]
    } else {
        puts "Generate DDR4 IP C1"
        file mkdir $IP_DIR

        create_ip -vlnv $IP_TYPE -module_name $IP_NAME_C1 -dir $IP_DIR -force
        set ipi_c1 [get_ips $IP_NAME_C1]

        set props_c1 {}
        lappend props_c1 CONFIG.C0_CLOCK_BOARD_INTERFACE {Custom}
        lappend props_c1 CONFIG.C0_DDR4_BOARD_INTERFACE {Custom}
        lappend props_c1 CONFIG.C0.DDR4_TimePeriod {833}
        lappend props_c1 CONFIG.C0.DDR4_InputClockPeriod {4000}
        lappend props_c1 CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5}
        lappend props_c1 CONFIG.C0.DDR4_MemoryPart {MT40A256M16GE-083E}
        lappend props_c1 CONFIG.C0.DDR4_DataWidth {80}
        lappend props_c1 CONFIG.C0.DDR4_CasWriteLatency {12}
        lappend props_c1 CONFIG.C0.DDR4_AxiDataWidth {64}
        lappend props_c1 CONFIG.C0.DDR4_AxiAddressWidth {32}
        lappend props_c1 CONFIG.C0.DDR4_isCustom {false}
        lappend props_c1 CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {None}
        lappend props_c1 CONFIG.C0.BANK_GROUP_WIDTH {1}

        set_property -dict $props_c1 $ipi_c1
        generate_target all $ipi_c1
    }

    #generate design check point for synthesis
    if {[info exists SYNTHESIS] && ![file exists $IP_DIR/$IP_NAME_C1/$IP_NAME_C1.dcp]} {
        set_property generate_synth_checkpoint true [get_files $IP_DIR/$IP_NAME_C1/$IP_NAME_C1.xci]
        create_ip_run $ipi_c1
        launch_runs [get_runs ${IP_NAME_C1}_synth_1]
    }
}

#DDR4 component 2
if {[info exists USE_DDR4_C2]} {
    #skip generating IP if it already exists
    if {[file exists $IP_DIR/$IP_NAME_C2/$IP_NAME_C2.xci]} {
        read_ip -verbose $IP_DIR/$IP_NAME_C2/$IP_NAME_C2.xci
        set ipi_c2 [get_ips $IP_NAME_C2]
    } else {
        #DDR4 component 2
        puts "Generate DDR4 IP C2"
        file mkdir $IP_DIR

        create_ip -vlnv $IP_TYPE -module_name $IP_NAME_C2 -dir $IP_DIR -force
        set ipi_c2 [get_ips $IP_NAME_C2]

        set props_c2 {}
        lappend props_c2 CONFIG.C0_CLOCK_BOARD_INTERFACE {Custom}
        lappend props_c2 CONFIG.C0_DDR4_BOARD_INTERFACE {Custom}
        lappend props_c2 CONFIG.C0.DDR4_TimePeriod {833}
        lappend props_c2 CONFIG.C0.DDR4_InputClockPeriod {4000}
        lappend props_c2 CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5}
        lappend props_c2 CONFIG.C0.DDR4_MemoryPart {MT40A256M16GE-083E}
        lappend props_c2 CONFIG.C0.DDR4_DataWidth {80}
        lappend props_c2 CONFIG.C0.DDR4_CasWriteLatency {12}
        lappend props_c2 CONFIG.C0.DDR4_AxiDataWidth {64}
        lappend props_c2 CONFIG.C0.DDR4_AxiAddressWidth {32}
        lappend props_c2 CONFIG.C0.DDR4_isCustom {false}
        lappend props_c2 CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {None}
        lappend props_c2 CONFIG.C0.BANK_GROUP_WIDTH {1}

        set_property -dict $props_c2 $ipi_c2
        generate_target all $ipi_c2
    }

    #generate design check point for synthesis
    if {[info exists SYNTHESIS] && ![file exists $IP_DIR/$IP_NAME_C2/$IP_NAME_C2.dcp]} {
        set_property generate_synth_checkpoint true [get_files $IP_DIR/$IP_NAME_C2/$IP_NAME_C2.xci]
        create_ip_run $ipi_c2
        launch_runs [get_runs ${IP_NAME_C2}_synth_1]
    }
}

#wait on runs here to enable parallel processing
if {[info exists USE_DDR4_C1] && [info exists SYNTHESIS] && ![file exists $IP_DIR/$IP_NAME_C1/$IP_NAME_C1.dcp]} {
    wait_on_run [get_runs ${IP_NAME_C1}_synth_1]
}
if {[info exists USE_DDR4_C2] && [info exists SYNTHESIS] && ![file exists $IP_DIR/$IP_NAME_C2/$IP_NAME_C2.dcp]} {
    wait_on_run [get_runs ${IP_NAME_C2}_synth_1]
}
