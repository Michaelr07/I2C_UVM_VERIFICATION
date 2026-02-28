`ifndef I2C_PING_SEQ_SV
	`define I2C_PING_SEQ_SV

class i2c_ping_seq extends i2c_base_seq;
   
  rand i2c_addr 	addr;
  // rand i2c_wr_size 	wr_len;
  // rand i2c_rd_size 	rd_len;
  
  `uvm_object_utils(i2c_ping_seq)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    i2c_transaction_item item;
    `uvm_do_with(item, {
      addr 		== local::addr;
      wr_len	== 0;
      rd_len	== 0;
    });
    
  endtask
  
endclass

`endif