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
        DEBUG_inst_type : instruction_type_debug;
        lw : std_logic;
        mux_control_src2 : std_logic;
        mux_control_result : std_logic;
        write_mem_enable : std_logic;
        write_back_enable : std_logic;
        mux_ex_one : std_logic_vector(1 downto 0);
        mux_ex_two : std_logic_vector(1 downto 0);
        data_one : std_logic_vector(DATA_WIDTH-1 downto 0);
        data_two : std_logic_vector(DATA_WIDTH-1 downto 0);
        immediate : std_logic_vector(DATA_WIDTH-1 downto 0);
        rd :  std_logic_vector(4 downto 0);
        ALU_control : std_logic_vector(3 downto 0);
        
    end record reg_block_two;
-- SIGNAL DEFINITIONS

    type reg_block_three is record
        DEBUG_inst_type : instruction_type_debug;
        write_mem_enable : std_logic;
        write_back_enable : std_logic;
        mux_control_result : std_logic;
        result : std_logic_vector(DATA_WIDTH-1 downto 0);
        data_two : std_logic_vector(DATA_WIDTH-1 downto 0);
        rd : std_logic_vector(4 downto 0);
        
    end record reg_block_three;
    
    type reg_block_four is record 
        DEBUG_inst_type : instruction_type_debug;
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
signal comp_equal : std_logic;
signal comp : std_logic;
signal comp_u : std_logic;
signal op_code : std_logic_vector(6 downto 0);
signal funct3 : std_logic_vector(2 downto 0);
signal funct7 : std_logic_vector(6 downto 0);
signal rs1 : std_logic_vector(4 downto 0);
signal rs2 : std_logic_vector(4 downto 0);
signal mux_id_two : std_logic;
signal mux_id_one : std_logic;
signal data_two_from_id : std_logic_vector(DATA_WIDTH-1 downto 0);
signal data_one_from_id : std_logic_vector(DATA_WIDTH-1 downto 0);
signal data_one : std_logic_vector(DATA_WIDTH-1 downto 0);
signal data_two : std_logic_vector(DATA_WIDTH-1 downto 0);
signal operand_one : std_logic_vector(DATA_WIDTH-1 downto 0);
signal operand_two : std_logic_vector(DATA_WIDTH-1 downto 0);

signal stall_1, stall_2, stall : std_logic;
signal immediate : std_logic_vector(DATA_WIDTH-1 downto 0);

signal wb_result : std_logic_vector(DATA_WIDTH-1 downto 0);
signal block_wb : std_logic;
-- COMPONENT DEFINITION

constant FORWARD_NONE: std_logic_vector(1 downto 0) := "00";
constant FORWARD_EX_MEM: std_logic_vector(1 downto 0) := "01";
constant FORWARD_MEM_WB: std_logic_vector(1 downto 0) := "10";

component calculate_forwarding is 
    port (  
        rs : in std_logic_vector(4 downto 0);
        rd_ex : in std_logic_vector(4 downto 0);
        rd_mem : in std_logic_vector(4 downto 0);
        rd_wb : in std_logic_vector(4 downto 0);
        ex_wb_enable :in std_logic;
        mem_wb_enable : in std_logic;
        wb_wb_enable : in std_logic;
        lw_ex : in std_logic;
        opcode : in std_logic_vector(6 downto 0);
        ex_mux : out std_logic_vector(1 downto 0);
        id_mux : out std_logic;
        stall : out std_logic
        );
end component; 

begin
    reg_block_two_next.data_one <= data_one;
    reg_block_two_next.data_two <= data_two;
    reg_block_two_next.immediate <= immediate;
    reg_block_three_next.rd <= reg_block_two_out.rd;
    reg_block_three_next.data_two <= reg_block_two_out.data_two;
    reg_block_three_next.write_mem_enable <= reg_block_two_out.write_mem_enable;
    reg_block_three_next.write_back_enable <= reg_block_two_out.write_back_enable;
    reg_block_three_next.mux_control_result <= reg_block_two_out.mux_control_result;
    reg_block_three_next.DEBUG_inst_type <= reg_block_two_out.DEBUG_inst_type;
    
    reg_block_four_next.rd <= reg_block_three_out.rd;
    reg_block_four_next.write_back_enable <= reg_block_three_out.write_back_enable;
    reg_block_four_next.mux_control_result <= reg_block_three_out.mux_control_result;
    reg_block_four_next.ALU_result <= reg_block_three_out.result;
    reg_block_four_next.DEBUG_inst_type <= reg_block_three_out.DEBUG_inst_type;

    -- maybe this should be structured more like an alu with alternating operating modes depending on control signals. 
    comparator : process(data_one, data_two)
    begin
        if(data_one = data_two) then 
            comp_equal <= '1';
        else 
            comp_equal <= '0';
        end if;
        if(signed(data_one) < signed(data_two)) then 
            comp <= '1';
        else
            comp <= '0';
        end if; 
        if(unsigned(data_one) < unsigned(data_two)) then 
            comp_u <= '1';
        else
            comp_u <= '0';
        end if; 
    end process;
    
    branch_control : process(comp_equal, comp, op_code, funct3)
    begin 
        mux_control_pc <= '0';
        if_flush <= '0';
        if(op_code = B_FORMAT) then 
            if((funct3 = "000" and comp_equal ='1') or( funct3 ="001" and comp_equal = '0')or( funct3 ="100" and comp = '1') or( funct3 ="101" and comp_equal = '1')or( funct3 ="110" and (comp_equal = '1' or comp_u = '1'))or( funct3 ="111" and (comp_equal = '0' and comp_u = '0'))) then 
                mux_control_pc <= '1';
                if_flush <= '1';
            end if;
        end if;
    end process;
    
    ALU_control : process(op_code, funct3, funct7, immediate)
    begin 
        reg_block_two_next.mux_control_src2 <= '1';
        reg_block_two_next.ALU_control <= "0000";
        block_wb <= '0';
        -- add
        if((funct3 = "000" and(op_code = I_FORMAT or (op_code = R_FORMAT and funct7 = "0000000"))) or op_code= S_FORMAT or op_code = L_FORMAT) then 
            reg_block_two_next.ALU_control <= "0010";
        -- sub
        elsif(funct3 = "000" and op_code = R_FORMAT and funct7 = "0100000") then
            reg_block_two_next.ALU_control <= "0110";
        -- less than 
        elsif(funct3 = "010" and (op_code = I_FORMAT or op_code = R_FORMAT)) then 
            reg_block_two_next.ALU_control <= "0011";
        -- unsigned less than
        elsif(funct3 = "011" and (op_code = I_FORMAT or op_code = R_FORMAT)) then 
            reg_block_two_next.ALU_control <= "0100";
        -- xor 
        elsif(funct3 = "100" and (op_code = I_FORMAT or op_code = R_FORMAT)) then 
            reg_block_two_next.ALU_control <= "0101";
        -- or 
        elsif(funct3 = "110" and (op_code = I_FORMAT or op_code = R_FORMAT)) then
            reg_block_two_next.ALU_control <= "0001";
        -- and 
        elsif(funct3 = "111" and (op_code = I_FORMAT or op_code = R_FORMAT)) then
            reg_block_two_next.ALU_control <= "0000";  -- technically does not need to be here as and is currently the defalut option, but added for clearity. 
        -- left logical shift 
        elsif(funct3 = "001" and( op_code = I_FORMAT or op_code = R_FORMAT)) then 
            --should we have some kind of error message here that changes the instruction to a NOP if it is wrong somehow, so that it would be easier
            -- to debug wrong instructions. 
            if(immediate(4) = '0') then 
                reg_block_two_next.ALU_control <= "0111";
            else
                block_wb <= '1';
            end if;
        -- right logical or arithmetic shift
        elsif(funct3 = "101") then
            if(op_code = R_FORMAT) then 
                if(immediate(10) = '0') then --maybe this should change to looking at funct7. 
                    -- right logical shift
                        reg_block_two_next.ALU_control <= "1000";
                    else
                    -- right arithmetic shift
                        reg_block_two_next.ALU_control <= "1001";
                    end if;
            end if; 
            if(op_code = I_FORMAT) then
                if(immediate(4) = '0') then 
                    if(immediate(10) = '0') then 
                    -- right logical shift
                        reg_block_two_next.ALU_control <= "1000";
                    else
                    -- right arithmetic shift
                        reg_block_two_next.ALU_control <= "1001";
                    end if;
                else
                    block_wb <= '1';
                end if;
            end if;            
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
    
    write_back_control : process(op_code, block_wb)
    begin 
        reg_block_two_next.write_back_enable <= '0';
        reg_block_two_next.mux_control_result <= '0'; --- means ALU_result ( exe or mem)
        if((op_code = R_FORMAT or op_code = L_FORMAT or op_code = I_FORMAT) and block_wb = '0') then
            reg_block_two_next.write_back_enable <= '1';
        end if; 
        if(op_code = L_FORMAT) then 
            reg_block_two_next.mux_control_result <= '1'; -- means wb from mem stage
        end if; 
    end process;
    
    write_back : process(reg_block_four_out.mux_control_result, reg_block_four_out.ALU_result, reg_block_four_out.read_data)
    begin 
        if(reg_block_four_out.mux_control_result = '0') then 
            data_write <= reg_block_four_out.ALU_result; --for redundancy so that vivado don't optimize away the design
            wb_result <= reg_block_four_out.ALU_result;
        else 
            data_write <= reg_block_four_out.read_data; --for redundancy so that vivado don't optimize away the design
            wb_result <= reg_block_four_out.read_data;
        end if;
    end process;
    
    forward_wb_to_id : process(mux_id_two, mux_id_one, data_two_from_id, data_one_from_id, wb_result)
    begin 
        data_two <= data_two_from_id;
        data_one <= data_one_from_id;
        if(mux_id_two = '1') then 
            data_two <= wb_result;
        end if; 
        
        if(mux_id_one = '1') then 
            data_one <= wb_result;
        end if; 
    end process;
    
    forward_to_ex : process(reg_block_two_out.mux_ex_one, reg_block_two_out.mux_ex_two, reg_block_two_out.data_one, reg_block_two_out.data_two, reg_block_three_out.result, wb_result)
    begin
        operand_one <= reg_block_two_out.data_one;
        operand_two <= reg_block_two_out.data_two;
        if(reg_block_two_out.mux_ex_one = FORWARD_NONE) then
            operand_one <= reg_block_two_out.data_one;
        elsif(reg_block_two_out.mux_ex_one = FORWARD_EX_MEM) then
            operand_one <= reg_block_three_out.result;
        elsif(reg_block_two_out.mux_ex_one = FORWARD_MEM_WB) then
            operand_one <= wb_result;
        end if;
        if(reg_block_two_out.mux_ex_two = FORWARD_NONE) then
            operand_two <= reg_block_two_out.data_two;
        elsif(reg_block_two_out.mux_ex_two = FORWARD_EX_MEM) then
            operand_two <= reg_block_three_out.result;
        elsif(reg_block_two_out.mux_ex_two = FORWARD_MEM_WB) then
            operand_two <= wb_result;
        end if;
    end process;
    
    hazard_control_lw : process(op_code)
    begin 
        reg_block_two_next.lw <= '0';
        if(op_code = L_FORMAT) then 
            reg_block_two_next.lw <= '1';
        end if; 
    end process;
    
    hazard_control_stall : process(stall_1, stall_2)
    begin 
        stall <= '0';
        if(stall_1 = '1' or stall_2 = '1') then
            stall <= '1';
        end if;
    end process;
    
    stage_if : entity work.stage_if
    port map(
        clk             => clk,
        n_rst           => reset_n,
        stall           => stall,
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
        pc_branch_out   => pc_branch,
        immediate_out   => immediate,
        op_code         => op_code, 
        funct3           => funct3,
        funct7          => funct7,
        rs1             => rs1, 
        rs2             => rs2, 
        rd              => reg_block_two_next.rd, 
        data_one        => data_one_from_id, 
        data_two        => data_two_from_id,
        debug_inst_type => reg_block_two_next.DEBUG_inst_type
    );
    
    stage_ex : entity work.stage_ex
    port map(
        ALU_control => reg_block_two_out.ALU_control, 
        data_one => operand_one,
        data_two => operand_two,
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

    calculate_forwarding_1 : calculate_forwarding
    port map (  
        rs => rs1,
        rd_ex => reg_block_two_out.rd,
        rd_mem  => reg_block_three_out.rd,
        rd_wb  => reg_block_four_out.rd,
        ex_wb_enable => reg_block_two_out.write_back_enable,
        mem_wb_enable => reg_block_three_out.write_back_enable,
        wb_wb_enable => reg_block_four_out.write_back_enable,
        opcode => op_code,
        lw_ex => reg_block_two_out.lw,
        ex_mux => reg_block_two_next.mux_ex_one, 
        id_mux => mux_id_one,
        stall => stall_1
        );

    calculate_forwarding_2 : calculate_forwarding
    port map (  
        rs => rs2,
        rd_ex => reg_block_two_out.rd,
        rd_mem  => reg_block_three_out.rd,
        rd_wb  => reg_block_four_out.rd,
        ex_wb_enable => reg_block_two_out.write_back_enable,
        mem_wb_enable => reg_block_three_out.write_back_enable,
        wb_wb_enable => reg_block_four_out.write_back_enable,
        opcode => op_code,
        lw_ex => reg_block_two_out.lw,
        ex_mux => reg_block_two_next.mux_ex_two, 
        id_mux => mux_id_two,
        stall => stall_2
        );
    
    registers: process (clk, reg_block_one_next, reg_block_two_next, reg_block_three_next, reg_block_four_next, if_flush, stall) is
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                reg_block_one_out <= (others => (others => '0'));
                reg_block_two_out <= (None,'0','0', '0', '0', '0', others => (others => '0'));
                reg_block_three_out <= (None,'0', '0', '0', others => (others => '0'));
                reg_block_four_out <= (None,'0', '0', others => (others => '0'));
            else
                if(stall = '1') then 
                    reg_block_two_out <= (None,'0','0', '0', '0', '0', others => (others => '0')); -- redo this one to a NOP instruction
                    reg_block_one_out <= reg_block_one_out;
                elsif(if_flush = '1' or stall = '1') then 
                    reg_block_one_out <= ((others => '0'), NOP);
                    reg_block_two_out <= reg_block_two_next;
                else 
                    reg_block_one_out <= reg_block_one_next;
                    reg_block_two_out <= reg_block_two_next;
                end if;
                reg_block_three_out <= reg_block_three_next;
                reg_block_four_out <= reg_block_four_next;
            end if;
        end if;
    end process registers;

end behavioral;

