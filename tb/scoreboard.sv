import uart_pl_pkg::*;
class scoreboard;

    mailbox#(apb4_trans) apb4_mon2scb;
    mailbox#(logic [DATA_BITS - 1:0]) uart_mon2scb;

    virtual uart_intf uart_vif;
    virtual sync_intf sync_vif;

    test_cfg_base cfg;

    logic [DATA_BITS - 1:0] tx_ref_queue [$]; // APB4
    logic [DATA_BITS - 1:0] rx_ref_queue [$]; // UART

    int processed_pkt = 0;
    int err_cnt       = 0;

    bit done;

    function void reset();
        done          = 1'b0;
        processed_pkt = 0;
        err_cnt       = 0;
        tx_ref_queue.delete();
        rx_ref_queue.delete();
    endfunction  

    virtual function void check_uart_tx(logic [7:0] real_byte);
        logic [DATA_BITS - 1:0] ref_byte;
        ref_byte = tx_ref_queue.pop_front();

        if (ref_byte !== real_byte) begin
            $error("[SCB] TX mismatch! Real: 0x%0h, Ref: 0x%0h (%0d/%0d)",
                real_byte, ref_byte, ++processed_pkt, cfg.uart_pkt_amount);
            err_cnt++;
        end
        else  
            $display("[SCB] TX send: 0x%0h (%0d/%0d)", real_byte, ++processed_pkt,
                cfg.uart_pkt_amount);
    endfunction

    virtual function void check_apb_rx(logic [7:0] real_byte);
        if (rx_ref_queue.size() > 0) begin 
            logic [7:0] ref_byte = rx_ref_queue.pop_front();
            if (ref_byte !== real_byte) begin
                $error("[SCB] RX mismatch! Real: 0x%0h, Ref: 0x%0h (%0d/%0d)",
                    real_byte , ref_byte, ++processed_pkt, cfg.uart_pkt_amount);
                err_cnt++;
            end
            else  
                $display("[SCB] RX read: 0x%0h (%0d/%0d)", real_byte, ++processed_pkt,
                    cfg.uart_pkt_amount);
        end
        else 
            $display("[SCB] RX empty read (%0d/%0d)", ++processed_pkt,
                cfg.uart_pkt_amount);
    endfunction

    virtual function void check_status(logic [31:0] real_sr);
        logic                        real_rxfne    = real_sr[0];
        logic                        real_txfnf    = real_sr[1];
        logic [FIFO_CNT_WIDTH - 1:0] real_rxflevel = real_sr[6:2];
        logic [FIFO_CNT_WIDTH - 1:0] real_txfspace = real_sr[11:7];
        logic                        real_ore      = real_sr[12];

        logic                        ref_rxfne    = uart_vif.rxfne;
        logic                        ref_txfnf    = uart_vif.txfnf;
        logic [FIFO_CNT_WIDTH - 1:0] ref_rxflevel = uart_vif.rxflevel;
        logic [FIFO_CNT_WIDTH - 1:0] ref_txfspace = uart_vif.txfspace;

        $display("[SCB] SR read %0b: RXFNE %0d, TXFNF %0d, RXFLEVEL %0d, TXFSPACE %0d, ORE %0d (%0d/%0d)",
            real_sr, real_rxfne, real_txfnf, real_rxflevel, real_txfspace, real_ore, ++processed_pkt, cfg.uart_pkt_amount);
        if (real_rxfne !== ref_rxfne) begin  
            $error("[SCB] RXFNE   mismatch! Real: %b,  Ref: %b",
                real_rxfne, ref_rxfne);
            err_cnt++;
        end
        if (real_txfnf !== ref_txfnf) begin
            $error("[SCB] TXFNF   mismatch! Real: %b,  Ref: %b",
                real_txfnf, ref_txfnf);
            err_cnt++;
        end
        if (real_rxflevel !== ref_rxflevel) begin
            $error("[SCB] RXLEVEL mismatch! Real: %0d, Ref: %0d", 
                real_rxflevel, ref_rxflevel);
            err_cnt++;
        end
        if (real_txfspace !== ref_txfspace) begin
            $error("[SCB] TXSPACE mismatch! Real: %0d, Ref: %0d", 
                real_txfspace, ref_txfspace);
            err_cnt++;
        end
    endfunction

    virtual task run();
        wait(sync_vif.rst_n);
        reset();
        fork
            forever begin
                apb4_trans tr;
                apb4_mon2scb.get(tr);
                case (tr.paddr)
                    UART_TX_ADDR: tx_ref_queue.push_back(tr.pdata[DATA_BITS - 1:0]);
                    UART_RX_ADDR: check_apb_rx(tr.pdata[DATA_BITS - 1:0]);
                    UART_SR_ADDR: check_status(tr.pdata); 
                endcase
            end

            forever begin
                logic [DATA_BITS - 1:0] uart_byte;
                uart_mon2scb.get(uart_byte);
                check_uart_tx(uart_byte);
                rx_ref_queue.push_back(uart_byte);
            end

            forever begin
                logic [DATA_BITS - 1:0] uart_byte_dropped;
                @(posedge uart_vif.ore) begin
                    uart_byte_dropped = tx_ref_queue[tx_ref_queue.size() - 2];
                    tx_ref_queue.delete(tx_ref_queue.size() - 2); 
                    $display("[SCB] Dropped by ore: 0x%0h (tx_ref)", uart_byte_dropped);
                end
            end

            wait(processed_pkt >= cfg.uart_pkt_amount);
        join_any 
        disable fork; 
        done = 1'b1;  
        $display("[SCB] All packets processed: %0d/%0d", 
            processed_pkt, cfg.uart_pkt_amount);
        if (err_cnt == 0) 
            $display("PASSED");
        else begin
            $display("FAILED");
            $display("Total error: %0d", err_cnt);
        end
    endtask
endclass 