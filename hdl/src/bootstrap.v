// This program is a part of Riscade project.
// Licensed under MIT License.
// See https://github.com/m13253/riscade/blob/master/COPYING for licensing information.

module bootstrap(
    input clk,
    input rst,
    output reg rdy
);
    reg state;
    initial
        state <= 0;
    always @(posedge clk, posedge rst)
        if(rst)
            state <= 0;
        else if(state == 0) begin
            state <= 1;
            rdy <= 1;
        end  else
            rdy <= 0;
endmodule
