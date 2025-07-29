class axi_lite_slave_driver extends uvm_driver #(axi_lite_seq_item);
    `uvm_component_utils(axi_lite_slave_driver)

    virtual axi_lite_if           axi_lite_vif;
    axi_lite_agent_config         axi_lite_config;

    function new(string name="axi_lite_slave_driver", uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase); 
        if(!uvm_config_db #(axi_lite_agent_config)::get(this, "", "axi_lite_config", axi_lite_config)) begin
            `uvm_fatal("config_monitor", "No config_agent_config has found");
        end
        axi_lite_vif = axi_lite_config.axi_lite_svif;
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        axi_lite_seq_item axi_lite_txn;
        super.run_phase(phase);

        // Initialize all inputs
        axi_lite_vif.cbsd.bready <= 0;
        
        // Wait for reset to complete
        wait(axi_lite_vif.cbsd.rst_i === 1'b0);
        
        forever begin
            axi_lite_txn = axi_lite_seq_item::type_id::create("axi_lite_slave_txn");
            seq_item_port.get_next_item(axi_lite_txn);
            axi_lite_transfer(axi_lite_txn);
            seq_item_port.item_done();
        end
    endtask: run_phase
    
    task axi_lite_transfer (axi_lite_seq_item axi_lite_txn);
        logic [31:0] data [$];
        logic [5:0] addr [$];
        int unsigned data_length_in_words;
        int unsigned addr_length_in_words;  

        logic  [5:0]             awaddr;
        logic  [2:0]             awprot;
        logic                    awvalid;

        //WRITE DATA BUS
        logic  [31:0]            wdata;
        logic  [3:0]             wstrb;
        logic                    wvalid;

        int i, j = 0;
        
        axi_lite_txn.get_data(data, addr);

        data_length_in_words       = data.size();  
        addr_length_in_words       = addr.size();  

        axi_lite_vif.cbsd.bready <= 1;

        while (i < data_length_in_words || j < addr_length_in_words) begin
            @(this.axi_lite_vif.cbsd);
            if (axi_lite_vif.cbsd.wready) begin
                wvalid = 1'b1;
                wstrb  = {(`DATA_WIDTH/8){1'b1}};
                wdata  = data.pop_front();
                i += 1;
            end 

            if (axi_lite_vif.cbsd.awready) begin
                awvalid = 1'b1;
                awprot  = {(`DATA_WIDTH/8){1'b1}};
                awaddr  = addr.pop_front();
                j += 1;
            end 
            // Setting interface signals based on axis_txn data
            axi_lite_vif.cbsd.wdata   <= wdata;
            axi_lite_vif.cbsd.wstrb   <= wstrb;
            axi_lite_vif.cbsd.wvalid  <= wvalid;
            axi_lite_vif.cbsd.awaddr  <= awaddr;
            axi_lite_vif.cbsd.awprot  <= awprot;
            axi_lite_vif.cbsd.awvalid <= awvalid;     
        end

    endtask: axi_lite_transfer 

endclass: axi_lite_slave_driver