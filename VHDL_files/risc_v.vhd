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
    
    type reg_block_two is record 
        data_one : std_logic_vector(DATA_WIDTH-1 downto 0);
        data_two : std_logic_vector(DATA_WIDTH-1 downto 0);
        immediate : std_logic_vector(DATA_WIDTH-1 downto 0);
        rd :  std_logic_vector(4 downto 0);
    end record reg_block_two;
-- SIGNAL DEFINITIONS

signal pc_branch: std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
signal mux_control_pc : std_logic;
signal reg_block_one_next, reg_block_one_out : reg_block_one;
signal reg_block_two_next, reg_block_two_out : reg_block_two;

signal if_flush : std_logic;
signal comp : std_logic;
signal op_code : std_logic_vector(6 downto 0);
signal funct3 : std_logic_vector(2 downto 0);
signal funct7 : std_logic_vector(6 downto 0);
-- COMPONENT DEFINITION

    

begin
    
    branch_control : process(comp, op_code, funct3) --only compatiable with beq so far
    begin 
        mux_control_pc <= '0';
        if_flush <= '0';
        if(op_code = B_FORMAT) then 
            if(funct3 = "000" and comp ='1') then 
                mux_control_pc <= '1';
                if_flush <= '1';
            end if;
        end if;
    end process;
    
    stage_if : entity work.stage_if
    port map(
        clk             => clk,
        rst             => reset_n,
        mux_control     => mux_control_pc,
        pc_branch       => pc_branch,
        instruction_out => reg_block_one_next.pc,
        pc_out          => reg_block_one_next.instruction
    );

    stage_id : entity work.stage_id
    port map(
        clk             => clk,
        reset_n         => reset_n,
        pc_in           => reg_block_one_out.pc,
        instruction_in  => reg_block_one_out.instruction,
        rd_from_wb      => open, 
        write_en_from_wb => open,
        result_from_wb  => open, 
        comp            => comp,
        pc_branch_out   => pc_branch,
        immediate_out   => reg_block_two_next.immediate,
        op_code         => op_code, 
        funct3           => funct3,
        funct7          => funct7,
        rd              => reg_block_two_next.rd, 
        data_one        => reg_block_two_next.data_one, 
        data_two        => reg_block_two_next.data_two
    );

    registers: process (clk) is
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                reg_block_one_out <= (others => (others => '0'));
                reg_block_two_out <= (others => (others => '0'));
            else
                if(if_flush = '1') then 
                    reg_block_one_out <= (others => (others => '0'));
                else
                    reg_block_one_out <= reg_block_one_next;
                end if;
                reg_block_two_out <= reg_block_two_next;
            end if;
        end if;
    end process registers;

end behavioral;

