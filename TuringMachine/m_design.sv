module hex_to_sevenseg (
    input logic [3:0] hexdigit,
    output logic [7:0] seg
);

    always_comb begin
        seg = '1;
        if (hexdigit == 4'h0) seg = 8'b1100_0000;
        if (hexdigit == 4'h1) seg = 8'b1111_1001;
        if (hexdigit == 4'h2) seg = 8'b1010_0100;
        if (hexdigit == 4'h3) seg = 8'b1011_0000;
        if (hexdigit == 4'h4) seg = 8'b1001_1001;
        if (hexdigit == 4'h5) seg = 8'b1001_0010;
        if (hexdigit == 4'h6) seg = 8'b1000_0010;
        if (hexdigit == 4'h7) seg = 8'b1111_1000;
        if (hexdigit == 4'h8) seg = 8'b1000_0000;
        if (hexdigit == 4'h9) seg = 8'b1001_0000;
        if (hexdigit == 4'hA) seg = 8'b1000_1000;
        if (hexdigit == 4'hB) seg = 8'b1000_0011;
        if (hexdigit == 4'hC) seg = 8'b1100_0110;
        if (hexdigit == 4'hD) seg = 8'b1010_0001;
        if (hexdigit == 4'hE) seg = 8'b1000_0110;
        if (hexdigit == 4'hF) seg = 8'b1000_1110;
    end

endmodule

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

    TuringMachine TM (.input_data(sw[3:0]), .clock(clk100), .reset(~reset_n), .state,
                      .Next(btn[0]), .Done(btn[1]), .display_out(led[10:0]), .Compute_done(led[11]));

    logic [3:0] state;

    hex_to_sevenseg hts (.hexdigit(state), .seg(display));

    assign display_sel = 4'b1110;

    assign base_led = sw[3:0];

    assign led[12] = btn[0];
    assign led[13] = btn[1];

endmodule