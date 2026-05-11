class test_cfg_base;
    real clk_freq            = 10_000_000;
    rand int baudrate        = 9600;
    rand int uart_pkt_amount = 100;
    int test_timeout_cycles  = 100_000_000;

    rand bit over8;
    rand bit stop_bits;

    rand int trans_delay_min;
    rand int trans_delay_max;

    bit  [11:0] div_mant;
    bit  [3:0]  div_frac;

    constraint baudrate_c {
        baudrate inside {9600, 19200, 38400, 57600, 115200, 230400};
    }

    constraint delayc_c {
        trans_delay_min inside {[5000:10000]};
        trans_delay_max inside {[10000:20000]};
        trans_delay_min <= trans_delay_max;
    }

    constraint uart_pkt_amount_c {
        uart_pkt_amount inside {[10:30]};
    }

    function void post_randomize();
        real uart_div = real'(clk_freq / (8 * (2 - over8) * baudrate));
        div_mant = int'($floor(uart_div));
        div_frac = int'(over8 ? ((uart_div - div_mant) * 8) :
                       ((uart_div - div_mant) * 16));
        $display("[CFG] Baudrate: %0d, over: %0s, sb: %0d, div_mant: %0d, div_frac: %0d, pkt: %0d",
                baudrate, over8 ? "8" : "16", stop_bits, div_mant, div_frac, uart_pkt_amount);

    endfunction;
endclass

class test_cfg_fifo extends test_cfg_base;
    constraint delayc_c {
        trans_delay_min == 0;
        trans_delay_max == 0;
    }

    constraint uart_pkt_amount_c {
        uart_pkt_amount == 32;
    }
endclass

class test_cfg_ore extends test_cfg_base;
    constraint delayc_c {
        trans_delay_min == 0;
        trans_delay_max == 0;
    }

    constraint uart_pkt_amount_c {
        uart_pkt_amount == 20;
    }
endclass