// morse_top.v : tap button -> Morse decoder -> LEDs + 1602 LCD
module morse_top #(
    parameter CLK_HZ     = 50_000_000,   // CHECK your board's clock!
    parameter ACTIVE_LOW = 0,            // 1 if onboard buttons read 0 when pressed
    parameter DEBOUNCE_MS = 20,
    parameter DASH_MS    = 300,          // press >= 300 ms = dash
    parameter LETTER_MS  = 700,          // silence >= 700 ms = letter done
    parameter WORD_MS    = 1800          // silence >= 1800 ms = word done
)(
    input  wire       clk,
    input  wire       btn_tap,
    input  wire       btn_rst,
    output wire [4:0] led_code,          // last decoded letter (0=A..25=Z)
    output wire       led_tap,           // debounced tap
    output wire       led_dash,          // last symbol was a dash
    output reg        led_space,         // toggles at each word gap
    output wire [2:0] led_cnt,           // symbols entered so far
    output wire       lcd_rs, lcd_e,
    output wire [3:0] lcd_d
);
  localparam MS = CLK_HZ/1000;

  // power-on reset + optional reset button
  reg [15:0] por = 0;
  wire rst_btn = ACTIVE_LOW ? ~btn_rst : btn_rst;
  wire rst = (por != 16'hFFFF) | rst_btn;
  always @(posedge clk) if (por != 16'hFFFF) por <= por + 1;

  wire tap_raw = ACTIVE_LOW ? ~btn_tap : btn_tap;
  wire tap;
  debounce #(.CYC(MS*DEBOUNCE_MS)) db(.clk(clk), .rst(rst), .din(tap_raw), .dout(tap));

  wire letter_valid, space_pulse;
  wire [4:0] letter_code;
  morse_core #(.DASH_CYC(MS*DASH_MS), .LETTER_CYC(MS*LETTER_MS), .WORD_CYC(MS*WORD_MS))
    core(.clk(clk), .rst(rst), .tap(tap), .letter_valid(letter_valid),
         .letter_code(letter_code), .space_pulse(space_pulse),
         .last_is_dash(led_dash), .sym_cnt(led_cnt));

  assign led_code = letter_code;
  assign led_tap  = tap;
  always @(posedge clk) begin
    if (rst) led_space <= 0; else if (space_pulse) led_space <= ~led_space;
  end

  // letter code -> ASCII
  reg lcd_put; reg [7:0] lcd_char;
  always @(posedge clk) begin
    lcd_put <= 1'b0;
    if (rst) begin
      lcd_char <= 8'h20;
    end else if (letter_valid) begin
      lcd_put <= 1'b1;
      lcd_char <= (letter_code == 5'd31) ? 8'h3F : (8'd65 + letter_code); // '?' on error
    end else if (space_pulse) begin
      lcd_put <= 1'b1; lcd_char <= 8'h20;
    end
  end

  lcd_driver #(.CLK_HZ(CLK_HZ)) lcd(.clk(clk), .rst(rst), .put_en(lcd_put),
      .put_char(lcd_char), .lcd_rs(lcd_rs), .lcd_e(lcd_e), .lcd_d(lcd_d));
endmodule
