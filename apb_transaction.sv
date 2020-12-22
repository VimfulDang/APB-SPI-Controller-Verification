class apb_transaction extends uvm_sequence_item;
    `uvm_object_utils(apb_transaction)
    
    rand logic [31:0] paddr, pdata;
    rand logic pwrite, psel; 
    logic [31:0] cfg_reg_addr[5] = {`CTRL_REG, 
                                    `STATUS_REG, 
                                    `DATA_REG,
                                    `CLK_REG,
                                    `INT_REG
                                    };
 
    
    constraint addr {paddr inside cfg_reg_addr;
                     pdata[31:16] == 16'd0;
                     };
    
    //S0SPCR
    //Control Register
    constraint ctrl_reg {if (paddr == `CTRL_REG) {
                         pdata[1:0] == 2'd0;
                         pdata[15:12]== 4'd0;
                         pdata[5] == 1'b1;  //always master
                         pdata[7] == 1'b0;  //Interrupt inhibited
                         pdata[11:8] inside {0, [8:15]};}
                         };
    //S0SPSR
    //only read
    constraint status_reg {if (paddr == `STATUS_REG)
                            pwrite == 0;}; 
                             
    //S0SPINT, SPTSR, SPTCR, don't use.
    //constraint unuse_reg {!(paddr inside {[32'hE002_0010:32'hE002_0014]});};
    
    //S0SPCCR 
    //Must be even and >= 8
    constraint clock_counter_reg {if (paddr == `CLK_REG) {
                                    pdata[31:8] == 0;
                                    pdata[7:0] >= 8;
                                    (pdata[7:0] % 2) == 0;}
                                    };
    
    
    function new(string name = "");
        super.new(name);
        //initialize_addr();
    endfunction
    
    virtual function void initialize_addr();
        foreach(cfg_reg_addr[i]) begin
            cfg_reg_addr[i] = 32'hE002_0000 + i*4;
        end
    endfunction
    
    virtual function string convert2str();
        return $sformatf("paddr = 0x%0h pdata = 0x%0h psel = 0x%0h pwrite = 0x%0h", paddr, pdata, psel, pwrite);
    endfunction: convert2str
                          
endclass: apb_transaction
