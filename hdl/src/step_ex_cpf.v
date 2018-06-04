module step_ex_cpf(clk, rst_, ena_, rdy_, reg_id,
    r0_din, r0_we_,
    r0_dout, r1_dout, r2_dout, r3_dout, r4_dout, r5_dout, fl_dout, pc_dout);
    input clk;
    input rst_;
    input ena_;
    output rdy_;
    input[3:0] reg_id;
    output[7:0] r0_din;
    output r0_we_;
    input[7:0] r0_dout, r1_dout, r2_dout, r3_dout, r4_dout, r5_dout, fl_dout, pc_dout;

    reg rdy_en;
    assign rdy_ = rdy_en ? 1'b0 : 1'bZ;
    reg r0_din_en;
    assign r0_din = r0_din_en ? regs_dout[reg_id] : 8'bZ;
    reg r0_we_en;
    assign r0_we_ = r0_we_en ? 1'b0 : 1'bZ;
    reg state;
    tri0[7:0] regs_dout[15:0];
    assign regs_dout[0] = r0_dout;
    assign regs_dout[1] = r1_dout;
    assign regs_dout[2] = r2_dout;
    assign regs_dout[3] = r3_dout;
    assign regs_dout[4] = r4_dout;
    assign regs_dout[5] = r5_dout;
    assign regs_dout[10] = fl_dout;
    assign regs_dout[14] = 8'hff;
    assign regs_dout[15] = pc_dout;

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
