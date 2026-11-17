`timescale 1ns/1ps
// Short glitches must be ignored; a stable change must pass through after CYC clocks.
module tb_debounce;
  reg clk = 0, rst = 1, din = 0; wire dout;
  debounce #(.CYC(100)) dut(.clk(clk), .rst(rst), .din(din), .dout(dout));
  always #5 clk = ~clk;
  integer errors = 0;
  initial begin
    repeat (5) @(posedge clk); rst = 0; repeat (10) @(posedge clk);
    // 1) bouncing press: glitches shorter than 100 clocks
    din = 1; repeat (10) @(posedge clk); din = 0; repeat (10) @(posedge clk);
    din = 1; repeat (20) @(posedge clk); din = 0; repeat (5)  @(posedge clk);
    din = 1; repeat (30) @(posedge clk); din = 0; repeat (50) @(posedge clk);
    if (dout !== 0) begin $display("FAIL: glitches leaked through"); errors = errors + 1; end
    // 2) real press: held 300 clocks -> output must rise
    din = 1; repeat (50) @(posedge clk);
    if (dout !== 0) begin $display("FAIL: output rose too early"); errors = errors + 1; end
    repeat (250) @(posedge clk);
    if (dout !== 1) begin $display("FAIL: output never rose"); errors = errors + 1; end
    // 3) bouncing release, then a real release
    din = 0; repeat (10) @(posedge clk); din = 1; repeat (15) @(posedge clk);
    din = 0; repeat (5) @(posedge clk); din = 1; repeat (40) @(posedge clk);
    if (dout !== 1) begin $display("FAIL: release glitch leaked"); errors = errors + 1; end
    din = 0; repeat (300) @(posedge clk);
    if (dout !== 0) begin $display("FAIL: output never fell"); errors = errors + 1; end
    if (errors == 0) $display("tb_debounce: PASS"); else $display("tb_debounce: FAIL (%0d)", errors);
    $finish;
  end
endmodule
