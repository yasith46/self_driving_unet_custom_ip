`timescale 1ns/1ps

module tb_unet_fsm_3_1;

	reg rst_n, clk, unet_enpulse;
	reg [31:0] data_in;
	wire [2:0] statusflag;
	wire busyflag;
	wire [31:0] data_out;
	
	unet_top dut0(
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
	
	parameter DATA_BASE_ADDR = 32'd0,
	          WEIGHT_BASE_ADDR = 32'd0;
	
	
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
	
	reg [31:0] weights_mem [0:938];
	reg [31:0] input_layers  [0:98368];
	reg [31:0] output_layers [0:65535];
	reg [31:0] expected_output_layers [0:65535];
	reg [31:0] raddr, raddr_real;
	reg [31:0] counter, counter2;
	
	initial begin
		$readmemh("weightdata.mem", weights_mem);
		$readmemh("inputdata.mem", input_layers);
		$readmemh("outputdata.mem", expected_output_layers);
	end
	
	always@(*) begin
		case (state)
			SEND_WEIGHTS:         data_in <= weights_mem[raddr];
			WAIT_TO_SEND_DATA:    data_in <= weights_mem[raddr];
			SEND_DATA:            data_in <= input_layers[raddr];
			WAIT_TO_RECEIVE_DATA: data_in <= input_layers[raddr];
			default: 		       data_in <= 32'd0;
		endcase
	end
	
	
	
	// Program
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			counter <= 32'd0;
			counter2 <= 32'd0;
			state   <= IDLE;
			unet_enpulse <= 1'b0;
			raddr <= 32'b0;
			raddr_real <= 32'b0;
		end else begin
			case (state)
				IDLE:
					begin
						$display("! - IDLE");
						if (statusflag == SAY_IDLE) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							counter2 <= 32'd0;
							
							if (unet_enpulse) begin
								state <= SEND_WEIGHTS;
								raddr_real <= WEIGHT_BASE_ADDR;
							end
						end
					end
					
				SEND_WEIGHTS:
					begin
						if (counter == 32'd0) begin
							$display("! - Sending weights");
							unet_enpulse <= 1'b0;
						end
												
						if (statusflag == SAY_SEND_WEIGHTS) begin
							if (counter == 32'd938) begin
								state <= WAIT_TO_SEND_DATA;
								counter <= 32'd0;
							end
						end
						
						counter <= counter + 32'd1;
						raddr_real <= raddr_real + 32'd1;
					end
					
				WAIT_TO_SEND_DATA:	
					begin
						$display("! - Waiting to send data");
						if (statusflag == SAY_IDLE) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							if (unet_enpulse) begin
								state <= SEND_DATA;
								raddr_real <= DATA_BASE_ADDR;
							end
						end
					end
					
				SEND_DATA:
					begin
						if (counter == 32'd0) begin
							unet_enpulse <= 1'b0;
							$display("! - Sending data");
						end
						
						/*
						if (counter2 < 259) begin
						 	if (counter2 % 4 == 1) begin
						 		if (counter2 == 1) 
						 			raddr_real <= DATA_BASE_ADDR;
						 		else
						 			raddr_real <= raddr_real + 1;
							end
						end else begin
							if (counter2 == 512) counter2 <= 0;
						 	raddr_real <= raddr_real + 1;
						end
						*/
						
						if (counter < 32'd32837) begin
							if (counter > 0) raddr_real <= raddr_real + 1;
						end else if (counter == 32'd32837) begin
							counter2 <= 32'd0;
							raddr_real <= raddr_real + 1;
						end else begin
							counter2 <= counter2 + 32'd1;
							if (counter2 % 4 == 0) begin
								raddr_real <= raddr_real + 32'd1;
							end
						end
							
						
						if (statusflag == SAY_SEND_DATA) begin
							if (counter == 32'd98368) begin		// 1 + (4xiw1xiw1) + (ow1xow1) + (ow1/2) + (iw2xiw2x4)
								state <= WAIT_TO_RECEIVE_DATA;
								counter <= 32'd0;
							end
						end
						
						counter <= counter + 32'd1;
					end
					
				WAIT_TO_RECEIVE_DATA:
					begin
						$display("! - Waiting for the calculation to be done");
						if (statusflag == SAY_DATA_READY) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							state <= RECEIVE_DATA;
						end
						raddr_real <= 32'd0;
					end
					
				RECEIVE_DATA:
					begin
						if (counter == 32'd0) begin
							unet_enpulse <= 1'b0;
							$display("! - RECIEVE_DATA");
						end
						
						
						if (statusflag == SAY_IDLE) begin		// 16 x 128 x 128 / 4
							state <= TB_EVALUATE;
							counter <= 32'd0;
						end
							
						if (statusflag == SAY_SENDING) begin
							counter <= counter + 32'd1;
							if (counter < 32'd65536) output_layers[counter] <= data_out;
						end
						raddr_real <= 32'd0;
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
						raddr_real <= 32'd0;
					end
				
				default:	
					begin
						state <= IDLE;
						raddr_real <= 32'd0;
					end
			endcase
			
			raddr <= raddr_real;
		end
	end
endmodule 