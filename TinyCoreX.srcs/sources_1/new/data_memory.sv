`timescale 1ns / 1ps
module data_memory #(
    parameter int DATA_WIDTH = 16,
    parameter int DEPTH = 256,
    parameter int ADDR_WIDTH = $clog2(DEPTH)
)(
    input logic clk,

    input logic [ADDR_WIDTH-1:0] address,

    input logic signed [DATA_WIDTH-1:0] write_data,
    input logic write_en,

    output logic signed [DATA_WIDTH-1:0] read_data
);

logic signed [DATA_WIDTH-1:0]memory[0:DEPTH-1];

always_comb begin
    read_data=memory[address];
end

always_ff @(posedge clk) begin
    if(write_en)
        memory[address]<=write_data;
end
endmodule
