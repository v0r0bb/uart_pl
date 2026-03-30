import uart_pl_pkg::*;
class uart_monitor;
    mailbox#(logic [DATA_BITS - 1:0]) uart_mon2scb;
    virtual sync_intf sync_vif;
    virtual uart_intf uart_vif;

    virtual task monitor();
        @(posedge sync_vif.clk_i);
        if (uart_vif.rdy & uart_vif.vld) begin
            uart_mon2scb.put(uart_vif.data);
            $display("[UART MNT] received: data 0x%0h", uart_vif.data);
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

class uart_agent;
    uart_monitor mnt;

    function new();
        mnt = new();
    endfunction

    virtual task run();
        fork
            mnt.run();
        join
    endtask
endclass