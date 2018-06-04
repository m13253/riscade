module step_ex_im(clk, rst_, ena_, rdy_,
    r0_din, r0_dout, r0_we_,
    immed, high);
    input clk;
    input rst_;
    input ena_;
    output rdy_;
    output[7:0] r0_din;
    input[7:0] r0_dout;
    output r0_we_;
    input[3:0] immed;
    input high;

    reg rdy_en;
    assign rdy_ = rdy_en ? 1'b0 : 1'bZ;
    reg r0_din_en;
    assign r0_din = r0_din_en ?
                        high ? {immed, r0_dout[3:0]} : {r0_dout[7:4], immed} :
                        8'bZ;
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
