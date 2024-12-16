library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Use ieee.numeric_std.all;

entity COUNTER is
    Port ( clk: in std_logic;
           reset: in std_logic;
           counter: out std_logic_vector(41 downto 0)
     );
end COUNTER;


architecture Behavioral of COUNTER is
signal counter_up: unsigned(41 downto 0);

begin

-- up counter
process(clk)
begin

	if(rising_edge(clk)) then
		if(reset='1') then
			counter_up <= (others => '0');
		else
			counter_up <= counter_up + 1;
		end if;
	end if;
	
end process;

counter <= std_logic_vector(counter_up); 

end Behavioral;