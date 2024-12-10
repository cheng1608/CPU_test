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
    input  [5:0]   addr,    // ��ַ��Ϊ6λ�����Է���64���洢��Ԫ
    input  [31:0]  din,
    input [2:0]    DMType,
    output [31:0]  dout   // dout �� wire ���ͣ���Ҫʹ�� reg ����
);

    reg [31:0] dd;
    reg [7:0] dmem[63:0];  // 64���洢��Ԫ��ÿ����Ԫ8λ (byte)

    // dm_word 3'b000
    // dm_halfword 3'b001
    // dm_halfword_unsigned 3'b010
    // dm_byte 3'b011
    // dm_byte_unsigned 3'b100

    always @(posedge clk) begin
        if (DMWr) begin
            case(DMType)
                `dm_word: begin
                    dmem[addr]   <= din[7:0];   // �洢��8λ
                    dmem[addr+1] <= din[15:8];  // �洢�ε�8λ
                    dmem[addr+2] <= din[23:16]; // �洢�θ�8λ
                    dmem[addr+3] <= din[31:24]; // �洢��8λ
                end
                `dm_halfword: begin
                    dmem[addr]   <= din[7:0];   // �洢��8λ
                    dmem[addr+1] <= din[15:8];  // �洢�ε�8λ
                end
                `dm_halfword_unsigned: begin
                    dmem[addr]   <= din[7:0];   // �洢��8λ
                    dmem[addr+1] <= din[15:8];  // �洢�ε�8λ
                end
                `dm_byte: begin
                    dmem[addr] <= din[7:0]; // �洢�ֽ�
                end
                `dm_byte_unsigned: begin
                    dmem[addr] <= din[7:0]; // �洢�ֽ�
                end
                default: begin
                    // Ĭ����Ϊ�������κβ���
                end
            endcase
        end
        $display("DMTy = 0x%x,", DMType);
        $display("addr = 0x%x,", addr);
        //$display("dmem[addr] = 0x%2x", dmem[addr]);
    end
    
    always @(*) begin
        case(DMType)
            `dm_word: dd <= {dmem[addr+3], dmem[addr+2], dmem[addr+1], dmem[addr]}; // 32λ���ݺϲ�
            `dm_halfword: dd <= {{16{dmem[addr+1][7]}}, dmem[addr+1], dmem[addr]};  // ������չ16λ
            `dm_halfword_unsigned: dd <= {16'b0, dmem[addr+1], dmem[addr]};  // �޷�����չ16λ
            `dm_byte: dd <= {{24{dmem[addr][7]}}, dmem[addr]};  // ������չ8λ
            `dm_byte_unsigned: dd <= {24'b0, dmem[addr]};  // �޷�����չ8λ
            default: dd <= 32'hFFFFFFFF;  // Ĭ�����ΪF
        endcase
    end

    assign dout = dd; // ͨ�� assign �����и�ֵ��ȷ�� dout Ϊ wire ����

endmodule
