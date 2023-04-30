`default_nettype none

module ShiftRegister_SIPO_wRewrite
 #(parameter w = 8)
  (input  logic en, clear, serial, left, rewrite, clock,
   output logic [w-1:0] Q);

  always_ff @(posedge clock) begin
    if (clear)
      Q <= w'('b0);
    else if (rewrite)
      Q <= {Q[w-1:1], ~Q[0]};
    else if (en && left)
      Q <= {Q[w-2:0], serial};
    else if (en && (~left))
      Q <= {serial, Q[w-1:1]};
  end

endmodule: ShiftRegister_SIPO_wRewrite

module TuringMachine
 #(parameter dw = 4, // size of each word
             w = 64, // number of words
             aw = $clog2(w))
  (input logic [dw-1:0] input_data,
   input logic clock, Reset, Next, Done,
   output logic [10:0] display,
   output logic Compute_done);

  // control points
  logic NextState_en, NextState_init, InputAddr_en, InputAddr_clr, StateAddr_ld, StateAddr_en, TapeAddr_en, TapeAddr_ld,
        Write_en, Read_en, ReadInput, TapeReg_en, TapeReg_clr, DataReg_en, DataReg_clr, Display_en, Display_clr, Display_rewrite, Direction_en, Compute_done;
  logic [1:0] Data_sel, Addr_sel;

  // status points
  logic Data_eq, Halt, Right, Memory_end;

  // connecting wires
  logic [aw-1:0] next_state_in, next_state_out, next_state_prep, state_addr_in, state_addr_out, tape_addr_in, tape_addr_out, input_addr_out, memory_addr;
  logic [dw-1:0] write_data, read_data;
  tri   [dw-1:0] memory_data;
  logic [1:0] direction_in, direction_out;
  logic tape_reg_in, tape_reg_out, data_reg_in, data_reg_out;
  
  // datapath modules & connections
  Mux2to1 #(dw) mux_input_calculate (.I0(data_reg_out), .I1(input_data), .S(ReadInput), .Y(write_data));
  Mux2to1 #(aw) mux_next_state (.I0(next_state_prep), .I1(1'b1), .S(NextState_init), .Y(next_state_in));
  Mux4to1 #(aw) mux_state_tape_addr (.I0(state_addr_out), .I1(tape_addr_out), .I2(tape_addr_out - 'd6), .I3(input_addr_out), .S(Addr_sel), .Y(memory_addr));

  assign state_addr_in = ((next_state_out + next_state_out + next_state_out - 'd3) << 1'b1) + 1'b1 + (tape_reg_in + tape_reg_in + tape_reg_in);
  assign tape_addr_in = ((input_data + input_data + input_data) << 1'b1) + 1'b1;

  Counter #(aw) state_addr (.en(StateAddr_en), .clear(1'b0), .load(StateAddr_ld), .up(1'b1), .clock, .D(state_addr_in), .Q(state_addr_out));
  Counter #(aw) tape_addr (.en(TapeAddr_en), .clear(1'b0), .load(TapeAddr_ld), .up(Right), .clock, .D(tape_addr_in), .Q(tape_addr_out));

  Counter #(aw) input_addr (.en(InputAddr_en), .clear(InputAddr_clr), .load(1'b0), .up(1'b1), .clock, .D(), .Q(input_addr_out));
  assign Memory_end = memory_data == input_addr_out;

  BusDriver #(dw) busdriver (.en(Write_en), .data(write_data), .buff(read_data), .bus(memory_data));

  Memory #(dw, w, aw) memory (.re(Read_en), .we(Write_en), .clock, .addr(memory_addr), .data(memory_data));

  Demux1to4 #(dw) demux (.I(read_data), .S(Data_sel), .Y0(data_reg_in), .Y1(direction_in), .Y2(next_state_prep), .Y3(tape_reg_in));

  assign Right = direction_out[0];
  assign Halt = direction_out[1];

  ShiftRegister_SIPO_wRewrite #(11) display_reg (.en(Display_en), .clear(Display_clr), .left(Right), .rewrite(Display_rewrite), .clock, .serial(tape_reg_out), .Q(display));

  Register #(1) tape_reg (.en(TapeReg_en), .clear(TapeReg_clr), .clock, .D(tape_reg_in), .Q(tape_reg_out));
  Register #(1) data_reg (.en(DataReg_en), .clear(DataReg_clr), .clock, .D(data_reg_in), .Q(data_reg_out));
  Register #(aw) next_state (.en(NextState_en), .clear(1'b0), .clock, .D(next_state_in), .Q(next_state_out));
  Register #(aw) direction_reg (.en(Direction_en), .clear(1'b0), .clock, .D(direction_in), .Q(direction_out));

  assign Data_eq = tape_reg_out == data_reg_out;

  // finite state machine
  FSM fsm (.*);

endmodule: TuringMachine


module FSM (
  input logic clock, Reset, Next, Done,
  input logic Data_eq, Halt, Right, Memory_end,
  output logic NextState_en, NextState_init, InputAddr_en, InputAddr_clr, StateAddr_ld, StateAddr_en, TapeAddr_en, TapeAddr_ld,
               Write_en, Read_en, ReadInput, TapeReg_en, TapeReg_clr, DataReg_en, DataReg_clr, Display_en, Display_clr, Display_rewrite, Direction_en, Compute_done,
  output logic [1:0] Addr_sel, Data_sel);

  enum logic [3:0] {START, WAIT, WRITE_INPUT, READ_TAPE, READ_DATA, REWRITE_TAPE, READ_DIRECTION, MOVE_LEFT, READ_STATE, STOP} currState, nextState;

  // next state logic
  always_comb
    case (currState)
      START: nextState = Next ? WAIT : START;
      WAIT:
        begin
          if (Next) nextState = WRITE_INPUT;
          else if (Done) nextState = READ_TAPE;
          else nextState = WAIT;
        end
      WRITE_INPUT: nextState = (~Next) ? WAIT : WRITE_INPUT;
      READ_TAPE: nextState = Memory_end ? STOP : READ_DATA;
      READ_DATA: nextState = Data_eq ? READ_DIRECTION : REWRITE_TAPE;
      REWRITE_TAPE: nextState = READ_DIRECTION;
      READ_DIRECTION:
        begin
          if (~Next) nextState = READ_DIRECTION;
          else if (~Right) nextState = MOVE_LEFT;
          else if (Halt) nextState = STOP;
          else nextState = READ_STATE;
        end
      MOVE_LEFT: nextState = READ_STATE;
      READ_STATE: nextState = (~Next) ? READ_TAPE : READ_STATE;
      STOP: nextState = STOP;
      default: nextState = currState;
    endcase
  
  // output logic
  always_comb begin
    NextState_en = 1'b0; NextState_init = 1'b0;
    InputAddr_en = 1'b0; InputAddr_clr = 1'b0;
    StateAddr_ld = 1'b0; StateAddr_en = 1'b0;
    TapeAddr_en = 1'b0; TapeAddr_ld = 1'b0;
    Addr_sel = 2'b00; Write_en = 1'b0; Read_en = 1'b0;
    ReadInput = 1'b0; Data_sel = 2'b00;
    TapeReg_en = 1'b0; TapeReg_clr = 1'b0;
    DataReg_en = 1'b0; DataReg_clr = 1'b0;
    Display_en = 1'b0; Display_clr = 1'b0; Display_rewrite = 1'b0;
    Direction_en = 1'b0;
    Compute_done = 1'b0;
    case (currState)
      START:
        if (Next) begin
          ReadInput = 1'b1;
          Write_en = 1'b1;
          Addr_sel = 2'b11;
        end else begin
          InputAddr_clr = 1'b1;
          TapeAddr_ld = 1'b1;
          TapeReg_clr = 1'b1;
          DataReg_clr = 1'b1;
          Display_clr = 1'b1;
          NextState_init = 1'b1;
          NextState_en = 1'b1;
        end
      WAIT:
        if (Next) begin
          ReadInput = 1'b1;
          Write_en = 1'b1;
          InputAddr_en = 1'b1;
          Addr_sel = 2'b11;
        end else if (Done) begin
          StateAddr_ld = 1'b1;
          Addr_sel = 2'b01;
          Read_en = 1'b1;
          Data_sel = 2'b11;
          TapeReg_en = 1'b1;
        end
      // WRITE_INPUT outputs nothing
      READ_TAPE:
        if (~Memory_end) begin
          StateAddr_en = 1'b1;
          Read_en = 1'b1;
          Data_sel = 2'b00;
          DataReg_en = 1'b1;
          Display_en = 1'b1;
        end
      READ_DATA:
        if (Data_eq) begin
          StateAddr_en = 1'b1;
          Read_en = 1'b1;
          Data_sel = 2'b01;
          Direction_en = 1'b1;
        end else begin
          Addr_sel = 2'b01;
          Write_en = 1'b1;
          Display_rewrite = 1'b1;
        end
      REWRITE_TAPE:
        begin
          StateAddr_en = 1'b1;
          Read_en = 1'b1;
          Data_sel = 2'b01;
          Direction_en = 1'b1;
        end
      READ_DIRECTION:
        if (~Right) begin
          Read_en = 1'b1;
          Addr_sel = 2'b10;
          Data_sel = 2'b11;
          TapeReg_en = 1'b1;
        end else if (Next & (~Halt)) begin
          Read_en = 1'b1;
          Data_sel = 2'b10;
          NextState_en = 1'b1;
          TapeAddr_en = 1'b1;
        end
      MOVE_LEFT:
        begin
          Read_en = 1'b1;
          Data_sel = 2'b10;
          NextState_en = 1'b1;
          TapeAddr_en = 1'b1;
          Display_en = 1'b1;
        end
      READ_STATE:
        if (~Next) begin
          StateAddr_ld = 1'b1;
          Addr_sel = 2'b01;
          Read_en = 1'b1;
          Data_sel = 2'b11;
          TapeReg_en = 1'b1;
        end
      STOP:
        Compute_done = 1'b1;
    endcase
  end

  // Asynchronous state reset
  always_ff @(posedge clock, posedge Reset)
    if (Reset)
      currState <= START;
    else
      currState <= nextState;

endmodule: FSM