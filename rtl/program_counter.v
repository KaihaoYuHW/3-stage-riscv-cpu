module program_counter (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire jump_en,
    input wire [31:0] jump_addr,
    output reg [31:0] inst_addr
);
    
    // inst_mem[0, 4, 8, 12,...] 
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            inst_addr <= 32'd0;
        else if (jump_en == 1'b1)
            inst_addr <= jump_addr;
        else 
            inst_addr <= inst_addr + 3'd4;
    end    

endmodule