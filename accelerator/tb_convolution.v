`timescale 1ns/1ps

module tb_convolution;
	parameter CONV = 2'd0;
	
	
	parameter IMAGE_WIDTH = 4;
	parameter IMAGE_HEIGHT = IMAGE_WIDTH;
	
	reg clk, cv_rst, rst_n, cv_paddingL ,cv_paddingR, relu;
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
		.clk(clk), 
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
	reg signed [31:0] out [0:15];
	
	
	
	// assigning weights, pixels, biases
	initial begin
		w1 <= 8'sd0;  w2 <= 8'sd1;  w3 <= 8'sd0;
		w4 <= -8'sd1; w5 <= 8'sd39; w6 <= -8'sd1;
		w7 <= 8'sd0;  w8 <= 8'sd2;  w9 <= 8'sd0;
		
		bias <= -32'sd1;
		
		im[0]  <= 8'sd14;   im[1]  <= 8'sd1;   im[2]  <= 8'sd0;   im[3]  <= 8'sd100;
		im[4]  <= 8'sd0;    im[5]  <= -8'sd1;  im[6]  <= 8'sd0;   im[7]  <= -8'sd100;
		im[8]  <= 8'sd0;    im[9]  <= 8'sd0;   im[10] <= 8'sd0;   im[11] <= 8'sd0;
		im[12] <= 8'sd1;    im[13] <= 8'sd2;   im[14] <= 8'sd0;   im[15] <= 8'sd1;
		
		out[0]  <= 32'sd544;  out[1]  <= 32'sd22;    out[2]  <= 32'sd0;    out[3]  <= 32'sd3699;   
		out[4]  <= 32'sd14;   out[5]  <= 32'sd0;     out[6]  <= 32'sd100;  out[7]  <= 32'sd0;    
		out[8]  <= 32'sd1;    out[9]  <= 32'sd2;     out[10] <= 32'sd0;    out[11] <= 32'sd0;  
		out[12] <= 32'sd36;   out[13] <= 32'sd76;    out[14] <= 32'sd0;    out[15] <= 32'sd38;    
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
	
	
	
	reg [7:0] pixelcount;
	reg finish;
	reg signed [31:0] intermediate_dummyreg, layerint_buf_dummyreg;
	
	
	
	always@(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			finish <= 1'b0;
			pixelcount <= 8'd0;
			
		end else begin
			// 1 (4x4) Layers ---> 1 (4x4) Layers
			
			if (pixelcount >= 8'd22) begin  // (height*width + (width) for padding + 2 for storing)
				
				cv_rst <= 1'b1;
				finish <= 1'b1;
				pixelcount <= 8'd0;
				
			end else begin
				if (pixelcount == 8'd21) begin
					pixelcount <= pixelcount + 1'b1;
					cv_rst <= 1'b0;	 // Reset	
				end
				
				// filling weights
				
				if (pixelcount >= 7'd5) begin  // ( width+1 for the padding )
					intermediate_dummyreg <= conv_out;
					
					// add bias and quantization
					
					// save image to buffer
					layerint_buf_dummyreg <= intermediate_dummyreg;
				end
				
				pixelcount <= pixelcount + 1'b1;
			end	
		end
	end
	
	always@(*) begin
		cv_op <= CONV;		
		relu <= 1'b1;
		
		// Setting padding
		cv_paddingL <= (pixelcount % 4 == 0) ? 1'b1 : 1'b0;
		cv_paddingR <= (pixelcount % 4 == 1) ? 1'b1 : 1'b0; 
	
		if (~rst_n) begin
			pixelin <= 0;
		end else begin
			if (pixelcount <16)
				pixelin <= im[pixelcount];
			else
				pixelin <= 0;
		end
	end
	
	reg waiting;
	
	always @(posedge clk) begin
		if (~finish) begin
			if (pixelcount > 8'd5) begin
				if (out[pixelcount-8'd6] == intermediate_dummyreg)
					$display("%d: Correct %d", (pixelcount-8'd6), intermediate_dummyreg);
				else
					$display("%d: ERROR - expected %d got %d", (pixelcount-8'd6), out[pixelcount-8'd6], intermediate_dummyreg);
			end
		end else begin
			$diplay("Finished");
			$stop;
		end
	end
	
endmodule 