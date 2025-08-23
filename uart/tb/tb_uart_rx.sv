module tb_uart_rx();

    localparam int c_clkfreq = 100_000_000; //10ns 
    localparam int c_baudrate = 115_200; 
    localparam int c_clkperiod = 10;
    localparam int c_timerlim = (c_clkfreq/c_baudrate)*c_clkperiod; //868 * 10ns = 8.68us

    logic        clk;
    logic        rstn;
    logic [7:0]  dout;
    logic        rx;
    logic        rx_done_tick;
    logic        rx_active;

    uart_rx i_uart_rx(
        .clk_i(clk),
        .rstn_i(rstn),
        .rx_i(rx),
        .rx_dout_o(dout),
        .rx_done_tick_o(rx_done_tick),
        .rx_active_o(rx_active)
    );

    logic [9:0] c_cf = {1'b1,8'hcf,1'b0};
    logic [9:0] c_ab = {1'b1,8'hab,1'b0};
    logic [9:0] c_fd = {1'b1,8'hfd,1'b0};

    initial forever begin
        clk = 0;
        #(c_clkperiod/2);
        clk = 1;
        #(c_clkperiod/2);
    end
    initial begin
        rstn = 0;
        #100;
        rstn = 1;
        for(int i = 0; i<10; i++)begin
            rx = c_cf[i];
            #(c_timerlim);
        end
        #400;
        for(int i = 0; i<10; i++)begin
            rx = c_ab[i];
            #(c_timerlim);
        end
        #400;
        for(int i = 0; i<10; i++)begin
            rx = c_fd[i];
            #(c_timerlim);
        end
        #300;
        $finish;
    end

        
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars();
   end
    
endmodule
