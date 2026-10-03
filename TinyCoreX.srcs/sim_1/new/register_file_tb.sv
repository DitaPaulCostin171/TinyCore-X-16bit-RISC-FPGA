`timescale 1ns / 1ps

module register_file_tb();

parameter int DATA_WIDTH=16;
parameter int NUM_REGS=8;
parameter int ADDR_WIDTH=$clog2(NUM_REGS);

logic clk;
logic rst;

    logic [ADDR_WIDTH-1:0] read_addr1;
    logic [ADDR_WIDTH-1:0] read_addr2;

    logic [ADDR_WIDTH-1:0] write_addr;
    logic signed [DATA_WIDTH-1:0] write_data;
    logic write_en;

    logic signed [DATA_WIDTH-1:0] read_data1;
    logic signed [DATA_WIDTH-1:0] read_data2;


    register_file #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .NUM_REGS(NUM_REGS)
                    )dut(
                    .clk(clk),
                    .rst(rst),

                    .read_addr1(read_addr1),
                    .read_addr2(read_addr2),

                    .write_addr(write_addr),
                    .write_data(write_data),
                    .write_en(write_en),

                    .read_data1(read_data1),
                    .read_data2(read_data2)
                    );


        initial begin
            clk=0;
            forever #5 clk=~clk;//T=10ns, f=100MHz
        end


        initial begin

            rst = 1'b1;

            read_addr1 = '0;
            read_addr2 = '0;

            write_addr = '0;
            write_data = '0;
            write_en   = 1'b0;


            //TEST1: RESET

            @(posedge clk);
            @(negedge clk);

            rst=1'b0;

            read_addr1=3'd0;
            read_addr2=3'd7;

            #1;

            if(read_data1 !== 16'sd0 ||
               read_data2 !== 16'sd0)

                $error("RESET test failed");

            else
                $display("PASS: RESET");



            //TEST2: synchronous write R3 <- 25

            write_addr=3'd3;
            write_data=16'sd25;
            write_en=1'b1;

            read_addr1=3'd3;

            #1;

            if(read_data1 !== 16'sd0)

                $error("WRITE timing failed: R3 changed before posedge");

            else
                $display("PASS: R3 unchanged before posedge");


            @(posedge clk);
            #1;

            if(read_data1 !== 16'sd25)

                $error(
                    "WRITE failed: expected R3=25, got %0d",
                    read_data1
                );

            else
                $display("PASS: R3=25 after posedge");


            write_en=1'b0;



            //TEST3: write R5=-12 + simultaneous read R3/R5

            write_addr=3'd5;
            write_data=-16'sd12;
            write_en=1'b1;

            @(posedge clk);
            #1;

            write_en=1'b0;

            read_addr1=3'd3;
            read_addr2=3'd5;

            #1;

            if(read_data1 !== 16'sd25 ||
               read_data2 !== -16'sd12)

            begin

                $error(
                    "DUAL READ failed: R3=%0d expected 25, R5=%0d expected -12",
                    read_data1,
                    read_data2
                );

            end

            else begin

                $display(
                    "PASS: simultaneous read R3=25 and R5=-12"
                );

            end



            //TEST4: write_en=0, R3 unchanged

            write_addr = 3'd3;
            write_data = 16'sd99;
            write_en   = 1'b0;

            @(posedge clk);
            #1;

            read_addr1 = 3'd3;

            #1;

            if(read_data1 !== 16'sd25)

            begin

                $error(
                    "WRITE ENABLE test failed: R3=%0d expected 25",
                    read_data1
                );

            end

            else begin

                $display(
                    "PASS: write_en=0 preserves R3=25"
                );

            end



            //TEST5: persistence
            //R3 si R5 trebuie sa isi pastreze valorile
            //dupa mai multe clock-uri fara write

            write_en=1'b0;

            repeat(3)
                @(posedge clk);

            #1;

            read_addr1=3'd3;
            read_addr2=3'd5;

            #1;

            if(read_data1 !== 16'sd25 ||
               read_data2 !== -16'sd12)

            begin

                $error("PERSISTENCE failed: R3=%0d R5=%0d",read_data1,read_data2);
            end

            else begin
                $display("PASS: R3 and R5 preserved after 3 clock cycles");
            end
            //TEST6: overwrite R3
            //R3 = 25 -> R3 = 100

            write_addr=3'd3;
            write_data=16'sd100;
            write_en=1'b1;

            @(posedge clk);
            #1;

            write_en=1'b0;

            read_addr1=3'd3;

            #1;

            if(read_data1 !== 16'sd100)

            begin
                $error("OVERWRITE failed: R3=%0d expected 100",read_data1);
            end

            else begin
                $display("PASS: R3 overwritten from 25 to 100");
            end

            //TEST7: same register read on both ports
            read_addr1=3'd3;
            read_addr2=3'd3;
            #1;

            if(read_data1 !== 16'sd100 ||
               read_data2 !== 16'sd100)

            begin
                $error(
                    "SAME REGISTER READ failed: read1=%0d read2=%0d",
                    read_data1,
                    read_data2
                );
            end

            else begin
                $display("PASS: both read ports correctly read R3=100");
            end
            //TEST8: reset has priority over write
            rst=1'b1;

            write_addr=3'd3;
            write_data=16'sd777;
            write_en=1'b1;

            @(posedge clk);
            #1;

            write_en=1'b0;

            read_addr1=3'd3;
            read_addr2=3'd5;

            #1;

            if(read_data1 !== 16'sd0 ||
               read_data2 !== 16'sd0)

            begin

                $error("RESET PRIORITY failed: R3=%0d R5=%0d",read_data1,read_data2);
            end

            else begin

                $display("PASS: reset has priority over write");
            end

            @(negedge clk);
            rst=1'b0;

            //TEST9: verify all registers are zero after reset

            for(int i=0;i<NUM_REGS;i++)
            begin

                read_addr1=i;
                #1;

                if(read_data1 !== 16'sd0)

                begin

                    $error("FULL RESET failed: R%0d=%0d expected 0",i,read_data1);
                end
                else begin
                    $display("PASS: R%0d reset to 0",i);
                end
            end
            $display("REGISTER FILE TESTBENCH FINISHED");
            $finish;

        end

endmodule