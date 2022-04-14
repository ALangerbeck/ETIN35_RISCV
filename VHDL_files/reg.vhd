library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity reg is 
    generic( W: integer);
    port (  clk     : in std_logic;
            rst     : in std_logic;
            next_out : in std_logic_vector(W-1 downto 0);
            output  : out std_logic_vector(W-1 downto 0)
         );
end reg; 

architecture behavioral of reg is

begin

    reg : process  ( clk, rst ) 
    begin 
        if rising_edge(clk) then 
            if rst = '1' then
                output <= (others => '0');
            else 
                output <= next_out;
            end if;
        end if;
        
    end process; 

end behavioral; 