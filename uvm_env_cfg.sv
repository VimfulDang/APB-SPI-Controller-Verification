class apb_env_config extends uvm_object;
    `uvm_object_utils(apb_env_config)
    
    bit has_pass_agent = 1'b1;
    bit has_act_agent  = 1'b1;
    
    apb_agent_config    pass_agent_cfg;
    apb_agent_config    act_agent_cfg;
    
    function new(string name = "");
        super.new(name);
    endfunction
    
endclass
