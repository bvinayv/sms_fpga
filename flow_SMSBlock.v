`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.05.2020 23:10:25
// Design Name: 
// Module Name: flow_SMSBlock
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


module flow_SMSBlock(buffer,clk, rst, start, tout,
                     en, ten, odata
    );
input [7:0]buffer;  // carries the output ans from module
input clk, rst, start, tout;
output  en, ten;    
output  [7:0]odata; // commds to the module
//output reg [10*8-1:0]sender_no;
//output reg [16*8-1:0]msg;
wire [6:0] addr;
wire [7:0] rom;
wire [2:0]ctrl;
wire [8-1:0] msg_no;
reg [8-1:0]sender_no;
reg [16*8-1:0]msg;

// gives the phone no. , sms data , message no. 
atcu_string uut1(  buffer,// buffer from the UART block
               ctrl   ,  msg_no); // sent to the sms reception block
               //,sender_no      , msg
//feed msg no. get ctrl and 
sms_block_FSM uut2(clk, start, rst, msg_no, tout, ctrl, rom,  //inputs
                         en, ten, odata, addr);                //outputs
cmem uut3(addr,
      rom);

endmodule
