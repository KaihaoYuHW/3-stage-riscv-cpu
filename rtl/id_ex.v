`include "defines.v"

module id_ex (
    input wire sys_clk,
    input wire sys_rst_n,

    input wire hold_en,
    input wire [31:0] inst,
    input wire [31:0] inst_addr,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [4:0] rd_addr,
    input wire rd_wen,

    output reg [31:0] inst_dly,
    output reg [31:0] inst_addr_dly,
    output reg [31:0] rs1_data_dly,
    output reg [31:0] rs2_data_dly,
    output reg [4:0] rd_addr_dly,
    output reg rd_wen_dly
);

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0 || hold_en == 1'b1) begin
            inst_dly <= `INST_NOP;
            inst_addr_dly <= 32'd0;
            rs1_data_dly <= 32'b0;
            rs2_data_dly <= 32'b0;
            rd_addr_dly <= 5'b0;
            rd_wen_dly <= 1'b0;
        end
        else begin
            inst_dly <= inst;
            inst_addr_dly <= inst_addr;
            rs1_data_dly <= rs1_data;
            rs2_data_dly <= rs2_data;
            rd_addr_dly <= rd_addr;
            rd_wen_dly <= rd_wen;
        end
    end
    
endmodule