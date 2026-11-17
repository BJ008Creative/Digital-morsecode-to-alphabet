#!/bin/sh
# Runs every testbench. Needs Icarus Verilog:  sudo apt install iverilog gtkwave
set -e
iverilog -o decoder.vvp  tb_decoder.v  morse_decoder.v                    && vvp decoder.vvp
iverilog -o debounce.vvp tb_debounce.v debounce.v                         && vvp debounce.vvp
iverilog -o core.vvp     tb_core.v     morse_core.v morse_decoder.v       && vvp core.vvp
iverilog -o lcd.vvp      tb_lcd.v      lcd_driver.v                       && vvp lcd.vvp | tail -n 3
iverilog -o top.vvp tb_top.v morse_top.v morse_core.v morse_decoder.v debounce.v lcd_driver.v && vvp top.vvp
rm -f *.vvp
echo "Waveform: gtkwave tb_top.vcd"
