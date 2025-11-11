interface system_bus_v3;
	parameter ADDR_WIDTH = 16;
	parameter DATA_WIDTH = 16;
	bit clk;
	bit rst_n; // active 0 synchronous reset
	logic re; // active 1 read enable
	logic we; // active 1 write enable
	logic [ADDR_WIDTH-1:0] addr; // address from outside, from system
	logic [DATA_WIDTH-1:0] data_from_system; // data coming in
	logic [DATA_WIDTH-1:0] data_to_system; // data going out
	logic [DATA_WIDTH-1:0] data_op; // operation generated data
endinterface

