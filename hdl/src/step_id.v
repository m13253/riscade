module step_id(inst, ena_, cond_dout,
    rdy_nop_, rdy_cpf_, rdy_cpt_, rdy_ld_, rdy_st_, rdy_clr_, rdy_im_, rdy_tce_, rdy_ts_, rdy_add_, rdy_sub_);
    input[7:0] inst;
    input ena_;
    input cond_dout;
    output rdy_nop_, rdy_cpf_, rdy_cpt_, rdy_ld_, rdy_st_, rdy_clr_, rdy_im_, rdy_tce_, rdy_ts_, rdy_add_, rdy_sub_;

    wire cond_ = inst[7] ^ cond_dout;
    wire[6:0] inst_cond = inst[6:0] & {7{~(cond_ | ena_)}};

    assign rdy_nop_ = inst_cond[6:0] != 7'b0000000 || ena_;
    assign rdy_cpf_ = inst_cond[6:4] != 3'b010 || inst_cond[3:0] == 4'b0000;
    assign rdy_cpt_ = inst_cond[6:4] != 3'b011 || inst_cond[3:0] == 4'b0000;
    assign rdy_ld_  = {inst_cond[6:2], inst_cond[0]} != {5'b10001, 1'b0};
    assign rdy_st_  = {inst_cond[6:2], inst_cond[0]} != {5'b10001, 1'b1};
    assign rdy_clr_ = inst_cond != 7'b1010000;
    assign rdy_im_  = inst_cond[6:5] != 2'b11;
    assign rdy_tce_ = inst_cond != 7'b0001100;
    assign rdy_ts_  = {inst_cond[6], inst_cond[3:0]} != {1'b0, 4'b0000} || inst_cond[5:4] == 2'b00;
    assign rdy_add_ = inst_cond != 7'b1010110;
    assign rdy_sub_ = inst_cond != 7'b1010111;

endmodule
