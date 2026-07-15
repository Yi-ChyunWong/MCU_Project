`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/15 14:45:39
// Design Name: 
// Module Name: alu_tb
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

module alu_tb(
);
    logic [31:0] in1, in2;
    aluOp_t aluOp;
    logic [31:0] out; 

    initial begin
        // Test ADD operation
        in1 = 32'd10;
        in2 = 32'd5;
        aluOp = ADD;
        #10;
        $display("ADD: %d + %d = %d", in1, in2, out);

        // Test SUB operation
        aluOp = SUB;
        #10;
        $display("SUB: %d - %d = %d", in1, in2, out);

        // Test AND operation
        aluOp = AND;
        #10;
        $display("AND: %d & %d = %d", in1, in2, out);

        // Test OR operation
        aluOp = OR;
        #10;
        $display("OR: %d | %d = %d", in1, in2, out);

        // Test XOR operation
        aluOp = XOR;
        #10;
        $display("XOR: %d ^ %d = %d", in1, in2, out);

        // Test SLL operation
        aluOp = SLL;
        #10;
        $display("SLL: %d << %d = %d", in1, in2[4:0], out);

        // Test SRL operation
        aluOp = SRL;
        #10;
        $display("SRL: %d >> %d = %d", in1, in2[4:0], out);

        // Test SRA operation
        aluOp = SRA;
        #10;
        $display("SRA: %d >>> %d = %d", in1, in2[4:0], out);    

        // Test SLT operation
        aluOp = SLT;
        #10;
        $display("SLT: %d < %d = %d", in1, in2, out);

        // Test SLTU operation
        aluOp = SLTU;
        #10;
        $display("SLTU: %d < %d = %d", in1, in2, out);
        $finish;
    end

    alu uut (
        .in1(in1),
        .in2(in2),
        .aluOp(aluOp),
        .out(out)
    );




endmodule
