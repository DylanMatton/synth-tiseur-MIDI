library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

type str_cmd    is array(3 downto 0) of std_logic_vector(7 downto 0);--représente une chaîne de caractère de la commande à lire
type statecmpr is (CONVON,ENDOFCONV);--état de la conversion
			
----------------------------------------------------------------
entity VLQ_CALC is
 	port
 	(
 			clk: in std_logic;
 			reset: in std_logic;
			req_vlq: in std_logic;
			midi_rom_adr: in std_logic_vector(31 downto 0);
			state_vlq: out statevlq;
			res_vlq : out  std_logic_vector(31 downto 0);--résultat de la conversion en entier
 	)
end entity COMP;
----------------------------------------------------------------
architecture A of VLQ_CALC is
---
signal cure_state:statecmpr;
signal next_state:statecmpr;
signal count:unsigned(2 downto 0);
signal next_count:unsigned(2 downto 0);
signal r:std_logic;
---
begin
---
	FSM_NEXT_VLQ: process(clk,reset)
		begin
		if(clk'event and clk='1') then
		
			if(reset='1') then 
				count<="0000";
				r<='0';
				cure_state<=ENDOFCONV;
				state<=ENDOFCONV;
			else
			
				if (next_state=ENDOFCONV) then 
					count<="0000";
				
				else
				state<=next_state;
				cure_state<=next_state;
				count<=next_count;
				end if
			end if
			
		end if
	end process;
---
	FSM_VLQ: process(cure_state,req_comp)
		begin
		case cure_state is 
		
				when CONVON=>

					next_count <= count + "0001";
					next_r<= (r*128)+romres mod 128 
					if (count<6) then next_state<=ENDOFCONV;
					if (rom(adr_rom+count<128)then next_state<=CONVOFF;
					
					
				when ENDOFCONV=>
					res<=r;--on retourne le resultat à la fsm
					next_r<=0;
					next_count<="0000";--pret pour une nouvelle conversion
					next_state<=ENDOFCONV;
					if(req_vlq'event and req_vlq ='1') then next_state<=CONVON;
					
	end process;

end A;
