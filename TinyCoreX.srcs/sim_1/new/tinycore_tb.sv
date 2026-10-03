`timescale 1ns / 1ps
module tinycore_tb();

parameter int DATA_WIDTH=16;
parameter int ADDR_WIDTH=8;

logic clk;
logic rst;
logic halted;

integer cycle_count;
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
        while((halted!==1'b1) && (cycle_count<100))
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
    //MOVI R1,3
    //MOVI R2,4
    //ADD R3,R1,R2
    //MUL R4,R1,R2
    //MOVI R5,10
    //MAC R5,R1,R2
    //HALT
    
    clear_program();
    
    dut.imem.memory[0]=16'h0903;
    dut.imem.memory[1]=16'h0A04;
    dut.imem.memory[2]=16'h1B28;
    dut.imem.memory[3]=16'h4428;
    dut.imem.memory[4]=16'h0D0A;
    dut.imem.memory[5]=16'h7528;
    dut.imem.memory[6]=16'hB000;
    
    reset_cpu();
    run_until_halt();
    
    if(dut.rf.registers[1]!==16'sd3)
        $error("TEST 1 R1 failed, got %0d",
                dut.rf.registers[1]);
    
    if(dut.rf.registers[2]!==16'sd4)
        $error("TEST 1 R2 failed, got %0d",
                dut.rf.registers[2]);
    
    if(dut.rf.registers[3]!==16'sd7)
        $error("TEST 1 ADD failed, R3=%0d",
                dut.rf.registers[3]);
    
    if(dut.rf.registers[4]!==16'sd12)
        $error("TEST 1 MUL failed, R4=%0d",
                dut.rf.registers[4]);
    
    if(dut.rf.registers[5]!==16'sd22)
        $error("TEST 1 MAC failed, R5=%0d",
                dut.rf.registers[5]);
    
    if(dut.pc!==8'd6)
        $error("TEST 1 PC failed, expected 6, got %0d",
                dut.pc);
    
    $display("TEST 1");
    $display("R1=%0d",dut.rf.registers[1]);
    $display("R2=%0d",dut.rf.registers[2]);
    $display("R3=%0d",dut.rf.registers[3]);
    $display("R4=%0d",dut.rf.registers[4]);
    $display("R5=%0d",dut.rf.registers[5]);
    $display("cycles=%0d",cycle_count);
    
    
    //TEST 2
    //MOVI R1,11
    //STORE R1,[R0+5]
    //LOAD R2,[R0+5]
    //SHL R2
    //HALT
    
    clear_program();
    
    dut.imem.memory[0]=16'h090B;
    dut.imem.memory[1]=16'h5105;
    dut.imem.memory[2]=16'h4A05;
    dut.imem.memory[3]=16'h7A00;
    dut.imem.memory[4]=16'hB000;
    
    reset_cpu();
    run_until_halt();
    
    if(dut.rf.registers[1]!==16'sd11)
        $error("TEST 2 R1 failed, got %0d",
                dut.rf.registers[1]);
    
    if(dut.dmem.memory[5]!==16'sd11)
        $error("TEST 2 STORE failed, memory[5]=%0d",
                dut.dmem.memory[5]);
    
    if(dut.rf.registers[2]!==16'sd22)
        $error("TEST 2 LOAD or SHL failed, R2=%0d",
                dut.rf.registers[2]);
    
    if(dut.flag_zero!==1'b0)
        $error("TEST 2 zero flag failed");
    
    if(dut.flag_negative!==1'b0)
        $error("TEST 2 negative flag failed");
    
    if(dut.flag_carry!==1'b0)
        $error("TEST 2 carry flag failed");
    
    if(dut.pc!==8'd4)
        $error("TEST 2 PC failed, expected 4, got %0d",
                dut.pc);
    
    $display("TEST 2");
    $display("R1=%0d",dut.rf.registers[1]);
    $display("MEM[5]=%0d",dut.dmem.memory[5]);
    $display("R2=%0d",dut.rf.registers[2]);
    $display("Z=%0b",dut.flag_zero);
    $display("N=%0b",dut.flag_negative);
    $display("C=%0b",dut.flag_carry);
    $display("cycles=%0d",cycle_count);
    
    
    //TEST 3
    //MOVI R1,2
    //MOVI R2,4
    //MOVI R3,0
    //LOOP R2,1
    //ADD R3,R3,R1
    //HALT
    //ADD trebuie executat de 4 ori
    
    clear_program();
    
    dut.imem.memory[0]=16'h0902;
    dut.imem.memory[1]=16'h0A04;
    dut.imem.memory[2]=16'h0B00;
    dut.imem.memory[3]=16'h6A01;
    dut.imem.memory[4]=16'h1B64;
    dut.imem.memory[5]=16'hB000;
    
    reset_cpu();
    run_until_halt();
    
    if(dut.rf.registers[1]!==16'sd2)
        $error("TEST 3 R1 failed, got %0d",
                dut.rf.registers[1]);
    
    if(dut.rf.registers[2]!==16'sd4)
        $error("TEST 3 R2 failed, got %0d",
                dut.rf.registers[2]);
    
    if(dut.rf.registers[3]!==16'sd8)
        $error("TEST 3 LOOP failed, expected R3=8, got %0d",
                dut.rf.registers[3]);
    
    if(dut.loop_active!==1'b0)
        $error("TEST 3 loop_active should be 0");
    
    if(dut.pc!==8'd5)
        $error("TEST 3 PC failed, expected 5, got %0d",
                dut.pc);
    
    $display("TEST 3");
    $display("R1=%0d",dut.rf.registers[1]);
    $display("R2=%0d",dut.rf.registers[2]);
    $display("R3=%0d",dut.rf.registers[3]);
    $display("loop_active=%0b",dut.loop_active);
    $display("cycles=%0d",cycle_count);
    
    $finish;
    
end

endmodule