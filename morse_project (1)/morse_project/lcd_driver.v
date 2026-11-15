// lcd_driver.v : HD44780 1602 LCD, 4-bit mode, RW tied to GND (write only).
// put_en pulse + put_char (ASCII) writes one character. Line 1 -> line 2 -> clear, automatically.
module lcd_driver #(parameter CLK_HZ = 50_000_000)(
    input  wire       clk, rst,
    input  wire       put_en,
    input  wire [7:0] put_char,
    output reg        lcd_rs, lcd_e,
    output reg  [3:0] lcd_d              // connect to LCD D4..D7
);
  // ---- 1 microsecond tick ----
  localparam US = CLK_HZ/1_000_000;
  reg [7:0] pre; reg tick;
  always @(posedge clk) begin
    if (rst) begin pre <= 0; tick <= 0; end
    else if (pre >= US-1) begin pre <= 0; tick <= 1; end
    else begin pre <= pre + 1; tick <= 0; end
  end

  // ---- byte/nibble engine: every state lasts exactly 1 us ----
  localparam E_IDLE=0, E_SU1=1, E_E1=2, E_H1=3, E_SU2=4, E_E2=5, E_H2=6, E_WAIT=7;
  reg [2:0] es;
  reg req, rs_q, nib_q;
  reg [7:0] by_q;
  reg [15:0] dly_q, w;
  wire busy = (es != E_IDLE);
  always @(posedge clk) begin
    if (rst) begin es <= E_IDLE; lcd_e <= 0; lcd_rs <= 0; lcd_d <= 0; w <= 0; end
    else if (tick) case (es)
      E_IDLE: if (req) es <= E_SU1;
      E_SU1 : begin lcd_rs <= rs_q; lcd_d <= by_q[7:4]; es <= E_E1; end
      E_E1  : begin lcd_e <= 1; es <= E_H1; end
      E_H1  : begin lcd_e <= 0;
                if (nib_q) begin w <= dly_q; es <= E_WAIT; end else es <= E_SU2; end
      E_SU2 : begin lcd_d <= by_q[3:0]; es <= E_E2; end
      E_E2  : begin lcd_e <= 1; es <= E_H2; end
      E_H2  : begin lcd_e <= 0; w <= dly_q; es <= E_WAIT; end
      E_WAIT: if (w <= 1) es <= E_IDLE; else w <= w - 1;
    endcase
  end

  // ---- main sequencer: power-up wait, init commands, then character writes ----
  localparam M_PWR=0, M_INIT=1, M_IDLE=2, M_PUT=3, M_CMD=4;
  reg [2:0] ms; reg [15:0] pw; reg [3:0] step; reg [5:0] pos;
  reg pend; reg [7:0] pchar;

  task issue(input r, input n, input [7:0] b, input [15:0] d);
    begin rs_q <= r; nib_q <= n; by_q <= b; dly_q <= d; req <= 1'b1; end
  endtask

  always @(posedge clk) begin
    if (rst) begin ms <= M_PWR; pw <= 0; step <= 0; pos <= 0; pend <= 0; req <= 0; pchar <= 0; end
    else begin
      if (req && busy) req <= 1'b0;
      case (ms)
        M_PWR: if (tick) begin if (pw == 16'd50000) ms <= M_INIT; else pw <= pw + 1; end
        M_INIT: if (!req && !busy) begin
          case (step)
            0: issue(0,1,8'h30,4500);   // wake-up x3, then switch to 4-bit
            1: issue(0,1,8'h30,150);
            2: issue(0,1,8'h30,150);
            3: issue(0,1,8'h20,150);
            4: issue(0,0,8'h28,50);     // 4-bit, 2 lines, 5x8 font
            5: issue(0,0,8'h0C,50);     // display on, cursor off
            6: issue(0,0,8'h01,2000);   // clear
            7: issue(0,0,8'h06,50);     // entry mode: increment
            default: ms <= M_IDLE;
          endcase
          if (step <= 7) step <= step + 1;
        end
        M_IDLE: if (pend && !req && !busy) begin
          issue(1,0,pchar,50); pend <= 0; pos <= pos + 1; ms <= M_PUT;
        end
        M_PUT: if (!req && !busy) begin
          if (pos == 16)      begin issue(0,0,8'hC0,50);   ms <= M_CMD; end  // go to line 2
          else if (pos == 32) begin issue(0,0,8'h01,2000); pos <= 0; ms <= M_CMD; end // clear
          else ms <= M_IDLE;
        end
        M_CMD: if (!req && !busy) ms <= M_IDLE;
        default: ms <= M_IDLE;
      endcase
      if (put_en) begin pend <= 1'b1; pchar <= put_char; end
    end
  end
endmodule
