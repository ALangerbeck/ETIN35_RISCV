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


begin

reg_file: entity work.register_file 
        generic map (
            DATA_WIDTH => CPU_DATA_WIDTH,
            ADDRESS_WIDTH => REGISTER_FILE_ADDRESS_WIDTH
        )
        port map (
            clk => clk,
            reset_n => reset_n,
            write_en => mem_wb_reg.control_reg_write,
            read1_id => if_id_reg.instruction.rs1,
            read2_id => if_id_reg.instruction.rs2,
            write_id => mem_wb_reg.register_file_rd,
            write_data => wb_register_file_write_data,
            read1_data => id_register_file_read1_data,
            read2_data => id_register_file_read2_data
        );



end behavioral;