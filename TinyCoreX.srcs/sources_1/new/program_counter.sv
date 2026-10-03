`timescale 1ns / 1ps
module program_counter
    #(parameter int ADDR_WIDTH=8)
    (
       input logic clk,
       input logic rst,
       input logic pc_write,
       
       input logic [ADDR_WIDTH-1:0]next_pc,
       
       output logic [ADDR_WIDTH-1:0]pc     
    );
    
    always_ff @(posedge clk)begin
        if(rst)
            pc<='0;
        else if(pc_write)
                pc<=next_pc;
    end
endmodule
