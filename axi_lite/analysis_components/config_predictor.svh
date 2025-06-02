class config_predictor extends uvm_subscriber#(axi_lite_seq_item);
    `uvm_component_utils(config_predictor)

    uvm_analysis_port   #(config_seq_item)     expected_config_aport;
    
    function new(string name="config_predictor", uvm_component parent);
        super.new(name, parent);
        expected_config_aport  = new("expected_config_aport", this);
    endfunction : new

    virtual function void write(axi_lite_seq_item t);
        config_seq_item     expected_config_item;
        logic  [1:0]        bresp;
        logic [31:0] data[$];
        logic [5:0] addr[$];

        logic [31:0] InputImageAddress;
        logic [31:0] OutputImageAddress;
        logic        BeginConv;
        logic [7:0]  heightOfImage;
        logic [7:0]  widthOfImage;
        logic [7:0]  NumberOfFilters;

        expected_config_item = config_seq_item::type_id::create("expected_config_item", this);
        t.get_response(bresp);
        t.get_data(data, addr);
        if(bresp) begin
            InputImageAddress  = '0;    
            OutputImageAddress = '0;    
            BeginConv          = '0;
            heightOfImage      = '0;    
            widthOfImage       = '0;    
            NumberOfFilters    = '0;    
            expected_config_item.set_data(InputImageAddress, OutputImageAddress, BeginConv, heightOfImage, widthOfImage, NumberOfFilters);     
            expected_config_aport.write(expected_config_item);   
        end

    endfunction: write

endclass : config_predictor
