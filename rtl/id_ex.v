module id_ex (
    input wire sys_clk,
    input wire sys_rst_n,

    input wire [31:0] op1,
    input wire [31:0] op2,
    input wire [4:0] rd_addr,
    input wire rd_wen,

    output reg [31:0] op1_dly,
    output reg [31:0] op2_dly,
    output reg [4:0] rd_addr_dly,
    output reg rd_wen_dly
);

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0) begin
            op1_dly <= 32'b0;
            op2_dly <= 32'b0;
            rd_addr_dly <= 5'b0;
            rd_wen_dly <= 1'b0;
        end
        else begin
            op1_dly <= op1;
            op2_dly <= op2;
            rd_addr_dly <= rd_addr;
            rd_wen_dly <= rd_wen;
        end
    end
    
endmodule