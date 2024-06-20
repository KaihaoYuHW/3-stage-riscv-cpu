`include "defines.v"

module if_id (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire [31:0] inst,
    input wire [31:0] inst_addr,
    output reg [31:0] inst_dly,
    output reg [31:0] inst_addr_dly
);
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0) begin
            inst_dly <= `INST_NOP;
            inst_addr_dly <= 32'd0;
        end
        else begin
            inst_dly <= inst;
            inst_addr_dly <= inst_addr;
        end
    end

endmodule