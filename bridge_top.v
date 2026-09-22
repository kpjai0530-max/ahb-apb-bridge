module bridge_top(hclk,hresetn,hwrite,hreadyin,haddr,hwdata,htrans,
                  prdata,pwrite,penable,psel,paddr,pwdata,hreadyout,hresp,hrdata);

input hwrite,hclk,hresetn,hreadyin;
input [1:0] htrans;
input [31:0] haddr,hwdata,prdata;
output pwrite,penable,hreadyout;
output [2:0]psel;
output [31:0] paddr,pwdata,hrdata;
output [1:0] hresp;

wire hwritereg,hwritereg1,valid;
wire [31:0] hwdata1,hwdata2,haddr1,haddr2;
wire [2:0] tempselx;

//Instantiating ahb_slave_interface
ahb_slave_interface ahb_sla(hclk,hresetn,hwrite,hreadyin,htrans,haddr,hwdata,prdata,
						valid,haddr1,haddr2,hwdata1,hwdata2,hwritereg,tempselx,hrdata);

//Instantiating apb_controller
apb_controller apb_con(hclk,hresetn,valid,hwrite,haddr,hwdata,haddr1,haddr2,hwdata1,hwdata2,
                 hwritereg,tempselx,hreadyout,pwrite,penable,psel,pwdata,paddr);

endmodule