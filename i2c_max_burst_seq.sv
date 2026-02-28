`ifndef I2C_MAX_BURST_SEQ_SV
	`define I2C_MAX_BURST_SEQ_SV

class i2c_max_burst_seq extends i2c_base_seq;
 
  rand i2c_addr 	addr;
  
  rand bit 			do_write;
  rand bit 			do_read;
  
  constraint do_atleast_one_action {
    do_write || do_read;
  }
  
  `uvm_object_utils(i2c_max_burst_seq)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    i2c_transaction_item item;
    `uvm_do_with(item, {
      addr 		==  local::addr;
      wr_len	== (local::do_write ? 	120 : 0);
      rd_len	== (local::do_read ?   120 : 0);
    });
    
  endtask
  
endclass

`endif