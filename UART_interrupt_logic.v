module uart_irq (
    input wire rx_fifo_empty,
    input wire tx_fifo_empty,

    output wire irq
);

assign irq = (!rx_fifo_empty) | tx_fifo_empty;

endmodule
