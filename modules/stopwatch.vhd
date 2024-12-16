library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Use ieee.numeric_std.all;

entity STOPWATCH is
    Port ( CLK_100: in std_logic;
           reset: in std_logic;
           counter: out std_logic_vector(41 downto 0)
     );
end STOPWATCH;


architecture Behavioral of STOPWATCH is
signal counter_mili: integer range 0 to 100 	:= 0;
signal counter_sec: 	integer range 0 to 60 	:= 0;
signal counter_min: 	integer range 0 to 100 	:= 0;
signal counter_s: 	std_logic_vector(41 downto 0);

subtype digit_type is integer range 0 to 9;
type digits_type is array (1 downto 0) of digit_type;
signal digit : 		digit_type;
signal digit_mili : 	digits_type;
signal digit_sec : 	digits_type;
signal digit_min : 	digits_type;


begin

process(CLK_100)
begin

	if(rising_edge(CLK_100)) then
		if(reset='1') then
			counter_mili 	<= 0;
			counter_sec 	<= 0;
			counter_min 	<= 0;
			
		else		
			counter_mili <= counter_mili + 1;
			
			if (counter_mili = 99) then				
				counter_mili 	<= 0;
				counter_sec 	<= counter_sec + 1;
						
				if (counter_sec = 59) then
					counter_sec 	<= 0;
					counter_min 	<= counter_min + 1;
					
					if (counter_min = 99) then
						counter_min 	<= 0;					
					end if;
					
				end if;
				
			end if;
			
		end if;
	end if;
	
	digit_mili(1) <= counter_mili / 10;
	digit_mili(0) <= counter_mili - ((counter_mili / 10) * 10);
	
	digit_sec(1) <= counter_sec / 10;
	digit_sec(0) <= counter_sec - ((counter_sec / 10) * 10);
	
	digit_min(1) <= counter_min / 10;
	digit_min(0) <= counter_min - ((counter_min / 10) * 10);
	
end process;


process(digit_mili)
begin
	case digit_mili(0) is
  
		when 0 => counter_s(6 DOWNTO 0) <= "0000001";
		when 1 => counter_s(6 DOWNTO 0) <= "1001111";
		when 2 => counter_s(6 DOWNTO 0) <= "0010010";
		when 3 => counter_s(6 DOWNTO 0) <= "0000110";
		when 4 => counter_s(6 DOWNTO 0) <= "1001100";
		when 5 => counter_s(6 DOWNTO 0) <= "0100100";
		when 6 => counter_s(6 DOWNTO 0) <= "0100000";
		when 7 => counter_s(6 DOWNTO 0) <= "0001111";
		when 8 => counter_s(6 DOWNTO 0) <= "0000000";
		when 9 => counter_s(6 DOWNTO 0) <= "0000100";
    
    end case;
	 
	 case digit_mili(1) is
  
		 when 0 => counter_s(13 DOWNTO 7) <= "0000001";
		 when 1 => counter_s(13 DOWNTO 7) <= "1001111";
		 when 2 => counter_s(13 DOWNTO 7) <= "0010010";
		 when 3 => counter_s(13 DOWNTO 7) <= "0000110";
		 when 4 => counter_s(13 DOWNTO 7) <= "1001100";
		 when 5 => counter_s(13 DOWNTO 7) <= "0100100";
		 when 6 => counter_s(13 DOWNTO 7) <= "0100000";
		 when 7 => counter_s(13 DOWNTO 7) <= "0001111";
		 when 8 => counter_s(13 DOWNTO 7) <= "0000000";
		 when 9 => counter_s(13 DOWNTO 7) <= "0000100";
    
    end case;
end process;


process(digit_sec)
begin
	case digit_sec(0) is
  
		when 0 => counter_s(20 DOWNTO 14) <= "0000001";
		when 1 => counter_s(20 DOWNTO 14) <= "1001111";
		when 2 => counter_s(20 DOWNTO 14) <= "0010010";
		when 3 => counter_s(20 DOWNTO 14) <= "0000110";
		when 4 => counter_s(20 DOWNTO 14) <= "1001100";
		when 5 => counter_s(20 DOWNTO 14) <= "0100100";
		when 6 => counter_s(20 DOWNTO 14) <= "0100000";
		when 7 => counter_s(20 DOWNTO 14) <= "0001111";
		when 8 => counter_s(20 DOWNTO 14) <= "0000000";
		when 9 => counter_s(20 DOWNTO 14) <= "0000100";
    
    end case;
	 
	 case digit_sec(1) is
  
		 when 0 => counter_s(27 DOWNTO 21) <= "0000001";
		 when 1 => counter_s(27 DOWNTO 21) <= "1001111";
		 when 2 => counter_s(27 DOWNTO 21) <= "0010010";
		 when 3 => counter_s(27 DOWNTO 21) <= "0000110";
		 when 4 => counter_s(27 DOWNTO 21) <= "1001100";
		 when 5 => counter_s(27 DOWNTO 21) <= "0100100";
		 when 6 => counter_s(27 DOWNTO 21) <= "0100000";
		 when 7 => counter_s(27 DOWNTO 21) <= "0001111";
		 when 8 => counter_s(27 DOWNTO 21) <= "0000000";
		 when 9 => counter_s(27 DOWNTO 21) <= "0000100";
    
    end case;
end process;


process(digit_min)
begin
	case digit_min(0) is
  
		when 0 => counter_s(34 DOWNTO 28) <= "0000001";
		when 1 => counter_s(34 DOWNTO 28) <= "1001111";
		when 2 => counter_s(34 DOWNTO 28) <= "0010010";
		when 3 => counter_s(34 DOWNTO 28) <= "0000110";
		when 4 => counter_s(34 DOWNTO 28) <= "1001100";
		when 5 => counter_s(34 DOWNTO 28) <= "0100100";
		when 6 => counter_s(34 DOWNTO 28) <= "0100000";
		when 7 => counter_s(34 DOWNTO 28) <= "0001111";
		when 8 => counter_s(34 DOWNTO 28) <= "0000000";
		when 9 => counter_s(34 DOWNTO 28) <= "0000100";
    
    end case;
	 
	 case digit_min(1) is
  
		 when 0 => counter_s(41 DOWNTO 35) <= "0000001";
		 when 1 => counter_s(41 DOWNTO 35) <= "1001111";
		 when 2 => counter_s(41 DOWNTO 35) <= "0010010";
		 when 3 => counter_s(41 DOWNTO 35) <= "0000110";
		 when 4 => counter_s(41 DOWNTO 35) <= "1001100";
		 when 5 => counter_s(41 DOWNTO 35) <= "0100100";
		 when 6 => counter_s(41 DOWNTO 35) <= "0100000";
		 when 7 => counter_s(41 DOWNTO 35) <= "0001111";
		 when 8 => counter_s(41 DOWNTO 35) <= "0000000";
		 when 9 => counter_s(41 DOWNTO 35) <= "0000100";
    
    end case;
end process;

counter <= counter_s; 

end Behavioral;