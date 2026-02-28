`ifndef I2C_COVERAGE_SV
	`define I2C_COVERAGE_SV

class i2c_coverage extends uvm_subscriber #(i2c_transaction_item);
  `uvm_component_utils(i2c_coverage)

  i2c_transaction_item cov_item;

  // Define the Covergroup
  covergroup i2c_cg;
    option.per_instance = 1;

    cp_addr: coverpoint cov_item.addr {
      bins general_call = {7'h00};
      bins target_slave = {7'h21};
      bins others       = {[7'h01:7'h20], [7'h22:7'h7F]};
    }
    
    cp_write_len: coverpoint cov_item.wr_len {
      bins zero			= {0};
      bins single		= {1};
      bins short_burst	= {[2:5]};
      bins long_burst	= {[6:255]};
    }
    
    cp_read_len: coverpoint cov_item.rd_len {
      bins zero			= {0};
      bins single		= {1};
      bins short_burst	= {[2:5]};
      bins long_burst	= {[6:255]};
    }
    
    cx_dir: cross cp_write_len, cp_read_len {
      // It's impossible for both lengths to be 0 if a transaction occurred, so we ignore it
      ignore_bins no_traffic = binsof(cp_write_len.zero) && binsof(cp_read_len.zero);
    }
    
    cp_nack_addr: coverpoint cov_item.nack_addr {
      bins acked 	= {0};
      bins nacked 	= {1};
    }
    
    cp_nack_data: coverpoint cov_item.nack_data {
      bins acked 	= {0};
      bins nacked 	= {1};
    }
    
    // Cross Address NACKs with the Addresses to ensure we NACK'd an "other" address
    cx_addr_nack: cross cp_addr, cp_nack_addr {
      ignore_bins tgt_nack = binsof(cp_addr.target_slave) && binsof(cp_nack_addr.nacked);
      ignore_bins gen_nack = binsof(cp_addr.general_call) && binsof(cp_nack_addr.nacked);
      ignore_bins oth_ack  = binsof(cp_addr.others)     && binsof(cp_nack_addr.acked);
    }
    
  endgroup

  function new(string name = "i2c_coverage", uvm_component parent);
    super.new(name, parent);
    i2c_cg = new(); // Instantiate the covergroup
  endfunction

  // The write function automatically catches items from the Monitor
  virtual function void write(i2c_transaction_item t);
    cov_item = t;
    i2c_cg.sample(); // Toss the data into the buckets
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)
    `uvm_info("COV_REPORT", "          I2C FUNCTIONAL COVERAGE REPORT          ", UVM_NONE)
    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf(" Overall Coverage : %3.2f%%", i2c_cg.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("   - Addressing   : %3.2f%%", i2c_cg.cp_addr.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("   - Write Length : %3.2f%%", i2c_cg.cp_write_len.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("   - Read Length  : %3.2f%%", i2c_cg.cp_read_len.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("   - Address NACK : %3.2f%%", i2c_cg.cp_nack_addr.get_inst_coverage()), UVM_NONE)
    
    `uvm_info("COV_REPORT", $sformatf("   - Data NACK    : %3.2f%%", i2c_cg.cp_nack_data.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("   - Cross Dir    : %3.2f%%", i2c_cg.cx_dir.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("   - Cross NACK   : %3.2f%%", i2c_cg.cx_addr_nack.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)
    
  endfunction
endclass

`endif