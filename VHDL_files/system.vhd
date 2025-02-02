library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;


entity system is
    
    port (
        clk: in std_logic;
        reset_n: in std_logic;
        redundant: out std_logic      
    );
end system;

architecture structural of system is
    
    signal program_address: std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
    signal program_data: std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
    
    signal data_write_en: std_logic;
    signal data_address: std_logic_vector(DATA_ADDRESS_WIDTH-1 downto 0);
    signal data_read: std_logic_vector(CPU_DATA_WIDTH-1 downto 0);
    signal data_write: std_logic_vector(CPU_DATA_WIDTH-1 downto 0);    

begin

    cpu: entity work.ph_risc_v 
        port map (
            clk => clk,
            reset_n => reset_n,
            data_write => data_write
        );
    
    -- Just added to force the tools not to optimize away the logic
    process (clk)
        variable red: std_logic := '0';
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                red := '0';
            else
                for i in data_write'range loop
                    red := red or data_write(i);
                end loop;
            end if;            
            redundant <= red;
        end if;
    end process;
    
end structural;