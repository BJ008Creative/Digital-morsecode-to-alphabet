## ============================================================================
## Constraints for the EDGE Artix 7 kit (XC7A35T / XC7A100T, FTG256)  -- top module: morse_edge_top
##
## VERIFIED from the vendor's own tutorial (allaboutfpga.com, System Generator guide):
##    clock = N11 (50 MHz);  LEDs = J3, H3, J1, K1;  a slide switch = L5
## NOT VERIFIED (I could not open the vendor's master XDC): the push-button pins and the
##    LCD (J7) pins. Open the official master XDC from
##    https://allaboutfpga.com/edge-artix-7-fpga-kit-xdc-pin-details/
##    and copy the PACKAGE_PIN for each line marked <<FILL>> below.
##    Never guess a pin: an output on the wrong pin can fight another chip on the board.
## ============================================================================

## ---- Clock (verified) ----
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 20.000 -name sys_clk [get_ports clk]

## ---- LEDs (verified in vendor tutorial; check against master XDC) ----
set_property -dict { PACKAGE_PIN J3 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN H3 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]

## ---- Push buttons <<FILL>> : manual calls them SW19..SW23. Pick two from the master XDC. ----
## btn_tap  = the tap button,  btn_rst = reset button
# set_property -dict { PACKAGE_PIN <<FILL>> IOSTANDARD LVCMOS33 } [get_ports btn_tap]
# set_property -dict { PACKAGE_PIN <<FILL>> IOSTANDARD LVCMOS33 } [get_ports btn_rst]

## ---- LCD on header J7 <<FILL>> : copy the pins of RS, EN and data bits D4..D7 ----
## (the board wires LCD in 8-bit mode; we only use D4..D7. RW is already tied to GND.)
# set_property -dict { PACKAGE_PIN <<FILL>> IOSTANDARD LVCMOS33 } [get_ports lcd_rs]
# set_property -dict { PACKAGE_PIN <<FILL>> IOSTANDARD LVCMOS33 } [get_ports lcd_e]
# set_property -dict { PACKAGE_PIN <<FILL>> IOSTANDARD LVCMOS33 } [get_ports {lcd_d[0]}]   ;# LCD D4
# set_property -dict { PACKAGE_PIN <<FILL>> IOSTANDARD LVCMOS33 } [get_ports {lcd_d[1]}]   ;# LCD D5
# set_property -dict { PACKAGE_PIN <<FILL>> IOSTANDARD LVCMOS33 } [get_ports {lcd_d[2]}]   ;# LCD D6
# set_property -dict { PACKAGE_PIN <<FILL>> IOSTANDARD LVCMOS33 } [get_ports {lcd_d[3]}]   ;# LCD D7

## ---- Bitstream settings (3.3 V board) ----
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
