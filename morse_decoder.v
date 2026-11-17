// morse_decoder.v : combinational lookup. cnt = number of symbols (1-4),
// bits = symbols right-aligned, first symbol is the most significant used bit, dash=1, dot=0.
// code: 0=A ... 25=Z, 31 = no match.
module morse_decoder(input [2:0] cnt, input [3:0] bits, output reg [4:0] code);
  always @(*) begin
    case ({cnt, bits})
      {3'd2, 4'b0001}: code = 5'd0; // A .-
      {3'd4, 4'b1000}: code = 5'd1; // B -...
      {3'd4, 4'b1010}: code = 5'd2; // C -.-.
      {3'd3, 4'b0100}: code = 5'd3; // D -..
      {3'd1, 4'b0000}: code = 5'd4; // E .
      {3'd4, 4'b0010}: code = 5'd5; // F ..-.
      {3'd3, 4'b0110}: code = 5'd6; // G --.
      {3'd4, 4'b0000}: code = 5'd7; // H ....
      {3'd2, 4'b0000}: code = 5'd8; // I ..
      {3'd4, 4'b0111}: code = 5'd9; // J .---
      {3'd3, 4'b0101}: code = 5'd10; // K -.-
      {3'd4, 4'b0100}: code = 5'd11; // L .-..
      {3'd2, 4'b0011}: code = 5'd12; // M --
      {3'd2, 4'b0010}: code = 5'd13; // N -.
      {3'd3, 4'b0111}: code = 5'd14; // O ---
      {3'd4, 4'b0110}: code = 5'd15; // P .--.
      {3'd4, 4'b1101}: code = 5'd16; // Q --.-
      {3'd3, 4'b0010}: code = 5'd17; // R .-.
      {3'd3, 4'b0000}: code = 5'd18; // S ...
      {3'd1, 4'b0001}: code = 5'd19; // T -
      {3'd3, 4'b0001}: code = 5'd20; // U ..-
      {3'd4, 4'b0001}: code = 5'd21; // V ...-
      {3'd3, 4'b0011}: code = 5'd22; // W .--
      {3'd4, 4'b1001}: code = 5'd23; // X -..-
      {3'd4, 4'b1011}: code = 5'd24; // Y -.--
      {3'd4, 4'b1100}: code = 5'd25; // Z --..
      default: code = 5'd31;
    endcase
  end
endmodule
