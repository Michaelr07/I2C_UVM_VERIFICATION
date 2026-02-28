`ifndef I2C_DRIVER_SV
`define I2C_DRIVER_SV

class i2c_driver extends uvm_driver #(i2c_transaction_item) implements i2c_reset_handler;

  i2c_agent_config agent_config;
  
  // A flag to act as a "kill switch" for the loops
  bit in_reset_cleanup = 0;

  // Process handle to kill the drive task if needed
  protected process process_drive_transactions;

  `uvm_component_utils(i2c_driver)

  function new (string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  // --- FIXED RUN_PHASE ---
  // This version handles reset concurrently so it never gets "stuck"
  virtual task run_phase(uvm_phase phase);
    forever begin
      // 1. Always wait for reset to end first (safe state)
      wait_reset_end();
      
      in_reset_cleanup = 0; // Clear our cleanup flag
      
      // 2. Start driving AND watching for the next reset at the same time
      fork
        begin
          process_drive_transactions = process::self();
          drive_transactions();
        end
        begin
          wait_reset_start();
        end
      join_any // If EITHER finishes (driving crashes or reset starts), we move on
      
      // 3. If we got here, a reset happened (or we crashed). Kill everything.
      disable fork;
      
      // 4. Clean up signals
      handle_reset(phase);
    end
  endtask

  protected virtual task drive_transactions();
    forever begin
      i2c_transaction_item item;
      seq_item_port.get_next_item(item);
      drive_transaction(item);
      seq_item_port.item_done();
    end
  endtask
   
  protected virtual task drive_transaction(i2c_transaction_item item);
    i2c_vif vif = agent_config.get_vif();
    int timeout_counter = 0;

    `uvm_info("DEBUG", $sformatf("Driving \"%0s\": %0s", 
                                 item.get_full_name(), item.convert2string()), UVM_HIGH)

    @(posedge vif.clk);
    vif.addr7  <= item.addr;
    vif.wr_len <= item.wr_data.size();
    vif.rd_len <= item.rd_len;
    vif.start  <= 1;
    @(posedge vif.clk);
    vif.start  <= 0;

    // --- TIMEOUT CHECK ---
    fork
      begin : timeout_check
        #(10us);
        `uvm_fatal("DRV_TIMEOUT", "Master never asserted busy after start!")
      end
      begin
        wait(vif.busy);
        disable timeout_check;
      end
    join
     
    // --- Write phase ---
    if (item.wr_data.size() > 0) begin
      foreach (item.wr_data[i]) begin
        vif.wr_data  <= item.wr_data[i];
        vif.wr_valid <= 1;

        // FIXED: Loop with safety break for Reset or Timeout
        timeout_counter = 0;
        do begin
          @(posedge vif.clk);
          timeout_counter++;
          if (in_reset_cleanup) break; // Break if reset happened
          if (timeout_counter > 100000) begin 
             `uvm_fatal("DRV_STUCK", "Stuck waiting for wr_ready!"); 
          end
        end while (!vif.wr_ready && !vif.nack_addr && !vif.nack_data);

        vif.wr_valid <= 0;

        if (vif.nack_addr || vif.nack_data|| in_reset_cleanup) break;
      end
    end

    // --- Read phase ---
    if (item.rd_len > 0) begin
      item.rd_data = new[item.rd_len];
      
      foreach (item.rd_data[i]) begin
      
        // --- 1. RANDOM STALL INJECTION ---
        // 30% chance to hold rd_ready LOW to test Master backpressure
        if ($urandom_range(0, 99) < 30) begin 
           vif.rd_ready <= 0;
           // Wait a random number of clock cycles (1 to 4)
           repeat($urandom_range(1, 4)) @(posedge vif.clk); 
        end

        // --- 2. DECLARE READY ---
        vif.rd_ready <= 1;

        // --- 3. WAIT FOR MASTER ---
        timeout_counter = 0;
        do begin
          @(posedge vif.clk);
          timeout_counter++;
          if (in_reset_cleanup) break;
        end while (!vif.rd_valid && !vif.nack_addr && !vif.nack_data);

        if (vif.nack_addr || vif.nack_data || in_reset_cleanup) begin
           vif.rd_ready <= 0;
           break;
        end

        // --- 4. CAPTURE DATA ---
        item.rd_data[i] = vif.rd_data;
        
        // Drop ready (it will stay 0 ONLY if the random stall triggers on the next loop)
        vif.rd_ready <= 0; 
      end
    end

    // --- Wait for done ---
    timeout_counter = 0;
    while (!vif.done && !in_reset_cleanup) begin
       @(posedge vif.clk);
       timeout_counter++;
       if (timeout_counter > 100000) begin
          `uvm_fatal("DRV_STUCK", "Stuck waiting for Done!");
       end
    end

    @(posedge vif.clk);
    vif.start    <= 0;
    vif.wr_valid <= 0;
    vif.rd_ready <= 0;
  endtask

  protected virtual task wait_reset_end();
    agent_config.wait_reset_end();
  endtask
  
  protected virtual task wait_reset_start();
    agent_config.wait_reset_start();
  endtask
   
  virtual function void handle_reset(uvm_phase phase);
    i2c_vif vif = agent_config.get_vif();
    
    // Set flag to break loops instantly
    in_reset_cleanup = 1;

    // Kill process if it's still running
    if(process_drive_transactions != null) begin
      process_drive_transactions.kill();
      process_drive_transactions = null;
    end
     
    // Clear signals
    vif.start    <= 0;
    vif.wr_valid <= 0;
    vif.rd_ready <= 0;
  endfunction
       
endclass
`endif