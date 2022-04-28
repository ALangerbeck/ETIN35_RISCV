library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ph_risc_v is    
    
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        data_address: out std_logic_vector(DATA_ADDRESS_WIDTH-1 downto 0);
        data_read: in std_logic_vector(CPU_DATA_WIDTH-1 downto 0);
        data_write_en: out std_logic;
        data_write: out std_logic_vector(CPU_DATA_WIDTH-1 downto 0) 
    );        
end ph_risc_v;

architecture behavioral of ph_risc_v is
-- TYPE DEFINITIONS
    type reg_block_one is record
        pc: std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
        instruction : std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
    end record reg_block_one;    

-- SIGNAL DEFINITIONS

 signal pc_branch, pc_if_out: std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
 signal instruction : std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
 signal mux_control_pc : std_logic;
 signal reg_block_one_next, reg_block_one_out : reg_block_one;

-- COMPONENT DEFINITION

begin

reg_block_one_next <= (  pc => pc_if_out,
	                    instruction => instruction);

stage_if : entity work.stage_if
    port map(
        clk => clk,
        rst => reset_n,
        mux_control => mux_control_pc,
        pc_branch => pc_branch,
        instruction_out => instruction,
        pc_out      => pc_if_out
    );

    registers: process (clk) is
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                reg_block_one_out <= (others => (others => '0'));
            else
                reg_block_one_out <= reg_block_one_next;
            end if;
        end if;
    end process registers;

end behavioral;

