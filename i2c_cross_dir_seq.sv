`ifndef I2C_CROSS_DIR_SEQ_SV
	`define I2C_CROSS_DIR_SEQ_SV

class i2c_cross_dir_seq extends i2c_base_seq;
  `uvm_object_utils(i2c_cross_dir_seq)
  
  function new (string name = ""); super.new(name); endfunction
  
  virtual task body();
    i2c_transaction_item req;
    // Arrays representing the bins: Zero, Single, Short, Long
    int lengths[4] = '{0, 1, 4, 255}; 
    
    `uvm_info("DIR_SEQ", "Sweeping all Write/Read length combinations", UVM_LOW)
    
    foreach(lengths[w]) begin
      foreach(lengths[r]) begin
        // Skip the impossible 0/0 combination
        if (lengths[w] == 0 && lengths[r] == 0) continue; 
        
        `uvm_do_with(req, {
          addr == 7'h21;
          wr_len == local::lengths[w];
          rd_len == local::lengths[r];
        })
      end
    end
  endtask
endclass

`endif