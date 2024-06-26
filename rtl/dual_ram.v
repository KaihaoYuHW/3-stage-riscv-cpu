module dual_ram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12,
    parameter MEM_BLOCKS = 4096     // Memory has 2^12 = 4096 blocks(addresses)
)(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire wen,
    input wire [ADDR_WIDTH-1:0] w_addr,
    input wire [DATA_WIDTH-1:0] w_data,
    input wire ren,
    input wire [ADDR_WIDTH-1:0] r_addr,
    output wire [DATA_WIDTH-1:0] r_data
);

    // 32b * 4096 instruction memory 
    // This a self designed memory, and does not conform to rules of standard memory (i.e. The storage of a block or an address is 1 byte.). A standard memory is replaced with it during a real CPU design.
    reg [DATA_WIDTH-1:0] inst_mem [0:MEM_BLOCKS-1];

    reg [DATA_WIDTH-1:0] w_data_dly;
    reg [DATA_WIDTH-1:0] r_data_dly;
    reg rd_equ_wr_flag;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            r_data_dly <= 32'b0;
        // When ren = 1'b1, read data. When ren = 1'b0, hold value.
        else if (ren)
            r_data_dly <= inst_mem[r_addr];
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            inst_mem[w_addr] <= 32'b0;
        // When wen = 1'b1, write data in a block of inst_mem. When wen = 1'b0, hold block value.
        else if (wen)
            inst_mem[w_addr] <= w_data;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            w_data_dly <= 32'b0;
        else 
            w_data_dly <= w_data;
    end

    // When reading and writing the same block in memory at a time, we must read the new value that is about to be written instead of old value in the block. 
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            rd_equ_wr_flag <= 1'b0;
        else if (wen && ren && w_addr == r_addr)
            rd_equ_wr_flag <= 1'b1;
        else
            rd_equ_wr_flag <= 1'b0;
    end

    assign r_data = (rd_equ_wr_flag)? w_data_dly: r_data_dly;
    
endmodule