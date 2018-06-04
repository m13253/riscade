module bootstrap(clk, rst_, rdy_);
    input clk;
    input rst_;
    output rdy_;

    reg rst_1, rst_2;
    always @(negedge rst_ or posedge clk)
        if(!rst_) begin
            rst_1 <= 0;
            rst_2 <= 0;
        end else begin
            rst_1 <= rst_;
            rst_2 <= rst_1;
        end

    assign rdy_ = (rst_1 && !rst_2) ? 1'b0 : 1'bZ;

endmodule
