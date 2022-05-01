library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity stage_mem is

    port(
        clk : in std_logic;
        write_en : in std_logic;
        result : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_two : in std_logic_vector(DATA_WIDTH-1 downto 0);
        
        read_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end stage_mem;

architecture behavioral of stage_mem is



begin
    data_memory : entity work.data_memory    
    port map(
        clk => clk, 
        write_en => write_en,
        write_data => data_two, 
        address => result, 
        read_data => read_data
    );

end behavioral;