`ifndef I2C_REGRESSION_TEST_SV
	`define I2C_REGRESSION_TEST_SV

class i2c_regression_test extends i2c_base_test;
  `uvm_component_utils(i2c_regression_test)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase (uvm_phase phase);
   // i2c_ping_seq			ping_seq;
    i2c_random_seq       	rand_seq;
    i2c_max_burst_seq		max_seq;
    i2c_addr_nack_seq		nack_seq;
    i2c_back_to_back_seq 	b2b_seq;
    i2c_cross_dir_seq		cross_seq;
    i2c_data_nack_seq       dnack_seq;
    
    
    phase.raise_objection(this);
    
    env.agent.agent_config.wait_reset_end();
    #(100ns);
    
    
    // 1 RANDOM PHASE
    `uvm_info("REGRESSION", "--- STARTING RANDOM PHASE ---", UVM_NONE)
    repeat(5) begin
      rand_seq = i2c_random_seq::type_id::create("rand_seq");
    
      if(!rand_seq.randomize()) begin
          `uvm_error("TEST", "Failed to randomize random sequence")
      end
      rand_seq.start(env.agent.sequencer);
    end
    
    
    // 2 MAX BURST PHASE
    `uvm_info("REGRESSION", "--- STARTING MAX BURST PHASE ---", UVM_NONE)
    max_seq = i2c_max_burst_seq::type_id::create("max_seq");
      
    if(!max_seq.randomize() with {
      		addr 		== 7'h21;
      		do_write 	== 1;
       		do_read  	== 1;}) 
     begin
    	`uvm_error("TEST", "Failed to randomize random sequence")
    end  
    max_seq.start(env.agent.sequencer);
    
    
    // 3 NACK PHASE
    `uvm_info("REGRESSION", "--- STARTING NACK PHASE ---", UVM_NONE)
    nack_seq = i2c_addr_nack_seq::type_id::create("nack_seq");
      
    if (!nack_seq.randomize()) begin
    	`uvm_error("TEST", "Failed to randomize addr nack seqeunce")
    end
    nack_seq.start(env.agent.sequencer);
    
    
    // 4 BACK TO BACK PHASE
    `uvm_info("REGRESSION", "--- STARTING B2B STRESS PHASE ---", UVM_NONE)
    b2b_seq = i2c_back_to_back_seq::type_id::create("b2b_seq");
    
    if (!b2b_seq.randomize() with {num_trans == 10;
                                  target_addr == 7'h21;}) begin
        `uvm_error("TEST", "Failed to randomize b2b")
    end
    b2b_seq.start(env.agent.sequencer);
    
    
    // 5 GENERAL CALL PHASE
    `uvm_info("REGRESSION", "--- STARTING GENERAL CALL PHASE ---", UVM_NONE)
    rand_seq = i2c_random_seq::type_id::create("rand_seq");
    if(!rand_seq.randomize() with {addr == 7'h00; rd_len == 0;}) begin 
        `uvm_error("TEST", "Failed to randomize Gen Call")
    end
    rand_seq.start(env.agent.sequencer);
    
     // 6 Cross Direction PHASE
    `uvm_info("REGRESSION", "--- STARTING Cross Direction PHASE ---", UVM_NONE)
    cross_seq = i2c_cross_dir_seq::type_id::create("cross_seq");
    if(!cross_seq.randomize()) begin 
      `uvm_error("TEST", "Failed to randomize Cross Call")
    end
    cross_seq.start(env.agent.sequencer);
    
    
     // 7DATA nack PHASE
    `uvm_info("REGRESSION", "--- STARTING DAT NACK PHASE ---", UVM_NONE)
    dnack_seq = i2c_data_nack_seq::type_id::create("dnack_seq");
    if(!dnack_seq.randomize()) begin 
      `uvm_error("TEST", "Failed to randomize nack data Call")
    end
    dnack_seq.start(env.agent.sequencer);
    
    #(5ms);
    phase.drop_objection(this, "TEST_DONE");
  endtask
endclass

`endif