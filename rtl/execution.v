`include "defines.v"

module execution (
    input wire [31:0] inst,
    input wire [31:0] inst_addr,
    input wire [31:0] op1,
    input wire [31:0] op2,

    // to register file
    output reg [31:0] rd_data,

    // to ctrl
    output reg [31:0] jump_addr,
    output reg jump_en,
    output reg hold_en
);

    // I and R instruction
    wire [6:0] funct7;
    wire [4:0] rs2;     // rs2 address
    wire [4:0] rs1;     // rs1 address
    wire [2:0] funct3;
    wire [4:0] rd;      // rd address
    wire [6:0] opcode;
    wire [11:0] imm;

    // branch instruction
    wire [12:0] imm_jump; 
    wire op1_equal_op2;

    assign funct7 = inst[31:25];
    assign rs2 = inst[24:20];
    assign rs1 = inst[19:15];
    assign funct3 = inst[14:12];
    assign rd = inst[11:7];
    assign opcode = inst[6:0];
    assign imm = inst[31:20];

    assign imm_jump = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    assign op1_equal_op2 = (op1 == op2) ? 1'b1 : 1'b0;

    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
                case (funct3)
                    `INST_ADDI: begin
                        rd_data = op1 + op2;
                    end
                    default: begin
                        rd_data = 32'b0;
                    end
                endcase
            end
            `INST_TYPE_R_M: begin
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
                case (funct3)
                    `INST_ADD_SUB: begin
                        if (funct7 == 7'b000_0000)
                            rd_data = op1 + op2;
                        else
                            rd_data = op1 - op2;
                    end
                    default: begin
                        rd_data = 32'b0;
                    end
                endcase
            end
            `INST_TYPE_B:begin
                rd_data = 32'b0;
                case (funct3)
                    `INST_BNE: begin
                        jump_addr = (inst_addr + {{19{inst[31]}}, imm_jump}) & {32{(~op1_equal_op2)}};  // 这里其实利用&操作来实现一个if功能
                        jump_en = ~op1_equal_op2;
                        hold_en = 1'b1;
                    end
                    `INST_BEQ: begin
                        jump_addr = (inst_addr + {{19{inst[31]}}, imm_jump}) & {32{op1_equal_op2}};     // 同上
                        jump_en = op1_equal_op2;
                        hold_en = 1'b1;
                    end
                    default: begin
                        jump_addr = 32'd0;
                        jump_en = 1'b0;
                        hold_en = 1'b0;
                    end
                endcase
            end
            default: begin
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
                rd_data = 32'b0;
            end
        endcase
    end
    

endmodule