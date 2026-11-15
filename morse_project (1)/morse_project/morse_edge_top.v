// morse_edge_top.v : board wrapper for the ApplyVolt / All About FPGA "EDGE Artix 7" kit.
// Facts used (from the vendor's product page and manual):
//   * 50 MHz on-board clock
//   * 5 push buttons, they read 1 while pressed  -> ACTIVE_LOW = 0
//   * 2x16 LCD plugs into header J7, RW is wired to GND on the board
// Only the signals we really need are exposed, so you only have to find a few pins.
module morse_edge_top(
    input  wire       clk,        // 50 MHz
    input  wire       btn_tap,    // any push button = the "tap" input
    input  wire       btn_rst,    // another push button = reset
    output wire [3:0] led,        // led[0]=tap  led[1]=last symbol was dash
                                  // led[2]=letter in progress  led[3]=toggles each word gap
    output wire       lcd_rs,
    output wire       lcd_e,
    output wire [3:0] lcd_d       // LCD D4..D7  (D0..D3 stay unused: 4-bit mode)
);
  wire [4:0] code_unused;
  wire       led_tap, led_dash, led_space;
  wire [2:0] led_cnt;

  morse_top #(.CLK_HZ(50_000_000), .ACTIVE_LOW(0)) core_top(
      .clk(clk), .btn_tap(btn_tap), .btn_rst(btn_rst),
      .led_code(code_unused), .led_tap(led_tap), .led_dash(led_dash),
      .led_space(led_space), .led_cnt(led_cnt),
      .lcd_rs(lcd_rs), .lcd_e(lcd_e), .lcd_d(lcd_d));

  assign led = {led_space, (led_cnt != 3'd0), led_dash, led_tap};
endmodule
