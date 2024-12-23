# Makefile for APB-SPI-Controller-Verification

# Variables
TOP = top.sv
TOP_MODULE = top
SIM_SNAPSHOT = tb_sim
XVLOG = xvlog
XELAB = xelab
XSIM = xsim

# Default target
all: simulate

# Compile
compile:
	$(XVLOG) --sv -L uvm $(TOP)

# Elaborate
elaborate: compile
	$(XELAB) -timescale 1ns/1ps -debug typical -L uvm -s $(SIM_SNAPSHOT) work.$(TOP_MODULE)

# Simulate
simulate: elaborate
	$(XSIM) $(SIM_SNAPSHOT) -R

# Clean up generated files
clean:
	rm -rf xsim.dir xvlog.pb xelab.pb webtalk* *.log *.jou

.PHONY: all compile elaborate simulate clean