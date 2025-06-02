class config_monitor extends uvm_monitor;
    `uvm_component_utils(config_monitor)

    virtual config_if#(`DATA_WIDTH)       config_vif;
    config_agent_config                   config_agt_cfg;
    uvm_analysis_port #(config_seq_item)  a_port;

    function new(string name="config_monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info("config_monitor", "constructor", UVM_LOW);
        a_port  = new("a_port", this);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(config_agent_config)::get(this, "", "config_agt_cfg", config_agt_cfg)) begin
            `uvm_fatal("config_monitor", "No config_agent_config has found");
        end
        config_vif = config_agt_cfg.config_vif;
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        config_seq_item config_txn;
        super.run_phase(phase);
       `uvm_info("[MONITOR]", "run_phase", UVM_HIGH)

        @(posedge this.config_vif.cbm.rst_i);

        forever begin
            config_txn = config_seq_item::type_id::create("axi_txn", this);
            collect_transaction(config_txn);
            a_port.write(config_txn);
        end       
    endtask: run_phase 

    task collect_transaction (config_seq_item config_txn);
        logic [31:0] InputImageAddress;
        logic [31:0] OutputImageAddress;
        logic        BeginConv;
        logic [7:0]  heightOfImage;
        logic [7:0]  widthOfImage;
        logic [7:0]  NumberOfFilters;

        @(this.config_vif.cbm);
        InputImageAddress   = this.config_vif.cbm.InputImageAddress;
        OutputImageAddress  = this.config_vif.cbm.OutputImageAddress;
        BeginConv           = this.config_vif.cbm.BeginConv;
        heightOfImage       = this.config_vif.cbm.heightOfImage;
        widthOfImage        = this.config_vif.cbm.widthOfImage;
        NumberOfFilters     = this.config_vif.cbm.NumberOfFilters;
        
        config_txn.set_data(InputImageAddress, OutputImageAddress, BeginConv, heightOfImage, widthOfImage, NumberOfFilters);

    endtask: collect_transaction  
endclass: config_monitor

