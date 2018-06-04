module top(clk, rst_, abus, dbus, mem_re_, mem_we_);
    input clk;
    input rst_;
    output[7:0] abus;
    output[7:0] dbus;
    output mem_re_, mem_we_;

    tri1 mem_re_, mem_we_;
    wire[7:0] abus;
    wire[7:0] dbus;
    memory memory(
        .clk(clk), .rst_(rst_),
        .re_(mem_re_), .we_(mem_we_),
        .abus(abus),
        .dbus(dbus)
    );

    wire[7:0] r_din[5:0], r_dout[5:0];
    tri1 r_we_[5:0];
    generate
        genvar i;
        for(i = 0; i < 6; i = i+1) begin : r
            register r(
                .rst_(rst_),
                .din(r_din[i]), .dout(r_dout[i]),
                .we_(r_we_[i])
            );
        end
    endgenerate

    wire[7:0] fl_din, fl_dout;
    tri1 fl_we_;
    register fl(
        .rst_(rst_),
        .din(fl_din), .dout(fl_dout),
        .we_(fl_we_)
    );

    wire[7:0] pc_din, pc_dout;
    tri1 pc_we_;
    register pc(
        .rst_(rst_),
        .din(pc_din), .dout(pc_dout),
        .we_(pc_we_)
    );

    tri1 step_if_ena_;
    bootstrap bootstrap(
        .clk(clk), .rst_(rst_),
        .rdy_(step_if_ena_)
    );

    wire step_id_ena_;
    wire[7:0] step_id_inst;
    step_if step_if(
        .clk(clk), .rst_(rst_),
        .ena_(step_if_ena_), .rdy_(step_id_ena_),
        .mem_re_(mem_re_), .abus(abus), .dbus(dbus),
        .pc_din(pc_din), .pc_dout(pc_dout), .pc_we_(pc_we_),
        .inst(step_id_inst)
    );

    wire step_ex_nop_, step_ex_cpf_, step_ex_cpt_, step_ex_ld_, step_ex_st_;
    wire step_ex_clr_, step_ex_im_, step_ex_tce_, step_ex_ts_, step_ex_add_;
    wire step_ex_sub_;
    step_id step_id(
        .inst(step_id_inst), .ena_(step_id_ena_),
        .cond_dout(fl_dout[0]),
        .rdy_nop_(step_ex_nop_),
        .rdy_cpf_(step_ex_cpf_),
        .rdy_cpt_(step_ex_cpt_),
        .rdy_ld_(step_ex_ld_),
        .rdy_st_(step_ex_st_),
        .rdy_clr_(step_ex_clr_),
        .rdy_im_(step_ex_im_),
        .rdy_tce_(step_ex_tce_),
        .rdy_ts_(step_ex_ts_),
        .rdy_add_(step_ex_add_),
        .rdy_sub_(step_ex_sub_)
    );

    step_ex_nop step_ex_nop(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_nop_), .rdy_(step_if_ena_)
    );

    step_ex_cpf step_ex_cpf(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_cpf_), .rdy_(step_if_ena_),
        .reg_id(step_id_inst[3:0]),
        .r0_din(r_din[0]), .r0_we_(r_we_[0]),
        .r0_dout(r_dout[0]), .r1_dout(r_dout[1]), .r2_dout(r_dout[2]), .r3_dout(r_dout[3]),
        .r4_dout(r_dout[4]), .r5_dout(r_dout[5]), .fl_dout(fl_dout), .pc_dout(pc_dout)
    );

    step_ex_cpt step_ex_cpt(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_cpt_), .rdy_(step_if_ena_),
        .reg_id(step_id_inst[3:0]),
        .r0_dout(r_dout[0]),
        .r0_din(r_din[0]), .r1_din(r_din[1]), .r2_din(r_din[2]), .r3_din(r_din[3]),
        .r4_din(r_din[4]), .r5_din(r_din[5]), .fl_din(fl_din), .pc_din(pc_din),
        .r0_we_(r_we_[0]), .r1_we_(r_we_[1]), .r2_we_(r_we_[2]), .r3_we_(r_we_[3]),
        .r4_we_(r_we_[4]), .r5_we_(r_we_[5]), .fl_we_(fl_we_), .pc_we_(pc_we_)
    );

    step_ex_ld step_ex_ld(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_ld_), .rdy_(step_if_ena_),
        .mem_re_(mem_re_), .abus(abus), .dbus(dbus),
        .r1_dout(r_dout[1]), .r0_din(r_din[0]), .r0_we_(r_we_[0])
    );

    step_ex_st step_ex_st(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_st_), .rdy_(step_if_ena_),
        .mem_we_(mem_we_), .abus(abus), .dbus(dbus),
        .r0_dout(r_dout[0]), .r1_dout(r_dout[1])
    );

    step_ex_clr step_ex_clr(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_clr_), .rdy_(step_if_ena_),
        .r0_din(r_din[0]), .r0_we_(r_we_[0])
    );

    step_ex_im step_ex_im(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_im_), .rdy_(step_if_ena_),
        .r0_din(r_din[0]), .r0_dout(r_dout[0]), .r0_we_(r_we_[0]),
        .immed(step_id_inst[3:0]), .high(step_id_inst[4])
    );

    step_ex_tce step_ex_tce(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_tce_), .rdy_(step_if_ena_),
        .fl_din(fl_din), .fl_dout(fl_dout), .fl_we_(fl_we_)
    );

    step_ex_ts step_ex_ts(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_ts_), .rdy_(step_if_ena_),
        .mode(step_id_inst[5:4]), .r0_dout(r_dout[0]),
        .fl_din(fl_din), .fl_dout(fl_dout), .fl_we_(fl_we_)
    );

    step_ex_add step_ex_add(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_add_), .rdy_(step_if_ena_),
        .r0_dout(r_dout[0]), .r1_dout(r_dout[1]),
        .r0_din(r_din[0]), .r0_we_(r_we_[0])
    );

    step_ex_sub step_ex_sub(
        .clk(clk), .rst_(rst_),
        .ena_(step_ex_sub_), .rdy_(step_if_ena_),
        .r0_dout(r_dout[0]), .r1_dout(r_dout[1]),
        .r0_din(r_din[0]), .r0_we_(r_we_[0])
    );

endmodule
