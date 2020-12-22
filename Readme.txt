0. Top module consist of DUT environment and verif environment.

1. DUT design logic is inside apb_slave.sv which is instantiated inside apb_driver.sv.

2. Verification Environment is apb_env.sv and all the uvm_components are instantiated inside it.
   apb_premon.sv and apb_pretranslator.sv acts as predictor models.

3. All the test cases are inside apb_test.sv

__________To Run the Testcases_____________: 

1) ./sv_uvm top.sv

2) To randomize the DUT behaviour set the random_enable signal in the "apb_slave.sv"


--------------------------------------------

Note: Clock Phase Exception - Cannot verify phase if data does not change.
      example:-16'hFFFF or 16'h0000
