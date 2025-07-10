`timescale 1ns/1ps

module tb_transconv_3_1;
	parameter im_WIDTH = 128;
	parameter im_HEIGHT = im_WIDTH;
	
	reg clk, rst_n, tr_rst, tr_rw, tr_hop, tr_flip, rw, rw2;
	reg  signed [7:0] pixelin;
	wire signed [19:0] tr_out;
	
	reg signed [7:0] w9, w8, w7, w6, w5, w4, w3, w2, w1, bias;
	
	transconv #(.IMAGE_WIDTH(8), .IMAGE_HEIGHT(8)) trans0 (
		.in(pixelin),
		.w9(w9), .w8(w8), .w7(w7), 
		.w6(w6), .w5(w5), .w4(w4), 
		.w3(w3), .w2(w2), .w1(w1),
		.bias(bias),
		.width(8),
		.flip(tr_flip),
		.clk(clk),
		.rst(rst_n && tr_rst),
		.rw(tr_rw),
		.hop(tr_hop),
		.pixel(tr_out)
	);
	
	
	reg signed [7:0] im [0:3][0:3];
	reg signed [19:0] out [0:7][0:7];
	reg signed [19:0] save;
	
	
	// assigning weights, pixels, biases
	initial begin
		w1 <= 39; w2 <= 11; w3 <= -3;
		w4 <= 81; w5 <= 0;  w6 <= 0;
		w7 <= 1;  w8 <= 1;  w9 <= 0;
		
		bias <= 0;
		
		im[0][0] <= 14;   im[0][1] <= 1;   im[0][2] <= 0;   im[0][3] <= 100;
		im[1][0] <= 0;    im[1][1] <= -1;  im[1][2] <= 0;   im[1][3] <= -100;
		im[2][0] <= 0;    im[2][1] <= 0;   im[2][2] <= 0;   im[2][3] <= 0;
		im[3][0] <= 1;    im[3][1] <= 2;   im[3][2] <= 0;   im[3][3] <= 1;
		
		out[0][0] <= 546;  out[0][1] <= 154;   out[0][2] <= -3;   out[0][3] <= 11;   out[0][4] <= -3;   out[0][5] <= 0;   out[0][6] <= 3900;   out[0][7] <= 1100;   		
		out[1][0] <= 1134; out[1][1] <= 0;     out[1][2] <= 81;   out[1][3] <= 0;    out[1][4] <= 0;    out[1][5] <= 0;   out[1][6] <= 8100;   out[1][7] <= 0;      		
		out[2][0] <= 14;   out[2][1] <= 14;    out[2][2] <= -38;  out[2][3] <= -10;  out[2][4] <= 3;    out[2][5] <= 0;   out[2][6] <= -3800;  out[2][7] <= -1000;  		
		out[3][0] <= 0;    out[3][1] <= 0;     out[3][2] <= -81;  out[3][3] <= 0;    out[3][4] <= 0;    out[3][5] <= 0;   out[3][6] <= -8100;  out[3][7] <= 0;      		
		out[4][0] <= 0;    out[4][1] <= 0;     out[4][2] <= -1;   out[4][3] <= -1;   out[4][4] <= 0;    out[4][5] <= 0;   out[4][6] <= -100;   out[4][7] <= -100;   		
		out[5][0] <= 0;    out[5][1] <= 0;     out[5][2] <= 0;    out[5][3] <= 0;    out[5][4] <= 0;    out[5][5] <= 0;   out[5][6] <= 0;      out[5][7] <= 0;      		
		out[6][0] <= 39;   out[6][1] <= 11;    out[6][2] <= 75;   out[6][3] <= 22;   out[6][4] <= -6;   out[6][5] <= 0;   out[6][6] <= 39;     out[6][7] <= 11;      		
		out[7][0] <= 81;   out[7][1] <= 0;     out[7][2] <= 162;  out[7][3] <= 0;    out[7][4] <= 0;    out[7][5] <= 0;   out[7][6] <= 81;     out[7][7] <= 0;      		
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
	reg [7:0] pixelcount, writepixel;
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			finish <= 0;
			pixelcount <= 0;
			writepixel <= 0;
			tr_hop <= 1;
			tr_rw <= 1;
			tr_flip <= 0;
			rw <= 1;
			
		end else begin
			if (rw) begin
				tr_hop <= 1;
				pixelcount <= pixelcount + 1;
				if (pixelcount % 4 == 3) tr_rw <= 0;
				if (pixelcount % 4 == 3) rw <= 0;
				
			end else begin
				if (writepixel % 16 == 15) begin
					if (writepixel != 63) tr_rw <= 1;
					if (writepixel != 63) rw <= 1;
					tr_flip <= ~tr_flip;
					
					if (writepixel == 63) begin
						tr_rst <= 0;
						writepixel <= writepixel + 16;
						
						pixelcount <= 0;
						
					end else if (writepixel == 79) begin
						tr_rst <= 1;
						finish <= 1;
						writepixel <= 0;
						tr_rw <= 1;
						rw <= 1;
						
					end else begin
						writepixel <= writepixel + 1;
					
					end
				end else begin
					writepixel <= writepixel + 1;
					
				end
				
				save <= tr_out;
			end

			rw2 <= rw;
			
			if (finish && rw2) $stop;
		end
	end
	
	reg waiting;
	
	always @(posedge clk) begin
		if (~finish) begin
			if (~rw2) begin
				if (out[(writepixel-1) >> 3][(writepixel-1) & 3'b111] == tr_out)
					$display("%2d : Correct %d", (writepixel-1), tr_out);
				else
					$display("%2d : ERROR - expected %d  got %d", (writepixel-1), out[(writepixel-1) >> 3][(writepixel-1) & 3'b111], tr_out);
			end else begin
				$display("...");
			end
		end 
	end
	
	always@(*) begin
		pixelin <= im[pixelcount >> 2][pixelcount & 2'b11];
	end
	
endmodule 