module step_ex_clr(clk, rst_, ena_, rdy_,
    r0_din, r0_we_);
    input clk;
    input rst_;
    input ena_;
    output rdy_;
    output[7:0] r0_din;
    output r0_we_;

    reg rdy_en;
    assign rdy_ = rdy_en ? 1'b0 : 1'bZ;
    reg r0_din_en;
    assign r0_din = r0_din_en ? 8'b0 : 8'bZ;
    reg r0_we_en;
    assign r0_we_ = r0_we_en ? 1'b0 : 1'bZ;
    reg state;

    always @(negedge rst_ or posedge clk)
        if(!rst_) begin
            rdy_en <= 0;
            r0_din_en <= 0;
            r0_we_en <= 0;
            state <= 0;
        end else if(!ena_) begin
            rdy_en <= 0;
            r0_din_en <= 1;
            r0_we_en <= 0;
            state <= 1;
        end else if(state) begin
            rdy_en <= 1;
            r0_din_en <= 1;
            r0_we_en <= 1;
            state <= 0;
        end else begin
            rdy_en <= 0;
            r0_din_en <= 0;
            r0_we_en <= 0;
        end

endmodule
