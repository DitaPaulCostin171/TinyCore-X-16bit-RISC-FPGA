`timescale 1ns / 1ps

module instruction_decoder(
    input logic [15:0]instruction,

    output logic [4:0]opcode,

    output logic [2:0]reg_field1,
    output logic [2:0]reg_field2,
    output logic [2:0]reg_field3,

    output logic [7:0]imm8,
    output logic [4:0]imm5,
    output logic [10:0]imm11
);

    always_comb begin

        opcode = instruction[15:11];

        reg_field1 = instruction[10:8];
        reg_field2 = instruction[7:5];
        reg_field3 = instruction[4:2];

        imm8  = instruction[7:0];
        imm5  = instruction[4:0];
        imm11 = instruction[10:0];
    end
endmodule