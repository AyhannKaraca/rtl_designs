module rise_edge_det(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic sig_i,
    output logic sig_o
);

logic q;

always_ff @ (posedge clk_i) begin
    if(!rstn_i) begin
        q <= 0;
    end else begin
        q <= sig_i;
    end
end

assign sig_o = (sig_i & !q);


endmodule
