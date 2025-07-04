module convolutor3x3 #(
		parameter IMAGE_WIDTH = 128,
		parameter IMAGE_HEIGHT = 128
	)(
		input signed [7:0]  pixel_in,
		input signed [7:0]  w9, w8, w7, w6, w5, w4, w3, w2, w1,
		input signed [31:0] bias,
		input [7:0]  width,
		input clk, rst_n, paddingl, paddingr, relu,
		input [1:0]  operation,
		
		output reg signed [19:0] pixel_out
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
	 
	parameter conv3x3    = 0,
	          maxpool2x2 = 1,
	          transconv  = 2;
				 
	reg signed [7:0] max1, max2;
	
	always@(*) begin
		case (operation)
			conv3x3:
				begin
					if (((paddingl==1) ? 0 : (convout9 * w9)) + (convout8 * w8) + ((paddingr==1) ? 0 : (convout7 * w7)) +
					    ((paddingl==1) ? 0 : (convout6 * w6)) + (convout5 * w5) + ((paddingr==1) ? 0 : (convout4 * w4)) +
					    ((paddingl==1) ? 0 : (convout3 * w3)) + (convout2 * w2) + ((paddingr==1) ? 0 : (convout1 * w1)) +
					    bias < 0
					    && relu)	
							pixel_out <= 0;
					else
							pixel_out <= ((paddingl==1) ? 0 : (convout9 * w9)) + (convout8 * w8) + ((paddingr==1) ? 0 : (convout7 * w7)) +
							             ((paddingl==1) ? 0 : (convout6 * w6)) + (convout5 * w5) + ((paddingr==1) ? 0 : (convout4 * w4)) +
							             ((paddingl==1) ? 0 : (convout3 * w3)) + (convout2 * w2) + ((paddingr==1) ? 0 : (convout1 * w1)) +
							             bias;
				end
							
			maxpool2x2:
				begin
					if (convout1 > convout2)
						max1 <= convout1;
					else
						max1 <= convout2;
						
						
					if (convout4 > convout5)
						max2 <= convout4;
					else
						max2 <= convout5;
						
						
					if (max1 > max2)
						pixel_out <= max1;
					else
						pixel_out <= max2;							
				end
				
				
			default:
				pixel_out <= 0;
		endcase
	end
endmodule
