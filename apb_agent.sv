class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)
    
    apb_driver              drv;
    apb_sequencer           seqr;
    apb_premon              pre_mon;    //ACTIVE = sequence, sequencer, monitor, and driver
    spi_postmon             post_mon;   //PASSIVE = monitor only
    apb_agent_config        agent_cfg;
    
    //Connect to sb outside of agents --> up hierarchy
    uvm_analysis_export #(apb_message)    pre_export_mon;
    uvm_analysis_export #(spi_packet)     post_export_mon;
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(apb_agent_config) :: get(this, "*", "agent_config", agent_cfg))
            `uvm_error("Agent Config", "Agent Configuration not set")
        `uvm_info("agent", $sformatf("Agent Active: %d", agent_cfg.active), UVM_LOW)
        if (agent_cfg.active == UVM_ACTIVE) begin
            `uvm_info("agent", "Making Active Monitor", UVM_LOW)
            drv = apb_driver::type_id::create("drv", this);
            seqr = apb_sequencer::type_id::create("seqr", this);
            pre_mon = apb_premon::type_id::create("pre_mon", this);
            pre_export_mon = new("pre_export_mon", this);
        end
        else begin
            `uvm_info("agent", "Making Passive Monitor", UVM_LOW)
            post_mon = spi_postmon::type_id::create("post_mon", this);
            post_export_mon = new("post_export_mon", this);
        end
        
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (agent_cfg.active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
            pre_mon.ap_premon.connect(pre_export_mon);
        end
        else
            post_mon.ap_postmon.connect(post_export_mon);
    endfunction: connect_phase
    
endclass: apb_agent
