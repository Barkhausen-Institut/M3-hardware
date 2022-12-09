set BD_NAME bd_axi_dma_eth_fmc_nsl
set BOARD   xilinx.com:vcu118:part0:2.3
set PART    xcvu9p-flga2104-2L-e


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
    xilinx.com:ip:axi_dma:7.*\
    xilinx.com:ip:axi_ethernet:7.*\
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
set M00_AXI_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI_0 ]
set_property -dict [ list \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.FREQ_HZ {100000000} \
    CONFIG.PROTOCOL {AXI4} \
] $M00_AXI_0

set S00_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI_0 ]
set_property -dict [ list \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.ARUSER_WIDTH {0} \
    CONFIG.AWUSER_WIDTH {0} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.FREQ_HZ {100000000} \
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
] $S00_AXI_0

set mdio_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_0 ]

set rgmii_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_0 ]


# Create ports
if { [string match [version -short] "2019.1"] } {
    set aclk_0 [ create_bd_port -dir I -type clk aclk_0 ]
} else {
    set aclk_0 [ create_bd_port -dir I -type clk -freq_hz 100000000 aclk_0 ]
}
set_property -dict [ list \
    CONFIG.ASSOCIATED_BUSIF {S00_AXI_0:M00_AXI_0} \
    CONFIG.FREQ_HZ {100000000} \
] $aclk_0
set aresetn_0 [ create_bd_port -dir I -type rst aresetn_0 ]
if { [string match [version -short] "2019.1"] } {
    set gtx_clk_0 [ create_bd_port -dir I -type clk gtx_clk_0 ]
} else {
    set gtx_clk_0 [ create_bd_port -dir I -type clk -freq_hz 125000000 gtx_clk_0 ]
}
set_property -dict [ list \
    CONFIG.FREQ_HZ {125000000} \
    CONFIG.PHASE {0} \
] $gtx_clk_0
set interrupt_axi_ethernet [ create_bd_port -dir O -type intr interrupt_axi_ethernet ]
set mac_irq_0 [ create_bd_port -dir O -type intr mac_irq_0 ]
set mm2s_dma_introut [ create_bd_port -dir O -type intr mm2s_dma_introut ]
set phy_rst_n_0 [ create_bd_port -dir O -from 0 -to 0 -type rst phy_rst_n_0 ]
set s2mm_dma_introut [ create_bd_port -dir O -type intr s2mm_dma_introut ]

# Create instance: axi_dma_0, and set properties
set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.* axi_dma_0 ]
set_property -dict [ list \
    CONFIG.c_include_sg {1} \
    CONFIG.c_m_axi_mm2s_data_width {128} \
    CONFIG.c_micro_dma {0} \
    CONFIG.c_mm2s_burst_size {4} \
    CONFIG.c_sg_include_stscntrl_strm {1} \
] $axi_dma_0

# Create instance: axi_ethernet_0, and set properties
set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.* axi_ethernet_0 ]
set_property -dict [ list \
    CONFIG.Frame_Filter {false} \
    CONFIG.MDIO_BOARD_INTERFACE {Custom} \
    CONFIG.PHYRST_BOARD_INTERFACE {Custom} \
    CONFIG.PHY_TYPE {RGMII} \
    CONFIG.RXCSUM {Full} \
    CONFIG.RXMEM {32k} \
    CONFIG.Statistics_Counters {false} \
    CONFIG.SupportLevel {0} \
    CONFIG.TXCSUM {Full} \
    CONFIG.TXMEM {32k} \
] $axi_ethernet_0

# Create instance: smartconnect_0, and set properties
set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
set_property -dict [ list \
    CONFIG.ADVANCED_PROPERTIES {0} \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
] $smartconnect_0

# Create instance: smartconnect_1, and set properties
set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1 ]
set_property -dict [ list \
    CONFIG.NUM_SI {3} \
] $smartconnect_1

# Create interface connections
connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_ports S00_AXI_0] [get_bd_intf_pins smartconnect_0/S00_AXI]
connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_CNTRL [get_bd_intf_pins axi_dma_0/M_AXIS_CNTRL] [get_bd_intf_pins axi_ethernet_0/s_axis_txc]
connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins axi_ethernet_0/s_axis_txd]
connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins smartconnect_1/S01_AXI]
connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins smartconnect_1/S02_AXI]
connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_0/M_AXI_SG] [get_bd_intf_pins smartconnect_1/S00_AXI]
connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxd [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins axi_ethernet_0/m_axis_rxd]
connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxs [get_bd_intf_pins axi_dma_0/S_AXIS_STS] [get_bd_intf_pins axi_ethernet_0/m_axis_rxs]
connect_bd_intf_net -intf_net axi_ethernet_0_mdio [get_bd_intf_ports mdio_0] [get_bd_intf_pins axi_ethernet_0/mdio]
connect_bd_intf_net -intf_net axi_ethernet_0_rgmii [get_bd_intf_ports rgmii_0] [get_bd_intf_pins axi_ethernet_0/rgmii]
connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins smartconnect_0/M00_AXI]
connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins axi_ethernet_0/s_axi] [get_bd_intf_pins smartconnect_0/M01_AXI]
connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_ports M00_AXI_0] [get_bd_intf_pins smartconnect_1/M00_AXI]

# Create port connections
connect_bd_net -net aclk_0_1 [get_bd_ports aclk_0] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/m_axi_sg_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins axi_ethernet_0/s_axi_lite_clk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins smartconnect_1/aclk]
connect_bd_net -net aresetn_0_1 [get_bd_ports aresetn_0] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins smartconnect_1/aresetn]
connect_bd_net -net axi_dma_0_mm2s_cntrl_reset_out_n [get_bd_pins axi_dma_0/mm2s_cntrl_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txc_arstn]
connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_ports mm2s_dma_introut] [get_bd_pins axi_dma_0/mm2s_introut]
connect_bd_net -net axi_dma_0_mm2s_prmry_reset_out_n [get_bd_pins axi_dma_0/mm2s_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_txd_arstn]
connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_ports s2mm_dma_introut] [get_bd_pins axi_dma_0/s2mm_introut]
connect_bd_net -net axi_dma_0_s2mm_prmry_reset_out_n [get_bd_pins axi_dma_0/s2mm_prmry_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxd_arstn]
connect_bd_net -net axi_dma_0_s2mm_sts_reset_out_n [get_bd_pins axi_dma_0/s2mm_sts_reset_out_n] [get_bd_pins axi_ethernet_0/axi_rxs_arstn]
connect_bd_net -net axi_ethernet_0_interrupt [get_bd_ports interrupt_axi_ethernet] [get_bd_pins axi_ethernet_0/interrupt]
connect_bd_net -net axi_ethernet_0_mac_irq [get_bd_ports mac_irq_0] [get_bd_pins axi_ethernet_0/mac_irq]
connect_bd_net -net axi_ethernet_0_phy_rst_n [get_bd_ports phy_rst_n_0] [get_bd_pins axi_ethernet_0/phy_rst_n]
connect_bd_net -net gtx_clk_0_1 [get_bd_ports gtx_clk_0] [get_bd_pins axi_ethernet_0/gtx_clk]

# Create address segments
create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs M00_AXI_0/Reg] SEG_M00_AXI_0_Reg
create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs M00_AXI_0/Reg] SEG_M00_AXI_0_Reg
create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs M00_AXI_0/Reg] SEG_M00_AXI_0_Reg
create_bd_addr_seg -range 0x00040000 -offset 0x00040000 [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
create_bd_addr_seg -range 0x00040000 -offset 0x00000000 [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs axi_ethernet_0/s_axi/Reg0] SEG_axi_ethernet_0_Reg0


# Restore current instance
current_bd_instance $oldCurInst

validate_bd_design
save_bd_design


set wrapper_file [make_wrapper -files [get_files $IP_DIR/$BD_NAME/$BD_NAME.bd] -top]
set bd_design [get_files $IP_DIR/$BD_NAME/$BD_NAME.bd]
generate_target all $bd_design


#generate design check point for synthesis
if {[info exists SYNTHESIS]} {
    set subIP1 ${BD_NAME}_smartconnect_0_0
    set subIP2 ${BD_NAME}_smartconnect_1_0
    set subIP3 ${BD_NAME}_axi_ethernet_0_0
    set subIP4 ${BD_NAME}_axi_dma_0_0

    set_property generate_synth_checkpoint true [get_files $IP_DIR/$BD_NAME/$BD_NAME.bd]
    create_ip_run [get_files $IP_DIR/$BD_NAME/$BD_NAME.bd]
    set subIP_runs [list [get_runs ${subIP1}_synth_1] [get_runs ${subIP2}_synth_1] [get_runs ${subIP3}_synth_1] [get_runs ${subIP4}_synth_1]]
    launch_runs -jobs 4 $subIP_runs
    #wait until all runs have been finished
    for {set i 0} {$i < [llength $subIP_runs]} {incr i} {
        wait_on_run [lindex $subIP_runs $i]
    }
}

#add IP files for simulation
if {[info exists SIMULATION]} {
    foreach verfile [get_files -compile_order sources -used_in simulation -of_objects $bd_design \
        -filter {(FILE_TYPE == VERILOG || FILE_TYPE == SYSTEMVERILOG) && NAME !~ "*ipshared*"}] {
        lappend VERILOG_FILES $verfile
    }
    foreach vhdlfile [get_files -compile_order sources -used_in simulation -of_objects $bd_design \
        -filter {FILE_TYPE == VHDL && NAME !~ "*ipshared*"}] {
        lappend VHDL_FILES $vhdlfile
    }
}
lappend VERILOG_FILES $wrapper_file
