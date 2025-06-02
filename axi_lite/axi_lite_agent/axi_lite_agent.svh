class axi_lite_agent extends uvm_agent;
    `uvm_component_utils(axi_lite_agent)

    axi_lite_slave_driver                         driver;
    axi_lite_monitor                        monitor;   
    uvm_sequencer#(axi_lite_seq_item)       sequencer;

    axi_lite_agent_config                   agent_cfg;

    uvm_analysis_port#(axi_lite_seq_item)   agent_aport;
    
    function new(string name = "axi_lite_agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info("[UVM agent / axi_lite]", "constructor", UVM_HIGH)
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        `uvm_info("[UVM agent / axi_lite]", "build_phase", UVM_HIGH)
        if(!uvm_config_db #(axi_lite_agent_config)::get(this, "", "axi_lite_config", agent_cfg)) begin
            `uvm_fatal("axi_lite_agent/build_phase", "");
        end
        driver  = axi_lite_slave_driver::type_id::create("axi_lite_slave_driver", this);
        monitor     = axi_lite_monitor::type_id::create("axi_lite_monitor", this);
        sequencer   = uvm_sequencer #(axi_lite_seq_item)::type_id::create("axi_lite_sequencer", this);
        agent_aport = new("axi_lite_agent_aport", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        `uvm_info("AGENT", "connect_phase", UVM_HIGH)
 
        driver.seq_item_port.connect(sequencer.seq_item_export);
        agent_aport = monitor.a_port;
    endfunction: connect_phase
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
    
endclass: axi_lite_agent