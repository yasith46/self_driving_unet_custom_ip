class axi_lite_test extends uvm_test;
    `uvm_component_utils(axi_lite_test)

    int     data_width          = `DATA_WIDTH;
    virtual config_if                     config_vif;
    virtual axi_lite_if     axi_lite_svif;

    axi_lite_env    a_env;
    env_config      env_config_obj;

    virtual function void set_data_width(int data_width);
        this.data_width = data_width;
    endfunction: set_data_width    
   
    function new(string name="axi_lite_test", uvm_component parent);
        super.new(name, parent);
        `uvm_info("[TEST]", "top level axi_lite_test constructor", UVM_LOW)
    endfunction: new

    function void build_phase(uvm_phase phase);
        `uvm_info("[TEST]","build_phase", UVM_LOW)
        
        env_config_obj  = env_config::type_id::create("env_config_obj", this);
        a_env           = axi_lite_env::type_id::create("a_env", this);

        //get interfaces from db
        if(!uvm_config_db #(virtual config_if#(`DATA_WIDTH))::get(this, "*", "config_vif", config_vif)) begin
            `uvm_fatal("test","No virtual interface has found");
        end
        if(!uvm_config_db #(virtual axi_lite_if)::get(this, "*", "axi_lite_svif", axi_lite_svif)) begin
            `uvm_fatal("test","No virtual interface has found");
        end   

        //assign values to objects 
        env_config_obj.data_width           = data_width;
        env_config_obj.config_vif           = config_vif;
        env_config_obj.axi_lite_svif        = axi_lite_svif;

        //set environment configuration into the config_db
        uvm_config_db #(env_config)::set(this, "a_env", "env_configs", env_config_obj);
        uvm_config_db #(int)::set(null, "*", "datawidth", data_width);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        // axi_lite_sequence m_axi_lite_seq;
        axi_lite_sequence s_axi_lite_seq;

        phase.raise_objection(this, "Starting uvm sequence...");
        // m_axi_lite_seq = axi_lite_sequence::type_id::create("m_axi_lite_seq");
        s_axi_lite_seq = axi_lite_sequence::type_id::create("s_axi_lite_seq");
        // fork
            // m_axi_lite_seq.start(a_env.m_axi_lite_agent.sequencer);
            // s_axi_lite_seq.start(a_env.s_axi_lite_agent.sequencer);
        // join_any
        s_axi_lite_seq.start(a_env.s_axi_lite_agent.sequencer);
        #160000ns;
        phase.drop_objection(this);
    endtask: run_phase
endclass: axi_lite_test
    