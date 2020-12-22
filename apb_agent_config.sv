class apb_agent_config extends uvm_object;
    `uvm_object_utils(apb_agent_config)
    
    uvm_active_passive_enum active = UVM_ACTIVE;
    
    virtual apb_if apb_vi;
    
    function new(string name = "");
        super.new(name);
    endfunction
endclass
