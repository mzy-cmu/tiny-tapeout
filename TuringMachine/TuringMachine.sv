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
   input logic clock, reset, Next, Done,
   output logic [10:0] display_out,
   output logic [3:0] currState,
   output logic display_in, tape_reg_out, data_reg_out,
   output logic [aw-1:0] next_state_out, tape_addr_out,
   output logic Compute_done);

  // control points
  logic Init, NextState_en, InputAddr_en, StateAddr_ld, StateAddr_en, TapeAddr_en, Write_en, Read_en, ReadInput, 
        PrevTape_en, TapeReg_en, DataReg_en, Direction_en, Display_en, Display_rewrite;
  logic [1:0] Addr_sel, Data_sel;

  // status points
  logic Data_eq, Halt, Left, Memory_end;

  // connecting wires
  logic [aw-1:0] next_state_prep, next_state_in, next_state_out, state_addr_in, state_addr_out, tape_addr_in, tape_addr_out, tape_init_addr, prev_tape_addr, input_addr_out, memory_addr;
  logic [dw-1:0] write_data, read_data;
  logic [1:0] direction_in, direction_out;
  logic tape_in, tape_reg_in, tape_reg_out, prev_tape_in, prev_tape_out, data_reg_in, data_reg_out, display_in;
  
  // datapath modules & connections
  Mux2to1 #(dw) mux_input_calculate (.I0(data_reg_out), .I1(input_data), .S(ReadInput), .Y(write_data));
  Counter #(aw) input_addr (.en(InputAddr_en), .clear(Init), .load(1'b0), .up(1'b1), .clock, .D(), .Q(input_addr_out));
  assign Memory_end = (tape_addr_out >= input_addr_out) || (tape_addr_out < tape_init_addr);

  assign state_addr_in = ((next_state_out + next_state_out + next_state_out - 'd3) << 1'b1) + 1'b1 + (tape_in + tape_in + tape_in);
  assign tape_addr_in = ((input_data + input_data + input_data) << 1'b1) + 1'b1;
  
  Mux2to1 #(aw) mux_next_state (.I0(next_state_prep), .I1(1'b1), .S(Init), .Y(next_state_in));
  Register #(aw) next_state (.en(NextState_en), .clear(1'b0), .clock, .D(next_state_in), .Q(next_state_out));
  
  Counter #(aw) state_addr (.en(StateAddr_en), .clear(1'b0), .load(StateAddr_ld), .up(1'b1), .clock, .D(state_addr_in), .Q(state_addr_out));
  Counter #(aw) tape_addr (.en(TapeAddr_en), .clear(1'b0), .load(Init), .up(~Left), .clock, .D(tape_addr_in), .Q(tape_addr_out));
  Register #(aw) tape_addr_init (.en(Init), .clear(1'b0), .clock, .D(tape_addr_in), .Q(tape_init_addr));
  assign prev_tape_addr = tape_addr_out - 'd11;
  
  Mux4to1 #(aw) mux_state_tape_addr (.I0(state_addr_out), .I1(tape_addr_out), .I2(prev_tape_addr), .I3(input_addr_out), .S(Addr_sel), .Y(memory_addr));
  Memory_synth #(dw, w, aw) memory (.re(Read_en), .we(Write_en), .clock, .addr(memory_addr), .data_in(write_data), .data_out(read_data));
  
  Demux1to4 #(dw) demux (.I(read_data), .S(Data_sel), .Y0(data_reg_in), .Y1(direction_in), .Y2(next_state_prep), .Y3(tape_in));
  
  Mux2to1 #(1) mux_tape_reg (.I0(tape_in), .I1(display_out[1]), .S(Left), .Y(tape_reg_in));
  Register #(1) tape_reg (.en(TapeReg_en), .clear(Init), .clock, .D(tape_reg_in), .Q(tape_reg_out));
  
  Mux2to1 #(1) mux_prev_tape (.I0(tape_in), .I1(1'b0), .S(prev_tape_addr < tape_init_addr), .Y(prev_tape_in));
  Register #(1) prev_tape_reg (.en(PrevTape_en), .clear(Init), .clock, .D(prev_tape_in), .Q(prev_tape_out));
  
  Mux2to1 #(aw) mux_display (.I0(tape_reg_out), .I1(prev_tape_out), .S(Left), .Y(display_in));
  ShiftRegister_SIPO_wRewrite #(11) display_reg (.en(Display_en), .clear(Init), .left(~Left), .rewrite(Display_rewrite), .clock, .serial(display_in), .Q(display_out));

  Register #(1) data_reg (.en(DataReg_en), .clear(Init), .clock, .D(data_reg_in), .Q(data_reg_out));
  assign Data_eq = tape_reg_out == data_reg_out;
  
  Register #(aw) direction_reg (.en(Direction_en), .clear(Init), .clock, .D(direction_in), .Q(direction_out));
  assign Left = direction_out[0];
  assign Halt = direction_out[1];

  assign Compute_done = Memory_end | Halt;
  
  // finite state machine
  FSM fsm (.*);

endmodule: TuringMachine


module FSM (
  input logic clock, reset, Next, Done,
  input logic Data_eq, Halt, Left, Memory_end,
  output logic Init, NextState_en, InputAddr_en, StateAddr_ld, StateAddr_en, TapeAddr_en, Write_en, Read_en, ReadInput, 
               PrevTape_en, TapeReg_en, DataReg_en, Direction_en, Display_en, Display_rewrite,
  output logic [1:0] Addr_sel, Data_sel,
  output logic [3:0] currState);

  enum logic [3:0] {START, WAIT, WRITE_INPUT, READ_TAPE, READ_DATA, REWRITE_TAPE, READ_DIRECTION, READ_STATE, STOP} currState, nextState;

  // next state logic
  always_comb
    case (currState)
      START: nextState = Next ? WAIT : START;
      WAIT: nextState = Next ? WRITE_INPUT : (Done ? READ_TAPE : WAIT);
      WRITE_INPUT: nextState = (~Next) ? WAIT : WRITE_INPUT;
      READ_TAPE: nextState = READ_DATA;
      READ_DATA: nextState = Next ? (Data_eq ? READ_DIRECTION : REWRITE_TAPE) : READ_DATA;
      REWRITE_TAPE: nextState = READ_DIRECTION;
      READ_DIRECTION: nextState = (~Next) ? READ_STATE : READ_DIRECTION;
      READ_STATE: nextState = Memory_end ? STOP : READ_TAPE;
      STOP: nextState = STOP;
      default: nextState = currState;
    endcase
  
  // output logic
  always_comb begin
    Init = 1'b0;
    NextState_en = 1'b0; StateAddr_ld = 1'b0; StateAddr_en = 1'b0;
    InputAddr_en = 1'b0; TapeAddr_en = 1'b0;
    Addr_sel = 2'b00; Write_en = 1'b0; Read_en = 1'b0;
    ReadInput = 1'b0; Data_sel = 2'b00;
    PrevTape_en = 1'b0; TapeReg_en = 1'b0; DataReg_en = 1'b0; Direction_en = 1'b0;
    Display_en = 1'b0; Display_rewrite = 1'b0;
    case (currState)
      START:
        if (Next) begin
          ReadInput = 1'b1;
          Write_en = 1'b1;
          Addr_sel = 2'b11;
        end else begin
          Init = 1'b1;
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
        begin
          StateAddr_en = 1'b1;
          Read_en = 1'b1;
          Data_sel = 2'b00;
          DataReg_en = 1'b1;
          Display_en = ~Halt;
        end
      READ_DATA:
        if (Next) begin
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
        end
      REWRITE_TAPE:
        begin
          StateAddr_en = 1'b1;
          Read_en = 1'b1;
          Data_sel = 2'b01;
          Direction_en = 1'b1;
        end
      READ_DIRECTION:
        if (~Next) begin
          Read_en = 1'b1;
          Data_sel = 2'b10;
          NextState_en = 1'b1;
          TapeAddr_en = ~Halt;
        end
      READ_STATE:
        if (~Memory_end) begin
          if (Left) begin
            StateAddr_ld = 1'b1;
            Addr_sel = 2'b10;
            Read_en = 1'b1;
            Data_sel = 2'b11;
            PrevTape_en = 1'b1;
            TapeReg_en = 1'b1;
          end else begin
            StateAddr_ld = 1'b1;
            Addr_sel = 2'b01;
            Read_en = 1'b1;
            Data_sel = 2'b11;
            TapeReg_en = 1'b1;
          end
        end
      // STOP outputs nothing
    endcase
  end

  // Asynchronous state reset
  always_ff @(posedge clock, posedge reset)
    if (reset)
      currState <= START;
    else
      currState <= nextState;

endmodule: FSM