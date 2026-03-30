class environment;
    apb4_agent apb4_agt;
    uart_agent uart_agt;

    function new();
        apb4_agt = new();
        uart_agt = new();
    endfunction

    virtual task run();
        fork
            apb4_agt.run();
            uart_agt.run();
        join
    endtask
endclass