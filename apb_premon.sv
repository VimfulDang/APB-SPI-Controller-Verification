class apb_premon extends uvm_monitor;
    `uvm_component_utils(apb_premon);
    
    uvm_analysis_port #(apb_message)   ap_premon;
    virtual apb_if                  apb_vi;
    apb_message                        msg;
     
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction 
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!(uvm_config_db #(virtual apb_if)::get(this, "*", "apb_vi", apb_vi)))
            `uvm_error("premon_vi", "Virtual Interface not set");
        ap_premon = new("mon_port", this);
    endfunction: build_phase
    
    task run_phase(uvm_phase phase);
        #20ns;
        forever begin
            @(posedge apb_vi.penable) begin
                #1ns;
                msg = new();
                msg.address = apb_vi.paddr;
                msg.rw = apb_vi.pwrite;
                msg.data = apb_vi.pwdata;
                msg.time_stamp = $time;
                ap_premon.write(msg);
            end
        end
    endtask
endclass: apb_premon
