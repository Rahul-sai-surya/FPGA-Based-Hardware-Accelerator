`timescale 1ns / 1ps


module top(
input clk,
input reset,
input start,
input kernel_read,
output kernel_read_complete,
output  bram_read_complete,
output reg led = 1'b0,
output  tx
);

wire busy;
wire [8:0]transmit_data;
wire [15:0] image_read_count;
wire send;
wire done;
wire signed [8:0]out_data;

// Instantiate the test1_sinc module
test1_sinc uut (
    .clk(clk),
    .start(start),
    .kernel_read(kernel_read),
    .reset(reset),
    .done(done),
    .addr_in(image_read_count),
    .kernel_read_complete(kernel_read_complete),
    .out(out_data)
);

  // Instantiate the UART BRAM Reader module
uart_bram_reader uut1 (
    .clk(clk),
    .reset(reset),
    .busy(busy),
    .start(done),
    .out_data(out_data),
    .send(send),
    .bram_read_complete(bram_read_complete),
    .image_read_count(image_read_count),
    .transmit_data(transmit_data)
);

    // Simple instantiation without overriding parameters
    uart_transmission uart_inst (
        .clk(clk),
        .rst(reset),
        .data_in(transmit_data),
        .send(send),
        .tx(tx),
        .busy(busy)
    );
    
    
    always@(posedge clk)begin
    led <= busy;
    end
    
    
    
endmodule