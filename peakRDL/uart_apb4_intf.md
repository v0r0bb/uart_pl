<!---
Markdown description for SystemRDL register map.

Don't override. Generated from: uart_apb4_intf
  - uart_apb4_intf.rdl
-->

## uart_apb4_intf address map

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x14

|Offset|Identifier|            Name           |
|------|----------|---------------------------|
| 0x00 |  UART_SR |    UART Status Register   |
| 0x04 |  UART_CR |   UART Control Register   |
| 0x08 |  UART_RX | UART Recieve Data Register|
| 0x0C |  UART_TX |UART Transmit Data Register|
| 0x10 | UART_BRR |  UART Baud Rate Register  |

### UART_SR register

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x4

|Bits|Identifier|Access|Reset|             Name            |
|----|----------|------|-----|-----------------------------|
|  0 |   RXFNE  |   r  | 0x0 | Receive data FIFO not empty |
|  1 |   TXFNF  |   r  | 0x1 | Transmit data FIFO not full |
| 6:2| RXFLEVEL |   r  | 0x0 | Receive data FIFO fill level|
|11:7| TXFSPACE |   r  | 0x10|Transmit data FIFO free space|

#### RXFNE field

<p>Set by hw when rx_fifo is not empty.
UART_RX can be read</p>

#### TXFNF field

<p>Set by hw when tx_fifo is not full. 
UART_TX can be written</p>

#### RXFLEVEL field

<p>0: rx_fifo is empty;
1-15: bytes that are available for reading;
16: rx_fifo is full</p>

#### TXFSPACE field

<p>0: tx_fifo is full;
1-15: number of available slots for writing;
16: tx_fifo is empty</p>

### UART_CR register

- Absolute Address: 0x4
- Base Offset: 0x4
- Size: 0x4

|Bits|Identifier|Access|Reset|       Name      |
|----|----------|------|-----|-----------------|
|  0 |    SB    |  rw  | 0x0 |    STOP bits    |
|  1 |   OVER8  |  rw  | 0x0 |Oversampling mode|

#### SB field

<p>0: 1 stop bit;
1: 2 stop bits</p>

#### OVER8 field

<p>0: oversampling by 16;
1: oversampling by 8</p>

### UART_RX register

- Absolute Address: 0x8
- Base Offset: 0x8
- Size: 0x4

|Bits|Identifier|Access|Reset|   Name   |
|----|----------|------|-----|----------|
| 7:0|  RX_DATA |   r  | 0x0 |Data value|

#### RX_DATA field

<p>Contains the received data
character when the register is read</p>

### UART_TX register

- Absolute Address: 0xC
- Base Offset: 0xC
- Size: 0x4

|Bits|Identifier|Access|Reset|   Name   |
|----|----------|------|-----|----------|
| 7:0|  TX_DATA |   w  | 0x0 |Data value|

#### TX_DATA field

<p>Contains the data character to be
transmitted when the register is written to</p>

### UART_BRR register

- Absolute Address: 0x10
- Base Offset: 0x10
- Size: 0x4

|Bits|Identifier|Access|Reset|          Name          |
|----|----------|------|-----|------------------------|
| 3:0| DIV_FRAC |  rw  | 0x0 |Fraction of UART Divider|
|15:4| DIV_MANT |  rw  | 0x0 |Mantissa of UART Divider|

#### DIV_FRAC field

<p>These 4 bits define the fraction of the UART Divider</p>

#### DIV_MANT field

<p>These 12 bits define the mantissa of the UART Divider</p>
