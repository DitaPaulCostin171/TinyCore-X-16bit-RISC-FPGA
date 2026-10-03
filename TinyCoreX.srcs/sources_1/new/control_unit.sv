`timescale 1ns / 1ps
module control_unit(
    input logic clk,
    input logic rst,
    
    input logic [4:0]opcode,
    
    output logic ir_write,
    
    output logic reg_write,
    output logic [3:0]alu_op,
    
    output logic z_we,
    output logic n_we,
    output logic c_we,
    output logic v_we,
    
    output logic instruction_done,
    output logic pc_write,
    
    output logic [2:0]wb_sel,
    
    output logic mac_latch,
    
    output logic [1:0]rf_addr1_sel,
    output logic [1:0]rf_addr2_sel,
    
    output logic alu_b_imm,
    output logic mem_write,
    output logic jump_en,
    output logic branch_en,
    output logic loop_setup,
    output logic halted
    );
    
    typedef enum logic [3:0]{
        FETCH,
        DECODE,
        EXEC_ALU,
        EXEC_MOV,
        EXEC_MUL,
        MAC_READ,
        MAC_EXEC,
        EXEC_LOAD,
        EXEC_STORE,
        EXEC_JMP,
        EXEC_BEQ,
        EXEC_LOOP,
        EXEC_NOP,
        HALT
    }state_t;
    
    state_t state;
    state_t state_next;
    
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
        WB_ALU=3'b000,
        WB_MOV=3'b001,
        WB_IMM=3'b010,
        WB_MUL=3'b011,
        WB_MAC=3'b100,
        WB_MEM=3'b101;
    
    localparam logic [1:0]
        RF_F1=2'b00,
        RF_F2=2'b01,
        RF_F3=2'b10;
    
    always_ff @(posedge clk)begin
        if(rst)
            state<=FETCH;
        else state<=state_next;
    end
    
    always_comb begin
        state_next=state;
        
        case(state)
            FETCH:begin
                state_next=DECODE;
            end
            
            DECODE:begin
                case(opcode)
                    OP_ADD,
                    OP_SUB,
                    OP_AND,
                    OP_OR,
                    OP_XOR,
                    OP_SHL,
                    OP_SHR,
                    OP_SAR,
                    OP_ROL,
                    OP_ROR,
                    OP_RCL,
                    OP_RCR:
                        state_next=EXEC_ALU;
                        
                    OP_NOP:state_next=EXEC_NOP;
                    OP_MOV,OP_MOVI:state_next=EXEC_MOV;
                    
                    OP_MUL:state_next=EXEC_MUL;
                    
                    OP_MAC:state_next=MAC_READ;
                    
                    OP_LOAD:state_next=EXEC_LOAD;
                    
                    OP_STORE:state_next=EXEC_STORE;
                    
                    OP_JMP:state_next=EXEC_JMP;
                    
                    OP_BEQ:state_next=EXEC_BEQ;
                    
                    OP_LOOP:state_next=EXEC_LOOP;
                        
                    OP_HALT:state_next=HALT;
                    
                    default:state_next=EXEC_NOP;
                endcase
            end
            
            EXEC_ALU,
            EXEC_MOV,
            EXEC_MUL,
            EXEC_LOAD,
            EXEC_STORE,
            EXEC_JMP,
            EXEC_BEQ,
            EXEC_LOOP,
            EXEC_NOP:state_next=FETCH;
            
            MAC_READ:state_next=MAC_EXEC;
            
            MAC_EXEC:state_next=FETCH;
            
            HALT:state_next=HALT;
            
            default:state_next=FETCH;
        endcase
    end

    
    always_comb begin
        ir_write=1'b0;
        reg_write=1'b0;
        alu_op=4'b0000;
        wb_sel=WB_ALU;
        mac_latch=1'b0;
        rf_addr1_sel=RF_F2;
        rf_addr2_sel=RF_F3;
        alu_b_imm=1'b0;
        mem_write=1'b0;
        jump_en=1'b0;
        branch_en=1'b0;
        loop_setup=1'b0;
        halted=1'b0;
        
        z_we=1'b0;
        n_we=1'b0;
        c_we=1'b0;
        v_we=1'b0;
        
        instruction_done=1'b0;
        pc_write=1'b0;
        
        case(state)
            FETCH:begin
                ir_write=1'b1;
            end
            
            EXEC_ALU:begin
                reg_write=1'b1;
                instruction_done=1'b1;
                pc_write=1'b1;
                
                case(opcode)
                    OP_ADD:begin
                        alu_op=4'b0000;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b1;
                    end
                    
                    OP_SUB:begin
                        alu_op=4'b0001;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b1;
                    end
                    
                    OP_AND:begin
                        alu_op=4'b0010;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b0;
                        v_we=1'b0;
                    end
                    
                    OP_OR:begin
                        alu_op=4'b0011;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b0;
                        v_we=1'b0;
                    end
                    
                    OP_XOR:begin
                        alu_op=4'b0100;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b0;
                        v_we=1'b0;
                    end
                    
                    OP_SHL:begin
                        rf_addr1_sel=RF_F1;
                        alu_op=4'b0101;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b0;
                    end
                    
                    OP_SHR:begin
                        rf_addr1_sel=RF_F1;
                        alu_op=4'b0110;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b0;
                    end
                    
                    OP_SAR:begin
                        rf_addr1_sel=RF_F1;
                        alu_op=4'b0111;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b0;
                    end
                    
                    OP_ROL:begin
                        rf_addr1_sel=RF_F1;
                        alu_op=4'b1000;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b0;
                    end
                    
                    OP_ROR:begin
                        rf_addr1_sel=RF_F1;
                        alu_op=4'b1001;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b0;
                    end
                    
                    OP_RCL:begin
                        rf_addr1_sel=RF_F1;
                        alu_op=4'b1010;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b0;
                    end
                    
                    OP_RCR:begin
                        rf_addr1_sel=RF_F1;
                        alu_op=4'b1011;
                        z_we=1'b1;
                        n_we=1'b1;
                        c_we=1'b1;
                        v_we=1'b0;
                    end
                    
                    default:alu_op=4'b0000;
                endcase
            end
            
            EXEC_MOV:begin
                reg_write=1'b1;
                instruction_done=1'b1;
                pc_write=1'b1;
                
                case(opcode)
                    OP_MOV:wb_sel=WB_MOV;
                    OP_MOVI:wb_sel=WB_IMM;
                    default:wb_sel=WB_ALU;
                endcase
            end
            
            EXEC_MUL:begin
                reg_write=1'b1;
                wb_sel=WB_MUL;
                instruction_done=1'b1;
                pc_write=1'b1;
            end
            
            MAC_READ:begin
                mac_latch=1'b1;
                rf_addr1_sel=RF_F1;
                rf_addr2_sel=RF_F2;
            end
            
            MAC_EXEC:begin
                reg_write=1'b1;
                wb_sel=WB_MAC;
                instruction_done=1'b1;
                pc_write=1'b1;
            end

            EXEC_LOAD:begin
                rf_addr1_sel=RF_F2;
                alu_op=4'b0000;
                alu_b_imm=1'b1;
                reg_write=1'b1;
                wb_sel=WB_MEM;
                instruction_done=1'b1;
                pc_write=1'b1;
            end
            
            EXEC_STORE:begin
                rf_addr1_sel=RF_F2;
                rf_addr2_sel=RF_F1;
                alu_op=4'b0000;
                alu_b_imm=1'b1;
                mem_write=1'b1;
                instruction_done=1'b1;
                pc_write=1'b1;
            end
            
            EXEC_JMP:begin
                jump_en=1'b1;
                instruction_done=1'b1;
                pc_write=1'b1;
            end
            
            EXEC_BEQ:begin
                rf_addr1_sel=RF_F1;
                rf_addr2_sel=RF_F2;
                branch_en=1'b1;
                instruction_done=1'b1;
                pc_write=1'b1;
            end
            
            EXEC_LOOP:begin
                rf_addr1_sel=RF_F1;
                loop_setup=1'b1;
                instruction_done=1'b1;
                pc_write=1'b1;
            end
            
            EXEC_NOP:begin
                instruction_done=1'b1;
                pc_write=1'b1;
            end
            
            HALT:begin
                halted=1'b1;
            end
        endcase
    end
endmodule