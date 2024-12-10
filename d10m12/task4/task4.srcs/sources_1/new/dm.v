`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/09 21:50:42
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

`include "ctrl_encode_def.v"
// data memory
module dm(
    input          clk,
    input          DMWr,
    input  [5:0]   addr,    // 地址改为6位，可以访问64个存储单元
    input  [31:0]  din,
    input [2:0]    DMType,
    output [31:0]  dout   // dout 是 wire 类型，不要使用 reg 类型
);

    reg [31:0] dd;
    reg [7:0] dmem[63:0];  // 64个存储单元，每个单元8位 (byte)

    // dm_word 3'b000
    // dm_halfword 3'b001
    // dm_halfword_unsigned 3'b010
    // dm_byte 3'b011
    // dm_byte_unsigned 3'b100

    always @(posedge clk) begin
        if (DMWr) begin
            case(DMType)
                `dm_word: begin
                    dmem[addr]   <= din[7:0];   // 存储低8位
                    dmem[addr+1] <= din[15:8];  // 存储次低8位
                    dmem[addr+2] <= din[23:16]; // 存储次高8位
                    dmem[addr+3] <= din[31:24]; // 存储高8位
                end
                `dm_halfword: begin
                    dmem[addr]   <= din[7:0];   // 存储低8位
                    dmem[addr+1] <= din[15:8];  // 存储次低8位
                end
                `dm_halfword_unsigned: begin
                    dmem[addr]   <= din[7:0];   // 存储低8位
                    dmem[addr+1] <= din[15:8];  // 存储次低8位
                end
                `dm_byte: begin
                    dmem[addr] <= din[7:0]; // 存储字节
                end
                `dm_byte_unsigned: begin
                    dmem[addr] <= din[7:0]; // 存储字节
                end
                default: begin
                    // 默认行为，不做任何操作
                end
            endcase
        end
        $display("DMTy = 0x%x,", DMType);
        $display("addr = 0x%x,", addr);
        //$display("dmem[addr] = 0x%2x", dmem[addr]);
    end
    
    always @(*) begin
        case(DMType)
            `dm_word: dd <= {dmem[addr+3], dmem[addr+2], dmem[addr+1], dmem[addr]}; // 32位数据合并
            `dm_halfword: dd <= {{16{dmem[addr+1][7]}}, dmem[addr+1], dmem[addr]};  // 符号扩展16位
            `dm_halfword_unsigned: dd <= {16'b0, dmem[addr+1], dmem[addr]};  // 无符号扩展16位
            `dm_byte: dd <= {{24{dmem[addr][7]}}, dmem[addr]};  // 符号扩展8位
            `dm_byte_unsigned: dd <= {24'b0, dmem[addr]};  // 无符号扩展8位
            default: dd <= 32'hFFFFFFFF;  // 默认输出为F
        endcase
    end

    assign dout = dd; // 通过 assign 语句进行赋值，确保 dout 为 wire 类型

endmodule
