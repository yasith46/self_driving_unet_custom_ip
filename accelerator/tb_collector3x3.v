module tb_collector3x3;

	parameter IMAGE_WIDTH = 256;
	parameter IMAGE_HEIGHT = IMAGE_WIDTH;
	
	reg clk, rst;
	reg [7:0] pixel;
	wire [7:0] out9, out8, out7, out6, out5, out4, out3, out2, out1;
	wire stall;
	
	collector3x3 #(.IMAGE_WIDTH(IMAGE_WIDTH), .IMAGE_HEIGHT(IMAGE_HEIGHT)) uut0 (
		.pixel_in(pixel),
		.clk(clk), .rst_n(rst), .stall(stall),
		.out9(out9), .out8(out8), .out7(out7),
		.out6(out6), .out5(out5), .out4(out4),
		.out3(out3), .out2(out2), .out1(out1)
	);
	
	initial clk = 0;
	always #5 clk = ~clk;
	
	integer row, col, cycle;
	
	initial begin
		rst <= 1;
		#10;
		cycle = 0;
		$display("Starting testbench");
		
		rst <= 0;
		#4;
		rst <= 1;
		
		for (row=0; row<IMAGE_HEIGHT; row=row+1) begin		
			for (col=0; col<IMAGE_WIDTH; col=col+1) begin
				@(posedge clk);
				pixel <= col[7:0];
			end
		end
		
		#20;
		$stop;
	end
	
	always@(posedge clk) cycle <= cycle + 1;
	
	always@(posedge clk) begin
		$display("At %d", cycle);
		$display(" %3d %3d %3d", out1, out2, out3);
		$display(" %3d %3d %3d", out4, out5, out6);
		$display(" %3d %3d %3d", out7, out8, out9);
		
		if (
				(out1==out4) && (out4==out7) && (out2==out5) && 
				(out5==out8) && (out3==out6) && (out6==out9) && 
				(out2==out1+1) && (out3==out2+1)
			) begin
			if (stall)
				$display("!!!!wrong");
			else
				$display("Correct");
				
			$display("Kernel detected");
		end else begin
			if (stall)
				$display("Correct");
			else
				$display("!!wrong");
				
			$display("No kernel detected");
		end
		
		$display("--------------------------------------");
	end
endmodule
