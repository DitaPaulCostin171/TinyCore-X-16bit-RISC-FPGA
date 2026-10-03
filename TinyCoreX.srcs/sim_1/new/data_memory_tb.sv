`timescale 1ns / 1ps
module data_memory_tb();
    parameter int DATA_WIDTH = 16;
    parameter int DEPTH = 256;
    parameter int ADDR_WIDTH = $clog2(DEPTH);

    logic clk;

    logic [ADDR_WIDTH-1:0] address;

    logic signed [DATA_WIDTH-1:0] write_data;
    logic write_en;

    logic signed [DATA_WIDTH-1:0] read_data;


    data_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .write_en(write_en),
        .read_data(read_data)
    );  
    
    initial begin
        clk=0;
        
        forever #5 clk=~clk;
    end
    
    initial begin

        address    = '0;
        write_data = '0;
        write_en   = 1'b0;


        // test1: write address 10 <- 25

        address    = 8'd10;
        write_data = 16'sd25;
        write_en   = 1'b1;

        @(posedge clk);
        #1;

        write_en = 1'b0;

        if(read_data !== 16'sd25)
            $error(
                "WRITE/READ failed: address 10 = %0d expected 25",
                read_data
            );
        else
            $display("PASS: address 10 = 25");


        // test2: write a negative value
        // address 20 <- -12

        @(negedge clk);

        address    = 8'd20;
        write_data = -16'sd12;
        write_en   = 1'b1;

        @(posedge clk);
        #1;

        write_en = 1'b0;

        if(read_data !== -16'sd12)
            $error(
                "SIGNED WRITE failed: address 20 = %0d expected -12",
                read_data
            );
        else
            $display("PASS: address 20 = -12");


        // test3: combinational read
        // switch address without waiting for clock

        address = 8'd10;
        #1;

        if(read_data !== 16'sd25)
            $error(
                "COMBINATIONAL READ failed: address 10 = %0d expected 25",
                read_data
            );
        else
            $display("PASS: combinational read address 10 = 25");


        address = 8'd20;
        #1;

        if(read_data !== -16'sd12)
            $error(
                "COMBINATIONAL READ failed: address 20 = %0d expected -12",
                read_data
            );
        else
            $display("PASS: combinational read address 20 = -12");


        // test4: write_en = 0
        // try to overwrite address 10 with 99

        @(negedge clk);

        address    = 8'd10;
        write_data = 16'sd99;
        write_en   = 1'b0;

        @(posedge clk);
        #1;

        if(read_data !== 16'sd25)
            $error(
                "WRITE ENABLE failed: address 10 = %0d expected 25",
                read_data
            );
        else
            $display("PASS: write_en=0 preserves address 10");


        // test5: overwrite address 10
        // 25 -> 100

        @(negedge clk);

        address    = 8'd10;
        write_data = 16'sd100;
        write_en   = 1'b1;

        @(posedge clk);
        #1;

        write_en = 1'b0;

        if(read_data !== 16'sd100)
            $error(
                "OVERWRITE failed: address 10 = %0d expected 100",
                read_data
            );
        else
            $display("PASS: address 10 overwritten with 100");


        // test6: address 20 must still contain -12

        address = 8'd20;
        #1;

        if(read_data !== -16'sd12)
            $error(
                "MEMORY INDEPENDENCE failed: address 20 = %0d expected -12",
                read_data
            );
        else
            $display("PASS: address 20 still contains -12");


        //test7: persistence after several clocks

        write_en = 1'b0;

        repeat(3)
            @(posedge clk);

        #1;

        address = 8'd10;
        #1;

        if(read_data !== 16'sd100)
            $error(
                "PERSISTENCE failed: address 10 = %0d expected 100",
                read_data
            );
        else
            $display("PASS: address 10 preserved after 3 clock cycles");


        address = 8'd20;
        #1;

        if(read_data !== -16'sd12)
            $error(
                "PERSISTENCE failed: address 20 = %0d expected -12",
                read_data
            );
        else
            $display("PASS: address 20 preserved after 3 clock cycles");
        $display("DATA MEMORY TESTS FINISHED");
        $finish;

    end
endmodule
