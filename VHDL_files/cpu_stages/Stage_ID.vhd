library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity stage_id is
    port(
        pc_in : in std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
        instruction_out : in std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
        clk : in std_logic;
        reset_n : in std_logic
        
    );
end stage_id;

architecture behavioral of stage_id is

-- TYPE DEFINITIONS

 type instruction is record
        opcode: std_logic_vector(6 downto 0);
        rd : std_logic_vector(4 downto 0);
        funct3 : std_logic_vector(2 downto 0);
        rs1 : std_logic_vector(4 downto 0);
        rs2 : std_logic_vector(4 downto 0);
        funct7 : std_logic_vector(6 downto 0);
 end record instruction;

-- SIGNAL DEFINITIONS


signal inst_opcode : std_logic_vector(6 downto 0);

-- COMPONENT DEFINITION


begin

reg_file: entity work.register_file 
        generic map (
            DATA_WIDTH => CPU_DATA_WIDTH,
            ADDRESS_WIDTH => REGISTER_FILE_ADDRESS_WIDTH
        )
        port map (
            clk => clk,
            reset_n => reset_n,
            write_en => open,
            read1_id => open,
            read2_id => open,
            write_id => open,
            write_data => open,
            read1_data => open,
            read2_data => open
        );



end behavioral;