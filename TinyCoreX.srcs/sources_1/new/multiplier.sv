`timescale 1ns / 1ps
module multiplier#(
    parameter int DATA_WIDTH=16
    )(
    input logic signed [DATA_WIDTH-1:0]a,
    input logic signed [DATA_WIDTH-1:0]b,
    
    output logic signed[(2*DATA_WIDTH)-1:0]product
    );
    
    always_comb begin
    product=a*b;
    end
endmodule
