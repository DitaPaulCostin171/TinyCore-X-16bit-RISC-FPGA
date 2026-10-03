`timescale 1ns / 1ps

module flags_register_tb();

    logic clk;
    logic rst;

    logic z_in;
    logic n_in;
    logic c_in;
    logic of_in;

    logic z_we;
    logic n_we;
    logic c_we;
    logic v_we;

    logic zero;
    logic negative;
    logic carry;
    logic overflow;


    flags_register dut(
        .clk(clk),
        .rst(rst),

        .z_in(z_in),
        .n_in(n_in),
        .c_in(c_in),
        .of_in(of_in),

        .z_we(z_we),
        .n_we(n_we),
        .c_we(c_we),
        .v_we(v_we),

        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );
    
    initial begin
        clk=0;
        forever #5 clk=~clk;
    end
    
    initial begin
        rst=1'b1;
        
        z_in=1'b0;
        n_in=1'b0;
        c_in=1'b0;
        of_in=1'b0;
        
        z_we=1'b0;
        n_we=1'b0;
        c_we=1'b0;
        v_we=1'b0;
        
        //test1: reset
        
        @(posedge clk)
        
        #1;
        
        if(zero!==1'b0 ||
            negative!==1'b0 ||
            carry !== 1'b0 ||
            overflow !== 1'b0)begin
                $error("RESET test failed");
            end
            
        else begin
            $display("T1 reset test pass");
            
            
        
        @(negedge clk);
        rst=1'b0;
        
        //test2: write all flags  zncv=1011
        
        z_in  = 1'b1;
        n_in  = 1'b0;
        c_in  = 1'b1;
        of_in = 1'b1;

        z_we = 1'b1;
        n_we = 1'b1;
        c_we = 1'b1;
        v_we = 1'b1;

        @(posedge clk);
        #1;

        if(zero !== 1'b1 ||
           negative !== 1'b0 ||
           carry !== 1'b1 ||
           overflow !== 1'b1)
        begin
            $error("FULL WRITE failed");
        end
        else begin
            $display("PASS: all flags written correctly");
        end
        
        
        //test3: update only z and n, c and v unchanged
        
        @(negedge clk);

        z_in  = 1'b0;
        n_in  = 1'b1;
        c_in  = 1'b0;
        of_in = 1'b0;

        z_we = 1'b1;
        n_we = 1'b1;
        c_we = 1'b0;
        v_we = 1'b0;

        @(posedge clk);
        #1;

        if(zero !== 1'b0 ||
           negative !== 1'b1 ||
           carry !== 1'b1 ||
           overflow !== 1'b1)
        begin
            $error(
                "PARTIAL WRITE failed: Z=%b N=%b C=%b V=%b",
                zero, negative, carry, overflow
            );
        end
        else begin
            $display("PASS: partial update preserves C and V");
        end
        
        // test: no write enables

        @(negedge clk);

        z_in  = 1'b1;
        n_in  = 1'b0;
        c_in  = 1'b0;
        of_in = 1'b0;

        z_we = 1'b0;
        n_we = 1'b0;
        c_we = 1'b0;
        v_we = 1'b0;

        @(posedge clk);
        #1;

        if(zero !== 1'b0 ||
           negative !== 1'b1 ||
           carry !== 1'b1 ||
           overflow !== 1'b1)
        begin
            $error("hold test failed");
        end
        else begin
            $display("PASS: flags preserved when all write enables are 0");
        end


        // test5: update only carry

        @(negedge clk);

        c_in = 1'b0;

        c_we = 1'b1;

        @(posedge clk);
        #1;

        if(carry !== 1'b0 ||
           zero !== 1'b0 ||
           negative !== 1'b1 ||
           overflow !== 1'b1)
        begin
            $error("CARRY-ONLY update failed");
        end
        else begin
            $display("PASS: carry updated independently");
        end
        end
        
        // test6: reset priority over write
        // try to write 1111 while reset is active

        @(negedge clk);

        rst = 1'b1;

        z_in  = 1'b1;
        n_in  = 1'b1;
        c_in  = 1'b1;
        of_in = 1'b1;

        z_we = 1'b1;
        n_we = 1'b1;
        c_we = 1'b1;
        v_we = 1'b1;

        @(posedge clk);
        #1;

        if(zero !== 1'b0 ||
           negative !== 1'b0 ||
           carry !== 1'b0 ||
           overflow !== 1'b0)
        begin
            $error("RESET PRIORITY failed");
        end
        else begin
            $display("PASS: reset has priority over flag writes");
        end
        
        $display("FLAGS REGISTER TESTS FINISHED");
        $finish();
    end
endmodule
