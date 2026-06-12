module uart_tx_fifo (
    input wire clk,
    input wire rst,
    input wire baud_tick,

    input wire [7:0] fifo_data,
    input wire fifo_empty,
    output reg  fifo_rd_en,

    output reg tx,
    output reg tx_busy
);

reg [2:0] state;
reg [7:0] shift_reg;
reg [3:0] bit_cnt;

localparam IDLE  = 0;
localparam START = 1;
localparam DATA  = 2;
localparam STOP  = 3;

always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        tx <= 1;
        fifo_rd_en <= 0;
        tx_busy <= 0;
    end else begin

        fifo_rd_en <= 0;

        case (state)

        IDLE: begin
            tx <= 1;
            tx_busy <= 0;

            if (!fifo_empty) begin
                fifo_rd_en <= 1;
                shift_reg <= fifo_data;
                tx_busy <= 1;
                state <= START;
            end
        end

        START: begin
            tx <= 0;
            if (baud_tick) state <= DATA;
        end

        DATA: begin
            tx <= shift_reg[0];

            if (baud_tick) begin
                shift_reg <= shift_reg >> 1;

                if (bit_cnt == 7) begin
                    bit_cnt <= 0;
                    state <= STOP;
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end
        end

        STOP: begin
            tx <= 1;

            if (baud_tick)
                state <= IDLE;
        end

        endcase
    end
end

endmodule
