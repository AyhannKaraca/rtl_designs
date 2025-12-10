module tb_rise_edge_det();

logic clk_i;
logic rstn_i;
logic sig_i;
logic sig_o;

rise_edge_det DUT(.*);

initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
end

initial begin
    rstn_i = 0;
    #10;
    rstn_i = 1;
    #10;
    sig_i = 1;
    #15;
    sig_i = 0;
    #11;
    sig_i = 1;
    #7;
    sig_i = 0;
    #15;
    $finish;
end

initial begin
   $dumpfile("dump.vcd");
   $dumpvars();
end

endmodule