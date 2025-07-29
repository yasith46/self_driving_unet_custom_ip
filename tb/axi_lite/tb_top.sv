import uvm_pkg::*;
`include "uvm_macros.svh"

import env_pkg::*;
import axi_lite_test_pkg::*;

parameter integer C_S00_AXI_DATA_WIDTH	= 32;
parameter integer C_S00_AXI_ADDR_WIDTH	= 6;
localparam HALF_CLK_PERIOD  = 5;

module tb_top;
    logic clk;
    logic rst_i;

    config_if #(
        .C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    )config_vif(
        .clk           (clk             ),
        .rst_i         (rst_i           )
    );
    axi_lite_if  axi_lite_svif (      
        .clk           (clk             ),
        .rst_i         (rst_i           )
    );

    slave_axi_lite inst(

        //GLOBAL CLOCK AND RESET
        .s00_axi_aclk     (clk),
        .s00_axi_aresetn  (~rst_i),
        
        //WRITE ADDRESS BUS
        .s00_axi_awaddr   (axi_lite_svif.awaddr),
        .s00_axi_awprot   (axi_lite_svif.awprot),
        .s00_axi_awvalid  (axi_lite_svif.awvalid),
        .s00_axi_awready  (axi_lite_svif.awready),
        
        //WRITE DATA BUS
        .s00_axi_wdata    (axi_lite_svif.wdata),
        .s00_axi_wstrb    (axi_lite_svif.wstrb),
        .s00_axi_wvalid   (axi_lite_svif.wvalid),
        .s00_axi_wready   (axi_lite_svif.wready),
        
        //WRITE RESPONSE BUS
        .s00_axi_bresp    (axi_lite_svif.bresp),
        .s00_axi_bvalid   (axi_lite_svif.bvalid),
        .s00_axi_bready   (axi_lite_svif.bready),

        .InterruptToCPU     (),
        .ConvDone           (),

        .InputImageAddress  (config_vif.InputImageAddress),
        .OutputImageAddress (config_vif.OutputImageAddress),
        .BeginConv          (config_vif.BeginConv),
        .heightOfImage      (config_vif.heightOfImage),
        .widthOfImage       (config_vif.widthOfImage),
        .NumberOfFilters    (config_vif.NumberOfFilters)
    );

    initial begin
        clk=0;
        forever #5 clk=~clk;
    end

    initial begin
        rst_i   = 1'b0;
        #(HALF_CLK_PERIOD);
        rst_i   = 1'b1;
        #(3*HALF_CLK_PERIOD);
        rst_i   = 1'b0;
    end

    initial begin
        uvm_config_db #(virtual config_if)::set(null, "*", "config_vif", config_vif);
        uvm_config_db #(virtual axi_lite_if)::set(null, "*", "axi_lite_svif", axi_lite_svif); 
        run_test("axi_lite_test");
    end
    
endmodule
