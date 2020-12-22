class apb_env extends uvm_env;
    `uvm_component_utils(apb_env);
    
    apb_agent           act_agent;  //Active
    apb_agent           pass_agent; //Passive
    apb_agent_config    agent_cfg;  //Config
    apb_env_config      env_cfg;
    
    //APB Predictor
    apb_pre_translator  apb_trans;
    
    //SPI Verification
    spi_translator      spi_trans;
    spi_process_sb      spi_process;
    
    //Comparison checkers
    compsb_cfg          cfg_checker;
    compsb_data         data_checker;
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //Set environment config
        if (!uvm_config_db #(apb_env_config)::get(this, "*", "env_config", env_cfg))
            `uvm_error("env_cfg", "Environment Configuration not set")
        //Create agent & set agent_config
        if (env_cfg.has_act_agent) begin
            `uvm_info("Environment", "Active Agent Present", UVM_LOW)
            uvm_config_db #(apb_agent_config)::set(this, "act_agent*", "agent_config", env_cfg.act_agent_cfg);
            act_agent = apb_agent::type_id::create("act_agent", this);
        end
        if (env_cfg.has_pass_agent) begin
            `uvm_info("Environment", "Passive Agent Present", UVM_LOW)
            uvm_config_db #(apb_agent_config)::set(this, "pass_agent*", "agent_config", env_cfg.pass_agent_cfg);
            pass_agent = apb_agent::type_id::create("pass_agent", this);
        end
        //Create scoreboards
        apb_trans = apb_pre_translator::type_id::create("apb_trans", this);
        spi_trans = spi_translator::type_id::create("spi_post_translator", this);
        spi_process = spi_process_sb::type_id::create("spi_process", this);
        cfg_checker = compsb_cfg::type_id::create("cfg_checker", this);
        data_checker = compsb_data::type_id::create("data_checker", this);
        
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //connect predictor path
        if (env_cfg.has_act_agent) begin
            act_agent.pre_export_mon.connect(apb_trans.ap_rx_translator.analysis_export);
            apb_trans.ap_tx_trans_cfg.connect(cfg_checker.pre_port.analysis_export);
            apb_trans.ap_tx_trans_data.connect(data_checker.pre_port.analysis_export);
        end
        //connect SPI path
        if (env_cfg.has_pass_agent) begin
            pass_agent.post_export_mon.connect(spi_trans.ap_rx_translator.analysis_export);
            spi_trans.ap_tx_translator.connect(spi_process.ap_rx_process.analysis_export);
            spi_process.ap_tx_cfg.connect(cfg_checker.post_port.analysis_export);
            spi_process.ap_tx_data.connect(data_checker.post_port.analysis_export);
                   
        end
    endfunction
endclass: apb_env
