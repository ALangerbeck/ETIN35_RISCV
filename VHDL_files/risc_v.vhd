library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;


entity ph_risc_v is    
    
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        program_read: in std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
        pc: out std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
        data_address: out std_logic_vector(DATA_ADDRESS_WIDTH-1 downto 0);
        data_read: in std_logic_vector(CPU_DATA_WIDTH-1 downto 0);
        data_write_en: out std_logic;
        data_write: out std_logic_vector(CPU_DATA_WIDTH-1 downto 0) 
    );        
end ph_risc_v;

architecture behavioral of ph_risc_v is


       
begin


    
end behavioral;
