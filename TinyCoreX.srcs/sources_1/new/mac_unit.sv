`timescale 1ns / 1ps
module mac_unit#(
    parameter int DATA_WIDTH=16
    )(
    input logic signed [DATA_WIDTH-1:0]a,
    input logic signed [DATA_WIDTH-1:0]b,
    
    input logic signed [DATA_WIDTH-1:0]acc,
    
    output logic signed[DATA_WIDTH-1:0]result,
    output logic signed[(2*DATA_WIDTH)-1:0]full_result,
    
    output logic overflow
    );
    
    logic signed [(2*DATA_WIDTH)-1:0]product;
    logic signed [(2*DATA_WIDTH)-1:0]acc_extended;
    
    multiplier #(.DATA_WIDTH(DATA_WIDTH))
        mul(
            .a(a),
            .b(b),
            .product(product)    
        );
        
    always_comb begin
        //sign extension
        
        acc_extended={
            {DATA_WIDTH{acc[DATA_WIDTH-1]}},
            acc };
            
        full_result=product+acc_extended;
        
        result=full_result[DATA_WIDTH-1:0];
        
        //we set overflow if full_result cannot be represented as a signed
        //DATA_WIDTH bit number
        
        overflow=full_result[(2*DATA_WIDTH)-1:DATA_WIDTH]
                    !=
                 {DATA_WIDTH{full_result[DATA_WIDTH-1]}};
    end
endmodule
