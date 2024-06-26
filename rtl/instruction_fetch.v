module instruction_fetch (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire wen,
    input wire [31:0] w_addr,
    input wire [31:0] w_data,
    input wire ren,
    input wire [31:0] r_addr,
    output wire [31:0] r_data
);

    wire [31:0] w_addr_shift;
    wire [31:0] r_addr_shift;

    // inst_mem[0, 1, 2, 3,...]
    assign w_addr_shift = w_addr >> 2;
    assign r_addr_shift = r_addr >> 2;

    dual_ram #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(12),
        .MEM_BLOCKS(4096)
    ) instruction_memory (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .wen(wen),
        .w_addr(w_addr_shift[11:0]),
        .w_data(w_data),
        .ren(ren),
        .r_addr(r_addr_shift[11:0]),
        .r_data(r_data)
    );
    
endmodule