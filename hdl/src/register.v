module register(rst_, din, dout, we_);
    input rst_;
    input[7:0] din;
    output[7:0] dout;
    input we_;
    reg[7:0] dout;

    always @(negedge rst_ or negedge we_)
        if(!rst_)
            dout <= 0;
        else if(!we_)
            dout <= din;

endmodule
