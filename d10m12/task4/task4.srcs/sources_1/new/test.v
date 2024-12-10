`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 19:01:41
// Design Name: 
// Module Name: test
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

module SCPU_TOP(
    input clk,
    input rstn,
    input [15:0]sw_i,
    output [7:0]disp_an_o,
    output [7:0]disp_seg_o
);
reg [31:0]clkdiv;
wire Clk_CPU;
always@(posedge clk or negedge rstn)
begin
    if(!rstn)
        clkdiv <= 0;
    else
        clkdiv <= clkdiv + 1'b1;
end
assign Clk_CPU = (sw_i[15])?clkdiv[27]:clkdiv[25];


reg [63:0]display_data;
reg [4:0]led_data_addr;
reg [63:0]led_disp_data;

parameter LED_DATA_NUM=19;
reg [63:0]LED_DATA[18:0];

parameter ROM_DATA_NUM=11;
reg [3:0]rom_addr; //2^4=16

parameter REG_DATA_NUM=32;
reg [4:0]reg_addr;

parameter ALU_DATA_NUM=4;
reg [1:0]alu_addr;

parameter DM_DATA_NUM=16;//只显示前16个单元,其实有2^8个
reg [5:0]dm_addr;

//////////////////////////////////////////////////////////////////////////////////

initial begin
    LED_DATA[0] = 64'hC6F6F6F0C6F6F6F0;
    LED_DATA[1] = 64'hF9F6F6CFF9F6F6CF;
    LED_DATA[2] = 64'hFFC6F0FFFFC6F0FF;
    LED_DATA[3] = 64'hFFC0FFFFFFC0FFFF;
    LED_DATA[4] = 64'hFFA3FFFFFFA3FFFF;
    LED_DATA[5] = 64'hFFFFA3FFFFFFA3FF;
    LED_DATA[6] = 64'hFFFF9CFFFFFF9CFF;
    LED_DATA[7] = 64'hFF9EBCFFFF9EBCFF;
    LED_DATA[8] = 64'hFF9CFFFFFF9CFFFF;
    LED_DATA[9] = 64'hFFC0FFFFFFC0FFFF;
    LED_DATA[10] = 64'hFFA3FFFFFFA3FFFF;
    LED_DATA[11] = 64'hFFA7B3FFFFA7B3FF;
    LED_DATA[12] = 64'hFFC6F0FFFFC6F0FF;
    LED_DATA[13] = 64'hF9F6F6CFF9F6F6CF;
    LED_DATA[14] = 64'h9EBEBEBC9EBEBEBC;
    LED_DATA[15] = 64'h2737373327373733;
    LED_DATA[16] = 64'h505454EC505454EC;
    LED_DATA[17] = 64'h744454F8744454F8;
    LED_DATA[18] = 64'h0062080000620800;
end

//////////////////////////////////////////////////////////////////////////////////

reg [31:0]reg_data;
reg [4:0]rs1,rs2;
reg [4:0]rd;
reg [31:0]WD;
reg RegWrite;
wire [31:0]RD1,RD2;
reg [31:0]A,B;
reg [1:0]ALUOp;
wire Zero;
 
reg   MemWrite;
reg [31:0]    dm_addr, dm_din;
wire [31:0]dm_dout;
reg [2:0] dm_type;

//////////////////////////////////////////////////////////////////////////////////

always @(posedge clk)
begin
    //rf
    if(sw_i[13]== 1'b1)begin
        rd = sw_i[10:6];//10-6RD寄存器号
        WD = sw_i[5:3];//5-3WD 数据
        RegWrite = sw_i[2];//RegWrite信号
    end
    
    //alu
    else if(sw_i[12] == 1'b1)begin
        if(sw_i[2] == 1'b0)//读寄存器
        begin 
            rs1 = sw_i[10:8];
            rs2 = sw_i[7:5];
            A = RD1;
            B = RD2;
        end
        else//写寄存器
        begin
            rd = sw_i[10:8];
            if(sw_i[7]==1'b1)
                WD={28'hFFFFFFF,1'b1,sw_i[7:5]};
            else
                WD={28'h0000000,1'b0,sw_i[7:5]};
        end
        RegWrite = sw_i[2];
        ALUOp = sw_i[4:3];
    end
    
    //dm
    else if(sw_i[11] == 1'b1)begin
        dm_type=sw_i[4:3];
        MemWrite=sw_i[3];
        dm_din=sw_i[7:5];
    end
end

wire [31:0]aluout;

//////////////////////////////////////////////////////////////////////////////////
/*
ctrl U_ctrl(
.Op(Op), 
.Funct7(Funct7), 
.Funct3(Funct3), 
.Zero(Zero), 
.RegWrite(RegWrite), 
.MemWrite(mem_w),
.EXTOp(EXTOp), 
.ALUOp(ALUOp), 
.NPCOp(NPCOp), 
.ALUSrc(ALUSrc), 
.GPRSel(GPRSel), 
.WDSel(WDSel), 
.DMType(DMType)
	);
*/
//实例化RF
RF U_RF(
.clk(Clk_CPU),
.rstn(rstn)
,.RFWr(RegWrite),
.sw_i(sw_i),
.A1(rs1),
.A2(rs2)
,.A3(rd),
.WD(WD),
.RD1(RD1),
.RD2(RD2));

//实例化ALU
reg [31:0]alu_disp_data;

alu U_alu(
.A(A),
.B(B),
.ALUOp(ALUOp),
.C(aluout),
.Zero(Zero));

//实例化DM
reg [31:0]dmem_data;

dm U_DM(
.clk(clk),           // input:  cpu clock
.DMWr(MemWrite),     // input:  ram write
.addr(dm_addr[5:0]), // input:  ram address
.DMType(dm_type[2:0]),
.din(dm_din),        // input:  data to ram
.dout(dm_dout)       // output: data from ram
);



//////////////////////////////////////////////////////////////////////////////////


always @(posedge Clk_CPU or negedge rstn)
begin
    if(!rstn)begin
        rom_addr = 4'b0;
        reg_addr = 5'b0;
        alu_addr = 2'b0;
        led_data_addr = 5'd0;
        led_disp_data = 64'b1;
    end
    
    else if(sw_i[0] == 1'b1)begin
        if(led_data_addr == LED_DATA_NUM)begin
            led_data_addr=5'd0;
            led_disp_data=64'b1;
        end
        led_disp_data=LED_DATA[led_data_addr];
        led_data_addr=led_data_addr+1;
    end
    else begin
    //显示ROM
        if(sw_i[14] == 1'b1)begin
            if(rom_addr == ROM_DATA_NUM)
                rom_addr = 4'b0;
            else
            if (sw_i[1] == 1'b0)begin
                rom_addr = rom_addr+1'b1;
            end
        end
        
        //显示RM
        else if(sw_i[13]==1'b1) begin
            if(reg_addr==REG_DATA_NUM) begin
                reg_addr=5'b0;
            end    
            else begin
                reg_data=U_RF.rf[reg_addr];
                reg_addr=reg_addr+1'b1;
            end
        end
        
        else if(sw_i[12] == 1'b1)//进行ALU运算
        begin
            if(alu_addr == ALU_DATA_NUM)
            alu_addr = 2'b0;
            else begin
                case(alu_addr)
                2'b00:alu_disp_data=U_alu.A;
                2'b01:alu_disp_data=U_alu.B;
                2'b10:alu_disp_data=U_alu.C;
                2'b11:alu_disp_data=U_alu.Zero;
                endcase
                alu_addr=alu_addr+1'b1;
            end
        end
        
        else if(sw_i[11] == 1'b1)//显示DM
        begin
            if(dm_addr == DM_DATA_NUM)
            dm_addr=5'b0;
            else begin
                dmem_data=U_DM.dmem[dm_addr];
                dm_addr=dm_addr+1;
            end
        end
    end
end

wire [31:0]instr;
dist_mem_gen_0 U_IM(.a(rom_addr),.spo(instr));



always@(sw_i)
begin
    if(sw_i[0]==1'b0)
    begin
        case(sw_i[14:11])
            4'b1000:display_data=instr;
            4'b0100:display_data=reg_data;
            4'b0010:display_data=alu_disp_data;
            4'b0001:display_data=dmem_data;
            default:display_data=32'h01145140;
        endcase
    end
    else
    begin
        display_data=led_disp_data;
    end
end


seg7x16 u_seg7x16(.clk(clk),.rstn(rstn),.i_data(display_data),.disp_mode(sw_i[0]),.o_seg(disp_seg_o),.o_sel(disp_an_o));


endmodule
