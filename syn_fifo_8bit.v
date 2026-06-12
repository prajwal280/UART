module fifo #(parameter DEPTH = 16)(
    input  wire clk,
    input  wire rst,

    input  wire wr_en,
    input  wire rd_en,

    input  wire [7:0] din,
    output reg  [7:0] dout,

    output wire full,
    output wire empty
);

reg [7:0] mem [0:DEPTH-1];

reg [$clog2(DEPTH):0] wr_ptr;
reg [$clog2(DEPTH):0] rd_ptr;
reg [$clog2(DEPTH+1):0] count;

assign full  = (count == DEPTH);
assign empty = (count == 0);

always @(posedge clk) begin
    if (rst) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        count  <= 0;
    end else begin

        // WRITE
        if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr <= wr_ptr + 1;
            count <= count + 1;
        end

        // READ
        if (rd_en && !empty) begin
            dout <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
            count <= count - 1;
        end
    end
end

endmodule
