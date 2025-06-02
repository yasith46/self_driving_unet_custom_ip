class axi_lite_seq_item extends uvm_sequence_item;
    `uvm_object_utils(axi_lite_seq_item)

    logic [31:0] data_inp_img_base;
    logic [31:0] data_out_img_base;
    logic [31:0] data_start;
    logic [31:0] data_clear_interrupt;
    logic [31:0] data_img_size_x;
    logic [31:0] data_img_size_y;

    logic [5:0] addr_inp_img_base;
    logic [5:0] addr_out_img_base;
    logic [5:0] addr_start;
    logic [5:0] addr_clear_interrupt;
    logic [5:0] addr_img_size_x;
    logic [5:0] addr_img_size_y;

    logic [1:0]  bresp;

    function new(string name = "axi_lite_seq_item");
        super.new(name);
    endfunction: new     

    function void set_response(
        logic  [1:0] resp
    );
        this.bresp = resp;
    endfunction: set_response       

    function void get_response(
        logic  [1:0] resp
    );
        resp       = this.bresp;
    endfunction: get_response       

    function void set_data(
        logic [31:0] data [$],
        logic [5:0] addr [$]
    );
        this.data_inp_img_base    = data[0];
        this.data_out_img_base    = data[1];
        this.data_start           = data[2];
        this.data_clear_interrupt = data[3];
        this.data_img_size_x      = data[4];
        this.data_img_size_y      = data[5];

        this.addr_inp_img_base    = addr[0];
        this.addr_out_img_base    = addr[1];
        this.addr_start           = addr[2];
        this.addr_clear_interrupt = addr[3];
        this.addr_img_size_x      = addr[4];
        this.addr_img_size_y      = addr[5];        
    endfunction: set_data      

    function void get_data(
        output logic [31:0] data [$],
        output logic [5:0] addr [$]
    );          
        data.push_back(data_inp_img_base   );
        data.push_back(data_out_img_base   );
        data.push_back(data_start          );
        data.push_back(data_clear_interrupt);
        data.push_back(data_img_size_x     );
        data.push_back(data_img_size_y     );

        addr.push_back(addr_inp_img_base   );
        addr.push_back(addr_out_img_base   );
        addr.push_back(addr_start          );
        addr.push_back(addr_clear_interrupt);
        addr.push_back(addr_img_size_x     );
        addr.push_back(addr_img_size_y     );
    endfunction: get_data

    function void send_data();
        data_inp_img_base    = $random;
        data_out_img_base    = $random;
        data_start           = $random;
        data_clear_interrupt = $random;
        data_img_size_x      = $random;
        data_img_size_y      = $random;

        addr_inp_img_base    = 32'h0;
        addr_out_img_base    = 32'h1;
        addr_start           = 32'h2;
        addr_clear_interrupt = 32'h3;
        addr_img_size_x      = 32'h4;
        addr_img_size_y      = 32'h5;        
    endfunction: send_data

    function void do_print(
        uvm_printer printer
    );
        printer.m_string = convert2string();
    endfunction : do_print

    function string convert2string();
        string str = "";
        str = {str, $sformatf("\data_inp_img_base: %s\n", data_inp_img_base)};
        str = {str, $sformatf("data_out_img_base: %s\n", data_out_img_base)};
        str = {str, $sformatf("data_start: %s\n", data_start)};
        str = {str, $sformatf("data_clear_interrupt: %s", data_clear_interrupt)};
        str = {str, $sformatf("data_img_size_x: %s\n", data_img_size_x)};
        str = {str, $sformatf("data_img_size_y: %s\n", data_img_size_y)};

        str = {str, $sformatf("addr_inp_img_base: %s\n", addr_inp_img_base)};
        str = {str, $sformatf("addr_out_img_base: %s", addr_out_img_base)};
        str = {str, $sformatf("addr_start: %s\n", addr_start)};
        str = {str, $sformatf("addr_clear_interrupt: %s\n", addr_clear_interrupt)};
        str = {str, $sformatf("addr_img_size_x: %s\n", addr_img_size_x)};
        str = {str, $sformatf("addr_img_size_y: %s", addr_img_size_y)};
        return str;
    endfunction

    function bit do_compare(
        uvm_object      rhs, 
        uvm_comparer    comparer
    );
        axi_lite_seq_item  tr;
        bit                     eq = 1'b1;

        if(!$cast(tr,rhs)) begin
            `uvm_fatal("FTR","Illegal do_compare cast")
        end
        
        eq &= (this.data_inp_img_base    == tr.data_inp_img_base   );
        eq &= (this.data_out_img_base    == tr.data_out_img_base   );
        eq &= (this.data_start           == tr.data_start          );
        eq &= (this.data_clear_interrupt == tr.data_clear_interrupt);
        eq &= (this.data_img_size_x      == tr.data_img_size_x     );
        eq &= (this.data_img_size_y      == tr.data_img_size_y     );

        eq &= (this.addr_inp_img_base    == tr.addr_inp_img_base   );
        eq &= (this.addr_out_img_base    == tr.addr_out_img_base   );
        eq &= (this.addr_start           == tr.addr_start          );
        eq &= (this.addr_clear_interrupt == tr.addr_clear_interrupt);
        eq &= (this.addr_img_size_x      == tr.addr_img_size_x     );
        eq &= (this.addr_img_size_y      == tr.addr_img_size_y     );  
        return eq;
    endfunction: do_compare
endclass : axi_lite_seq_item


