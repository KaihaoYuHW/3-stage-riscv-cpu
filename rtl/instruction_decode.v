`include "defines.v"

module instruction_decode (
    // from instruction rom
    input wire [31:0] inst,

    // from register file
    input wire [31:0] rs1_data_in,
    input wire [31:0] rs2_data_in,

    // to register file
    output reg [4:0] rs1_addr,
    output reg [4:0] rs2_addr,

    // to execution
    // rs1_data_out + rs2_data_out = rd_data
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    // write operation delay to execution phase
    // store result in write register address
    output reg [4:0] rd_addr,
    // write enable
    output reg rd_wen
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
                case (funct3)
                    `INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI: begin
                        rs1_addr = inst[19:15];
                        rs2_addr = 5'd0;
                        rs1_data_out = rs1_data_in;
                        rs2_data_out = 32'b0;
                        rd_addr = inst[11:7];
                        rd_wen = 1'b1;
                    end
                    `INST_SLLI,`INST_SRI: begin
                        rs1_addr = inst[19:15];
                        rs2_addr = 5'd0;
                        rs1_data_out = rs1_data_in;
                        rs2_data_out = 32'b0;
                        rd_addr = inst[11:7];
                        rd_wen = 1'b1;
                    end
                    default: begin
                        rs1_addr = 5'd0;
                        rs2_addr = 5'd0;
                        rs1_data_out = 32'b0;
                        rs2_data_out = 32'b0;
                        rd_addr = 5'd0;
                        rd_wen = 1'b0;
                    end
                endcase
            end
            `INST_TYPE_R_M: begin
                case (funct3)
                    `INST_ADD_SUB,`INST_SLL,`INST_SLT,`INST_SLTU,`INST_XOR,`INST_SR,`INST_OR,`INST_AND: begin
                        rs1_addr = inst[19:15];
                        rs2_addr = inst[24:20];
                        rs1_data_out = rs1_data_in;
                        rs2_data_out = rs2_data_in;
                        rd_addr = inst[11:7];
                        rd_wen = 1'b1;
                    end 
                    default: begin
                        rs1_addr = 5'd0;
                        rs2_addr = 5'd0;
                        rs1_data_out = 32'b0;
                        rs2_data_out = 32'b0;
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
                        rs1_data_out = rs1_data_in;
                        rs2_data_out = rs2_data_in;
                        rd_addr = 5'd0;
                        rd_wen = 1'b0;
                    end
                    default: begin
                        rs1_addr = 5'd0;
                        rs2_addr = 5'd0;
                        rs1_data_out = 32'b0;
                        rs2_data_out = 32'b0;
                        rd_addr = 5'd0;
                        rd_wen = 1'b0;
                    end
                endcase
            end
            `INST_JAL: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                rs1_data_out = 32'b0;
                rs2_data_out = 32'b0;
                rd_addr = inst[11:7];
                rd_wen = 1'b1;
            end
            `INST_LUI: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                rs1_data_out = 32'b0;
                rs2_data_out = 32'b0;
                rd_addr = inst[11:7];
                rd_wen = 1'b1;
            end
            `INST_JALR: begin
                rs1_addr = inst[19:15];
                rs2_addr = 5'd0;
                rs1_data_out = rs1_data_in;
                rs2_data_out = 32'b0;
                rd_addr = inst[11:7];
                rd_wen = 1'b1;
            end
            `INST_AUIPC: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                rs1_data_out = 32'b0;
                rs2_data_out = 32'b0;
                rd_addr = inst[11:7];
                rd_wen = 1'b1;
            end
            default: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                rs1_data_out = 32'b0;
                rs2_data_out = 32'b0;
                rd_addr = 5'd0;
                rd_wen = 1'b0;
            end
        endcase
    end
    
endmodule