-- ======================
-- ====    Autor Martín Vázquez 
-- ====    Arquitectura de Computadoras  - 2024
--
-- ====== Memoria de Programa -  lectura de una palabra (4 bytes)

-- ======================

library STD;
use STD.textio.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_textio.all;


entity ProgramMemory is
    generic(
        C_ELF_FILENAME    : string := "program";
        C_MEM_SIZE        : integer := 1024
	 );
    Port ( Addr : in std_logic_vector(31 downto 0);
           DataIn : in std_logic_vector(31 downto 0);
           RdStb : in std_logic ;
           WrStb : in std_logic ;
           Clk : in std_logic ;
           Reset: in std_logic;						  
           DataOut : out std_logic_vector(31 downto 0));
end ProgramMemory;

architecture mem_arch of ProgramMemory is 
	
    type matriz is array(0 to C_MEM_SIZE-1) of STD_LOGIC_VECTOR(7 downto 0);
    signal memo: matriz;
    signal aux : STD_LOGIC_VECTOR (31 downto 0):= (others=>'0'); 
    


begin

    process (clk)
            variable init_memory : boolean := true;
            variable datum : STD_LOGIC_VECTOR(31 downto 0);
            file bin_file : text is C_ELF_FILENAME;
            variable  current_line : line;
            variable address:integer;
    
    begin
	
        if init_memory then 
            -- primero iniciamos la memoria con ceros
                for i in 0 to C_MEM_SIZE-1 loop
                    memo(i) <= (others => '0');
                end loop; 
                
            -- luego cargamos el archivo en la misma
                address := 0;  
                while (not endfile (bin_file)) loop
                    
                    readline (bin_file, current_line);					
                    hread(current_line, datum);
                    assert address<C_MEM_SIZE 
                        report "Direccion fuera de rango en el fichero de la memoria"
                    severity failure;
                    memo(address) <= datum(31 downto 24);
                    memo(address+1) <= datum(23 downto 16);
                    memo(address+2) <= datum(15 downto 8);
                    memo(address+3) <= datum(7 downto 0);
                    address := address + 4;
            end loop;
                -- por ultimo cerramos el archivo y actualizamos el flag de memoria cargada
                file_close (bin_file);
                init_memory := false;
 
       elsif (falling_edge(Clk)) then
             address:= conv_integer(Addr(30 downto 0));
             if (WrStb = '1') then
                memo(address) <= DataIn(31 downto 24);
                memo(address+1) <= DataIn(23 downto 16);
                memo(address+2) <= DataIn(15 downto 8);
                memo(address+3) <= DataIn(7 downto 0);
                
             elsif (RdStb = '1')then
                aux(31 downto 24) <= memo(address);
                aux(23 downto 16) <= memo(address+1);
                aux(15 downto 8) <= memo(address+2);
                aux(7 downto 0) <= memo(address+3);
             end if;
       end if;
    end process;

    DataOut <= aux;	 


end mem_arch;
