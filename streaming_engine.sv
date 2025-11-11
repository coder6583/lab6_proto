module streaming_engine_v3 (system_bus_v3 bus);
parameter ADDR_WIDTH = 16;
parameter DATA_WIDTH = 16;

// offsets for the CSR
parameter BASE_CFG = 0; // config registers start at 0
parameter BASE_STATUS = 10; // status registers start at 10
parameter BASE_DATA = 15; // data registers start at 15
parameter BASE_CMD = 99; // command registers start at 99

// internal parameters
parameter FIFO_LENGTH = 32; // both FIFO and LIFO modes take this parameter
`include "operations.svh"

// aliases for clock and reset
logic clk;
assign clk = bus.clk;
logic rst_n;
assign rst_n = bus.rst_n;

// CSR registers
logic [DATA_WIDTH-1:0] c_mode; // read and write register. *BUG* from lab1 was here
logic c_mode_re, c_mode_we; // flags for controlling read/write operations to c_mode
assign c_mode_re = (bus.re && bus.addr == BASE_CFG+0);
assign c_mode_we = (bus.we && bus.addr == BASE_CFG+0);

logic [DATA_WIDTH-1:0] c_status; // read-only register
logic c_status_re, c_status_we; // flags for controlling read/write operations to c_status
assign c_status_re = (bus.re && bus.addr == BASE_STATUS+0);
assign c_status_we = 0;

logic [DATA_WIDTH-1:0] c_data [0:FIFO_LENGTH-1]; // 2d array of FL-1 elements, each containing DW-1 bits.
// read-only. writes through pushes only.
logic c_data_re, c_data_we; // flags for controlling read/write operations to c_data
assign c_data_re = (bus.re && (bus.addr >= (BASE_DATA+0) && bus.addr <= (BASE_DATA+FIFO_LENGTH-1)));
assign c_data_we = 0;

// special command registers. these are shadow registers with no storage behind them
logic cmd_re, cmd_we; // flags for controlling read/write operations to command registers
assign cmd_re = 0;
assign cmd_we = (bus.we && (bus.addr >= (BASE_CMD+0) && bus.addr <= (BASE_CMD+OP_LAST)));

// FIFO - LIFO registers
logic [$clog2(FIFO_LENGTH):0] pointer_h, pointer_l;

logic stream_flag;
typedef enum logic [1:0] {ST_IDLE, ST_RUN, ST_END} statetype;
statetype stream_state;
logic [$clog2(FIFO_LENGTH)-1:0] stream_counter;

assign c_status[0] = 1'b0;
assign c_status[1] = (pointer_h == pointer_l); // bug from lab2 was here
assign c_status[2] = stream_flag || (stream_state != ST_IDLE);
assign c_status[3] = 0;
assign c_status[4] = 0;
assign c_status[5] = 0;
assign c_status[6] = 0;
assign c_status[7] = 0;
assign c_status[8] = 0;
assign c_status[9] = 0;
assign c_status[10] = 0;
assign c_status[11] = 0;
assign c_status[12] = 0;
assign c_status[13] = 0;
assign c_status[14] = 0;
assign c_status[15] = 0;

// this always block controls writes to the CSR
always_ff @(posedge clk) begin
	if (rst_n == 1'b0) begin
		c_mode <= '0;
	end
	else begin
		if (c_mode_we) c_mode <= bus.data_from_system;
	end
end

// this always block controls reads to the CSR
always_comb begin
	bus.data_to_system = '0;

	if (c_mode_re) bus.data_to_system = c_mode;
	if (c_status_re) bus.data_to_system = c_status;
	if (c_data_re) bus.data_to_system = c_data[bus.addr-BASE_DATA];
end

// this always block controls what appears on the data_op port
always_comb begin
	bus.data_op = '0;
	if (stream_flag || (stream_state == ST_RUN) ) bus.data_op = c_data[stream_flag? 0 : stream_counter];
end

// this always block relates to command registers and their behavior
// it also controls write to the FIFO/LIFO
always_ff @(posedge clk) begin
	if (rst_n == 1'b0) begin
		pointer_h <= '0;
		pointer_l <= '0;
	end
	else begin
		if (stream_state == ST_RUN) begin // ongoing operations have precedence over new ops.
			// streaming engine can only do one operation at a time.
		end
		else if (cmd_we) begin
			case (bus.addr-BASE_CMD)
				OP_NOP, OP_LAST: begin
					// do nothing
				end
				OP_PUSH: begin
					if (c_mode[2:1] == 2'b01) begin // LIFO mode
						$display("starting a push in LIFO mode");
						pointer_l <= pointer_l; // bug from lab 2 was here
						pointer_h <= (pointer_h + 1) % FIFO_LENGTH;
						c_data[pointer_h] <= bus.data_from_system;
					end
					else if (c_mode[2:1] == 2'b10) begin // FIFO mode
						$display("starting a push in FIFO mode");
						pointer_l <= pointer_l;
						pointer_h <= (pointer_h + 1) % FIFO_LENGTH;
						c_data[pointer_h] <= bus.data_from_system;
					end
				end
				OP_POP: begin
					if (c_mode[2:1] == 2'b01) begin // LIFO mode
						$display("starting a pop in LIFO mode");
						pointer_l <= pointer_l; // bug from lab2 was here
						pointer_h <= (pointer_h - 1) % FIFO_LENGTH;
					end
					else if (c_mode[2:1] == 2'b10) begin // FIFO mode
						$display("starting a pop in FIFO mode");
						pointer_l <= (pointer_l+1) % FIFO_LENGTH;
						pointer_h <= pointer_h;
					end
				end
				OP_STREAM: begin
					// do nothing here, there is an entire FSM for this
				end
				default: begin
					$display("unknown operation: %d", bus.addr-BASE_CMD);
				end
			endcase
		end
	end
end

// this block controls the stream flag combinationally. this allows the
// streaming operation to start right away.
always_comb begin
	stream_flag = 1'b0;
	if (cmd_we && (bus.addr == BASE_CMD + OP_STREAM) ) begin
		stream_flag = 1'b1;
	end
end

// FSM that controls the stream operation
always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		stream_counter <= '0;
		stream_state <= ST_IDLE;
	end
	else begin
		if (stream_flag) stream_counter <= 1;
		else stream_counter <= stream_counter + 1;

		case (stream_state)
			ST_IDLE: begin
				if (stream_flag) begin
					stream_state <= ST_RUN;
				end
			end
			ST_RUN: begin
				if (stream_counter == FIFO_LENGTH-1) begin
					stream_state <= ST_END;
				end
			end
			ST_END: begin
				stream_state <= ST_IDLE;
			end
		endcase
	end

end

endmodule




