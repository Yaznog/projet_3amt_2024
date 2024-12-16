library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity image_process is

	port 
	(
		IMG : 				IN 	STD_LOGIC;
		reset : 				IN 	STD_LOGIC;
		control : 			IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
		CLK_1 :				IN		STD_LOGIC;
		VGA_HS : 			IN 	STD_LOGIC;
		VGA_VS : 			IN 	STD_LOGIC;
		VGA_CLK : 			IN 	STD_LOGIC;
		X_Cont : 			IN 	STD_LOGIC_VECTOR(8 DOWNTO 0);
		Y_Cont : 			IN 	STD_LOGIC_VECTOR(8 DOWNTO 0);  -- image 512 x 512
		r : 					IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		g : 					IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		b : 					IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		r_out : 				OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		g_out	: 				OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		b_out	: 				OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		newImage_out :		OUT	STD_LOGIC
	);

end entity;

architecture rtl of image_process is
type 		gen_states is (S0,S1);

TYPE 		t_3d_array is array (0 to 9, 0 to 8) of STD_LOGIC_VECTOR(0 TO 6);

SIGNAL	numberArray : t_3d_array;

subtype 	digit_type is integer range 0 to 9;
type 		digits_type_2 is array (1 downto 0) of digit_type;
type 		digits_type_3 is array (2 downto 0) of digit_type;
signal 	digit : 						digit_type;
signal 	digit_ips : 				digits_type_2;
signal 	digit_avop : 				digits_type_3;

signal 	t : 							INTEGER ;
signal   ri,gi,bi,nri,ngi,nbi : 	STD_LOGIC_VECTOR(7 downto 0);
signal   state,next_state : 		gen_states;

SIGNAL	imageGreenOnly :			STD_LOGIC := control(0);
SIGNAL	gameOverlay :				STD_LOGIC := control(1);

SIGNAL 	screenZone_X_min : 		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   screenZone_X_max : 		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   screenZone_Y_min : 		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   screenZone_Y_max : 		STD_LOGIC_VECTOR(8 downto 0);

SIGNAL 	gameZone_X_min : 			STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   gameZone_X_max : 			STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   gameZone_Y_min : 			STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   gameZone_Y_max : 			STD_LOGIC_VECTOR(8 downto 0);

SIGNAL   dinoZone_X_min : 			STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   dinoZone_X_max : 			STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   dinoZone_Y_min : 			STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   dinoZone_Y_max : 			STD_LOGIC_VECTOR(8 downto 0);

SIGNAL   detectionZone_X_min : 	STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   detectionZone_X_max : 	STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   detectionZone_Y_min : 	STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   detectionZone_Y_max : 	STD_LOGIC_VECTOR(8 downto 0);

SIGNAL   scoreZone_X_min : 		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   scoreZone_X_max : 		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   scoreZone_Y_min : 		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL   scoreZone_Y_max : 		STD_LOGIC_VECTOR(8 downto 0);

SIGNAL 	ips_X_min : 				STD_LOGIC_VECTOR(8 downto 0);
SIGNAL 	ips_Y_min : 				STD_LOGIC_VECTOR(8 downto 0);

SIGNAL 	avop_X_min : 				STD_LOGIC_VECTOR(8 downto 0);
SIGNAL 	avop_Y_min : 				STD_LOGIC_VECTOR(8 downto 0);

SIGNAL 	valueOfPixels :			INTEGER range 0 to 7200 := 0; -- 120 * 60
SIGNAL	averageValueOfPixels :	INTEGER range 0 to 256 := 0;
SIGNAL	frame_counter :			INTEGER range 0 to 100 := 0;
SIGNAL	imagePerSecond :			INTEGER range 0 to 100 := 0;
SIGNAL	newImage_s :				STD_LOGIC := '0';
SIGNAL	newImagePrevious_s :		STD_LOGIC := '0';

	--SIGNAL	temp_integer_Y_ips :		INTEGER range 0 to 512 := 0;
	--SIGNAL	temp_integer_X_ips :		INTEGER range 0 to 512 := 0;
	--SIGNAL	temp_integer_Y_avop :	INTEGER range 0 to 512 := 0;
	--SIGNAL	temp_integer_X_avop :	INTEGER range 0 to 512 := 0;

SIGNAL	numberArrayHeight :		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL	numberArrayWidth :		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL	numberArrayWidth_2 :		STD_LOGIC_VECTOR(8 downto 0);
SIGNAL	numberArrayWidth_3 :		STD_LOGIC_VECTOR(8 downto 0);


begin -- 512*512

numberArray(0,0) <= "0000000";
numberArray(0,1) <= "0011100";
numberArray(0,2) <= "0100010";
numberArray(0,3) <= "0100010";
numberArray(0,4) <= "0100010";
numberArray(0,5) <= "0100010";
numberArray(0,6) <= "0100010";
numberArray(0,7) <= "0011100";
numberArray(0,8) <= "0000000";

numberArray(1,0) <= "0000000";
numberArray(1,1) <= "0001100";
numberArray(1,2) <= "0010100";
numberArray(1,3) <= "0100100";
numberArray(1,4) <= "0000100";
numberArray(1,5) <= "0000100";
numberArray(1,6) <= "0000100";
numberArray(1,7) <= "0011110";
numberArray(1,8) <= "0000000";

numberArray(2,0) <= "0000000";
numberArray(2,1) <= "0011100";
numberArray(2,2) <= "0100010";
numberArray(2,3) <= "0100010";
numberArray(2,4) <= "0000100";
numberArray(2,5) <= "0001000";
numberArray(2,6) <= "0010000";
numberArray(2,7) <= "0111110";
numberArray(2,8) <= "0000000";

numberArray(3,0) <= "0000000";
numberArray(3,1) <= "0011100";
numberArray(3,2) <= "0100010";
numberArray(3,3) <= "0000010";
numberArray(3,4) <= "0011100";
numberArray(3,5) <= "0000010";
numberArray(3,6) <= "0100010";
numberArray(3,7) <= "0011100";
numberArray(3,8) <= "0000000";

numberArray(4,0) <= "0000000";
numberArray(4,1) <= "0001100";
numberArray(4,2) <= "0010100";
numberArray(4,3) <= "0100100";
numberArray(4,4) <= "0111110";
numberArray(4,5) <= "0000100";
numberArray(4,6) <= "0000100";
numberArray(4,7) <= "0000100";
numberArray(4,8) <= "0000000";

numberArray(5,0) <= "0000000";
numberArray(5,1) <= "0111110";
numberArray(5,2) <= "0100000";
numberArray(5,3) <= "0100000";
numberArray(5,4) <= "0111100";
numberArray(5,5) <= "0000010";
numberArray(5,6) <= "0000010";
numberArray(5,7) <= "0111100";
numberArray(5,8) <= "0000000";

numberArray(6,0) <= "0000000";
numberArray(6,1) <= "0011100";
numberArray(6,2) <= "0100000";
numberArray(6,3) <= "0100000";
numberArray(6,4) <= "0011100";
numberArray(6,5) <= "0100010";
numberArray(6,6) <= "0100010";
numberArray(6,7) <= "0011100";
numberArray(6,8) <= "0000000";

numberArray(7,0) <= "0000000";
numberArray(7,1) <= "0111110";
numberArray(7,2) <= "0000010";
numberArray(7,3) <= "0000010";
numberArray(7,4) <= "0000100";
numberArray(7,5) <= "0001000";
numberArray(7,6) <= "0010000";
numberArray(7,7) <= "0100000";
numberArray(7,8) <= "0000000";

numberArray(8,0) <= "0000000";
numberArray(8,1) <= "0011100";
numberArray(8,2) <= "0100010";
numberArray(8,3) <= "0100010";
numberArray(8,4) <= "0011100";
numberArray(8,5) <= "0100010";
numberArray(8,6) <= "0100010";
numberArray(8,7) <= "0011100";
numberArray(8,8) <= "0000000";

numberArray(9,0) <= "0000000";
numberArray(9,1) <= "0011100";
numberArray(9,2) <= "0100010";
numberArray(9,3) <= "0100010";
numberArray(9,4) <= "0011110";
numberArray(9,5) <= "0000010";
numberArray(9,6) <= "0000010";
numberArray(9,7) <= "0011100";
numberArray(9,8) <= "0000000";



screenZone_X_min 		<= std_logic_vector(to_unsigned(10, 	9));
screenZone_X_max 		<= std_logic_vector(to_unsigned(510, 	9));
screenZone_Y_min 		<= std_logic_vector(to_unsigned(0, 		9));
screenZone_Y_max 		<= std_logic_vector(to_unsigned(468, 	9));

gameZone_X_min 		<= std_logic_vector(to_unsigned(30, 	9));
gameZone_X_max 		<= std_logic_vector(to_unsigned(481, 	9));
gameZone_Y_min 		<= std_logic_vector(to_unsigned(100, 	9));
gameZone_Y_max 		<= std_logic_vector(to_unsigned(225, 	9)); -- 125

dinoZone_X_min 		<= std_logic_vector(to_unsigned(45, 	9));
dinoZone_X_max 		<= std_logic_vector(to_unsigned(105, 	9)); -- 60
dinoZone_Y_min 		<= std_logic_vector(to_unsigned(150, 	9));
dinoZone_Y_max 		<= std_logic_vector(to_unsigned(210, 	9)); -- 60

detectionZone_X_min 	<= std_logic_vector(to_unsigned(170, 	9));
detectionZone_X_max 	<= std_logic_vector(to_unsigned(290, 	9)); -- 120
detectionZone_Y_min 	<= std_logic_vector(to_unsigned(150, 	9));
detectionZone_Y_max 	<= std_logic_vector(to_unsigned(210, 	9)); -- 60

scoreZone_X_min 		<= std_logic_vector(to_unsigned(370, 	9));
scoreZone_X_max 		<= std_logic_vector(to_unsigned(470, 	9)); -- 100
scoreZone_Y_min 		<= std_logic_vector(to_unsigned(110, 	9));
scoreZone_Y_max 		<= std_logic_vector(to_unsigned(135, 	9)); -- 25

ips_X_min 				<= std_logic_vector(to_unsigned(30, 	9));
ips_Y_min 				<= std_logic_vector(to_unsigned(20, 	9));

avop_X_min 				<= std_logic_vector(to_unsigned(30, 	9));
avop_Y_min 				<= std_logic_vector(to_unsigned(30, 	9));

numberArrayHeight 	<= std_logic_vector(to_unsigned(9, 		9));
numberArrayWidth 		<= std_logic_vector(to_unsigned(7, 		9));
numberArrayWidth_2 	<= std_logic_vector(to_unsigned(14, 	9));
numberArrayWidth_3 	<= std_logic_vector(to_unsigned(21, 	9));


-----------------------
-- Send image by VGA --
-----------------------
clk:process(VGA_CLK)
begin 
	if (VGA_CLK'event and VGA_CLK ='1') then	
		if (reset='0') then
			ri <= x"00"; gi <= x"00"; bi <= x"00";
			state <= S0;

			else
				ri <= r;	gi <= g; bi <= b;

			for t in 0 to 7 loop		 
				r_out(t) <= (nri(t) and IMG);
				g_out(t) <= (ngi(t) and IMG);
				b_out(t) <= (nbi(t) and IMG);
			end loop;

			state <= next_state; 
		end if;
	end if;
end process clk;	
	   
		

---------------------------------------------------------------
-- Gets the cumulative value of pixels in the detection zone --
---------------------------------------------------------------
average:process(X_Cont, Y_Cont)
begin
	
	--valueOfPixels <= valueOfPixels;

	if ( 	X_Cont >= detectionZone_X_min and X_Cont <= detectionZone_X_max and 
			Y_Cont >= detectionZone_Y_min and Y_Cont <= detectionZone_Y_max  ) then
			
		if (X_Cont = detectionZone_X_max and Y_Cont = detectionZone_Y_max) then	
			averageValueOfPixels <= to_integer(unsigned(std_logic_vector(to_unsigned(valueOfPixels, 13))(12 DOWNTO 5)));
			valueOfPixels <= 0;
		
		elsif (gi(7) = '1') then 
				valueOfPixels <= valueOfPixels + 1; --to_integer(unsigned(gi));			
		end if;
	end if;
		
end process average;		


------------------------------------------------------
-- Process the number of image displayed per second --
------------------------------------------------------
ips:process(CLK_1, newImage_s)
begin
	--reset='0' or 
--	if (rising_edge(CLK_1)) then
--		frame_counter <= 0;
--	els
	if (newImagePrevious_s = '0' and newImage_s = '1') then
		frame_counter <= frame_counter + 1;
		imagePerSecond <= frame_counter;
	end if;
		
end process ips;	


-----------------------------------------
-- Detect the beginning of a new image --
-----------------------------------------
imageBegin:process(X_Cont, Y_Cont)
begin
	newImage_s <= newImage_s;
	newImagePrevious_s <= newImage_s;
	if(X_Cont = std_logic_vector(to_unsigned(0, 9)) and Y_Cont = std_logic_vector(to_unsigned(0, 9))) then
		newImage_s <= '1';
	else
		newImage_s <= '0';
	end if;
	newImage_out <= newImage_s;
		
end process imageBegin;		
		
		
--------------------------------------------
-- Add the overlay on the displayed image --
--------------------------------------------
gen:process(gi, X_Cont, Y_Cont, IMG, state, imageGreenOnly, gameOverlay)
begin
	nri <= gi; ngi <= gi; nbi <= gi;
	
	if (imageGreenOnly = '1') then
		nri <= x"00"; ngi <= gi; nbi <= x"00";
	end if;
			
	
		-- Add overlay
	if (gameOverlay='1') then
			
			
		-- Screen zone orange
			-- Horizontal upper side
		if (Y_Cont = screenZone_Y_min and X_Cont >= screenZone_X_min and X_Cont <= screenZone_X_max) then
			nri <= x"FF"; ngi <= x"FF"; nbi <= x"00"; 	
		end if;
		
			-- Horizontal lower side
		if (Y_Cont = screenZone_Y_max and X_Cont >= screenZone_X_min and X_Cont <= screenZone_X_max) then
			nri <= x"FF"; ngi <= x"FF"; nbi <= x"00"; 	
		end if;
		
			-- Vertical left side
		if (X_Cont = screenZone_X_min and Y_Cont >= screenZone_Y_min and Y_Cont <= screenZone_Y_max) then
			nri <= x"FF"; ngi <= x"FF"; nbi <= x"00"; 	
		end if;
		
			-- Vertical right side
		if (X_Cont = screenZone_X_max and Y_Cont >= screenZone_Y_min and Y_Cont <= screenZone_Y_max) then
			nri <= x"FF"; ngi <= x"FF"; nbi <= x"00"; 	
		end if;
		
		
		-- Game zone red
			-- Horizontal upper side
		if (Y_Cont = gameZone_Y_min and X_Cont >= gameZone_X_min and X_Cont <= gameZone_X_max) then
			nri <= x"FF"; ngi <= x"00"; nbi <= x"00"; 	
		end if;
		
			-- Horizontal lower side
		if (Y_Cont = gameZone_Y_max and X_Cont >= gameZone_X_min and X_Cont <= gameZone_X_max) then
			nri <= x"FF"; ngi <= x"00"; nbi <= x"00"; 	
		end if;
		
			-- Vertical left side
		if (X_Cont = gameZone_X_min and Y_Cont >= gameZone_Y_min and Y_Cont <= gameZone_Y_max) then
			nri <= x"FF"; ngi <= x"00"; nbi <= x"00"; 	
		end if;
		
			-- Vertical right side
		if (X_Cont = gameZone_X_max and Y_Cont >= gameZone_Y_min and Y_Cont <= gameZone_Y_max) then
			nri <= x"FF"; ngi <= x"00"; nbi <= x"00"; 	
		end if;
		
		
		
		-- Dino zone green
			-- Horizontal upper side
		if (Y_Cont = dinoZone_Y_min and X_Cont >= dinoZone_X_min and X_Cont <= dinoZone_X_max) then
			nri <= x"00"; ngi <= x"FF"; nbi <= x"00"; 	
		end if;
		
			-- Horizontal lower side
		if (Y_Cont = dinoZone_Y_max and X_Cont >= dinoZone_X_min and X_Cont <= dinoZone_X_max) then
			nri <= x"00"; ngi <= x"FF"; nbi <= x"00"; 	
		end if;
		
			-- Vertical left side
		if (X_Cont = dinoZone_X_min and Y_Cont >= dinoZone_Y_min and Y_Cont <= dinoZone_Y_max) then
			nri <= x"00"; ngi <= x"FF"; nbi <= x"00"; 	
		end if;
		
			-- Vertical right side
		if (X_Cont = dinoZone_X_max and Y_Cont >= dinoZone_Y_min and Y_Cont <= dinoZone_Y_max) then
			nri <= x"00"; ngi <= x"FF"; nbi <= x"00"; 	
		end if;
		
		
		
		-- Detection zone blue
			-- Horizontal upper side
		if (Y_Cont = detectionZone_Y_min and X_Cont >= detectionZone_X_min and X_Cont <= detectionZone_X_max) then
			nri <= x"00"; ngi <= x"00"; nbi <= x"FF"; 	
		end if;
		
			-- Horizontal lower side
		if (Y_Cont = detectionZone_Y_max and X_Cont >= detectionZone_X_min and X_Cont <= detectionZone_X_max) then
			nri <= x"00"; ngi <= x"00"; nbi <= x"FF"; 	
		end if;
		
			-- Vertical left side
		if (X_Cont = detectionZone_X_min and Y_Cont >= detectionZone_Y_min and Y_Cont <= detectionZone_Y_max) then
			nri <= x"00"; ngi <= x"00"; nbi <= x"FF"; 	
		end if;
		
			-- Vertical right side
		if (X_Cont = detectionZone_X_max and Y_Cont >= detectionZone_Y_min and Y_Cont <= detectionZone_Y_max) then
			nri <= x"00"; ngi <= x"00"; nbi <= x"FF"; 	
		end if;
		
		
		
		-- Score zone pink
			-- Horizontal upper side
		if (Y_Cont = scoreZone_Y_min and X_Cont >= scoreZone_X_min and X_Cont <= scoreZone_X_max) then
			nri <= x"FF"; ngi <= x"00"; nbi <= x"FF"; 	
		end if;
		
			-- Horizontal lower side
		if (Y_Cont = scoreZone_Y_max and X_Cont >= scoreZone_X_min and X_Cont <= scoreZone_X_max) then
			nri <= x"FF"; ngi <= x"00"; nbi <= x"FF"; 	
		end if;
		
			-- Vertical left side
		if (X_Cont = scoreZone_X_min and Y_Cont >= scoreZone_Y_min and Y_Cont <= scoreZone_Y_max) then
			nri <= x"FF"; ngi <= x"00"; nbi <= x"FF"; 	
		end if;
		
			-- Vertical right side
		if (X_Cont = scoreZone_X_max and Y_Cont >= scoreZone_Y_min and Y_Cont <= scoreZone_Y_max) then
			nri <= x"FF"; ngi <= x"00"; nbi <= x"FF"; 	
		end if;
		
		
		
		
		-- Frame per second		
		
		--imagePerSecond <= 75;
		
--		digit_ips(1) <= imagePerSecond / 10;
--		digit_ips(0) <= imagePerSecond - ((imagePerSecond / 10) * 10);

		digit_ips(1) <= 1;
		digit_ips(0) <= 2;
--		
--		digit_avop(2) <= averageValueOfPixels / 10;
--		digit_avop(1) <= averageValueOfPixels - ((averageValueOfPixels / 10) * 10);
--		digit_avop(0) <= averageValueOfPixels - ((averageValueOfPixels / 100) * 100);
		
		digit_avop(2) <= 3;
		digit_avop(1) <= 4;
		digit_avop(0) <= 5;
				
--		
--		temp_integer_Y_ips <= to_integer(unsigned(Y_cont)) - to_integer(unsigned(ips_Y_min));
--		temp_integer_X_ips <= to_integer(unsigned(X_cont)) - to_integer(unsigned(ips_X_min));	

		
		-- If in digit(1) of IPS zone
		if (	X_Cont >= ips_X_min and 								Y_Cont >= ips_Y_min and 
				X_Cont < ips_X_min + numberArrayWidth and			Y_Cont < ips_Y_min + numberArrayHeight) then
			--if (numberArray(digit_ips(1), temp_integer_Y_ips) (temp_integer_X_ips) = '0') then nri <= x"00"; ngi <= x"00"; nbi <= x"00";
			if (numberArray(digit_ips(1), to_integer(unsigned(Y_cont)) - to_integer(unsigned(ips_Y_min))) 
				(to_integer(unsigned(X_cont)) - to_integer(unsigned(avop_X_min)) - to_integer(unsigned(numberArrayWidth))) = '0') then 
					nri <= x"00"; ngi <= x"00"; nbi <= x"00";
			else 	nri <= x"00"; ngi <= x"FF"; nbi <= x"00";
			end if;
		
		-- If in digit(0) of IPS zone	
		elsif (	X_Cont >= ips_X_min + numberArrayWidth and 	Y_Cont >= ips_Y_min and 
					X_Cont < ips_X_min + numberArrayWidth_2 and 	Y_Cont < ips_Y_min + numberArrayHeight) then
			--if (numberArray(digit_ips(0), temp_integer_Y_ips) (temp_integer_X_ips) = '0') then nri <= x"00"; ngi <= x"00"; nbi <= x"00";
			if (numberArray(digit_ips(0), to_integer(unsigned(Y_cont)) - to_integer(unsigned(ips_Y_min))) 
				(to_integer(unsigned(X_cont)) - to_integer(unsigned(ips_X_min)) - to_integer(unsigned(numberArrayWidth))) = '0') then 
					nri <= x"00"; ngi <= x"00"; nbi <= x"00";
			else 	nri <= x"00"; ngi <= x"FF"; nbi <= x"00";
			end if;

			
			
		
		-- If in digit(2) of AVOP zone
		elsif (	X_Cont >= avop_X_min and 								Y_Cont >= avop_Y_min and 
					X_Cont < avop_X_min + numberArrayWidth  and		Y_Cont < avop_Y_min + numberArrayHeight) then
			if (numberArray(digit_avop(2), to_integer(unsigned(Y_cont)) - to_integer(unsigned(avop_Y_min))) 
				(to_integer(unsigned(X_cont)) - to_integer(unsigned(avop_X_min))) = '0') then 
					nri <= x"00"; ngi <= x"00"; nbi <= x"00";
			else 	nri <= x"00"; ngi <= x"FF"; nbi <= x"00";
			end if;
		
		
		-- If in digit(1) of AVOP zone
		elsif (	X_Cont >= avop_X_min + numberArrayWidth and 		Y_Cont >= avop_Y_min and 
					X_Cont < avop_X_min + numberArrayWidth_2 and 	Y_Cont < avop_Y_min + numberArrayHeight) then
			if (numberArray(digit_avop(1), to_integer(unsigned(Y_cont)) - to_integer(unsigned(avop_Y_min))) 
				(to_integer(unsigned(X_cont)) - to_integer(unsigned(avop_X_min)) - to_integer(unsigned(numberArrayWidth))) = '0') then 
					nri <= x"00"; ngi <= x"00"; nbi <= x"00";
			else 	nri <= x"00"; ngi <= x"FF"; nbi <= x"00";
			end if;
			
		-- If in digit(0) of AVOP zone
		elsif (	X_Cont >= avop_X_min + numberArrayWidth_2 and 	Y_Cont >= avop_Y_min and 
					X_Cont < avop_X_min + numberArrayWidth_3 and 	Y_Cont < avop_Y_min + numberArrayHeight) then
			if (numberArray(digit_avop(0), to_integer(unsigned(Y_cont)) - to_integer(unsigned(avop_Y_min))) 
				(to_integer(unsigned(X_cont)) - to_integer(unsigned(avop_X_min)) - to_integer(unsigned(numberArrayWidth_2))) = '0') then 
					nri <= x"00"; ngi <= x"00"; nbi <= x"00";
			else 	nri <= x"00"; ngi <= x"FF"; nbi <= x"00";
			end if;
		end if;
					
		
		
		
	end if;

end process gen;
		
end rtl;
