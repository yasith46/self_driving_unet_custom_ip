module buffer4096 (
		input clk, we,
		input  [31:0] wr_addr, rd_addr, wr_data,
		output reg [31:0] rd_data
	);
	
	(* ram_style = "block" *) reg [31:0] mem [0:4095];
	
	always@(posedge clk) begin
		if (we) mem[wr_addr] <= wr_data;
	end
	
	always@(posedge clk) begin
		rd_data <= mem[rd_addr];
	end
endmodule 