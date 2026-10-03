`timescale 1ns / 1ps

module register_file #(
    parameter int DATA_WIDTH = 16,
    parameter int NUM_REGS   = 8
)(
    input logic clk,
    input logic rst,

    input logic [$clog2(NUM_REGS)-1:0] read_addr1,
    input logic [$clog2(NUM_REGS)-1:0] read_addr2,

    input logic [$clog2(NUM_REGS)-1:0] write_addr,
    input logic signed [DATA_WIDTH-1:0] write_data,
    input logic write_en,

    output logic signed [DATA_WIDTH-1:0] read_data1,
    output logic signed [DATA_WIDTH-1:0] read_data2
);

    
    logic signed [DATA_WIDTH-1:0]registers[0:NUM_REGS-1];
    
    always_comb begin
        read_data1=registers[read_addr1];
        read_data2=registers[read_addr2];
    end
    
    always_ff@(posedge clk)begin
        if(rst)begin
            for(int i=0;i<NUM_REGS;i++)
            begin
                registers[i]<='0;
            end
        end
        
        else if(write_en)begin
                registers[write_addr]<=write_data;
            end
    end
endmodule