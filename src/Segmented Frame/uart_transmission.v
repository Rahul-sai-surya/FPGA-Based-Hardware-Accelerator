`timescale 1ns / 1ps



module uart_transmission #(parameter CLK_FREQ = 100000000, // 50 MHz clock
                            parameter BAUD_RATE = 9600)  // Baud rate
(
    input wire clk,              // System clock
    input wire rst,              // Reset signal
    input wire  [7:0] data_in,    // Data to send
    input wire send,             // Signal to trigger data transmission
    output reg tx,               // UART transmit line
    output reg busy              // Transmission busy flag
);

   // reg [7:0] data_in = 8'd1;
    // Calculate the number of clock cycles per baud interval
    localparam BAUD_TICKS = CLK_FREQ / BAUD_RATE;
    localparam IDLE = 2'b00, START_BIT = 2'b01, DATA_BITS = 2'b10, STOP_BIT = 2'b11;

    reg [15:0] baud_counter;
    reg [3:0] bit_index;
    reg  [7:0] tx_shift_reg;
    reg [1:0] state;

    initial begin
        tx = 1;  // UART idle state is high
        busy = 0;
        baud_counter = 0;
        bit_index = 0;
        state = IDLE;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1;
            busy <= 0;
            baud_counter <= 0;
            bit_index <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;
                    busy <= 0;
                    baud_counter <= 0;
                    bit_index <= 0;
                    if (send) begin
                        tx_shift_reg <= data_in;
                        state <= START_BIT;
                        busy <= 1;
                    end
                end

                START_BIT: begin
                    tx <= 0; // Start bit
                    if (baud_counter == BAUD_TICKS - 1) begin
                        baud_counter <= 0;
                        state <= DATA_BITS;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                DATA_BITS: begin
                    tx <= tx_shift_reg[bit_index];
                    if (baud_counter == BAUD_TICKS - 1) begin
                        baud_counter <= 0;
                        if (bit_index == 7) begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                STOP_BIT: begin
                    tx <= 1; // Stop bit
                    if (baud_counter == BAUD_TICKS - 1) begin
                        baud_counter <= 0;
                        state <= IDLE;
                        busy <= 0;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
            endcase
        end
    end
endmodule