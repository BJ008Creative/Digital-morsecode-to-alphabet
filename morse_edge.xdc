## ============================================================================
## Master Constraints File for EDGE Artix-7 FPGA Board (XC7A35T-FTG256)
## Part: xc7a35tftg256-1
## Project: Tap-Based Morse Code Decoder
## ============================================================================

## ---- Clock (50 MHz) ----
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports {clk}]
create_clock -add -name sys_clk -period 20.000 -waveform {0.000 10.000} [get_ports {clk}]

## ---- Push Buttons (Active High: reads 1 when pressed) ----
## L13 = Right push button (btn_tap: short = dot, hold >= 300 ms = dash)
## M14 = Reset push button (btn_rst)
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 } [get_ports {btn_tap}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {btn_rst}]

## ---- 16 User LEDs (Active High: 1 = ON) ----
## led[4:0]  = Last decoded letter (0=A .. 25=Z, 31=error)
## led[5]    = Debounced tap state
## led[6]    = Last symbol was a dash
## led[7]    = Toggles on each word gap
## led[10:8] = Symbols entered in current letter
set_property -dict { PACKAGE_PIN J3  IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN H3  IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN J1  IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN L3  IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN L2  IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
set_property -dict { PACKAGE_PIN K3  IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports {led[7]}]
set_property -dict { PACKAGE_PIN K5  IOSTANDARD LVCMOS33 } [get_ports {led[8]}]
set_property -dict { PACKAGE_PIN P6  IOSTANDARD LVCMOS33 } [get_ports {led[9]}]
set_property -dict { PACKAGE_PIN R7  IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
set_property -dict { PACKAGE_PIN R6  IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
set_property -dict { PACKAGE_PIN T5  IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
set_property -dict { PACKAGE_PIN R5  IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports {led[15]}]

## ---- 16x2 Character LCD (4-bit mode; R/W is tied to GND on the board) ----
## Used when top module is `morse_edge_lcd_top`
set_property -dict { PACKAGE_PIN P5  IOSTANDARD LVCMOS33 } [get_ports {lcd_rs}]
set_property -dict { PACKAGE_PIN T3  IOSTANDARD LVCMOS33 } [get_ports {lcd_e}]
set_property -dict { PACKAGE_PIN R2  IOSTANDARD LVCMOS33 } [get_ports {lcd_d[0]}]  ;# LCD D4
set_property -dict { PACKAGE_PIN N4  IOSTANDARD LVCMOS33 } [get_ports {lcd_d[1]}]  ;# LCD D5
set_property -dict { PACKAGE_PIN M5  IOSTANDARD LVCMOS33 } [get_ports {lcd_d[2]}]  ;# LCD D6
set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports {lcd_d[3]}]  ;# LCD D7

## ---- Bitstream & Configuration Voltage Settings ----
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]