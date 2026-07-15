`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/15 09:53:01
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] in1,
    input logic [WIDTH-1:0] in2,
    input logic [3:0] aluOp,
    output logic [WIDTH-1:0] out1
);

    typedef enum logic [3:0] {
        ADD,
        SUB,
        AND,
        OR,
        XOR,
        SLL,
        SRL,
        SRA,
        SLT,
        SLTU
    } aluOp_t;

endmodule
