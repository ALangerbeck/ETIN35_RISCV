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
signal instruction, instruction_ordi, instruction_comp : instruction_type;
signal imm_gen_in : std_logic_vector(11 downto 0);
signal imm_gen_out: std_logic_vector(DATA_WIDTH-1 downto 0);
signal imm_gen_in_c : std_logic_vector(5 downto 0);
signal imm_gen_out_c : std_logic_vector(11 downto 0);
signal imm_gen_shifted, pc_temp_calc  : std_logic_vector(12 downto 0);
signal debug_instruction_type : instruction_type_debug;

signal opcode_c : std_logic_vector(6 downto 0);
signal rd_c : std_logic_vector(4 downto 0);
signal funct3_c : std_logic_vector(2 downto 0);
signal rs1_c : std_logic_vector(4 downto 0);
signal rs2_c : std_logic_vector(4 downto 0);
signal funct7_C : std_logic_vector(6 downto 0);


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

    instruction_ordi <= (  opcode  => instruction_in(6 downto 0),
                  rd => instruction_in(11 downto 7),
                  funct3 => instruction_in(14 downto 12),
                  rs1 => instruction_in(19 downto 15),
                  rs2 => instruction_in(24 downto 20),
                  funct7=> instruction_in(31 downto 25));
                      
    instruction_comp <= (  opcode  => opcode_c,
                  rd => rd_c,
                  funct3 => funct3_c,
                  rs1 => rs1_c,
                  rs2 => rs2_c,
                  funct7=> funct7_c);             
                      
    op_code <= instruction.opcode;
    funct3 <= instruction.funct3;
    funct7 <= instruction.funct7;
    rd <= instruction.rd;
    data_one <= read_data_one;
    data_two <= read_data_two;
    debug_inst_type <= debug_instruction_type;
    rs1 <= instruction.rs1;
    rs2 <= instruction.rs2;
    
    pick_format : process(instruction_ordi, instruction_comp) 
    begin 
         if(instruction_in(0) = '0' or instruction_in(1) = '0') then 
            instruction <= instruction_comp;
         else
            instruction <= instruction_ordi;
         end if;
    
    end process;
    
    sign_extend_compressed : process(instruction_in)
    begin
        imm_gen_in_c <= "000000";
        --c.addi
        if(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 13) = "000") then 
            imm_gen_in_c <= instruction_in(12) & instruction_in(6 downto 2);
        --c.andi
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 13) = "100" and instruction_in(11 downto 10)="10") then 
            imm_gen_in_c <= instruction_in(12) & instruction_in(6 downto 2);
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 13) = "010") then 
            imm_gen_in_c <= instruction_in(12) & instruction_in(6 downto 2);
        end if;
    end process;
    
    compressed_decode : process(instruction_in, imm_gen_out_c)
    begin 
        -- verkar som funct3_c <= instruction_in(15 downto 13); -- not for sw
        if(instruction_in(1 downto 0) = "00" and instruction_in(15 downto 13) =  "010") then --c.lw
            opcode_c <= "0000011";
            rd_c <= ( "00" & instruction_in(4 downto 2)) +8;
            funct3_c <= "010";
            rs1_c <= ( "00" & instruction_in(9 downto 7)) +8;
            rs2_c <= instruction_in(11 downto 10) & instruction_in(6) & "00";
            funct7_c <= "00000" & instruction_in(12) & instruction_in(5);
        -- c.sw
        elsif(instruction_in(1 downto 0) = "00" and instruction_in(15 downto 13) = "110") then 
            opcode_c <= "0100011";
            rd_c <= instruction_in(11 downto 10) & instruction_in(6) & "00";
            funct3_c <= "010";
            rs1_c <= ("00" & instruction_in(9 downto 7)) +8;
            rs2_c <= ( "00" & instruction_in(4 downto 2)) +8;
            funct7_c <= "00000" & instruction_in(12) & instruction_in(5);
        -- c.add - invalid when rd or rs2 equal 0, should we controll for that?
        elsif(instruction_in(1 downto 0) = "10" and instruction_in(15 downto 12) = "1001") then 
            opcode_c <= "0110011";
            rd_c <= instruction_in(11 downto 7);
            funct3_c <= "000";
            rs1_c <= instruction_in(11 downto 7);
            rs2_c <= instruction_in(6 downto 2);
            funct7_c <= "0000000";
        -- c. sub 
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 10) = "100011" and instruction_in(6 downto 5)="00") then 
            opcode_c <= "0110011";
            rd_c <= ( "00" & instruction_in(9 downto 7)) + 8;
            funct3_c <= "000";
            rs1_c <= ( "00" & instruction_in(9 downto 7)) + 8;
            rs2_c <= ( "00" & instruction_in(4 downto 2)) + 8;
            funct7_c <= "0100000";
            --c.addi -- for this one rd and rs1 is not allowed to be zero, sbould we program in that in vivado?
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 13) = "000") then 
            opcode_c <= "0010011";
            rd_c <= instruction_in(11 downto 7);
            funct3_c <= "000";
            rs1_c <= instruction_in(11 downto 7);
            rs2_c <= imm_gen_out_c(4 downto 0);
            funct7_c <= imm_gen_out_c(11 downto 5);
            --c.and 
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 10) = "100011" and instruction_in(6 downto 5)="11") then 
            opcode_c <= "0110011";
            rd_c <= ( "00" & instruction_in(9 downto 7))+8;
            funct3_c <= "111";
            rs1_c <= ( "00" & instruction_in(9 downto 7))+8;
            rs2_c <= ( "00" & instruction_in(4 downto 2))+8;
            funct7_c <= "0000000";
            --c.andi
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 13) = "100" and instruction_in(11 downto 10)="10") then 
            opcode_c <= "0010011";
            rd_c <= ( "00" & instruction_in(9 downto 7))+8;
            funct3_c <= "111";
            rs1_c <= ( "00" & instruction_in(9 downto 7))+8;
            rs2_c <= imm_gen_out_c(4 downto 0);
            funct7_c <= imm_gen_out_c(11 downto 5);
            --c.or 
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 10) = "100011" and instruction_in(6 downto 5)="10") then 
            opcode_c <= "0110011";
            rd_c <= ( "00" & instruction_in(9 downto 7))+8;
            funct3_c <= "110";
            rs1_c <= ( "00" & instruction_in(9 downto 7))+8;
            rs2_c <= ( "00" & instruction_in(4 downto 2))+8;
            funct7_c <= "0000000";
            --c.or 
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 10) = "100011" and instruction_in(6 downto 5)="01") then 
            opcode_c <= "0110011";
            rd_c <= ( "00" & instruction_in(9 downto 7))+8;
            funct3_c <= "100";
            rs1_c <= ( "00" & instruction_in(9 downto 7))+8;
            rs2_c <= ( "00" & instruction_in(4 downto 2))+8;
            funct7_c <= "0000000";
            --c.mv
        elsif(instruction_in(1 downto 0) = "10" and instruction_in(15 downto 12) = "1000") then 
            opcode_c <= "0110011";
            rd_c <= instruction_in(11 downto 7);
            funct3_c <= "000";
            rs1_c <= "00000";
            rs2_c <= instruction_in(6 downto 2);
            funct7_c <= "0000000";
            --c.li
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 13) = "010") then 
            opcode_c <= "0010011";
            rd_c <= instruction_in(11 downto 7);
            funct3_c <= "000";
            rs1_c <= "00000";
            rs2_c <= imm_gen_out_c(4 downto 0);
            funct7_c <= imm_gen_out_c(11 downto 5);
            --c.slli
        elsif(instruction_in(1 downto 0) = "10" and instruction_in(15 downto 13) = "000") then 
            opcode_c <= "0010011";
            rd_c <= instruction_in(11 downto 7);
            funct3_c <= "001";
            rs1_c <= instruction_in(11 downto 7);
            rs2_c <= instruction_in(6 downto 2);
            funct7_c <= "000000" & instruction_in(12);
            --c.srai
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 13) = "100" and instruction_in(11 downto 10)="01") then 
            opcode_c <= "0010011";
            rd_c <= ( "00" & instruction_in(9 downto 7))+8;
            funct3_c <= "101";
            rs1_c <= ( "00" & instruction_in(9 downto 7))+8;
            rs2_c <= instruction_in(6 downto 2);
            funct7_c <= "010000" & instruction_in(12);
            --c.srli 
        elsif(instruction_in(1 downto 0) = "01" and instruction_in(15 downto 13) = "100" and instruction_in(11 downto 10)="00") then 
            opcode_c <= "0010011";
            rd_c <= ( "00" & instruction_in(9 downto 7))+8;
            funct3_c <= "101";
            rs1_c <= ( "00" & instruction_in(9 downto 7))+8;
            rs2_c <= instruction_in(6 downto 2);
            funct7_c <= "000000" & instruction_in(12);
        else -- if no op_code fits we import a nop instruction. - has in instruction manual same format as addi, but here I just expand it to the Nop instruction in the common file. 
            opcode_c <= NOP(6 downto 0);
            rd_c <= NOP(11 downto 7);
            funct3_c <= NOP(14 downto 12);
            rs1_c <= NOP(19 downto 15);
            rs2_c <= NOP(24 downto 20);
            funct7_c <= NOP(31 downto 25);
        end if; 
    end process;
    
    immediate_genarator : process(instruction.opcode,imm_gen_out, instruction.opcode, imm_gen_out, instruction.funct7,instruction.rs2,instruction.rd) --only implemented to check a few opcodes, might need to be extended. 
    begin
        immediate_out <= imm_gen_out;
        if(instruction.opcode = L_FORMAT or instruction.opcode = I_FORMAT or instruction.opcode = R_FORMAT) then 
            imm_gen_in <=  instruction.funct7 & instruction.rs2;
        elsif(instruction.opcode = S_FORMAT) then 
            imm_gen_in <= instruction.funct7 & instruction.rd;
        elsif(instruction.opcode = B_FORMAT) then 
            imm_gen_in <= instruction.funct7(6) & instruction.rd(0) & instruction.funct7(5 downto 0) & instruction.rd(4 downto 1);
        elsif(instruction.opcode = U_FORMAT) then 
            imm_gen_in <= (others => '0');
        else 
            if(instruction.opcode = U_FORMAT) then 
                immediate_out <= instruction.funct7 & instruction.rs2 & instruction.rs1 & instruction.funct3 & "000000000000";
            end if;
            imm_gen_in <= (others => '0');
        end if;
    end process;
    
    pc_branch : process(imm_gen_out, pc_in,imm_gen_shifted, pc_temp_calc)
    begin 
        imm_gen_shifted <= imm_gen_out(11 downto 0) & '0'; --unsure if this is the correct left shift one that they want us to do. Double check later. 
        pc_temp_calc <= imm_gen_shifted + ("000000" & pc_in);
        pc_branch_out <= pc_temp_calc(PROGRAM_ADDRESS_WIDTH-1 downto 0);
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
    
    inst_sign_extender_c : sign_extender
    generic map ( I => 6,
                  O => 12)
    port map (  
            input => imm_gen_in_c,
            output  => imm_gen_out_c
         );
    
    inst_sign_extender : sign_extender
    generic map ( I => 12,
                  O => 32)
    port map (  
            input => imm_gen_in,
            output  => imm_gen_out
         );

end behavioral;