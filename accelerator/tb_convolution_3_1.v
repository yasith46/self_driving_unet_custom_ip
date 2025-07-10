`timescale 1ns/1ps

module tb_convolution_3_1;
	parameter CONV = 2'd0;
	
	
	parameter IMAGE_WIDTH = 4;
	parameter IMAGE_HEIGHT = IMAGE_WIDTH;
	
	reg clk, cv_clk, cv_rst, rst_n, cv_paddingL ,cv_paddingR, relu;
	reg  signed [7:0] pixelin;
	wire signed [31:0] conv_out;
	
	reg signed [7:0]  w9, w8, w7, w6, w5, w4, w3, w2, w1;
	reg signed [31:0] bias;
	
	reg [1:0] cv_op;	
	
	
	
	convolutor3x3 #(.IMAGE_WIDTH(128), .IMAGE_HEIGHT(128)) conv6 (
		.pixel_in(pixelin),
		.w9(w9), .w8(w8), .w7(w7), 
		.w6(w6), .w5(w5), .w4(w4), 
		.w3(w3), .w2(w2), .w1(w1),
		.clk(cv_clk), 
		.rst_n(rst_n && cv_rst),
		.paddingl(cv_paddingL),
		.paddingr(cv_paddingR),
		.pixel_out(conv_out),
		.bias(bias),
		.operation(cv_op),
		.width(8'd4),
		.relu(relu)
	);
	
	
	
	reg signed [7:0] im [0:15];
	reg signed [31:0] out1 [0:15];
	reg signed [31:0] out2 [0:15];
	reg signed [31:0] out3 [0:15];
	reg signed [31:0] out4 [0:15];
	
	
	// assigning weights, pixels, biases
	initial begin
		im[0]  <= 8'sd14;   im[1]  <= 8'sd1;   im[2]  <= 8'sd0;   im[3]  <= 8'sd100;
		im[4]  <= 8'sd0;    im[5]  <= -8'sd1;  im[6]  <= 8'sd0;   im[7]  <= -8'sd100;
		im[8]  <= 8'sd0;    im[9]  <= 8'sd0;   im[10] <= 8'sd0;   im[11] <= 8'sd0;
		im[12] <= 8'sd1;    im[13] <= 8'sd2;   im[14] <= 8'sd0;   im[15] <= 8'sd1;
		
		out1[0]  <= 32'sd544;  out1[1]  <= 32'sd22;    out1[2]  <= 32'sd0;    out1[3]  <= 32'sd3699;   
		out1[4]  <= 32'sd14;   out1[5]  <= 32'sd0;     out1[6]  <= 32'sd100;  out1[7]  <= 32'sd0;    
		out1[8]  <= 32'sd1;    out1[9]  <= 32'sd2;     out1[10] <= 32'sd0;    out1[11] <= 32'sd0;  
		out1[12] <= 32'sd36;   out1[13] <= 32'sd76;    out1[14] <= 32'sd0;    out1[15] <= 32'sd38;    
		
		out2[0]  <= 32'sd0;    out2[1]  <= 32'sd0;     out2[2]  <= 32'sd0;    out2[3]  <= 32'sd0;   
		out2[4]  <= 32'sd16;   out2[5]  <= 32'sd2;     out2[6]  <= 32'sd102;  out2[7]  <= 32'sd101;    
		out2[8]  <= 32'sd2;    out2[9]  <= 32'sd2;     out2[10] <= 32'sd1;    out2[11] <= 32'sd0;  
		out2[12] <= 32'sd0;    out2[13] <= 32'sd0;     out2[14] <= 32'sd0;    out2[15] <= 32'sd1;  
		
		out3[0]  <= 32'sd1;    out3[1]  <= 32'sd0;     out3[2]  <= 32'sd1;    out3[3]  <= 32'sd0;   
		out3[4]  <= 32'sd15;   out3[5]  <= 32'sd2;     out3[6]  <= 32'sd1;    out3[7]  <= 32'sd101;    
		out3[8]  <= 32'sd2;    out3[9]  <= 32'sd2;     out3[10] <= 32'sd1;    out3[11] <= 32'sd0;  
		out3[12] <= 32'sd1;    out3[13] <= 32'sd1;     out3[14] <= 32'sd1;    out3[15] <= 32'sd1;  
		
		out4[0]  <= 32'sd0;    out4[1]  <= 32'sd0;     out4[2]  <= 32'sd0;    out4[3]  <= 32'sd1;   
		out4[4]  <= 32'sd2;    out4[5]  <= 32'sd1;     out4[6]  <= 32'sd102;  out4[7]  <= 32'sd1;    
		out4[8]  <= 32'sd1;    out4[9]  <= 32'sd1;     out4[10] <= 32'sd1;    out4[11] <= 32'sd1;  
		out4[12] <= 32'sd0;    out4[13] <= 32'sd0;     out4[14] <= 32'sd0;    out4[15] <= 32'sd1;  
	end
	
	initial begin
		rst_n <= 1'b1;
		#10;
		$display("Starting testbench");
		
		rst_n <= 1'b0;
		#7;
		rst_n <= 1'b1;
	end
	
	initial clk = 1'b0;
	always #5 clk = ~clk;
	
	
	
	reg [7:0] pixelcount, raddr, layercount;
	reg finish;
	reg signed [31:0] intermediate_dummyreg;
	reg signed [31:0] layerint_buf_dummyreg1 [0:15];
	reg signed [31:0] layerint_buf_dummyreg2 [0:15];
	reg signed [31:0] layerint_buf_dummyreg3 [0:15];
	reg signed [31:0] layerint_buf_dummyreg4 [0:15];
	
	
	always@(*) begin
		case (layercount)
			0: cv_clk <= 1;
			1: cv_clk <= 1;
			2: cv_clk <= 0;
			default: cv_clk <= 0;
		endcase
	end
	
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			finish <= 1'b0;
			pixelcount <= 8'd0;
			layercount <= 0;
			pixelin <= 0;
			raddr <= 0;
			
		end else begin
			// 1 (4x4) Layers ---> 1 (4x4) Layers
			
			
			raddr <= pixelcount;
			
			
			
			if (pixelcount <16)
				if ((pixelcount == 0) && (layercount < 3))
					pixelin <= 0;
				else
					pixelin <= im[raddr];
			else
				pixelin <= 0;
				
				
			
			if (pixelcount >= 8'd23) begin  // (height*width + (width) for padding + 3 for storing)
				
				cv_rst <= 1'b1;
				finish <= 1'b1;
				pixelcount <= 8'd0;
				layercount <= 0;
				
			end else begin
				// filling weights
				
				if (pixelcount >= 7'd5) begin  // ( width+1 for the padding )
					if (pixelcount == 8'd22) begin
						pixelcount <= pixelcount + 1'b1;
						cv_rst <= 1'b0;	 // Reset	
					end else if (layercount == 32'd3) begin
						layercount <= 0;
						pixelcount <= pixelcount + 1'b1;
					end else begin
						layercount <= layercount + 1;
					end
					
					case (layercount)
						3:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd1;  w3 <= 8'sd0;
								w4 <= -8'sd1; w5 <= 8'sd39; w6 <= -8'sd1;
								w7 <= 8'sd0;  w8 <= 8'sd2;  w9 <= 8'sd0;
								
								bias <= -32'sd1;
							end
						0:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd1;  w3 <= 8'sd0;
								w4 <= -8'sd1; w5 <= 8'sd0;  w6 <= -8'sd1;
								w7 <= 8'sd0;  w8 <= 8'sd1;  w9 <= 8'sd0;
								
								bias <= 32'sd1;
							end
						1:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd1;  w3 <= 8'sd0;
								w4 <= 8'sd0;  w5 <= 8'sd0;  w6 <= 8'sd0;
								w7 <= 8'sd0;  w8 <= 8'sd1;  w9 <= 8'sd0;
								
								bias <= 32'sd1;
							end
						2:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd0;  w3 <= 8'sd0;
								w4 <= -8'sd1; w5 <= 8'sd0;  w6 <= -8'sd1;
								w7 <= 8'sd0;  w8 <= 8'sd0;  w9 <= 8'sd0;
								
								bias <= 32'sd1;
							end
						default:
							begin
								w1 <= 8'sd0;  w2 <= 8'sd0;  w3 <= 8'sd0;
								w4 <= 8'sd0;  w5 <= 8'sd0;  w6 <= 8'sd0;
								w7 <= 8'sd0;  w8 <= 8'sd0;  w9 <= 8'sd0;
								
								bias <= 32'sd0;
							end
					endcase
					
					
					intermediate_dummyreg <= conv_out;
					
					// add bias and quantization
					
					// save image to buffer
					case (layercount)
						1: layerint_buf_dummyreg1[pixelcount-6] <= intermediate_dummyreg;
						2: layerint_buf_dummyreg2[pixelcount-6] <= intermediate_dummyreg;
						3: layerint_buf_dummyreg3[pixelcount-6] <= intermediate_dummyreg;
						0: if (pixelcount > 6) layerint_buf_dummyreg4[pixelcount-7] <= intermediate_dummyreg;
					endcase
				end else begin
					layercount <= layercount + 1;
					if (layercount == 3) begin
						pixelcount <= pixelcount + 1;
						layercount <= 0;
					end
				end
			end	
		end
	end
	
	always@(*) begin
		cv_op <= CONV;		
		relu <= 1'b1;
		
		// Setting padding
		cv_paddingL <= (pixelcount % 4 == 1) ? 1'b1 : 1'b0;
		cv_paddingR <= (pixelcount % 4 == 2) ? 1'b1 : 1'b0; 
	end
	
	reg [7:0] counter;
	initial counter <= 8'd0;
	
	always @(posedge clk) begin
		if (~rst_n) begin
			counter <= 8'd0;
		end else begin
			if (finish) begin
				if (counter == 8'd63) begin
					$dipslay("Finished");
					$stop;
				end
					
				counter <= counter + 8'd1;
				
				if (counter < 16) begin
					if (layerint_buf_dummyreg1[counter] == out1[counter])
						$display("1-%2d : Correct %5d", counter, out1[counter]);
					else
						$display("1-%2d : ERROR got %5d expected", counter, layerint_buf_dummyreg1[counter], out1[counter]);
				end else if (counter < 32) begin
					if (layerint_buf_dummyreg2[counter-16] == out2[counter-16])
						$display("2-%2d : Correct %5d", counter-16, out2[counter-16]);
					else
						$display("2-%2d : ERROR got %5d expected", counter-16, layerint_buf_dummyreg2[counter-16], out2[counter-16]);
				end else if (counter < 48) begin
					if (layerint_buf_dummyreg3[counter-32] == out3[counter-32])
						$display("3-%2d : Correct %5d", counter-32, out3[counter-32]);
					else
						$display("3-%2d : ERROR got %5d expected", counter-32, layerint_buf_dummyreg3[counter-32], out3[counter-32]);
				end else begin
					if (layerint_buf_dummyreg4[counter-48] == out4[counter-48])
						$display("4-%2d : Correct %5d", counter-48, out4[counter-48]);
					else
						$display("4-%2d : ERROR got %5d expected", counter-48, layerint_buf_dummyreg4[counter-48], out4[counter-48]);
				end
			end
		end
	end
	
endmodule 