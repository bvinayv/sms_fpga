`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RVCE
// Engineer: Sharath
// 
// Create Date: 15.02.2020 11:03:18
// Design Name: Vinay Varma B
// Module Name: sms_block
// Project Name: IOT Module
// Target Devices: Sparton-6
// Tool Versions: Vivado
// Description: Commands to atcu from here sms initializtion block
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

     // clk for states, start for FSM, reset, no in the list of messages where it is placed, rom data from CMEM
     // for corresponding address
module sms_block_FSM(clk, start, rst, msg_no, tout, ctrl, rom,  //inputs
                         en, ten, odata, addr);                //outputs
                  // sending the data to uart en, timer, data to uart, addr for the at commands
input clk,  rst, start;// start is after the initial FSM is completed. generally its zero
input [7:0] msg_no;
//input [16*8-1:0]message;
input [2:0] ctrl; 
input[7:0] rom;
input tout;
output reg en;
output reg [6:0] addr;
output reg ten; 
output reg [7:0]odata;
reg [6:0]i;
reg [3:0] ps,ns; 
reg shift_state;
reg load; // the states of the FSM
parameter s0=0, s1=1, s2=2, s3=3, s4=4 , s5=5, s6=6,s7=7, s8=8, s9=9, s10 = 10;

reg [9*8-1:0] send[10:0];

initial 
begin
en    <= 1'b0;
odata <= 8'd0;
ten   <= 1'b0;
ns <= s0;
shift_state <= 1'b0;
end
// even states are for the recieving and
// odd for sending the information  
always@(shift_state)
    begin
    case(ps)
        s0:begin
             if(start)begin
                ns<=s1;
                i = 23;
                end
             else
                ns<=s0;
            
           end
        s1:begin // send AT+CMPS="SM","SM","SM"<CR>
            if(i != 0)
            begin
            i= i - 1;
            addr=22-i;
            #20 odata <= rom;
            en <= 1'b1;
            load = 1'b1;
            #30 load = 1'b0;
            ns <= s1;
            end
            else //if(i==0)
            begin
            ns <= s2;
            end
            
          end
       s2:begin  // check +CMPS:
            en <= 1'b0;
            ten <=1'd1;
            if(ctrl == 3'b10)
            begin //+CMPS:
            i = 34;
            ns <= s3;
            ten<=1'b0;
            end
            else if(tout == 1'b1) begin
            i = 11;
            ns <=s1;
            ten<=1'b0;            
            end
            else
            ns<= s2;
          end
       s3:begin //AT+CMGD = 1,4
            if(i != 0)
            begin
            i = i-1;
            addr=33-i;
            #20 odata <= rom;
            en <= 1'b1;
            load = 1'b1;
            #30 load = 1'b0;
            end
            else if(i==0)
            begin
            ns <= s4;
            end          
          end
       s4:begin  // check for OK<CR>
            en <= 1'b0;
            ten <=1'd1;
            if(ctrl == 3'b01)begin //ok
            i = 10;
            ns <= s5;
            ten<=1'b0;
            end
            else if(tout == 1'b1) begin
            i = 11;
            ns <=s3;
            ten<=1'b0;            
            end
            else
            ns<= s4;
          end
       s5:begin // AT+CSDH=1
            if(i != 0)
            begin
            i = i-1;
            addr=43-i;
            #20 odata <= rom;
            en <= 1'b1;
            load = 1'b1;
            #30 load = 1'b0;
            end
            else //if(i==0)
            begin
            ns <= s6;
            end
          end
       s6:begin  // check OK<CR>
            en <= 1'b0;
            ten <=1'd1;
            if(ctrl == 3'b10)begin
            i = 8;
            ns <= s9;
            ten<=1'b0;
            end
            else if(tout == 1'b1) begin
            i = 10;
            ns <=s5;
            ten<=1'b0;            
            end
            else
            ns<= s0;
          end 
       s9:begin
            if(ctrl == 3'd4) // here can add a state to reset every 1hr 
                             // since if any problem this loop wont break
                ns <= s7;
            else 
                ns <= s9;
          end
       s7:begin // AT+CMGR=
            if(i != 0)
            begin
            i = i-1;
            addr=51-i;
            #20 odata <= rom;
            en <= 1'b1;
            load = 1'b1;
            #30 load = 1'b0;
            end
            else //if(i==0)
            begin
            ns <= s8;
            end
          end
       s8:begin // message_no<CR>
            if(ctrl == 3'd4)begin
            #20 odata <= msg_no;
                en <= 1'b1;
                load = 1'b1;
            #30 load = 1'b0;
            #20 odata <= 8'h0D;
                en <= 1'b1;
                load = 1'b1;
            #30 load = 1'b0;
                ns <= s9;
                end
            else //if(i==0)
            begin
            ns <= s8;
            end
          end
        //default: ns <= s0;
    endcase
    end

always@(posedge clk or posedge rst)
begin
    if(rst) ps<=s0; else ps <=ns;
    shift_state = ~shift_state;
end

    
endmodule