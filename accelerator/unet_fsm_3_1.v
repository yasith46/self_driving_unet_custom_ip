module unet_fsm_3_1(
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
	          TRANS       = 2'd2;
				 
	
				 
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv0 (
		.pixel_in(cv_pixelin[0]),
		.w9(cv_w[0][9]), .w8(cv_w[0][8]), .w7(cv_w[0][7]), 
		.w6(cv_w[0][6]), .w5(cv_w[0][5]), .w4(cv_w[0][4]), 
		.w3(cv_w[0][3]), .w2(cv_w[0][2]), .w1(cv_w[0][1]),
		.clk(clk), 
		.rst_n(rst_n && cv_rst[0]),
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
		.rst_n(rst_n && cv_rst[1]),
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
		.rst_n(rst_n && cv_rst[2]),
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
		.rst_n(rst_n && cv_rst[3]),
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
		.rst_n(rst_n && cv_rst[4]),
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
		.rst_n(rst_n && cv_rst[5]),
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
		.rst_n(rst_n && cv_rst[6]),
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
		.rst_n(rst_n && cv_rst[7]),
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
		.rst_n(rst_n && cv_rst[8]),
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
		.rst_n(rst_n && cv_rst[9]),
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
		.rst_n(rst_n && cv_rst[10]),
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
		.rst_n(rst_n && cv_rst[11]),
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
		.rst_n(rst_n && cv_rst[12]),
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
		.rst_n(rst_n && cv_rst[13]),
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
		.rst_n(rst_n && cv_rst[14]),
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
		.rst_n(rst_n && cv_rst[15]),
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
		.rst_n(rst_n && cv_rst[16]),
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
		.rst_n(rst_n && cv_rst[17]),
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
		.rst_n(rst_n && cv_rst[18]),
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
		.rst_n(rst_n && cv_rst[19]),
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
		.rst_n(rst_n && cv_rst[20]),
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
		.rst_n(rst_n && cv_rst[21]),
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
		.rst_n(rst_n && cv_rst[22]),
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
		.rst_n(rst_n && cv_rst[23]),
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
    .rst_n(rst_n && cv_rst[24]),
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
		 .rst_n(rst_n && cv_rst[25]),
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
		 .rst_n(rst_n && cv_rst[26]),
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
		 .rst_n(rst_n && cv_rst[27]),
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
		 .rst_n(rst_n && cv_rst[28]),
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
		 .rst_n(rst_n && cv_rst[29]),
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
		 .rst_n(rst_n && cv_rst[30]),
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
		 .rst_n(rst_n && cv_rst[31]),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[31]),
		 .operation(cv_op[31]),
		.width(cv_width[31]),
		.relu(relu)
	);
	
	
	
	/*********************************************************************************
	 * Set of transpose convolutors
	 */
	 
	wire [31:0] tr_out [0:31];
	reg tr_flip, tr_hop, tr_rw;
	
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans0 (
		.in(cv_pixelin[0]),
		.w9(cv_w[0][9]), .w8(cv_w[0][8]), .w7(cv_w[0][7]), 
		.w6(cv_w[0][6]), .w5(cv_w[0][5]), .w4(cv_w[0][4]), 
		.w3(cv_w[0][3]), .w2(cv_w[0][2]), .w1(cv_w[0][1]),
		.bias(cv_bias[0][7:0]),
		.width(cv_width[0]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[0]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[0])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans1 (
		.in(cv_pixelin[1]),
		.w9(cv_w[1][9]), .w8(cv_w[1][8]), .w7(cv_w[1][7]), 
		.w6(cv_w[1][6]), .w5(cv_w[1][5]), .w4(cv_w[1][4]), 
		.w3(cv_w[1][3]), .w2(cv_w[1][2]), .w1(cv_w[1][1]),
		.bias(cv_bias[1][7:0]),
		.width(cv_width[1]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[1]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[1])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans2 (
		.in(cv_pixelin[2]),
		.w9(cv_w[2][9]), .w8(cv_w[2][8]), .w7(cv_w[2][7]), 
		.w6(cv_w[2][6]), .w5(cv_w[2][5]), .w4(cv_w[2][4]), 
		.w3(cv_w[2][3]), .w2(cv_w[2][2]), .w1(cv_w[2][1]),
		.bias(cv_bias[2][7:0]),
		.width(cv_width[2]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[2]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[2])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans3 (
		.in(cv_pixelin[3]),
		.w9(cv_w[3][9]), .w8(cv_w[3][8]), .w7(cv_w[3][7]), 
		.w6(cv_w[3][6]), .w5(cv_w[3][5]), .w4(cv_w[3][4]), 
		.w3(cv_w[3][3]), .w2(cv_w[3][2]), .w1(cv_w[3][1]),
		.bias(cv_bias[3][7:0]),
		.width(cv_width[3]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[3]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[3])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans4 (
		.in(cv_pixelin[4]),
		.w9(cv_w[4][9]), .w8(cv_w[4][8]), .w7(cv_w[4][7]), 
		.w6(cv_w[4][6]), .w5(cv_w[4][5]), .w4(cv_w[4][4]), 
		.w3(cv_w[4][3]), .w2(cv_w[4][2]), .w1(cv_w[4][1]),
		.bias(cv_bias[4][7:0]),
		.width(cv_width[4]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[4]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[4])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans5 (
		.in(cv_pixelin[5]),
		.w9(cv_w[5][9]), .w8(cv_w[5][8]), .w7(cv_w[5][7]), 
		.w6(cv_w[5][6]), .w5(cv_w[5][5]), .w4(cv_w[5][4]), 
		.w3(cv_w[5][3]), .w2(cv_w[5][2]), .w1(cv_w[5][1]),
		.bias(cv_bias[5][7:0]),
		.width(cv_width[5]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[5]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[5])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans6 (
		.in(cv_pixelin[6]),
		.w9(cv_w[6][9]), .w8(cv_w[6][8]), .w7(cv_w[6][7]), 
		.w6(cv_w[6][6]), .w5(cv_w[6][5]), .w4(cv_w[6][4]), 
		.w3(cv_w[6][3]), .w2(cv_w[6][2]), .w1(cv_w[6][1]),
		.bias(cv_bias[6][7:0]),
		.width(cv_width[6]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[6]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[6])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans7 (
		.in(cv_pixelin[7]),
		.w9(cv_w[7][9]), .w8(cv_w[7][8]), .w7(cv_w[7][7]), 
		.w6(cv_w[7][6]), .w5(cv_w[7][5]), .w4(cv_w[7][4]), 
		.w3(cv_w[7][3]), .w2(cv_w[7][2]), .w1(cv_w[7][1]),
		.bias(cv_bias[7][7:0]),
		.width(cv_width[7]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[7]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[7])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans8 (
		.in(cv_pixelin[8]),
		.w9(cv_w[8][9]), .w8(cv_w[8][8]), .w7(cv_w[8][7]), 
		.w6(cv_w[8][6]), .w5(cv_w[8][5]), .w4(cv_w[8][4]), 
		.w3(cv_w[8][3]), .w2(cv_w[8][2]), .w1(cv_w[8][1]),
		.bias(cv_bias[8][7:0]),
		.width(cv_width[8]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[8]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[8])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans9 (
		.in(cv_pixelin[9]),
		.w9(cv_w[9][9]), .w8(cv_w[9][8]), .w7(cv_w[9][7]), 
		.w6(cv_w[9][6]), .w5(cv_w[9][5]), .w4(cv_w[9][4]), 
		.w3(cv_w[9][3]), .w2(cv_w[9][2]), .w1(cv_w[9][1]),
		.bias(cv_bias[9][7:0]),
		.width(cv_width[9]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[9]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[9])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans10 (
		.in(cv_pixelin[10]),
		.w9(cv_w[10][9]), .w8(cv_w[10][8]), .w7(cv_w[10][7]), 
		.w6(cv_w[10][6]), .w5(cv_w[10][5]), .w4(cv_w[10][4]), 
		.w3(cv_w[10][3]), .w2(cv_w[10][2]), .w1(cv_w[10][1]),
		.bias(cv_bias[10][7:0]),
		.width(cv_width[10]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[10]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[10])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans11 (
		.in(cv_pixelin[11]),
		.w9(cv_w[11][9]), .w8(cv_w[11][8]), .w7(cv_w[11][7]), 
		.w6(cv_w[11][6]), .w5(cv_w[11][5]), .w4(cv_w[11][4]), 
		.w3(cv_w[11][3]), .w2(cv_w[11][2]), .w1(cv_w[11][1]),
		.bias(cv_bias[11][7:0]),
		.width(cv_width[11]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[11]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[11])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans12 (
		.in(cv_pixelin[12]),
		.w9(cv_w[12][9]), .w8(cv_w[12][8]), .w7(cv_w[12][7]), 
		.w6(cv_w[12][6]), .w5(cv_w[12][5]), .w4(cv_w[12][4]), 
		.w3(cv_w[12][3]), .w2(cv_w[12][2]), .w1(cv_w[12][1]),
		.bias(cv_bias[12][7:0]),
		.width(cv_width[12]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[12]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[12])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans13 (
		.in(cv_pixelin[13]),
		.w9(cv_w[13][9]), .w8(cv_w[13][8]), .w7(cv_w[13][7]), 
		.w6(cv_w[13][6]), .w5(cv_w[13][5]), .w4(cv_w[13][4]), 
		.w3(cv_w[13][3]), .w2(cv_w[13][2]), .w1(cv_w[13][1]),
		.bias(cv_bias[13][7:0]),
		.width(cv_width[13]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[13]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[13])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans14 (
		.in(cv_pixelin[14]),
		.w9(cv_w[14][9]), .w8(cv_w[14][8]), .w7(cv_w[14][7]), 
		.w6(cv_w[14][6]), .w5(cv_w[14][5]), .w4(cv_w[14][4]), 
		.w3(cv_w[14][3]), .w2(cv_w[14][2]), .w1(cv_w[14][1]),
		.bias(cv_bias[14][7:0]),
		.width(cv_width[14]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[14]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[14])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans15 (
		.in(cv_pixelin[15]),
		.w9(cv_w[15][9]), .w8(cv_w[15][8]), .w7(cv_w[15][7]), 
		.w6(cv_w[15][6]), .w5(cv_w[15][5]), .w4(cv_w[15][4]), 
		.w3(cv_w[15][3]), .w2(cv_w[15][2]), .w1(cv_w[15][1]),
		.bias(cv_bias[15][7:0]),
		.width(cv_width[15]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[15]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[15])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans16 (
		.in(cv_pixelin[16]),
		.w9(cv_w[16][9]), .w8(cv_w[16][8]), .w7(cv_w[16][7]), 
		.w6(cv_w[16][6]), .w5(cv_w[16][5]), .w4(cv_w[16][4]), 
		.w3(cv_w[16][3]), .w2(cv_w[16][2]), .w1(cv_w[16][1]),
		.bias(cv_bias[16][7:0]),
		.width(cv_width[16]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[16]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[16])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans17 (
		.in(cv_pixelin[17]),
		.w9(cv_w[17][9]), .w8(cv_w[17][8]), .w7(cv_w[17][7]), 
		.w6(cv_w[17][6]), .w5(cv_w[17][5]), .w4(cv_w[17][4]), 
		.w3(cv_w[17][3]), .w2(cv_w[17][2]), .w1(cv_w[17][1]),
		.bias(cv_bias[17][7:0]),
		.width(cv_width[17]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[17]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[17])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans18 (
		.in(cv_pixelin[18]),
		.w9(cv_w[18][9]), .w8(cv_w[18][8]), .w7(cv_w[18][7]), 
		.w6(cv_w[18][6]), .w5(cv_w[18][5]), .w4(cv_w[18][4]), 
		.w3(cv_w[18][3]), .w2(cv_w[18][2]), .w1(cv_w[18][1]),
		.bias(cv_bias[18][7:0]),
		.width(cv_width[18]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[18]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[18])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans19 (
		.in(cv_pixelin[19]),
		.w9(cv_w[19][9]), .w8(cv_w[19][8]), .w7(cv_w[19][7]), 
		.w6(cv_w[19][6]), .w5(cv_w[19][5]), .w4(cv_w[19][4]), 
		.w3(cv_w[19][3]), .w2(cv_w[19][2]), .w1(cv_w[19][1]),
		.bias(cv_bias[19][7:0]),
		.width(cv_width[19]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[19]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[19])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans20 (
		.in(cv_pixelin[20]),
		.w9(cv_w[20][9]), .w8(cv_w[20][8]), .w7(cv_w[20][7]), 
		.w6(cv_w[20][6]), .w5(cv_w[20][5]), .w4(cv_w[20][4]), 
		.w3(cv_w[20][3]), .w2(cv_w[20][2]), .w1(cv_w[20][1]),
		.bias(cv_bias[20][7:0]),
		.width(cv_width[20]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[20]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[20])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans21 (
		.in(cv_pixelin[21]),
		.w9(cv_w[21][9]), .w8(cv_w[21][8]), .w7(cv_w[21][7]), 
		.w6(cv_w[21][6]), .w5(cv_w[21][5]), .w4(cv_w[21][4]), 
		.w3(cv_w[21][3]), .w2(cv_w[21][2]), .w1(cv_w[21][1]),
		.bias(cv_bias[21][7:0]),
		.width(cv_width[21]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[21]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[21])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans22 (
		.in(cv_pixelin[22]),
		.w9(cv_w[22][9]), .w8(cv_w[22][8]), .w7(cv_w[22][7]), 
		.w6(cv_w[22][6]), .w5(cv_w[22][5]), .w4(cv_w[22][4]), 
		.w3(cv_w[22][3]), .w2(cv_w[22][2]), .w1(cv_w[22][1]),
		.bias(cv_bias[22][7:0]),
		.width(cv_width[22]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[22]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[22])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans23 (
		.in(cv_pixelin[23]),
		.w9(cv_w[23][9]), .w8(cv_w[23][8]), .w7(cv_w[23][7]), 
		.w6(cv_w[23][6]), .w5(cv_w[23][5]), .w4(cv_w[23][4]), 
		.w3(cv_w[23][3]), .w2(cv_w[23][2]), .w1(cv_w[23][1]),
		.bias(cv_bias[23][7:0]),
		.width(cv_width[23]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[23]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[23])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans24 (
		.in(cv_pixelin[24]),
		.w9(cv_w[24][9]), .w8(cv_w[24][8]), .w7(cv_w[24][7]), 
		.w6(cv_w[24][6]), .w5(cv_w[24][5]), .w4(cv_w[24][4]), 
		.w3(cv_w[24][3]), .w2(cv_w[24][2]), .w1(cv_w[24][1]),
		.bias(cv_bias[24][7:0]),
		.width(cv_width[24]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[24]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[24])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans25 (
		.in(cv_pixelin[25]),
		.w9(cv_w[25][9]), .w8(cv_w[25][8]), .w7(cv_w[25][7]), 
		.w6(cv_w[25][6]), .w5(cv_w[25][5]), .w4(cv_w[25][4]), 
		.w3(cv_w[25][3]), .w2(cv_w[25][2]), .w1(cv_w[25][1]),
		.bias(cv_bias[25][7:0]),
		.width(cv_width[25]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[25]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[25])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans26 (
		.in(cv_pixelin[26]),
		.w9(cv_w[26][9]), .w8(cv_w[26][8]), .w7(cv_w[26][7]), 
		.w6(cv_w[26][6]), .w5(cv_w[26][5]), .w4(cv_w[26][4]), 
		.w3(cv_w[26][3]), .w2(cv_w[26][2]), .w1(cv_w[26][1]),
		.bias(cv_bias[26][7:0]),
		.width(cv_width[26]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[26]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[26])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans27 (
		.in(cv_pixelin[27]),
		.w9(cv_w[27][9]), .w8(cv_w[27][8]), .w7(cv_w[27][7]), 
		.w6(cv_w[27][6]), .w5(cv_w[27][5]), .w4(cv_w[27][4]), 
		.w3(cv_w[27][3]), .w2(cv_w[27][2]), .w1(cv_w[27][1]),
		.bias(cv_bias[27][7:0]),
		.width(cv_width[27]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[27]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[27])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans28 (
		.in(cv_pixelin[28]),
		.w9(cv_w[28][9]), .w8(cv_w[28][8]), .w7(cv_w[28][7]), 
		.w6(cv_w[28][6]), .w5(cv_w[28][5]), .w4(cv_w[28][4]), 
		.w3(cv_w[28][3]), .w2(cv_w[28][2]), .w1(cv_w[28][1]),
		.bias(cv_bias[28][7:0]),
		.width(cv_width[28]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[28]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[28])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans29 (
		.in(cv_pixelin[29]),
		.w9(cv_w[29][9]), .w8(cv_w[29][8]), .w7(cv_w[29][7]), 
		.w6(cv_w[29][6]), .w5(cv_w[29][5]), .w4(cv_w[29][4]), 
		.w3(cv_w[29][3]), .w2(cv_w[29][2]), .w1(cv_w[29][1]),
		.bias(cv_bias[29][7:0]),
		.width(cv_width[29]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[29]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[29])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans30 (
		.in(cv_pixelin[30]),
		.w9(cv_w[30][9]), .w8(cv_w[30][8]), .w7(cv_w[30][7]), 
		.w6(cv_w[30][6]), .w5(cv_w[30][5]), .w4(cv_w[30][4]), 
		.w3(cv_w[30][3]), .w2(cv_w[30][2]), .w1(cv_w[30][1]),
		.bias(cv_bias[30][7:0]),
		.width(cv_width[30]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[30]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[30])
	);
	
	transconv #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) trans31 (
		.in(cv_pixelin[31]),
		.w9(cv_w[31][9]), .w8(cv_w[31][8]), .w7(cv_w[31][7]), 
		.w6(cv_w[31][6]), .w5(cv_w[31][5]), .w4(cv_w[31][4]), 
		.w3(cv_w[31][3]), .w2(cv_w[31][2]), .w1(cv_w[31][1]),
		.bias(cv_bias[31][7:0]),
		.width(cv_width[31]),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && cv_rst[31]),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out[31])
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
	 
	reg [31:0] cv00_wb_0_buf   [0:1028];	//  1: {cv0_w4, cv0_w3, cv0_w2, cv0_w1} -----
	reg [31:0] cv00_wb_1_buf   [0:1028];   //  2: {cv0_w8, cv0_w7, cv0_w6, cv0_w5}
	reg [31:0] cv0001_wb_2_buf [0:1028];	//  3: {cv1_w3, cv1_w2, cv1_w1, cv0_w9}
	reg [31:0] cv01_wb_0_buf   [0:1028];   //  4: {cv1_w7, cv1_w6, cv1_w5, cv1_w4}
	reg [31:0] cv0102_wb_1_buf [0:1028];   //  5: {cv2_w2, cv2_w1, cv1_w9, cv1_w8}
	reg [31:0] cv02_wb_0_buf   [0:1028];   //  6: {cv2_w6, cv2_w5, cv2_w4, cv2_w3}
	reg [31:0] cv0203_wb_0_buf [0:1028];   //  7: {cv3_w1, cv2_w9, cv2_w8, cv2_w7}
	reg [31:0] cv03_wb_0_buf   [0:1028];	//  8: {cv3_w5, cv3_w4, cv3_w3, cv3_w2}
	reg [31:0] cv03_wb_1_buf   [0:1028];   //  9: {cv3_w9, cv3_w8, cv3_w7, cv3_w6}
	reg [31:0] cv04_wb_0_buf   [0:1028];	// 10: {cv4_w4, cv4_w3, cv4_w2, cv4_w1} -----
	reg [31:0] cv04_wb_1_buf   [0:1028];   // 11: {cv4_w8, cv4_w7, cv4_w6, cv4_w5}
	reg [31:0] cv0405_wb_2_buf [0:1028];	// 12: {cv5_w3, cv5_w2, cv5_w1, cv4_w9}
	reg [31:0] cv05_wb_0_buf   [0:1028];   // 13: {cv5_w7, cv5_w6, cv5_w5, cv5_w4}
	reg [31:0] cv0506_wb_1_buf [0:1028];   // 14: {cv6_w2, cv6_w1, cv5_w9, cv5_w8}
	reg [31:0] cv06_wb_0_buf   [0:1028];   // 15: {cv6_w6, cv6_w5, cv6_w4, cv6_w3}
	reg [31:0] cv0607_wb_0_buf [0:1028];   // 16: {cv7_w1, cv6_w9, cv6_w8, cv6_w7}
	reg [31:0] cv07_wb_0_buf   [0:1028];	// 17: {cv7_w5, cv7_w4, cv7_w3, cv7_w2}
	reg [31:0] cv07_wb_1_buf   [0:1028];   // 18: {cv7_w9, cv7_w8, cv7_w7, cv7_w6}
	reg [31:0] cv08_wb_0_buf   [0:1028];	// 19: {cv8_w4, cv8_w3, cv8_w2, cv8_w1} -----
	reg [31:0] cv08_wb_1_buf   [0:1028];   // 20: {cv8_w8, cv8_w7, cv8_w6, cv8_w5}
	reg [31:0] cv0809_wb_2_buf [0:1028];	// 21: {cv1_w3, cv1_w2, cv1_w1, cv8_w9}
	reg [31:0] cv09_wb_0_buf   [0:1028];   // 22: {cv9_w7, cv9_w6, cv9_w5, cv9_w4}
	reg [31:0] cv0910_wb_1_buf [0:1028];   // 23: {cv10_w2, cv10_w1, cv9_w9, cv9_w8}
	reg [31:0] cv10_wb_0_buf   [0:1028];   // 24: {cv10_w6, cv10_w5, cv10_w4, cv10_w3}
	reg [31:0] cv1011_wb_0_buf [0:1028];   // 25: {cv11_w1, cv10_w9, cv10_w8, cv10_w7}
	reg [31:0] cv11_wb_0_buf   [0:1028];	// 26: {cv11_w5, cv11_w4, cv11_w3, cv11_w2}
	reg [31:0] cv11_wb_1_buf   [0:1028];   // 27: {cv11_w9, cv11_w8, cv11_w7, cv11_w6}
	reg [31:0] cv12_wb_0_buf   [0:1028];	// 28: {cv12_w4, cv12_w3, cv12_w2, cv12_w1} -----
	reg [31:0] cv12_wb_1_buf   [0:1028];   // 29: {cv12_w8, cv12_w7, cv12_w6, cv12_w5}
	reg [31:0] cv1213_wb_2_buf [0:1028];   // 30: {cv13_w3, cv13_w2, cv13_w1, cv12_w9}
	reg [31:0] cv13_wb_0_buf   [0:1028];   // 31: {cv13_w7, cv13_w6, cv13_w5, cv13_w4}
	reg [31:0] cv1314_wb_1_buf [0:1028];   // 32: {cv14_w2, cv14_w1, cv13_w9, cv13_w8}
	reg [31:0] cv14_wb_0_buf   [0:1028];   // 33: {cv14_w6, cv14_w5, cv14_w4, cv14_w3}
	reg [31:0] cv1415_wb_0_buf [0:1028];   // 34: {cv15_w1, cv14_w9, cv14_w8, cv14_w7}
	reg [31:0] cv15_wb_0_buf   [0:1028];	// 35: {cv15_w5, cv15_w4, cv15_w3, cv15_w2}
	reg [31:0] cv15_wb_1_buf   [0:1028];   // 36: {cv15_w9, cv15_w8, cv15_w7, cv15_w6}
	reg [31:0] cv16_wb_0_buf   [0:1028];	// 37: {cv16_w4, cv16_w3, cv16_w2, cv16_w1} -----
	reg [31:0] cv16_wb_1_buf   [0:1028];   // 38: {cv16_w8, cv16_w7, cv16_w6, cv16_w5}
	reg [31:0] cv1617_wb_2_buf [0:1028];   // 39: {cv17_w3, cv17_w2, cv17_w1, cv16_w9}
	reg [31:0] cv17_wb_0_buf   [0:1028];   // 40: {cv17_w7, cv17_w6, cv17_w5, cv17_w4}
	reg [31:0] cv1718_wb_1_buf [0:1028];   // 41: {cv18_w2, cv18_w1, cv17_w9, cv17_w8}
	reg [31:0] cv18_wb_0_buf   [0:1028];   // 42: {cv18_w6, cv18_w5, cv18_w4, cv18_w3}
	reg [31:0] cv1819_wb_0_buf [0:1028];   // 43: {cv19_w1, cv18_w9, cv18_w8, cv18_w7}
	reg [31:0] cv19_wb_0_buf   [0:1028];	// 44: {cv19_w5, cv19_w4, cv19_w3, cv19_w2}
	reg [31:0] cv19_wb_1_buf   [0:1028];   // 45: {cv19_w9, cv19_w8, cv19_w7, cv19_w6}
	reg [31:0] cv20_wb_0_buf   [0:1028];	// 46: {cv20_w4, cv20_w3, cv20_w2, cv20_w1} -----
	reg [31:0] cv20_wb_1_buf   [0:1028];   // 47: {cv20_w8, cv20_w7, cv20_w6, cv20_w5}
	reg [31:0] cv2021_wb_2_buf [0:1028];   // 48: {cv21_w3, cv21_w2, cv21_w1, cv20_w9}
	reg [31:0] cv21_wb_0_buf   [0:1028];   // 49: {cv21_w7, cv21_w6, cv21_w5, cv21_w4}
	reg [31:0] cv2122_wb_1_buf [0:1028];   // 50: {cv22_w2, cv22_w1, cv21_w9, cv21_w8}
	reg [31:0] cv22_wb_0_buf   [0:1028];   // 51: {cv22_w6, cv22_w5, cv22_w4, cv22_w3}
	reg [31:0] cv2223_wb_0_buf [0:1028];   // 52: {cv23_w1, cv22_w9, cv22_w8, cv22_w7}
	reg [31:0] cv23_wb_0_buf   [0:1028];	// 53: {cv23_w5, cv23_w4, cv23_w3, cv23_w2}
	reg [31:0] cv23_wb_1_buf   [0:1028];   // 54: {cv23_w9, cv23_w8, cv23_w7, cv23_w6}
	reg [31:0] cv24_wb_0_buf   [0:1028];	// 55: {cv24_w4, cv24_w3, cv24_w2, cv24_w1} -----
	reg [31:0] cv24_wb_1_buf   [0:1028];   // 56: {cv24_w8, cv24_w7, cv24_w6, cv24_w5}
	reg [31:0] cv2425_wb_2_buf [0:1028];   // 57: {cv25_w3, cv25_w2, cv25_w1, cv24_w9}
	reg [31:0] cv25_wb_0_buf   [0:1028];   // 58: {cv25_w7, cv25_w6, cv25_w5, cv25_w4}
	reg [31:0] cv2526_wb_1_buf [0:1028];   // 59: {cv26_w2, cv26_w1, cv25_w9, cv25_w8}
	reg [31:0] cv26_wb_0_buf   [0:1028];   // 60: {cv26_w6, cv26_w5, cv26_w4, cv26_w3}
	reg [31:0] cv2627_wb_0_buf [0:1028];   // 61: {cv27_w1, cv26_w9, cv26_w8, cv26_w7}
	reg [31:0] cv27_wb_0_buf   [0:1028];	// 62: {cv27_w5, cv27_w4, cv27_w3, cv27_w2}
	reg [31:0] cv27_wb_1_buf   [0:1028];   // 63: {cv27_w9, cv27_w8, cv27_w7, cv27_w6}
	reg [31:0] cv28_wb_0_buf   [0:1028];	// 64: {cv28_w4, cv28_w3, cv28_w2, cv28_w1} -----
	reg [31:0] cv28_wb_1_buf   [0:1028];   // 65: {cv28_w8, cv28_w7, cv28_w6, cv28_w5}
	reg [31:0] cv2829_wb_2_buf [0:1028];   // 66: {cv29_w3, cv29_w2, cv29_w1, cv28_w9}
	reg [31:0] cv29_wb_0_buf   [0:1028];   // 67: {cv29_w7, cv29_w6, cv29_w5, cv29_w4}
	reg [31:0] cv2930_wb_1_buf [0:1028];   // 68: {cv30_w2, cv30_w1, cv29_w9, cv29_w8}
	reg [31:0] cv30_wb_0_buf   [0:1028];   // 69: {cv30_w6, cv30_w5, cv30_w4, cv30_w3}
	reg [31:0] cv3031_wb_0_buf [0:1028];   // 70: {cv31_w1, cv30_w9, cv30_w8, cv30_w7}
	reg [31:0] cv31_wb_0_buf   [0:1028];	// 71: {cv31_w5, cv31_w4, cv31_w3, cv31_w2}
	reg [31:0] cv31_wb_1_buf   [0:1028];   // 72: {cv31_w9, cv31_w8, cv31_w7, cv31_w6}
	
	reg [31:0] cv0_bias_buf [0:1028];	
	reg [31:0] cv1_bias_buf [0:1028];	
	reg [31:0] cv2_bias_buf [0:1028];	
	reg [31:0] cv3_bias_buf [0:1028];	
	reg [31:0] cv4_bias_buf [0:1028];	
	reg [31:0] cv5_bias_buf [0:1028];	
	reg [31:0] cv6_bias_buf [0:1028];	
	reg [31:0] cv7_bias_buf [0:1028];	
	reg [31:0] cv8_bias_buf [0:1028];	
	reg [31:0] cv9_bias_buf [0:1028];
	reg [31:0] cv10_bias_buf [0:1028];	
	reg [31:0] cv11_bias_buf [0:1028];	
	reg [31:0] cv12_bias_buf [0:1028];	
	reg [31:0] cv13_bias_buf [0:1028];	
	reg [31:0] cv14_bias_buf [0:1028];	
	reg [31:0] cv15_bias_buf [0:1028];	
	reg [31:0] cv16_bias_buf [0:1028];	
	reg [31:0] cv17_bias_buf [0:1028];	
	reg [31:0] cv18_bias_buf [0:1028];	
	reg [31:0] cv19_bias_buf [0:1028];
	reg [31:0] cv20_bias_buf [0:1028];	
	reg [31:0] cv21_bias_buf [0:1028];	
	reg [31:0] cv22_bias_buf [0:1028];	
	reg [31:0] cv23_bias_buf [0:1028];	
	reg [31:0] cv24_bias_buf [0:1028];	
	reg [31:0] cv25_bias_buf [0:1028];	
	reg [31:0] cv26_bias_buf [0:1028];	
	reg [31:0] cv27_bias_buf [0:1028];	
	reg [31:0] cv28_bias_buf [0:1028];	
	reg [31:0] cv29_bias_buf [0:1028];
	reg [31:0] cv30_bias_buf [0:1028];	
	reg [31:0] cv31_bias_buf [0:1028];	
	
	reg [31:0] qt_buf [0:13];
	
	
	/*********************************************************************************
	 * Macros for loading weights
	 */				
	
	`define load_bias(src)                 \
		cv_bias[0]  <= cv0_bias_buf[src];   \
		cv_bias[1]  <= cv1_bias_buf[src];   \
		cv_bias[2]  <= cv2_bias_buf[src];   \
		cv_bias[3]  <= cv3_bias_buf[src];   \
		cv_bias[4]  <= cv4_bias_buf[src];   \
		cv_bias[5]  <= cv5_bias_buf[src];   \
		cv_bias[6]  <= cv6_bias_buf[src];   \
		cv_bias[7]  <= cv7_bias_buf[src];   \
		cv_bias[8]  <= cv8_bias_buf[src];   \
		cv_bias[9]  <= cv9_bias_buf[src];   \
		cv_bias[10] <= cv10_bias_buf[src];  \
		cv_bias[11] <= cv11_bias_buf[src];  \
		cv_bias[12] <= cv12_bias_buf[src];  \
		cv_bias[13] <= cv13_bias_buf[src];  \
		cv_bias[14] <= cv14_bias_buf[src];  \
		cv_bias[15] <= cv15_bias_buf[src];  \
		cv_bias[16] <= cv16_bias_buf[src];  \
		cv_bias[17] <= cv17_bias_buf[src];  \
		cv_bias[18] <= cv18_bias_buf[src];  \
		cv_bias[19] <= cv19_bias_buf[src];  \
		cv_bias[20] <= cv20_bias_buf[src];  \
		cv_bias[21] <= cv21_bias_buf[src];  \
		cv_bias[22] <= cv22_bias_buf[src];  \
		cv_bias[23] <= cv23_bias_buf[src];  \
		cv_bias[24] <= cv24_bias_buf[src];  \
		cv_bias[25] <= cv25_bias_buf[src];  \
		cv_bias[26] <= cv26_bias_buf[src];  \
		cv_bias[27] <= cv27_bias_buf[src];  \
		cv_bias[28] <= cv28_bias_buf[src];  \
		cv_bias[29] <= cv29_bias_buf[src];  \
		cv_bias[30] <= cv30_bias_buf[src];  \
		cv_bias[31] <= cv31_bias_buf[src];
	
	`define load_weight(src)                        \
		`load_bias(src)                              \
		cv_w[0][1] <= cv00_wb_0_buf[src][7:0];       \
		cv_w[0][2] <= cv00_wb_0_buf[src][15:8];      \
		cv_w[0][3] <= cv00_wb_0_buf[src][23:16];     \
		cv_w[0][4] <= cv00_wb_0_buf[src][31:24];     \
		cv_w[0][5] <= cv00_wb_1_buf[src][7:0];       \
		cv_w[0][6] <= cv00_wb_1_buf[src][15:8];      \
		cv_w[0][7] <= cv00_wb_1_buf[src][23:16];     \
		cv_w[0][8] <= cv00_wb_1_buf[src][31:24];     \
		cv_w[0][9] <= cv0001_wb_2_buf[src][7:0];     \
		cv_w[1][1] <= cv0001_wb_2_buf[src][15:8];    \
		cv_w[1][2] <= cv0001_wb_2_buf[src][23:16];   \
		cv_w[1][3] <= cv0001_wb_2_buf[src][31:24];   \
		cv_w[1][4] <= cv01_wb_0_buf[src][7:0];       \
		cv_w[1][5] <= cv01_wb_0_buf[src][15:8];      \
		cv_w[1][6] <= cv01_wb_0_buf[src][23:16];     \
		cv_w[1][7] <= cv01_wb_0_buf[src][31:24];     \
		cv_w[1][8] <= cv0102_wb_1_buf[src][7:0];     \
		cv_w[1][9] <= cv0102_wb_1_buf[src][15:8];    \
		cv_w[2][1] <= cv0102_wb_1_buf[src][23:16];   \
		cv_w[2][2] <= cv0102_wb_1_buf[src][31:24];   \
		cv_w[2][3] <= cv02_wb_0_buf[src][7:0];       \
		cv_w[2][4] <= cv02_wb_0_buf[src][15:8];      \
		cv_w[2][5] <= cv02_wb_0_buf[src][23:16];     \
		cv_w[2][6] <= cv02_wb_0_buf[src][31:24];     \
		cv_w[2][7] <= cv0203_wb_0_buf[src][7:0];     \
		cv_w[2][8] <= cv0203_wb_0_buf[src][15:8];    \
		cv_w[2][9] <= cv0203_wb_0_buf[src][23:16];   \
		cv_w[3][1] <= cv0203_wb_0_buf[src][31:24];   \
		cv_w[3][2] <= cv03_wb_0_buf[src][7:0];       \
		cv_w[3][3] <= cv03_wb_0_buf[src][15:8];      \
		cv_w[3][4] <= cv03_wb_0_buf[src][23:16];     \
		cv_w[3][5] <= cv03_wb_0_buf[src][31:24];     \
		cv_w[3][6] <= cv03_wb_1_buf[src][7:0];       \
		cv_w[3][7] <= cv03_wb_1_buf[src][15:8];      \
		cv_w[3][8] <= cv03_wb_1_buf[src][23:16];     \
		cv_w[3][9] <= cv03_wb_1_buf[src][31:24];     \
		cv_w[4][1] <= cv04_wb_0_buf[src][7:0];       \
		cv_w[4][2] <= cv04_wb_0_buf[src][15:8];      \
		cv_w[4][3] <= cv04_wb_0_buf[src][23:16];     \
		cv_w[4][4] <= cv04_wb_0_buf[src][31:24];     \
		cv_w[4][5] <= cv04_wb_1_buf[src][7:0];       \
		cv_w[4][6] <= cv04_wb_1_buf[src][15:8];      \
		cv_w[4][7] <= cv04_wb_1_buf[src][23:16];     \
		cv_w[4][8] <= cv04_wb_1_buf[src][31:24];     \
		cv_w[4][9] <= cv0405_wb_2_buf[src][7:0];	   \
		cv_w[5][1] <= cv0405_wb_2_buf[src][15:8];    \
		cv_w[5][2] <= cv0405_wb_2_buf[src][23:16];   \
		cv_w[5][3] <= cv0405_wb_2_buf[src][31:24];   \
		cv_w[5][4] <= cv05_wb_0_buf[src][7:0];       \
		cv_w[5][5] <= cv05_wb_0_buf[src][15:8];      \
		cv_w[5][6] <= cv05_wb_0_buf[src][23:16];     \
		cv_w[5][7] <= cv05_wb_0_buf[src][31:24];     \
		cv_w[5][8] <= cv0506_wb_1_buf[src][7:0];     \
		cv_w[5][9] <= cv0506_wb_1_buf[src][15:8];    \
		cv_w[6][1] <= cv0506_wb_1_buf[src][23:16];   \
		cv_w[6][2] <= cv0506_wb_1_buf[src][31:24];   \
		cv_w[6][3] <= cv06_wb_0_buf[src][7:0];       \
		cv_w[6][4] <= cv06_wb_0_buf[src][15:8];      \
		cv_w[6][5] <= cv06_wb_0_buf[src][23:16];     \
		cv_w[6][6] <= cv06_wb_0_buf[src][31:24];     \
		cv_w[6][7] <= cv0607_wb_0_buf[src][7:0];     \
		cv_w[6][8] <= cv0607_wb_0_buf[src][15:8];    \
		cv_w[6][9] <= cv0607_wb_0_buf[src][23:16];   \
		cv_w[7][1] <= cv0607_wb_0_buf[src][31:24];   \
		cv_w[7][2] <= cv07_wb_0_buf[src][7:0];       \
		cv_w[7][3] <= cv07_wb_0_buf[src][15:8];      \
		cv_w[7][4] <= cv07_wb_0_buf[src][23:16];     \
		cv_w[7][5] <= cv07_wb_0_buf[src][31:24];     \
		cv_w[7][6] <= cv07_wb_1_buf[src][7:0];       \
		cv_w[7][7] <= cv07_wb_1_buf[src][15:8];      \
		cv_w[7][8] <= cv07_wb_1_buf[src][23:16];     \
		cv_w[7][9] <= cv07_wb_1_buf[src][31:24];     \
		cv_w[8][1] <= cv08_wb_0_buf[src][7:0];       \
		cv_w[8][2] <= cv08_wb_0_buf[src][15:8];      \
		cv_w[8][3] <= cv08_wb_0_buf[src][23:16];     \
		cv_w[8][4] <= cv08_wb_0_buf[src][31:24];     \
		cv_w[8][5] <= cv08_wb_1_buf[src][7:0];       \
		cv_w[8][6] <= cv08_wb_1_buf[src][15:8];      \
		cv_w[8][7] <= cv08_wb_1_buf[src][23:16];     \
		cv_w[8][8] <= cv08_wb_1_buf[src][31:24];     \
		cv_w[8][9] <= cv0809_wb_2_buf[src][7:0];     \
		cv_w[9][1] <= cv0809_wb_2_buf[src][15:8];    \
		cv_w[9][2] <= cv0809_wb_2_buf[src][23:16];   \
		cv_w[9][3] <= cv0809_wb_2_buf[src][31:24];   \
		cv_w[9][4] <= cv09_wb_0_buf[src][7:0];       \
		cv_w[9][5] <= cv09_wb_0_buf[src][15:8];      \
		cv_w[9][6] <= cv09_wb_0_buf[src][23:16];     \
		cv_w[9][7] <= cv09_wb_0_buf[src][31:24];     \
		cv_w[9][8] <= cv0910_wb_1_buf[src][7:0];     \
		cv_w[9][9] <= cv0910_wb_1_buf[src][15:8];    \
		cv_w[10][1] <= cv0910_wb_1_buf[src][23:16];  \
		cv_w[10][2] <= cv0910_wb_1_buf[src][31:24];  \
		cv_w[10][3] <= cv10_wb_0_buf[src][7:0];      \
		cv_w[10][4] <= cv10_wb_0_buf[src][15:8];     \
		cv_w[10][5] <= cv10_wb_0_buf[src][23:16];    \
		cv_w[10][6] <= cv10_wb_0_buf[src][31:24];    \
		cv_w[10][7] <= cv1011_wb_0_buf[src][7:0];    \
		cv_w[10][8] <= cv1011_wb_0_buf[src][15:8];   \
		cv_w[10][9] <= cv1011_wb_0_buf[src][23:16];  \
		cv_w[11][1] <= cv1011_wb_0_buf[src][31:24];  \
		cv_w[11][2] <= cv11_wb_0_buf[src][7:0];      \
		cv_w[11][3] <= cv11_wb_0_buf[src][15:8];     \
		cv_w[11][4] <= cv11_wb_0_buf[src][23:16];    \
		cv_w[11][5] <= cv11_wb_0_buf[src][31:24];    \
		cv_w[11][6] <= cv11_wb_1_buf[src][7:0];      \
		cv_w[11][7] <= cv11_wb_1_buf[src][15:8];     \
		cv_w[11][8] <= cv11_wb_1_buf[src][23:16];    \
		cv_w[11][9] <= cv11_wb_1_buf[src][31:24];	   \
		cv_w[12][1] <= cv12_wb_0_buf[src][7:0];      \
		cv_w[12][2] <= cv12_wb_0_buf[src][15:8];     \
		cv_w[12][3] <= cv12_wb_0_buf[src][23:16];    \
		cv_w[12][4] <= cv12_wb_0_buf[src][31:24];    \
		cv_w[12][5] <= cv12_wb_1_buf[src][7:0];      \
		cv_w[12][6] <= cv12_wb_1_buf[src][15:8];     \
		cv_w[12][7] <= cv12_wb_1_buf[src][23:16];    \
		cv_w[12][8] <= cv12_wb_1_buf[src][31:24];    \
		cv_w[12][9] <= cv1213_wb_2_buf[src][7:0];    \
		cv_w[13][1] <= cv1213_wb_2_buf[src][15:8];   \
		cv_w[13][2] <= cv1213_wb_2_buf[src][23:16];  \
		cv_w[13][3] <= cv1213_wb_2_buf[src][31:24];  \
		cv_w[13][4] <= cv13_wb_0_buf[src][7:0];      \
		cv_w[13][5] <= cv13_wb_0_buf[src][15:8];     \
		cv_w[13][6] <= cv13_wb_0_buf[src][23:16];    \
		cv_w[13][7] <= cv13_wb_0_buf[src][31:24];    \
		cv_w[13][8] <= cv1314_wb_1_buf[src][7:0];    \
		cv_w[13][9] <= cv1314_wb_1_buf[src][15:8];   \
		cv_w[14][1] <= cv1314_wb_1_buf[src][23:16];  \
		cv_w[14][2] <= cv1314_wb_1_buf[src][31:24];  \
		cv_w[14][3] <= cv14_wb_0_buf[src][7:0];      \
		cv_w[14][4] <= cv14_wb_0_buf[src][15:8];     \
		cv_w[14][5] <= cv14_wb_0_buf[src][23:16];    \
		cv_w[14][6] <= cv14_wb_0_buf[src][31:24];    \
		cv_w[14][7] <= cv1415_wb_0_buf[src][7:0];    \
		cv_w[14][8] <= cv1415_wb_0_buf[src][15:8];   \
		cv_w[14][9] <= cv1415_wb_0_buf[src][23:16];  \
		cv_w[15][1] <= cv1415_wb_0_buf[src][31:24];  \
		cv_w[15][2] <= cv15_wb_0_buf[src][7:0];      \
		cv_w[15][3] <= cv15_wb_0_buf[src][15:8];     \
		cv_w[15][4] <= cv15_wb_0_buf[src][23:16];    \
		cv_w[15][5] <= cv15_wb_0_buf[src][31:24];    \
		cv_w[15][6] <= cv15_wb_1_buf[src][7:0];      \
		cv_w[15][7] <= cv15_wb_1_buf[src][15:8];     \
		cv_w[15][8] <= cv15_wb_1_buf[src][23:16];    \
		cv_w[15][9] <= cv15_wb_1_buf[src][31:24];    \
		cv_w[16][1] <= cv16_wb_0_buf[src][7:0];      \
		cv_w[16][2] <= cv16_wb_0_buf[src][15:8];     \
		cv_w[16][3] <= cv16_wb_0_buf[src][23:16];    \
		cv_w[16][4] <= cv16_wb_0_buf[src][31:24];    \
		cv_w[16][5] <= cv16_wb_1_buf[src][7:0];      \
		cv_w[16][6] <= cv16_wb_1_buf[src][15:8];     \
		cv_w[16][7] <= cv16_wb_1_buf[src][23:16];    \
		cv_w[16][8] <= cv16_wb_1_buf[src][31:24];    \
		cv_w[16][9] <= cv1617_wb_2_buf[src][7:0];    \
		cv_w[17][1] <= cv1617_wb_2_buf[src][15:8];   \
		cv_w[17][2] <= cv1617_wb_2_buf[src][23:16];  \
		cv_w[17][3] <= cv1617_wb_2_buf[src][31:24];  \
		cv_w[17][4] <= cv17_wb_0_buf[src][7:0];      \
		cv_w[17][5] <= cv17_wb_0_buf[src][15:8];     \
		cv_w[17][6] <= cv17_wb_0_buf[src][23:16];    \
		cv_w[17][7] <= cv17_wb_0_buf[src][31:24];    \
		cv_w[17][8] <= cv1718_wb_1_buf[src][7:0];    \
		cv_w[17][9] <= cv1718_wb_1_buf[src][15:8];   \
		cv_w[18][1] <= cv1718_wb_1_buf[src][23:16];  \
		cv_w[18][2] <= cv1718_wb_1_buf[src][31:24];  \
		cv_w[18][3] <= cv18_wb_0_buf[src][7:0];      \
		cv_w[18][4] <= cv18_wb_0_buf[src][15:8];     \
		cv_w[18][5] <= cv18_wb_0_buf[src][23:16];    \
		cv_w[18][6] <= cv18_wb_0_buf[src][31:24];    \
		cv_w[18][7] <= cv1819_wb_0_buf[src][7:0];    \
		cv_w[18][8] <= cv1819_wb_0_buf[src][15:8];   \
		cv_w[18][9] <= cv1819_wb_0_buf[src][23:16];  \
		cv_w[19][1] <= cv1819_wb_0_buf[src][31:24];  \
		cv_w[19][2] <= cv19_wb_0_buf[src][7:0];      \
		cv_w[19][3] <= cv19_wb_0_buf[src][15:8];     \
		cv_w[19][4] <= cv19_wb_0_buf[src][23:16];    \
		cv_w[19][5] <= cv19_wb_0_buf[src][31:24];    \
		cv_w[19][6] <= cv19_wb_1_buf[src][7:0];      \
		cv_w[19][7] <= cv19_wb_1_buf[src][15:8];     \
		cv_w[19][8] <= cv19_wb_1_buf[src][23:16];    \
		cv_w[19][9] <= cv19_wb_1_buf[src][31:24];    \
		cv_w[20][1] <= cv20_wb_0_buf[src][7:0];      \
		cv_w[20][2] <= cv20_wb_0_buf[src][15:8];     \
		cv_w[20][3] <= cv20_wb_0_buf[src][23:16];    \
		cv_w[20][4] <= cv20_wb_0_buf[src][31:24];    \
		cv_w[20][5] <= cv20_wb_1_buf[src][7:0];      \
		cv_w[20][6] <= cv20_wb_1_buf[src][15:8];     \
		cv_w[20][7] <= cv20_wb_1_buf[src][23:16];    \
		cv_w[20][8] <= cv20_wb_1_buf[src][31:24];    \
		cv_w[20][9] <= cv2021_wb_2_buf[src][7:0];    \
		cv_w[21][1] <= cv2021_wb_2_buf[src][15:8];   \
		cv_w[21][2] <= cv2021_wb_2_buf[src][23:16];  \
		cv_w[21][3] <= cv2021_wb_2_buf[src][31:24];  \
		cv_w[21][4] <= cv21_wb_0_buf[src][7:0];      \
		cv_w[21][5] <= cv21_wb_0_buf[src][15:8];     \
		cv_w[21][6] <= cv21_wb_0_buf[src][23:16];    \
		cv_w[21][7] <= cv21_wb_0_buf[src][31:24];    \
		cv_w[21][8] <= cv2122_wb_1_buf[src][7:0];    \
		cv_w[21][9] <= cv2122_wb_1_buf[src][15:8];   \
		cv_w[22][1] <= cv2122_wb_1_buf[src][23:16];  \
		cv_w[22][2] <= cv2122_wb_1_buf[src][31:24];  \
		cv_w[22][3] <= cv22_wb_0_buf[src][7:0];      \
		cv_w[22][4] <= cv22_wb_0_buf[src][15:8];     \
		cv_w[22][5] <= cv22_wb_0_buf[src][23:16];    \
		cv_w[22][6] <= cv22_wb_0_buf[src][31:24];    \
		cv_w[22][7] <= cv2223_wb_0_buf[src][7:0];    \
		cv_w[22][8] <= cv2223_wb_0_buf[src][15:8];   \
		cv_w[22][9] <= cv2223_wb_0_buf[src][23:16];  \
		cv_w[23][1] <= cv2223_wb_0_buf[src][31:24];  \
		cv_w[23][2] <= cv23_wb_0_buf[src][7:0];      \
		cv_w[23][3] <= cv23_wb_0_buf[src][15:8];     \
		cv_w[23][4] <= cv23_wb_0_buf[src][23:16];    \
		cv_w[23][5] <= cv23_wb_0_buf[src][31:24];    \
		cv_w[23][6] <= cv23_wb_1_buf[src][7:0];      \
		cv_w[23][7] <= cv23_wb_1_buf[src][15:8];     \
		cv_w[23][8] <= cv23_wb_1_buf[src][23:16];    \
		cv_w[23][9] <= cv23_wb_1_buf[src][31:24];    \
		cv_w[24][1] <= cv24_wb_0_buf[src][7:0];      \
		cv_w[24][2] <= cv24_wb_0_buf[src][15:8];     \
		cv_w[24][3] <= cv24_wb_0_buf[src][23:16];    \
		cv_w[24][4] <= cv24_wb_0_buf[src][31:24];    \
		cv_w[24][5] <= cv24_wb_1_buf[src][7:0];      \
		cv_w[24][6] <= cv24_wb_1_buf[src][15:8];     \
		cv_w[24][7] <= cv24_wb_1_buf[src][23:16];    \
		cv_w[24][8] <= cv24_wb_1_buf[src][31:24];    \
		cv_w[24][9] <= cv2425_wb_2_buf[src][7:0];    \
		cv_w[25][1] <= cv2425_wb_2_buf[src][15:8];   \
		cv_w[25][2] <= cv2425_wb_2_buf[src][23:16];  \
		cv_w[25][3] <= cv2425_wb_2_buf[src][31:24];  \
		cv_w[25][4] <= cv25_wb_0_buf[src][7:0];      \
		cv_w[25][5] <= cv25_wb_0_buf[src][15:8];     \
		cv_w[25][6] <= cv25_wb_0_buf[src][23:16];    \
		cv_w[25][7] <= cv25_wb_0_buf[src][31:24];    \
		cv_w[25][8] <= cv2526_wb_1_buf[src][7:0];    \
		cv_w[25][9] <= cv2526_wb_1_buf[src][15:8];   \
		cv_w[26][1] <= cv2526_wb_1_buf[src][23:16];  \
		cv_w[26][2] <= cv2526_wb_1_buf[src][31:24];  \
		cv_w[26][3] <= cv26_wb_0_buf[src][7:0];      \
		cv_w[26][4] <= cv26_wb_0_buf[src][15:8];     \
		cv_w[26][5] <= cv26_wb_0_buf[src][23:16];    \
		cv_w[26][6] <= cv26_wb_0_buf[src][31:24];    \
		cv_w[26][7] <= cv2627_wb_0_buf[src][7:0];    \
		cv_w[26][8] <= cv2627_wb_0_buf[src][15:8];   \
		cv_w[26][9] <= cv2627_wb_0_buf[src][23:16];  \
		cv_w[27][1] <= cv2627_wb_0_buf[src][31:24];  \
		cv_w[27][2] <= cv27_wb_0_buf[src][7:0];      \
		cv_w[27][3] <= cv27_wb_0_buf[src][15:8];     \
		cv_w[27][4] <= cv27_wb_0_buf[src][23:16];    \
		cv_w[27][5] <= cv27_wb_0_buf[src][31:24];    \
		cv_w[27][6] <= cv27_wb_1_buf[src][7:0];      \
		cv_w[27][7] <= cv27_wb_1_buf[src][15:8];     \
		cv_w[27][8] <= cv27_wb_1_buf[src][23:16];    \
		cv_w[27][9] <= cv27_wb_1_buf[src][31:24];    \
		cv_w[28][1] <= cv28_wb_0_buf[src][7:0];      \
		cv_w[28][2] <= cv28_wb_0_buf[src][15:8];     \
		cv_w[28][3] <= cv28_wb_0_buf[src][23:16];    \
		cv_w[28][4] <= cv28_wb_0_buf[src][31:24];    \
		cv_w[28][5] <= cv28_wb_1_buf[src][7:0];      \
		cv_w[28][6] <= cv28_wb_1_buf[src][15:8];     \
		cv_w[28][7] <= cv28_wb_1_buf[src][23:16];    \
		cv_w[28][8] <= cv28_wb_1_buf[src][31:24];    \
		cv_w[28][9] <= cv2829_wb_2_buf[src][7:0];    \
		cv_w[29][1] <= cv2829_wb_2_buf[src][15:8];   \
		cv_w[29][2] <= cv2829_wb_2_buf[src][23:16];  \
		cv_w[29][3] <= cv2829_wb_2_buf[src][31:24];  \
		cv_w[29][4] <= cv29_wb_0_buf[src][7:0];      \
		cv_w[29][5] <= cv29_wb_0_buf[src][15:8];     \
		cv_w[29][6] <= cv29_wb_0_buf[src][23:16];    \
		cv_w[29][7] <= cv29_wb_0_buf[src][31:24];    \
		cv_w[29][8] <= cv2930_wb_1_buf[src][7:0];    \
		cv_w[29][9] <= cv2930_wb_1_buf[src][15:8];   \
		cv_w[30][1] <= cv2930_wb_1_buf[src][23:16];  \
		cv_w[30][2] <= cv2930_wb_1_buf[src][31:24];  \
		cv_w[30][3] <= cv30_wb_0_buf[src][7:0];      \
		cv_w[30][4] <= cv30_wb_0_buf[src][15:8];     \
		cv_w[30][5] <= cv30_wb_0_buf[src][23:16];    \
		cv_w[30][6] <= cv30_wb_0_buf[src][31:24];    \
		cv_w[30][7] <= cv3031_wb_0_buf[src][7:0];    \
		cv_w[30][8] <= cv3031_wb_0_buf[src][15:8];   \
		cv_w[30][9] <= cv3031_wb_0_buf[src][23:16];  \
		cv_w[31][1] <= cv3031_wb_0_buf[src][31:24];  \
		cv_w[31][2] <= cv31_wb_0_buf[src][7:0];      \
		cv_w[31][3] <= cv31_wb_0_buf[src][15:8];     \
		cv_w[31][4] <= cv31_wb_0_buf[src][23:16];    \
		cv_w[31][5] <= cv31_wb_0_buf[src][31:24];    \
		cv_w[31][6] <= cv31_wb_1_buf[src][7:0];      \
		cv_w[31][7] <= cv31_wb_1_buf[src][15:8];     \
		cv_w[31][8] <= cv31_wb_1_buf[src][23:16];    \
		cv_w[31][9] <= cv31_wb_1_buf[src][31:24];
		
	`define load_qt(src)                   \
		for (i=0; i<8; i=i+1) begin         \
			qt_zp[i] <= qt_buf[src][31:16];  \
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
								0  : cv00_wb_0_buf[pixelcount]   <= data_in;	  //  1: {cv0_w4, cv0_w3, cv0_w2, cv0_w1} -----
								1  : cv00_wb_1_buf[pixelcount]   <= data_in;   //  2: {cv0_w8, cv0_w7, cv0_w6, cv0_w5}
								2  : cv0001_wb_2_buf[pixelcount] <= data_in;   //  3: {cv1_w3, cv1_w2, cv1_w1, cv0_w9}
								3  : cv01_wb_0_buf[pixelcount]   <= data_in;   //  4: {cv1_w7, cv1_w6, cv1_w5, cv1_w4}
								4  : cv0102_wb_1_buf[pixelcount] <= data_in;   //  5: {cv2_w2, cv2_w1, cv1_w9, cv1_w8}
								5  : cv02_wb_0_buf[pixelcount]   <= data_in;   //  6: {cv2_w6, cv2_w5, cv2_w4, cv2_w3}
								6  : cv0203_wb_0_buf[pixelcount] <= data_in;   //  7: {cv3_w1, cv2_w9, cv2_w8, cv2_w7}
								7  : cv03_wb_0_buf[pixelcount]   <= data_in;	  //  8: {cv3_w5, cv3_w4, cv3_w3, cv3_w2}
								8  : cv03_wb_1_buf[pixelcount]   <= data_in;   //  9: {cv3_w9, cv3_w8, cv3_w7, cv3_w6}
								9  : cv04_wb_0_buf[pixelcount]   <= data_in;	  // 10: {cv4_w4, cv4_w3, cv4_w2, cv4_w1} -----
								10 : cv04_wb_1_buf[pixelcount]   <= data_in;   // 11: {cv4_w8, cv4_w7, cv4_w6, cv4_w5}
								11 : cv0405_wb_2_buf[pixelcount] <= data_in;	  // 12: {cv5_w3, cv5_w2, cv5_w1, cv4_w9}
								12 : cv05_wb_0_buf[pixelcount]   <= data_in;   // 13: {cv5_w7, cv5_w6, cv5_w5, cv5_w4}
								13 : cv0506_wb_1_buf[pixelcount] <= data_in;   // 14: {cv6_w2, cv6_w1, cv5_w9, cv5_w8}
								14 : cv06_wb_0_buf[pixelcount]   <= data_in;   // 15: {cv6_w6, cv6_w5, cv6_w4, cv6_w3}
								15 : cv0607_wb_0_buf[pixelcount] <= data_in;   // 16: {cv7_w1, cv6_w9, cv6_w8, cv6_w7}
								16 : cv07_wb_0_buf[pixelcount]   <= data_in;	  // 17: {cv7_w5, cv7_w4, cv7_w3, cv7_w2}
								17 : cv07_wb_1_buf[pixelcount]   <= data_in;   // 18: {cv7_w9, cv7_w8, cv7_w7, cv7_w6}
								18 : cv08_wb_0_buf[pixelcount]   <= data_in;	  // 19: {cv8_w4, cv8_w3, cv8_w2, cv8_w1} -----
								19 : cv08_wb_1_buf[pixelcount]   <= data_in;   // 20: {cv8_w8, cv8_w7, cv8_w6, cv8_w5}
								20 : cv0809_wb_2_buf[pixelcount] <= data_in;	  // 21: {cv1_w3, cv1_w2, cv1_w1, cv8_w9}
								21 : cv09_wb_0_buf[pixelcount]   <= data_in;   // 22: {cv9_w7, cv9_w6, cv9_w5, cv9_w4}
								22 : cv0910_wb_1_buf[pixelcount] <= data_in;   // 23: {cv10_w2, cv10_w1, cv9_w9, cv9_w8}
								23 : cv10_wb_0_buf[pixelcount]   <= data_in;   // 24: {cv10_w6, cv10_w5, cv10_w4, cv10_w3}
								24 : cv1011_wb_0_buf[pixelcount] <= data_in;   // 25: {cv11_w1, cv10_w9, cv10_w8, cv10_w7}
								25 : cv11_wb_0_buf[pixelcount]   <= data_in;	  // 26: {cv11_w5, cv11_w4, cv11_w3, cv11_w2}
								26 : cv11_wb_1_buf[pixelcount]   <= data_in;   // 27: {cv11_w9, cv11_w8, cv11_w7, cv11_w6}
								27 : cv12_wb_0_buf[pixelcount]   <= data_in;	  // 28: {cv12_w4, cv12_w3, cv12_w2, cv12_w1} -----
								28 : cv12_wb_1_buf[pixelcount]   <= data_in;   // 29: {cv12_w8, cv12_w7, cv12_w6, cv12_w5}
								29 : cv1213_wb_2_buf[pixelcount] <= data_in;   // 30: {cv13_w3, cv13_w2, cv13_w1, cv12_w9}
								30 : cv13_wb_0_buf[pixelcount]   <= data_in;   // 31: {cv13_w7, cv13_w6, cv13_w5, cv13_w4}
								31 : cv1314_wb_1_buf[pixelcount] <= data_in;   // 32: {cv14_w2, cv14_w1, cv13_w9, cv13_w8}
								32 : cv14_wb_0_buf[pixelcount]   <= data_in;   // 33: {cv14_w6, cv14_w5, cv14_w4, cv14_w3}
								33 : cv1415_wb_0_buf[pixelcount] <= data_in;   // 34: {cv15_w1, cv14_w9, cv14_w8, cv14_w7}
								34 : cv15_wb_0_buf[pixelcount]   <= data_in;	  // 35: {cv15_w5, cv15_w4, cv15_w3, cv15_w2}
								35 : cv15_wb_1_buf[pixelcount]   <= data_in;   // 36: {cv15_w9, cv15_w8, cv15_w7, cv15_w6}
								36 : cv16_wb_0_buf[pixelcount]   <= data_in;	  // 37: {cv16_w4, cv16_w3, cv16_w2, cv16_w1} -----
								37 : cv16_wb_1_buf[pixelcount]   <= data_in;   // 38: {cv16_w8, cv16_w7, cv16_w6, cv16_w5}
								38 : cv1617_wb_2_buf[pixelcount] <= data_in;   // 39: {cv17_w3, cv17_w2, cv17_w1, cv16_w9}
								39 : cv17_wb_0_buf[pixelcount]   <= data_in;   // 40: {cv17_w7, cv17_w6, cv17_w5, cv17_w4}
								40 : cv1718_wb_1_buf[pixelcount] <= data_in;   // 41: {cv18_w2, cv18_w1, cv17_w9, cv17_w8}
								41 : cv18_wb_0_buf[pixelcount]   <= data_in;   // 42: {cv18_w6, cv18_w5, cv18_w4, cv18_w3}
								42 : cv1819_wb_0_buf[pixelcount] <= data_in;   // 43: {cv19_w1, cv18_w9, cv18_w8, cv18_w7}
								43 : cv19_wb_0_buf[pixelcount]   <= data_in;	  // 44: {cv19_w5, cv19_w4, cv19_w3, cv19_w2}
								44 : cv19_wb_1_buf[pixelcount]   <= data_in;   // 45: {cv19_w9, cv19_w8, cv19_w7, cv19_w6}
								45 : cv20_wb_0_buf[pixelcount]   <= data_in;	  // 46: {cv20_w4, cv20_w3, cv20_w2, cv20_w1} -----
								46 : cv20_wb_1_buf[pixelcount]   <= data_in;   // 47: {cv20_w8, cv20_w7, cv20_w6, cv20_w5}
								47 : cv2021_wb_2_buf[pixelcount] <= data_in;   // 48: {cv21_w3, cv21_w2, cv21_w1, cv20_w9}
								48 : cv21_wb_0_buf[pixelcount]   <= data_in;   // 49: {cv21_w7, cv21_w6, cv21_w5, cv21_w4}
								49 : cv2122_wb_1_buf[pixelcount] <= data_in;   // 50: {cv22_w2, cv22_w1, cv21_w9, cv21_w8}
								50 : cv22_wb_0_buf[pixelcount]   <= data_in;   // 51: {cv22_w6, cv22_w5, cv22_w4, cv22_w3}
								51 : cv2223_wb_0_buf[pixelcount] <= data_in;   // 52: {cv23_w1, cv22_w9, cv22_w8, cv22_w7}
								52 : cv23_wb_0_buf[pixelcount]   <= data_in;	  // 53: {cv23_w5, cv23_w4, cv23_w3, cv23_w2}
								53 : cv23_wb_1_buf[pixelcount]   <= data_in;   // 54: {cv23_w9, cv23_w8, cv23_w7, cv23_w6}
								54 : cv24_wb_0_buf[pixelcount]   <= data_in;	  // 55: {cv24_w4, cv24_w3, cv24_w2, cv24_w1} -----
								55 : cv24_wb_1_buf[pixelcount]   <= data_in;   // 56: {cv24_w8, cv24_w7, cv24_w6, cv24_w5}
								56 : cv2425_wb_2_buf[pixelcount] <= data_in;   // 57: {cv25_w3, cv25_w2, cv25_w1, cv24_w9}
								57 : cv25_wb_0_buf[pixelcount]   <= data_in;   // 58: {cv25_w7, cv25_w6, cv25_w5, cv25_w4}
								58 : cv2526_wb_1_buf[pixelcount] <= data_in;   // 59: {cv26_w2, cv26_w1, cv25_w9, cv25_w8}
								59 : cv26_wb_0_buf[pixelcount]   <= data_in;   // 60: {cv26_w6, cv26_w5, cv26_w4, cv26_w3}
								60 : cv2627_wb_0_buf[pixelcount] <= data_in;   // 61: {cv27_w1, cv26_w9, cv26_w8, cv26_w7}
								61 : cv27_wb_0_buf[pixelcount]   <= data_in;	  // 62: {cv27_w5, cv27_w4, cv27_w3, cv27_w2}
								62 : cv27_wb_1_buf[pixelcount]   <= data_in;   // 63: {cv27_w9, cv27_w8, cv27_w7, cv27_w6}
								63 : cv28_wb_0_buf[pixelcount]   <= data_in;	  // 64: {cv28_w4, cv28_w3, cv28_w2, cv28_w1} -----
								64 : cv28_wb_1_buf[pixelcount]   <= data_in;   // 65: {cv28_w8, cv28_w7, cv28_w6, cv28_w5}
								65 : cv2829_wb_2_buf[pixelcount] <= data_in;   // 66: {cv29_w3, cv29_w2, cv29_w1, cv28_w9}
								66 : cv29_wb_0_buf[pixelcount]   <= data_in;   // 67: {cv29_w7, cv29_w6, cv29_w5, cv29_w4}
								67 : cv2930_wb_1_buf[pixelcount] <= data_in;   // 68: {cv30_w2, cv30_w1, cv29_w9, cv29_w8}
								68 : cv30_wb_0_buf[pixelcount]   <= data_in;   // 69: {cv30_w6, cv30_w5, cv30_w4, cv30_w3}
								69 : cv3031_wb_0_buf[pixelcount] <= data_in;   // 70: {cv31_w1, cv30_w9, cv30_w8, cv30_w7}
								70 : cv31_wb_0_buf[pixelcount]   <= data_in;	  // 71: {cv31_w5, cv31_w4, cv31_w3, cv31_w2}
								71 : cv31_wb_1_buf[pixelcount]   <= data_in;   // 72: {cv31_w9, cv31_w8, cv31_w7, cv31_w6}
							endcase
						
						end else begin
							ctrl <= SEND_WEIGHTS;
						end
					end
					
				STAGE9_TRANSCONV:
					// 16 (64x64) Layers ---> 8 (128x128) Layers
					//
					// pixel1 - calc outlayers 1,2 
					// pixel2 - calc outlayers 1,2
					// ...
					// pixel1023 - calc outlayers 1,2
					// pixel1 - calc outlayers 3,4 
					// pixel2 - calc outlayers 3,4
					// ...
					// pixel1023 - calc outlayers 5,6
					// ....
					// pixel1 - calc outlayers 7,8 
					// pixel2 - calc outlayers 7,8
					// ...
					// pixel1023 - calc outlayers 7,8
					
					begin
						if (tr_rw) begin
							tr_hop <= 1;
							pixelcount <= pixelcount + 1;
							if (pixelcount % 64 == 63) tr_rw <= 0;
							
							case (layercount)
								0: begin `load_weight(1013) end
								2: begin `load_weight(1014) end
								4: begin `load_weight(1015) end
								6: begin `load_weight(1016) end
							endcase
							
							`load_qt(11)
							
						end else begin
							if (writepixel % 256 == 255) begin
								if (writepixel != 16383) tr_rw <= 1;
								tr_flip <= ~tr_flip;
								
								if (writepixel == 16383) begin
									if (layercount == 6) begin
										for (l=0; l<32; l=l+1) cv_rst[l] = 0;
										writepixel = writepixel + 256;
									
									end else begin
										layercount <= layercount + 2;
										writepixel <= 0;
										
									end
									
									pixelcount <= 0;
									
								end else if (writepixel == 16639) begin
									for (l=0; l<32; l=l+1) cv_rst[l] = 1;
									layercount <= 0;
									state <= STAGE9_CONV;
									writepixel <= 0;
									tr_rw <= 1;
									
								end else begin
									writepixel <= writepixel + 1;
								
								end
							end else begin
								writepixel <= writepixel + 1;
							
							end
							
							qt0_in <= tr_out[0] + tr_out[1] + tr_out[2] + tr_out[3]
							          + tr_out[4] + tr_out[5] + tr_out[6] + tr_out[7]
							          + tr_out[8] + tr_out[9] + tr_out[10] + tr_out[11]
							          + tr_out[12] + tr_out[13] + tr_out[14] + tr_out[15];
										 
							qt1_in <= tr_out[16] + tr_out[17] + tr_out[18] + tr_out[19]
							          + tr_out[20] + tr_out[21] + tr_out[22] + tr_out[23]
							          + tr_out[24] + tr_out[25] + tr_out[26] + tr_out[27]
							          + tr_out[28] + tr_out[29] + tr_out[30] + tr_out[31]; 
							
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
							
							
							if (writepixel < 4096) begin				
								case (layercount)
									0:  layerint_buf0_st2[(writepixel)] <= {qt0_res, qt1_res, 16'b0};
									2:  layerint_buf0_st2[(writepixel)] <= {layerint_buf0_st2[(writepixel)][31:16], qt0_res, qt1_res};
									4:  layerint_buf1_st2[(writepixel)] <= {qt0_res, qt1_res, 16'b0};
									6:  layerint_buf1_st2[(writepixel)] <= {layerint_buf1_st2[(writepixel)][31:16], qt0_res, qt1_res};
								endcase
							end else if (writepixel < 8192) begin
								case (layercount)
									0:  layerint_buf2_st2[(writepixel-4096)] <= {qt0_res, qt1_res, 16'b0};
									2:  layerint_buf2_st2[(writepixel-4096)] <= {layerint_buf2_st2[(writepixel-4096)][31:16], qt0_res, qt1_res};
									4:  layerint_buf3_st2[(writepixel-4096)] <= {qt0_res, qt1_res, 16'b0};
									6:  layerint_buf3_st2[(writepixel-4096)] <= {layerint_buf3_st2[(writepixel-4096)][31:16], qt0_res, qt1_res};
								endcase
							end else if (writepixel < 12288) begin
								case (layercount)
									0:  layerint_buf4_st2[(writepixel-8192)] <= {qt0_res, qt1_res, 16'b0};
									2:  layerint_buf4_st2[(writepixel-8192)] <= {layerint_buf4_st2[(writepixel-8192)][31:16], qt0_res, qt1_res};
									4:  layerint_buf5_st2[(writepixel-8192)] <= {qt0_res, qt1_res, 16'b0};
									6:  layerint_buf5_st2[(writepixel-8192)] <= {layerint_buf5_st2[(writepixel-8192)][31:16], qt0_res, qt1_res};
								endcase
							end else if (writepixel < 16384) begin
								case (layercount)
									0:  layerint_buf6_st2[(writepixel-12288)] <= {qt0_res, qt1_res, 16'b0};
									2:  layerint_buf6_st2[(writepixel-12288)] <= {layerint_buf6_st2[(writepixel-12288)][31:16], qt0_res, qt1_res};
									4:  layerint_buf7_st2[(writepixel-12288)] <= {qt0_res, qt1_res, 16'b0};
									6:  layerint_buf7_st2[(writepixel-12288)] <= {layerint_buf7_st2[(writepixel-12288)][31:16], qt0_res, qt1_res};
								endcase
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
									32'd0:  begin `load_weight(1017) end
									32'd2:  begin `load_weight(1018) end
									32'd4:  begin `load_weight(1019) end
									32'd6:  begin `load_weight(1020) end
										
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
									32'd0:  begin `load_weight(1021) end
									32'd2:  begin `load_weight(1022) end
									32'd4:  begin `load_weight(1023) end
									32'd6:  begin `load_weight(1024) end
									32'd8:  begin `load_weight(1025) end
									32'd10: begin `load_weight(1026) end
									32'd12: begin `load_weight(1027) end
									32'd14: begin `load_weight(1028) end
									
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
	
	reg [31:0] datain_buffer;
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
		end else begin
			case (state)
				STAGE9_CONV:
					begin
						datain_buffer <= data_in;
					end
			endcase
		end
	end

	reg [7:0] buffer0_outwire [2:0];
	integer a,b,c;
	
	always@(*) begin
		case (state)
			STAGE9_TRANSCONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_width[a] <= 7'd64;
					end
					
					
					relu <= 0;
					
					
					// 16 (64x64) ---> 8 (128x128) Layers
					// send pixel at once
					//
					// {L1-P1, L2-P1, L3-P1, L4-P1}
					// {L1-P2, L2-P2, L3-P2, L4-P2}
					// ...
					// {L1-P4096, L2-P4096, L3-P4096, L4-P4096}
					// {L5-P1, L6-P1, L7-P1, L8-P1}
					// ...
					// {L5-P4096, L6-P4096, L7-P4096, L8-P4096}
					// {L9-P1, L10-P1, L11-P1, L12-P1}
					// ...
					// {L9-P4096, L10-P4096, L11-P4096, L12-P4096}
					// {L13-P1, L14-P1, L15-P1, L16-P1}
					// ...
					// {L13-P4096, L14-P4096, L15-P4096, L1-P4096}         
					
					// ************************** amend to load datain while transpose conv is doing its thing
					//
					
					cv_pixelin[0] <= datain_buffer[31:24];
					cv_pixelin[1] <= datain_buffer[23:16];
					cv_pixelin[2] <= datain_buffer[15:8];
					cv_pixelin[3] <= datain_buffer[7:0];
					
					
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