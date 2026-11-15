// debounce.v : output follows input only after input has been stable for CYC clocks
module debounce #(parameter CYC = 1_000_000)(
    input  wire clk, rst, din,
    output reg  dout
);
  reg s0, s1;                 // 2-flop synchronizer (input is asynchronous)
  reg [31:0] cnt;
  always @(posedge clk) begin
    s0 <= din; s1 <= s0;
    if (rst) begin dout <= 1'b0; cnt <= 0; end
    else if (s1 == dout) cnt <= 0;
    else begin
      cnt <= cnt + 1;
      if (cnt == CYC-1) begin dout <= s1; cnt <= 0; end
    end
  end
endmodule
