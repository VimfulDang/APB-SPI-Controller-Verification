//Predictor message from translator to verify Clock Rate, Clock polarity, clock phase
class device_cfg_msg;
    logic [3:0] clk_rate;
    logic [1:0] clk_pha; 
    logic clk_pol;
    
    function new();
        clk_rate = 4'd0;
        clk_pol = 0;
        clk_pha = 2'd0;
    endfunction
endclass

//Predictor message from translator to verify data, LSBF setting, and bits per transfer
class device_data_msg;
    logic [31:0] data;
    logic LSBF;    
    int bts;
    
    function new();
        data = 32'd0;
        LSBF = 1'b1;
        bts = 0;
    endfunction
    
    function string toStr();
        string str = $sformatf("Data: %h LSBF: %h bts: %h", data, LSBF, bts);
        return str;
    endfunction
endclass

//Predictor Monitor message to translator of APB bus
class apb_message;
    logic [31:0] address, data, rw;   
    time time_stamp; 
    function new();
        address = 32'd0;
        data = 32'd0;
        rw = 32'd0;
        time_stamp = 0;
    endfunction
endclass

//DUT Monitor message to post translator
class spi_packet;
    logic sck, mosi, ssel, miso;
    time time_stamp;
    function new();
        sck = 0;
        mosi = 0;
        ssel = 1;
        miso = 0;
        time_stamp = 0;
    endfunction
endclass

//SPI data and clk waveform
class spi_message;
    logic [33:0] data;
    logic [33:0] clk_trace;
    time time_stamp[33];
    int message_length;
    
    function new();
        data = 34'd0;
        clk_trace = 34'd0;
        message_length = 0;
    endfunction    
    
    function string toStr();
        string temp_str;
        temp_str = $sformatf("\nData: %b\nTrace:%b\nmessage_length: %d\nTime Start:%d", data, clk_trace, message_length, time_stamp[0]);
        return temp_str;
    endfunction
endclass
    
    
