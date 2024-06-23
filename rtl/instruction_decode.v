`include "defines.v"

module instruction_decode (
    // from instruction rom
    input wire [31:0] inst,
    input wire [31:0] inst_addr,

    // from register file
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,

    // to register file
    output reg [4:0] rs1_addr,
    output reg [4:0] rs2_addr,

    // to execution
    output reg [31:0] op1,
    output reg [31:0] op2,
    // write operation delay to execution phase
    // store result in write register address
    output reg [4:0] rd_addr,
    // write enable
    output reg rd_wen,
    output reg [31:0] base_addr,
    output reg [31:0] addr_offset
);

    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [6:0] opcode;
    // 为了更加直观地对照instruction的结构（即rs1就是rs1，而不是将imm暂时放入rs1中），我们将imm放到execution中定义。

    assign funct7 = inst[31:25];
    assign funct3 = inst[14:12];
    assign opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                base_addr = 32'd0;
                addr_offset = 32'd0;
                case (funct3)
                    `INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI: begin
                        rs1_addr = inst[19:15];
                        rs2_addr = 5'd0;
                        op1 = rs1_data;
                        op2 = {{20{inst[31]}}, inst[31:20]};    // imm_addi
                        rd_addr = inst[11:7];
                        rd_wen = 1'b1;
                    end
                    `INST_SLLI,`INST_SRI: begin
                        rs1_addr = inst[19:15];
                        rs2_addr = 5'd0;
                        op1 = rs1_data;
                        op2 = {27'b0, inst[24:20]};     // shamt
                        rd_addr = inst[11:7];
                        rd_wen = 1'b1;
                    end
                    default: begin
                        rs1_addr = 5'd0;
                        rs2_addr = 5'd0;
                        op1 = 32'b0;
                        op2 = 32'b0;
                        rd_addr = 5'd0;
                        rd_wen = 1'b0;
                    end
                endcase
            end
            `INST_TYPE_R_M: begin
                base_addr = 32'd0;
                addr_offset = 32'd0;
                case (funct3)
                    `INST_ADD_SUB,`INST_SLT,`INST_SLTU,`INST_XOR,`INST_OR,`INST_AND: begin
                        rs1_addr = inst[19:15];
                        rs2_addr = inst[24:20];
                        op1 = rs1_data;
                        op2 = rs2_data;
                        rd_addr = inst[11:7];
                        rd_wen = 1'b1;
                    end 
                    `INST_SLL,`INST_SR: begin
                        rs1_addr = inst[19:15];
                        rs2_addr = inst[24:20];
                        op1 = rs1_data;
                        op2 = {27'b0, rs2_data[4:0]};
                        rd_addr = inst[11:7];
                        rd_wen = 1'b1;
                    end
                    default: begin
                        rs1_addr = 5'd0;
                        rs2_addr = 5'd0;
                        op1 = 32'b0;
                        op2 = 32'b0;
                        rd_addr = 5'd0;
                        rd_wen = 1'b0;
                    end
                endcase
            end
            `INST_TYPE_B: begin
                case (funct3)
                    `INST_BNE,`INST_BEQ,`INST_BLT,`INST_BGE,`INST_BLTU,`INST_BGEU: begin
                        rs1_addr = inst[19:15];
                        rs2_addr = inst[24:20];
                        op1 = rs1_data;
                        op2 = rs2_data;
                        rd_addr = 5'd0;
                        rd_wen = 1'b0;
                        base_addr = inst_addr;
                        addr_offset = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};   // imm_bne
                    end
                    default: begin
                        rs1_addr = 5'd0;
                        rs2_addr = 5'd0;
                        op1 = 32'b0;
                        op2 = 32'b0;
                        rd_addr = 5'd0;
                        rd_wen = 1'b0;
                        base_addr = 32'd0;
                        addr_offset = 32'd0;
                    end
                endcase
            end
            `INST_JAL: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                op1 = inst_addr;
                op2 = 32'd4;
                rd_addr = inst[11:7];
                rd_wen = 1'b1;
                base_addr = inst_addr;
                addr_offset = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};     // imm_jal
            end
            `INST_LUI: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                op1 = {inst[31:12], 12'b0};     // imm_lui
                op2 = 32'b0;
                rd_addr = inst[11:7];
                rd_wen = 1'b1;
                base_addr = 32'd0;
                addr_offset = 32'd0; 
            end
            `INST_JALR: begin
                rs1_addr = inst[19:15];
                rs2_addr = 5'd0;
                op1 = inst_addr;
                op2 = 32'd4;
                rd_addr = inst[11:7];
                rd_wen = 1'b1;
                base_addr = rs1_data;
                addr_offset = {{20{inst[31]}}, inst[31:20]};    // imm_jalr=imm_addi
            end
            `INST_AUIPC: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                op1 = inst_addr;
                op2 = {inst[31:12], 12'b0};    // imm_lui=imm_auipc
                rd_addr = inst[11:7];
                rd_wen = 1'b1;
                base_addr = 32'd0;
                addr_offset = 32'd0;
            end
            default: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                op1 = 32'b0;
                op2 = 32'b0;
                rd_addr = 5'd0;
                rd_wen = 1'b0;
                base_addr = 32'd0;
                addr_offset = 32'd0;
            end
        endcase
    end
    
endmodule