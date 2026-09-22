module apb_controller(
    hclk, hresetn, valid, hwrite, haddr, hwdata, haddr1,
    haddr2, hwdata1, hwdata2, hwritereg, tempselx, hreadyout,
    pwrite, penable, pselx, pwdata, paddr
);

input valid, hwritereg, hclk, hresetn, hwrite;
input [31:0] haddr1, haddr2, hwdata1, hwdata2, haddr, hwdata;
input [2:0] tempselx;
output reg pwrite, penable;
output reg [2:0] pselx;
output reg hreadyout;
output reg [31:0] pwdata, paddr;

parameter st_idle     = 3'b000,
          st_wait     = 3'b001,
          st_write    = 3'b010,
          st_writep   = 3'b011,
          st_wenablep = 3'b100,
          st_wenable  = 3'b101,
          st_read     = 3'b110,
          st_renable  = 3'b111;

reg [2:0] state, next_state;
reg [31:0] paddr_temp, pwdata_temp;
reg penable_temp, pwrite_temp, hreadyout_temp;
reg [2:0] pselx_temp;

// present state logic
always @(posedge hclk) begin
    if (!hresetn)
        state <= st_idle;
    else
        state <= next_state;
end

// next state logic
always @(*) begin
    case (state)
        st_idle: begin
            if ((valid == 1'b1) && (hwrite == 1'b1))
                next_state = st_wait;
            else if ((valid == 1'b1) && (hwrite == 1'b0))
                next_state = st_read;
            else
                next_state = st_idle;
        end

        st_wait: begin
            if (valid == 1'b1)
                next_state = st_writep;
            else
                next_state = st_write;
        end

        st_writep: begin
            next_state = st_wenablep;
        end

        st_write: begin
            if (valid == 1'b1)
                next_state = st_wenablep;
            else
                next_state = st_wenable;
        end

        st_wenable: begin
            if ((valid == 1'b1) && ~hwrite)
                next_state = st_read;
            else if (~valid)
                next_state = st_idle;
            else
                next_state = st_wenable;
        end

        st_read: begin
            next_state = st_renable;
        end

        st_renable: begin
            if ((valid == 1'b1) && ~hwrite)
                next_state = st_read;
            else if ((valid == 1'b1) && hwrite)
                next_state = st_wait;
            else if (~valid)
                next_state = st_idle;
            else
                next_state = st_renable;
        end

        default: next_state = st_idle;
    endcase
end

// logic to store the data in temporary register
always @(*) begin
    case (state)
        st_idle: begin
            if ((valid == 1'b1) && (hwrite == 1'b1)) begin // Burst write
                pselx_temp     = 3'b000;
                penable_temp   = 1'b0;
                hreadyout_temp = 1'b1;
            end
            else if ((valid == 1'b1) && (hwrite == 1'b0)) begin // burst read
                paddr_temp     = haddr;
                pwrite_temp    = 1'b0;
                pselx_temp     = tempselx;
                hreadyout_temp = 1'b0;
                penable_temp   = 1'b0;
            end
        end

        st_wait: begin
            paddr_temp     = haddr1;
            pwrite_temp    = hwrite;
            pselx_temp     = tempselx;
            hreadyout_temp = 1'b0;
            pwdata_temp    = hwdata;
        end

        st_write: begin
            hreadyout_temp = 1'b1;
            penable_temp   = 1'b1;
        end

        st_writep: begin
            hreadyout_temp = 1'b1;
            penable_temp   = 1'b1;
        end

        st_wenable: begin
            paddr_temp     = haddr2;
            hreadyout_temp = 1'b0;
            penable_temp   = 1'b0;
            pwdata_temp    = hwdata;
        end

        st_read: begin
            hreadyout_temp = 1'b1;
            penable_temp   = 1'b1;
        end

        st_renable: begin
            paddr_temp     = haddr;
            hreadyout_temp = 1'b0;
            penable_temp   = 1'b0;
        end
    endcase
end

// output logic
always @(posedge hclk) begin
    if (!hresetn) begin
        penable   <= 0;
        pselx     <= 0;
        hreadyout <= 1'b1;
    end
    else begin
        pwrite    <= pwrite_temp;
        penable   <= penable_temp;
        pselx     <= pselx_temp;
        pwdata    <= pwdata_temp;
        paddr     <= paddr_temp;
        hreadyout <= hreadyout_temp;
    end
end

endmodule