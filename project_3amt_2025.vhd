LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use ieee.numeric_std.ALL;

LIBRARY work;


ENTITY project_3amt_2025 IS -----------------------------------------------------------------------
	PORT
	(
	-- Board DE1-SOC
		CLOCK_50 :  		IN  	STD_LOGIC;
		RESETn_pin :  		OUT  	STD_LOGIC;	
		VGA_CLK : 			OUT 	STD_LOGIC;
		VGA_VS :  			OUT  	STD_LOGIC;
		VGA_HS :  			OUT  	STD_LOGIC;
		VGA_BLANK_N : 		OUT 	STD_LOGIC;
		VGA_SYNC_N : 		OUT 	STD_LOGIC;
		
		test1_pin :			OUT	STD_LOGIC; -- test pin 1
		test2_pin :			OUT	STD_LOGIC; -- test pin 2
		test3_pin :			OUT	STD_LOGIC; -- test pin 3
		CLK_50M_pin :		OUT	STD_LOGIC; -- test pin 4
		test5_pin :			OUT	STD_LOGIC; -- test pin 5
		CLK_100_pin :		OUT	STD_LOGIC; -- test pin 6
		test7_pin :			OUT	STD_LOGIC; -- test pin 7
		CLK_38_4K_pin :	OUT	STD_LOGIC; -- test pin 8
		test9_pin :			OUT	STD_LOGIC; -- test pin 9
		ENABLE_pin :		OUT	STD_LOGIC; -- test pin 10
	
	-- USB
--		rx :  				IN  	STD_LOGIC;		
--		tx :  				OUT  	STD_LOGIC;		
		
	-- Display ledr pio
--		pio :  				OUT  	STD_LOGIC_VECTOR(7 DOWNTO 0);

	-- 7-segments displays
		HEX0 : 				OUT  	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1 : 				OUT  	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2 : 				OUT  	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3 : 				OUT  	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4 : 				OUT  	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5 : 				OUT  	STD_LOGIC_VECTOR(6 DOWNTO 0);

	-- Camera GPIO_1 Camera D5M
		Ext_Clock : 		IN  	STD_LOGIC;
		CCD_FVAL :  		IN  	STD_LOGIC;
		CCD_LVAL :  		IN  	STD_LOGIC;
		CCD_PIXCLK :  		IN  	STD_LOGIC;
		I2C_SCLK :  		INOUT STD_LOGIC;
		I2C_SDAT :  		INOUT STD_LOGIC;
		CCD_DATA :  		IN  	STD_LOGIC_VECTOR(11 DOWNTO 0);
		KEY :  				IN  	STD_LOGIC_VECTOR(3 DOWNTO 0);
		SW :  				IN  	STD_LOGIC_VECTOR(9 DOWNTO 0);
		CCD_MCCLK :  		OUT  	STD_LOGIC;
		TRIGGER :  			OUT  	STD_LOGIC;		
		LEDG :  				OUT  	STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_B :  			OUT  	STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_G :  			OUT  	STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_R :  			OUT  	STD_LOGIC_VECTOR(7 DOWNTO 0);		
		VGA_HS_OBS : 		OUT 	STD_LOGIC;
		VGA_VS_OBS : 		OUT 	STD_LOGIC;
		VGA_BLANK_N_OBS : OUT 	STD_LOGIC;
		VGA_G7_OBS : 		OUT 	STD_LOGIC;
		tempo_flag : 		OUT  	STD_LOGIC;
		servo1 : 			OUT  	STD_LOGIC;
		servo2 : 			OUT  	STD_LOGIC		 
		);

END project_3amt_2025;



ARCHITECTURE project_3amt_2025_arch OF project_3amt_2025 IS ---------------------------------------

----------------------------------------------------------------------
-- ATTRIBUTEs									                             --
----------------------------------------------------------------------

attribute chip_pin : 								string;


---- Board DE1-SOC
attribute chip_pin of CLOCK_50 : 				signal is "AF14";

attribute chip_pin of VGA_HS : 					signal is "B11";
attribute chip_pin of VGA_VS : 					signal is "D11";

attribute chip_pin of VGA_CLK : 					signal is "A11";
attribute chip_pin of VGA_BLANK_N : 			signal is "F10";
attribute chip_pin of VGA_SYNC_N : 				signal is "C10";		
		
attribute chip_pin of VGA_G : 					signal is "E11,F11,G12,G11,G10,H12,J10,J9";
attribute chip_pin of VGA_R : 					signal is "F13,E12,D12,C12,B12,E13,C13,A13";
attribute chip_pin of VGA_B : 					signal is "J14,G15,F15,H14,F14,H13,G13,B13";

--attribute chip_pin of LEDR : 						signal is "G19,F19,E19,F21,F15,G15,G16,H16";
attribute chip_pin of LEDG : 						signal is "W20,Y19,W19,W17,V18,V17,W16,V16";
attribute chip_pin of KEY : 						signal is "Y16,W15,AA15,AA14";
attribute chip_pin of SW : 						signal is "AE12,AD10,AC9,AE11,AD12,AD11,AF10,AF9,AC12,AB12";


---- Camera GPIO_1 Camera D5M
attribute chip_pin of CCD_FVAL :  				signal is "AK24";
attribute chip_pin of CCD_LVAL :   				signal is "AJ24";
attribute chip_pin of CCD_PIXCLK :				signal is "AB17";
attribute chip_pin of I2C_SCLK :   				signal is "AK23";
attribute chip_pin of I2C_SDAT :   				signal is "AG23";
attribute chip_pin of CCD_MCCLK : 				signal is "AK27";
attribute chip_pin of CCD_DATA : 				signal is "AA21,AC23,AD24,AE23,AE24,AF25,AF26,AG25,AG26,AH24,AH27,AJ27";
attribute chip_pin of TRIGGER : 					signal is "AH25";
attribute chip_pin of RESETn_pin : 				signal is "AJ26";


---- Servo Connecteurs GPIO_0 
attribute chip_pin of servo1 : 					signal is "AK16";
attribute chip_pin of servo2 : 					signal is "AK18";

--attribute chip_pin of Ext_Clock : 				signal is "AG18";
--attribute chip_pin of tempo_flag : 				signal is "AG21";


---- Controle timing VGA_B GPIO_0 (en haut gauche droite)
attribute chip_pin of VGA_HS_OBS : 				signal is "AC18";	-- GPIO_0(0)
attribute chip_pin of VGA_VS_OBS : 				signal is "Y17";  -- GPIO_0(1)
attribute chip_pin of VGA_BLANK_N_OBS : 		signal is "AD17";	-- GPIO_0(2)
attribute chip_pin of VGA_G7_OBS : 				signal is "Y18"; 	-- GPIO_0(3)


---- 7-segments displays
attribute chip_pin of HEX0 : 						signal is "AE26,AE27,AE28,AG27,AF28,AG28,AH28";	-- Seven Segment Digit 0
attribute chip_pin of HEX1 : 						signal is "AJ29,AH29,AH30,AG30,AF29,AF30,AD27";	-- Seven Segment Digit 1
attribute chip_pin of HEX2 : 						signal is "AB23,AE29,AD29,AC28,AD30,AC29,AC30";	-- Seven Segment Digit 2
attribute chip_pin of HEX3 : 						signal is "AD26,AC27,AD25,AC25,AB28,AB25,AB22";	-- Seven Segment Digit 3
attribute chip_pin of HEX4 : 						signal is "AA24,Y23,Y24,W22,W24,V23,W25";			-- Seven Segment Digit 4
attribute chip_pin of HEX5 : 						signal is "V25,AA28,Y27,AB27,AB26,AA26,AA25";	-- Seven Segment Digit 5


attribute chip_pin of test1_pin : 				signal is "AE18";	-- GPIO_0(31)
attribute chip_pin of test2_pin : 				signal is "AE19";	-- GPIO_0(31)
attribute chip_pin of test3_pin : 				signal is "AF20";	-- GPIO_0(32)
attribute chip_pin of CLK_50M_pin : 			signal is "AF21";	-- GPIO_0(31)
attribute chip_pin of test5_pin : 				signal is "AF19";	-- GPIO_0(31)
attribute chip_pin of CLK_100_pin : 			signal is "AG21";	-- GPIO_0(31) -- Warning: already used
attribute chip_pin of test7_pin : 				signal is "AF18";	-- GPIO_0(33)
attribute chip_pin of CLK_38_4K_pin : 			signal is "AG20";	-- GPIO_0(34)
attribute chip_pin of test9_pin : 				signal is "AG18";	-- GPIO_0(34) -- Warning: already used
attribute chip_pin of ENABLE_pin : 				signal is "AJ21";	-- GPIO_0(35) -- Warning: already used



-- USB-RS232 UART cable TX -> GPIO_0(1)
--attribute chip_pin of rx : 						signal is "AC18"; -- GPIO (0)
--attribute chip_pin of tx : 						signal is "Y17";  -- GPIO (1)

---- USB-RS232 UART cable TX -> GPIO_0(34/35)
--attribute chip_pin of rxd_pc : 					signal is "AG18";
--attribute chip_pin of txd_dyna : 				signal is "AJ21";

---- GIO_1(33)
--attribute chip_pin of byteenable_obs : 		signal is "AD21";
----  GIO_1(35)
--attribute chip_pin of start_transmit_obs : 	signal is "AC22";

---- afficheur ledr pio
--attribute  chip_pin of pio : 						signal is "W20,Y19,W19,W17,V18,V17,W16,V16";


----------------------------------------------------------------------
-- COMPONENTs									                             --
----------------------------------------------------------------------

COMPONENT d5m_ip
	PORT(
		CLOCK_50 : 			IN 	STD_LOGIC;
		CCD_FVAL : 			IN 	STD_LOGIC;
		CCD_LVAL : 			IN 	STD_LOGIC;
		CCD_PIXCLK : 		IN 	STD_LOGIC;
		CCD_DATA : 			IN 	STD_LOGIC_VECTOR(11 DOWNTO 0);
		KEY : 				IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
		SW : 					IN 	STD_LOGIC_VECTOR(9 DOWNTO 0);
		CCD_MCLK : 			OUT 	STD_LOGIC;
		TRIGGER : 			OUT 	STD_LOGIC;
		RESETn : 			OUT 	STD_LOGIC;
		I2C_SCLK : 			INOUT STD_LOGIC;
		I2C_SDAT : 			INOUT STD_LOGIC;
		sCCD_DVAL : 		OUT 	STD_LOGIC;
		owrite_DPRAM : 	OUT 	STD_LOGIC;
		LEDG : 				OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		sCCD_B : 			OUT 	STD_LOGIC_VECTOR(11 DOWNTO 0);
		sCCD_G : 			OUT 	STD_LOGIC_VECTOR(11 DOWNTO 0);
		sCCD_R : 			OUT 	STD_LOGIC_VECTOR(11 DOWNTO 0);
		X_Cont : 			OUT 	STD_LOGIC_VECTOR(11 DOWNTO 0);
		Y_Cont : 			OUT 	STD_LOGIC_VECTOR(10 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dpram_512x512
	PORT(
		wren : 				IN 	STD_LOGIC;
		wrclock : 			IN 	STD_LOGIC;
		rdclock : 			IN 	STD_LOGIC;
		data : 				IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		rdaddress : 		IN 	STD_LOGIC_VECTOR(17 DOWNTO 0); -- IMAGE 512 x 512
		wraddress : 		IN 	STD_LOGIC_VECTOR(17 DOWNTO 0);
		q : 					OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT gensync
	PORT(
		CLK : 				IN 	STD_LOGIC;
		reset : 				IN 	STD_LOGIC;
		HSYNC : 				OUT 	STD_LOGIC;
		VSYNC : 				OUT 	STD_LOGIC;
		IMG : 				OUT 	STD_LOGIC;
		IMGY_out : 			OUT 	STD_LOGIC;
		X : 					OUT 	STD_LOGIC_VECTOR(9 DOWNTO 0);
		Y : 					OUT 	STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
END COMPONENT;

COMPONENT image_process
		PORT(
		IMG : 				IN 	STD_LOGIC;
		reset : 				IN 	STD_LOGIC;
		control : 			IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
		CLK_1 :				IN		STD_LOGIC;
		VGA_HS : 			IN 	STD_LOGIC;
		VGA_VS : 			IN 	STD_LOGIC;
		VGA_CLK : 			IN 	STD_LOGIC;
		X_Cont : 			IN 	STD_LOGIC_VECTOR(8 downto 0);
		Y_Cont : 			IN 	STD_LOGIC_VECTOR(8 downto 0);  -- image 512 x 512
		r : 					IN 	STD_LOGIC_VECTOR(7 downto 0);
		g : 					IN 	STD_LOGIC_VECTOR(7 downto 0);
		b : 					IN 	STD_LOGIC_VECTOR(7 downto 0);
		r_out	: 				OUT 	STD_LOGIC_VECTOR(7 downto 0);
		g_out	: 				OUT 	STD_LOGIC_VECTOR(7 downto 0);
		b_out	: 				OUT 	STD_LOGIC_VECTOR(7 downto 0);
		newImage_out :		OUT	STD_LOGIC
		);
END COMPONENT;
		
COMPONENT altpll0
	PORT(
		inclk0 : 			IN 	STD_LOGIC;
		c0 : 					OUT 	STD_LOGIC;
		locked : 			OUT 	STD_LOGIC
	);
END COMPONENT;

COMPONENT pwm_cycle
	PORT(
		Rst : 				IN 	STD_LOGIC;
		Clk : 				IN 	STD_LOGIC;
		CLOCK_50 : 			IN 	STD_LOGIC;
		pwm_high : 			IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		tempo_flag : 		OUT 	STD_LOGIC;
		PWMout : 			OUT 	STD_LOGIC
	);
END COMPONENT;


--COMPONENT rr
--	PORT (
--		clk_clk : 								in std_logic := 'X';             	-- clk
--		uart_0_external_connection_rxd : in std_logic := 'X';             	-- rxd
--		uart_0_external_connection_txd : out std_logic;                   	-- txd
--		pio_external_connection_export : out std_logic_vector(7 downto 0); 	-- export
--		reset_reset_n : 						in std_logic := 'X'             		-- reset_n
----		recep_nios_emiss_dyna_0_conduit_end_export   : out std_logic;        --  recep_nios_emiss_dyna_0_conduit_end.export
----		recep_nios_emiss_dyna_0_conduit_end_1_export : in  std_logic := '0'; -- recep_nios_emiss_dyna_0_conduit_end_1.export
----		recep_nios_emiss_dyna_0_conduit_end_2_export : out std_logic;        -- recep_nios_emiss_dyna_0_conduit_end_2.export
----    recep_nios_emiss_dyna_0_conduit_end_3_export : out std_logic
--);
--END COMPONENT rr;


COMPONENT clock_divider
	PORT(
		CLK_50M: 			IN 	STD_LOGIC;
		reset: 				IN 	STD_LOGIC;
		CLK_100: 			OUT 	STD_LOGIC;
		CLK_38_4K: 			OUT 	STD_LOGIC;
		CLK_1: 				OUT 	STD_LOGIC
	);
END COMPONENT;


COMPONENT stopwatch
	PORT(
		CLK_100: 			IN 	STD_LOGIC;
		reset: 				IN 	STD_LOGIC;
		counter: 			OUT 	STD_LOGIC_VECTOR(41 downto 0)
	);
END COMPONENT;


----------------------------------------------------------------------
-- SIGNALs									                      			  --
----------------------------------------------------------------------

SIGNAL	memr_ad :  									STD_LOGIC_VECTOR(17 DOWNTO 0);  -- 512 x 512 carre
SIGNAL	memw_ad :  									STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL	sCCD_VAL :  								STD_LOGIC;
SIGNAL	CCD_MCCLK_i :  							STD_LOGIC;
SIGNAL	VGA_G_i,VGA_B_i,VGA_R_i :  			STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	VGA_NB_i :  								STD_LOGIC_VECTOR(13 DOWNTO 0);
SIGNAL	VGA_NB_i_uns :  							unsigned(13 DOWNTO 0);
SIGNAL	wadd :  										STD_LOGIC_VECTOR(16 DOWNTO 0);
SIGNAL	x_read :  									STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	X_write :  									STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	y_read :  									STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL	Y_write :  									STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL	rdclock :  									STD_LOGIC;
SIGNAL	wren :  										STD_LOGIC;
SIGNAL	IMG,CLK_25 :  								STD_LOGIC;
SIGNAL	owrite_DPRAM :  							STD_LOGIC;
SIGNAL	b,r,b_out,r_out,g,g_out,g_out_in :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	Noir_et_blanc_int :  					STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	q :  											STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	IMGY_out,VGA_CLK_i :  					STD_LOGIC;
SIGNAL	VGA_H_int,VGA_V_int,PWM_out :  		STD_LOGIC;
SIGNAL   R_level,G_level,B_level	: 				UNSIGNED(7 DOWNTO 0);

SIGNAL 	HEX012345 : 								STD_LOGIC_VECTOR(41 DOWNTO 0);
SIGNAL	CLK_100_s :									STD_LOGIC;
SIGNAL	CLK_38_4K_s :								STD_LOGIC;
SIGNAL	CLK_1_s :									STD_LOGIC;

SIGNAL	imageGreenOnly_s :						STD_LOGIC;
SIGNAL	gameOverlay_s :							STD_LOGIC;
--SIGNAL	imageRed_s :								STD_LOGIC;
--SIGNAL	imageGreen_s :								STD_LOGIC;
--SIGNAL	imageBlue_s :								STD_LOGIC;

SIGNAL 	RESETn :										STD_LOGIC;

SIGNAL 	stopwatchEnable_s :						STD_LOGIC;
SIGNAL 	clockEnable_s :							STD_LOGIC;

SIGNAL 	newImage_s :								STD_LOGIC;

BEGIN ---------------------------------------------------------------------------------------------


VGA_CLK 				<= CLK_25;
VGA_BLANK_N 		<=  IMG;
VGA_SYNC_N 			<= CLK_25;
VGA_HS 				<= VGA_H_int;
VGA_VS 				<= VGA_V_int;
VGA_HS_OBS 			<= VGA_H_int;
VGA_VS_OBS 			<= VGA_V_int;
VGA_BLANK_N_OBS 	<= IMG;
VGA_G7_OBS 			<= g_out_in(7);
g_out 				<= g_out_in;

--VGA_R <= Noir_et_blanc_VGA_NB_i <= conv_std_logic_vector(VGA_NB_i_uns(13 downto 0),14);int; -- passage par le blanker
--VGA_G <= Noir_et_blanc_int;
--VGA_B <= Noir_et_blanc_int;

VGA_R <= r_out;  -- sans le blanker
VGA_G <= g_out;
VGA_B <= b_out;
-- 
VGA_NB_i <= conv_std_logic_vector(VGA_NB_i_uns(13 downto 0),14);



Calc_NB :process(VGA_R_i,VGA_G_i,VGA_B_i)
	begin	
--	noir et blanc = (vert + rouge + bleu) / 3 
	VGA_NB_i_uns <= ("00" & unsigned(VGA_R_i)) + ("00" & unsigned(VGA_R_i)) +("00" & unsigned(VGA_R_i));		
end process Calc_NB;



b2v_inst : d5m_ip
PORT MAP(CLOCK_50 	=> CLOCK_50,
		 CCD_FVAL 		=> CCD_FVAL,
		 CCD_LVAL 		=> CCD_LVAL,
		 CCD_PIXCLK 	=> CCD_PIXCLK,
		 CCD_DATA 		=> CCD_DATA,
		 KEY 				=> KEY,
		 SW 				=> SW,
		 CCD_MCLK 		=> CCD_MCCLK_i,
		 TRIGGER 		=> TRIGGER,
		 RESETn 			=> RESETn,
		 I2C_SCLK 		=> I2C_SCLK,
		 I2C_SDAT 		=> I2C_SDAT,
		 sCCD_DVAL 		=> sCCD_VAL,
		 owrite_DPRAM 	=> owrite_DPRAM,
		 LEDG 			=> LEDG,
		 sCCD_R 			=> VGA_R_i,
		 sCCD_G 			=> VGA_G_i,
		 sCCD_B 			=> VGA_B_i,
		 X_Cont 			=> X_write,
		 Y_Cont 			=> Y_write);


b2v_inst1 : dpram_512x512
PORT MAP(wren 			=> wren,
	    wrclock 		=> CCD_MCCLK_i,
		 rdclock 		=> rdclock,
		 data 			=> VGA_G_i(11 DOWNTO 4),  -- noir et blanc depuis G
		 rdaddress 		=> memr_ad,
		 wraddress 		=> memw_ad,
		 q 				=> q);

-- Pour 512 x 512
memw_ad(8 DOWNTO 0) 	<= X_write(9 DOWNTO 1);
memw_ad(17 DOWNTO 9) <= Y_write(9 DOWNTO 1);  -- 8 bits

memr_ad(8 DOWNTO 0) 	<= x_read(8 DOWNTO 0);
memr_ad(17 DOWNTO 9) <= y_read(8 DOWNTO 0);
	

servo1 <= PWM_out; 
servo2 <= not PWM_out; 

b2v_inst2 : gensync
PORT MAP(CLK 			=> CLK_25,
		 reset 			=> RESETn,--KEY(0),
		 HSYNC 			=> VGA_H_int,
		 VSYNC 			=> VGA_V_int,
		 IMG 				=> IMG,
		 IMGY_out 		=> IMGY_out,
		 X 				=> x_read,
		 Y 				=> y_read);


b2v_inst3 : image_process
PORT MAP(IMG	 		=> IMG,
		reset  			=> RESETn,--KEY(0),
		--control 			=> imageBlue_s & imageGreen_s & imageRed_s & gameOverlay_s & imageGreenOnly_s,
		control 			=> gameOverlay_s & imageGreenOnly_s,
		CLK_1				=> CLK_1_s,
		VGA_HS 			=> VGA_H_int,
		VGA_VS 			=> VGA_V_int,
		VGA_CLK	 		=> CLK_25,
		X_Cont   		=> memr_ad(8 DOWNTO 0), 
		Y_Cont  			=> memr_ad(17 DOWNTO 9),  -- image 512 x 512
		r					=> r,
		g					=> g,
		b  				=> b,
		r_out				=> r_out,
		g_out				=> g_out_in,
		b_out				=> b_out,
		newImage_out 	=> newImage_s
		);

rdclock 		<= CLK_25;
CCD_MCCLK  	<= CCD_MCCLK_i;
wren 			<= owrite_DPRAM;
g 				<= q;


b2v_inst9 : altpll0
PORT MAP(inclk0 		=> CLOCK_50,
		 c0 				=> CLK_25);

b2v_inst10 : pwm_cycle
PORT MAP(Rst 			=> RESETn,--KEY(0),
		 Clk 				=> Ext_Clock,
		 CLOCK_50 		=> CLOCK_50,
		 pwm_high 		=> SW(7 downto 0),
		 tempo_flag 	=> tempo_flag,
		 PWMout 			=> PWM_out);
		 
		 
b2v_inst11 : clock_divider
PORT MAP(CLK_50M 		=> CLOCK_50,
		 reset 			=> clockEnable_s,--RESETn,--KEY(0),
		 CLK_100 		=> CLK_100_s,
		 CLK_38_4K 		=> CLK_38_4K_s,
		 CLK_1 			=> CLK_1_s);		 
		 
		 
b2v_inst13 : stopwatch
PORT MAP(CLK_100 		=> CLK_100_s,
		 reset 			=> stopwatchEnable_s,--RESETn,--KEY(0),
		 counter 		=> HEX012345);
		 

		 
--b2v_inst13 : rr
--PORT MAP(clk_clk => CLOCK_50,
--		 uart_0_external_connection_rxd => rx,
--		 uart_0_external_connection_txd => tx,
--		 pio_external_connection_export => LEDG,--pio,
--		 reset_reset_n => RESETN
----		 recep_nios_emiss_dyna_0_conduit_end_export  => txd_dyna,      --   recep_nios_emiss_dyna_0_conduit_end.export
----		 recep_nios_emiss_dyna_0_conduit_end_1_export  =>  rxd_pc,  --   recep_nios_emiss_dyna_0_conduit_end_1.export
----		 recep_nios_emiss_dyna_0_conduit_end_2_export => byteenable_obs,                            -- recep_nios_emiss_dyna_0_conduit_end_2.export
----     recep_nios_emiss_dyna_0_conduit_end_3_export => start_transmit_obs
--);



	-- 4 7-seg displays
	HEX0 					<= HEX012345(6 DOWNTO 0);
	HEX1 					<= HEX012345(13 DOWNTO 7);
	HEX2 					<= HEX012345(20 DOWNTO 14);
	HEX3 					<= HEX012345(27 DOWNTO 21);
	HEX4					<= HEX012345(34 DOWNTO 28);
	HEX5 					<= HEX012345(41 DOWNTO 35);
	
	
	RESETn_pin 			<= RESETn;
	
	
	test1_pin			<= imageGreenOnly_s;
	test2_pin			<= CLK_1_s;
	test3_pin			<= gameOverlay_s;
	CLK_50M_pin			<= CLOCK_50;
	test5_pin			<= newImage_s;
	CLK_100_pin			<= CLK_100_s;
	test7_pin			<= '0';
	CLK_38_4K_pin		<= CLK_38_4K_s;
	test9_pin			<= '0';
	ENABLE_pin 			<= RESETn; --SW(4);--
	
	
--	void 					<= SW(0); -- Sensibility control
	imageGreenOnly_s 	<= SW(1);
	gameOverlay_s 		<= SW(2);
--	imageRed_s 			<= SW(3);
--	imageGreen_s 		<= SW(4);
--	imageBlue_s 		<= SW(5);
--	void 					<= SW(6);
--	void 					<= SW(7);
	stopwatchEnable_s <= SW(8);
	clockEnable_s 		<= SW(9);


--	void					<= KEY(0);
--	void					<= KEY(1);
--	void					<= KEY(2);
--	void					<= KEY(3);

--	LEDG(0)				<= newImage_s;
--	LEDG(1)				<= newImage_s;
--	LEDG(2)				<= ;
--	LEDG(3)				<= ;
--	LEDG(4)				<= ;
--	LEDG(5)				<= ;
--	LEDG(6)				<= ;
--	LEDG(7)				<= ;
--	LEDG(8)				<= ;
--	LEDG(9)				<= ;
	
	
-- /softslin/altera17_0/modelsim_ase/linuxaloem
-- /softslin/questa_core_prime_2019/questasim/bin/

END project_3amt_2025_arch;