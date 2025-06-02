class config_analysis_config extends uvm_object;
    `uvm_object_utils(config_analysis_config)
    
    int data_width = `DATA_WIDTH;
    
    function new(string name="config_analysis_config");
        super.new(name);
        `uvm_info("[config_analysis_conifg]","working",UVM_LOW);
    endfunction: new
    
endclass : config_analysis_config