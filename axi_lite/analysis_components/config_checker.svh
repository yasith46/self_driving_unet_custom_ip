class config_checker extends uvm_scoreboard;
    `uvm_component_utils(config_checker)

    uvm_analysis_export     #(config_seq_item)         config_before_export;
    uvm_analysis_export     #(config_seq_item)         config_after_export;

    uvm_in_order_class_comparator #(config_seq_item)   config_comparator;

    function new(string name="config_checker",uvm_component parent);
        super.new(name,parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        config_before_export      = new("config_before_export", this);
        config_after_export       = new("config_after_export", this);

        config_comparator         = uvm_in_order_class_comparator #(config_seq_item)::type_id::create("config_comparator", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        //connecting config comparator
        config_before_export.connect(config_comparator.before_export);
        config_after_export.connect(config_comparator.after_export);
    endfunction: connect_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            #(100);
            $display("config_comparator.m_mismatches %d", config_comparator.m_mismatches);
            $display("config_comparator.m_matches %d", config_comparator.m_matches);
            if(config_comparator.m_mismatches > 0) begin
                $fatal(1,"Error_code : found_mismatches");
            end
        end
    endtask : run_phase
    
endclass: config_checker
