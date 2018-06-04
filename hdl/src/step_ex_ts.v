module step_ex_ts(clk, rst_, ena_, rdy_,
    mode, r0_dout,
    fl_din, fl_dout, fl_we_);
    input clk;
    input rst_;
    input ena_;
    output rdy_;
    input[1:0] mode;
    input[7:0] r0_dout;
    output[7:0] fl_din;
    input[7:0] fl_dout;
    output fl_we_;

    reg rdy_en;
    assign rdy_ = rdy_en ? 1'b0 : 1'bZ;
    wire result = mode[1] ? mode[0] ? r0_dout[7] : r0_dout != 8'b0 : r0_dout[0];
    reg fl_din_en;
    assign fl_din = fl_din_en ? {fl_dout[7:1], result} : 8'bZ;
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
