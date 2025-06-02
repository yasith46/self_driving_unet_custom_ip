class config_agent extends uvm_agent;
    `uvm_component_utils(config_agent)

    config_monitor                        monitor;   
    config_agent_config                   config_agt_cfg;

    uvm_analysis_port#(config_seq_item)   agent_aport;
   
    function new(string name = "config_agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info("[UVM agent / config]", "constructor", UVM_HIGH)
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        `uvm_info("[UVM agent / config]", "build_phase", UVM_HIGH)
        if(!uvm_config_db #(config_agent_config)::get(this, "", "config_agt_cfg", config_agt_cfg)) begin
            `uvm_fatal("config_agent/build_phase", "");
        end
        monitor     = config_monitor::type_id::create("config_monitor", this);
        agent_aport = new("config_agent_aport", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        `uvm_info("AGENT", "connect_phase", UVM_HIGH)
 
        agent_aport = monitor.a_port;
    endfunction: connect_phase
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
    
endclass: config_agent