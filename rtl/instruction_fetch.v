module instruction_fetch (
    input wire [31:0] inst_addr,
    output reg [31:0] inst
);

    // 32b * 4096 instruction memory 
    // 这是自己建立的一个存储器，并不符合标准memory的规则（每个地址只存储1byte数据）。当真正的CPU设计时，要用标准memory来替换这个模块。
    reg [31:0] inst_mem [0:4095];

    // inst_mem[0, 1, 2, 3,...]
    always @(*) begin
        inst = inst_mem[inst_addr >> 2];
    end
    
endmodule