library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity stage_if is
    generic(PROGRAM_ADDRESS_WIDTH: natural := 6);

    port(
        program_read : in std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
        pc: out std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0)
    );
end stage_if;

architecture behavioral of stage_if is


begin



end behavioral;