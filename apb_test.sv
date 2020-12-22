class apb_test extends uvm_test;
    `uvm_component_utils(apb_test);
    
    apb_env     env;
    apb_env_config env_cfg;
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        env_cfg = apb_env_config::type_id::create("env_cfg");
        env_cfg.pass_agent_cfg = apb_agent_config::type_id::create("pass_agent_cfg");
        env_cfg.act_agent_cfg = apb_agent_config::type_id::create("act_agent_cfg");
        env_cfg.has_pass_agent = 1'b1;
        env_cfg.pass_agent_cfg.active = UVM_PASSIVE;
        env_cfg.has_act_agent = 1'b1;
        env_cfg.act_agent_cfg.active = UVM_ACTIVE;
        env = apb_env::type_id::create("env", this);
        uvm_config_db #(apb_env_config)::set(this, "*", "env_config", env_cfg);
    endfunction: build_phase
    
    task run_phase(uvm_phase phase);
        apb_seq     seq;
        seq = apb_seq::type_id::create("seq");
        phase.raise_objection(this, "Test Started");
        seq.start(env.act_agent.seqr);
        phase.drop_objection(this, "Test Finished");
        `uvm_info("DUT Randomization", "\n***************************************\nSet random enable in DUT for verification of testbench\n***************************************", UVM_LOW);
    endtask: run_phase
    
endclass
