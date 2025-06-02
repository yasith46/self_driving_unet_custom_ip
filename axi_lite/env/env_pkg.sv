package env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_lite_defines.svh"

    import axi_lite_agent_pkg::*;
    import config_agent_pkg::*;
    import analysis_components_pkg::*;
    
    `include "env_config.svh"
    `include "axi_lite_env.svh"
    
endpackage: env_pkg