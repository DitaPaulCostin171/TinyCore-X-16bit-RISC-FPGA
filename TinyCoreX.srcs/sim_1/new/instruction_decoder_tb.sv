`timescale 1ns / 1ps

module instruction_decoder_tb();

    logic [15:0] instruction;

    logic [4:0] opcode;

    logic [2:0] reg_field1;
    logic [2:0] reg_field2;
    logic [2:0] reg_field3;

    logic [7:0]  imm8;
    logic [4:0]  imm5;
    logic [10:0] imm11;


    instruction_decoder dut(
        .instruction(instruction),

        .opcode(opcode),

        .reg_field1(reg_field1),
        .reg_field2(reg_field2),
        .reg_field3(reg_field3),

        .imm8(imm8),
        .imm5(imm5),
        .imm11(imm11)
    );


    initial begin
        // TEST1: ADD R3, R1, R2
        // 00011 | 011 | 001 | 010 | 00
        instruction = 16'b00011_011_001_010_00;

        #1;

        if(opcode     !== 5'b00011 ||
           reg_field1 !== 3'b011   ||
           reg_field2 !== 3'b001   ||
           reg_field3 !== 3'b010)
        begin
            $error("ADD decode failed");
        end
        else begin
            $display("PASS: ADD R3,R1,R2");
        end

        // TEST2: MOVI R2, -7
        // opcode = 00001
        // Rd     = 010
        // imm8   = 11111001 = -7 in 2complement
        instruction = 16'b00001_010_11111001;

        #1;

        if(opcode     !== 5'b00001 ||
           reg_field1 !== 3'b010   ||
           imm8       !== 8'b11111001)
        begin
            $error("MOVI decode failed");
        end
        else begin
            $display("PASS: MOVI R2,-7");
        end
        // TEST3: BEQ R1, R2, -3
        // 01100 | 001 | 010 | 11101
        // imm5 = 11101 = -3

        instruction = 16'b01100_001_010_11101;

        #1;

        if(opcode     !== 5'b01100 ||
           reg_field1 !== 3'b001   ||
           reg_field2 !== 3'b010   ||
           imm5       !== 5'b11101)
        begin
            $error("BEQ decode failed");
        end
        else begin
            $display("PASS: BEQ R1,R2,-3");
        end

        // TEST4: JMP +20
        // opcode = 01011
        // imm11  = 20

        instruction = 16'b01011_00000010100;

        #1;

        if(opcode !== 5'b01011 ||
           imm11  !== 11'd20)
        begin
            $error("JMP decode failed");
        end
        else begin
            $display("PASS: JMP +20");
        end
        // TEST5: LOOP R7, 3
        // opcode = 01101
        // Rc     = R7
        // length = 3

        instruction = 16'b01101_111_00000011;

        #1;

        if(opcode     !== 5'b01101 ||
           reg_field1 !== 3'b111   ||
           imm8       !== 8'd3)
        begin
            $error("LOOP decode failed");
        end
        else begin
            $display("PASS: LOOP R7,3");
        end
        // TEST6: RCL R2
        // 10100 | 010 | 00000000

        instruction = 16'b10100_010_00000000;

        #1;

        if(opcode     !== 5'b10100 ||
           reg_field1 !== 3'b010)
        begin
            $error("RCL decode failed");
        end
        else begin
            $display("PASS: RCL R2");
        end
        $display("DECODER TESTS FINISHED");
        $finish;

    end

endmodule