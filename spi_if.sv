interface spi_if();
    logic sck, ssel, mosi, miso;
    
    modport slave (input sck, ssel, mosi,
                        output miso);
    modport master (input miso, output sck, ssel, mosi);
endinterface
