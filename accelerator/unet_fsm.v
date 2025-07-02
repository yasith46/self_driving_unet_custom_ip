module unet_fsm(
		input rst_n, clk, unet_enpulse, 
		input [31:0] data_in,
		output reg [2:0] ctrl,
		output reg busy,
		output reg [31:0] data_out
	);
	
	parameter SEND_WEIGHTS = 3'd1,
	          SEND_DATA    = 3'd2,
				 DATA_READY   = 3'd3,
				 SAY_IDLE     = 3'd4;
	
	parameter IDLE              = 5'd0,
				 STAGE1_WEIGHTLOAD = 5'd1,
	          STAGE1_CONV       = 5'd2,
	          STAGE1_MXPL       = 5'd3,
	          STAGE2_CONV       = 5'd4,
				 STAGE2_MXPL       = 5'd5,
				 STAGE3_CONV       = 5'd6,
				 STAGE3_MXPL       = 5'd7,
				 STAGE4_CONV       = 5'd8,
				 STAGE4_MXPL       = 5'd9,
				 STAGE5_CONV       = 5'd10,
				 STAGE6_TRANSCONV  = 5'd11,
				 STAGE6_CONV       = 5'd12,
				 STAGE7_TRANSCONV  = 5'd13,
				 STAGE7_CONV       = 5'd14,
				 STAGE8_TRANSCONV  = 5'd15,
				 STAGE8_CONV       = 5'd16,
				 STAGE9_TRANSCONV  = 5'd17,
				 STAGE9_CONV       = 5'd18,
				 STAGE10_CONV      = 5'd19,
				 SEND              = 5'd20;
				 
	reg [4:0] state;
	
	
	
	/*********************************************************************************
	 * Set of convolutors
	 */
	 
	reg [7:0] cv_pixelin [0:31];
	reg [7:0] cv_w [0:31][1:9];
	reg cv_paddingL, cv_paddingR, relu;
	reg [1:0] cv_op [0:31];
	reg [7:0] cv_width [0:31];
	reg [31:0] cv_bias [0:31];
	wire [31:0] cv_pixelout [0:31];
	reg cv_rst[0:31];
	
	
	parameter CONV        = 2'd0,
	          MAXPOOL2x2  = 2'd1,
				 TRANS       = 2'd2;
				 
	
				 
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv0 (
		.pixel_in(cv_pixelin[0]),
		.w9(cv_w[0][9]), .w8(cv_w[0][8]), .w7(cv_w[0][7]), 
		.w6(cv_w[0][6]), .w5(cv_w[0][5]), .w4(cv_w[0][4]), 
		.w3(cv_w[0][3]), .w2(cv_w[0][2]), .w1(cv_w[0][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[0]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[0]),
		.pixel_out(cv_pixelout[0]),
		.operation(cv_op[0]),
		.width(cv_width[0]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv1 (
		.pixel_in(cv_pixelin[1]),
		.w9(cv_w[1][9]), .w8(cv_w[1][8]), .w7(cv_w[1][7]), 
		.w6(cv_w[1][6]), .w5(cv_w[1][5]), .w4(cv_w[1][4]), 
		.w3(cv_w[1][3]), .w2(cv_w[1][2]), .w1(cv_w[1][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[1]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[1]),
		.pixel_out(cv_pixelout[1]),
		.operation(cv_op[1]),
		.width(cv_width[1]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv2 (
		.pixel_in(cv_pixelin[2]),
		.w9(cv_w[2][9]), .w8(cv_w[2][8]), .w7(cv_w[2][7]), 
		.w6(cv_w[2][6]), .w5(cv_w[2][5]), .w4(cv_w[2][4]), 
		.w3(cv_w[2][3]), .w2(cv_w[2][2]), .w1(cv_w[2][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[2]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[2]),
		.pixel_out(cv_pixelout[2]),
		.operation(cv_op[2]),
		.width(cv_width[2]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv3 (
		.pixel_in(cv_pixelin[3]),
		.w9(cv_w[3][9]), .w8(cv_w[3][8]), .w7(cv_w[3][7]), 
		.w6(cv_w[3][6]), .w5(cv_w[3][5]), .w4(cv_w[3][4]), 
		.w3(cv_w[3][3]), .w2(cv_w[3][2]), .w1(cv_w[3][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[3]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[3]),
		.pixel_out(cv_pixelout[3]),
		.operation(cv_op[3]),
		.width(cv_width[3]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv4 (
		.pixel_in(cv_pixelin[4]),
		.w9(cv_w[4][9]), .w8(cv_w[4][8]), .w7(cv_w[4][7]), 
		.w6(cv_w[4][6]), .w5(cv_w[4][5]), .w4(cv_w[4][4]), 
		.w3(cv_w[4][3]), .w2(cv_w[4][2]), .w1(cv_w[4][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[4]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[4]),
		.pixel_out(cv_pixelout[4]),
		.operation(cv_op[4]),
		.width(cv_width[4]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv5 (
		.pixel_in(cv_pixelin[5]),
		.w9(cv_w[5][9]), .w8(cv_w[5][8]), .w7(cv_w[5][7]), 
		.w6(cv_w[5][6]), .w5(cv_w[5][5]), .w4(cv_w[5][4]), 
		.w3(cv_w[5][3]), .w2(cv_w[5][2]), .w1(cv_w[5][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[5]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[5]),
		.pixel_out(cv_pixelout[5]),
		.operation(cv_op[5]),
		.width(cv_width[5]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv6 (
		.pixel_in(cv_pixelin[6]),
		.w9(cv_w[6][9]), .w8(cv_w[6][8]), .w7(cv_w[6][7]), 
		.w6(cv_w[6][6]), .w5(cv_w[6][5]), .w4(cv_w[6][4]), 
		.w3(cv_w[6][3]), .w2(cv_w[6][2]), .w1(cv_w[6][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[6]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[6]),
		.bias(cv_bias[6]),
		.operation(cv_op[6]),
		.width(cv_width[6]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv7 (
		.pixel_in(cv_pixelin[7]),
		.w9(cv_w[7][9]), .w8(cv_w[7][8]), .w7(cv_w[7][7]), 
		.w6(cv_w[7][6]), .w5(cv_w[7][5]), .w4(cv_w[7][4]), 
		.w3(cv_w[7][3]), .w2(cv_w[7][2]), .w1(cv_w[7][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[7]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[7]),
		.bias(cv_bias[7]),
		.operation(cv_op[7]),
		.width(cv_width[7]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv8 (
		.pixel_in(cv_pixelin[8]),
		.w9(cv_w[8][9]), .w8(cv_w[8][8]), .w7(cv_w[8][7]), 
		.w6(cv_w[8][6]), .w5(cv_w[8][5]), .w4(cv_w[8][4]), 
		.w3(cv_w[8][3]), .w2(cv_w[8][2]), .w1(cv_w[8][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[8]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[8]),
		.bias(cv_bias[8]),
		.operation(cv_op[8]),
		.width(cv_width[8]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv9 (
		.pixel_in(cv_pixelin[9]),
		.w9(cv_w[9][9]), .w8(cv_w[9][8]), .w7(cv_w[9][7]), 
		.w6(cv_w[9][6]), .w5(cv_w[9][5]), .w4(cv_w[9][4]), 
		.w3(cv_w[9][3]), .w2(cv_w[9][2]), .w1(cv_w[9][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[9]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[9]),
		.bias(cv_bias[9]),
		.operation(cv_op[9]),
		.width(cv_width[9]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv10 (
		.pixel_in(cv_pixelin[10]),
		.w9(cv_w[10][9]), .w8(cv_w[10][8]), .w7(cv_w[10][7]), 
		.w6(cv_w[10][6]), .w5(cv_w[10][5]), .w4(cv_w[10][4]), 
		.w3(cv_w[10][3]), .w2(cv_w[10][2]), .w1(cv_w[10][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[10]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[10]),
		.bias(cv_bias[10]),
		.operation(cv_op[10]),
		.width(cv_width[10]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv11 (
		.pixel_in(cv_pixelin[11]),
		.w9(cv_w[11][9]), .w8(cv_w[11][8]), .w7(cv_w[11][7]), 
		.w6(cv_w[11][6]), .w5(cv_w[11][5]), .w4(cv_w[11][4]), 
		.w3(cv_w[11][3]), .w2(cv_w[11][2]), .w1(cv_w[11][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[11]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[11]),
		.pixel_out(cv_pixelout[11]),
		.operation(cv_op[11]),
		.width(cv_width[11]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv12 (
		.pixel_in(cv_pixelin[12]),
		.w9(cv_w[12][9]), .w8(cv_w[12][8]), .w7(cv_w[12][7]), 
		.w6(cv_w[12][6]), .w5(cv_w[12][5]), .w4(cv_w[12][4]), 
		.w3(cv_w[12][3]), .w2(cv_w[12][2]), .w1(cv_w[12][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[12]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[12]),
		.pixel_out(cv_pixelout[12]),
		.operation(cv_op[12]),
		.width(cv_width[12]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv13 (
		.pixel_in(cv_pixelin[13]),
		.w9(cv_w[13][9]), .w8(cv_w[13][8]), .w7(cv_w[13][7]), 
		.w6(cv_w[13][6]), .w5(cv_w[13][5]), .w4(cv_w[13][4]), 
		.w3(cv_w[13][3]), .w2(cv_w[13][2]), .w1(cv_w[13][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[13]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[13]),
		.pixel_out(cv_pixelout[13]),
		.operation(cv_op[13]),
		.width(cv_width[13]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv14 (
		.pixel_in(cv_pixelin[14]),
		.w9(cv_w[14][9]), .w8(cv_w[14][8]), .w7(cv_w[14][7]), 
		.w6(cv_w[14][6]), .w5(cv_w[14][5]), .w4(cv_w[14][4]), 
		.w3(cv_w[14][3]), .w2(cv_w[14][2]), .w1(cv_w[14][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[14]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[14]),
		.pixel_out(cv_pixelout[14]),
		.operation(cv_op[14]),
		.width(cv_width[14]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv15 (
		.pixel_in(cv_pixelin[15]),
		.w9(cv_w[15][9]), .w8(cv_w[15][8]), .w7(cv_w[15][7]), 
		.w6(cv_w[15][6]), .w5(cv_w[15][5]), .w4(cv_w[15][4]), 
		.w3(cv_w[15][3]), .w2(cv_w[15][2]), .w1(cv_w[15][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[15]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[15]),
		.pixel_out(cv_pixelout[15]),
		.operation(cv_op[15]),
		.width(cv_width[15]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv16 (
		.pixel_in(cv_pixelin[16]),
		.w9(cv_w[16][9]), .w8(cv_w[16][8]), .w7(cv_w[16][7]), 
		.w6(cv_w[16][6]), .w5(cv_w[16][5]), .w4(cv_w[16][4]), 
		.w3(cv_w[16][3]), .w2(cv_w[16][2]), .w1(cv_w[16][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[16]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[16]),
		.pixel_out(cv_pixelout[16]),
		.operation(cv_op[16]),
		.width(cv_width[16]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv17 (
		.pixel_in(cv_pixelin[17]),
		.w9(cv_w[17][9]), .w8(cv_w[17][8]), .w7(cv_w[17][7]), 
		.w6(cv_w[17][6]), .w5(cv_w[17][5]), .w4(cv_w[17][4]), 
		.w3(cv_w[17][3]), .w2(cv_w[17][2]), .w1(cv_w[17][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[17]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[17]),
		.pixel_out(cv_pixelout[17]),
		.operation(cv_op[17]),
		.width(cv_width[17]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv18 (
		.pixel_in(cv_pixelin[18]),
		.w9(cv_w[18][9]), .w8(cv_w[18][8]), .w7(cv_w[18][7]), 
		.w6(cv_w[18][6]), .w5(cv_w[18][5]), .w4(cv_w[18][4]), 
		.w3(cv_w[18][3]), .w2(cv_w[18][2]), .w1(cv_w[18][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[18]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[18]),
		.pixel_out(cv_pixelout[18]),
		.operation(cv_op[18]),
		.width(cv_width[18]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv19 (
		.pixel_in(cv_pixelin[19]),
		.w9(cv_w[19][9]), .w8(cv_w[19][8]), .w7(cv_w[19][7]), 
		.w6(cv_w[19][6]), .w5(cv_w[19][5]), .w4(cv_w[19][4]), 
		.w3(cv_w[19][3]), .w2(cv_w[19][2]), .w1(cv_w[19][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[19]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[19]),
		.pixel_out(cv_pixelout[19]),
		.operation(cv_op[19]),
		.width(cv_width[19]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv20 (
		.pixel_in(cv_pixelin[20]),
		.w9(cv_w[20][9]), .w8(cv_w[20][8]), .w7(cv_w[20][7]), 
		.w6(cv_w[20][6]), .w5(cv_w[20][5]), .w4(cv_w[20][4]), 
		.w3(cv_w[20][3]), .w2(cv_w[20][2]), .w1(cv_w[20][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[20]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[20]),
		.pixel_out(cv_pixelout[20]),
		.operation(cv_op[20]),
		.width(cv_width[20]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv21 (
		.pixel_in(cv_pixelin[21]),
		.w9(cv_w[21][9]), .w8(cv_w[21][8]), .w7(cv_w[21][7]), 
		.w6(cv_w[21][6]), .w5(cv_w[21][5]), .w4(cv_w[21][4]), 
		.w3(cv_w[21][3]), .w2(cv_w[21][2]), .w1(cv_w[21][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[21]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[21]),
		.pixel_out(cv_pixelout[21]),
		.operation(cv_op[21]),
		.width(cv_width[21]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv22 (
		.pixel_in(cv_pixelin[22]),
		.w9(cv_w[22][9]), .w8(cv_w[22][8]), .w7(cv_w[22][7]), 
		.w6(cv_w[22][6]), .w5(cv_w[22][5]), .w4(cv_w[22][4]), 
		.w3(cv_w[22][3]), .w2(cv_w[22][2]), .w1(cv_w[22][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[22]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[22]),
		.pixel_out(cv_pixelout[22]),
		.operation(cv_op[22]),
		.width(cv_width[22]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv23 (
		.pixel_in(cv_pixelin[23]),
		.w9(cv_w[23][9]), .w8(cv_w[23][8]), .w7(cv_w[23][7]), 
		.w6(cv_w[23][6]), .w5(cv_w[23][5]), .w4(cv_w[23][4]), 
		.w3(cv_w[23][3]), .w2(cv_w[23][2]), .w1(cv_w[23][1]),
		.clk(clk), 
		.rst_n(rst_n || cv_rst[23]),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[23]),
		.pixel_out(cv_pixelout[23]),
		.operation(cv_op[23]),
		.width(cv_width[23]),
		.relu(relu)
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv24 (
    .pixel_in(cv_pixelin[24]),
    .w9(cv_w[24][9]), .w8(cv_w[24][8]), .w7(cv_w[24][7]), 
		.w6(cv_w[24][6]), .w5(cv_w[24][5]), .w4(cv_w[24][4]), 
		.w3(cv_w[24][3]), .w2(cv_w[24][2]), .w1(cv_w[24][1]),
    .clk(clk), 
    .rst_n(rst_n || cv_rst[24]),
	 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[24]),
    .pixel_out(cv_pixelout[24]),
    .operation(cv_op[24]),
		.width(cv_width[24]),
		.relu(relu)
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv25 (
		 .pixel_in(cv_pixelin[25]),
		 .w9(cv_w[25][9]), .w8(cv_w[25][8]), .w7(cv_w[25][7]), 
		.w6(cv_w[25][6]), .w5(cv_w[25][5]), .w4(cv_w[25][4]), 
		.w3(cv_w[25][3]), .w2(cv_w[25][2]), .w1(cv_w[25][1]),
		 .clk(clk), 
		 .rst_n(rst_n || cv_rst[25]),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[25]),
		 .pixel_out(cv_pixelout[25]),
		 .operation(cv_op[25]),
		.width(cv_width[25]),
		.relu(relu)
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv26 (
		 .pixel_in(cv_pixelin[26]),
		 .w9(cv_w[26][9]), .w8(cv_w[26][8]), .w7(cv_w[26][7]), 
		.w6(cv_w[26][6]), .w5(cv_w[26][5]), .w4(cv_w[26][4]), 
		.w3(cv_w[26][3]), .w2(cv_w[26][2]), .w1(cv_w[26][1]),
		 .clk(clk), 
		 .rst_n(rst_n || cv_rst[26]),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[26]),
		 .pixel_out(cv_pixelout[26]),
		 .operation(cv_op[26]),
		.width(cv_width[26]),
		.relu(relu)
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv27 (
		 .pixel_in(cv_pixelin[27]),
		 .w9(cv_w[27][9]), .w8(cv_w[27][8]), .w7(cv_w[27][7]), 
		.w6(cv_w[27][6]), .w5(cv_w[27][5]), .w4(cv_w[27][4]), 
		.w3(cv_w[27][3]), .w2(cv_w[27][2]), .w1(cv_w[27][1]),
		 .clk(clk), 
		 .rst_n(rst_n || cv_rst[27]),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[27]),
		 .pixel_out(cv_pixelout[27]),
		 .operation(cv_op[27]),
		.width(cv_width[27]),
		.relu(relu)
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv28 (
		 .pixel_in(cv_pixelin[28]),
		 .w9(cv_w[28][9]), .w8(cv_w[28][8]), .w7(cv_w[28][7]), 
		.w6(cv_w[28][6]), .w5(cv_w[28][5]), .w4(cv_w[28][4]), 
		.w3(cv_w[28][3]), .w2(cv_w[28][2]), .w1(cv_w[28][1]),
		 .clk(clk), 
		 .rst_n(rst_n || cv_rst[28]),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[28]),
		 .pixel_out(cv_pixelout[28]),
		 .operation(cv_op[28]),
		.width(cv_width[28]),
		.relu(relu)
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv29 (
		 .pixel_in(cv_pixelin[29]),
		 .w9(cv_w[29][9]), .w8(cv_w[29][8]), .w7(cv_w[29][7]), 
		.w6(cv_w[29][6]), .w5(cv_w[29][5]), .w4(cv_w[29][4]), 
		.w3(cv_w[29][3]), .w2(cv_w[29][2]), .w1(cv_w[29][1]),
		 .clk(clk), 
		 .rst_n(rst_n || cv_rst[29]),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[29]),
		 .pixel_out(cv_pixelout[29]),
		 .operation(cv_op[29]),
		.width(cv_width[29]),
		.relu(relu)
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv30 (
		 .pixel_in(cv_pixelin[30]),
		 .w9(cv_w[30][9]), .w8(cv_w[30][8]), .w7(cv_w[30][7]), 
		.w6(cv_w[30][6]), .w5(cv_w[30][5]), .w4(cv_w[30][4]), 
		.w3(cv_w[30][3]), .w2(cv_w[30][2]), .w1(cv_w[30][1]),
		 .clk(clk), 
		 .rst_n(rst_n || cv_rst[30]),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.bias(cv_bias[30]),
		 .pixel_out(cv_pixelout[30]),
		 .operation(cv_op[30]),
		.width(cv_width[30]),
		.relu(relu)
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv31 (
		 .pixel_in(cv_pixelin[31]),
		 .w9(cv_w[31][9]), .w8(cv_w[31][8]), .w7(cv_w[31][7]), 
		 .w6(cv_w[31][6]), .w5(cv_w[31][5]), .w4(cv_w[31][4]), 
		 .w3(cv_w[31][3]), .w2(cv_w[31][2]), .w1(cv_w[31][1]),
		 .clk(clk), 
		 .bias(cv_bias[31]),
		 .rst_n(rst_n || cv_rst[31]),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[31]),
		 .operation(cv_op[31]),
		.width(cv_width[31]),
		.relu(relu)
	);
	
	
	/*********************************************************************************
	 * Set of quantizers
	 */
	 
	reg [31:0] qt0_in, qt1_in, qt2_in, qt3_in, qt4_in, qt5_in, qt6_in, qt7_in;
	reg [7:0]  qt_zp [0:7]; 
	reg [15:0] qt_scale [0:7];
	
	wire [7:0] qt0_res, qt1_res, qt2_res, qt3_res, qt4_res, qt5_res, qt6_res, qt7_res;

	// Quantizers
	quant qt0(.in(qt0_in), .zeropoint(qt_zp[0]), .scaler_scaled16(qt_scale[0]), .result(qt0_res));
	quant qt1(.in(qt1_in), .zeropoint(qt_zp[1]), .scaler_scaled16(qt_scale[1]), .result(qt1_res));
	quant qt2(.in(qt2_in), .zeropoint(qt_zp[2]), .scaler_scaled16(qt_scale[2]), .result(qt2_res));
	quant qt3(.in(qt3_in), .zeropoint(qt_zp[3]), .scaler_scaled16(qt_scale[3]), .result(qt3_res));
	quant qt4(.in(qt4_in), .zeropoint(qt_zp[4]), .scaler_scaled16(qt_scale[4]), .result(qt4_res));
	quant qt5(.in(qt5_in), .zeropoint(qt_zp[5]), .scaler_scaled16(qt_scale[5]), .result(qt5_res));
	quant qt6(.in(qt6_in), .zeropoint(qt_zp[6]), .scaler_scaled16(qt_scale[6]), .result(qt6_res));
	quant qt7(.in(qt7_in), .zeropoint(qt_zp[7]), .scaler_scaled16(qt_scale[7]), .result(qt7_res));
	
		
	
	/*********************************************************************************
	 * Stages of the UNET, doing the operations...
	 */
	 
	reg [31:0] pixelcount, layercount, inlayercount, writepixel, row, savebuffer;
	
	// inter-stage memory
	reg [31:0] intermediate [0:31];
	
	// intra-stage memory
	reg [31:0] layerint_buf0_st1 [0:4095];
	reg [31:0] layerint_buf1_st1 [0:4095];
	reg [31:0] layerint_buf2_st1 [0:4095];
	reg [31:0] layerint_buf3_st1 [0:4095];
	reg [31:0] layerint_buf4_st1 [0:4095];
	reg [31:0] layerint_buf5_st1 [0:4095];
	reg [31:0] layerint_buf6_st1 [0:4095];
	reg [31:0] layerint_buf7_st1 [0:4095];
	
	reg [31:0] layerint_buf0_st2 [0:4095];
	reg [31:0] layerint_buf1_st2 [0:4095];
	reg [31:0] layerint_buf2_st2 [0:4095];
	reg [31:0] layerint_buf3_st2 [0:4095];
	reg [31:0] layerint_buf4_st2 [0:4095];
	reg [31:0] layerint_buf5_st2 [0:4095];
	reg [31:0] layerint_buf6_st2 [0:4095];
	reg [31:0] layerint_buf7_st2 [0:4095];
	
	reg [31:0] layerint_buf0_st3 [0:1023];
	reg [31:0] layerint_buf1_st3 [0:1023];
	reg [31:0] layerint_buf2_st3 [0:1023];
	reg [31:0] layerint_buf3_st3 [0:1023];
	reg [31:0] layerint_buf4_st3 [0:1023];
	reg [31:0] layerint_buf5_st3 [0:1023];
	reg [31:0] layerint_buf6_st3 [0:1023];
	reg [31:0] layerint_buf7_st3 [0:1023];
	
	reg [31:0] layerint_buf0_st4 [0:255];
	reg [31:0] layerint_buf1_st4 [0:255];
	reg [31:0] layerint_buf2_st4 [0:255];
	reg [31:0] layerint_buf3_st4 [0:255];
	reg [31:0] layerint_buf4_st4 [0:255];
	reg [31:0] layerint_buf5_st4 [0:255];
	reg [31:0] layerint_buf6_st4 [0:255];
	reg [31:0] layerint_buf7_st4 [0:255];
	reg [31:0] layerint_buf8_st4 [0:255];
	reg [31:0] layerint_buf9_st4 [0:255];
	reg [31:0] layerint_buf10_st4 [0:255];
	reg [31:0] layerint_buf11_st4 [0:255];
	reg [31:0] layerint_buf12_st4 [0:255];
	reg [31:0] layerint_buf13_st4 [0:255];
	reg [31:0] layerint_buf14_st4 [0:255];
	reg [31:0] layerint_buf15_st4 [0:255];
	
	reg [31:0] layerint_buf0_st5 [0:63];
	reg [31:0] layerint_buf1_st5 [0:63];
	reg [31:0] layerint_buf2_st5 [0:63];
	reg [31:0] layerint_buf3_st5 [0:63];
	reg [31:0] layerint_buf4_st5 [0:63];
	reg [31:0] layerint_buf5_st5 [0:63];
	reg [31:0] layerint_buf6_st5 [0:63];
	reg [31:0] layerint_buf7_st5 [0:63];
	reg [31:0] layerint_buf8_st5 [0:63];
	reg [31:0] layerint_buf9_st5 [0:63];
	reg [31:0] layerint_buf10_st5 [0:63];
	reg [31:0] layerint_buf11_st5 [0:63];
	reg [31:0] layerint_buf12_st5 [0:63];
	reg [31:0] layerint_buf13_st5 [0:63];
	reg [31:0] layerint_buf14_st5 [0:63];
	reg [31:0] layerint_buf15_st5 [0:63];
	
	reg [31:0] layerint_buf16_st5 [0:15];
	reg [31:0] layerint_buf17_st5 [0:15];
	reg [31:0] layerint_buf18_st5 [0:15];
	reg [31:0] layerint_buf19_st5 [0:15];
	reg [31:0] layerint_buf20_st5 [0:15];
	reg [31:0] layerint_buf21_st5 [0:15];
	reg [31:0] layerint_buf22_st5 [0:15];
	reg [31:0] layerint_buf23_st5 [0:15];
	reg [31:0] layerint_buf24_st5 [0:15];
	reg [31:0] layerint_buf25_st5 [0:15];
	reg [31:0] layerint_buf26_st5 [0:15];
	reg [31:0] layerint_buf27_st5 [0:15];
	reg [31:0] layerint_buf28_st5 [0:15];
	reg [31:0] layerint_buf29_st5 [0:15];
	reg [31:0] layerint_buf30_st5 [0:15];
	reg [31:0] layerint_buf31_st5 [0:15];	
	
	/*********************************************************************************
	 * Weight buffers
	 */
	 
	reg [31:0] cv00_wb_0_buf   [0:1034];	//  1: {cv0_w4, cv0_w3, cv0_w2, cv0_w1} -----
	reg [31:0] cv00_wb_1_buf   [0:1034];   //  2: {cv0_w8, cv0_w7, cv0_w6, cv0_w5}
	reg [31:0] cv0001_wb_2_buf [0:1034];	//  3: {cv1_w3, cv1_w2, cv1_w1, cv0_w9}
	reg [31:0] cv01_wb_0_buf   [0:1034];   //  4: {cv1_w7, cv1_w6, cv1_w5, cv1_w4}
	reg [31:0] cv0102_wb_1_buf [0:1034];   //  5: {cv2_w2, cv2_w1, cv1_w9, cv1_w8}
	reg [31:0] cv02_wb_0_buf   [0:1034];   //  6: {cv2_w6, cv2_w5, cv2_w4, cv2_w3}
	reg [31:0] cv0203_wb_0_buf [0:1034];   //  7: {cv3_w1, cv2_w9, cv2_w8, cv2_w7}
	reg [31:0] cv03_wb_0_buf   [0:1034];	//  8: {cv3_w5, cv3_w4, cv3_w3, cv3_w2}
	reg [31:0] cv03_wb_1_buf   [0:1034];   //  9: {cv3_w9, cv3_w8, cv3_w7, cv3_w6}
	reg [31:0] cv04_wb_0_buf   [0:1034];	// 10: {cv4_w4, cv4_w3, cv4_w2, cv4_w1} -----
	reg [31:0] cv04_wb_1_buf   [0:1034];   // 11: {cv4_w8, cv4_w7, cv4_w6, cv4_w5}
	reg [31:0] cv0405_wb_2_buf [0:1034];	// 12: {cv5_w3, cv5_w2, cv5_w1, cv4_w9}
	reg [31:0] cv05_wb_0_buf   [0:1034];   // 13: {cv5_w7, cv5_w6, cv5_w5, cv5_w4}
	reg [31:0] cv0506_wb_1_buf [0:1034];   // 14: {cv6_w2, cv6_w1, cv5_w9, cv5_w8}
	reg [31:0] cv06_wb_0_buf   [0:1034];   // 15: {cv6_w6, cv6_w5, cv6_w4, cv6_w3}
	reg [31:0] cv0607_wb_0_buf [0:1034];   // 16: {cv7_w1, cv6_w9, cv6_w8, cv6_w7}
	reg [31:0] cv07_wb_0_buf   [0:1034];	// 17: {cv7_w5, cv7_w4, cv7_w3, cv7_w2}
	reg [31:0] cv07_wb_1_buf   [0:1034];   // 18: {cv7_w9, cv7_w8, cv7_w7, cv7_w6}
	reg [31:0] cv08_wb_0_buf   [0:1034];	// 19: {cv8_w4, cv8_w3, cv8_w2, cv8_w1} -----
	reg [31:0] cv08_wb_1_buf   [0:1034];   // 20: {cv8_w8, cv8_w7, cv8_w6, cv8_w5}
	reg [31:0] cv0809_wb_2_buf [0:1034];	// 21: {cv1_w3, cv1_w2, cv1_w1, cv8_w9}
	reg [31:0] cv09_wb_0_buf   [0:1034];   // 22: {cv9_w7, cv9_w6, cv9_w5, cv9_w4}
	reg [31:0] cv0910_wb_1_buf [0:1034];   // 23: {cv10_w2, cv10_w1, cv9_w9, cv9_w8}
	reg [31:0] cv10_wb_0_buf   [0:1034];   // 24: {cv10_w6, cv10_w5, cv10_w4, cv10_w3}
	reg [31:0] cv1011_wb_0_buf [0:1034];   // 25: {cv11_w1, cv10_w9, cv10_w8, cv10_w7}
	reg [31:0] cv11_wb_0_buf   [0:1034];	// 26: {cv11_w5, cv11_w4, cv11_w3, cv11_w2}
	reg [31:0] cv11_wb_1_buf   [0:1034];   // 27: {cv11_w9, cv11_w8, cv11_w7, cv11_w6}
	reg [31:0] cv12_wb_0_buf   [0:1034];	// 28: {cv12_w4, cv12_w3, cv12_w2, cv12_w1} -----
	reg [31:0] cv12_wb_1_buf   [0:1034];   // 29: {cv12_w8, cv12_w7, cv12_w6, cv12_w5}
	reg [31:0] cv1213_wb_2_buf [0:1034];   // 30: {cv13_w3, cv13_w2, cv13_w1, cv12_w9}
	reg [31:0] cv13_wb_0_buf   [0:1034];   // 31: {cv13_w7, cv13_w6, cv13_w5, cv13_w4}
	reg [31:0] cv1314_wb_1_buf [0:1034];   // 32: {cv14_w2, cv14_w1, cv13_w9, cv13_w8}
	reg [31:0] cv14_wb_0_buf   [0:1034];   // 33: {cv14_w6, cv14_w5, cv14_w4, cv14_w3}
	reg [31:0] cv1415_wb_0_buf [0:1034];   // 34: {cv15_w1, cv14_w9, cv14_w8, cv14_w7}
	reg [31:0] cv15_wb_0_buf   [0:1034];	// 35: {cv15_w5, cv15_w4, cv15_w3, cv15_w2}
	reg [31:0] cv15_wb_1_buf   [0:1034];   // 36: {cv15_w9, cv15_w8, cv15_w7, cv15_w6}
	reg [31:0] cv16_wb_0_buf   [0:1034];	// 37: {cv16_w4, cv16_w3, cv16_w2, cv16_w1} -----
	reg [31:0] cv16_wb_1_buf   [0:1034];   // 38: {cv16_w8, cv16_w7, cv16_w6, cv16_w5}
	reg [31:0] cv1617_wb_2_buf [0:1034];   // 39: {cv17_w3, cv17_w2, cv17_w1, cv16_w9}
	reg [31:0] cv17_wb_0_buf   [0:1034];   // 40: {cv17_w7, cv17_w6, cv17_w5, cv17_w4}
	reg [31:0] cv1718_wb_1_buf [0:1034];   // 41: {cv18_w2, cv18_w1, cv17_w9, cv17_w8}
	reg [31:0] cv18_wb_0_buf   [0:1034];   // 42: {cv18_w6, cv18_w5, cv18_w4, cv18_w3}
	reg [31:0] cv1819_wb_0_buf [0:1034];   // 43: {cv19_w1, cv18_w9, cv18_w8, cv18_w7}
	reg [31:0] cv19_wb_0_buf   [0:1034];	// 44: {cv19_w5, cv19_w4, cv19_w3, cv19_w2}
	reg [31:0] cv19_wb_1_buf   [0:1034];   // 45: {cv19_w9, cv19_w8, cv19_w7, cv19_w6}
	reg [31:0] cv20_wb_0_buf   [0:1034];	// 46: {cv20_w4, cv20_w3, cv20_w2, cv20_w1} -----
	reg [31:0] cv20_wb_1_buf   [0:1034];   // 47: {cv20_w8, cv20_w7, cv20_w6, cv20_w5}
	reg [31:0] cv2021_wb_2_buf [0:1034];   // 48: {cv21_w3, cv21_w2, cv21_w1, cv20_w9}
	reg [31:0] cv21_wb_0_buf   [0:1034];   // 49: {cv21_w7, cv21_w6, cv21_w5, cv21_w4}
	reg [31:0] cv2122_wb_1_buf [0:1034];   // 50: {cv22_w2, cv22_w1, cv21_w9, cv21_w8}
	reg [31:0] cv22_wb_0_buf   [0:1034];   // 51: {cv22_w6, cv22_w5, cv22_w4, cv22_w3}
	reg [31:0] cv2223_wb_0_buf [0:1034];   // 52: {cv23_w1, cv22_w9, cv22_w8, cv22_w7}
	reg [31:0] cv23_wb_0_buf   [0:1034];	// 53: {cv23_w5, cv23_w4, cv23_w3, cv23_w2}
	reg [31:0] cv23_wb_1_buf   [0:1034];   // 54: {cv23_w9, cv23_w8, cv23_w7, cv23_w6}
	reg [31:0] cv24_wb_0_buf   [0:1034];	// 55: {cv24_w4, cv24_w3, cv24_w2, cv24_w1} -----
	reg [31:0] cv24_wb_1_buf   [0:1034];   // 56: {cv24_w8, cv24_w7, cv24_w6, cv24_w5}
	reg [31:0] cv2425_wb_2_buf [0:1034];   // 57: {cv25_w3, cv25_w2, cv25_w1, cv24_w9}
	reg [31:0] cv25_wb_0_buf   [0:1034];   // 58: {cv25_w7, cv25_w6, cv25_w5, cv25_w4}
	reg [31:0] cv2526_wb_1_buf [0:1034];   // 59: {cv26_w2, cv26_w1, cv25_w9, cv25_w8}
	reg [31:0] cv26_wb_0_buf   [0:1034];   // 60: {cv26_w6, cv26_w5, cv26_w4, cv26_w3}
	reg [31:0] cv2627_wb_0_buf [0:1034];   // 61: {cv27_w1, cv26_w9, cv26_w8, cv26_w7}
	reg [31:0] cv27_wb_0_buf   [0:1034];	// 62: {cv27_w5, cv27_w4, cv27_w3, cv27_w2}
	reg [31:0] cv27_wb_1_buf   [0:1034];   // 63: {cv27_w9, cv27_w8, cv27_w7, cv27_w6}
	reg [31:0] cv28_wb_0_buf   [0:1034];	// 64: {cv28_w4, cv28_w3, cv28_w2, cv28_w1} -----
	reg [31:0] cv28_wb_1_buf   [0:1034];   // 65: {cv28_w8, cv28_w7, cv28_w6, cv28_w5}
	reg [31:0] cv2829_wb_2_buf [0:1034];   // 66: {cv29_w3, cv29_w2, cv29_w1, cv28_w9}
	reg [31:0] cv29_wb_0_buf   [0:1034];   // 67: {cv29_w7, cv29_w6, cv29_w5, cv29_w4}
	reg [31:0] cv2930_wb_1_buf [0:1034];   // 68: {cv30_w2, cv30_w1, cv29_w9, cv29_w8}
	reg [31:0] cv30_wb_0_buf   [0:1034];   // 69: {cv30_w6, cv30_w5, cv30_w4, cv30_w3}
	reg [31:0] cv3031_wb_0_buf [0:1034];   // 70: {cv31_w1, cv30_w9, cv30_w8, cv30_w7}
	reg [31:0] cv31_wb_0_buf   [0:1034];	// 71: {cv31_w5, cv31_w4, cv31_w3, cv31_w2}
	reg [31:0] cv31_wb_1_buf   [0:1034];   // 72: {cv31_w9, cv31_w8, cv31_w7, cv31_w6}
	
	reg [31:0] cv0_bias_buf [0:1034];	
	reg [31:0] cv1_bias_buf [0:1034];	
	reg [31:0] cv2_bias_buf [0:1034];	
	reg [31:0] cv3_bias_buf [0:1034];	
	reg [31:0] cv4_bias_buf [0:1034];	
	reg [31:0] cv5_bias_buf [0:1034];	
	reg [31:0] cv6_bias_buf [0:1034];	
	reg [31:0] cv7_bias_buf [0:1034];	
	reg [31:0] cv8_bias_buf [0:1034];	
	reg [31:0] cv9_bias_buf [0:1034];
	reg [31:0] cv10_bias_buf [0:1034];	
	reg [31:0] cv11_bias_buf [0:1034];	
	reg [31:0] cv12_bias_buf [0:1034];	
	reg [31:0] cv13_bias_buf [0:1034];	
	reg [31:0] cv14_bias_buf [0:1034];	
	reg [31:0] cv15_bias_buf [0:1034];	
	reg [31:0] cv16_bias_buf [0:1034];	
	reg [31:0] cv17_bias_buf [0:1034];	
	reg [31:0] cv18_bias_buf [0:1034];	
	reg [31:0] cv19_bias_buf [0:1034];
	reg [31:0] cv20_bias_buf [0:1034];	
	reg [31:0] cv21_bias_buf [0:1034];	
	reg [31:0] cv22_bias_buf [0:1034];	
	reg [31:0] cv23_bias_buf [0:1034];	
	reg [31:0] cv24_bias_buf [0:1034];	
	reg [31:0] cv25_bias_buf [0:1034];	
	reg [31:0] cv26_bias_buf [0:1034];	
	reg [31:0] cv27_bias_buf [0:1034];	
	reg [31:0] cv28_bias_buf [0:1034];	
	reg [31:0] cv29_bias_buf [0:1034];
	reg [31:0] cv30_bias_buf [0:1034];	
	reg [31:0] cv31_bias_buf [0:1034];	
	
	reg [31:0] qt_buf [0:1034];
	
	
	/*********************************************************************************
	 * Macros for loading weights
	 */				
	
	
	`define load_weight(src) \
		cv_w[0][1] <= cv00_wb_0_buf[src][7:0];   \
		cv_w[0][2] <= cv00_wb_0_buf[src][15:8];  \
		cv_w[0][3] <= cv00_wb_0_buf[src][23:16]; \
		cv_w[0][4] <= cv00_wb_0_buf[src][31:24]; \
		cv_w[0][5] <= cv00_wb_1_buf[src][7:0];   \
		cv_w[0][6] <= cv00_wb_1_buf[src][15:8];  \
		cv_w[0][7] <= cv00_wb_1_buf[src][23:16]; \
		cv_w[0][8] <= cv00_wb_1_buf[src][31:24]; \
		cv_w[0][9] <= cv0001_wb_2_buf[src][7:0];  \
		cv_w[1][1] <= cv0001_wb_2_buf[src][15:8]; \
		cv_w[1][2] <= cv0001_wb_2_buf[src][23:16];\
		cv_w[1][3] <= cv0001_wb_2_buf[src][31:24];\
		cv_w[1][4] <= cv01_wb_0_buf[src][7:0];   \
		cv_w[1][5] <= cv01_wb_0_buf[src][15:8];  \
		cv_w[1][6] <= cv01_wb_0_buf[src][23:16]; \
		cv_w[1][7] <= cv01_wb_0_buf[src][31:24]; \
		cv_w[1][8] <= cv0102_wb_1_buf[src][7:0];  \
		cv_w[1][9] <= cv0102_wb_1_buf[src][15:8]; \
		cv_w[2][1] <= cv0102_wb_1_buf[src][23:16];\
		cv_w[2][2] <= cv0102_wb_1_buf[src][31:24];\
		cv_w[2][3] <= cv02_wb_0_buf[src][7:0];   \
		cv_w[2][4] <= cv02_wb_0_buf[src][15:8];  \
		cv_w[2][5] <= cv02_wb_0_buf[src][23:16]; \
		cv_w[2][6] <= cv02_wb_0_buf[src][31:24]; \
		cv_w[2][7] <= cv0203_wb_0_buf[src][7:0];  \
		cv_w[2][8] <= cv0203_wb_0_buf[src][15:8]; \
		cv_w[2][9] <= cv0203_wb_0_buf[src][23:16];\
		cv_w[3][1] <= cv0203_wb_0_buf[src][31:24];\
		cv_w[3][2] <= cv03_wb_0_buf[src][7:0];   \
		cv_w[3][3] <= cv03_wb_0_buf[src][15:8];  \
		cv_w[3][4] <= cv03_wb_0_buf[src][23:16]; \
		cv_w[3][5] <= cv03_wb_0_buf[src][31:24]; \
		cv_w[3][6] <= cv03_wb_1_buf[src][7:0];   \
		cv_w[3][7] <= cv03_wb_1_buf[src][15:8];  \
		cv_w[3][8] <= cv03_wb_1_buf[src][23:16]; \
		cv_w[3][9] <= cv03_wb_1_buf[src][31:24]; \
		cv_w[4][1] <= cv04_wb_0_buf[src][7:0];   \
		cv_w[4][2] <= cv04_wb_0_buf[src][15:8];  \
		cv_w[4][3] <= cv04_wb_0_buf[src][23:16]; \
		cv_w[4][4] <= cv04_wb_0_buf[src][31:24]; \
		cv_w[4][5] <= cv04_wb_1_buf[src][7:0];   \
		cv_w[4][6] <= cv04_wb_1_buf[src][15:8];  \
		cv_w[4][7] <= cv04_wb_1_buf[src][23:16]; \
		cv_w[4][8] <= cv04_wb_1_buf[src][31:24]; \
		cv_w[4][9] <= cv0405_wb_2_buf[src][7:0];	 \
		cv_w[5][1] <= cv0405_wb_2_buf[src][15:8]; \
		cv_w[5][2] <= cv0405_wb_2_buf[src][23:16];\
		cv_w[5][3] <= cv0405_wb_2_buf[src][31:24];\
		cv_w[5][4] <= cv05_wb_0_buf[src][7:0];   \
		cv_w[5][5] <= cv05_wb_0_buf[src][15:8];  \
		cv_w[5][6] <= cv05_wb_0_buf[src][23:16]; \
		cv_w[5][7] <= cv05_wb_0_buf[src][31:24]; \
		cv_w[5][8] <= cv0506_wb_1_buf[src][7:0];  \
		cv_w[5][9] <= cv0506_wb_1_buf[src][15:8]; \
		cv_w[6][1] <= cv0506_wb_1_buf[src][23:16];\
		cv_w[6][2] <= cv0506_wb_1_buf[src][31:24];\
		cv_w[6][3] <= cv06_wb_0_buf[src][7:0];   \
		cv_w[6][4] <= cv06_wb_0_buf[src][15:8];  \
		cv_w[6][5] <= cv06_wb_0_buf[src][23:16]; \
		cv_w[6][6] <= cv06_wb_0_buf[src][31:24]; \
		cv_w[6][7] <= cv0607_wb_0_buf[src][7:0];  \
		cv_w[6][8] <= cv0607_wb_0_buf[src][15:8]; \
		cv_w[6][9] <= cv0607_wb_0_buf[src][23:16];\
		cv_w[7][1] <= cv0607_wb_0_buf[src][31:24];\
		cv_w[7][2] <= cv07_wb_0_buf[src][7:0];   \
		cv_w[7][3] <= cv07_wb_0_buf[src][15:8];  \
		cv_w[7][4] <= cv07_wb_0_buf[src][23:16]; \
		cv_w[7][5] <= cv07_wb_0_buf[src][31:24]; \
		cv_w[7][6] <= cv07_wb_1_buf[src][7:0];   \
		cv_w[7][7] <= cv07_wb_1_buf[src][15:8];  \
		cv_w[7][8] <= cv07_wb_1_buf[src][23:16]; \
		cv_w[7][9] <= cv07_wb_1_buf[src][31:24]; \
		cv_w[8][1] <= cv08_wb_0_buf[src][7:0];   \
		cv_w[8][2] <= cv08_wb_0_buf[src][15:8];  \
		cv_w[8][3] <= cv08_wb_0_buf[src][23:16]; \
		cv_w[8][4] <= cv08_wb_0_buf[src][31:24]; \
		cv_w[8][5] <= cv08_wb_1_buf[src][7:0];   \
		cv_w[8][6] <= cv08_wb_1_buf[src][15:8];  \
		cv_w[8][7] <= cv08_wb_1_buf[src][23:16]; \
		cv_w[8][8] <= cv08_wb_1_buf[src][31:24]; \
		cv_w[8][9] <= cv0809_wb_2_buf[src][7:0];  \
		cv_w[9][1] <= cv0809_wb_2_buf[src][15:8]; \
		cv_w[9][2] <= cv0809_wb_2_buf[src][23:16];\
		cv_w[9][3] <= cv0809_wb_2_buf[src][31:24];\
		cv_w[9][4] <= cv09_wb_0_buf[src][7:0];   \
		cv_w[9][5] <= cv09_wb_0_buf[src][15:8];  \
		cv_w[9][6] <= cv09_wb_0_buf[src][23:16]; \
		cv_w[9][7] <= cv09_wb_0_buf[src][31:24]; \
		cv_w[9][8] <= cv0910_wb_1_buf[src][7:0]; \
		cv_w[9][9] <= cv0910_wb_1_buf[src][15:8];\
		cv_w[10][1] <= cv0910_wb_1_buf[src][23:16];\
		cv_w[10][2] <= cv0910_wb_1_buf[src][31:24];\
		cv_w[10][3] <= cv10_wb_0_buf[src][7:0];   \
		cv_w[10][4] <= cv10_wb_0_buf[src][15:8];  \
		cv_w[10][5] <= cv10_wb_0_buf[src][23:16]; \
		cv_w[10][6] <= cv10_wb_0_buf[src][31:24]; \
		cv_w[10][7] <= cv1011_wb_0_buf[src][7:0]; \
		cv_w[10][8] <= cv1011_wb_0_buf[src][15:8];\
		cv_w[10][9] <= cv1011_wb_0_buf[src][23:16];\
		cv_w[11][1] <= cv1011_wb_0_buf[src][31:24];\
		cv_w[11][2] <= cv11_wb_0_buf[src][7:0];    \
		cv_w[11][3] <= cv11_wb_0_buf[src][15:8];   \
		cv_w[11][4] <= cv11_wb_0_buf[src][23:16];  \
		cv_w[11][5] <= cv11_wb_0_buf[src][31:24];  \
		cv_w[11][6] <= cv11_wb_1_buf[src][7:0];    \
		cv_w[11][7] <= cv11_wb_1_buf[src][15:8];   \
		cv_w[11][8] <= cv11_wb_1_buf[src][23:16];  \
		cv_w[11][9] <= cv11_wb_1_buf[src][31:24];	 \
		cv_w[12][1] <= cv12_wb_0_buf[src][7:0];  \
		cv_w[12][2] <= cv12_wb_0_buf[src][15:8];  \
		cv_w[12][3] <= cv12_wb_0_buf[src][23:16];  \
		cv_w[12][4] <= cv12_wb_0_buf[src][31:24];  \
		cv_w[12][5] <= cv12_wb_1_buf[src][7:0];  \
		cv_w[12][6] <= cv12_wb_1_buf[src][15:8];  \
		cv_w[12][7] <= cv12_wb_1_buf[src][23:16];  \
		cv_w[12][8] <= cv12_wb_1_buf[src][31:24];  \
		cv_w[12][9] <= cv1213_wb_2_buf[src][7:0];  \
		cv_w[13][1] <= cv1213_wb_2_buf[src][15:8];  \
		cv_w[13][2] <= cv1213_wb_2_buf[src][23:16];  \
		cv_w[13][3] <= cv1213_wb_2_buf[src][31:24];  \
		cv_w[13][4] <= cv13_wb_0_buf[src][7:0];  \
		cv_w[13][5] <= cv13_wb_0_buf[src][15:8];  \
		cv_w[13][6] <= cv13_wb_0_buf[src][23:16];  \
		cv_w[13][7] <= cv13_wb_0_buf[src][31:24];  \
		cv_w[13][8] <= cv1314_wb_1_buf[src][7:0];  \
		cv_w[13][9] <= cv1314_wb_1_buf[src][15:8];  \
		cv_w[14][1] <= cv1314_wb_1_buf[src][23:16];  \
		cv_w[14][2] <= cv1314_wb_1_buf[src][31:24];  \
		cv_w[14][3] <= cv14_wb_0_buf[src][7:0];  \
		cv_w[14][4] <= cv14_wb_0_buf[src][15:8];  \
		cv_w[14][5] <= cv14_wb_0_buf[src][23:16];  \
		cv_w[14][6] <= cv14_wb_0_buf[src][31:24];  \
		cv_w[14][7] <= cv1415_wb_0_buf[src][7:0];  \
		cv_w[14][8] <= cv1415_wb_0_buf[src][15:8];  \
		cv_w[14][9] <= cv1415_wb_0_buf[src][23:16];  \
		cv_w[15][1] <= cv1415_wb_0_buf[src][31:24];  \
		cv_w[15][2] <= cv15_wb_0_buf[src][7:0];  \
		cv_w[15][3] <= cv15_wb_0_buf[src][15:8];  \
		cv_w[15][4] <= cv15_wb_0_buf[src][23:16];  \
		cv_w[15][5] <= cv15_wb_0_buf[src][31:24];  \
		cv_w[15][6] <= cv15_wb_1_buf[src][7:0];  \
		cv_w[15][7] <= cv15_wb_1_buf[src][15:8];  \
		cv_w[15][8] <= cv15_wb_1_buf[src][23:16];  \
		cv_w[15][9] <= cv15_wb_1_buf[src][31:24];  \
		cv_w[16][1] <= cv16_wb_0_buf[src][7:0];  \
		cv_w[16][2] <= cv16_wb_0_buf[src][15:8];  \
		cv_w[16][3] <= cv16_wb_0_buf[src][23:16];  \
		cv_w[16][4] <= cv16_wb_0_buf[src][31:24];  \
		cv_w[16][5] <= cv16_wb_1_buf[src][7:0];  \
		cv_w[16][6] <= cv16_wb_1_buf[src][15:8];  \
		cv_w[16][7] <= cv16_wb_1_buf[src][23:16];  \
		cv_w[16][8] <= cv16_wb_1_buf[src][31:24];  \
		cv_w[16][9] <= cv1617_wb_2_buf[src][7:0];  \
		cv_w[17][1] <= cv1617_wb_2_buf[src][15:8];  \
		cv_w[17][2] <= cv1617_wb_2_buf[src][23:16];  \
		cv_w[17][3] <= cv1617_wb_2_buf[src][31:24];  \
		cv_w[17][4] <= cv17_wb_0_buf[src][7:0];  \
		cv_w[17][5] <= cv17_wb_0_buf[src][15:8];  \
		cv_w[17][6] <= cv17_wb_0_buf[src][23:16];  \
		cv_w[17][7] <= cv17_wb_0_buf[src][31:24];  \
		cv_w[17][8] <= cv1718_wb_1_buf[src][7:0];  \
		cv_w[17][9] <= cv1718_wb_1_buf[src][15:8];  \
		cv_w[18][1] <= cv1718_wb_1_buf[src][23:16];  \
		cv_w[18][2] <= cv1718_wb_1_buf[src][31:24];  \
		cv_w[18][3] <= cv18_wb_0_buf[src][7:0];  \
		cv_w[18][4] <= cv18_wb_0_buf[src][15:8];  \
		cv_w[18][5] <= cv18_wb_0_buf[src][23:16];  \
		cv_w[18][6] <= cv18_wb_0_buf[src][31:24];  \
		cv_w[18][7] <= cv1819_wb_0_buf[src][7:0];  \
		cv_w[18][8] <= cv1819_wb_0_buf[src][15:8];  \
		cv_w[18][9] <= cv1819_wb_0_buf[src][23:16];  \
		cv_w[19][1] <= cv1819_wb_0_buf[src][31:24];  \
		cv_w[19][2] <= cv19_wb_0_buf[src][7:0];  \
		cv_w[19][3] <= cv19_wb_0_buf[src][15:8];  \
		cv_w[19][4] <= cv19_wb_0_buf[src][23:16];  \
		cv_w[19][5] <= cv19_wb_0_buf[src][31:24];  \
		cv_w[19][6] <= cv19_wb_1_buf[src][7:0];  \
		cv_w[19][7] <= cv19_wb_1_buf[src][15:8];  \
		cv_w[19][8] <= cv19_wb_1_buf[src][23:16];  \
		cv_w[19][9] <= cv19_wb_1_buf[src][31:24];  \
		cv_w[20][1] <= cv20_wb_0_buf[src][7:0];  \
		cv_w[20][2] <= cv20_wb_0_buf[src][15:8];  \
		cv_w[20][3] <= cv20_wb_0_buf[src][23:16];  \
		cv_w[20][4] <= cv20_wb_0_buf[src][31:24];  \
		cv_w[20][5] <= cv20_wb_1_buf[src][7:0];  \
		cv_w[20][6] <= cv20_wb_1_buf[src][15:8];  \
		cv_w[20][7] <= cv20_wb_1_buf[src][23:16];  \
		cv_w[20][8] <= cv20_wb_1_buf[src][31:24];  \
		cv_w[20][9] <= cv2021_wb_2_buf[src][7:0];  \
		cv_w[21][1] <= cv2021_wb_2_buf[src][15:8];  \
		cv_w[21][2] <= cv2021_wb_2_buf[src][23:16];  \
		cv_w[21][3] <= cv2021_wb_2_buf[src][31:24];  \
		cv_w[21][4] <= cv21_wb_0_buf[src][7:0];  \
		cv_w[21][5] <= cv21_wb_0_buf[src][15:8];  \
		cv_w[21][6] <= cv21_wb_0_buf[src][23:16];  \
		cv_w[21][7] <= cv21_wb_0_buf[src][31:24];  \
		cv_w[21][8] <= cv2122_wb_1_buf[src][7:0];  \
		cv_w[21][9] <= cv2122_wb_1_buf[src][15:8];  \
		cv_w[22][1] <= cv2122_wb_1_buf[src][23:16];  \
		cv_w[22][2] <= cv2122_wb_1_buf[src][31:24];  \
		cv_w[22][3] <= cv22_wb_0_buf[src][7:0];  \
		cv_w[22][4] <= cv22_wb_0_buf[src][15:8];  \
		cv_w[22][5] <= cv22_wb_0_buf[src][23:16];  \
		cv_w[22][6] <= cv22_wb_0_buf[src][31:24];  \
		cv_w[22][7] <= cv2223_wb_0_buf[src][7:0];  \
		cv_w[22][8] <= cv2223_wb_0_buf[src][15:8];  \
		cv_w[22][9] <= cv2223_wb_0_buf[src][23:16];  \
		cv_w[23][1] <= cv2223_wb_0_buf[src][31:24];  \
		cv_w[23][2] <= cv23_wb_0_buf[src][7:0];  \
		cv_w[23][3] <= cv23_wb_0_buf[src][15:8];  \
		cv_w[23][4] <= cv23_wb_0_buf[src][23:16];  \
		cv_w[23][5] <= cv23_wb_0_buf[src][31:24];  \
		cv_w[23][6] <= cv23_wb_1_buf[src][7:0];  \
		cv_w[23][7] <= cv23_wb_1_buf[src][15:8];  \
		cv_w[23][8] <= cv23_wb_1_buf[src][23:16];  \
		cv_w[23][9] <= cv23_wb_1_buf[src][31:24];  \
		cv_w[24][1] <= cv24_wb_0_buf[src][7:0];  \
		cv_w[24][2] <= cv24_wb_0_buf[src][15:8];  \
		cv_w[24][3] <= cv24_wb_0_buf[src][23:16];  \
		cv_w[24][4] <= cv24_wb_0_buf[src][31:24];  \
		cv_w[24][5] <= cv24_wb_1_buf[src][7:0];  \
		cv_w[24][6] <= cv24_wb_1_buf[src][15:8];  \
		cv_w[24][7] <= cv24_wb_1_buf[src][23:16];  \
		cv_w[24][8] <= cv24_wb_1_buf[src][31:24];  \
		cv_w[24][9] <= cv2425_wb_2_buf[src][7:0];  \
		cv_w[25][1] <= cv2425_wb_2_buf[src][15:8];  \
		cv_w[25][2] <= cv2425_wb_2_buf[src][23:16];  \
		cv_w[25][3] <= cv2425_wb_2_buf[src][31:24];  \
		cv_w[25][4] <= cv25_wb_0_buf[src][7:0];  \
		cv_w[25][5] <= cv25_wb_0_buf[src][15:8];  \
		cv_w[25][6] <= cv25_wb_0_buf[src][23:16];  \
		cv_w[25][7] <= cv25_wb_0_buf[src][31:24];  \
		cv_w[25][8] <= cv2526_wb_1_buf[src][7:0];  \
		cv_w[25][9] <= cv2526_wb_1_buf[src][15:8];  \
		cv_w[26][1] <= cv2526_wb_1_buf[src][23:16];  \
		cv_w[26][2] <= cv2526_wb_1_buf[src][31:24];  \
		cv_w[26][3] <= cv26_wb_0_buf[src][7:0];  \
		cv_w[26][4] <= cv26_wb_0_buf[src][15:8];  \
		cv_w[26][5] <= cv26_wb_0_buf[src][23:16];  \
		cv_w[26][6] <= cv26_wb_0_buf[src][31:24];  \
		cv_w[26][7] <= cv2627_wb_0_buf[src][7:0];  \
		cv_w[26][8] <= cv2627_wb_0_buf[src][15:8];  \
		cv_w[26][9] <= cv2627_wb_0_buf[src][23:16];  \
		cv_w[27][1] <= cv2627_wb_0_buf[src][31:24];  \
		cv_w[27][2] <= cv27_wb_0_buf[src][7:0];  \
		cv_w[27][3] <= cv27_wb_0_buf[src][15:8];  \
		cv_w[27][4] <= cv27_wb_0_buf[src][23:16];  \
		cv_w[27][5] <= cv27_wb_0_buf[src][31:24];  \
		cv_w[27][6] <= cv27_wb_1_buf[src][7:0];  \
		cv_w[27][7] <= cv27_wb_1_buf[src][15:8];  \
		cv_w[27][8] <= cv27_wb_1_buf[src][23:16];  \
		cv_w[27][9] <= cv27_wb_1_buf[src][31:24];  \
		cv_w[28][1] <= cv28_wb_0_buf[src][7:0];  \
		cv_w[28][2] <= cv28_wb_0_buf[src][15:8];  \
		cv_w[28][3] <= cv28_wb_0_buf[src][23:16];  \
		cv_w[28][4] <= cv28_wb_0_buf[src][31:24];  \
		cv_w[28][5] <= cv28_wb_1_buf[src][7:0];  \
		cv_w[28][6] <= cv28_wb_1_buf[src][15:8];  \
		cv_w[28][7] <= cv28_wb_1_buf[src][23:16];  \
		cv_w[28][8] <= cv28_wb_1_buf[src][31:24];  \
		cv_w[28][9] <= cv2829_wb_2_buf[src][7:0];  \
		cv_w[29][1] <= cv2829_wb_2_buf[src][15:8];  \
		cv_w[29][2] <= cv2829_wb_2_buf[src][23:16];  \
		cv_w[29][3] <= cv2829_wb_2_buf[src][31:24];  \
		cv_w[29][4] <= cv29_wb_0_buf[src][7:0];  \
		cv_w[29][5] <= cv29_wb_0_buf[src][15:8];  \
		cv_w[29][6] <= cv29_wb_0_buf[src][23:16];  \
		cv_w[29][7] <= cv29_wb_0_buf[src][31:24];  \
		cv_w[29][8] <= cv2930_wb_1_buf[src][7:0];  \
		cv_w[29][9] <= cv2930_wb_1_buf[src][15:8];  \
		cv_w[30][1] <= cv2930_wb_1_buf[src][23:16];  \
		cv_w[30][2] <= cv2930_wb_1_buf[src][31:24];  \
		cv_w[30][3] <= cv30_wb_0_buf[src][7:0];  \
		cv_w[30][4] <= cv30_wb_0_buf[src][15:8];  \
		cv_w[30][5] <= cv30_wb_0_buf[src][23:16];  \
		cv_w[30][6] <= cv30_wb_0_buf[src][31:24];  \
		cv_w[30][7] <= cv3031_wb_0_buf[src][7:0];  \
		cv_w[30][8] <= cv3031_wb_0_buf[src][15:8];  \
		cv_w[30][9] <= cv3031_wb_0_buf[src][23:16];  \
		cv_w[31][1] <= cv3031_wb_0_buf[src][31:24];  \
		cv_w[31][2] <= cv31_wb_0_buf[src][7:0];  \
		cv_w[31][3] <= cv31_wb_0_buf[src][15:8];  \
		cv_w[31][4] <= cv31_wb_0_buf[src][23:16];  \
		cv_w[31][5] <= cv31_wb_0_buf[src][31:24];  \
		cv_w[31][6] <= cv31_wb_1_buf[src][7:0];  \
		cv_w[31][7] <= cv31_wb_1_buf[src][15:8];  \
		cv_w[31][8] <= cv31_wb_1_buf[src][23:16];  \
		cv_w[31][9] <= cv31_wb_1_buf[src][31:24];
		
	`define load_qt(src) \
		for (i=0; i<8; i=i+1) begin \
			qt_zp[i] <= qt_buf[src][31:16]; \
			qt_scale[i] <= qt_buf[src][7:0];	\
		end
	
	
	/*********************************************************************************
	 * Functions
	 */
		
	function signed [7:0] int8_add;
		input signed [7:0] a, b;
		reg signed [8:0] sum;
		
		begin
			sum = a + b;
			
			if (sum > 127)
				int8_add = 127;
			else if (sum < -128)
				int8_add = -128;
			else
				int8_add = sum[7:0];
		end
	endfunction
	
	
	
	reg firsttime;
	
	
	integer i, j, k, l, w;	
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
		
			pixelcount <= 0;
			layercount <= 0;
			inlayercount <= 0;
			writepixel <= 0;
			row <= 0;
			savebuffer <= 0;
			firsttime <= 1;
			
			for (i=0; i<32; i=i+1) begin
				intermediate[i] <= 0;
				for (w=1; w<10; w=w+1) cv_w[i][w] <= 0;
			end
			
		end else begin
			case (state)
				SAY_IDLE:
					begin
						pixelcount <= 0;
						layercount <= 0;
						inlayercount <= 0;
						writepixel <= 0;
						row <= 0;
						busy <= 0;
						savebuffer <=0;
						ctrl <= IDLE;
						
						for (i=0; i<32; i=i+1) begin
							intermediate[i] <= 0;
							for (w=1; w<10; w=w+1) cv_w[i][w] <= 0;
						end
						
						if (~unet_enpulse) begin
							state <= STAGE1_WEIGHTLOAD;
							busy <= 1;
							pixelcount <= 0;
						end
					end
					
					
				STAGE1_WEIGHTLOAD:
					begin
						if (firsttime) begin
							if (pixelcount == 1344) begin
								ctrl <= SEND_WEIGHTS;
								layercount <= 0;
								pixelcount <= 0;
								firsttime <= 0;
							end else if (layercount == 71) begin
								pixelcount <= pixelcount + 1;
								layercount <= 0;
							end else begin
								layercount <= layercount + 1;
							end
							
							case (layercount)
								0  : cv00_wb_0_buf[pixelcount]   <= data_in;	//  1: {cv0_w4, cv0_w3, cv0_w2, cv0_w1} -----
								1  : cv00_wb_1_buf[pixelcount]   <= data_in;   //  2: {cv0_w8, cv0_w7, cv0_w6, cv0_w5}
								2  : cv0001_wb_2_buf[pixelcount] <= data_in;	//  3: {cv1_w3, cv1_w2, cv1_w1, cv0_w9}
								3  : cv01_wb_0_buf[pixelcount]   <= data_in;   //  4: {cv1_w7, cv1_w6, cv1_w5, cv1_w4}
								4  : cv0102_wb_1_buf[pixelcount] <= data_in;   //  5: {cv2_w2, cv2_w1, cv1_w9, cv1_w8}
								5  : cv02_wb_0_buf[pixelcount]   <= data_in;   //  6: {cv2_w6, cv2_w5, cv2_w4, cv2_w3}
								6  : cv0203_wb_0_buf[pixelcount] <= data_in;   //  7: {cv3_w1, cv2_w9, cv2_w8, cv2_w7}
								7  : cv03_wb_0_buf[pixelcount]   <= data_in;	//  8: {cv3_w5, cv3_w4, cv3_w3, cv3_w2}
								8  : cv03_wb_1_buf[pixelcount]   <= data_in;   //  9: {cv3_w9, cv3_w8, cv3_w7, cv3_w6}
								9  : cv04_wb_0_buf[pixelcount]   <= data_in;	// 10: {cv4_w4, cv4_w3, cv4_w2, cv4_w1} -----
								10 : cv04_wb_1_buf[pixelcount]   <= data_in;   // 11: {cv4_w8, cv4_w7, cv4_w6, cv4_w5}
								11 : cv0405_wb_2_buf[pixelcount] <= data_in;	// 12: {cv5_w3, cv5_w2, cv5_w1, cv4_w9}
								12 : cv05_wb_0_buf[pixelcount]   <= data_in;   // 13: {cv5_w7, cv5_w6, cv5_w5, cv5_w4}
								13 : cv0506_wb_1_buf[pixelcount] <= data_in;   // 14: {cv6_w2, cv6_w1, cv5_w9, cv5_w8}
								14 : cv06_wb_0_buf[pixelcount]   <= data_in;   // 15: {cv6_w6, cv6_w5, cv6_w4, cv6_w3}
								15 : cv0607_wb_0_buf[pixelcount] <= data_in;   // 16: {cv7_w1, cv6_w9, cv6_w8, cv6_w7}
								16 : cv07_wb_0_buf[pixelcount]   <= data_in;	// 17: {cv7_w5, cv7_w4, cv7_w3, cv7_w2}
								17 : cv07_wb_1_buf[pixelcount]   <= data_in;   // 18: {cv7_w9, cv7_w8, cv7_w7, cv7_w6}
								18 : cv08_wb_0_buf[pixelcount]   <= data_in;	// 19: {cv8_w4, cv8_w3, cv8_w2, cv8_w1} -----
								19 : cv08_wb_1_buf[pixelcount]   <= data_in;   // 20: {cv8_w8, cv8_w7, cv8_w6, cv8_w5}
								20 : cv0809_wb_2_buf[pixelcount] <= data_in;	// 21: {cv1_w3, cv1_w2, cv1_w1, cv8_w9}
								21 : cv09_wb_0_buf[pixelcount]   <= data_in;   // 22: {cv9_w7, cv9_w6, cv9_w5, cv9_w4}
								22 : cv0910_wb_1_buf[pixelcount] <= data_in;   // 23: {cv10_w2, cv10_w1, cv9_w9, cv9_w8}
								23 : cv10_wb_0_buf[pixelcount]   <= data_in;   // 24: {cv10_w6, cv10_w5, cv10_w4, cv10_w3}
								24 : cv1011_wb_0_buf[pixelcount] <= data_in;   // 25: {cv11_w1, cv10_w9, cv10_w8, cv10_w7}
								25 : cv11_wb_0_buf[pixelcount]   <= data_in;	// 26: {cv11_w5, cv11_w4, cv11_w3, cv11_w2}
								26 : cv11_wb_1_buf[pixelcount]   <= data_in;   // 27: {cv11_w9, cv11_w8, cv11_w7, cv11_w6}
								27 : cv12_wb_0_buf[pixelcount]   <= data_in;	// 28: {cv12_w4, cv12_w3, cv12_w2, cv12_w1} -----
								28 : cv12_wb_1_buf[pixelcount]   <= data_in;   // 29: {cv12_w8, cv12_w7, cv12_w6, cv12_w5}
								29 : cv1213_wb_2_buf[pixelcount] <= data_in;   // 30: {cv13_w3, cv13_w2, cv13_w1, cv12_w9}
								30 : cv13_wb_0_buf[pixelcount]   <= data_in;   // 31: {cv13_w7, cv13_w6, cv13_w5, cv13_w4}
								31 : cv1314_wb_1_buf[pixelcount] <= data_in;   // 32: {cv14_w2, cv14_w1, cv13_w9, cv13_w8}
								32 : cv14_wb_0_buf[pixelcount]   <= data_in;   // 33: {cv14_w6, cv14_w5, cv14_w4, cv14_w3}
								33 : cv1415_wb_0_buf[pixelcount] <= data_in;   // 34: {cv15_w1, cv14_w9, cv14_w8, cv14_w7}
								34 : cv15_wb_0_buf[pixelcount]   <= data_in;	// 35: {cv15_w5, cv15_w4, cv15_w3, cv15_w2}
								35 : cv15_wb_1_buf[pixelcount]   <= data_in;   // 36: {cv15_w9, cv15_w8, cv15_w7, cv15_w6}
								36 : cv16_wb_0_buf[pixelcount]   <= data_in;	// 37: {cv16_w4, cv16_w3, cv16_w2, cv16_w1} -----
								37 : cv16_wb_1_buf[pixelcount]   <= data_in;   // 38: {cv16_w8, cv16_w7, cv16_w6, cv16_w5}
								38 : cv1617_wb_2_buf[pixelcount] <= data_in;   // 39: {cv17_w3, cv17_w2, cv17_w1, cv16_w9}
								39 : cv17_wb_0_buf[pixelcount]   <= data_in;   // 40: {cv17_w7, cv17_w6, cv17_w5, cv17_w4}
								40 : cv1718_wb_1_buf[pixelcount] <= data_in;   // 41: {cv18_w2, cv18_w1, cv17_w9, cv17_w8}
								41 : cv18_wb_0_buf[pixelcount]   <= data_in;   // 42: {cv18_w6, cv18_w5, cv18_w4, cv18_w3}
								42 : cv1819_wb_0_buf[pixelcount] <= data_in;   // 43: {cv19_w1, cv18_w9, cv18_w8, cv18_w7}
								43 : cv19_wb_0_buf[pixelcount]   <= data_in;	// 44: {cv19_w5, cv19_w4, cv19_w3, cv19_w2}
								44 : cv19_wb_1_buf[pixelcount]   <= data_in;   // 45: {cv19_w9, cv19_w8, cv19_w7, cv19_w6}
								45 : cv20_wb_0_buf[pixelcount]   <= data_in;	// 46: {cv20_w4, cv20_w3, cv20_w2, cv20_w1} -----
								46 : cv20_wb_1_buf[pixelcount]   <= data_in;   // 47: {cv20_w8, cv20_w7, cv20_w6, cv20_w5}
								47 : cv2021_wb_2_buf[pixelcount] <= data_in;   // 48: {cv21_w3, cv21_w2, cv21_w1, cv20_w9}
								48 : cv21_wb_0_buf[pixelcount]   <= data_in;   // 49: {cv21_w7, cv21_w6, cv21_w5, cv21_w4}
								49 : cv2122_wb_1_buf[pixelcount] <= data_in;   // 50: {cv22_w2, cv22_w1, cv21_w9, cv21_w8}
								50 : cv22_wb_0_buf[pixelcount]   <= data_in;   // 51: {cv22_w6, cv22_w5, cv22_w4, cv22_w3}
								51 : cv2223_wb_0_buf[pixelcount] <= data_in;   // 52: {cv23_w1, cv22_w9, cv22_w8, cv22_w7}
								52 : cv23_wb_0_buf[pixelcount]   <= data_in;	// 53: {cv23_w5, cv23_w4, cv23_w3, cv23_w2}
								53 : cv23_wb_1_buf[pixelcount]   <= data_in;   // 54: {cv23_w9, cv23_w8, cv23_w7, cv23_w6}
								54 : cv24_wb_0_buf[pixelcount]   <= data_in;	// 55: {cv24_w4, cv24_w3, cv24_w2, cv24_w1} -----
								55 : cv24_wb_1_buf[pixelcount]   <= data_in;   // 56: {cv24_w8, cv24_w7, cv24_w6, cv24_w5}
								56 : cv2425_wb_2_buf[pixelcount] <= data_in;   // 57: {cv25_w3, cv25_w2, cv25_w1, cv24_w9}
								57 : cv25_wb_0_buf[pixelcount]   <= data_in;   // 58: {cv25_w7, cv25_w6, cv25_w5, cv25_w4}
								58 : cv2526_wb_1_buf[pixelcount] <= data_in;   // 59: {cv26_w2, cv26_w1, cv25_w9, cv25_w8}
								59 : cv26_wb_0_buf[pixelcount]   <= data_in;   // 60: {cv26_w6, cv26_w5, cv26_w4, cv26_w3}
								60 : cv2627_wb_0_buf[pixelcount] <= data_in;   // 61: {cv27_w1, cv26_w9, cv26_w8, cv26_w7}
								61 : cv27_wb_0_buf[pixelcount]   <= data_in;	// 62: {cv27_w5, cv27_w4, cv27_w3, cv27_w2}
								62 : cv27_wb_1_buf[pixelcount]   <= data_in;   // 63: {cv27_w9, cv27_w8, cv27_w7, cv27_w6}
								63 : cv28_wb_0_buf[pixelcount]   <= data_in;	// 64: {cv28_w4, cv28_w3, cv28_w2, cv28_w1} -----
								64 : cv28_wb_1_buf[pixelcount]   <= data_in;   // 65: {cv28_w8, cv28_w7, cv28_w6, cv28_w5}
								65 : cv2829_wb_2_buf[pixelcount] <= data_in;   // 66: {cv29_w3, cv29_w2, cv29_w1, cv28_w9}
								66 : cv29_wb_0_buf[pixelcount]   <= data_in;   // 67: {cv29_w7, cv29_w6, cv29_w5, cv29_w4}
								67 : cv2930_wb_1_buf[pixelcount] <= data_in;   // 68: {cv30_w2, cv30_w1, cv29_w9, cv29_w8}
								68 : cv30_wb_0_buf[pixelcount]   <= data_in;   // 69: {cv30_w6, cv30_w5, cv30_w4, cv30_w3}
								69 : cv3031_wb_0_buf[pixelcount] <= data_in;   // 70: {cv31_w1, cv30_w9, cv30_w8, cv30_w7}
								70 : cv31_wb_0_buf[pixelcount]   <= data_in;	// 71: {cv31_w5, cv31_w4, cv31_w3, cv31_w2}
								71 : cv31_wb_1_buf[pixelcount]   <= data_in;   // 72: {cv31_w9, cv31_w8, cv31_w7, cv31_w6}
							endcase
						
						end else begin
							ctrl <= SEND_WEIGHTS;
						end
					end
					
					
				STAGE1_CONV:
					// 3 (128x128) Layers ---> 8 (128x128) Layers
					// Here all 8 outlayers calced parellelly
					
					begin
						if (pixelcount >= 32'd16514) begin  // (height*width + (width) for padding + 1 for storing)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <= STAGE1_MXPL;
							pixelcount <= 32'b0;
							layercount <= 32'b0;
							
						end else begin
							if (pixelcount == 32'd16513) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset	
							end
							
							// filling weights
							`load_weight(0)
							`load_qt(0)
							
							if (pixelcount >= 129) begin  // ( width+1 for the padding )
								for (i=0; i<24; i=i+3) begin
									// filters
									for (j=0; j<3; j=j+1) begin
										intermediate[i+j] <= cv_pixelout[i+j];
									end
								end
								
								// add bias and quantization
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2];
								qt1_in   <= intermediate[3] + intermediate[4] + intermediate[5];
								qt2_in   <= intermediate[6] + intermediate[7] + intermediate[8];
								qt3_in   <= intermediate[9] + intermediate[10] + intermediate[11];
								qt4_in   <= intermediate[12] + intermediate[13] + intermediate[14];
								qt5_in   <= intermediate[15] + intermediate[16] + intermediate[17];
								qt6_in   <= intermediate[18] + intermediate[19] + intermediate[20];
								qt7_in   <= intermediate[21] + intermediate[22] + intermediate[23];
								
								
								// save image to buffer, seperated to 4 pices
								// 
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [4095:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								// ------------------------------------------------------------------------------- Q2 [8191:4096]
								//   layerint_buf2         L1-P4224       L2-P4224       L3-P4224      L4-P4224
								//   layerint_buf3         L5-P4224       L6-P4224       L7-P4224      L8-P4224
								// ------------------------------------------------------------------------------- Q3 [12287:8192]
								//   layerint_buf4         L1-P8449       L2-P8449       L3-P8449      L4-P8449
								//   layerint_buf5         L5-P8449       L6-P8449       L7-P8449      L8-P8449
								// ------------------------------------------------------------------------------- Q4 [16383:12288]
								//   layerint_buf6         L1-P12674      L2-P12674      L3-P12674     L4-P12674
								//   layerint_buf7         L5-P12674      L6-P12674      L7-P12674     L8-P12674
								// 
								
								if (pixelcount < 32'd4226) begin		              // pixelcount = 4095 + 130 = 4225
									layerint_buf0_st1[ pixelcount-130 ]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
									layerint_buf1_st1[ pixelcount-130 ]  <= {qt4_res, qt5_res, qt6_res, qt7_res};
									
								end else if (pixelcount < 32'd8322) begin         // pixelcount = 8191 - 4096 + 130 = 4225
																								  // 8191 + 130 = 8321
									layerint_buf2_st1[ pixelcount-4096-130 ]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
									layerint_buf3_st1[ pixelcount-4096-130 ]  <= {qt4_res, qt5_res, qt6_res, qt7_res};
									
								end else if (pixelcount < 32'd12418) begin		  // pixelcount = 12287 - 8192 + 130 = 4225
								                                                  // 12287 + 130 = 12417
									layerint_buf4_st1[ pixelcount-8192-130 ]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
									layerint_buf5_st1[ pixelcount-8192-130 ]  <= {qt4_res, qt5_res, qt6_res, qt7_res};
									
								end else begin                                    // pixelcount = 16383 - 12288 + 130 = 4225
								                                                  // 16383 + 130 = 16513
									layerint_buf6_st1[ pixelcount-12288-130 ]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
									layerint_buf7_st1[ pixelcount-12288-130 ]  <= {qt4_res, qt5_res, qt6_res, qt7_res};
								end
							end
							
							pixelcount <= pixelcount + 1;
						end
					end
					
				STAGE1_MXPL:
					// 8 (128x128) Layers ---> 8 (64x64) Layers
					begin
						if (pixelcount >= 32'd4225) begin // (128*128/4 as 1/4th image pooled parellerly)
							if (pixelcount == 32'd4225) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE2_CONV;
								pixelcount <= 32'b0;
								layercount <= 32'b0;
							end
							
						end else begin
							// pixelcount
							pixelcount <= pixelcount + 1;
								
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [1023:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							// ------------------------------------------------------------------------------- Q2 [2047:1024]
							//   layerint_buf2         L1-P1024       L2-P1024       L3-P1024      L4-P1024
							//   layerint_buf3         L5-P1024       L6-P1024       L7-P1024      L8-P1024
							// ------------------------------------------------------------------------------- Q3 [3071:2048]
							//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
							//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
							// ------------------------------------------------------------------------------- Q4 [4095:3072]
							//   layerint_buf6         L1-P3072       L2-P3072       L3-P3072      L4-P3072
							//   layerint_buf7         L5-P3072       L6-P3072       L7-P3072      L8-P3072
							// 
							if ((pixelcount + 1) % 128 == 0) row <= row + 1;
							
							
							if ((pixelcount >= 129) && (pixelcount % 2 == 1) && (row % 2 == 0)) begin
								writepixel <= writepixel + 1;
								
								layerint_buf0_st2[(writepixel)] <= {cv_pixelout[0][7:0], cv_pixelout[1][7:0], cv_pixelout[2][7:0], cv_pixelout[3][7:0]};
								layerint_buf1_st2[(writepixel)] <= {cv_pixelout[4][7:0], cv_pixelout[5][7:0], cv_pixelout[6][7:0], cv_pixelout[7][7:0]};
								layerint_buf2_st2[(writepixel)] <= {cv_pixelout[8][7:0], cv_pixelout[9][7:0], cv_pixelout[10][7:0], cv_pixelout[11][7:0]};
								layerint_buf3_st2[(writepixel)] <= {cv_pixelout[12][7:0], cv_pixelout[13][7:0], cv_pixelout[14][7:0], cv_pixelout[15][7:0]};
								layerint_buf4_st2[(writepixel)] <= {cv_pixelout[16][7:0], cv_pixelout[17][7:0], cv_pixelout[18][7:0], cv_pixelout[19][7:0]};
								layerint_buf5_st2[(writepixel)] <= {cv_pixelout[20][7:0], cv_pixelout[21][7:0], cv_pixelout[22][7:0], cv_pixelout[23][7:0]};
								layerint_buf6_st2[(writepixel)] <= {cv_pixelout[24][7:0], cv_pixelout[25][7:0], cv_pixelout[26][7:0], cv_pixelout[27][7:0]};
								layerint_buf7_st2[(writepixel)] <= {cv_pixelout[28][7:0], cv_pixelout[29][7:0], cv_pixelout[30][7:0], cv_pixelout[31][7:0]};
							end
						end
					end
					
				STAGE2_CONV:
					// 8 (64x64) Layers ---> 16 (64x64) Layers
					//
					// pixel1 - calc outlayers 1,2,3,4
					//          calc outlayers 5,6,7,8
					//          calc outlayers 9,10,11,12
					//          calc outlayers 13,14,15,16
					// pixel2...
					//
					
					begin
						if (pixelcount >= 32'd4162) begin  // (height*width + (width) for padding + 2 for storing)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <= STAGE2_MXPL;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount >= 65) begin  // width + 1
							
								if (pixelcount == 32'd4161) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
								end else if (layercount == 12) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								end else begin
									layercount <= layercount + 4;
								end
								
								// Loading weights
								case (layercount)
									32'd0:  begin `load_weight(1) end
									32'd4:  begin `load_weight(2) end
									32'd8:  begin `load_weight(3) end
									32'd12: begin `load_weight(4) end

									default:
										begin
											for (i=0; i<32; i=i+1) begin
												for (w=1; w<10; w=w+1) begin
													cv_w[i][w] <= 1;
												end
											end
										end
								endcase
								
								`load_qt(1)
								
							
								// Do the convolution
								for (i=0; i<32; i=i+8) begin
									// filters
									for (j=0; j<8; j=j+1) begin
										intermediate[i+j] <= cv_pixelout[i+j];
									end
								end
								
								// add bias and quantization
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
												+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7];
								
								qt1_in   <= intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
												+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15];
								
								qt2_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
												+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23];
								
								qt3_in   <= intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
												+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
								
								// save to buffer
								
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [2047:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
								//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
								// ------------------------------------------------------------------------------- Q2 [4095:2048]
								//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
								//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
								//   layerint_buf6         L9-P2048       L10-P2048      L11-P2048     L12-P2048
								//   layerint_buf7         L13-P2048      L14-P2048      L15-P2048     L16-P2048
								// 
								
								case (layercount)
									32'd4:
										begin
											if (pixelcount < 32'd2114) 
												layerint_buf0_st2[(pixelcount-65)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
											else
												layerint_buf4_st2[(pixelcount-65)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
										end
									
									32'd8:
										begin
											if (pixelcount < 32'd2114) 
												layerint_buf1_st2[(pixelcount-65)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
											else
												layerint_buf5_st2[(pixelcount-65)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
										end
										
									32'd12:
										begin
											if (pixelcount < 32'd2114) 
												layerint_buf2_st2[(pixelcount-65)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
											else
												layerint_buf6_st2[(pixelcount-65)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
										end
										
									32'd0:
										begin
											if (pixelcount > 65) begin
												if (pixelcount < 32'd2115) 
													layerint_buf3_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
												else
													layerint_buf7_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
											end
										end
								endcase
							end else begin						
								pixelcount <= pixelcount + 1;
							end
						end
					end
					
				STAGE2_MXPL:
					// 16 (64x64) Layers ---> 16 (32x32) Layers
					begin
						if (pixelcount >= 32'd2113) begin // (64*64/2 as 1/2th image pooled parellerly + 64 + 1)
							if (pixelcount == 32'd2113) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE3_CONV;
								pixelcount <= 32'b0;
								layercount <= 0;
							end
							
						end else begin
							// pixelcount
							pixelcount <= pixelcount + 1;
								
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [511:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
							//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
							// ------------------------------------------------------------------------------- Q2 [1023:512]
							//   layerint_buf4         L1-P512        L2-P512        L3-P512       L4-P512 
							//   layerint_buf5         L5-P512        L6-P512        L7-P512       L8-P512 
							//   layerint_buf6         L9-P512        L10-P512       L11-P512      L12-P512 
							//   layerint_buf7         L13-P512       L14-P512       L15-P512      L16-P512
							// 
							
							if ((pixelcount + 1) % 64 == 0) row <= row + 1;
							
							
							if ((pixelcount >= 65) && (pixelcount % 2 == 1) && (row % 2 == 0)) begin
								writepixel <= writepixel + 1;
								
								layerint_buf0_st3[(writepixel)] <= {cv_pixelout[0][7:0], cv_pixelout[1][7:0], cv_pixelout[2][7:0], cv_pixelout[3][7:0]};
								layerint_buf1_st3[(writepixel)] <= {cv_pixelout[4][7:0], cv_pixelout[5][7:0], cv_pixelout[6][7:0], cv_pixelout[7][7:0]};
								layerint_buf2_st3[(writepixel)] <= {cv_pixelout[8][7:0], cv_pixelout[9][7:0], cv_pixelout[10][7:0], cv_pixelout[11][7:0]};
								layerint_buf3_st3[(writepixel)] <= {cv_pixelout[12][7:0], cv_pixelout[13][7:0], cv_pixelout[14][7:0], cv_pixelout[15][7:0]};
								layerint_buf4_st3[(writepixel)] <= {cv_pixelout[16][7:0], cv_pixelout[17][7:0], cv_pixelout[18][7:0], cv_pixelout[19][7:0]};
								layerint_buf5_st3[(writepixel)] <= {cv_pixelout[20][7:0], cv_pixelout[21][7:0], cv_pixelout[22][7:0], cv_pixelout[23][7:0]};
								layerint_buf6_st3[(writepixel)] <= {cv_pixelout[24][7:0], cv_pixelout[25][7:0], cv_pixelout[26][7:0], cv_pixelout[27][7:0]};
								layerint_buf7_st3[(writepixel)] <= {cv_pixelout[28][7:0], cv_pixelout[29][7:0], cv_pixelout[30][7:0], cv_pixelout[31][7:0]};
							end
						end
					end
					
					
				STAGE3_CONV:
					// 16 (32x32) levels ---> 32 (32x32) levels
					//
					// pixel1 - calc outlayers 1,2
					//          calc outlayers 3,4
					//          ...
					//          calc outlayers 31,32
					// pixel2...
					//
					begin
						if (pixelcount >= 32'd1058) begin  // (height*width + (width) for padding + 2)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <= STAGE3_MXPL;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount >= 33) begin  // ( width+1 for the padding )
							
								if (pixelcount == 32'd1057) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
								end else if (layercount == 30) begin
									pixelcount <= pixelcount + 1;
									layercount <= 0;
								end else begin
									layercount <= layercount + 2;
								end
								
								case (layercount)
									32'd0:  begin `load_weight(5) end
									32'd2:  begin `load_weight(6) end
									32'd4:  begin `load_weight(7) end
									32'd6:  begin `load_weight(8) end
									32'd8:  begin `load_weight(9) end
									32'd10: begin `load_weight(10) end
									32'd12: begin `load_weight(11) end
									32'd14: begin `load_weight(12) end
									32'd16: begin `load_weight(13) end
									32'd18: begin `load_weight(14) end
									32'd20: begin `load_weight(15) end
									32'd22: begin `load_weight(16) end
									32'd24: begin `load_weight(17) end
									32'd26: begin `load_weight(18) end
									32'd28: begin `load_weight(19) end
									32'd30: begin `load_weight(20) end
									
									default:
										begin
											for (i=0; i<32; i=i+1) begin
												for (w=1; w<10; w=w+1) begin
													cv_w[i][w]    <= 0;
												end
											end
										end
								endcase		
								
								`load_qt(2)
								
								
								for (i=0; i<32; i=i+16) begin
									// filters
									for (j=0; j<16; j=j+1) begin
										intermediate[i+j] <= cv_pixelout[i+j];
									end
								end
								
								// add bias and quantization
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
												+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
												+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
												+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15];
								
								qt1_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
												+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
												+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
												+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
								
								// save to buffer
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [511:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
								//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
								//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
								//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
								//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
								//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
								// 			
								
								case (layercount)
									32'd2:  savebuffer[31:16] <= {qt0_res, qt1_res};
									32'd4:  layerint_buf0_st3[(pixelcount-33)] <= {savebuffer[31:16], qt0_res, qt1_res};
									32'd6:  savebuffer[31:16] <= {qt0_res, qt1_res};
									32'd8:  layerint_buf1_st3[(pixelcount-33)] <= {savebuffer[31:16], qt0_res, qt1_res};
									32'd10: savebuffer[31:16] <= {qt0_res, qt1_res};
									32'd12: layerint_buf2_st3[(pixelcount-33)] <= {savebuffer[31:16], qt0_res, qt1_res};
									32'd14: savebuffer[31:16] <= {qt0_res, qt1_res};
									32'd16: layerint_buf3_st3[(pixelcount-33)] <= {savebuffer[31:16], qt0_res, qt1_res};
									32'd18: savebuffer[31:16] <= {qt0_res, qt1_res};
									32'd20: layerint_buf4_st3[(pixelcount-33)] <= {savebuffer[31:16], qt0_res, qt1_res};
									32'd22: savebuffer[31:16] <= {qt0_res, qt1_res};
									32'd24: layerint_buf5_st3[(pixelcount-33)] <= {savebuffer[31:16], qt0_res, qt1_res};
									32'd26: savebuffer[31:16] <= {qt0_res, qt1_res};
									32'd28: layerint_buf6_st3[(pixelcount-33)] <= {savebuffer[31:16], qt0_res, qt1_res};
									32'd30: savebuffer[31:16] <= {qt0_res, qt1_res};
									32'd0:  if (pixelcount > 33) layerint_buf7_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
								endcase
							end else begin
								pixelcount <= pixelcount + 1;
							end	
						end
					end
					
				STAGE3_MXPL:
					// 32 (32x32) Layers ---> 32 (16x16) Layers
					
					begin
						if (pixelcount >= 32'd1057) begin // (32*32 + 32 + 1)
							if (pixelcount == 32'd4161) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE4_CONV;
								pixelcount <= 32'b0;
								layercount <= 0;
							end
							
						end else begin
							// pixelcount
							pixelcount <= pixelcount + 1;
								
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [255:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
							//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
							//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
							//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
							//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
							//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
							
							if ((pixelcount + 1) % 32 == 0) row <= row + 1;
							
							
							if ((pixelcount >= 33) && (pixelcount % 2 == 1) && (row % 2 == 0)) begin
								writepixel <= writepixel + 1;
								
								layerint_buf0_st4[(writepixel)] <= {cv_pixelout[0][7:0], cv_pixelout[1][7:0], cv_pixelout[2][7:0], cv_pixelout[3][7:0]};
								layerint_buf1_st4[(writepixel)] <= {cv_pixelout[4][7:0], cv_pixelout[5][7:0], cv_pixelout[6][7:0], cv_pixelout[7][7:0]};
								layerint_buf2_st4[(writepixel)] <= {cv_pixelout[8][7:0], cv_pixelout[9][7:0], cv_pixelout[10][7:0], cv_pixelout[11][7:0]};
								layerint_buf3_st4[(writepixel)] <= {cv_pixelout[12][7:0], cv_pixelout[13][7:0], cv_pixelout[14][7:0], cv_pixelout[15][7:0]};
								layerint_buf4_st4[(writepixel)] <= {cv_pixelout[16][7:0], cv_pixelout[17][7:0], cv_pixelout[18][7:0], cv_pixelout[19][7:0]};
								layerint_buf5_st4[(writepixel)] <= {cv_pixelout[20][7:0], cv_pixelout[21][7:0], cv_pixelout[22][7:0], cv_pixelout[23][7:0]};
								layerint_buf6_st4[(writepixel)] <= {cv_pixelout[24][7:0], cv_pixelout[25][7:0], cv_pixelout[26][7:0], cv_pixelout[27][7:0]};
								layerint_buf7_st4[(writepixel)] <= {cv_pixelout[28][7:0], cv_pixelout[29][7:0], cv_pixelout[30][7:0], cv_pixelout[31][7:0]};
							end
						end
					end
					
				STAGE4_CONV:
					// 32 (16x16) levels ---> 64 (16x16) levels
					//
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 64
					// pixel2...
					//
					begin
						if (pixelcount >= 32'd274) begin  // (height*width + (width) for padding + 2)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <= STAGE4_MXPL;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount >= 17) begin  // ( width+1 for the padding )
							
								if (pixelcount == 273) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
								end else if (layercount == 63) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								end else begin
									layercount <= layercount + 1;
								end
								
							
								// Loading weights
								`load_weight(layercount + 21)
								`load_qt(3)
								
								for (i=0; i<32; i=i+1) begin
									// filters
									intermediate[i] <= cv_pixelout[i];
								end
								
								// add bias and quantization
								//qt0
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
												+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
												+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
												+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
												+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
												+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
												+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
												+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
								
								// save to buffer
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [255:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
								//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
								//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
								//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
								//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
								//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
								//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
								//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
								//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
								//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
								//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
								//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
								//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
								//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
								
								case (layercount)
									32'd1:  savebuffer[31:24] <= {qt0_res};
									32'd2:  savebuffer[23:16] <= {qt0_res};
									32'd3:  savebuffer[15:8]  <= {qt0_res};
									32'd4:  layerint_buf0_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd5:  savebuffer[31:24] <= {qt0_res};
									32'd6:  savebuffer[23:16] <= {qt0_res};
									32'd7:  savebuffer[15:8]  <= {qt0_res};
									32'd8:  layerint_buf1_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd9:  savebuffer[31:24] <= {qt0_res};
									32'd10: savebuffer[23:16] <= {qt0_res};
									32'd11: savebuffer[15:8]  <= {qt0_res};
									32'd12: layerint_buf2_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd13: savebuffer[31:24] <= {qt0_res};
									32'd14: savebuffer[23:16] <= {qt0_res};
									32'd15: savebuffer[15:8]  <= {qt0_res};
									32'd16: layerint_buf3_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd17: savebuffer[31:24] <= {qt0_res};
									32'd18: savebuffer[23:16] <= {qt0_res};
									32'd19: savebuffer[15:8]  <= {qt0_res};
									32'd20: layerint_buf4_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd21: savebuffer[31:24] <= {qt0_res};
									32'd22: savebuffer[23:16] <= {qt0_res};
									32'd23: savebuffer[15:8]  <= {qt0_res};
									32'd24: layerint_buf5_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd25: savebuffer[31:24] <= {qt0_res};
									32'd26: savebuffer[23:16] <= {qt0_res};
									32'd27: savebuffer[15:8]  <= {qt0_res};
									32'd28: layerint_buf6_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd29: savebuffer[31:24] <= {qt0_res};
									32'd30: savebuffer[23:16] <= {qt0_res};
									32'd31: savebuffer[15:8]  <= {qt0_res};
									32'd32: layerint_buf7_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd33: savebuffer[31:24] <= {qt0_res};
									32'd34: savebuffer[23:16] <= {qt0_res};
									32'd35: savebuffer[15:8]  <= {qt0_res};
									32'd36: layerint_buf8_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd37: savebuffer[31:24] <= {qt0_res};
									32'd38: savebuffer[23:16] <= {qt0_res};
									32'd39: savebuffer[15:8]  <= {qt0_res};
									32'd40: layerint_buf9_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd41: savebuffer[31:24] <= {qt0_res};
									32'd42: savebuffer[23:16] <= {qt0_res};
									32'd43: savebuffer[15:8]  <= {qt0_res};
									32'd44: layerint_buf10_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd45: savebuffer[31:24] <= {qt0_res};
									32'd46: savebuffer[23:16] <= {qt0_res};
									32'd47: savebuffer[15:8]  <= {qt0_res};
									32'd48: layerint_buf11_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd49: savebuffer[31:24] <= {qt0_res};
									32'd50: savebuffer[23:16] <= {qt0_res};
									32'd51: savebuffer[15:8]  <= {qt0_res};
									32'd52: layerint_buf12_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd53: savebuffer[31:24] <= {qt0_res};
									32'd54: savebuffer[23:16] <= {qt0_res};
									32'd55: savebuffer[15:8]  <= {qt0_res};
									32'd56: layerint_buf13_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd57: savebuffer[31:24] <= {qt0_res};
									32'd58: savebuffer[23:16] <= {qt0_res};
									32'd59: savebuffer[15:8]  <= {qt0_res};
									32'd60: layerint_buf14_st4[(pixelcount-17)] <= {savebuffer[31:8], qt0_res};
									32'd61: savebuffer[31:24] <= {qt0_res};
									32'd62: savebuffer[23:16] <= {qt0_res};
									32'd63: savebuffer[15:8]  <= {qt0_res};
									32'd0:  if (pixelcount > 17) layerint_buf15_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
								endcase
							end else begin
								pixelcount <= pixelcount + 1;
							end
						end
					end
					
				STAGE4_MXPL:
					// 64 (16x16) Layers ---> 64 (8x8) Layers
					
					begin
						if (pixelcount >= 32'd273) begin  // (height*width + (width+1) for padding)
							if (inlayercount >= 32'd64) begin
								if (pixelcount == 32'd273) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
								end else begin
									for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
									state <= STAGE5_CONV;
									pixelcount <= 32'b0;
									layercount <= 0;
								end
								
							end else begin
								pixelcount <= 32'b0;
								writepixel <= 0;
								row <= 0;
								inlayercount <= inlayercount + 32'd32;
							end
							
						end else begin
							pixelcount <= pixelcount + 1;
								
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [63:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
							//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
							//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
							//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
							//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
							//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
							//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
							//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
							//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
							//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
							//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
							//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
							//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
							//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
							
							if ((pixelcount + 1) % 16 == 0) row <= row + 1;
							
							
							if ((pixelcount >= 33) && (pixelcount % 2 == 1) && (row % 2 == 0)) begin
								writepixel <= writepixel + 1;
								
								if (inlayercount == 0) begin
									layerint_buf0_st5[(writepixel)] <= {cv_pixelout[0][7:0], cv_pixelout[1][7:0], cv_pixelout[2][7:0], cv_pixelout[3][7:0]};
									layerint_buf1_st5[(writepixel)] <= {cv_pixelout[4][7:0], cv_pixelout[5][7:0], cv_pixelout[6][7:0], cv_pixelout[7][7:0]};
									layerint_buf2_st5[(writepixel)] <= {cv_pixelout[8][7:0], cv_pixelout[9][7:0], cv_pixelout[10][7:0], cv_pixelout[11][7:0]};
									layerint_buf3_st5[(writepixel)] <= {cv_pixelout[12][7:0], cv_pixelout[13][7:0], cv_pixelout[14][7:0], cv_pixelout[15][7:0]};
									layerint_buf4_st5[(writepixel)] <= {cv_pixelout[16][7:0], cv_pixelout[17][7:0], cv_pixelout[18][7:0], cv_pixelout[19][7:0]};
									layerint_buf5_st5[(writepixel)] <= {cv_pixelout[20][7:0], cv_pixelout[21][7:0], cv_pixelout[22][7:0], cv_pixelout[23][7:0]};
									layerint_buf6_st5[(writepixel)] <= {cv_pixelout[24][7:0], cv_pixelout[25][7:0], cv_pixelout[26][7:0], cv_pixelout[27][7:0]};
									layerint_buf7_st5[(writepixel)] <= {cv_pixelout[28][7:0], cv_pixelout[29][7:0], cv_pixelout[30][7:0], cv_pixelout[31][7:0]};
								end else begin
									layerint_buf8_st5[(writepixel)] <= {cv_pixelout[0][7:0], cv_pixelout[1][7:0], cv_pixelout[2][7:0], cv_pixelout[3][7:0]};
									layerint_buf9_st5[(writepixel)] <= {cv_pixelout[4][7:0], cv_pixelout[5][7:0], cv_pixelout[6][7:0], cv_pixelout[7][7:0]};
									layerint_buf10_st5[(writepixel)] <= {cv_pixelout[8][7:0], cv_pixelout[9][7:0], cv_pixelout[10][7:0], cv_pixelout[11][7:0]};
									layerint_buf11_st5[(writepixel)] <= {cv_pixelout[12][7:0], cv_pixelout[13][7:0], cv_pixelout[14][7:0], cv_pixelout[15][7:0]};
									layerint_buf12_st5[(writepixel)] <= {cv_pixelout[16][7:0], cv_pixelout[17][7:0], cv_pixelout[18][7:0], cv_pixelout[19][7:0]};
									layerint_buf13_st5[(writepixel)] <= {cv_pixelout[20][7:0], cv_pixelout[21][7:0], cv_pixelout[22][7:0], cv_pixelout[23][7:0]};
									layerint_buf14_st5[(writepixel)] <= {cv_pixelout[24][7:0], cv_pixelout[25][7:0], cv_pixelout[26][7:0], cv_pixelout[27][7:0]};
									layerint_buf15_st5[(writepixel)] <= {cv_pixelout[28][7:0], cv_pixelout[29][7:0], cv_pixelout[30][7:0], cv_pixelout[31][7:0]};
								end
							end
						end
					end
					
				STAGE5_CONV:
					// 64 (8x8) Layers ---> 128 (8x8) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 128 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 128
					// pixel2...
					// ...
					// pixel100...
					
					begin
						if (pixelcount >= 9) begin  // ( width+1 for the padding )
							
							if (pixelcount == 73) begin  // (height*width + (width+1) for padding)
								pixelcount   <= 0;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								
								if (inlayercount == 32) begin
									state <= STAGE6_TRANSCONV;
									inlayercount <= 0;
								end else begin
									inlayercount <= inlayercount + 32'd32;
								end
								
							end else if (layercount == 127) begin
								layercount <= 0;
								pixelcount <= pixelcount + 1;
								if (pixelcount == 72) for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
							end else begin
								layercount <= layercount + 32'd1;	
							end
								
							// Loading weights
							if (inlayercount == 0) begin
								`load_weight(layercount + 85)
							end else begin
								`load_weight(layercount + 213)
							end
							
							`load_qt(4)
						
							// Convolution
							for (i=0; i<32; i=i+1)	intermediate[i] <= cv_pixelout[i];
							
							// add bias and quantization
							qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
											+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
											+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
											+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
											+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
											+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
											+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
											+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
							// save to buffer
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [63:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
							//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
							//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
							//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
							//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
							//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
							//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
							//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
							//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
							//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
							//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
							//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
							//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
							//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
							//   layerint_buf16        L65-P1         L66-P1         L67-P1        L68-P1
							//   layerint_buf17        L69-P1         L70-P1         L71-P1        L72-P1
							//   layerint_buf18        L73-P1         L74-P1         L75-P1        L76-P1
							//   layerint_buf19        L77-P1         L78-P1         L79-P1        L80-P1
							//   layerint_buf20        L81-P1         L82-P1         L83-P1        L84-P1
							//   layerint_buf21        L85-P1         L86-P1         L87-P1        L88-P1
							//   layerint_buf22        L89-P1         L90-P1         L91-P1        L92-P1
							//   layerint_buf23        L93-P1         L94-P1         L95-P1        L96-P1
							//   layerint_buf24        L97-P1         L98-P1         L99-P1        L100-P1
							//   layerint_buf25        L101-P1        L102-P1        L103-P1       L104-P1
							//   layerint_buf26        L105-P1        L106-P1        L107-P1       L108-P1
							//   layerint_buf27        L109-P1        L110-P1        L111-P1       L112-P1
							//   layerint_buf28        L113-P1        L114-P1        L115-P1       L116-P1
							//   layerint_buf29        L117-P1        L118-P1        L119-P1       L120-P1
							//   layerint_buf30        L121-P1        L122-P1        L123-P1       L124-P1
							//   layerint_buf31        L125-P1        L126-P1        L127-P1       L128-P1
							
							case (layercount)
								32'd1:   savebuffer[31:24] <= {qt0_res};
								32'd2:   savebuffer[23:16] <= {qt0_res};
								32'd3:   savebuffer[15:8]  <= {qt0_res};
								32'd4:   layerint_buf0_st5[(pixelcount-9)] <= {int8_add(layerint_buf0_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf0_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf0_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf0_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd5:   savebuffer[31:24] <= {qt0_res};
								32'd6:   savebuffer[23:16] <= {qt0_res};
								32'd7:   savebuffer[15:8]  <= {qt0_res};
								32'd8:   layerint_buf1_st5[(pixelcount-9)] <= {int8_add(layerint_buf1_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf1_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf1_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf1_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd9:   savebuffer[31:24] <= {qt0_res};
								32'd10:  savebuffer[23:16] <= {qt0_res};
								32'd11:  savebuffer[15:8]  <= {qt0_res};
								32'd12:  layerint_buf2_st5[(pixelcount-9)] <= {int8_add(layerint_buf2_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf2_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf2_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf2_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd13:  savebuffer[31:24] <= {qt0_res};
								32'd14:  savebuffer[23:16] <= {qt0_res};
								32'd15:  savebuffer[15:8]  <= {qt0_res};
								32'd16:  layerint_buf3_st5[(pixelcount-9)] <= {int8_add(layerint_buf3_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf3_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf3_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf3_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd17:  savebuffer[31:24] <= {qt0_res};
								32'd18:  savebuffer[23:16] <= {qt0_res};
								32'd19:  savebuffer[15:8]  <= {qt0_res};
								32'd20:  layerint_buf4_st5[(pixelcount-9)] <= {int8_add(layerint_buf4_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf4_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf4_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf4_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd21:  savebuffer[31:24] <= {qt0_res};
								32'd22:  savebuffer[23:16] <= {qt0_res};
								32'd23:  savebuffer[15:8]  <= {qt0_res};
								32'd24:  layerint_buf5_st5[(pixelcount-9)] <= {int8_add(layerint_buf5_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf5_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf5_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf5_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd25:  savebuffer[31:24] <= {qt0_res};
								32'd26:  savebuffer[23:16] <= {qt0_res};
								32'd27:  savebuffer[15:8]  <= {qt0_res};
								32'd28:  layerint_buf6_st5[(pixelcount-9)] <= {int8_add(layerint_buf6_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf6_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf6_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf6_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd29:  savebuffer[31:24] <= {qt0_res};
								32'd30:  savebuffer[23:16] <= {qt0_res};
								32'd31:  savebuffer[15:8]  <= {qt0_res};
								32'd32:  layerint_buf7_st5[(pixelcount-9)] <= {int8_add(layerint_buf7_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf7_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf7_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf7_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd33:  savebuffer[31:24] <= {qt0_res};
								32'd34:  savebuffer[23:16] <= {qt0_res};
								32'd35:  savebuffer[15:8]  <= {qt0_res};
								32'd36:  layerint_buf8_st5[(pixelcount-9)] <= {int8_add(layerint_buf8_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf8_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf8_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf8_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd37:  savebuffer[31:24] <= {qt0_res};
								32'd38:  savebuffer[23:16] <= {qt0_res};
								32'd39:  savebuffer[15:8]  <= {qt0_res};
								32'd40:  layerint_buf9_st5[(pixelcount-9)] <= {int8_add(layerint_buf9_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf9_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf9_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf9_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd41:  savebuffer[31:24] <= {qt0_res};
								32'd42:  savebuffer[23:16] <= {qt0_res};
								32'd43:  savebuffer[15:8]  <= {qt0_res};
								32'd44:  layerint_buf10_st5[(pixelcount-9)] <= {int8_add(layerint_buf10_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf10_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf10_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf10_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd45:  savebuffer[31:24] <= {qt0_res};
								32'd46:  savebuffer[23:16] <= {qt0_res};
								32'd47:  savebuffer[15:8]  <= {qt0_res};
								32'd48:  layerint_buf11_st5[(pixelcount-9)] <= {int8_add(layerint_buf11_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf11_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf11_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf11_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd49:  savebuffer[31:24] <= {qt0_res};
								32'd50:  savebuffer[23:16] <= {qt0_res};
								32'd51:  savebuffer[15:8]  <= {qt0_res};
								32'd52:  layerint_buf12_st5[(pixelcount-9)] <= {int8_add(layerint_buf12_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf12_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf12_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf12_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd53:  savebuffer[31:24] <= {qt0_res};
								32'd54:  savebuffer[23:16] <= {qt0_res};
								32'd55:  savebuffer[15:8]  <= {qt0_res};
								32'd56:  layerint_buf13_st5[(pixelcount-9)] <= {int8_add(layerint_buf13_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf13_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf13_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf13_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd57:  savebuffer[31:24] <= {qt0_res};
								32'd58:  savebuffer[23:16] <= {qt0_res};
								32'd59:  savebuffer[15:8]  <= {qt0_res};
								32'd60:  layerint_buf14_st5[(pixelcount-9)] <= {int8_add(layerint_buf14_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf14_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf14_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf14_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd61:  savebuffer[31:24] <= {qt0_res};
								32'd62:  savebuffer[23:16] <= {qt0_res};
								32'd63:  savebuffer[15:8]  <= {qt0_res};
								32'd64:  layerint_buf15_st5[(pixelcount-9)] <= {int8_add(layerint_buf15_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf15_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf15_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf15_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd65:  savebuffer[31:24] <= {qt0_res};
								32'd66:  savebuffer[23:16] <= {qt0_res};
								32'd67:  savebuffer[15:8]  <= {qt0_res};
								32'd68:  layerint_buf16_st5[(pixelcount-9)] <= {int8_add(layerint_buf16_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf16_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf16_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf16_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd69:  savebuffer[31:24] <= {qt0_res};
								32'd70:  savebuffer[23:16] <= {qt0_res};
								32'd71:  savebuffer[15:8]  <= {qt0_res};
								32'd72:  layerint_buf17_st5[(pixelcount-9)] <= {int8_add(layerint_buf17_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf17_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf17_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf17_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd73:  savebuffer[31:24] <= {qt0_res};
								32'd74:  savebuffer[23:16] <= {qt0_res};
								32'd75:  savebuffer[15:8]  <= {qt0_res};
								32'd76:  layerint_buf18_st5[(pixelcount-9)] <= {int8_add(layerint_buf18_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf18_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf18_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf18_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd77:  savebuffer[31:24] <= {qt0_res};
								32'd78:  savebuffer[23:16] <= {qt0_res};
								32'd79:  savebuffer[15:8]  <= {qt0_res};
								32'd80:  layerint_buf19_st5[(pixelcount-9)] <= {int8_add(layerint_buf19_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf19_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf19_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf19_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd81:  savebuffer[31:24] <= {qt0_res};
								32'd82:  savebuffer[23:16] <= {qt0_res};
								32'd83:  savebuffer[15:8]  <= {qt0_res};
								32'd84:  layerint_buf20_st5[(pixelcount-9)] <= {int8_add(layerint_buf20_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf20_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf20_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf20_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd85:  savebuffer[31:24] <= {qt0_res};
								32'd86:  savebuffer[23:16] <= {qt0_res};
								32'd87:  savebuffer[15:8]  <= {qt0_res};
								32'd88:  layerint_buf21_st5[(pixelcount-9)] <= {int8_add(layerint_buf21_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf21_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf21_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf21_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd89:  savebuffer[31:24] <= {qt0_res};
								32'd90:  savebuffer[23:16] <= {qt0_res};
								32'd91:  savebuffer[15:8]  <= {qt0_res};
								32'd92:  layerint_buf22_st5[(pixelcount-9)] <= {int8_add(layerint_buf22_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf22_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf22_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf22_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd93:  savebuffer[31:24] <= {qt0_res};
								32'd94:  savebuffer[23:16] <= {qt0_res};
								32'd95:  savebuffer[15:8]  <= {qt0_res};
								32'd96:  layerint_buf23_st5[(pixelcount-9)] <= {int8_add(layerint_buf23_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf23_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf23_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf23_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd97:  savebuffer[31:24] <= {qt0_res};
								32'd98:  savebuffer[23:16] <= {qt0_res};
								32'd99:  savebuffer[15:8]  <= {qt0_res};
								32'd100: layerint_buf24_st5[(pixelcount-9)] <= {int8_add(layerint_buf24_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf24_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf24_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf24_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd101: savebuffer[31:24] <= {qt0_res};
								32'd102: savebuffer[23:16] <= {qt0_res};
								32'd103: savebuffer[15:8]  <= {qt0_res};
								32'd104: layerint_buf25_st5[(pixelcount-9)] <= {int8_add(layerint_buf25_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf25_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf25_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf25_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd105: savebuffer[31:24] <= {qt0_res};
								32'd106: savebuffer[23:16] <= {qt0_res};
								32'd107: savebuffer[15:8]  <= {qt0_res};
								32'd108: layerint_buf26_st5[(pixelcount-9)] <= {int8_add(layerint_buf26_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf26_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf26_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf26_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd109: savebuffer[31:24] <= {qt0_res};
								32'd110: savebuffer[23:16] <= {qt0_res};
								32'd111: savebuffer[15:8]  <= {qt0_res};
								32'd112: layerint_buf27_st5[(pixelcount-9)] <= {int8_add(layerint_buf27_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf27_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf27_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf27_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd113: savebuffer[31:24] <= {qt0_res};
								32'd114: savebuffer[23:16] <= {qt0_res};
								32'd115: savebuffer[15:8]  <= {qt0_res};
								32'd116: layerint_buf28_st5[(pixelcount-9)] <= {int8_add(layerint_buf28_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								 int8_add(layerint_buf28_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								 int8_add(layerint_buf28_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								 int8_add(layerint_buf28_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd117: savebuffer[31:24] <= {qt0_res};
								32'd118: savebuffer[23:16] <= {qt0_res};
								32'd119: savebuffer[15:8]  <= {qt0_res};
								32'd120: layerint_buf29_st5[(pixelcount-9)] <= {int8_add(layerint_buf29_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf29_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf29_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf29_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd121: savebuffer[31:24] <= {qt0_res};
								32'd122: savebuffer[23:16] <= {qt0_res};
								32'd123: savebuffer[15:8]  <= {qt0_res};
								32'd124: layerint_buf30_st5[(pixelcount-9)] <= {int8_add(layerint_buf30_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf30_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf30_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf30_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd125: savebuffer[31:24] <= {qt0_res};
								32'd126: savebuffer[23:16] <= {qt0_res};
								32'd127: savebuffer[15:8]  <= {qt0_res};
								32'd0:   
									begin
										if (pixelcount > 9)
											layerint_buf31_st5[(pixelcount-10)] <= {int8_add(layerint_buf31_st5[(pixelcount-10)][31:24], savebuffer[31:24]), 
																								 int8_add(layerint_buf31_st5[(pixelcount-10)][23:16], savebuffer[23:16]),
																								 int8_add(layerint_buf31_st5[(pixelcount-10)][15:8] , savebuffer[15:8]), 
																								 int8_add(layerint_buf31_st5[(pixelcount-10)][7:0]  , qt0_res)};
									end
							endcase
							
						end else begin
							pixelcount <= pixelcount + 1;
						end
					end
					
					
		//****************************************************************************************
		//
		//   DECODER
		//
		//****************************************************************************************
					
				STAGE6_TRANSCONV:
					// 128 (8x8) Layers ---> 64 (16x16) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 64 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 64 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 64 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1 
					//          calc outlayers 2
					//          ...
					//          calc outlayers 64
					// pixel2...
					// ...
					// pixel100...
					
					begin
						if (pixelcount >= 9) begin  // ( width+1 for the padding )
							if (pixelcount == 73) begin // (height*width + (width+1) for padding)
								pixelcount <= 0;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								
								if (inlayercount == 96) begin
									state <= STAGE6_CONV;
									inlayercount <= 0;
								end else begin
									inlayercount <= inlayercount + 32;
								end
								
							end else if (layercount == 63) begin
								layercount <= 0;
								pixelcount <= pixelcount + 1;
								if (pixelcount == 72) for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
							end else begin							
								layercount <= layercount + 1;
							end
							
							
							// Loading weights
							if (inlayercount == 0) begin
								`load_weight(layercount + 341)
							end else if (inlayercount == 32) begin
								`load_weight(layercount + 405)
							end else if (inlayercount == 64) begin
								`load_weight(layercount + 469)
							end else begin
								`load_weight(layercount + 533)
							end
							
							`load_qt(5)
							
					
							for (i=0; i<32; i=i+1) begin
								// filters
								intermediate[i] <= cv_pixelout[i];
							end
							
							
							// add bias and quantization
							qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
											+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
											+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
											+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
											+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
											+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
											+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
											+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
							
							// save to buffer
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [255:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
							//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
							//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
							//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
							//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
							//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
							//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
							//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
							//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
							//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
							//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
							//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
							//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
							//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
							
							case (layercount)
								32'd1:  savebuffer[31:24] <= {qt0_res};
								32'd2:  savebuffer[23:16] <= {qt0_res};
								32'd3:  savebuffer[15:8]  <= {qt0_res};
								32'd4:  layerint_buf0_st5[(pixelcount-9)] <= {int8_add(layerint_buf0_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf0_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf0_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf0_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd5:  savebuffer[31:24] <= {qt0_res};
								32'd6:  savebuffer[23:16] <= {qt0_res};
								32'd7:  savebuffer[15:8]  <= {qt0_res};
								32'd8:  layerint_buf1_st5[(pixelcount-9)] <= {int8_add(layerint_buf1_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf1_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf1_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf1_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd9:  savebuffer[31:24] <= {qt0_res};
								32'd10: savebuffer[23:16] <= {qt0_res};
								32'd11: savebuffer[15:8]  <= {qt0_res};
								32'd12: layerint_buf2_st5[(pixelcount-9)] <= {int8_add(layerint_buf2_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf2_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf2_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf2_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd13: savebuffer[31:24] <= {qt0_res};
								32'd14: savebuffer[23:16] <= {qt0_res};
								32'd15: savebuffer[15:8]  <= {qt0_res};
								32'd16: layerint_buf3_st5[(pixelcount-9)] <= {int8_add(layerint_buf3_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf3_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf3_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf3_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd17: savebuffer[31:24] <= {qt0_res};
								32'd18: savebuffer[23:16] <= {qt0_res};
								32'd19: savebuffer[15:8]  <= {qt0_res};
								32'd20: layerint_buf4_st5[(pixelcount-9)] <= {int8_add(layerint_buf4_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf4_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf4_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf4_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd21: savebuffer[31:24] <= {qt0_res};
								32'd22: savebuffer[23:16] <= {qt0_res};
								32'd23: savebuffer[15:8]  <= {qt0_res};
								32'd24: layerint_buf5_st5[(pixelcount-9)] <= {int8_add(layerint_buf5_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf5_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf5_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf5_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd25: savebuffer[31:24] <= {qt0_res};
								32'd26: savebuffer[23:16] <= {qt0_res};
								32'd27: savebuffer[15:8]  <= {qt0_res};
								32'd28: layerint_buf6_st5[(pixelcount-9)] <= {int8_add(layerint_buf6_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf6_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf6_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf6_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd29: savebuffer[31:24] <= {qt0_res};
								32'd30: savebuffer[23:16] <= {qt0_res};
								32'd31: savebuffer[15:8]  <= {qt0_res};
								32'd32: layerint_buf7_st5[(pixelcount-9)] <= {int8_add(layerint_buf7_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf7_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf7_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf7_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd33: savebuffer[31:24] <= {qt0_res};
								32'd34: savebuffer[23:16] <= {qt0_res};
								32'd35: savebuffer[15:8]  <= {qt0_res};
								32'd36: layerint_buf8_st5[(pixelcount-9)] <= {int8_add(layerint_buf8_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf8_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf8_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf8_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd37: savebuffer[31:24] <= {qt0_res};
								32'd38: savebuffer[23:16] <= {qt0_res};
								32'd39: savebuffer[15:8]  <= {qt0_res};
								32'd40: layerint_buf9_st5[(pixelcount-9)] <= {int8_add(layerint_buf9_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							 int8_add(layerint_buf9_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							 int8_add(layerint_buf9_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							 int8_add(layerint_buf9_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd41: savebuffer[31:24] <= {qt0_res};
								32'd42: savebuffer[23:16] <= {qt0_res};
								32'd43: savebuffer[15:8]  <= {qt0_res};
								32'd44: layerint_buf10_st5[(pixelcount-9)] <= {int8_add(layerint_buf10_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
									  													     int8_add(layerint_buf10_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf10_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf10_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd45: savebuffer[31:24] <= {qt0_res};
								32'd46: savebuffer[23:16] <= {qt0_res};
								32'd47: savebuffer[15:8]  <= {qt0_res};
								32'd48: layerint_buf11_st5[(pixelcount-9)] <= {int8_add(layerint_buf11_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf11_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf11_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf11_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd49: savebuffer[31:24] <= {qt0_res};
								32'd50: savebuffer[23:16] <= {qt0_res};
								32'd51: savebuffer[15:8]  <= {qt0_res};
								32'd52: layerint_buf12_st5[(pixelcount-9)] <= {int8_add(layerint_buf12_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							   int8_add(layerint_buf12_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							   int8_add(layerint_buf12_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							   int8_add(layerint_buf12_st5[(pixelcount-9)][7:0], qt0_res)};
								32'd53: savebuffer[31:24] <= {qt0_res};
								32'd54: savebuffer[23:16] <= {qt0_res};
								32'd55: savebuffer[15:8]  <= {qt0_res};
								32'd56: layerint_buf13_st5[(pixelcount-9)] <= {int8_add(layerint_buf13_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf13_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf13_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf13_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd57: savebuffer[31:24] <= {qt0_res};
								32'd58: savebuffer[23:16] <= {qt0_res};
								32'd59: savebuffer[15:8]  <= {qt0_res};
								32'd60: layerint_buf14_st5[(pixelcount-9)] <= {int8_add(layerint_buf14_st5[(pixelcount-9)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf14_st5[(pixelcount-9)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf14_st5[(pixelcount-9)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf14_st5[(pixelcount-9)][7:0]  , qt0_res)};
								32'd61: savebuffer[31:24] <= {qt0_res};
								32'd62: savebuffer[23:16] <= {qt0_res};
								32'd63: savebuffer[15:8]  <= {qt0_res};
								32'd0:  
									begin
										if (pixelcount > 9)
											layerint_buf15_st5[(pixelcount-10)] <= {int8_add(layerint_buf15_st5[(pixelcount-10)][31:24], savebuffer[31:24]), 
																							    int8_add(layerint_buf15_st5[(pixelcount-10)][23:16], savebuffer[23:16]),
																							    int8_add(layerint_buf15_st5[(pixelcount-10)][15:8] , savebuffer[15:8]), 
																							    int8_add(layerint_buf15_st5[(pixelcount-10)][7:0]  , qt0_res)};
									end
							endcase
						end else begin
							pixelcount <= pixelcount + 1;
						end
					end
					
				STAGE6_CONV:
					// 64 (16x16) + 64 (16x16) STAGE4_CONV Layers ---> 64 (16x16) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 64 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 64
					// pixel2...
					// ...
					// pixel100...
					
					begin
						if (pixelcount >= 17) begin  // ( width+1 for the padding )
							if (pixelcount == 273) begin  // (height*width + (width+1) for padding)
								pixelcount <= 0;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								
								if (inlayercount == 96) begin
									state <= STAGE7_TRANSCONV;
									inlayercount <= 0;
								end else begin
									inlayercount <= inlayercount + 32;
								end
							
							end else if (layercount == 63) begin
								layercount <= 0;
								pixelcount <= pixelcount + 1;
								if (pixelcount == 272) for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
							end else begin							
								layercount <= layercount + 1;
							end
							
							
							// Loading weights
							if (inlayercount == 0) begin
								`load_weight(layercount + 597)
							end else if (inlayercount == 32) begin
								`load_weight(layercount + 661)
							end else if (inlayercount == 64) begin
								`load_weight(layercount + 725)
							end else begin
								`load_weight(layercount + 789)
							end
							
							`load_qt(6)
							
								
							// Convolution
							for (i=0; i<32; i=i+1) begin
								// filters
								intermediate[i] <= cv_pixelout[i];
							end
							
							// add bias and quantization
							//qt0
							qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
											+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
											+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
											+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
											+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
											+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
											+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
											+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
							
							// save to buffer
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [255:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
							//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
							//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
							//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
							//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
							//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
							//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
							//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
							//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
							//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
							//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
							//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
							//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
							//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
							
							case (layercount)
								32'd1:  savebuffer[31:24] <= {qt0_res};
								32'd2:  savebuffer[23:16] <= {qt0_res};
								32'd3:  savebuffer[15:8]  <= {qt0_res};
								32'd4:  layerint_buf0_st5[(pixelcount-17)] <= {int8_add(layerint_buf0_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf0_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf0_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf0_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd5:  savebuffer[31:24] <= {qt0_res};
								32'd6:  savebuffer[23:16] <= {qt0_res};
								32'd7:  savebuffer[15:8]  <= {qt0_res};
								32'd8:  layerint_buf1_st5[(pixelcount-17)] <= {int8_add(layerint_buf1_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf1_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf1_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf1_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd9:  savebuffer[31:24] <= {qt0_res};
								32'd10: savebuffer[23:16] <= {qt0_res};
								32'd11: savebuffer[15:8]  <= {qt0_res};
								32'd12: layerint_buf2_st5[(pixelcount-17)] <= {int8_add(layerint_buf2_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf2_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf2_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf2_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd13: savebuffer[31:24] <= {qt0_res};
								32'd14: savebuffer[23:16] <= {qt0_res};
								32'd15: savebuffer[15:8]  <= {qt0_res};
								32'd16: layerint_buf3_st5[(pixelcount-17)] <= {int8_add(layerint_buf3_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf3_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf3_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf3_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd17: savebuffer[31:24] <= {qt0_res};
								32'd18: savebuffer[23:16] <= {qt0_res};
								32'd19: savebuffer[15:8]  <= {qt0_res};
								32'd20: layerint_buf4_st5[(pixelcount-17)] <= {int8_add(layerint_buf4_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf4_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf4_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf4_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd21: savebuffer[31:24] <= {qt0_res};
								32'd22: savebuffer[23:16] <= {qt0_res};
								32'd23: savebuffer[15:8]  <= {qt0_res};
								32'd24: layerint_buf5_st5[(pixelcount-17)] <= {int8_add(layerint_buf5_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf5_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf5_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf5_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd25: savebuffer[31:24] <= {qt0_res};
								32'd26: savebuffer[23:16] <= {qt0_res};
								32'd27: savebuffer[15:8]  <= {qt0_res};
								32'd28: layerint_buf6_st5[(pixelcount-17)] <= {int8_add(layerint_buf6_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf6_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf6_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf6_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd29: savebuffer[31:24] <= {qt0_res};
								32'd30: savebuffer[23:16] <= {qt0_res};
								32'd31: savebuffer[15:8]  <= {qt0_res};
								32'd32: layerint_buf7_st5[(pixelcount-17)] <= {int8_add(layerint_buf7_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf7_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf7_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf7_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd33: savebuffer[31:24] <= {qt0_res};
								32'd34: savebuffer[23:16] <= {qt0_res};
								32'd35: savebuffer[15:8]  <= {qt0_res};
								32'd36: layerint_buf8_st5[(pixelcount-17)] <= {int8_add(layerint_buf8_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf8_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf8_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf8_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd37: savebuffer[31:24] <= {qt0_res};
								32'd38: savebuffer[23:16] <= {qt0_res};
								32'd39: savebuffer[15:8]  <= {qt0_res};
								32'd40: layerint_buf9_st5[(pixelcount-17)] <= {int8_add(layerint_buf9_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf9_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf9_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf9_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd41: savebuffer[31:24] <= {qt0_res};
								32'd42: savebuffer[23:16] <= {qt0_res};
								32'd43: savebuffer[15:8]  <= {qt0_res};
								32'd44: layerint_buf10_st5[(pixelcount-17)] <= {int8_add(layerint_buf10_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							   int8_add(layerint_buf10_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							   int8_add(layerint_buf10_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							   int8_add(layerint_buf10_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd45: savebuffer[31:24] <= {qt0_res};
								32'd46: savebuffer[23:16] <= {qt0_res};
								32'd47: savebuffer[15:8]  <= {qt0_res};
								32'd48: layerint_buf11_st5[(pixelcount-17)] <= {int8_add(layerint_buf11_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							   int8_add(layerint_buf11_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							   int8_add(layerint_buf11_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							   int8_add(layerint_buf11_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd49: savebuffer[31:24] <= {qt0_res};
								32'd50: savebuffer[23:16] <= {qt0_res};
								32'd51: savebuffer[15:8]  <= {qt0_res};
								32'd52: layerint_buf12_st5[(pixelcount-17)] <= {int8_add(layerint_buf12_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							   int8_add(layerint_buf12_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							   int8_add(layerint_buf12_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							   int8_add(layerint_buf12_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd53: savebuffer[31:24] <= {qt0_res};
								32'd54: savebuffer[23:16] <= {qt0_res};
								32'd55: savebuffer[15:8]  <= {qt0_res};
								32'd56: layerint_buf13_st5[(pixelcount-17)] <= {int8_add(layerint_buf13_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							   int8_add(layerint_buf13_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							   int8_add(layerint_buf13_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							   int8_add(layerint_buf13_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd57: savebuffer[31:24] <= {qt0_res};
								32'd58: savebuffer[23:16] <= {qt0_res};
								32'd59: savebuffer[15:8]  <= {qt0_res};
								32'd60: layerint_buf14_st5[(pixelcount-17)] <= {int8_add(layerint_buf14_st5[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							   int8_add(layerint_buf14_st5[(pixelcount-17)][23:16], savebuffer[23:16]),
																							   int8_add(layerint_buf14_st5[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							   int8_add(layerint_buf14_st5[(pixelcount-17)][7:0]  , qt0_res)};
								32'd61: savebuffer[31:24] <= {qt0_res};
								32'd62: savebuffer[23:16] <= {qt0_res};
								32'd63: savebuffer[15:8]  <= {qt0_res};
								32'd0:  
									begin
										if (pixelcount > 17)
											layerint_buf15_st5[(pixelcount-18)] <= {int8_add(layerint_buf15_st5[(pixelcount-18)][31:24], savebuffer[31:24]), 
																							    int8_add(layerint_buf15_st5[(pixelcount-18)][23:16], savebuffer[23:16]),
																							    int8_add(layerint_buf15_st5[(pixelcount-18)][15:8] , savebuffer[15:8]), 
																							    int8_add(layerint_buf15_st5[(pixelcount-18)][7:0]  , qt0_res)};
									end
							endcase
							
						end else begin
							pixelcount <= pixelcount + 1;
						end
					end
					
				STAGE7_TRANSCONV:
					// 64 (16x16) Layers ---> 32 (32x32) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 32 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 32
					// pixel2...
					// ...
					// pixel100...
					
					begin
						if (pixelcount >= 17) begin  // ( width+1 for the padding )
							if (pixelcount == 273) begin  // (height*width + (width+1) for padding)
								pixelcount <= 0;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								
								if (inlayercount == 32) begin
									state <= STAGE7_CONV;
									inlayercount <= 0;
								end else begin
									inlayercount <= inlayercount + 32;
								end
								
							end else if (layercount == 31) begin
								layercount <= 0;
								pixelcount <= pixelcount + 1;
								if (pixelcount == 272) for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								layercount <= layercount + 1;
							end
							
							
							// Loading weights
							if (inlayercount == 0) begin
								`load_weight(layercount + 859)
							end else begin
								`load_weight(layercount + 891)
							end
							
							`load_qt(7)
							
															
							// transconv
							for (i=0; i<32; i=i+1) begin
								// filters
								intermediate[i] <= cv_pixelout[i];
							end
							
							
							// add bias and quantization
							//qt0
							qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
											+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
											+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
											+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
											+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
											+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
											+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
											+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
							
							// save to buffer
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [1023:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
							//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
							//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
							//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
							//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
							//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
							// 			
							
							case (layercount)
								32'd1:  savebuffer[31:24] <= {qt0_res};
								32'd2:  savebuffer[23:16] <= {qt0_res};
								32'd3:  savebuffer[15:8]  <= {qt0_res};
								32'd4:  layerint_buf0_st4[(pixelcount-17)] <= {int8_add(layerint_buf0_st4[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf0_st4[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf0_st4[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf0_st4[(pixelcount-17)][7:0]  , qt0_res)};
								32'd5:  savebuffer[31:24] <= {qt0_res};
								32'd6:  savebuffer[23:16] <= {qt0_res};
								32'd7:  savebuffer[15:8]  <= {qt0_res};
								32'd8:  layerint_buf1_st4[(pixelcount-17)] <= {int8_add(layerint_buf1_st4[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf1_st4[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf1_st4[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf1_st4[(pixelcount-17)][7:0]  , qt0_res)};
								32'd9:  savebuffer[31:24] <= {qt0_res};
								32'd10: savebuffer[23:16] <= {qt0_res};
								32'd11: savebuffer[15:8]  <= {qt0_res};
								32'd12: layerint_buf2_st4[(pixelcount-17)] <= {int8_add(layerint_buf2_st4[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf2_st4[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf2_st4[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf2_st4[(pixelcount-17)][7:0]  , qt0_res)};
								32'd13: savebuffer[31:24] <= {qt0_res};
								32'd14: savebuffer[23:16] <= {qt0_res};
								32'd15: savebuffer[15:8]  <= {qt0_res};
								32'd16: layerint_buf3_st4[(pixelcount-17)] <= {int8_add(layerint_buf3_st4[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf3_st4[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf3_st4[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf3_st4[(pixelcount-17)][7:0]  , qt0_res)};
								32'd17: savebuffer[31:24] <= {qt0_res};
								32'd18: savebuffer[23:16] <= {qt0_res};
								32'd19: savebuffer[15:8]  <= {qt0_res};
								32'd20: layerint_buf4_st4[(pixelcount-17)] <= {int8_add(layerint_buf4_st4[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf4_st4[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf4_st4[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf4_st4[(pixelcount-17)][7:0]  , qt0_res)};
								32'd21: savebuffer[31:24] <= {qt0_res};
								32'd22: savebuffer[23:16] <= {qt0_res};
								32'd23: savebuffer[15:8]  <= {qt0_res};
								32'd24: layerint_buf5_st4[(pixelcount-17)] <= {int8_add(layerint_buf5_st4[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf5_st4[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf5_st4[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf5_st4[(pixelcount-17)][7:0]  , qt0_res)};
								32'd25: savebuffer[31:24] <= {qt0_res};
								32'd26: savebuffer[23:16] <= {qt0_res};
								32'd27: savebuffer[15:8]  <= {qt0_res};
								32'd28: layerint_buf6_st4[(pixelcount-17)] <= {int8_add(layerint_buf6_st4[(pixelcount-17)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf6_st4[(pixelcount-17)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf6_st4[(pixelcount-17)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf6_st4[(pixelcount-17)][7:0]  , qt0_res)};
								32'd29: savebuffer[31:24] <= {qt0_res};
								32'd30: savebuffer[23:16] <= {qt0_res};
								32'd31: savebuffer[15:8]  <= {qt0_res};
								32'd0:
									begin
										if (pixelcount > 17)
											layerint_buf7_st4[(pixelcount-18)] <= {int8_add(layerint_buf7_st4[(pixelcount-18)][31:24], savebuffer[31:24]), 
																								int8_add(layerint_buf7_st4[(pixelcount-18)][23:16], savebuffer[23:16]),
																								int8_add(layerint_buf7_st4[(pixelcount-18)][15:8] , savebuffer[15:8]), 
																								int8_add(layerint_buf7_st4[(pixelcount-18)][7:0]  , qt0_res)};
									end
							endcase
						
						end else begin
							pixelcount <= pixelcount + 1;
						end
					end
				
				STAGE7_CONV:
					// 32 (32x32) + 32 (32x32) STAGE3_CONV Layers ---> 32 (32x32) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 32 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 32
					// pixel2...
					// ...

					
					begin
						if (pixelcount >= 33) begin  // ( width+2 for the padding )
							if (pixelcount == 1057) begin  // (height*width + (width+1) for padding)
								pixelcount <= 0;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								
								if (inlayercount == 32) begin
									state <= STAGE8_TRANSCONV;
									inlayercount <= 0;
								end else begin
									inlayercount <= inlayercount + 32;
								end
								
							end else if (layercount == 31) begin
								layercount <= 0;
								pixelcount <= pixelcount + 1;
								if (pixelcount == 1056) for (l=0; l<32; l=l+1) cv_rst[l] <= 0; // reset
							end else begin
								layercount <= layercount + 1;
							end
								
							
							// Loading weights
							if (inlayercount == 0) begin
								`load_weight(layercount + 923)
							end else begin
								`load_weight(layercount + 955)
							end
							
							`load_qt(8)
							
							
							for (i=0; i<32; i=i+1) begin
								// filters
								intermediate[i] <= cv_pixelout[i];
							end
							
							// add bias and quantization
							//qt0
							qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
											+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
											+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
											+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
											+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
											+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
											+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
											+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
							
							// save to buffer
							//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
							// ------------------------------------------------------------------------------- Q1 [1023:0]
							//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
							//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
							//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
							//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
							//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
							//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
							//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
							//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
							// 			
							
							case (layercount)
								32'd1:  savebuffer[31:24] <= {qt0_res};
								32'd2:  savebuffer[23:16] <= {qt0_res};
								32'd3:  savebuffer[15:8]  <= {qt0_res};
								32'd4:  layerint_buf0_st3[(pixelcount-33)] <= {int8_add(layerint_buf0_st3[(pixelcount-33)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf0_st3[(pixelcount-33)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf0_st3[(pixelcount-33)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf0_st3[(pixelcount-33)][7:0]  , qt0_res)};
								32'd5:  savebuffer[31:24] <= {qt0_res};
								32'd6:  savebuffer[23:16] <= {qt0_res};
								32'd7:  savebuffer[15:8]  <= {qt0_res};
								32'd8:  layerint_buf1_st3[(pixelcount-33)] <= {int8_add(layerint_buf1_st3[(pixelcount-33)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf1_st3[(pixelcount-33)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf1_st3[(pixelcount-33)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf1_st3[(pixelcount-33)][7:0]  , qt0_res)};
								32'd9:  savebuffer[31:24] <= {qt0_res};
								32'd10: savebuffer[23:16] <= {qt0_res};
								32'd11: savebuffer[15:8]  <= {qt0_res};
								32'd12: layerint_buf2_st3[(pixelcount-33)] <= {int8_add(layerint_buf2_st3[(pixelcount-33)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf2_st3[(pixelcount-33)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf2_st3[(pixelcount-33)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf2_st3[(pixelcount-33)][7:0]  , qt0_res)};
								32'd13: savebuffer[31:24] <= {qt0_res};
								32'd14: savebuffer[23:16] <= {qt0_res};
								32'd15: savebuffer[15:8]  <= {qt0_res};
								32'd16: layerint_buf3_st3[(pixelcount-33)] <= {int8_add(layerint_buf3_st3[(pixelcount-33)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf3_st3[(pixelcount-33)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf3_st3[(pixelcount-33)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf3_st3[(pixelcount-33)][7:0]  , qt0_res)};
								32'd17: savebuffer[31:24] <= {qt0_res};
								32'd18: savebuffer[23:16] <= {qt0_res};
								32'd19: savebuffer[15:8]  <= {qt0_res};
								32'd20: layerint_buf4_st3[(pixelcount-33)] <= {int8_add(layerint_buf4_st3[(pixelcount-33)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf4_st3[(pixelcount-33)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf4_st3[(pixelcount-33)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf4_st3[(pixelcount-33)][7:0]  , qt0_res)};
								32'd21: savebuffer[31:24] <= {qt0_res};
								32'd22: savebuffer[23:16] <= {qt0_res};
								32'd23: savebuffer[15:8]  <= {qt0_res};
								32'd24: layerint_buf5_st3[(pixelcount-33)] <= {int8_add(layerint_buf5_st3[(pixelcount-33)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf5_st3[(pixelcount-33)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf5_st3[(pixelcount-33)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf5_st3[(pixelcount-33)][7:0]  , qt0_res)};
								32'd25: savebuffer[31:24] <= {qt0_res};
								32'd26: savebuffer[23:16] <= {qt0_res};
								32'd27: savebuffer[15:8]  <= {qt0_res};
								32'd28: layerint_buf6_st3[(pixelcount-33)] <= {int8_add(layerint_buf6_st3[(pixelcount-33)][31:24], savebuffer[31:24]), 
																							  int8_add(layerint_buf6_st3[(pixelcount-33)][23:16], savebuffer[23:16]),
																							  int8_add(layerint_buf6_st3[(pixelcount-33)][15:8] , savebuffer[15:8]), 
																							  int8_add(layerint_buf6_st3[(pixelcount-33)][7:0]  , qt0_res)};
								32'd29: savebuffer[31:24] <= {qt0_res};
								32'd30: savebuffer[23:16] <= {qt0_res};
								32'd31: savebuffer[15:8]  <= {qt0_res};
								32'd0:  
									begin
										if (pixelcount > 33)
											layerint_buf7_st3[(pixelcount-34)] <= {int8_add(layerint_buf7_st3[(pixelcount-34)][31:24], savebuffer[31:24]), 
																							   int8_add(layerint_buf7_st3[(pixelcount-34)][23:16], savebuffer[23:16]),
																							   int8_add(layerint_buf7_st3[(pixelcount-34)][15:8] , savebuffer[15:8]), 
																							   int8_add(layerint_buf7_st3[(pixelcount-34)][7:0]  , qt0_res)};
									end
							endcase
						end else begin
							pixelcount <= pixelcount + 1;
						end
					end
					
				STAGE8_TRANSCONV:
					// 32 (32x32) Layers ---> 16 (64x64) Layers
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 16
					// pixel2...
					//
					begin
						if (pixelcount >= 32'd1058) begin  // (height*width + (width) for padding + 2)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <= STAGE8_CONV;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount >= 33) begin  // ( width+1 for the padding )
							
								if (pixelcount == 1057) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;  // Reset
								end else if (layercount == 15) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								end else begin
									layercount <= layercount + 1;
								end
								
								
								// Loading weights
								`load_weight(layercount + 987)
								`load_qt(9)

								for (i=0; i<32; i=i+1) begin
									// filters
									intermediate[i] <= cv_pixelout[i];
								end
								
								// add bias and quantization
								//qt0
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
												+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
												+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
												+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
												+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
												+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
												+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
												+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
								// save to buffer
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [2047:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
								//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
								// ------------------------------------------------------------------------------- Q2 [4095:2048]
								//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
								//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
								//   layerint_buf6         L9-P2048       L10-P2048      L11-P2048     L12-P2048
								//   layerint_buf7         L13-P2048      L14-P2048      L15-P2048     L16-P2048
								// 
								
								case (layercount)
									32'd1:  savebuffer[31:24] <= {qt0_res};
									32'd2:  savebuffer[23:16] <= {qt0_res};
									32'd3:  savebuffer[15:8]  <= {qt0_res};
									32'd4:  
										begin
											if (pixelcount < 32'd2081)
												layerint_buf0_st3[(pixelcount-33)] <= {savebuffer[31:8], qt0_res};
											else
												layerint_buf4_st3[(pixelcount-2081)] <= {savebuffer[31:8], qt0_res};
										end
									32'd5:  savebuffer[31:24] <= {qt0_res};
									32'd6:  savebuffer[23:16] <= {qt0_res};
									32'd7:  savebuffer[15:8]  <= {qt0_res};
									32'd8:  
										begin
											if (pixelcount < 32'd2081)
												layerint_buf1_st3[(pixelcount-33)] <= {savebuffer[31:8], qt0_res};
											else
												layerint_buf5_st3[(pixelcount-2081)] <= {savebuffer[31:8], qt0_res};
										end
									32'd9:  savebuffer[31:24] <= {qt0_res};
									32'd10: savebuffer[23:16] <= {qt0_res};
									32'd11: savebuffer[15:8]  <= {qt0_res};
									32'd12: 
										begin
											if (pixelcount < 32'd2081)
												layerint_buf2_st3[(pixelcount-33)] <= {savebuffer[31:8], qt0_res};
											else
												layerint_buf6_st3[(pixelcount-2081)] <= {savebuffer[31:8], qt0_res};
										end
									32'd13: savebuffer[31:24] <= {qt0_res};
									32'd14: savebuffer[23:16] <= {qt0_res};
									32'd15: savebuffer[15:8]  <= {qt0_res};
									32'd0:  
										begin
											if (pixelcount > 33) begin
												if (pixelcount < 32'd2082)
													layerint_buf3_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												else
													layerint_buf7_st3[(pixelcount-2082)] <= {savebuffer[31:8], qt0_res};
											end
										end
								endcase
							end else begin
								pixelcount <= pixelcount + 1;
							end
						end
					end
				
				STAGE8_CONV:
					// 16 (64x64) + 16 (64x64) STAGE2_CONV Layers ---> 16 (64x64) Layers
					//
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 16
					// pixel2...
					//
					begin
						if (pixelcount >= 32'd4162) begin  // (height*width + (width+1) for padding)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <=  STAGE9_TRANSCONV;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount >= 65) begin  // ( width+2 for the padding )
								if (pixelcount == 4161) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;//Reset
								end else if (layercount == 15) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								end else begin
									layercount <= layercount + 1;
								end
							
								`load_weight(layercount + 1003)
								`load_qt(10)

								for (i=0; i<32; i=i+1) begin
									// filters
									intermediate[i] <= cv_pixelout[i];
								end
								
								// add bias and quantization
								//qt0
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
												+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
												+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
												+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
												+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
												+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
												+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
												+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
								// save to buffer
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [2047:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
								//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
								// ------------------------------------------------------------------------------- Q2 [4095:2048]
								//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
								//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
								//   layerint_buf6         L9-P2048       L10-P2048      L11-P2048     L12-P2048
								//   layerint_buf7         L13-P2048      L14-P2048      L15-P2048     L16-P2048
								// 
								
								case (layercount)
									32'd1:  savebuffer[31:24] <= {qt0_res};
									32'd2:  savebuffer[23:16] <= {qt0_res};
									32'd3:  savebuffer[15:8]  <= {qt0_res};
									32'd4:  
										begin
											if (pixelcount < 32'd2113)
												layerint_buf0_st2[(pixelcount-65)] <= {savebuffer[31:8], qt0_res};
											else
												layerint_buf4_st2[(pixelcount-2114)] <= {savebuffer[31:8], qt0_res};
										end
									32'd5:  savebuffer[31:24] <= {qt0_res};
									32'd6:  savebuffer[23:16] <= {qt0_res};
									32'd7:  savebuffer[15:8]  <= {qt0_res};
									32'd8:  
										begin
											if (pixelcount < 32'd2113)
												layerint_buf1_st2[(pixelcount-65)] <= {savebuffer[31:8], qt0_res};
											else
												layerint_buf5_st2[(pixelcount-2114)] <= {savebuffer[31:8], qt0_res};
										end
									32'd9:  savebuffer[31:24] <= {qt0_res};
									32'd10: savebuffer[23:16] <= {qt0_res};
									32'd11: savebuffer[15:8]  <= {qt0_res};
									32'd12: 
										begin
											if (pixelcount < 32'd2113)
												layerint_buf2_st2[(pixelcount-65)] <= {savebuffer[31:8], qt0_res};
											else
												layerint_buf6_st2[(pixelcount-2114)] <= {savebuffer[31:8], qt0_res};
										end
									32'd13: savebuffer[31:24] <= {qt0_res};
									32'd14: savebuffer[23:16] <= {qt0_res};
									32'd15: savebuffer[15:8]  <= {qt0_res};
									32'd0: 
										begin
											if (pixelcount > 65) begin
												if (pixelcount < 32'd2114)
													layerint_buf3_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
												else
													layerint_buf7_st2[(pixelcount-2115)] <= {savebuffer[31:8], qt0_res};
											end
										end
								endcase
							end else begin
								pixelcount <= pixelcount + 1;
							end
						end
					end
					
				STAGE9_TRANSCONV:
					// 16 (64x64) Layers ---> 8 (128x128) Layers
					// pixel1 - calc outlayers 1,2
					//          calc outlayers 3,4
					//          ...
					//          calc outlayers 7,8
					// pixel2...
					//
					begin
						if (pixelcount >= 32'd4162) begin  // (height*width + (width) for padding + 2)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <= STAGE9_CONV;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount >= 65) begin  // ( width+1 for the padding )
								if (pixelcount == 4161) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
								end else if (layercount == 6) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								end else begin
									layercount <= layercount + 2;
								end
									
									
								case (layercount)
									32'd0:  begin `load_weight(1019) end
									32'd2:  begin `load_weight(1020) end
									32'd4:  begin `load_weight(1021) end
									32'd6:  begin `load_weight(1022) end
									
									default:
										begin
											for (i=0; i<32; i=i+1) begin
												for (w=1; w<10; w=w+1) begin
													cv_w[i][w]    <= 0;
												end
											end
										end
								endcase		
								
								`load_qt(11)
								
			
								for (i=0; i<32; i=i+16) begin
									// filters
									for (j=0; j<16; j=j+1) begin 
										intermediate[i+j] <= cv_pixelout[i+j];
									end
								end
								
								// add bias and quantization
								//qt0
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
												+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
												+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
												+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15];
								
								//qt1
								qt1_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
												+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
												+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
												+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
								// save to buffer
								// save image to buffer, seperated to 4 pices
								// 
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [4095:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								// ------------------------------------------------------------------------------- Q2 [8191:4096]
								//   layerint_buf2         L1-P4224       L2-P4224       L3-P4224      L4-P4224
								//   layerint_buf3         L5-P4224       L6-P4224       L7-P4224      L8-P4224
								// ------------------------------------------------------------------------------- Q3 [12287:8192]
								//   layerint_buf4         L1-P8449       L2-P8449       L3-P8449      L4-P8449
								//   layerint_buf5         L5-P8449       L6-P8449       L7-P8449      L8-P8449
								// ------------------------------------------------------------------------------- Q4 [16383:12288]
								//   layerint_buf6         L1-P12674      L2-P12674      L3-P12674     L4-P12674
								//   layerint_buf7         L5-P12674      L6-P12674      L7-P12674     L8-P12674
								
								case (layercount)
									32'd2:  savebuffer[31:16] <= {qt0_res, qt1_res};
									
									32'd4:  
										begin
											if (pixelcount < 4161)
												layerint_buf0_st2[(pixelcount-65)] <= {savebuffer[31:16], qt0_res, qt1_res};  
											else if (pixelcount < 8257)
												layerint_buf2_st2[(pixelcount-4161)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
											else if (pixelcount <12353)
												layerint_buf4_st2[(pixelcount-8257)] <= {savebuffer[31:16], qt0_res, qt1_res};  
											else
												layerint_buf6_st2[(pixelcount-12353)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
										end
										
									32'd6:  savebuffer[31:16] <= {qt0_res, qt1_res};
									
									32'd0:  
										begin	
											if (pixelcount > 65)	begin
												if (pixelcount < 4162)
													layerint_buf0_st2[(pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res};  
												else if (pixelcount < 8258)
													layerint_buf2_st2[(pixelcount-4162)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
												else if (pixelcount <12354)
													layerint_buf4_st2[(pixelcount-8258)] <= {savebuffer[31:16], qt0_res, qt1_res};  
												else
													layerint_buf6_st2[(pixelcount-12354)] <= {savebuffer[31:16], qt0_res, qt1_res};
											end
										end
								endcase
							end else begin
								pixelcount <= pixelcount + 1;
							end
						end
					end
					
				STAGE9_CONV:
					// 8 (128x128) + 8 (128x128) STAGE1_CONV Layers ---> 8 (128x128) Layers
					//
					// pixel1 - calc outlayers 1,2
					//          calc outlayers 3,4
					//          ...
					//          calc outlayers 7,8
					// pixel2...
					//
					begin
						if (pixelcount >= 32'd16514) begin  // (height*width + (width) for padding + 2)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <= STAGE10_CONV;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount >= 129) begin  // ( width+1 for the padding )
								
								if (pixelcount == 16513) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0; // Reset
								end else if (layercount == 6) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								end else begin
									layercount <= layercount + 2;
								end
								
								
								case (layercount)
									32'd0:  begin `load_weight(1023) end
									32'd2:  begin `load_weight(1024) end
									32'd4:  begin `load_weight(1025) end
									32'd6:  begin `load_weight(1026) end
										
									default:
										begin
											for (i=0; i<32; i=i+1) begin
												for (w=1; w<10; w=w+1) begin
													cv_w[i][w]    <= 0;
												end
											end
										end
								endcase			
								
								`load_qt(12)
								
			
								for (i=0; i<32; i=i+16) begin
									// filters
									for (j=0; j<16; j=j+1) begin 
										intermediate[i+j] <= cv_pixelout[i+j];
									end
								end
								
								// add bias and quantization
								//qt0
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
												+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
												+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
												+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15];
								
								//qt1
								qt1_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
												+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
												+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
												+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
								// save to buffer
								// save image to buffer, seperated to 4 pices
								// 
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [4095:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								// ------------------------------------------------------------------------------- Q2 [8191:4096]
								//   layerint_buf2         L1-P4224       L2-P4224       L3-P4224      L4-P4224
								//   layerint_buf3         L5-P4224       L6-P4224       L7-P4224      L8-P4224
								// ------------------------------------------------------------------------------- Q3 [12287:8192]
								//   layerint_buf4         L1-P8449       L2-P8449       L3-P8449      L4-P8449
								//   layerint_buf5         L5-P8449       L6-P8449       L7-P8449      L8-P8449
								// ------------------------------------------------------------------------------- Q4 [16383:12288]
								//   layerint_buf6         L1-P12674      L2-P12674      L3-P12674     L4-P12674
								//   layerint_buf7         L5-P12674      L6-P12674      L7-P12674     L8-P12674
								// 
								
								case (layercount)
									32'd2:  savebuffer[31:16] <= {qt0_res, qt1_res};
									
									32'd4:  
										begin
											if (pixelcount < 4225)
												layerint_buf0_st2[(pixelcount-129)] <= {savebuffer[31:16], qt0_res, qt1_res};  
											else if (pixelcount < 8321)
												layerint_buf2_st2[(pixelcount-4225)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
											else if (pixelcount <12417)
												layerint_buf4_st2[(pixelcount-8321)] <= {savebuffer[31:16], qt0_res, qt1_res};  
											else
												layerint_buf6_st2[(pixelcount-12417)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
										end
										
									32'd6:  savebuffer[31:16] <= {qt0_res, qt1_res};
									
									32'd0:  
										begin	
											if (pixelcount > 129) begin
												if (pixelcount < 4226)
													layerint_buf0_st2[(pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};  
												else if (pixelcount < 8322)
													layerint_buf2_st2[(pixelcount-4226)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
												else if (pixelcount <12418)
													layerint_buf4_st2[(pixelcount-8322)] <= {savebuffer[31:16], qt0_res, qt1_res};  
												else
													layerint_buf6_st2[(pixelcount-12418)] <= {savebuffer[31:16], qt0_res, qt1_res};
											end
										end
								endcase		
							end else begin
								pixelcount <= pixelcount + 1;
							end
						end
					end
					
				STAGE10_CONV:
					begin
						// 8 (128x128) ---> 16 (128x128) Layers
						//
						// pixel1 - calc outlayers 1,2
						//          calc outlayers 3,4
						//          ...
						//          calc outlayers 14,15
						// pixel2...
						//
						if (pixelcount >= 32'd16514) begin  // (height*width + (width) for padding + 2)
							
							for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
							state <= SEND;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount >= 129) begin  // ( width+2 for the padding )
								
								if (pixelcount == 16513) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0; // Reset
								end else if (layercount == 14) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								end else begin
									layercount <= layercount + 2;
								end
								
									
								case (layercount)
									32'd0:  begin `load_weight(1027) end
									32'd2:  begin `load_weight(1028) end
									32'd4:  begin `load_weight(1029) end
									32'd6:  begin `load_weight(1030) end
									32'd8:  begin `load_weight(1031) end
									32'd10: begin `load_weight(1032) end
									32'd12: begin `load_weight(1033) end
									32'd14: begin `load_weight(1034) end
									
									default:
										begin
											for (i=0; i<32; i=i+1) begin
												for (w=1; w<10; w=w+1) begin
													cv_w[i][w]    <= 0;
												end
											end
										end
								endcase
					
								`load_qt(13)
								
			
								for (i=0; i<32; i=i+16) begin
									// filters
									for (j=0; j<16; j=j+1) begin 
										intermediate[i+j] <= cv_pixelout[i+j];
									end
								end
								
								// add bias and quantization
								//qt0
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
												+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
												+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
												+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15];
								
								//qt1
								qt1_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
												+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
												+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
												+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
								
								// save to buffer
								// save image to buffer, seperated to 4 pices
								// 
								//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
								// ------------------------------------------------------------------------------- Q1 [8191:0]
								//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
								//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
								//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
								//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
								// ------------------------------------------------------------------------------- Q3 [16383:8192]
								//   layerint_buf4         L1-P8192       L2-P8192       L3-P8192      L4-P8192
								//   layerint_buf5         L5-P8192       L6-P8192       L7-P8192      L8-P8192
								//   layerint_buf6         L9-P8192       L10-P8192      L11-P8192     L12-P8192
								//   layerint_buf7         L13-P8192      L14-P8192      L15-P8192     L16-P8192
								// 
								
								case (layercount)
									32'd2:  savebuffer[31:16] <= {qt0_res, qt1_res};
									
									32'd4:  
										begin
											if (pixelcount < 8321)
												layerint_buf0_st1[(pixelcount-129)] <= {savebuffer[31:16], qt0_res, qt1_res};
											else
												layerint_buf4_st1[(pixelcount-8321)] <= {savebuffer[31:16], qt0_res, qt1_res};
										end
										
									32'd6:  savebuffer[31:16] <= {qt0_res, qt1_res};
									
									32'd8:  
										begin
											if (pixelcount < 8321)
												layerint_buf1_st1[(pixelcount-129)] <= {savebuffer[31:16], qt0_res, qt1_res};
											else
												layerint_buf5_st1[(pixelcount-8321)] <= {savebuffer[31:16], qt0_res, qt1_res};
										end
										
									32'd10: savebuffer[31:16] <= {qt0_res, qt1_res};
									
									32'd12: 
										begin
											if (pixelcount < 8321)
												layerint_buf2_st1[(pixelcount-129)] <= {savebuffer[31:16], qt0_res, qt1_res};
											else
												layerint_buf6_st1[(pixelcount-8321)] <= {savebuffer[31:16], qt0_res, qt1_res};
										end
										
									32'd14: savebuffer[31:16] <= {qt0_res, qt1_res};
									
									32'd0:  
										begin
											if (pixelcount > 129) begin
												if (pixelcount < 8322)
													layerint_buf3_st1[(pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
												else
													layerint_buf7_st1[(pixelcount-8322)] <= {savebuffer[31:16], qt0_res, qt1_res};
											end
										end
								endcase	
							end else begin
								pixelcount <= pixelcount + 1;
							end
						end
					end
					
				SEND:
					begin
						ctrl <= DATA_READY;
						if (~unet_enpulse) begin
							if (pixelcount >= 32'd16513) begin  // (height*width + (width+1) for padding)
								if (inlayercount >= 32'd16) begin
									if (pixelcount == 32'd16513) begin
										pixelcount <= pixelcount + 1;
										for (l=0; l<32; l=l+1) cv_rst[l] <= 0;	 // Reset
									end else begin
										for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
										state <= SAY_IDLE;
										pixelcount <= 32'b0;
										layercount <= 0;
										inlayercount <= 0;
										busy <= 0;
									end
									
								end else begin
									pixelcount <= 32'b0;
									inlayercount <= inlayercount + 32'd1;
								end
								
							end else begin
								pixelcount <= pixelcount + 1;
							end
						end
					end
					
				default: 
					state <= SAY_IDLE;
			endcase
		end
	end
	
	reg [7:0] buffer0 [11:0];
	reg [1:0] loadcounter;
	reg [3:0] buffer0_offset;
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
		end else begin
			case (state)
				STAGE1_CONV:
					// Loads 4 byts, outs 3byts. avoid loading for 1 clock every 3
					begin
						loadcounter <= (loadcounter == 3) ? 0 : loadcounter + 1;
						buffer0_offset <= (buffer0_offset == 9) ? 0 : buffer0_offset + 3;
					
						if (loadcounter == 0) begin
							buffer0[0] <= data_in[7:0];
							buffer0[1] <= data_in[15:8];
							buffer0[2] <= data_in[23:16];
							buffer0[3] <= data_in[31:24];
						end else if (loadcounter == 1) begin
							buffer0[4] <= data_in[7:0];
							buffer0[5] <= data_in[15:8];
							buffer0[6] <= data_in[23:16];
							buffer0[7] <= data_in[31:24];
						end else if (loadcounter == 2) begin
							buffer0[8] <= data_in[7:0];
							buffer0[9] <= data_in[15:8];
							buffer0[10] <= data_in[23:16];
							buffer0[11] <= data_in[31:24];
						end
					end
			endcase
		end
	end

	reg [7:0] buffer0_outwire [2:0];
	integer a,b,c;
	
	always@(*) begin
		case (state)
			STAGE1_CONV:
				// Here all 8 outlayers calced parellelly
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 8'd128;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 128 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 128 == 1) ? 1 : 0; 
				
					buffer0_outwire[0] <= buffer0[buffer0_offset];
					buffer0_outwire[1] <= buffer0[buffer0_offset+1];
					buffer0_outwire[2] <= buffer0[buffer0_offset+2];
					
					for (b=0; b<24; b=b+3) begin
						// filter
						for (c=0; c<3; c=c+1) begin
							cv_pixelin[c+b] <= buffer0_outwire[c];
						end
					end
				end
				
			STAGE1_MXPL:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= MAXPOOL2x2;
					end
					
					relu <= 0;
					
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [4095:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					// ------------------------------------------------------------------------------- Q2 [8191:4096]
					//   layerint_buf2         L1-P4224       L2-P4224       L3-P4224      L4-P4224
					//   layerint_buf3         L5-P4224       L6-P4224       L7-P4224      L8-P4224
					// ------------------------------------------------------------------------------- Q3 [12287:8192]
					//   layerint_buf4         L1-P8449       L2-P8449       L3-P8449      L4-P8449
					//   layerint_buf5         L5-P8449       L6-P8449       L7-P8449      L8-P8449
					// ------------------------------------------------------------------------------- Q4 [16383:12288]
					//   layerint_buf6         L1-P12674      L2-P12674      L3-P12674     L4-P12674
					//   layerint_buf7         L5-P12674      L6-P12674      L7-P12674     L8-P12674
					// 
					
					for (b=0; b<4; b=b+1) begin
						cv_pixelin[b]    <= layerint_buf0_st1[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+4]  <= layerint_buf1_st1[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+8]  <= layerint_buf2_st1[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+12] <= layerint_buf3_st1[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+16] <= layerint_buf4_st1[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+20] <= layerint_buf5_st1[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+24] <= layerint_buf6_st1[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+28] <= layerint_buf7_st1[pixelcount][31-(b*8) -:8];
					end
				end
				
			STAGE2_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd64;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 64 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 64 == 1) ? 1 : 0; 
					
					// Storage input:
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [1023:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					// ------------------------------------------------------------------------------- Q2 [2047:1024]
					//   layerint_buf2         L1-P1024       L2-P1024       L3-P1024      L4-P1024
					//   layerint_buf3         L5-P1024       L6-P1024       L7-P1024      L8-P1024
					// ------------------------------------------------------------------------------- Q3 [3071:2048]
					//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
					//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
					// ------------------------------------------------------------------------------- Q4 [4095:3072]
					//   layerint_buf6         L1-P3072       L2-P3072       L3-P3072      L4-P3072
					//   layerint_buf7         L5-P3072       L6-P3072       L7-P3072      L8-P3072
					//
					//
					// Calculation sequence:
					// --------------------------------------------------
					// 	pixel1 - calc outlayers 1,2,3,4
					// 	         calc outlayers 5,6,7,8
					//	 	         calc outlayers 9,10,11,12
					//    	      calc outlayers 13,14,15,16
					// 	pixel2...
					//
					
					if (pixelcount<1024) begin
						for (b=0; b<4; b=b+1) begin
							for (c=0; c<32; c=c+8) begin
								cv_pixelin[b+c]   <= layerint_buf0_st2[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4+c] <= layerint_buf1_st2[(pixelcount)][31-(b*8) -:8];
							end
						end
					end else if (pixelcount<2048) begin
						for (b=0; b<4; b=b+1) begin
							for (c=0; c<32; c=c+8) begin
								cv_pixelin[b+c]   <= layerint_buf2_st2[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4+c] <= layerint_buf3_st2[(pixelcount)][31-(b*8) -:8];
							end
						end
					end else if (pixelcount<3072) begin
						for (b=0; b<4; b=b+1) begin
							for (c=0; c<32; c=c+8) begin
								cv_pixelin[b+c]   <= layerint_buf4_st2[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4+c] <= layerint_buf5_st2[(pixelcount)][31-(b*8) -:8];
							end
						end
					end else if (pixelcount<4096) begin
						for (b=0; b<4; b=b+1) begin
							for (c=0; c<32; c=c+8) begin
								cv_pixelin[b+c]   <= layerint_buf6_st2[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4+c] <= layerint_buf7_st2[(pixelcount)][31-(b*8) -:8];
							end
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							for (c=0; c<32; c=c+8) begin
								cv_pixelin[b+c]   <= 0;
								cv_pixelin[b+4+c] <= 0;
							end
						end
					end
				end
				
			STAGE2_MXPL:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= MAXPOOL2x2;
					end
					
					relu <= 0;
					
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [2047:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					// ------------------------------------------------------------------------------- Q2 [4095:2048]
					//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
					//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
					//   layerint_buf6         L9-P2048       L10-P2048      L11-P2048     L12-P2048
					//   layerint_buf7         L13-P2048      L14-P2048      L15-P2048     L16-P2048
					// 
					// 
					
					for (b=0; b<4; b=b+1) begin
						cv_pixelin[b]    <= layerint_buf0_st2[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+4]  <= layerint_buf1_st2[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+8]  <= layerint_buf2_st2[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+12] <= layerint_buf3_st2[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+16] <= layerint_buf4_st2[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+20] <= layerint_buf5_st2[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+24] <= layerint_buf6_st2[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+28] <= layerint_buf7_st2[pixelcount][31-(b*8) -:8];
					end
				end
				
			STAGE3_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd32;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 32 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 32 == 1) ? 1 : 0; 
					
					// Storage input:
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [511:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					// ------------------------------------------------------------------------------- Q2 [1023:512]
					//   layerint_buf4         L1-P512        L2-P512        L3-P512       L4-P512 
					//   layerint_buf5         L5-P512        L6-P512        L7-P512       L8-P512 
					//   layerint_buf6         L9-P512        L10-P512       L11-P512      L12-P512 
					//   layerint_buf7         L13-P512       L14-P512       L15-P512      L16-P512
					// 
					//
					// Calculation sequence:
					// --------------------------------------------------
					// 	// 16 (32x32) levels ---> 32 (32x32) levels
					//
					//    pixel1 - calc outlayers 1,2
					//             calc outlayers 3,4
					//             ...
					//             calc outlayers 31,32
					//    pixel2...
					//
					
					if (pixelcount<512) begin
						for (b=0; b<4; b=b+1) begin
							for (c=0; c<32; c=c+16) begin
								cv_pixelin[b+c]    <= layerint_buf0_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4+c]  <= layerint_buf1_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+8+c]  <= layerint_buf2_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+12+c] <= layerint_buf3_st3[(pixelcount)][31-(b*8) -:8];
							end
						end
					end else if (pixelcount<1024) begin
						for (b=0; b<4; b=b+1) begin
							for (c=0; c<32; c=c+8) begin
								cv_pixelin[b+c]    <= layerint_buf4_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4+c]  <= layerint_buf5_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+8+c]  <= layerint_buf6_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+12+c] <= layerint_buf7_st3[(pixelcount)][31-(b*8) -:8];
							end
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							for (c=0; c<32; c=c+8) begin
								cv_pixelin[b+c]    <= 0;
								cv_pixelin[b+4+c]  <= 0;
								cv_pixelin[b+8+c]  <= 0;
								cv_pixelin[b+12+c] <= 0;
							end
						end
					end 
				end
				
			STAGE3_MXPL:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= MAXPOOL2x2;
					end
					
					relu <= 0;
					
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [511:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					// 
					
					for (b=0; b<4; b=b+1) begin
						cv_pixelin[b]    <= layerint_buf0_st3[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+4]  <= layerint_buf1_st3[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+8]  <= layerint_buf2_st3[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+12] <= layerint_buf3_st3[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+16] <= layerint_buf4_st3[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+20] <= layerint_buf5_st3[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+24] <= layerint_buf6_st3[pixelcount][31-(b*8) -:8];
						cv_pixelin[b+28] <= layerint_buf7_st3[pixelcount][31-(b*8) -:8];
					end
				end
			
			STAGE4_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd16;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 16 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 16 == 1) ? 1 : 0; 
					
					// Storage input:
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [255:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					// 			
					//
					// Calculation sequence:
					// --------------------------------------------------
					// 32 (16x16) levels ---> 64 (16x16) levels
					//
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 64
					// pixel2...
					//
					
					if (pixelcount<256) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf0_st4[(pixelcount*4)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf1_st4[(pixelcount*4)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf2_st4[(pixelcount*4)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf3_st4[(pixelcount*4)][31-(b*8) -:8];
							cv_pixelin[b+16] <= layerint_buf4_st4[(pixelcount*4)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf5_st4[(pixelcount*4)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf6_st4[(pixelcount*4)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf7_st4[(pixelcount*4)][31-(b*8) -:8];
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= 0;
							cv_pixelin[b+4]  <= 0;
							cv_pixelin[b+8]  <= 0;
							cv_pixelin[b+12] <= 0;
							cv_pixelin[b+16] <= 0;
							cv_pixelin[b+20] <= 0;
							cv_pixelin[b+24] <= 0;
							cv_pixelin[b+28] <= 0;
						end
					end 
				end
				
			STAGE4_MXPL:
				// save to buffer
				
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= MAXPOOL2x2;
					end
					
					relu <= 0;
					
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [255:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
					//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
					//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
					//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
					//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
					//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
					//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
					//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
					
					if (inlayercount == 0) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf0_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf1_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf2_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf3_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+16] <= layerint_buf4_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf5_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf6_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf7_st4[pixelcount][31-(b*8) -:8];
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf8_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf9_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf10_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf11_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+16] <= layerint_buf12_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf13_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf14_st4[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf15_st4[pixelcount][31-(b*8) -:8];
						end
					end
				end
			
			STAGE5_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd8;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 8 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 8 == 1) ? 1 : 0; 
					
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [63:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
					//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
					//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
					//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
					//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
					//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
					//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
					//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
					//
					//
					// 64 (8x8) Layers ---> 128 (8x8) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 128 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 128
					// pixel2...
					// ...
					// pixel100...
					if (inlayercount==0) begin
						if (pixelcount<64) begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= layerint_buf0_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4]  <= layerint_buf1_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+8]  <= layerint_buf2_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+12] <= layerint_buf3_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+16] <= layerint_buf4_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+20] <= layerint_buf5_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+24] <= layerint_buf6_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+28] <= layerint_buf7_st5[(pixelcount)][31-(b*8) -:8];
							end
						end else begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= 0;
								cv_pixelin[b+4]  <= 0;
								cv_pixelin[b+8]  <= 0;
								cv_pixelin[b+12] <= 0;
								cv_pixelin[b+16] <= 0;
								cv_pixelin[b+20] <= 0;
								cv_pixelin[b+24] <= 0;
								cv_pixelin[b+28] <= 0;
							end
						end 
					end else begin
						if (pixelcount<64) begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= layerint_buf8_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4]  <= layerint_buf9_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+8]  <= layerint_buf10_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+12] <= layerint_buf11_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+16] <= layerint_buf12_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+20] <= layerint_buf13_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+24] <= layerint_buf14_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+28] <= layerint_buf15_st5[(pixelcount)][31-(b*8) -:8];
							end
						end else begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= 0;
								cv_pixelin[b+4]  <= 0;
								cv_pixelin[b+8]  <= 0;
								cv_pixelin[b+12] <= 0;
								cv_pixelin[b+16] <= 0;
								cv_pixelin[b+20] <= 0;
								cv_pixelin[b+24] <= 0;
								cv_pixelin[b+28] <= 0;
							end
						end 
					end
				end
				
			STAGE6_TRANSCONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= TRANS;
						cv_width[a] <= 7'd8;
					end
					
					relu <= 0;
					
					// 128 (8x8) Layers ---> 64 (16x16) Layers
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 64 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 64
					// pixel2...
					// ...
					// pixel100...
					//
					//	Storage at st5
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [63:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
					//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
					//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
					//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
					//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
					//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
					//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
					//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
					//   layerint_buf16        L65-P1         L66-P1         L67-P1        L68-P1
					//   layerint_buf17        L69-P1         L70-P1         L71-P1        L72-P1
					//   layerint_buf18        L73-P1         L74-P1         L75-P1        L76-P1
					//   layerint_buf19        L77-P1         L78-P1         L79-P1        L80-P1
					//   layerint_buf20        L81-P1         L82-P1         L83-P1        L84-P1
					//   layerint_buf21        L85-P1         L86-P1         L87-P1        L88-P1
					//   layerint_buf22        L89-P1         L90-P1         L91-P1        L92-P1
					//   layerint_buf23        L93-P1         L94-P1         L95-P1        L96-P1
					//   layerint_buf24        L97-P1         L98-P1         L99-P1        L100-P1
					//   layerint_buf25        L101-P1        L102-P1        L103-P1       L104-P1
					//   layerint_buf26        L105-P1        L106-P1        L107-P1       L108-P1
					//   layerint_buf27        L109-P1        L110-P1        L111-P1       L112-P1
					//   layerint_buf28        L113-P1        L114-P1        L115-P1       L116-P1
					//   layerint_buf29        L117-P1        L118-P1        L119-P1       L120-P1
					//   layerint_buf30        L121-P1        L122-P1        L123-P1       L124-P1
					//   layerint_buf31        L125-P1        L126-P1        L127-P1       L128-P1
					
					case (inlayercount)
						32'd0:
							begin
								if (pixelcount<64) begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= layerint_buf0_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+4]  <= layerint_buf1_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+8]  <= layerint_buf2_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+12] <= layerint_buf3_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+16] <= layerint_buf4_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+20] <= layerint_buf5_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+24] <= layerint_buf6_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+28] <= layerint_buf7_st5[(pixelcount)][31-(b*8) -:8];
									end
								end else begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= 0;
										cv_pixelin[b+4]  <= 0;
										cv_pixelin[b+8]  <= 0;
										cv_pixelin[b+12] <= 0;
										cv_pixelin[b+16] <= 0;
										cv_pixelin[b+20] <= 0;
										cv_pixelin[b+24] <= 0;
										cv_pixelin[b+28] <= 0;
									end
								end
							end
						32'd32:
							begin
								if (pixelcount<64) begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= layerint_buf8_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+4]  <= layerint_buf9_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+8]  <= layerint_buf10_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+12] <= layerint_buf11_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+16] <= layerint_buf12_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+20] <= layerint_buf13_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+24] <= layerint_buf14_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+28] <= layerint_buf15_st5[(pixelcount)][31-(b*8) -:8];
									end
								end else begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= 0;
										cv_pixelin[b+4]  <= 0;
										cv_pixelin[b+8]  <= 0;
										cv_pixelin[b+12] <= 0;
										cv_pixelin[b+16] <= 0;
										cv_pixelin[b+20] <= 0;
										cv_pixelin[b+24] <= 0;
										cv_pixelin[b+28] <= 0;
									end
								end
							end
						32'd64:
							begin
								if (pixelcount<64) begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= layerint_buf16_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+4]  <= layerint_buf17_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+8]  <= layerint_buf18_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+12] <= layerint_buf19_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+16] <= layerint_buf20_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+20] <= layerint_buf21_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+24] <= layerint_buf22_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+28] <= layerint_buf23_st5[(pixelcount)][31-(b*8) -:8];
									end
								end else begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= 0;
										cv_pixelin[b+4]  <= 0;
										cv_pixelin[b+8]  <= 0;
										cv_pixelin[b+12] <= 0;
										cv_pixelin[b+16] <= 0;
										cv_pixelin[b+20] <= 0;
										cv_pixelin[b+24] <= 0;
										cv_pixelin[b+28] <= 0;
									end
								end
							end
						default:
							// first half from st4
							begin
								if (pixelcount<64) begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= layerint_buf24_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+4]  <= layerint_buf25_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+8]  <= layerint_buf26_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+12] <= layerint_buf27_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+16] <= layerint_buf28_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+20] <= layerint_buf29_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+24] <= layerint_buf30_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+28] <= layerint_buf31_st5[(pixelcount)][31-(b*8) -:8];
									end
								end else begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= 0;
										cv_pixelin[b+4]  <= 0;
										cv_pixelin[b+8]  <= 0;
										cv_pixelin[b+12] <= 0;
										cv_pixelin[b+16] <= 0;
										cv_pixelin[b+20] <= 0;
										cv_pixelin[b+24] <= 0;
										cv_pixelin[b+28] <= 0;
									end
								end
							end
					endcase
				end
			
			STAGE6_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd16;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 16 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 16 == 1) ? 1 : 0; 
					
					// 64 (16x16) + 64 (16x16) STAGE4_CONV Layers ---> 64 (16x16) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 64 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 64
					// pixel2...
					// ...
					// pixel100...
					//
					//	Storage at st5
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [255:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
					//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
					//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
					//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
					//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
					//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
					//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
					//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
					//
					// Storage at st4
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [255:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
					//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
					//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
					//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
					//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
					//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
					//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
					//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
					
					case (inlayercount)
						32'd0:
							// first half from st5
							begin
								if (pixelcount<256) begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= layerint_buf0_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+4]  <= layerint_buf1_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+8]  <= layerint_buf2_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+12] <= layerint_buf3_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+16] <= layerint_buf4_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+20] <= layerint_buf5_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+24] <= layerint_buf6_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+28] <= layerint_buf7_st5[(pixelcount)][31-(b*8) -:8];
									end
								end else begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= 0;
										cv_pixelin[b+4]  <= 0;
										cv_pixelin[b+8]  <= 0;
										cv_pixelin[b+12] <= 0;
										cv_pixelin[b+16] <= 0;
										cv_pixelin[b+20] <= 0;
										cv_pixelin[b+24] <= 0;
										cv_pixelin[b+28] <= 0;
									end
								end
							end
						32'd32:
							// second half from st5
							begin
								if (pixelcount<256) begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= layerint_buf8_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+4]  <= layerint_buf9_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+8]  <= layerint_buf10_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+12] <= layerint_buf11_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+16] <= layerint_buf12_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+20] <= layerint_buf13_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+24] <= layerint_buf14_st5[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+28] <= layerint_buf15_st5[(pixelcount)][31-(b*8) -:8];
									end
								end else begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= 0;
										cv_pixelin[b+4]  <= 0;
										cv_pixelin[b+8]  <= 0;
										cv_pixelin[b+12] <= 0;
										cv_pixelin[b+16] <= 0;
										cv_pixelin[b+20] <= 0;
										cv_pixelin[b+24] <= 0;
										cv_pixelin[b+28] <= 0;
									end
								end
							end
						32'd64:
							// first half from st4
							begin
								if (pixelcount<256) begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= layerint_buf0_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+4]  <= layerint_buf1_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+8]  <= layerint_buf2_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+12] <= layerint_buf3_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+16] <= layerint_buf4_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+20] <= layerint_buf5_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+24] <= layerint_buf6_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+28] <= layerint_buf7_st4[(pixelcount)][31-(b*8) -:8];
									end
								end else begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= 0;
										cv_pixelin[b+4]  <= 0;
										cv_pixelin[b+8]  <= 0;
										cv_pixelin[b+12] <= 0;
										cv_pixelin[b+16] <= 0;
										cv_pixelin[b+20] <= 0;
										cv_pixelin[b+24] <= 0;
										cv_pixelin[b+28] <= 0;
									end
								end
							end
						default:
							// first half from st4
							begin
								if (pixelcount<256) begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= layerint_buf8_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+4]  <= layerint_buf9_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+8]  <= layerint_buf10_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+12] <= layerint_buf11_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+16] <= layerint_buf12_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+20] <= layerint_buf13_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+24] <= layerint_buf14_st4[(pixelcount)][31-(b*8) -:8];
										cv_pixelin[b+28] <= layerint_buf15_st4[(pixelcount)][31-(b*8) -:8];
									end
								end else begin
									for (b=0; b<4; b=b+1) begin
										cv_pixelin[b]    <= 0;
										cv_pixelin[b+4]  <= 0;
										cv_pixelin[b+8]  <= 0;
										cv_pixelin[b+12] <= 0;
										cv_pixelin[b+16] <= 0;
										cv_pixelin[b+20] <= 0;
										cv_pixelin[b+24] <= 0;
										cv_pixelin[b+28] <= 0;
									end
								end
							end
					endcase
				end
				
			STAGE7_TRANSCONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= TRANS;
						cv_width[a] <= 7'd16;
					end
					
					relu <= 0;
					
					// 64 (16x16) ---> 32 (32x32) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 32 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 32
					// pixel2...
					// ...
					// pixel100...
					//
					// Storage at st5
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [255:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					//   layerint_buf8         L33-P1         L34-P1         L35-P1        L36-P1
					//   layerint_buf9         L37-P1         L38-P1         L39-P1        L40-P1
					//   layerint_buf10        L41-P1         L42-P1         L43-P1        L44-P1
					//   layerint_buf11        L45-P1         L46-P1         L47-P1        L48-P1
					//   layerint_buf12        L49-P1         L50-P1         L51-P1        L52-P1
					//   layerint_buf13        L53-P1         L54-P1         L55-P1        L56-P1
					//   layerint_buf14        L57-P1         L58-P1         L59-P1        L60-P1
					//   layerint_buf15        L61-P1         L62-P1         L63-P1        L64-P1
					// 	
					
					if (inlayercount == 0) begin
						if (pixelcount<256) begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= layerint_buf0_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4]  <= layerint_buf1_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+8]  <= layerint_buf2_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+12] <= layerint_buf3_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+16] <= layerint_buf4_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+20] <= layerint_buf5_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+24] <= layerint_buf6_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+28] <= layerint_buf7_st5[(pixelcount)][31-(b*8) -:8];
							end
						end else begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= 0;
								cv_pixelin[b+4]  <= 0;
								cv_pixelin[b+8]  <= 0;
								cv_pixelin[b+12] <= 0;
								cv_pixelin[b+16] <= 0;
								cv_pixelin[b+20] <= 0;
								cv_pixelin[b+24] <= 0;
								cv_pixelin[b+28] <= 0;
							end
						end
					end else begin
						if (pixelcount<256) begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= layerint_buf8_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4]  <= layerint_buf9_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+8]  <= layerint_buf10_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+12] <= layerint_buf11_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+16] <= layerint_buf12_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+20] <= layerint_buf13_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+24] <= layerint_buf14_st5[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+28] <= layerint_buf15_st5[(pixelcount)][31-(b*8) -:8];
							end
						end else begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= 0;
								cv_pixelin[b+4]  <= 0;
								cv_pixelin[b+8]  <= 0;
								cv_pixelin[b+12] <= 0;
								cv_pixelin[b+16] <= 0;
								cv_pixelin[b+20] <= 0;
								cv_pixelin[b+24] <= 0;
								cv_pixelin[b+28] <= 0;
							end
						end
					end
				end
				
			STAGE7_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd32;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 32 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 32 == 1) ? 1 : 0; 
					
					// 32 (32x32) + 32 (32x32) STAGE3_CONV Layers ---> 32 (32x32) Layers
					//
					// pixel1 - calc outlayers 1 intermediate
					//          calc outlayers 2 intermediate
					//          ...
					//          calc outlayers 32 intermediate
					// pixel2...
					// ...
					// pixel100...
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 32
					// pixel2...
					// ...
					// pixel100...
					//
					// Storage at st4
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [1023:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					// 			
					// Storage at st3
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [1023:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					// 	
					
					if (inlayercount == 0) begin
						if (pixelcount<1024) begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= layerint_buf0_st4[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4]  <= layerint_buf1_st4[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+8]  <= layerint_buf2_st4[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+12] <= layerint_buf3_st4[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+16] <= layerint_buf4_st4[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+20] <= layerint_buf5_st4[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+24] <= layerint_buf6_st4[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+28] <= layerint_buf7_st4[(pixelcount)][31-(b*8) -:8];
							end
						end else begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= 0;
								cv_pixelin[b+4]  <= 0;
								cv_pixelin[b+8]  <= 0;
								cv_pixelin[b+12] <= 0;
								cv_pixelin[b+16] <= 0;
								cv_pixelin[b+20] <= 0;
								cv_pixelin[b+24] <= 0;
								cv_pixelin[b+28] <= 0;
							end
						end
					end else begin
						if (pixelcount<1024) begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= layerint_buf0_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+4]  <= layerint_buf1_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+8]  <= layerint_buf2_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+12] <= layerint_buf3_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+16] <= layerint_buf4_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+20] <= layerint_buf5_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+24] <= layerint_buf6_st3[(pixelcount)][31-(b*8) -:8];
								cv_pixelin[b+28] <= layerint_buf7_st3[(pixelcount)][31-(b*8) -:8];
							end
						end else begin
							for (b=0; b<4; b=b+1) begin
								cv_pixelin[b]    <= 0;
								cv_pixelin[b+4]  <= 0;
								cv_pixelin[b+8]  <= 0;
								cv_pixelin[b+12] <= 0;
								cv_pixelin[b+16] <= 0;
								cv_pixelin[b+20] <= 0;
								cv_pixelin[b+24] <= 0;
								cv_pixelin[b+28] <= 0;
							end
						end
					end
				end
			
			STAGE8_TRANSCONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= TRANS;
						cv_width[a] <= 7'd32;
					end
					
					relu <= 0;
					
					// 32 (32x32) Layers ---> 16 (64x64) Layers
					
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 16
					// pixel2...
					//
					// Storage at st4
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [1023:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					//   layerint_buf4         L17-P1         L18-P1         L19-P1        L20-P1
					//   layerint_buf5         L21-P1         L22-P1         L23-P1        L24-P1
					//   layerint_buf6         L25-P1         L26-P1         L27-P1        L28-P1
					//   layerint_buf7         L29-P1         L30-P1         L31-P1        L32-P1
					// 	
					
					if (pixelcount<1024) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf0_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf1_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf2_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf3_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+16] <= layerint_buf4_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf5_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf6_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf7_st3[(pixelcount)][31-(b*8) -:8];
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= 0;
							cv_pixelin[b+4]  <= 0;
							cv_pixelin[b+8]  <= 0;
							cv_pixelin[b+12] <= 0;
							cv_pixelin[b+16] <= 0;
							cv_pixelin[b+20] <= 0;
							cv_pixelin[b+24] <= 0;
							cv_pixelin[b+28] <= 0;
						end
					end 
				end
				
			STAGE8_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd64;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 64 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 64 == 1) ? 1 : 0; 
					
					// 16 (64x64) + 16 (64x64) STAGE2_CONV Layers ---> 16 (64x64) Layers
					//
					// pixel1 - calc outlayers 1
					//          calc outlayers 2
					//          ...
					//          calc outlayers 16
					// pixel2...
					//
					// Storage at st3
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [2047:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					// ------------------------------------------------------------------------------- Q2 [4095:2048]
					//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
					//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
					//   layerint_buf6         L9-P2048       L10-P2048      L11-P2048     L12-P2048
					//   layerint_buf7         L13-P2048      L14-P2048      L15-P2048     L16-P2048
					// 			
					// Storage at st2
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [2047:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					// ------------------------------------------------------------------------------- Q2 [4095:2048]
					//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
					//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
					//   layerint_buf6         L9-P2048       L10-P2048      L11-P2048     L12-P2048
					//   layerint_buf7         L13-P2048      L14-P2048      L15-P2048     L16-P2048
					// 
					
					if (pixelcount<2048) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf0_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf1_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf2_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf3_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+16] <= layerint_buf1_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf2_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf3_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf4_st2[(pixelcount)][31-(b*8) -:8];
						end
					end else if (pixelcount<4096) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf4_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf5_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf6_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf7_st3[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+16] <= layerint_buf4_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf5_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf6_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf7_st2[(pixelcount)][31-(b*8) -:8];
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= 0;
							cv_pixelin[b+4]  <= 0;
							cv_pixelin[b+8]  <= 0;
							cv_pixelin[b+12] <= 0;
							cv_pixelin[b+16] <= 0;
							cv_pixelin[b+20] <= 0;
							cv_pixelin[b+24] <= 0;
							cv_pixelin[b+28] <= 0;
						end
					end 
				end
				
			STAGE9_TRANSCONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= TRANS;
						cv_width[a] <= 7'd64;
					end
					
					relu <= 0;
					
					// 16 (64x64) ---> 8 (128x128) Layers
					//
					// pixel1 - calc outlayers 1,2
					//          calc outlayers 3,4
					//          ...
					//          calc outlayers 7,8
					// pixel2...
					//
					// Storage at st2
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [2047:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					//   layerint_buf2         L9-P1          L10-P1         L11-P1        L12-P1
					//   layerint_buf3         L13-P1         L14-P1         L15-P1        L16-P1
					// ------------------------------------------------------------------------------- Q2 [4095:2048]
					//   layerint_buf4         L1-P2048       L2-P2048       L3-P2048      L4-P2048
					//   layerint_buf5         L5-P2048       L6-P2048       L7-P2048      L8-P2048
					//   layerint_buf6         L9-P2048       L10-P2048      L11-P2048     L12-P2048
					//   layerint_buf7         L13-P2048      L14-P2048      L15-P2048     L16-P2048
					// 
					//
					
					if (pixelcount<2048) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf0_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf0_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf1_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf1_st2[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf2_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf2_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf3_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf3_st2[(pixelcount)][31-(b*8) -:8];
						end
					end else if (pixelcount<4096) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf4_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf4_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf5_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf5_st2[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf6_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf6_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf7_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf7_st2[(pixelcount)][31-(b*8) -:8];
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= 0;
							cv_pixelin[b+4]  <= 0;
							cv_pixelin[b+8]  <= 0;
							cv_pixelin[b+12] <= 0;
							cv_pixelin[b+16] <= 0;
							cv_pixelin[b+20] <= 0;
							cv_pixelin[b+24] <= 0;
							cv_pixelin[b+28] <= 0;
						end
					end 
				end
				
			STAGE9_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 8'd128;
					end
					
					relu <= 1;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 128 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 128 == 1) ? 1 : 0; 
					
					// 8 (128x128) + 8 (128x128) STAGE1_CONV Layers ---> 8 (128x128) Layers
					//
					// pixel1 - calc outlayers 1,2
					//          calc outlayers 3,4
					//          ...
					//          calc outlayers 7,8
					// pixel2...
					//
					// Storage at st2
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [4095:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					// ------------------------------------------------------------------------------- Q2 [8191:4096]
					//   layerint_buf2         L1-P4224       L2-P4224       L3-P4224      L4-P4224
					//   layerint_buf3         L5-P4224       L6-P4224       L7-P4224      L8-P4224
					// ------------------------------------------------------------------------------- Q3 [12287:8192]
					//   layerint_buf4         L1-P8449       L2-P8449       L3-P8449      L4-P8449
					//   layerint_buf5         L5-P8449       L6-P8449       L7-P8449      L8-P8449
					// ------------------------------------------------------------------------------- Q4 [16383:12288]
					//   layerint_buf6         L1-P12674      L2-P12674      L3-P12674     L4-P12674
					//   layerint_buf7         L5-P12674      L6-P12674      L7-P12674     L8-P12674
					//
					// Storage at st1
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [4095:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					// ------------------------------------------------------------------------------- Q2 [8191:4096]
					//   layerint_buf2         L1-P4224       L2-P4224       L3-P4224      L4-P4224
					//   layerint_buf3         L5-P4224       L6-P4224       L7-P4224      L8-P4224
					// ------------------------------------------------------------------------------- Q3 [12287:8192]
					//   layerint_buf4         L1-P8449       L2-P8449       L3-P8449      L4-P8449
					//   layerint_buf5         L5-P8449       L6-P8449       L7-P8449      L8-P8449
					// ------------------------------------------------------------------------------- Q4 [16383:12288]
					//   layerint_buf6         L1-P12674      L2-P12674      L3-P12674     L4-P12674
					//   layerint_buf7         L5-P12674      L6-P12674      L7-P12674     L8-P12674
					//
					
					if (pixelcount<4096) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf0_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf0_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf0_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf0_st1[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf1_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf1_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf1_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf1_st1[(pixelcount)][31-(b*8) -:8];
						end
					end else if (pixelcount<8192) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf2_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf2_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf2_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf2_st1[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf3_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf3_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf3_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf3_st1[(pixelcount)][31-(b*8) -:8];
						end
					end else if (pixelcount<12288) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf4_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf4_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf4_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf4_st1[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf5_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf5_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf5_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf5_st1[(pixelcount)][31-(b*8) -:8];
						end
					end else if (pixelcount<16384) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf6_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf6_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf6_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf6_st1[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf7_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf7_st2[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf7_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf7_st1[(pixelcount)][31-(b*8) -:8];
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= 0;
							cv_pixelin[b+4]  <= 0;
							cv_pixelin[b+8]  <= 0;
							cv_pixelin[b+12] <= 0;
							cv_pixelin[b+16] <= 0;
							cv_pixelin[b+20] <= 0;
							cv_pixelin[b+24] <= 0;
							cv_pixelin[b+28] <= 0;
						end
					end 
				end
				
			STAGE10_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 8'd128;
					end
					
					relu <= 0;
					
					// Setting padding
					cv_paddingL <= (pixelcount % 128 == 0) ? 1 : 0;
					cv_paddingR <= (pixelcount % 128 == 1) ? 1 : 0; 
					
					// save image to buffer, seperated to 4 pices
					// 
					//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
					// ------------------------------------------------------------------------------- Q1 [4095:0]
					//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
					//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
					// ------------------------------------------------------------------------------- Q2 [8191:4096]
					//   layerint_buf2         L1-P4224       L2-P4224       L3-P4224      L4-P4224
					//   layerint_buf3         L5-P4224       L6-P4224       L7-P4224      L8-P4224
					// ------------------------------------------------------------------------------- Q3 [12287:8192]
					//   layerint_buf4         L1-P8449       L2-P8449       L3-P8449      L4-P8449
					//   layerint_buf5         L5-P8449       L6-P8449       L7-P8449      L8-P8449
					// ------------------------------------------------------------------------------- Q4 [16383:12288]
					//   layerint_buf6         L1-P12674      L2-P12674      L3-P12674     L4-P12674
					//   layerint_buf7         L5-P12674      L6-P12674      L7-P12674     L8-P12674
					// 
					
					if (pixelcount<4096) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf0_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf0_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf0_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf0_st1[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf1_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf1_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf1_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf1_st1[(pixelcount)][31-(b*8) -:8];
						end
					end else if (pixelcount<8192) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf2_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf2_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf2_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf2_st1[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf3_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf3_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf3_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf3_st1[(pixelcount)][31-(b*8) -:8];
						end
					end else if (pixelcount<12288) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf4_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf4_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf4_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf4_st1[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf5_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf5_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf5_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf5_st1[(pixelcount)][31-(b*8) -:8];
						end
					end else if (pixelcount<16384) begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf6_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf6_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf6_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf6_st1[(pixelcount)][31-(b*8) -:8];
							
							cv_pixelin[b+16] <= layerint_buf7_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf7_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf7_st1[(pixelcount)][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf7_st1[(pixelcount)][31-(b*8) -:8];
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= 0;
							cv_pixelin[b+4]  <= 0;
							cv_pixelin[b+8]  <= 0;
							cv_pixelin[b+12] <= 0;
							cv_pixelin[b+16] <= 0;
							cv_pixelin[b+20] <= 0;
							cv_pixelin[b+24] <= 0;
							cv_pixelin[b+28] <= 0;
						end
					end
				end
				
			SEND:
				// 
				//                       0-word[31:24]  0-word[23:16]  0-word[15:8]  0-word[7:0]
				// ------------------------------------------------------------------------------- Q1 [4095:0]
				//   layerint_buf0         L1-P1          L2-P1          L3-P1         L4-P1
				//   layerint_buf1         L5-P1          L6-P1          L7-P1         L8-P1
				// ------------------------------------------------------------------------------- Q2 [8191:4096]
				//   layerint_buf2         L1-P4224       L2-P4224       L3-P4224      L4-P4224
				//   layerint_buf3         L5-P4224       L6-P4224       L7-P4224      L8-P4224
				// ------------------------------------------------------------------------------- Q3 [12287:8192]
				//   layerint_buf4         L1-P8449       L2-P8449       L3-P8449      L4-P8449
				//   layerint_buf5         L5-P8449       L6-P8449       L7-P8449      L8-P8449
				// ------------------------------------------------------------------------------- Q4 [16383:12288]
				//   layerint_buf6         L1-P12674      L2-P12674      L3-P12674     L4-P12674
				//   layerint_buf7         L5-P12674      L6-P12674      L7-P12674     L8-P12674
				// 
				begin
					case (inlayercount)
						32'd0: data_out <= layerint_buf0_st1[pixelcount];
						32'd0: data_out <= layerint_buf1_st1[pixelcount];
						32'd0: data_out <= layerint_buf2_st1[pixelcount];
						32'd0: data_out <= layerint_buf3_st1[pixelcount];
						32'd0: data_out <= layerint_buf4_st1[pixelcount];
						32'd0: data_out <= layerint_buf5_st1[pixelcount];
						32'd0: data_out <= layerint_buf6_st1[pixelcount];
						32'd0: data_out <= layerint_buf7_st1[pixelcount];
						default: data_out <= 0;
					endcase
				end
				
			default:
				data_out <= 0;
		endcase
	end
endmodule 