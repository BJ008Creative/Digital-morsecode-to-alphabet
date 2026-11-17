# Tap-Based Morse Code Decoder (Verilog, EDGE Artix-7)

A Morse code decoder built only from digital logic. Press a single push button — **short press = dot, long press = dash** — and the circuit works out the letter, with no microcontroller and no software. The decoded letter is shown as a binary code on the FPGA's LEDs, and an optional 16x2 LCD driver is included.

Built for the Digital Design course at IIT Tirupati by **Baishali Jena (CS25B006)** and **G Sphoorthi (CS25B017)**.

> Motivation: people with locked-in syndrome or severe paralysis may be able to make only one small movement. With one switch, timing has to carry the message, and Morse code does exactly that.

## How it works

```
Push button -> Debounce -> Timing core (counter, comparator, symbol register, FSM) -> Decoder -> LEDs / LCD
```

1. **Debounce** — ignores switch bounce; a change counts only after 20 ms of steady input.
2. **Press timer** — a counter measures how long the button stays pressed.
3. **Dot or dash** — a comparator checks the count against a threshold (>= 300 ms is a dash).
4. **Symbol register** — a 4-bit shift register stores the symbols; a 3-bit counter stores how many.
5. **Gap detection** — the same counter measures silence: >= 700 ms ends a letter, >= 1800 ms ends a word.
6. **Decoder** — one AND gate per letter (with NOT gates for 0-bits) detects the pattern; OR gates encode it into a 5-bit letter code.
7. **Output** — the code goes to the LEDs (and the LCD, if used).

## Repository layout

| File | Purpose |
|---|---|
| `debounce.v` | Switch debouncer |
| `morse_core.v` | Press/gap timing, symbol register, control state machine |
| `morse_decoder.v` | Combinational Morse-to-letter decoder |
| `lcd_driver.v` | HD44780 1602 LCD driver (4-bit mode, write-only) |
| `morse_top.v` | Board-independent top level |
| `morse_edge_top.v` | **Board top, LED output** (default) |
| `morse_edge_lcd_top.v` | Board top, LED + LCD output |
| `morse_edge.xdc` | Pin constraints for the EDGE Artix-7 kit |
| `tb_decoder.v`, `tb_debounce.v`, `tb_core.v`, `tb_lcd.v`, `tb_top.v` | Testbenches |
| `run_all.sh` | Runs all testbenches with Icarus Verilog |
| `create_vivado_project.tcl`, `xsim_waves.tcl` | One-step Vivado project and simulation setup |

## Run the simulations

You do not need a board for this.

**Icarus Verilog** (`sudo apt install iverilog gtkwave`, or the Windows installer from bleyer.org/icarus):

```sh
sh run_all.sh          # runs every testbench
gtkwave tb_top.vcd     # view the full-system waveform
```

On Windows, run the `iverilog` / `vvp` lines from `run_all.sh` one at a time.

**Vivado:** *Tools -> Run Tcl Script -> `create_vivado_project.tcl`*, then *Run Simulation -> Run Behavioral Simulation*. The script runs the simulation to the end and adds all signals to the waveform. Pick another testbench with:

```tcl
set_property top tb_core [get_filesets sim_1]
```

### Simulation results

| Testbench | Checks | Result |
|---|---|---|
| `tb_decoder` | All 26 letters and invalid patterns | PASS |
| `tb_debounce` | Glitches ignored, real edges accepted | PASS |
| `tb_core` | SOS, HI, MAKE, too-long pattern | PASS (self-checking) |
| `tb_lcd` | LCD init sequence, writes, line wrap, clear | Correct sequence |
| `tb_top` | Bouncy button -> whole chain -> simulated LCD | PASS (`HI SOS`) |

Simulations use shortened timings. The real design uses the values below.

## Build for the board

Target: **EDGE Artix-7 kit, XC7A35T-FTG256** (part `xc7a35tftg256-1`), 50 MHz clock.

1. Run `create_vivado_project.tcl` in Vivado (change the part at the top for the 100T board).
2. Run Synthesis -> Implementation -> Generate Bitstream -> Program Device.
3. Top module is `morse_edge_top`, constraints are `morse_edge.xdc`.

### Using it

| Action | Result |
|---|---|
| Short press of the **right push button** (L13) | Dot |
| Hold longer than 0.3 s | Dash |
| Pause 0.7 s | Letter is decoded |
| Pause 1.8 s | Word gap |
| **Reset button** (M14) | Clears everything |

### LED map

| LED | Meaning |
|---|---|
| 0–4 | Last letter as a binary number: A=0, B=1 ... Z=25, 31 = error |
| 5 | Debounced tap |
| 6 | Last symbol was a dash |
| 7 | Toggles at every word gap |
| 8–10 | Symbols entered in the current letter |

Examples: `S` = 18 = `10010`, `O` = 14 = `01110`, `E` = 4 = `00100`.

### LCD (optional)

The LCD version needs six pin numbers that are not in the vendor's board file. Get RS, EN and D4–D7 for header J7 from the vendor's master XDC, fill the commented lines at the bottom of `morse_edge.xdc`, and set `morse_edge_lcd_top` as the top module.

## Timing parameters

Set in `morse_top.v`; defaults assume a 50 MHz clock.

| Parameter | Default |
|---|---|
| `DEBOUNCE_MS` | 20 |
| `DASH_MS` | 300 |
| `LETTER_MS` | 700 |
| `WORD_MS` | 1800 |

If the board has an active-low button, set `ACTIVE_LOW = 1`. If the clock is not 50 MHz, set `CLK_HZ`.

## Limitations

- Letters only (up to 4 symbols). Digits and punctuation are not decoded; longer patterns show as error `31` / `?`.
- Thresholds are fixed, so very slow or fast tapping may need them changed.
- Hardware testing on the board is still to be recorded; the design has been verified in simulation.

## Future work

- Use an IR reflectance sensor (e.g. TCRT5000) so a blink can act as the tap.
- Digits and punctuation, adaptive timing, buzzer playback, SOS alarm.

## Licence

Add your preferred licence here (for example MIT).
