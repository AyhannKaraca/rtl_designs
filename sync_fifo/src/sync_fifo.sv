module sync_fifo#
(
    parameter int WIDTH = 16,
    parameter int DEPTH = 4
)
(
    input  logic             clk_i,
    input  logic             rstn_i,
    input  logic             wr_i,
    input  logic             rd_i,
    input  logic [WIDTH-1:0] din_i,
    output logic [WIDTH-1:0] dout_o,
    output logic             empty_o,
    output logic             full_o
);

logic [WIDTH-1:0] fifo [DEPTH-1:0];

logic [WIDTH-1:0] dout_d;

logic write;
logic read;
logic [$clog2(DEPTH)-1:0] wptr;
logic [$clog2(DEPTH)-1:0] wptr_d;
logic [$clog2(DEPTH)-1:0] rptr;
logic [$clog2(DEPTH)-1:0] rptr_d;
logic [$clog2(DEPTH):0] cnt;
logic [$clog2(DEPTH):0] cnt_d;

rise_edge_det i_rise_edge_det_write(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .sig_i(wr_i),
    .sig_o(write)
);

rise_edge_det i_rise_edge_det_read(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .sig_i(rd_i),
    .sig_o(read)
);

assign dout_d = (read & !empty_o) ? fifo[rptr] : dout_o;

assign wptr_d = (write & !full_o) ? wptr + 1 : wptr;
assign rptr_d = (read  & !empty_o) ? rptr + 1 : rptr;


assign cnt_d = (write & !full_o) ? cnt + 1:
               (read  & !empty_o) ? cnt - 1: cnt;

assign full_o  = (cnt == DEPTH);
assign empty_o = (cnt == 0);

always_ff @ (posedge clk_i) begin
    if(!rstn_i) begin
        cnt <= 0;
        wptr <= 0;
        rptr <= 0;
        dout_o <= 0;
    end else begin
        if(write & !full_o) begin
            fifo[wptr] <= din_i;
        end
        cnt <= cnt_d;
        wptr <= wptr_d;
        rptr <= rptr_d;
        dout_o <= dout_d;
    end
end

endmodule
