`ifndef I2C_BASE_SEQ_SV
	`define I2C_BASE_SEQ_SV

class i2c_base_seq extends uvm_sequence #(i2c_transaction_item);
  
  `uvm_declare_p_sequencer(i2c_sequencer)
  
  `uvm_object_utils(i2c_base_seq)

  function new(string name = "");
    super.new(name);
  endfunction
  
endclass

`endif