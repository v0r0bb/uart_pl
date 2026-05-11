interface uart_intf;
    import uart_pl_pkg::*;
    logic [DATA_BITS - 1:0] data;
    logic rdy;
    logic vld;

    logic                        rxfne;   
    logic                        txfnf;   
    logic [FIFO_CNT_WIDTH - 1:0] rxflevel; 
    logic [FIFO_CNT_WIDTH - 1:0] txfspace;
    logic                        ore;
endinterface