`include "defines.v"

module instruction_decode (
    // from instruction rom
    input wire [31:0] inst,

    // from register file
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,

    // to register file
    output reg [4:0] rs1_addr,
    output reg [4:0] rs2_addr,

    // to execution
    // op1 + op2 = result
    output reg [31:0] op1,
    output reg [31:0] op2,
    // write operation delay to execution phase
    // store result in write register address
    output reg [4:0] rd_addr,
    // write enable
    output reg rd_wen
);

    wire [6:0] funct7;
    wire [4:0] rs2;     // rs2 address
    wire [4:0] rs1;     // rs1 address
    wire [2:0] funct3;
    wire [4:0] rd;      // rd address
    wire [6:0] opcode;
    wire [11:0] imm;

    assign funct7 = inst[31:25];
    assign rs2 = inst[24:20];
    assign rs1 = inst[19:15];
    assign funct3 = inst[14:12];
    assign rd = inst[11:7];
    assign opcode = inst[6:0];
    assign imm = inst[31:20];

    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                case (funct3)
                    `INST_ADDI: begin
                        rs1_addr = rs1;
                        rs2_addr = 5'b0;
                        op1 = rs1_data;
                        op2 = {{20{imm[11]}}, imm};
                        rd_addr = rd;
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
                case (funct3)
                    `INST_ADD_SUB: begin
                        rs1_addr = rs1;
                        rs2_addr = rs2;
                        op1 = rs1_data;
                        op2 = rs2_data;
                        rd_addr = rd;
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
            default: begin
                rs1_addr = 5'd0;
                rs2_addr = 5'd0;
                op1 = 32'b0;
                op2 = 32'b0;
                rd_addr = 5'd0;
                rd_wen = 1'b0;
            end
            `INST_TYPE_B: begin
                case (funct3)
                    `INST_BNE: begin
                        rs1_addr = rs1;
                        rs2_addr = rs2;
                        op1 = rs1_data;
                        op2 = rs2_data;
                        rd_addr = 5'd0;
                        rd_wen = 1'b0;
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
        endcase
    end
    
endmodule