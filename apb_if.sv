interface apb_if(input pclk);
    logic [31:0] paddr, pwdata, prdata;
    logic pwrite, psel, penable, pready;
    //Added Experiment SPI

    modport master ( 
                        input pready, pclk, prdata,
                        output paddr, psel, penable, pwdata, pwrite
                        );
    modport slave ( 
                        input paddr, psel, penable, pclk, pwdata, pwrite,
                        output pready, prdata
                       );
endinterface : apb_if
