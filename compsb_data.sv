  
class compsb_data extends uvm_scoreboard;
    `uvm_component_utils(compsb_data)
    
    
    uvm_tlm_analysis_fifo   #(device_data_msg)   pre_port;
    uvm_tlm_analysis_fifo   #(device_data_msg)   post_port;
    
    device_data_msg     pre_msg, post_msg;

    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        pre_port = new("pre_port", this);
        post_port = new("post_port", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            pre_port.get(pre_msg);
            post_port.get(post_msg);
            if (pre_msg.data !== post_msg.data)
                if(pre_msg.data !== data_reverse(post_msg.data))
                    `uvm_error("Data Error", $sformatf("Bad Data\nExpected: %h Received: %h", pre_msg.data, post_msg.data))
                else
                    `uvm_error("Data Error", $sformatf("BAD LSBF\nExpected:%h Received:%h", pre_msg.data, post_msg.data)); 
            //else
                //`uvm_info("Data Checker", "GOOD Data & LSBF", UVM_LOW)                   
            if (pre_msg.bts != post_msg.bts)
                `uvm_error("Data Checker", "BAD Bits per Second")
            //else
                //`uvm_info("Data Checker", "GOOD Bits per Second", UVM_LOW)
        end
    endtask
    
    function logic [31:0] data_reverse(input logic [31:0] data);
        logic [31:0] out_data = 32'd0;
        for(int i = 0; i < pre_msg.bts; i++) begin
            out_data[i] = data[pre_msg.bts - 1 - i];
        end
        //$display("out_data:%h", out_data);
        return out_data;
    endfunction
    
    
endclass
