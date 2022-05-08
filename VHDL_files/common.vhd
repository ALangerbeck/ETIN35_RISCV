library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is

    constant INSTRUCTION_WIDTH: natural := 32;
    constant PROGRAM_ADDRESS_WIDTH: natural := 7;
    constant DATA_ADDRESS_WIDTH: natural := 6;
    constant CPU_DATA_WIDTH: natural := 32;
    constant REGISTER_FILE_ADDRESS_WIDTH: natural := 5;
    constant DATA_WIDTH: natural := 32;
    constant ADDRESS_WIDTH: natural := 6;
    constant ADDRESS_WIDTH_REG_FILE: natural := 5;
    
    constant R_FORMAT : std_logic_vector(6 downto 0) := "0110011";
    constant I_FORMAT : std_logic_vector(6 downto 0) := "0010011";
    constant L_FORMAT : std_logic_vector(6 downto 0) := "0000011";
    constant S_FORMAT : std_logic_vector(6 downto 0) := "0100011";
    constant B_FORMAT : std_logic_vector(6 downto 0) := "1100011";
    constant NOP : std_logic_vector(DATA_WIDTH -1 downto 0) := "00000000000000000000000000110011"; --should be an

    -- Debug constants
    constant Register_type : std_logic_vector := "0110011";
    constant Integer_Type_Arithmetic : std_logic_vector := "0010011";
    constant Integer_Type_Load : std_logic_vector := "0000011";
    constant Store_type : std_logic_vector :=  "0100011";
    constant Branch_type : std_logic_vector :=  "1100011";
    constant Upper_type : std_logic_vector := "0110111";
    
    type instruction_type_debug is (U_type,J_type,Int_Load,Int_Arith,Store,Branch,Reg,Unknown,None);
    
    --constant OP_ADDI : std_logic_vector(6 downto 0) := "0110011";
end common;
