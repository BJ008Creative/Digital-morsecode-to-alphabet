// morse_edge_top.v : EDGE Artix 7 (XC7A35T). Decoded letter shown on the 16 on-board LEDs.
//   led[4:0]  = last decoded letter as a binary number (A=0, B=1 ... Z=25, 31=error)
//   led[5]    = debounced tap      led[6] = last symbol was a dash
//   led[7]    = toggles at every word gap
//   led[10:8] = symbols entered so far in the current letter
module morse_edge_top(
    input  wire        clk,        // 50 MHz
    input  wire        btn_tap,    // right push button, reads 1 when pressed
    input  wire        btn_rst,    // reset push button, reads 1 when pressed
    output wire [15:0] led
);
  wire [4:0] code; wire tap_led, dash, space; wire [2:0] cnt;
  morse_top #(.CLK_HZ(50_000_000), .ACTIVE_LOW(0)) core_top(
      .clk(clk), .btn_tap(btn_tap), .btn_rst(btn_rst),
      .led_code(code), .led_tap(tap_led), .led_dash(dash),
      .led_space(space), .led_cnt(cnt),
      .lcd_rs(), .lcd_e(), .lcd_d());
  assign led = {5'b0, cnt, space, dash, tap_led, code};
endmodule
