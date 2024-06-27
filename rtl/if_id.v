`include "defines.v"

module if_id (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire hold_en,
    input wire [31:0] inst,
    input wire [31:0] inst_addr,
    output wire [31:0] inst_dly,
    output reg [31:0] inst_addr_dly
);

    // Since the instruction has been delayed in instruction_fetch, it can not be delayed in this module. 
    reg hold_en_dly;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            hold_en_dly <= 1'b0;
        else
            hold_en_dly <= hold_en;    
    end

    assign inst_dly = (hold_en_dly) ? `INST_NOP : inst;

    // delay inst_addr 1 clock cycle
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0 || hold_en == 1'b1)
            inst_addr_dly <= 32'd0;
        else
            inst_addr_dly <= inst_addr;
    end
endmodule