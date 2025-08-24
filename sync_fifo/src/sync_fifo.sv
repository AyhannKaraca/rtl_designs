// In this design, one slot of the fifo isn't used to avoid increasing complexity.

module sync_fifo#(
    parameter FIFO_WIDTH = 32,
    parameter FIFO_DEPTH = 2048
)(
    input  logic                  clk_i,
    input  logic                  rstn_i,
    input  logic                  wr_en_i,
    input  logic                  rd_en_i,
    input  logic [FIFO_WIDTH-1:0] din_i,
    output logic [FIFO_WIDTH-1:0] dout_o,
    output logic                  empty_o,
    output logic                  full_o
);

logic [FIFO_WIDTH-1:0] fifo [FIFO_DEPTH-1:0] = '{default:0};
logic [$clog2(FIFO_DEPTH)-1:0] wptr;
logic [$clog2(FIFO_DEPTH)-1:0] wptr_d;
logic [$clog2(FIFO_DEPTH)-1:0] rptr;
logic [$clog2(FIFO_DEPTH)-1:0] rptr_d;
logic [FIFO_WIDTH-1:0]         din;
logic [FIFO_WIDTH-1:0]         dout_d;

assign wptr_d  = (wr_en_i && !full_o)  ? wptr + 1   : wptr;
assign rptr_d  = (rd_en_i && !empty_o) ? rptr + 1   : rptr;
assign din     = (wr_en_i && !full_o)  ? din_i      : fifo[wptr];
assign dout_d  = (rd_en_i && !empty_o) ? fifo[rptr] : dout_o;
assign empty_o = (wptr == rptr);
assign full_o  = (rptr == wptr + 1);

always_ff @ (posedge clk_i) begin
    if(!rstn_i) begin
        wptr   <= 0;
        rptr   <= 0;
        dout_o <= 0;
    end else begin
        wptr       <= wptr_d;
        fifo[wptr] <= din;
        rptr       <= rptr_d;
        dout_o     <= dout_d;
    end
end
endmodule
