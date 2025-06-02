class axi_lite_sequence extends uvm_sequence;
`uvm_object_utils(axi_lite_sequence)

function new(string name="axi_lite_sequence");
    super.new(name);
endfunction: new

task body();
    axi_lite_seq_item    axi_lite_txn;
    axi_lite_txn = axi_lite_seq_item::type_id::create("axi_lite_txn");

    repeat (10) begin
        start_item(axi_lite_txn);
        axi_lite_txn.send_data();
        finish_item(axi_lite_txn);
    end
    $finish;
endtask: body
endclass : axi_lite_sequence