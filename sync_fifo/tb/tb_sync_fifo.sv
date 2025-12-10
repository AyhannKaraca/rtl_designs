module tb_sync_fifo();

localparam WIDTH = 16;

logic             clk_i;
logic             rstn_i;
logic             wr_i;
logic             rd_i;
logic [WIDTH-1:0] din_i;
logic [WIDTH-1:0] dout_o;
logic             empty_o;
logic             full_o;

sync_fifo DUT(.*);

initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
end

initial begin
    rstn_i = 0;
    #10;
    rstn_i = 1;
    #10;
    din_i = $urandom[15:0];
    wr_i= 1;
    #10;
    wr_i= 0;
    #10;
    din_i = $urandom[15:0];
    wr_i= 1;
    #10;
    wr_i= 0;
    #10;
    din_i = $urandom[15:0];
    wr_i= 1;
    #10;
    wr_i= 0;
    #10;
    din_i = $urandom[15:0];
    wr_i= 1;
    #10;
    wr_i= 0;
    #10;
    din_i = $urandom[15:0];
     wr_i= 1;
    #10;
    wr_i= 0;

    rd_i = 1;
    #10;
    rd_i = 0;
    #10;
    rd_i = 1;
    #10;
    rd_i = 0;
    #10;
    rd_i = 1;
    #10;
    rd_i = 0;
    #10;
    rd_i = 1;
    #10;
    rd_i = 0;
    #10;
    rd_i = 1;
    #10;
    rd_i = 0;
    #10;
    $finish;
end


initial begin
   $dumpfile("dump.vcd");
   $dumpvars();
end

endmodule