module uart_rx#(
    parameter int c_clkfreq = 100_000_000, //10ns 
    parameter int c_baudrate = 10_000_000
)(
    input  logic        clk_i,
    input  logic        rstn_i,
    input  logic        rx_i,
    output logic [7:0]  rx_dout_o,
    output logic        rx_done_tick_o,
    output logic        rx_active_o
);

localparam int c_timerlim = c_clkfreq/c_baudrate; //868 * 10ns = 8.68us

typedef enum logic [1:0] {S_IDLE, S_START, S_DATA, S_STOP} states_t;
states_t state;
states_t next_state;

logic [31:0] timer; 
logic [31:0] timer_d; 
logic [7:0 ] shreg;
logic [7:0 ] shreg_d;
logic [2:0 ] bitcntr;
logic [2:0 ] bitcntr_d;
logic rx_done_tick_d;

assign rx_dout_o = shreg;
assign rx_active_o = (state == S_DATA);

assign timer_d = (state == S_IDLE) ? 0:
                 ((state == S_START) && (timer == (c_timerlim-1)/2)) ? 0:
                 ((state == S_DATA) && (timer == c_timerlim-1)) ? 0:
                 ((state == S_STOP) && (timer == c_timerlim-1)) ? 0:
                 timer + 1;

always_ff @(posedge clk_i) begin : TIMER_FF_UPDATE
    if(!rstn_i) begin
        timer <= 0;
    end else begin
        timer <= timer_d;
    end
end

assign next_state = ((state == S_IDLE) && (!rx_i)) ? S_START : 
             ((state == S_START) && (timer == (c_timerlim-1)/2)) ? S_DATA:
             ((state == S_DATA) && (timer == c_timerlim-1) && (bitcntr == 3'd7)) ? S_STOP:
             ((state == S_STOP) && (timer == c_timerlim-1)) ? S_IDLE: state;

always_ff @(posedge clk_i) begin :STATE_FF_UPDATE
    if(!rstn_i) begin
        state <= S_IDLE;
    end else begin
        state <= next_state;
    end
end

assign bitcntr_d = ((state == S_DATA) && (timer == c_timerlim-1)) ? bitcntr + 1 : bitcntr; 

always_ff @(posedge clk_i) begin :BITCNT_FF_UPDATE
    if(!rstn_i) begin
        bitcntr <= 0;
    end else begin
        bitcntr <= bitcntr_d;
    end
end

always_comb begin : OUTPUT_UPDATE
    rx_done_tick_d = 0;
    shreg_d = shreg;
    case(state)
        S_IDLE:begin
            rx_done_tick_d = 0;
            shreg_d = '0;
        end
        S_START:begin
            ;
        end
        S_DATA:begin
            if(timer == c_timerlim-1) begin
                shreg_d = shreg_d >> 1;
                shreg_d[7] = rx_i;
            end
        end
        S_STOP:begin
            if(timer == c_timerlim-1) begin
                rx_done_tick_d = 1;
            end
        end
    endcase
end

always_ff @(posedge clk_i) begin :OUTPUT_FF_UPDATE
    if(!rstn_i) begin
        shreg <= 0;
        rx_done_tick_o <= 0;
    end else begin
        shreg <= shreg_d;
        rx_done_tick_o <= rx_done_tick_d;
    end
end
endmodule
