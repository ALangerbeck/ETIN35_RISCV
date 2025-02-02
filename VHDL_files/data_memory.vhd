library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;


entity data_memory is    
    port (
        clk: in std_logic;
        write_en: in std_logic;
        write_data: in std_logic_vector(DATA_WIDTH-1 downto 0);
        address: in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        read_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end data_memory;

architecture behavioral of data_memory is

    constant MEMORY_DEPTH: natural := 2 ** ADDRESS_WIDTH;
    
    type ram_type is array (0 to MEMORY_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram: ram_type := (
        others => "00000000000000000000000000000000"
    );

begin

    data_ram: process (clk) is
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                ram(to_integer(unsigned(address))) <= write_data;
            end if;
        end if;
    end process data_ram;

    read_data <= ram(to_integer(unsigned(address)));

end behavioral;
