class axi_lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi_lite_monitor)

    virtual axi_lite_if           axi_lite_vif;
    axi_lite_agent_config                   axi_lite_config;
    uvm_analysis_port #(axi_lite_seq_item)  a_port;

    function new(string name="axi_lite_monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info("axi_lite_monitor", "constructor", UVM_LOW);
        a_port  = new("a_port", this);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(axi_lite_agent_config)::get(this, "", "axi_lite_config", axi_lite_config)) begin
            `uvm_fatal("axi_lite_monitor", "No axi_lite_agent_config has found");
        end
        axi_lite_vif = axi_lite_config.axi_lite_svif;
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        axi_lite_seq_item axi_lite_txn;
        super.run_phase(phase);
       `uvm_info("[MONITOR]", "run_phase", UVM_HIGH)

        @(posedge this.axi_lite_vif.cbm.rst_i);

        forever begin
            axi_lite_txn = axi_lite_seq_item::type_id::create("axi_txn", this);
            collect_transaction(axi_lite_txn);
            a_port.write(axi_lite_txn);
        end       
    endtask: run_phase 

    // task collect_transaction (axi_lite_seq_item axi_lite_txn);

    //     logic [31:0] data[$];
    //     logic [5:0] addr[$];

    //     logic  [5:0]             awaddr;
    //     logic  [2:0]             awprot;
    //     logic                    awvalid;
    //     logic                    awready;

    //     logic  [31:0]  wdata;
    //     logic  [3:0]  wstrb;
    //     logic                    wvalid;
    //     logic                    wready;

    //     logic  [1:0]             bresp;
    //     logic                    bvalid;
    //     logic                    bready;

    //     while(axi_lite_vif.cbm.wvalid == 1'b1) begin            
    //         wdata          = axi_lite_vif.cbm.wdata;
    //         @(this.axi_lite_vif.cbm);

    //         data.push_back(wdata);
    //         if (axi_lite_vif.cbm.wvalid == 1'b0) break;
    //     end

    //     while(axi_lite_vif.cbm.awvalid == 1'b1) begin            
    //         awaddr         = axi_lite_vif.cbm.awaddr;
    //         @(this.axi_lite_vif.cbm);
    //         data.push_back(awaddr);
    //         if (axi_lite_vif.cbm.awvalid == 1'b0) break;
    //     end

    //     if(bready && bvalid) begin
    //         bresp = axi_lite_vif.cbm.bresp;
    //     end

    //     axi_lite_txn.set_data(data, addr);
    //     axi_lite_txn.set_response(bresp);

    // endtask: collect_transaction  

    task collect_transaction(axi_lite_seq_item axi_lite_txn);
    logic [31:0] data[$];
    logic [5:0] addr[$];
    logic [1:0] bresp;

    // Wait for valid write address
    @(posedge axi_lite_vif.cbm.awvalid);
    addr.push_back(axi_lite_vif.cbm.awaddr);
    
    // Wait for valid write data
    @(posedge axi_lite_vif.cbm.wvalid);
    data.push_back(axi_lite_vif.cbm.wdata);
    
    // Wait for write response
    fork
        begin
            @(posedge axi_lite_vif.cbm.bvalid);
            bresp = axi_lite_vif.cbm.bresp;
        end
        begin
            // Timeout protection
            #100ns;
            `uvm_error("TIMEOUT", "No write response received")
        end
    join_any
    disable fork;

    axi_lite_txn.set_data(data, addr);
    axi_lite_txn.set_response(bresp);
endtask
endclass: axi_lite_monitor

