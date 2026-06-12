module uart_rx_fifo (
    input wire clk,
    input wire rst,
    input wire baud_tick,
    input wire rx,

    output reg [7:0] fifo_data,
    output reg fifo_wr_en
);

reg [2:0] state;
reg [3:0] sample_cnt;
reg [3:0] bit_cnt;
reg [7:0] shift_reg;

reg rx_sync1, rx_sync2;

localparam IDLE  = 0;
localparam START = 1;
localparam DATA  = 2;
localparam STOP  = 3;

// Synchronizer
always @(posedge clk) begin
    rx_sync1 <= rx;
    rx_sync2 <= rx_sync1;
end

wire rx_clean = rx_sync2;

always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        fifo_wr_en <= 0;
    end else begin

        fifo_wr_en <= 0;

        if (baud_tick) begin

            case (state)

            IDLE: begin
                if (rx_clean == 0)
                    state <= START;
            end

            START: begin
                sample_cnt <= sample_cnt + 1;

                if (sample_cnt == 7) begin
                    if (rx_clean == 0)
                        state <= DATA;
                    else
                        state <= IDLE;

                    sample_cnt <= 0;
                end
            end

            DATA: begin
                sample_cnt <= sample_cnt + 1;

                if (sample_cnt == 15) begin
                    sample_cnt <= 0;

                    shift_reg <= {rx_clean, shift_reg[7:1]};

                    if (bit_cnt == 7) begin
                        bit_cnt <= 0;
                        state <= STOP;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
            end

            STOP: begin
                if (sample_cnt == 15) begin
                    fifo_data <= shift_reg;
                    fifo_wr_en <= 1;
                    state <= IDLE;
                    sample_cnt <= 0;
                end else begin
                    sample_cnt <= sample_cnt + 1;
                end
            end

            endcase
        end
    end
end

endmodule
