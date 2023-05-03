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

    logic Next, Done;

    Synchronizer sync1 (.async(btn[0]), .sync(Next), .clock(clk100));
    Synchronizer sync2 (.async(btn[1]), .sync(Done), .clock(clk100));

    TuringMachine TM (.input_data, .clock(clk100), .reset(~reset_n), .currState, .read_data,
                      .Next, .Done, .display_out(led[10:0]), .Compute_done(led[11]));

    logic [3:0] currState;
    logic [3:0] input_data;
    logic [3:0] read_data;

    assign input_data = sw[3:0];

    hex_to_sevenseg hex2(.hexdigit(read_data), .seg(display));
    assign display_sel = 4'b1110;

    assign base_led = input_data;

    // logic [31:0] ctr;

    // always_ff @(posedge clk100) begin
    //     if (~reset_n) begin
    //         ctr <= 32'b0;
    //     end
    //     else begin
    //         ctr <= ctr + 1'b1;
    //         if (ctr[10]) begin
    //             display_sel <= 4'b1110;
    //             display <= display1;
    //         end else begin
    //             display_sel <= 4'b1101;
    //             display <= display2;
    //         end
    //     end
    // end

    assign led[12] = btn[0];
    assign led[13] = btn[1];
    assign led[14] = btn[2];

endmodule