interface config_if# (
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 6
)(
    input clk,
    input rst_i
);

    logic [31:0] InputImageAddress;
    logic [31:0] OutputImageAddress;
    logic        BeginConv;
    logic [7:0]  heightOfImage;
    logic [7:0]  widthOfImage;
    logic [7:0]  NumberOfFilters;

   clocking cbm@(posedge clk);
      input  rst_i;

      input InputImageAddress;
      input OutputImageAddress;
      input BeginConv;
      input heightOfImage;
      input widthOfImage;
      input NumberOfFilters;
    endclocking

endinterface: config_if
