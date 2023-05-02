module m_design (
    input logic clk100, // 100MHz clock
    input logic reset_n, // Active-low reset

    output logic [7:0] base_led, // LEDs on the far right side of the board
    output logic [23:0] led, // LEDs in the middle of the board

    input logic [23:0] sw, // The tiny slide-switches
    input logic [4:0] btn, // The buttons

    output logic [3:0] display_sel, // Select between the 4 segments
    output logic [7:0] display // Seven-segment display
);

    TuringMachine TM (.input_data(sw[3:0]), .clock(clk100), .reset(~reset_n),
                      .Next(btn[0]), .Done(btn[1]), .display_out(led[10:0]), .Compute_done(led[11]));

endmodule