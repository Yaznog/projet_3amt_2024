library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CLOCK_DIVIDER is
    Port ( CLK_50M: 		IN std_logic;
           reset: 		IN std_logic;
			  CLK_100: 		OUT std_logic;
			  CLK_38_4K: 	OUT std_logic;
			  CLK_1: 		OUT std_logic
     );
end CLOCK_DIVIDER;


architecture Behavioral of CLOCK_DIVIDER is
--signal counter_10: 		integer range 0 to 2500000 := 0;
signal counter_38_4K: 	integer range 0 to 651 		:= 0;
signal counter_100: 		integer range 0 to 250000 	:= 0;
signal counter_1: 		integer range 0 to 25000000 	:= 0;

--signal CLK_10_s: 			std_logic := '0';
signal CLK_38_4K_s: 		std_logic := '0';
signal CLK_100_s: 		std_logic := '0';
signal CLK_1_s: 			std_logic := '0';

begin

process(CLK_50M)
begin

	if(rising_edge(CLK_50M)) then
		if(reset='1') then
--			counter_10 			<= 0;
			counter_38_4K 		<= 0;
			counter_100 		<= 0;
			counter_1 			<= 0;
		else
--			counter_10 			<= counter_10 		+ 1;
			counter_38_4K 		<= counter_38_4K 	+ 1;
			counter_100 		<= counter_100 	+ 1;
			counter_1 			<= counter_1 		+ 1;
			
--			if (counter_10 = 2500000) then
--				CLK_10_s 		<= not CLK_10_s;
--				counter_10 		<= 0;
--			end if;
			
			if (counter_38_4K = 651) then
				CLK_38_4K_s 	<= not CLK_38_4K_s;
				counter_38_4K 	<= 0;
			end if;
			
			if (counter_100 = 250000) then
				CLK_100_s 		<= not CLK_100_s;
				counter_100 	<= 0;
			end if;
			
			if (counter_1 = 25000000) then
				CLK_1_s 			<= not CLK_1_s;
				counter_1 		<= 0;
			end if;
			
		end if;
	end if;
	
end process;

CLK_100 		<= CLK_100_s;
CLK_38_4K 	<= CLK_38_4K_s;
CLK_1 		<= CLK_1_s;

end Behavioral;