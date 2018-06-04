module memory(clk, rst_, abus, dbus, re_, we_);
    input clk;
    input rst_;
    input re_, we_;
    input[7:0] abus;
    inout[7:0] dbus;

    reg[7:0] mem[255:0];

    assign dbus = re_ ? 8'bZ : mem[abus];

    initial
        $readmemh("./rom/rom.hex", mem);

    always @(posedge clk)
        if(!we_)
            mem[abus] <= dbus;

endmodule
