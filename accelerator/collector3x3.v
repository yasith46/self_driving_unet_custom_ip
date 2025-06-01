module collector3x3 #(
		parameter IMAGE_WIDTH = 256,
		parameter IMAGE_HEIGHT = 256
	)(
		input  [7:0] pixel_in, 
		input  clk, rst_n,
		output [7:0] out1, out2, out3, out4, out5, out6, out7, out8, out9,
		output stall
	);
	
	reg [8*IMAGE_WIDTH-1: 0] linebuf1;
	reg [8*IMAGE_WIDTH-1: 0] linebuf2;
	reg [7:0] buffer [5:0];
	
	integer i;
	
	reg [7:0] row, col;
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			row <= 8'hff;
			col <= 8'hff;
		end else begin
			// Shifting buffers
			linebuf1 <= {pixel_in, linebuf1[8*IMAGE_WIDTH-1: 8]};
			linebuf2 <= {linebuf1[7:0], linebuf2[8*IMAGE_WIDTH-1: 8]};
			
			buffer[5] <= pixel_in;
			buffer[4] <= buffer[5];
			
			buffer[3] <= linebuf1[7:0];
			buffer[2] <= buffer[3];
			
			buffer[1] <= linebuf2[7:0];
			buffer[0] <= buffer[1];
		
			// Counters for stall
			if (col == IMAGE_WIDTH-1) begin
				col <= 8'b0;
				if (row == IMAGE_HEIGHT-1) 
					row <= 8'b0;
				else
					row <= row + 8'b1;
			end else begin
				col <= col + 8'b1;
			end
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
	
	assign stall = (row==0) || (row==1) || (row==2 && (col==0 || col==1)) || (col==0) || (col==1) || ~rst_n;
endmodule 