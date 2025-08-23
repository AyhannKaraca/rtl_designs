module edge_detector(
    input  logic clk_i,    
    input  logic rstn_i,    
    input  logic in_i,    
    output logic rise_o,    
    output logic fall_o
);

logic q;

always_ff @(posedge clk_i) begin : RISE_EDGE_DEC
    if(!rstn_i) begin
        q <= 0;
    end else begin
        q <= in_i;
    end
end
assign rise_o = (in_i && !q);
assign fall_o = (!in_i && q);


endmodule
