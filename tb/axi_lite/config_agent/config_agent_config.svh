class config_agent_config extends uvm_object;
    `uvm_object_utils(config_agent_config)

    bit         is_master           = 1'b1;
    int         data_width          = `DATA_WIDTH;
    virtual config_if#(`DATA_WIDTH)     config_vif;
    
    function new(string name="config_agent_config");
        super.new(name);
        `uvm_info("[config_agent_config]", "constructor", UVM_LOW);
    endfunction: new

endclass: config_agent_config