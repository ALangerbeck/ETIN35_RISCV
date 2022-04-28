library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity stage_if is
    port(
        clk : in std_logic;
        rst : in std_logic;
        mux_control : in std_logic;
        pc_branch : in std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
        instruction_out : out std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
        pc_out: out std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0)
    );
end stage_if;

architecture behavioral of stage_if is

-- SIGNAL DEFINITIONS

 signal pc, pc_next: std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
 signal instruction : std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);

-- COMPONENT DEFINITION
component reg is 
    generic( W: integer);
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        next_out : in std_logic_vector(W-1 downto 0);
        output  : out std_logic_vector(W-1 downto 0)
    );
end component;

component program_memory is
    
    port (
        clk: in std_logic;
        write_en: in std_logic;
        write_data: in std_logic_vector(DATA_WIDTH-1 downto 0);
        address: in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        read_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end component;


begin
    
    pc_out <= pc;
    instruction_out <= instruction;
    
    program_counter : process(mux_control, pc, pc_branch)
    begin
        if (mux_control = '0') then 
            pc_next <= pc +4;
        elsif (mux_control = '1') then
            pc_next <= pc_branch;
        end if;
        
    end process;

prog_mem: entity work.program_memory 
    port map (
        clk => clk,
        write_en => '0',
        write_data => (others => '0'),
        address => pc,
        read_data => instruction
    );

 pc_reg : reg 
    generic map ( W => PROGRAM_ADDRESS_WIDTH)
    port map(
        clk     => clk,
        n_rst     => rst,
        next_out => pc_next,
        output  => pc
        );

end behavioral;