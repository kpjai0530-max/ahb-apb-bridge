module ahb_to_apb;

reg hclk, hresetn;
//reg [31:0] hrdata;
wire penable_out, pwrite_out;
wire [31:0] paddr_out, pwdata_out, prdata;
wire [2:0] psel_out;

wire [31:0] hrdata;

wire [2:0] psel;
wire [31:0] haddr, hwdata;
wire hwrite, hreadyin, hreadyout;
wire [1:0] htrans;
wire penable, pwrite;
wire [31:0] paddr, pwdata;
wire [1:0] hresp;

//instantiating ahb_master
ahb_master ahb_m1(hclk, hresetn, hreadyout, hrdata, haddr, hwdata, hwrite, hreadyin, htrans);

//instantiating bridge top
bridge_top bt1(hclk, hresetn, hwrite, hreadyin, haddr, hwdata, htrans, prdata, pwrite, penable,
               psel, paddr, pwdata, hreadyout, hresp, hrdata);

//instantiating apb_interface
apb_interface apb_i1(pwrite, penable, psel, paddr, pwdata, pwrite_out, penable_out,
                    psel_out, paddr_out, pwdata_out, prdata);

initial
hclk = 1'b0;

always
#10 hclk = ~hclk;

task reset;
begin
    @(negedge hclk);
    hresetn = 1'b0;
    @(negedge hclk);
    hresetn = 1'b1;
end
endtask

initial
begin
    reset;
//  ahb_m1.single_write();
//  ahb_m1.single_read();
    ahb_m1.burst_write_wrap4;
end

initial
//#1000 $finish;
#1000 $stop;
endmodule