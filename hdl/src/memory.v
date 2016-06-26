// This program is a part of Riscade project.
// Licensed under MIT License.
// See https://github.com/m13253/riscade/blob/master/COPYING for licensing information.

module memory(
    input clk,
    input [15:0] adr,
    input [7:0] dat_i,
    output [7:0] dat_o
    input sel,
    input we
);
    reg [7:0] ram [65535:0];

    initial
        $readmemh("../rom/rom.hex", ram);

    always @(posedge clk)
        if(sel) begin
            if(we)
                ram[adr] <= dst_i;
            else
                dst_o <= ram[adr];
        end else
            dst_o <= 8'bx;

endmodule
