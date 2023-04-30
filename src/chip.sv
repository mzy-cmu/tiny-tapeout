`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
    logic [3:0] input_data;
    logic Next, Done;
    logic [10:0] display;
    logic Compute_done;

    assign input_data = io_in[5:2];
    assign Next = io_in[1];
    assign Done = io_in[0];
    assign io_out[11:1] = display;
    assign io_out[0] = Compute_done;

    TuringMachine #(4, 64) dut (.*);

endmodule
