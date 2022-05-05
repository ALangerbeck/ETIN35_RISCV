library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity stage_id is
    port(
        clk : in std_logic;
        reset_n : in std_logic;
        pc_in : in std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
        instruction_in : in std_logic_vector(INSTRUCTION_WIDTH-1 downto 0); 
        rd_from_wb : in std_logic_vector(4 downto 0);
        write_en_from_wb : in std_logic;
        result_from_wb : in std_logic_vector(DATA_WIDTH-1 downto 0); 
        
        comp : out std_logic;
        pc_branch_out : out std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
        immediate_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        op_code : out std_logic_vector(6 downto 0);
        funct3 : out std_logic_vector(2 downto 0);
        funct7 : out std_logic_vector(6 downto 0);
        rd : out std_logic_vector(4 downto 0);
        rs1 : out std_logic_vector(4 downto 0);
        rs2 : out std_logic_vector(4 downto 0);
        data_one : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_two : out std_logic_vector(DATA_WIDTH-1 downto 0);
        debug_inst_type : out instruction_type_debug
    );
end stage_id;

architecture behavioral of stage_id is

-- TYPE DEFINITIONS

 type instruction_type is record
        opcode: std_logic_vector(6 downto 0);
        rd : std_logic_vector(4 downto 0);
        funct3 : std_logic_vector(2 downto 0);
        rs1 : std_logic_vector(4 downto 0);
        rs2 : std_logic_vector(4 downto 0);
        funct7 : std_logic_vector(6 downto 0);
 end record instruction_type;

-- SIGNAL DEFINITIONS

--Double check that the read of the register file happens asynchronously
signal read_data_one, read_data_two : std_logic_vector(DATA_WIDTH-1 downto 0);
signal instruction : instruction_type;
signal imm_gen_in : std_logic_vector(11 downto 0);
signal imm_gen_out: std_logic_vector(DATA_WIDTH-1 downto 0);
signal imm_gen_shifted, pc_temp_calc  : std_logic_vector(12 downto 0);
signal debug_instruction_type : instruction_type_debug;

-- COMPONENT DEFINITION

component sign_extender is 
    generic( I: integer;
             O: integer);
    port (  
            input : in std_logic_vector(I-1 downto 0);
            output  : out std_logic_vector(O-1 downto 0)
         );
end component; 

begin

    instruction <= (  opcode  => instruction_in(6 downto 0),
                      rd => instruction_in(11 downto 7),
                      funct3 => instruction_in(14 downto 12),
                      rs1 => instruction_in(19 downto 15),
                      rs2 => instruction_in(24 downto 20),
                      funct7=> instruction_in(31 downto 25));
                      
    op_code <= instruction.opcode;
    funct3 <= instruction.funct3;
    funct7 <= instruction.funct7;
    rd <= instruction.rd;
    data_one <= read_data_one;
    data_two <= read_data_two;
    debug_inst_type <= debug_instruction_type;
    rs1 <= instruction.rs1;
    rs2 <= instruction.rs2;
    
    immediate_genarator : process(instruction.opcode,imm_gen_out, instruction.opcode, imm_gen_out, instruction.funct7,instruction.rs2,instruction.rd) --only implemented to check a few opcodes, might need to be extended. 
    begin
        immediate_out <= imm_gen_out;
        if(instruction.opcode = L_FORMAT or instruction.opcode = I_FORMAT) then 
            imm_gen_in <=  instruction.funct7 & instruction.rs2;
        elsif(instruction.opcode = S_FORMAT) then 
            imm_gen_in <= instruction.funct7 & instruction.rd;
        elsif(instruction.opcode = B_FORMAT) then 
            imm_gen_in <= instruction.funct7(6) & instruction.rd(0) & instruction.funct7(5 downto 0) & instruction.rd(4 downto 1);
        else 
            imm_gen_in <= (others => '0');
        end if;
    end process;
    
    pc_branch : process(imm_gen_out, pc_in,imm_gen_shifted, pc_temp_calc)
    begin 
        imm_gen_shifted <= imm_gen_out(11 downto 0) & '0'; --unsure if this is the correct left shift one that they want us to do. Double check later. 
        pc_temp_calc <= imm_gen_shifted + ("000000" & pc_in);
        pc_branch_out <= pc_temp_calc(PROGRAM_ADDRESS_WIDTH-1 downto 0);
    end process;
    
    comparator : process(read_data_one, read_data_two)
    begin
        if(read_data_one = read_data_two) then 
            comp <= '1';
        else 
            comp <= '0';
        end if;
    end process;

    debug_opcode : process (instruction.opcode)
    begin
        case instruction.opcode is
            when Register_type =>
                debug_instruction_type <= Reg;	
            when Integer_Type_Arithmetic =>
                debug_instruction_type <= Int_Arith;
            when Integer_Type_Load =>
                debug_instruction_type <= Int_Load;
            when Store_type =>
                debug_instruction_type <= Store;
            when Branch_type =>
                debug_instruction_type <= Branch;
            when Upper_type =>
                debug_instruction_type <= U_type;
            when others  =>
                debug_instruction_type <= Unknown;
         end case;
    end process;
     
    reg_file: entity work.register_file 
    port map (
        clk => clk,
        reset_n => reset_n,
        write_en => write_en_from_wb,
        read1_id => instruction.rs1,
        read2_id => instruction.rs2,
        write_id => rd_from_wb,
        write_data => result_from_wb,
        read1_data => read_data_one,
        read2_data => read_data_two
    );

    inst_sign_extender : sign_extender
    generic map ( I => 12,
                  O => 32)
    port map (  
            input => imm_gen_in,
            output  => imm_gen_out
         );

end behavioral;