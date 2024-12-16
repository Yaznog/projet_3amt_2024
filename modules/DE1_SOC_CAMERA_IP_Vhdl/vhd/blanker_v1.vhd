-- Quartus II VHDL Template
-- blanker

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blanker_v1 is

	port 
	(
		IMG	   : in std_logic;
		r	   : in std_logic_vector(7 downto 0);
		g	   : in std_logic_vector(7 downto 0);
		b	   : in std_logic_vector(7 downto 0);
		r_out	: out std_logic_vector(7 downto 0);
		g_out	: out std_logic_vector(7 downto 0);
		b_out	: out std_logic_vector(7 downto 0)
	);

end entity;

architecture rtl of blanker_v1 is

signal 	t 					: integer ;

begin

gen:process(r,g,b)
begin
	 for t in 0 to 7 loop	
		r_out(t) <= ( r(t) and IMG );
		g_out(t) <= ( g(t) and IMG );
		b_out(t) <= ( b(t) and IMG );
	end loop;
--	for t in 2 to 3 loop	
--	r_out(t) <= '0';
--	g_out(t) <= '0';
--	b_out(t) <= '0';
--	end loop;

end process gen;
		
--	x_out(2) <= (x(2) and ( IMG));
--	x_out(1) <= (x(1) and ( IMG));
--	x_out(0) <= (x(0) and ( IMG));
--	y_out(x) <= (y(3) and ( IMG));
--	y_out(2) <= (y(2) and ( IMG));
--	y_out(1) <= (y(1) and ( IMG));
--	y_out(0) <= (y(0) and ( IMG));
--	z_out(x) <= (z(3) and ( IMG));
--	z_out(2) <= (z(2) and ( IMG));
--	z_out(1) <= (z(1) and ( IMG));
--	z_out(0) <= (z(0) and ( IMG)); 
end rtl;
