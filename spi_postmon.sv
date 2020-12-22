
class spi_postmon extends uvm_monitor;
    `uvm_component_utils(spi_postmon)
    
    uvm_analysis_port #(spi_packet)    ap_postmon;
    virtual spi_if                     spi_vi;
    spi_packet                         spi_msg;
    
    int state;
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_postmon = new("ap_postmon", this);
        if (!uvm_config_db#(virtual spi_if)::get(this, "*", "spi_vi", spi_vi))
            `uvm_error("postmon_vi", "SPI Virtual Interface not set");
        state = 0;
    endfunction: build_phase    
    
    task run_phase(uvm_phase phase);
        //Wait a few for DUT to initialize
        #20ns;
        forever begin
            @(spi_vi.sck or spi_vi.ssel) begin
                #1ns;
                spi_msg = new();
                spi_msg.ssel = spi_vi.ssel;
                spi_msg.mosi = spi_vi.mosi;
                spi_msg.miso = spi_vi.miso;
                spi_msg.sck =  spi_vi.sck;
                spi_msg.time_stamp = $time;
                ap_postmon.write(spi_msg);
            end
        end
    endtask
endclass
                        
            
