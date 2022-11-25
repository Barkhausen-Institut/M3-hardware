
set TOPLEVEL        fpga_top
set BOARD           xilinx.com:vcu118:part0:2.3
set PART            xcvu9p-flga2104-2L-e
set IP_DIR          $env(VIVADO_IP_DIR)
set REPO_DIR        $env(FPGA_DESIGN)/units
set SYNTH_DIR       $env(VIVADO_SYNTH_DIR)

#comment when DDR4 should be taken out of synthesis
set USE_DDR4_C1 1
set USE_DDR4_C2 1

#comment when Ethernet FMC design should be taken out of synthesis
#set USE_ETHERNET_FMC 1
#set number of used ports in synthesis
set ETHERNET_FMC_PORT_COUNT 1


#--------------------------------------------------------------------------------
#map port count to individual variables
if {$ETHERNET_FMC_PORT_COUNT > 1} {
    set USE_ETHERNET_FMC_PHY2 1
    if {$ETHERNET_FMC_PORT_COUNT > 2} {
        set USE_ETHERNET_FMC_PHY3 1
        if {$ETHERNET_FMC_PORT_COUNT > 3} {
            set USE_ETHERNET_FMC_PHY4 1
        }
    }
}

#--------------------------------------------------------------------------------
#this is synthesis
set SYNTHESIS 1

#--------------------------------------------------------------------------------
#create project
create_project -name $SYNTH_DIR/vivado_proj/vivado -part $PART -force
set_property board_part $BOARD [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language verilog [current_project]
set_property MANAGED_IP true [current_project]
set_msg_config -id "Synth 8-3332" -limit 100000
set_msg_config -id "Synth 8-3331" -limit 100000
set_msg_config -id "Synth 8-6104" -limit 100000


#get source files
source $REPO_DIR/fpga_top/source/fpga_files.tcl

#--------------------------------------------------------------------------------

# compile files
foreach fname $VERILOG_FILES {
    read_verilog -library xil_defaultlib $fname
}

if {[info exists VHDL_FILES]} {
    foreach fname $VHDL_FILES {
        read_vhdl -library xil_defaultlib $fname
    }
}


#add constraints
add_files -fileset [current_fileset -constrset] $REPO_DIR/fpga_top/source/constraints/constraints_clocks.xdc
add_files -fileset [current_fileset -constrset] $REPO_DIR/fpga_top/source/constraints/constraints_pins.xdc
set_property USED_IN_SYNTHESIS false [get_files $REPO_DIR/fpga_top/source/constraints/constraints_pins.xdc]

add_files -fileset [current_fileset -constrset] $REPO_DIR/ethernet/source/constraints/constraints_ethernet_pins.xdc
add_files -fileset [current_fileset -constrset] $REPO_DIR/ethernet/source/IP/verilog-ethernet/syn/vivado/eth_mac_fifo.tcl
add_files -fileset [current_fileset -constrset] $REPO_DIR/ethernet/source/IP/verilog-ethernet/lib/axis/syn/vivado/axis_async_fifo.tcl
set_property USED_IN_SYNTHESIS false [get_files $REPO_DIR/ethernet/source/constraints/constraints_ethernet_pins.xdc]


add_files -fileset [current_fileset -constrset] $REPO_DIR/rocket/source/constraints/constraints_rocket.xdc
add_files -fileset [current_fileset -constrset] $REPO_DIR/boom/source/constraints/constraints_boom.xdc

if {[info exists USE_DDR4_C1] || [info exists USE_DDR4_C2]} {
    add_files -fileset [current_fileset -constrset] $REPO_DIR/ddr4/source/constraints/constraints_ddr4_pins.xdc
    set_property USED_IN_SYNTHESIS false [get_files $REPO_DIR/ddr4/source/constraints/constraints_ddr4_pins.xdc]
}

#--------------------------------------------------------------------------------

#do synthesis 
set     ARGS    synth_design
lappend ARGS	-top $TOPLEVEL
lappend ARGS    -keep_equivalent_registers
lappend ARGS    -part $PART
lappend ARGS    -verilog_define "XILINX_FPGA=1"
lappend ARGS    -verilog_define "SYNTHESIS=1"
if {[info exists USE_DDR4_C1]} {
    lappend ARGS    -verilog_define "USE_DDR4_C1=1"
}
if {[info exists USE_DDR4_C2]} {
    lappend ARGS    -verilog_define "USE_DDR4_C2=1"
}
if {[info exists USE_DDR4_C1] || [info exists USE_DDR4_C2]} {
    lappend ARGS    -verilog_define "USE_DDR4=1"
}
if {[info exists USE_ETHERNET_FMC]} {
    if {[info exists ETHFMC_USE_BOOM]} {
        lappend ARGS    -verilog_define "ETHFMC_USE_BOOM=1"
    }
    lappend ARGS    -verilog_define "USE_ETHERNET_FMC=1"
    if {[info exists USE_ETHERNET_FMC_PHY2]} {
        lappend ARGS    -verilog_define "USE_ETHERNET_FMC_PHY2=1"
    }
    if {[info exists USE_ETHERNET_FMC_PHY3]} {
        lappend ARGS    -verilog_define "USE_ETHERNET_FMC_PHY3=1"
    }
    if {[info exists USE_ETHERNET_FMC_PHY4]} {
        lappend ARGS    -verilog_define "USE_ETHERNET_FMC_PHY4=1"
    }
}
lappend ARGS    -flatten_hierarchy none
foreach pname $INCLUDE_DIRS {
    lappend ARGS    -include_dirs $pname
}

eval $ARGS

write_checkpoint -force results/synth.dcp

report_utilization -file reports/synth_utilization.rpt
report_utilization -hierarchical -file reports/synth_utilization_hier.rpt

write_verilog -force results/fpga_top.v

