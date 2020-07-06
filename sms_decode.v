`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 07:50:48 PM
// Design Name: 
// Module Name: sms_code
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


module sms_decode (
  input start,
  input clkb,
  input rst,
  input [15:0] data_in,
  input data_en, // when high data_in is sending 2 bytes of data 
  input [2:0]send_state, // when state is 1 only then recieve the message 
  //input motor_on,
  //output reg [7:0] data_out,
  output reg load,
  //output reg en,
  output reg motor_status =1'b0
  ); 
  //code=pin4+mode2+data10
  reg [8:0]i;
  reg [255:0] message;
  reg [7:0] pin [3:0];
  reg [7:0] mode;
  reg msg_reciv;
  //reg [7:0] ph_no[9:0];
  parameter s0=8'd30,s1=8'd31,s2=8'd32,s3=8'd33,s4=8'd34;
  //reg [7:0] ps,ns,state;
  reg [7:0]code[15:0]; 
  
  ///////// recieving message 
  always@(posedge data_en)
  begin
  if(send_state == 3'd1) begin
    i = i + 8'd1;
    if(data_in[7:0]!=8'h0D || data_in[15:8]!=8'h0D)
        begin 
        message<=data_in;
        message=message<<16;
        end
    else if(data_in[7:0]==8'h0D) begin 
        message<=data_in;
        msg_reciv = 1'b1;
        end
    else begin 
        message<=data_in;
        message = message>>8; //to make last bit 0D
        msg_reciv = 1'b1;
        end 
    if(i == 8'd3) begin
        if({pin[3],pin[2],pin[1],pin[0]} == message[31+16:0+16])
            mode = message[15:8];
        end
        
        end
  else i = 0;
  end  // for always block
  
 always @(posedge clkb)
 begin
    if(msg_reciv == 1'd1) begin
    case(mode)
        s0 : begin
            if(start)
             i=8'd3;j=8'd3;
             if(i!=0)
                 begin data_out<=pin[j];
                       i=i-1; j=j-1; 
                 end
             else 
                 begin 
                    data_out<=mode; 
                 end
            end
        s1: begin 
            i=8'd4;j=8'd3;
            if(i!=0)
             begin 
                pin[j]<=data_in;
                load=1'b1;
                load=1'b0;
                i=i-1;
                j=j-1; 
             end
            else 
              begin
                $display("New pin set");
                waitt=1'b0;
              end
            
            end
        s2: begin 
            
            end
        s3: begin 
            motor_status=~motor_status;
            en<=1'b1;
            load=1'b1;
            load=1'b0;
            waitt=1'b0;
            end
        s4: begin 
            i=8'd9;j=8'd9;
            if(i!=0)
             begin 
                code[j]<=data_in;
                en<=1'b1;
                load=1'b1;
                load=1'b0;
                i=i-1;
                j=j-1; 
             end
            else 
              begin
                $display("New number is stored");
                en<=1'b1;
                load=1'b1;
                load=1'b0;
                waitt=1'b0;
              end
            end
    endcase
    end
    end
endmodule