
LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

LIBRARY work;

ENTITY TOP_D5M_IP IS 
	PORT
	(
	
		CLOCK_50 :  IN  STD_LOGIC;
		Ext_Clock : IN  STD_LOGIC;
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
		LEDG :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_B :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_G :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_R :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_CLK : OUT STD_LOGIC;
		VGA_BLANK_N : OUT STD_LOGIC;
		VGA_SYNC_N : OUT STD_LOGIC;
		VGA_HS_OBS : OUT STD_LOGIC;
		VGA_VS_OBS : OUT STD_LOGIC;
		VGA_BLANK_N_OBS : OUT STD_LOGIC;
		VGA_G7_OBS : OUT STD_LOGIC;
		tempo_flag : OUT  STD_LOGIC;
		servo1 : OUT  STD_LOGIC;
		servo2 : OUT  STD_LOGIC
	);
END TOP_D5M_IP;

ARCHITECTURE bdf_type OF TOP_D5M_IP IS 

attribute chip_pin          		: string;

--Carte DE1-SOC
attribute chip_pin of CLOCK_50  : signal is "AF14";

attribute chip_pin of VGA_HS  : signal is "B11"; --
attribute chip_pin of VGA_VS  : signal is "D11"; --

attribute chip_pin of VGA_CLK  : signal is "A11";
attribute chip_pin of VGA_BLANK_N  : signal is "F10";
attribute chip_pin of VGA_SYNC_N  : signal is "C10";		
		
--
attribute chip_pin of VGA_G  : signal is "E11,F11,G12,G11,G10,H12,J10,J9";
attribute chip_pin of VGA_R  : signal is "F13,E12,D12,C12,B12,E13,C13,A13";
attribute chip_pin of VGA_B  : signal is "J14,G15,F15,H14,F14,H13,G13,B13";
--
--attribute chip_pin of LEDR  : signal is "G19,F19,E19,F21,F15,G15,G16,H16";
attribute chip_pin of LEDG  : signal is "W20,Y19,W19,W17,V18,V17,W16,V16";
attribute chip_pin of KEY  : signal is "Y16,W15,AA15,AA14";
attribute chip_pin of SW  : signal is "AE12,AD10,AC9,AE11,AD12,AD11,AF10,AF9,AC12,AB12";

---- Camera GPIO_1 Camera D5M
attribute chip_pin of CCD_FVAL :  signal is "AK24";
attribute chip_pin of CCD_LVAL :   signal is "AJ24";
attribute chip_pin of CCD_PIXCLK :   signal is "AB17";
attribute chip_pin of I2C_SCLK :   signal is "AK23";
attribute chip_pin of I2C_SDAT :   signal is "AG23";
attribute chip_pin of CCD_MCCLK  : signal is "AK27";
attribute chip_pin of CCD_DATA  : signal is "AA21,AC23,AD24,AE23,AE24,AF25,AF26,AG25,AG26,AH24,AH27,AJ27";
attribute chip_pin of TRIGGER  : signal is "AH25";
attribute chip_pin of RESETn  : signal is "AJ26";
--
--
---- Servo Connecteurs GPIO_0 
attribute chip_pin of servo1  : signal is "AK16";
attribute chip_pin of servo2  : signal is "AK18";

attribute chip_pin of Ext_Clock  : signal is "AG18";
attribute chip_pin of tempo_flag  : signal is "AG21";

-- Controle timing VGA_B GPIO_0 (en haut gauche droite)
attribute chip_pin of VGA_HS_OBS  : signal is "AC18";      -- GPIO_0(0)
attribute chip_pin of VGA_VS_OBS  : signal is "Y17";        -- GPIO_0(1)
attribute chip_pin of VGA_BLANK_N_OBS  : signal is "AD17";  -- GPIO_0(2)
attribute chip_pin of VGA_G7_OBS  : signal is "Y18";  -- GPIO_0(3)

COMPONENT d5m_ip
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

COMPONENT dpram_512x512
	PORT(wren : IN STD_LOGIC;
		 wrclock : IN STD_LOGIC;
		 rdclock : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 rdaddress : IN STD_LOGIC_VECTOR(16 DOWNTO 0);  IMAGE  340 x 192 4/3
--		 wraddress : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
--		 rdaddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- IMAGE 256 x 256
--		 wraddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rdaddress : IN STD_LOGIC_VECTOR(17 DOWNTO 0); -- IMAGE 512 x 512
		 wraddress : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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

COMPONENT image_process
		PORT(IMG	   : in std_logic;
		reset    : in std_logic;
		SW1     : in std_logic;
		VGA_HS	   : in std_logic;
		VGA_VS	   : in std_logic;
		VGA_CLK	   : in std_logic;
		X_Cont   : in std_logic_vector(8 downto 0);
		Y_Cont   : in std_logic_vector(8 downto 0);  -- image 512 x 512
		r	   : in std_logic_vector(7 downto 0);
		g	   : in std_logic_vector(7 downto 0);
		b	   : in std_logic_vector(7 downto 0);
		r_out	: out std_logic_vector(7 downto 0);
		g_out	: out std_logic_vector(7 downto 0);
		b_out	: out std_logic_vector(7 downto 0)
		);
END COMPONENT;
		
COMPONENT altpll0
	PORT(inclk0 : IN STD_LOGIC;
		 c0 : OUT STD_LOGIC;
		 locked : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT pwm_cycle
	PORT(Rst : IN STD_LOGIC;
		 Clk : IN STD_LOGIC;
		 CLOCK_50 : IN STD_LOGIC;
		 pwm_high : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 tempo_flag : OUT STD_LOGIC;
		 PWMout : OUT STD_LOGIC
	);
END COMPONENT;

--SIGNAL	mem_ad :  STD_LOGIC_VECTOR(16 DOWNTO 0);  -- 256 x 256 4/3
--SIGNAL	memw_ad :  STD_LOGIC_VECTOR(16 DOWNTO 0);
--SIGNAL	mem_ad :  STD_LOGIC_VECTOR(15 DOWNTO 0);  -- 256 x 256 carre
--SIGNAL	memw_ad :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	memr_ad :  STD_LOGIC_VECTOR(17 DOWNTO 0);  -- 512 x 512 carre
SIGNAL	memw_ad :  STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL	sCCD_VAL :  STD_LOGIC;
SIGNAL	CCD_MCCLK_i :  STD_LOGIC;
SIGNAL	VGA_G_i,VGA_B_i,VGA_R_i :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	VGA_NB_i :  STD_LOGIC_VECTOR(13 DOWNTO 0);
SIGNAL	VGA_NB_i_uns :  unsigned(13 DOWNTO 0);
SIGNAL	wadd :  STD_LOGIC_VECTOR(16 DOWNTO 0);
SIGNAL	x_read :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	X_write :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	y_read :  STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL	Y_write :  STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL	rdclock :  STD_LOGIC;
SIGNAL	wren :  STD_LOGIC;
SIGNAL	IMG,CLK_25 :  STD_LOGIC;
SIGNAL	owrite_DPRAM :  STD_LOGIC;
SIGNAL	b,r,b_out,r_out,g,g_out,g_out_in :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	Noir_et_blanc_int :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	q :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	IMGY_out,VGA_CLK_i :  STD_LOGIC;
SIGNAL	VGA_H_int,VGA_V_int,PWM_out :  STD_LOGIC;
SIGNAL   R_level,G_level,B_level	: unsigned(7 DOWNTO 0);


BEGIN 

VGA_CLK <= CLK_25;
VGA_BLANK_N <=  IMG;
VGA_SYNC_N <= CLK_25;
VGA_HS <= VGA_H_int;
VGA_VS <= VGA_V_int;
VGA_HS_OBS <= VGA_H_int;
VGA_VS_OBS <= VGA_V_int;
VGA_BLANK_N_OBS <= IMG;
VGA_G7_OBS <= g_out_in(7);
g_out <= g_out_in;

--VGA_R <= Noir_et_blanc_int; -- passage par le blanker
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
PORT MAP(CLOCK_50 => CLOCK_50,
		 CCD_FVAL => CCD_FVAL,
		 CCD_LVAL => CCD_LVAL,
		 CCD_PIXCLK => CCD_PIXCLK,
		 CCD_DATA => CCD_DATA,
		 KEY => KEY,
		 SW => SW,
		 CCD_MCLK => CCD_MCCLK_i,
		 TRIGGER => TRIGGER,
		 RESETn => RESETn,
		 I2C_SCLK => I2C_SCLK,
		 I2C_SDAT => I2C_SDAT,
		 sCCD_DVAL => sCCD_VAL,
		 owrite_DPRAM => owrite_DPRAM,
		 LEDG => LEDG,
		 sCCD_R => VGA_R_i,
		 sCCD_G => VGA_G_i,
		 sCCD_B => VGA_B_i,
		 X_Cont => X_write,
		 Y_Cont => Y_write);


b2v_inst1 : dpram_512x512
PORT MAP(wren => wren,
	    wrclock => CCD_MCCLK_i,
		 rdclock => rdclock,
		 data => VGA_G_i(11 DOWNTO 4),  -- noir et blanc depuis G
		 rdaddress => memr_ad,
		 wraddress => memw_ad,
		 q => q);

-- Pour 512 x 512
memw_ad(8 DOWNTO 0) <= X_write(9 DOWNTO 1);
memw_ad(17 DOWNTO 9) <= Y_write(9 DOWNTO 1);  -- 8 bits

memr_ad(8 DOWNTO 0) <= x_read(8 DOWNTO 0);
memr_ad(17 DOWNTO 9) <= y_read(8 DOWNTO 0);
		 
-- Pour 256x256
--memw_ad(7 DOWNTO 0) <= X_write(9 DOWNTO 2);
--memw_ad(15 DOWNTO 8) <= Y_write(9 DOWNTO 2);  -- 8 bits
--
--mem_ad(7 DOWNTO 0) <= x_read(8 DOWNTO 1);
--mem_ad(15 DOWNTO 8) <= y_read(8 DOWNTO 1);
		 
-- Pour 256x256 4/3
--memw_ad(8 DOWNTO 0) <= X_write(10 DOWNTO 2);
--memw_ad(16 DOWNTO 9) <= Y_write(9 DOWNTO 2);
--
--mem_ad(8 DOWNTO 0) <= x_read(9 DOWNTO 1);
--mem_ad(16 DOWNTO 9) <= y_read(8 DOWNTO 1);


-- Pour 128x128 4/3
--memw_ad(7 DOWNTO 0) <= X_write(10 DOWNTO 3);
--memw_ad(14 DOWNTO 8) <= Y_write(9 DOWNTO 3);

--mem_ad(7 DOWNTO 0) <= x_read(9 DOWNTO 2);
--mem_ad(14 DOWNTO 8) <= y_read(8 DOWNTO 2);



servo1 <= PWM_out; 
servo2 <= not PWM_out; 

b2v_inst2 : gensync
PORT MAP(CLK => CLK_25,
		 reset => KEY(0),
		 HSYNC => VGA_H_int,
		 VSYNC => VGA_V_int,
		 IMG => IMG,
		 IMGY_out => IMGY_out,
		 X => x_read,
		 Y => y_read);


b2v_inst3 : image_process
PORT MAP(IMG	 => IMG,
		reset  => KEY(0),
		SW1   => SW(1),
		VGA_HS => VGA_H_int,
		VGA_VS => VGA_V_int,
		VGA_CLK	 => CLK_25,
		X_Cont   => memr_ad(8 DOWNTO 0), 
		Y_Cont   => memr_ad(17 DOWNTO 9),  -- image 512 x 512
		r	=> r,
		g	=> g,
		b  => b,
		r_out	=> r_out,
		g_out	=> g_out_in,
		b_out	=> b_out);

rdclock <= CLK_25;
CCD_MCCLK  <= CCD_MCCLK_i;
wren <= owrite_DPRAM;
g <= q;


b2v_inst9 : altpll0
PORT MAP(inclk0 => CLOCK_50,
		 c0 => CLK_25);

b2v_inst10 : pwm_cycle
PORT MAP(Rst => KEY(0),
		 Clk => Ext_Clock,
		 CLOCK_50 => CLOCK_50,
		 pwm_high => SW(7 downto 0),
		 tempo_flag => tempo_flag,
		 PWMout => PWM_out);


END bdf_type;