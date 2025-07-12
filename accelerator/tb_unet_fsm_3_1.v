`timescale 1ns/1ps

module tb_unet_fsm_3_1;

	reg rst_n, clk, unet_enpulse;
	reg [31:0] data_in;
	wire [2:0] statusflag;
	wire busyflag;
	wire [31:0] data_out;
	
	unet_fsm_3_1 dut0(
		.rst_n(rst_n), 
		.clk(clk), 
		.unet_enpulse(unet_enpulse), 
		.data_in(data_in),
		.ctrl(statusflag),
		.busy(busyflag),
		.data_out(data_out)
	);
	
	
	parameter	SAY_CALCULATING	= 3'd0,
					SAY_SEND_WEIGHTS	= 3'd1,
					SAY_SEND_DATA		= 3'd2,
					SAY_DATA_READY		= 3'd3,
					SAY_SENDING			= 3'd4,
					SAY_IDLE				= 3'd5;
					
	reg [2:0] state;
				 
	parameter	IDLE						= 3'd0,
					SEND_WEIGHTS			= 3'd1,
					WAIT_TO_SEND_DATA		= 3'd2,
					SEND_DATA				= 3'd3,
					WAIT_TO_RECEIVE_DATA	= 3'd4,
					RECEIVE_DATA			= 3'd5,
					TB_EVALUATE				= 3'd6;
	
	
	
	// Clock
	initial clk = 0;
	always #5 clk = ~clk;
	
	
	// Reset pulse
	initial begin
		rst_n <= 1;
		#10;
		$display("Starting testbench");
		
		rst_n <= 0;
		#4;
		rst_n <= 1;
	end
	
	
	// Memories
	
	reg [31:0] weights_mem [0:1679];
	reg [31:0] input_layers  [0:49217];
	reg [31:0] output_layers [0:65535];
	reg [31:0] expected_output_layers [0:65535];
	
	initial begin
		$readmemh("weightdata.mem", weights_mem);
		$readmemh("inputdata.mem", input_layers);
		$readmemh("outputdata.mem", expected_output_layers);
	end
	
	always@(*) begin
		case (state)
			IDLE:  			data_in <= 32'd0;
			SEND_WEIGHTS:	data_in <= weights_mem[counter];
			SEND_DATA:		data_in <= input_layers[counter];
			default: 		data_in <= 32'd0;
		endcase
	end
	
	
	
	// Program
	reg [31:0] counter;
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			counter <= 32'd0;
			state   <= IDLE;
			unet_enpulse <= 1'b0;
		end else begin
			case (state)
				IDLE:
					begin
						$display("! - IDLE");
						if (statusflag == SAY_IDLE) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							state <= SEND_WEIGHTS;
						end
					end
					
				SEND_WEIGHTS:
					begin
						if (counter == 32'd0) begin
							$display("! - Sending data");
							unet_enpulse <= 1'b0;
						end
						
						if (statusflag == SAY_SEND_WEIGHTS) begin
							counter <= counter + 32'd1;
							if (counter == 32'd939) begin
								state <= WAIT_TO_SEND_DATA;
								counter <= 32'd0;
							end
						end
					end
					
				WAIT_TO_SEND_DATA:	
					begin
						$display("! - Waiting to send data");
						if (statusflag == SAY_IDLE) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							state <= SEND_DATA;
						end
					end
					
				SEND_DATA:
					begin
						if (counter == 32'd0) begin
							unet_enpulse <= 1'b0;
							$display("! - Sending data");
						end
						
						if (statusflag == SAY_SEND_DATA) begin
							counter <= counter + 32'd1;
							if (counter == 32'd49217) begin		// 1 + (4xiw1xiw1) + (ow1xow1) + (ow1/2) + (iw2xiw2)
								state <= WAIT_TO_RECEIVE_DATA;
								counter <= 32'd0;
							end
						end
					end
					
				WAIT_TO_RECEIVE_DATA:
					begin
						$display("! - Waiting for the calculation to be done");
						if (statusflag == SAY_DATA_READY) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							state <= RECEIVE_DATA;
						end
					end
					
				RECEIVE_DATA:
					begin
						if (counter == 32'd0) begin
							unet_enpulse <= 1'b0;
							$display("! - RECIEVE_DATA");
						end
							
						if (statusflag == SAY_SENDING) begin
							counter <= counter + 32'd1;
							if (counter == 32'd65536) begin		// 16 x 128 x 128 / 4
								state <= TB_EVALUATE;
								counter <= 32'd0;
							end
							
							if (counter < 32'd65536) output_layers[counter] <= data_out;
						end
					end
					
				TB_EVALUATE:
					begin
						counter <= counter + 32'd1;
						
						if (counter == 65536) begin
							$display("Finished evaluating");
							$stop;
						end else begin
							if (output_layers[counter] == expected_output_layers[counter]) begin
								$display("%5d Correct -> 0x%08h", counter, output_layers[counter]);
							end else begin
								$display("%5d ERROR: Got 0x%08h expected 0x%08h", counter, output_layers[counter], expected_output_layers[counter]);
							end
						end
					end
				
				default:	state <= IDLE;
			endcase
		end
	end
endmodule 