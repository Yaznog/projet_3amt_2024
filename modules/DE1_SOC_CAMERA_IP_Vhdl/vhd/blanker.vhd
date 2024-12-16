-- Quartus II VHDL Template
--  blanker

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_arith.all;


entity blanker is

	port 
	(
	   RST	   : in std_logic;
	   VGA_HS	   : in std_logic;
		VGA_VS	   : in std_logic;
		clk	   : in std_logic;
		SW8	   : in std_logic;
		SW7	   : in std_logic;
		SW5	   : in std_logic;
		SW4		   : in std_logic;
		SW3	:   in std_logic;
		SW2	:   in std_logic;
		SW1	:   in std_logic;
		r	   : in std_logic_vector(9 downto 0);
		g	   : in std_logic_vector(9 downto 0);
		b	   : in std_logic_vector(9 downto 0);
--		LEDG	: out std_logic_vector(8 downto 0);
		r_out	: out std_logic_vector(9 downto 0);
		g_out	: out std_logic_vector(9 downto 0);
		b_out	: out std_logic_vector(9 downto 0)
	);

end entity;

architecture rtl of blanker is

-- process(r,g,b)
signal 	t 					: integer ;
signal r_in, g_in, b_in, noir_et_blanc		: unsigned(11 downto 0);


type delay_line is array (0 to 800) of STD_LOGIC_VECTOR(9 downto 0);
signal rin,gin,bin : delay_line ;



-- Processes P-STATE & Trame
type Trame_states is (init_image, init_line, Y); -- ,  Y); -- r1, r2 not used
 
signal   etat, etat_suivant				: Trame_states;
signal   reg1,reg2,reg3         		: std_logic_vector(9 downto 0);
signal   next_reg1,next_reg2,next_reg3  : std_logic_vector(9 downto 0);
signal   r_out_in, g_out_in, b_out_in   : std_logic_vector(9 downto 0);
signal   r_out_2, g_out_2, b_out_2   : std_logic_vector(9 downto 0);

signal   r_delay,g_delay,b_delay		: std_logic_vector(9 downto 0);
signal   count_Line 					: unsigned(10 downto 0);
signal   count_Col          			: unsigned(10 downto 0);
signal   next_count_Line 				: unsigned(10 downto 0);
signal   next_count_Col     			: unsigned(10 downto 0);
signal   counter						: unsigned(5 downto 0);	
--signal	 count_HS, next_count_HS		: unsigned(5 downto 0);	
signal 	 Clk_div						: std_logic;
--signal	 count_line_incremented			: std_logic;
--signal	 next_count_line_incremented	: std_logic;

begin

blanking:process(clk_div)
begin
 if (Clk_div='1' and Clk_div'EVENT ) then
  if ( VGA_VS='0' or VGA_HS='0') then  
    r_out <="0000000000"; g_out <="0000000000"; b_out <="0000000000";
  else 
    r_out <= r_out_2; g_out <= g_out_2; b_out <= b_out_2;  
  end if;
 end if;
end process;
 
gen:process(r_out_in, g_out_in, b_out_in,SW4, SW3, SW2, SW1, r_in, g_in, b_in, noir_et_blanc)
begin
if (SW1='1') then
--	   -- noir et blanc
		r_in(9 downto 0) <= unsigned(r_out_in(9 downto 0)); r_in(11 downto 10)<="00";
		g_in(9 downto 0) <= unsigned(g_out_in(9 downto 0)); g_in(11 downto 10)<="00";
		b_in(9 downto 0) <= unsigned(b_out_in(9 downto 0)); b_in(11 downto 10)<="00";
		noir_et_blanc(11 downto 0) <= (r_in(11 downto 0) + g_in(11 downto 0) + b_in(11 downto 0));
		r_out_2 <= conv_std_logic_vector(noir_et_blanc(11 downto 2),10);
		g_out_2 <= conv_std_logic_vector(noir_et_blanc(11 downto 2),10);
		b_out_2 <= conv_std_logic_vector(noir_et_blanc(11 downto 2),10);
	else
    
	if  (SW4='1') then
		r_out_2 <= r_out_in;
	else
		r_out_2 <= "0000000000";
	end if;

	if  (SW3='1') then
		g_out_2 <= g_out_in;
	else
		g_out_2 <= "0000000000";
	end if;

	if  (SW2='1') then
		b_out_2 <= b_out_in;
	else
		b_out_2 <= "0000000000";
	end if;
	
	r_in(11 downto 0) <= "000000000000";
	g_in(11 downto 0) <= "000000000000";
	b_in(11 downto 0) <= "000000000000";
	noir_et_blanc(11 downto 0) <= "000000000000";
	
 end if;
 	 
end process gen;

-- r_out <= r; g_out <= g; b_out <= b;


P_STATE:process(Clk_div)
	begin
		if (Clk_div='1' and Clk_div'EVENT ) then
		   r_out_in <= next_reg1; g_out_in <= next_reg2; b_out_in <= next_reg3; 
		   reg1<=next_reg1; reg2<=next_reg2; reg3<=next_reg3;
	-- Initialisation  l'etat 0 sous contrle de "RST0" , debut affichage ligne video
		   if (VGA_VS ='0') then 
		      etat <= init_image;
			  count_Col(10 downto 0) <= "00000000000";	
		   	  count_line(10 downto 0) <= "00000000000";
		     else     
		   	  etat <= etat_suivant;
	  	   	  count_Col(10 downto 0) <= next_count_Col(10 downto 0);	
		   	  count_line(10 downto 0) <= next_count_line(10 downto 0);
		   end if ;
	  	   		  
		end if;
	end process P_STATE;
	
Trame:process(etat, etat_suivant, count_col, count_line , reg1, reg2, reg3, r, g, b,r_delay,g_delay,b_delay, SW8, SW7, SW5, VGA_HS) 
    begin
    next_reg1<="0000000000"; next_reg2<="0000000000"; next_reg3<="0000000000";
    
	case etat is
	       when init_image =>
--	        LEDG <="000000001";
	        next_count_Line(10 downto 0) <= "11111111111"; -- pour commencer  a 0 sur 1ere ligne
	        next_count_Col(10 downto 0)  <= "00000000000";
		     next_reg1<="0000000000"; next_reg2<="0000000000"; next_reg3<="0000000000";    		    	  	  	
	         if (VGA_HS ='0') then
	           etat_suivant <= init_line;
	          else
			   etat_suivant <= init_image;
			  end if;
			  	
	       when init_line =>
--	          LEDG <="000000010";
			  next_count_Col(10 downto 0) <= "00000000000";
			   next_count_Line(10 downto 0) <= count_line(10 downto 0);
			  next_reg1<=reg1; next_reg2<=reg2; next_reg3<=reg3;
			  if (VGA_HS ='1') then
	           next_count_Line(10 downto 0) <= count_line(10 downto 0)+ "00000000001";
	           etat_suivant <= Y;
	          else
			   next_count_Line(10 downto 0) <= count_line(10 downto 0);
			   etat_suivant <= init_line;
			  end if;
			       		    	  	  	
	       when Y =>
--	            LEDG <="000001000";
--             if ( count_line > 0 and  count_line < 250 and  count_col > 50 and  count_col < 500) then
--				if ( count_col > 1280 and  count_line > 480) then

--				if (SW7= '1') then			     
--				  if ( count_col(0) = '0' and SW8 = '0') then
----                   if ( count_line > "0000100000" and  count_line < "0100100001" and  count_col > "010000000" and  count_col < "1010000001") then					           
--			        next_reg1 <= r_delay; next_reg2 <= g_delay; next_reg3 <= b_delay; -- acquisition 1 fois sur 2
--			       elsif  ( count_col(1) = '0' and count_col(0) = '0') then
--			        next_reg1 <= r_delay; next_reg2 <= g_delay; next_reg3 <= b_delay; -- acquisition 1 fois sur 4		      
--			       else
--			        next_reg1 <= reg1; next_reg2 <= reg2; next_reg3 <= reg3; -- repetition du Pixel
--			      end if;
--			    else
--				   next_reg1 <= r ; next_reg2 <= g ; next_reg3 <= b;	 -- lecture vga in (SW16 =1=
--				end if;
    if (SW5='1'  and count_line > 0 and count_line < 75) then	
	next_reg1(9 downto 2) <= conv_std_logic_vector((count_col(7 downto 0)-0),8);
	next_reg2(9 downto 0) <= "0000000000";
	next_reg3(9 downto 0) <= "0000000000";
	 elsif (SW5='1'  and count_line >= 75 and count_line < 125) then
	 next_reg1(9 downto 0) <= "0000000000";
	 next_reg2(9 downto 2) <= conv_std_logic_vector((count_col(7 downto 0)-0),8);
	 next_reg3(9 downto 0) <= "0000000000";
	  elsif (SW5='1'  and count_line >= 125 and count_line < 175) then
	  next_reg1(9 downto 0) <= "0000000000";
	  next_reg2(9 downto 0) <= "0000000000";
	  next_reg3(9 downto 2) <= conv_std_logic_vector((count_col(7 downto 0)-0),8);
	   elsif (SW5='1'  and count_line >= 175 and count_line < 225) then
		 next_reg1(9 downto 2) <= conv_std_logic_vector((count_col(7 downto 0)-0),8);
		 next_reg2(9 downto 2) <= conv_std_logic_vector((count_col(7 downto 0)-0),8);
		 next_reg3(9 downto 2) <= conv_std_logic_vector((count_col(7 downto 0)-0),8);
				elsif (SW8='0' and SW7= '0') then
					 next_reg1 <= r ; next_reg2 <= g ; next_reg3 <= b;	 -- lecture vga in 
	--				 elsif  ( SW8='0' and SW7='1' and count_col(0)='0' and count_line(1)='0') then
					   elsif  ( SW8='0' and SW7='1' and count_col(0)='0') then
					   next_reg1 <= r_delay; next_reg2 <= g_delay; next_reg3 <= b_delay; -- acquisition 1 fois sur 2	
					   elsif  ( SW8='1' and SW7= '0' and count_col(1) = '0' and count_col(0) = '0') then
						next_reg1 <= r_delay; next_reg2 <= g_delay; next_reg3 <= b_delay; -- acquisition 1 fois sur 4
						elsif  ( SW8='1' and SW7= '1' and count_col(2) = '0' and count_col(1) = '0' and count_col(0) = '0') then
						 next_reg1 <= r_delay; next_reg2 <= g_delay; next_reg3 <= b_delay; -- acquisition 1 fois sur 8
						else
						next_reg1 <= reg1; next_reg2 <= reg2; next_reg3 <= reg3; -- repetition du Pixel
				end if;
	 
			    next_count_Col(10 downto 0) <= count_Col(10 downto 0) + "00000000001";
			    next_count_Line(10 downto 0) <= count_line(10 downto 0);
			     if (VGA_HS ='0') then
	               etat_suivant <= init_line;
	              else		       
			       etat_suivant <= Y;
			     end if;  
	 end case;
	
   end process Trame;
	

	P_DL : process(Clk_div)
	begin 

	if (Clk_div'event and Clk_div='1') then
--      	   if (VGA_HS = '0') then
--		    for i in rin'range loop
--		     rin(i) <= (others => '0');
--		     gin(i) <= (others => '0');
--		     bin(i) <= (others => '0');
--		    end loop ;

--	       elsif ( SW17 = '1') then
--		 if (VGA_HS = '1'and count_line(0) = '0' and SW8 = '0') then
		 if (VGA_HS = '1' and SW8 = '0' and SW7 = '0') then		 
		      rin(0) <= r;
		      gin(0) <= g;
		      bin(0) <= b;
		       for i in rin'low to (rin'high - 1) loop
		        rin(i+1) <= rin(i);
		        gin(i+1) <= gin(i);
		        bin(i+1) <= bin(i);
		       end loop;
--		  elsif (VGA_HS = '1'and count_line(0) = '0' and count_line(1) = '0') then
		    elsif (VGA_HS = '1' and count_line(0) ='0' and SW8 ='0' and SW7 = '1') then 
	          rin(0) <= r;
		      gin(0) <= g;
		      bin(0) <= b;
		       for i in rin'low to (rin'high - 1) loop
		        rin(i+1) <= rin(i);
		        gin(i+1) <= gin(i);
		        bin(i+1) <= bin(i);
		       end loop;
		     elsif (VGA_HS = '1' and count_line(0) = '0' and count_line(1)='0' and SW8 ='1' and SW7 ='0') then 
	          rin(0) <= r;
		      gin(0) <= g;
		      bin(0) <= b;
		       for i in rin'low to (rin'high - 1) loop
		        rin(i+1) <= rin(i);
		        gin(i+1) <= gin(i);
		        bin(i+1) <= bin(i);
		       end loop;
		      elsif (VGA_HS = '1' and count_line(0) = '0' and count_line(1)='0' and count_line(2)='0' and SW8 ='1' and SW7 ='1') then 
	           rin(0) <= r;
		       gin(0) <= g;
		       bin(0) <= b;
		        for i in rin'low to (rin'high - 1) loop
		         rin(i+1) <= rin(i);
		         gin(i+1) <= gin(i);
		         bin(i+1) <= bin(i);
		        end loop;
		       
		        elsif (VGA_HS = '1') then
	          rin(0) <= r_delay;
		      gin(0) <= g_delay;
		      bin(0) <= b_delay;
		       for i in rin'low to (rin'high - 1) loop
		        rin(i+1) <= rin(i);
		        gin(i+1) <= gin(i);
		        bin(i+1) <= bin(i);
		       end loop;
	       end if;
	     
	end if;
	end process P_DL ;

	r_delay <= rin(conv_integer(704));
	g_delay <= gin(conv_integer(704));
	b_delay <= bin(conv_integer(704));
	
	P_DIV:process(Clk)
	begin
		if (Clk='1' and Clk'EVENT ) then
		   if (RST ='0') then 
		   	  counter <= "000000";
		     else     
		   	  counter <= counter + "000001";
		   end if ;	  	   		  
		end if;
		
	end process P_DIV;
	
 --Clk_Div <= Clk;		
  Clk_Div <= counter(0);
end rtl;
