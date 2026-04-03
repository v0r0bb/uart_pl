interface fifo_tx_hwif_intf;
    logic       wr_req_tx;
    logic       rd_req_sr;
    logic [7:0] wr_data;
    logic       txfnf;
    logic [4:0] txfspace;

    modport master (
        output wr_req_tx,
        output rd_req_sr,
        output wr_data, 
        input  txfnf,
        input  txfspace
    );

    modport slave (
        input  wr_req_tx,
        input  rd_req_sr,
        input  wr_data, 
        output txfnf,
        output txfspace 
    );
endinterface

interface fifo_rx_hwif_intf;
    logic       rd_req_sr;
    logic       rd_req_rx;
    logic [7:0] rd_data;
    logic       rxfne;
    logic [4:0] rxflevel;

    modport master (
        output rd_req_sr,
        output rd_req_rx,
        input  rd_data,
        input  rxfne,
        input  rxflevel
    );

    modport slave (
        input  rd_req_sr,
        input  rd_req_rx,
        output rd_data,
        output rxfne,
        output rxflevel
    );
endinterface

interface rx_hwif_intf;
    logic rd_req_sr;
    logic ore;

    modport master (
        output rd_req_sr,
        input  ore
    );
    
    modport slave (
        input  rd_req_sr,
        output ore
    );
endinterface