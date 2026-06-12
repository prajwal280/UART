interface uart_if(input logic clk);

    logic rst;

    logic tx;
    logic rx;

    logic [7:0] tx_data;
    logic tx_start;

    logic [7:0] rx_data;
    

endinterface

class uart_transaction;

    rand byte data;

    function void display();
        $display("TX DATA = %0h", data);
    endfunction

endclass

class uart_driver;

    virtual uart_if vif;

    function new(virtual uart_if vif);
        this.vif = vif;
    endfunction

    task send(byte data);
        @(posedge vif.clk);

        vif.tx_data  <= data;
        vif.tx_start <= 1'b1;

        @(posedge vif.clk);
        vif.tx_start <= 1'b0;

        // wait some cycles for transmission
        repeat(200) @(posedge vif.clk);
    endtask

endclass

class uart_monitor;

    virtual uart_if vif;

    byte received_data;

    function new(virtual uart_if vif);
        this.vif = vif;
    endfunction

    task run();
        forever begin
            @(posedge vif.rx_done);

            received_data = vif.rx_data;

            $display("MONITOR: Received = %0h", received_data);
        end
    endtask

endclass

class uart_scoreboard;

    mailbox #(byte) exp_mbx;
    mailbox #(byte) act_mbx;

    function new(mailbox #(byte) e, mailbox #(byte) a);
        exp_mbx = e;
        act_mbx = a;
    endfunction

    task run();
        byte exp, act;

        forever begin
            exp_mbx.get(exp);
            act_mbx.get(act);

            if (exp == act)
                $display("PASS: exp=%0h act=%0h", exp, act);
            else
                $display("FAIL: exp=%0h act=%0h", exp, act);
        end
    endtask

endclass

module uart_tb;

    logic clk;

    uart_if vif(clk);

    uart_top dut (
        .clk(clk),
        .rst(vif.rst),
        .rx(vif.tx),          // loopback
        .tx(vif.tx),
        .rx_data(vif.rx_data),
        
    );

    // clock
    initial clk = 0;
    always #5 clk = ~clk;

    uart_driver      drv;
    uart_monitor     mon;

    mailbox #(byte) exp_mbx = new();
    mailbox #(byte) act_mbx = new();

    // expected generator
    task automatic generate_test();
        byte data;

        repeat (5) begin
            data = $random;

            exp_mbx.put(data);
            drv.send(data);
        end
    endtask

    // monitor collector thread
    task automatic collect();
        forever begin
            @(posedge vif.rx_done);
            act_mbx.put(vif.rx_data);
        end
    endtask

    initial begin
        vif.rst = 1;
        vif.tx_start = 0;
        vif.tx_data = 0;

        repeat(10) @(posedge clk);
        vif.rst = 0;

        drv = new(vif);
        mon = new(vif);

        fork
            mon.run();
            collect();
            generate_test();
        join_any

        #100;
        $finish;
    end

endmodule
