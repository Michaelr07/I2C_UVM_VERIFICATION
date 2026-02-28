`ifndef I2C_AGENT_SV
	`define I2C_AGENT_SV

class i2c_agent extends uvm_agent implements i2c_reset_handler;
  
  i2c_agent_config 	agent_config;
  
  i2c_driver 		driver;
  i2c_sequencer	 	sequencer;
  i2c_monitor 		monitor;
  i2c_coverage		coverage;
  
  `uvm_component_utils(i2c_agent)
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    agent_config 		= i2c_agent_config::type_id::create("agent_config", this);
    
    monitor 			= i2c_monitor::type_id::create("monitor", this);
    
    if(agent_config.get_active_passive() == UVM_ACTIVE) begin
     	driver 		= i2c_driver::type_id::create("driver", this);
    	sequencer 	= i2c_sequencer::type_id::create("sequencer", this);
      
    end
    
    if(agent_config.get_has_coverage()) begin
        coverage = i2c_coverage::type_id::create("coverage", this);
    end
    
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    i2c_vif vif;
    string      vif_name = "vif";
    
    super.connect_phase(phase);
    
    if(!uvm_config_db#(virtual i2c_m_if)::get(this, "", vif_name, vif)) begin
        `uvm_fatal("APB_NO_VIF", $sformatf("Could not get from the database the APB virtual interface using name \"%0s\"", vif_name))
    end
    else begin
       agent_config.set_vif(vif);
    end
    
    monitor.agent_config = agent_config;
    
    //monitor.output_port.connect(ap);
    
    if(agent_config.get_active_passive() == UVM_ACTIVE) begin
    	driver.seq_item_port.connect(sequencer.seq_item_export);
      	driver.agent_config	= agent_config;
    end
    
    if(agent_config.get_has_coverage()) begin
      monitor.output_port.connect(coverage.analysis_export);
     end
       
  endfunction
  
      //Task for waiting the reset to start
    protected virtual task wait_reset_start();
      agent_config.wait_reset_start();
    endtask
         
    //Task for waiting the reset to be finished
    protected virtual task wait_reset_end();
      agent_config.wait_reset_end();
    endtask
    
    //Function to handle the reset
    virtual function void handle_reset(uvm_phase phase);
      uvm_component children[$];
      
      get_children(children);
      
      foreach(children[idx]) begin
        i2c_reset_handler reset_handler;
        
        if($cast(reset_handler, children[idx])) begin
          reset_handler.handle_reset(phase);
        end
      end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
      forever begin
        wait_reset_start();
        handle_reset(phase);
        wait_reset_end();
      end
    endtask
  
endclass

`endif