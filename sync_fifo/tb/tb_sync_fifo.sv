module tb_sync_fifo();

    localparam FIFO_WIDTH = 8;
    localparam FIFO_DEPTH = 8;
    
    logic                  clk_i;
    logic                  rstn_i;
    logic                  wr_en_i;
    logic                  rd_en_i;
    logic [FIFO_WIDTH-1:0] din_i;
    logic [FIFO_WIDTH-1:0] dout_o;
    logic                  empty_o;
    logic                  full_o;

    sync_fifo DUT(.*);

    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    initial begin
        rstn_i = 0;
        #50;
        rstn_i = 1;
        #1_000;
        $finish;
    end

    logic [2:0] write_active; 
    logic [4:0] read_active;

    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            write_active <= 0;
            read_active  <= 0;
        end else begin
            write_active <= write_active + 1;
            read_active  <= read_active + 1;
        end
    end

    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            wr_en_i <= 0;
            din_i <= 0;
        end else begin
            wr_en_i <= 0;
            if(write_active == 4) begin
                wr_en_i <= 1;
                din_i <= $random;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            rd_en_i <= 0;
        end else begin 
            rd_en_i <= 0;
            if(read_active == 4) begin
                rd_en_i <= 1;
            end
        end
    end

initial begin
   $dumpfile("dump.vcd");
   $dumpvars();
end

endmodule
