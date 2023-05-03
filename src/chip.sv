`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
    logic Next, Done;
    Synchronizer sync1 (.async(io_in[1]), .sync(Next), .clock);
    Synchronizer sync2 (.async(io_in[0]), .sync(Done), .clock);

    TuringMachine #(4, 64) dut (.clock, .reset, .input_data(io_in[5:2]), .Next, .Done,
                                .display_out(io_out[11:1]), .Compute_done(io_out[0]));

endmodule
