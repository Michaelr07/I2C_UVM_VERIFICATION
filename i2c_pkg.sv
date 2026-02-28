`ifndef I2C_PKG_SV
	`define I2C_PKG_SV

	`include "uvm_macros.svh"

	package i2c_pkg;
		import uvm_pkg::*;
			
        `include "i2c_types.sv"
		`include "i2c_reset_handler.sv"
        `include "i2c_transaction_item.sv"
        `include "i2c_agent_config.sv"
        `include "i2c_monitor.sv"
		`include "i2c_coverage.sv"
        `include "i2c_scoreboard.sv"
        `include "i2c_driver.sv"
        `include "i2c_sequencer.sv"
        `include "i2c_agent.sv"
        `include "i2c_base_seq.sv"
        `include "i2c_ping_seq.sv"
        `include "i2c_random_seq.sv"
        `include "i2c_max_burst_seq.sv"
        `include "i2c_addr_nack_seq.sv"
        `include "i2c_back_to_back_seq.sv"
		`include "i2c_cross_dir_seq.sv"
		`include "i2c_nack_data_seq.sv"
        `include "i2c_env.sv"
		`include "i2c_base_test.sv"
        `include "i2c_tests.sv"
		`include "i2c_regression_test.sv"

	endpackage
`endif