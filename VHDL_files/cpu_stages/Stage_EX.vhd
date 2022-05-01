library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity stage_ex is
    port(
        ALU_control : in std_logic_vector(2 downto 0);
        data_one : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_two : in std_logic_vector(DATA_WIDTH-1 downto 0);
        immediate : in std_logic_vector(DATA_WIDTH-1 downto 0);
        mux_control : in std_logic;
        
        result : out std_logic_vector(DATA_WIDTH-1 downto 0);
        zero : out std_logic -- the question is if we still need this value for anything now that we do comparasion for branch in decode stage. 
    );
end stage_ex;

architecture behavioral of stage_ex is

-- TYPE DEFINITIONS


-- SIGNAL DEFINITIONS

signal chosen_second_operand : std_logic_vector(DATA_WIDTH-1 downto 0);

begin
        
    control_right_operand : process(data_two, immediate, mux_control)
    begin 
        if(mux_control = '0') then 
            chosen_second_operand <= data_two;
        else 
            chosen_second_operand <= immediate;
        end if;
    end process;

    alu : entity work.alu
    port map(
        control => ALU_control,
        left_operand => data_one, 
        right_operand => chosen_second_operand,
        zero => zero, 
        result => result
    );

end behavioral;