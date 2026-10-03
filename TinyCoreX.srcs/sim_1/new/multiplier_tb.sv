`timescale 1ns / 1ps
module multiplier_tb(    );

parameter DATA_WIDTH=16;

logic signed[DATA_WIDTH-1:0]a;
logic signed[DATA_WIDTH-1:0]b;

logic signed[(2*DATA_WIDTH)-1:0]product;

multiplier#(.DATA_WIDTH(DATA_WIDTH))
    dut(
        .a(a),
        .b(b),
        .product(product)
    );

initial begin
    a=16'sd7;
    b=16'sd3;
    
    #1;
    
    if(product!==32'sd21)
        $error("mul failed(7*3)");
    else
        $display("7*3=21");
        
    
    a=-16'sd7;
    b=16'sd3;
    
    #1;
    
    if(product !== -32'sd21)
        $error("mul failed(-7*3)");
    else
        $display("-7*3=-21");
        
    a=16'sd7;
    b=-16'sd3;
    
    #1;
    
    if(product !== -32'sd21)
        $error("mul failed(7*-3)");
    else
        $display("7*-3=-21");
        
    a=-16'sd7;
    b=-16'sd3;
    
    #1;
    
    if(product !== 32'sd21)
        $error("mul failed(7*3)");
    else
        $display("-7*-3=21");
        
    a=16'sd0;
    b=16'sd100;
    
    #1;
    
    if(product !== 32'sd0)
        $error("mul failed(0*100)");
    else
        $display("0*100=0");
        
    a=16'sd32767;
    b=16'sd32767;
    
    #1;
    
    if(product !== 32'sd1073676289)
        $error("mul failed(32767*32767)");
    else
        $display("mul pass");
        
    a=-16'sd32767;
    b=16'sd1;
    
    #1;
    
    if(product !== -32'sd32767)
        $error("mul failed(-32767*1)");
    else
        $display("-32767*1=-32767");
    
    a=-16'sd32767;
    b=-16'sd1;
    
    #1;
    
    if(product !== 32'sd32767)
        $error("mul failed(-1*-32767)");
    else
        $display("-1*-32767=32767");
        
    a = -16'sh32768;
    b = 16'sd1;
    
    #1;
    
    if(product !== -32'sd32768)
        $error("mul failed(-32768*1)");
    else
        $display("-32768*1=-32768");
    
    a = -16'sh32768;
    b = -16'sd1;
    
    #1;
    
    if(product !== 32'sd32768)
        $error("mul failed(-32768*-1)");
    else
        $display("-32768*-1=32768");
        
    $finish;
end
endmodule
