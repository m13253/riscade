module step_ex_nop(clk, rst_, ena_, rdy_);
    input clk;
    input rst_;
    input ena_;
    output rdy_;

    reg rdy_en;
    assign rdy_ = rdy_en ? 1'b0 : 1'bZ;

    always @(negedge rst_ or posedge clk)
        if(!rst_)
            rdy_en <= 0;
        else if(!ena_)
            rdy_en <= 1;
        else
            rdy_en <= 0;

endmodule
