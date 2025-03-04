`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/10 11:10:40
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input rstn,
    output [7:0] disp_seg_o,
    output [7:0] disp_an_o
    );
    
wire [31:0] i_data = 32'b0111_0110_0101_0100_0011_0010_0001_0000;

test u_test (
    .clk(clk),
    .rstn(rstn),
    .i_data(i_data),
    .o_seg(disp_seg_o),
    .o_sel(disp_an_o)
);

endmodule
