`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/10 18:25:32
// Design Name: 
// Module Name: test_tb
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

module test(input clk, input rstn, input [15:0] sw_i, output [15:0] led_o);

    reg ledstate;

    always@(*)
        begin
            if (sw_i[4:1] == 4'b1010) begin
                ledstate = 1'b1; 
            end
            else begin
                ledstate = 1'b0; 
            end
        end

    assign led_o[15] = ledstate;

endmodule
