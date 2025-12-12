set IP_NAME    rld3_xcvu37p
set IP_TYPE    xilinx.com:ip:rld3:1.4
set BOARD      xilinx.com:vcu128:part0:1.0
set PART       xcvu37p-fsvh2892-2L-e


if {[info exists USE_RLD3_VCU128]} {
    #skip generating IP if it already exists
    if {[file exists $IP_DIR/$IP_NAME/$IP_NAME.xci]} {
        read_ip -verbose $IP_DIR/$IP_NAME/$IP_NAME.xci
        set ipi [get_ips $IP_NAME]
    } else {
        puts "Generate RLD3 IP"
        file mkdir $IP_DIR

        create_ip -vlnv $IP_TYPE -module_name $IP_NAME -dir $IP_DIR -force
        set ipi [get_ips $IP_NAME]

        set props_c2 {}
        lappend props_c2 CONFIG.C0.ControllerType {RLDRAM3}
        lappend props_c2 CONFIG.C0_CLOCK_BOARD_INTERFACE {Custom}
        lappend props_c2 CONFIG.C0.RLD3_TimePeriod {1071}
        lappend props_c2 CONFIG.C0.RLD3_InputClockPeriod {9996}
        lappend props_c2 CONFIG.C0.RLD3_Specify_MandD {false}
        lappend props_c2 CONFIG.C0.RLD3_CLKFBOUT_MULT {14}
        lappend props_c2 CONFIG.C0.RLD3_DIVCLK_DIVIDE {1}
        lappend props_c2 CONFIG.C0.RLD3_CLKOUT0_DIVIDE {6}
        lappend props_c2 CONFIG.C0.RLD3_PhyClockRatio {4:1}
        lappend props_c2 CONFIG.C0.RLD3_MemoryPart {MT44K32M36RB-107E}
        lappend props_c2 CONFIG.C0.RLD3_MemoryVoltage {1.2V}
        lappend props_c2 CONFIG.C0.RLD3_DataWidth {72}
        lappend props_c2 CONFIG.C0.RLD3_BurstLength {4}
        lappend props_c2 CONFIG.C0.RLD3_AddressMux {Non_Multiplexed}
        lappend props_c2 CONFIG.C0.RLD3_ReadLatency {15}

        set_property -dict $props_c2 $ipi
        generate_target all $ipi
    }

    #generate design check point for synthesis
    if {[info exists SYNTHESIS] && ![file exists $IP_DIR/$IP_NAME/$IP_NAME.dcp]} {
        set_property generate_synth_checkpoint true [get_files $IP_DIR/$IP_NAME/$IP_NAME.xci]
        create_ip_run $ipi
        launch_runs [get_runs ${IP_NAME}_synth_1]
    }

    if {[info exists SYNTHESIS] && ![file exists $IP_DIR/$IP_NAME/$IP_NAME.dcp]} {
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
}

