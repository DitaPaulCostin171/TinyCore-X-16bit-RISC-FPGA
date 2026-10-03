`timescale 1ns / 1ps
module loop_controller#(
    parameter int ADDR_WIDTH=8,
    parameter int DATA_WIDTH=16
    )(
    
    input logic clk,
    input logic rst,
    //LOOP instruction setup
    input logic loop_setup,
    
    input logic [ADDR_WIDTH-1:0]start_address,
    input logic [7:0]body_length,
    input logic [DATA_WIDTH-1:0]iterations,
    //CPU state
    input logic [ADDR_WIDTH-1:0]current_pc,
    input logic instruction_done,
    
    //PC control
    output logic loop_active,
    output logic loop_jump,
    output logic [ADDR_WIDTH-1:0]loop_target
    );
    
    logic [ADDR_WIDTH-1:0]loop_start;
    logic [ADDR_WIDTH-1:0]loop_end;
    logic [DATA_WIDTH-1:0]loop_count;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            loop_start<='0;
            loop_end<='0;
            loop_count<='0;
            loop_active<='0;
        end
        
        else begin
            if(loop_setup)begin
                if((iterations !=0 ) && (body_length != 0))begin
                    loop_start<=start_address;
                    
                    loop_end<=start_address+body_length-1'b1;
                    
                    loop_count<=iterations;
                    
                    loop_active<=1'b1;
                end
                
                else begin
                    loop_count<='0;
                    loop_active<=1'b0;
                end
            end
            
            else if(loop_active && instruction_done && (current_pc==loop_end))
            begin
                if(loop_count>1)begin
                    loop_count<=loop_count-1'b1;
                end
                
                else begin
                    loop_count<='0;
                    loop_active<=1'b0;
                end
            end
        end
    end
    
    //PC redirection
    
    always_comb begin
        loop_jump=1'b0;
        loop_target=loop_start;
        
        if(loop_active && 
           instruction_done &&
           (current_pc==loop_end) &&
           (loop_count > 1)
           )begin
            loop_jump=1'b1;
            loop_target=loop_start;
           end
    end
endmodule
