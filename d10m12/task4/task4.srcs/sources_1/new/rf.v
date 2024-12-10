`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 18:27:58
// Design Name: 
// Module Name: 
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


module RF(
    input clk,
    input rstn,
    input RFWr,
    input [15:0]sw_i,
    input [4:0]A1,
    input [4:0]A2,
    input [4:0]A3,
    input [31:0]WD,
    output [31:0]RD1,RD2
);
reg [31:0]rf[31:0];
always@(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        rf[0]<=32'h00000000;
        rf[1]<=32'h00000001;
        rf[2]<=32'h00000002;
        rf[3]<=32'h00000003;
        rf[4]<=32'h00000004;
        rf[5]<=32'h00000005;
        rf[6]<=32'h00000006;
        rf[7]<=32'h00000007;
        rf[8]<=32'h00000008;
        rf[9]<=32'h00000009;
        rf[10]<=32'h0000000A;
        rf[11]<=32'h0000000B;
        rf[12]<=32'h0000000C;
        rf[13]<=32'h0000000D;
        rf[14]<=32'h0000000E;
        rf[15]<=32'h0000000F;
        rf[16]<=32'h00000010;
        rf[17]<=32'h00000011;
        rf[18]<=32'h00000012;
        rf[19]<=32'h00000013;
        rf[20]<=32'h00000014;
        rf[21]<=32'h00000015;
        rf[22]<=32'h00000016;
        rf[23]<=32'h00000017;
        rf[24]<=32'h00000018;
        rf[25]<=32'h00000019;
        rf[26]<=32'h0000001A;
        rf[27]<=32'h0000001B;
        rf[28]<=32'h0000001C;
        rf[29]<=32'h0000001D;
        rf[30]<=32'h0000001E;
        rf[31]<=32'h0000001F;
    end
    else
    begin
        if(RFWr && (!sw_i[1]))
        begin
            rf[A3] <= WD;
        end
    end
end
assign RD1 = rf[A1];
assign RD2 = rf[A2];
endmodule
