# Steps for the EDGE Artix 7 kit

Top module: `morse_edge_top`   Constraints: `morse_edge.xdc`   Clock: 50 MHz   Buttons: 1 when pressed

## 0. Test without the board first
    sh run_all.sh        (needs iverilog;  gtkwave tb_top.vcd to see waves)

## 1. Install Vivado ML Standard (free). The vendor guide:
   https://allaboutfpga.com/download-and-installation-of-vivado-design-suite-for-working-with-edge-artix-7-and-zynq-fpga-kits/

## 2. Find your FPGA part (read the chip marking or the box)
   XC7A35T  -> part  xc7a35tftg256-1
   XC7A100T -> part  xc7a100tftg256-1  (check the speed grade printed on the chip)

## 3. Create the project
   Add design sources: morse_edge_top.v morse_top.v morse_core.v morse_decoder.v debounce.v lcd_driver.v
   Do NOT add the tb_*.v files as design sources (add them as simulation sources if you like).
   Set morse_edge_top as the top module. Add morse_edge.xdc as the constraints file.

## 4. Fill the missing pins in morse_edge.xdc
   Open the vendor's master XDC (link is at the top of morse_edge.xdc).
   Copy the pin for: two push buttons, LCD RS, LCD EN, LCD D4, D5, D6, D7.
   Remove the leading '#' on those lines.

## 5. Hardware
   Plug the 16x2 LCD into header J7 (no wires; check the pin 1 mark matches). Turn the contrast
   pot if the board has one. Connect USB, switch the board on.

## 6. Build and program
   Run Synthesis -> Implementation -> Generate Bitstream -> Hardware Manager -> Program Device.

## 7. Use it
   Short press of btn_tap = dot, press longer than 0.3 s = dash.
   Pause 0.7 s = letter is written on the LCD.  Pause 1.8 s = a space is written.
   LEDs: 0 = tap seen, 1 = last symbol was dash, 2 = letter in progress, 3 = toggles per word gap.

## Troubleshooting
   LCD blank / black boxes : contrast; then check RS/EN/D4..D7 pins and that the LCD is seated on J7.
   Garbage characters      : a data pin is wrong or swapped (D4..D7 order).
   Nothing on tap          : wrong button pin, or reset button held down.
   Timing feels off        : change DASH_MS / LETTER_MS / WORD_MS in morse_top.v.
