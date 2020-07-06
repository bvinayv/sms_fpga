`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2020 11:07:14
// Design Name: 
// Module Name: sms_integrated
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


module sms_integrated(buffer,clk, rst, start, tout, wai, wait1,bus_mux,
                     en, ten, odata,
                     send_state, data_en , dataout, motor_status, data_out_i2c, load);
                     
input [7:0]buffer;  // carries the output ans from UART
input clk, rst, start, tout, wai;// for the UART bus
input wait1;// signal for the data to be ready at the output
input [2:0]bus_mux;
output en, ten;    
output [7:0]odata; // commds to the module
output [2:0]send_state;
output data_en;
output [15:0]dataout;
output motor_status;
output [7:0] data_out_i2c;
output load; 
//output reg [10*8-1:0]sender_no;
//output reg [16*8-1:0]msg;
wire [6:0] addr;
wire [7:0] rom;
wire [2:0]ctrl;
wire [8-1:0] msg_no;
wire ctrl_rst;


// gives the phone no. , sms data , message no. 
atcu_string a1( rst, clk, wait1, buffer, ctrl_rst,bus_mux,// buffer from the UART block
               ctrl   ,  msg_no,
               send_state, data_en, dataout); // sent to the sms reception block
               //,sender_no      , msg
//feed msg no. get ctrl and 
sms_block_FSM a2( clk, start, rst, msg_no, tout, ctrl,wai, rom,  //inputs
                         en, ten, odata, addr, ctrl_rst ,load);                //outputs
                         
sms_decode_v2 a3(start,clk,rst,dataout,data_en,send_state,data_out_i2c,load,motor_status);

cmem_sms a4(addr,
      rom);

endmodule
