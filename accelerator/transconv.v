module transconv #(
		parameter IMAGE_WIDTH = 128,
		parameter IMAGE_HEIGHT = 128
	)(
		input signed [7:0] in,
		input signed [7:0] w9, w8, w7, w6, w5, w4, w3, w2, w1,
		input signed [7:0] bias,
		input [7:0] width,
		input flip, clk, rst, rw, hop,
		output reg signed [19:0] pixel
	);
	
	reg signed [19:0] linebuf1_array [0:IMAGE_WIDTH];
   reg signed [19:0] linebuf2_array [0:IMAGE_WIDTH];
	reg signed [19:0] linebuf3_array [0:IMAGE_WIDTH];
	
	reg [8:0] wcounter, rcounter;
	
	reg hold_first;
	
	integer i;
	
	always@(posedge clk or negedge rst) begin
		if (!rst) begin
			wcounter <= 0;
			rcounter <= 0;
			hold_first <= 1;
			
			for (i=0; i<IMAGE_WIDTH+1; i=i+1) linebuf1_array[i] <= 0;
			for (i=0; i<IMAGE_WIDTH+1; i=i+1) linebuf2_array[i] <= 0;
			for (i=0; i<IMAGE_WIDTH+1; i=i+1) linebuf3_array[i] <= 0;
			
		end else begin
			if (rw) begin
				if (flip) begin
					linebuf3_array[wcounter]   <= (in*w1) + linebuf3_array[wcounter] + bias;
					linebuf3_array[wcounter+1] <= (in*w2) + linebuf3_array[wcounter+1] + bias;
					linebuf3_array[wcounter+2] <= (in*w3) + linebuf3_array[wcounter+2] + bias;
					
					linebuf2_array[wcounter]   <= (in*w4) + ((wcounter == 0 && hold_first) ? 0 : linebuf2_array[wcounter]) + bias;
					linebuf2_array[wcounter+1] <= (in*w5) + ((wcounter == 0 && hold_first) ? 0 : linebuf2_array[wcounter+1]) + bias;
					linebuf2_array[wcounter+2] <= (in*w6) + ((wcounter == 0 && hold_first) ? 0 : linebuf2_array[wcounter+2]) + bias;
					
					linebuf1_array[wcounter]   <= (in*w7) + ((wcounter == 0 && hold_first) ? 0 : linebuf1_array[wcounter]) + bias;
					linebuf1_array[wcounter+1] <= (in*w8) + ((wcounter == 0 && hold_first) ? 0 : linebuf1_array[wcounter+1]) + bias;
					linebuf1_array[wcounter+2] <= (in*w9) + ((wcounter == 0 && hold_first) ? 0 : linebuf1_array[wcounter+2]) + bias;
					
					if (wcounter == 0) begin
						for (i=3; i<IMAGE_WIDTH+1; i=i+1) linebuf1_array[i] <= 0;
						for (i=3; i<IMAGE_WIDTH+1; i=i+1) linebuf2_array[i] <= 0;
					end
					
				end else begin
					linebuf1_array[wcounter]   <= (in*w1) + linebuf1_array[wcounter] + bias;
					linebuf1_array[wcounter+1] <= (in*w2) + linebuf1_array[wcounter+1] + bias;
					linebuf1_array[wcounter+2] <= (in*w3) + linebuf1_array[wcounter+2] + bias;
					
					linebuf2_array[wcounter]   <= (in*w4) + ((wcounter == 0 && hold_first) ? 0 : linebuf2_array[wcounter]) + bias;
					linebuf2_array[wcounter+1] <= (in*w5) + ((wcounter == 0 && hold_first) ? 0 : linebuf2_array[wcounter+1]) + bias;
					linebuf2_array[wcounter+2] <= (in*w6) + ((wcounter == 0 && hold_first) ? 0 : linebuf2_array[wcounter+2]) + bias;
					
					linebuf3_array[wcounter]   <= (in*w7) + ((wcounter == 0 && hold_first) ? 0 : linebuf3_array[wcounter]) + bias;
					linebuf3_array[wcounter+1] <= (in*w8) + ((wcounter == 0 && hold_first) ? 0 : linebuf3_array[wcounter+1]) + bias;
					linebuf3_array[wcounter+2] <= (in*w9) + ((wcounter == 0 && hold_first) ? 0 : linebuf3_array[wcounter+2]) + bias;
					
					if (wcounter == 0) begin
						for (i=3; i<IMAGE_WIDTH+1; i=i+1) linebuf2_array[i] <= 0;
						for (i=3; i<IMAGE_WIDTH+1; i=i+1) linebuf3_array[i] <= 0;
					end
					
				end
				
				if (hop) wcounter <= wcounter + 2;
				if (hold_first) hold_first <= 0;
				rcounter <= 0;
				
			end else begin
				rcounter <= rcounter + 1;
				wcounter <= 0;
				hold_first <= 1;
				
				if (rcounter < width) begin
					pixel <= flip ? linebuf3_array[rcounter] : linebuf1_array[rcounter];
				end else if (rcounter < (width << 2)) begin
					pixel <= linebuf2_array[rcounter-width];
				end else begin	
					pixel <= flip ? linebuf1_array[rcounter-(width<<2)] : linebuf3_array[rcounter-(width<<2)];
				end
				
			end
		end
	end
endmodule
