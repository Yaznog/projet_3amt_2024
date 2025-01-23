//==============================================================================================
//  Filename    : Dynamixel TTL Controller                                              
//  Designer    : Sylvain ENGELS
//
//  Description: Basic Sequence - Dynamixel MX -28T
//               Code command is controlled by fpga switch
//               This demo switch on/off the LED
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




logic [4:0] tx_byte;    // Number of byte transmitted
logic       start_tx;   // Start Transmittion
logic       end_tx;     // end of Uart Transmittion

 //received data output
logic           rx_data_read;
logic  [7:0]    rx_data;
logic           rx_data_ready; 

//Data to transmit input
logic           tx_data_ready;
logic  [7:0]    tx_data;
logic           tx_data_valid, tx_data_valid_q;

logic           tx_data_ready_q;

//--------------------------------------------------------
// FSM To control Instruction Packet Sending
//--------------------------------------------------------
typedef enum logic [4:0] { tx_idle,
                           tx_preamble,
                           tx_id,
                           tx_length,
                           tx_inst,
                           tx_param,
                           tx_checksum
                         } dyna_tx_t;

dyna_tx_t tx_state, tx_next;

instruction_packet_t inst_pkt;


// Small piece of code to have parameter update
logic [7:0] led_color;
always @(posedge clk_fpga)
 if      (~rst_n)           led_color <= 8'h00;
 else if (send_instr_pulse) led_color[0] <= ~led_color[0];

// Packet Definition
assign    inst_pkt.preamble = 16'hFF_FF;
assign    inst_pkt.id       = 8'h02;    // 
assign    inst_pkt.length   = 4;
assign    inst_pkt.inst     = WRITE_DATA;
assign    inst_pkt.param[0] = 8'h19;     // Adress for led
assign    inst_pkt.param[1] = led_color; // 
assign    inst_pkt.checksum = dyna_checksum(inst_pkt);

// Force unused parameter to 0
assign    inst_pkt.param[2] = 8'h00;
assign    inst_pkt.param[3] = 8'h00;
assign    inst_pkt.param[4] = 8'h00;
assign    inst_pkt.param[5] = 8'h00;



//--------------------------------------------------------
// Main Code
//--------------------------------------------------------
// Push button0 Rising Edge Detection
logic [1:0] pushb0_q;
always @(posedge clk_fpga)
 if (~rst_n)  pushb0_q <= 1'b0;
 else         pushb0_q <= {pushb0_q[0],pushb[0]};

assign send_instr_pulse =  pushb0_q[1] && ~pushb0_q[0];

// Pulse Generation on tx_data_valid to detect end of tx
always @(posedge clk_fpga)
 if (~rst_n)  tx_data_valid_q <= 1'b0;
 else         tx_data_valid_q <= tx_data_valid;

assign end_tx   = ~tx_data_valid && tx_data_valid_q;  // pulse on tx_valid_posedge


// Start 1 Byte Transmission (on end of previous transmit or or initial start)
always @(posedge clk_fpga)
 if      (~rst_n)                start_tx <= 1'b0;
 else if (tx_state==tx_idle)     start_tx <= send_instr_pulse;
 else if (tx_state!=tx_checksum) start_tx <= end_tx;    // Checksum is latest transmitted data then no-need to relaunch uart com
 else                            start_tx <= 1'b0;

// Count number of transmitted frame
always_ff @(posedge clk_fpga or negedge rst_n)
  if      (~rst_n)               tx_byte <= 0;
  else if (tx_state != tx_next)  tx_byte <= 0;
  else if (end_tx)               tx_byte++;


always_ff @(posedge clk_fpga or negedge rst_n)
  if (~rst_n) tx_state <= tx_idle;
  else        tx_state <= tx_next;

always_comb 
  case (tx_state) 
    tx_idle      : tx_next = (send_instr_pulse)                          ? tx_preamble : tx_idle;               // FSM is started when push button 0 is pressed
    tx_preamble  : tx_next = (end_tx && tx_byte == 1)                    ? tx_id       : tx_preamble;
    tx_id        : tx_next = (end_tx)                                    ? tx_length   : tx_id;
    tx_length    : tx_next = (end_tx)                                    ? tx_inst     : tx_length;
    tx_inst      : tx_next = (end_tx) ? (inst_pkt.length == 2)           ? tx_checksum : tx_param : tx_inst;    // if no paremater, directly goes to checksum
    tx_param     : tx_next = (end_tx && tx_byte == inst_pkt.length-3)    ? tx_checksum : tx_param;              // inst_pkt.length-3 is equal to number of parameter (byte start@0)
    tx_checksum  : tx_next = (end_tx)                                    ? tx_idle     : tx_checksum;           // 
    default      : tx_next =                                               tx_idle;
  endcase


// Tri-State Bus Control
assign dyna_bus_oen = ~tx_data_valid; 
assign dyna_ttl     = (dyna_bus_oen == 1'b1) ? 1'bz : dyna_txd;
assign dyna_rxd     =  dyna_ttl;  


assign rx_data_read = 1'b1; // Always reading data

// TX Data Selection (internally lock by uart then simple mux is OK)
always_comb 
    case (tx_next)
     tx_idle      : tx_data <= 8'h00;
     tx_preamble  : tx_data <= inst_pkt.preamble[tx_byte];
     tx_id        : tx_data <= inst_pkt.id;
     tx_length    : tx_data <= inst_pkt.length;
     tx_inst      : tx_data <= inst_pkt.inst;
     tx_param     : tx_data <= inst_pkt.param[tx_byte];
     tx_checksum  : tx_data <= inst_pkt.checksum;
     default      : tx_data <= 8'h00;
    endcase


uga_uart #(
  .parity               (none)     // 0 = none
 ) dyna_uart (
  .rst_n                (rst_n), 
  .clk                  (clk_fpga),

  .uart_rxd             (dyna_rxd),
  .uart_txd             (dyna_txd),
    //received data output
  .rx_data_read         (rx_data_read),
  .rx_data              (rx_data),
  .rx_data_ready        (rx_data_ready),
    // Data to transmit input
  .tx_data_ready        (start_tx),     // One clock pulse to launch rfuart transmition
  .tx_data              (tx_data),      // Parrelel data to be transmitted on uart line
  .tx_data_valid        (tx_data_valid) // When high, uart is transmitting data on uart_txd
  );


assign     red_led  = {rst_n,2'b00,pushb[1:0],1'b0,switch[3:0]};



endmodule

