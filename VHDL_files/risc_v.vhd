library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ph_risc_v is    
    
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        data_write: out std_logic_vector(CPU_DATA_WIDTH-1 downto 0)  --need to assign this something for the redundant function, so vivado does not optimize away everything
    );        
end ph_risc_v;

architecture behavioral of ph_risc_v is
-- TYPE DEFINITIONS
    type reg_block_one is record
        pc: std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
        instruction : std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
    end record reg_block_one;    
    
    type reg_block_two is record 
        mux_control_src2 : std_logic;
        mux_control_result : std_logic;
        write_mem_enable : std_logic;
        write_back_enable : std_logic;
        data_one : std_logic_vector(DATA_WIDTH-1 downto 0);
        data_two : std_logic_vector(DATA_WIDTH-1 downto 0);
        immediate : std_logic_vector(DATA_WIDTH-1 downto 0);
        rd :  std_logic_vector(4 downto 0);
        ALU_control : std_logic_vector(2 downto 0);
    end record reg_block_two;
-- SIGNAL DEFINITIONS

    type reg_block_three is record 
        write_mem_enable : std_logic;
        write_back_enable : std_logic;
        mux_control_result : std_logic;
        result : std_logic_vector(DATA_WIDTH-1 downto 0);
        data_two : std_logic_vector(DATA_WIDTH-1 downto 0);
        rd : std_logic_vector(4 downto 0);
    end record reg_block_three;
    
    type reg_block_four is record 
        write_back_enable : std_logic;
        mux_control_result : std_logic;
        read_data : std_logic_vector(DATA_WIDTH-1 downto 0);
        ALU_result : std_logic_vector(DATA_WIDTH-1 downto 0);
        rd : std_logic_vector(4 downto 0);
    end record reg_block_four;

signal pc_branch: std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
signal mux_control_pc : std_logic;
signal reg_block_one_next, reg_block_one_out : reg_block_one;
signal reg_block_two_next, reg_block_two_out : reg_block_two;
signal reg_block_three_next, reg_block_three_out : reg_block_three;
signal reg_block_four_next, reg_block_four_out : reg_block_four;

signal if_flush : std_logic;
signal comp : std_logic;
signal op_code : std_logic_vector(6 downto 0);
signal funct3 : std_logic_vector(2 downto 0);
signal funct7 : std_logic_vector(6 downto 0);

signal wb_result : std_logic_vector(DATA_WIDTH-1 downto 0);
-- COMPONENT DEFINITION

    

begin
    
    
    reg_block_three_next.rd <= reg_block_two_out.rd;
    reg_block_three_next.data_two <= reg_block_two_out.data_two;
    reg_block_three_next.write_mem_enable <= reg_block_two_out.write_mem_enable;
    reg_block_three_next.write_back_enable <= reg_block_two_out.write_back_enable;
    reg_block_three_next.mux_control_result <= reg_block_two_out.mux_control_result;
    
    reg_block_four_next.rd <= reg_block_three_out.rd;
    reg_block_four_next.write_back_enable <= reg_block_three_out.write_back_enable;
    reg_block_four_next.mux_control_result <= reg_block_three_out.mux_control_result;
    reg_block_four_next.ALU_result <= reg_block_three_out.result;


    
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
    
    ALU_control : process(op_code, funct3, funct7)
    begin 
        reg_block_two_next.mux_control_src2 <= '1';
        reg_block_two_next.ALU_control <= "000";
        -- ALU control only supports R_add, I_addi, S_SW and L_LW right now
        if((funct3 = "000" and(op_code = I_FORMAT or (op_code = R_FORMAT and funct7 = "0000000"))) or op_code= S_FORMAT or op_code = L_FORMAT) then 
            reg_block_two_next.ALU_control <= "010";
        end if;
        
        if(op_code = R_FORMAT) then 
            reg_block_two_next.mux_control_src2 <= '0';
        end if;
    end process;
    
    write_mem_control : process(op_code)
    begin 
    reg_block_two_next.write_mem_enable <= '0';
    if(op_code = S_FORMAT) then 
        reg_block_two_next.write_mem_enable <= '1';
    end if;
    end process;
    
    write_back_control : process(op_code)
    begin 
        reg_block_two_next.write_back_enable <= '0';
        reg_block_two_next.mux_control_result <= '0'; --- means ALU_result
        if(op_code = R_FORMAT or op_code = L_FORMAT or op_code = I_FORMAT) then
            reg_block_two_next.write_back_enable <= '1';
        end if; 
        if(op_code = S_FORMAT) then 
            reg_block_two_next.mux_control_result <= '1';
        end if; 
    end process;
    
    write_back : process(reg_block_four_out.mux_control_result, reg_block_four_out.ALU_result, reg_block_four_out.read_data)
    begin 
        if(reg_block_four_out.mux_control_result = '0') then 
            data_write <= reg_block_four_out.ALU_result; --for redundancy
            wb_result <= reg_block_four_out.ALU_result;
        else 
            data_write <= reg_block_four_out.read_data; --for redundancy
            wb_result <= reg_block_four_out.read_data;
        end if;
    end process;
    
    stage_if : entity work.stage_if
    port map(
        clk             => clk,
        n_rst             => reset_n,
        mux_control     => mux_control_pc,
        pc_branch       => pc_branch,
        instruction_out => reg_block_one_next.instruction,
        pc_out          => reg_block_one_next.pc
    );
    
-- because of the way the register file works, incase we want to read from a reg in decode stage, when we are writing to that reg in wb stage, it has
-- to be forwarded past the reg_file instead of only saved to the reg file as we will otherwise read the old value. 
    stage_id : entity work.stage_id
    port map(
        clk             => clk,
        reset_n         => reset_n,
        pc_in           => reg_block_one_out.pc,
        instruction_in  => reg_block_one_out.instruction,
        rd_from_wb      => reg_block_four_out.rd,  --from wb
        write_en_from_wb => reg_block_four_out.write_back_enable,
        result_from_wb  => wb_result, 
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
    
    stage_ex : entity work.stage_ex
    port map(
        ALU_control => reg_block_two_out.ALU_control, 
        data_one => reg_block_two_out.data_one,
        data_two => reg_block_two_out.data_two,
        immediate => reg_block_two_out.immediate,
        mux_control => reg_block_two_out.mux_control_src2,
        result => reg_block_three_next.result,
        zero => open -- the question is if we still need this value for anything now that we do comparasion for branch in decode stage. 
    );
    
    stage_mem : entity work.stage_mem
    port map(
        clk => clk,
        write_en => reg_block_three_out.write_mem_enable,
        result => reg_block_three_out.result, 
        data_two => reg_block_three_out.data_two, 
        read_data => reg_block_four_next.read_data
    );

    registers: process (clk, reg_block_one_next, reg_block_two_next, reg_block_three_next, reg_block_four_next, if_flush) is
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                reg_block_one_out <= (others => (others => '0'));
                reg_block_two_out <= ('0', '0', '0', '0', others => (others => '0'));
                reg_block_three_out <= ('0', '0', '0', others => (others => '0'));
                reg_block_four_out <= ('0', '0', others => (others => '0'));
            else
                if(if_flush = '1') then 
                    reg_block_one_out <= ((others => '0'), NOP);
                else
                    reg_block_one_out <= reg_block_one_next;
                end if;
                reg_block_two_out <= reg_block_two_next;
                reg_block_three_out <= reg_block_three_next;
                reg_block_four_out <= reg_block_four_next;
            end if;
        end if;
    end process registers;

end behavioral;

