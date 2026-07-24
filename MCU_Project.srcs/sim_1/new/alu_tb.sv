`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/15 14:45:39
// Design Name: 
// Module Name: alu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

interface alu_if #(parameter WIDTH = 32) ();
    logic [WIDTH-1:0] in1;
    logic [WIDTH-1:0] in2;
    aluOp_t aluOp;
    logic [WIDTH-1:0] out;
endinterface

class alu_transaction #(parameter WIDTH = 32);
    rand logic [WIDTH-1:0] in1;
    rand logic [WIDTH-1:0] in2;
    rand aluOp_t aluOp;

    logic [WIDTH-1:0] out;

    // constraint small_numbers {
    //     in1 inside {[0:100]};
    //     in2 inside {[0:100]};
    // }

    function void display();
        $display("Transaction: in1=%0h, in2=%0h, aluOp=%s", in1, in2, aluOp.name());
    endfunction

endclass

class driver #(parameter WIDTH = 32);
    virtual alu_if #(WIDTH) vif;
    event drv_done;
    mailbox #(alu_transaction #(WIDTH)) drv_mb;
    alu_transaction #(WIDTH) tr;

    function new(
        virtual alu_if #(WIDTH) vif, 
        mailbox #(alu_transaction #(WIDTH)) drv_mb,
        event drv_done
    );
        this.vif = vif;
        this.drv_mb = drv_mb;
        this.drv_done = drv_done;
    endfunction

    task run();
        $display("T=%0t: Driver starting", $time);

        forever begin
            drv_mb.get(tr);

            vif.in1 = tr.in1;
            vif.in2 = tr.in2;
            vif.aluOp = tr.aluOp;

            #1;

            -> drv_done;

        end
    endtask
endclass

class generator #(parameter WIDTH = 32);
    mailbox #(alu_transaction #(WIDTH)) drv_mb;
    alu_transaction #(WIDTH) tr;
    event drv_done;

    function new(
        mailbox #(alu_transaction #(WIDTH)) drv_mb,
        event drv_done
    );
        this.drv_mb = drv_mb;
        this.drv_done = drv_done;
    endfunction

    task run(int num_transactions = 100);
        repeat (num_transactions) begin
            tr = new();
            assert(tr.randomize());
            drv_mb.put(tr);
            @(drv_done);
        end
    endtask

endclass

class monitor #(parameter WIDTH = 32);
    virtual alu_if #(WIDTH) vif;
    mailbox #(alu_transaction #(WIDTH)) mon_mb;
    alu_transaction #(WIDTH) tr;
    event drv_done;

    function new(
        virtual alu_if #(WIDTH) vif,
        mailbox #(alu_transaction #(WIDTH)) mon_mb,
        event drv_done
    );
        this.vif = vif;
        this.mon_mb = mon_mb;
        this.drv_done = drv_done;
    endfunction

    task run();
        $display("T=%0t: Monitor starting", $time);

        forever begin
            @(drv_done);

            #1;

            tr = new();

            tr.in1 = vif.in1;
            tr.in2 = vif.in2;
            tr.aluOp = vif.aluOp;
            tr.out = vif.out;

            mon_mb.put(tr);
        end

    endtask

endclass

class scoreboard #(parameter WIDTH=32);
    mailbox #(alu_transaction #(WIDTH)) mon_mb;
    alu_transaction #(WIDTH) tr;
    event done;

    logic [WIDTH-1:0] expected;

    int pass_count;
    int fail_count;
    int total_count;

    function new(mailbox #(alu_transaction #(WIDTH)) mon_mb);
        this.mon_mb = mon_mb;

        pass_count  = 0;
        fail_count  = 0;
        total_count = 0;
    endfunction

    task run(int num_transactions = 100);
        repeat (num_transactions) begin
            mon_mb.get(tr);
            $display("Scoreboard received %0d", total_count+1);
            case(tr.aluOp)
                ADD: expected = tr.in1 + tr.in2;
                SUB: expected = tr.in1 - tr.in2;
                AND: expected = tr.in1 & tr.in2;
                OR: expected = tr.in1 | tr.in2;
                XOR: expected = tr.in1 ^ tr.in2;
                SLL: expected = tr.in1 << tr.in2[4:0];
                SRL: expected = tr.in1 >> tr.in2[4:0];
                SRA: expected = $signed(tr.in1) >>> tr.in2[4:0];
                SLT: expected = ($signed(tr.in1) < $signed(tr.in2));
                SLTU: expected = (tr.in1 < tr.in2);
                default: $fatal("Unknown ALU operation");
            endcase

            total_count++;
            if(expected === tr.out) begin
                pass_count++;

                $display(
                    "[PASS] %s in1=%h in2=%h expected=%h actual=%h",
                    tr.aluOp.name(),
                    tr.in1,
                    tr.in2,
                    expected,
                    tr.out
                );
            end
            else begin
                fail_count++;

                $display(
                    "[FAIL] %s in1=%h in2=%h expected=%h actual=%h",
                    tr.aluOp.name(),
                    tr.in1,
                    tr.in2,
                    expected,
                    tr.out
                );
            end
        end

        $display("");
        $display("Total Tests : %0d", total_count);
        $display("Passed      : %0d", pass_count);
        $display("Failed      : %0d", fail_count);
        -> done;
    endtask
endclass

class env #(parameter WIDTH=32);
    generator #(WIDTH) gen;
    driver #(WIDTH) drv;
    monitor #(WIDTH) mon;
    scoreboard #(WIDTH) sb;

    mailbox #(alu_transaction #(WIDTH)) drv_mb;
    mailbox #(alu_transaction #(WIDTH)) mon_mb;

    event drv_done;

    virtual alu_if #(WIDTH) vif;

    function new(virtual alu_if #(WIDTH) vif);
        this.vif = vif;
    endfunction

    task build();
        drv_mb = new();
        mon_mb = new();
        
        gen = new(drv_mb, drv_done);
        drv = new(vif, drv_mb, drv_done);
        mon = new(vif, mon_mb, drv_done);
        sb = new(mon_mb);
    endtask

    task run(int num_transactions = 100);
        fork
           gen.run(num_transactions);
           drv.run();
           mon.run();
           sb.run(num_transactions);
        join_none
    endtask
endclass

class test #(parameter WIDTH=32);
    env #(WIDTH) e;
    virtual alu_if #(WIDTH) vif;

    function new(virtual alu_if #(WIDTH) vif);
        this.vif = vif;
    endfunction

    task run(int num_transactions = 100);
        e = new(vif);
        e.build();
        e.run(num_transactions);
    endtask
endclass

module alu_tb;
    parameter WIDTH = 32;
    localparam int NUM_TESTS = 100;

    alu_if #(WIDTH) intf();
    alu #(.WIDTH(WIDTH)) dut (
        .in1(intf.in1),
        .in2(intf.in2),
        .aluOp(intf.aluOp),
        .out(intf.out)
    );

    test #(WIDTH) t;

    initial begin
        t = new(intf);
        t.run(NUM_TESTS);
        @(t.e.sb.done);
        $finish;
    end
endmodule
