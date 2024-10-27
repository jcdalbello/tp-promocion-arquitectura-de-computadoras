-- ======================
-- ====    Autor Martín Vázquez 
-- ====    rquitectura de Computadoras  - 2024
-- ====
-- ====   Unidad Aritmético Lógica del procesador MIPS
-- ======================


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


entity ALU is
    Port ( control : in std_logic_vector(2 downto 0);
           a : in std_logic_vector(31 downto 0);
           b : in std_logic_vector(31 downto 0);
           result : out std_logic_vector(31 downto 0);
           zero : out std_logic);
end ALU;

architecture alu_arch of ALU is

signal o : STD_LOGIC_VECTOR (31 downto 0):= (others=>'0');

begin

    process (a,b,control)
    begin
    
        --and
        if control="000" then
              o <= a and b;
        --or
        elsif control="001" then
              o <= a or b;
        --suma
        elsif control="010" then
              o <= a + b;
        --resta
        elsif control="110" then
              o <= a - b;
              
        --setear si <
        elsif control="111" then
            if a<b then
                o <= x"00000001";	
            else
                o <= x"00000000"; 
            end if ;
        -- shift left 16
        elsif control="100" then
            o <= b(15 downto 0) & x"0000";
        else
            o <= x"00000000"; 
        end if;
    
    end process;


	zero <= '1' when o=x"00000000" else '0';
	result <= o;
	
end alu_arch;
