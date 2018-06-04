module step_ex_tce(clk, rst_, ena_, rdy_,
    fl_din, fl_dout, fl_we_);
    input clk;
    input rst_;
    input ena_;
    output rdy_;
    output[7:0] fl_din;
    input[7:0] fl_dout;
    output fl_we_;

    reg rdy_en;
    assign rdy_ = rdy_en ? 1'b0 : 1'bZ;
    reg fl_din_en;
    assign fl_din = fl_din_en ? {fl_dout[7:1], ~fl_dout[0]} : 8'bZ;
    reg fl_we_en;
    assign fl_we_ = fl_we_en ? 1'b0 : 1'bZ;
    reg state;

    always @(negedge rst_ or posedge clk)
    if(!rst_) begin
        rdy_en <= 0;
        fl_din_en <= 0;
        fl_we_en <= 0;
        state <= 0;
    end else if(!ena_) begin
        rdy_en <= 0;
        fl_din_en <= 1;
        fl_we_en <= 0;
        state <= 1;
    end else if(state) begin
        rdy_en <= 1;
        fl_din_en <= 1;
        fl_we_en <= 1;
        state <= 0;
    end else begin
        rdy_en <= 0;
        fl_din_en <= 0;
        fl_we_en <= 0;
    end

endmodule
