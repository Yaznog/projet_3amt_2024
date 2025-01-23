`ifndef UGA_UART_PKG
`define UGA_UART_PKG
   package uga_uart_pkg;

     // User Option (setting clock frequency and baudrate)
     localparam integer c_sysclk    = 50;        // FPGA 50 Mhz clock
     localparam integer c_baud      = 38600;     // := 1000000;  --1Mbaud, default speed of dynaximel servos

     // Define parity option for uart
     typedef enum logic [1:0] {
         none,
         even, 
         odd 
      } parity_t;

      localparam integer c_scaler    =  8;        // Clock division inside scaler (rx/tx)
      localparam integer c_prescaler = (c_sysclk*1E6)/(c_baud*c_scaler);


   endpackage
`endif // UGA_UART_PKG

// Dynamixel does the Asynchronous Serial Communication with 8 bit, 1 Stop bit, and None Parity.

// Dynamixel MX and RX servos come from the factory with their baud rate set to 57600. To change this to 1000000 (one million), do:
