-- ======================
-- ====    Autor Martín Vázquez 
-- ====    arquitectura de Computadoras  - 2024
--
-- ====== MIPS uniciclo
-- ======================

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity Processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory

	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end Processor;

architecture processor_arch of Processor is 

    -- declaración de componentes ALU
    component ALU 
        port  (a : in std_logic_vector(31 downto 0);
               b : in std_logic_vector(31 downto 0);
               control : in std_logic_vector(2 downto 0);
               zero : out std_logic;
               result : out std_logic_vector(31 downto 0)); 
    end component;
    
    -- declaración de componente Registers
    component Registers 
        port  (clk : in std_logic;
               reset : std_logic;
               wr : in std_logic;
               reg1_rd : in std_logic_vector(4 downto 0);
               reg2_rd : in std_logic_vector(4 downto 0);
               reg_wr : in std_logic_vector(4 downto 0);
               data_wr : in std_logic_vector(31 downto 0);
               data1_rd : out std_logic_vector(31 downto 0);
               data2_rd : out std_logic_vector(31 downto 0));
    end component;

    -- señales de control 
    signal RegWrite, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, Jump: std_logic;
    signal ALUOp: std_logic_vector(1 downto 0); 

-- declarción de otras señales 
    signal r_wr: std_logic; -- habilitación de escritura en el banco de registros
    signal reg_wr: std_logic_vector(4 downto 0); -- dirección del registro de escritura
    signal data1_reg, data2_reg: std_logic_vector(31 downto 0); -- registros leídos desde el banco de registro
    signal data_w_reg: std_logic_vector(31 downto 0); -- dato a escribir en el banco de registros
    
    signal pc_4: std_logic_vector(31 downto 0); -- para incremento de PC
    signal pc_branch: std_logic_vector(31 downto 0); -- salto por beq
    signal pc_jump: std_logic_vector(31 downto 0); -- para salto incondicional
    signal reg_pc, next_reg_pc: std_logic_vector(31 downto 0); -- correspondientes al registro del program counter
 
    signal ALU_oper_b : std_logic_vector(31 downto 0); -- corrspondiente al segundo operando de ALU
    signal ALU_control: std_logic_vector(2 downto 0); -- señales de control de la ALU
    signal ALU_zero: std_logic; -- flag zero de la ALU
    signal ALU_result: std_logic_vector(31 downto 0); -- resultado de la ALU  

    signal inm_extended: std_logic_vector(31 downto 0); -- describe el operando inmediato de la instrucción extendido a 32 bits

begin 	

-- Interfaz con memoria de Instrucciones
    I_Addr <= ; -- el PC
    I_RdStb <= '1';
    I_WrStb <= '0';
    I_DataOut <= (others => '0'); -- dato que nunca se carga en memoria de programa

    
-- Instanciación de banco de registros
    E_Regs:  Registers 
	   Port map (
			clk => clk, 
			reset => reset, 
			wr => RegWrite,
			reg1_rd => I_DataIn(25 downto 21), 
			reg2_rd => I_DataIn(20 downto 16), 
			reg_wr => ,
			data_wr => , 
			data1_rd => ,
			data2_rd => ); 
			
			
-- mux de para destino de escritura en banco de registros
    
    
-- extensión de signo del operando inmediato de la instrucción
  
    
-- mux correspondiente a segundo operando de ALU
   
        
-- Instanciación de ALU
    E_ALU: ALU port map(
            a => , 
            b => , 
            control => ,
            zero => , 
            result => ALU_result);

-- Control de la ALU
    

    -- determina salto incondicional
    

    -- determina salto condicional por iguales

    
    -- incremento de PC

    
    -- mux que maneja carga de PC
   
-- Contador de programa


 
-- Unidad de Control
  
  
    -- mux que maneja escritura en banco de registros
 

    -- Manejo de memorias de Datos
--    D_Addr <= ; resultado de la ALU
--    D_RdStb <= MemRead;
--    D_WrStb <= MemWrite;
--    D_DataOut <= ALU_result ;

end processor_arch;