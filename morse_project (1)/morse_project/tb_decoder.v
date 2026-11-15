`timescale 1ns/1ps
// Checks every letter A-Z against its Morse code, plus some invalid patterns.
module tb_decoder;
  reg [2:0] cnt; reg [3:0] bits; wire [4:0] code;
  morse_decoder dut(.cnt(cnt), .bits(bits), .code(code));
  integer errors = 0, i;
  reg [8*5-1:0] morse [0:25];      // "-" = dash, "." = dot
  task check(input [4:0] expect_code, input [2:0] c, input [3:0] b);
    begin cnt = c; bits = b; #1;
      if (code !== expect_code) begin
        $display("FAIL: cnt=%0d bits=%b -> %0d (expected %0d)", c, b, code, expect_code);
        errors = errors + 1; end
    end endtask
  initial begin
    // letter, length, bits (dash=1, first symbol = leftmost)
    check(0 ,2,4'b0001); check(1 ,4,4'b1000); check(2 ,4,4'b1010); check(3 ,3,4'b100);
    check(4 ,1,4'b0000); check(5 ,4,4'b0010); check(6 ,3,4'b110);  check(7 ,4,4'b0000);
    check(8 ,2,4'b0000); check(9 ,4,4'b0111); check(10,3,4'b101);  check(11,4,4'b0100);
    check(12,2,4'b0011); check(13,2,4'b0010); check(14,3,4'b111);  check(15,4,4'b0110);
    check(16,4,4'b1101); check(17,3,4'b010);  check(18,3,4'b000);  check(19,1,4'b0001);
    check(20,3,4'b001);  check(21,4,4'b0001); check(22,3,4'b011);  check(23,4,4'b1001);
    check(24,4,4'b1011); check(25,4,4'b1100);
    // invalid patterns must give 31
    check(31,0,4'b0000); check(31,4,4'b1111); check(31,4,4'b0101); check(31,3,4'b1000);
    if (errors == 0) $display("tb_decoder: PASS (all 26 letters + invalid patterns)");
    else $display("tb_decoder: FAIL (%0d errors)", errors);
    $finish;
  end
endmodule
