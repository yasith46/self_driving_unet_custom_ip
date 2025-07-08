module quant(
		input signed [31:0] in, 
		input signed [15:0] scaler_scaled16,
		input signed [7:0]  zeropoint,
		output signed [7:0]  result
	);
	
	assign result = ((in + zeropoint) * scaler_scaled16) >> 16;
	
endmodule 