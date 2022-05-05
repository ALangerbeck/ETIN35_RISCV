library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity calculate_forwarding is 
    port (  
            rs : in std_logic_vector(4 downto 0);
            rd_ex : in std_logic_vector(4 downto 0);
            rd_mem : in std_logic_vector(4 downto 0);
            rd_wb : in std_logic_vector(4 downto 0);
            ex_mux : out std_logic_vector(2 downto 0);
            id_mux : out std_logic
            );
end calculate_forwarding; 

architecture behavioral of calculate_forwarding is



begin

    calc : process(rs, rd_ex, rd_mem, rd_wb) 
    begin 
        ex_mux <= "00";
        id_mux <= '0';
        if(rs = rd_ex) then
            ex_mux <= "01";
        elsif ( rs=rd_mem ) then 
            ex_mux <= "10";
        end if;
        
        if(rs = rd_wb) then 
            id_mux <= '1';
        end if;
    end process; 

end behavioral; 