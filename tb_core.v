`timescale 1ns/1ps
// Taps out SOS, HI, MAKE and a too-long pattern. Tasks have no arguments, so no signal stays red in the waveform.
module tb_core;
  reg clk = 0, rst = 1, tap = 0;
  wire lv, sp, ld; wire [4:0] lc; wire [2:0] sc;
  morse_core #(.DASH_CYC(15), .LETTER_CYC(35), .WORD_CYC(90))
    dut(.clk(clk), .rst(rst), .tap(tap), .letter_valid(lv), .letter_code(lc),
        .space_pulse(sp), .last_is_dash(ld), .sym_cnt(sc));
  always #5 clk = ~clk;
  task dot;        begin tap = 1; repeat (5)   @(posedge clk); tap = 0; repeat (5) @(posedge clk); end endtask
  task dash;       begin tap = 1; repeat (30)  @(posedge clk); tap = 0; repeat (5) @(posedge clk); end endtask
  task letter_gap; begin tap = 0; repeat (40)  @(posedge clk); end endtask  // > LETTER, < WORD
  task word_gap;   begin tap = 0; repeat (100) @(posedge clk); end endtask  // > WORD
  integer errors = 0, n = 0;
  reg [4:0] expect_codes [0:9];
  initial begin
    // expected letters in order: S O S H I M A K E ?
    expect_codes[0]=18; expect_codes[1]=14; expect_codes[2]=18; expect_codes[3]=7;  expect_codes[4]=8;
    expect_codes[5]=12; expect_codes[6]=0;  expect_codes[7]=10; expect_codes[8]=4;  expect_codes[9]=31;
  end
  always @(posedge clk) begin
    if (lv) begin
      $display("%0t  LETTER %c (code %0d)", $time, (lc==31)?"?":(8'd65+lc), lc);
      if (n < 10 && lc !== expect_codes[n]) begin
        $display("   FAIL: expected code %0d", expect_codes[n]); errors = errors + 1; end
      n = n + 1;
    end
    if (sp) $display("%0t  SPACE", $time);
  end
  initial begin
    repeat (4) @(posedge clk); rst = 0; tap = 0; repeat (3) @(posedge clk);
    dot; dot; dot; letter_gap;              // S
    dash; dash; dash; letter_gap;           // O
    dot; dot; dot; word_gap;                // S
    dot; dot; dot; dot; letter_gap;         // H
    dot; dot; word_gap;                     // I
    dash; dash; letter_gap;                 // M
    dot; dash; letter_gap;                  // A
    dash; dot; dash; letter_gap;            // K
    dot; word_gap;                          // E
    dot; dot; dot; dot; dot; dot; word_gap; // 6 symbols -> error
    if (n !== 10) begin $display("FAIL: got %0d letters, expected 10", n); errors = errors + 1; end
    if (errors == 0) $display("tb_core: PASS (S O S H I M A K E ?)");
    else $display("tb_core: FAIL (%0d errors)", errors);
    $finish;
  end
endmodule
