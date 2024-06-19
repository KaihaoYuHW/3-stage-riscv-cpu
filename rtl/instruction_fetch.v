module instruction_fetch (
    input wire [31:0] inst_addr,
    output reg [31:0] inst
);

    // 32b * 4096 instruction memory 
    reg [31:0] inst_mem [0:4095];

    // inst_mem[0, 1, 2, 3,...]
    always @(*) begin
        inst = inst_mem[inst_addr >> 2];
    end
    
endmodule