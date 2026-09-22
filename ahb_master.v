module ahb_master(
    input hclk,
    input hresetn,
    input hreadyout,
    input [31:0] hrdata,

    output reg [31:0] haddr,
    output reg [31:0] hwdata,
    output reg hwrite,
    output reg hreadyin,
    output reg [1:0] htrans
);

    reg [2:0] hburst;
    reg [2:0] hsize;
    integer i = 0;

    // Single Write Task
    task single_write();
    begin
        @(posedge hclk);
        #1;
        begin
            hwrite    = 1;
            htrans    = 2'd2; // NONSEQ
            hsize     = 0;
            hburst    = 0;
            hreadyin  = 1;
            haddr     = 32'h8000_0000;
        end

        @(posedge hclk);
        #1;
        begin
            haddr  = 32'h0000_0000;
            hwrite = 0;
            hwdata = 32'h24;
            htrans = 2'd0; // IDLE
        end
    end
    endtask

    // Single Read Task
    task single_read();
    begin
        @(posedge hclk);
        #1;
        begin
            hwrite    = 0;
            htrans    = 2'd2; // NONSEQ
            hsize     = 0;
            hburst    = 0;
            hreadyin  = 1;
            haddr     = 32'h8000_0000;
        end

        @(posedge hclk);
        #1;
        begin
            htrans = 2'd0; // IDLE
        end
    end
    endtask

    // 4-beat Incrementing Burst Write
    task burst_4_incr_write();
    begin
        @(posedge hclk);
        #1;
        begin
            hwrite    = 1;
            htrans    = 2'd2; // NONSEQ
            hsize     = 0;
            hburst    = 3'd3; // INCR4
            hreadyin  = 1;
            haddr     = 32'h8000_0000;
        end

        @(posedge hclk);
        #1;
        begin
            haddr  = haddr + 1;
            hwdata = {$random} % 256;
            htrans = 2'd3; // SEQ
        end

        for (i = 0; i < 2; i = i + 1) begin
            @(posedge hclk);
            #1;
            begin
                haddr  = haddr + 1;
                hwdata = {$random} % 256;
                htrans = 2'd3; // SEQ
            end
        end

        @(posedge hclk);
        #1;
        begin
            haddr  = 32'h0000_0000;
            hwdata = {$random} % 256;
            htrans = 2'd0; // IDLE
            hwrite = 1'b0;
        end
    end
    endtask

    // 4-beat Wrapping Burst Write (called by ahb_to_apb testbench)
    task burst_write_wrap4();
    begin
        @(posedge hclk);
        #1;
        begin
            hwrite    = 1;
            htrans    = 2'd2; // NONSEQ
            hsize     = 0;
            hburst    = 3'd2; // WRAP4
            hreadyin  = 1;
            haddr     = 32'h8000_0000;
        end

        @(posedge hclk);
        #1;
        begin
            haddr  = {haddr[31:2], haddr[1:0] + 1'b1};
            hwdata = {$random} % 256;
            htrans = 2'd3; // SEQ
        end

        for (i = 0; i < 2; i = i + 1) begin
            @(posedge hclk);
            #1;
            begin
                haddr  = {haddr[31:2], haddr[1:0] + 1'b1};
                hwdata = {$random} % 256;
                htrans = 2'd3; // SEQ
            end
        end

        @(posedge hclk);
        #1;
        begin
            haddr  = 32'h0000_0000;
            hwdata = {$random} % 256;
            htrans = 2'd0; // IDLE
            hwrite = 1'b0;
        end
    end
    endtask

endmodule