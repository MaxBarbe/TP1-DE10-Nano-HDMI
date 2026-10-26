module add32 (
    input  wire        clk,
    input  wire [31:0] A,
    input  wire [31:0] B,
    output reg  [31:0] R1
);

always @(posedge clk)
    R1 <= A + B;

endmodule
