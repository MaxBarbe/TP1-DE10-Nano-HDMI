`timescale 1ns/1ps

module testbench;

reg clk;
reg [31:0] A;
reg [31:0] B;
wire [31:0] R1;

add32 DUT (
    .clk(clk),
    .A(A),
    .B(B),
    .R1(R1)
);

always #5 clk = ~clk;   // période = 10 ns → 100 MHz

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, testbench);

    clk = 0;
    A = 0;
    B = 0;

    #10;
    A = 10;  B = 5;

    #10;
    A = 20;  B = 7;

    #10;
    A = 100; B = 50;

    #10;
    A = 32'hFFFFFFFF;
    B = 1;

    #20;
    $finish;
end

initial begin
    $monitor("t=%0t ns | A=%0d | B=%0d | R1=%0d",
             $time, A, B, R1);
end

endmodule
