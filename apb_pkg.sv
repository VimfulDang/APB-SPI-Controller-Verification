package apb_pkg;
import uvm_pkg::*;

`define CTRL_REG        32'hE002_0000
`define STATUS_REG      32'hE002_0004
`define DATA_REG        32'hE002_0008
`define CLK_REG         32'hE002_000C
`define INT_REG         32'hE002_001C
`define APB_CLK_RATE    10  //in nanoseconds

`include "apb_msg_classes.sv"       //Classes used for port messages
`include "apb_transaction.sv"
`include "apb_seq.sv"
typedef uvm_sequencer #(apb_transaction) apb_sequencer;
`include "apb_driver.sv"
`include "apb_agent_config.sv"
`include "apb_premon.sv"
`include "spi_postmon.sv"
`include "apb_agent.sv"
`include "apb_pre_translator.sv"    //Predictor
`include "compsb_cfg.sv"            //Screobard Setting Compator
`include "compsb_data.sv"           //Scoreboard Data Comparator

`include "spi_post_translator.sv"   //FSM for receiving SPI
`include "spi_process_sb.sv"        //Process data & cfg settings
`include "uvm_env_cfg.sv"           
`include "apb_env.sv"
`include "apb_test.sv"
endpackage: apb_pkg
