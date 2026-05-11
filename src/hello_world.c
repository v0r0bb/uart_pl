#include "sleep.h"
#include "uart_pl.h"
#include "xil_printf.h"
#include "string.h"

#define OVER8       0
#define SB          0

#define DIV_MANT    54
#define DIV_FRAC    4

#define RX_BUF_SIZE 64
#define TX_BUF_SIZE 128

void uart_pl_init(void)
{
    UART_PL->UART_CR = (OVER8 << UART_CR_OVER8_Pos) | (SB << UART_CR_SB_Pos);
    UART_PL->UART_BRR = (DIV_MANT << UART_BRR_DIV_MANT_Pos) | DIV_FRAC;
}

int uart_pl_send(const char *buf)
{
    int cnt = 0;
    int txf_space;

    while (*buf) {
        txf_space = (UART_PL->UART_SR & UART_SR_TXFSPACE) >> UART_SR_TXFSPACE_Pos;
        while (txf_space && *buf) {
            UART_PL->UART_TX = (uint8_t)*buf++;
            cnt++;
            txf_space--;
        }

        if (*buf)
            while (!(UART_PL->UART_SR & UART_SR_TXFNF));
    }

    return cnt;
} 

int uart_pl_recieve_block(char *buf)
{
    int cnt = 0, nl = 0;
    int rxf_level;
    char ch;
    
    while (cnt < (RX_BUF_SIZE - 1) && !nl) {
        rxf_level = (UART_PL->UART_SR & UART_SR_RXFLEVEL) >> UART_SR_RXFLEVEL_Pos;
        while (cnt < (RX_BUF_SIZE - 1) && rxf_level > 0) {
            ch = (char)(UART_PL->UART_RX);
            rxf_level--;
            if (ch == '\n' || ch == '\r') {
                nl = 1;
                while (UART_PL->UART_SR & UART_SR_RXFNE)
                    UART_PL->UART_RX;
                break;
            }
            buf[cnt++] = ch;
        }
    }
    buf[cnt] = '\0'; 
    return cnt;
}


int main(void)
{
    const char *msg = "\r\n[xc7z010] Hello World from Zynq 7000!\r\n";
    const char *tag = "\r\n[xc7z010] Recieved msg: ";
    char rx_buffer[RX_BUF_SIZE];
    char tx_buffer[TX_BUF_SIZE];
    int msg_len;

    uart_pl_init();
    uart_pl_send(msg);
    while (1) {
        msg_len = uart_pl_recieve_block(rx_buffer);
        strcpy(tx_buffer, tag);
        strcat(tx_buffer, rx_buffer);
        strcat(tx_buffer, "\r\n");
        uart_pl_send(tx_buffer);
    }

    return 0;
}
