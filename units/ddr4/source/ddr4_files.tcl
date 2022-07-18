
source $REPO_DIR/ddr4/source/IP/ddr4_generate_ip.tcl

lappend INCLUDE_DIRS $REPO_DIR/ddr4/source/rtl/verilog

lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_regfile.v
lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_app_sync.v
lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_mem_app_bridge.v
lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_wrap.v
lappend VERILOG_FILES $REPO_DIR/ddr4/source/rtl/verilog/ddr4_domain.v
