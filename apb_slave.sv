`timescale 1ns/10ps

module apb_slave(apb_if.slave if_apb, spi_if.master if_spi, output logic SPIINTF);

    logic [31:0] S0SPCR, S0SPSR, S0SPDR, rS0SPDR, S0SPCCR, S0SPINT; 
    int count, state, bitcount, clockedge_count;
    logic [4:0] bitMax, rbitMax; //bits per transfer
    logic [7:0] COUNTER, rCOUNTER;    //clock divider
    logic sck_en, pready, CPHA, rCPHA, CPOL, rCPOL, LSBF, rLSBF, SPIE, SPIF;
    logic [31:0] cfg_reg_addr[5] = '{32'hE002_0000, //S0SPCR
                                  32'hE002_0004, //S0SPSR
                                  32'hE002_0008, //S0SPDR
                                  32'hE002_000C,  //S0SPCCR
                                  32'hE002_001C   //S0SPINT
                                  };
    logic [5:0] random_ctrl_reg;
    logic random_en;
                                  
    initial begin
        S0SPCR = 0;
        S0SPSR = 0;
        S0SPDR = 0;
        S0SPCCR = 0;
        state = 0;
        bitcount = 0;
        if_spi.mosi = 0;
        if_spi.ssel = 1;
        random_en = 0;      //Set this to randomize DUT
    end
    
    //S0SPRC
    always @(*) begin
        CPOL = S0SPCR[4];
        CPHA = S0SPCR[3];
        LSBF = S0SPCR[6];
        SPIE = S0SPCR[7];
        //Bits of data per transfer
        //0000 = 16 bits per transfer
        bitMax = (S0SPCR[2]) ? ((S0SPCR[11:8] == 4'b0000) ? 16 :S0SPCR[11:8]):4'd8;
    end
    
    //S0SPSR
    always @(*) begin
        SPIF = S0SPSR[7];
    end
    
    //S0SCCR
    always @(*) begin
        COUNTER = S0SPCCR[7:0];
    end
    
    //S0SPINT
    always @(*) begin
        SPIINTF = S0SPINT[0];
    end
    
    //Randomize blk 
    always @(*) begin
        rCPOL = (random_ctrl_reg[0] & random_en) ? $urandom_range(0, 1) : CPOL;
        rLSBF = (random_ctrl_reg[1] & random_en) ? $urandom_range(0, 1) : LSBF;
        rCPHA = (random_ctrl_reg[2] & random_en) ? $urandom_range(0, 1) : CPHA;
        rbitMax = (random_ctrl_reg[3] & random_en) ? $urandom_range(16, 32) / 2: bitMax;
        rCOUNTER = (random_ctrl_reg[4] & random_en) ? $urandom_range(16, 32) / 2 : COUNTER;
        rS0SPDR = (random_ctrl_reg[5] & random_en) ? $urandom_range(0, 50) : S0SPDR;
    end
///////////////////////////////////////////////////

    always @(posedge if_apb.pclk) begin
        case(state)
            //Idle
            0:  begin
                sck_en <= 0;
                if_spi.sck <= rCPOL;
                bitcount <= 0;
                count <= 0;
                SPIF <= 1'b0;
                if_apb.pready <= 1'b0; 
                #1ns;
                if (if_apb.psel) state <= 1;
                end
            //Write or read
            1:  begin
                random_ctrl_reg <= $urandom_range(0, 63);
                pready = $urandom_range(0, 1);
                if_apb.pready <= pready;
                if (pready) begin
                    do_access();
                end
                else state <= 1;
                end
            //SPI Output
            2:  begin
                    if_apb.pready <= 1'b0;                   
                    SPI_clk(); 
                    if (clockedge_count == 2*rbitMax) begin
                        clockedge_count <= 0;
                        state <= 0;      
                        SPIF <= 1'b1;
                        if_spi.ssel <= 1'b1;
                    end
                end
        endcase
    end  

///////////////////////////////////////////////////
    
    task do_access();
        //Write or Read
        if (if_apb.pwrite) begin
            //Find register
            foreach(cfg_reg_addr[i]) begin
                if (cfg_reg_addr[i] == if_apb.paddr) begin
                    state <= 0;
                    case(i)
                        0: S0SPCR <= if_apb.pwdata;
                        1: S0SPSR <= if_apb.pwdata;
                        2: begin
                           S0SPDR <= if_apb.pwdata;
                           state <= 2;
                           SPI_config(if_apb.pwdata);
                           end
                        3: S0SPCCR <= if_apb.pwdata;
                    endcase
                end
            end
        end
        else
            state <= 0;
    endtask
    
///////////////////////////////////////////////////     
// SPI first data output with CPHA
    task SPI_config(input logic [31:0] data);
        begin
        if_spi.ssel = 1'b0;
        sck_en = 1'b1;
        count = 0;
        clockedge_count = 0;
        bitcount = rLSBF ? 0 : rbitMax - 1;
        if (!rCPHA) begin
            if_spi.mosi = data[bitcount];
            bitcount = rLSBF ? 1 : rbitMax - 2;
        end
        end
    endtask
//////////////////////////////////////////////////
//SPI Clock Divider   
    task SPI_clk();
        begin
            if (count == rCOUNTER) begin
                clockedge_count += 1;
                if_spi.sck <= ~if_spi.sck;
                count <= 0;
            end
            else
                count <= count + 1;
        end
    endtask   
///////////////////////////////////////////////////
//SPI Output
    always @(if_spi.sck) begin
        if (if_spi.sck == (rCPOL ^ rCPHA)) begin
            if_spi.mosi <= rS0SPDR[bitcount];
            if (rLSBF) begin
                if (bitcount < rbitMax) bitcount <= bitcount + 1;
                else bitcount <= bitcount;
            end
            else begin 
                if (bitcount > 0) bitcount <= bitcount - 1;
                else bitcount <= bitcount;
            end
        end
    end
endmodule
