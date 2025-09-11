#!/bin/bash

BITFILE=$1
JTAG_NO=$2

vivado -mode batch -source $FPGA_DESIGN/units/fpga_top/software/fpga/program_fpga.tcl -tclargs $BITFILE $JTAG_NO
