set BD_NAME bd_axi4_mux_1to2
set BOARD   xilinx.com:vcu118:part0:2.3
set PART    xcvu9p-flga2104-2L-e


################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
    puts ""
    catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}
    return 1
}

################################################################
# START
################################################################

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
    create_project project_1 myproj -part $PART
    set_property BOARD_PART $BOARD [current_project]
}


create_bd_design -dir $IP_DIR $BD_NAME
current_bd_design $BD_NAME


set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
    set list_check_ips "\ 
    xilinx.com:ip:smartconnect:1.0\
    "

    set list_ips_missing ""
    common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

    foreach ip_vlnv $list_check_ips {
        set ip_obj [get_ipdefs -all $ip_vlnv]
        if { $ip_obj eq "" } {
            lappend list_ips_missing $ip_vlnv
        }
    }

    if { $list_ips_missing ne "" } {
        catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
        set bCheckIPsPassed 0
    }
}

if { $bCheckIPsPassed != 1 } {
    common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
}


set parentCell [get_bd_cells /]
# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
    catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
    return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
    catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
    return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# Set parent object as current
current_bd_instance $parentObj


# Create interface ports
set AXI4_IN [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI4_IN ]
set_property -dict [ list \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.ARUSER_WIDTH {0} \
    CONFIG.AWUSER_WIDTH {0} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.HAS_BRESP {1} \
    CONFIG.HAS_BURST {1} \
    CONFIG.HAS_CACHE {1} \
    CONFIG.HAS_LOCK {1} \
    CONFIG.HAS_PROT {1} \
    CONFIG.HAS_QOS {1} \
    CONFIG.HAS_REGION {0} \
    CONFIG.HAS_RRESP {1} \
    CONFIG.HAS_WSTRB {1} \
    CONFIG.ID_WIDTH {4} \
    CONFIG.MAX_BURST_LENGTH {256} \
    CONFIG.NUM_READ_OUTSTANDING {1} \
    CONFIG.NUM_READ_THREADS {1} \
    CONFIG.NUM_WRITE_OUTSTANDING {1} \
    CONFIG.NUM_WRITE_THREADS {1} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.RUSER_BITS_PER_BYTE {0} \
    CONFIG.RUSER_WIDTH {0} \
    CONFIG.SUPPORTS_NARROW_BURST {1} \
    CONFIG.WUSER_BITS_PER_BYTE {0} \
    CONFIG.WUSER_WIDTH {0} \
] $AXI4_IN

set AXI4_OUT0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI4_OUT0 ]
set_property -dict [ list \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.HAS_REGION {0} \
    CONFIG.PROTOCOL {AXI4} \
] $AXI4_OUT0

set AXI4_OUT1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI4_OUT1 ]
set_property -dict [ list \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.HAS_REGION {0} \
    CONFIG.PROTOCOL {AXI4} \
] $AXI4_OUT1


# Create ports
set axi4_clk [ create_bd_port -dir I -type clk axi4_clk ]
set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {AXI4_IN:AXI4_OUT0:AXI4_OUT1} \
] $axi4_clk
set axi4_reset_n [ create_bd_port -dir I -type rst axi4_reset_n ]

# Create instance: smartconnect_0, and set properties
set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
set_property -dict [ list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
] $smartconnect_0

# Create interface connections
connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_ports AXI4_IN] [get_bd_intf_pins smartconnect_0/S00_AXI]
connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_ports AXI4_OUT0] [get_bd_intf_pins smartconnect_0/M00_AXI]
connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_ports AXI4_OUT1] [get_bd_intf_pins smartconnect_0/M01_AXI]

# Create port connections
connect_bd_net -net aclk_0_1 [get_bd_ports axi4_clk] [get_bd_pins smartconnect_0/aclk]
connect_bd_net -net aresetn_0_1 [get_bd_ports axi4_reset_n] [get_bd_pins smartconnect_0/aresetn]

# Create address segments
create_bd_addr_seg -range 0x01000000 -offset 0xF0000000 [get_bd_addr_spaces AXI4_IN] [get_bd_addr_segs AXI4_OUT0/Reg] SEG_AXI4_OUT0_Reg
create_bd_addr_seg -range 0x01000000 -offset 0xF4000000 [get_bd_addr_spaces AXI4_IN] [get_bd_addr_segs AXI4_OUT1/Reg] SEG_AXI4_OUT1_Reg


# Restore current instance
current_bd_instance $oldCurInst

validate_bd_design
save_bd_design


set wrapper_file [make_wrapper -files [get_files $IP_DIR/$BD_NAME/$BD_NAME.bd] -top]
set bd_design [get_files $IP_DIR/$BD_NAME/$BD_NAME.bd]
generate_target all $bd_design


#generate design check point for synthesis
if {[info exists SYNTHESIS]} {
    set subIP ${BD_NAME}_smartconnect_0_0

    set_property generate_synth_checkpoint true [get_files $IP_DIR/$BD_NAME/$BD_NAME.bd]
    create_ip_run [get_files $IP_DIR/$BD_NAME/$BD_NAME.bd]
    set subIP_run [get_runs ${subIP}_synth_1]
    launch_runs -jobs 4 $subIP_run
    #wait until run has been finished
    wait_on_run $subIP_run
}


#add IP files for simulation
if {[info exists SIMULATION]} {
    foreach verfile [get_files -compile_order sources -used_in simulation -of_objects $bd_design -filter {(FILE_TYPE == VERILOG || FILE_TYPE == SYSTEMVERILOG) && NAME !~ "*rfs*"}] {
        lappend VERILOG_FILES $verfile
    }
    foreach vhdlfile [get_files -compile_order sources -used_in simulation -of_objects $bd_design -filter {FILE_TYPE == VHDL && NAME !~ "*rfs*"}] {
        lappend VHDL_FILES $vhdlfile
    }
}
lappend VERILOG_FILES $wrapper_file
