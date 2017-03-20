library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library modelsim_lib;
use modelsim_lib.util.all; --à voir quelle si c'est la bonne librairie à utiliser

library lib_VHDL;

entity bench_top is
end entity;  -- bench_top

architecture arch of bench_top is

    component cmp
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            req_comp   : in std_logic;
            tab        : in str_cmd;
            comp_in    : in std_logic_vector(7 downto 0);
            midi_rom_adr : in std_logic_vector(31 downto 0);
            lenght : in std_logic_vector(3 downto 0);
            state_comp : out statecmpr;
            res_comp : out std_logic;
            comp_rom : out std_logic_vector(31 downto 0);
            ) ;
    end component;
    
    signal clk_s        : std_logic := '0';
    signal reset_s      : std_logic;
    signal req_comp_s : std_logic;
    signal tab_s : str_cmd;
    signal comp_in_s : std_logic_vector(7 downto 0);
    signal midi_rom_adr_s : std_logic_vector(31 downto 0);
    signal lenght_s : std_logic_vector(3 downto 0);
    signal state_comp_s : statecmpr
    signal res_comp_s : std_logic;
    signal comp_rom_s : std_logic_vector(31 downto 0);
    
    --signaux internes
    signal cure_state : statecmpr;
    signal next_state : statecmpr;
    signal count : unsigned(3 downto 0);
    signal r : std_logic;
    
    
begin
  port map (
      clk => clk_s,
      reset => reset_s,
      req_comp => req_comp_s,
      tab => tab_s,
      comp_in => comp_in_s,
      midi_rom_adr => midi_rom_adr_s,
      lenght => lenght_s,
      state_comp => state_comp_s,
      res_comp => res_comp_s,
      comp_rom => comp_rom_s
      );
      
   clk_s <= not(clk_s) after 10 ns;
   reset_s <= '1', '0' after 15 ns;
   
   tab_s(0) <= "00000000";
   tab_s(1) <= "11110000";
   tab_s(2) <= "00001111";
   tab_s(3) <= "10101010";
   
   req_comp_s <= '0', '1' after 10 ns; 
    
    
end architecture;
