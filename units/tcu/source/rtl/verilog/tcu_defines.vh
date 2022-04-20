
`ifndef TCU_DEFINES_VH
`define TCU_DEFINES_VH

`ifndef SYNTHESIS
    `define TCU_DEBUG(X) $write("%t TCU_DEBUG(%d:0x%x): %s\n", $time, home_chipid_i, HOME_MODID, $sformatf X)
`else
    `define TCU_DEBUG(X)
`endif


`endif
