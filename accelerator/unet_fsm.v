module unet_fsm(
		input rst_n, clk, unet_enpulse, 
		input [31:0] data_in,
		output reg [2:0] ctrl,
		output reg busy,
		output reg [31:0] data_out
	);
	
	parameter SEND_WEIGHTS = 2'd1,
	          SEND_DATA = 2d'2,
				 DATA_READY = 2'd3
				 IDLE = 2'd4;
	
	parameter IDLE             = 5'd0,
				 STAGE1_LOAD      = 5'd1,
	          STAGE1_CONV      = 5'd2,
	          STAGE1_MXPL      = 5'd3,
	          STAGE2_CONV      = 5'd4,
				 STAGE2_MXPL      = 5'd5,
				 STAGE2_CONV      = 5'd6,
				 STAGE2_MXPL      = 5'd7,
				 STAGE3_CONV      = 5'd8,
				 STAGE4_MXPL      = 5'd9,
				 STAGE5_CONV      = 5'd10,
				 STAGE6_TRANSCONV = 5'd11,
				 STAGE6_CONV      = 5'd12,
				 STAGE7_TRANSCONV = 5'd13,
				 STAGE7_CONV      = 5'd14,
				 STAGE8_TRANSCONV = 5'd15,
				 STAGE8_CONV      = 5'd16,
				 STAGE9_TRANSCONV = 5'd17,
				 STAGE10_CONV     = 5'd18;
				 
	reg [4:0] state;
	
	
	
	/*********************************************************************************
	 * Set of convolutors
	 */
	 
	reg [7:0] cv_pixelin [0:31];
	reg [7:0] cv_w [0:31][1:9];
	reg cv_paddingL, cv_paddingR;
	reg [1:0] cv_op [0:31];
	reg [7:0] cv_width [0:31];
	
	wire [19:0] cv_pixelout [0:31];
	
	parameter CONV        = 2'd0,
	          MAXPOOL2X2 = 2'd1,
				 TRANS      = 2'd2;
				 
	
				 
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv0 (
		.pixel_in(cv_pixelin[0]),
		.w9(cv_w[0][9]), .w8(cv_w[0][8]), .w7(cv_w[0][7]), 
		.w6(cv_w[0][6]), .w5(cv_w[0][5]), .w4(cv_w[0][4]), 
		.w3(cv_w[0][3]), .w2(cv_w[0][2]), .w1(cv_w[0][1]),
		.clk(clk), 
		.rst_n(rst_n && cv0_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[0]),
		.operation(cv_op[0]),
		.width(cv_width[0])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv1 (
		.pixel_in(cv_pixelin[1]),
		.w9(cv_w[1][9]), .w8(cv_w[1][8]), .w7(cv_w[1][7]), 
		.w6(cv_w[1][6]), .w5(cv_w[1][5]), .w4(cv_w[1][4]), 
		.w3(cv_w[1][3]), .w2(cv_w[1][2]), .w1(cv_w[1][1]),
		.clk(clk), 
		.rst_n(rst_n && cv1_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[1]),
		.operation(cv_op[1]),
		.width(cv_width[1])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv2 (
		.pixel_in(cv_pixelin[2]),
		.w9(cv_w[2][9]), .w8(cv_w[2][8]), .w7(cv_w[2][7]), 
		.w6(cv_w[2][6]), .w5(cv_w[2][5]), .w4(cv_w[2][4]), 
		.w3(cv_w[2][3]), .w2(cv_w[2][2]), .w1(cv_w[2][1]),
		.clk(clk), 
		.rst_n(rst_n && cv2_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[2]),
		.operation(cv_op[2]),
		.width(cv_width[2])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv3 (
		.pixel_in(cv_pixelin[3]),
		.w9(cv_w[3][9]), .w8(cv_w[3][8]), .w7(cv_w[3][7]), 
		.w6(cv_w[3][6]), .w5(cv_w[3][5]), .w4(cv_w[3][4]), 
		.w3(cv_w[3][3]), .w2(cv_w[3][2]), .w1(cv_w[3][1]),
		.clk(clk), 
		.rst_n(rst_n && cv3_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[3]),
		.operation(cv_op[3]),
		.width(cv_width[3])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv4 (
		.pixel_in(cv_pixelin[4]),
		.w9(cv_w[4][9]), .w8(cv_w[4][8]), .w7(cv_w[4][7]), 
		.w6(cv_w[4][6]), .w5(cv_w[4][5]), .w4(cv_w[4][4]), 
		.w3(cv_w[4][3]), .w2(cv_w[4][2]), .w1(cv_w[4][1]),
		.clk(clk), 
		.rst_n(rst_n && cv4_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[4]),
		.operation(cv_op[4]),
		.width(cv_width[4])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv5 (
		.pixel_in(cv_pixelin[5]),
		.w9(cv_w[5][9]), .w8(cv_w[5][8]), .w7(cv_w[5][7]), 
		.w6(cv_w[5][6]), .w5(cv_w[5][5]), .w4(cv_w[5][4]), 
		.w3(cv_w[5][3]), .w2(cv_w[5][2]), .w1(cv_w[5][1]),
		.clk(clk), 
		.rst_n(rst_n && cv5_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[5]),
		.operation(cv_op[5]),
		.width(cv_width[5])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv6 (
		.pixel_in(cv_pixelin[6]),
		.w9(cv_w[6][9]), .w8(cv_w[6][8]), .w7(cv_w[6][7]), 
		.w6(cv_w[6][6]), .w5(cv_w[6][5]), .w4(cv_w[6][4]), 
		.w3(cv_w[6][3]), .w2(cv_w[6][2]), .w1(cv_w[6][1]),
		.clk(clk), 
		.rst_n(rst_n && cv6_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[6]),
		.operation(cv_op[6]),
		.width(cv_width[6])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv7 (
		.pixel_in(cv_pixelin[7]),
		.w9(cv_w[7][9]), .w8(cv_w[7][8]), .w7(cv_w[7][7]), 
		.w6(cv_w[7][6]), .w5(cv_w[7][5]), .w4(cv_w[7][4]), 
		.w3(cv_w[7][3]), .w2(cv_w[7][2]), .w1(cv_w[7][1]),
		.clk(clk), 
		.rst_n(rst_n && cv7_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[7]),
		.operation(cv_op[7]),
		.width(cv_width[7])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv8 (
		.pixel_in(cv_pixelin[8]),
		.w9(cv_w[8][9]), .w8(cv_w[8][8]), .w7(cv_w[8][7]), 
		.w6(cv_w[8][6]), .w5(cv_w[8][5]), .w4(cv_w[8][4]), 
		.w3(cv_w[8][3]), .w2(cv_w[8][2]), .w1(cv_w[8][1]),
		.clk(clk), 
		.rst_n(rst_n && cv8_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[8]),
		.operation(cv_op[8]),
		.width(cv_width[8])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv9 (
		.pixel_in(cv_pixelin[9]),
		.w9(cv_w[9][9]), .w8(cv_w[9][8]), .w7(cv_w[9][7]), 
		.w6(cv_w[9][6]), .w5(cv_w[9][5]), .w4(cv_w[9][4]), 
		.w3(cv_w[9][3]), .w2(cv_w[9][2]), .w1(cv_w[9][1]),
		.clk(clk), 
		.rst_n(rst_n && cv9_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[9]),
		.operation(cv_op[9]),
		.width(cv_width[9])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv10 (
		.pixel_in(cv_pixelin[10]),
		.w9(cv_w[10][9]), .w8(cv_w[10][8]), .w7(cv_w[10][7]), 
		.w6(cv_w[10][6]), .w5(cv_w[10][5]), .w4(cv_w[10][4]), 
		.w3(cv_w[10][3]), .w2(cv_w[10][2]), .w1(cv_w[10][1]),
		.clk(clk), 
		.rst_n(rst_n && cv10_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[10]),
		.operation(cv_op[10]),
		.width(cv_width[10])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv11 (
		.pixel_in(cv_pixelin[11]),
		.w9(cv_w[11][9]), .w8(cv_w[11][8]), .w7(cv_w[11][7]), 
		.w6(cv_w[11][6]), .w5(cv_w[11][5]), .w4(cv_w[11][4]), 
		.w3(cv_w[11][3]), .w2(cv_w[11][2]), .w1(cv_w[11][1]),
		.clk(clk), 
		.rst_n(rst_n && cv11_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[11]),
		.operation(cv_op[11]),
		.width(cv_width[11])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv12 (
		.pixel_in(cv_pixelin[12]),
		.w9(cv_w[12][9]), .w8(cv_w[12][8]), .w7(cv_w[12][7]), 
		.w6(cv_w[12][6]), .w5(cv_w[12][5]), .w4(cv_w[12][4]), 
		.w3(cv_w[12][3]), .w2(cv_w[12][2]), .w1(cv_w[12][1]),
		.clk(clk), 
		.rst_n(rst_n && cv12_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[12]),
		.operation(cv_op[12]),
		.width(cv_width[12])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv13 (
		.pixel_in(cv_pixelin[13]),
		.w9(cv_w[13][9]), .w8(cv_w[13][8]), .w7(cv_w[13][7]), 
		.w6(cv_w[13][6]), .w5(cv_w[13][5]), .w4(cv_w[13][4]), 
		.w3(cv_w[13][3]), .w2(cv_w[13][2]), .w1(cv_w[13][1]),
		.clk(clk), 
		.rst_n(rst_n && cv13_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[13]),
		.operation(cv_op[13]),
		.width(cv_width[13])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv14 (
		.pixel_in(cv_pixelin[14]),
		.w9(cv_w[14][9]), .w8(cv_w[14][8]), .w7(cv_w[14][7]), 
		.w6(cv_w[14][6]), .w5(cv_w[14][5]), .w4(cv_w[14][4]), 
		.w3(cv_w[14][3]), .w2(cv_w[14][2]), .w1(cv_w[14][1]),
		.clk(clk), 
		.rst_n(rst_n && cv14_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[14]),
		.operation(cv_op[14]),
		.width(cv_width[14])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv15 (
		.pixel_in(cv_pixelin[15]),
		.w9(cv_w[15][9]), .w8(cv_w[15][8]), .w7(cv_w[15][7]), 
		.w6(cv_w[15][6]), .w5(cv_w[15][5]), .w4(cv_w[15][4]), 
		.w3(cv_w[15][3]), .w2(cv_w[15][2]), .w1(cv_w[15][1]),
		.clk(clk), 
		.rst_n(rst_n && cv15_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[15]),
		.operation(cv_op[15]),
		.width(cv_width[15])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv16 (
		.pixel_in(cv_pixelin[16]),
		.w9(cv_w[16][9]), .w8(cv_w[16][8]), .w7(cv_w[16][7]), 
		.w6(cv_w[16][6]), .w5(cv_w[16][5]), .w4(cv_w[16][4]), 
		.w3(cv_w[16][3]), .w2(cv_w[16][2]), .w1(cv_w[16][1]),
		.clk(clk), 
		.rst_n(rst_n && cv16_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[16]),
		.operation(cv_op[16]),
		.width(cv_width[16])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv17 (
		.pixel_in(cv_pixelin[17]),
		.w9(cv_w[17][9]), .w8(cv_w[17][8]), .w7(cv_w[17][7]), 
		.w6(cv_w[17][6]), .w5(cv_w[17][5]), .w4(cv_w[17][4]), 
		.w3(cv_w[17][3]), .w2(cv_w[17][2]), .w1(cv_w[17][1]),
		.clk(clk), 
		.rst_n(rst_n && cv17_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[17]),
		.operation(cv_op[17]),
		.width(cv_width[17])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv18 (
		.pixel_in(cv_pixelin[18]),
		.w9(cv_w[18][9]), .w8(cv_w[18][8]), .w7(cv_w[18][7]), 
		.w6(cv_w[18][6]), .w5(cv_w[18][5]), .w4(cv_w[18][4]), 
		.w3(cv_w[18][3]), .w2(cv_w[18][2]), .w1(cv_w[18][1]),
		.clk(clk), 
		.rst_n(rst_n && cv18_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[18]),
		.operation(cv_op[18]),
		.width(cv_width[18])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv19 (
		.pixel_in(cv_pixelin[19]),
		.w9(cv_w[19][9]), .w8(cv_w[19][8]), .w7(cv_w[19][7]), 
		.w6(cv_w[19][6]), .w5(cv_w[19][5]), .w4(cv_w[19][4]), 
		.w3(cv_w[19][3]), .w2(cv_w[19][2]), .w1(cv_w[19][1]),
		.clk(clk), 
		.rst_n(rst_n && cv19_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[19]),
		.operation(cv_op[19]),
		.width(cv_width[19])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv20 (
		.pixel_in(cv_pixelin[20]),
		.w9(cv_w[20][9]), .w8(cv_w[20][8]), .w7(cv_w[20][7]), 
		.w6(cv_w[20][6]), .w5(cv_w[20][5]), .w4(cv_w[20][4]), 
		.w3(cv_w[20][3]), .w2(cv_w[20][2]), .w1(cv_w[20][1]),
		.clk(clk), 
		.rst_n(rst_n && cv20_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[20]),
		.operation(cv_op[20]),
		.width(cv_width[20])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv21 (
		.pixel_in(cv_pixelin[21]),
		.w9(cv_w[21][9]), .w8(cv_w[21][8]), .w7(cv_w[21][7]), 
		.w6(cv_w[21][6]), .w5(cv_w[21][5]), .w4(cv_w[21][4]), 
		.w3(cv_w[21][3]), .w2(cv_w[21][2]), .w1(cv_w[21][1]),
		.clk(clk), 
		.rst_n(rst_n && cv21_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[21]),
		.operation(cv_op[21]),
		.width(cv_width[21])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv22 (
		.pixel_in(cv_pixelin[22]),
		.w9(cv_w[22][9]), .w8(cv_w[22][8]), .w7(cv_w[22][7]), 
		.w6(cv_w[22][6]), .w5(cv_w[22][5]), .w4(cv_w[22][4]), 
		.w3(cv_w[22][3]), .w2(cv_w[22][2]), .w1(cv_w[22][1]),
		.clk(clk), 
		.rst_n(rst_n && cv22_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[22]),
		.operation(cv_op[22]),
		.width(cv_width[22])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv23 (
		.pixel_in(cv_pixelin[23]),
		.w9(cv_w[23][9]), .w8(cv_w[23][8]), .w7(cv_w[23][7]), 
		.w6(cv_w[23][6]), .w5(cv_w[23][5]), .w4(cv_w[23][4]), 
		.w3(cv_w[23][3]), .w2(cv_w[23][2]), .w1(cv_w[23][1]),
		.clk(clk), 
		.rst_n(rst_n && cv23_int_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(cv_pixelout[23]),
		.operation(cv_op[23]),
		.width(cv_width[23])
	);
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv24 (
    .pixel_in(cv_pixelin[24]),
    .w9(cv_w[24][9]), .w8(cv_w[24][8]), .w7(cv_w[24][7]), 
		.w6(cv_w[24][6]), .w5(cv_w[24][5]), .w4(cv_w[24][4]), 
		.w3(cv_w[24][3]), .w2(cv_w[24][2]), .w1(cv_w[24][1]),
    .clk(clk), 
    .rst_n(rst_n && cv24_int_rst),
	 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
    .pixel_out(cv_pixelout[24]),
    .operation(cv_op[24]),
		.width(cv_width[24])
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv25 (
		 .pixel_in(cv_pixelin[25]),
		 .w9(cv_w[25][9]), .w8(cv_w[25][8]), .w7(cv_w[25][7]), 
		.w6(cv_w[25][6]), .w5(cv_w[25][5]), .w4(cv_w[25][4]), 
		.w3(cv_w[25][3]), .w2(cv_w[25][2]), .w1(cv_w[25][1]),
		 .clk(clk), 
		 .rst_n(rst_n && cv25_int_rst),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[25]),
		 .operation(cv_op[25]),
		.width(cv_width[25])
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv26 (
		 .pixel_in(cv_pixelin[26]),
		 .w9(cv_w[26][9]), .w8(cv_w[26][8]), .w7(cv_w[26][7]), 
		.w6(cv_w[26][6]), .w5(cv_w[26][5]), .w4(cv_w[26][4]), 
		.w3(cv_w[26][3]), .w2(cv_w[26][2]), .w1(cv_w[26][1]),
		 .clk(clk), 
		 .rst_n(rst_n && cv26_int_rst),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[26]),
		 .operation(cv_op[26]),
		.width(cv_width[26])
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv27 (
		 .pixel_in(cv_pixelin[27]),
		 .w9(cv_w[27][9]), .w8(cv_w[27][8]), .w7(cv_w[27][7]), 
		.w6(cv_w[27][6]), .w5(cv_w[27][5]), .w4(cv_w[27][4]), 
		.w3(cv_w[27][3]), .w2(cv_w[27][2]), .w1(cv_w[27][1]),
		 .clk(clk), 
		 .rst_n(rst_n && cv27_int_rst),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[27]),
		 .operation(cv_op[27]),
		.width(cv_width[27])
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv28 (
		 .pixel_in(cv_pixelin[28]),
		 .w9(cv_w[28][9]), .w8(cv_w[28][8]), .w7(cv_w[28][7]), 
		.w6(cv_w[28][6]), .w5(cv_w[28][5]), .w4(cv_w[28][4]), 
		.w3(cv_w[28][3]), .w2(cv_w[28][2]), .w1(cv_w[28][1]),
		 .clk(clk), 
		 .rst_n(rst_n && cv28_int_rst),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[28]),
		 .operation(cv_op[28]),
		.width(cv_width[28])
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv29 (
		 .pixel_in(cv_pixelin[29]),
		 .w9(cv_w[29][9]), .w8(cv_w[29][8]), .w7(cv_w[29][7]), 
		.w6(cv_w[29][6]), .w5(cv_w[29][5]), .w4(cv_w[29][4]), 
		.w3(cv_w[29][3]), .w2(cv_w[29][2]), .w1(cv_w[29][1]),
		 .clk(clk), 
		 .rst_n(rst_n && cv29_int_rst),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[29]),
		 .operation(cv_op[29]),
		.width(cv_width[29])
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv30 (
		 .pixel_in(cv_pixelin[30]),
		 .w9(cv_w[30][9]), .w8(cv_w[30][8]), .w7(cv_w[30][7]), 
		.w6(cv_w[30][6]), .w5(cv_w[30][5]), .w4(cv_w[30][4]), 
		.w3(cv_w[30][3]), .w2(cv_w[30][2]), .w1(cv_w[30][1]),
		 .clk(clk), 
		 .rst_n(rst_n && cv30_int_rst),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[30]),
		 .operation(cv_op[30]),
		.width(cv_width[30])
	);

	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv31 (
		 .pixel_in(cv_pixelin[31]),
		 .w9(cv_w[31][9]), .w8(cv_w[31][8]), .w7(cv_w[31][7]), 
		 .w6(cv_w[31][6]), .w5(cv_w[31][5]), .w4(cv_w[31][4]), 
		 .w3(cv_w[31][3]), .w2(cv_w[31][2]), .w1(cv_w[31][1]),
		 .clk(clk), 
		 .rst_n(rst_n && cv31_int_rst),
		 .paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		 .pixel_out(cv_pixelout[31]),
		 .operation(cv_op[31]),
		.width(cv_width[31])
	);
	
	
	/*********************************************************************************
	 * Set of quantizers
	 */
	 
	reg [31:0] qt0_in, qt1_in, qt2_in, qt3_in, qt4_in, qt5_in, qt6_in, qt7_in, 
	           qt0_bias, qt1_bias, qt2_bias, qt3_bias, qt4_bias, qt5_bias, qt6_bias, qt7_bias,
				  qt0_zp, qt1_zp, qt2_zp, qt3_zp, qt4_zp, qt5_zp, qt6_zp, qt7_zp, 
				  qt0_scale, qt1_scale, qt1_scale, qt1_scale, qt1_scale, qt1_scale, qt1_scale;
	
	wire [7:0] qt0_res, qt1_res, qt2_res, qt3_res, qt4_res, qt5_res, qt6_res, qt7_res;

	// Quantizers
	quant qt0(.in(qt0_in), .bias(qt0_bias), .zeropoint(qt0_zp), .scaler_scaled16(qt0_scale), .result(.qt0_res));
	quant qt1(.in(qt1_in), .bias(qt1_bias), .zeropoint(qt1_zp), .scaler_scaled16(qt1_scale), .result(.qt1_res));
	quant qt2(.in(qt2_in), .bias(qt2_bias), .zeropoint(qt2_zp), .scaler_scaled16(qt2_scale), .result(.qt2_res));
	quant qt3(.in(qt3_in), .bias(qt3_bias), .zeropoint(qt3_zp), .scaler_scaled16(qt3_scale), .result(.qt3_res));
	quant qt4(.in(qt4_in), .bias(qt4_bias), .zeropoint(qt4_zp), .scaler_scaled16(qt4_scale), .result(.qt4_res));
	quant qt5(.in(qt5_in), .bias(qt5_bias), .zeropoint(qt5_zp), .scaler_scaled16(qt5_scale), .result(.qt5_res));
	quant qt6(.in(qt6_in), .bias(qt6_bias), .zeropoint(qt6_zp), .scaler_scaled16(qt6_scale), .result(.qt6_res));
	quant qt7(.in(qt7_in), .bias(qt7_bias), .zeropoint(qt7_zp), .scaler_scaled16(qt7_scale), .result(.qt7_res));
	
	
	
	
	/*********************************************************************************
	 * Macros for loading weights
	 */
	
	`define LOAD_WEIGHTS(src) \
		begin \
			word_index = src; \
			byte_index = 0; \
			for (f = 0; f < 32; f = f + 1) begin \
				for (w = 1; w < 10; w = w + 1) begin \
					case (byte_offset) \
						0: cv_w[f][w] <= weightbank[word_index][31:24]; \
						1: cv_w[f][w] <= weightbank[word_index][23:16]; \
						2: cv_w[f][w] <= weightbank[word_index][15:8];  \
						3: cv_w[f][w] <= weightbank[word_index][7:0]; \
					endcase \
					byte_offset = byte_offset + 1; \
					if (byte_offset == 4) begin \
						byte_offset = 0; \
						word_index = word_index + 1; \
					end \
				end \
			qt0_bias <= weightbank[src+72]; \
			qt0_zp   <= weightbank[src+73]; \
			qt0_scale <= weightbank[src+74];	\	
			qt1_bias <= weightbank[src+75]; \
			qt1_zp   <= weightbank[src+76]; \
			qt1_scale <= weightbank[src+77];	\
			qt2_bias <= weightbank[src+78]; \
			qt2_zp   <= weightbank[src+79]; \
			qt2_scale <= weightbank[src+80];	\	
			qt3_bias <= weightbank[src+81]; \
			qt3_zp   <= weightbank[src+82]; \
			qt3_scale <= weightbank[src+83]; \
			qt4_bias <= weightbank[src+84]; \
			qt4_zp   <= weightbank[src+85]; \
			qt4_scale <= weightbank[src+86];	 \	
			qt5_bias <= weightbank[src+87]; \
			qt5_zp   <= weightbank[src+88]; \
			qt5_scale <= weightbank[src+89];	 \
			qt6_bias <= weightbank[src+90]; \ 
			qt6_zp   <= weightbank[src+91];\ 
			qt6_scale <= weightbank[src+92];	\ 	
			qt7_bias <= weightbank[src+93]; \
			qt7_zp   <= weightbank[src+94]; \
			qt7_scale <= weightbank[src+95];	 \
		end
				
	
	
	
	
	/*********************************************************************************
	 * Stages of the UNET, doing the operations...
	 */
	 
	reg [31:0] pixelcount, layercount, inlayercount;
	
	// inter-stage memory
	reg [19:0] intermediate [0:31];
	
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
			for (i=0; i<128; i=i+1) intermediatesum[i] <= 0;
			
			for (i=0; i<32; i=i+1) begin
				intermediate[i] <= 0;
				for (w=1; w<10) cv_w[i][w] <= 0;
			end
		end else begin
			case (state)
				IDLE:
					begin
						pixelcount <= 0;
						layercount <= 0;
						inlayercount <= 0;
						writepixel <= 0;
						row <= 0;
						busy <= 0;
						savebuffer <=0
						for (i=0; i<128; i=i+1) intermediatesum[i] <= 0;
						ctrl <= IDLE;
						
						for (i=0; i<32; i=i+1) begin
							intermediate[i] <= 0;
							for (w=1; w<10) cv_w[i][w] <= 0;
						end
						
						if (unet_enpulse) begin
							stage <= STAGE1_WEIGHTLOAD;
							busy <= 1;
							pixelcount <= 0;
						end
					end
					
					
				STAGE1_WEIGHTLOAD:
					begin
						if (firsttime) begin
							ctrl <= SEND_WEIGHTS;
							pixelcount <= pixelcount + 1;
							
							if (pixelcount <= 1344) begin
								weightbank[pixelcount] <= datain;
							end else begin
								ctrl <= SEND_DATA
								firsttime <= 0;
								stage <= STAGE1_CONV;
								pixelcount <= 0;
							end
						end else begin
							stage <= STAGE1_CONV;
						end
					end
					
					
				STAGE1_CONV:
					// 3 (128x128) Layers ---> 8 (128x128) Layers
					// Here all 8 outlayers calced parellelly
					
					begin
						if (pixelcount >= 32'd16513) begin  // (height*width + (width+1) for padding)
							if (pixelcount == 32'd16513) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE1_MXPL;
								pixelcount <= 32'b0;
								layercount <= 32'b0;
							end
							
						end else begin
							// pixelcount
							pixelcount <= pixelcount + 1;
							
							// filling weights
							`LOAD_WEIGHTS(stage1_layer1, 3, 0)	// filter 0
							`LOAD_WEIGHTS(stage1_layer2, 3, 3)	// filter 1
							`LOAD_WEIGHTS(stage1_layer3, 3, 6)	// filter 2
							`LOAD_WEIGHTS(stage1_layer4, 3, 9)	// filter 3
							`LOAD_WEIGHTS(stage1_layer5, 3, 12)	// filter 4
							`LOAD_WEIGHTS(stage1_layer6, 3, 15)	// filter 5
							`LOAD_WEIGHTS(stage1_layer7, 3, 18)	// filter 6
							`LOAD_WEIGHTS(stage1_layer8, 3, 21)	// filter 7
							
							if (pixelcount >= 129) begin  // ( width+2 for the padding )
								for (i=0; i<24; i=i+3) begin
									// filters
									for (j=0; j<3; j=j+1) begin
										intermediate[i+j] <= cv_pixelout[i+j];
									end
								end
								
								// add bias and quantization
								//qt0
								qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2];
								qt0_bias <= bias0;
								qt0_zp   <= zp0;
								qt0_scale <= scale0;
							
								//qt1
								qt1_in   <= intermediate[3] + intermediate[4] + intermediate[5];
								qt1_bias <= bias1;
								qt1_zp   <= zp1;
								qt1_scale <= scale1;
								
								//qt2
								qt2_in   <= intermediate[6] + intermediate[7] + intermediate[8];
								qt2_bias <= bias2;
								qt2_zp   <= zp2;
								qt2_scale <= scale2;
								
								//qt3
								qt3_in   <= intermediate[9] + intermediate[10] + intermediate[11];
								qt3_bias <= bias3;
								qt3_zp   <= zp3;
								qt3_scale <= scale3;
								
								//qt4
								qt4_in   <= intermediate[12] + intermediate[13] + intermediate[14];
								qt4_bias <= bias4;
								qt4_zp   <= zp4;
								qt4_scale <= scale4;
								
								//qt5
								qt5_in   <= intermediate[15] + intermediate[16] + intermediate[17];
								qt5_bias <= bias5;
								qt5_zp   <= zp5;
								qt5_scale <= scale5;
								
								//qt6
								qt6_in   <= intermediate[18] + intermediate[19] + intermediate[20];
								qt6_bias <= bias6;
								qt6_zp   <= zp6;
								qt6_scale <= scale6;
								
								//qt7
								qt7_in   <= intermediate[21] + intermediate[22] + intermediate[23];
								qt7_bias <= bias7;
								qt7_zp   <= zp7;
								qt7_scale <= scale7;
								
								
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
								
								if (pixelcount > 129) begin
									if (pixelcount < 32'd4226) begin
										layerint_buf0_st1[(pixelcount-130)*4]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
										layerint_buf1_st1[(pixelcount-130)*4]  <= {qt4_res, qt5_res, qt6_res, qt7_res};
									end else if (pixelcount < 32'd8322) begin
										layerint_buf2_st1[(pixelcount-4096-130)*4]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
										layerint_buf3_st1[(pixelcount-4096-130)*4]  <= {qt4_res, qt5_res, qt6_res, qt7_res};
									end else if (pixelcount < 32'd12418) begin
										layerint_buf4_st1[(pixelcount-8192-130)*4]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
										layerint_buf5_st1[(pixelcount-8192-130)*4]  <= {qt4_res, qt5_res, qt6_res, qt7_res};
									end else begin
										layerint_buf6_st1[(pixelcount-12288-130)*4]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
										layerint_buf7_st1[(pixelcount-12288-130)*4]  <= {qt4_res, qt5_res, qt6_res, qt7_res};
									end
								end
							end
						end
					end
					
				STAGE1_MXPL:
					// 8 (128x128) Layers ---> 8 (64x64) Layers
					begin
						if (pixelcount >= 32'd4225) begin // (128*128/4 as 1/4th image pooled parellerly)
							if (pixelcount == 32'd4225) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
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
						if (pixelcount >= 32'd4161) begin  // (height*width + (width+1) for padding)
							if (pixelcount == 32'd4161) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE2_MXPL;
								pixelcount <= 32'b0;
								layercount <= 0;
							end
														
							
						end else begin
							if (pixelcount < 65) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount + 1;
							end else begin
								if (layercount >= 32'd16) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd4;
									
									case (layercount)
										32'd0:
											begin
												`LOAD_WEIGHTS(stage2_layer1, 8, 0)	// filter 0
												`LOAD_WEIGHTS(stage2_layer2, 8, 8)	// filter 1
												`LOAD_WEIGHTS(stage2_layer3, 8, 16)	// filter 2
												`LOAD_WEIGHTS(stage2_layer4, 8, 24)	// filter 3
											end
											
										32'd4:
											begin
												`LOAD_WEIGHTS(stage2_layer5, 8, 0)	// filter 4
												`LOAD_WEIGHTS(stage2_layer6, 8, 8)	// filter 5
												`LOAD_WEIGHTS(stage2_layer7, 8, 16)	// filter 6
												`LOAD_WEIGHTS(stage2_layer8, 8, 24)	// filter 7
											end
										
										32'd8:
											begin
												`LOAD_WEIGHTS(stage2_layer9, 8, 0)	// filter 8
												`LOAD_WEIGHTS(stage2_layer10, 8, 8)	// filter 9
												`LOAD_WEIGHTS(stage2_layer11, 8, 16)	// filter 10
												`LOAD_WEIGHTS(stage2_layer12, 8, 24)	// filter 11
											end
										
										32'd12:
											begin
												`LOAD_WEIGHTS(stage2_layer13, 8, 0)	// filter 12
												`LOAD_WEIGHTS(stage2_layer14, 8, 8)	// filter 13
												`LOAD_WEIGHTS(stage2_layer15, 8, 16)	// filter 14
												`LOAD_WEIGHTS(stage2_layer16, 8, 24)	// filter 15
											end
											
										default:
											begin
												for (int i=0; i<32; i=i+1) begin
													for (int w=1; w<10; w=w+1) begin
														cv_w[i][w] <= 1;
													end
												end
											end
									endcase
								
									for (i=0; i<32; i=i+8) begin
										// filters
										for (j=0; j<8; j=j+1) begin
											intermediate[i+j] <= cv_pixelout[i+j];
										end
									end
									
									
									// add bias and quantization
									//qt0
									qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
													+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7];
									qt0_bias <= bias0;
									qt0_zp   <= zp0;
									qt0_scale <= scale0;
									
									//qt1
									qt1_in   <= intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
													+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15];
									qt1_bias <= bias0;
									qt1_zp   <= zp0;
									qt1_scale <= scale0;
									
									//qt2
									qt2_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
													+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23];
									qt2_bias <= bias2;
									qt2_zp   <= zp2;
									qt2_scale <= scale2;
									
									//qt0
									qt3_in   <= intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
													+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									qt3_bias <= bias3;
									qt3_zp   <= zp3;
									qt3_scale <= scale3;
									
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
									
									if (pixelcount > 65) begin
										case (layercount-4):
											32'd0:
												begin
													if (pixelcount < 32'd2114) 
														layerint_buf0_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
													else
														layerint_buf4_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
												end
											
											32'd4:
												begin
													if (pixelcount < 32'd2114) 
														layerint_buf1_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
													else
														layerint_buf5_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
												end
												
											32'd8:
												begin
													if (pixelcount < 32'd2114) 
														layerint_buf2_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
													else
														layerint_buf6_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
												end
												
											32'd12:
												begin
													if (pixelcount < 32'd2114) 
														layerint_buf3_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
													else
														layerint_buf7_st2[(pixelcount-66)]  <= {qt0_res, qt1_res, qt2_res, qt3_res};
												end
										endcase
									end
								end
							end
						end
					end
					
				STAGE2_MXPL:
					// 16 (64x64) Layers ---> 16 (32x32) Layers
					begin
						if (pixelcount >= 32'd2113) begin // (64*64/2 as 1/2th image pooled parellerly + 64 + 1)
							if (pixelcount == 32'd2113) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
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
						if (pixelcount >= 32'd1057) begin  // (height*width + (width+1) for padding)
							if (pixelcount == 32'd1057) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE3_MXPL;
								pixelcount <= 32'b0;
								layercount <= 0;
							end
							
						end else begin
							if (pixelcount < 33) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
							end else begin 
								if (layercount >= 32'd32) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd2;
									
									case (layercount)
										32'd0:
											begin
												`LOAD_WEIGHTS(stage3_layer1, 16, 0)	   // filter 0
												`LOAD_WEIGHTS(stage3_layer2, 16, 16)	// filter 1
											end
											
										32'd2:
											begin
												`LOAD_WEIGHTS(stage3_layer3, 16, 0)	   // filter 2
												`LOAD_WEIGHTS(stage3_layer4, 16, 16)	// filter 3
											end
											
										32'd4:
											begin
												`LOAD_WEIGHTS(stage3_layer5, 16, 0)	   // filter 4
												`LOAD_WEIGHTS(stage3_layer6, 16, 16)	// filter 5
											end
											
										32'd6:
											begin
												`LOAD_WEIGHTS(stage3_layer7, 16, 0)	   // filter 6
												`LOAD_WEIGHTS(stage3_layer8, 16, 16)	// filter 7
											end
											
										32'd8:
											begin
												`LOAD_WEIGHTS(stage3_layer9, 16, 0)	   // filter 8
												`LOAD_WEIGHTS(stage3_layer10, 16, 16)	// filter 9
											end
											
										32'd10:
											begin
												`LOAD_WEIGHTS(stage3_layer11, 16, 0)	// filter 10
												`LOAD_WEIGHTS(stage3_layer12, 16, 16)	// filter 11
											end
											
										32'd12:
											begin
												`LOAD_WEIGHTS(stage3_layer13, 16, 0)	// filter 12
												`LOAD_WEIGHTS(stage3_layer14, 16, 16)	// filter 13
											end
											
										32'd14:
											begin
												`LOAD_WEIGHTS(stage3_layer15, 16, 0)	// filter 14
												`LOAD_WEIGHTS(stage3_layer16, 16, 16)	// filter 15
											end
											
										32'd16:
											begin
												`LOAD_WEIGHTS(stage3_layer17, 16, 0)	// filter 16
												`LOAD_WEIGHTS(stage3_layer18, 16, 16)	// filter 17
											end
											
										32'd18:
											begin
												`LOAD_WEIGHTS(stage3_layer19, 16, 0)	// filter 18
												`LOAD_WEIGHTS(stage3_layer20, 16, 16)	// filter 19
											end
											
										32'd20:
											begin
												`LOAD_WEIGHTS(stage3_layer21, 16, 0)	// filter 20
												`LOAD_WEIGHTS(stage3_layer22, 16, 16)	// filter 21
											end
											
										32'd22:
											begin
												`LOAD_WEIGHTS(stage3_layer23, 16, 0)	// filter 22
												`LOAD_WEIGHTS(stage3_layer24, 16, 16)	// filter 23
											end
											
										32'd24:
											begin
												`LOAD_WEIGHTS(stage3_layer25, 16, 0)	// filter 24
												`LOAD_WEIGHTS(stage3_layer26, 16, 16)	// filter 25
											end
											
										32'd26:
											begin
												`LOAD_WEIGHTS(stage3_layer27, 16, 0)	// filter 26
												`LOAD_WEIGHTS(stage3_layer28, 16, 16)	// filter 27
											end
											
										32'd28:
											begin
												`LOAD_WEIGHTS(stage3_layer29, 16, 0)	// filter 28
												`LOAD_WEIGHTS(stage3_layer30, 16, 16)	// filter 29
											end
											
										32'd30:
											begin
												`LOAD_WEIGHTS(stage3_layer31, 16, 0)	// filter 30
												`LOAD_WEIGHTS(stage3_layer32, 16, 16)	// filter 31
											end
											
										default:
											begin
												for (int i=0; i<32; i=i+1) begin
													for (int w=1; w<10; w=w+1) begin
														cv_w[i][w]    <= 0;
													end
												end
											end
									endcase		
			
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
									qt0_bias <= bias0;
									qt0_zp   <= zp0;
									qt0_scale <= scale0;
									
									//qt1
									qt1_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
													+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
													+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
													+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									qt1_bias <= bias0;
									qt1_zp   <= zp0;
									qt1_scale <= scale0;
									
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
									
									if (pixelcount >33) begin
										case (layercount-2):
											32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
											32'd2:  layerint_buf0_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
											32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
											32'd6:  layerint_buf1_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
											32'd8:  savebuffer[31:16] <= {qt0_res, qt1_res};
											32'd10: layerint_buf2_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
											32'd12: savebuffer[31:16] <= {qt0_res, qt1_res};
											32'd14: layerint_buf3_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
											32'd16: savebuffer[31:16] <= {qt0_res, qt1_res};
											32'd18: layerint_buf4_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
											32'd20: savebuffer[31:16] <= {qt0_res, qt1_res};
											32'd22: layerint_buf5_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
											32'd24: savebuffer[31:16] <= {qt0_res, qt1_res};
											32'd26: layerint_buf6_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
											32'd28: savebuffer[31:16] <= {qt0_res, qt1_res};
											32'd30: layerint_buf7_st3[(pixelcount-34)] <= {savebuffer[31:16], qt0_res, qt1_res};
										endcase
									end
								end
							end
						end
					end
					
				STAGE3_MXPL:
					// 32 (32x32) Layers ---> 32 (16x16) Layers
					
					begin
						if (pixelcount >= 32'd1057) begin // (32*32 + 32 + 1)
							if (pixelcount == 32'd4161) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
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
						if (pixelcount >= 32'd273) begin  // (height*width + (width+1) for padding)
							if (pixelcount == 32'd4161) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE4_MXPL;
								pixelcount <= 32'b0;
								layercount <= 0;
							end
							
						end else begin
							if (pixelcount < 17) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
							end else begin 
								if (layercount >= 32'd64) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd1;
									
									case (layercount)
										32'd0:  LOAD_WEIGHTS(stage4_layer1, 32, 0)	   // filter 0
										32'd1:  LOAD_WEIGHTS(stage4_layer2, 32, 0)	   // filter 1
										32'd2:  LOAD_WEIGHTS(stage4_layer3, 32, 0)	   // filter 2
										32'd3:  LOAD_WEIGHTS(stage4_layer4, 32, 0)	   // filter 3
										32'd4:  LOAD_WEIGHTS(stage4_layer5, 32, 0)	   // filter 4
										32'd5:  LOAD_WEIGHTS(stage4_layer6, 32, 0)	   // filter 5
										32'd6:  LOAD_WEIGHTS(stage4_layer7, 32, 0)	   // filter 6
										32'd7:  LOAD_WEIGHTS(stage4_layer8, 32, 0)	   // filter 7
										32'd8:  LOAD_WEIGHTS(stage4_layer9, 32, 0)	   // filter 8
										32'd9:  LOAD_WEIGHTS(stage4_layer10, 32, 0)	   // filter 9
										32'd10: LOAD_WEIGHTS(stage4_layer11, 32, 0)	   // filter 10
										32'd11: LOAD_WEIGHTS(stage4_layer12, 32, 0)	   // filter 11
										32'd12: LOAD_WEIGHTS(stage4_layer13, 32, 0)	   // filter 12
										32'd13: LOAD_WEIGHTS(stage4_layer14, 32, 0)	   // filter 13
										32'd14: LOAD_WEIGHTS(stage4_layer15, 32, 0)	   // filter 14
										32'd15: LOAD_WEIGHTS(stage4_layer16, 32, 0)	   // filter 15
										32'd16: LOAD_WEIGHTS(stage4_layer17, 32, 0)	   // filter 16
										32'd17: LOAD_WEIGHTS(stage4_layer18, 32, 0)	   // filter 17
										32'd18: LOAD_WEIGHTS(stage4_layer19, 32, 0)	   // filter 18
										32'd19: LOAD_WEIGHTS(stage4_layer20, 32, 0)	   // filter 19
										32'd20: LOAD_WEIGHTS(stage4_layer21, 32, 0)	   // filter 20
										32'd21: LOAD_WEIGHTS(stage4_layer22, 32, 0)	   // filter 21
										32'd22: LOAD_WEIGHTS(stage4_layer23, 32, 0)	   // filter 22
										32'd23: LOAD_WEIGHTS(stage4_layer24, 32, 0)	   // filter 23
										32'd24: LOAD_WEIGHTS(stage4_layer25, 32, 0)	   // filter 24
										32'd25: LOAD_WEIGHTS(stage4_layer26, 32, 0)	   // filter 25
										32'd26: LOAD_WEIGHTS(stage4_layer27, 32, 0)	   // filter 26
										32'd27: LOAD_WEIGHTS(stage4_layer28, 32, 0)	   // filter 27
										32'd28: LOAD_WEIGHTS(stage4_layer29, 32, 0)	   // filter 28
										32'd29: LOAD_WEIGHTS(stage4_layer30, 32, 0)	   // filter 29
										32'd30: LOAD_WEIGHTS(stage4_layer31, 32, 0)	   // filter 30
										32'd31: LOAD_WEIGHTS(stage4_layer32, 32, 0)	   // filter 31
										32'd32: LOAD_WEIGHTS(stage4_layer33, 32, 0)	   // filter 32
										32'd33: LOAD_WEIGHTS(stage4_layer34, 32, 0)	   // filter 33
										32'd34: LOAD_WEIGHTS(stage4_layer35, 32, 0)	   // filter 34
										32'd35: LOAD_WEIGHTS(stage4_layer36, 32, 0)	   // filter 35
										32'd36: LOAD_WEIGHTS(stage4_layer37, 32, 0)	   // filter 36
										32'd37: LOAD_WEIGHTS(stage4_layer38, 32, 0)	   // filter 37
										32'd38: LOAD_WEIGHTS(stage4_layer39, 32, 0)	   // filter 38
										32'd39: LOAD_WEIGHTS(stage4_layer40, 32, 0)	   // filter 39
										32'd40: LOAD_WEIGHTS(stage4_layer41, 32, 0)	   // filter 40
										32'd41: LOAD_WEIGHTS(stage4_layer42, 32, 0)	   // filter 41
										32'd42: LOAD_WEIGHTS(stage4_layer43, 32, 0)	   // filter 42
										32'd43: LOAD_WEIGHTS(stage4_layer44, 32, 0)	   // filter 43
										32'd44: LOAD_WEIGHTS(stage4_layer45, 32, 0)	   // filter 44
										32'd45: LOAD_WEIGHTS(stage4_layer46, 32, 0)	   // filter 45
										32'd46: LOAD_WEIGHTS(stage4_layer47, 32, 0)	   // filter 46
										32'd47: LOAD_WEIGHTS(stage4_layer48, 32, 0)	   // filter 47
										32'd48: LOAD_WEIGHTS(stage4_layer49, 32, 0)	   // filter 48
										32'd49: LOAD_WEIGHTS(stage4_layer50, 32, 0)	   // filter 49
										32'd50: LOAD_WEIGHTS(stage4_layer51, 32, 0)	   // filter 50
										32'd51: LOAD_WEIGHTS(stage4_layer52, 32, 0)	   // filter 51
										32'd52: LOAD_WEIGHTS(stage4_layer53, 32, 0)	   // filter 52
										32'd53: LOAD_WEIGHTS(stage4_layer54, 32, 0)	   // filter 53
										32'd54: LOAD_WEIGHTS(stage4_layer55, 32, 0)	   // filter 54
										32'd55: LOAD_WEIGHTS(stage4_layer56, 32, 0)	   // filter 55
										32'd56: LOAD_WEIGHTS(stage4_layer57, 32, 0)	   // filter 56
										32'd57: LOAD_WEIGHTS(stage4_layer58, 32, 0)	   // filter 57
										32'd58: LOAD_WEIGHTS(stage4_layer59, 32, 0)	   // filter 58
										32'd59: LOAD_WEIGHTS(stage4_layer60, 32, 0)	   // filter 59
										32'd60: LOAD_WEIGHTS(stage4_layer61, 32, 0)	   // filter 60
										32'd61: LOAD_WEIGHTS(stage4_layer62, 32, 0)	   // filter 61
										32'd62: LOAD_WEIGHTS(stage4_layer63, 32, 0)	   // filter 62
										32'd63: LOAD_WEIGHTS(stage4_layer64, 32, 0)	   // filter 63
											
										default:
											begin
												for (int i=0; i<32; i=i+1) begin
													for (int w=1; w<10; w=w+1) begin
														cv_w[i][w]    <= 0;
													end
												end
											end
									endcase
									
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
									qt0_bias <= bias0;
									qt0_zp   <= zp0;
									qt0_scale <= scale0;
									
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
									
									if (pixelcount >17) begin
										case (layercount-1):
											32'd0:  savebuffer[31:24] <= {qt0_res};
											32'd1:  savebuffer[23:16] <= {qt0_res};
											32'd2:  savebuffer[15:8]  <= {qt0_res};
											32'd3:  layerint_buf0_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd4:  savebuffer[31:24] <= {qt0_res};
											32'd5:  savebuffer[23:16] <= {qt0_res};
											32'd6:  savebuffer[15:8]  <= {qt0_res};
											32'd7:  layerint_buf1_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd8:  savebuffer[31:24] <= {qt0_res};
											32'd9:  savebuffer[23:16] <= {qt0_res};
											32'd10: savebuffer[15:8]  <= {qt0_res};
											32'd11: layerint_buf2_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd12: savebuffer[31:24] <= {qt0_res};
											32'd13: savebuffer[23:16] <= {qt0_res};
											32'd14: savebuffer[15:8]  <= {qt0_res};
											32'd15: layerint_buf3_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd16: savebuffer[31:24] <= {qt0_res};
											32'd17: savebuffer[23:16] <= {qt0_res};
											32'd18: savebuffer[15:8]  <= {qt0_res};
											32'd19: layerint_buf4_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd20: savebuffer[31:24] <= {qt0_res};
											32'd21: savebuffer[23:16] <= {qt0_res};
											32'd22: savebuffer[15:8]  <= {qt0_res};
											32'd23: layerint_buf5_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd24: savebuffer[31:24] <= {qt0_res};
											32'd25: savebuffer[23:16] <= {qt0_res};
											32'd26: savebuffer[15:8]  <= {qt0_res};
											32'd27: layerint_buf6_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd28: savebuffer[31:24] <= {qt0_res};
											32'd29: savebuffer[23:16] <= {qt0_res};
											32'd30: savebuffer[15:8]  <= {qt0_res};
											32'd31: layerint_buf7_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd32: savebuffer[31:24] <= {qt0_res};
											32'd33: savebuffer[23:16] <= {qt0_res};
											32'd34: savebuffer[15:8]  <= {qt0_res};
											32'd35: layerint_buf8_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd36: savebuffer[31:24] <= {qt0_res};
											32'd37: savebuffer[23:16] <= {qt0_res};
											32'd38: savebuffer[15:8]  <= {qt0_res};
											32'd39: layerint_buf9_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd40: savebuffer[31:24] <= {qt0_res};
											32'd41: savebuffer[23:16] <= {qt0_res};
											32'd42: savebuffer[15:8]  <= {qt0_res};
											32'd43: layerint_buf10_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd44: savebuffer[31:24] <= {qt0_res};
											32'd45: savebuffer[23:16] <= {qt0_res};
											32'd46: savebuffer[15:8]  <= {qt0_res};
											32'd47: layerint_buf11_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd48: savebuffer[31:24] <= {qt0_res};
											32'd49: savebuffer[23:16] <= {qt0_res};
											32'd50: savebuffer[15:8]  <= {qt0_res};
											32'd51: layerint_buf12_st4[[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd52: savebuffer[31:24] <= {qt0_res};
											32'd53: savebuffer[23:16] <= {qt0_res};
											32'd54: savebuffer[15:8]  <= {qt0_res};
											32'd55: layerint_buf13_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd56: savebuffer[31:24] <= {qt0_res};
											32'd57: savebuffer[23:16] <= {qt0_res};
											32'd58: savebuffer[15:8]  <= {qt0_res};
											32'd59: layerint_buf14_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											32'd60: savebuffer[31:24] <= {qt0_res};
											32'd61: savebuffer[23:16] <= {qt0_res};
											32'd62: savebuffer[15:8]  <= {qt0_res};
											32'd63: layerint_buf15_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
										endcase
									end
								end
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
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
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
									layerint_buf0_st2[(writepixel)] <= {cv_pixelout[0][7:0], cv_pixelout[1][7:0], cv_pixelout[2][7:0], cv_pixelout[3][7:0]};
									layerint_buf1_st2[(writepixel)] <= {cv_pixelout[4][7:0], cv_pixelout[5][7:0], cv_pixelout[6][7:0], cv_pixelout[7][7:0]};
									layerint_buf2_st2[(writepixel)] <= {cv_pixelout[8][7:0], cv_pixelout[9][7:0], cv_pixelout[10][7:0], cv_pixelout[11][7:0]};
									layerint_buf3_st2[(writepixel)] <= {cv_pixelout[12][7:0], cv_pixelout[13][7:0], cv_pixelout[14][7:0], cv_pixelout[15][7:0]};
									layerint_buf4_st2[(writepixel)] <= {cv_pixelout[16][7:0], cv_pixelout[17][7:0], cv_pixelout[18][7:0], cv_pixelout[19][7:0]};
									layerint_buf5_st2[(writepixel)] <= {cv_pixelout[20][7:0], cv_pixelout[21][7:0], cv_pixelout[22][7:0], cv_pixelout[23][7:0]};
									layerint_buf6_st2[(writepixel)] <= {cv_pixelout[24][7:0], cv_pixelout[25][7:0], cv_pixelout[26][7:0], cv_pixelout[27][7:0]};
									layerint_buf7_st2[(writepixel)] <= {cv_pixelout[28][7:0], cv_pixelout[29][7:0], cv_pixelout[30][7:0], cv_pixelout[31][7:0]};
								end else begin
									layerint_buf8_st2[(writepixel)] <= {cv_pixelout[0][7:0], cv_pixelout[1][7:0], cv_pixelout[2][7:0], cv_pixelout[3][7:0]};
									layerint_buf9_st2[(writepixel)] <= {cv_pixelout[4][7:0], cv_pixelout[5][7:0], cv_pixelout[6][7:0], cv_pixelout[7][7:0]};
									layerint_buf10_st2[(writepixel)] <= {cv_pixelout[8][7:0], cv_pixelout[9][7:0], cv_pixelout[10][7:0], cv_pixelout[11][7:0]};
									layerint_buf11_st2[(writepixel)] <= {cv_pixelout[12][7:0], cv_pixelout[13][7:0], cv_pixelout[14][7:0], cv_pixelout[15][7:0]};
									layerint_buf12_st2[(writepixel)] <= {cv_pixelout[16][7:0], cv_pixelout[17][7:0], cv_pixelout[18][7:0], cv_pixelout[19][7:0]};
									layerint_buf13_st2[(writepixel)] <= {cv_pixelout[20][7:0], cv_pixelout[21][7:0], cv_pixelout[22][7:0], cv_pixelout[23][7:0]};
									layerint_buf14_st2[(writepixel)] <= {cv_pixelout[24][7:0], cv_pixelout[25][7:0], cv_pixelout[26][7:0], cv_pixelout[27][7:0]};
									layerint_buf15_st2[(writepixel)] <= {cv_pixelout[28][7:0], cv_pixelout[29][7:0], cv_pixelout[30][7:0], cv_pixelout[31][7:0]};
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
						if (pixelcount >= 32'd73) begin  // (height*width + (width+1) for padding)
							if (inlayercount >= 32'd64) begin
								if (pixelcount == 32'd73) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
								end else begin
									for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
									state <= STAGE6_TRANSCONV;
									pixelcount <= 32'b0;
									layercount <= 0;
									inlayercount <= 0;
								end
								
							end else begin
								pixelcount <= 32'b0;
								inlayercount <= inlayercount + 32'd32;
							end
							
						end else begin
							if (pixelcount < 9) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin 
								if (layercount >= 32'd128) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd1;
									
									if (inlayercount == 0) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage5_layer1_1, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage5_layer2_1, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage5_layer3_1, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage5_layer4_1, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage5_layer5_1, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage5_layer6_1, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage5_layer7_1, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage5_layer8_1, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage5_layer9_1, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage5_layer10_1, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage5_layer11_1, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage5_layer12_1, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage5_layer13_1, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage5_layer14_1, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage5_layer15_1, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage5_layer16_1, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage5_layer17_1, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage5_layer18_1, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage5_layer19_1, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage5_layer20_1, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage5_layer21_1, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage5_layer22_1, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage5_layer23_1, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage5_layer24_1, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage5_layer25_1, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage5_layer26_1, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage5_layer27_1, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage5_layer28_1, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage5_layer29_1, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage5_layer30_1, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage5_layer31_1, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage5_layer32_1, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage5_layer33_1, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage5_layer34_1, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage5_layer35_1, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage5_layer36_1, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage5_layer37_1, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage5_layer38_1, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage5_layer39_1, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage5_layer40_1, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage5_layer41_1, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage5_layer42_1, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage5_layer43_1, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage5_layer44_1, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage5_layer45_1, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage5_layer46_1, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage5_layer47_1, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage5_layer48_1, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage5_layer49_1, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage5_layer50_1, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage5_layer51_1, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage5_layer52_1, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage5_layer53_1, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage5_layer54_1, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage5_layer55_1, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage5_layer56_1, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage5_layer57_1, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage5_layer58_1, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage5_layer59_1, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage5_layer60_1, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage5_layer61_1, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage5_layer62_1, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage5_layer63_1, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage5_layer64_1, 32, 0)	   // filter 63
											32'd64:  LOAD_WEIGHTS(stage5_layer65_1, 32, 0)	   // filter 64
											32'd65:  LOAD_WEIGHTS(stage5_layer66_1, 32, 0)	   // filter 65
											32'd66:  LOAD_WEIGHTS(stage5_layer67_1, 32, 0)	   // filter 66
											32'd67:  LOAD_WEIGHTS(stage5_layer68_1, 32, 0)	   // filter 67
											32'd68:  LOAD_WEIGHTS(stage5_layer69_1, 32, 0)	   // filter 68
											32'd69:  LOAD_WEIGHTS(stage5_layer70_1, 32, 0)	   // filter 69
											32'd70:  LOAD_WEIGHTS(stage5_layer71_1, 32, 0)	   // filter 70
											32'd71:  LOAD_WEIGHTS(stage5_layer72_1, 32, 0)	   // filter 71
											32'd72:  LOAD_WEIGHTS(stage5_layer73_1, 32, 0)	   // filter 72
											32'd73:  LOAD_WEIGHTS(stage5_layer74_1, 32, 0)	   // filter 73
											32'd74:  LOAD_WEIGHTS(stage5_layer75_1, 32, 0)	   // filter 74
											32'd75:  LOAD_WEIGHTS(stage5_layer76_1, 32, 0)	   // filter 75
											32'd76:  LOAD_WEIGHTS(stage5_layer77_1, 32, 0)	   // filter 76
											32'd77:  LOAD_WEIGHTS(stage5_layer78_1, 32, 0)	   // filter 77
											32'd78:  LOAD_WEIGHTS(stage5_layer79_1, 32, 0)	   // filter 78
											32'd79:  LOAD_WEIGHTS(stage5_layer80_1, 32, 0)	   // filter 79
											32'd80:  LOAD_WEIGHTS(stage5_layer81_1, 32, 0)	   // filter 80
											32'd81:  LOAD_WEIGHTS(stage5_layer82_1, 32, 0)	   // filter 81
											32'd82:  LOAD_WEIGHTS(stage5_layer83_1, 32, 0)	   // filter 82
											32'd83:  LOAD_WEIGHTS(stage5_layer84_1, 32, 0)	   // filter 83
											32'd84:  LOAD_WEIGHTS(stage5_layer85_1, 32, 0)	   // filter 84
											32'd85:  LOAD_WEIGHTS(stage5_layer86_1, 32, 0)	   // filter 85
											32'd86:  LOAD_WEIGHTS(stage5_layer87_1, 32, 0)	   // filter 86
											32'd87:  LOAD_WEIGHTS(stage5_layer88_1, 32, 0)	   // filter 87
											32'd88:  LOAD_WEIGHTS(stage5_layer89_1, 32, 0)	   // filter 88
											32'd89:  LOAD_WEIGHTS(stage5_layer90_1, 32, 0)	   // filter 89
											32'd90:  LOAD_WEIGHTS(stage5_layer91_1, 32, 0)	   // filter 90
											32'd91:  LOAD_WEIGHTS(stage5_layer92_1, 32, 0)	   // filter 91
											32'd92:  LOAD_WEIGHTS(stage5_layer93_1, 32, 0)	   // filter 92
											32'd93:  LOAD_WEIGHTS(stage5_layer94_1, 32, 0)	   // filter 93
											32'd94:  LOAD_WEIGHTS(stage5_layer95_1, 32, 0)	   // filter 94
											32'd95:  LOAD_WEIGHTS(stage5_layer96_1, 32, 0)	   // filter 95
											32'd96:  LOAD_WEIGHTS(stage5_layer97_1, 32, 0)	   // filter 96
											32'd97:  LOAD_WEIGHTS(stage5_layer98_1, 32, 0)	   // filter 97
											32'd98:  LOAD_WEIGHTS(stage5_layer99_1, 32, 0)	   // filter 98
											32'd99:  LOAD_WEIGHTS(stage5_layer100_1, 32, 0)	   // filter 99
											32'd100: LOAD_WEIGHTS(stage5_layer101_1, 32, 0)	   // filter 100
											32'd101: LOAD_WEIGHTS(stage5_layer102_1, 32, 0)	   // filter 101
											32'd102: LOAD_WEIGHTS(stage5_layer103_1, 32, 0)	   // filter 102
											32'd103: LOAD_WEIGHTS(stage5_layer104_1, 32, 0)	   // filter 103
											32'd104: LOAD_WEIGHTS(stage5_layer105_1, 32, 0)	   // filter 104
											32'd105: LOAD_WEIGHTS(stage5_layer106_1, 32, 0)	   // filter 105
											32'd106: LOAD_WEIGHTS(stage5_layer107_1, 32, 0)	   // filter 106
											32'd107: LOAD_WEIGHTS(stage5_layer108_1, 32, 0)	   // filter 107
											32'd108: LOAD_WEIGHTS(stage5_layer109_1, 32, 0)	   // filter 108
											32'd109: LOAD_WEIGHTS(stage5_layer110_1, 32, 0)	   // filter 109
											32'd110: LOAD_WEIGHTS(stage5_layer111_1, 32, 0)	   // filter 110
											32'd111: LOAD_WEIGHTS(stage5_layer112_1, 32, 0)	   // filter 111
											32'd112: LOAD_WEIGHTS(stage5_layer113_1, 32, 0)	   // filter 112
											32'd113: LOAD_WEIGHTS(stage5_layer114_1, 32, 0)	   // filter 113
											32'd114: LOAD_WEIGHTS(stage5_layer115_1, 32, 0)	   // filter 114
											32'd115: LOAD_WEIGHTS(stage5_layer116_1, 32, 0)	   // filter 115
											32'd116: LOAD_WEIGHTS(stage5_layer117_1, 32, 0)	   // filter 116
											32'd117: LOAD_WEIGHTS(stage5_layer118_1, 32, 0)	   // filter 117
											32'd118: LOAD_WEIGHTS(stage5_layer119_1, 32, 0)	   // filter 118
											32'd119: LOAD_WEIGHTS(stage5_layer120_1, 32, 0)	   // filter 119
											32'd120: LOAD_WEIGHTS(stage5_layer121_1, 32, 0)	   // filter 120
											32'd121: LOAD_WEIGHTS(stage5_layer122_1, 32, 0)	   // filter 121
											32'd122: LOAD_WEIGHTS(stage5_layer123_1, 32, 0)	   // filter 122
											32'd123: LOAD_WEIGHTS(stage5_layer124_1, 32, 0)	   // filter 123
											32'd124: LOAD_WEIGHTS(stage5_layer125_1, 32, 0)	   // filter 124
											32'd125: LOAD_WEIGHTS(stage5_layer126_1, 32, 0)	   // filter 125
											32'd126: LOAD_WEIGHTS(stage5_layer127_1, 32, 0)	   // filter 126
											32'd127: LOAD_WEIGHTS(stage5_layer128_1, 32, 0)	   // filter 127
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage5_layer1_2, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage5_layer2_2, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage5_layer3_2, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage5_layer4_2, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage5_layer5_2, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage5_layer6_2, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage5_layer7_2, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage5_layer8_2, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage5_layer9_2, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage5_layer10_2, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage5_layer11_2, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage5_layer12_2, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage5_layer13_2, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage5_layer14_2, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage5_layer15_2, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage5_layer16_2, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage5_layer17_2, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage5_layer18_2, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage5_layer19_2, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage5_layer20_2, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage5_layer21_2, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage5_layer22_2, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage5_layer23_2, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage5_layer24_2, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage5_layer25_2, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage5_layer26_2, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage5_layer27_2, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage5_layer28_2, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage5_layer29_2, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage5_layer30_2, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage5_layer31_2, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage5_layer32_2, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage5_layer33_2, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage5_layer34_2, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage5_layer35_2, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage5_layer36_2, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage5_layer37_2, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage5_layer38_2, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage5_layer39_2, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage5_layer40_2, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage5_layer41_2, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage5_layer42_2, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage5_layer43_2, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage5_layer44_2, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage5_layer45_2, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage5_layer46_2, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage5_layer47_2, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage5_layer48_2, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage5_layer49_2, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage5_layer50_2, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage5_layer51_2, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage5_layer52_2, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage5_layer53_2, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage5_layer54_2, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage5_layer55_2, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage5_layer56_2, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage5_layer57_2, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage5_layer58_2, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage5_layer59_2, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage5_layer60_2, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage5_layer61_2, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage5_layer62_2, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage5_layer63_2, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage5_layer64_2, 32, 0)	   // filter 63
											32'd64:  LOAD_WEIGHTS(stage5_layer65_2, 32, 0)	   // filter 64
											32'd65:  LOAD_WEIGHTS(stage5_layer66_2, 32, 0)	   // filter 65
											32'd66:  LOAD_WEIGHTS(stage5_layer67_2, 32, 0)	   // filter 66
											32'd67:  LOAD_WEIGHTS(stage5_layer68_2, 32, 0)	   // filter 67
											32'd68:  LOAD_WEIGHTS(stage5_layer69_2, 32, 0)	   // filter 68
											32'd69:  LOAD_WEIGHTS(stage5_layer70_2, 32, 0)	   // filter 69
											32'd70:  LOAD_WEIGHTS(stage5_layer71_2, 32, 0)	   // filter 70
											32'd71:  LOAD_WEIGHTS(stage5_layer72_2, 32, 0)	   // filter 71
											32'd72:  LOAD_WEIGHTS(stage5_layer73_2, 32, 0)	   // filter 72
											32'd73:  LOAD_WEIGHTS(stage5_layer74_2, 32, 0)	   // filter 73
											32'd74:  LOAD_WEIGHTS(stage5_layer75_2, 32, 0)	   // filter 74
											32'd75:  LOAD_WEIGHTS(stage5_layer76_2, 32, 0)	   // filter 75
											32'd76:  LOAD_WEIGHTS(stage5_layer77_2, 32, 0)	   // filter 76
											32'd77:  LOAD_WEIGHTS(stage5_layer78_2, 32, 0)	   // filter 77
											32'd78:  LOAD_WEIGHTS(stage5_layer79_2, 32, 0)	   // filter 78
											32'd79:  LOAD_WEIGHTS(stage5_layer80_2, 32, 0)	   // filter 79
											32'd80:  LOAD_WEIGHTS(stage5_layer81_2, 32, 0)	   // filter 80
											32'd81:  LOAD_WEIGHTS(stage5_layer82_2, 32, 0)	   // filter 81
											32'd82:  LOAD_WEIGHTS(stage5_layer83_2, 32, 0)	   // filter 82
											32'd83:  LOAD_WEIGHTS(stage5_layer84_2, 32, 0)	   // filter 83
											32'd84:  LOAD_WEIGHTS(stage5_layer85_2, 32, 0)	   // filter 84
											32'd85:  LOAD_WEIGHTS(stage5_layer86_2, 32, 0)	   // filter 85
											32'd86:  LOAD_WEIGHTS(stage5_layer87_2, 32, 0)	   // filter 86
											32'd87:  LOAD_WEIGHTS(stage5_layer88_2, 32, 0)	   // filter 87
											32'd88:  LOAD_WEIGHTS(stage5_layer89_2, 32, 0)	   // filter 88
											32'd89:  LOAD_WEIGHTS(stage5_layer90_2, 32, 0)	   // filter 89
											32'd90:  LOAD_WEIGHTS(stage5_layer91_2, 32, 0)	   // filter 90
											32'd91:  LOAD_WEIGHTS(stage5_layer92_2, 32, 0)	   // filter 91
											32'd92:  LOAD_WEIGHTS(stage5_layer93_2, 32, 0)	   // filter 92
											32'd93:  LOAD_WEIGHTS(stage5_layer94_2, 32, 0)	   // filter 93
											32'd94:  LOAD_WEIGHTS(stage5_layer95_2, 32, 0)	   // filter 94
											32'd95:  LOAD_WEIGHTS(stage5_layer96_2, 32, 0)	   // filter 95
											32'd96:  LOAD_WEIGHTS(stage5_layer97_2, 32, 0)	   // filter 96
											32'd97:  LOAD_WEIGHTS(stage5_layer98_2, 32, 0)	   // filter 97
											32'd98:  LOAD_WEIGHTS(stage5_layer99_2, 32, 0)	   // filter 98
											32'd99:  LOAD_WEIGHTS(stage5_layer100_2, 32, 0)	   // filter 99
											32'd100: LOAD_WEIGHTS(stage5_layer101_2, 32, 0)	   // filter 100
											32'd101: LOAD_WEIGHTS(stage5_layer102_2, 32, 0)	   // filter 101
											32'd102: LOAD_WEIGHTS(stage5_layer103_2, 32, 0)	   // filter 102
											32'd103: LOAD_WEIGHTS(stage5_layer104_2, 32, 0)	   // filter 103
											32'd104: LOAD_WEIGHTS(stage5_layer105_2, 32, 0)	   // filter 104
											32'd105: LOAD_WEIGHTS(stage5_layer106_2, 32, 0)	   // filter 105
											32'd106: LOAD_WEIGHTS(stage5_layer107_2, 32, 0)	   // filter 106
											32'd107: LOAD_WEIGHTS(stage5_layer108_2, 32, 0)	   // filter 107
											32'd108: LOAD_WEIGHTS(stage5_layer109_2, 32, 0)	   // filter 108
											32'd109: LOAD_WEIGHTS(stage5_layer110_2, 32, 0)	   // filter 109
											32'd110: LOAD_WEIGHTS(stage5_layer111_2, 32, 0)	   // filter 110
											32'd111: LOAD_WEIGHTS(stage5_layer112_2, 32, 0)	   // filter 111
											32'd112: LOAD_WEIGHTS(stage5_layer113_2, 32, 0)	   // filter 112
											32'd113: LOAD_WEIGHTS(stage5_layer114_2, 32, 0)	   // filter 113
											32'd114: LOAD_WEIGHTS(stage5_layer115_2, 32, 0)	   // filter 114
											32'd115: LOAD_WEIGHTS(stage5_layer116_2, 32, 0)	   // filter 115
											32'd116: LOAD_WEIGHTS(stage5_layer117_2, 32, 0)	   // filter 116
											32'd117: LOAD_WEIGHTS(stage5_layer118_2, 32, 0)	   // filter 117
											32'd118: LOAD_WEIGHTS(stage5_layer119_2, 32, 0)	   // filter 118
											32'd119: LOAD_WEIGHTS(stage5_layer120_2, 32, 0)	   // filter 119
											32'd120: LOAD_WEIGHTS(stage5_layer121_2, 32, 0)	   // filter 120
											32'd121: LOAD_WEIGHTS(stage5_layer122_2, 32, 0)	   // filter 121
											32'd122: LOAD_WEIGHTS(stage5_layer123_2, 32, 0)	   // filter 122
											32'd123: LOAD_WEIGHTS(stage5_layer124_2, 32, 0)	   // filter 123
											32'd124: LOAD_WEIGHTS(stage5_layer125_2, 32, 0)	   // filter 124
											32'd125: LOAD_WEIGHTS(stage5_layer126_2, 32, 0)	   // filter 125
											32'd126: LOAD_WEIGHTS(stage5_layer127_2, 32, 0)	   // filter 126
											32'd127: LOAD_WEIGHTS(stage5_layer128_2, 32, 0)	   // filter 127
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end
								
							
									for (i=0; i<32; i=i+1) begin
										// filters
										intermediate[i] <= cv_pixelout[i];
									end
									
									// add bias and quantization
									if (inlayercount == 32'd32) begin
										//qt0
										qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
														+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
														+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
														+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
														+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
														+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
														+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
														+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31]
														+ intermediatesum[layercount];
										qt0_bias <= bias0;
										qt0_zp   <= zp0;
										qt0_scale <= scale0;
										
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
										
										if (pixelcount >9) begin
											case (layercount-1):
												32'd0:  savebuffer[31:24] <= {qt0_res};
												32'd1:  savebuffer[23:16] <= {qt0_res};
												32'd2:  savebuffer[15:8]  <= {qt0_res};
												32'd3:  layerint_buf0_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd4:  savebuffer[31:24] <= {qt0_res};
												32'd5:  savebuffer[23:16] <= {qt0_res};
												32'd6:  savebuffer[15:8]  <= {qt0_res};
												32'd7:  layerint_buf1_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd8:  savebuffer[31:24] <= {qt0_res};
												32'd9:  savebuffer[23:16] <= {qt0_res};
												32'd10: savebuffer[15:8]  <= {qt0_res};
												32'd11: layerint_buf2_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd12: savebuffer[31:24] <= {qt0_res};
												32'd13: savebuffer[23:16] <= {qt0_res};
												32'd14: savebuffer[15:8]  <= {qt0_res};
												32'd15: layerint_buf3_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd16: savebuffer[31:24] <= {qt0_res};
												32'd17: savebuffer[23:16] <= {qt0_res};
												32'd18: savebuffer[15:8]  <= {qt0_res};
												32'd19: layerint_buf4_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd20: savebuffer[31:24] <= {qt0_res};
												32'd21: savebuffer[23:16] <= {qt0_res};
												32'd22: savebuffer[15:8]  <= {qt0_res};
												32'd23: layerint_buf5_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd24: savebuffer[31:24] <= {qt0_res};
												32'd25: savebuffer[23:16] <= {qt0_res};
												32'd26: savebuffer[15:8]  <= {qt0_res};
												32'd27: layerint_buf6_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd28: savebuffer[31:24] <= {qt0_res};
												32'd29: savebuffer[23:16] <= {qt0_res};
												32'd30: savebuffer[15:8]  <= {qt0_res};
												32'd31: layerint_buf7_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd32: savebuffer[31:24] <= {qt0_res};
												32'd33: savebuffer[23:16] <= {qt0_res};
												32'd34: savebuffer[15:8]  <= {qt0_res};
												32'd35: layerint_buf8_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd36: savebuffer[31:24] <= {qt0_res};
												32'd37: savebuffer[23:16] <= {qt0_res};
												32'd38: savebuffer[15:8]  <= {qt0_res};
												32'd39: layerint_buf9_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd40: savebuffer[31:24] <= {qt0_res};
												32'd41: savebuffer[23:16] <= {qt0_res};
												32'd42: savebuffer[15:8]  <= {qt0_res};
												32'd43: layerint_buf10_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd44: savebuffer[31:24] <= {qt0_res};
												32'd45: savebuffer[23:16] <= {qt0_res};
												32'd46: savebuffer[15:8]  <= {qt0_res};
												32'd47: layerint_buf11_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd48: savebuffer[31:24] <= {qt0_res};
												32'd49: savebuffer[23:16] <= {qt0_res};
												32'd50: savebuffer[15:8]  <= {qt0_res};
												32'd51: layerint_buf12_st5[[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd52: savebuffer[31:24] <= {qt0_res};
												32'd53: savebuffer[23:16] <= {qt0_res};
												32'd54: savebuffer[15:8]  <= {qt0_res};
												32'd55: layerint_buf13_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd56: savebuffer[31:24] <= {qt0_res};
												32'd57: savebuffer[23:16] <= {qt0_res};
												32'd58: savebuffer[15:8]  <= {qt0_res};
												32'd59: layerint_buf14_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd60: savebuffer[31:24] <= {qt0_res};
												32'd61: savebuffer[23:16] <= {qt0_res};
												32'd62: savebuffer[15:8]  <= {qt0_res};
												32'd63: layerint_buf15_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd64:  savebuffer[31:24] <= {qt0_res};
												32'd65:  savebuffer[23:16] <= {qt0_res};
												32'd66:  savebuffer[15:8]  <= {qt0_res};
												32'd67:  layerint_buf16_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd68:  savebuffer[31:24] <= {qt0_res};
												32'd69:  savebuffer[23:16] <= {qt0_res};
												32'd70:  savebuffer[15:8]  <= {qt0_res};
												32'd71:  layerint_buf17_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd72:  savebuffer[31:24] <= {qt0_res};
												32'd73:  savebuffer[23:16] <= {qt0_res};
												32'd74: savebuffer[15:8]  <= {qt0_res};
												32'd75: layerint_buf18_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd76: savebuffer[31:24] <= {qt0_res};
												32'd77: savebuffer[23:16] <= {qt0_res};
												32'd78: savebuffer[15:8]  <= {qt0_res};
												32'd79: layerint_buf19_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd80: savebuffer[31:24] <= {qt0_res};
												32'd81: savebuffer[23:16] <= {qt0_res};
												32'd82: savebuffer[15:8]  <= {qt0_res};
												32'd83: layerint_buf20_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd84: savebuffer[31:24] <= {qt0_res};
												32'd85: savebuffer[23:16] <= {qt0_res};
												32'd86: savebuffer[15:8]  <= {qt0_res};
												32'd87: layerint_buf21_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd88: savebuffer[31:24] <= {qt0_res};
												32'd89: savebuffer[23:16] <= {qt0_res};
												32'd90: savebuffer[15:8]  <= {qt0_res};
												32'd91: layerint_buf22_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd92: savebuffer[31:24] <= {qt0_res};
												32'd93: savebuffer[23:16] <= {qt0_res};
												32'd94: savebuffer[15:8]  <= {qt0_res};
												32'd95: layerint_buf23_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd96: savebuffer[31:24] <= {qt0_res};
												32'd97: savebuffer[23:16] <= {qt0_res};
												32'd98: savebuffer[15:8]  <= {qt0_res};
												32'd99: layerint_buf24_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd100: savebuffer[31:24] <= {qt0_res};
												32'd101: savebuffer[23:16] <= {qt0_res};
												32'd102: savebuffer[15:8]  <= {qt0_res};
												32'd103: layerint_buf25_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd104: savebuffer[31:24] <= {qt0_res};
												32'd105: savebuffer[23:16] <= {qt0_res};
												32'd106: savebuffer[15:8]  <= {qt0_res};
												32'd107: layerint_buf26_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd108: savebuffer[31:24] <= {qt0_res};
												32'd109: savebuffer[23:16] <= {qt0_res};
												32'd110: savebuffer[15:8]  <= {qt0_res};
												32'd111: layerint_buf27_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd112: savebuffer[31:24] <= {qt0_res};
												32'd113: savebuffer[23:16] <= {qt0_res};
												32'd114: savebuffer[15:8]  <= {qt0_res};
												32'd115: layerint_buf28_st5[[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd116: savebuffer[31:24] <= {qt0_res};
												32'd117: savebuffer[23:16] <= {qt0_res};
												32'd118: savebuffer[15:8]  <= {qt0_res};
												32'd119: layerint_buf29_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd120: savebuffer[31:24] <= {qt0_res};
												32'd121: savebuffer[23:16] <= {qt0_res};
												32'd122: savebuffer[15:8]  <= {qt0_res};
												32'd123: layerint_buf30_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
												32'd124: savebuffer[31:24] <= {qt0_res};
												32'd125: savebuffer[23:16] <= {qt0_res};
												32'd126: savebuffer[15:8]  <= {qt0_res};
												32'd127: layerint_buf31_st5[(pixelcount-10)] <= {savebuffer[31:8], qt0_res};
											endcase
										end
									end else begin
										intermediatesum[layercount] <= intermediate[0 + intermediate[1] + intermediate[2] + intermediate[3]
														                   + intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
														                   + intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
														                   + intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
												             		       + intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
														                   + intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
														                   + intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
														                   + intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									end
								end
							end
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
						if (pixelcount >= 32'd265) begin  // (height*width + (width+1) for padding)
							if (inlayercount >= 32'd128) begin
								if (pixelcount == 32'd265) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
								end else begin
									for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
									state <= STAGE67_CONV;
									pixelcount <= 32'b0;
									layercount <= 0;
									inlayercount <= 0;
								end
								
							end else begin
								pixelcount <= 32'b0;
								inlayercount <= inlayercount + 32'd32;
							end
							
						end else begin
							if (pixelcount < 9) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin 
								if (layercount >= 32'd64) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd1;
									
									if (inlayercount == 0) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage6_translayer1_1, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage6_translayer2_1, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage6_translayer3_1, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage6_translayer4_1, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage6_translayer5_1, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage6_translayer6_1, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage6_translayer7_1, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage6_translayer8_1, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage6_translayer9_1, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage6_translayer10_1, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage6_translayer11_1, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage6_translayer12_1, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage6_translayer13_1, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage6_translayer14_1, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage6_translayer15_1, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage6_translayer16_1, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage6_translayer17_1, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage6_translayer18_1, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage6_translayer19_1, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage6_translayer20_1, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage6_translayer21_1, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage6_translayer22_1, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage6_translayer23_1, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage6_translayer24_1, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage6_translayer25_1, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage6_translayer26_1, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage6_translayer27_1, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage6_translayer28_1, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage6_translayer29_1, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage6_translayer30_1, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage6_translayer31_1, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage6_translayer32_1, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage6_translayer33_1, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage6_translayer34_1, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage6_translayer35_1, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage6_translayer36_1, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage6_translayer37_1, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage6_translayer38_1, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage6_translayer39_1, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage6_translayer40_1, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage6_translayer41_1, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage6_translayer42_1, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage6_translayer43_1, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage6_translayer44_1, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage6_translayer45_1, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage6_translayer46_1, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage6_translayer47_1, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage6_translayer48_1, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage6_translayer49_1, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage6_translayer50_1, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage6_translayer51_1, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage6_translayer52_1, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage6_translayer53_1, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage6_translayer54_1, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage6_translayer55_1, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage6_translayer56_1, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage6_translayer57_1, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage6_translayer58_1, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage6_translayer59_1, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage6_translayer60_1, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage6_translayer61_1, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage6_translayer62_1, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage6_translayer63_1, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage6_translayer64_1, 32, 0)	   // filter 63
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else if (inlayercount == 32'd32) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage6_translayer1_2, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage6_translayer2_2, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage6_translayer3_2, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage6_translayer4_2, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage6_translayer5_2, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage6_translayer6_2, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage6_translayer7_2, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage6_translayer8_2, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage6_translayer9_2, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage6_translayer10_2, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage6_translayer11_2, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage6_translayer12_2, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage6_translayer13_2, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage6_translayer14_2, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage6_translayer15_2, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage6_translayer16_2, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage6_translayer17_2, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage6_translayer18_2, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage6_translayer19_2, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage6_translayer20_2, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage6_translayer21_2, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage6_translayer22_2, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage6_translayer23_2, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage6_translayer24_2, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage6_translayer25_2, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage6_translayer26_2, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage6_translayer27_2, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage6_translayer28_2, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage6_translayer29_2, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage6_translayer30_2, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage6_translayer31_2, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage6_translayer32_2, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage6_translayer33_2, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage6_translayer34_2, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage6_translayer35_2, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage6_translayer36_2, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage6_translayer37_2, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage6_translayer38_2, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage6_translayer39_2, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage6_translayer40_2, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage6_translayer41_2, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage6_translayer42_2, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage6_translayer43_2, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage6_translayer44_2, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage6_translayer45_2, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage6_translayer46_2, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage6_translayer47_2, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage6_translayer48_2, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage6_translayer49_2, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage6_translayer50_2, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage6_translayer51_2, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage6_translayer52_2, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage6_translayer53_2, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage6_translayer54_2, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage6_translayer55_2, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage6_translayer56_2, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage6_translayer57_2, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage6_translayer58_2, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage6_translayer59_2, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage6_translayer60_2, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage6_translayer61_2, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage6_translayer62_2, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage6_translayer63_2, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage6_translayer64_2, 32, 0)	   // filter 63
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else if (inlayercount == 32'd64) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage6_translayer1_3, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage6_translayer2_3, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage6_translayer3_3, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage6_translayer4_3, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage6_translayer5_3, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage6_translayer6_3, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage6_translayer7_3, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage6_translayer8_3, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage6_translayer9_3, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage6_translayer10_3, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage6_translayer11_3, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage6_translayer12_3, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage6_translayer13_3, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage6_translayer14_3, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage6_translayer15_3, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage6_translayer16_3, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage6_translayer17_3, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage6_translayer18_3, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage6_translayer19_3, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage6_translayer20_3, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage6_translayer21_3, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage6_translayer22_3, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage6_translayer23_3, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage6_translayer24_3, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage6_translayer25_3, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage6_translayer26_3, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage6_translayer27_3, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage6_translayer28_3, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage6_translayer29_3, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage6_translayer30_3, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage6_translayer31_3, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage6_translayer32_3, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage6_translayer33_3, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage6_translayer34_3, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage6_translayer35_3, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage6_translayer36_3, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage6_translayer37_3, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage6_translayer38_3, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage6_translayer39_3, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage6_translayer40_3, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage6_translayer41_3, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage6_translayer42_3, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage6_translayer43_3, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage6_translayer44_3, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage6_translayer45_3, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage6_translayer46_3, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage6_translayer47_3, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage6_translayer48_3, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage6_translayer49_3, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage6_translayer50_3, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage6_translayer51_3, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage6_translayer52_3, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage6_translayer53_3, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage6_translayer54_3, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage6_translayer55_3, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage6_translayer56_3, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage6_translayer57_3, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage6_translayer58_3, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage6_translayer59_3, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage6_translayer60_3, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage6_translayer61_3, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage6_translayer62_3, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage6_translayer63_3, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage6_translayer64_3, 32, 0)	   // filter 63
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage6_translayer1_4, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage6_translayer2_4, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage6_translayer3_4, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage6_translayer4_4, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage6_translayer5_4, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage6_translayer6_4, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage6_translayer7_4, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage6_translayer8_4, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage6_translayer9_4, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage6_translayer10_4, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage6_translayer11_4, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage6_translayer12_4, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage6_translayer13_4, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage6_translayer14_4, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage6_translayer15_4, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage6_translayer16_4, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage6_translayer17_4, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage6_translayer18_4, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage6_translayer19_4, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage6_translayer20_4, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage6_translayer21_4, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage6_translayer22_4, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage6_translayer23_4, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage6_translayer24_4, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage6_translayer25_4, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage6_translayer26_4, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage6_translayer27_4, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage6_translayer28_4, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage6_translayer29_4, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage6_translayer30_4, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage6_translayer31_4, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage6_translayer32_4, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage6_translayer33_4, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage6_translayer34_4, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage6_translayer35_4, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage6_translayer36_4, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage6_translayer37_4, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage6_translayer38_4, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage6_translayer39_4, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage6_translayer40_4, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage6_translayer41_4, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage6_translayer42_4, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage6_translayer43_4, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage6_translayer44_4, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage6_translayer45_4, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage6_translayer46_4, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage6_translayer47_4, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage6_translayer48_4, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage6_translayer49_4, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage6_translayer50_4, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage6_translayer51_4, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage6_translayer52_4, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage6_translayer53_4, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage6_translayer54_4, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage6_translayer55_4, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage6_translayer56_4, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage6_translayer57_4, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage6_translayer58_4, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage6_translayer59_4, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage6_translayer60_4, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage6_translayer61_4, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage6_translayer62_4, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage6_translayer63_4, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage6_translayer64_4, 32, 0)	   // filter 63
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end 
								
							
									for (i=0; i<32; i=i+1) begin
										// filters
										intermediate[i] <= cv_pixelout[i];
									end
									
									// add bias and quantization
									if (inlayercount == 32'd96) begin
										//qt0
										qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
														+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
														+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
														+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
														+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
														+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
														+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
														+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31] 
														+ intermediatesum[layercount];
										qt0_bias <= bias0;
										qt0_zp   <= zp0;
										qt0_scale <= scale0;
										
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
										
										if (pixelcount >9) begin
											case (layercount-1):
												32'd0:  layerint_buf0_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd1:  layerint_buf0_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd2:  layerint_buf0_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd3:  layerint_buf0_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd4:  layerint_buf1_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd5:  layerint_buf1_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd6:  layerint_buf1_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd7:  layerint_buf1_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd8:  layerint_buf2_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd9:  layerint_buf2_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd10: layerint_buf2_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd11: layerint_buf2_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd12: layerint_buf3_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd13: layerint_buf3_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd14: layerint_buf3_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd15: layerint_buf3_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd16: layerint_buf4_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd17: layerint_buf4_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd18: layerint_buf4_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd19: layerint_buf4_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd20: layerint_buf5_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd21: layerint_buf5_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd22: layerint_buf5_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd23: layerint_buf5_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd24: layerint_buf6_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd25: layerint_buf6_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd26: layerint_buf6_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd27: layerint_buf6_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd28: layerint_buf7_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd29: layerint_buf7_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd30: layerint_buf7_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd31: layerint_buf7_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd32: layerint_buf8_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd33: layerint_buf8_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd34: layerint_buf8_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd35: layerint_buf8_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd36: layerint_buf9_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd37: layerint_buf9_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd38: layerint_buf9_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd39: layerint_buf9_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd40: layerint_buf10_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd41: layerint_buf10_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd42: layerint_buf10_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd43: layerint_buf10_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd44: layerint_buf11_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd45: layerint_buf11_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd46: layerint_buf11_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd47: layerint_buf11_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd48: layerint_buf12_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd49: layerint_buf12_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd50: layerint_buf12_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd51: layerint_buf12_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd52: layerint_buf13_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd53: layerint_buf13_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd54: layerint_buf13_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd55: layerint_buf13_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd56: layerint_buf14_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd57: layerint_buf14_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd58: layerint_buf14_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd59: layerint_buf14_st5[((pixelcount-10)*4)+3] <= {qt0_res};
												32'd60: layerint_buf15_st5[(pixelcount-10)*4]     <= {qt0_res};
												32'd61: layerint_buf15_st5[((pixelcount-10)*4)+1] <= {qt0_res};
												32'd62: layerint_buf15_st5[((pixelcount-10)*4)+2] <= {qt0_res};
												32'd63: layerint_buf15_st5[((pixelcount-10)*4)+3] <= {qt0_res};
											endcase
										end
										
									end else if (inlayercount == 32'd0) begin
										intermediatesum[layercount] <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
																					+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
																					+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
																					+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
																					+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
																					+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
																					+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
																					+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									end else begin
										intermediatesum[layercount] <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
																					+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
																					+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
																					+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
																					+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
																					+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
																					+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
																					+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31]
																					+ intermediatesum[layercount];
									end
								end
							end
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
						if (pixelcount >= 32'd273) begin  // (height*width + (width+1) for padding)
							if (inlayercount >= 32'd128) begin
								if (pixelcount == 32'd273) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
								end else begin
									for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
									state <= STAGE7_TRANSCONV;
									pixelcount <= 32'b0;
									layercount <= 0;
									inlayercount <= 0;
								end
								
							end else begin
								pixelcount <= 32'b0;
								inlayercount <= inlayercount + 32'd32;
							end
							
						end else begin
							if (pixelcount < 17) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin 
								if (layercount >= 32'd64) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd1;
									
									if (inlayercount == 0) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage6_layer1_1, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage6_layer2_1, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage6_layer3_1, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage6_layer4_1, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage6_layer5_1, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage6_layer6_1, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage6_layer7_1, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage6_layer8_1, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage6_layer9_1, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage6_layer10_1, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage6_layer11_1, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage6_layer12_1, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage6_layer13_1, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage6_layer14_1, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage6_layer15_1, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage6_layer16_1, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage6_layer17_1, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage6_layer18_1, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage6_layer19_1, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage6_layer20_1, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage6_layer21_1, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage6_layer22_1, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage6_layer23_1, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage6_layer24_1, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage6_layer25_1, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage6_layer26_1, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage6_layer27_1, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage6_layer28_1, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage6_layer29_1, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage6_layer30_1, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage6_layer31_1, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage6_layer32_1, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage6_layer33_1, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage6_layer34_1, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage6_layer35_1, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage6_layer36_1, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage6_layer37_1, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage6_layer38_1, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage6_layer39_1, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage6_layer40_1, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage6_layer41_1, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage6_layer42_1, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage6_layer43_1, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage6_layer44_1, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage6_layer45_1, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage6_layer46_1, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage6_layer47_1, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage6_layer48_1, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage6_layer49_1, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage6_layer50_1, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage6_layer51_1, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage6_layer52_1, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage6_layer53_1, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage6_layer54_1, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage6_layer55_1, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage6_layer56_1, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage6_layer57_1, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage6_layer58_1, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage6_layer59_1, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage6_layer60_1, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage6_layer61_1, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage6_layer62_1, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage6_layer63_1, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage6_layer64_1, 32, 0)	   // filter 63
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else if (inlayercount == 32'd32) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage6_layer1_2, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage6_layer2_2, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage6_layer3_2, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage6_layer4_2, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage6_layer5_2, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage6_layer6_2, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage6_layer7_2, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage6_layer8_2, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage6_layer9_2, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage6_layer10_2, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage6_layer11_2, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage6_layer12_2, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage6_layer13_2, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage6_layer14_2, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage6_layer15_2, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage6_layer16_2, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage6_layer17_2, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage6_layer18_2, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage6_layer19_2, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage6_layer20_2, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage6_layer21_2, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage6_layer22_2, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage6_layer23_2, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage6_layer24_2, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage6_layer25_2, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage6_layer26_2, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage6_layer27_2, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage6_layer28_2, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage6_layer29_2, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage6_layer30_2, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage6_layer31_2, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage6_layer32_2, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage6_layer33_2, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage6_layer34_2, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage6_layer35_2, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage6_layer36_2, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage6_layer37_2, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage6_layer38_2, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage6_layer39_2, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage6_layer40_2, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage6_layer41_2, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage6_layer42_2, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage6_layer43_2, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage6_layer44_2, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage6_layer45_2, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage6_layer46_2, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage6_layer47_2, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage6_layer48_2, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage6_layer49_2, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage6_layer50_2, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage6_layer51_2, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage6_layer52_2, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage6_layer53_2, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage6_layer54_2, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage6_layer55_2, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage6_layer56_2, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage6_layer57_2, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage6_layer58_2, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage6_layer59_2, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage6_layer60_2, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage6_layer61_2, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage6_layer62_2, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage6_layer63_2, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage6_layer64_2, 32, 0)	   // filter 63
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else if (inlayercount == 32'd64) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage6_layer1_3, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage6_layer2_3, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage6_layer3_3, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage6_layer4_3, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage6_layer5_3, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage6_layer6_3, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage6_layer7_3, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage6_layer8_3, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage6_layer9_3, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage6_layer10_3, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage6_layer11_3, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage6_layer12_3, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage6_layer13_3, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage6_layer14_3, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage6_layer15_3, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage6_layer16_3, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage6_layer17_3, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage6_layer18_3, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage6_layer19_3, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage6_layer20_3, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage6_layer21_3, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage6_layer22_3, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage6_layer23_3, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage6_layer24_3, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage6_layer25_3, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage6_layer26_3, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage6_layer27_3, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage6_layer28_3, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage6_layer29_3, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage6_layer30_3, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage6_layer31_3, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage6_layer32_3, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage6_layer33_3, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage6_layer34_3, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage6_layer35_3, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage6_layer36_3, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage6_layer37_3, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage6_layer38_3, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage6_layer39_3, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage6_layer40_3, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage6_layer41_3, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage6_layer42_3, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage6_layer43_3, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage6_layer44_3, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage6_layer45_3, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage6_layer46_3, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage6_layer47_3, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage6_layer48_3, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage6_layer49_3, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage6_layer50_3, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage6_layer51_3, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage6_layer52_3, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage6_layer53_3, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage6_layer54_3, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage6_layer55_3, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage6_layer56_3, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage6_layer57_3, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage6_layer58_3, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage6_layer59_3, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage6_layer60_3, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage6_layer61_3, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage6_layer62_3, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage6_layer63_3, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage6_layer64_3, 32, 0)	   // filter 63
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage6_layer1_4, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage6_layer2_4, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage6_layer3_4, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage6_layer4_4, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage6_layer5_4, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage6_layer6_4, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage6_layer7_4, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage6_layer8_4, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage6_layer9_4, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage6_layer10_4, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage6_layer11_4, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage6_layer12_4, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage6_layer13_4, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage6_layer14_4, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage6_layer15_4, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage6_layer16_4, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage6_layer17_4, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage6_layer18_4, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage6_layer19_4, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage6_layer20_4, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage6_layer21_4, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage6_layer22_4, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage6_layer23_4, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage6_layer24_4, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage6_layer25_4, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage6_layer26_4, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage6_layer27_4, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage6_layer28_4, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage6_layer29_4, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage6_layer30_4, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage6_layer31_4, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage6_layer32_4, 32, 0)	   // filter 31
											32'd32:  LOAD_WEIGHTS(stage6_layer33_4, 32, 0)	   // filter 32
											32'd33:  LOAD_WEIGHTS(stage6_layer34_4, 32, 0)	   // filter 33
											32'd34:  LOAD_WEIGHTS(stage6_layer35_4, 32, 0)	   // filter 34
											32'd35:  LOAD_WEIGHTS(stage6_layer36_4, 32, 0)	   // filter 35
											32'd36:  LOAD_WEIGHTS(stage6_layer37_4, 32, 0)	   // filter 36
											32'd37:  LOAD_WEIGHTS(stage6_layer38_4, 32, 0)	   // filter 37
											32'd38:  LOAD_WEIGHTS(stage6_layer39_4, 32, 0)	   // filter 38
											32'd39:  LOAD_WEIGHTS(stage6_layer40_4, 32, 0)	   // filter 39
											32'd40:  LOAD_WEIGHTS(stage6_layer41_4, 32, 0)	   // filter 40
											32'd41:  LOAD_WEIGHTS(stage6_layer42_4, 32, 0)	   // filter 41
											32'd42:  LOAD_WEIGHTS(stage6_layer43_4, 32, 0)	   // filter 42
											32'd43:  LOAD_WEIGHTS(stage6_layer44_4, 32, 0)	   // filter 43
											32'd44:  LOAD_WEIGHTS(stage6_layer45_4, 32, 0)	   // filter 44
											32'd45:  LOAD_WEIGHTS(stage6_layer46_4, 32, 0)	   // filter 45
											32'd46:  LOAD_WEIGHTS(stage6_layer47_4, 32, 0)	   // filter 46
											32'd47:  LOAD_WEIGHTS(stage6_layer48_4, 32, 0)	   // filter 47
											32'd48:  LOAD_WEIGHTS(stage6_layer49_4, 32, 0)	   // filter 48
											32'd49:  LOAD_WEIGHTS(stage6_layer50_4, 32, 0)	   // filter 49
											32'd50:  LOAD_WEIGHTS(stage6_layer51_4, 32, 0)	   // filter 50
											32'd51:  LOAD_WEIGHTS(stage6_layer52_4, 32, 0)	   // filter 51
											32'd52:  LOAD_WEIGHTS(stage6_layer53_4, 32, 0)	   // filter 52
											32'd53:  LOAD_WEIGHTS(stage6_layer54_4, 32, 0)	   // filter 53
											32'd54:  LOAD_WEIGHTS(stage6_layer55_4, 32, 0)	   // filter 54
											32'd55:  LOAD_WEIGHTS(stage6_layer56_4, 32, 0)	   // filter 55
											32'd56:  LOAD_WEIGHTS(stage6_layer57_4, 32, 0)	   // filter 56
											32'd57:  LOAD_WEIGHTS(stage6_layer58_4, 32, 0)	   // filter 57
											32'd58:  LOAD_WEIGHTS(stage6_layer59_4, 32, 0)	   // filter 58
											32'd59:  LOAD_WEIGHTS(stage6_layer60_4, 32, 0)	   // filter 59
											32'd60:  LOAD_WEIGHTS(stage6_layer61_4, 32, 0)	   // filter 60
											32'd61:  LOAD_WEIGHTS(stage6_layer62_4, 32, 0)	   // filter 61
											32'd62:  LOAD_WEIGHTS(stage6_layer63_4, 32, 0)	   // filter 62
											32'd63:  LOAD_WEIGHTS(stage6_layer64_4, 32, 0)	   // filter 63
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end 
								
							
									for (i=0; i<32; i=i+1) begin
										// filters
										intermediate[i] <= cv_pixelout[i];
									end
									
									// add bias and quantization
									if (inlayercount == 32'd96) begin
										//qt0
										qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
														+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
														+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
														+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
														+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
														+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
														+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
														+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31] 
														+ intermediatesum[layercount];
										qt0_bias <= bias0;
										qt0_zp   <= zp0;
										qt0_scale <= scale0;
										
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
										
										if (pixelcount >17) begin
											case (layercount-1):
												32'd0:  savebuffer[31:24] <= {qt0_res};
												32'd1:  savebuffer[23:16] <= {qt0_res};
												32'd2:  savebuffer[15:8]  <= {qt0_res};
												32'd3:  layerint_buf0_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd4:  savebuffer[31:24] <= {qt0_res};
												32'd5:  savebuffer[23:16] <= {qt0_res};
												32'd6:  savebuffer[15:8]  <= {qt0_res};
												32'd7:  layerint_buf1_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd8:  savebuffer[31:24] <= {qt0_res};
												32'd9:  savebuffer[23:16] <= {qt0_res};
												32'd10: savebuffer[15:8]  <= {qt0_res};
												32'd11: layerint_buf2_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd12: savebuffer[31:24] <= {qt0_res};
												32'd13: savebuffer[23:16] <= {qt0_res};
												32'd14: savebuffer[15:8]  <= {qt0_res};
												32'd15: layerint_buf3_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd16: savebuffer[31:24] <= {qt0_res};
												32'd17: savebuffer[23:16] <= {qt0_res};
												32'd18: savebuffer[15:8]  <= {qt0_res};
												32'd19: layerint_buf4_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd20: savebuffer[31:24] <= {qt0_res};
												32'd21: savebuffer[23:16] <= {qt0_res};
												32'd22: savebuffer[15:8]  <= {qt0_res};
												32'd23: layerint_buf5_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd24: savebuffer[31:24] <= {qt0_res};
												32'd25: savebuffer[23:16] <= {qt0_res};
												32'd26: savebuffer[15:8]  <= {qt0_res};
												32'd27: layerint_buf6_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd28: savebuffer[31:24] <= {qt0_res};
												32'd29: savebuffer[23:16] <= {qt0_res};
												32'd30: savebuffer[15:8]  <= {qt0_res};
												32'd31: layerint_buf7_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd32: savebuffer[31:24] <= {qt0_res};
												32'd33: savebuffer[23:16] <= {qt0_res};
												32'd34: savebuffer[15:8]  <= {qt0_res};
												32'd35: layerint_buf8_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd36: savebuffer[31:24] <= {qt0_res};
												32'd37: savebuffer[23:16] <= {qt0_res};
												32'd38: savebuffer[15:8]  <= {qt0_res};
												32'd39: layerint_buf9_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd40: savebuffer[31:24] <= {qt0_res};
												32'd41: savebuffer[23:16] <= {qt0_res};
												32'd42: savebuffer[15:8]  <= {qt0_res};
												32'd43: layerint_buf10_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd44: savebuffer[31:24] <= {qt0_res};
												32'd45: savebuffer[23:16] <= {qt0_res};
												32'd46: savebuffer[15:8]  <= {qt0_res};
												32'd47: layerint_buf11_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd48: savebuffer[31:24] <= {qt0_res};
												32'd49: savebuffer[23:16] <= {qt0_res};
												32'd50: savebuffer[15:8]  <= {qt0_res};
												32'd51: layerint_buf12_st5[[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd52: savebuffer[31:24] <= {qt0_res};
												32'd53: savebuffer[23:16] <= {qt0_res};
												32'd54: savebuffer[15:8]  <= {qt0_res};
												32'd55: layerint_buf13_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd56: savebuffer[31:24] <= {qt0_res};
												32'd57: savebuffer[23:16] <= {qt0_res};
												32'd58: savebuffer[15:8]  <= {qt0_res};
												32'd59: layerint_buf14_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd60: savebuffer[31:24] <= {qt0_res};
												32'd61: savebuffer[23:16] <= {qt0_res};
												32'd62: savebuffer[15:8]  <= {qt0_res};
												32'd63: layerint_buf15_st5[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											endcase
										end
										
									end else if (inlayercount == 32'd0) begin
										intermediatesum[layercount] <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
																					+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
																					+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
																					+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
																					+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
																					+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
																					+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
																					+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									end else begin
										intermediatesum[layercount] <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
																					+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
																					+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
																					+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
																					+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
																					+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
																					+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
																					+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31]
																					+ intermediatesum[layercount];
									end
								end
							end
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
						if (pixelcount >= 32'd1041) begin  // (height*width + (width+1) for padding)
							if (inlayercount >= 32'd64) begin
								if (pixelcount == 32'd1041) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
								end else begin
									for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
									state <= STAGE7_CONV;
									pixelcount <= 32'b0;
									layercount <= 0;
									inlayercount <= 0;
								end
								
							end else begin
								pixelcount <= 32'b0;
								inlayercount <= inlayercount + 32'd32;
							end
							
						end else begin
							if (pixelcount < 17) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin 
								if (layercount >= 32'd32) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd1;
									
									if (inlayercount == 0) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage7_translayer1_1, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage7_translayer2_1, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage7_translayer3_1, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage7_translayer4_1, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage7_translayer5_1, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage7_translayer6_1, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage7_translayer7_1, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage7_translayer8_1, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage7_translayer9_1, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage7_translayer10_1, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage7_translayer11_1, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage7_translayer12_1, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage7_translayer13_1, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage7_translayer14_1, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage7_translayer15_1, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage7_translayer16_1, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage7_translayer17_1, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage7_translayer18_1, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage7_translayer19_1, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage7_translayer20_1, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage7_translayer21_1, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage7_translayer22_1, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage7_translayer23_1, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage7_translayer24_1, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage7_translayer25_1, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage7_translayer26_1, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage7_translayer27_1, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage7_translayer28_1, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage7_translayer29_1, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage7_translayer30_1, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage7_translayer31_1, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage7_translayer32_1, 32, 0)	   // filter 31
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else begin
										case (translayercount)
											32'd0:   LOAD_WEIGHTS(stage7_translayer1_2, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage7_translayer2_2, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage7_translayer3_2, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage7_translayer4_2, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage7_translayer5_2, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage7_translayer6_2, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage7_translayer7_2, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage7_translayer8_2, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage7_translayer9_2, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage7_translayer10_2, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage7_translayer11_2, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage7_translayer12_2, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage7_translayer13_2, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage7_translayer14_2, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage7_translayer15_2, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage7_translayer16_2, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage7_translayer17_2, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage7_translayer18_2, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage7_translayer19_2, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage7_translayer20_2, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage7_translayer21_2, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage7_translayer22_2, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage7_translayer23_2, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage7_translayer24_2, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage7_translayer25_2, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage7_translayer26_2, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage7_translayer27_2, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage7_translayer28_2, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage7_translayer29_2, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage7_translayer30_2, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage7_translayer31_2, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage7_translayer32_2, 32, 0)	   // filter 31
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end
								
							
									for (i=0; i<32; i=i+1) begin
										// filters
										intermediate[i] <= cv_pixelout[i];
									end
									
									// add bias and quantization
									if (inlayercount == 32'd32) begin
										//qt0
										qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
														+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
														+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
														+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
														+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
														+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
														+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
														+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31]
														+ intermediatesum[layercount];
										qt0_bias <= bias0;
										qt0_zp   <= zp0;
										qt0_scale <= scale0;
										
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
										
										if (pixelcount >17) begin
											case (layercount-1):
												32'd0:  savebuffer[31:24] <= {qt0_res};
												32'd1:  savebuffer[23:16] <= {qt0_res};
												32'd2:  savebuffer[15:8]  <= {qt0_res};
												32'd3:  layerint_buf0_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd4:  savebuffer[31:24] <= {qt0_res};
												32'd5:  savebuffer[23:16] <= {qt0_res};
												32'd6:  savebuffer[15:8]  <= {qt0_res};
												32'd7:  layerint_buf1_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd8:  savebuffer[31:24] <= {qt0_res};
												32'd9:  savebuffer[23:16] <= {qt0_res};
												32'd10: savebuffer[15:8]  <= {qt0_res};
												32'd11: layerint_buf2_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd12: savebuffer[31:24] <= {qt0_res};
												32'd13: savebuffer[23:16] <= {qt0_res};
												32'd14: savebuffer[15:8]  <= {qt0_res};
												32'd15: layerint_buf3_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd16: savebuffer[31:24] <= {qt0_res};
												32'd17: savebuffer[23:16] <= {qt0_res};
												32'd18: savebuffer[15:8]  <= {qt0_res};
												32'd19: layerint_buf4_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd20: savebuffer[31:24] <= {qt0_res};
												32'd21: savebuffer[23:16] <= {qt0_res};
												32'd22: savebuffer[15:8]  <= {qt0_res};
												32'd23: layerint_buf5_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd24: savebuffer[31:24] <= {qt0_res};
												32'd25: savebuffer[23:16] <= {qt0_res};
												32'd26: savebuffer[15:8]  <= {qt0_res};
												32'd27: layerint_buf6_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
												32'd28: savebuffer[31:24] <= {qt0_res};
												32'd29: savebuffer[23:16] <= {qt0_res};
												32'd30: savebuffer[15:8]  <= {qt0_res};
												32'd31: layerint_buf7_st4[(pixelcount-18)] <= {savebuffer[31:8], qt0_res};
											endcase
										end
									end else begin
										intermediatesum[layercount] <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
																				 + intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
																				 + intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
																				 + intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
																				 + intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
																				 + intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
																				 + intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
																				 + intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									end
								end
							end
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
					// pixel100...
					
					begin
						if (pixelcount >= 32'd1057) begin  // (height*width + (width+1) for padding)
							if (inlayercount >= 32'd64) begin
								if (pixelcount == 32'd1057) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
								end else begin
									for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
									state <= STAGE8_TRANSCONV;
									pixelcount <= 32'b0;
									layercount <= 0;
									inlayercount <= 0;
								end
								
							end else begin
								pixelcount <= 32'b0;
								inlayercount <= inlayercount + 32'd32;
							end
							
						end else begin
							if (pixelcount < 33) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin 
								if (layercount >= 32'd32) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd1;
									
									if (inlayercount == 0) begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage7_layer1_1, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage7_layer2_1, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage7_layer3_1, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage7_layer4_1, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage7_layer5_1, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage7_layer6_1, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage7_layer7_1, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage7_layer8_1, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage7_layer9_1, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage7_layer10_1, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage7_layer11_1, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage7_layer12_1, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage7_layer13_1, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage7_layer14_1, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage7_layer15_1, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage7_layer16_1, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage7_layer17_1, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage7_layer18_1, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage7_layer19_1, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage7_layer20_1, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage7_layer21_1, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage7_layer22_1, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage7_layer23_1, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage7_layer24_1, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage7_layer25_1, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage7_layer26_1, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage7_layer27_1, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage7_layer28_1, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage7_layer29_1, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage7_layer30_1, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage7_layer31_1, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage7_layer32_1, 32, 0)	   // filter 31
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end else begin
										case (layercount)
											32'd0:   LOAD_WEIGHTS(stage7_layer1_2, 32, 0)	   // filter 0
											32'd1:   LOAD_WEIGHTS(stage7_layer2_2, 32, 0)	   // filter 1
											32'd2:   LOAD_WEIGHTS(stage7_layer3_2, 32, 0)	   // filter 2
											32'd3:   LOAD_WEIGHTS(stage7_layer4_2, 32, 0)	   // filter 3
											32'd4:   LOAD_WEIGHTS(stage7_layer5_2, 32, 0)	   // filter 4
											32'd5:   LOAD_WEIGHTS(stage7_layer6_2, 32, 0)	   // filter 5
											32'd6:   LOAD_WEIGHTS(stage7_layer7_2, 32, 0)	   // filter 6
											32'd7:   LOAD_WEIGHTS(stage7_layer8_2, 32, 0)	   // filter 7
											32'd8:   LOAD_WEIGHTS(stage7_layer9_2, 32, 0)	   // filter 8
											32'd9:   LOAD_WEIGHTS(stage7_layer10_2, 32, 0)	   // filter 9
											32'd10:  LOAD_WEIGHTS(stage7_layer11_2, 32, 0)	   // filter 10
											32'd11:  LOAD_WEIGHTS(stage7_layer12_2, 32, 0)	   // filter 11
											32'd12:  LOAD_WEIGHTS(stage7_layer13_2, 32, 0)	   // filter 12
											32'd13:  LOAD_WEIGHTS(stage7_layer14_2, 32, 0)	   // filter 13
											32'd14:  LOAD_WEIGHTS(stage7_layer15_2, 32, 0)	   // filter 14
											32'd15:  LOAD_WEIGHTS(stage7_layer16_2, 32, 0)	   // filter 15
											32'd16:  LOAD_WEIGHTS(stage7_layer17_2, 32, 0)	   // filter 16
											32'd17:  LOAD_WEIGHTS(stage7_layer18_2, 32, 0)	   // filter 17
											32'd18:  LOAD_WEIGHTS(stage7_layer19_2, 32, 0)	   // filter 18
											32'd19:  LOAD_WEIGHTS(stage7_layer20_2, 32, 0)	   // filter 19
											32'd20:  LOAD_WEIGHTS(stage7_layer21_2, 32, 0)	   // filter 20
											32'd21:  LOAD_WEIGHTS(stage7_layer22_2, 32, 0)	   // filter 21
											32'd22:  LOAD_WEIGHTS(stage7_layer23_2, 32, 0)	   // filter 22
											32'd23:  LOAD_WEIGHTS(stage7_layer24_2, 32, 0)	   // filter 23
											32'd24:  LOAD_WEIGHTS(stage7_layer25_2, 32, 0)	   // filter 24
											32'd25:  LOAD_WEIGHTS(stage7_layer26_2, 32, 0)	   // filter 25
											32'd26:  LOAD_WEIGHTS(stage7_layer27_2, 32, 0)	   // filter 26
											32'd27:  LOAD_WEIGHTS(stage7_layer28_2, 32, 0)	   // filter 27
											32'd28:  LOAD_WEIGHTS(stage7_layer29_2, 32, 0)	   // filter 28
											32'd29:  LOAD_WEIGHTS(stage7_layer30_2, 32, 0)	   // filter 29
											32'd30:  LOAD_WEIGHTS(stage7_layer31_2, 32, 0)	   // filter 30
											32'd31:  LOAD_WEIGHTS(stage7_layer32_2, 32, 0)	   // filter 31
												
											default:
												begin
													for (int i=0; i<32; i=i+1) begin
														for (int w=1; w<10; w=w+1) begin
															cv_w[i][w]    <= 0;
														end
													end
												end
										endcase
									end
								
							
									for (i=0; i<32; i=i+1) begin
										// filters
										intermediate[i] <= cv_pixelout[i];
									end
									
									// add bias and quantization
									if (inlayercount == 32'd32) begin
										//qt0
										qt0_in   <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
														+ intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
														+ intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
														+ intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
														+ intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
														+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
														+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
														+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31]
														+ intermediatesum[layercount];
										qt0_bias <= bias0;
										qt0_zp   <= zp0;
										qt0_scale <= scale0;
										
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
										
										if (pixelcount >33) begin
											case (layercount-1):
												32'd0:  savebuffer[31:24] <= {qt0_res};
												32'd1:  savebuffer[23:16] <= {qt0_res};
												32'd2:  savebuffer[15:8]  <= {qt0_res};
												32'd3:  layerint_buf0_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd4:  savebuffer[31:24] <= {qt0_res};
												32'd5:  savebuffer[23:16] <= {qt0_res};
												32'd6:  savebuffer[15:8]  <= {qt0_res};
												32'd7:  layerint_buf1_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd8:  savebuffer[31:24] <= {qt0_res};
												32'd9:  savebuffer[23:16] <= {qt0_res};
												32'd10: savebuffer[15:8]  <= {qt0_res};
												32'd11: layerint_buf2_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd12: savebuffer[31:24] <= {qt0_res};
												32'd13: savebuffer[23:16] <= {qt0_res};
												32'd14: savebuffer[15:8]  <= {qt0_res};
												32'd15: layerint_buf3_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd16: savebuffer[31:24] <= {qt0_res};
												32'd17: savebuffer[23:16] <= {qt0_res};
												32'd18: savebuffer[15:8]  <= {qt0_res};
												32'd19: layerint_buf4_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd20: savebuffer[31:24] <= {qt0_res};
												32'd21: savebuffer[23:16] <= {qt0_res};
												32'd22: savebuffer[15:8]  <= {qt0_res};
												32'd23: layerint_buf5_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd24: savebuffer[31:24] <= {qt0_res};
												32'd25: savebuffer[23:16] <= {qt0_res};
												32'd26: savebuffer[15:8]  <= {qt0_res};
												32'd27: layerint_buf6_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd28: savebuffer[31:24] <= {qt0_res};
												32'd29: savebuffer[23:16] <= {qt0_res};
												32'd30: savebuffer[15:8]  <= {qt0_res};
												32'd31: layerint_buf7_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
											endcase
										end
									end else begin
										intermediatesum[layercount] <= intermediate[0] + intermediate[1] + intermediate[2] + intermediate[3]
																				 + intermediate[4] + intermediate[5] + intermediate[6] + intermediate[7]
																				 + intermediate[8] + intermediate[9] + intermediate[10] + intermediate[11]
																				 + intermediate[12] + intermediate[13] + intermediate[14] + intermediate[15]
																				 + intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
																				 + intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
																				 + intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
																				 + intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									end
								end
							end
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
						if (pixelcount >= 32'd4129) begin  // (height*width + (width+1) for padding)
							if (pixelcount == 32'd4129) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE8_CONV;
								pixelcount <= 32'b0;
								layercount <= 0;
								inlayercount <= 0;
							end
							
						end else begin
							if (pixelcount < 33) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin
								if (layercount >= 32'd16) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd1;
									
									case (layercount)
										32'd0:  LOAD_WEIGHTS(stage8_translayer1, 32, 0)	   // filter 0
										32'd1:  LOAD_WEIGHTS(stage8_translayer2, 32, 0)	   // filter 1
										32'd2:  LOAD_WEIGHTS(stage8_translayer3, 32, 0)	   // filter 2
										32'd3:  LOAD_WEIGHTS(stage8_translayer4, 32, 0)	   // filter 3
										32'd4:  LOAD_WEIGHTS(stage8_translayer5, 32, 0)	   // filter 4
										32'd5:  LOAD_WEIGHTS(stage8_translayer6, 32, 0)	   // filter 5
										32'd6:  LOAD_WEIGHTS(stage8_translayer7, 32, 0)	   // filter 6
										32'd7:  LOAD_WEIGHTS(stage8_translayer8, 32, 0)	   // filter 7
										32'd8:  LOAD_WEIGHTS(stage8_translayer9, 32, 0)	   // filter 8
										32'd9:  LOAD_WEIGHTS(stage8_translayer10, 32, 0)	   // filter 9
										32'd10: LOAD_WEIGHTS(stage8_translayer11, 32, 0)	   // filter 10
										32'd11: LOAD_WEIGHTS(stage8_translayer12, 32, 0)	   // filter 11
										32'd12: LOAD_WEIGHTS(stage8_translayer13, 32, 0)	   // filter 12
										32'd13: LOAD_WEIGHTS(stage8_translayer14, 32, 0)	   // filter 13
										32'd14: LOAD_WEIGHTS(stage8_translayer15, 32, 0)	   // filter 14
										32'd15: LOAD_WEIGHTS(stage8_translayer16, 32, 0)	   // filter 15
											
										default:
											begin
												for (int i=0; i<32; i=i+1) begin
													for (int w=1; w<10; w=w+1) begin
														cv_w[i][w]    <= 0;
													end
												end
											end
									endcase

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
									qt0_bias <= bias0;
									qt0_zp   <= zp0;
									qt0_scale <= scale0;
									
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
									
									if (pixelcount > 33) begin
										if (pixelcount < 32'd2048) begin
											case (layercount-1):
												32'd0:  savebuffer[31:24] <= {qt0_res};
												32'd1:  savebuffer[23:16] <= {qt0_res};
												32'd2:  savebuffer[15:8]  <= {qt0_res};
												32'd3:  layerint_buf0_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd4:  savebuffer[31:24] <= {qt0_res};
												32'd5:  savebuffer[23:16] <= {qt0_res};
												32'd6:  savebuffer[15:8]  <= {qt0_res};
												32'd7:  layerint_buf1_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd8:  savebuffer[31:24] <= {qt0_res};
												32'd9:  savebuffer[23:16] <= {qt0_res};
												32'd10: savebuffer[15:8]  <= {qt0_res};
												32'd11: layerint_buf2_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd12: savebuffer[31:24] <= {qt0_res};
												32'd13: savebuffer[23:16] <= {qt0_res};
												32'd14: savebuffer[15:8]  <= {qt0_res};
												32'd15: layerint_buf3_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
											endcase
										end else begin
											case (layercount-1):
												32'd0:  savebuffer[31:24] <= {qt0_res};
												32'd1:  savebuffer[23:16] <= {qt0_res};
												32'd2:  savebuffer[15:8]  <= {qt0_res};
												32'd3:  layerint_buf4_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd4:  savebuffer[31:24] <= {qt0_res};
												32'd5:  savebuffer[23:16] <= {qt0_res};
												32'd6:  savebuffer[15:8]  <= {qt0_res};
												32'd7:  layerint_buf5_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd8:  savebuffer[31:24] <= {qt0_res};
												32'd9:  savebuffer[23:16] <= {qt0_res};
												32'd10: savebuffer[15:8]  <= {qt0_res};
												32'd11: layerint_buf6_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
												32'd12: savebuffer[31:24] <= {qt0_res};
												32'd13: savebuffer[23:16] <= {qt0_res};
												32'd14: savebuffer[15:8]  <= {qt0_res};
												32'd15: layerint_buf7_st3[(pixelcount-34)] <= {savebuffer[31:8], qt0_res};
											endcase
										end
									end
								end
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
						if (pixelcount >= 32'd4161) begin  // (height*width + (width+1) for padding)
							if (pixelcount == 32'd4161) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE9_TRANSCONV;
								pixelcount <= 32'b0;
								layercount <= 0;
								inlayercount <= 0;
							end
							
						end else begin
							if (pixelcount < 65) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin
								if (layercount >= 32'd16) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd1;
									
									case (layercount)
										32'd0:  LOAD_WEIGHTS(stage8_layer1, 32, 0)	   // filter 0
										32'd1:  LOAD_WEIGHTS(stage8_layer2, 32, 0)	   // filter 1
										32'd2:  LOAD_WEIGHTS(stage8_layer3, 32, 0)	   // filter 2
										32'd3:  LOAD_WEIGHTS(stage8_layer4, 32, 0)	   // filter 3
										32'd4:  LOAD_WEIGHTS(stage8_layer5, 32, 0)	   // filter 4
										32'd5:  LOAD_WEIGHTS(stage8_layer6, 32, 0)	   // filter 5
										32'd6:  LOAD_WEIGHTS(stage8_layer7, 32, 0)	   // filter 6
										32'd7:  LOAD_WEIGHTS(stage8_layer8, 32, 0)	   // filter 7
										32'd8:  LOAD_WEIGHTS(stage8_layer9, 32, 0)	   // filter 8
										32'd9:  LOAD_WEIGHTS(stage8_layer10, 32, 0)	   // filter 9
										32'd10: LOAD_WEIGHTS(stage8_layer11, 32, 0)	   // filter 10
										32'd11: LOAD_WEIGHTS(stage8_layer12, 32, 0)	   // filter 11
										32'd12: LOAD_WEIGHTS(stage8_layer13, 32, 0)	   // filter 12
										32'd13: LOAD_WEIGHTS(stage8_layer14, 32, 0)	   // filter 13
										32'd14: LOAD_WEIGHTS(stage8_layer15, 32, 0)	   // filter 14
										32'd15: LOAD_WEIGHTS(stage8_layer16, 32, 0)	   // filter 15
											
										default:
											begin
												for (int i=0; i<32; i=i+1) begin
													for (int w=1; w<10; w=w+1) begin
														cv_w[i][w]    <= 0;
													end
												end
											end
									endcase

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
									qt0_bias <= bias0;
									qt0_zp   <= zp0;
									qt0_scale <= scale0;
									
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
									
									if (pixelcount > 65) begin
										if (pixelcount < 32'd2114) begin
											case (layercount-1):
												32'd0:  savebuffer[31:24] <= {qt0_res};
												32'd1:  savebuffer[23:16] <= {qt0_res};
												32'd2:  savebuffer[15:8]  <= {qt0_res};
												32'd3:  layerint_buf0_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
												32'd4:  savebuffer[31:24] <= {qt0_res};
												32'd5:  savebuffer[23:16] <= {qt0_res};
												32'd6:  savebuffer[15:8]  <= {qt0_res};
												32'd7:  layerint_buf1_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
												32'd8:  savebuffer[31:24] <= {qt0_res};
												32'd9:  savebuffer[23:16] <= {qt0_res};
												32'd10: savebuffer[15:8]  <= {qt0_res};
												32'd11: layerint_buf2_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
												32'd12: savebuffer[31:24] <= {qt0_res};
												32'd13: savebuffer[23:16] <= {qt0_res};
												32'd14: savebuffer[15:8]  <= {qt0_res};
												32'd15: layerint_buf3_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
											endcase
										end else begin
											case (layercount-1):
												32'd0:  savebuffer[31:24] <= {qt0_res};
												32'd1:  savebuffer[23:16] <= {qt0_res};
												32'd2:  savebuffer[15:8]  <= {qt0_res};
												32'd3:  layerint_buf4_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
												32'd4:  savebuffer[31:24] <= {qt0_res};
												32'd5:  savebuffer[23:16] <= {qt0_res};
												32'd6:  savebuffer[15:8]  <= {qt0_res};
												32'd7:  layerint_buf5_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
												32'd8:  savebuffer[31:24] <= {qt0_res};
												32'd9:  savebuffer[23:16] <= {qt0_res};
												32'd10: savebuffer[15:8]  <= {qt0_res};
												32'd11: layerint_buf6_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
												32'd12: savebuffer[31:24] <= {qt0_res};
												32'd13: savebuffer[23:16] <= {qt0_res};
												32'd14: savebuffer[15:8]  <= {qt0_res};
												32'd15: layerint_buf7_st2[(pixelcount-66)] <= {savebuffer[31:8], qt0_res};
											endcase
										end
									end
								end
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
						if (pixelcount >= 32'd16449) begin  // (height*width + (width+1) for padding)
							if (pixelcount == 32'd16449) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE9_CONV;
								pixelcount <= 32'b0;
								layercount <= 0;
								inlayercount <= 0;
							end
							
						end else begin
							if (pixelcount < 65) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin
								if (layercount >= 32'd8) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd2;
									
									case (layercount)
										32'd0:
											begin
												`LOAD_WEIGHTS(stage9_translayer1, 16, 0)	   // filter 0
												`LOAD_WEIGHTS(stage9_translayer2, 16, 16)	// filter 1
											end
											
										32'd2:
											begin
												`LOAD_WEIGHTS(stage9_translayer3, 16, 0)	   // filter 2
												`LOAD_WEIGHTS(stage9_translayer4, 16, 16)	// filter 3
											end
											
										32'd4:
											begin
												`LOAD_WEIGHTS(stage9_translayer5, 16, 0)	   // filter 4
												`LOAD_WEIGHTS(stage9_translayer6, 16, 16)	// filter 5
											end
											
										32'd6:
											begin
												`LOAD_WEIGHTS(stage9_translayer7, 16, 0)	   // filter 6
												`LOAD_WEIGHTS(stage9_translayer8, 16, 16)	// filter 7
											end
											
										default:
											begin
												for (int i=0; i<32; i=i+1) begin
													for (int w=1; w<10; w=w+1) begin
														cv_w[i][w]    <= 0;
													end
												end
											end
									endcase			
				
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
									qt0_bias <= bias0;
									qt0_zp   <= zp0;
									qt0_scale <= scale0;
									
									//qt1
									qt1_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
													+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
													+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
													+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									qt1_bias <= bias0;
									qt1_zp   <= zp0;
									qt1_scale <= scale0;
									
									// save to buffer
									if (pixelcount > 65) begin
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
										
										if (pixelcount < 32'd4226) begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf0_st2[((pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res};  
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf1_st2[((pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res};
											endcase
										end else if (pixelcount < 32'd8322) begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf2_st2[((pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf3_st2[((pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
											endcase
										end else if (pixelcount < 32'd12418) begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf4_st2[((pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res};   
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf5_st2[((pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
											endcase
										end else begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf6_st2[((pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res};  
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf7_st2[((pixelcount-66)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
											endcase
										end
									end			
								end
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
						if (pixelcount >= 32'd16513) begin  // (height*width + (width+1) for padding)
							if (pixelcount == 32'd16513) begin
								pixelcount <= pixelcount + 1;
								for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
							end else begin
								for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
								state <= STAGE10_CONV;
								pixelcount <= 32'b0;
								layercount <= 0;
								inlayercount <= 0;
							end
							
						end else begin
							if (pixelcount < 129) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin
								if (layercount >= 32'd8) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd2;
									
									case (layercount)
										32'd0:
											begin
												`LOAD_WEIGHTS(stage9_layer1, 16, 0)	   // filter 0
												`LOAD_WEIGHTS(stage9_layer2, 16, 16)	// filter 1
											end
											
										32'd2:
											begin
												`LOAD_WEIGHTS(stage9_layer3, 16, 0)	   // filter 2
												`LOAD_WEIGHTS(stage9_layer4, 16, 16)	// filter 3
											end
											
										32'd4:
											begin
												`LOAD_WEIGHTS(stage9_layer5, 16, 0)	   // filter 4
												`LOAD_WEIGHTS(stage9_layer6, 16, 16)	// filter 5
											end
											
										32'd6:
											begin
												`LOAD_WEIGHTS(stage9_layer7, 16, 0)	   // filter 6
												`LOAD_WEIGHTS(stage9_layer8, 16, 16)	// filter 7
											end
											
										default:
											begin
												for (int i=0; i<32; i=i+1) begin
													for (int w=1; w<10; w=w+1) begin
														cv_w[i][w]    <= 0;
													end
												end
											end
									endcase			
				
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
									qt0_bias <= bias0;
									qt0_zp   <= zp0;
									qt0_scale <= scale0;
									
									//qt1
									qt1_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
													+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
													+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
													+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									qt1_bias <= bias0;
									qt1_zp   <= zp0;
									qt1_scale <= scale0;
									
									// save to buffer
									if (pixelcount > 129) begin
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
										
										
										if (pixelcount < 32'd4226) begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf0_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};   
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf1_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
											endcase
										end else if (pixelcount < 32'd8322) begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf2_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf3_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
											endcase
										end else if (pixelcount < 32'd12418) begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf4_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf5_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
											endcase
										end else begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf6_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf7_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
											endcase
										end
									end			
								end
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
						begin
						if (pixelcount >= 32'd16513) begin  // (height*width + (width+1) for padding)
							state <= SEND;
							pixelcount <= 32'b0;
							layercount <= 0;
							
						end else begin
							if (pixelcount < 129) begin  // ( width+2 for the padding )
								pixelcount <= pixelcount+1;
								
							end else begin
								if (layercount >= 32'd16) begin
									layercount <= 0;
									pixelcount <= pixelcount + 1;
								
								end else begin
									layercount <= layercount + 32'd2;
									
									case (layercount)
										32'd0:
											begin
												`LOAD_WEIGHTS(stage10_layer1, 16, 0)	   // filter 0
												`LOAD_WEIGHTS(stage10_layer2, 16, 16)	// filter 1
											end
											
										32'd2:
											begin
												`LOAD_WEIGHTS(stage10_layer3, 16, 0)	   // filter 2
												`LOAD_WEIGHTS(stage10_layer4, 16, 16)	// filter 3
											end
											
										32'd4:
											begin
												`LOAD_WEIGHTS(stage10_layer5, 16, 0)	   // filter 4
												`LOAD_WEIGHTS(stage10_layer6, 16, 16)	// filter 5
											end
											
										32'd6:
											begin
												`LOAD_WEIGHTS(stage10_layer7, 16, 0)	   // filter 6
												`LOAD_WEIGHTS(stage10_layer8, 16, 16)	// filter 7
											end
											
										32'd8:
											begin
												`LOAD_WEIGHTS(stage10_layer9, 16, 0)	   // filter 8
												`LOAD_WEIGHTS(stage10_layer10, 16, 16)	// filter 9
											end
											
										32'd10:
											begin
												`LOAD_WEIGHTS(stage10_layer11, 16, 0)	   // filter 10
												`LOAD_WEIGHTS(stage10_layer12, 16, 16)	// filter 11
											end
										
										32'd12:
											begin
												`LOAD_WEIGHTS(stage10_layer13, 16, 0)	   // filter 12
												`LOAD_WEIGHTS(stage10_layer14, 16, 16)	// filter 13
											end
										
										32'd14:
											begin
												`LOAD_WEIGHTS(stage10_layer15, 16, 0)	   // filter 14
												`LOAD_WEIGHTS(stage10_layer16, 16, 16)	// filter 15
											end
											
										default:
											begin
												for (int i=0; i<32; i=i+1) begin
													for (int w=1; w<10; w=w+1) begin
														cv_w[i][w]    <= 0;
													end
												end
											end
									endcase			
				
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
									qt0_bias <= bias0;
									qt0_zp   <= zp0;
									qt0_scale <= scale0;
									
									//qt1
									qt1_in   <= intermediate[16] + intermediate[17] + intermediate[18] + intermediate[19]
													+ intermediate[20] + intermediate[21] + intermediate[22] + intermediate[23]
													+ intermediate[24] + intermediate[25] + intermediate[26] + intermediate[27]
													+ intermediate[28] + intermediate[29] + intermediate[30] + intermediate[31];
									qt1_bias <= bias0;
									qt1_zp   <= zp0;
									qt1_scale <= scale0;
									
									// save to buffer
									if (pixelcount > 129) begin
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
										
										
										if (pixelcount < 32'd8192) begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf0_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res}; 
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf1_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
												32'd8:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd10: layerint_buf2_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
												32'd12: savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd14: layerint_buf3_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
											endcase
										end else begin
											case (layercount-2)
												32'd0:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd2:  layerint_buf4_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
												32'd4:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd6:  layerint_buf5_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
												32'd8:  savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd10: layerint_buf6_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
												32'd12: savebuffer[31:16] <= {qt0_res, qt1_res};
												32'd14: layerint_buf7_st1[((pixelcount-130)] <= {savebuffer[31:16], qt0_res, qt1_res};
											endcase
										end
									end			
								end
							end
						end
					end
					
				SEND:
					ctrl <= DATA_READY;
					if (~unet_enpulse) begin
						if (pixelcount >= 32'd16513) begin  // (height*width + (width+1) for padding)
							if (inlayercount >= 32'd16) begin
								if (pixelcount == 32'd16513) begin
									pixelcount <= pixelcount + 1;
									for (l=0; l<32; l=l+1) cv_rst[l] <= 0;
								end else begin
									for (l=0; l<32; l=l+1) cv_rst[l] <= 1;
									state <= IDLE;
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
					
				default: stage <= idle;
			endcase
		end
	end
	
	reg [7:0] buffer0 [11:0];
	
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
							buffer0[0] <= datain[7:0];
							buffer0[1] <= datain[15:8];
							buffer0[2] <= datain[23:16];
							buffer0[3] <= datain[31:24];
						end else if (loadcounter == 1) begin
							buffer0[4] <= datain[7:0];
							buffer0[5] <= datain[15:8];
							buffer0[6] <= datain[23:16];
							buffer0[7] <= datain[31:24];
						end else if (loadcounter == 2) begin
							buffer0[8] <= datain[7:0];
							buffer0[9] <= datain[15:8];
							buffer0[10] <= datain[23:16];
							buffer0[11] <= datain[31:24];
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
						cv_width[a] <= 7'd128;
					end
					
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
				
			STAGE3_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd32;
					end
					
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
			
			STAGE4_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd16;
					end
					
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
							cv_pixelin[b]    <= layerint_buf0_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf1_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf2_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf3_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+16] <= layerint_buf4_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf5_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf6_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf7_st1[pixelcount][31-(b*8) -:8];
						end
					end else begin
						for (b=0; b<4; b=b+1) begin
							cv_pixelin[b]    <= layerint_buf8_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+4]  <= layerint_buf9_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+8]  <= layerint_buf10_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+12] <= layerint_buf11_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+16] <= layerint_buf12_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+20] <= layerint_buf13_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+24] <= layerint_buf14_st1[pixelcount][31-(b*8) -:8];
							cv_pixelin[b+28] <= layerint_buf15_st1[pixelcount][31-(b*8) -:8];
						end
					end
				end
			
			STAGE5_CONV:
				begin
					for (a=0; a<32; a=a+1) begin
						cv_op[a] <= CONV;
						cv_width[a] <= 7'd8;
					end
					
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
					
					if (inlayerscount == 0) begin
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
					
					if (inlayerscount == 0) begin
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
						cv_width[a] <= 7'd128;
					end
					
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
						cv_width[a] <= 7'd128;
					end
					
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
						32'd0: dataout <= layerint_buf0_st1[pixelcount];
						32'd0: dataout <= layerint_buf1_st1[pixelcount];
						32'd0: dataout <= layerint_buf2_st1[pixelcount];
						32'd0: dataout <= layerint_buf3_st1[pixelcount];
						32'd0: dataout <= layerint_buf4_st1[pixelcount];
						32'd0: dataout <= layerint_buf5_st1[pixelcount];
						32'd0: dataout <= layerint_buf6_st1[pixelcount];
						32'd0: dataout <= layerint_buf7_st1[pixelcount];
						default: dataout <= 0;
					endcase
				end
				
			default:
				dataout <= 0;
	end
endmodule 