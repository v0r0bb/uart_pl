import uart_pl_pkg::*;
class test_base; 

    virtual apb4_intf#(.ADDR_WIDTH(ADDR_WIDTH)) apb4_vif;
    virtual sync_intf sync_vif;
    virtual uart_intf uart_vif;
    test_cfg_base cfg;
    scoreboard scb;

    environment env;

    mailbox#(apb4_trans) apb4_gen2drv;
    mailbox#(apb4_trans) apb4_mon2scb;
    mailbox#(logic [DATA_BITS - 1:0]) uart_mon2scb;


    function new(
        virtual apb4_intf#(.ADDR_WIDTH(ADDR_WIDTH)) apb4_vif,
        virtual sync_intf sync_vif,
        virtual uart_intf uart_vif
    );
        this.apb4_vif = apb4_vif;
        this.sync_vif = sync_vif;
        this.uart_vif = uart_vif;
    endfunction

    virtual function connect();
        env.apb4_agt.gen.cfg = cfg;
        env.apb4_agt.drv.cfg = cfg;
        scb.cfg = cfg;

        env.apb4_agt.gen.apb4_gen2drv = apb4_gen2drv;
        env.apb4_agt.drv.apb4_gen2drv = apb4_gen2drv;
        env.apb4_agt.mnt.apb4_mon2scb = apb4_mon2scb;
        env.uart_agt.mnt.uart_mon2scb = uart_mon2scb;
        scb.uart_mon2scb = uart_mon2scb;
        scb.apb4_mon2scb = apb4_mon2scb;

        env.apb4_agt.drv.apb4_vif = apb4_vif;
        env.apb4_agt.mnt.apb4_vif = apb4_vif;
        env.apb4_agt.drv.sync_vif = sync_vif;
        env.apb4_agt.mnt.sync_vif = sync_vif;
        env.uart_agt.mnt.uart_vif = uart_vif;
        env.uart_agt.mnt.sync_vif = sync_vif;
        scb.sync_vif = sync_vif;
        scb.uart_vif = uart_vif;
    endfunction;

    virtual function init();
        if (this.cfg == null) 
            this.cfg = new();
        env = new();
        apb4_gen2drv = new();
        apb4_mon2scb = new();
        uart_mon2scb = new();
        scb = new();

        if (!cfg.randomize()) begin 
            $error("[TEST] Configuration randomization failed");
            $finish();
        end
        connect();
    endfunction

    virtual task run();
        init();
        fork 
            env.run();
            scb.run();
            timeout();
        join_none
        wait(scb.done);
        disable fork;
    endtask

    task timeout();
        repeat (cfg.test_timeout_cycles) @(posedge sync_vif.clk_i);
        $error("Test timeout");
        $finish();
    endtask

endclass

class test_fifo extends test_base;
    test_cfg_fifo fifo_cfg;
    apb4_gen_fifo fifo_gen;

    function new(
        virtual apb4_intf#(.ADDR_WIDTH(ADDR_WIDTH)) apb4_vif,
        virtual sync_intf sync_vif,
        virtual uart_intf uart_vif
    );
        super.new(apb4_vif, sync_vif, uart_vif);
    endfunction
    
    virtual function init();
        fifo_cfg = new();
        cfg = fifo_cfg;
        super.init();

        fifo_gen = new();
        env.apb4_agt.gen = fifo_gen;
        connect();
    endfunction
endclass

class test_ore extends test_base;
    test_cfg_ore ore_cfg;
    apb4_gen_ore ore_gen;

    function new(
        virtual apb4_intf#(.ADDR_WIDTH(ADDR_WIDTH)) apb4_vif,
        virtual sync_intf sync_vif,
        virtual uart_intf uart_vif
    );
        super.new(apb4_vif, sync_vif, uart_vif);
    endfunction
    
    virtual function init();
        ore_cfg = new();
        cfg = ore_cfg;
        super.init();

        ore_gen = new();
        env.apb4_agt.gen = ore_gen;
        connect();
    endfunction
endclass