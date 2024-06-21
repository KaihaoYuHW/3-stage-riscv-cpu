`include "defines.v"

module execution (
    input wire [31:0] inst,
    input wire [31:0] inst_addr,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,

    // to register file
    output reg [31:0] rd_data,

    // to ctrl
    output reg [31:0] jump_addr,
    output reg jump_en,
    output reg hold_en
);

    // I and R instruction
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [6:0] opcode;
    wire [11:0] imm_addi;   // ADDI instruction
    wire [12:0] imm_bne;    // BNE & BEQ instruction
    wire [20:0] imm_jal;    // JAL instruction

    wire rs1_data_equal_rs2_data;     

    assign funct7 = inst[31:25];
    assign funct3 = inst[14:12];
    assign opcode = inst[6:0];
    assign imm_addi = inst[31:20];
    assign imm_bne = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    assign imm_jal = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

    assign rs1_data_equal_rs2_data = (rs1_data == rs2_data) ? 1'b1 : 1'b0;

    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
                case (funct3)
                    `INST_ADDI: begin
                        rd_data = rs1_data + {{20{imm_addi[11]}}, imm_addi};
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
                            rd_data = rs1_data + rs2_data;
                        else
                            rd_data = rs1_data - rs2_data;
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
                        jump_addr = (inst_addr + {{19{imm_bne[12]}}, imm_bne}) & {32{(~rs1_data_equal_rs2_data)}};  // 这里其实利用&操作来实现一个if功能
                        jump_en = ~rs1_data_equal_rs2_data;
                        hold_en = 1'b1;
                    end
                    `INST_BEQ: begin
                        jump_addr = (inst_addr + {{19{imm_bne[12]}}, imm_bne}) & {32{rs1_data_equal_rs2_data}};     // 同上
                        jump_en = rs1_data_equal_rs2_data;
                        hold_en = 1'b1;
                    end
                    default: begin
                        jump_addr = 32'd0;
                        jump_en = 1'b0;
                        hold_en = 1'b0;
                    end
                endcase
            end
            `INST_JAL: begin
                // 将JAL指令后面指令的地址（PC+4）保存到寄存器rd中，主要是为了返回跳转前的位置继续执行。
                rd_data = inst_addr + 32'd4;
                jump_addr = inst_addr + {{11{imm_jal[20]}}, imm_jal};
                jump_en = 1'b1;
                hold_en = 1'b1;
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