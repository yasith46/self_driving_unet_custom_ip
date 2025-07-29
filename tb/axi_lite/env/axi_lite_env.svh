class axi_lite_env extends uvm_env;
    `uvm_component_utils(axi_lite_env)

    env_config          env_configs;

    config_agent        m_config_agent;
    axi_lite_agent      s_axi_lite_agent;

    config_checker      a_checker;
    config_predictor    a_predictor;

    function new(string name="axi_lite_env", uvm_component parent);
        super.new(name, parent);
        `uvm_info("[ENV]", "constructor", UVM_LOW);
    endfunction: new
     
    function void build_phase(uvm_phase phase);
        config_agent_config         config_agt_cfg;
        axi_lite_agent_config       s_axi_lite_agt_cfg;
        config_analysis_config      analysis_cfg;   

        super.build_phase(phase);

        //create agents
        m_config_agent      = config_agent::type_id::create("config_agent", this);
        s_axi_lite_agent    = axi_lite_agent::type_id::create("s_axi_lite_agent", this);

        //create analysis components
        a_checker           = config_checker::type_id::create("axi_lite_checker", this);
        a_predictor         = config_predictor::type_id::create("axi_lite_predictor", this);

        //create configuration objects for agents
        config_agt_cfg      = config_agent_config::type_id::create("config_agt_cfg", this);
        s_axi_lite_agt_cfg  = axi_lite_agent_config::type_id::create("s_axi_lite_agt_cfg", this);

        analysis_cfg        = config_analysis_config::type_id::create("analysis_cfg", this);

        //get environment configs
        if(!uvm_config_db #(env_config)::get(this, "", "env_configs", env_configs)) begin
            `uvm_fatal("[axi_lite_env]", "cannot find configs")
        end

        //set master agent configs
        config_agt_cfg.data_width               = env_configs.data_width;
        config_agt_cfg.config_vif               = env_configs.config_vif;

        //set slave agent configs
        s_axi_lite_agt_cfg.data_width           = env_configs.data_width;
        s_axi_lite_agt_cfg.is_master            = 1'b0;
        s_axi_lite_agt_cfg.axi_lite_svif        = env_configs.axi_lite_svif;

        //set analysis component configs
        analysis_cfg.data_width             = env_configs.data_width;

        uvm_config_db #(config_agent_config)::set(this, "config_agent*", "config_agt_cfg", config_agt_cfg);
        uvm_config_db #(axi_lite_agent_config)::set(this, "s_axi_lite_agent*", "axi_lite_config", s_axi_lite_agt_cfg);
        uvm_config_db #(config_analysis_config)::set(this, "axi_lite_predictor*", "analysis_cfg", analysis_cfg);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        s_axi_lite_agent.agent_aport.connect(a_predictor.analysis_export);
        a_predictor.expected_config_aport.connect(a_checker.config_before_export);
        m_config_agent.agent_aport.connect(a_checker.config_after_export);
    endfunction: connect_phase

    task run_phase(uvm_phase phase);
        `uvm_info("[ENV]", "run_phase", UVM_LOW)
    endtask: run_phase
    
endclass: axi_lite_env



