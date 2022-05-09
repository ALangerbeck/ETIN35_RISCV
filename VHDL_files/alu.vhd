library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;


entity alu is
    port(
        control: in std_logic_vector(2 downto 0);
        left_operand: in std_logic_vector(DATA_WIDTH-1 downto 0);
        right_operand: in std_logic_vector(DATA_WIDTH-1 downto 0);
        zero: out std_logic;
        result: out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end alu;

architecture behavioral of alu is

    signal alu_result: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal debug : unsigned(DATA_WIDTH-1 downto 0);
begin

    -- the originl from Masudos code was 000, 001, 010, 110, and the others have been added by us. 
    process(control, left_operand, right_operand)
    begin
        debug <= (others => '0');
        case control is
            when "000" => 
                alu_result <= left_operand and right_operand;
            when "001" => 
                alu_result <= left_operand or right_operand;
            when "010" =>
                alu_result <= std_logic_vector(signed(left_operand) + signed(right_operand));
            when "011" =>
                if (signed(left_operand) < signed(right_operand)) then 
                    alu_result <= "0000000000000000000000000000000" & '1';
                else
                    alu_result <= (others=> '0');
                end if;
            when "100" =>
                debug <= unsigned(left_operand);
                if (unsigned(left_operand) < unsigned(right_operand)) then 
                    alu_result <= "0000000000000000000000000000000" & '1';
                else
                    alu_result <= (others=> '0');
                end if;
            when "110" => 
                alu_result <= std_logic_vector(signed(left_operand) - signed(right_operand));
            when others => 
                alu_result <= left_operand and right_operand;
        end case;
    end process;

    result <= alu_result;
    zero <= '1' when signed(alu_result) = 0 else '0';

end behavioral;