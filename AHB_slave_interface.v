module ahb_slave_interface(
    input hclk,
    input hresetn,
    input hwrite,
    input hreadyin,
    input [1:0] htrans,
    input [31:0] haddr,
    input [31:0] hwdata,
    input [31:0] prdata,
    
    output reg valid,
    output reg [31:0] haddr1,
    output reg [31:0] haddr2,
    output reg [31:0] hwdata1,
    output reg [31:0] hwdata2,
    output reg hwritereg,
    output reg [2:0] tempselx,
    output reg [31:0] hrdata
);

    // Pipeline address and write control signals across clock cycles
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            haddr1    <= 32'h0;
            haddr2    <= 32'h0;
            hwdata1   <= 32'h0;
            hwdata2   <= 32'h0;
            hwritereg <= 1'b0;
        end else begin
            haddr1    <= haddr;
            haddr2    <= haddr1;
            hwdata1   <= hwdata;
            hwdata2   <= hwdata1;
            hwritereg <= hwrite;
        end
    end

    // Decode Valid transaction (HTRANS == 2'b10 (NONSEQ) or 2'b11 (SEQ)) during active select
    always @(*) begin
        if (hresetn && hreadyin && ((htrans == 2'b10) || (htrans == 2'b11)))
            valid = 1'b1;
        else
            valid = 1'b0;
    end

    // Peripheral Address Decoder Logic for APB Select Lines (tempselx)
    always @(*) begin
        if (haddr >= 32'h8000_0000 && haddr < 32'h8000_0400)
            tempselx = 3'b001; // APB Peripheral 1
        else if (haddr >= 32'h8000_0400 && haddr < 32'h8000_0800)
            tempselx = 3'b010; // APB Peripheral 2
        else if (haddr >= 32'h8000_0800 && haddr < 32'h8000_0C00)
            tempselx = 3'b100; // APB Peripheral 3
        else
            tempselx = 3'b000;
    end

    // Read Data Pass-through
    always @(*) begin
        hrdata = prdata;
    end

endmodule