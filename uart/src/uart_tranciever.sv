module uart_tranciever#(
    parameter int c_clkfreq = 100_000_000, 
    parameter int c_baudrate = 10_000_000,
    parameter int c_stopbit = 2  
    
)(
    input  logic        clk_i,
    input  logic        rstn_i,
    input  logic        tx_start_i,
    input  logic [7:0]  tx_din_i,
    input  logic        rx_din_i,
    output logic        tx_dout_o,
    output logic        tx_done_tick_o,
    output logic        tx_active_o,
    output logic [7:0]  rx_dout_o,
    output logic        rx_done_tick_o,
    output logic        rx_active_o
);

localparam int c_timerlim = c_clkfreq/c_baudrate;

uart_tx#(
    .c_clkfreq(c_clkfreq),
    .c_baudrate(c_baudrate),
    .c_stopbit(c_stopbit)
)i_uart_tx
(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .tx_din_i(tx_din_i),
    .tx_start_i(tx_start_i),
    .tx_o(tx_dout_o),
    .tx_done_tick_o(tx_done_tick_o),
    .tx_active_o(tx_active_o)
);

uart_rx#(
    .c_clkfreq(c_clkfreq),
    .c_baudrate(c_baudrate)
)i_uart_rx
(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .rx_i(rx_din_i),
    .rx_dout_o(rx_dout_o),
    .rx_done_tick_o(rx_done_tick_o),
    .rx_active_o(rx_active_o)
);

endmodule
