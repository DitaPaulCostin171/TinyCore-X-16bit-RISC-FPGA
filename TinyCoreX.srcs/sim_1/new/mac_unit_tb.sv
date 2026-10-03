`timescale 1ns / 1ps
module mac_unit_tb();
parameter int DATA_WIDTH=16;
    
    logic signed [DATA_WIDTH-1:0]a;
    logic signed [DATA_WIDTH-1:0]b;
    logic signed [DATA_WIDTH-1:0]acc;
    
    logic signed [DATA_WIDTH-1:0] result;
    logic signed [(2*DATA_WIDTH)-1:0] full_result;
    logic overflow;

    mac_unit #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .a(a),
        .b(b),
        .acc(acc),
        .result(result),
        .full_result(full_result),
        .overflow(overflow)
    );

    
    initial begin
        // 10 + 3*4 = 22

        a   = 16'sd3;
        b   = 16'sd4;
        acc = 16'sd10;

        #1;

        if(full_result !== 32'sd22 ||
           result      !== 16'sd22 ||
           overflow    !== 1'b0)

            $error("MAC failed: 10 + 3*4");

        else
            $display("PASS: 10 + 3*4 = 22");

        // -10 + 3*4 = 2

        a   = 16'sd3;
        b   = 16'sd4;
        acc = -16'sd10;

        #1;

        if(full_result !== 32'sd2 ||
           result      !== 16'sd2 ||
           overflow    !== 1'b0)

            $error("MAC failed: -10 + 3*4");

        else
            $display("PASS: -10 + 3*4 = 2");

        // 10 + (-3)*4 = -2

        a   = -16'sd3;
        b   = 16'sd4;
        acc = 16'sd10;

        #1;

        if(full_result !== -32'sd2 ||
           result      !== -16'sd2 ||
           overflow    !== 1'b0)

            $error("MAC failed: 10 + (-3)*4");

        else
            $display("PASS: 10 + (-3)*4 = -2");

        // -10 + (-3)*(-4) = 2

        a   = -16'sd3;
        b   = -16'sd4;
        acc = -16'sd10;

        #1;

        if(full_result !== 32'sd2 ||
           result      !== 16'sd2 ||
           overflow    !== 1'b0)

            $error("MAC failed: -10 + (-3)*(-4)");

        else
            $display("PASS: -10 + (-3)*(-4) = 2");

        // Maximum valid positive result
        // 32760 + 7*1 = 32767

        a   = 16'sd7;
        b   = 16'sd1;
        acc = 16'sd32760;

        #1;

        if(full_result !== 32'sd32767 ||
           result      !== 16'sd32767 ||
           overflow    !== 1'b0)

            $error("MAC failed at positive boundary");

        else
            $display("PASS: positive boundary = 32767");

        // Positive overflow
        // 32760 + 10 = 32770

        a   = 16'sd10;
        b   = 16'sd1;
        acc = 16'sd32760;

        #1;

        if(full_result !== 32'sd32770 ||
           overflow    !== 1'b1)

            $error("Positive overflow detection failed");

        else
            $display("PASS: positive overflow detected");

        // Minimum valid negative result
        // -32760 + (-8)*1 = -32768

        a   = -16'sd8;
        b   = 16'sd1;
        acc = -16'sd32760;

        #1;

        if(full_result !== -32'sd32768 ||
           result      !== 16'sh8000 ||
           overflow    !== 1'b0)

            $error("MAC failed at negative boundary");

        else
            $display("PASS: negative boundary = -32768");
        // Negative overflow
        // -32760 + (-10) = -32770

        a   = -16'sd10;
        b   = 16'sd1;
        acc = -16'sd32760;

        #1;

        if(full_result !== -32'sd32770 ||
           overflow    !== 1'b1)

            $error("Negative overflow detection failed");

        else
            $display("PASS: negative overflow detected");

        // Large multiplication
        // 300 * 200 + 10 = 60010
        // does not fit in signed 16-bit
        a   = 16'sd300;
        b   = 16'sd200;
        acc = 16'sd10;

        #1;

        if(full_result !== 32'sd60010 ||
           overflow    !== 1'b1)

            $error("Large MAC overflow failed");

        else
            $display("PASS: 300*200+10 = 60010, overflow detected");

        $finish;
    end
endmodule
