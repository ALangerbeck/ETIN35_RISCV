library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.common.all;

entity program_memory is
    
    port (
        clk: in std_logic;
        write_en: in std_logic;
        write_data: in std_logic_vector(DATA_WIDTH-1 downto 0);
        address: in std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0);
        read_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end program_memory;

architecture behavioral of program_memory is

    constant MEMORY_DEPTH: natural := 2 ** PROGRAM_ADDRESS_WIDTH;
    
    
    
    type ram_type is array (0 to 4*MEMORY_DEPTH-1) of std_logic_vector(DATA_WIDTH/4-1 downto 0);
    
    impure function initRAM(filename: in string) return ram_type is
        FILE ram_file: text is in filename;
        variable ram_file_line: line;
        variable instruction: bit_vector(DATA_WIDTH/4-1 downto 0);
        variable ram: ram_type := (others => (others => '0'));
    begin
        for i in ram_type'range loop
            if(not endfile(ram_file)) then
                readline(ram_file, ram_file_line);            
                read(ram_file_line, instruction);
                ram(i) := to_stdlogicvector((instruction));
            end if;
        end loop;        
        return ram;        
    end function;
    
    signal ram: ram_type := initRAM("output.mem");
    
    alias word_address: std_logic_vector(PROGRAM_ADDRESS_WIDTH-1 downto 0) is address(PROGRAM_ADDRESS_WIDTH-1 downto 0);



begin

    instruction_ram: process (clk) is
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                ram(to_integer(unsigned(word_address))) <= write_data(7 downto 0);
                ram(to_integer(unsigned(word_address)+1)) <= write_data(15 downto 8);
                ram(to_integer(unsigned(word_address)+2)) <= write_data(23 downto 16);
                ram(to_integer(unsigned(word_address)+3)) <= write_data(31 downto 24);
            end if;
        end if;
    end process instruction_ram;

    read_data <= ram(to_integer(unsigned(word_address)+3)) & ram(to_integer(unsigned(word_address)+2)) & ram(to_integer(unsigned(word_address)+1)) & ram(to_integer(unsigned(word_address)));


end behavioral;
