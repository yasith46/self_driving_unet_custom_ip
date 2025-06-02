class axi_lite_agent_config extends uvm_object;
    `uvm_object_utils(axi_lite_agent_config)

    bit         is_master           = 1'b1;
    int         data_width          = `DATA_WIDTH;
    virtual axi_lite_if     axi_lite_svif;
    
    function new(string name="axi_lite_agent_config");
        super.new(name);
        `uvm_info("[axi_lite_agent_config]", "constructor", UVM_LOW);
    endfunction: new

endclass: axi_lite_agent_config