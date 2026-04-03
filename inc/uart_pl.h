#ifndef UART_PL_H
#define UART_PL_H

#include "uart_apb4_intf.h"

#define UART_PL_APB_BASE        (0x43C00000UL)
#define UART_PL                 ((volatile uart_apb4_intf_t *)UART_PL_APB_BASE)

/* UART_SR register */
#define UART_SR_RXFNE_Pos       (UART_APB4_INTF__UART_SR__RXFNE_bp)
#define UART_SR_RXFNE_Msk       (UART_APB4_INTF__UART_SR__RXFNE_bm)
#define UART_SR_RXFNE           UART_SR_RXFNE_Msk
#define UART_SR_RXFNE_Res       (UART_APB4_INTF__UART_SR__RXFNE_reset)

#define UART_SR_TXFNF_Pos       (UART_APB4_INTF__UART_SR__TXFNF_bp)
#define UART_SR_TXFNF_Msk       (UART_APB4_INTF__UART_SR__TXFNF_bm)
#define UART_SR_TXFNF           UART_SR_TXFNF_Msk
#define UART_SR_TXFNF_Res       (UART_APB4_INTF__UART_SR__TXFNF_reset)

#define UART_SR_RXFLEVEL_Pos    (UART_APB4_INTF__UART_SR__RXFLEVEL_bp)
#define UART_SR_RXFLEVEL_Msk    (UART_APB4_INTF__UART_SR__RXFLEVEL_bm)
#define UART_SR_RXFLEVEL        UART_SR_RXFLEVEL_Msk
#define UART_SR_RXFLEVEL_Res    (UART_APB4_INTF__UART_SR__RXFLEVEL_reset)

#define UART_SR_TXFSPACE_Pos    (UART_APB4_INTF__UART_SR__TXFSPACE_bp)
#define UART_SR_TXFSPACE_Msk    (UART_APB4_INTF__UART_SR__TXFSPACE_bm)
#define UART_SR_TXFSPACE        UART_SR_TXFSPACE_Msk
#define UART_SR_TXFSPACE_Res    (UART_APB4_INTF__UART_SR__TXFSPACE_reset)

#define UART_SR_ORE_Pos         (UART_APB4_INTF__UART_SR__ORE_bp)
#define UART_SR_ORE_Msk         (UART_APB4_INTF__UART_SR__ORE_bm)
#define UART_SR_ORE             UART_SR_ORE_Msk
#define UART_SR_ORE_Res         (UART_APB4_INTF__UART_SR__ORE_reset)

#define UART_SR_Msk             (UART_SR_RXFNE_Msk   | UART_SR_TXFNF_Msk    | \
                                UART_SR_RXFLEVEL_Msk | UART_SR_TXFSPACE_Msk | \
                                UART_SR_ORE_Msk)

#define UART_SR_Res             (UART_SR_RXFNE_Res   << UART_SR_RXFNE_Pos    | \
                                UART_SR_TXFNF_Res    << UART_SR_TXFNF_Pos    | \
                                UART_SR_RXFLEVEL_Res << UART_SR_RXFLEVEL_Pos | \
                                UART_SR_TXFSPACE_Res << UART_SR_TXFSPACE_Pos | \
                                UART_SR_ORE_Res      << UART_SR_ORE_Pos)

#define UART_SR_Addr            (UART_PL_APB_BASE + 0x00)

/* UART_CR register */
#define UART_CR_SB_Pos          (UART_APB4_INTF__UART_CR__SB_bp)
#define UART_CR_SB_Msk          (UART_APB4_INTF__UART_CR__SB_bm)
#define UART_CR_SB              UART_CR_SB_Msk
#define UART_CR_SB_Res          (UART_APB4_INTF__UART_CR__SB_reset)

#define UART_CR_OVER8_Pos       (UART_APB4_INTF__UART_CR__OVER8_bp)
#define UART_CR_OVER8_Msk       (UART_APB4_INTF__UART_CR__OVER8_bm)
#define UART_CR_OVER8           UART_CR_OVER8_Msk
#define UART_CR_OVER8_Res       (UART_APB4_INTF__UART_CR__OVER8_reset)

#define UART_CR_Msk             (UART_CR_SB_Msk | UART_CR_OVER8_Msk)

#define UART_CR_Res             (UART_CR_SB_Res   << UART_CR_SB_Pos | \
                                UART_CR_OVER8_Res << UART_CR_OVER8_Pos)

#define UART_CR_Addr            (UART_PL_APB_BASE + 0x04)

/* UART_RX register */
#define UART_RX_DATA_Pos        (UART_APB4_INTF__UART_RX__RX_DATA_bp)
#define UART_RX_DATA_Msk        (UART_APB4_INTF__UART_RX__RX_DATA_bm)
#define UART_RX_DATA            UART_RX_DATA_Msk
#define UART_RX_DATA_Res        (UART_APB4_INTF__UART_RX__RX_DATA_reset)

#define UART_RX_Msk             (UART_RX_DATA_Msk)

#define UART_RX_Res             (UART_RX_DATA_Res << UART_RX_DATA_Pos)

#define UART_RX_Addr            (UART_PL_APB_BASE + 0x08)

/* UART_TX register */
#define UART_TX_DATA_Pos        (UART_APB4_INTF__UART_TX__TX_DATA_bp)
#define UART_TX_DATA_Msk        (UART_APB4_INTF__UART_TX__TX_DATA_bm)
#define UART_TX_DATA            UART_TX_DATA_Msk
#define UART_TX_DATA_Res        (UART_APB4_INTF__UART_TX__TX_DATA_reset)

#define UART_TX_Msk             (UART_TX_DATA_Msk)

#define UART_TX_Res             (UART_TX_DATA_Res << UART_TX_DATA_Pos)

#define UART_TX_Addr            (UART_PL_APB_BASE + 0x0C)

/* UART_BRR register */
#define UART_BRR_DIV_FRAC_Pos   (UART_APB4_INTF__UART_BRR__DIV_FRAC_bp)
#define UART_BRR_DIV_FRAC_Msk   (UART_APB4_INTF__UART_BRR__DIV_FRAC_bm)
#define UART_BRR_DIV_FRAC       UART_BRR_DIV_FRAC_Msk
#define UART_BRR_DIV_FRAC_Res   (UART_APB4_INTF__UART_BRR__DIV_FRAC_reset)

#define UART_BRR_DIV_MANT_Pos   (UART_APB4_INTF__UART_BRR__DIV_MANT_bp)
#define UART_BRR_DIV_MANT_Msk   (UART_APB4_INTF__UART_BRR__DIV_MANT_bm)
#define UART_BRR_DIV_MANT       UART_BRR_DIV_MANT_Msk
#define UART_BRR_DIV_MANT_Res   (UART_APB4_INTF__UART_BRR__DIV_MANT_reset)

#define UART_BRR_Msk            (UART_BRR_DIV_FRAC_Msk | UART_BRR_DIV_MANT_Msk)

#define UART_BRR_Res            (UART_BRR_DIV_FRAC_Res << UART_BRR_DIV_FRAC_Pos | \
                                UART_BRR_DIV_MANT_Res  << UART_BRR_DIV_MANT_Pos)
                            
#define UART_BRR_Addr           (UART_PL_APB_BASE + 0x10)

#endif