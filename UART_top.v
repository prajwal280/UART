module uart_top (
    input wire clk,
    input wire rst,
    input wire rx,

    output wire tx,
    output wire irq
);

wire baud_tick;

// FIFO signals
wire [7:0] tx_fifo_data;
wire tx_fifo_empty;
wire tx_fifo_rd;

wire [7:0] rx_fifo_data;
wire rx_fifo_wr;

// FIFO blocks
fifo tx_fifo (
    .clk(clk),
    .rst(rst),
    .wr_en(0),
    .rd_en(tx_fifo_rd),
    .din(0),
    .dout(tx_fifo_data),
    .empty(tx_fifo_empty),
    .full()
);

fifo rx_fifo (
    .clk(clk),
    .rst(rst),
    .wr_en(rx_fifo_wr),
    .rd_en(0),
    .din(rx_fifo_data),
    .dout(),
    .empty(),
    .full()
);

// UART TX/RX
uart_tx_fifo tx_core (...);
uart_rx_fifo rx_core (...);

// IRQ
uart_irq irq_block (...);

endmodule
