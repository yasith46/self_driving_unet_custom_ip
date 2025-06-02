module collector3x3 #(
		parameter IMAGE_WIDTH = 128,
		parameter IMAGE_HEIGHT = 128
	)(
		input  [7:0] pixel_in, 
		input  clk, rst_n,
		input  [7:0] stage_width,
		output [7:0] out1, out2, out3, out4, out5, out6, out7, out8, out9,
	);
	
	reg [8*IMAGE_WIDTH-1: 0] linebuf1;
	reg [8*IMAGE_WIDTH-1: 0] linebuf2;
	reg [7:0] buffer [5:0];
	
	integer i;
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			linebuf1 <= 0;
			linebuf2 <= 0;
			
			for (i=0; i<6; i=i+1) begin
				buffer[i] <= 0;
			end
			
		end else begin
			// Shifting buffers
			linebuf1 <= {pixel_in, linebuf1[8*stage_width-1: 8]};
			linebuf2 <= {linebuf1[7:0], linebuf2[8*stage_width-1: 8]};
			
			buffer[5] <= pixel_in;
			buffer[4] <= buffer[5];
			
			buffer[3] <= linebuf1[7:0];
			buffer[2] <= buffer[3];
			
			buffer[1] <= linebuf2[7:0];
			buffer[0] <= buffer[1];
		end
	end	
	
	assign out9 = pixel_in;
	assign out8 = buffer[5];
	assign out7 = buffer[4];
	assign out6 = linebuf1[7:0];
	assign out5 = buffer[3];
	assign out4 = buffer[2];
	assign out3 = linebuf2[7:0];
	assign out2 = buffer[1];
	assign out1 = buffer[0]; 
endmodule 