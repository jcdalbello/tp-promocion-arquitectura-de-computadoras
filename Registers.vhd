-- ======================
-- ====    Autor Martín Vázquez 
-- ====    rquitectura de Computadoras  - 2024
-- ====
-- ====   Banco de registros de procesador MIPS con escritura en flanco ascendente
-- ======================

library IEEE;
use IEEE.STD_LOGIC_1164.all;	
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Registers is
  port(
    reg1_rd, reg2_rd, reg_wr : in std_logic_vector(4 downto 0);
    data_wr : in std_logic_vector(31 downto 0);
    clk, reset, wr : in std_logic ;
    data1_rd, data2_rd  : out std_logic_vector(31 downto 0)
  );
end Registers;

architecture registers_arch of Registers is

  constant reg_tam : INTEGER := 32;
  
  type t_regs is array(reg_tam-1 downto 0) of std_logic_vector(31 downto 0);
  signal regs: t_regs;
  
begin 

          process (clk,reset)
          begin
            
            if reset= '1' then
              for i in 0 to reg_tam-1 loop
                regs(i) <= (others => '0');
              end loop; 
            elsif (falling_edge(clk)) then
--            elsif (rising_edge(clk)) then
              if (wr = '1') then
                regs(conv_integer(reg_wr)) <= data_wr;
              end if;
            end if; 
          end process; 
        
        data1_rd <= (others=>'0') when (reg1_rd="00000") else regs(conv_integer(reg1_rd)); 
        data2_rd <= (others=>'0') when (reg2_rd="00000") else regs(conv_integer(reg2_rd));
        

end registers_arch;
