`ifndef I2C_TESTS_SV
  `define I2C_TESTS_SV

  class i2c_ping_test extends i2c_base_test;
    
    `uvm_component_utils(i2c_ping_test)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    
    virtual task run_phase (uvm_phase phase);
      i2c_ping_seq seq;
      
      phase.raise_objection(this);
      
      // Wait for the testbench reset to complete before doing anything
      env.agent.agent_config.wait_reset_end();
	  
      #(100ns);
      
      seq = i2c_ping_seq::type_id::create("seq");
      
      if(!seq.randomize() with {addr == 7'h21;}) begin
        `uvm_error("TEST", "Failed to randomize ping sequence")
      end
      seq.start(env.agent.sequencer);
      
      #(100us);
      
      phase.drop_objection(this, "TEST_DONE");
    endtask 
    
  endclass


  class i2c_rand_test extends i2c_base_test;
    
    `uvm_component_utils(i2c_rand_test)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    
    virtual task run_phase (uvm_phase phase);
      i2c_random_seq seq;
      
      phase.raise_objection(this);
      
      // Wait for the testbench reset to complete before doing anything
      env.agent.agent_config.wait_reset_end();
	  
      #(100ns);
      
      seq = i2c_random_seq::type_id::create("seq");
      
      if(!seq.randomize() with {addr == 7'h21;}) begin
        `uvm_error("TEST", "Failed to randomize random sequence")
      end
      
      seq.start(env.agent.sequencer);
      
      #(100us);
      
      phase.drop_objection(this, "TEST_DONE");
    endtask
  
  endclass


  class i2c_max_burst_test extends i2c_base_test;
    
    `uvm_component_utils(i2c_max_burst_test)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    
    virtual task run_phase (uvm_phase phase);
      i2c_max_burst_seq seq;
      
      phase.raise_objection(this);
      
      // Wait for the testbench reset to complete before doing anything
      env.agent.agent_config.wait_reset_end();
	  
      #(100ns);
      
      seq = i2c_max_burst_seq::type_id::create("seq");
      
      if(!seq.randomize() with {addr == 7'h21;}) begin
        `uvm_error("TEST", "Failed to randomize random sequence")
      end
      
      seq.start(env.agent.sequencer);
      
      #(5ms);
      
      phase.drop_objection(this, "TEST_DONE");
    endtask
  
  endclass

  class i2c_addr_nack_test extends i2c_base_test;
    
    `uvm_component_utils(i2c_addr_nack_test)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    
    virtual task run_phase (uvm_phase phase);
      i2c_addr_nack_seq seq;
      
      phase.raise_objection(this);
      
      env.agent.agent_config.wait_reset_end();
	  
      #(100ns);
      
      seq = i2c_addr_nack_seq::type_id::create("seq");
      
      if (!seq.randomize()) begin
        `uvm_error("TEST", "Failed to randomize addr nack seqeunce")
      end
      
      seq.start(env.agent.sequencer);
      
      #(100us);
      
      phase.drop_objection(this, "TEST_DONE");
    endtask
  
  endclass


  class i2c_b2b_test extends i2c_base_test;
    
    `uvm_component_utils(i2c_b2b_test)
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    
    virtual task run_phase (uvm_phase phase);
      i2c_back_to_back_seq seq;
      
      phase.raise_objection(this);
      
      // Wait for the testbench reset to complete before doing anything
      env.agent.agent_config.wait_reset_end();
	  
      #(100ns);
      
      seq = i2c_back_to_back_seq::type_id::create("seq");
      
      if (!seq.randomize() with {target_addr==7'h21;}) begin
        `uvm_error("TEST", "Failed to randomize back 2 back sequence")
      end
      seq.start(env.agent.sequencer);
      
      #(1ms);
      
      phase.drop_objection(this, "TEST_DONE");
    endtask
  
  endclass

  

`endif