
source $REPO_DIR/rld3/source/IP/rld3_generate_ip.tcl

lappend VERILOG_FILES $REPO_DIR/rld3/source/rtl/verilog/rld3_wrap.v
lappend VERILOG_FILES $REPO_DIR/rld3/source/rtl/verilog/rld3_domain.v
lappend VERILOG_FILES $REPO_DIR/rld3/source/rtl/verilog/rld3_mem_app_bridge.v
lappend VERILOG_FILES $REPO_DIR/rld3/source/rtl/verilog/rld3_app_sync.v
