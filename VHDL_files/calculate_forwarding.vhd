library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common.all;



entity calculate_forwarding is 
    port (  
            rs : in std_logic_vector(4 downto 0);
            rd_ex : in std_logic_vector(4 downto 0);
            rd_mem : in std_logic_vector(4 downto 0);
            rd_wb : in std_logic_vector(4 downto 0);
            lw_ex : in std_logic;
            opcode : in std_logic_vector(6 downto 0);
            ex_mux : out std_logic_vector(1 downto 0);
            id_mux : out std_logic;
            stall : out std_logic
            );
end calculate_forwarding; 

architecture behavioral of calculate_forwarding is

signal stall_branch, stall_load : std_logic;


begin
    
    calc_hazard_detection : process(opcode, rs, rd_ex, rd_mem, lw_ex, stall_load, stall_branch)
    begin
    stall <= '0';
    stall_load <= '0';
    stall_branch <= '0';
    if(opcode = B_FORMAT) then --For branch insert stall since no forward possible
        if((rs=rd_ex and rd_ex/="00000") or(rs=rd_mem and rd_mem/="00000")) then
            stall_branch <= '1';
        end if;
    end if;
    if(lw_ex = '1' and rs=rd_ex and rd_ex/="00000") then --Stall until lw has loaded word
        stall_load <= '1';
    end if;
    if(stall_load = '1' or stall_branch = '1') then
        stall <= '1';
    end if;
    end process;
    
    calc_forwarding : process(rs, rd_ex, rd_mem, rd_wb) 
    begin 
        ex_mux <= "00";
        id_mux <= '0';
        if(rs = rd_ex) then
            ex_mux <= "01";
        elsif ( rs=rd_mem ) then 
            ex_mux <= "10";
        end if;
        
        if(rs = rd_wb) then -- forwardning since we can't write the same cycle as we read
            id_mux <= '1';
        end if;
    end process; 

end behavioral; 