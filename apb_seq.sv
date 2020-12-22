class apb_seq extends uvm_sequence #(apb_transaction);
    `uvm_object_utils(apb_seq)
    
    const string report_id = "apb_seq";
    const string report_msg = "Failed to randomize APB Transaction";
   
    function new(string name = "");
        super.new(name);
    endfunction
    
    task body();
        apb_transaction apb_tx;
        //Initialize Registers
        repeat(10) begin
            apb_tx = apb_transaction::type_id::create("apb_tx");
            start_item(apb_tx);
            if (!(apb_tx.randomize() with {apb_tx.paddr == `CTRL_REG;}))
               `uvm_error(report_id, report_msg);
            finish_item(apb_tx);
            apb_tx = apb_transaction::type_id::create("apb_tx");
            start_item(apb_tx);
            if (!(apb_tx.randomize() with {apb_tx.paddr == `CLK_REG;}))
               `uvm_error(report_id, report_msg);
            finish_item(apb_tx);
        end
        repeat(10000) begin
            apb_tx = apb_transaction::type_id::create("apb_tx");
            start_item(apb_tx);
            if (!(apb_tx.randomize()))
               `uvm_error(report_id, report_msg);
            finish_item(apb_tx);
        end
    endtask: body   
endclass
           
