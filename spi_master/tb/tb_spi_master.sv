module tb_spi_master();

parameter DATA_WIDTH = 8;

logic                  clk_i;    
logic                  rstn_i;     
logic                  en_i;
logic [DATA_WIDTH-1:0] tx_data_i;
logic [DATA_WIDTH-1:0] rx_data_o;
logic                  busy_o;
logic                  done_o;
logic                  sclk_o;
logic                  mosi_o;
logic                  miso_i;
logic                  cs_o;

logic [DATA_WIDTH-1:0] miso_data;
logic [DATA_WIDTH-1:0] miso_sig;
logic [DATA_WIDTH-1:0] mosi_reg;
logic [DATA_WIDTH-1:0] mosi_sig;

spi_master DUT(.*);

initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
end

initial begin
    rstn_i = 0;
    repeat(50) @(posedge(clk_i));
    rstn_i = 1;
    repeat(5) @(posedge(clk_i));
end

initial begin
    wait(rstn_i == 1);
    en_i = 0;
    tx_data_i = '0;
    repeat(15) @(posedge(clk_i));

//::::::::::::::::::::: CPOL = 0, CPHA = 0 ::::::::::::::::::::::::::::
// ===================== FIRST DATA =======================
    tx_data_i = 8'hA5;
    miso_sig = 8'hB2;
    miso_data = miso_sig;
    en_i = 1;
    wait(cs_o == 0);
    miso_i = miso_data[DATA_WIDTH-1];
    repeat(DATA_WIDTH-1)begin
        @(negedge(sclk_o));
        miso_data = miso_data << 1;
        miso_i = miso_data[DATA_WIDTH-1];
    end
    en_i = 0;
    wait(done_o);
    @(negedge(sclk_o));
// ===================== SECOND DATA =======================
    tx_data_i = 8'hCD;
    miso_sig = 8'hAF;
    miso_data = miso_sig;
    repeat(500) @(negedge(clk_i));
    en_i = 1;
    wait(cs_o == 0);
    miso_i = miso_data[DATA_WIDTH-1];
    repeat(DATA_WIDTH-1)begin
        @(negedge(sclk_o));
        miso_data = miso_data << 1;
        miso_i = miso_data[DATA_WIDTH-1];
    end
    en_i = 0;
    wait(done_o);
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    repeat(25) @(posedge(clk_i));
//:::::::::::::::::::: CONSECUTIVE TRANSFER ::::::::::::::::::::::::::::
//::::::::::::::::::::: CPOL = 0, CPHA = 0 ::::::::::::::::::::::::::::
    en_i = 1;
    repeat(10) begin
        tx_data_i = $random;
        miso_sig = $random;
        @(negedge(sclk_o));
        miso_data = miso_sig;
        miso_i = miso_data[DATA_WIDTH-1];
        repeat(DATA_WIDTH-1)begin
            @(negedge(sclk_o));
            miso_data = miso_data << 1;
            miso_i = miso_data[DATA_WIDTH-1];
        end
        wait(done_o);
    end
    en_i = 0;
    repeat(500) @(negedge(clk_i));
    
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


/*
//::::::::::::::::::::: CPOL = 0, CPHA = 1 ::::::::::::::::::::::::::::
// ===================== FIRST DATA =======================
    tx_data_i = 8'hA5;
    miso_sig = 8'hB2;
    miso_data = miso_sig;
    en_i = 1;
    @(posedge(sclk_o));
    miso_i = miso_data[DATA_WIDTH-1];
    repeat(DATA_WIDTH-1)begin
        @(posedge(sclk_o));
        miso_data = miso_data << 1;
        miso_i = miso_data[DATA_WIDTH-1];
    end
    en_i = 0;
    wait(done_o);
// ===================== SECOND DATA =======================
    tx_data_i = 8'hCD;
    miso_sig = 8'hAF;
    miso_data = miso_sig;
    repeat(500) @(negedge(clk_i));
    en_i = 1;
    @(posedge(sclk_o));
    miso_i = miso_data[DATA_WIDTH-1];
    repeat(DATA_WIDTH-1)begin
        @(posedge(sclk_o));
        miso_data = miso_data << 1;
        miso_i = miso_data[DATA_WIDTH-1];
    end
    en_i = 0;
    wait(done_o);
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    repeat(25) @(posedge(clk_i));
//:::::::::::::::::::: CONSECUTIVE TRANSFER ::::::::::::::::::::::::::::
//::::::::::::::::::::: CPOL = 0, CPHA = 1 ::::::::::::::::::::::::::::
    en_i = 1;
    repeat(10) begin
        tx_data_i = $random;
        miso_sig = $random;
        @(posedge(sclk_o));
        miso_data = miso_sig;
        miso_i = miso_data[DATA_WIDTH-1];
        repeat(DATA_WIDTH-1)begin
            @(posedge(sclk_o));
            miso_data = miso_data << 1;
            miso_i = miso_data[DATA_WIDTH-1];
        end
        wait(done_o);
    end
    en_i = 0;
    repeat(500) @(negedge(clk_i));
    
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/

/*
//::::::::::::::::::::: CPOL = 1, CPHA = 0 ::::::::::::::::::::::::::::
// ===================== FIRST DATA =======================
    tx_data_i = 8'hA5;
    miso_sig = 8'hB2;
    miso_data = miso_sig;
    en_i = 1;
    wait(cs_o == 0);
    miso_i = miso_data[DATA_WIDTH-1];
    repeat(DATA_WIDTH-1)begin
        @(posedge(sclk_o));
        miso_data = miso_data << 1;
        miso_i = miso_data[DATA_WIDTH-1];
    end
    en_i = 0;
    wait(done_o);
    @(posedge(sclk_o));
// ===================== SECOND DATA =======================
    tx_data_i = 8'hCD;
    miso_sig = 8'hAF;
    miso_data = miso_sig;
    repeat(500) @(negedge(clk_i));
    en_i = 1;
    wait(cs_o == 0);
    miso_i = miso_data[DATA_WIDTH-1];
    repeat(DATA_WIDTH-1)begin
        @(posedge(sclk_o));
        miso_data = miso_data << 1;
        miso_i = miso_data[DATA_WIDTH-1];
    end
    en_i = 0;
    wait(done_o);
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    repeat(25) @(posedge(clk_i));
//:::::::::::::::::::: CONSECUTIVE TRANSFER ::::::::::::::::::::::::::::
//::::::::::::::::::::: CPOL = 1, CPHA = 0 ::::::::::::::::::::::::::::
    en_i = 1;
    repeat(10) begin
        tx_data_i = $random;
        miso_sig = $random;
        @(posedge(sclk_o));
        miso_data = miso_sig;
        miso_i = miso_data[DATA_WIDTH-1];
        repeat(DATA_WIDTH-1)begin
            @(posedge(sclk_o));
            miso_data = miso_data << 1;
            miso_i = miso_data[DATA_WIDTH-1];
        end
        wait(done_o);
    end
    en_i = 0;
    repeat(500) @(negedge(clk_i));
    
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/

/*
//::::::::::::::::::::: CPOL = 1, CPHA = 1 ::::::::::::::::::::::::::::
// ===================== FIRST DATA =======================
    tx_data_i = 8'hA5;
    miso_sig = 8'hB2;
    miso_data = miso_sig;
    en_i = 1;
    @(negedge(sclk_o));
    miso_i = miso_data[DATA_WIDTH-1];
    repeat(DATA_WIDTH-1)begin
        @(negedge(sclk_o));
        miso_data = miso_data << 1;
        miso_i = miso_data[DATA_WIDTH-1];
    end
    en_i = 0;
    wait(done_o);
// ===================== SECOND DATA =======================
    tx_data_i = 8'hCD;
    miso_sig = 8'hAF;
    miso_data = miso_sig;
    repeat(500) @(negedge(clk_i));
    en_i = 1;
    @(negedge(sclk_o));
    miso_i = miso_data[DATA_WIDTH-1];
    repeat(DATA_WIDTH-1)begin
        @(negedge(sclk_o));
        miso_data = miso_data << 1;
        miso_i = miso_data[DATA_WIDTH-1];
    end
    en_i = 0;
    wait(done_o);
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    repeat(25) @(posedge(clk_i));
//:::::::::::::::::::: CONSECUTIVE TRANSFER ::::::::::::::::::::::::::::
//::::::::::::::::::::: CPOL = 1, CPHA = 1 ::::::::::::::::::::::::::::
    en_i = 1;
    repeat(10) begin
        tx_data_i = $random;
        miso_sig = $random;
        @(negedge(sclk_o));
        miso_data = miso_sig;
        miso_i = miso_data[DATA_WIDTH-1];
        repeat(DATA_WIDTH-1)begin
            @(negedge(sclk_o));
            miso_data = miso_data << 1;
            miso_i = miso_data[DATA_WIDTH-1];
        end
        wait(done_o);
    end
    en_i = 0;
    repeat(500) @(negedge(clk_i));
    
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
    repeat(500) @(posedge(clk_i));
    $finish;
end

// -- Sampling Edge
// 00: posedge
// 01: negedge
// 10: negedge
// 11: posedge

always_ff@(posedge sclk_o) begin
    if(!rstn_i) begin
        mosi_sig = 0;
    end else begin
        mosi_reg = mosi_reg << 1;
        mosi_reg[0] = mosi_o;
        if(done_o) begin
            mosi_sig = mosi_reg;
        end 
    end
end

initial begin
   $dumpfile("dump.vcd");
   $dumpvars();
end

endmodule
