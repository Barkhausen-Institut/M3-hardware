
open_checkpoint results/synth.dcp

# ------------------------------------------------------------
# optimize design
# ------------------------------------------------------------
set_msg_config -id "Opt 31-6" -limit 10000
set_msg_config -id "Opt 31-54" -limit 10000
set_msg_config -id "Opt 31-131" -limit 10000
opt_design -verbose
report_drc -fail_on error -file reports/opt_drc.rpt

# ------------------------------------------------------------
# place design
# ------------------------------------------------------------
place_design
catch { report_io                    -file reports/placed_io.rpt }
catch { report_clock_utilization     -file reports/placed_clock_utilization.rpt }
catch { report_utilization           -file reports/placed_utilization.rpt }
catch { report_control_sets -verbose -file reports/placed_control_sets.rpt }
if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
  puts "Found setup timing violations => running physical optimization"
  phys_opt_design
}

# ------------------------------------------------------------
# route design
# ------------------------------------------------------------
route_design
catch { report_drc            -file reports/routed_drc.rpt }
catch { report_power          -file reports/routed_power.rpt }
catch { report_route_status   -file reports/routed_route_status.rpt }
catch { report_timing_summary -file reports/routed_timing_summary.rpt }

catch { report_clock_interaction -file reports/routed_clock_interaction.rpt }
catch { report_cdc -file reports/routed_cdc.rpt }

catch { report_utilization -file reports/routed_utilization.rpt }
catch { report_utilization -hierarchical -file reports/routed_utilization_hier.rpt }

write_checkpoint -force results/impl.dcp
