module transconv #(
		parameter IMAGE_WIDTH = 256,
		parameter IMAGE_HEIGHT = 256
	)(
		input [7:0] in1, in2, in3, in4, in5, in6, in7, in8, in9,
		input [7:0] bufwidth,
		input clk, rst_n,
		output [19:0] pixelout
	);
	
	reg [8*IMAGE_WIDTH-1: 0] linebuf1;
	reg [8*IMAGE_WIDTH-1: 0] linebuf2;
	
endmodule
