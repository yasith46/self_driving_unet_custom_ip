interface axi_lite_if(
    input clk,
    input rst_i
);
    localparam C_S00_AXI_DATA_WIDTH	= 32;
	  localparam C_S00_AXI_ADDR_WIDTH	= 6;
    localparam STRB_WIDTH = (C_S00_AXI_DATA_WIDTH/8);

    //WRITE ADDRESS BUS
    logic  [C_S00_AXI_ADDR_WIDTH-1:0]  awaddr;
    logic  [2:0]             awprot;
    logic                    awvalid;
    logic                    awready;
    
    //WRITE DATA BUS
    logic  [C_S00_AXI_DATA_WIDTH-1:0]  wdata;
    logic  [STRB_WIDTH-1:0]  wstrb;
    logic                    wvalid;
    logic                    wready;
    
    //WRITE RESPONSE BUS
    logic  [1:0]             bresp;
    logic                    bvalid;
    logic                    bready;

    always @(rst_i) begin
        $display("[AXI_LITE_IF] rst_i changed to %b (time=%0t)", rst_i, $time);
    end

    clocking cbsd@(posedge clk);
      input   rst_i;
       
      //WRITE ADDRESS BUS
      input  awready;
      output awaddr,awvalid,awprot;

      //WRITE DATA BUS
      input  wready;
      output wdata,wstrb,wvalid;
       
      //WRITE RESPONSE BUS
      input  bresp,bvalid;
      output bready;
    endclocking

   clocking cbm@(posedge clk);
      input  rst_i;

      //WRITE ADDRESS BUS
      input  awready;
      input  awaddr,awvalid,awprot;

      //WRITE DATA BUS
      input  wready;
      input  wdata,wstrb,wvalid;
       
      //WRITE RESPONSE BUS
      input  bresp,bvalid;
      input  bready;
    endclocking

endinterface: axi_lite_if
