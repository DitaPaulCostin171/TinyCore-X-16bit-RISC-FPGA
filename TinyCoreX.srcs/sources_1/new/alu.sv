`timescale 1ns / 1ps
module alu
    #(parameter int DATA_WIDTH=16)
    (
        input logic signed [DATA_WIDTH-1:0]a,
        input logic signed [DATA_WIDTH-1:0]b,
        input logic [3:0]alu_op,
        input logic carry_in,
        
        output logic signed [DATA_WIDTH-1:0]result,
        output logic zero,
        output logic negative,
        output logic carry_out,
        output logic overflow
    );
    localparam logic [3:0]
    ALU_ADD = 4'b0000,
    ALU_SUB = 4'b0001,
    ALU_AND = 4'b0010,
    ALU_OR  = 4'b0011,
    ALU_XOR = 4'b0100,
    ALU_SHL = 4'b0101,
    ALU_SHR = 4'b0110,
    ALU_SAR = 4'b0111,
    ALU_ROL = 4'b1000,
    ALU_ROR = 4'b1001,
    ALU_RCL = 4'b1010,
    ALU_RCR = 4'b1011;
    
    always_comb begin
    result='0;
    carry_out=carry_in;
    overflow=1'b0;
    case(alu_op)
    ALU_ADD:begin//ADD
        {carry_out,result}={1'b0,a}+{1'b0,b};
        
        overflow =~(a[DATA_WIDTH-1] ^ b[DATA_WIDTH-1]) &
                    (a[DATA_WIDTH-1] ^ result[DATA_WIDTH-1]);
    end
    
    ALU_SUB:begin//SUB
        result=a-b;
        carry_out=($unsigned(a) >= $unsigned(b));
        overflow=(a[DATA_WIDTH-1]^b[DATA_WIDTH-1])&
                (a[DATA_WIDTH-1]^result[DATA_WIDTH-1]);
    end
    
    ALU_AND:begin//AND
        result=a&b; 
    end
    
    ALU_OR:begin//OR
        result=a|b;
    end
    
    ALU_XOR:begin//XOR
        result=a^b;
    end
    ALU_SHL:begin//SHL
        result=a<<1;
        carry_out = a[DATA_WIDTH-1];
    end
    ALU_SHR:begin//SHR
        result=a>>1;
        carry_out=a[0];
    end
    
    ALU_SAR:begin//SAR(arithmetic, keeps the sign)
        result=a>>>1;
        carry_out=a[0];
    end
    
    ALU_ROL: begin // ROL
        result = {a[DATA_WIDTH-2:0], a[DATA_WIDTH-1]};
        carry_out = a[DATA_WIDTH-1];
    end
    
    ALU_ROR: begin // ROR
        result = {a[0], a[DATA_WIDTH-1:1]};
        carry_out = a[0];
    end
    
    ALU_RCL: begin // RCL
        result = {a[DATA_WIDTH-2:0], carry_in};
        carry_out = a[DATA_WIDTH-1];
    end
    
    ALU_RCR: begin // RCR
        result = {carry_in, a[DATA_WIDTH-1:1]};
        carry_out = a[0];
    end
    default:begin
        result='0;
    end
    endcase
    
    zero=(result=='0);
    negative=result[DATA_WIDTH-1];
    end
endmodule
