module ram (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire [3:0] wen,       // write one byte at a time during writing operation.
    input wire [31:0] w_addr,
    input wire [31:0] w_data,
    input wire ren,             // read a whole 32 bits instruction r_data during reading operation
    input wire [31:0] r_addr,
    output wire [31:0] r_data
);

    wire [31:0] w_addr_shift;
    wire [31:0] r_addr_shift;

    assign w_addr_shift = w_addr >> 2;
    assign w_addr_shift = r_addr << 2;

    // byte 0
    dual_ram #(
        .DATA_WIDTH(8),         
        .ADDR_WIDTH(12),
        .MEM_BLOCKS(4096)       // 4 bytes as a group. There are total 4096 groups, so there are 4096 kinds of bytes 
    ) ram_byte0 (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .wen(wen[0]),
        .w_addr(w_addr_shift[11:0]),
        .w_data(w_data[7:0]),
        .ren(ren),
        .r_addr(r_addr_shift[11:0]),
        .r_data(r_data[7:0])
    );

    // byte 1
    dual_ram #(
        .DATA_WIDTH(8),         
        .ADDR_WIDTH(12),
        .MEM_BLOCKS(4096)
    ) ram_byte1 (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .wen(wen[1]),
        .w_addr(w_addr_shift[11:0]),
        .w_data(w_data[15:8]),
        .ren(ren),
        .r_addr(r_addr_shift[11:0]),
        .r_data(r_data[15:8])
    );
    
    // byte 2
    dual_ram #(
        .DATA_WIDTH(8),         
        .ADDR_WIDTH(12),
        .MEM_BLOCKS(4096)
    ) ram_byte2 (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .wen(wen[2]),
        .w_addr(w_addr_shift[11:0]),
        .w_data(w_data[23:16]),
        .ren(ren),
        .r_addr(r_addr_shift[11:0]),
        .r_data(r_data[23:16])
    );

    // byte 3
    dual_ram #(
        .DATA_WIDTH(8),         
        .ADDR_WIDTH(12),
        .MEM_BLOCKS(4096)
    ) ram_byte3 (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .wen(wen[3]),
        .w_addr(w_addr_shift[11:0]),
        .w_data(w_data[31:24]),
        .ren(ren),
        .r_addr(r_addr_shift[11:0]),
        .r_data(r_data[31:24])
    );
endmodule