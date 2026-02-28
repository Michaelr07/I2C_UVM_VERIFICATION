`ifndef I2C_ADDR_NACK_SEQ_SV
	`define I2C_ADDR_NACK_SEQ_SV

class i2c_addr_nack_seq extends i2c_base_seq;
   
  rand i2c_addr 	addr;
  
  constraint force_nack_c {
    addr != 7'h21;
  }
  
  `uvm_object_utils(i2c_addr_nack_seq)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    i2c_transaction_item item;
    `uvm_do_with(item, {
      addr 		== local::addr;
      wr_len	== 1;
      rd_len	== 0;
    });
    
  endtask
  
endclass

`endif