import uart_pl_pkg::*;
class apb4_gen_base;
    test_cfg_base cfg;
    mailbox#(apb4_trans) apb4_gen2drv;

    task setup();
        apb4_trans tr = new();
        tr.paddr = UART_CR_ADDR;
        tr.pdata = cfg.over8 << 1 | cfg.stop_bits;
        tr.pwrite = 1'b1;
        apb4_gen2drv.put(tr); 
        tr = new();
        tr.paddr = UART_BRR_ADDR;
        tr.pdata = cfg.div_mant << 4 | cfg.div_frac;
        tr.pwrite = 1'b1;
        apb4_gen2drv.put(tr); 
    endtask

    virtual task run();
        apb4_trans tr;
        setup();
        repeat (cfg.uart_pkt_amount) begin 
            tr = new();
            if (!tr.randomize()) begin 
                $error("[GEN] Transaction randomization failed");
                $finish();
            end
            // tr.display("[APB4 GEN]");
            apb4_gen2drv.put(tr); 
        end
    endtask
endclass 

class apb4_gen_fifo extends apb4_gen_base;
    virtual task run();
        apb4_trans tr;
        setup();
        repeat (cfg.uart_pkt_amount / 2) begin 
            tr = new();
            tr.paddr = UART_TX_ADDR;
            tr.pwrite = 1'b1;
            tr.pdata = $urandom_range(0, 255);
            apb4_gen2drv.put(tr); 
        end

        #17ms; 

        repeat (cfg.uart_pkt_amount / 2) begin
            tr = new();
            tr.paddr = UART_RX_ADDR;
            tr.pwrite = 1'b0;
            tr.pdata = 32'h0;
            apb4_gen2drv.put(tr);
        end
    endtask
endclass

class apb4_gen_ore extends apb4_gen_base;
    virtual task run();
        setup();
    endtask
endclass

class apb4_driver;
    test_cfg_base cfg;   
    mailbox#(apb4_trans) apb4_gen2drv;
    virtual apb4_intf#(.ADDR_WIDTH(ADDR_WIDTH)) apb4_vif;
    virtual sync_intf sync_vif;

    virtual task reset();
        apb4_vif.PSEL    <= 1'b0;
        apb4_vif.PENABLE <= 1'b0;
        apb4_vif.PWRITE  <= 1'b0;
        apb4_vif.PPROT   <= '0;
        apb4_vif.PADDR   <= '0;
        apb4_vif.PWDATA  <= '0;
        apb4_vif.PSTRB   <= '0;
    endtask

    task apb_transfer(logic [ADDR_WIDTH - 1:0] paddr, logic [DATA_WIDTH - 1:0] pdata, logic pwrite);
        @(posedge sync_vif.clk_i);
        apb4_vif.PSEL    <= 1'b1;
        apb4_vif.PENABLE <= 1'b0;
        apb4_vif.PWRITE  <= pwrite;
        apb4_vif.PADDR   <= paddr;
        apb4_vif.PWDATA  <= pdata;
        apb4_vif.PSTRB   <= 4'hF;
        @(posedge sync_vif.clk_i);
        apb4_vif.PENABLE <= 1'b1;
        do begin
            @(posedge sync_vif.clk_i);
        end
        while (~apb4_vif.PREADY);
        apb4_vif.PSEL    <= 1'b0;
        apb4_vif.PENABLE <= 1'b0;
    endtask

    virtual task drive(apb4_trans tr);
        int delay; 
        void'(std::randomize(delay) with {
            delay inside {[cfg.trans_delay_min:cfg.trans_delay_max]};
        });
        repeat (delay) @(posedge sync_vif.clk_i);
        apb_transfer(tr.paddr, tr.pdata, tr.pwrite);
        // tr.display("[APB4 DRV]");
    endtask

    virtual task run();
        apb4_trans tr;
        forever begin
            reset(); 
            wait(sync_vif.rst_n);
            fork
                forever begin
                    apb4_gen2drv.get(tr);
                    drive(tr); 
                end
                wait(~sync_vif.rst_n); 
            join_any 
            disable fork;  
            while(apb4_gen2drv.try_get(tr)); 
        end
    endtask
endclass

class apb4_monitor;
    mailbox#(apb4_trans) apb4_mon2scb;
    virtual apb4_intf#(.ADDR_WIDTH(ADDR_WIDTH)) apb4_vif;
    virtual sync_intf sync_vif;

    virtual task monitor();
        apb4_trans tr; 
        @(posedge sync_vif.clk_i);
        if (apb4_vif.PSEL & apb4_vif.PENABLE & apb4_vif.PREADY) begin 
            tr = new();
            tr.paddr = apb4_vif.PADDR;
            tr.pdata = apb4_vif.PWRITE ? apb4_vif.PWDATA : apb4_vif.PRDATA;
            tr.pwrite = apb4_vif.PWRITE;
            apb4_mon2scb.put(tr);
            tr.display("[APB4 MNT]");
        end
    endtask

    virtual task run();
        forever begin 
            wait(sync_vif.rst_n);
            fork
                forever monitor();
                wait(~sync_vif.rst_n); 
            join_any 
            disable fork;  
        end
    endtask
endclass

class apb4_agent;
    apb4_gen_base gen;
    apb4_driver   drv;
    apb4_monitor  mnt;

    function new();
        gen = new();
        drv = new();
        mnt = new();
    endfunction

    virtual task run();
        fork
            gen.run();
            drv.run();
            mnt.run();
        join
    endtask
endclass