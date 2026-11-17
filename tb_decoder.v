`timescale 1ns/1ps
// Checks every letter A-Z against its Morse code, plus invalid patterns (must give 31).
module tb_decoder;
  reg [2:0] cnt = 0; reg [3:0] bits = 0; wire [4:0] code;
  morse_decoder dut(.cnt(cnt), .bits(bits), .code(code));
  reg [4:0] ex_code [0:29];
  reg [2:0] ex_cnt  [0:29];
  reg [3:0] ex_bits [0:29];
  integer errors = 0, i = 0;
  initial begin
    ex_code[0]=5'd0; ex_cnt[0]=3'd2; ex_bits[0]=4'b0001;
    ex_code[1]=5'd1; ex_cnt[1]=3'd4; ex_bits[1]=4'b1000;
    ex_code[2]=5'd2; ex_cnt[2]=3'd4; ex_bits[2]=4'b1010;
    ex_code[3]=5'd3; ex_cnt[3]=3'd3; ex_bits[3]=4'b0100;
    ex_code[4]=5'd4; ex_cnt[4]=3'd1; ex_bits[4]=4'b0000;
    ex_code[5]=5'd5; ex_cnt[5]=3'd4; ex_bits[5]=4'b0010;
    ex_code[6]=5'd6; ex_cnt[6]=3'd3; ex_bits[6]=4'b0110;
    ex_code[7]=5'd7; ex_cnt[7]=3'd4; ex_bits[7]=4'b0000;
    ex_code[8]=5'd8; ex_cnt[8]=3'd2; ex_bits[8]=4'b0000;
    ex_code[9]=5'd9; ex_cnt[9]=3'd4; ex_bits[9]=4'b0111;
    ex_code[10]=5'd10; ex_cnt[10]=3'd3; ex_bits[10]=4'b0101;
    ex_code[11]=5'd11; ex_cnt[11]=3'd4; ex_bits[11]=4'b0100;
    ex_code[12]=5'd12; ex_cnt[12]=3'd2; ex_bits[12]=4'b0011;
    ex_code[13]=5'd13; ex_cnt[13]=3'd2; ex_bits[13]=4'b0010;
    ex_code[14]=5'd14; ex_cnt[14]=3'd3; ex_bits[14]=4'b0111;
    ex_code[15]=5'd15; ex_cnt[15]=3'd4; ex_bits[15]=4'b0110;
    ex_code[16]=5'd16; ex_cnt[16]=3'd4; ex_bits[16]=4'b1101;
    ex_code[17]=5'd17; ex_cnt[17]=3'd3; ex_bits[17]=4'b0010;
    ex_code[18]=5'd18; ex_cnt[18]=3'd3; ex_bits[18]=4'b0000;
    ex_code[19]=5'd19; ex_cnt[19]=3'd1; ex_bits[19]=4'b0001;
    ex_code[20]=5'd20; ex_cnt[20]=3'd3; ex_bits[20]=4'b0001;
    ex_code[21]=5'd21; ex_cnt[21]=3'd4; ex_bits[21]=4'b0001;
    ex_code[22]=5'd22; ex_cnt[22]=3'd3; ex_bits[22]=4'b0011;
    ex_code[23]=5'd23; ex_cnt[23]=3'd4; ex_bits[23]=4'b1001;
    ex_code[24]=5'd24; ex_cnt[24]=3'd4; ex_bits[24]=4'b1011;
    ex_code[25]=5'd25; ex_cnt[25]=3'd4; ex_bits[25]=4'b1100;
    ex_code[26]=5'd31; ex_cnt[26]=3'd0; ex_bits[26]=4'b0000;
    ex_code[27]=5'd31; ex_cnt[27]=3'd4; ex_bits[27]=4'b1111;
    ex_code[28]=5'd31; ex_cnt[28]=3'd4; ex_bits[28]=4'b0101;
    ex_code[29]=5'd31; ex_cnt[29]=3'd3; ex_bits[29]=4'b1000;
    for (i = 0; i < 30; i = i + 1) begin
      cnt = ex_cnt[i]; bits = ex_bits[i]; #1;
      if (code !== ex_code[i]) begin
        $display("FAIL: cnt=%0d bits=%b -> %0d (expected %0d)", cnt, bits, code, ex_code[i]);
        errors = errors + 1;
      end
    end
    if (errors == 0) $display("tb_decoder: PASS (all 26 letters + invalid patterns)");
    else $display("tb_decoder: FAIL (%0d errors)", errors);
    $finish;
  end
endmodule
