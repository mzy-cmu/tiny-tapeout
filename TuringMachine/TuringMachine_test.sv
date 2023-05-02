`default_nettype none

module TuringMachine_test();
  logic [3:0] input_data;
  logic clock, reset, Next, Done, Compute_done;
  logic [10:0] display;

  TuringMachine #(4, 64) dut (.display_out(display), .*);

  initial begin
    clock = 1'b0;
    forever #5 clock = ~clock;
  end

  initial begin
    $monitor($time,, "input_data = %d, next = %b, done = %b, display = %b, Compute_done = %b\n",
             input_data, Next, Done, display, Compute_done);
    reset <= 1'b1;
    Next <= 1'b0; Done <= 1'b0;
    @(posedge clock);
    reset <= 1'b0;
    input_data <= 3;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 2;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);
    
    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 3;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 2;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 2;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 3;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 2;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 3;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    input_data <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    Done <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Done <= 1'b0;
    @(posedge clock);
    @(posedge clock);

    if ((display != 11'b00000_1_11101) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b00001_1_11011) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b00011_1_10111) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b00111_1_01110) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b01111_0_11100) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b11111_1_11000) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b11111_1_10000) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b11111_1_00000) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b11111_0_00000) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b11111_1_00000) || Compute_done)
      $display("error\n");
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    Next <= 1'b0;
    @(posedge clock);
    if ((display != 11'b11111_0_00000) || (~Compute_done))
      $display("error\n");
    @(posedge clock);
    #1 $finish;
  end

endmodule: TuringMachine_test