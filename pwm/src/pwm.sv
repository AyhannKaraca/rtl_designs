module pwm#(
    parameter c_clkfreq = 100_000_000,
    parameter c_pwmfreq = 1000
)(
    input  logic       clk_i,
    input  logic       rstn_i,
    input  logic [6:0] dutycycle_i,
    output logic       pwm_o
);

localparam c_timlim = c_clkfreq/c_pwmfreq;

logic [$clog2(c_timlim)-1:0] hightime;
logic [$clog2(c_timlim)-1:0] cnt;
logic [$clog2(c_timlim)-1:0] cnt_d;
logic                        pwm_d;

assign hightime = (c_timlim/100)*dutycycle_i;  

assign cnt_d = (cnt == c_timlim-1) ? 0 : cnt + 1;  
               
assign pwm_d = (hightime > cnt) ? 1 : 0;

always_ff @(posedge clk_i) begin : PWM_OUT_UPDATE
    if(!rstn_i) begin
        pwm_o <= 0;
        cnt <= 0;
    end else begin
        pwm_o <= pwm_d;
        cnt <= cnt_d;
    end
end

endmodule
