module tb_pwm();

logic       clk_i;
logic       rstn_i;
logic [6:0] dutycycle_i;
logic       pwm_o;

pwm DUT(.*);

initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
end

initial begin
    rstn_i = 0;
    dutycycle_i = 25;
    #20;
    rstn_i = 1;
    #5ms;
    dutycycle_i = 33;
    #5ms;
    dutycycle_i = 50;
    #5ms;
    dutycycle_i = 85;
    #5ms;
    dutycycle_i = 99;
    #5ms;
    dutycycle_i = 0;
    #5ms;
    dutycycle_i = 100;
    #5ms;
    $finish;
end

initial begin
   $dumpfile("dump.vcd");
   $dumpvars();
end

endmodule
