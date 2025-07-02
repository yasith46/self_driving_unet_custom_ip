module quant(
		input  [31:0] in, 
		input  [15:0] scaler_scaled16,
		input  [7:0]  zeropoint,
		output [7:0]  result
	);
	
	assign result = ((in + zeropoint) * scaler_scaled16) >> 16;
	
endmodule 