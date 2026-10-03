`timescale 1ns / 1ps
module tinycore_benchmark_tb();

parameter int DATA_WIDTH=16;
parameter int ADDR_WIDTH=8;

logic clk;
logic rst;
logic halted;

integer cycle_count;
integer baseline_cycles;
integer mac_cycles;
integer hwloop_cycles;
integer i;

tinycore #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
)dut(
    .clk(clk),
    .rst(rst),
    .halted(halted)
);

initial begin
    clk=0;
    forever #5 clk=~clk;
end

always @(posedge clk)begin
    if(rst)
        cycle_count<=0;
    else
        cycle_count<=cycle_count+1;
end

task automatic clear_program;
    begin
        for(i=0;i<256;i=i+1)
            dut.imem.memory[i]=16'h0000;
    end
endtask

task automatic clear_data;
    begin
        for(i=0;i<256;i=i+1)
            dut.dmem.memory[i]=16'd0;
    end
endtask

task automatic load_vectors;
    begin
        dut.dmem.memory[0]=16'd2;
        dut.dmem.memory[1]=16'd3;
        dut.dmem.memory[2]=16'd4;
        dut.dmem.memory[3]=16'd5;
        
        dut.dmem.memory[16]=16'd1;
        dut.dmem.memory[17]=16'd2;
        dut.dmem.memory[18]=16'd3;
        dut.dmem.memory[19]=16'd4;
    end
endtask

task automatic reset_cpu;
    begin
        @(negedge clk);
        rst=1'b1;
        
        repeat(2)
            @(posedge clk);
        
        @(negedge clk);
        rst=1'b0;
    end
endtask

task automatic run_until_halt;
    begin
        while((halted!==1'b1) && (cycle_count<500))
            @(posedge clk);
        
        #1;
        
        if(halted!==1'b1)begin
            $error("processor did not reach HALT");
            $finish;
        end
    end
endtask

initial begin

    rst=1'b0;
    
    #1;
    
    
    //TEST 1
    //dot product cu MUL + ADD si software loop
    //R1 pointer A
    //R2 pointer B
    //R3 accumulator
    //R4 valoare A si rezultat MUL
    //R5 valoare B
    //R6 loop counter
    //R7 constant 1
    
    clear_program();
    clear_data();
    load_vectors();
    
    dut.imem.memory[0]=16'h0900;
    dut.imem.memory[1]=16'h0A10;
    dut.imem.memory[2]=16'h0B00;
    dut.imem.memory[3]=16'h0E04;
    dut.imem.memory[4]=16'h0F01;
    
    dut.imem.memory[5]=16'h4C20;
    dut.imem.memory[6]=16'h4D40;
    dut.imem.memory[7]=16'h4494;
    dut.imem.memory[8]=16'h1B70;
    dut.imem.memory[9]=16'h193C;
    dut.imem.memory[10]=16'h1A5C;
    dut.imem.memory[11]=16'h26DC;
    dut.imem.memory[12]=16'h6601;
    dut.imem.memory[13]=16'h5FF7;
    
    dut.imem.memory[14]=16'hB000;
    
    reset_cpu();
    run_until_halt();
    
    baseline_cycles=cycle_count;
    
    if(dut.rf.registers[3]!==16'sd40)
        $error("TEST 1 failed, expected R3=40, got %0d",
                dut.rf.registers[3]);
    
    $display("TEST 1");
    $display("MUL + ADD + software loop");
    $display("R3=%0d",dut.rf.registers[3]);
    $display("cycles=%0d",baseline_cycles);
    
    
    //TEST 2
    //dot product cu MAC si software loop
    //MUL + ADD sunt inlocuite de o singura instructiune MAC
    
    clear_program();
    clear_data();
    load_vectors();
    
    dut.imem.memory[0]=16'h0900;
    dut.imem.memory[1]=16'h0A10;
    dut.imem.memory[2]=16'h0B00;
    dut.imem.memory[3]=16'h0E04;
    dut.imem.memory[4]=16'h0F01;
    
    dut.imem.memory[5]=16'h4C20;
    dut.imem.memory[6]=16'h4D40;
    dut.imem.memory[7]=16'h7394;
    dut.imem.memory[8]=16'h193C;
    dut.imem.memory[9]=16'h1A5C;
    dut.imem.memory[10]=16'h26DC;
    dut.imem.memory[11]=16'h6601;
    dut.imem.memory[12]=16'h5FF8;
    
    dut.imem.memory[13]=16'hB000;
    
    reset_cpu();
    run_until_halt();
    
    mac_cycles=cycle_count;
    
    if(dut.rf.registers[3]!==16'sd40)
        $error("TEST 2 failed, expected R3=40, got %0d",
                dut.rf.registers[3]);
    
    $display("TEST 2");
    $display("MAC + software loop");
    $display("R3=%0d",dut.rf.registers[3]);
    $display("cycles=%0d",mac_cycles);
    
    
    //TEST 3
    //dot product cu MAC si hardware LOOP
    //R6 contine numarul de iteratii
    //LOOP repeta automat urmatoarele 5 instructiuni
    
    clear_program();
    clear_data();
    load_vectors();
    
    dut.imem.memory[0]=16'h0900;
    dut.imem.memory[1]=16'h0A10;
    dut.imem.memory[2]=16'h0B00;
    dut.imem.memory[3]=16'h0E04;
    dut.imem.memory[4]=16'h0F01;
    
    dut.imem.memory[5]=16'h6E05;
    
    dut.imem.memory[6]=16'h4C20;
    dut.imem.memory[7]=16'h4D40;
    dut.imem.memory[8]=16'h7394;
    dut.imem.memory[9]=16'h193C;
    dut.imem.memory[10]=16'h1A5C;
    
    dut.imem.memory[11]=16'hB000;
    
    reset_cpu();
    run_until_halt();
    
    hwloop_cycles=cycle_count;
    
    if(dut.rf.registers[3]!==16'sd40)
        $error("TEST 3 failed, expected R3=40, got %0d",
                dut.rf.registers[3]);
    
    if(dut.loop_active!==1'b0)
        $error("TEST 3 loop_active should be 0");
    
    $display("TEST 3");
    $display("MAC + hardware LOOP");
    $display("R3=%0d",dut.rf.registers[3]);
    $display("cycles=%0d",hwloop_cycles);
    
    
    //comparatia finala intre cele 3 implementari
    
    $display("");
    $display("BENCHMARK");
    $display("Baseline cycles = %0d",baseline_cycles);
    $display("MAC cycles = %0d",mac_cycles);
    $display("MAC + LOOP cycles = %0d",hwloop_cycles);
    
    $display("MAC speedup = %0.3f x",
        $itor(baseline_cycles)/$itor(mac_cycles));
        
    $display("MAC + LOOP speedup = %0.3f x",
        $itor(baseline_cycles)/$itor(hwloop_cycles));
    
    $finish;

end

endmodule