module spi_master#(
    parameter  CLKFREQ    = 100_000_000,
    parameter  SCLKFREQ   = 1_000_000, 
    parameter  DATA_WIDTH = 8,
    parameter bit CPOL   = 0,
    parameter bit CPHA   = 0
)(
    input  logic                  clk_i,    
    input  logic                  rstn_i,           
    
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] tx_data_i,
    output logic [DATA_WIDTH-1:0] rx_data_o,
    output logic                  busy_o,
    output logic                  done_o,

    output logic                  sclk_o,
    output logic                  mosi_o,
    input  logic                  miso_i,
    output logic                  cs_o
);

localparam HALF_TIME = ((CLKFREQ / SCLKFREQ))/2;

typedef enum logic [1:0] {S_IDLE, S_TRANSFER, S_DONE} states_t;
states_t                         state; 
states_t                         next_state;

logic [$clog2(DATA_WIDTH)-1:0]   bitcnt;
logic [$clog2(DATA_WIDTH)-1:0]   bitcnt_d;
logic [$clog2(HALF_TIME)-1:0 ]   cnt;
logic [$clog2(HALF_TIME)-1:0 ]   cnt_d;
logic [$clog2(HALF_TIME)-1:0 ]   donecnt;
logic [$clog2(HALF_TIME)-1:0 ]   donecnt_d;
logic [DATA_WIDTH-1:0        ]   shreg_tx;
logic [DATA_WIDTH-1:0        ]   shreg_tx_d;
logic [DATA_WIDTH-1:0        ]   shreg_rx;
logic [DATA_WIDTH-1:0        ]   shreg_rx_d;
logic [DATA_WIDTH-1:0        ]   rx_data_d;
logic [1:0                   ]   pol_pha;
logic                            cs_d;
logic                            sclk_d;
logic                            mosi_d;
logic                            busy_d;
logic                            done_d;
logic                            sclk_en;
logic                            sclk_en_d;
logic                            rise;
logic                            fall;
logic                            last_smpl;
logic                            last_smpl_d;

assign pol_pha = {CPOL,CPHA};

edge_detector edge_detector_Inst(
    .clk_i (clk_i ), 
    .rstn_i(rstn_i ),
    .in_i  (sclk_d),  
    .rise_o(rise  ),
    .fall_o(fall  )
);

always_comb begin : COMB_PART
    cs_d         = cs_o;
    busy_d       = busy_o;
    done_d       = 0;
    last_smpl_d  = last_smpl;
    mosi_d       = mosi_o;
    sclk_en_d    = sclk_en;
    bitcnt_d     = bitcnt;
    donecnt_d    = donecnt;
    shreg_tx_d   = shreg_tx;
    shreg_rx_d   = shreg_rx;
    rx_data_d    = rx_data_o;
    next_state   = state;    
    case(state)
        S_IDLE: begin
            cs_d       = 1;
            sclk_en_d  = 0;
            busy_d     = 0;
            shreg_tx_d = '0;
            last_smpl_d= 0;
            if(en_i) begin
                sclk_en_d  = 1;
                cs_d       = 0;
                busy_d     = 1;    
                shreg_tx_d = tx_data_i;
                case (pol_pha) inside
                    2'b?0: begin
                        mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                        next_state = S_TRANSFER;
                    end
                    2'b01: begin
                        if(rise) begin
                            mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                            next_state = S_TRANSFER;
                        end
                    end
                    2'b11: begin
                        if(fall) begin
                            mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                            next_state = S_TRANSFER;
                        end
                    end
                endcase
            end
        end
        S_TRANSFER: begin
            case(pol_pha)
                2'b00: begin
                    if(fall) begin
                        shreg_tx_d = shreg_tx_d << 1;
                        mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                        bitcnt_d   = bitcnt + 1;
                        if(bitcnt == DATA_WIDTH-1) begin
                            bitcnt_d   = 0;
                             if(en_i) begin
                                shreg_tx_d = tx_data_i;
                                mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                            end else begin
                                next_state   = S_DONE;
                                sclk_en_d    = 0;
                            end
                        end
                    end else if(rise) begin
                        shreg_rx_d    = shreg_rx_d << 1;
                        shreg_rx_d[0] = miso_i;
                        if(bitcnt == DATA_WIDTH-1) begin
                            done_d     = 1;
                            rx_data_d  = shreg_rx_d;
                        end
                    end 
                end
                2'b01: begin
                    if(rise) begin
                        shreg_tx_d = shreg_tx_d << 1;
                        mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                        if(last_smpl) begin
                            last_smpl_d = 0;
                            shreg_tx_d = tx_data_i;
                            mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                        end
                    end else if(fall) begin
                        shreg_rx_d    = shreg_rx_d << 1;
                        shreg_rx_d[0] = miso_i;
                        bitcnt_d   = bitcnt + 1;
                        if(bitcnt == DATA_WIDTH-1) begin
                            bitcnt_d   = 0;
                            rx_data_d  = shreg_rx_d;
                            done_d     = 1;
                            if(!en_i) begin
                                sclk_en_d  = 0;
                                next_state = S_DONE;
                            end else begin
                                last_smpl_d= 1;
                            end
                        end
                    end
                end
                2'b10: begin
                    if(rise) begin
                        shreg_tx_d = shreg_tx_d << 1;
                        mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                        bitcnt_d   = bitcnt + 1;
                        if(bitcnt == DATA_WIDTH-1) begin
                            bitcnt_d = 0;
                             if(en_i) begin
                                shreg_tx_d = tx_data_i;
                                mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                            end else begin
                                next_state = S_DONE;
                                sclk_en_d  = 0;
                            end
                        end
                    end else if(fall) begin
                        shreg_rx_d    = shreg_rx_d << 1;
                        shreg_rx_d[0] = miso_i;
                        if(bitcnt == DATA_WIDTH-1) begin
                            done_d     = 1;
                            rx_data_d  = shreg_rx_d;
                        end
                    end
                end
                2'b11: begin
                    if(fall) begin
                        shreg_tx_d = shreg_tx_d << 1;
                        mosi_d     = shreg_tx_d[DATA_WIDTH-1];
                        if(last_smpl) begin
                            last_smpl_d = 0;
                            shreg_tx_d  = tx_data_i;
                            mosi_d      = shreg_tx_d[DATA_WIDTH-1];
                        end
                    end else if(rise) begin    
                        shreg_rx_d    = shreg_rx_d << 1;
                        shreg_rx_d[0] = miso_i;
                        bitcnt_d   = bitcnt + 1;
                        if(bitcnt == DATA_WIDTH-1) begin
                            bitcnt_d   = 0;
                            rx_data_d  = shreg_rx_d;
                            done_d     = 1;
                            if(!en_i) begin
                                sclk_en_d  = 0;
                                next_state = S_DONE;
                            end else begin
                                last_smpl_d= 1;
                            end
                        end
                    end
                end
            endcase
        end
        S_DONE: begin
            if(donecnt == HALF_TIME-1) begin
                donecnt_d  = 0;
                cs_d       = 1;
                busy_d     = 0;
                next_state = S_IDLE;
            end else begin
                donecnt_d = donecnt + 1;
            end
        end
    endcase
end

always_comb begin : SCLK_GEN
    cnt_d  = 0;
    sclk_d = sclk_o;
    if(sclk_en) begin
        if(cnt == HALF_TIME-1) begin
            sclk_d = ~sclk_d;
            cnt_d  = 0;
        end else begin
            cnt_d = cnt + 1;
        end
    end else begin
        if(pol_pha[1] == 0) begin
            sclk_d = 0;        
        end else begin
            sclk_d = 1;
        end
    end
end

always_ff @(posedge clk_i) begin : SEQ_PART
    if(!rstn_i) begin
        cs_o      <= 1;
        busy_o    <= 0;
        done_o    <= 0;
        mosi_o    <= 0;
        rx_data_o <= '0;
        shreg_tx  <= 0;
        shreg_rx  <= 0;
        sclk_en   <= 0;
        sclk_o    <= 0;
        cnt       <= 0;
        bitcnt    <= 0;
        donecnt   <= 0;
        last_smpl <= 0;
        state     <= S_IDLE;
    end else begin
        cs_o      <= cs_d;
        busy_o    <= busy_d;
        done_o    <= done_d;
        mosi_o    <= mosi_d;
        rx_data_o <= rx_data_d;
        shreg_tx  <= shreg_tx_d;
        shreg_rx  <= shreg_rx_d;
        sclk_en   <= sclk_en_d;
        sclk_o    <= sclk_d;
        cnt       <= cnt_d;
        bitcnt    <= bitcnt_d;
        state     <= next_state;
        donecnt   <= donecnt_d;
        last_smpl <= last_smpl_d;
    end
end
endmodule
