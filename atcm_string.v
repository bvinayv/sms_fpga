`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RVCE
// Engineer: Vinay Varma B
// 
// Create Date: 23.01.2020 09:10:26
// Design Name: Connecting block to UART
// Module Name: atcu_rec
// Project Name: FPGA Controlled Motor
// Target Devices: Artiex-7
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


module atcu_string(
input [7:0]buffer,// buffer from the UART block
output reg [2:0]ctrl  , 
output reg [8-1:0] message_no 
);
//, output reg [16*8-1:0]msg
//, output reg [8-1:0]sender_no
//reg [2:0]ctrl;
reg [8*255-1:0] store ;
//reg [10*8-1:0]phone;
reg [12*8-1:0]sender_no; 
//reg [8-1:0] message_no;  // "SM",3
reg [20*8-1:0]msg;
reg [3:0] flag;
reg [3:0]i;
reg message_next;

initial
    begin 
        store <= 1'b0;
        i<=4'b0 ;
        message_next <=1'b0;
    end

always@(buffer) // when ever buffer is sent from UART
begin
// ctrl is for the message block to directly access this module
// flag is to work in the same module
    i = i + 4'b0001;
    store = store << 8;
    store[7:0] = buffer;
    
    if(buffer == 8'h0D)  // termination string is sent
        begin
            if((i==3)&&(store == 24'h4F4B0D))  //ok
                ctrl <= 3'd1;
            else if(flag == 1'd1)
                ctrl <= 3'd2;                 
            else if((i == 6)&&(store ==48'h4552524F520D)) //error
                ctrl <= 3'd3;
            else if(flag == 4'd3)                    //ctrl = 0,do nothing;
                begin
                sender_no <= store[8-1:0]; // output
                message_next = 1;
                end
            else if(flag == 4'd2)    
                begin                                  //       1,OK; 2,MESSAGE saving done;
                message_no <= store[23:16]; 
                ctrl <= 3'd4; 
                end                                   //       3,ERROR; 
            else if(message_next==1)                 //       4, its message
                begin
                message_next = 0;
                msg <= store[16*8-1:0];
                end
            else begin
                ctrl = 1'd0;
                flag = 1'd0;
                 end
            store = 1'd0;
            i = 0;
        end
    else if(i==6)
        begin
        if(store == "+CPMS:")  //AFTER assigning the SIM storage
            flag <= 4'd1;
        else if(store == "+CMTI:")   //message no. "SM",3
            flag <= 4'd2;
        else if(store == "+CMGR:")  //actually recving mesage
            flag <= 4'd3;
        else 
            flag <= 1'd0;        
        end
        
end
endmodule

