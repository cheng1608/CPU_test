`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/10 10:27:17
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


module test_tb();

reg clk, rstn;
reg [15:0] sw_i;
wire [15:0] led_o;
integer foutput, counter;

// instance
test u_test(.clk(clk), .rstn(rstn), .sw_i(sw_i), .led_o(led_o));

// initial ,rstn produce
initial begin
    counter = 0;
    clk = 1;
    rstn = 1;
    sw_i = 16'b0000_0000_0001_0100;
    foutput = $fopen("results.txt");
    #5;
    rstn = 0;
    #20;
    rstn = 1;
end

// clk produce
always begin
    #50 clk = ~clk;
    if (clk == 1'b1) begin
        $fdisplay(foutput, "led_o:\t %b", led_o);
        $display("led_o:\t %b", led_o);
        $display("counter: %h", counter);
        counter = counter + 1;
    end else if (counter > 1000) begin
        $fclose(foutput);
        $stop;
    end else
        counter = counter;
end

endmodule

