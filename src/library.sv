`default_nettype none

// parameterized library functions with parameter WIDTH (w)

module MagComp
 #(parameter w = 8)
  (input  logic [w-1:0] A, B,
   output logic AltB, AeqB, AgtB);
  
  assign AltB = A < B;
  assign AeqB = A == B;
  assign AgtB = A > B;

endmodule: MagComp


/* Sums 2 w bit inputs and uses a carry-in to compute the sum and carryout
   values. */
module Adder
 #(parameter w = 5)
  (input  logic cin, 
   input  logic [w-1:0] A, B,
   output logic cout, 
   output logic [w-1:0] sum);

  assign {cout, sum} = A + B + cin;

endmodule: Adder


module Multiplexer // choose 1 bit from w bit input
 #(parameter w = 8)
  (input  logic [w-1:0] I,
   input  logic [$clog2(w)-1:0] S,
   output logic Y);
  
  assign Y = I[S];

endmodule: Multiplexer


module Demux1to4 // choose 1 from 4 outputs to get the input
 #(parameter w = 8)
  (input  logic [w-1:0] I, 
   input  logic [1:0] S,
   output logic [w-1:0] Y0, Y1, Y2, Y3);

  always_comb begin
    Y0 = w'('b0); Y1 = w'('b0); Y2 = w'('b0); Y3 = w'('b0);
    case (S)
      2'b00: Y0 = I;
      2'b01: Y1 = I;
      2'b10: Y2 = I;
      2'b11: Y3 = I;
    endcase
  end

endmodule: Demux1to4


module Mux2to1 // choose 1 from 2 inputs
 #(parameter w = 7)
  (input  logic [w-1:0] I0, I1, 
   input  logic S,
   output logic [w-1:0] Y);

  assign Y = S ? I1 : I0;

endmodule: Mux2to1


module Mux4to1 // choose 1 from 4 inputs
 #(parameter w = 7)
  (input  logic [w-1:0] I0, I1, I2, I3,
   input  logic [1:0] S,
   output logic [w-1:0] Y);

  always_comb  begin
    if (S[1]) Y = S[0] ? I3 : I2;
    else Y = S[0] ? I1 : I0;
  end

endmodule: Mux4to1


module Decoder // converts from binary to one-hot if enabled
 #(parameter w = 8)
  (input  logic en,
   input  logic [$clog2(w)-1:0] I,
   output logic [w-1:0] D);

  assign D = en ? (w'('b1) << I) : w'('b0);

endmodule: Decoder


module DFlipFlop // stores 1 bit value
  (input  logic D,
   input  logic clock, reset_L, preset_L,
   output logic Q);

  always_ff @(posedge clock, negedge reset_L, negedge preset_L) begin
    // asynchronous reset and preset, active low
    if (~reset_L)
      Q <= 1'b0;
    else if (~preset_L)
      Q <= 1'b1;
    else
      Q <= D;
  end

endmodule: DFlipFlop


module Register // stores the value D
 #(parameter w = 8)
  (input  logic en, clear, clock,
   input  logic [w-1:0] D,
   output logic [w-1:0] Q);

  always_ff @(posedge clock) begin // synchronous clear, active high
    if (en)
      Q <= D;
    else if (clear)
      Q <= w'('b0);
  end

endmodule: Register


/* enable counting, clearning, loading a value from the D inputs and
   determine the direction of count (up or down) */
module Counter
 #(parameter w = 8)
  (input  logic en, clear, load, up, clock,
   input  logic [w-1:0] D,
   output logic [w-1:0] Q);

  always_ff @(posedge clock) begin // synchronous clear, active high
    if (clear)
      Q <= w'('b0);
    else if (load)
      Q <= D;
    else if (en && up)
      Q <= Q + 1'b1;
    else if (en && (!up))
      Q <= Q - 1'b1;
  end

endmodule: Counter


module Synchronizer // protects FSM / HW from asynchronous input signal
  (input  logic async, clock,
   output logic sync);

  logic async1;
  // synchronize input through DFF twice
  always_ff @(posedge clock)
    async1 <= async;
  
  always_ff @(posedge clock)
    sync <= async1;

endmodule: Synchronizer


/* shifts left or right only when enabled and load is not active */
module ShiftRegister_PIPO
 #(parameter w = 8)
  (input  logic en, load, left, clock,
   input  logic [w-1:0] D,
   output logic [w-1:0] Q);

  always_ff @(posedge clock) begin
    if (load)
      Q <= D;
    else if (en && left)
      Q <= Q << 1;
    else if (en && (!left))
      Q <= Q >> 1;
  end

endmodule: ShiftRegister_PIPO


/* shifts left or right, consume the bit on the serial input and place it in
   either the MSB or LSB position of the output; clear signal added */
module ShiftRegister_SIPO
 #(parameter w = 8)
  (input  logic en, clear, serial, left, clock,
   output logic [w-1:0] Q);

  always_ff @(posedge clock) begin
    if (clear)
      Q <= w'('b0);
    else if (en && left)
      Q <= {Q[w-2:0], serial};
    else if (en && (~left))
      Q <= {serial, Q[w-1:1]};
  end

endmodule: ShiftRegister_SIPO


module BarrelShiftRegister // PIPO register that shifts left
 #(parameter w = 8)
  (input  logic en, load, clock,
   input  logic [1:0] by,
   input  logic [w-1:0] D,
   output logic [w-1:0] Q);

  always_ff @(posedge clock) begin
    if (load)
        Q <= D;
    else if (en)
        Q <= Q << by;
  end

endmodule: BarrelShiftRegister


module BusDriver // control access to a shared wire or bus
 #(parameter w = 8)
  (input  logic en,
   input  logic [w-1:0] data,
   output logic [w-1:0] buff,
   inout  tri   [w-1:0] bus);
  
  assign buff = bus;
  assign bus = (en) ? data : w'('bz);

endmodule: BusDriver


module Memory // stores a number of words, conbinational read, sequential write
 #(parameter dw = 8, // size of each word
             w = 16, // number of words
             aw = $clog2(w)) // address width
  (input logic re, we, clock,
   input logic [aw-1:0] addr,
   inout tri   [dw-1:0] data);
  
  logic [dw-1:0] M[w];
  logic [dw-1:0] rData;

  assign data = (re) ? rData : dw'('bz); // put the read data on the bus

  always_ff @(posedge clock) begin
    if (we)
      M[addr] <= data; // synchronized write
  end

  always_comb
    rData = M[addr]; // conbinational read

endmodule: Memory