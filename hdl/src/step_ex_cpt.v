module step_ex_cpt(clk, rst_, ena_, rdy_, reg_id,
    r0_dout,
    r0_din, r1_din, r2_din, r3_din, r4_din, r5_din, fl_din, pc_din,
    r0_we_, r1_we_, r2_we_, r3_we_, r4_we_, r5_we_, fl_we_, pc_we_);
    input clk;
    input rst_;
    input ena_;
    output rdy_;
    input[3:0] reg_id;
    input[7:0] r0_dout;
    output[7:0] r0_din, r1_din, r2_din, r3_din, r4_din, r5_din, fl_din, pc_din;
    output r0_we_, r1_we_, r2_we_, r3_we_, r4_we_, r5_we_, fl_we_, pc_we_;

    reg rdy_en;
    assign rdy_ = rdy_en ? 1'b0 : 1'bZ;
    reg state;
    wire[7:0] regs_din;
    reg regs_din_en;
    assign regs_din = regs_din_en ? r0_dout : 8'bZ;
    assign r0_din = regs_din;
    assign r1_din = regs_din;
    assign r2_din = regs_din;
    assign r3_din = regs_din;
    assign r4_din = regs_din;
    assign r5_din = regs_din;
    assign fl_din = regs_din;
    assign pc_din = regs_din;
    reg regs_we_en[15:0];
    assign r0_we_ = regs_we_en[0] ? 1'b0 : 1'bZ;
    assign r1_we_ = regs_we_en[1] ? 1'b0 : 1'bZ;
    assign r2_we_ = regs_we_en[2] ? 1'b0 : 1'bZ;
    assign r3_we_ = regs_we_en[3] ? 1'b0 : 1'bZ;
    assign r4_we_ = regs_we_en[4] ? 1'b0 : 1'bZ;
    assign r5_we_ = regs_we_en[5] ? 1'b0 : 1'bZ;
    assign fl_we_ = regs_we_en[10] ? 1'b0 : 1'bZ;
    assign pc_we_ = regs_we_en[15] ? 1'b0 : 1'bZ;

    integer i;

    always @(negedge rst_ or posedge clk)
        if(!rst_) begin
            rdy_en <= 0;
            regs_din_en <= 0;
            for(i = 0; i < 16; i = i+1)
                regs_we_en[i] <= 0;
            state <= 0;
        end else if(!ena_) begin
            rdy_en <= 0;
            regs_din_en <= 1;
            for(i = 0; i < 16; i = i+1)
                regs_we_en[i] <= 0;
            state <= 1;
        end else if(state) begin
            rdy_en <= 1;
            regs_din_en <= 1;
            for(i = 0; i < 16; i = i+1)
                regs_we_en[i] <= 0;
            regs_we_en[reg_id] <= 1;
            state <= 0;
        end else begin
            rdy_en <= 0;
            regs_din_en <= 0;
            for(i = 0; i < 16; i = i+1)
                regs_we_en[i] <= 0;
        end

endmodule
