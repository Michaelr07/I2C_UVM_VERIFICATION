`ifndef I2C_RANDOM_SEQ_SV
	`define I2C_RANDOM_SEQ_SV

class i2c_random_seq extends i2c_base_seq;
   
  rand i2c_addr 	addr;
  rand i2c_wr_size 	wr_len;
  rand i2c_rd_size 	rd_len;
  
  constraint num_items_default {
    soft wr_len inside {[0:5]}; 
    soft rd_len inside {[0:5]}; 
    
    (wr_len + rd_len) > 0;
   }
  
  `uvm_object_utils(i2c_random_seq)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    i2c_transaction_item item;
    `uvm_do_with(item, {
      addr 		== local::addr;
      wr_len	== local::wr_len;
      rd_len	== local::rd_len;
    });
    
  endtask
  
endclass

`endif