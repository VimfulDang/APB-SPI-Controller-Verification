class apb_pre_translator extends uvm_scoreboard;
    `uvm_component_utils(apb_pre_translator)
    
    //Tx - Connect respective feature scoreboard
    uvm_analysis_port #(device_cfg_msg) ap_tx_trans_cfg; 
    uvm_analysis_port #(device_data_msg) ap_tx_trans_data;
    
    //Rx - apb sequence item from monitor
    uvm_tlm_analysis_fifo #(apb_message) ap_rx_translator;
    
    //Messages
    apb_message         apb_msg;
    device_cfg_msg      cfg_msg;
    device_data_msg     data_msg;
    
    //Device Registers
    logic [31:0] device_reg[logic [31:0]];
    
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_tx_trans_cfg = new("ap_tx_trans_cfg", this);
        ap_tx_trans_data = new("ap_tx_trans_data", this);
        ap_rx_translator = new("ap_rx_translator", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            ap_rx_translator.get(apb_msg);
            if (apb_msg.rw) begin
		        if (apb_msg.address == `DATA_REG) begin
		            send_message();
		        end
		        else 
		            device_reg[apb_msg.address] = apb_msg.data;
            end
        end
    endtask
    
    task send_message();
        //CLK_RATE & CPOL & CPHA
        cfg_msg = new();
        cfg_msg.clk_rate = device_reg[`CLK_REG][7:0] * `APB_CLK_RATE;   //clock rate in ns
        cfg_msg.clk_pol = device_reg[`CTRL_REG][4];
        cfg_msg.clk_pha = device_reg[`CTRL_REG][3];
        ap_tx_trans_cfg.write(cfg_msg);
        
        //DATA & LSBF
        data_msg = new();
        data_msg.LSBF = device_reg[`CTRL_REG][6];
        data_msg.bts = get_bts();
        data_msg.data = get_data(apb_msg.data, data_msg.bts, data_msg.LSBF);
        //$display("Predicted Msg Time: %d", apb_msg.time_stamp);
        //$display("Predicted Msg Len: %d", data_msg.bts);
        ap_tx_trans_data.write(data_msg);        
    endtask
    
    //Invert Message
    function logic [31:0] get_data(input logic [31:0] data, int msg_len, logic lsbf);
        logic [31:0] out_data = 32'd0;
        for(int i = 0; i < msg_len; i++) begin
        	if (!lsbf)
            	out_data[i] = data[msg_len - 1 - i];
        	else
        		out_data[i] = data[i];
        end
        return out_data;
    endfunction
 
    
    function int get_bts();
        int bts;
        if (device_reg[`CTRL_REG][2]) begin
            if (device_reg[`CTRL_REG][11:8] != 4'b0000)
                bts = device_reg[`CTRL_REG][11:8];
            else
                bts = 16;
        end
        else
            bts = 8;
        return bts;
    endfunction

endclass
