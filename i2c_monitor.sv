`ifndef I2C_MONITOR_SV
	`define I2C_MONITOR_SV

class i2c_monitor extends uvm_monitor implements i2c_reset_handler;
  
  i2c_agent_config agent_config;
  
  uvm_analysis_port #(i2c_transaction_item) output_port;
  
   //Process for collect_transactions() task
   protected process process_collect_transactions;
  
  `uvm_component_utils(i2c_monitor)
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
    
    output_port = new ("output_port", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
      forever begin
        fork
          begin
            wait_reset_end();
            collect_transactions();
            
            disable fork;
          end 
        join
      end
    endtask
    
      
 	//Task which drives one single item on the bus
    protected virtual task collect_transaction();
      	i2c_vif vif = agent_config.get_vif();
      	i2c_transaction_item data = i2c_transaction_item::type_id::create("data");
      
      	wait(vif.start);
      	@(posedge vif.clk); 
    	data.addr 		= vif.addr7;
      	data.rd_len 	= vif.rd_len;
      	data.wr_len		= vif.wr_len;
      	
      	@(posedge vif.clk);
      
      
      	if (data.wr_len > 0) begin			// handle write
          data.wr_data = new[data.wr_len];
          foreach (data.wr_data[i]) begin
            
            while(1) begin
              @(posedge vif.clk);
            
              if (vif.done || vif.nack_addr || vif.nack_data) break;
              
              if (vif.wr_valid && vif.wr_ready) begin
                data.wr_data[i] = vif.wr_data;
                break;
              end
            end

            if (vif.done || vif.nack_addr || vif.nack_data) break;
            
          end   
      	end
      
      
    	if (data.rd_len > 0) begin	  		// handle read
          data.rd_data 	= new[data.rd_len];
          
          foreach (data.rd_data[i]) begin
            
            while(1) begin
            	@(posedge vif.clk);
              
            	if (vif.done || vif.nack_addr || vif.nack_data) break;
              
              if (vif.rd_valid && vif.rd_ready) begin
                data.rd_data[i] = vif.rd_data;
                break;
              end
            end
            
            if (vif.done || vif.nack_addr || vif.nack_data) break;
          end
        end

      wait(vif.done == 1)
      	data.nack_addr	= vif.nack_addr;
      	data.nack_data	= vif.nack_data;
      
      output_port.write(data);
      `uvm_info("MON", $sformatf("Collected: %s", data.convert2string()), UVM_LOW);
                   
  endtask
  
  protected virtual task collect_transactions();
      fork
        begin
          process_collect_transactions = process::self();
          
          forever begin
            collect_transaction();
          end
          
        end
      join
    endtask
  
    //Task for waiting the reset to be finished
    protected virtual task wait_reset_end();
      agent_config.wait_reset_end();
    endtask
    
    //Function to handle the reset
    virtual function void handle_reset(uvm_phase phase);
      if(process_collect_transactions != null) begin
        process_collect_transactions.kill();
        
        process_collect_transactions = null;
      end
    endfunction
  
endclass

`endif