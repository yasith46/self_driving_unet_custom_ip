module transconv #(
		parameter IMAGE_WIDTH = 128,
		parameter IMAGE_HEIGHT = 128
	)(
		input signed [7:0] in,
		input signed [7:0] w9, w8, w7, w6, w5, w4, w3, w2, w1,
		input signed [7:0] bias,
		input [7:0] width,
		input flip, clk, rst, rw, hop,
		output reg signed [31:0] pixel
	);
	
	reg signed [31:0] linebuf1_array [0:IMAGE_WIDTH];
   reg signed [31:0] linebuf2_array [0:IMAGE_WIDTH];
	reg signed [31:0] linebuf3_array [0:IMAGE_WIDTH];
	
	reg [15:0] wcounter, rcounter;
	
	reg hold_first;
	
	integer i;
	
	always@(posedge clk or negedge rst) begin
		if (!rst) begin
			wcounter <= 16'd0;
			rcounter <= 16'd0;
			hold_first <= 1'b1;
			
			for (i=0; i<IMAGE_WIDTH+1; i=i+1) linebuf1_array[i] <= 32'sd0;
			for (i=0; i<IMAGE_WIDTH+1; i=i+1) linebuf2_array[i] <= 32'sd0;
			for (i=0; i<IMAGE_WIDTH+1; i=i+1) linebuf3_array[i] <= 32'sd0;
			
		end else begin
			if (rw) begin
				if (flip) begin
					linebuf3_array[wcounter]       <= (in*w1) + linebuf3_array[wcounter];
					linebuf3_array[wcounter+16'd1] <= (in*w2) + linebuf3_array[wcounter+16'd1];
					linebuf3_array[wcounter+16'd2] <= (in*w3) + linebuf3_array[wcounter+16'd2];
					
					linebuf2_array[wcounter]       <= (in*w4) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf2_array[wcounter]);
					linebuf2_array[wcounter+16'd1] <= (in*w5) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf2_array[wcounter+16'd1]);
					linebuf2_array[wcounter+16'd2] <= (in*w6) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf2_array[wcounter+16'd2]);
					
					linebuf1_array[wcounter]       <= (in*w7) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf1_array[wcounter]);
					linebuf1_array[wcounter+16'd1] <= (in*w8) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf1_array[wcounter+16'd1]);
					linebuf1_array[wcounter+16'd2] <= (in*w9) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf1_array[wcounter+16'd2]);
					
					if (wcounter == 16'd0) begin
						for (i=3; i<IMAGE_WIDTH+1; i=i+1) linebuf1_array[i] <= 32'sd0;
						for (i=3; i<IMAGE_WIDTH+1; i=i+1) linebuf2_array[i] <= 32'sd0;
					end
					
				end else begin
					linebuf1_array[wcounter]       <= (in*w1) + linebuf1_array[wcounter];
					linebuf1_array[wcounter+16'd1] <= (in*w2) + linebuf1_array[wcounter+16'd1];
					linebuf1_array[wcounter+16'd2] <= (in*w3) + linebuf1_array[wcounter+16'd2];
					
					linebuf2_array[wcounter]       <= (in*w4) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf2_array[wcounter]);
					linebuf2_array[wcounter+16'd1] <= (in*w5) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf2_array[wcounter+16'd1]);
					linebuf2_array[wcounter+16'd2] <= (in*w6) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf2_array[wcounter+16'd2]);
					
					linebuf3_array[wcounter]       <= (in*w7) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf3_array[wcounter]);
					linebuf3_array[wcounter+16'd1] <= (in*w8) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf3_array[wcounter+16'd1]);
					linebuf3_array[wcounter+16'd2] <= (in*w9) + ((wcounter == 16'd0 && hold_first) ? 32'sd0 : linebuf3_array[wcounter+16'd2]);
					
					if (wcounter == 16'd0) begin
						for (i=3; i<IMAGE_WIDTH+1; i=i+1) linebuf2_array[i] <= 32'sd0;
						for (i=3; i<IMAGE_WIDTH+1; i=i+1) linebuf3_array[i] <= 32'sd0;
					end
					
				end
				
				if (hop) wcounter <= wcounter + 16'd2;
				if (hold_first) hold_first <= 1'b0;
				rcounter <= 16'd0;
				
				pixel <= (flip ? linebuf1_array[rcounter-(width<<2)-1] : linebuf3_array[rcounter-(width<<2)-16'd1]) + bias;
				
			end else begin
				rcounter <= rcounter + 16'd1;
				wcounter <= 16'd0;
				hold_first <= 1'b1;
				
				if (rcounter < width) begin
					pixel <= (flip ? linebuf3_array[rcounter] : linebuf1_array[rcounter]) + bias;
				end else if (rcounter < (width << 2)) begin
					pixel <= (linebuf2_array[rcounter-width]) + bias;
				end else begin	
					pixel <= (flip ? linebuf1_array[rcounter-(width<<2)] : linebuf3_array[rcounter-(width<<2)]) + bias;
				end
				
			end
		end
	end
endmodule
