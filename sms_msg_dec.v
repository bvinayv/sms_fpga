`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2020 10:15:30 PM
// Design Name: 
// Module Name: sms_1
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


module sms_msg_dec( start, message, mode,
                code,//ascii notation for 16 digits needs 128 bits
                motor_status,
                ready,//start for the sms_block
                signal);  
  input start;
  input [256:1] message;
  input [1:0] mode;
  output reg [128:1] code;//ascii notation for 16 digits needs 128 bits
  output reg motor_status;
  output reg ready;//start for the sms_block
  output reg signal;
  reg [31:0]pin=32'd0;
  //code=pin4+mode2+data10
  
  always @ (message)
  if(start==1)
  begin
    if(pin == message[128:96]) 
       case(mode)
         8'd00 : begin 
                 pin=32'h31323334; //1234 in decimal
                 $display("New pin is set");
                 ready=1'b1;
                 end
         8'd01 : begin 
                  signal=1'b1;
                 end
         8'd02 : begin 
              if(motor_status==1)
                 motor_status=0;
              else
                 motor_status=1;
              end
         8'd03 : begin 
              code[80:1]=80'h31323334353637383930;
              ready=1'b1;
              end
       endcase
       code={pin,mode,code[80:1]};
       #5 ready=1'b1; //start for sms_block
     end
endmodule

