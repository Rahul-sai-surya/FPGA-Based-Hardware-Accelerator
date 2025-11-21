`timescale 1ns / 1ps

module uart_bram_reader(
input clk,
input reset,
input busy,
input start,
input signed [22:0] out_unit1,
input signed [22:0] out_unit2,
input signed [22:0] out_unit3,
input signed [22:0] out_unit4,
input signed [22:0] out_unit5,
input signed [22:0] out_unit6,
input signed [22:0] out_unit7,
input signed [22:0] out_unit8,
output reg send = 1'b0,
output reg bram_read_complete = 1'b0,
output reg bram_read_complete1 = 1'b0,
output reg bram_read_complete2 = 1'b0,
output reg bram_read_complete3 = 1'b0,
output reg bram_read_complete4 = 1'b0,
output reg bram_read_complete5 = 1'b0,
output reg bram_read_complete6 = 1'b0,
output reg bram_read_complete7 = 1'b0,
output reg bram_read_complete8 = 1'b0,
output reg [15:0] strip1_image_read_count,
output reg [15:0] strip2_image_read_count =16'd0,
output reg [15:0] strip3_image_read_count =16'd0,
output reg [15:0] strip4_image_read_count =16'd0,
output reg [15:0] strip5_image_read_count =16'd0,
output reg [15:0] strip6_image_read_count =16'd0,
output reg [15:0] strip7_image_read_count =16'd0,
output reg [15:0] strip8_image_read_count =16'd0,
output reg [7:0]transmit_data 
);
    
    parameter [2:0] IDLE = 3'b000;
    parameter [2:0] ADDR_SEL = 3'b001;
    parameter [2:0] DELAY1 = 3'b010;
    parameter [2:0] DELAY2 = 3'b011;
    parameter [2:0] TRANSMISSION = 3'b100;
    parameter [2:0] WAIT = 3'b101;
    parameter [2:0] DONE = 3'b110;
    
   reg [2:0] NS,PS; 
   
   reg [12:0]addr_count =13'd0; 
   reg [2:0] count = 3'd0;
   reg write_flag = 1'b0;
   reg signed [22:0] out_data;
    
    always @(posedge clk or posedge reset) begin
    if (reset) begin
        PS <= IDLE;
    end
    else begin
        PS <= NS;
    end
    end 
    
    
    
     always @(*) begin
        NS = PS;
    case (PS)
 
              IDLE: begin
               
                if (start) begin
                
                    NS = ADDR_SEL;
                    
                    end
                else begin
                
                    NS = IDLE;
                    
                end
              end
             
              ADDR_SEL: begin
              
              if(bram_read_complete1 && bram_read_complete2 && bram_read_complete3 && bram_read_complete4 && bram_read_complete5 && bram_read_complete6 && bram_read_complete7 && bram_read_complete8)begin
              NS = DONE;
              end
              
              
              else begin
              case(count)
              
              3'd0: begin
               if(addr_count >13'd6215)begin
                  
              end
              
              else begin
                  NS = DELAY1;
              
              end
              end
              
              3'd1: begin
               if(addr_count >13'd6215)begin
                  
              end
              
              else begin
                  NS = DELAY1;
              
              end
              end
              
              3'd2: begin
               if(addr_count >13'd6215)begin
                  
              end
              
              else begin
                  NS = DELAY1;
              
              end
              end
              
              3'd3: begin
               if(addr_count >13'd6215)begin
                  
              end
              
              else begin
                  NS = DELAY1;
              
              end
              end
              
              3'd4: begin
               if(addr_count >13'd6215)begin
                  
              end
              
              else begin
                  NS = DELAY1;
              
              end
              end
              
              3'd5: begin
               if(addr_count >13'd6215)begin
                  
              end
              
              else begin
                  NS = DELAY1;
              
              end
              end
              
              3'd6: begin
               if(addr_count >13'd6215)begin
                  
              end
              
              else begin
                  NS = DELAY1;
              
              end
              end
              
              3'd7: begin
               if(addr_count >13'd5771)begin
                  
              end
              
              else begin
                  NS = DELAY1;
              
              end
              end
              endcase
              
              end
              
              end
            
             
             DELAY1:  begin
                
                NS = DELAY2;
                
             end
             
              DELAY2:  begin
                
                NS = TRANSMISSION;
                
             end
             
               TRANSMISSION:  begin
               
                if(busy ==0)begin
                  NS = ADDR_SEL;
                end
                else begin
                    NS = WAIT;
                end
                
               end
               
               WAIT: begin
                
                  NS = TRANSMISSION;  
               end
             
             DONE : begin
             
             end
             default: begin
               
                  NS = IDLE;
             end
        endcase
    end
    
    
      
always @(posedge clk) begin

         if (reset) begin 
          bram_read_complete1 <= 1'b0;
          bram_read_complete2 <= 1'b0;
          bram_read_complete3 <= 1'b0;
          bram_read_complete4 <= 1'b0;
          bram_read_complete5 <= 1'b0;
          bram_read_complete6 <= 1'b0;
          bram_read_complete7 <= 1'b0;
          bram_read_complete8 <= 1'b0;
          bram_read_complete <= 1'b0;
         strip1_image_read_count <=13'd0;
         strip2_image_read_count <=13'd0;
         strip3_image_read_count <=13'd0;
         strip4_image_read_count <=13'd0;
         strip5_image_read_count <=13'd0;
         strip6_image_read_count <=13'd0;
         strip7_image_read_count <=13'd0;
         strip8_image_read_count <=13'd0;
         addr_count <= 13'd0;
         count <= 3'd0;
         send <= 1'b0;
         transmit_data <= 16'b0;
         write_flag <= 1'b0;
         out_data <= 23'd0;
         
          
         end
         else begin
         
          case (PS)
 
              IDLE: begin
               //do nothing
              end
             
              ADDR_SEL: begin
              
              send <= 1'b0;
              
              if(bram_read_complete1 && bram_read_complete2 && bram_read_complete3 && bram_read_complete4 && bram_read_complete5 && bram_read_complete6 && bram_read_complete7 && bram_read_complete8)begin
              
              end
              else begin
              case(count)
              
              3'd0: begin
               if(addr_count >13'd6215)begin
                  addr_count <= 0;
                  write_flag <= 0;
                  count <= count+1;
                  bram_read_complete1 = 1'b1;
              end
              
              else begin
                  if (!write_flag) begin
                         strip1_image_read_count <= addr_count;
                  end
                  else begin
                         addr_count <= addr_count+1;
                         strip1_image_read_count <= addr_count;
                  end
                     write_flag <= 1; 
                 end
              
              end
              
             3'd1: begin
               if(addr_count >13'd6215)begin
                  addr_count <= 0;
                  write_flag <= 0;
                  count <= count+1;
                  bram_read_complete2 = 1'b1;
              end
              
              else begin
                  if (!write_flag) begin
                         strip2_image_read_count <= addr_count;
                  end
                  else begin
                         addr_count <= addr_count+1;
                         strip2_image_read_count <= addr_count;
                  end
                     write_flag <= 1; 
                 end
              
              end
              
               3'd2: begin
               if(addr_count >13'd6215)begin
                  addr_count <= 0;
                  write_flag <= 0;
                  count <= count+1;
                  bram_read_complete3 = 1'b1;
              end
              
              else begin
                  if (!write_flag) begin
                         strip3_image_read_count <= addr_count;
                  end
                  else begin
                         addr_count <= addr_count+1;
                         strip3_image_read_count <= addr_count;
                  end
                     write_flag <= 1; 
                 end
              
              end
              
              3'd3: begin
               if(addr_count >13'd6215)begin
                  addr_count <= 0;
                  write_flag <= 0;
                  count <= count+1;
                  bram_read_complete4 = 1'b1;
              end
              
              else begin
                  if (!write_flag) begin
                         strip4_image_read_count <= addr_count;
                  end
                  else begin
                         addr_count <= addr_count+1;
                         strip4_image_read_count <= addr_count;
                  end
                     write_flag <= 1; 
                 end
              
              end
              
               3'd4: begin
               if(addr_count >13'd6215)begin
                  addr_count <= 0;
                  write_flag <= 0;
                  count <= count+1;
                  bram_read_complete5 = 1'b1;
              end
              
              else begin
                  if (!write_flag) begin
                         strip5_image_read_count <= addr_count;
                  end
                  else begin
                         addr_count <= addr_count+1;
                         strip5_image_read_count <= addr_count;
                  end
                     write_flag <= 1; 
                 end
              
              end
              
               3'd5: begin
               if(addr_count >13'd6215)begin
                  addr_count <= 0;
                  write_flag <= 0;
                  count <= count+1;
                  bram_read_complete6 = 1'b1;
              end
              
              else begin
                  if (!write_flag) begin
                         strip6_image_read_count <= addr_count;
                  end
                  else begin
                         addr_count <= addr_count+1;
                         strip6_image_read_count <= addr_count;
                  end
                     write_flag <= 1; 
                 end
              
              end
              
               3'd6: begin
               if(addr_count >13'd6215)begin
                  addr_count <= 0;
                  write_flag <= 0;
                  count <= count+1;
                  bram_read_complete7 = 1'b1;
              end
              
              else begin
                  if (!write_flag) begin
                         strip7_image_read_count <= addr_count;
                  end
                  else begin
                         addr_count <= addr_count+1;
                         strip7_image_read_count <= addr_count;
                  end
                     write_flag <= 1; 
                 end
              
              end
              
               3'd7: begin
               if(addr_count >13'd5771)begin
                  addr_count <= 0;
                  write_flag <= 0;
                  count <= count+1;
                  bram_read_complete8 = 1'b1;
              end
              
              else begin
                  if (!write_flag) begin
                         strip8_image_read_count <= addr_count;
                  end
                  else begin
                         addr_count <= addr_count+1;
                         strip8_image_read_count <= addr_count;
                  end
                     write_flag <= 1; 
                 end
              
              end
              
       
              
              endcase
              end
     
              
              end
            
             DELAY1:  begin
                //do nothing
             end
             
              DELAY2:  begin
                //do nothing
                
             end
             
             
             TRANSMISSION:  begin
             if(count == 0) begin
             out_data <= out_unit1;
             end
             else if(count == 1) begin
             out_data <= out_unit2;
             end
              else if(count == 2)begin
              out_data <= out_unit3;
              end
              else if(count == 3) begin
             out_data <= out_unit4;
             end
              else if(count == 4)begin
              out_data <= out_unit5;
              end
              else if(count == 5) begin
             out_data <= out_unit6;
             end
              else if(count == 6)begin
              out_data <= out_unit7;
              end 
              else begin
              out_data <= out_unit8;
              end 
               if(busy == 0)begin
               
                if(out_data < 23'sd0)begin
                    transmit_data <= 8'b0;
                end
                
                else if(out_data > 23'sd255) begin
                    transmit_data <= 8'd255;
                end
                
                else begin
                   transmit_data <= out_data[7:0];
                end
                
                send <= 1'b1;
                end
                  
               end
               
               
              WAIT: begin
                      
               end
                 
             DONE : begin
                
                bram_read_complete <=1'b1;
             
             end
             
             
             default: begin
               
             end
             
        endcase
       end
         
    end
   
    
    
    
    
  
endmodule