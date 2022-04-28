library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity sign_extender is 
    generic( I: integer;
             O: integer);
    port (  
            input : in std_logic_vector(I-1 downto 0);
            output  : out std_logic_vector(O-1 downto 0)
         );
end sign_extender; 

architecture behavioral of sign_extender is

signal temporary : std_logic_vector(O-1 downto 0);

begin

    sign_extension : process(input) 
    begin 
        if(input(I-1)='0') then 
            temporary <= (others => '0');
        else 
            temporary <= (others => '1');
        end if;
        output <= temporary(O-1 downto I) & input;
    end process; 

end behavioral; 