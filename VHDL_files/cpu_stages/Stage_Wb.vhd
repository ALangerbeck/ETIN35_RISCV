library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage_wb is
    generic(DATA_WIDTH: integer := 32);

    port(
        Data  : inout std_logic
    );
end stage_wb;

architecture behavioral of stage_wb is


begin



end behavioral;