`timescale 1ns/10ps
`include "apb_if.sv"
`include "spi_if.sv"
`include "apb_pkg.sv"
`include "apb_slave.sv"
import uvm_pkg::*;
import apb_pkg::*;

module top();
    reg clk, SPI_INT;
   
    apb_if if_apb(clk);
    spi_if if_spi();
    
    apb_slave   apb_slv(if_apb.slave, if_spi.master, SPI_INT);
    
    always #10 clk = ~clk;
    
    
    initial begin
        clk = 0;
        uvm_config_db#(virtual apb_if)::set(null,"*", "apb_vi", if_apb);
        uvm_config_db#(virtual spi_if)::set(null, "*", "spi_vi", if_spi);
        run_test("apb_test");
        $finish;
    end
    
    /*
    initial begin
        clk = 0;
        #50000000;
        $finish;
    end
    */
   
    initial begin
        $dumpfile("apb.vpd");
        $dumpvars(9, top);
    end
endmodule
