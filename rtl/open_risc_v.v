module open_risc_v (
    input wire sys_clk,
    input wire sys_rst_n
);

    // program counter to instruction fetch rom
    wire [31:0] pc_if_inst_addr;

    // instruction fetch to if_id
    wire [31:0] if_if_id_inst;

    // if_id to instruction decode
    wire [31:0] if_id_id_inst;

    // if_id to id_ex
    wire [31:0] if_id_id_ex_inst_addr;

    // instruction decode to register file
    wire [31:0] id_rf_rs1_data;
    wire [31:0] id_rf_rs2_data;
    wire [4:0] id_rf_rs1_addr;
    wire [4:0] id_rf_rs2_addr;

    // instruction decode to id_ex
    wire [31:0] id_id_ex_op1;
    wire [31:0] id_id_ex_op2;
    wire [4:0] id_id_ex_rd_addr;
    wire id_id_ex_rd_wen;

    // execution to register file
    wire [31:0] ex_rf_reg_wdata;

    // id_ex to execution
    wire [31:0] id_ex_ex_inst;
    wire [31:0] id_ex_ex_inst_addr;
    wire [31:0] id_ex_ex_op1;
    wire [31:0] id_ex_ex_op2;

    // id_ex to register file
    wire [4:0] id_ex_rf_rd_addr;
    wire id_ex_rf_rd_wen;

    program_counter program_counter_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .inst_addr(pc_if_inst_addr)
    );

    instruction_fetch instruction_fetch_inst (
        .inst_addr(pc_if_inst_addr),
        .inst(if_if_id_inst)
    );

    if_id if_id_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .inst(if_if_id_inst),
        .inst_addr(pc_if_inst_addr),
        .inst_dly(if_id_id_inst),
        .inst_addr_dly(if_id_id_ex_inst_addr)
    );

    instruction_decode instruction_decode_inst (
        .inst(if_id_id_inst),
        .rs1_data(id_rf_rs1_data),
        .rs2_data(id_rf_rs2_data),
        .rs1_addr(id_rf_rs1_addr),
        .rs2_addr(id_rf_rs2_addr),
        .op1(id_id_ex_op1),
        .op2(id_id_ex_op2),
        .rd_addr(id_id_ex_rd_addr),
        .rd_wen(id_id_ex_rd_wen)
    );

    register_file register_file_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .reg1_raddr(id_rf_rs1_addr),
        .reg2_raddr(id_rf_rs2_addr),
        .reg1_rdata(id_rf_rs1_data),
        .reg2_rdata(id_rf_rs2_data),
        .reg_waddr(id_ex_rf_rd_addr),
        .reg_wdata(ex_rf_reg_wdata),
        .reg_wen(id_ex_rf_rd_wen)
    );

    id_ex id_ex_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .inst(if_id_id_inst),
        .inst_addr(if_id_id_ex_inst_addr),
        .op1(id_id_ex_op1),
        .op2(id_id_ex_op2),
        .rd_addr(id_id_ex_rd_addr),
        .rd_wen(id_id_ex_rd_wen),
        .inst_dly(id_ex_ex_inst),
        .inst_addr_dly(id_ex_ex_inst_addr),
        .op1_dly(id_ex_ex_op1),
        .op2_dly(id_ex_ex_op2),
        .rd_addr_dly(id_ex_rf_rd_addr),
        .rd_wen_dly(id_ex_rf_rd_wen)
    );

    execution execution_inst (
        .inst(id_ex_ex_inst),
        .op1(id_ex_ex_op1),
        .op2(id_ex_ex_op2),
        .rd_data(ex_rf_reg_wdata)
    );
    
endmodule