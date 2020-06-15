`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.02.2020 08:03:58
// Design Name: 
// Module Name: cmem
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

module cmem(in,
            y);
input[6:0] in;
output[7:0] y;
reg[7:0] rom[84:0];
reg[7:0] mem;

initial
begin
mem=8'b0;
// 1  AT+CMPS="SM","SM","SM"<CR> ....... 41 54 2B 43 4D 50 53 3D 22 53 4D 22 2C 22 53 4D 22 2C 22 53 4D 22 0D
rom[0]=8'h41;
rom[1]=8'h54;
rom[2]=8'h2b;
rom[3]=8'h43;
rom[4]=8'h4d;
rom[5]=8'h50;
rom[6]=8'h53;
rom[7]=8'h3d;
rom[8]=8'h22;
rom[9]=8'h53;

rom[10]=8'h4d;
rom[11]=8'h22;
rom[12]=8'h2c;
rom[13]=8'h22;
rom[14]=8'h53;
rom[15]=8'h4d;
rom[16]=8'h22;
rom[17]=8'h2c;
rom[18]=8'h22;
rom[19]=8'h53;

rom[20]=8'h4d;
rom[21]=8'h22;
rom[22]=8'h0d;

//2. AT+CMGD=1,4.... 41 54 2B 43 4D 47 44 3D 31 2C 34 0D
rom[23]=8'h41;
rom[24]=8'h54;
rom[25]=8'h2b;
rom[26]=8'h43;
rom[27]=8'h4d;
rom[28]=8'h47;  
rom[29]=8'h3d;
rom[30]=8'h31;
rom[31]=8'h2c;
rom[32]=8'h34;
rom[33]=8'h0d;

//3. AT+CSDH=1  .... 41 54 2B 43 53 44 48 3D 31 0d
rom[34]=8'h41;
rom[35]=8'h54;
rom[36]=8'h2b;
rom[37]=8'h43;
rom[38]=8'h53;
rom[39]=8'h44;
rom[40]=8'h48;
rom[41]=8'h3d;
rom[42]=8'h31;
rom[43]=8'h0d;

//4. AT+CMGR=  .... 41 54 2B 43 4D 47 52 3D
rom[44]=8'h41;
rom[45]=8'h54;
rom[46]=8'h2b;
rom[47]=8'h43;
rom[48]=8'h4d;
rom[49]=8'h47;
rom[50]=8'h52;
rom[51]=8'h3d;

end

always @(in)
mem<=rom[in];

assign y=mem;
endmodule

/*
rom[52]=8'h54;
rom[53]=8'h2b;
rom[54]=8'h51;
rom[55]=8'h47;
rom[56]=8'h50;
rom[57]=8'h53;
rom[58]=8'h4c;
rom[59]=8'h4f;
rom[60]=8'h43;
rom[61]=8'h0d;
rom[62]=8'h41;
rom[63]=8'h54;
rom[64]=8'h2b;
rom[65]=8'h43;
rom[66]=8'h4d;
rom[67]=8'h47;
rom[68]=8'h46;
rom[69]=8'h3d;
rom[70]=8'h01;
rom[71]=8'h0d;
rom[72]=8'h41;
rom[73]=8'h54;
rom[74]=8'h2b;
rom[75]=8'h43;
rom[76]=8'h50;
rom[77]=8'h4d;
rom[78]=8'h53;
rom[79]=8'h3d;
rom[80]=8'h22;
rom[81]=8'h53;
rom[82]=8'h4d;
rom[83]=8'h22;
rom[84]=8'h0d;
*/

