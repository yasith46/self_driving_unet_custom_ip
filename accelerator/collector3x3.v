module collector3x3 #(
		parameter IMAGE_WIDTH = 128,
		parameter IMAGE_HEIGHT = 128
	)(
		input  clk, rst_n,
		input  [7:0] pixel_in,
		input  [7:0] stage_width,  // dynamic width (in pixels)
		output [7:0] out1, out2, out3, out4, out5, out6, out7, out8, out9
	);

   reg [7:0] linebuf1_array [0:IMAGE_WIDTH-1];
   reg [7:0] linebuf2_array [0:IMAGE_WIDTH-1];
   reg [7:0] buffer[5:0];

   integer i;

   always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (i = 0; i < IMAGE_WIDTH; i = i + 1) begin
				linebuf1_array[i] <= 0;
				linebuf2_array[i] <= 0;
			end
			for (i = 0; i < 6; i = i + 1)  buffer[i] <= 0;
			
		end else begin
			// Shift linebuf1_array
			for (i = IMAGE_WIDTH - 1; i > 0; i = i - 1) begin
				linebuf1_array[i] <= linebuf1_array[i - 1];
			end
			linebuf1_array[0] <= pixel_in;

			// Shift linebuf2_array
			for (i = IMAGE_WIDTH - 1; i > 0; i = i - 1) begin
				linebuf2_array[i] <= linebuf2_array[i - 1];
			end
			linebuf2_array[0] <= linebuf1_array[stage_width-1];

			// 6-element shift register for pixels
			buffer[5] <= pixel_in;
			buffer[4] <= buffer[5];

			buffer[3] <= linebuf1_array[stage_width-1];
			buffer[2] <= buffer[3];

			buffer[1] <= linebuf2_array[stage_width-1];
			buffer[0] <= buffer[1];
		end
	end


	assign out9 = pixel_in;
	assign out8 = buffer[5];
	assign out7 = buffer[4];
	assign out6 = linebuf1_array[stage_width-1];
	assign out5 = buffer[3];
	assign out4 = buffer[2];
	assign out3 = linebuf2_array[stage_width-1];
	assign out2 = buffer[1];
	assign out1 = buffer[0];
	 
	// The output kernel is in the following format
	//
	// +-----+-----+-----+
	// | o1  | o2  | o3  |
	// +-----+-----+-----+
	// | o4  | o5  | o6  |
	// +-----+-----+-----+
	// | o7  | o8  | o9  |
	// +-----+-----+-----+

endmodule
