-- ======================
-- ====    Autor Martin Vazquez 
-- ====    arquitectura de Computadoras  - 2024
--
-- ====== MIPS uniciclo
-- ======================

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;

entity Processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
    I_DataOut   : out std_logic_vector(31 downto 0); -- no se usa
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory

	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0); -- Write data
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end Processor;

architecture processor_arch of Processor is 

    -- declaracion de componentes ALU
    component ALU 
        port  (a		: in std_logic_vector(31 downto 0);
               b		: in std_logic_vector(31 downto 0);
               control	: in std_logic_vector(2 downto 0);
               zero		: out std_logic;
               result	: out std_logic_vector(31 downto 0)); 
    end component;
    
    -- declaracion de componente Registers
    component Registers 
        port  (clk		: in std_logic;
               reset	: std_logic;
               wr		: in std_logic;
               reg1_rd	: in std_logic_vector(4 downto 0);
               reg2_rd	: in std_logic_vector(4 downto 0);
               reg_wr	: in std_logic_vector(4 downto 0);
               data_wr	: in std_logic_vector(31 downto 0);
               data1_rd : out std_logic_vector(31 downto 0);
               data2_rd	: out std_logic_vector(31 downto 0));
    end component;
    
  	-- declaracion de la memoria de programa
    component ProgramMemory
    	port (
          Addr		: in std_logic_vector(31 downto 0);
          DataIn	: in std_logic_vector(31 downto 0);
          RdStb 	: in std_logic ;
          WrStb		: in std_logic ;
          Clk		: in std_logic ;
          Reset		: in std_logic ;						  
          DataOut	: out std_logic_vector(31 downto 0));
    end component;

    -- declaracion de la memoria de datos
    component DataMemory
    	port (
			Addr	: in std_logic_vector(31 downto 0);
			DataIn	: in std_logic_vector(31 downto 0);
			RdStb	: in std_logic ;
			WrStb	: in std_logic ;
			Clk		: in std_logic ;
			Reset	: in std_logic ;
			DataOut : out std_logic_vector(31 downto 0));
    end component;

    -- señales de control 
    signal RegWrite, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, Jump: std_logic;
    signal ALUOp: std_logic_vector(1 downto 0); 

-- declarcion de otras señales 
    signal r_wr: std_logic; -- habilitacion de escritura en el banco de registros
    signal reg_wr: std_logic_vector(4 downto 0); -- direccion del registro de escritura
    signal data1_reg, data2_reg: std_logic_vector(31 downto 0); -- registros leidos desde el banco de registro
    signal data_w_reg: std_logic_vector(31 downto 0); -- dato a escribir en el banco de registros
    
    signal pc_4: std_logic_vector(31 downto 0); -- para incremento de PC
    signal pc_branch: std_logic_vector(31 downto 0); -- salto por beq
    signal pc_jump: std_logic_vector(31 downto 0); -- para salto incondicional
    signal reg_pc, next_reg_pc: std_logic_vector(31 downto 0); -- correspondientes al registro del program counter
    signal direccion_salto_condicional: std_logic_vector(31 downto 0); -- direccion condicional del beq
    signal direccion_salto_incondicional: std_logic_vector(31 downto 0); -- direccion incondicional del jump
 
    signal ALU_oper_b : std_logic_vector(31 downto 0); -- corrspondiente al segundo operando de ALU
    signal ALU_control: std_logic_vector(2 downto 0); -- señales de control de la ALU
    signal ALU_zero: std_logic; -- flag zero de la ALU
    signal ALU_result: std_logic_vector(31 downto 0); -- resultado de la ALU  

    signal inm_extended: std_logic_vector(31 downto 0); -- describe el operando inmediato de la instruccion extendido a 32 bits
    signal inm_extended_shifted: std_logic_vector(31 downto 0); -- inm_extended shifteado 2 bits a la izquierda
    
    signal target_address_extended: std_logic_vector(27 downto 0); -- target_address extendido 2 bits
    
    signal extension_offset: std_logic_vector(15 downto 0); -- cadena para los 16 1s o 0s para la extension de signo del offset
    
    signal data1_RegRead, data2_RegRead: std_logic_vector(31 downto 0); -- salida de los registros antes de la ALU
    signal data_Write: std_logic_vector(31 downto 0); -- dato para escribir en el registro (tipo-R o lw)
    signal I_DataIn_signal, D_DataIn_signal: std_logic_vector(31 downto 0); -- reciben el dato de entrada de la memoria de instrucciones y de datos
    
    -- segmentos de las instrucciones
    signal op: std_logic_vector(5 downto 0);
    signal rs: std_logic_vector(4 downto 0);
    signal rt: std_logic_vector(4 downto 0);
    signal rd: std_logic_vector(4 downto 0);
    signal shamt: std_logic_vector(4 downto 0);
    signal funct: std_logic_vector(5 downto 0);
    signal offset: std_logic_vector(15 downto 0);
    signal target_address: std_logic_vector(25 downto 0);

begin 	

-- Interfaz con memoria de Instrucciones
    I_Addr <= reg_pc; -- el pc
    I_RdStb <= '1';
    I_WrStb <= '0';
    I_DataOut <= (others => '0'); -- dato que nunca se carga en memoria de programa


-- Instanciacion de banco de registros
	E_Regs:  Registers 
		Port map (
			clk => clk, 
			reset => reset, 
			wr => RegWrite,
			reg1_rd => I_DataIn(25 downto 21),
			reg2_rd => I_DataIn(20 downto 16),
			reg_wr => reg_wr,
			data_wr => data_Write, 
			data1_rd => data1_RegRead,
			data2_rd => data2_RegRead
		);


-- signals para las partes de la instruccion

	op <= I_DataIn(31 downto 26);
    rs <= I_DataIn(25 downto 21);
    rt <= I_DataIn(20 downto 16);
    rd <= I_DataIn(15 downto 11);
    shamt <= I_DataIn(10 downto 6); -- no se usa
    funct <= I_DataIn(5 downto 0);
    offset <= I_DataIn(15 downto 0);
    target_address <= I_DataIn(25 downto 0);

	-- PC
	-- incremento normal del pc
	pc_4 <= std_logic_vector(unsigned(reg_pc) + 4);
    
    -- shifteado 2 bits a la izquieda
    inm_extended_shifted <= inm_extended(29 downto 0) & "00";

    -- incremento por beq
    direccion_salto_condicional <= std_logic_vector(signed(pc_4) + signed(inm_extended_shifted)); -- inm_extended = offset ya pasado por la extension de signo

    -- extendido 2 bits
    target_address_extended <= target_address(25 downto 0) & "00";
    
    -- incremento por jump
    direccion_salto_incondicional <= pc_4(31 downto 28) & target_address_extended;

    -- MUX modelado con las tres entradas posibles del pc: incremento normal, salto condicional y salto incondicional
    next_reg_pc <= (direccion_salto_condicional) when (Branch and ALU_zero) else direccion_salto_incondicional when (Jump) else pc_4;

	-- caja del pc
	process (clk, reset)
	begin
      if reset= '1' then
        reg_pc <= (others =>'0');
      elsif (rising_edge(clk)) then
        if (rising_edge(clk)) then
            reg_pc <= next_reg_pc;
          end if;
      end if; 
    end process;

	-- mux de para destino de escritura en banco de registros
	-- mux para controlar direccion de entrada del banco de registros
    reg_wr <= rd when RegDst else rt;


-- extension de signo del operando inmediato de la instruccion
	extension_offset <= (others => I_DataIn(15)); -- 16 1s o 0s, dependiendo el bit mas significativo del offset
	inm_extended <= extension_offset & I_DataIn(15 downto 0); -- offset = I_DataIn(15 downto 0)


-- mux correspondiente a segundo operando de ALU
    ALU_oper_b <= inm_extended when ALUSrc else data2_RegRead;

-- Instanciacion de ALU
    E_ALU: ALU port map(
            a => data1_RegRead , 
            b => ALU_oper_b , 
            control => ALU_control ,
            zero => ALU_zero , 
            result => ALU_result);

-- Control de la ALU
    process (ALUOp, funct)
    begin
    	case ALUOp is
        	when "00" => -- lw o sw
            	ALU_control <= "010";
            
           	when "01" => -- branch
            	ALU_control <= "110";
                
            when "10" => -- tipo-R
            	case funct is
                	when "100000" => -- add
                    	ALU_control <= "010";
                   	when "100010" => -- sub
                    	ALU_control <= "110";
                    when "100100" => -- and
                    	ALU_control <= "000";
                    when "100101" => -- or
                    	ALU_control <= "001";
                    when "101010" => -- slt
                    	ALU_control <= "111";
                    when others => -- codigo sin usar
                    	ALU_control <= "011";
                end case;

            when others => -- ALUOp incorrecto
            	ALU_control <= "011";


          
    	end case;
        -- PREGUNTAR SI ESTA BIEN HACER TODO ESTO AFUERA DEL PROCESO
            -- determina salto incondicional
            -- determina salto condicional por iguales
            -- incremento de PC
            -- mux que maneja carga de PC
    end process;
   
-- Contador de programa


-- Unidad de Control
-- Para setear las signals RegWrite, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, Jump: std_logic y ALUOp std_logic_vector(1 downto 0);
-- Se usan los 6 bits mas significativos de la instruccion (31 downto 26)
	process (op)
	begin
    	if op = "000000" then -- instrucciones de tipo-R
        	RegWrite <= '1';
            RegDst	 <= '1';
            Branch	 <= '0';
            MemRead	 <= '0';
            MemtoReg <= '0';
            MemWrite <= '0';
            ALUSrc	 <= '0';
            Jump	 <= '0';
            ALUOp	 <= "10";
            
        elsif op = "100011" then -- lw
        	RegWrite <= '1';
            RegDst	 <= '0';
            Branch	 <= '0';
            MemRead	 <= '1';
            MemtoReg <= '1';
            MemWrite <= '0';
            ALUSrc	 <= '1';
            Jump	 <= '0';
            ALUOp	 <= "00";
            
        elsif op = "101011" then -- sw
        	RegWrite <= '0';
            -- RegDst no importa
            Branch	 <= '0';
            MemRead	 <= '0';
            -- MemtoReg no importa
            MemWrite <= '1';
            ALUSrc	 <= '1';
            Jump	 <= '0';
            ALUOp	 <= "00";
            
        elsif op = "000100" then -- beq
        	RegWrite <= '0';
            -- RegDst no importa
            Branch	 <= '1';
            MemRead	 <= '0';
            -- MemtoReg no importa
            MemWrite <= '0';
            ALUSrc	 <= '0';
            Jump	 <= '0';
            ALUOp	 <= "01";
        
        elsif op = "000010" then -- jump
        	RegWrite <= '0';
            --RegDst no importa, no se va a guardar en el banco de regs
            Branch	 <= '0';
            MemRead	 <= '0';
            --MemtoReg no importa
            MemWrite <= '0';
            --ALUSrc no importa
            Jump	 <= '1';
            --ALUOp no importa
            
        else -- codigo de instruccion incorrecto
        	RegWrite <= '0';
            RegDst	 <= '0';
            Branch	 <= '0';
            MemRead	 <= '0';
            MemtoReg <= '0';
            MemWrite <= '0';
            ALUSrc	 <= '0';
            Jump	 <= '0';
            ALUOp	 <= "00";
        end if;
    end process;

	-- mux que maneja escritura en banco de registros
    data_Write <= D_DataIn when MemtoReg else ALU_result;

    -- Manejo de memorias de Datos
    
	D_Addr	<= ALU_result;
    D_RdStb	<= MemRead;
    D_WrStb	<= MemWrite;
    D_DataOut <= data2_RegRead;

end processor_arch;