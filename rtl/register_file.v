module register_file (
    input wire sys_clk,
    input wire sys_rst_n,

    // from instruction decode
    // read register address: 5'd0 ~ 5'd31
    input wire [4:0] reg1_raddr,
    input wire [4:0] reg2_raddr,

    // from execution
    input wire [4:0] reg_waddr,
    input wire [31:0] reg_wdata,
    input wire reg_wen,

    // to instruction decode
    // read register data
    output reg [31:0] reg1_rdata,
    output reg [31:0] reg2_rdata
);

    // 32 * (32 bit) registers
    reg [31:0] reg_mem[0:31];
    integer i;

    // read from register file
    always @(*) begin
        if (sys_rst_n == 1'b0)
            reg1_rdata = 32'b0;
        // As soon as register 0 is called, its value is forced to be 0. It is useless to assign reg_mem[0] = 0 in advance because if there is an instruction like add zero,ra,sp next, register 0 will not equal to 0.
        else if (reg1_raddr == 5'd0)
            reg1_rdata = 32'b0;
        // solve dependency
        else if (reg_wen == 1'b1 && reg1_raddr == reg_waddr)
            reg1_rdata = reg_wdata;
        else 
            reg1_rdata = reg_mem[reg1_raddr];
    end

    always @(*) begin
        if (sys_rst_n == 1'b0)
            reg2_rdata = 32'b0;
        else if (reg2_raddr == 5'd0)
            reg2_rdata = 32'b0;
        // solve dependency
        else if (reg_wen == 1'b1 && reg2_raddr == reg_waddr)
            reg2_rdata = reg_wdata;
        else
            reg2_rdata = reg_mem[reg2_raddr];
    end

    // write to register file
    always @(posedge sys_clk or negedge sys_rst_n) begin
        // initiate register file: all zero
        if (sys_rst_n == 1'b0) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_mem[i] <= 32'b0;
            end
        end
        else if (reg_wen && reg_waddr != 5'd0)
            reg_mem[reg_waddr] <= reg_wdata;
    end
    
endmodule