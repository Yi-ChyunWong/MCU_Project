`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/14 10:13:37
// Design Name: 
// Module Name: addOne_tb
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


module addOne_tb(

    );
    logic a, b;
    addOne aa (a, b);
    
    initial begin
        a = 1;
        #10
        a = 0;
        #10
        $finish;
    end
    
endmodule
