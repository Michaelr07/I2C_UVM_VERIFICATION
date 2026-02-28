`ifndef I2C_TYPES_SV
	`define I2C_TYPES_SV

  typedef virtual i2c_m_if i2c_vif;

  typedef bit[`I2C_MAX_ADDR_WIDTH-1:0] 		i2c_addr;

  typedef bit[`I2C_MAX_DATA_WIDTH-1:0] 		i2c_wr_size;

  typedef bit[`I2C_MAX_DATA_WIDTH-1:0] 		i2c_rd_size;

`endif