`timescale 1ns / 1ps

module uart_transmission #(
    parameter integer CLK_FREQ = 100_000_000, // system clock freq (Hz)
    parameter integer BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] data_in,
    input  wire       send,   // may be level; module will detect rising edge
    output reg        tx,
    output reg        busy
);

    // compute ticks (must be > 1)
    localparam integer BAUD_TICKS = (CLK_FREQ + BAUD_RATE/2) / BAUD_RATE; // round
    // width for counters
    localparam integer BAUD_CTR_W = (BAUD_TICKS <= 1) ? 1 : $clog2(BAUD_TICKS);
    localparam integer BIT_IDX_W = 3; // 0..7

    // states
    localparam [1:0] IDLE      = 2'b00;
    localparam [1:0] START_BIT = 2'b01;
    localparam [1:0] DATA_BITS = 2'b10;
    localparam [1:0] STOP_BIT  = 2'b11;

    reg [1:0] state, next_state;
    reg [BAUD_CTR_W-1:0] baud_counter;
    reg [BIT_IDX_W-1:0] bit_index;
    reg [7:0] tx_shift_reg;
    reg send_d; // delayed send for edge detect
    wire send_posedge = send & ~send_d;

    // synchronous registers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            send_d <= 1'b0;
            state <= IDLE;
            baud_counter <= {BAUD_CTR_W{1'b0}};
            bit_index <= 0;
            tx_shift_reg <= 8'h00;
            tx <= 1'b1; // idle high
            busy <= 1'b0;
        end else begin
            send_d <= send;
            state <= next_state;
            // update counters and registers in state machine below
            case (next_state)
                IDLE: begin
                    // reset counters in IDLE
                    baud_counter <= {BAUD_CTR_W{1'b0}};
                    bit_index <= 0;
                    if (send_posedge) begin
                        tx_shift_reg <= data_in;
                        busy <= 1'b1;
                        tx <= 1'b1; // will be driven in START_BIT
                    end
                end

                START_BIT: begin
                    // drive start bit and step baud_counter
                    if (baud_counter == BAUD_TICKS - 1) begin
                        baud_counter <= {BAUD_CTR_W{1'b0}};
                    end else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                    tx <= 1'b0;
                end

                DATA_BITS: begin
                    tx <= tx_shift_reg[bit_index];
                    if (baud_counter == BAUD_TICKS - 1) begin
                        baud_counter <= {BAUD_CTR_W{1'b0}};
                        if (bit_index == 7)
                            bit_index <= 0;
                        else
                            bit_index <= bit_index + 1'b1;
                    end else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                STOP_BIT: begin
                    tx <= 1'b1;
                    if (baud_counter == BAUD_TICKS - 1) begin
                        baud_counter <= {BAUD_CTR_W{1'b0}};
                    end else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                    // busy cleared when STOP_BIT completes (in next_state logic)
                end

                default: begin
                    // safety defaults
                    tx <= 1'b1;
                    busy <= 1'b0;
                end
            endcase
        end
    end

    // next-state combinational logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (send_posedge) begin
                    next_state = START_BIT;
                    // busy set in sequential block
                end else begin
                    next_state = IDLE;
                end
            end

            START_BIT: begin
                if (baud_counter == BAUD_TICKS - 1)
                    next_state = DATA_BITS;
                else
                    next_state = START_BIT;
            end

            DATA_BITS: begin
                if ((bit_index == 7) && (baud_counter == BAUD_TICKS - 1))
                    next_state = STOP_BIT;
                else
                    next_state = DATA_BITS;
            end

            STOP_BIT: begin
                if (baud_counter == BAUD_TICKS - 1) begin
                    next_state = IDLE;
                end else begin
                    next_state = STOP_BIT;
                end
            end

            default: next_state = IDLE;
        endcase
    end

    // clear busy when state machine completes STOP_BIT -> IDLE transition
    // detect that transition and clear busy
    reg prev_state;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_state <= IDLE;
        end else begin
            prev_state <= state;
            if ((state == STOP_BIT) && (next_state == IDLE)) begin
                busy <= 1'b0;
            end else if (state == IDLE && next_state == START_BIT) begin
                busy <= 1'b1;
            end
        end
    end

endmodule
