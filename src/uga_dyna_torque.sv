//==============================================================================================
//  Filename    : Dynamixel TTL Controller                                              
//  Designer    : Sylvain ENGELS
//
//  Description: Basic Sequence - Dynamixel MX -28T
//               Code command is controlled by fpga switch
//               This demo read position
//               The write command enable or disblae the torque (led is on when torque is on)
//==============================================================================================
// DE1-SOC Board Assignment
//----------------------------------------------------------------------------------------------
// Signal Name FPGA Pin No.             Description
//----------------------------------------------------------------------------------------------
// CLOCK_50   PIN_AF14                  50 MHz clock input
//----------------------------------------------------------------------------------------------
// KEY[3]     PIN_Y16                   Pushbutton[3]
// KEY[2]     PIN_W15                   Pushbutton[2]
// KEY[1]     PIN_AA15                  Pushbutton[1]
// KEY[0]     PIN_AA14                  Pushbutton[0]
//----------------------------------------------------------------------------------------------
// SW[9]      PIN_AE12                  Switch[9]
// SW[8]      PIN_AD10                  Switch[8]
// SW[7]      PIN_AC9                   Switch[7]
// SW[6]      PIN_AE11                  Switch[6]
// SW[5]      PIN_AD12                  Switch[5]
// SW[4]      PIN_AD11                  Switch[4]
// SW[3]      PIN_AF10                  Switch[3]
// SW[2]      PIN_AF9                   Switch[2]
// SW[1]      PIN_AC12                  Switch[1]
// SW[0]      PIN_AB12                  Switch[0]
//----------------------------------------------------------------------------------------------
// LEDR[9]    PIN_Y21                   LED[9]
// LEDR[8]    PIN_W21                   LED[8]
// LEDR[7]    PIN_W20                   LED[7]
// LEDR[6]    PIN_Y19                   LED[6]
// LEDR[5]    PIN_W19                   LED[5]
// LEDR[4]    PIN_W17                   LED[4]
// LEDR[3]    PIN_V18                   LED[3]
// LEDR[2]    PIN_V17                   LED[2]
// LEDR[1]    PIN_W16                   LED[1]
// LEDR[0]    PIN_V16                   LED[0]
//----------------------------------------------------------------------------------------------
// GPIO_0[3]  PIN_Y18                   GPIO Connection 0[3]
// ..
//----------------------------------------------------------------------------------------------
// GPIO_1[0]  PIN_AB17                  GPIO Connection 1[0]
// GPIO_1[1]  PIN_AA21                  GPIO Connection 1[1]
// ..
// GPIO_1[35] PIN_AC22                  GPIO Connection 1[35]
//----------------------------------------------------------------------------------------------
`include "uga_uart_pkg.sv"
`include "uga_dyna_pkg.sv"

module uga_dyna_demo (
  (* chip_pin = "Y16"                                        *) input  logic        rst_n,     // Push button[3]
  (* chip_pin = "AF14"                                       *) input  logic        clk_fpga,  // 50 MHz clock input
  // FGPA User Interface (button, switch, led)
  (* chip_pin = "AA15,AA14"                                  *) input  logic [1:0]  pushb,     // Push button[1:0]
  (* chip_pin = "AF10,AF9,AC12,AB12"                         *) input  logic [3:0]  switch,    // Toggle Switch[3:0]
  (* chip_pin = "Y21,W21,W20,Y19,W19,W17,V18,V17,W16,V16"    *) output logic [9:0]  red_led,   // Led 9 to 0
  // Uart Input and Output (usefull to strobe signal)
  (* chip_pin = "AB17"                                       *) output logic        dyna_rxd,  // GPIO1[0]
  (* chip_pin = "AA21"                                       *) output logic        dyna_txd,  // GPIO1[1]
  // TTL Dynamixel Connector
  (* chip_pin = "Y18"                                        *) inout  tri1         dyna_ttl   // GPIO0[3] !! Need to be pull-up !!
);

  import     uga_uart_pkg::*;
  import     uga_dyna_pkg::*;
  localparam parity_t parity = none;
    
  logic   dyna_bus_oen;   // Direction of Dynamixel TTL Bus (0=TX, 1=RX)




logic [4:0] byte_nb;    // Number of byte transmitted
logic       start_tx;   // Start Transmittion
logic       end_tx;     // end of Uart Transmittion

 //received data output
logic           rx_data_valid;
logic  [7:0]    rx_data;
logic           rx_data_ready, rx_data_ready_q; 

//Data to transmit input
logic           tx_data_ready;
logic  [7:0]    tx_data;
logic           tx_data_valid, tx_data_valid_q;

//--------------------------------------------------------
// FSM To control Instruction Packet Sending and Status
// As we're in half duplex mode, we always expect receiving
// status after command execution.
//--------------------------------------------------------
typedef enum logic [3:0] { idle,
                           tx_preamble,
                           tx_id,
                           tx_length,
                           tx_inst,
                           tx_param,
                           tx_checksum,
                           return_delay,
                           rx_preamble,
                           rx_id,
                           rx_length,
                           rx_error,
                           rx_param,
                           rx_checksum
                         } dyna_state_t;

dyna_state_t state, next;

instruction_packet_t inst_pkt;
status_packet_t      stat_pkt;
logic [7:0]          torque;


// Packet Definition
assign    inst_pkt.preamble = 16'hFF_FF;
assign    inst_pkt.id       = 8'h02;    // 
assign    inst_pkt.length   = 5;
assign    inst_pkt.inst     = WRITE_DATA;
assign    inst_pkt.param[0] = 8'h18;     // Adress for Torque but we write 2 parameter the also update led
assign    inst_pkt.param[1] = torque; // torque location
assign    inst_pkt.param[2] = torque; // led location
assign    inst_pkt.checksum = dyna_inst_checksum(inst_pkt);

// Force unused parameter to 0
assign    inst_pkt.param[3] = 8'h00;
assign    inst_pkt.param[4] = 8'h00;
assign    inst_pkt.param[5] = 8'h00;



//--------------------------------------------------------
// Main Code
//--------------------------------------------------------
// Push button 0 and 1 Rising Edge Detection
// Write is 0 and read is 1
logic [1:0] pushb0_q, pushb1_q;
always @(posedge clk_fpga)
 if (~rst_n)  begin
              pushb0_q <= 1'b0;
              pushb1_q <= 1'b0;
              end
 else         begin
              pushb0_q <= {pushb0_q[0],pushb[0]};
              pushb1_q <= {pushb1_q[0],pushb[1]};
              end

assign send_instr_pulse =  pushb0_q[1] && ~pushb0_q[0];
assign read_instr_pulse =  pushb1_q[1] && ~pushb1_q[0];

// Small piece of code to have parameter update
// position is moving around 0800 (0700 and 0900 by pushing button 0)
always @(posedge clk_fpga)
 if      (~rst_n)           torque <= 8'h00;
 else if (send_instr_pulse) torque[0] <= ~torque[0];








// Pulse Generation on tx_data_valid to detect end of tx
always @(posedge clk_fpga)
 if (~rst_n)  tx_data_valid_q <= 1'b0;
 else         tx_data_valid_q <= tx_data_valid;

assign end_tx   = ~tx_data_valid && tx_data_valid_q;  // pulse on tx_valid_posedge

// Pulse Generation on rx_data_ready to detect start of rx
always @(posedge clk_fpga)
 if (~rst_n)  rx_data_ready_q <= 1'b0;
 else         rx_data_ready_q <= rx_data_ready;

assign start_rx  = ~rx_data_ready && rx_data_ready_q;  // pulse on rx ready negedge
assign end_rx    = rx_data_ready && ~rx_data_ready_q;  // pulse on rx ready posedge

// Start 1 Byte Transmission (on end of previous transmit or or initial start)
always @(posedge clk_fpga)
 if      (~rst_n)             start_tx <= 1'b0;
 else if (state==idle)        start_tx <= send_instr_pulse;
 else if (state!=tx_checksum) start_tx <= end_tx;    // Checksum is latest transmitted data then no-need to relaunch uart com
 else                         start_tx <= 1'b0;

// Count number of byte transmitted during same frame
always_ff @(posedge clk_fpga or negedge rst_n)
  if      (~rst_n)               byte_nb <= 0;
  else if (state != next)        byte_nb <= 0;
  else if (end_tx || start_rx)   byte_nb++;


always_ff @(posedge clk_fpga or negedge rst_n)
  if (~rst_n) state <= idle;
  else        state <= next;

always_comb 
  case (state) 
    idle         : next = (send_instr_pulse)                          ? tx_preamble  : idle;               // FSM is started when push button 0 is pressed
    tx_preamble  : next = (end_tx && byte_nb == 1)                    ? tx_id        : tx_preamble;
    tx_id        : next = (end_tx)                                    ? tx_length    : tx_id;
    tx_length    : next = (end_tx)                                    ? tx_inst      : tx_length;
    tx_inst      : next = (end_tx) ? (inst_pkt.length == 2)           ? tx_checksum  : tx_param : tx_inst;    // if no paremater, directly goes to checksum
    tx_param     : next = (end_tx && byte_nb == inst_pkt.length-3)    ? tx_checksum  : tx_param;              // inst_pkt.length-3 is equal to number of parameter (byte start@0)
    tx_checksum  : next = (end_tx)                                    ? return_delay : tx_checksum;           // 
    return_delay : next = (start_rx)                                  ? rx_preamble  : return_delay;          // 
    rx_preamble  : next = (start_rx && byte_nb == 1)                  ? rx_id        : rx_preamble;
    rx_id        : next = (start_rx)                                  ? rx_length    : rx_id;
    rx_length    : next = (start_rx)                                  ? rx_error     : rx_length;
    rx_error     : next = (start_rx) ? (stat_pkt.length == 2)         ? rx_checksum  : rx_param : rx_error;   // if no paremater, directly goes to checksum
    rx_param     : next = (start_rx && byte_nb == stat_pkt.length-3)  ? rx_checksum  : rx_param;              // stat_pkt.length-3 is equal to number of parameter (byte start@0)
    rx_checksum  : next = (end_rx)                                    ? idle         : rx_checksum;           // 
    default      : next =                                               idle;
  endcase


// Tri-State Bus Control
assign dyna_bus_oen = ~tx_data_valid; 
assign dyna_ttl     = (dyna_bus_oen == 1'b1) ? 1'bz : dyna_txd;
assign dyna_rxd     =  dyna_ttl;  


always_ff @(posedge clk_fpga or negedge rst_n)
  if      (~rst_n)                rx_data_valid <= 1'b0;
  else if (state == idle)         rx_data_valid <= 1'b0;
  else if (state == return_delay) rx_data_valid <= 1'b1;


// TX Data Selection (internally lock by uart then simple mux is OK)
always_comb 
    case (next)
     idle         : tx_data <= 8'h00;
     tx_preamble  : tx_data <= inst_pkt.preamble[byte_nb];
     tx_id        : tx_data <= inst_pkt.id;
     tx_length    : tx_data <= inst_pkt.length;
     tx_inst      : tx_data <= inst_pkt.inst;
     tx_param     : tx_data <= inst_pkt.param[byte_nb];
     tx_checksum  : tx_data <= inst_pkt.checksum;
     default      : tx_data <= 8'h00;
    endcase

// Status Packet
always_ff @(posedge clk_fpga or negedge rst_n)
  if (~rst_n) stat_pkt <= '{default:0};
  else if (end_rx)
     case (state)
       rx_preamble  : stat_pkt.preamble[byte_nb] <= rx_data;
       rx_id        : stat_pkt.id                <= rx_data; 
       rx_length    : stat_pkt.length            <= rx_data;
       rx_error     : stat_pkt.error             <= rx_data;
       rx_param     : stat_pkt.param[byte_nb]    <= rx_data;
       rx_checksum  : stat_pkt.checksum          <= rx_data;
     endcase

// Generate End of Status Reception Signal
// Can be used as interrupt
logic irq_end_of_rx;

always_ff @(posedge clk_fpga or negedge rst_n)
  if      (~rst_n)                         irq_end_of_rx <= 0;
  else if (state == rx_checksum && end_rx) irq_end_of_rx <= 1;
  else                                     irq_end_of_rx <= 0;


uga_uart #(
  .parity               (none)     // 0 = none
 ) dyna_uart (
  .rst_n                (rst_n), 
  .clk                  (clk_fpga),

  .uart_rxd             (dyna_rxd),
  .uart_txd             (dyna_txd),
    //received data output
  .rx_data_valid        (rx_data_valid),
  .rx_data              (rx_data),
  .rx_data_ready        (rx_data_ready),
    // Data to transmit input
  .tx_data_ready        (start_tx),     // One clock pulse to launch rfuart transmition
  .tx_data              (tx_data),      // Parrelel data to be transmitted on uart line
  .tx_data_valid        (tx_data_valid) // When high, uart is transmitting data on uart_txd
  );

// Print Binary Code of Reception ID on LED
assign     red_led  = {stat_pkt.id,pushb[1:0]};



endmodule

