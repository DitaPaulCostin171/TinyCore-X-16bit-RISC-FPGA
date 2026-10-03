`timescale 1ns / 1ps
module instruction_memory_tb();

    parameter int DATA_WIDTH = 16;
    parameter int DEPTH = 256;
    parameter int ADDR_WIDTH = $clog2(DEPTH);

    logic [ADDR_WIDTH-1:0] address;
    logic [DATA_WIDTH-1:0] instruction;


    instruction_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .INIT_FILE("test_program.mem")
    ) dut (
        .address(address),
        .instruction(instruction)
    );


    initial begin
    // TEST1: address 0
        address = 8'd0;
        #1;

        if(instruction !== 16'h1B28)
            $error(
                "ADDRESS 0 failed: got %h expected 1B28",
                instruction
            );
        else
            $display("PASS: address 0 -> 1B28");


        // TEST2: address 1
        address = 8'd1;
        #1;

        if(instruction !== 16'h0AF9)
            $error(
                "ADDRESS 1 failed: got %h expected 0AF9",
                instruction
            );
        else
            $display("PASS: address 1 -> 0AF9");


        // TEST3: address 2
        address = 8'd2;
        #1;

        if(instruction !== 16'hA200)
            $error(
                "ADDRESS 2 failed: got %h expected A200",
                instruction
            );
        else
            $display("PASS: address 2 -> A200");


        // TEST4: address 3
        address = 8'd3;
        #1;

        if(instruction !== 16'h7C00)
            $error(
                "ADDRESS 3 failed: got %h expected 7C00",
                instruction
            );
        else
            $display("PASS: address 3 -> 7C00");


        // TEST5: address 4
        address = 8'd4;
        #1;

        if(instruction !== 16'h615D)
            $error(
                "ADDRESS 4 failed: got %h expected 615D",
                instruction
            );
        else
            $display("PASS: address 4 -> 615D");
    end
endmodule
