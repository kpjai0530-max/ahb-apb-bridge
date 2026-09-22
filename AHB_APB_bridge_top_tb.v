//Single Read
`timescale 1ns/1ps
module AHB_APB_bridge_top_tb;
    reg        hclk;
    reg        hresetn;
    reg        hwrite;
    reg        hreadyin;
    reg [1:0]  htrans;
    reg [31:0] haddr;
    reg [31:0] hwdata;
    reg [31:0] prdata;

    wire        pwrite;
    wire        penable;
    wire [2:0]  pselx;
    wire [31:0] paddr;
    wire [31:0] pwdata;

    wire        hr_readyout;
    wire [31:0] hrdata;
    wire [1:0]  hresp;

    AHB_APB_bridge_top dut (
        .hclk(hclk), .hresetn(hresetn), .hwrite(hwrite), .hreadyin(hreadyin), .hwdata(hwdata),
        .haddr(haddr), .prdata(prdata),
        .htrans(htrans), .pwrite(pwrite), .penable(penable), .pselx(pselx), .paddr(paddr), .pwdata(pwdata),
        .hr_readyout(hr_readyout), .hrdata(hrdata), .hresp(hresp)
    );

    initial begin
        hclk = 0;
        forever #10 hclk = ~hclk;
    end

    initial begin
        hresetn = 0;
        hreadyin = 1;
        #10;
        hresetn = 1;
    end

    initial begin
        hwrite = 0;
        htrans = 2'b00;
        haddr  = 0;
        hwdata = 0;
        prdata = 0;

        @(posedge hresetn);
        @(posedge hclk);

        hwrite = 0;
        htrans = 2'b10;
        haddr  = 32'h8000_0070;

        @(posedge hclk);
        htrans = 2'b00;

        #5;
        prdata = 32'd40;

        @(posedge hclk);
        prdata = 32'd28;

        #100;
        $finish;
    end
endmodule