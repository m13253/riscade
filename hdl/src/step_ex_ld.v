module step_ex_ld(clk, rst_, ena_, rdy_,
    mem_re_, abus, dbus,
    r1_dout, r0_din, r0_we_);
    input clk;
    input rst_;
    input ena_;
    output rdy_;
    output mem_re_;
    output[7:0] abus;
    input[7:0] dbus;
    input[7:0] r1_dout;
    output[7:0] r0_din;
    output r0_we_;

    reg rdy_en;
    assign rdy_ = rdy_en ? 1'b0 : 1'bZ;
    reg mem_re_en;
    assign mem_re_ = mem_re_en ? 1'b0 : 1'bZ;
    assign abus = mem_re_en ? r1_dout : 8'bZ;
    assign r0_din = mem_re_en ? dbus : 8'bZ;
    reg r0_we_en;
    assign r0_we_ = r0_we_en ? 1'b0 : 1'bZ;
    reg[1:0] state;

    always @(negedge rst_ or posedge clk)
        if(!rst_) begin
            rdy_en <= 0;
            mem_re_en <= 0;
            r0_we_en <= 0;
            state <= 0;
        end else begin
            /*
                State 0: ena_=0 state=00
                    rdy_en=0 mem_re_en=1 r0_we_en=0 state=01
                State 1: ena_=1 state=01
                    rdy_en=0 mem_re_en=1 r0_we_en=1 state=10
                State 2: ena_=1 state=10
                    rdy_en=1 mem_re_en=0 r0_we_en=0 state=00
                State 3: ena_=1 state=00
                    rdy_en=0 mem_re_en=0 r0_we_en=0 state=00
            */
            rdy_en <= state[1];
            mem_re_en <= state[0] | ~ena_;
            r0_we_en <= state[0];
            state <= {state[0], ~ena_};
        end

endmodule
