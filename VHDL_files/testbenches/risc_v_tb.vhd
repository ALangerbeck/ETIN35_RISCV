library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use STD.textio.all;
use work.common.all;


entity risc_v_tb is
end entity;


architecture structural of  risc_v_tb is


	--Signal Declaration
signal clk,rst: std_logic := '0';
constant period : time := 100 ns;
signal data_cpu : std_logic_vector(CPU_DATA_WIDTH-1 downto 0);


	--Component declaration
component ph_risc_v is    
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        data_write: out std_logic_vector(CPU_DATA_WIDTH-1 downto 0)
    );        
end component;

	
begin
  
    inst : ph_risc_v   
    port map(
        clk => clk,
        reset_n => rst,
        data_write => data_cpu
    );        
    
    clk <= not(clk) after period*0.5;
    rst <= '1' after 1*period;


end structural;