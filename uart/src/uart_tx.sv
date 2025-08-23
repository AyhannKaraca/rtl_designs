module uart_tx#(
    parameter int c_clkfreq = 100_000_000, //10ns 
    parameter int c_baudrate = 10_000_000,  
    parameter int c_stopbit = 2
)(
    input  logic        clk_i,
    input  logic        rstn_i,
    input  logic [7:0]  tx_din_i,
    input  logic        tx_start_i,
    output logic        tx_o,
    output logic        tx_active_o,
    output logic        tx_done_tick_o
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
logic tx_d;
logic tx;
logic tx_done_tick_d;
  
assign tx_active_o = (state == S_DATA);  
assign tx_o = tx;  

assign timer_d = (state == S_IDLE) ? 0:
                 ((state == S_START) && (timer == c_timerlim-1)) ? 0:
                 ((state == S_DATA) && (timer == c_timerlim-1)) ? 0:
                 ((state == S_STOP) && (timer == (c_timerlim*c_stopbit)-1)) ? 0:
                 timer + 1;

always_ff @(posedge clk_i) begin : TIMER_FF_UPDATE
    if(!rstn_i) begin
        timer <= 0;
    end else begin
        timer <= timer_d;
    end
end

assign next_state = ((state == S_IDLE) && (tx_start_i)) ? S_START : 
             ((state == S_START) && (timer == c_timerlim-1)) ? S_DATA:
             ((state == S_DATA) && (timer == c_timerlim-1) && (bitcntr == 3'd7)) ? S_STOP:
             ((state == S_STOP) && (timer == (c_timerlim*c_stopbit)-1)) ? S_IDLE: state;

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
    shreg_d = shreg;
    tx_done_tick_d = 0;
    tx_d = tx;
    case(state)
        S_IDLE:begin
            tx_d = 1;
            tx_done_tick_d = 0;
            if(tx_start_i)begin
                tx_d = 0;
                shreg_d = tx_din_i;
            end
        end
        S_START:begin
            if(timer == c_timerlim-1) begin
                tx_d = shreg_d[0];
                shreg_d = shreg_d >> 1;
            end    
        end
        S_DATA:begin
            if(timer == c_timerlim-1) begin
                tx_d = shreg_d[0];
                shreg_d = shreg_d >> 1;
                if(bitcntr == 3'd7) begin
                    tx_d = 1;
                end
            end
        end
        S_STOP:begin
            if(timer == (c_timerlim*c_stopbit)-1) begin
                tx_done_tick_d  = 1;
            end
        end
    endcase
end

always_ff @(posedge clk_i) begin :OUTPUT_FF_UPDATE
    if(!rstn_i) begin
        tx <= 1;
        tx_done_tick_o <= 0;
        shreg <= 0;
    end else begin
        tx <= tx_d;
        tx_done_tick_o <= tx_done_tick_d;
        shreg <= shreg_d;
    end
end

endmodule
