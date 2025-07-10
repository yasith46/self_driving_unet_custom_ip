module tb_fsm;

	parameter CALCULATING  = 3'd0,
	          SEND_WEIGHTS = 3'd1,
	          SEND_DATA    = 3'd2,
	          DATA_READY   = 3'd3,
	          SAY_IDLE     = 3'd4;
	
	reg rst_n, clk, enpulse;
	wire busy;
	wire [2:0] ctrl;
	wire [31:0] dut_out;
	reg  [31:0] dut_in;
	
	unet_fsm_3_1 dut0 (
		.rst_n(rst_n),
		.clk(clk),
		.unet_enpulse(enpulse),
		.data_in(dut_in),
		.ctrl(ctrl),
		.busy(busy),
		.data_out(dut_out)
	);
	
	
	reg [31:0] in_image;
	
	
	
	
	// CLK
	initial clk = 0;
	always #5 clk = ~clk;
	
	
endmodule 