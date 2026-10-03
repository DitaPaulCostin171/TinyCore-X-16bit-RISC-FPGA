`timescale 1ns / 1ps
module loop_controller_tb();

parameter int ADDR_WIDTH=8;
parameter int DATA_WIDTH=16;

logic clk;
logic rst;

logic loop_setup;

logic [ADDR_WIDTH-1:0]start_address;
logic [7:0]body_length;
logic [DATA_WIDTH-1:0]iterations;

logic [ADDR_WIDTH-1:0]current_pc;
logic instruction_done;

logic loop_active;
logic loop_jump;
logic [ADDR_WIDTH-1:0]loop_target;

loop_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
        )dut(
            .clk(clk),
            .rst(rst),
            
            .loop_setup(loop_setup),
            
            .start_address(start_address),
            .body_length(body_length),
            .iterations(iterations),
            
            .current_pc(current_pc),
            .instruction_done(instruction_done),
            
            .loop_active(loop_active),
            .loop_jump(loop_jump),
            .loop_target(loop_target)
        );
        
        //T=10ns
        initial begin
            clk=0;
            forever #5 clk=~clk;
        end

        initial begin
            rst=0;
            loop_setup=0;
            start_address=0;
            body_length=0;
            iterations=0;
            current_pc=0;
            instruction_done=0;
            
            //reset
            @(negedge clk);
                rst=1;
            @(posedge clk);
                #1;
                
            if(loop_active)
                $error("reset failed:loop active not 0");
                
            else $display("reset test passed");
            
            @(negedge clk);
            rst=0;
            
            //loop setup
            //start=21
            //length=3
            //iterations=4
            
            //loop end = 21+3-1=23
            
            start_address = 8'd21;
            body_length = 8'd3;
            iterations = 16'd4;
            loop_setup = 1'b1;
            
            @(posedge clk);
            #1;
            loop_setup=1'b0;
            
            if(loop_active!== 1'b1)
                $error("loop setup failed, loop should be active");
            else
                $display("pass: loop setup");
                
            if(loop_target !== 8'd21)
                $error("loop target should be 21, got %0d", loop_target);
            else 
                $display("loop target = 21");
                
            //pc=21
            //not the end of loop->no jmp
            
            current_pc       = 8'd21;
            instruction_done = 1'b1;
    
            #1;
    
            if(loop_jump !== 1'b0)
                $error("Unexpected jump at PC 21");
            else
                $display("PASS no jump at PC 21");
    
            instruction_done = 1'b0;
            
            //pc=22
            //no end
            
            current_pc       = 8'd22;
            instruction_done = 1'b1;
    
            #1;
    
            if(loop_jump !== 1'b0)
                $error("Unexpected jump at PC 22");
            else
                $display("PASS: no jump at PC 22");
    
            instruction_done = 1'b0;
            
            //iteration 1 ends
            //pc=23
            //count 4->3
            //jump->21
            
            @(negedge clk);

            current_pc       = 8'd23;
            instruction_done = 1'b1;
    
            #1;
    
            if(loop_jump !== 1'b1)
                $error("Iteration 1: loop_jump should be 1");
    
            if(loop_target !== 8'd21)
                $error("Iteration 1: target should be 21");
    
            @(posedge clk);
            #1;
    
            if(dut.loop_count !== 16'd3)
                $error("Iteration 1: count expected 3, got %0d",
                        dut.loop_count);
            else
                $display("PASS: iteration 1 -> count = 3, jump to 21");
    
            @(negedge clk);
            instruction_done = 1'b0;
            
            //iteration 2 ends, count 3->2
            current_pc       = 8'd23;
            instruction_done = 1'b1;
    
            #1;
    
            if(loop_jump !== 1'b1)
                $error("Iteration 2: loop_jump should be 1");
    
            @(posedge clk);
            #1;
    
            if(dut.loop_count !== 16'd2)
                $error("Iteration 2: count expected 2, got %0d",
                        dut.loop_count);
            else
                $display("PASS: iteration 2 -> count = 2, jump to 21");
    
            @(negedge clk);
            instruction_done = 1'b0;
                
            //iteration 3 ends, count 2->1
            current_pc       = 8'd23;
            instruction_done = 1'b1;
    
            #1;
    
            if(loop_jump !== 1'b1)
                $error("Iteration 3: loop_jump should be 1");
    
            @(posedge clk);
            #1;
    
            if(dut.loop_count !== 16'd1)
                $error("Iteration 3: count expected 1, got %0d",
                        dut.loop_count);
            else
                $display("PASS: iteration 3 -> count = 1, jump to 21");
    
            @(negedge clk);
            instruction_done = 1'b0;
            //iteration 4 ends    
            // count = 1
            // NO jump, loop ends    
            current_pc       = 8'd23;
            instruction_done = 1'b1;
    
            #1;
    
            if(loop_jump !== 1'b0)
                $error("Iteration 4: loop_jump should be 0");
            else
                $display("PASS: final iteration produces no jump");
    
            @(posedge clk);
            #1;
    
            if((loop_active !== 1'b0) ||
               (dut.loop_count !== 16'd0))
            begin
                $error("Loop did not finish correctly: active=%b count=%0d",
                       loop_active, dut.loop_count);
            end
            else begin
                $display("PASS: loop finished after exactly 4 iterations");
            end
            @(negedge clk);
            instruction_done = 1'b0;
            
            //one iteration
            //iterations=1
            //one exec and 0 jumps
            
            start_address=8'd40;
            body_length=8'd2;
            iterations=16'd1;
            loop_setup=1'b1;
            
            @(posedge clk);
            #1;
            
            @(negedge clk);
            loop_setup=1'b0;
            
            current_pc=8'd41;
            instruction_done=1'b1;
            
            #1;
            
            if(loop_jump!==1'b0)
                $error("single iteration should not jump");
                
            @(posedge clk);
            #1;
            
            if(loop_active !== 1'b0)
                $error("single iteration loop should finish");
            else $display("pass: single iteration loop");
            
            $display("loop controller tests finished");
            
            $finish;
        end
endmodule
