# 3-stage-riscv-cpu
This project is based on [tiny riscv](https://github.com/liangkangnan/tinyriscv). After stages division, we design a CPU step by step by connecting individual modules together, and finally realize a simple 3-stage pipelined CPU including instruction fetch (if), instruction decode (id), and execution (ex). 

---

## Instructions
The CPU can run following basic risc instructions.

| Inst | Name | FMT | Opcode | funct3 | funct7 | Description | Note |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| add | ADD | R | 0110011 | 0x0 | 0x00 | rd = rs1 + rs2 | |
| sub | SUB | R | 0110011 | 0x0 | 0x20 | rd = rs1 - rs2 | |
| xor | XOR | R | 0110011 | 0x4 | 0x00 | rd = rs1 ^ rs2 | |
| or | OR | R | 0110011 | 0x6 | 0x00 | rd = rs1 or rs2 | |
| and | AND | R | 0110011 | 0x7 | 0x00 | rd = rs1 and rs2 | |
| sll | Shift Left Logical | R | 0110011 | 0x1 | 0x00 | rd = rs1 << rs2 | |
| srl | Shift Right Logical | R | 0110011 | 0x5 | 0x00 | rd = rs1 >> rs2 | |
| sra | Shift Right Arith* | R | 0110011 | 0x5 | 0x20 | rd = rs1 >> rs2 | msb-extends |
| slt | Set Less Than | R | 0110011 | 0x2 | 0x00 | rd = (rs1 < rs2) ? 1 : 0 | |
| sltu | Set Less Than (U) | R | 0110011 | 0x3 | 0x00 | rd = (rs1 < rs2) ? 1 : 0 | zero-extends |
| addi | ADD Immediate | I | 0010011 | 0x0 | | rd = rs1 + imm | |
| xori | XOR Immediate | I | 0010011 | 0x4 | | rd = rs1 ^ imm | |
| ori | OR Immediate | I | 0010011 | 0x6 | | rd = rs1 or imm | |
| andi | AND Immediate | I | 0010011 | 0x7 | | rd = rs1 and imm | |
| slli | Shift Left Logical Imm | I | 0010011 | 0x1 | imm[5:11]=0x00 | rd = rs1 << imm[0:4] | |
| srli | Shift Right Logical Imm | I | 0010011 | 0x5 | imm[5:11]=0x00 | rd = rs1 >> imm[0:4] | |
| srai | Shift Right Arith Imm | I | 0010011 | 0x5 | imm[5:11]=0x20 | rd = rs1 >> imm[0:4] | msb-extends |
| slti | Set Less Than Imm | I | 0010011 | 0x2 | | rd = (rs1 < imm) ? 1 : 0 | |
| sltiu | Set Less Than Imm (U) | I | 0010011 | 0x3 | | rd = (rs1 < imm) ? 1 : 0 | zero-extends |
| lb | Load Byte | I | 0000011 | 0x0 | | rd = M[rs1+imm][0:7] | |
| lh | Load Half | I | 0000011 | 0x1 | | rd = M[rs1+imm][0:15] | |
| lw | Load Word | I | 0000011 | 0x2 | | rd = M[rs1+imm][0:31] | |
| lbu | Load Byte (U) | I | 0000011 | 0x4 | | rd = M[rs1+imm][0:7] | zero-extends |
| lhu | Load Half (U) | I | 0000011 | 0x5 | | rd = M[rs1+imm][0:15] | zero-extends |
| sb | Store Byte | S | 0100011 | 0x0 | | M[rs1+imm][0:7] = rs2[0:7] | |
| sh | Store Half | S | 0100011 | 0x1 | | M[rs1+imm][0:15] = rs2[0:15] | |
| sw | Store Word | S | 0100011 | 0x2 | | M[rs1+imm][0:31] = rs2[0:31] | |
| beq | Branch == | B | 1100011 | 0x0 | | if(rs1 == rs2) PC += imm | |
| bne | Branch != | B | 1100011 | 0x1 | | if(rs1 != rs2) PC += imm | |
| blt | Branch < | B | 1100011 | 0x4 | | if(rs1 < rs2) PC += imm | |
| bge | Branch ≤ | B | 1100011 | 0x5 | | if(rs1 >= rs2) PC += imm | |
| bltu | Branch < (U) | B | 1100011 | 0x6 | | if(rs1 < rs2) PC += imm | zero-extends |
| bgeu | Branch ≥ (U) | B | 1100011 | 0x7 | | if(rs1 >= rs2) PC += imm | zero-extends |
| jal | Jump And Link | J | 1101111 | | | rd = PC+4; PC += imm | |
| jalr | Jump And Link Reg | I | 1100111 | 0x0 | | rd = PC+4; PC = rs1 + imm | |
| lui | Load Upper Imm | U | 0110111 | | | rd = imm << 12 | |
| auipc | Add Upper Imm to PC | U | 0010111 | | | rd = PC + (imm << 12) | |

Reference: [The RISC-V Instruction Set Manual](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)

---

## Architecture
![CPU Architecture](doc/3%20stage%20riscv%20cpu.png)

The architecture of CPU is shown in the above figure, where the instruction fetch is made of a dual-port block RAM. The instructions can be sent by a computer through UART connected with writing ports. In addition, RAM in the figure is used for load and store instructions.

---

## Simulation
There are files to verify every instruction of risc-v in `sim/inst_txt` folder. We design a test bench to read a corresponding instruction file. We simulate process of instructions running on CPU, and then all passed. As a result, the design is correct. 
