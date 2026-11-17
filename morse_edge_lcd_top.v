// morse_edge_lcd_top.v : same as morse_edge_top plus the 16x2 LCD on header J7.
// Use this as top ONLY after you uncomment/fill the LCD lines in morse_edge.xdc.
module morse_edge_lcd_top(
    input  wire        clk,
    input  wire        btn_tap,
    input  wire        btn_rst,
    output wire [15:0] led,
    output wire        lcd_rs,
    output wire        lcd_e,
    output wire [3:0]  lcd_d        // LCD D4..D7
);
  wire [4:0] code; wire tap_led, dash, space; wire [2:0] cnt;
  morse_top #(.CLK_HZ(50_000_000), .ACTIVE_LOW(0)) core_top(
      .clk(clk), .btn_tap(btn_tap), .btn_rst(btn_rst),
      .led_code(code), .led_tap(tap_led), .led_dash(dash),
      .led_space(space), .led_cnt(cnt),
      .lcd_rs(lcd_rs), .lcd_e(lcd_e), .lcd_d(lcd_d));
  assign led = {5'b0, cnt, space, dash, tap_led, code};
endmodule
