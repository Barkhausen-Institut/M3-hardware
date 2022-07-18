
lappend DEF_MACROS RANDOMIZE_REG_INIT
lappend DEF_MACROS RANDOMIZE_MEM_INIT
lappend DEF_MACROS "PRINTF_COND=0"

set ROCKET_CONFIG chipyard.TestHarness.BigRocketMmioJtagUartConfig


lappend VERILOG_FILES $REPO_DIR/rocket/source/IP/$ROCKET_CONFIG/plusarg_reader.v
lappend VERILOG_FILES $REPO_DIR/rocket/source/IP/$ROCKET_CONFIG/${ROCKET_CONFIG}.top.v

lappend VERILOG_FILES $REPO_DIR/rocket/source/rtl/verilog/mem_ext_big.v
lappend VERILOG_FILES $REPO_DIR/rocket/source/rtl/verilog/rocket_trace.v
lappend VERILOG_FILES $REPO_DIR/rocket/source/rtl/verilog/rocket_ctrl.v
lappend VERILOG_FILES $REPO_DIR/rocket/source/rtl/verilog/rocket_core.v
lappend VERILOG_FILES $REPO_DIR/rocket/source/rtl/verilog/rocket_regfile.v
lappend VERILOG_FILES $REPO_DIR/rocket/source/rtl/verilog/rocket_wrap.v
lappend VERILOG_FILES $REPO_DIR/rocket/source/rtl/verilog/pm_rocket.v

