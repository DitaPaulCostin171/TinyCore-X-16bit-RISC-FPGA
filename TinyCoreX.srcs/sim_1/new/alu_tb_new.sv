`timescale 1ns / 1ps

module alu_tb_new();

    parameter int DATA_WIDTH = 16;

    logic signed [DATA_WIDTH-1:0] a;
    logic signed [DATA_WIDTH-1:0] b;
    logic [3:0] alu_op;
    logic carry_in;

    logic signed [DATA_WIDTH-1:0] result;
    logic zero;
    logic negative;
    logic carry_out;
    logic overflow;

    localparam logic [3:0]
        ALU_ADD = 4'b0000,
        ALU_SUB = 4'b0001,
        ALU_AND = 4'b0010,
        ALU_OR  = 4'b0011,
        ALU_XOR = 4'b0100,
        ALU_SHL = 4'b0101,
        ALU_SHR = 4'b0110,
        ALU_SAR = 4'b0111,
        ALU_ROL = 4'b1000,
        ALU_ROR = 4'b1001,
        ALU_RCL = 4'b1010,
        ALU_RCR = 4'b1011;


    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .carry_in(carry_in),

        .result(result),
        .zero(zero),
        .negative(negative),
        .carry_out(carry_out),
        .overflow(overflow)
    );


    integer tests;
    integer errors;


    task automatic check_alu(
        input logic signed [DATA_WIDTH-1:0] test_a,
        input logic signed [DATA_WIDTH-1:0] test_b,
        input logic [3:0] test_op,
        input logic test_carry_in,

        input logic signed [DATA_WIDTH-1:0] expected_result,
        input logic expected_zero,
        input logic expected_negative,
        input logic expected_carry,
        input logic expected_overflow,

        input string test_name
    );

    begin

        a        = test_a;
        b        = test_b;
        alu_op   = test_op;
        carry_in = test_carry_in;

        #1;

        tests = tests + 1;

        if (
            result    !== expected_result ||
            zero      !== expected_zero ||
            negative  !== expected_negative ||
            carry_out !== expected_carry ||
            overflow  !== expected_overflow
        )
        begin

            errors = errors + 1;

            $error(
                "FAIL: %s | result=%h expected=%h | Z=%b/%b | N=%b/%b | C=%b/%b | V=%b/%b",
                test_name,
                result, expected_result,
                zero, expected_zero,
                negative, expected_negative,
                carry_out, expected_carry,
                overflow, expected_overflow
            );

        end

        else begin
            $display("PASS: %s", test_name);
        end

    end

    endtask


    initial begin

        tests  = 0;
        errors = 0;

        a        = '0;
        b        = '0;
        alu_op   = ALU_ADD;
        carry_in = 1'b0;

        // ADD

        check_alu(
            16'sd7,
            16'sd5,
            ALU_ADD,
            1'b0,

            16'sd12,
            1'b0,
            1'b0,
            1'b0,
            1'b0,

            "ADD 7 + 5"
        );


        check_alu(
            16'hFFFF,
            16'h0001,
            ALU_ADD,
            1'b0,

            16'h0000,
            1'b1,
            1'b0,
            1'b1,
            1'b0,

            "ADD FFFF + 1"
        );


        check_alu(
            16'sd32767,
            16'sd1,
            ALU_ADD,
            1'b0,

            16'h8000,
            1'b0,
            1'b1,
            1'b0,
            1'b1,

            "ADD 32767 + 1 overflow"
        );


        check_alu(
            16'h8000,
            16'hFFFF,
            ALU_ADD,
            1'b0,

            16'h7FFF,
            1'b0,
            1'b0,
            1'b1,
            1'b1,

            "ADD -32768 + (-1)"
        );

        // SUB

        check_alu(
            16'sd7,
            16'sd3,
            ALU_SUB,
            1'b0,

            16'sd4,
            1'b0,
            1'b0,
            1'b1,
            1'b0,

            "SUB 7 - 3"
        );


        check_alu(
            16'sd3,
            16'sd7,
            ALU_SUB,
            1'b0,

            16'hFFFC,
            1'b0,
            1'b1,
            1'b0,
            1'b0,

            "SUB 3 - 7"
        );


        check_alu(
            16'sd5,
            16'sd5,
            ALU_SUB,
            1'b0,

            16'h0000,
            1'b1,
            1'b0,
            1'b1,
            1'b0,

            "SUB 5 - 5"
        );


        check_alu(
            16'h8000,
            16'h0001,
            ALU_SUB,
            1'b0,

            16'h7FFF,
            1'b0,
            1'b0,
            1'b1,
            1'b1,

            "SUB -32768 - 1"
        );

        // AND

        check_alu(
            16'hAAAA,
            16'h0F0F,
            ALU_AND,
            1'b1,

            16'h0A0A,
            1'b0,
            1'b0,
            1'b1,
            1'b0,

            "AND AAAA & 0F0F"
        );


        check_alu(
            16'hF000,
            16'h0FFF,
            ALU_AND,
            1'b0,

            16'h0000,
            1'b1,
            1'b0,
            1'b0,
            1'b0,

            "AND produces zero"
        );

        // OR

        check_alu(
            16'hAAAA,
            16'h0F0F,
            ALU_OR,
            1'b1,

            16'hAFAF,
            1'b0,
            1'b1,
            1'b1,
            1'b0,

            "OR AAAA | 0F0F"
        );

        // XOR

        check_alu(
            16'hAAAA,
            16'h0F0F,
            ALU_XOR,
            1'b0,

            16'hA5A5,
            1'b0,
            1'b1,
            1'b0,
            1'b0,

            "XOR AAAA ^ 0F0F"
        );


        check_alu(
            16'h1234,
            16'h1234,
            ALU_XOR,
            1'b1,

            16'h0000,
            1'b1,
            1'b0,
            1'b1,
            1'b0,

            "XOR produces zero"
        );

        // SHL
        check_alu(
            16'h8001,
            16'h0000,
            ALU_SHL,
            1'b0,

            16'h0002,
            1'b0,
            1'b0,
            1'b1,
            1'b0,

            "SHL 8001"
        );


        check_alu(
            16'h4000,
            16'h0000,
            ALU_SHL,
            1'b0,

            16'h8000,
            1'b0,
            1'b1,
            1'b0,
            1'b0,

            "SHL 4000"
        );

        // SHR

        check_alu(
            16'h8001,
            16'h0000,
            ALU_SHR,
            1'b0,

            16'h4000,
            1'b0,
            1'b0,
            1'b1,
            1'b0,

            "SHR 8001"
        );


        check_alu(
            16'h0002,
            16'h0000,
            ALU_SHR,
            1'b0,

            16'h0001,
            1'b0,
            1'b0,
            1'b0,
            1'b0,

            "SHR 0002"
        );

        // SAR

        check_alu(
            16'h8001,
            16'h0000,
            ALU_SAR,
            1'b0,

            16'hC000,
            1'b0,
            1'b1,
            1'b1,
            1'b0,

            "SAR 8001"
        );


        check_alu(
            16'h7FFE,
            16'h0000,
            ALU_SAR,
            1'b0,

            16'h3FFF,
            1'b0,
            1'b0,
            1'b0,
            1'b0,

            "SAR 7FFE"
        );

        // ROL

        check_alu(
            16'h8001,
            16'h0000,
            ALU_ROL,
            1'b0,

            16'h0003,
            1'b0,
            1'b0,
            1'b1,
            1'b0,

            "ROL 8001"
        );


        check_alu(
            16'h4001,
            16'h0000,
            ALU_ROL,
            1'b0,

            16'h8002,
            1'b0,
            1'b1,
            1'b0,
            1'b0,

            "ROL 4001"
        );
        // ROR

        check_alu(
            16'h8001,
            16'h0000,
            ALU_ROR,
            1'b0,

            16'hC000,
            1'b0,
            1'b1,
            1'b1,
            1'b0,

            "ROR 8001"
        );


        check_alu(
            16'h8000,
            16'h0000,
            ALU_ROR,
            1'b0,

            16'h4000,
            1'b0,
            1'b0,
            1'b0,
            1'b0,

            "ROR 8000"
        );

        // RCL

        check_alu(
            16'h8001,
            16'h0000,
            ALU_RCL,
            1'b0,

            16'h0002,
            1'b0,
            1'b0,
            1'b1,
            1'b0,

            "RCL 8001 C=0"
        );


        check_alu(
            16'h0001,
            16'h0000,
            ALU_RCL,
            1'b1,

            16'h0003,
            1'b0,
            1'b0,
            1'b0,
            1'b0,

            "RCL 0001 C=1"
        );

        // RCR

        check_alu(
            16'h8001,
            16'h0000,
            ALU_RCR,
            1'b0,

            16'h4000,
            1'b0,
            1'b0,
            1'b1,
            1'b0,

            "RCR 8001 C=0"
        );


        check_alu(
            16'h0002,
            16'h0000,
            ALU_RCR,
            1'b1,

            16'h8001,
            1'b0,
            1'b1,
            1'b0,
            1'b0,

            "RCR 0002 C=1"
        );

        // INVALID OPERATION

        check_alu(
            16'h1234,
            16'h5678,
            4'b1111,
            1'b1,

            16'h0000,
            1'b1,
            1'b0,
            1'b1,
            1'b0,

            "Invalid ALU operation"
        );
        // SUMMARY

        $display("");
        $display("--------------------------------------");
        $display("Tests run : %0d", tests);
        $display("Passed    : %0d", tests - errors);
        $display("Errors    : %0d", errors);
        $display("--------------------------------------");

        if (errors == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("SOME ALU TESTS FAILED");

        $finish;

    end

endmodule