import uart_pl_pkg::*;
class apb4_trans;
    rand logic [ADDR_WIDTH - 1:0] paddr;
    rand logic [DATA_WIDTH - 1:0] pdata;
    rand logic pwrite;
    
    constraint addr_c { 
        paddr inside {UART_SR_ADDR, UART_RX_ADDR, UART_TX_ADDR};
    }

    constraint dist_c {
        paddr dist {
            UART_RX_ADDR := 30,
            UART_TX_ADDR := 60,
            UART_SR_ADDR := 10
        };
    }

    constraint access_type_c {
        paddr == UART_SR_ADDR -> pwrite == 1'b0; 
        paddr == UART_RX_ADDR -> pwrite == 1'b0; 
        paddr == UART_TX_ADDR -> pwrite == 1'b1;
    }

    constraint data_c {
        pwrite == 1'b0 -> pdata == 32'h0;
    }

    constraint tx_data_c {
        paddr == UART_TX_ADDR -> pdata[DATA_WIDTH - 1:8] == '0;
    }

    function void display(string tag = "");
        string name;
        case (paddr)
            UART_SR_ADDR:  name = "UART_SR";
            UART_CR_ADDR:  name = "UART_CR";
            UART_RX_ADDR:  name = "UART_RX";
            UART_TX_ADDR:  name = "UART_TX";
            UART_BRR_ADDR: name = "UART_BRR";
            default:       name = "UNKNOWN";
        endcase

        $display("%s APB transaction: %s %s (0x%0h) 0x%0h",
            tag, pwrite ? "wr" : "rd", name, paddr, pdata);
    endfunction
endclass;