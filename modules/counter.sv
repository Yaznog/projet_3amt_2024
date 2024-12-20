
module counter (
  //(* chip_pin = "AF14"                                       *) input  logic       clk,               // Main Clock 50 MHz
  //(* chip_pin = "AA14"                                       *) input  logic       reset,             // Key[0] Synchronous Active Low Reset (More Robust mapping on FPGA)
  // Ready/Valid Interface with ADC FSM]
  //(* chip_pin = "AB17"                                       *) input  logic       adc_conv_valid,  // GPIO_1[0]
 // (* chip_pin = "AB12"                                       *) input  logic       adc_conv_valid,  // SW[0]
  input  logic       clk,
  input  logic       reset,
  output logic [9:0] led_out
 // (* chip_pin = "AA21"                                       *) output logic       adc_conv_ready,   // GPIO_1[1]
  // Filter Control Signal
  //(* chip_pin = "Y21,W21,W20,Y19,W19,W17,V18,V17,W16,V16" *)output logic [9:0] led_out
);

logic [23:0] count;

always @ (posedge clk)
  begin
  
    if (!reset) begin
      count <= 8'b000;
    end
    else  begin
      count <= count+1;
    end
	 
  end

//  assign led_out [9:0] = count [23:15];
  assign led_out [9:0] = count [9:0];  //simulation
  
endmodule