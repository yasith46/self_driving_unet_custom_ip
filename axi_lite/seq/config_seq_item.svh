class config_seq_item extends uvm_sequence_item;
    `uvm_object_utils(config_seq_item)

    logic [31:0] InputImageAddress;
    logic [31:0] OutputImageAddress;
    logic        BeginConv;
    logic [7:0]  heightOfImage;
    logic [7:0]  widthOfImage;
    logic [7:0]  NumberOfFilters;

    function new(string name = "config_seq_item");
        super.new(name);
    endfunction: new      

    function void set_data(
        logic [31:0] InputImageAddress,
        logic [31:0] OutputImageAddress,
        logic        BeginConv,
        logic [7:0]  heightOfImage,
        logic [7:0]  widthOfImage,
        logic [7:0]  NumberOfFilters
    );
        this.InputImageAddress   = InputImageAddress;        
        this.OutputImageAddress  = OutputImageAddress;            
        this.BeginConv           = BeginConv;    
        this.heightOfImage       = heightOfImage;        
        this.widthOfImage        = widthOfImage;        
        this.NumberOfFilters     = NumberOfFilters; 
    endfunction: set_data      

    function void get_data(
        output logic [31:0] InputImageAddress,
        output logic [31:0] OutputImageAddress,
        output logic        BeginConv,
        output logic [7:0]  heightOfImage,
        output logic [7:0]  widthOfImage,
        output logic [7:0]  NumberOfFilters
    );          
        InputImageAddress   = this.InputImageAddress;
        OutputImageAddress  = this.OutputImageAddress;
        BeginConv           = this.BeginConv;
        heightOfImage       = this.heightOfImage;    
        widthOfImage        = this.widthOfImage;    
        NumberOfFilters     = this.NumberOfFilters;
    endfunction: get_data

    function void do_print(
        uvm_printer printer
    );
        printer.m_string = convert2string();
    endfunction : do_print

    function string convert2string();
        string str = "";
        str = {str, $sformatf("Input Img Addr: %s\n, Output Img Addr: %s\n, Begin Convolve: %s\n, Height of Img: %s\n, Width of Img: %s\n, No of Filters: %s\n, ", 
                               InputImageAddress, OutputImageAddress, BeginConv, heightOfImage, widthOfImage, NumberOfFilters)};
        return str;
    endfunction

    function bit do_compare(
        uvm_object      rhs, 
        uvm_comparer    comparer
    );
        config_seq_item  tr;
        bit                     eq = 1'b1;

        if(!$cast(tr,rhs)) begin
            `uvm_fatal("FTR","Illegal do_compare cast")
        end
        
        eq &= (this.InputImageAddress  == tr.InputImageAddress );
        eq &= (this.OutputImageAddress == tr.OutputImageAddress);
        eq &= (this.BeginConv          == tr.BeginConv         );
        eq &= (this.heightOfImage      == tr.heightOfImage     );
        eq &= (this.widthOfImage       == tr.widthOfImage      );
        eq &= (this.NumberOfFilters    == tr.NumberOfFilters   );
        return eq;
    endfunction: do_compare
endclass : config_seq_item


