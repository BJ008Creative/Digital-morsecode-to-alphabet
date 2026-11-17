# EDGE Artix 7 (XC7A35T-FTG256) - steps

## Test without the board
    sh run_all.sh   (or use Vivado simulation, see create_vivado_project.tcl)

## Version A - LEDs (recommended first, every pin verified)
  Top module : morse_edge_top        Constraints : morse_edge.xdc
  Part       : xc7a35tftg256-1
  Easiest    : Vivado -> Tools -> Run Tcl Script -> create_vivado_project.tcl
  Then       : Run Synthesis -> Implementation -> Generate Bitstream -> Program Device

  Use it     : press the RIGHT push button (L13).  short press = dot, hold > 0.3 s = dash.
               pause 0.7 s -> the letter appears on LEDs 0..4 as a binary number
               pause 1.8 s -> LED 7 toggles (word gap)
  Reset      : the RESET push button (M14)

  LED map    : LED0-4  letter code (A=0 B=1 C=2 ... Z=25, 31=error)
               LED5 tap   LED6 last symbol was dash   LED7 word-gap toggle
               LED8-10 symbols entered in current letter
  Examples   : S = 18 = 10010   O = 14 = 01110   H = 7 = 00111   E = 4 = 00100   T = 19 = 10011

## Version B - LCD (needs 6 LCD pins)
  Top module : morse_edge_lcd_top         Constraints : morse_edge.xdc (LCD section at the bottom)
  Fill the <<FILL>> pins (LCD RS, EN, D4-D7) from the vendor's master XDC:
  https://allaboutfpga.com/edge-artix-7-fpga-kit-xdc-pin-details/
  Plug the 16x2 LCD into header J7.

## Troubleshooting
  Nothing happens on tap : reset button held? wrong project top module?
  Wrong letters          : your dash threshold; adjust DASH_MS / LETTER_MS / WORD_MS in morse_top.v
