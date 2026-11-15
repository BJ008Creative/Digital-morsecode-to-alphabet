`timescale 1ns/1ps
module tb_core;
  reg clk = 0, rst = 1, tap = 0;
  wire lv, sp, ld; wire [4:0] lc; wire [2:0] sc;
  morse_core #(.DASH_CYC(15), .LETTER_CYC(35), .WORD_CYC(90))
    dut(.clk(clk), .rst(rst), .tap(tap), .letter_valid(lv), .letter_code(lc),
        .space_pulse(sp), .last_is_dash(ld), .sym_cnt(sc));
  always #5 clk = ~clk;
  task press(input integer n); begin tap = 1; repeat (n) @(posedge clk); tap = 0; end endtask
  task rel  (input integer n); begin tap = 0; repeat (n) @(posedge clk); end endtask
  task dot;  begin press(5);  rel(5); end endtask
  task dash; begin press(30); rel(5); end endtask
  task letter_gap; rel(40);  endtask   // > LETTER, < WORD
  task word_gap;   rel(100); endtask   // > WORD
  always @(posedge clk) begin
    if (lv) $display("%0t  LETTER %c (code %0d)", $time, (lc==31)?"?":(8'd65+lc), lc);
    if (sp) $display("%0t  SPACE", $time);
  end
  initial begin
    repeat (4) @(posedge clk); rst = 0; rel(3);
    // S O S
    dot; dot; dot; letter_gap;
    dash; dash; dash; letter_gap;
    dot; dot; dot; word_gap;
    // H I
    dot; dot; dot; dot; letter_gap;
    dot; dot; word_gap;
    // M  A  K  E
    dash; dash; letter_gap;  dot; dash; letter_gap;
    dash; dot; dash; letter_gap; dot; word_gap;
    // too many symbols -> error
    dot; dot; dot; dot; dot; dot; word_gap;
    $finish;
  end
endmodule
