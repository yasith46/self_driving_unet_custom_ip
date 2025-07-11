`timescale 1ns/1ps

module tb_unet_fsm_3_1;

	reg rst_n, clk, unet_enpulse;
	reg [31:0] data_in;
	wire [2:0] ctrlflag;
	wire busyflag;
	wire [31:0] data_out;
	
	unet_fsm_3_1 dut0(
		.rst_n(rst_n), 
		.clk(clk), 
		.unet_enpulse(unet_enpulse), 
		.data_in(data_in),
		.ctrl(ctrlflag),
		.busy(busyflag),
		.data_out(data_out)
	);
	
	
	parameter CALCULATING  = 3'd0,
	          SEND_WEIGHTS = 3'd1,
	          SEND_DATA    = 3'd2,
	          DATA_READY   = 3'd3,
	          SAY_IDLE     = 3'd4;
	
	
	// Clock
	initial clk = 0;
	always #5 clk = ~clk;
	
	
endmodule 