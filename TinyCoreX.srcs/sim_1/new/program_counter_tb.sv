`timescale 1ns / 1ps
module program_counter_tb();

parameter int ADDR_WIDTH=8;

logic clk;
logic rst;

logic pc_write;

logic [ADDR_WIDTH-1:0]next_pc;
logic [ADDR_WIDTH-1:0]pc;

program_counter #(.ADDR_WIDTH(ADDR_WIDTH))
        dut(
        .clk(clk),
        .rst(rst),
        .pc_write(pc_write),
        
        .next_pc(next_pc),
        .pc(pc)
        );
        
        initial begin
            clk=0;
            forever #5 clk=~clk;
        end
        
        initial begin
        
        rst=1'b1;
        pc_write=1'b0;
        next_pc='0;
        
        @(posedge clk);
        #1;

        if(pc !== 8'd0)
            $error("RESET failed: PC=%0d expected 0", pc);
        else
            $display("PASS: RESET -> PC=0");


        @(negedge clk);
        rst = 1'b0;
        
        // TEST2: WRITE
        // PC <- 25

        next_pc  = 8'd25;
        pc_write = 1'b1;

        // Before posedge PC must still be 0
        #1;

        if(pc !== 8'd0)
            $error("WRITE timing failed: PC changed before posedge");
        else
            $display("PASS: PC unchanged before posedge");


        @(posedge clk);
        #1;

        if(pc !== 8'd25)
            $error("WRITE failed: PC=%0d expected 25", pc);
        else
            $display("PASS: PC=25 after posedge");
            
        //TEST3:HOLD, next_pc changes but pc_write=0;
        
        @(negedge clk);
        
        next_pc=8'd100;
        pc_write=1'b0;
        
        @(posedge clk);
        #1;

        if(pc !== 8'd25)
            $error("HOLD failed: PC=%0d expected 25", pc);
        else
            $display("PASS: pc_write=0 preserves PC=25");
        
        //TEST4:second write
        //PC<-200
        
        @(negedge clk);

        next_pc  = 8'd200;
        pc_write = 1'b1;

        @(posedge clk);
        #1;

        if(pc !== 8'd200)
            $error("SECOND WRITE failed: PC=%0d expected 200", pc);
        else
            $display("PASS: PC overwritten with 200");
        
        
        //TEST5:RESET priority//rst>>>pc_write
        
        @(negedge clk);

        rst      = 1'b1;
        pc_write = 1'b1;
        next_pc  = 8'd77;

        @(posedge clk);
        #1;

        if(pc !== 8'd0)
            $error(
                "RESET PRIORITY failed: PC=%0d expected 0",
                pc
            );
        else
            $display("PASS: reset has priority over pc_write");
            
            
            $finish;
        end
        
endmodule
