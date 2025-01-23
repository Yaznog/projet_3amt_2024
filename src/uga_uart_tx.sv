// Reset is synchronous as this code is targetting FPGA
// May need to replace in asynchronous one if ASIC implementation is required.

module uga_rfuart_tx #(
  parameter enum {none,even,odd} parity = none 
  )(
  input logic rst_n,    // Main Synchronous Reset (Active Low)
  input logic clk,      // System Clock
  input logic tick,      // UART Event (computed based on Baud rate requirement)
  // Data to transmit input
  input  logic [7:0] tx_data,
  input  logic       tx_data_ready,
  output logic       uart_txd,
  output logic       tx_data_valid    // High when uart is transmitting data
);

  localparam p_start_bit = 1'b0;
  localparam p_stop_bit  = 1'b1;

  typedef enum logic [2:0] {
        tx_idle,
        tx_startbit, 
        tx_payload, 
        tx_parity, 
        tx_stopbit } txfsmtype;

  txfsmtype               tx_state, next_tx_state;
  logic                   tx_tick;    // tx clock (internal)
  logic [2:0]             tx_scaler;  // tx clock divider (scaler)
  logic                   thempty;    // transmitter hold register empty
  logic [7:0]             tx_hold;
  logic [10:0]            tx_shift;
  logic                   parity_bit;      // tx data parity (internal)

  logic [2:0]             tx_cnt;  // count number of bit send of TX

  //--------------------------------------------------------------------------------------------------
  // TX tick and divided clock
  //--------------------------------------------------------------------------------------------------
  always_ff @(posedge clk) 
    if (~rst_n)    tx_scaler <= 3'b000;
    else if (tick) tx_scaler <= tx_scaler + 1;

  always_ff @(posedge clk)
    if  (~rst_n) tx_tick <= 1'b0;
    else         tx_tick <= tick && (tx_scaler == 7);


  //--------------------------------------------------------------------------------------------------
  // TX FSM
  //--------------------------------------------------------------------------------------------------
  always_ff @(posedge clk)
    if (~rst_n) tx_state <= tx_idle;
    else        tx_state <= next_tx_state;

  always_comb begin
    next_tx_state = tx_state;
    if (tx_tick) // FSM Trigger on TX tick
      case (tx_state)
        tx_idle     : if (~thempty)     next_tx_state = tx_startbit;
        tx_startbit :                   next_tx_state = tx_payload;
        tx_payload  : if (tx_cnt == 7)  next_tx_state = (parity == none) ? tx_stopbit : tx_parity;
        tx_parity   :                   next_tx_state = tx_stopbit; // transmitt parity bit
        tx_stopbit  :                   next_tx_state = tx_idle;    // transmitt stop bit
        default     :                   next_tx_state = tx_idle;
      endcase
  end


  //--------------------------------------------------------------------------------------------------
  // Transmitter Hold Register Empty
  // writing of tx data register must be done after tx fsm to get correct operation of thempty flag
  //--------------------------------------------------------------------------------------------------
  always_ff @(posedge clk) 
    if       (~rst_n)                      thempty <= 1'b1;
    else if  (next_tx_state == tx_payload) thempty <= 1'b1;
    else if  (tx_data_ready)               thempty <= 1'b0;

  //---------------------------------------------------------
  // Data Hold and Shift. We compute parity bit when user load data
  //---------------------------------------------------------
  always_ff @(posedge clk) 
    if      (~rst_n)        {tx_hold,parity_bit} <= {8'h00   , 1'b0                        };
    else if (tx_data_ready) {tx_hold,parity_bit} <= {tx_data , (parity == odd) ^ (^tx_data)};


  always_ff @(posedge clk)
    if (~rst_n) {tx_shift,uart_txd} <= {8'hFF,1'b1};
    else if (tx_tick)
      case (next_tx_state)
        tx_idle      :   {tx_shift,uart_txd} <= {tx_hold,1'b1};
        tx_startbit  :   {tx_shift,uart_txd} <= {tx_hold,p_start_bit};
        tx_payload   :   {tx_shift,uart_txd} <= {1'b1 , tx_shift[7:0]};
        tx_parity    :   {tx_shift,uart_txd} <= {tx_shift,parity_bit}; 
        tx_stopbit   :   {tx_shift,uart_txd} <= {tx_shift,p_stop_bit}; 
    endcase
  
  // counter for end of txx
  always_ff @(posedge clk)
    if      (~rst_n)                            tx_cnt <= 0;
    else if (tx_tick && tx_state == tx_payload) tx_cnt <= tx_cnt + 1;
  



  assign tx_data_valid = (tx_state != tx_idle);

endmodule
