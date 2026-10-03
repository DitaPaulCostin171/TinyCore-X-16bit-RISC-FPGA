`timescale 1ns / 1ps
module flags_register(
    input logic clk,
    input logic rst,
    
    input logic z_in,
    input logic n_in,
    input logic c_in,
    input logic of_in,
    
    input logic z_we,
    input logic n_we,
    input logic c_we,
    input logic v_we,
    
    output logic zero,
    output logic negative,
    output logic carry,
    output logic overflow
    );
    
    always_ff @(posedge clk)begin
        if(rst)
            begin
            zero<=1'b0;
            negative<=1'b0;
            carry<=1'b0;
            overflow<=1'b0;
            end
            
         else begin
            if(z_we)zero<=z_in;
            
            if(n_we)negative<=n_in;
            
            if(c_we)carry<=c_in;
                
            if(v_we)overflow<=of_in;
         end
    end
endmodule
