module convolutor3x3 #(
		parameter IMAGE_WIDTH = 128,
		parameter IMAGE_HEIGHT = 128
	)(
		input signed [7:0]  pixel_in,
		input signed [7:0]  w9, w8, w7, w6, w5, w4, w3, w2, w1,
		input signed [31:0] bias,
		input [7:0]  width,
		input clk, rst_n, paddingl, paddingr, relu,
		
		output reg signed [31:0] pixel_out
	);
	
	wire signed [7:0] convout9, convout8, convout7, convout6, convout5, convout4, convout3, convout2, convout1;
	
	collector3x3 #(.IMAGE_WIDTH(IMAGE_WIDTH), .IMAGE_HEIGHT(IMAGE_HEIGHT)) collector0 (
		.pixel_in(pixel_in),
		.clk(clk), .rst_n(rst_n), .stage_width(width),
		.out9(convout9), .out8(convout8), .out7(convout7),
		.out6(convout6), .out5(convout5), .out4(convout4),
		.out3(convout3), .out2(convout2), .out1(convout1)
	);
	
	/*
	 * max (convout * w) = 8b'1111_1111 * 8b'1111_1111 = 16b'1111_1110_0000_0001
	 * max pixel_out     = 16'b1111_1110_0000_0001 * 4d'9 = 20'b1000_1110_1110_0000_1001
	 */
	 
	parameter conv3x3 = 2'd0,
	          idle    = 2'd1;
				 
	reg signed [31:0] result;
	
	always@(*) begin
		result <= ((paddingl) ? 32'sd0 : (convout9 * w9)) + (convout8 * w8) + ((paddingr) ? 32'sd0 : (convout7 * w7)) +
					 ((paddingl) ? 32'sd0 : (convout6 * w6)) + (convout5 * w5) + ((paddingr) ? 32'sd0 : (convout4 * w4)) +
					 ((paddingl) ? 32'sd0 : (convout3 * w3)) + (convout2 * w2) + ((paddingr) ? 32'sd0 : (convout1 * w1)) +
					 bias;
					 
		if (relu) begin
			if (result < 32'sd0)
				pixel_out <= 32'sd0;
			else
				pixel_out <= result;
		end else begin
			pixel_out <= result;
		end
	end
endmodule
