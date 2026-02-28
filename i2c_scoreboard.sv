`ifndef I2C_SCOREBOARD_SV
	`define I2C_SCOREBOARD_SV

class i2c_scoreboard extends uvm_scoreboard;
  
  uvm_analysis_imp #(i2c_transaction_item, i2c_scoreboard) item_collected_export;
  
  // Creating mirror of the register
  logic [7:0] mem_mirror [256];
  logic [7:0] current_addr;
  
  `uvm_component_utils(i2c_scoreboard)
  
  function new (name = "", uvm_component parent);
    super.new(name,parent);
    item_collected_export = new ("item_collected_export", this);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    foreach(mem_mirror[i]) begin
      mem_mirror[i] = i;
      
    end
    current_addr = 8'h00;
  endfunction
  
  virtual function void write (i2c_transaction_item item);
    `uvm_info("SCB", $sformatf("Checking: %s", item.convert2string()), UVM_LOW)
              
	if(item.nack_addr) begin
      `uvm_info("SCB", "Expected behavior: Slave NACK'd the address phase. 	Skipping data check.", UVM_LOW);            
      return; 
    end 
    
    if (item.nack_data) begin
      `uvm_info("SCB", "Expected behavior: Slave NACK'd the data phase. Skipping data check.", UVM_LOW);                    
      return; 
    end
    
    //write phase
    if(item.wr_len>0) begin
      current_addr = item.wr_data[0];

      for (int i = 1; i < item.wr_len; i++) begin
        mem_mirror[current_addr] = item.wr_data[i];
        current_addr++;
      end
    end
      
      
   	if(item.rd_len > 0) begin
      for (int i = 0; i < item.rd_len; i++) begin
        if (current_addr < 255) begin
          if (item.rd_data[i] !== mem_mirror[current_addr]) begin
              `uvm_error("SCB_FAIL", $sformatf("Mismatch at Addr 0x%0h! Expected: 0x%0h, Got: 0x%0h", 
                                              current_addr, mem_mirror[current_addr], item.rd_data[i]))
          end else begin
             `uvm_info("SCB_PASS", $sformatf("Data match at Addr 0x%0h: 0x%0h", 
                                             current_addr, item.rd_data[i]), UVM_HIGH)
          end
        end else begin
          `uvm_info("SCB_WARNING", "Memory crossed into out of bounds area ADDR 0xFF, skipping check", UVM_HIGH)
        end
        if (i < item.rd_len - 1) begin
            current_addr++;
        end
        
      end
    end
  endfunction
  
endclass

`endif