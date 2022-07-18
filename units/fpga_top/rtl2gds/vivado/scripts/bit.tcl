
open_checkpoint results/impl.dcp

# ------------------------------------------------------------
# write bitstream
# ------------------------------------------------------------
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullnone [current_design]
set_property BITSTREAM.CONFIG.PERSIST no [current_design]
set_property BITSTREAM.STARTUP.MATCH_CYCLE Auto [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property CONFIG_MODE SPIx8 [current_design]
write_bitstream -force results/fpga_top.bit
write_cfgmem -force -format MCS -size 256 -interface SPIx8 -loadbit "up 0x0 results/fpga_top.bit" -file results/fpga_top.mcs

