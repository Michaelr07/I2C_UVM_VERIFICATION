`ifndef I2C_BASE_TEST_SV
  `define I2C_BASE_TEST_SV

  class i2c_base_test extends uvm_test;
    
    //Environment instance
    i2c_env 			env;

    `uvm_component_utils(i2c_base_test)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      env = i2c_env::type_id::create("env", this);
    endfunction
    
  endclass
    
 `endif