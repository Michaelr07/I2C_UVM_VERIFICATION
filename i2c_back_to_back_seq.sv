`ifndef I2C_BACK_TO_BACK_SEQ_SV
	`define I2C_BACK_TO_BACK_SEQ_SV

class i2c_back_to_back_seq extends i2c_base_seq;
   
  rand int num_trans;
  rand logic [6:0] target_addr;
  
  constraint num_trans_cons {
    num_trans inside {[10:50]};
  }
  
  `uvm_object_utils(i2c_back_to_back_seq)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    
    `uvm_info("B2B_SEQ", $sformatf("Starting Burst of %0d back-to-back transactions", num_trans), UVM_LOW)
    
    for (int i = 0; i < num_trans; i++) begin
      i2c_random_seq seq = i2c_random_seq::type_id::create("seq");
      
      if(!seq.randomize() with {addr == local::target_addr;}) begin
        `uvm_error("B2B_SEQ", "Failed to randomize random sequence")
      end
      
      seq.start(p_sequencer, this);
    end
    
    `uvm_info("B2B_SEQ", "Back-to-back sequence finished successfully!", UVM_LOW)
    
  endtask
  
endclass

`endif