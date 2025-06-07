module quant(
		input  [31:0] in, bias, zeropoint, scaler_scaled16,
		output [7:0]  result
	);
	
	assign result = ((in + bias + zeropoint) * scaler_scaled16) >> 16;
	
endmodule 