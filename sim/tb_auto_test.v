`timescale 1ns/1ps

module tb_auto_test;

    // inputs
    reg sys_clk;
    reg sys_rst_n;

    // outputs


    wire [31:0] x3;     // which test is processing
    wire [31:0] x26;    // when x26 = 1, the test finished.
    wire [31:0] x27;    // When x27 = 0, the test failed.
    
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
        $readmemh("./inst_txt/rv32ui-p-sw.txt", tb_auto_test.open_risc_v_inst.instruction_fetch_inst.instruction_memory.inst_mem);
    end

    // display results
    integer i;
    initial begin
        // As soon as the condition in wait funtion is true, we execute the next code.
        wait (x26 == 32'b1);

        // We must wait at least one clock cycle (i.e. register s11 = 1), and then determine pass or not.
        #200;
        if (x27 == 32'b1)
            $display("######  pass  !!!######");
        else begin
            $display("######  fail  !!!######");
            $display("fail testnum = %2d", x3); // Which test failed
            // if it failed, print all registers values to see the specific problems. 
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