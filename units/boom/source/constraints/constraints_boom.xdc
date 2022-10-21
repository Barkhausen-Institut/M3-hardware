
#mark sync registers in Boom as asynchronous
#modules: AsyncResetRegVec, SynchronizerShiftReg
set_property ASYNC_REG TRUE [get_cells -hier sync_0_reg*]
set_property ASYNC_REG TRUE [get_cells -hier sync_1_reg*]
set_property ASYNC_REG TRUE [get_cells -hier sync_2_reg*]
set_property ASYNC_REG TRUE [get_cells -hier reg__reg*]


