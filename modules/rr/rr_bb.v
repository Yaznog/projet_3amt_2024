
module rr (
	clk_clk,
	pio_external_connection_export,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd,
	reset_reset_n);	

	input		clk_clk;
	output	[7:0]	pio_external_connection_export;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
	input		reset_reset_n;
endmodule
