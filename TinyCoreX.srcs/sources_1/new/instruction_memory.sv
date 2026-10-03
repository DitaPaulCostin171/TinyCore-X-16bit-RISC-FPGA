`timescale 1ns / 1ps
module instruction_memory#(
    parameter int DATA_WIDTH=16,
    parameter int DEPTH=256,
    parameter int ADDR_WIDTH=$clog2(DEPTH),
    parameter string INIT_FILE=""
    )(
    input logic [ADDR_WIDTH-1:0] address,
    output logic [DATA_WIDTH-1:0]instruction
    );
    
    logic [DATA_WIDTH-1:0]memory[0:DEPTH-1];
    
    always_comb begin
        if(INIT_FILE!="")
            $readmemh(INIT_FILE, memory);
    end
    
    always_comb begin
        instruction=memory[address];
    end
endmodule
