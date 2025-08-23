module tb_uart_tx ();

    logic        clk;
    logic        rstn;
    logic [7:0]  din;
    logic        tx_start;
    logic        tx_active;
    logic        tx;
    logic        tx_done_tick;

    uart_tx i_uart_tx(
        .clk_i(clk),
        .rstn_i(rstn),
        .tx_din_i(din),
        .tx_start_i(tx_start),
        .tx_o(tx),
        .tx_done_tick_o(tx_done_tick),
        .tx_active_o(tx_active)
    );
    
    initial forever begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end
    initial begin
        rstn = 0;
        #100;
        rstn = 1;
        din	 = 8'h00;
        tx_start = 0;
        
        #100;
        din=8'h51;
        tx_start	= 1;
        #10;
        tx_start	= 0;
        @(posedge tx_done_tick);
        #100;

        din = 8'ha3;
        tx_start = 1;
        #10;
        tx_start = 0;
        @(posedge tx_done_tick);
        #1000;
        $finish;
    end

        
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars();
   end
    
endmodule
