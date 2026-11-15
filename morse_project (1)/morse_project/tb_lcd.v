`timescale 1ns/1ps
module tb_lcd;
  reg clk = 0, rst = 1, put = 0; reg [7:0] ch = 0;
  wire rs, e; wire [3:0] d;
  lcd_driver #(.CLK_HZ(1_000_000)) dut(.clk(clk), .rst(rst), .put_en(put), .put_char(ch),
                                       .lcd_rs(rs), .lcd_e(e), .lcd_d(d));
  always #500 clk = ~clk;   // 1 MHz
  always @(negedge e) $write("[rs=%b d=%h] ", rs, d);   // LCD latches on falling E
  task send(input [7:0] c); begin
    @(posedge clk); ch <= c; put <= 1; @(posedge clk); put <= 0; repeat (300) @(posedge clk);
  end endtask
  integer i;
  initial begin
    repeat (4) @(posedge clk); rst = 0;
    repeat (65000) @(posedge clk);          // power-up + init
    $write("\n--- init done, now writing S O S space ---\n");
    send("S"); send("O"); send("S"); send(" ");
    for (i = 0; i < 40; i = i + 1) send("A");   // check line wrap + clear
    $write("\n"); $finish;
  end
endmodule
