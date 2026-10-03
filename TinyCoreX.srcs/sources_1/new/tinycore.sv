`timescale 1ns / 1ps
(* keep_hierarchy = "yes" *)
module tinycore#(
    parameter int DATA_WIDTH=16,
    parameter int ADDR_WIDTH=8,
    parameter string IMEM_INIT_FILE=""
    )(
    input logic clk,
    input logic rst,
    
    output logic halted
    );
    
    logic [ADDR_WIDTH-1:0]pc;
    logic [ADDR_WIDTH-1:0]next_pc;
    logic [ADDR_WIDTH-1:0]pc_plus_one;
    
    logic [DATA_WIDTH-1:0]instruction_mem_out;
    logic [DATA_WIDTH-1:0]instruction_reg;
    
    logic ir_write;
    logic pc_write;
    
    logic [4:0]opcode;
    
    logic [2:0]reg_field1;
    logic [2:0]reg_field2;
    logic [2:0]reg_field3;
    
    logic [7:0]imm8;
    logic [4:0]imm5;
    logic [10:0]imm11;
    
    logic reg_write;
    logic [3:0]alu_op;
    
    logic z_we;
    logic n_we;
    logic c_we;
    logic v_we;
    
    logic instruction_done;
    
    logic [2:0]wb_sel;
    
    logic mac_latch;
    
    logic [1:0]rf_addr1_sel;
    logic [1:0]rf_addr2_sel;
    
    logic alu_b_imm;
    logic mem_write;
    logic jump_en;
    logic branch_en;
    logic loop_setup;
    
    logic [2:0]read_addr1;
    logic [2:0]read_addr2;
    logic [2:0]write_addr;
    
    logic signed [DATA_WIDTH-1:0]read_data1;
    logic signed [DATA_WIDTH-1:0]read_data2;
    logic signed [DATA_WIDTH-1:0]write_data;
    
    logic signed [DATA_WIDTH-1:0]imm5_extended;
    logic signed [DATA_WIDTH-1:0]imm8_extended;
    
    logic signed [DATA_WIDTH-1:0]alu_a;
    logic signed [DATA_WIDTH-1:0]alu_b;
    logic signed [DATA_WIDTH-1:0]alu_result;
    
    logic alu_zero;
    logic alu_negative;
    logic alu_carry;
    logic alu_overflow;
    
    logic flag_zero;
    logic flag_negative;
    logic flag_carry;
    logic flag_overflow;
    
    logic signed [(2*DATA_WIDTH)-1:0]mul_product;
    logic signed [DATA_WIDTH-1:0]mul_result;
    
    logic signed [DATA_WIDTH-1:0]mac_acc_reg;
    logic signed [DATA_WIDTH-1:0]mac_a_reg;
    
    logic signed [DATA_WIDTH-1:0]mac_result;
    logic signed [(2*DATA_WIDTH)-1:0]mac_full_result;
    logic mac_overflow;
    
    logic [ADDR_WIDTH-1:0]data_address;
    logic signed [DATA_WIDTH-1:0]mem_read_data;
    
    logic loop_active;
    logic loop_jump;
    logic [ADDR_WIDTH-1:0]loop_target;
    
    logic branch_equal;
    logic [ADDR_WIDTH-1:0]branch_target;
    logic [ADDR_WIDTH-1:0]jump_target;
    
    localparam int PC_CALC_WIDTH=((ADDR_WIDTH>11)?ADDR_WIDTH:11)+1;
    
    logic signed [PC_CALC_WIDTH-1:0]pc_extended;
    logic signed [PC_CALC_WIDTH-1:0]branch_offset;
    logic signed [PC_CALC_WIDTH-1:0]jump_offset;
    logic signed [PC_CALC_WIDTH-1:0]branch_calc;
    logic signed [PC_CALC_WIDTH-1:0]jump_calc;
    logic signed [PC_CALC_WIDTH-1:0]one_extended;
    
    localparam logic [1:0]
        RF_F1=2'b00,
        RF_F2=2'b01,
        RF_F3=2'b10;
        
    localparam logic [2:0]
        WB_ALU=3'b000,
        WB_MOV=3'b001,
        WB_IMM=3'b010,
        WB_MUL=3'b011,
        WB_MAC=3'b100,
        WB_MEM=3'b101;
    
    assign pc_plus_one=pc+1'b1;
    
    (* dont_touch = "yes" *)
    program_counter #(
        .ADDR_WIDTH(ADDR_WIDTH)
    )pc_unit(
        .clk(clk),
        .rst(rst),
        .pc_write(pc_write),
        .next_pc(next_pc),
        .pc(pc)
    );
    
    (* dont_touch = "yes" *)
    instruction_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(256),
        .INIT_FILE(IMEM_INIT_FILE)
    )imem(
        .address(pc),
        .instruction(instruction_mem_out)
    );
    
    always_ff @(posedge clk)begin
        if(rst)
            instruction_reg<='0;
        else if(ir_write)
            instruction_reg<=instruction_mem_out;
    end
    
    (* dont_touch = "yes" *)
    instruction_decoder decoder(
        .instruction(instruction_reg),
        .opcode(opcode),
        .reg_field1(reg_field1),
        .reg_field2(reg_field2),
        .reg_field3(reg_field3),
        .imm8(imm8),
        .imm5(imm5),
        .imm11(imm11)
    );
    
    (* dont_touch = "yes" *)
    control_unit controller(
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
    
    always_comb begin
        case(rf_addr1_sel)
            RF_F1:read_addr1=reg_field1;
            RF_F2:read_addr1=reg_field2;
            RF_F3:read_addr1=reg_field3;
            default:read_addr1='0;
        endcase
        
        case(rf_addr2_sel)
            RF_F1:read_addr2=reg_field1;
            RF_F2:read_addr2=reg_field2;
            RF_F3:read_addr2=reg_field3;
            default:read_addr2='0;
        endcase
    end
    
    assign write_addr=reg_field1;
    
    (* dont_touch = "yes" *)
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(8)
    )rf(
        .clk(clk),
        .rst(rst),
        
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        
        .write_addr(write_addr),
        .write_data(write_data),
        .write_en(reg_write),
        
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    
    assign imm5_extended={{(DATA_WIDTH-5){imm5[4]}},imm5};
    assign imm8_extended={{(DATA_WIDTH-8){imm8[7]}},imm8};
    
    assign alu_a=read_data1;
    assign alu_b=alu_b_imm ? imm5_extended : read_data2;
    
    (* dont_touch = "yes" *)
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    )alu_unit(
        .a(alu_a),
        .b(alu_b),
        .alu_op(alu_op),
        .carry_in(flag_carry),
        .result(alu_result),
        .zero(alu_zero),
        .negative(alu_negative),
        .carry_out(alu_carry),
        .overflow(alu_overflow)
    );
    
    (* dont_touch = "yes" *)
    flags_register flags_unit(
        .clk(clk),
        .rst(rst),
        
        .z_in(alu_zero),
        .n_in(alu_negative),
        .c_in(alu_carry),
        .of_in(alu_overflow),
        
        .z_we(z_we),
        .n_we(n_we),
        .c_we(c_we),
        .v_we(v_we),
        
        .zero(flag_zero),
        .negative(flag_negative),
        .carry(flag_carry),
        .overflow(flag_overflow)
    );
    
    (* dont_touch = "yes" *)
    multiplier #(
        .DATA_WIDTH(DATA_WIDTH)
    )multiplier_unit(
        .a(read_data1),
        .b(read_data2),
        .product(mul_product)
    );
    
    assign mul_result=mul_product[DATA_WIDTH-1:0];
    
    always_ff @(posedge clk)begin
        if(rst)begin
            mac_acc_reg<='0;
            mac_a_reg<='0;
        end
        
        else if(mac_latch)begin
            mac_acc_reg<=read_data1;
            mac_a_reg<=read_data2;
        end
    end
    
    (* dont_touch = "yes" *)
    mac_unit #(
        .DATA_WIDTH(DATA_WIDTH)
    )mac(
        .a(mac_a_reg),
        .b(read_data2),
        .acc(mac_acc_reg),
        .result(mac_result),
        .full_result(mac_full_result),
        .overflow(mac_overflow)
    );
    
    assign data_address=alu_result[ADDR_WIDTH-1:0];
    
    (* dont_touch = "yes" *)
    data_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(256)
    )dmem(
        .clk(clk),
        .address(data_address),
        .write_data(read_data2),
        .write_en(mem_write),
        .read_data(mem_read_data)
    );
    
    always_comb begin
        case(wb_sel)
            WB_ALU:write_data=alu_result;
            WB_MOV:write_data=read_data1;
            WB_IMM:write_data=imm8_extended;
            WB_MUL:write_data=mul_result;
            WB_MAC:write_data=mac_result;
            WB_MEM:write_data=mem_read_data;
            default:write_data='0;
        endcase
    end
    
    (* dont_touch = "yes" *)
    loop_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    )loop_unit(
        .clk(clk),
        .rst(rst),
        
        .loop_setup(loop_setup),
        
        .start_address(pc_plus_one),
        .body_length(imm8),
        .iterations(read_data1),
        
        .current_pc(pc),
        .instruction_done(instruction_done),
        
        .loop_active(loop_active),
        .loop_jump(loop_jump),
        .loop_target(loop_target)
    );
    
    assign branch_equal=(read_data1==read_data2);
    
    assign pc_extended=
        $signed({{(PC_CALC_WIDTH-ADDR_WIDTH){1'b0}},pc});
    
    assign branch_offset=
        $signed({{(PC_CALC_WIDTH-5){imm5[4]}},imm5});
    
    assign jump_offset=
        $signed({{(PC_CALC_WIDTH-11){imm11[10]}},imm11});
    
    assign one_extended=
        $signed({{(PC_CALC_WIDTH-1){1'b0}},1'b1});
    
    assign branch_calc=
        pc_extended+branch_offset+one_extended;
    
    assign jump_calc=
        pc_extended+jump_offset+one_extended;
    
    assign branch_target=
        branch_calc[ADDR_WIDTH-1:0];
    
    assign jump_target=
        jump_calc[ADDR_WIDTH-1:0];
    
    always_comb begin
        next_pc=pc_plus_one;
        
        if(jump_en)
            next_pc=jump_target;
            
        else if(branch_en && branch_equal)
            next_pc=branch_target;
            
        else if(loop_jump)
            next_pc=loop_target;
    end
    
endmodule