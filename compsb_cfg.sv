//Verifies clock rate, clock polarity, clock phase

class compsb_cfg extends uvm_scoreboard;
    `uvm_component_utils(compsb_cfg);
    
    uvm_tlm_analysis_fifo #(device_cfg_msg)     pre_port; //predictor message
    uvm_tlm_analysis_fifo #(device_cfg_msg)      post_port; //spi sb message
    
    
    device_cfg_msg      pre_msg, post_msg;
    
    
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
            if (pre_msg.clk_rate != post_msg.clk_rate)
                `uvm_error("Setting Error", "BAD Clock Rate")
            //else
                //`uvm_info("Setting Checker", "GOOD Clock Rate", UVM_LOW)
            if (pre_msg.clk_pol != post_msg.clk_pol)
                `uvm_error("Setting Error", "BAD Clock Polarity")
            //else
                //`uvm_info("Setting Checker", "GOOD Clock Polarity", UVM_LOW)
            if (pre_msg.clk_pha != post_msg.clk_pha) begin
                if (post_msg.clk_pha[1])
                    `uvm_info("Setting Checker", "Clock Phase Exception, Data was all 1s or 0s", UVM_HIGH)
                else
                    `uvm_error("Setting Error", $sformatf("BAD Clock Phase\nExpected:%h Received:%h",pre_msg.clk_pha, post_msg.clk_pha))
            end
            //else
                //`uvm_info("Setting Checker", "GOOD Clock Phase", UVM_LOW)
        end
    endtask
endclass

