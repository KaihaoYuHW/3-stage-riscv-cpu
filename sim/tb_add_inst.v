`timescale 1ns/1ps

module tb_add_inst;

    // inputs
    reg sys_clk;
    reg sys_rst_n;

    // outputs


    always #10 sys_clk = ~sys_clk;

    initial begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;

        #30;
        sys_rst_n <= 1'b1;
    end

    // initiate instruction memory
    initial begin
        $readmemb("inst_data_ADD.txt", tb_add_inst.open_risc_v_inst.instruction_fetch_inst.inst_mem);
    end

    // display results
    initial begin
        while (1) begin
            @(posedge sys_clk)
            $display("x1 register value is %d", tb_add_inst.open_risc_v_inst.register_file_inst.reg_mem[1]);
            $display("x2 register value is %d", tb_add_inst.open_risc_v_inst.register_file_inst.reg_mem[2]);
            $display("x30 register value is %d", tb_add_inst.open_risc_v_inst.register_file_inst.reg_mem[30]);
            $display("-----------------------------");
            $display("-----------------------------");
        end
    end

    open_risc_v open_risc_v_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n)
    );

endmodule