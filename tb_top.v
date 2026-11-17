`timescale 1ns/1ps
// FULL SYSTEM test (no FPGA needed): bouncy button -> debounce -> core -> decoder -> LCD driver.
// Taps out "HI", then "SOS". A virtual LCD collects what the real LCD would display and compares it.
// Writes tb_top.vcd so you can view the waveform in GTKWave.
module tb_top;
  reg clk = 0, btn = 0, rstb = 0;
  wire [4:0] led_code; wire led_tap, led_dash, led_space; wire [2:0] led_cnt;
  wire lcd_rs, lcd_e; wire [3:0] lcd_d;

  // 1 MHz clock, scaled-down timings: debounce 2ms, dash>=30ms, letter gap 70ms, word gap 180ms
  morse_top #(.CLK_HZ(1_000_000), .ACTIVE_LOW(0), .DEBOUNCE_MS(2),
              .DASH_MS(30), .LETTER_MS(70), .WORD_MS(180))
    dut(.clk(clk), .btn_tap(btn), .btn_rst(rstb), .led_code(led_code), .led_tap(led_tap),
        .led_dash(led_dash), .led_space(led_space), .led_cnt(led_cnt),
        .lcd_rs(lcd_rs), .lcd_e(lcd_e), .lcd_d(lcd_d));
  always #500 clk = ~clk;

  // ---- virtual LCD: collect data nibbles (rs=1) on falling E ----
  reg [7:0] shown [0:63]; integer n = 0; reg half = 0; reg [3:0] hi = 0;
  always @(negedge lcd_e) if (lcd_rs === 1'b1) begin
    if (!half) begin hi <= lcd_d; half <= 1; end
    else begin shown[n] <= {hi, lcd_d}; n <= n + 1; half <= 0; end
  end

  // ---- button tasks (ms of real time; 1 ms = 1000 clocks) ----
  task ms1;   begin repeat (1000)   @(posedge clk); end endtask
  task ms5;   begin repeat (5000)   @(posedge clk); end endtask
  task ms10;  begin repeat (10000)  @(posedge clk); end endtask
  task ms50;  begin repeat (50000)  @(posedge clk); end endtask
  task ms60;  begin repeat (60000)  @(posedge clk); end endtask
  task ms100; begin repeat (100000) @(posedge clk); end endtask
  task ms250; begin repeat (250000) @(posedge clk); end endtask
  task bounce_press; begin  // contact bounce while pressing
    btn=1; repeat(30)@(posedge clk); btn=0; repeat(40)@(posedge clk);
    btn=1; repeat(80)@(posedge clk); btn=0; repeat(20)@(posedge clk); btn=1; end endtask
  task bounce_release; begin
    btn=0; repeat(30)@(posedge clk); btn=1; repeat(40)@(posedge clk);
    btn=0; repeat(60)@(posedge clk); btn=1; repeat(10)@(posedge clk); btn=0; end endtask
  task dot;  begin bounce_press; ms10; bounce_release; ms10; end endtask
  task dash; begin bounce_press; ms50; bounce_release; ms10; end endtask
  task letter_gap; ms100; endtask
  task word_gap;   ms250; endtask

  integer errors = 0, i = 0;
  initial begin
    for (i = 0; i < 64; i = i + 1) shown[i] = 8'h00;   // no red (unknown) entries in the waveform
    $dumpfile("tb_top.vcd"); $dumpvars(0, tb_top);
    rstb = 1; ms1; rstb = 0;
    ms60;                                   // wait for LCD init (50 ms power-up + commands)
    // H = ....   I = ..
    dot; dot; dot; dot; letter_gap;
    dot; dot; word_gap;
    // S = ...  O = ---  S = ...
    dot; dot; dot; letter_gap;
    dash; dash; dash; letter_gap;
    dot; dot; dot; word_gap;
    ms5;
    $display("LCD received %0d characters: ", n);
    for (i = 0; i < n; i = i + 1) $write("%c", shown[i]); $write("\n");
    if (n !== 7) begin $display("FAIL: expected 7 characters"); errors = errors + 1; end
    else begin
      if (shown[0] !== "H" || shown[1] !== "I" || shown[2] !== " " ||
          shown[3] !== "S" || shown[4] !== "O" || shown[5] !== "S" || shown[6] !== " ")
        begin $display("FAIL: wrong text on LCD"); errors = errors + 1; end
    end
    if (errors == 0) $display("tb_top: PASS (bouncy taps -> \"HI SOS \" on LCD)");
    else $display("tb_top: FAIL (%0d)", errors);
    $finish;
  end
endmodule
