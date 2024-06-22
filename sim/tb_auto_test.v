`timescale 1ns/1ps

module tb_auto_test;

    // inputs
    reg sys_clk;
    reg sys_rst_n;

    // outputs


    wire [31:0] x3;     // 表示我们第几个test。
    wire [31:0] x26;    // 为1，表示我们测试结束。
    wire [31:0] x27;    // 为0表示fail，为1表示pass。
    
    assign x3 = tb_auto_test.open_risc_v_inst.register_file_inst.reg_mem[3];
    assign x26 = tb_auto_test.open_risc_v_inst.register_file_inst.reg_mem[26];
    assign x27 = tb_auto_test.open_risc_v_inst.register_file_inst.reg_mem[27];

    always #10 sys_clk = ~sys_clk;

    initial begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;

        #30;
        sys_rst_n <= 1'b1;
    end

    // initiate instruction memory
    initial begin
        $readmemh("./inst_txt/rv32ui-p-auipc.txt", tb_auto_test.open_risc_v_inst.instruction_fetch_inst.inst_mem);
    end

    // display results
    integer i;
    initial begin
        // 实现等待功能，当wait括号里面的条件成立，就可以执行wait后面的语句了。
        wait (x26 == 32'b1);

        // 至少延时一个周期，使s11置1以后，再判断pass or fail
        #200;
        if (x27 == 32'b1)
            $display("######  pass  !!!######");
        else begin
            $display("######  fail  !!!######");
            $display("fail testnum = %2d", x3); // 测试的哪个test出问题了
            // fail，则打印所有registers中的值，来查看具体哪里出错。
            for(i = 0; i < 32; i = i + 1) begin
                $display("x%2d register value is %d", i, tb_auto_test.open_risc_v_inst.register_file_inst.reg_mem[i]);
            end
        end
    end

    open_risc_v open_risc_v_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n)
    );

endmodule