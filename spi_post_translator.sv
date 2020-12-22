class spi_translator extends uvm_scoreboard;
    `uvm_component_utils(spi_translator)
    
    uvm_tlm_analysis_fifo #(spi_packet)         ap_rx_translator;
    
    uvm_analysis_port #(spi_message)            ap_tx_translator;
    
    spi_message             spi_tx_msg;
    spi_packet              spi_rx_packet;
    int state, bitcount;
    
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_rx_translator = new("ap_rx_translator", this);
        ap_tx_translator = new("ap_tx_translator", this);
        state = 0;
    endfunction
    
    task run_phase (uvm_phase phase);
        forever begin
            ap_rx_translator.get(spi_rx_packet);
            case(state) 
                0: begin
                    //idle sck changes when clk polarity setting changes -- caution
                    if (!spi_rx_packet.ssel) begin
                        spi_tx_msg = new();
                        bitcount = 0;
                        add_data(spi_tx_msg, spi_rx_packet, bitcount);
                        bitcount++;
                        state = 1;
                    end
                end 
                1: begin
                    add_data(spi_tx_msg, spi_rx_packet, bitcount);
                    bitcount++;
                    if (spi_rx_packet.ssel) begin
                        add_data(spi_tx_msg, spi_rx_packet, bitcount);
                        spi_tx_msg.message_length = ++bitcount;
                        ap_tx_translator.write(spi_tx_msg);
                        state = 0;
                    end
                end
            endcase
        end
    endtask
    
    function spi_message add_data(spi_message msg, spi_packet pkt, int index);
        msg.data[index] = pkt.mosi;
        msg.clk_trace[index] = pkt.sck;
        msg.time_stamp[index] = pkt.time_stamp;
        return msg;
    endfunction
        
            
endclass
