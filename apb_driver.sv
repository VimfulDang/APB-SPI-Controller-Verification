/* 2 Stages

Addr Stage - Get_next_item()
           - if sel, drive paddr, pwrite, pdata, psel, penable = 1'b0,
             nextStage = data;
           - else item_done(), nextstage = Addr, 
                
Data Stage - drive penable, if pready, 

*/

class apb_driver extends uvm_driver #(apb_transaction);
    `uvm_component_utils(apb_driver)
    
    uvm_analysis_port #(apb_transaction)    drv_aport;
    int state;
    virtual apb_if  apb_vi;
    apb_transaction apb_tx;
        
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_aport = new("drv_aport", this);
        if (!uvm_config_db #(virtual apb_if)::get(this, "*", "apb_vi", apb_vi))
            `uvm_error("driver_vi", "Virtual Interface not set");
        state = 0;
    endfunction: build_phase
    
    
    task run_phase(uvm_phase phase);
        forever begin
            @(posedge apb_vi.pclk) begin
                case(state)
                    //Addr Stage
                    0: begin
                        seq_item_port.get_next_item(apb_tx);
                        drive_addr(apb_tx);
                        apb_vi.penable <= 1'b0;
                        if (apb_tx.psel) begin
                            state <= 1;
                        end
                        else begin
                            apb_vi.psel <= 1'b0;
                            seq_item_port.item_done();
                            state <= 0;
                        end
                    end
                    //Access Stage
                    1: begin
                        apb_vi.penable <= 1'b1;
                        //Need to add delay, timing error on pready & penable
                        //seems to be setup time on pready
                        #1ns;
                        if (apb_vi.pready) begin
                            seq_item_port.item_done();
                            state <= 0;
                        end
                        else
                            state <= 1;
                    end
                endcase
            end
        end
    endtask: run_phase
    
    task drive_addr(apb_transaction tx);
        apb_vi.psel <= 1'b1;
        apb_vi.penable <= 1'b0;
        apb_vi.paddr <= tx.paddr;
        apb_vi.pwdata <= tx.pdata;
        apb_vi.pwrite <= tx.pwrite;
    endtask;
endclass: apb_driver
