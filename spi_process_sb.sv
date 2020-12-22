class spi_process_sb extends uvm_scoreboard;
    `uvm_component_utils(spi_process_sb);
    
    uvm_tlm_analysis_fifo #(spi_message)    ap_rx_process;
    
    uvm_analysis_port #(device_cfg_msg)     ap_tx_cfg;
    uvm_analysis_port #(device_data_msg)    ap_tx_data;
    
    spi_message         spi_msg;
    device_cfg_msg      cfg_msg;
    device_data_msg     data_msg;
    
    
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        ap_rx_process = new("ap_rx_process", this);
        ap_tx_cfg = new("ap_tx_cfg", this);
        ap_tx_data = new("ap_tx_data", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            ap_rx_process.get(spi_msg);
            //Clock rate, Clock Polarity, Clock Phase
            cfg_msg = process_cfg(spi_msg);
            ap_tx_cfg.write(cfg_msg);
            //Data, LSBF, bits per transfer
            //Need clock phase to determine which edge sample to keep
            data_msg = process_data(spi_msg, cfg_msg.clk_pha);
            ap_tx_data.write(data_msg);
        end
    endtask
    
    
//////////////////////////////////////////////////////////////////////  
//Process cfg     
    function device_cfg_msg process_cfg(spi_message message);
        device_cfg_msg temp_cfg_msg;
        temp_cfg_msg = new();
        temp_cfg_msg.clk_rate = get_clk_rate(message);
        temp_cfg_msg.clk_pha = get_clk_phase(message);
        temp_cfg_msg.clk_pol = message.clk_trace[0];
        return temp_cfg_msg;
    endfunction
 
    function time get_clk_rate(spi_message message);
        time avg_time;
        time old_time = message.time_stamp[0];
        for(int i = 1; i < message.message_length; i++) begin
            avg_time += (message.time_stamp[i] - old_time);
            old_time = message.time_stamp[i];
        end
        avg_time /= (message.message_length / 2);
        return avg_time;
    endfunction
    
    function logic[1:0] get_clk_phase(spi_message message);
        logic old_value, old_clk;
        logic [1:0] clk_phase = 2'b01;
        logic clk_pol = message.clk_trace[0];
        old_value = message.data[0];
        old_clk = message.clk_trace[0];
        for(int i = 0; i < message.message_length; i++) begin
            if (message.data[i] != old_value) begin //data transition
                if (message.clk_trace[i] < old_clk) //falling edge
                    clk_phase = clk_pol;
                else
                    clk_phase = ~clk_pol;
                clk_phase[1] = 1'b1;
                break;
            end
            else begin
                old_value = message.data[i];
                old_clk = message.clk_trace[i];
            end
        end
        if (clk_phase == 2'b01) begin
            `uvm_info("SPI Process", "Data is all 0's or all 1's", UVM_LOW)
            clk_phase[0] = clk_pol;
        end
            
        return clk_phase;
    endfunction
///////////////////////////////////////////////////////////////////////
//Process Data
    function device_data_msg process_data(spi_message message, logic clk_phase);
        device_data_msg temp_msg;
        //`uvm_info("Process Data", message.toStr(), UVM_LOW)
        temp_msg = new();
        //subtract start & end SSEL samples
        temp_msg.bts = (message.message_length - 2)/ 2;  
        temp_msg.data = get_data(message.data, clk_phase, message.message_length - 2);
        //can't verify here
        temp_msg.LSBF = 0; 
        return temp_msg; 
    endfunction
    
    function logic[31:0] get_data(logic [33:0] data, logic clk_phase, int len);
        logic [31:0] temp_data = 32'd0;
        //$display("len: %d", len);
        //clk_phase = 0, sample odd indexes, starts at index 1
        //clk_phase = 1, sample even indexes, starts at index 2
        for(int i = 0; i < len/2; i++) begin
            temp_data[i] = data[i*2 + 1 + clk_phase];             
        end
        //$display("temp_data: %h", temp_data);
        return temp_data;
    endfunction
endclass
