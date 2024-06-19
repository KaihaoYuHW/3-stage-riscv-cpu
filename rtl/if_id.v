`include "defines.v"

module if_id (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire [31:0] inst,
    output reg [31:0] inst_dly
);
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            inst_dly <= `INST_NOP;
        else
            inst_dly <= inst;
    end

endmodule