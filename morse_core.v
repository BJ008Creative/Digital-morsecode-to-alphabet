// morse_core.v : press-duration timing, dot/dash decision, symbol register, gap detection
module morse_core #(
    parameter DASH_CYC   = 15_000_000,  // press >= this many clocks -> dash
    parameter LETTER_CYC = 35_000_000,  // silence >= this -> letter finished
    parameter WORD_CYC   = 90_000_000   // silence >= this -> word finished
)(
    input  wire       clk, rst,
    input  wire       tap,              // debounced, 1 = pressed
    output reg        letter_valid,     // 1-clock pulse when a letter is ready
    output reg  [4:0] letter_code,      // 0=A..25=Z, 31=error
    output reg        space_pulse,      // 1-clock pulse at word gap
    output reg        last_is_dash,     // debug: last symbol type
    output reg  [2:0] sym_cnt           // debug: symbols entered so far
);
  localparam S_IDLE = 2'd0, S_PRESS = 2'd1, S_GAP = 2'd2;
  reg [1:0]  st;
  reg [31:0] dur;                       // press length, then gap length
  reg [3:0]  bits;
  reg        err, sent_letter;
  wire [4:0] dec_code;
  morse_decoder dec(.cnt(sym_cnt), .bits(bits), .code(dec_code));

  always @(posedge clk) begin
    letter_valid <= 1'b0;
    space_pulse  <= 1'b0;
    if (rst) begin
      st <= S_IDLE; dur <= 0; bits <= 0; sym_cnt <= 0;
      err <= 0; sent_letter <= 0; last_is_dash <= 0; letter_code <= 0;
    end else case (st)
      S_IDLE: if (tap) begin st <= S_PRESS; dur <= 0; end

      S_PRESS: begin
        if (tap) begin
          if (dur != 32'hFFFFFFFF) dur <= dur + 1;     // measure press length
        end else begin                                 // released: classify
          last_is_dash <= (dur >= DASH_CYC);
          if (sym_cnt == 3'd4) err <= 1'b1;            // more than 4 symbols
          else begin
            bits    <= {bits[2:0], (dur >= DASH_CYC)}; // shift in 0=dot 1=dash
            sym_cnt <= sym_cnt + 1;
          end
          st <= S_GAP; dur <= 0;                       // reuse counter for gap
        end
      end

      S_GAP: begin
        if (tap) begin st <= S_PRESS; dur <= 0; end
        else begin
          dur <= dur + 1;
          if (dur == LETTER_CYC-1 && sym_cnt != 0) begin   // letter gap
            letter_code  <= err ? 5'd31 : dec_code;
            letter_valid <= 1'b1;
            sym_cnt <= 0; bits <= 0; err <= 0; sent_letter <= 1'b1;
          end
          if (dur == WORD_CYC-1) begin                     // word gap
            if (sent_letter) space_pulse <= 1'b1;
            sent_letter <= 1'b0;
            st <= S_IDLE;
          end
        end
      end
      default: st <= S_IDLE;
    endcase
  end
endmodule
