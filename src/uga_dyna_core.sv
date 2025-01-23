//==============================================================================================
//  Filename    : Dynamixel MX-28T Core Controller                                               
//  Designer    : Sylvain ENGELS
//
//  Description: Core Module of Dynamixel MX -28T
//               This module must be connected to register bank to enable SW control
//==============================================================================================
module uga_dyna_core (
  input  logic        rst_n,  // Main reset (Synchronous for FPGA)
  input  logic        clk,    // 50 MHz clock input
  
  input  logic [1:0]  pushb,     // Push button[1:0]
  input  logic [3:0]  switch,    // Toggle Switch[3:0]
  output logic [9:0]  red_led,   // Led 9 to 0
  
  output logic        dyna_rxd,
  output logic        dyna_txd,
  
  inout  tri1         dyna_ttl   // !! Need to be pull-up !!
);

  import     uga_uart_pkg::*;
  import     uga_dyna_pkg::*;
  localparam parity_t parity = none;
    
  logic   dyna_bus_oen;   // Direction of Dynamixel TTL Bus (0=TX, 1=RX)










endmodule

