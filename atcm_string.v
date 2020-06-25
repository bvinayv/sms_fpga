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
input clk,
input wait1,
input [7:0]buffer,// buffer from the UART block
input ctrl_rst,  // send to reset the control port
input [2:0]bus_mux,// send the code to access the info
output reg [2:0]ctrl  , 
output reg [8-1:0] message_no,
output reg [2:0]send_state,
output reg data_en,
output reg [15:0]dataout
);
//, output reg [16*8-1:0]msg
//, output reg [8*12-1:0]sender_no
//reg [2:0]send_state;
reg [12*8-1:0]sender_no; 
reg [22*8-1:0]location;
reg [20*8-1:0]msg;
reg [20*8-1:0]imei;
reg [8*255-1:0] store ;
reg [3:0] flag;
reg [3:0]i;   // count for checking what data is recieved.
reg [8:0]j;   // count for sending the large date byte by byte
reg message_next;
reg imei_next;
parameter s0=0, // default state
          s1=1, // send message  
          s2=2, // send sender no.
          s3=3, // send imei  16digits
          s4=4; // send co-ordinates  

initial
    begin 
        store <= 1'b0;
        i<=4'b0 ;
        message_next <=1'b0;
        imei_next <=1'b0;
        send_state <=s0;
        data_en <= 1'b0;
        dataout <= 8'b0;
    end

always@(negedge wait1) // when ever buffer is sent from UART
begin
// ctrl is for the message block to directly access this module
// flag is to work in the same module
    i = i + 4'b0001;
    store = store << 8;
    store[7:0] = buffer;
    
    if(buffer == 8'h0D)  // termination string is sent
        begin           // after ctrl is sent we have to reset the flag bits************
            if((i==3)&&(store == 24'h4F4B0D))  //ok<CR>
                ctrl <= 3'd1;
            else if(flag == 1'd1)
                ctrl <= 3'd2;                 
            else if((i == 6)&&(store ==48'h4552524F520D)) //error
                ctrl <= 3'd3;
            else if(flag == 4'd3)                    //ctrl = 0,do nothing;
                begin
                sender_no <= store[8*12-1:0]; // output
                message_next = 1;
                flag <= 3'd0;
                end
            else if(flag == 4'd4)                    //ctrl = 0,do nothing;
                begin
                location <= store[8*22-1+34:0+34]; // output
                imei_next <= 1;
                flag <= 3'd0;
                send_state = s4;
                j<=16;
                end
            else if(flag == 4'd2)    
                begin                                  //       1,OK; 2,MESSAGE saving done;
                message_no <= store[15:8]; 
                ctrl <= 3'd4; 
                flag <= 3'd0;
                end                                   //       3,ERROR; 
            else if(message_next==1)                 //       4, its message
                begin
                message_next = 0;
                msg <= store[20*8-1:0];     //store with <CR>
                send_state = s1;
                j<=11; // since sending 2 bytes at a time
                end
            else if(imei_next==1)                 //       4, its message
                begin
                imei_next = 0;
                imei <= store[20*8-1:0];
                send_state = s3;
                j<=9;
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
        else if(store == "+QGPSL")  //actually recving LOC
            flag <= 4'd4;
        else 
            flag <= 1'd0;        
        end
    else
        ctrl <= 1'd0;
        
end

// sending one of message, imei, sender no., location
always@(posedge clk)
begin
    if(send_state == s0)
    begin
        send_state <= bus_mux; 
        case(bus_mux)
            s1: j=11; 
            s2: j=6;
            s3: j=9;
            s4: j=16;
            default: j=0;
        endcase
    end
    else 
        send_state = send_state;
    if(ctrl_rst)
        ctrl <= 3'd0;
    else ctrl <= ctrl;

case(send_state)
    s1: begin
            j = j - 8'd1;
            if(j != 0)
            begin
            data_en = 1;
            dataout = msg[20*8-1:18*8];
            msg = msg<<16;
            data_en = 0;
            end
            else
            send_state <= s0;            
        end
    s2: begin
            j = j - 8'd1;
            if(j != 0)
            begin
            data_en = 1;
            dataout = sender_no[12*8-1:10*8];
            sender_no = sender_no<<16;
            data_en = 0;
            end
            else
            send_state <= s0;            
        end
    s3: begin
            j = j - 8'd1;
            if(j != 0)
            begin
            data_en = 1;
            dataout = imei[20*8-1:18*8];
            imei = imei<<16;
            data_en = 0;
            end
            else
            send_state <= s0;            
        end
    s4: begin
            j = j - 8'd1;
            if(j != 0)
            begin
            data_en = 1;
            dataout = location[22*8-1:20*8];
            location = location<<16;
            data_en = 0;
            end
            else
            send_state <= s0;            
        end
    default: j=0;
endcase
end
endmodule

