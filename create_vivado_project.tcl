# Builds the whole Vivado project in one go.
# Usage: Vivado -> Tools -> Run Tcl Script... -> pick this file
#   or in the Tcl console:  source <path>/create_vivado_project.tcl
set part xc7a35tftg256-1        ;# use xc7a100tftg256-1 if your chip is the 100T
set src  [file normalize [file dirname [info script]]]

create_project morse_edge $src/vivado_proj -part $part -force

# Design sources (go on the FPGA)
add_files -fileset sources_1 [list \
  $src/morse_edge_top.v $src/morse_edge_lcd_top.v $src/morse_top.v $src/morse_core.v \
  $src/morse_decoder.v  $src/debounce.v  $src/lcd_driver.v]
set_property top morse_edge_top [get_filesets sources_1]   ;# LED version. For LCD use morse_edge_lcd_top

# Simulation sources (testbenches only)
add_files -fileset sim_1 [list \
  $src/tb_decoder.v $src/tb_debounce.v $src/tb_core.v $src/tb_lcd.v $src/tb_top.v]
set_property top tb_top [get_filesets sim_1]

# Constraints
add_files -fileset constrs_1 $src/morse_edge.xdc

# Simulation settings: run until the testbench ends, and show all signals
set_property -name {xsim.simulate.runtime}         -value {-all} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.custom_tcl}      -value $src/xsim_waves.tcl -objects [get_filesets sim_1]

update_compile_order -fileset sources_1
puts "DONE. To simulate: Flow Navigator -> Run Simulation -> Run Behavioral Simulation"
puts "To pick another testbench:  set_property top tb_core \[get_filesets sim_1\]"
