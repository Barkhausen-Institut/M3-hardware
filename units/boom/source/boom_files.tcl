
lappend DEF_MACROS RANDOMIZE_REG_INIT
lappend DEF_MACROS RANDOMIZE_MEM_INIT
lappend DEF_MACROS "PRINTF_COND=0"

set BOOM_CONFIG chipyard.TestHarness.MediumPFBoomMmioJtagUartConfig


lappend VERILOG_FILES $REPO_DIR/boom/source/IP/$BOOM_CONFIG/plusarg_reader.v
lappend VERILOG_FILES $REPO_DIR/boom/source/IP/$BOOM_CONFIG/${BOOM_CONFIG}.top.v

lappend VERILOG_FILES $REPO_DIR/boom/source/rtl/verilog/mem_ext_mediumboom.v
lappend VERILOG_FILES $REPO_DIR/boom/source/rtl/verilog/boom_trace.v
lappend VERILOG_FILES $REPO_DIR/boom/source/rtl/verilog/boom_ctrl.v
lappend VERILOG_FILES $REPO_DIR/boom/source/rtl/verilog/boom_core.v
lappend VERILOG_FILES $REPO_DIR/boom/source/rtl/verilog/boom_regfile.v
lappend VERILOG_FILES $REPO_DIR/boom/source/rtl/verilog/boom_wrap.v
lappend VERILOG_FILES $REPO_DIR/boom/source/rtl/verilog/pm_boom.v


