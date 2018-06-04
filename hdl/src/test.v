`timescale 1us/1us

module test;
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, test);
    end

    reg clk = 0;
    always begin
        #5 clk <= ~clk;
    end

    reg rst_;
    initial begin
        rst_ = 1;
        #1 rst_ = 0;
        #6 rst_ = 1;
        #10000 $finish;
    end

    top top(
        .clk(clk), .rst_(rst_)
    );

endmodule

