`ifndef I2C_TRANSACTION_SV
	`define I2C_TRANSACTION_SV

  class i2c_transaction_item extends uvm_sequence_item;
    
    rand bit [6:0] 	addr;
    //rand i2c_m_rw	rw;
    rand bit [7:0]		wr_data[];		// bit {width] is default to be unsigned
    rand bit [7:0] 		rd_len;
    rand bit [7:0] 		wr_len;
    
    
    bit 			nack_addr;
    bit  			nack_data;
    byte 			rd_data[];		
    
    `uvm_object_utils(i2c_transaction_item)
    
    // In i2c_transaction_item
    constraint data_size_c {
      wr_data.size() == wr_len;
      foreach (wr_data[i]) wr_data[i] inside {[8'h00:8'hFF]};
    }
    
    function new(string name = "");
      super.new(name);
    endfunction
    
    virtual function string convert2string();
      string result = $sformatf("ADDR: 0x%0h | WR_LEN: %0d | RD_LEN: %0d", addr, wr_len, rd_len);
      
      if (nack_addr) result = {result, " | [ADDR NACK]"};
      if (nack_data) result = {result, " | [DATA NACK]"};
      
      if (wr_len > 0 && wr_len <= 8) begin
        result = {result, " | WR_DATA: {"};
        foreach(wr_data[i]) result = {result, $sformatf("0x%0h ", wr_data[i])};
        result = {result, "}"};
      end
      
      return result;
    endfunction
    
  endclass

`endif