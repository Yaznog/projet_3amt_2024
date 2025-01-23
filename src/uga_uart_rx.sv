// Reset is synchronous as this code is targetting FPGA
// May need to replace in asynchronous one if ASIC implementation is required.

module uga_rfuart_rx #(
  parameter enum {none,even,odd} parity = none 
  ) (
  input logic rst_n,    // Main Synchronous Reset (Active Low)
  input logic clk,      // System Clock
  input logic tick,     // UART Event (computed based on Baud rate requirement)

  input  logic        uart_rxd,
  input  logic        rx_data_valid,    //RX line is valid then uart can receive data
  output logic  [7:0] rx_data,
  output logic        rx_data_ready
);

typedef enum logic [2:0] {rx_idle, rx_startbit, rx_payload, rx_parity, rx_stopbit} rx_fsmtype;
rx_fsmtype               rx_state, next_rx_state;

  logic rx_pulse_fall;
  logic rx_data_stream;
  logic [1:0]             rx_dly;      // rx delay
  logic [7:0]             rx_filter;   //  rx data filtering buffer

  logic [2:0]             rx_scaler;   // rx clock divider
  logic                   rx_tick;    // tx clock (internal)
  logic [7:0]             rx_shift;
  logic                   rsempty;      // receiver shift register empty (internal)

  logic                   ovf;          // receiver overflow
  logic                   parity_error;          // Parity Error
  logic                   break_error;          // Parity Error
  logic                   frame_error;          // Parity Error

  //--------------------------------------------------------------------------------------------------
  // RX tick and divided clock
  //--------------------------------------------------------------------------------------------------
  always_ff @(posedge clk)
    if      (~rst_n)                               rx_scaler <= 0;
    else if (rx_state == rx_idle && rx_pulse_fall) rx_scaler <= 4; // StartBit Detection --> Init value in the half scaler to strobe in the middle
    else if (tick)                                 rx_scaler <= rx_scaler + 1; 

  always_ff @(posedge clk) 
    if      (~rst_n)  rx_tick <= 0;
    else              rx_tick <= tick && (rx_scaler == 7);


  //==========================================================
  // RX FSM
  //==========================================================
  always_ff @(posedge clk)
    if (~rst_n) rx_state <= rx_idle;
    else        rx_state <= next_rx_state;

  always_comb begin
    next_rx_state = rx_state;
    case (rx_state)
        rx_idle : begin// wait for start bit
                if (rx_pulse_fall && rx_data_valid) next_rx_state = rx_startbit; 
        end
        rx_startbit : begin // check validity of start bit
                if (rx_tick) begin
                        if (~rx_data_stream) next_rx_state = rx_payload;
                        else          next_rx_state = rx_idle;
                end
        end
        rx_payload : begin // receive data frame
                if (rx_tick) begin
                  if (rx_shift[0] == 1'b0) begin
                    if (parity == none)  next_rx_state = rx_stopbit;
                    else        next_rx_state = rx_parity;
                  end
                end
        end
        rx_parity  : begin // receive parity bit
                if (rx_tick) next_rx_state = rx_stopbit;
        end
        rx_stopbit : begin // receive stop bit
                if (rx_tick) next_rx_state = rx_idle;
        end
        default : next_rx_state = rx_state;
    endcase

  end

  //==========================================================
  // Data Reception Cleaning (filtering)
  //==========================================================
  always_ff @(posedge clk) 
    if (~rst_n) rx_filter <= 8'h00;
    else        rx_filter <= {rx_filter[6:0] , uart_rxd}; // filter rx data;

  // Generate rx stream with some delay (after filtering ) and pulse on
  // negative edge of rx input data
  always_ff @(posedge clk) begin
    rx_dly   <= {2{rx_dly[0]}};
    if ({7{rx_filter[7]}} == rx_filter[6:0]) rx_dly[0] <= rx_filter[7];
  end    

  assign rx_pulse_fall  = rx_dly[1] && ~rx_dly[0];
  assign rx_data_stream = rx_dly[0];


  //==========================================================
  //  RX Data Shift Register
  //==========================================================
  always_ff @(posedge clk) 
    if (~rst_n) rx_shift  <= 8'hFF; 
    else if (rx_tick) 
      case (rx_state)
        rx_idle                 : rx_shift  <= 8'hFF; 
        rx_startbit , rx_payload :rx_shift  <= {rx_data_stream , rx_shift[7:1]}; 
      endcase



  //==========================================================
  //  Shift Register Empty Flag
  //==========================================================
  always_ff @(posedge clk) 
    if  (~rst_n)            rsempty <= 1'b1;
    else case (rx_state)
          rx_idle : begin// wait for start bit
                  if (~rsempty && ~rx_data_ready)              rsempty <= 1'b1;
                  if (rx_pulse_fall)  rsempty <= 1'b0; 
          end
          rx_stopbit : begin // receive stop bit
                  if (rx_tick) begin
                    if (rx_data_stream) rsempty  <= (parity==none) ? 1'b1 : rx_parity;
                    else                rsempty  <= 1'b1;
                  end
          end
      endcase



  //==========================================================
  // DATA Ready Signal
  //==========================================================
  always_ff @(posedge clk) 
    if      (~rst_n)                   {rx_data,rx_data_ready} <= {8'h00   ,1'b1};
    else if (rx_state ==  rx_startbit) {rx_data,rx_data_ready} <= {8'h00   ,1'b0};   
    else if (rx_state ==  rx_stopbit)  {rx_data,rx_data_ready} <= {rx_shift,1'b1};   




  //==========================================================
  //  Data Parity
  //----------------------------------------------------------
  // 7 bits of data  (nb of 1-bits) even          odd
  // 0000000          0             0_0000000     1_0000000
  // 1010001          3             1_1010001     0_1010001
  // 1101001          4             0_1101001     1_1101001
  // 1111111          7             1_1111111     0_1111111
  //==========================================================
  logic data_parity;
  always_ff @(posedge clk)
   if (~rst_n)         {data_parity, parity_error} <= {(parity == odd),1'b0};
   else if (rx_tick)
      case (rx_state)
         rx_startbit : {data_parity, parity_error} <= {(parity == odd),1'b0};
         rx_payload  : data_parity  <= data_parity ^ rx_data_stream;
         rx_parity   : parity_error <= (rx_data_stream != data_parity);
      endcase
  

//==========================================================
//  Overflow
//==========================================================
  always_ff @(posedge clk) 
    if (~rst_n) ovf <= 1'b0;
    else
      case (rx_state)
          rx_idle :  if (rx_pulse_fall && ~rsempty) ovf <= 1'b1;
      endcase


//==========================================================
//  break_error
//  frame  
//==========================================================
  always_ff @(posedge clk) 
   if (~rst_n)                                                    {break_error,frame_error} <= {1'b0,1'b0};
   else if (rx_tick && rx_state == rx_stopbit && ~rx_data_stream) {break_error,frame_error} <= {(rx_shift == 0),(rx_shift != 0)};


endmodule
