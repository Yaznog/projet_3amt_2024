// Simplify by removing 
//    - external clock support.
//    - loopback mode
//    - flow control ?
//    - parity Select ?

// Dynamixel does the Asynchronous Serial Communication with 8 bit, 1 Stop bit, and None Parity.
`include "uga_uart_pkg.sv"

module uga_uart #(
   parameter enum {none,even,odd} parity = none 
  ) (
    input  logic        rst_n,
    input  logic        clk,
    input  logic        uart_rxd,
    output logic        uart_txd,
    //received data output
    input  logic        rx_data_valid,
    output logic  [7:0] rx_data,
    output logic        rx_data_ready,
    // Data to transmit input
    input  logic       tx_data_ready,
    input  logic [7:0] tx_data,
    output logic       tx_data_valid
  );
  

  import uga_uart_pkg::*;

  logic [$clog2((c_prescaler))-1:0] scaler;
  logic                              tick;   // rx clock (internal)

  //==========================================================
  // SCALER and TICK
  //==========================================================
  always_ff @(posedge clk) 
    if      (~rst_n)      scaler <= c_prescaler;
    else if (scaler == 0) scaler <= c_prescaler;
    else                  scaler <= scaler-1;

  always_ff @(posedge clk)
    if (~rst_n) tick <= 1'b0;
    else        tick <= (scaler == 0); // scaler


  //==========================================================
  // TX Path : uart is transmitting Data
  //==========================================================
  uga_rfuart_tx  #(
    .parity             (parity)
   ) u_tx (
    .rst_n              (rst_n),                // Main Synchronous Reset (Active Low)
    .clk                (clk),                  // System Clock
    .tick               (tick),                 // Tick Event (prescale based on Baud rate requirement)

    .tx_data            (tx_data),
    .tx_data_ready      (tx_data_ready),        // Tick Event (prescale based on Baud rate requirement)
    .tx_data_valid      (tx_data_valid),

    .uart_txd           (uart_txd)
  );

  //==========================================================
  // RX Path : uart is receiving Data
  //==========================================================
  uga_rfuart_rx #(
    .parity             (parity)
   ) u_rx (
      .rst_n            (rst_n),    // Main Synchronous Reset (Active Low)
      .clk              (clk),      // System Clock
      .tick             (tick),      // Tick Event (prescale based on Baud rate requirement)

      .rx_data          (rx_data),
      .rx_data_ready    (rx_data_ready),
      .rx_data_valid    (rx_data_valid),

      .uart_rxd         (uart_rxd)
  );


endmodule
