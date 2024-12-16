-- Copyright (C) 1991-2009 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II"
-- VERSION		"Version 9.0 Build 235 06/17/2009 Service Pack 2 SJ Web Edition"
-- CREATED ON		"Tue Mar 19 09:52:56 2013"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY TOP_DE1_D5M_IP_save IS 
	PORT
	(
		CLOCK_50 :  IN  STD_LOGIC;
		CCD_FVAL :  IN  STD_LOGIC;
		CCD_LVAL :  IN  STD_LOGIC;
		CCD_PIXCLK :  IN  STD_LOGIC;
		I2C_SCLK :  INOUT  STD_LOGIC;
		I2C_SDAT :  INOUT  STD_LOGIC;
		CCD_DATA :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		KEY :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		SW :  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		CCD_MCCLK :  OUT  STD_LOGIC;
		TRIGGER :  OUT  STD_LOGIC;
		RESETn :  OUT  STD_LOGIC;
		VGA_VS :  OUT  STD_LOGIC;
		VGA_HS :  OUT  STD_LOGIC;
--		GPIO_0 :  OUT  STD_LOGIC_VECTOR(28 DOWNTO 0);
--		GPIO_0[16] :  OUT  STD_LOGIC;
--		GPIO_0[11] :  OUT  STD_LOGIC;
--		GPIO_0[10] :  OUT  STD_LOGIC;
--		GPIO_0[9] :  OUT  STD_LOGIC;
--		GPIO_0[8] :  OUT  STD_LOGIC;
--		GPIO_0[7] :  OUT  STD_LOGIC;
--		GPIO_0[6] :  OUT  STD_LOGIC;
--		GPIO_0[5] :  OUT  STD_LOGIC;
--		GPIO_0[4] :  OUT  STD_LOGIC;
--		GPIO_0[3] :  OUT  STD_LOGIC;
--		GPIO_0[2] :  OUT  STD_LOGIC;
--		GPIO_0[1] :  OUT  STD_LOGIC;
--		GPIO_0[0] :  OUT  STD_LOGIC;
--		GPIO_0[27] :  OUT  STD_LOGIC;
--		GPIO_0[26] :  OUT  STD_LOGIC;
--		GPIO_0[25] :  OUT  STD_LOGIC;
--		GPIO_0[24] :  OUT  STD_LOGIC;
--		GPIO_0[23] :  OUT  STD_LOGIC;
--		GPIO_0[22] :  OUT  STD_LOGIC;
--		GPIO_0[21] :  OUT  STD_LOGIC;
--		GPIO_0[20] :  OUT  STD_LOGIC;
--		GPIO_0[19] :  OUT  STD_LOGIC;
--		GPIO_0[18] :  OUT  STD_LOGIC;
--		GPIO_0[17] :  OUT  STD_LOGIC;
--		GPIO_0[28] :  OUT  STD_LOGIC;
		LEDG :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_B :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
		VGA_G :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
		VGA_R :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END TOP_DE1_D5M_IP_save;

ARCHITECTURE bdf_type OF TOP_DE1_D5M_IP_save IS 

attribute chip_pin          		: string;

attribute chip_pin of CLOCK_50  : signal is "L1";

attribute chip_pin of VGA_HS  : signal is "A11"; --
attribute chip_pin of VGA_VS  : signal is "B11"; --

attribute chip_pin of VGA_B  : signal is "B10,A10,D11,A9";
attribute chip_pin of VGA_G  : signal is "A8,B9,C10,B8";
attribute chip_pin of VGA_R  : signal is "B7,A7,C9,D9";

-- attribute chip_pin of LEDR  : signal is "R17,R18,U18,Y18,V19,T18,Y19,U19,R19,R20";
attribute chip_pin of LEDG  : signal is "Y21,Y22,W21,W22,V21,V22,U21,U22";
attribute chip_pin of KEY  : signal is "T21,T22,R21,R22";
attribute chip_pin of SW  : signal is "L2,M1,M2,U11,U12,W12,V12,M22,L21,L22";

-- Camera
attribute chip_pin of CCD_FVAL :  signal is "E19";
attribute chip_pin of CCD_LVAL :   signal is "F20";
attribute chip_pin of CCD_PIXCLK :   signal is "H12";
attribute chip_pin of I2C_SCLK :   signal is "G20";
attribute chip_pin of I2C_SDAT :   signal is "E18";
attribute chip_pin of CCD_MCCLK  : signal is "C19";
attribute chip_pin of CCD_DATA  : signal is "H13,G15,E14,E15,F15,G16,F12,F13,C14,D14,D15,D16";
attribute chip_pin of TRIGGER  : signal is "D20";
attribute chip_pin of RESETn  : signal is "C20";

COMPONENT de1_d5m_ip
	PORT(CLOCK_50 : IN STD_LOGIC;
		 CCD_FVAL : IN STD_LOGIC;
		 CCD_LVAL : IN STD_LOGIC;
		 CCD_PIXCLK : IN STD_LOGIC;
		 CCD_DATA : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 CCD_MCLK : OUT STD_LOGIC;
		 TRIGGER : OUT STD_LOGIC;
		 RESETn : OUT STD_LOGIC;
		 I2C_SCLK : INOUT STD_LOGIC;
		 I2C_SDAT : INOUT STD_LOGIC;
		 sCCD_DVAL : OUT STD_LOGIC;
		 owrite_DPRAM : OUT STD_LOGIC;
		 LEDG : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 sCCD_B : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 sCCD_G : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 sCCD_R : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 X_Cont : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 Y_Cont : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dp_ram_128x128
	PORT(wren : IN STD_LOGIC;
		 wrclock : IN STD_LOGIC;
		 rdclock : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 rdaddress : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		 wraddress : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT gensync
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 HSYNC : OUT STD_LOGIC;
		 VSYNC : OUT STD_LOGIC;
		 IMG : OUT STD_LOGIC;
		 IMGY_out : OUT STD_LOGIC;
		 X : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 Y : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
END COMPONENT;

COMPONENT blanker_v1
	PORT(IMG : IN STD_LOGIC;
		 b : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 g : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 r : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 b_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 g_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 r_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT altpll0
	PORT(inclk0 : IN STD_LOGIC;
		 c0 : OUT STD_LOGIC;
		 locked : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	mem_ad :  STD_LOGIC_VECTOR(14 DOWNTO 0);
SIGNAL	memw_ad :  STD_LOGIC_VECTOR(14 DOWNTO 0);
SIGNAL	sCCD_VAL :  STD_LOGIC;
SIGNAL	VGA_G_i :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	wadd :  STD_LOGIC_VECTOR(14 DOWNTO 0);
SIGNAL	x :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	X_Cont :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	y :  STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL	Y_Cont :  STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_30 :  STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL	b,r,b_out,r_out :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	IMGY_out :  STD_LOGIC;


BEGIN 
--GPIO_0(11) <= SYNTHESIZED_WIRE_29(11);
--GPIO_0(10) <= SYNTHESIZED_WIRE_29(10);
--GPIO_0(9) <= SYNTHESIZED_WIRE_29(9);
--GPIO_0(8) <= SYNTHESIZED_WIRE_29(8);
--GPIO_0(7) <= SYNTHESIZED_WIRE_29(7);
--GPIO_0(6) <= SYNTHESIZED_WIRE_29(6);
--GPIO_0(5) <= SYNTHESIZED_WIRE_29(5);
--GPIO_0(4) <= SYNTHESIZED_WIRE_29(4);
--GPIO_0(3) <= SYNTHESIZED_WIRE_29(3);
--GPIO_0(2) <= SYNTHESIZED_WIRE_29(2);
--GPIO_0(1) <= SYNTHESIZED_WIRE_29(1);
--GPIO_0(0) <= SYNTHESIZED_WIRE_29(0);
--GPIO_0(27) <= SYNTHESIZED_WIRE_30(10);
--GPIO_0(26) <= SYNTHESIZED_WIRE_30(9);
--GPIO_0(25) <= SYNTHESIZED_WIRE_30(8);
--GPIO_0(24) <= SYNTHESIZED_WIRE_30(7);
--GPIO_0(23) <= SYNTHESIZED_WIRE_30(6);
--GPIO_0(22) <= SYNTHESIZED_WIRE_30(5);
--GPIO_0(21) <= SYNTHESIZED_WIRE_30(4);
--GPIO_0(20) <= SYNTHESIZED_WIRE_30(3);
--GPIO_0(19) <= SYNTHESIZED_WIRE_30(2);
--GPIO_0(18) <= SYNTHESIZED_WIRE_30(1);
--GPIO_0(17) <= SYNTHESIZED_WIRE_30(0);



b2v_inst : de1_d5m_ip
PORT MAP(CLOCK_50 => CLOCK_50,
		 CCD_FVAL => CCD_FVAL,
		 CCD_LVAL => CCD_LVAL,
		 CCD_PIXCLK => CCD_PIXCLK,
		 CCD_DATA => CCD_DATA,
		 KEY => KEY,
		 SW => SW,
		 CCD_MCLK => CCD_MCCLK,
		 TRIGGER => TRIGGER,
		 RESETn => RESETn,
		 I2C_SCLK => I2C_SCLK,
		 I2C_SDAT => I2C_SDAT,
		 sCCD_DVAL => sCCD_VAL,
		 owrite_DPRAM => SYNTHESIZED_WIRE_27,
		 LEDG => LEDG,
		 sCCD_G => VGA_G_i,
		 X_Cont => X_Cont,
		 Y_Cont => Y_Cont);


b2v_inst1 : dp_ram_128x128
PORT MAP(wren => SYNTHESIZED_WIRE_27,
		 wrclock => CCD_PIXCLK,
		 rdclock => SYNTHESIZED_WIRE_28,
		 data => VGA_G_i(11 DOWNTO 8),
		 rdaddress => mem_ad,
		 wraddress => memw_ad,
		 q => SYNTHESIZED_WIRE_4);

memw_ad(7 DOWNTO 0) <= X_Cont(10 DOWNTO 3);


memw_ad(14 DOWNTO 8) <= Y_Cont(9 DOWNTO 3);


mem_ad(7 DOWNTO 0) <= x(9 DOWNTO 2);


mem_ad(14 DOWNTO 8) <= y(8 DOWNTO 2);



b2v_inst2 : gensync
PORT MAP(CLK => SYNTHESIZED_WIRE_28,
		 reset => KEY(0),
		 HSYNC => VGA_HS,
		 VSYNC => VGA_VS,
		 IMG => SYNTHESIZED_WIRE_3,
		 IMGY_out => IMGY_out,
		 X => x,
		 Y => y);


b2v_inst3 : blanker_v1
PORT MAP(IMG => SYNTHESIZED_WIRE_3,
		 b => b,
		 g => SYNTHESIZED_WIRE_4,
		 r => r,
		 b_out => b_out, 
		 g_out => VGA_G,
		  r_out => r_out);

--PORT(IMG : IN STD_LOGIC;
--		 b : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--		 g : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--		 r : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--		 b_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
--		 g_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
--		 r_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		 
--GPIO_0(16) <= sCCD_VAL;


SYNTHESIZED_WIRE_29 <= X_Cont;


VGA_G_i(3 DOWNTO 0) <= VGA_G_i(3 DOWNTO 0);


SYNTHESIZED_WIRE_30 <= Y_Cont;


--GPIO_0(28) <= SYNTHESIZED_WIRE_27;



b2v_inst9 : altpll0
PORT MAP(inclk0 => CLOCK_50,
		 c0 => SYNTHESIZED_WIRE_28);


END bdf_type;