`ifndef I2C_RESET_HANDLER_SV
  `define I2C_RESET_HANDLER_SV

  interface class i2c_reset_handler;
    
    //Function to handle the reset
    pure virtual function void handle_reset(uvm_phase phase);
    
  endclass

`endif