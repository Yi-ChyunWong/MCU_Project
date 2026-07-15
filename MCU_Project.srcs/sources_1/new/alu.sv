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
}aluOp_t;

module alu #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] in1,
    input logic [WIDTH-1:0] in2,
    input logic [3:0] aluOp,
    output logic [WIDTH-1:0] out
);

    always_comb begin
        case(aluOp)
            ADD: out = in1 + in2;
            SUB: out = in1 - in2;
            AND: out = in1 & in2;
            OR:  out = in1 | in2;
            XOR: out = in1 ^ in2;
            SLL: out = in1 << in2[4:0];
            SRL: out = in1 >> in2[4:0];
            SRA: out = $signed(in1) >>> in2[4:0];
            SLT: out = ($signed(in1) < $signed(in2)) ? 32'b1 : 32'b0;
            SLTU: out = (in1 < in2) ? 32'b1 : 32'b0;
            default: out = 32'b0;
        endcase
    end

endmodule
