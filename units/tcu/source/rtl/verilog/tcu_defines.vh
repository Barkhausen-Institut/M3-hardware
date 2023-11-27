
`ifndef TCU_DEFINES_VH
`define TCU_DEFINES_VH

`ifndef SYNTHESIS
    `define TCU_DEBUG(X) $write("%t TCU_DEBUG(%d:0x%x): ", $time, home_chipid_i, home_modid_i); \
        $write X; \
        $write("\n")
`else
    `define TCU_DEBUG(X)
`endif


`endif
