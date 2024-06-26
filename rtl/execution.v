`include "defines.v"

module execution (
    input wire [31:0] inst,
    input wire [31:0] inst_addr,
    input wire [31:0] op1,
    input wire [31:0] op2,
    input wire [31:0] base_addr,
    input wire [31:0] addr_offset,

    // to register file
    output reg [31:0] rd_data,

    // to ctrl
    output reg [31:0] jump_addr,
    output reg jump_en,
    output reg hold_en,

    // from ram reading
    input wire [31:0] ram_r_data,

    // to ram writing
    output reg [31:0] ram_w_addr,
    output reg [3:0] ram_wen,
    output reg [31:0] ram_w_data
);

    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [6:0] opcode;
    wire [31:0] SRA_mask;   // for SRA and SRAI

    wire op1_equal_op2;
    wire op1_less_imm_signed;
    wire op1_less_imm_unsigned;

    assign funct7 = inst[31:25];
    assign funct3 = inst[14:12];
    assign opcode = inst[6:0];

    // for BNE & BEQ
    assign op1_equal_op2 = (op1 == op2) ? 1'b1 : 1'b0;
    // for SLTI
    assign op1_less_imm_signed = ($signed(op1) < $signed({{20{inst[31]}}, inst[31:20]}))? 1'b1: 1'b0;
    // for SLTIU
    assign op1_less_imm_unsigned = (op1 < {{20{inst[31]}}, inst[31:20]})? 1'b1: 1'b0;

    // for SLT
    assign op1_less_op2_signed = ($signed(op1) < $signed(op2))? 1'b1: 1'b0;
    // for SLTU
    assign op1_less_op2_unsigned = (op1 < op2)? 1'b1: 1'b0;

    // for SRA and SRAI
    assign SRA_mask = 32'hffff_ffff >> op2[4:0];

    // ALU
    wire [31:0] op1_add_op2;
    wire [31:0] op1_xor_op2;
    wire [31:0] op1_and_op2;
    wire [31:0] op1_or_op2;
    wire [31:0] op1_shift_letf_op2;
    wire [31:0] op1_shift_right_op2;
    wire [31:0] base_addr_add_addr_offset;

    assign op1_add_op2 = op1 + op2;
    assign op1_xor_op2 = op1 ^ op2;
    assign op1_and_op2 = op1 & op2;
    assign op1_or_op2 = op1 | op2;
    assign op1_shift_letf_op2 = op1 << op2;
    assign op1_shift_right_op2 = op1 >> op2;
    assign base_addr_add_addr_offset = base_addr + addr_offset;

    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
                case (funct3)
                    `INST_ADDI: begin
                        rd_data = op1_add_op2;
                    end
                    `INST_SLTI: begin
                        rd_data = {31'b0, op1_less_imm_signed};
                    end
                    `INST_SLTIU: begin
                        rd_data = {31'b0, op1_less_imm_unsigned};
                    end
                    `INST_XORI: begin
                        rd_data = op1_xor_op2;
                    end
                    `INST_ORI: begin
                        rd_data = op1_or_op2;
                    end
                    `INST_ANDI: begin
                        rd_data = op1_and_op2;
                    end
                    `INST_SLLI: begin
                        rd_data = op1_shift_letf_op2;
                    end
                    `INST_SRI: begin
                        if (funct7[5] == 1'b1)
                            rd_data = (SRA_mask & op1_shift_right_op2) | ((~SRA_mask) & {32{op1[31]}});    // SRAI
                        else
                            rd_data = op1_shift_right_op2;  // SRLI        
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
                            rd_data = op1_add_op2;
                        else
                            rd_data = op1 - op2;
                    end
                    `INST_SLL: begin
                        rd_data = op1_shift_letf_op2;
                    end
                    `INST_SLT: begin
                        rd_data = {31'b0, op1_less_op2_signed};
                    end
                    `INST_SLTU: begin
                        rd_data = {31'b0, op1_less_op2_unsigned};
                    end
                    `INST_XOR: begin
                        rd_data = op1_xor_op2;
                    end
                    `INST_OR: begin
                        rd_data = op1_or_op2;
                    end
                    `INST_AND: begin
                        rd_data = op1_and_op2;
                    end
                    `INST_SR: begin
                        if (funct7[5] == 1'b1)
                            rd_data = (SRA_mask & op1_shift_right_op2) | ((~SRA_mask) & {32{op1[31]}});
                        else
                            rd_data = op1_shift_right_op2;
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
                        jump_addr = base_addr_add_addr_offset;
                        jump_en = ~op1_equal_op2;
                        hold_en = ~op1_equal_op2;
                    end
                    `INST_BEQ: begin
                        jump_addr = base_addr_add_addr_offset;
                        jump_en = op1_equal_op2;
                        hold_en = op1_equal_op2;
                    end
                    `INST_BLT: begin
                        jump_addr = base_addr_add_addr_offset;
                        jump_en = op1_less_op2_signed;
                        hold_en = op1_less_op2_signed;
                    end
                    `INST_BGE: begin
                        jump_addr = base_addr_add_addr_offset;
                        jump_en = ~op1_less_op2_signed;
                        hold_en = ~op1_less_op2_signed;
                    end
                    `INST_BLTU: begin
                        jump_addr = base_addr_add_addr_offset;
                        jump_en = op1_less_op2_unsigned;
                        hold_en = op1_less_op2_unsigned;
                    end
                    `INST_BGEU: begin
                        jump_addr = base_addr_add_addr_offset;
                        jump_en = ~op1_less_op2_unsigned;
                        hold_en = ~op1_less_op2_unsigned;
                    end
                    default: begin
                        jump_addr = 32'd0;
                        jump_en = 1'b0;
                        hold_en = 1'b0;
                    end
                endcase
            end
            `INST_TYPE_L: begin
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
                case (funct3)
                    `INST_LW: begin
                        rd_data = ram_r_data;
                    end
                    `INST_LH: begin
                        case (op1_add_op2[1])
                            1'b0: begin
                                rd_data = {{16{ram_r_data[15]}}, ram_r_data[15:0]};
                            end
                            1'b1: begin
                                rd_data = {{16{ram_r_data[31]}},ram_r_data[31:16]};
                            end
                            default: begin
                                rd_data = 32'b0;
                            end
                        endcase
                    end
                    `INST_LB: begin
                        case (op1_add_op2[1:0])
                            2'b00: begin
                                rd_data = {{24{ram_r_data[7]}}, ram_r_data[7:0]};
                            end
                            2'b01: begin
                                rd_data = {{24{ram_r_data[15]}}, ram_r_data[15:8]};
                            end
                            2'b10: begin
                                rd_data = {{24{ram_r_data[23]}}, ram_r_data[23:16]};
                            end
                            2'b11: begin
                                rd_data = {{24{ram_r_data[31]}}, ram_r_data[31:24]};
                            end
                            default: begin
                                rd_data = 32'b0;
                            end
                        endcase
                    end
                    `INST_LHU: begin
                        case (op1_add_op2[1])
                            1'b0: begin
                                rd_data = {16'b0, ram_r_data[15:0]};
                            end
                            1'b1: begin
                                rd_data = {16'b0, ram_r_data[31:16]};
                            end
                            default: begin
                                rd_data = 32'b0;
                            end
                        endcase
                    end
                    `INST_LBU: begin
                        case (op1_add_op2[1:0])
                            2'b00: begin
                                rd_data = {24'b0, ram_r_data[7:0]};
                            end
                            2'b01: begin
                                rd_data = {24'b0, ram_r_data[15:8]};
                            end
                            2'b10: begin
                                rd_data = {24'b0, ram_r_data[23:16]};
                            end
                            2'b11: begin
                                rd_data = {24'b0, ram_r_data[31:24]};
                            end
                            default: begin
                                rd_data = 32'b0;
                            end
                        endcase
                    end
                    default: begin
                        rd_data = 32'b0;
                    end
                endcase
            end
            `INST_TYPE_S: begin
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
                rd_data = 32'b0;
                case (funct3)
                    `INST_SW: begin
                        ram_wen = 4'b1111;
                        ram_w_addr = base_addr_add_addr_offset;
                        ram_w_data = op2;
                    end
                    `INST_SH: begin
                        ram_w_addr = base_addr_add_addr_offset;
                        case (base_addr_add_addr_offset[1])
                            1'b0: begin
                                ram_wen = 4'b0011;
                                ram_w_data = {16'b0, op2[15:0]};
                            end
                            1'b1: begin
                                ram_wen = 4'b1100;
                                ram_w_data = {op2[15:0], 16'b0};
                            end
                            default: begin
                                ram_wen = 4'b0000;
                                ram_w_data = 32'b0;
                            end
                        endcase
                    end
                    `INST_SB: begin
                        ram_w_addr = base_addr_add_addr_offset;
                        case (base_addr_add_addr_offset)
                            2'b00: begin
                                ram_wen = 4'b0001;
                                ram_w_data = {24'b0, op2[7:0]};
                            end 
                            2'b01: begin
                                ram_wen = 4'b0010;
                                ram_w_data = {16'b0, op2[7:0], 8'b0};
                            end
                            2'b10: begin
                                ram_wen = 4'b0100;
                                ram_w_data = {8'b0, op2[7:0], 16'b0};
                            end
                            2'b11: begin
                                ram_wen = 4'b1000;
                                ram_w_data = {op2[7:0], 24'b0};
                            end
                            default: begin
                                ram_wen = 4'b0000;
                                ram_w_data = 32'b0;
                            end
                        endcase
                    end
                    default: begin
                        ram_wen = 4'b0;
                        ram_w_addr = 32'b0;
                        ram_w_data = 32'b0;
                    end
                endcase
            end
            `INST_JAL: begin
                // store the instruction address (PC+4) following JAL insturction in register rd, so that we can return to the position before JAL and keep processing. 
                rd_data = op1_add_op2;
                jump_addr = base_addr_add_addr_offset;
                jump_en = 1'b1;
                hold_en = 1'b1;
            end
            `INST_LUI: begin
                rd_data = op1;
                jump_addr = 32'd0;
                jump_en = 1'b0;
                hold_en = 1'b0;
            end
            `INST_JALR: begin
                rd_data = op1_add_op2;
                jump_addr = base_addr_add_addr_offset;
                jump_en = 1'b1;
                hold_en = 1'b1;
            end
            `INST_AUIPC: begin
                rd_data = op1_add_op2;
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