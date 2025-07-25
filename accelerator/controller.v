module controller(
		input clk, rst_n,
		
		//slave_axi
		input  [31:0] InputImageAddress,
		
		//TODO: Add WeightAddress
		input  [31:0] OutputImageAddress,
		input  BeginConv,
		output reg ConvDone,
		input  [7:0]  heightOfImage, 
		input  [7:0]  widthOfImage, 
		input  [31:0] WeightAddress,

		//bram
		output reg [31:0] addr_0,
		output reg ce_0,
		output reg [3:0] we_0,
		input  [31:0] data_0,

		output reg [31:0] addr_1,
		output reg ce_1,
		output reg [3:0] we_1,
		input  [31:0] data_1,

		output reg [31:0] addr_2,
		output reg ce_2,
		output reg [3:0] we_2,
		output reg [31:0] data_2,

		//accelerator
		output reg unet_enpulse, 
		output reg [31:0] data_in,
		input [2:0] ctrl,
		input busy,
		input [31:0] data_out
	);
	
	
	/*
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
	*/
	
	
	reg [31:0] INPUT_BASE_ADDR, OUTPUT_BASE_ADDR, WEIGHTS_BASE_ADDR;
	
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
					DONE				= 3'd6;
	
	
	reg [31:0] counter, counter2, counter3;
	
	
	always@(*) begin
		case (state)
			SEND_WEIGHTS:         data_in <= data_0;
			WAIT_TO_SEND_DATA:    data_in <= data_0;
			SEND_DATA:            data_in <= data_1;
			WAIT_TO_RECEIVE_DATA: data_in <= data_1;
			default: 		       data_in <= 32'd0;
		endcase
	end
	
	
	
	// Program
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			counter <= 32'd0;
			counter2 <= 32'd4;
			counter3 <= 32'd0;
			state   <= IDLE;
			unet_enpulse <= 1'b0;
			
			INPUT_BASE_ADDR <= 32'b0; 
			OUTPUT_BASE_ADDR <= 32'b0; 
			WEIGHTS_BASE_ADDR <= 32'b0;
			
			ce_0 <= 0;
			we_0 <= 0;
			ce_1 <= 0;
			we_1 <= 0;
			ce_2 <= 0;
			we_2 <= 0;
			addr_0 <= 0;
			ConvDone <= 0;
			
		end else begin
			case (state)
				IDLE:
					begin
						if (BeginConv && ctrl == SAY_IDLE) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							counter2 <= 32'd0;
							counter3 <= 32'd0;
							
							INPUT_BASE_ADDR <= InputImageAddress; 
							OUTPUT_BASE_ADDR <= OutputImageAddress; 
							WEIGHTS_BASE_ADDR <= WeightAddress;
							ConvDone <= 0;
							
							if (unet_enpulse) begin
								state <= SEND_WEIGHTS;
								addr_0 <= WEIGHTS_BASE_ADDR;
								ce_0 <= 1;
								we_0 <= 0;
								counter2 <= 32'd4;
							end
						end
					end
					
				SEND_WEIGHTS:
					begin
						if (counter == 32'd0) begin
							unet_enpulse <= 1'b0;
						end
												
						if (ctrl == SAY_SEND_WEIGHTS) begin
							if (counter == 32'd938) begin
								state <= WAIT_TO_SEND_DATA;
								counter <= 32'd0;
								counter2 <= 32'd4;
							end
						end
						
						counter <= counter + 32'd1;
						counter2 <= counter2 + 32'd4;
						addr_0 <= WEIGHTS_BASE_ADDR + counter2;
					end
					
				WAIT_TO_SEND_DATA:	
					begin
						if (ctrl == SAY_IDLE) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							if (unet_enpulse) begin
								state <= SEND_DATA;
								addr_1 <= INPUT_BASE_ADDR;
								ce_0 <= 0;
								we_0 <= 0;
								ce_1 <= 1;
								we_1 <= 0;
							end
						end
					end
					
				SEND_DATA:
					begin
						if (counter == 32'd0) begin
							unet_enpulse <= 1'b0;
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
							if (counter > 0) begin
								addr_1 <= INPUT_BASE_ADDR + counter2;
								counter2 <= counter2 + 32'd4;
							end
						end else if (counter == 32'd32837) begin
							counter3 <= 32'd0;
							
							addr_1 <= INPUT_BASE_ADDR + counter2;
							counter2 <= counter2 + 32'd4;
						end else begin
							counter3 <= counter3 + 32'd1;
							if (counter3 % 4 == 0) begin
								addr_1 <= INPUT_BASE_ADDR + counter2;
								counter2 <= counter2 + 32'd4;
							end
						end
							
						
						if (ctrl == SAY_SEND_DATA) begin
							if (counter == 32'd98368) begin		// 1 + (4xiw1xiw1) + (ow1xow1) + (ow1/2) + (iw2xiw2x4)
								state <= WAIT_TO_RECEIVE_DATA;
								counter <= 32'd0;
								counter2 <= 32'd4;
							end
						end
						
						counter <= counter + 32'd1;
					end
					
				WAIT_TO_RECEIVE_DATA:
					begin
						if (ctrl == SAY_DATA_READY) begin
							unet_enpulse <= 1'b1;
							counter <= 32'd0;
							state <= RECEIVE_DATA;
							
							ce_1 <= 0;
							we_1 <= 0;
						end
					end
					
				RECEIVE_DATA:
					begin
						if (counter == 32'd0) begin
							unet_enpulse <= 1'b0;
						end
						
						
						if (ctrl == SAY_IDLE) begin		// 16 x 128 x 128 / 4
							state <= DONE;
							counter <= 32'd0;
							counter2 <= 32'd0;
						end
							
						if (ctrl == SAY_SENDING) begin
							counter <= counter + 32'd1;
							counter2 <= counter2 + 32'd4;
							
							if (counter < 32'd65536) begin
								addr_2 <= OUTPUT_BASE_ADDR + counter2;
								ce_2 <= 1;
								we_2 <= 1;
								data_2 <= data_out;
							end
						end
					end
					
				DONE:
					begin
						ConvDone <= 1;
						ce_2 <= 0;
						we_2 <= 0;
						state <= IDLE;
					end
					
				default:	
					begin
						state <= IDLE;
					end
			endcase
		end
	end
endmodule 