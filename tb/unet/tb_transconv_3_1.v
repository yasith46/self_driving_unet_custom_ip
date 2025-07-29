`timescale 1ns/1ps

module tb_transconv_3_1;
	parameter im_WIDTH = 128;
	parameter im_HEIGHT = im_WIDTH;
	
	reg clk, rst_n, tr_rst, tr_hop, tr_flip, rw, rw2;
	reg  signed [7:0] pixelin, intm;
	wire signed [19:0] tr_out;
	
	reg signed [7:0] w9, w8, w7, w6, w5, w4, w3, w2, w1, bias;
	
	transconv #(.IMAGE_WIDTH(8), .IMAGE_HEIGHT(8)) trans0 (
		.in(intm),
		.w9(w9), .w8(w8), .w7(w7), 
		.w6(w6), .w5(w5), .w4(w4), 
		.w3(w3), .w2(w2), .w1(w1),
		.bias(bias),
		.width(8),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && tr_rst),
		.rw(rw2),
		.hop(tr_hop),
		.pixel(tr_out)
	);
	
	
	reg signed [7:0] im [0:138];
	reg signed [31:0] out [0:63];
	reg signed [31:0] save [0:68];
	reg signed [31:0] save2 [0:68];
	
	
	// assigning weights, pixels, biases
	initial begin
		im[0] <= 8'sd0;
		im[1] <= 8'sd14;   im[2] <= 8'sd14;   im[3] <= 8'sd14;   im[4] <= 8'sd14;
		im[5] <= 8'sd1;    im[6] <= 8'sd1;    im[7] <= 8'sd1;    im[8] <= 8'sd1;
		im[9] <= 8'sd0;    im[10] <= 8'sd0;   im[11] <= 8'sd0;   im[12] <= 8'sd0;   
		im[13] <= 8'sd100; im[14] <= 8'sd100; im[15] <= 8'sd100; im[16] <= 8'sd100;
		
		im[17] <= 8'sd0;  im[18] <= 8'sd1;  im[19] <= 8'sd2;   im[20] <= 8'sd3;   im[21] <= 8'sd4;   im[22] <= 8'sd5;   im[23] <= 8'sd6;   im[24] <= 8'sd7;
		im[25] <= 8'sd8;  im[26] <= 8'sd9;  im[27] <= 8'sd10;  im[28] <= 8'sd11;  im[29] <= 8'sd12;  im[30] <= 8'sd13;  im[31] <= 8'sd14;  im[32] <= 8'sd15;
		im[33] <= 8'sd16;
		
		im[34] <= 8'sd0;    im[35] <= 8'sd0;    im[36] <= 8'sd0;    im[37] <= 8'sd0;
		im[38] <= -8'sd1;   im[39] <= -8'sd1;   im[40] <= -8'sd1;   im[41] <= -8'sd1;
		im[42] <= 8'sd0;    im[43] <= 8'sd0;    im[44] <= 8'sd0;    im[45] <= 8'sd0;
		im[46] <= -8'sd100; im[47] <= -8'sd100; im[48] <= -8'sd100; im[49] <= -8'sd100;
		
		im[50] <= 8'sd16; im[51] <= 8'sd17; im[52] <= 8'sd18;  im[53] <= 8'sd19;  im[54] <= 8'sd20;  im[55] <= 8'sd21;  im[56] <= 8'sd22;  im[57] <= 8'sd23;
		im[58] <= 8'sd24; im[59] <= 8'sd25; im[60] <= 8'sd26;  im[61] <= 8'sd27;  im[62] <= 8'sd28;  im[63] <= 8'sd29;  im[64] <= 8'sd30;  im[65] <= 8'sd31;
		im[66] <= 8'sd32;
		
		im[67] <= 8'sd0;    im[68] <= 8'sd0;    im[69] <= 8'sd0;    im[70] <= 8'sd0;
		im[71] <= 8'sd0;    im[72] <= 8'sd0;    im[73] <= 8'sd0;    im[74] <= 8'sd0;
		im[75] <= 8'sd0;    im[76] <= 8'sd0;    im[77] <= 8'sd0;    im[78] <= 8'sd0;
		im[79] <= 8'sd0;    im[80] <= 8'sd0;    im[81] <= 8'sd0;    im[82] <= 8'sd0;
		
		im[83] <= 8'sd32; im[84] <= 8'sd33; im[85] <= 8'sd34;  im[86] <= 8'sd35;  im[87] <= 8'sd36;  im[88] <= 8'sd37;  im[89] <= 8'sd38;  im[90] <= 8'sd39;
		im[91] <= 8'sd40; im[92] <= 8'sd41; im[93] <= 8'sd42;  im[94] <= 8'sd43;  im[95] <= 8'sd44;  im[96] <= 8'sd45;  im[97] <= 8'sd46;  im[98] <= 8'sd47;
		im[99] <= 8'sd48;
		
		im[100] <= 8'sd1;   im[101] <= 8'sd1;  im[102] <= 8'sd1;  im[103] <= 8'sd1;
		im[104] <= 8'sd2;   im[105] <= 8'sd2;  im[106] <= 8'sd2;  im[107] <= 8'sd2;  
		im[108] <= 8'sd0;   im[109] <= 8'sd0;  im[110] <= 8'sd0;  im[111] <= 8'sd0;
		im[112] <= 8'sd1;   im[113] <= 8'sd1;  im[114] <= 8'sd1;  im[115] <= 8'sd1;
		
		im[116] <= 8'sd48; im[117] <= 8'sd49; im[118] <= 8'sd50;  im[119] <= 8'sd51;  im[120] <= 8'sd52;  im[121] <= 8'sd53;  im[122] <= 8'sd54;  im[123] <= 8'sd55;
		im[124] <= 8'sd56; im[125] <= 8'sd57; im[126] <= 8'sd58;  im[127] <= 8'sd59;  im[128] <= 8'sd60;  im[129] <= 8'sd61;  im[130] <= 8'sd62;  im[131] <= 8'sd63;
		im[132] <= 8'sd63;
		
		
		out[0] <= 32'sd13;    out[1] <= 32'sd27;     out[2] <= 32'sd14;    out[3] <= 32'sd1;    out[4] <= 32'sd0;      out[5] <= -32'sd1;    out[6] <= 32'sd99;    out[7] <= 32'sd199;   		
		out[8] <= -32'sd1;    out[9] <= 32'sd559;    out[10] <= -32'sd1;   out[11] <= 32'sd39;  out[12] <= -32'sd1;    out[13] <= -32'sd1;   out[14] <= -32'sd1;   out[15] <= 32'sd3999;      		
		out[16] <= 32'sd13;   out[17] <= 32'sd41;    out[18] <= 32'sd13;   out[19] <= 32'sd0;   out[20] <= -32'sd1;    out[21] <= -32'sd1;   out[22] <= -32'sd1;   out[23] <= 32'sd99;  		
		out[24] <= -32'sd1;   out[25] <= -32'sd1;    out[26] <= -32'sd1;   out[27] <= -32'sd41; out[28] <= -32'sd1;    out[29] <= -32'sd1;   out[30] <= -32'sd1;   out[31] <= -32'sd4001;      		
		out[32] <= -32'sd1;   out[33] <= -32'sd1;    out[34] <= -32'sd2;   out[35] <= -32'sd4;  out[36] <= -32'sd2;    out[37] <= -32'sd1;   out[38] <= -32'sd101; out[39] <= -32'sd301;   		
		out[40] <= -32'sd1;   out[41] <= -32'sd1;    out[42] <= -32'sd1;   out[43] <= -32'sd1;  out[44] <= -32'sd1;    out[45] <= -32'sd1;   out[46] <= -32'sd1;   out[47] <= -32'sd1;      		
		out[48] <= 32'sd0;    out[49] <= 32'sd1;     out[50] <= 32'sd2;    out[51] <= 32'sd3;   out[52] <= 32'sd1;     out[53] <= -32'sd1;   out[54] <= 32'sd0;    out[55] <= 32'sd1;      		
		out[56] <= -32'sd1;   out[57] <= 32'sd39;    out[58] <= -32'sd1;   out[59] <= 32'sd79;  out[60] <= -32'sd1;    out[61] <= -32'sd1;   out[62] <= -32'sd1;   out[63] <= 32'sd39;      		
	end
	
	initial begin
		rst_n <= 1;
		#10;
		$display("Starting testbench");
		
		rst_n <= 0;
		#4;
		rst_n <= 1;
	end
	
	initial clk = 0;
	always #5 clk = ~clk;
	
	reg finish;
	reg [7:0] pixelcount, ind_pixelcount, writepixel, inlayercount, oldwritepixel;
	reg [7:0] counter1;
	
	always@(posedge clk or negedge rst_n) begin
		
		if (~rst_n) begin
			intm <= 0;
			finish <= 0;
			pixelcount <= 0;
			ind_pixelcount <= 0;
			writepixel <= 0;
			oldwritepixel <= 0;
			tr_hop <= 0;
			tr_flip <= 0;
			rw <= 1;
			rw2 <= 1;
			inlayercount <= 8'b1111_1111;
			counter1 <= 0;
			
			w1 <= 8'sd0;  w2 <= 8'sd0;   w3 <= 8'sd0;
			w4 <= 8'sd0;  w5 <= 8'sd0;   w6 <= 8'sd0;
			w7 <= 8'sd0;  w8 <= 8'sd0;   w9 <= 8'sd0;
			
			bias <= 8'sd0;
			
		end else begin
			if (~finish) begin
				intm <= im[ind_pixelcount];
				ind_pixelcount <= ind_pixelcount + 1;
				
				if (rw2) begin
					if (inlayercount == 3) begin
						pixelcount <= pixelcount + 1;
						tr_hop <= 1;
						if (pixelcount % 4 == 3) rw <= 0;
						inlayercount <= 0;
					end else begin
						tr_hop <= 0;
						inlayercount <= inlayercount + 1;
					end
					
					case (inlayercount)
						1:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd1;   w3 <= 8'sd0;
								w4 <= -8'sd1; w5 <= 8'sd39;  w6 <= -8'sd1;
								w7 <= 8'sd0;  w8 <= 8'sd2;   w9 <= 8'sd0;
								
								
							end
						2:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd1;   w3 <= 8'sd0;
								w4 <= 8'sd0;  w5 <= 8'sd0;   w6 <= 8'sd0;
								w7 <= 8'sd0;  w8 <= 8'sd1;   w9 <= 8'sd0;
							end
						3:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd0;   w3 <= 8'sd0;
								w4 <= 8'sd1;  w5 <= 8'sd0;   w6 <= 8'sd1;
								w7 <= 8'sd0;  w8 <= 8'sd0;   w9 <= 8'sd0;
							end
						0:
							begin
								w1 <= 8'sd1;  w2 <= 8'sd0;   w3 <= 8'sd1;
								w4 <= 8'sd0;  w5 <= 8'sd1;   w6 <= 8'sd0;
								w7 <= 8'sd1;  w8 <= 8'sd0;   w9 <= 8'sd1;
								
							end
						default:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd0;   w3 <= 8'sd0;
								w4 <= 8'sd0;  w5 <= 8'sd0;   w6 <= 8'sd0;
								w7 <= 8'sd0;  w8 <= 8'sd0;   w9 <= 8'sd0;
							end
					endcase
					
					bias <= -8'sd1;
					
				
					
				end else begin
					if (writepixel % 16 == 15) begin
						if (writepixel != 63) begin
							rw <= 1;
						end
						tr_flip <= ~tr_flip;
						writepixel <= writepixel + 1;
						
					end else begin
						if (writepixel == 64) begin
							tr_rst <= 0;
							writepixel <= writepixel + 16;
							pixelcount <= 0;
							
						end else if (writepixel == 80) begin
							tr_rst <= 1;
							finish <= 1;
							writepixel <= 0;
							rw <= 1;
							
						end else begin
							if (~rw) writepixel <= writepixel + 1;
						
						end
					end
					
					if (writepixel < 65 && writepixel > 0 && oldwritepixel != writepixel) save[writepixel-1] <= tr_out;
					save2[writepixel] <= intm;
				end
				
				rw2 <= rw;
				oldwritepixel <= writepixel;
			end
		end
	end
	
	reg waiting;
	
	reg [7:0] counter;
	initial counter <= 8'd0;
	
	always @(posedge clk) begin
		if (~rst_n) begin
			counter <= 8'd0;
		end else begin
			if (finish) begin
				if (counter == 8'd63) begin
					$display("Finished");
					$stop;
				end
					
				counter <= counter + 8'd1;
				
				if (save[counter] == out[counter])
					$display("%2d : Correct %5d", counter, out[counter]);
				else
					$display("%2d : ERROR got %5d expected", counter, save[counter], out[counter]);
			end
		end
	end
	
endmodule 