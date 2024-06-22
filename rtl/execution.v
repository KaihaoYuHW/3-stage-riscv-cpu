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

    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [6:0] opcode;
    wire [11:0] imm_addi;   // ADDI
    wire [12:0] imm_bne;    // BNE, BEQ
    wire [20:0] imm_jal;    // JAL
    wire [31:0] imm_lui;    // LUI
    wire [4:0] shamt;       // SLLI, SRI
    wire [31:0] SRAI_mask;  // SRAI
    wire [31:0] SRA_mask;   // SRA

    wire rs1_data_equal_rs2_data;
    wire rs1_data_less_imm_signed;
    wire rs1_data_less_imm_unsigned;

    assign funct7 = inst[31:25];
    assign funct3 = inst[14:12];
    assign opcode = inst[6:0];
    assign imm_addi = inst[31:20];
    assign imm_bne = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    assign imm_jal = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
    assign imm_lui = {inst[31:12], {12{1'b0}}};
    assign shamt = inst[24:20];

    // for BNE & BEQ
    assign rs1_data_equal_rs2_data = (rs1_data == rs2_data) ? 1'b1 : 1'b0;
    // for SLTI
    assign rs1_data_less_imm_signed = ($signed(rs1_data) < $signed({{20{imm_addi[11]}}, imm_addi}))? 1'b1: 1'b0;
    // for SLTIU
    assign rs1_data_less_imm_unsigned = (rs1_data < {{20{imm_addi[11]}}, imm_addi})? 1'b1: 1'b0;

    // for SLT
    assign rs1_data_less_rs2_data_signed = ($signed(rs1_data) < $signed(rs2_data))? 1'b1: 1'b0;
    // for SLTU
    assign rs1_data_less_rs2_data_unsigned = (rs1_data < rs2_data)? 1'b1: 1'b0;

    // for SRAI
    assign SRAI_mask = 32'hffff_ffff >> shamt;
    // for SRA
    assign SRA_mask = 32'hffff_ffff >> rs2_data[4:0];

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
                    `INST_SLTI: begin
                        rd_data = {31'b0, rs1_data_less_imm_signed};
                    end
                    `INST_SLTIU: begin
                        rd_data = {31'b0, rs1_data_less_imm_unsigned};
                    end
                    `INST_XORI: begin
                        rd_data = rs1_data ^ {{20{imm_addi[11]}}, imm_addi};
                    end
                    `INST_ORI: begin
                        rd_data = rs1_data | {{20{imm_addi[11]}}, imm_addi};
                    end
                    `INST_ANDI: begin
                        rd_data = rs1_data & {{20{imm_addi[11]}}, imm_addi};
                    end
                    `INST_SLLI: begin
                        rd_data = rs1_data << shamt;
                    end
                    `INST_SRI: begin
                        if (funct7[5] == 1'b1)
                            rd_data = (SRAI_mask & (rs1_data >> shamt)) | ((~SRAI_mask) & {32{rs1_data[31]}});
                        else
                            rd_data = rs1_data >> shamt;        
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
                    `INST_SLL: begin
                        rd_data = rs1_data << rs2_data[4:0];
                    end
                    `INST_SLT: begin
                        rd_data = {31'b0, rs1_data_less_rs2_data_signed};
                    end
                    `INST_SLTU: begin
                        rd_data = {31'b0, rs1_data_less_rs2_data_unsigned};
                    end
                    `INST_XOR: begin
                        rd_data = rs1_data ^ rs2_data;
                    end
                    `INST_OR: begin
                        rd_data = rs1_data | rs2_data;
                    end
                    `INST_AND: begin
                        rd_data = rs1_data & rs2_data;
                    end
                    `INST_SR: begin
                        if (funct7[5] == 1'b1)
                            rd_data = (SRA_mask & (rs1_data >> rs2_data[4:0])) | ((~SRA_mask) & {32{rs1_data[31]}});
                        else
                            rd_data = rs1_data >> rs2_data[4:0];
                    end
                    default: begin
                        rd_data = 32'b0;
                    end
                endcase
            end
            `INST_TYPE_B: begin
                rd_data = 32'b0;
                case (funct3)
                    `INST_BNE: begin
                        jump_addr = (inst_addr + {{19{imm_bne[12]}}, imm_bne}) & {32{(~rs1_data_equal_rs2_data)}};  // 这里其实利用&操作来实现一个if功能
                        jump_en = ~rs1_data_equal_rs2_data;
                        hold_en = ~rs1_data_equal_rs2_data;
                    end
                    `INST_BEQ: begin
                        jump_addr = (inst_addr + {{19{imm_bne[12]}}, imm_bne}) & {32{rs1_data_equal_rs2_data}};     // 同上
                        jump_en = rs1_data_equal_rs2_data;
                        hold_en = rs1_data_equal_rs2_data;
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
            `INST_LUI: begin
                rd_data = imm_lui;
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
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