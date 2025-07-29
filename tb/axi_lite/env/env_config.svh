class env_config extends uvm_object;
    `uvm_object_utils(env_config)
    
    int         data_width          = `DATA_WIDTH;
    // logic [1:0] slave_driver_mode   = 2'b00;   
    virtual config_if                     config_vif;
    virtual axi_lite_if     axi_lite_svif;
    
//---------------------------------------------------------------------------------------------------------------------
// Constructor
//---------------------------------------------------------------------------------------------------------------------
    function new(string name="env_config");
        super.new(name);
        `uvm_info("[env_config]", "working", UVM_LOW);
    endfunction: new
endclass : env_config