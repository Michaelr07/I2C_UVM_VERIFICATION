`ifndef I2C_M_IF_SV
  `define I2C_M_IF_SV  

`ifndef I2C_MAX_DATA_WIDTH
  	`define I2C_MAX_DATA_WIDTH 8
  `endif

  `ifndef I2C_MAX_ADDR_WIDTH
  	`define I2C_MAX_ADDR_WIDTH 7
  `endif

interface i2c_m_if (input bit clk);
    logic         	rst_n;
    logic           start;          
    logic [6:0]     addr7;          
    logic [7:0]     wr_len;         
    logic [7:0]     rd_len;     
    logic 			busy;          
    logic 			done;           
    logic 			nack_addr;     
    logic 			nack_data;      
    logic 			timeout;       
                                       
  	logic [7:0]		wr_data;        // write data stream
    logic 			wr_valid;
    logic 			wr_ready;
    
  	logic [7:0]		rd_data;        // read data stream
    logic 			rd_valid;
    logic 			rd_ready;
    
    wire			sda_io;         // I2C pins
    wire  			scl_io;
  	
  
  sequence s_start;
  	$fell(sda_io) ##0 (scl_io);
  endsequence
  
  sequence s_stop;
  	$rose(sda_io) ##0 (scl_io);
  endsequence
  
  property p_data_stable_when_scl_high;
    @(posedge clk) disable iff (!rst_n)
    	(scl_io == 1'b1 && !$changed(scl_io)) |-> 
    ($stable(sda_io) or s_start or s_stop);
  endproperty
  
  A_DATA_STABLE: assert property(p_data_stable_when_scl_high) 
    else $error("SVA_VIOLATION", "PROTOCOL FATAL: SDA transitioned while SCL was HIGH without a valid Start/Stop condition!");

  // 4. Property: Check for floating states on the clock
  property p_no_x_scl;
    @(posedge clk) disable iff (!rst_n)
      (!$isunknown(scl_io));
  endproperty
  
  // 5. Watchdog 2: Unknown State Checker
  A_NO_X_SCL: assert property(p_no_x_scl)
    else $error("SVA_VIOLATION", "SCL line floated to X or Z state!");
  
endinterface



`endif