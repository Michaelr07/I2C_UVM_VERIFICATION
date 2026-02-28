`ifndef I2C_NACK_DATA_SV
	`define I2C_NACK_DATA_SV

class i2c_data_nack_seq extends i2c_base_seq;
  `uvm_object_utils(i2c_data_nack_seq)
  
  function new (string name = ""); super.new(name); endfunction
  
  virtual task body();
    i2c_transaction_item req;
    `uvm_info("NACK_SEQ", "Sending out-of-bounds Data to trigger NACK", UVM_LOW)
    
    // Force a write to register 0xFF (255)
    `uvm_do_with(req, {
      addr == 7'h21;
      wr_len == 2; 
      rd_len == 0;
      wr_data[0] == 8'hFF; // The Out-of-bounds register address!
    })
  endtask
endclass

`endif