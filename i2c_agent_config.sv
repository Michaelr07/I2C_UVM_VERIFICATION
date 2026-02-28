class i2c_agent_config extends uvm_component;
  
  local i2c_vif vif;
  
  local uvm_active_passive_enum active_passive;
  
  //Switch to enable coverage
  local bit has_coverage;
  
  `uvm_component_utils(i2c_agent_config)
  
  function new (string name = "", uvm_component parent);
    super.new(name, parent);
    active_passive = UVM_ACTIVE;
    has_coverage    = 1;
    
  endfunction
  
   virtual function i2c_vif get_vif();
      return vif;
    endfunction
    
    //Setter for the APB virtual interface
  virtual function void set_vif(i2c_vif value);
     if(vif == null) begin
       vif = value;
        
       //set_has_checks(get_has_checks());
     end
     else begin
       `uvm_fatal("ALGORITHM_ISSUE", "Trying to set the i2c virtual interface more than once")
     end
  endfunction
  
  //Getter for the APB Active/Passive control
  virtual function uvm_active_passive_enum get_active_passive();
  	return active_passive;
  endfunction
    
   //Setter for the APB Active/Passive control
  virtual function void set_active_passive(uvm_active_passive_enum value);
  	active_passive = value;
  endfunction
  
   //Getter for the has_coverage control field
  virtual function bit get_has_coverage();
    return has_coverage;
  endfunction
    
  //Setter for the has_coverage control field
  virtual function void set_has_coverage(bit value);
    has_coverage = value;
  endfunction
  
  virtual task wait_reset_start();
    if(vif.rst_n !== 0) begin
      @(negedge vif.rst_n);
    end
  endtask
  
  virtual task wait_reset_end();
    while(vif.rst_n == 0) begin
      @(posedge vif.clk);
    end
  endtask
  
endclass