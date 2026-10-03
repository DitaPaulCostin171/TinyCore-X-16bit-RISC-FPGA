`timescale 1ns / 1ps
module control_unit_tb();
logic clk;
    logic rst;
    logic [4:0]opcode;

    logic ir_write;

    logic reg_write;
    logic [3:0]alu_op;

    logic z_we;
    logic n_we;
    logic c_we;
    logic v_we;

    logic instruction_done;
    logic pc_write;

    logic [2:0]wb_sel;

    logic mac_latch;

    logic [1:0]rf_addr1_sel;
    logic [1:0]rf_addr2_sel;

    logic alu_b_imm;
    logic mem_write;
    logic jump_en;
    logic branch_en;
    logic loop_setup;
    logic halted;


    localparam logic [4:0]
        OP_NOP   = 5'b00000,
        OP_MOVI  = 5'b00001,
        OP_MOV   = 5'b00010,
        OP_ADD   = 5'b00011,
        OP_SUB   = 5'b00100,
        OP_AND   = 5'b00101,
        OP_OR    = 5'b00110,
        OP_XOR   = 5'b00111,
        OP_MUL   = 5'b01000,
        OP_LOAD  = 5'b01001,
        OP_STORE = 5'b01010,
        OP_JMP   = 5'b01011,
        OP_BEQ   = 5'b01100,
        OP_LOOP  = 5'b01101,
        OP_MAC   = 5'b01110,
        OP_SHL   = 5'b01111,
        OP_SHR   = 5'b10000,
        OP_SAR   = 5'b10001,
        OP_ROL   = 5'b10010,
        OP_ROR   = 5'b10011,
        OP_RCL   = 5'b10100,
        OP_RCR   = 5'b10101,
        OP_HALT  = 5'b10110;

    localparam logic [2:0]
        WB_ALU = 3'b000,
        WB_MOV = 3'b001,
        WB_IMM = 3'b010,
        WB_MUL = 3'b011,
        WB_MAC = 3'b100,
        WB_MEM = 3'b101;

    localparam logic [1:0]
        RF_F1 = 2'b00,
        RF_F2 = 2'b01,
        RF_F3 = 2'b10;


    control_unit dut(
        .clk(clk),
        .rst(rst),

        .opcode(opcode),

        .ir_write(ir_write),

        .reg_write(reg_write),
        .alu_op(alu_op),

        .z_we(z_we),
        .n_we(n_we),
        .c_we(c_we),
        .v_we(v_we),

        .instruction_done(instruction_done),
        .pc_write(pc_write),

        .wb_sel(wb_sel),

        .mac_latch(mac_latch),

        .rf_addr1_sel(rf_addr1_sel),
        .rf_addr2_sel(rf_addr2_sel),

        .alu_b_imm(alu_b_imm),
        .mem_write(mem_write),
        .jump_en(jump_en),
        .branch_en(branch_en),
        .loop_setup(loop_setup),
        .halted(halted)
    );
    
    initial begin
        clk=0;
        forever #5 clk=~clk;
    end
    
    task automatic enter_execute(input logic [4:0]op);  
    begin
        opcode=op;
        
        @(posedge clk);
        #1;
        
        @(posedge clk);
        #1;
    end
    endtask
    
    task automatic return_fetch;
    begin
        @(posedge clk);
        #1;
        
        if(ir_write!==1'b1)
            $error("Did not return to FETCH");
    end
    endtask
    
    task automatic test_alu(
        input logic [4:0]op,
        input logic [3:0]expected_alu,
        input logic expected_z,
        input logic expected_n,
        input logic expected_c,
        input logic expected_v,
        input logic [1:0]expected_rf1
    );
    
    begin
        enter_execute(op);
        
        if(reg_write!==1'b1 ||
               alu_op!==expected_alu ||
               z_we!==expected_z ||
               n_we!==expected_n ||
               c_we!==expected_c ||
               v_we!==expected_v ||
               instruction_done!==1'b1 ||
               pc_write!==1'b1 ||
               rf_addr1_sel!==expected_rf1)
                $error("ALU test failed for opcode %b", op);
          else 
            $display("pass: alu opcode %b", op);
            
            return_fetch();
    end
    endtask
    
    initial begin
        rst=1'b0;
        opcode=OP_NOP;
        
        @(negedge clk);
        rst=1'b1;
        
        @(posedge clk);
        #1;
        
        if(ir_write!==1'b1)
            $error("reset failed");
        else
            $display("pass:reset->fetch");
           
        @(negedge clk);
        rst=1'b0;
        
        //alu
        
        test_alu(OP_ADD,4'b0000,1,1,1,1,RF_F2);
        test_alu(OP_SUB,4'b0001,1,1,1,1,RF_F2);

        test_alu(OP_AND,4'b0010,1,1,0,0,RF_F2);
        test_alu(OP_OR, 4'b0011,1,1,0,0,RF_F2);
        test_alu(OP_XOR,4'b0100,1,1,0,0,RF_F2);

        test_alu(OP_SHL,4'b0101,1,1,1,0,RF_F1);
        test_alu(OP_SHR,4'b0110,1,1,1,0,RF_F1);
        test_alu(OP_SAR,4'b0111,1,1,1,0,RF_F1);

        test_alu(OP_ROL,4'b1000,1,1,1,0,RF_F1);
        test_alu(OP_ROR,4'b1001,1,1,1,0,RF_F1);

        test_alu(OP_RCL,4'b1010,1,1,1,0,RF_F1);
        test_alu(OP_RCR,4'b1011,1,1,1,0,RF_F1);
        
        //mov
        
        enter_execute(OP_MOV);

        if(reg_write!==1'b1 ||
           wb_sel!==WB_MOV ||
           instruction_done!==1'b1 ||
           pc_write!==1'b1)
            $error("MOV failed");
        else
            $display("PASS: MOV");

        return_fetch();
        
        //mul
        
        enter_execute(OP_MUL);

        if(reg_write!==1'b1 ||
           wb_sel!==WB_MUL ||
           instruction_done!==1'b1 ||
           pc_write!==1'b1)
            $error("MUL failed");
        else
            $display("PASS: MUL");

        return_fetch();
        
        //mac
        //fetch->decode->mac_read
        
        opcode=OP_MAC;

        @(posedge clk);
        #1;

        @(posedge clk);
        #1;

        if(mac_latch!==1'b1 ||
           rf_addr1_sel!==RF_F1 ||
           rf_addr2_sel!==RF_F2 ||
           reg_write!==1'b0 ||
           instruction_done!==1'b0)
            $error("MAC_READ failed");
        else
            $display("PASS: MAC_READ");
            
        
        //mac_read->mac_exec
        
        @(posedge clk);
        #1;

        if(reg_write!==1'b1 ||
           wb_sel!==WB_MAC ||
           instruction_done!==1'b1 ||
           pc_write!==1'b1 ||
           mac_latch!==1'b0)
            $error("MAC_EXEC failed");
        else
            $display("PASS: MAC_EXEC");

        return_fetch();
        
        //load
        
        enter_execute(OP_LOAD);

        if(rf_addr1_sel!==RF_F2 ||
           alu_op!==4'b0000 ||
           alu_b_imm!==1'b1 ||
           reg_write!==1'b1 ||
           wb_sel!==WB_MEM ||
           mem_write!==1'b0 ||
           instruction_done!==1'b1 ||
           pc_write!==1'b1)
            $error("LOAD failed");
        else
            $display("PASS: LOAD");

        return_fetch();
        
        //store
        enter_execute(OP_STORE);

        if(rf_addr1_sel!==RF_F2 ||
           rf_addr2_sel!==RF_F1 ||
           alu_op!==4'b0000 ||
           alu_b_imm!==1'b1 ||
           mem_write!==1'b1 ||
           reg_write!==1'b0 ||
           instruction_done!==1'b1 ||
           pc_write!==1'b1)
            $error("STORE failed");
        else
            $display("PASS: STORE");

        return_fetch();
        
        //jmp
        enter_execute(OP_JMP);

        if(jump_en!==1'b1 ||
           instruction_done!==1'b1 ||
           pc_write!==1'b1)
            $error("JMP failed");
        else
            $display("PASS: JMP");

        return_fetch();
        
        //beq
        enter_execute(OP_BEQ);

        if(branch_en!==1'b1 ||
           rf_addr1_sel!==RF_F1 ||
           rf_addr2_sel!==RF_F2 ||
           instruction_done!==1'b1 ||
           pc_write!==1'b1)
            $error("BEQ failed");
        else
            $display("PASS: BEQ");

        return_fetch();
        
        //loop
        enter_execute(OP_LOOP);

        if(loop_setup!==1'b1 ||
           rf_addr1_sel!==RF_F1 ||
           instruction_done!==1'b1 ||
           pc_write!==1'b1)
            $error("LOOP failed");
        else
            $display("PASS: LOOP");

        return_fetch();
        
        //nop
        enter_execute(OP_NOP);

        if(instruction_done!==1'b1 ||
           pc_write!==1'b1 ||
           reg_write!==1'b0 ||
           mem_write!==1'b0)
            $error("NOP failed");
        else
            $display("PASS: NOP");

        return_fetch();
        
        //invalid opcode, should behave like nop
        enter_execute(5'b11111);

        if(instruction_done!==1'b1 ||
           pc_write!==1'b1 ||
           reg_write!==1'b0)
            $error("Invalid opcode handling failed");
        else
            $display("PASS: invalid opcode -> NOP");

        return_fetch();
        
        //halt
        //last because gpu stays in halt
        
        enter_execute(OP_HALT);

        if(halted!==1'b1 ||
           pc_write!==1'b0 ||
           reg_write!==1'b0 ||
           mem_write!==1'b0)
            $error("HALT failed");
        else
            $display("PASS: HALT");

        // Verify HALT -> HALT
        @(posedge clk);
        #1;

        if(halted!==1'b1)
            $error("CPU escaped HALT state");
        else
            $display("PASS: remains in HALT");
            
            
        $finish;
    end
endmodule
